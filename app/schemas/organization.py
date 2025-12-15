"""
Organization Pydantic Schemas
"""

from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field


class OrganizationBase(BaseModel):
    """Base organization schema"""
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    settings: dict = Field(default_factory=dict)


class OrganizationCreate(OrganizationBase):
    """Schema for organization creation"""
    pass


class OrganizationUpdate(BaseModel):
    """Schema for organization update"""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    settings: Optional[dict] = None
    is_active: Optional[bool] = None


class OrganizationResponse(OrganizationBase):
    """Schema for organization response"""
    id: UUID
    owner_id: UUID
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class OrganizationMemberBase(BaseModel):
    """Base organization member schema"""
    user_id: UUID
    role: str = Field(..., pattern="^(super_admin|school_admin|sub_admin|teacher|student|parent|guest)$")


class OrganizationMemberCreate(OrganizationMemberBase):
    """Schema for adding member to organization"""
    pass


class OrganizationMemberUpdate(BaseModel):
    """Schema for updating organization member"""
    role: Optional[str] = Field(None, pattern="^(super_admin|school_admin|sub_admin|teacher|student|parent|guest)$")
    is_active: Optional[bool] = None


class OrganizationMemberResponse(OrganizationMemberBase):
    """Schema for organization member response"""
    id: UUID
    organization_id: UUID
    invited_by: Optional[UUID]
    joined_at: datetime
    is_active: bool

    class Config:
        from_attributes = True


class InvitationBase(BaseModel):
    """Base invitation schema"""
    email: str = Field(..., pattern=r'^[\w\.-]+@[\w\.-]+\.\w+$')
    role: str = Field(..., pattern="^(sub_admin|teacher|student|parent|guest)$")


class InvitationCreate(InvitationBase):
    """Schema for creating invitation"""
    organization_id: UUID


class InvitationResponse(InvitationBase):
    """Schema for invitation response"""
    id: UUID
    organization_id: UUID
    invited_by: UUID
    token: str
    status: str  # 'pending', 'accepted', 'expired', 'revoked'
    expires_at: datetime
    accepted_at: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True


class InvitationAccept(BaseModel):
    """Schema for accepting invitation"""
    token: str


class ParentStudentLinkBase(BaseModel):
    """Base parent-student link schema"""
    student_id: UUID
    relationship: Optional[str] = Field(None, pattern="^(father|mother|guardian)$")
    can_view_chats: bool = True


class ParentStudentLinkCreate(ParentStudentLinkBase):
    """Schema for creating parent-student link"""
    organization_id: UUID


class ParentStudentLinkResponse(ParentStudentLinkBase):
    """Schema for parent-student link response"""
    id: UUID
    parent_id: UUID
    organization_id: UUID
    linked_at: datetime
    linked_by: Optional[UUID]

    class Config:
        from_attributes = True
