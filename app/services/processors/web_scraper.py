"""
LMS RAG Backend - Web Scraper
Uses requests + BeautifulSoup for website scraping
"""

from pathlib import Path
from typing import Optional
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup

from app.core.logging import get_logger
from app.services.processors.base import ProcessedChunk, ProcessedDocument

logger = get_logger(__name__)


class WebScraper:
    """Web scraper for extracting content from URLs."""
    
    # Default headers to mimic a browser
    DEFAULT_HEADERS = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.5",
    }
    
    # Tags to remove
    REMOVE_TAGS = [
        "script", "style", "meta", "link", "noscript",
        "header", "footer", "nav", "aside", "iframe",
        "form", "button", "input",
    ]
    
    def __init__(self, timeout: int = 30):
        """
        Initialize web scraper.
        
        Args:
            timeout: Request timeout in seconds
        """
        self.timeout = timeout
        self.session = requests.Session()
        self.session.headers.update(self.DEFAULT_HEADERS)
    
    def scrape(self, url: str, document_id: str) -> ProcessedDocument:
        """
        Scrape content from a URL.
        
        Args:
            url: URL to scrape
            document_id: Unique identifier for the document
            
        Returns:
            ProcessedDocument with scraped content
        """
        logger.info(f"Scraping URL: {url}")
        
        try:
            response = self.session.get(url, timeout=self.timeout)
            response.raise_for_status()
            
            # Extract content
            text, title, links = self._extract_content(response.text, url)
            
            chunk = ProcessedChunk(
                content=text,
                metadata={
                    "title": title,
                    "source_url": url,
                    "links_found": len(links),
                },
                chunk_index=0,
            )
            
            metadata = {
                "document_id": document_id,
                "filename": title or self._url_to_filename(url),
                "source_url": url,
                "title": title,
                "status_code": response.status_code,
                "content_type": response.headers.get("content-type", ""),
                "links_found": len(links),
                "processor": "web_scraper",
            }
            
            logger.info(f"Scraped {len(text)} characters from {url}")
            
            return ProcessedDocument(
                document_id=document_id,
                filename=title or self._url_to_filename(url),
                content=text,
                chunks=[chunk],
                metadata=metadata,
            )
            
        except requests.RequestException as e:
            logger.error(f"Error scraping {url}: {e}")
            raise
    
    def _extract_content(self, html: str, base_url: str) -> tuple[str, Optional[str], list[str]]:
        """
        Extract clean text and links from HTML.
        
        Args:
            html: Raw HTML content
            base_url: Base URL for resolving relative links
            
        Returns:
            Tuple of (text, title, links)
        """
        soup = BeautifulSoup(html, "lxml")
        
        # Get title
        title = None
        title_tag = soup.find("title")
        if title_tag:
            title = title_tag.get_text(strip=True)
        
        # Extract links before removing elements
        links = []
        for a_tag in soup.find_all("a", href=True):
            href = a_tag["href"]
            if href.startswith(("http://", "https://")):
                links.append(href)
            elif not href.startswith(("#", "javascript:", "mailto:")):
                links.append(urljoin(base_url, href))
        
        # Remove unwanted tags
        for tag in self.REMOVE_TAGS:
            for element in soup.find_all(tag):
                element.decompose()
        
        # Get main content (prefer article or main tags)
        main_content = soup.find("main") or soup.find("article") or soup.body or soup
        
        # Extract text
        text = main_content.get_text(separator="\n", strip=True)
        
        # Clean up
        lines = [line.strip() for line in text.split("\n") if line.strip()]
        text = "\n".join(lines)
        
        return text, title, links
    
    def _url_to_filename(self, url: str) -> str:
        """Convert URL to a safe filename."""
        parsed = urlparse(url)
        path = parsed.path.strip("/").replace("/", "_") or "index"
        return f"{parsed.netloc}_{path}.html"
    
    def scrape_multiple(self, urls: list[str], base_document_id: str, max_depth: int = 1) -> list[ProcessedDocument]:
        """
        Scrape multiple URLs (with optional link following).
        
        Args:
            urls: List of URLs to scrape
            base_document_id: Base document ID (will be suffixed)
            max_depth: Maximum crawl depth
            
        Returns:
            List of ProcessedDocuments
        """
        documents = []
        visited = set()
        
        for i, url in enumerate(urls):
            if url in visited:
                continue
            
            visited.add(url)
            
            try:
                doc = self.scrape(url, f"{base_document_id}_{i}")
                documents.append(doc)
            except Exception as e:
                logger.warning(f"Failed to scrape {url}: {e}")
        
        return documents
