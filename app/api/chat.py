"""
LMS RAG Backend - Direct Chat API with LangChain
Q&A with conversation memory powered by LangChain
"""

import time
from typing import Optional, List

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field

from app.core.security import verify_api_key
from app.services.langchain_chat import get_langchain_chat_service, clear_memory

router = APIRouter(prefix="/chat", tags=["Chat"])


class ChatMessage(BaseModel):
    """A single message in conversation history."""
    role: str = Field(..., description="Message role: 'user' or 'assistant'")
    content: str = Field(..., description="Message content")


class ChatRequest(BaseModel):
    """Chat request with conversation history support."""
    message: str = Field(
        ..., 
        min_length=1, 
        max_length=5000, 
        description="Your question",
        examples=["What is Python?", "What was my first question?"]
    )
    conversation_history: Optional[List[ChatMessage]] = Field(
        default=None,
        description="Previous messages in the conversation for context"
    )
    session_id: Optional[str] = Field(
        default=None,
        description="Session ID for server-side memory (optional)"
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


@router.post(
    "",
    response_model=ChatResponse,
    summary="Chat with Memory",
    description="Chat with AI that remembers your conversation history",
)
async def chat(
    request: ChatRequest,
    _: str = Depends(verify_api_key),
):
    """
    Chat with LangChain-powered conversation memory.
    
    The AI remembers previous messages and can answer questions like:
    - "What was my first question?"
    - "Can you summarize what we discussed?"
    - "You mentioned X earlier, can you explain more?"
    
    Two modes:
    1. **Client-side history**: Send `conversation_history` array
    2. **Server-side memory**: Send `session_id` for automatic memory
    """
    start_time = time.time()
    
    chat_service = get_langchain_chat_service()
    
    try:
        # Check if using server-side memory or client-side history
        if request.session_id:
            # Use server-side memory with session ID
            answer, model_used = await chat_service.chat(
                message=request.message,
                session_id=request.session_id,
                system_prompt=request.system_prompt,
            )
        elif request.conversation_history:
            # Use client-provided history
            messages = [{"role": msg.role, "content": msg.content} for msg in request.conversation_history]
            answer, model_used = await chat_service.chat_with_history_async(
                message=request.message,
                conversation_history=messages,
                system_prompt=request.system_prompt,
            )
        else:
            # No history - just single message
            answer, model_used = await chat_service.chat_with_history_async(
                message=request.message,
                conversation_history=[],
                system_prompt=request.system_prompt,
            )
            
    except Exception as e:
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
    summary="Streaming Chat with Memory",
    description="Chat with streaming response and conversation memory",
)
async def chat_stream(
    request: ChatRequest,
    _: str = Depends(verify_api_key),
):
    """Stream chat response with conversation memory."""
    chat_service = get_langchain_chat_service()
    
    async def generate():
        try:
            if request.session_id:
                # Use server-side memory
                async for chunk in chat_service.chat_stream(
                    message=request.message,
                    session_id=request.session_id,
                    system_prompt=request.system_prompt,
                ):
                    yield chunk
            elif request.conversation_history:
                # Use client-provided history
                messages = [{"role": msg.role, "content": msg.content} for msg in request.conversation_history]
                async for chunk in chat_service.chat_stream_with_history(
                    message=request.message,
                    conversation_history=messages,
                    system_prompt=request.system_prompt,
                ):
                    yield chunk
            else:
                # No history
                async for chunk in chat_service.chat_stream_with_history(
                    message=request.message,
                    conversation_history=[],
                    system_prompt=request.system_prompt,
                ):
                    yield chunk
        except Exception as e:
            yield f"\n\nError: {str(e)}"
    
    return StreamingResponse(
        generate(),
        media_type="text/plain",
    )


@router.delete(
    "/memory/{session_id}",
    summary="Clear Session Memory",
    description="Clear the conversation memory for a session",
)
async def clear_session_memory(
    session_id: str,
    _: str = Depends(verify_api_key),
):
    """Clear conversation memory for a specific session."""
    clear_memory(session_id)
    return {"status": "ok", "message": f"Memory cleared for session {session_id}"}


@router.get(
    "/history/{session_id}",
    summary="Get Chat History",
    description="Get the conversation history for a session",
)
async def get_chat_history(
    session_id: str,
    _: str = Depends(verify_api_key),
):
    """Get conversation history for a session."""
    chat_service = get_langchain_chat_service()
    history = chat_service.get_chat_history(session_id)
    return {"session_id": session_id, "history": history}
