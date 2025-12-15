"""
LMS RAG Backend - FastAPI Application
Main application entry point
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.logging import setup_logging
from app.api import api_router, api_v2_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler."""
    # Startup
    logger = setup_logging()
    logger.info(f"Starting {settings.app_name}")
    logger.info(f"Environment: {settings.app_env}")
    logger.info(f"Debug: {settings.debug}")
    
    # Initialize Redis connection
    try:
        from app.core.redis import get_redis
        await get_redis()
        logger.info("Redis connection initialized")
    except Exception as e:
        logger.warning(f"Redis initialization failed: {e}")
        logger.warning("Token blacklist will not work, but app will continue")
    
    # Pre-load models if needed (optional, can be lazy)
    # This is commented out to allow faster startup
    # from app.services.rag import get_embeddings_service
    # get_embeddings_service()  # Pre-load embeddings model
    
    yield
    
    # Shutdown
    logger.info("Shutting down application")
    
    # Close Redis connection
    try:
        from app.core.redis import close_redis
        await close_redis()
        logger.info("Redis connection closed")
    except Exception as e:
        logger.error(f"Error closing Redis: {e}")


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    
    app = FastAPI(
        title=settings.app_name,
        description="""
# LMS RAG Backend API

A powerful RAG (Retrieval-Augmented Generation) backend for Learning Management Systems.

## Features

- **Document Processing**: Upload and process PDF, HTML, TXT, CSV, and images (OCR)
- **Web Scraping**: Scrape and index content from URLs
- **Vector Search**: Semantic search using BGE embeddings and ChromaDB
- **LLM Integration**: Local-first LLM with Ollama, cloud fallback with Groq/Together
- **API Key Authentication**: Secure access with API keys

## Architecture

```
UPLOAD → PROCESS → CHUNK → EMBED → VECTOR STORE
QUERY → EMBED → SEARCH → CONTEXT → LLM → ANSWER
```

## Authentication

All endpoints (except health check) require an API key in the `X-API-Key` header.
        """,
        version="1.0.0",
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_url="/openapi.json",
        lifespan=lifespan,
    )
    
    # CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # Configure appropriately for production
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    # Include API routes
    app.include_router(api_router, prefix="/api/v1")
    app.include_router(api_v2_router)  # v2 routes include their own /api/v2 prefix
    
    return app


# Create app instance
app = create_app()


if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
        log_level=settings.log_level.lower(),
    )
