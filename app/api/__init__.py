"""
LMS RAG Backend - API Module
"""

from fastapi import APIRouter

from app.api.documents import router as documents_router
from app.api.query import router as query_router
from app.api.health import router as health_router
from app.api.chat import router as chat_router

# Main API router
api_router = APIRouter()

# Include all route modules
api_router.include_router(health_router)
api_router.include_router(documents_router)
api_router.include_router(query_router)
api_router.include_router(chat_router)

__all__ = ["api_router"]
