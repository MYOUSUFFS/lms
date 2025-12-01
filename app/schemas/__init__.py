"""
LMS RAG Backend - Pydantic Schemas
Request and response models
"""

from datetime import datetime
from enum import Enum
from typing import Any, Optional

from pydantic import BaseModel, Field


# ===========================================
# Enums
# ===========================================

class DocumentType(str, Enum):
    """Supported document types."""
    PDF = "pdf"
    TXT = "txt"
    HTML = "html"
    CSV = "csv"
    IMAGE = "image"
    URL = "url"


class ProcessingStatus(str, Enum):
    """Document processing status."""
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


# ===========================================
# Document Schemas
# ===========================================

class DocumentUploadResponse(BaseModel):
    """Response after document upload."""
    document_id: str = Field(..., description="Unique document identifier")
    filename: str = Field(..., description="Original filename")
    document_type: DocumentType = Field(..., description="Detected document type")
    status: ProcessingStatus = Field(..., description="Processing status")
    message: str = Field(..., description="Status message")
    chunks_created: int = Field(0, description="Number of chunks created")
    

class DocumentInfo(BaseModel):
    """Document information."""
    document_id: str
    filename: str
    document_type: DocumentType
    status: ProcessingStatus
    chunks_count: int
    created_at: datetime
    file_size_bytes: Optional[int] = None
    

class DocumentListResponse(BaseModel):
    """List of documents response."""
    documents: list[DocumentInfo]
    total: int


# ===========================================
# Query Schemas
# ===========================================

class QueryRequest(BaseModel):
    """Query request model."""
    query: str = Field(..., min_length=1, max_length=2000, description="User question")
    top_k: int = Field(5, ge=1, le=20, description="Number of context chunks to retrieve")
    include_sources: bool = Field(True, description="Include source documents in response")
    document_ids: Optional[list[str]] = Field(None, description="Filter by specific documents")
    

class SourceDocument(BaseModel):
    """Source document for a query result."""
    document_id: str
    filename: str
    chunk_id: str
    content: str
    similarity_score: float
    page_number: Optional[int] = None
    

class QueryResponse(BaseModel):
    """Query response model."""
    query: str = Field(..., description="Original query")
    answer: str = Field(..., description="Generated answer")
    sources: list[SourceDocument] = Field(default_factory=list, description="Source documents")
    model_used: str = Field(..., description="LLM model used for generation")
    processing_time_ms: float = Field(..., description="Processing time in milliseconds")
    

# ===========================================
# URL Scraping Schemas
# ===========================================

class URLScrapeRequest(BaseModel):
    """URL scraping request."""
    url: str = Field(..., description="URL to scrape")
    extract_links: bool = Field(False, description="Extract and follow links")
    max_depth: int = Field(1, ge=1, le=3, description="Maximum crawl depth")
    

class URLScrapeResponse(BaseModel):
    """URL scraping response."""
    url: str
    document_id: str
    title: Optional[str]
    status: ProcessingStatus
    chunks_created: int
    message: str


# ===========================================
# Health & Status Schemas
# ===========================================

class HealthStatus(BaseModel):
    """Health check status."""
    status: str
    version: str
    timestamp: datetime
    components: dict[str, Any]
    

class ComponentHealth(BaseModel):
    """Individual component health."""
    name: str
    status: str
    latency_ms: Optional[float] = None
    error: Optional[str] = None


# ===========================================
# Error Schemas
# ===========================================

class ErrorResponse(BaseModel):
    """Error response model."""
    error: str
    detail: Optional[str] = None
    status_code: int
