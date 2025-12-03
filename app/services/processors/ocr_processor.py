"""
LMS RAG Backend - OCR Processor
Uses PaddleOCR for image text extraction
"""

import io
import tempfile
from pathlib import Path
from typing import Optional, Union

import cv2
import numpy as np

from app.services.processors.base import (
    BaseDocumentProcessor,
    ProcessedChunk,
    ProcessedDocument,
)


class OCRProcessor(BaseDocumentProcessor):
    """OCR processor using PaddleOCR."""
    
    SUPPORTED_EXTENSIONS = ["png", "jpg", "jpeg", "bmp", "tiff", "tif", "webp"]
    
    # Maximum image dimension to prevent memory issues
    MAX_IMAGE_DIMENSION = 2000
    
    def __init__(self):
        super().__init__()
        self._ocr = None  # Lazy initialization
    
    @property
    def ocr(self):
        """Lazy-load PaddleOCR to avoid startup overhead."""
        if self._ocr is None:
            try:
                from paddleocr import PaddleOCR
                # Use PP-OCRv4 mobile model for better performance and memory usage
                self._ocr = PaddleOCR(
                    lang="en",
                    ocr_version="PP-OCRv4",
                )
                self.logger.info("PaddleOCR initialized successfully (PP-OCRv4)")
            except ImportError:
                self.logger.warning("PaddleOCR not installed. OCR features disabled.")
                raise ImportError("PaddleOCR is required for image processing")
        return self._ocr
        return self._ocr
    
    def _read_image(self, file_path: str) -> Optional[np.ndarray]:
        """
        Read image using cv2 to handle Unicode filenames properly.
        Also resizes large images to prevent memory issues.
        
        Args:
            file_path: Path to the image file
            
        Returns:
            Image as numpy array or None if failed
        """
        try:
            # Read image with cv2
            img = cv2.imread(file_path)
            
            if img is None:
                self.logger.warning(f"cv2 couldn't read image, trying numpy approach")
                # Fallback: read as bytes and decode
                with open(file_path, 'rb') as f:
                    img_bytes = f.read()
                img_array = np.frombuffer(img_bytes, dtype=np.uint8)
                img = cv2.imdecode(img_array, cv2.IMREAD_COLOR)
            
            if img is None:
                self.logger.error(f"Failed to read image: {file_path}")
                return None
            
            # Resize if too large to prevent memory issues
            height, width = img.shape[:2]
            if max(height, width) > self.MAX_IMAGE_DIMENSION:
                scale = self.MAX_IMAGE_DIMENSION / max(height, width)
                new_width = int(width * scale)
                new_height = int(height * scale)
                img = cv2.resize(img, (new_width, new_height), interpolation=cv2.INTER_AREA)
                self.logger.info(f"Resized image from {width}x{height} to {new_width}x{new_height}")
            
            return img
            
        except Exception as e:
            self.logger.error(f"Error reading image {file_path}: {e}")
            return None
    
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
        # Read and preprocess image
        img = self._read_image(image_path)
        if img is None:
            self.logger.error(f"Could not read image: {image_path}")
            return ""
        
        # Run OCR on numpy array (not file path to avoid Unicode issues)
        result = self.ocr.ocr(img)
        
        if not result or len(result) == 0:
            return ""
        
        # Handle new PaddleOCR 3.x API (OCRResult dict-like object)
        ocr_result = result[0]
        
        # New API: result is a dict with 'rec_texts' key
        if hasattr(ocr_result, 'keys') and 'rec_texts' in ocr_result:
            texts = ocr_result.get('rec_texts', [])
            return "\n".join(texts) if texts else ""
        
        # Legacy API fallback: result is list of [bbox, (text, confidence)]
        if isinstance(ocr_result, list):
            lines = []
            for line in ocr_result:
                if line and len(line) >= 2:
                    text = line[1][0]  # Get the text content
                    lines.append(text)
            return "\n".join(lines)
        
        return ""
    
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
