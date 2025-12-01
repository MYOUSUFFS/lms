"""
LMS RAG Backend - HTML Document Processor
Uses BeautifulSoup for HTML parsing
"""

from pathlib import Path
from typing import Optional

from bs4 import BeautifulSoup

from app.services.processors.base import (
    BaseDocumentProcessor,
    ProcessedChunk,
    ProcessedDocument,
)


class HTMLProcessor(BaseDocumentProcessor):
    """HTML document processor using BeautifulSoup."""
    
    SUPPORTED_EXTENSIONS = ["html", "htm"]
    
    # Tags to remove (typically non-content elements)
    REMOVE_TAGS = [
        "script", "style", "meta", "link", "noscript", 
        "header", "footer", "nav", "aside", "iframe"
    ]
    
    def supports(self, file_extension: str) -> bool:
        """Check if this processor supports HTML files."""
        return file_extension.lower() in self.SUPPORTED_EXTENSIONS
    
    def process(self, file_path: Path, document_id: str) -> ProcessedDocument:
        """
        Process an HTML document and extract text content.
        
        Args:
            file_path: Path to the HTML file
            document_id: Unique identifier for the document
            
        Returns:
            ProcessedDocument with extracted content
        """
        self.logger.info(f"Processing HTML: {file_path.name}")
        
        try:
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                html_content = f.read()
            
            text, title = self._extract_text(html_content)
            
            # Create single chunk for HTML content
            chunk = ProcessedChunk(
                content=text,
                metadata={"title": title} if title else {},
                chunk_index=0,
            )
            
            metadata = self._create_base_metadata(file_path, document_id)
            metadata.update({
                "title": title,
                "processor": "html_beautifulsoup",
            })
            
            self.logger.info(f"HTML processed: {len(text)} characters extracted")
            
            return ProcessedDocument(
                document_id=document_id,
                filename=file_path.name,
                content=text,
                chunks=[chunk],
                metadata=metadata,
            )
            
        except Exception as e:
            self.logger.error(f"Error processing HTML {file_path.name}: {e}")
            raise
    
    def _extract_text(self, html_content: str) -> tuple[str, Optional[str]]:
        """
        Extract clean text from HTML content.
        
        Args:
            html_content: Raw HTML string
            
        Returns:
            Tuple of (extracted_text, title)
        """
        soup = BeautifulSoup(html_content, "lxml")
        
        # Extract title
        title = None
        title_tag = soup.find("title")
        if title_tag:
            title = title_tag.get_text(strip=True)
        
        # Remove unwanted tags
        for tag in self.REMOVE_TAGS:
            for element in soup.find_all(tag):
                element.decompose()
        
        # Extract text
        text = soup.get_text(separator="\n", strip=True)
        
        # Clean up multiple newlines
        lines = [line.strip() for line in text.split("\n") if line.strip()]
        text = "\n".join(lines)
        
        return text, title
    
    def process_from_string(self, html_content: str, document_id: str, source_url: str = "") -> ProcessedDocument:
        """
        Process HTML content from a string (useful for web scraping).
        
        Args:
            html_content: Raw HTML string
            document_id: Unique identifier
            source_url: Source URL if applicable
            
        Returns:
            ProcessedDocument with extracted content
        """
        text, title = self._extract_text(html_content)
        
        chunk = ProcessedChunk(
            content=text,
            metadata={
                "title": title,
                "source_url": source_url,
            },
            chunk_index=0,
        )
        
        metadata = {
            "document_id": document_id,
            "filename": title or source_url or "scraped_content",
            "title": title,
            "source_url": source_url,
            "processor": "html_beautifulsoup",
        }
        
        return ProcessedDocument(
            document_id=document_id,
            filename=title or "scraped_content.html",
            content=text,
            chunks=[chunk],
            metadata=metadata,
        )
