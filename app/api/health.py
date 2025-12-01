"""
LMS RAG Backend - API Routes
Health check endpoints
"""

import time
from datetime import datetime

from fastapi import APIRouter

from app.core.config import settings
from app.schemas import HealthStatus
from app.services.rag import get_vector_store
from app.services.llm import get_llm_service

router = APIRouter(tags=["Health"])


@router.get(
    "/health",
    response_model=HealthStatus,
    summary="Health check",
    description="Check the health status of all system components",
)
async def health_check():
    """
    Comprehensive health check.
    
    Checks:
    - API status
    - Vector store (ChromaDB)
    - LLM providers (Ollama, Groq, Together)
    - Embeddings model
    """
    components = {}
    
    # Check vector store
    try:
        start = time.time()
        vector_store = get_vector_store()
        count = vector_store.count()
        components["vector_store"] = {
            "status": "healthy",
            "type": "chromadb",
            "documents_count": count,
            "latency_ms": round((time.time() - start) * 1000, 2),
        }
    except Exception as e:
        components["vector_store"] = {
            "status": "unhealthy",
            "error": str(e),
        }
    
    # Check LLM providers
    try:
        llm_service = get_llm_service()
        llm_health = await llm_service.health_check()
        components["llm"] = llm_health
    except Exception as e:
        components["llm"] = {
            "status": "unhealthy",
            "error": str(e),
        }
    
    # Overall status
    all_healthy = all(
        c.get("status") == "healthy" or c.get("available", False)
        for c in components.values()
        if isinstance(c, dict) and "status" in c
    )
    
    return HealthStatus(
        status="healthy" if all_healthy else "degraded",
        version="1.0.0",
        timestamp=datetime.now(),
        components=components,
    )


@router.get(
    "/",
    summary="Root endpoint",
    description="Basic API information",
)
async def root():
    """Root endpoint with API info."""
    return {
        "name": settings.app_name,
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs",
        "health": "/health",
    }


@router.get(
    "/stats",
    summary="System statistics",
    description="Get system statistics and usage information",
)
async def get_stats():
    """Get system statistics."""
    from app.services.rag import get_rag_pipeline
    
    pipeline = get_rag_pipeline()
    stats = pipeline.get_stats()
    
    return {
        "documents": stats["total_documents"],
        "chunks": stats["total_chunks"],
        "embedding_model": settings.embedding_model,
        "llm_model": settings.ollama_model,
        "chunk_size": settings.chunk_size,
        "chunk_overlap": settings.chunk_overlap,
    }
