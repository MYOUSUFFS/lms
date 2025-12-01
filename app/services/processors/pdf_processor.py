"""
LMS RAG Backend - PDF Document Processor
Uses PyMuPDF for high-quality PDF text extraction
"""

from pathlib import Path
from typing import Optional

import fitz  # PyMuPDF

from app.services.processors.base import (
    BaseDocumentProcessor,
    ProcessedChunk,
    ProcessedDocument,
)


class PDFProcessor(BaseDocumentProcessor):
    """PDF document processor using PyMuPDF."""
    
    SUPPORTED_EXTENSIONS = ["pdf"]
    
    def supports(self, file_extension: str) -> bool:
        """Check if this processor supports PDFs."""
        return file_extension.lower() in self.SUPPORTED_EXTENSIONS
    
    def process(self, file_path: Path, document_id: str) -> ProcessedDocument:
        """
        Process a PDF document and extract text content.
        
        Args:
            file_path: Path to the PDF file
            document_id: Unique identifier for the document
            
        Returns:
            ProcessedDocument with extracted content
        """
        self.logger.info(f"Processing PDF: {file_path.name}")
        
        try:
            doc = fitz.open(file_path)
            
            full_text = ""
            chunks = []
            
            for page_num in range(len(doc)):
                page = doc[page_num]
                page_text = page.get_text("text")
                
                if page_text.strip():
                    full_text += f"\n--- Page {page_num + 1} ---\n{page_text}"
                    
                    # Create chunk for this page
                    chunk = ProcessedChunk(
                        content=page_text.strip(),
                        metadata={
                            "page_number": page_num + 1,
                            "total_pages": len(doc),
                        },
                        chunk_index=page_num,
                        page_number=page_num + 1,
                    )
                    chunks.append(chunk)
            
            doc.close()
            
            metadata = self._create_base_metadata(file_path, document_id)
            metadata.update({
                "total_pages": len(chunks),
                "processor": "pdf_pymupdf",
            })
            
            self.logger.info(f"PDF processed: {len(chunks)} pages extracted")
            
            return ProcessedDocument(
                document_id=document_id,
                filename=file_path.name,
                content=full_text.strip(),
                chunks=chunks,
                metadata=metadata,
            )
            
        except Exception as e:
            self.logger.error(f"Error processing PDF {file_path.name}: {e}")
            raise
    
    def extract_images(self, file_path: Path) -> list[bytes]:
        """
        Extract images from PDF for OCR processing.
        
        Args:
            file_path: Path to the PDF file
            
        Returns:
            List of image bytes
        """
        images = []
        
        try:
            doc = fitz.open(file_path)
            
            for page_num in range(len(doc)):
                page = doc[page_num]
                image_list = page.get_images()
                
                for img_index, img in enumerate(image_list):
                    xref = img[0]
                    pix = fitz.Pixmap(doc, xref)
                    
                    if pix.n < 5:  # GRAY or RGB
                        images.append(pix.tobytes("png"))
                    else:  # CMYK
                        pix = fitz.Pixmap(fitz.csRGB, pix)
                        images.append(pix.tobytes("png"))
                    
                    pix = None
            
            doc.close()
            
        except Exception as e:
            self.logger.error(f"Error extracting images from PDF: {e}")
        
        return images
