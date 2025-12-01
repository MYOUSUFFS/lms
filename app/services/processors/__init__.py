"""
LMS RAG Backend - Document Processors Module
"""

from app.services.processors.base import (
    BaseDocumentProcessor,
    ProcessedChunk,
    ProcessedDocument,
)
from app.services.processors.pdf_processor import PDFProcessor
from app.services.processors.html_processor import HTMLProcessor
from app.services.processors.text_processor import TextProcessor
from app.services.processors.csv_processor import CSVProcessor
from app.services.processors.ocr_processor import OCRProcessor
from app.services.processors.web_scraper import WebScraper

__all__ = [
    "BaseDocumentProcessor",
    "ProcessedChunk",
    "ProcessedDocument",
    "PDFProcessor",
    "HTMLProcessor",
    "TextProcessor",
    "CSVProcessor",
    "OCRProcessor",
    "WebScraper",
]
