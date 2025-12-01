"""
LMS RAG Backend - Document Processors
Base class and common utilities for document processing
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

from app.core.logging import get_logger

logger = get_logger(__name__)


@dataclass
class ProcessedChunk:
    """Represents a processed document chunk."""
    content: str
    metadata: dict
    chunk_index: int
    page_number: Optional[int] = None
    

@dataclass  
class ProcessedDocument:
    """Represents a fully processed document."""
    document_id: str
    filename: str
    content: str
    chunks: list[ProcessedChunk]
    metadata: dict
    

class BaseDocumentProcessor(ABC):
    """Abstract base class for document processors."""
    
    def __init__(self):
        self.logger = get_logger(self.__class__.__name__)
    
    @abstractmethod
    def process(self, file_path: Path, document_id: str) -> ProcessedDocument:
        """
        Process a document and extract its content.
        
        Args:
            file_path: Path to the document file
            document_id: Unique identifier for the document
            
        Returns:
            ProcessedDocument with extracted content and chunks
        """
        pass
    
    @abstractmethod
    def supports(self, file_extension: str) -> bool:
        """
        Check if this processor supports the given file extension.
        
        Args:
            file_extension: File extension (without dot)
            
        Returns:
            True if supported, False otherwise
        """
        pass
    
    def _create_base_metadata(self, file_path: Path, document_id: str) -> dict:
        """Create base metadata for a document."""
        return {
            "document_id": document_id,
            "filename": file_path.name,
            "file_extension": file_path.suffix.lower().lstrip("."),
            "file_size_bytes": file_path.stat().st_size if file_path.exists() else 0,
        }
