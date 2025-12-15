"""
Analytics Event Model
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import String, DateTime, ForeignKey, Index
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class AnalyticsEvent(Base):
    """Analytics event model for tracking user activities"""
    
    __tablename__ = "analytics_events"
    
    # Primary Key
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )
    
    # Foreign Keys (nullable for flexibility)
    organization_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("organizations.id", ondelete="CASCADE"),
        nullable=True,
        index=True
    )
    classroom_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("classrooms.id", ondelete="CASCADE"),
        nullable=True,
        index=True
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    
    # Event Details
    event_type: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        index=True
    )  # 'message_sent', 'document_uploaded', 'login', etc.
    
    event_data: Mapped[dict] = mapped_column(JSONB, default=dict, nullable=False)
    
    # Timestamp
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=datetime.utcnow,
        nullable=False,
        index=True
    )
    
    # Relationships
    organization = relationship("Organization", back_populates="analytics_events")
    classroom = relationship("Classroom", back_populates="analytics_events")
    user = relationship("User", back_populates="analytics_events")
    
    __table_args__ = (
        Index("idx_analytics_org", "organization_id"),
        Index("idx_analytics_classroom", "classroom_id"),
        Index("idx_analytics_user", "user_id"),
        Index("idx_analytics_type", "event_type"),
        Index("idx_analytics_created", "created_at"),
    )
    
    def __repr__(self) -> str:
        return f"<AnalyticsEvent(id={self.id}, type={self.event_type}, user={self.user_id})>"
