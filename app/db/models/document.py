"""
Document Model
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import String, BigInteger, Integer, DateTime, Text, ForeignKey, Index
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class Document(Base):
    """Document model for uploaded files"""
    
    __tablename__ = "documents"
    
    # Primary Key
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )
    
    # Foreign Keys
    classroom_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("classrooms.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    uploader_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        nullable=False,
        index=True
    )
    
    # File Information
    filename: Mapped[str] = mapped_column(String(255), nullable=False)
    original_filename: Mapped[str] = mapped_column(String(255), nullable=False)
    file_path: Mapped[str] = mapped_column(Text, nullable=False)
    file_size: Mapped[int] = mapped_column(BigInteger, nullable=False)
    mime_type: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    file_type: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    
    # Visibility: 'classroom' or 'personal'
    visibility: Mapped[str] = mapped_column(String(20), default="classroom", nullable=False)
    
    # Processing Status
    chunk_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    processing_status: Mapped[str] = mapped_column(
        String(20),
        default="pending",
        nullable=False,
        index=True
    )  # 'pending', 'processing', 'completed', 'failed'
    processing_error: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Timestamps
    uploaded_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=datetime.utcnow,
        nullable=False
    )
    
    # Custom metadata (JSON) - renamed to avoid SQLAlchemy reserved name
    doc_metadata: Mapped[dict] = mapped_column(JSONB, default=dict, nullable=False)
    
    # Relationships
    classroom = relationship("Classroom", back_populates="documents")
    uploader = relationship("User", back_populates="uploaded_documents", foreign_keys=[uploader_id])
    
    __table_args__ = (
        Index("idx_documents_classroom", "classroom_id"),
        Index("idx_documents_uploader", "uploader_id"),
        Index("idx_documents_status", "processing_status"),
    )
    
    def __repr__(self) -> str:
        return f"<Document(id={self.id}, filename={self.filename}, classroom={self.classroom_id})>"
