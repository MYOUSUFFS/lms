"""
LMS RAG Backend - API Routes
Query endpoints for RAG
"""

import time
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse

from app.core.config import settings
from app.core.security import verify_api_key
from app.schemas import QueryRequest, QueryResponse, SourceDocument
from app.services.rag import get_rag_pipeline
from app.services.llm import get_llm_service

router = APIRouter(prefix="/query", tags=["Query"])


@router.post(
    "",
    response_model=QueryResponse,
    summary="Query the knowledge base",
    description="Ask a question and get an answer based on the indexed documents",
)
async def query_knowledge_base(
    request: QueryRequest,
    _: str = Depends(verify_api_key),
):
    """
    Query the RAG system.
    
    This endpoint:
    1. Searches for relevant context in the vector store
    2. Builds a prompt with the context
    3. Generates an answer using the LLM
    4. Returns the answer with source documents
    """
    start_time = time.time()
    
    # Get RAG pipeline and LLM service
    pipeline = get_rag_pipeline()
    llm_service = get_llm_service()
    
    # Build context from vector search
    context, sources = pipeline.build_context(
        query=request.query,
        top_k=request.top_k,
        document_ids=request.document_ids,
    )
    
    if not context:
        return QueryResponse(
            query=request.query,
            answer="I couldn't find any relevant information in the knowledge base to answer your question.",
            sources=[],
            model_used="none",
            processing_time_ms=round((time.time() - start_time) * 1000, 2),
        )
    
    # Generate answer
    try:
        answer, model_used = await llm_service.generate(
            prompt=request.query,
            context=context,
        )
    except RuntimeError as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(e),
        )
    
    # Build source documents
    source_docs = []
    if request.include_sources:
        for source in sources:
            source_docs.append(
                SourceDocument(
                    document_id=source["metadata"].get("document_id", ""),
                    filename=source["metadata"].get("filename", "unknown"),
                    chunk_id=source["chunk_id"],
                    content=source["content"][:500] + "..." if len(source["content"]) > 500 else source["content"],
                    similarity_score=round(source["similarity_score"], 4),
                    page_number=source["metadata"].get("page_number"),
                )
            )
    
    processing_time = round((time.time() - start_time) * 1000, 2)
    
    return QueryResponse(
        query=request.query,
        answer=answer,
        sources=source_docs,
        model_used=model_used,
        processing_time_ms=processing_time,
    )


@router.post(
    "/stream",
    summary="Query with streaming response",
    description="Query the knowledge base with streaming LLM response",
)
async def query_stream(
    request: QueryRequest,
    _: str = Depends(verify_api_key),
):
    """Query with streaming response."""
    pipeline = get_rag_pipeline()
    llm_service = get_llm_service()
    
    # Build context
    context, _ = pipeline.build_context(
        query=request.query,
        top_k=request.top_k,
        document_ids=request.document_ids,
    )
    
    async def generate():
        try:
            async for chunk, _ in llm_service.generate_stream(
                prompt=request.query,
                context=context,
            ):
                yield chunk
        except Exception as e:
            yield f"\n\nError: {str(e)}"
    
    return StreamingResponse(
        generate(),
        media_type="text/plain",
    )


@router.post(
    "/search",
    summary="Search without LLM",
    description="Search the knowledge base and return relevant chunks without LLM generation",
)
async def search_only(
    request: QueryRequest,
    _: str = Depends(verify_api_key),
):
    """
    Search for relevant documents without LLM generation.
    Useful for testing retrieval or when you want raw context.
    """
    pipeline = get_rag_pipeline()
    
    results = pipeline.search(
        query=request.query,
        top_k=request.top_k,
        document_ids=request.document_ids,
    )
    
    return {
        "query": request.query,
        "results": [
            {
                "chunk_id": r["chunk_id"],
                "content": r["content"],
                "metadata": r["metadata"],
                "similarity_score": round(r["similarity_score"], 4),
            }
            for r in results
        ],
        "total": len(results),
    }
