"""
LMS RAG Backend - Configuration Module
Centralized configuration using Pydantic Settings
"""

from functools import lru_cache
from pathlib import Path
from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore"
    )
    
    # Application Settings
    app_name: str = "LMS RAG Backend"
    app_env: Literal["development", "staging", "production"] = "development"
    debug: bool = True
    host: str = "0.0.0.0"
    port: int = 8000
    
    # API Key Authentication (Legacy - will be deprecated)
    api_key: str = "change-me-in-production"
    api_key_header: str = "X-API-Key"
    
    # Database
    database_url: str = "postgresql+asyncpg://lms_user:lms_password@localhost:5432/lms_db"
    database_echo: bool = False
    
    # Redis
    redis_url: str = "redis://localhost:6379/0"
    redis_password: str = ""
    
    # JWT Authentication
    jwt_secret: str = "change-me-in-production-use-strong-random-key"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 15
    refresh_token_expire_days: int = 7
    
    # Email Configuration
    smtp_host: str = "smtp.gmail.com"
    smtp_port: int = 587
    smtp_user: str = ""
    smtp_password: str = ""
    smtp_from_email: str = "noreply@lms.com"
    smtp_from_name: str = "LMS Platform"
    
    # Ollama (Local LLM - Primary)
    ollama_base_url: str = "http://localhost:11434"
    ollama_model: str = "llama3:8b"
    
    # Cloud Fallback
    groq_api_key: str = ""
    groq_model: str = "llama3-8b-8192"
    together_api_key: str = ""
    together_model: str = "meta-llama/Llama-3-8b-chat-hf"
    use_cloud_fallback: bool = True
    cloud_provider: Literal["groq", "together"] = "groq"
    
    # ChromaDB
    chroma_persist_directory: str = "./data/chroma_db"
    chroma_collection_name: str = "lms_documents"
    
    # Embeddings
    embedding_model: str = "BAAI/bge-large-en-v1.5"
    
    # Document Processing
    upload_directory: str = "./data/uploads"
    max_upload_size_mb: int = 50
    allowed_extensions: str = "pdf,txt,html,csv,png,jpg,jpeg"
    
    # Chunking
    chunk_size: int = 1000
    chunk_overlap: int = 200
    
    # RAG
    top_k_results: int = 5
    similarity_threshold: float = 0.7
    
    # Logging
    log_level: str = "INFO"
    log_format: str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    
    @property
    def allowed_extensions_list(self) -> list[str]:
        """Get allowed extensions as a list."""
        return [ext.strip().lower() for ext in self.allowed_extensions.split(",")]
    
    @property
    def max_upload_size_bytes(self) -> int:
        """Get max upload size in bytes."""
        return self.max_upload_size_mb * 1024 * 1024
    
    @property
    def upload_path(self) -> Path:
        """Get upload directory as Path object."""
        path = Path(self.upload_directory)
        path.mkdir(parents=True, exist_ok=True)
        return path
    
    @property
    def chroma_path(self) -> Path:
        """Get ChromaDB directory as Path object."""
        path = Path(self.chroma_persist_directory)
        path.mkdir(parents=True, exist_ok=True)
        return path


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()


# Global settings instance
settings = get_settings()
