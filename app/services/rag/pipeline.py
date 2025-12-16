"""
LMS RAG Backend - RAG Pipeline
Main RAG orchestration service
"""

import uuid
from pathlib import Path
from typing import Optional

from app.core.config import settings
from app.core.logging import get_logger
from app.services.processors import (
    PDFProcessor,
    HTMLProcessor,
    TextProcessor,
    CSVProcessor,
    OCRProcessor,
    WebScraper,
    ProcessedDocument,
)
from app.services.rag.chunker import TextChunker
from app.services.rag.vector_store import VectorStore, get_vector_store

logger = get_logger(__name__)


class RAGPipeline:
    """
    Main RAG pipeline orchestrator.
    
    Handles:
    - Document ingestion (upload → process → chunk → embed → store)
    - Query processing (embed → search → context retrieval)
    """
    
    def __init__(self):
        """Initialize RAG pipeline with all components."""
        self.chunker = TextChunker()
        self.vector_store = get_vector_store()
        
        # Initialize processors
        self.processors = {
            "pdf": PDFProcessor(),
            "html": HTMLProcessor(),
            "htm": HTMLProcessor(),
            "txt": TextProcessor(),
            "md": TextProcessor(),
            "csv": CSVProcessor(),
            "xlsx": CSVProcessor(),
            "xls": CSVProcessor(),
            "png": OCRProcessor(),
            "jpg": OCRProcessor(),
            "jpeg": OCRProcessor(),
        }
        
        self.web_scraper = WebScraper()
        
        logger.info("RAG Pipeline initialized")
    
    def ingest_file(self, file_path: Path, document_id: str = None, classroom_id: str = None) -> dict:
        """
        Ingest a file into the RAG system.
        
        Pipeline: Upload → Process → Chunk → Embed → Store
        
        Args:
            file_path: Path to the file
            document_id: Optional document ID (auto-generated if not provided)
            classroom_id: Optional classroom ID for document isolation
            
        Returns:
            Ingestion result with document info
        """
        document_id = document_id or str(uuid.uuid4())
        extension = file_path.suffix.lower().lstrip(".")
        
        logger.info(f"Ingesting file: {file_path.name} (type: {extension}, classroom: {classroom_id})")
        
        # Check if extension is supported
        if extension not in self.processors:
            raise ValueError(f"Unsupported file type: {extension}")
        
        try:
            # Step 1: Process document
            processor = self.processors[extension]
            document = processor.process(file_path, document_id)
            
            # Add classroom_id to document metadata
            if classroom_id:
                document.metadata["classroom_id"] = classroom_id
            
            # Step 2: Chunk document
            document = self.chunker.chunk_document(document)
            
            # Step 3: Add to vector store (embeds and stores)
            chunks_added = self.vector_store.add_document(document)
            
            logger.info(f"Document ingested: {document_id} with {chunks_added} chunks")
            
            return {
                "document_id": document_id,
                "filename": file_path.name,
                "document_type": extension,
                "chunks_created": chunks_added,
                "status": "completed",
                "message": f"Successfully ingested {file_path.name}",
            }
            
        except Exception as e:
            logger.error(f"Error ingesting file {file_path.name}: {e}")
            return {
                "document_id": document_id,
                "filename": file_path.name,
                "document_type": extension,
                "chunks_created": 0,
                "status": "failed",
                "message": str(e),
            }
    
    def ingest_url(self, url: str, document_id: str = None, classroom_id: str = None) -> dict:
        """
        Ingest content from a URL.
        
        Args:
            url: URL to scrape
            document_id: Optional document ID
            classroom_id: Optional classroom ID for document isolation
            
        Returns:
            Ingestion result
        """
        document_id = document_id or str(uuid.uuid4())
        
        logger.info(f"Ingesting URL: {url} (classroom: {classroom_id})")
        
        try:
            # Scrape URL
            document = self.web_scraper.scrape(url, document_id)
            
            # Add classroom_id to document metadata
            if classroom_id:
                document.metadata["classroom_id"] = classroom_id
            
            # Chunk document
            document = self.chunker.chunk_document(document)
            
            # Add to vector store
            chunks_added = self.vector_store.add_document(document)
            
            logger.info(f"URL ingested: {document_id} with {chunks_added} chunks")
            
            return {
                "document_id": document_id,
                "url": url,
                "title": document.metadata.get("title"),
                "document_type": "url",
                "chunks_created": chunks_added,
                "status": "completed",
                "message": f"Successfully ingested {url}",
            }
            
        except Exception as e:
            logger.error(f"Error ingesting URL {url}: {e}")
            return {
                "document_id": document_id,
                "url": url,
                "document_type": "url",
                "chunks_created": 0,
                "status": "failed",
                "message": str(e),
            }
    
    def search(
        self,
        query: str,
        top_k: int = None,
        document_ids: list[str] = None,
    ) -> list[dict]:
        """
        Search for relevant context.
        
        Args:
            query: Search query
            top_k: Number of results
            document_ids: Filter by documents
            
        Returns:
            List of matching chunks with context
        """
        return self.vector_store.search(
            query=query,
            top_k=top_k or settings.top_k_results,
            document_ids=document_ids,
        )
    
    def build_context(self, query: str, top_k: int = None, document_ids: list[str] = None) -> tuple[str, list[dict]]:
        """
        Build context string from search results.
        
        Args:
            query: Search query
            top_k: Number of results
            document_ids: Filter by documents
            
        Returns:
            Tuple of (context_string, source_documents)
        """
        results = self.search(query, top_k, document_ids)
        
        if not results:
            return "", []
        
        # Build context string
        context_parts = []
        for i, result in enumerate(results, 1):
            source = result["metadata"].get("filename", "Unknown")
            page = result["metadata"].get("page_number", "")
            page_info = f" (Page {page})" if page else ""
            
            context_parts.append(
                f"[Source {i}: {source}{page_info}]\n{result['content']}"
            )
        
        context = "\n\n---\n\n".join(context_parts)
        
        return context, results
    
    def delete_document(self, document_id: str) -> int:
        """
        Delete a document from the system.
        
        Args:
            document_id: Document ID to delete
            
        Returns:
            Number of chunks deleted
        """
        return self.vector_store.delete_document(document_id)
    
    def list_documents(self) -> list[dict]:
        """List all documents in the system."""
        return self.vector_store.list_documents()
    
    def get_stats(self) -> dict:
        """Get pipeline statistics."""
        documents = self.vector_store.list_documents()
        return {
            "total_documents": len(documents),
            "total_chunks": self.vector_store.count(),
            "documents": documents,
        }


# Global singleton
_rag_pipeline: Optional[RAGPipeline] = None


def get_rag_pipeline() -> RAGPipeline:
    """Get or create RAG pipeline singleton."""
    global _rag_pipeline
    if _rag_pipeline is None:
        _rag_pipeline = RAGPipeline()
    return _rag_pipeline
