"""
LMS RAG Backend - Text Document Processor
Native Python text file processing
"""

from pathlib import Path

from app.services.processors.base import (
    BaseDocumentProcessor,
    ProcessedChunk,
    ProcessedDocument,
)


class TextProcessor(BaseDocumentProcessor):
    """Plain text document processor."""
    
    SUPPORTED_EXTENSIONS = ["txt", "md", "rst", "log"]
    
    # Common encodings to try
    ENCODINGS = ["utf-8", "utf-16", "latin-1", "cp1252", "ascii"]
    
    def supports(self, file_extension: str) -> bool:
        """Check if this processor supports text files."""
        return file_extension.lower() in self.SUPPORTED_EXTENSIONS
    
    def process(self, file_path: Path, document_id: str) -> ProcessedDocument:
        """
        Process a text document.
        
        Args:
            file_path: Path to the text file
            document_id: Unique identifier for the document
            
        Returns:
            ProcessedDocument with extracted content
        """
        self.logger.info(f"Processing text file: {file_path.name}")
        
        try:
            content = self._read_file(file_path)
            
            # Create single chunk for text content
            chunk = ProcessedChunk(
                content=content,
                metadata={},
                chunk_index=0,
            )
            
            metadata = self._create_base_metadata(file_path, document_id)
            metadata.update({
                "line_count": content.count("\n") + 1,
                "processor": "text_native",
            })
            
            self.logger.info(f"Text processed: {len(content)} characters, {metadata['line_count']} lines")
            
            return ProcessedDocument(
                document_id=document_id,
                filename=file_path.name,
                content=content,
                chunks=[chunk],
                metadata=metadata,
            )
            
        except Exception as e:
            self.logger.error(f"Error processing text file {file_path.name}: {e}")
            raise
    
    def _read_file(self, file_path: Path) -> str:
        """
        Read file content with encoding detection.
        
        Args:
            file_path: Path to the file
            
        Returns:
            File content as string
        """
        for encoding in self.ENCODINGS:
            try:
                with open(file_path, "r", encoding=encoding) as f:
                    return f.read()
            except UnicodeDecodeError:
                continue
        
        # Fallback: read with error replacement
        with open(file_path, "r", encoding="utf-8", errors="replace") as f:
            return f.read()
