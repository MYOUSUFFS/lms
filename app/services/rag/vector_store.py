"""
LMS RAG Backend - Vector Store Service
ChromaDB integration for vector storage and retrieval
"""

import uuid
from typing import Optional

from app.core.config import settings
from app.core.logging import get_logger
from app.services.processors.base import ProcessedChunk, ProcessedDocument

logger = get_logger(__name__)


class VectorStore:
    """
    Vector store using ChromaDB for document storage and similarity search.
    """
    
    def __init__(
        self,
        persist_directory: str = None,
        collection_name: str = None,
    ):
        """
        Initialize ChromaDB vector store.
        
        Args:
            persist_directory: Directory for ChromaDB persistence
            collection_name: Name of the collection
        """
        self.persist_directory = persist_directory or str(settings.chroma_path)
        self.collection_name = collection_name or settings.chroma_collection_name
        
        self._client = None
        self._collection = None
        self._embeddings_service = None
        
        logger.info(f"VectorStore initialized: {self.collection_name}")
    
    @property
    def client(self):
        """Lazy-load ChromaDB client."""
        if self._client is None:
            import chromadb
            from chromadb.config import Settings as ChromaSettings
            
            self._client = chromadb.PersistentClient(
                path=self.persist_directory,
                settings=ChromaSettings(
                    anonymized_telemetry=False,
                    allow_reset=True,
                ),
            )
            logger.info(f"ChromaDB client initialized at {self.persist_directory}")
        
        return self._client
    
    @property
    def collection(self):
        """Get or create the collection."""
        if self._collection is None:
            self._collection = self.client.get_or_create_collection(
                name=self.collection_name,
                metadata={"hnsw:space": "cosine"},
            )
            logger.info(f"Collection '{self.collection_name}' ready with {self._collection.count()} documents")
        
        return self._collection
    
    @property
    def embeddings_service(self):
        """Get embeddings service."""
        if self._embeddings_service is None:
            from app.services.rag.embeddings import get_embeddings_service
            self._embeddings_service = get_embeddings_service()
        return self._embeddings_service
    
    def add_document(self, document: ProcessedDocument) -> int:
        """
        Add a processed document to the vector store.
        
        Args:
            document: ProcessedDocument with chunks
            
        Returns:
            Number of chunks added
        """
        if not document.chunks:
            logger.warning(f"No chunks in document {document.document_id}")
            return 0
        
        # Prepare data for ChromaDB
        ids = []
        texts = []
        metadatas = []
        
        for chunk in document.chunks:
            chunk_id = f"{document.document_id}_{chunk.chunk_index}"
            ids.append(chunk_id)
            texts.append(chunk.content)
            
            # Build metadata from document metadata (includes classroom_id) and chunk metadata
            metadata = {
                "document_id": document.document_id,
                "filename": document.filename,
                "chunk_index": chunk.chunk_index,
                **{k: str(v) for k, v in document.metadata.items() if v is not None and k not in ["document_id", "filename"]},
                **{k: str(v) for k, v in chunk.metadata.items() if v is not None},
            }
            if chunk.page_number:
                metadata["page_number"] = chunk.page_number
            
            metadatas.append(metadata)
        
        # Generate embeddings
        logger.info(f"Generating embeddings for {len(texts)} chunks")
        embeddings = self.embeddings_service.embed_texts(texts)
        
        # Add to ChromaDB
        self.collection.add(
            ids=ids,
            embeddings=embeddings,
            documents=texts,
            metadatas=metadatas,
        )
        
        logger.info(f"Added {len(ids)} chunks from document {document.document_id}")
        return len(ids)
    
    def search(
        self,
        query: str,
        top_k: int = None,
        document_ids: list[str] = None,
        similarity_threshold: float = None,
    ) -> list[dict]:
        """
        Search for similar chunks.
        
        Args:
            query: Search query
            top_k: Number of results to return
            document_ids: Filter by specific document IDs
            similarity_threshold: Minimum similarity score
            
        Returns:
            List of matching chunks with metadata
        """
        top_k = top_k or settings.top_k_results
        similarity_threshold = similarity_threshold or settings.similarity_threshold
        
        # Generate query embedding
        query_embedding = self.embeddings_service.embed_query(query)
        
        # Build where filter
        where_filter = None
        if document_ids:
            where_filter = {"document_id": {"$in": document_ids}}
        
        # Query ChromaDB
        results = self.collection.query(
            query_embeddings=[query_embedding],
            n_results=top_k,
            where=where_filter,
            include=["documents", "metadatas", "distances"],
        )
        
        # Process results
        matches = []
        
        if results and results["ids"] and results["ids"][0]:
            for i, chunk_id in enumerate(results["ids"][0]):
                # ChromaDB returns distance, convert to similarity
                distance = results["distances"][0][i]
                similarity = 1 - distance  # For cosine distance
                
                if similarity >= similarity_threshold:
                    matches.append({
                        "chunk_id": chunk_id,
                        "content": results["documents"][0][i],
                        "metadata": results["metadatas"][0][i],
                        "similarity_score": similarity,
                    })
        
        logger.debug(f"Search returned {len(matches)} results for query: {query[:50]}...")
        return matches
    
    def delete_document(self, document_id: str) -> int:
        """
        Delete all chunks for a document.
        
        Args:
            document_id: Document ID to delete
            
        Returns:
            Number of chunks deleted
        """
        # Get all chunk IDs for this document
        results = self.collection.get(
            where={"document_id": document_id},
            include=[],
        )
        
        if results and results["ids"]:
            self.collection.delete(ids=results["ids"])
            logger.info(f"Deleted {len(results['ids'])} chunks for document {document_id}")
            return len(results["ids"])
        
        return 0
    
    def get_document_chunks(self, document_id: str) -> list[dict]:
        """
        Get all chunks for a document.
        
        Args:
            document_id: Document ID
            
        Returns:
            List of chunks with metadata
        """
        results = self.collection.get(
            where={"document_id": document_id},
            include=["documents", "metadatas"],
        )
        
        chunks = []
        if results and results["ids"]:
            for i, chunk_id in enumerate(results["ids"]):
                chunks.append({
                    "chunk_id": chunk_id,
                    "content": results["documents"][i],
                    "metadata": results["metadatas"][i],
                })
        
        return chunks
    
    def list_documents(self) -> list[dict]:
        """
        List all unique documents in the store.
        
        Returns:
            List of document info
        """
        # Get all metadatas
        results = self.collection.get(include=["metadatas"])
        
        # Extract unique documents
        documents = {}
        if results and results["metadatas"]:
            for metadata in results["metadatas"]:
                doc_id = metadata.get("document_id")
                if doc_id:
                    if doc_id not in documents:
                        documents[doc_id] = {
                            "document_id": doc_id,
                            "filename": metadata.get("filename", "unknown"),
                            "classroom_id": metadata.get("classroom_id"),
                            "chunks_count": 0,
                        }
                    else:
                        # Update classroom_id if this chunk has it and document doesn't
                        if metadata.get("classroom_id") and not documents[doc_id].get("classroom_id"):
                            documents[doc_id]["classroom_id"] = metadata.get("classroom_id")
                    
                    documents[doc_id]["chunks_count"] += 1
        
        return list(documents.values())
    
    def count(self) -> int:
        """Get total number of chunks in the store."""
        return self.collection.count()
    
    def reset(self) -> None:
        """Reset the vector store (delete all data)."""
        self.client.delete_collection(self.collection_name)
        self._collection = None
        logger.warning(f"Vector store collection '{self.collection_name}' reset")


# Global singleton
_vector_store: Optional[VectorStore] = None


def get_vector_store() -> VectorStore:
    """Get or create vector store singleton."""
    global _vector_store
    if _vector_store is None:
        _vector_store = VectorStore()
    return _vector_store
