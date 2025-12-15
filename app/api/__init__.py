"""
LMS RAG Backend - API Module
"""

from fastapi import APIRouter

from app.api.documents import router as documents_router
from app.api.query import router as query_router
from app.api.health import router as health_router
from app.api.chat import router as chat_router
from app.api.auth import router as auth_router
from app.api.classrooms import router as classrooms_router
from app.api.organizations import router as organizations_router

# Main API router (v1 - legacy)
api_router = APIRouter()

# Include all v1 route modules
api_router.include_router(health_router)
api_router.include_router(documents_router)
api_router.include_router(query_router)
api_router.include_router(chat_router)

# V2 API router (new with authentication)
api_v2_router = APIRouter()
api_v2_router.include_router(auth_router)
api_v2_router.include_router(classrooms_router)
api_v2_router.include_router(organizations_router)

__all__ = ["api_router", "api_v2_router"]
