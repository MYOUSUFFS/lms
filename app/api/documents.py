"""
LMS RAG Backend - API Routes
Document management endpoints
"""

import shutil
import uuid
from datetime import datetime
from pathlib import Path
from typing import Optional

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile, status
from fastapi.responses import FileResponse

from app.core.config import settings
from app.core.security import verify_api_key
from app.schemas import (
    DocumentInfo,
    DocumentListResponse,
    DocumentType,
    DocumentUploadResponse,
    ProcessingStatus,
    URLScrapeRequest,
    URLScrapeResponse,
)
from app.services.rag import get_rag_pipeline

router = APIRouter(prefix="/documents", tags=["Documents"])


def get_document_type(extension: str) -> DocumentType:
    """Map file extension to DocumentType."""
    mapping = {
        "pdf": DocumentType.PDF,
        "txt": DocumentType.TXT,
        "md": DocumentType.TXT,
        "html": DocumentType.HTML,
        "htm": DocumentType.HTML,
        "csv": DocumentType.CSV,
        "xlsx": DocumentType.CSV,
        "xls": DocumentType.CSV,
        "png": DocumentType.IMAGE,
        "jpg": DocumentType.IMAGE,
        "jpeg": DocumentType.IMAGE,
    }
    return mapping.get(extension.lower(), DocumentType.TXT)


@router.post(
    "/upload",
    response_model=DocumentUploadResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Upload a document",
    description="Upload and process a document (PDF, TXT, HTML, CSV, or image for OCR)",
)
async def upload_document(
    file: UploadFile = File(..., description="Document file to upload"),
    document_id: Optional[str] = Query(None, description="Custom document ID"),
    classroom_id: Optional[str] = Query(None, description="Classroom ID for document isolation"),
    _: str = Depends(verify_api_key),
):
    """
    Upload a document for RAG processing.
    
    Supported formats:
    - PDF (.pdf)
    - Text (.txt, .md)
    - HTML (.html, .htm)
    - CSV/Excel (.csv, .xlsx, .xls)
    - Images for OCR (.png, .jpg, .jpeg)
    """
    # Validate file extension
    extension = file.filename.split(".")[-1].lower() if file.filename else ""
    
    if extension not in settings.allowed_extensions_list:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported file type: {extension}. Allowed: {settings.allowed_extensions}",
        )
    
    # Generate document ID
    doc_id = document_id or str(uuid.uuid4())
    
    # Save file
    upload_path = settings.upload_path / f"{doc_id}_{file.filename}"
    
    try:
        with open(upload_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to save file: {str(e)}",
        )
    
    # Process document
    pipeline = get_rag_pipeline()
    result = pipeline.ingest_file(upload_path, doc_id, classroom_id=classroom_id)
    
    return DocumentUploadResponse(
        document_id=result["document_id"],
        filename=result["filename"],
        document_type=get_document_type(extension),
        status=ProcessingStatus.COMPLETED if result["status"] == "completed" else ProcessingStatus.FAILED,
        message=result["message"],
        chunks_created=result["chunks_created"],
        classroom_id=classroom_id,
    )


@router.post(
    "/scrape",
    response_model=URLScrapeResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Scrape a URL",
    description="Scrape content from a URL and add to the knowledge base",
)
async def scrape_url(
    request: URLScrapeRequest,
    _: str = Depends(verify_api_key),
):
    """Scrape content from a URL."""
    pipeline = get_rag_pipeline()
    result = pipeline.ingest_url(request.url)
    
    return URLScrapeResponse(
        url=request.url,
        document_id=result["document_id"],
        title=result.get("title"),
        status=ProcessingStatus.COMPLETED if result["status"] == "completed" else ProcessingStatus.FAILED,
        chunks_created=result["chunks_created"],
        message=result["message"],
    )


@router.get(
    "",
    response_model=DocumentListResponse,
    summary="List all documents",
    description="Get a list of all documents in the knowledge base",
)
async def list_documents(
    _: str = Depends(verify_api_key),
):
    """List all documents."""
    pipeline = get_rag_pipeline()
    documents = pipeline.list_documents()
    
    doc_infos = [
        DocumentInfo(
            document_id=doc["document_id"],
            filename=doc["filename"],
            document_type=get_document_type(doc["filename"].split(".")[-1] if "." in doc["filename"] else "txt"),
            status=ProcessingStatus.COMPLETED,
            chunks_count=doc["chunks_count"],
            classroom_id=doc.get("classroom_id"),
            created_at=datetime.now(),  # Would need to store this
        )
        for doc in documents
    ]
    
    return DocumentListResponse(
        documents=doc_infos,
        total=len(doc_infos),
    )


@router.get(
    "/{document_id}",
    response_model=DocumentInfo,
    summary="Get document info",
    description="Get information about a specific document",
)
async def get_document(
    document_id: str,
    _: str = Depends(verify_api_key),
):
    """Get document information."""
    pipeline = get_rag_pipeline()
    documents = pipeline.list_documents()
    
    for doc in documents:
        if doc["document_id"] == document_id:
            return DocumentInfo(
                document_id=doc["document_id"],
                filename=doc["filename"],
                document_type=get_document_type(doc["filename"].split(".")[-1] if "." in doc["filename"] else "txt"),
                status=ProcessingStatus.COMPLETED,
                chunks_count=doc["chunks_count"],
                classroom_id=doc.get("classroom_id"),
                created_at=datetime.now(),
            )
    
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail=f"Document not found: {document_id}",
    )


@router.delete(
    "/{document_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete a document",
    description="Delete a document from the knowledge base",
)
async def delete_document(
    document_id: str,
    _: str = Depends(verify_api_key),
):
    """Delete a document."""
    pipeline = get_rag_pipeline()
    deleted = pipeline.delete_document(document_id)
    
    if deleted == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Document not found: {document_id}",
        )
    
    return None


@router.get(
    "/{document_id}/content",
    summary="Get document content",
    description="Download or view the original document file",
)
async def get_document_content(
    document_id: str,
    _: str = Depends(verify_api_key),
):
    """Get the original document file."""
    # Search for the file in the upload directory
    upload_dir = settings.upload_path
    
    # Find file matching the document_id prefix
    matching_files = list(upload_dir.glob(f"{document_id}_*"))
    
    if not matching_files:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Document file not found: {document_id}",
        )
    
    file_path = matching_files[0]
    
    if not file_path.exists():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Document file does not exist: {document_id}",
        )
    
    # Get the original filename (remove document_id prefix)
    original_filename = file_path.name.split('_', 1)[1] if '_' in file_path.name else file_path.name
    
    # Return file with appropriate media type
    return FileResponse(
        path=str(file_path),
        filename=original_filename,
        media_type="application/octet-stream",
    )
