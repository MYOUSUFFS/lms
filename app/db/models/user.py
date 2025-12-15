"""
User Model
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import String, Boolean, DateTime, Text, Index, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class User(Base):
    """User model for authentication and profile management"""
    
    __tablename__ = "users"
    
    # Primary Key
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )
    
    # Authentication
    email: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        nullable=False,
        index=True
    )
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    
    # Profile Information
    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    phone: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    profile_picture_url: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Status Flags
    is_email_verified: Mapped[bool] = mapped_column(Boolean, default=False)
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
    last_login_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True),
        nullable=True
    )
    
    # Preferences (JSON)
    preferences: Mapped[dict] = mapped_column(
        JSONB,
        default=dict,
        nullable=False
    )
    
    # Relationships
    organization_memberships = relationship(
        "OrganizationMember",
        back_populates="user",
        foreign_keys="OrganizationMember.user_id",
        cascade="all, delete-orphan"
    )
    
    owned_classrooms = relationship(
        "Classroom",
        back_populates="owner",
        foreign_keys="Classroom.owner_id"
    )
    
    classroom_memberships = relationship(
        "ClassroomMember",
        back_populates="user",
        foreign_keys="ClassroomMember.user_id",
        cascade="all, delete-orphan"
    )
    
    uploaded_documents = relationship(
        "Document",
        back_populates="uploader",
        foreign_keys="Document.uploader_id"
    )
    
    conversations = relationship(
        "Conversation",
        back_populates="user",
        cascade="all, delete-orphan"
    )
    
    invited_members = relationship(
        "OrganizationMember",
        foreign_keys="OrganizationMember.invited_by",
        cascade="all, delete-orphan"
    )
    
    sent_invitations = relationship(
        "Invitation",
        back_populates="invited_by_user",
        foreign_keys="Invitation.invited_by"
    )
    
    parent_links = relationship(
        "ParentStudentLink",
        back_populates="parent",
        foreign_keys="ParentStudentLink.parent_id"
    )
    
    student_links = relationship(
        "ParentStudentLink",
        back_populates="student",
        foreign_keys="ParentStudentLink.student_id"
    )
    
    analytics_events = relationship(
        "AnalyticsEvent",
        back_populates="user",
        cascade="all, delete-orphan"
    )
    
    # Constraints
    __table_args__ = (
        CheckConstraint("email = LOWER(email)", name="email_lowercase"),
        Index("idx_users_email", "email"),
        Index("idx_users_created_at", "created_at"),
    )
    
    def __repr__(self) -> str:
        return f"<User(id={self.id}, email={self.email}, name={self.full_name})>"
