"""
LMS RAG Backend - FastAPI Application
Main application entry point
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.logging import setup_logging
from app.api import api_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler."""
    # Startup
    logger = setup_logging()
    logger.info(f"Starting {settings.app_name}")
    logger.info(f"Environment: {settings.app_env}")
    logger.info(f"Debug: {settings.debug}")
    
    # Pre-load models if needed (optional, can be lazy)
    # This is commented out to allow faster startup
    # from app.services.rag import get_embeddings_service
    # get_embeddings_service()  # Pre-load embeddings model
    
    yield
    
    # Shutdown
    logger.info("Shutting down application")


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
