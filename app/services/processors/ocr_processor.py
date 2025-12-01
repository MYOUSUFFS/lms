"""
LMS RAG Backend - OCR Processor
Uses PaddleOCR for image text extraction
"""

import io
import tempfile
from pathlib import Path
from typing import Optional, Union

from app.services.processors.base import (
    BaseDocumentProcessor,
    ProcessedChunk,
    ProcessedDocument,
)


class OCRProcessor(BaseDocumentProcessor):
    """OCR processor using PaddleOCR."""
    
    SUPPORTED_EXTENSIONS = ["png", "jpg", "jpeg", "bmp", "tiff", "tif", "webp"]
    
    def __init__(self):
        super().__init__()
        self._ocr = None  # Lazy initialization
    
    @property
    def ocr(self):
        """Lazy-load PaddleOCR to avoid startup overhead."""
        if self._ocr is None:
            try:
                from paddleocr import PaddleOCR
                self._ocr = PaddleOCR(
                    use_angle_cls=True,
                    lang="en",
                    use_gpu=False,  # CPU by default, enable GPU if available
                    show_log=False,
                )
                self.logger.info("PaddleOCR initialized successfully")
            except ImportError:
                self.logger.warning("PaddleOCR not installed. OCR features disabled.")
                raise ImportError("PaddleOCR is required for image processing")
        return self._ocr
    
    def supports(self, file_extension: str) -> bool:
        """Check if this processor supports image files."""
        return file_extension.lower() in self.SUPPORTED_EXTENSIONS
    
    def process(self, file_path: Path, document_id: str) -> ProcessedDocument:
        """
        Process an image and extract text using OCR.
        
        Args:
            file_path: Path to the image file
            document_id: Unique identifier for the document
            
        Returns:
            ProcessedDocument with extracted text
        """
        self.logger.info(f"Processing image with OCR: {file_path.name}")
        
        try:
            text = self._extract_text(str(file_path))
            
            chunk = ProcessedChunk(
                content=text,
                metadata={
                    "ocr_engine": "paddleocr",
                },
                chunk_index=0,
            )
            
            metadata = self._create_base_metadata(file_path, document_id)
            metadata.update({
                "ocr_engine": "paddleocr",
                "processor": "ocr_paddle",
            })
            
            self.logger.info(f"OCR processed: {len(text)} characters extracted")
            
            return ProcessedDocument(
                document_id=document_id,
                filename=file_path.name,
                content=text,
                chunks=[chunk],
                metadata=metadata,
            )
            
        except Exception as e:
            self.logger.error(f"Error processing image {file_path.name}: {e}")
            raise
    
    def _extract_text(self, image_path: str) -> str:
        """
        Extract text from image using PaddleOCR.
        
        Args:
            image_path: Path to the image
            
        Returns:
            Extracted text
        """
        result = self.ocr.ocr(image_path, cls=True)
        
        if not result or not result[0]:
            return ""
        
        # Extract text from OCR results
        lines = []
        for line in result[0]:
            if line and len(line) >= 2:
                text = line[1][0]  # Get the text content
                lines.append(text)
        
        return "\n".join(lines)
    
    def process_from_bytes(self, image_bytes: bytes, document_id: str, filename: str = "image") -> ProcessedDocument:
        """
        Process image from bytes (useful for PDF image extraction).
        
        Args:
            image_bytes: Image data as bytes
            document_id: Unique identifier
            filename: Original filename
            
        Returns:
            ProcessedDocument with extracted text
        """
        # Save to temporary file for PaddleOCR
        with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp:
            tmp.write(image_bytes)
            tmp_path = tmp.name
        
        try:
            text = self._extract_text(tmp_path)
            
            chunk = ProcessedChunk(
                content=text,
                metadata={"ocr_engine": "paddleocr"},
                chunk_index=0,
            )
            
            return ProcessedDocument(
                document_id=document_id,
                filename=filename,
                content=text,
                chunks=[chunk],
                metadata={
                    "document_id": document_id,
                    "filename": filename,
                    "ocr_engine": "paddleocr",
                    "processor": "ocr_paddle",
                },
            )
        finally:
            # Clean up temp file
            Path(tmp_path).unlink(missing_ok=True)
