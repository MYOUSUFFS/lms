"""
Classroom Models
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import String, Boolean, DateTime, Text, ForeignKey, Index, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class Classroom(Base):
    """Classroom model for organizing learning groups"""
    
    __tablename__ = "classrooms"
    
    # Primary Key
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )
    
    # Basic Information
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Foreign Keys
    organization_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("organizations.id", ondelete="CASCADE"),
        nullable=True,
        index=True
    )
    owner_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    
    # Owner Type: 'user' or 'teacher'
    owner_type: Mapped[str] = mapped_column(String(20), nullable=False)
    
    # Classroom Details
    subject: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    grade_level: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    academic_year: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    
    # Settings (AI config, visibility, etc.)
    settings: Mapped[dict] = mapped_column(JSONB, default=dict, nullable=False)
    
    # Status
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=datetime.utcnow,
        nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False
    )
    
    # ChromaDB Collection Name (unique)
    chroma_collection_name: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        nullable=False,
        index=True
    )
    
    # Relationships
    organization = relationship("Organization", back_populates="classrooms")
    owner = relationship("User", back_populates="owned_classrooms", foreign_keys=[owner_id])
    
    members = relationship(
        "ClassroomMember",
        back_populates="classroom",
        cascade="all, delete-orphan"
    )
    
    documents = relationship(
        "Document",
        back_populates="classroom",
        cascade="all, delete-orphan"
    )
    
    conversations = relationship(
        "Conversation",
        back_populates="classroom",
        cascade="all, delete-orphan"
    )
    
    analytics_events = relationship(
        "AnalyticsEvent",
        back_populates="classroom"
    )
    
    __table_args__ = (
        Index("idx_classrooms_org", "organization_id"),
        Index("idx_classrooms_owner", "owner_id"),
        Index("idx_classrooms_chroma", "chroma_collection_name"),
    )
    
    def __repr__(self) -> str:
        return f"<Classroom(id={self.id}, name={self.name}, owner={self.owner_id})>"


class ClassroomMember(Base):
    """Classroom membership"""
    
    __tablename__ = "classroom_members"
    
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
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    
    # Role: 'teacher', 'student', 'observer'
    role: Mapped[str] = mapped_column(String(20), nullable=False)
    
    # Timestamps
    joined_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=datetime.utcnow,
        nullable=False
    )
    last_accessed_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True),
        nullable=True
    )
    
    # Relationships
    classroom = relationship("Classroom", back_populates="members")
    user = relationship("User", back_populates="classroom_memberships")
    
    __table_args__ = (
        UniqueConstraint("classroom_id", "user_id", name="uq_classroom_member"),
        Index("idx_classroom_members_classroom", "classroom_id"),
        Index("idx_classroom_members_user", "user_id"),
    )
    
    def __repr__(self) -> str:
        return f"<ClassroomMember(classroom={self.classroom_id}, user={self.user_id}, role={self.role})>"
