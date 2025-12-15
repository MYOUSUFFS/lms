"""
Parent-Student Link Model
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import String, Boolean, DateTime, ForeignKey, Index, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class ParentStudentLink(Base):
    """Parent-Student relationship model"""
    
    __tablename__ = "parent_student_links"
    
    # Primary Key
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )
    
    # Foreign Keys
    parent_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    student_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    organization_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("organizations.id", ondelete="CASCADE"),
        nullable=False
    )
    
    # Relationship Details - renamed to avoid SQLAlchemy function name conflict
    relationship_type: Mapped[Optional[str]] = mapped_column(
        String(50),
        nullable=True
    )  # 'father', 'mother', 'guardian'
    
    # Permissions
    can_view_chats: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    
    # Timestamps
    linked_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=datetime.utcnow,
        nullable=False
    )
    linked_by: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        nullable=True
    )
    
    # Relationships
    parent = relationship("User", back_populates="parent_links", foreign_keys="ParentStudentLink.parent_id")
    student = relationship("User", back_populates="student_links", foreign_keys="ParentStudentLink.student_id")
    organization = relationship("Organization", back_populates="parent_student_links")
    
    __table_args__ = (
        UniqueConstraint("parent_id", "student_id", "organization_id", name="uq_parent_student_org"),
        Index("idx_parent_links_parent", "parent_id"),
        Index("idx_parent_links_student", "student_id"),
    )
    
    def __repr__(self) -> str:
        return f"<ParentStudentLink(parent={self.parent_id}, student={self.student_id})>"
