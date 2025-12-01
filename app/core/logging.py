"""
LMS RAG Backend - Logging Configuration
Centralized logging setup
"""

import logging
import sys
from typing import Any

from app.core.config import settings


def setup_logging() -> logging.Logger:
    """
    Configure application logging.
    
    Returns:
        Configured logger instance
    """
    # Create formatter
    formatter = logging.Formatter(settings.log_format)
    
    # Create console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    console_handler.setLevel(getattr(logging, settings.log_level.upper()))
    
    # Configure root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, settings.log_level.upper()))
    root_logger.addHandler(console_handler)
    
    # Create application logger
    logger = logging.getLogger("lms_rag")
    logger.setLevel(getattr(logging, settings.log_level.upper()))
    
    # Reduce noise from third-party libraries
    logging.getLogger("chromadb").setLevel(logging.WARNING)
    logging.getLogger("sentence_transformers").setLevel(logging.WARNING)
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    
    return logger


def get_logger(name: str = "lms_rag") -> logging.Logger:
    """
    Get a logger instance.
    
    Args:
        name: Logger name
        
    Returns:
        Logger instance
    """
    return logging.getLogger(name)


class LoggerMixin:
    """Mixin class to add logging capability to any class."""
    
    @property
    def logger(self) -> logging.Logger:
        """Get logger for this class."""
        return get_logger(self.__class__.__name__)
