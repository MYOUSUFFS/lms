"""
LMS RAG Backend - Direct Chat API
Q&A without documents - just ask questions!
"""

import time
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field

from app.core.security import verify_api_key
from app.services.llm import get_llm_service

router = APIRouter(prefix="/chat", tags=["Chat"])


class ChatRequest(BaseModel):
    """Direct chat request - no documents needed."""
    message: str = Field(
        ..., 
        min_length=1, 
        max_length=5000, 
        description="Your question",
        examples=["What is Python?", "Explain machine learning", "Write a hello world in JavaScript"]
    )
    system_prompt: Optional[str] = Field(
        default=None,
        description="Custom system prompt (optional)"
    )


class ChatResponse(BaseModel):
    """Chat response."""
    message: str = Field(..., description="Your question")
    answer: str = Field(..., description="AI response")
    model_used: str = Field(..., description="Model that generated the response")
    processing_time_ms: float = Field(..., description="Time taken in milliseconds")


# Default system prompt for general Q&A
DEFAULT_CHAT_PROMPT = """You are a helpful AI assistant. 

Instructions:
- Provide clear, accurate, and concise answers
- If you don't know something, say so honestly
- Use examples when helpful
- Format code properly with markdown code blocks
- Be friendly and professional"""


@router.post(
    "",
    response_model=ChatResponse,
    summary="Direct Q&A Chat",
    description="Ask any question and get an answer - no documents needed!",
)
async def chat(
    request: ChatRequest,
    _: str = Depends(verify_api_key),
):
    """
    Direct Q&A with LLM - No documents required!
    
    Just ask any question and get an answer.
    
    **Examples:**
    - "What is Python?"
    - "Explain machine learning in simple terms"
    - "Write a hello world program in JavaScript"
    - "What's the difference between SQL and NoSQL?"
    """
    start_time = time.time()
    
    llm_service = get_llm_service()
    
    system_prompt = request.system_prompt or DEFAULT_CHAT_PROMPT
    
    try:
        answer, model_used = await llm_service.generate(
            prompt=request.message,
            system_prompt=system_prompt,
            context=None,  # No document context
        )
    except RuntimeError as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"LLM not available: {str(e)}. Make sure Ollama is running.",
        )
    
    processing_time = round((time.time() - start_time) * 1000, 2)
    
    return ChatResponse(
        message=request.message,
        answer=answer,
        model_used=model_used,
        processing_time_ms=processing_time,
    )


@router.post(
    "/stream",
    summary="Streaming Chat",
    description="Chat with streaming response",
)
async def chat_stream(
    request: ChatRequest,
    _: str = Depends(verify_api_key),
):
    """Chat with streaming response - see the answer as it's generated."""
    llm_service = get_llm_service()
    
    system_prompt = request.system_prompt or DEFAULT_CHAT_PROMPT
    
    async def generate():
        try:
            async for chunk, _ in llm_service.generate_stream(
                prompt=request.message,
                system_prompt=system_prompt,
                context=None,
            ):
                yield chunk
        except Exception as e:
            yield f"\n\nError: {str(e)}"
    
    return StreamingResponse(
        generate(),
        media_type="text/plain",
    )
