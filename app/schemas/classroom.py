"""
Classroom Pydantic Schemas
"""

from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field


class ClassroomBase(BaseModel):
    """Base classroom schema"""
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    organization_id: Optional[UUID] = None
    subject: Optional[str] = Field(None, max_length=100)
    grade_level: Optional[str] = Field(None, max_length=50)
    academic_year: Optional[str] = Field(None, max_length=20)
    settings: dict = Field(default_factory=dict)


class ClassroomCreate(ClassroomBase):
    """Schema for classroom creation"""
    pass


class ClassroomUpdate(BaseModel):
    """Schema for classroom update"""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    subject: Optional[str] = Field(None, max_length=100)
    grade_level: Optional[str] = Field(None, max_length=50)
    academic_year: Optional[str] = Field(None, max_length=20)
    settings: Optional[dict] = None
    is_active: Optional[bool] = None


class ClassroomResponse(ClassroomBase):
    """Schema for classroom response"""
    id: UUID
    owner_id: UUID
    owner_type: str
    chroma_collection_name: str
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class ClassroomMemberBase(BaseModel):
    """Base classroom member schema"""
    classroom_id: UUID
    user_id: UUID
    role: str = Field(..., pattern="^(teacher|student|assistant)$")


class ClassroomMemberCreate(ClassroomMemberBase):
    """Schema for adding member to classroom"""
    pass


class ClassroomMemberUpdate(BaseModel):
    """Schema for updating classroom member"""
    role: Optional[str] = Field(None, pattern="^(teacher|student|assistant)$")
    is_active: Optional[bool] = None


class ClassroomMemberResponse(ClassroomMemberBase):
    """Schema for classroom member response"""
    id: UUID
    joined_at: datetime
    is_active: bool
    invited_by: Optional[UUID]
    last_accessed_at: Optional[datetime]

    class Config:
        from_attributes = True
