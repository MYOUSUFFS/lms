"""
LMS RAG Backend - Embeddings Service
BGE embeddings using sentence-transformers
"""

from typing import Optional

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)


class EmbeddingsService:
    """
    Embeddings service using BGE models via sentence-transformers.
    Supports BGE-Base, BGE-Large, and future BGE-M3 for multilingual.
    """
    
    def __init__(self, model_name: str = None):
        """
        Initialize embeddings service.
        
        Args:
            model_name: Model name (default from settings)
        """
        self.model_name = model_name or settings.embedding_model
        self._model = None  # Lazy initialization
        self._dimension = None
        
        logger.info(f"EmbeddingsService initialized with model: {self.model_name}")
    
    @property
    def model(self):
        """Lazy-load the embedding model."""
        if self._model is None:
            logger.info(f"Loading embedding model: {self.model_name}")
            try:
                from sentence_transformers import SentenceTransformer
                
                self._model = SentenceTransformer(
                    self.model_name,
                    device="cpu",  # Can be changed to "cuda" if GPU available
                )
                self._dimension = self._model.get_sentence_embedding_dimension()
                
                logger.info(f"Model loaded. Embedding dimension: {self._dimension}")
            except Exception as e:
                logger.error(f"Failed to load embedding model: {e}")
                raise
        
        return self._model
    
    @property
    def dimension(self) -> int:
        """Get embedding dimension."""
        if self._dimension is None:
            _ = self.model  # Trigger model loading
        return self._dimension
    
    def embed_text(self, text: str) -> list[float]:
        """
        Generate embedding for a single text.
        
        Args:
            text: Text to embed
            
        Returns:
            Embedding vector as list of floats
        """
        if not text or not text.strip():
            return [0.0] * self.dimension
        
        # BGE models work better with instruction prefix for queries
        embedding = self.model.encode(
            text,
            normalize_embeddings=True,
            show_progress_bar=False,
        )
        
        return embedding.tolist()
    
    def embed_texts(self, texts: list[str], batch_size: int = 32) -> list[list[float]]:
        """
        Generate embeddings for multiple texts.
        
        Args:
            texts: List of texts to embed
            batch_size: Batch size for processing
            
        Returns:
            List of embedding vectors
        """
        if not texts:
            return []
        
        # Filter empty texts
        valid_texts = [t if t and t.strip() else " " for t in texts]
        
        embeddings = self.model.encode(
            valid_texts,
            normalize_embeddings=True,
            batch_size=batch_size,
            show_progress_bar=len(texts) > 100,
        )
        
        return [emb.tolist() for emb in embeddings]
    
    def embed_query(self, query: str) -> list[float]:
        """
        Generate embedding for a query (with BGE instruction prefix).
        
        For BGE models, queries should be prefixed with an instruction
        for better retrieval performance.
        
        Args:
            query: Query text
            
        Returns:
            Query embedding vector
        """
        if not query or not query.strip():
            return [0.0] * self.dimension
        
        # BGE instruction prefix for queries
        instruction = "Represent this sentence for searching relevant passages: "
        prefixed_query = instruction + query
        
        embedding = self.model.encode(
            prefixed_query,
            normalize_embeddings=True,
            show_progress_bar=False,
        )
        
        return embedding.tolist()
    
    def similarity(self, embedding1: list[float], embedding2: list[float]) -> float:
        """
        Calculate cosine similarity between two embeddings.
        
        Args:
            embedding1: First embedding
            embedding2: Second embedding
            
        Returns:
            Cosine similarity score (0-1)
        """
        import numpy as np
        
        vec1 = np.array(embedding1)
        vec2 = np.array(embedding2)
        
        # Cosine similarity (embeddings are already normalized)
        return float(np.dot(vec1, vec2))


# Global singleton instance
_embeddings_service: Optional[EmbeddingsService] = None


def get_embeddings_service() -> EmbeddingsService:
    """Get or create embeddings service singleton."""
    global _embeddings_service
    if _embeddings_service is None:
        _embeddings_service = EmbeddingsService()
    return _embeddings_service
