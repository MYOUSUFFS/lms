"""
LMS RAG Backend - Text Chunker
Intelligent text chunking for RAG pipeline
"""

from typing import Optional

from app.core.config import settings
from app.core.logging import get_logger
from app.services.processors.base import ProcessedChunk, ProcessedDocument

logger = get_logger(__name__)


class TextChunker:
    """
    Intelligent text chunker for document processing.
    Uses recursive character splitting with overlap.
    """
    
    # Separators ordered by priority (paragraph > sentence > word)
    SEPARATORS = [
        "\n\n",  # Paragraphs
        "\n",    # Lines
        ". ",    # Sentences
        "? ",    # Questions
        "! ",    # Exclamations
        "; ",    # Semi-colons
        ", ",    # Clauses
        " ",     # Words
        "",      # Characters (last resort)
    ]
    
    def __init__(
        self,
        chunk_size: int = None,
        chunk_overlap: int = None,
        separators: list[str] = None,
    ):
        """
        Initialize the text chunker.
        
        Args:
            chunk_size: Maximum chunk size in characters
            chunk_overlap: Overlap between chunks
            separators: Custom separators (optional)
        """
        self.chunk_size = chunk_size or settings.chunk_size
        self.chunk_overlap = chunk_overlap or settings.chunk_overlap
        self.separators = separators or self.SEPARATORS
        
        logger.info(f"TextChunker initialized: size={self.chunk_size}, overlap={self.chunk_overlap}")
    
    def chunk_text(self, text: str, metadata: dict = None) -> list[ProcessedChunk]:
        """
        Split text into overlapping chunks.
        
        Args:
            text: Text to chunk
            metadata: Additional metadata to include in each chunk
            
        Returns:
            List of ProcessedChunks
        """
        if not text or not text.strip():
            return []
        
        metadata = metadata or {}
        chunks_text = self._recursive_split(text, self.separators)
        
        # Merge small chunks
        merged_chunks = self._merge_small_chunks(chunks_text)
        
        # Create ProcessedChunk objects
        processed_chunks = []
        for i, chunk_text in enumerate(merged_chunks):
            chunk = ProcessedChunk(
                content=chunk_text.strip(),
                metadata={
                    **metadata,
                    "chunk_index": i,
                    "chunk_size": len(chunk_text),
                },
                chunk_index=i,
            )
            processed_chunks.append(chunk)
        
        logger.debug(f"Created {len(processed_chunks)} chunks from {len(text)} characters")
        return processed_chunks
    
    def chunk_document(self, document: ProcessedDocument) -> ProcessedDocument:
        """
        Re-chunk a processed document with proper overlap.
        
        Args:
            document: ProcessedDocument to chunk
            
        Returns:
            ProcessedDocument with updated chunks
        """
        # Combine all existing chunks into full text
        full_text = document.content
        
        # Create new chunks
        new_chunks = self.chunk_text(
            full_text,
            metadata={
                "document_id": document.document_id,
                "filename": document.filename,
            }
        )
        
        # Update document
        document.chunks = new_chunks
        
        return document
    
    def _recursive_split(self, text: str, separators: list[str]) -> list[str]:
        """
        Recursively split text using hierarchical separators.
        
        Args:
            text: Text to split
            separators: List of separators to use
            
        Returns:
            List of text chunks
        """
        if not separators:
            # No more separators, return text split by chunk_size
            return self._split_by_size(text)
        
        separator = separators[0]
        remaining_separators = separators[1:]
        
        if separator == "":
            # Final separator - split by characters
            return self._split_by_size(text)
        
        if separator not in text:
            # Separator not found, try next one
            return self._recursive_split(text, remaining_separators)
        
        # Split by this separator
        splits = text.split(separator)
        
        # Process each split
        chunks = []
        current_chunk = ""
        
        for split in splits:
            # Add separator back (except for first split)
            test_chunk = current_chunk + (separator if current_chunk else "") + split
            
            if len(test_chunk) <= self.chunk_size:
                current_chunk = test_chunk
            else:
                # Current chunk is full
                if current_chunk:
                    chunks.append(current_chunk)
                
                # Check if this split needs further splitting
                if len(split) > self.chunk_size:
                    # Recursively split with remaining separators
                    sub_chunks = self._recursive_split(split, remaining_separators)
                    chunks.extend(sub_chunks[:-1])
                    current_chunk = sub_chunks[-1] if sub_chunks else ""
                else:
                    current_chunk = split
        
        # Don't forget the last chunk
        if current_chunk:
            chunks.append(current_chunk)
        
        return chunks
    
    def _split_by_size(self, text: str) -> list[str]:
        """Split text into fixed-size chunks."""
        chunks = []
        for i in range(0, len(text), self.chunk_size - self.chunk_overlap):
            chunk = text[i:i + self.chunk_size]
            if chunk:
                chunks.append(chunk)
        return chunks
    
    def _merge_small_chunks(self, chunks: list[str], min_size: int = None) -> list[str]:
        """
        Merge chunks that are too small.
        
        Args:
            chunks: List of text chunks
            min_size: Minimum chunk size (default: chunk_size / 4)
            
        Returns:
            Merged chunks
        """
        min_size = min_size or self.chunk_size // 4
        
        merged = []
        current = ""
        
        for chunk in chunks:
            if len(current) + len(chunk) <= self.chunk_size:
                current += (" " if current else "") + chunk
            else:
                if current:
                    merged.append(current)
                current = chunk
        
        if current:
            merged.append(current)
        
        return merged
    
    def add_overlap(self, chunks: list[str]) -> list[str]:
        """
        Add overlap between chunks for better context.
        
        Args:
            chunks: List of text chunks
            
        Returns:
            Chunks with overlap added
        """
        if len(chunks) <= 1:
            return chunks
        
        overlapped = []
        
        for i, chunk in enumerate(chunks):
            # Get overlap from previous chunk
            if i > 0 and self.chunk_overlap > 0:
                prev_overlap = chunks[i - 1][-self.chunk_overlap:]
                chunk = prev_overlap + " " + chunk
            
            overlapped.append(chunk)
        
        return overlapped
