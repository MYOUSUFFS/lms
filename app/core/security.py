"""
LMS RAG Backend - Security & Authentication
API Key authentication middleware
"""

from fastapi import HTTPException, Security, status
from fastapi.security import APIKeyHeader

from app.core.config import settings

# API Key header extractor
api_key_header = APIKeyHeader(name=settings.api_key_header, auto_error=False)


async def verify_api_key(api_key: str = Security(api_key_header)) -> str:
    """
    Verify the API key from request header.
    
    Args:
        api_key: API key extracted from header
        
    Returns:
        The verified API key
        
    Raises:
        HTTPException: If API key is missing or invalid
    """
    if api_key is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="API key is missing",
            headers={"WWW-Authenticate": "API-Key"},
        )
    
    if api_key != settings.api_key:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid API key",
            headers={"WWW-Authenticate": "API-Key"},
        )
    
    return api_key


def get_api_key_dependency():
    """Get API key dependency for route protection."""
    return Security(verify_api_key)
