"""
Organization API Routes
Handles organization CRUD, member management, and invitations
"""

import uuid
import secrets
from datetime import datetime, timedelta
from typing import Annotated, List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.auth import get_current_user
from app.core.logging import get_logger
from app.db.models.user import User
from app.db.models.organization import Organization, OrganizationMember
from app.db.models.invitation import Invitation
from app.db.models.parent_student_link import ParentStudentLink
from app.db.session import get_db
from app.schemas.organization import (
    OrganizationCreate,
    OrganizationUpdate,
    OrganizationResponse,
    OrganizationMemberCreate,
    OrganizationMemberUpdate,
    OrganizationMemberResponse,
    InvitationCreate,
    InvitationResponse,
    InvitationAccept,
    ParentStudentLinkCreate,
    ParentStudentLinkResponse,
)

logger = get_logger(__name__)

router = APIRouter(prefix="/api/v2/organizations", tags=["Organizations"])


@router.post("/", response_model=OrganizationResponse, status_code=status.HTTP_201_CREATED)
async def create_organization(
    org_data: OrganizationCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """
    Create a new organization
    
    - **name**: Organization name (required)
    - **description**: Optional description
    - **settings**: Optional settings dictionary
    """
    # Create organization
    organization = Organization(
        id=uuid.uuid4(),
        name=org_data.name,
        description=org_data.description,
        owner_id=current_user.id,
        settings=org_data.settings,
        is_active=True,
    )
    
    db.add(organization)
    
    # Automatically add creator as school_admin member
    member = OrganizationMember(
        id=uuid.uuid4(),
        organization_id=organization.id,
        user_id=current_user.id,
        role="school_admin",
        is_active=True,
    )
    
    db.add(member)
    await db.commit()
    await db.refresh(organization)
    
    logger.info(f"Organization created: {organization.name} by {current_user.email}")
    
    return organization


@router.get("/", response_model=List[OrganizationResponse])
async def list_organizations(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    is_active: bool = True,
):
    """
    List organizations where user is owner or member
    """
    # Get organizations where user is a member
    query = select(Organization).join(OrganizationMember).where(
        OrganizationMember.user_id == current_user.id
    )
    
    if is_active is not None:
        query = query.where(Organization.is_active == is_active)
    
    result = await db.execute(query)
    organizations = result.scalars().all()
    
    return organizations


@router.get("/{organization_id}", response_model=OrganizationResponse)
async def get_organization(
    organization_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Get organization by ID"""
    result = await db.execute(
        select(Organization).where(Organization.id == organization_id)
    )
    organization = result.scalar_one_or_none()
    
    if not organization:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Organization not found"
        )
    
    # Check if user is member
    member_result = await db.execute(
        select(OrganizationMember).where(
            OrganizationMember.organization_id == organization_id,
            OrganizationMember.user_id == current_user.id
        )
    )
    member = member_result.scalar_one_or_none()
    
    if not member:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied"
        )
    
    return organization


@router.put("/{organization_id}", response_model=OrganizationResponse)
async def update_organization(
    organization_id: uuid.UUID,
    org_data: OrganizationUpdate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Update organization details (owner or admin only)"""
    result = await db.execute(
        select(Organization).where(Organization.id == organization_id)
    )
    organization = result.scalar_one_or_none()
    
    if not organization:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Organization not found"
        )
    
    # Check if user is owner or school_admin
    if organization.owner_id != current_user.id:
        member_result = await db.execute(
            select(OrganizationMember).where(
                OrganizationMember.organization_id == organization_id,
                OrganizationMember.user_id == current_user.id,
                OrganizationMember.role == "school_admin"
            )
        )
        if not member_result.scalar_one_or_none():
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only organization owner or admin can update"
            )
    
    # Update fields
    update_data = org_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(organization, field, value)
    
    organization.updated_at = datetime.utcnow()
    
    await db.commit()
    await db.refresh(organization)
    
    logger.info(f"Organization updated: {organization.name}")
    
    return organization


@router.delete("/{organization_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_organization(
    organization_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Delete organization (owner only, soft delete)"""
    result = await db.execute(
        select(Organization).where(Organization.id == organization_id)
    )
    organization = result.scalar_one_or_none()
    
    if not organization:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Organization not found"
        )
    
    # Only owner can delete
    if organization.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only organization owner can delete"
        )
    
    # Soft delete
    organization.is_active = False
    organization.updated_at = datetime.utcnow()
    
    await db.commit()
    
    logger.info(f"Organization deleted: {organization.name}")


# ==================== Members ====================

@router.post("/{organization_id}/members", response_model=OrganizationMemberResponse, status_code=status.HTTP_201_CREATED)
async def add_organization_member(
    organization_id: uuid.UUID,
    member_data: OrganizationMemberCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Add a member to organization (admin only)"""
    # Check admin permission
    result = await db.execute(
        select(OrganizationMember).where(
            OrganizationMember.organization_id == organization_id,
            OrganizationMember.user_id == current_user.id,
            or_(
                OrganizationMember.role == "school_admin",
                OrganizationMember.role == "sub_admin"
            )
        )
    )
    if not result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins can add members"
        )
    
    # Check if user already a member
    existing = await db.execute(
        select(OrganizationMember).where(
            OrganizationMember.organization_id == organization_id,
            OrganizationMember.user_id == member_data.user_id
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User is already a member"
        )
    
    # Add member
    member = OrganizationMember(
        id=uuid.uuid4(),
        organization_id=organization_id,
        user_id=member_data.user_id,
        role=member_data.role,
        invited_by=current_user.id,
        is_active=True,
    )
    
    db.add(member)
    await db.commit()
    await db.refresh(member)
    
    logger.info(f"Member added to organization {organization_id}")
    
    return member


@router.get("/{organization_id}/members", response_model=List[OrganizationMemberResponse])
async def list_organization_members(
    organization_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    role: str = None,
    is_active: bool = True,
):
    """List members of an organization"""
    # Check if user is member
    check = await db.execute(
        select(OrganizationMember).where(
            OrganizationMember.organization_id == organization_id,
            OrganizationMember.user_id == current_user.id
        )
    )
    if not check.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied"
        )
    
    # Get members
    query = select(OrganizationMember).where(
        OrganizationMember.organization_id == organization_id
    )
    
    if role:
        query = query.where(OrganizationMember.role == role)
    
    if is_active is not None:
        query = query.where(OrganizationMember.is_active == is_active)
    
    result = await db.execute(query)
    members = result.scalars().all()
    
    return members


@router.put("/{organization_id}/members/{member_id}", response_model=OrganizationMemberResponse)
async def update_organization_member(
    organization_id: uuid.UUID,
    member_id: uuid.UUID,
    member_data: OrganizationMemberUpdate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Update organization member (admin only)"""
    # Check admin permission
    admin_check = await db.execute(
        select(OrganizationMember).where(
            OrganizationMember.organization_id == organization_id,
            OrganizationMember.user_id == current_user.id,
            or_(
                OrganizationMember.role == "school_admin",
                OrganizationMember.role == "sub_admin"
            )
        )
    )
    if not admin_check.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins can update members"
        )
    
    # Get member
    result = await db.execute(
        select(OrganizationMember).where(
            OrganizationMember.id == member_id,
            OrganizationMember.organization_id == organization_id
        )
    )
    member = result.scalar_one_or_none()
    
    if not member:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Member not found"
        )
    
    # Update fields
    update_data = member_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(member, field, value)
    
    await db.commit()
    await db.refresh(member)
    
    return member


@router.delete("/{organization_id}/members/{member_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_organization_member(
    organization_id: uuid.UUID,
    member_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Remove member from organization (admin only)"""
    # Check admin permission
    admin_check = await db.execute(
        select(OrganizationMember).where(
            OrganizationMember.organization_id == organization_id,
            OrganizationMember.user_id == current_user.id,
            or_(
                OrganizationMember.role == "school_admin",
                OrganizationMember.role == "sub_admin"
            )
        )
    )
    if not admin_check.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins can remove members"
        )
    
    # Get member
    result = await db.execute(
        select(OrganizationMember).where(
            OrganizationMember.id == member_id,
            OrganizationMember.organization_id == organization_id
        )
    )
    member = result.scalar_one_or_none()
    
    if not member:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Member not found"
        )
    
    # Soft delete
    member.is_active = False
    
    await db.commit()
    
    logger.info(f"Member removed from organization {organization_id}")


# ==================== Invitations ====================

@router.post("/{organization_id}/invitations", response_model=InvitationResponse, status_code=status.HTTP_201_CREATED)
async def create_invitation(
    organization_id: uuid.UUID,
    invitation_data: InvitationCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Create invitation to join organization (admin only)"""
    # Check admin permission
    admin_check = await db.execute(
        select(OrganizationMember).where(
            OrganizationMember.organization_id == organization_id,
            OrganizationMember.user_id == current_user.id,
            or_(
                OrganizationMember.role == "school_admin",
                OrganizationMember.role == "sub_admin"
            )
        )
    )
    if not admin_check.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins can send invitations"
        )
    
    # Check if user already invited
    existing = await db.execute(
        select(Invitation).where(
            Invitation.organization_id == organization_id,
            Invitation.email == invitation_data.email,
            Invitation.status == "pending"
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User already has pending invitation"
        )
    
    # Generate token
    token = secrets.token_urlsafe(32)
    
    # Create invitation
    invitation = Invitation(
        id=uuid.uuid4(),
        organization_id=organization_id,
        invited_by=current_user.id,
        email=invitation_data.email,
        role=invitation_data.role,
        token=token,
        status="pending",
        expires_at=datetime.utcnow() + timedelta(days=7),
    )
    
    db.add(invitation)
    await db.commit()
    await db.refresh(invitation)
    
    # TODO: Send invitation email
    logger.info(f"Invitation created for {invitation_data.email}")
    
    return invitation


@router.get("/{organization_id}/invitations", response_model=List[InvitationResponse])
async def list_invitations(
    organization_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    status_filter: str = None,
):
    """List organization invitations (admin only)"""
    # Check admin permission
    admin_check = await db.execute(
        select(OrganizationMember).where(
            OrganizationMember.organization_id == organization_id,
            OrganizationMember.user_id == current_user.id,
            or_(
                OrganizationMember.role == "school_admin",
                OrganizationMember.role == "sub_admin"
            )
        )
    )
    if not admin_check.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins can view invitations"
        )
    
    query = select(Invitation).where(
        Invitation.organization_id == organization_id
    )
    
    if status_filter:
        query = query.where(Invitation.status == status_filter)
    
    result = await db.execute(query)
    invitations = result.scalars().all()
    
    return invitations


@router.post("/invitations/accept", status_code=status.HTTP_200_OK)
async def accept_invitation(
    accept_data: InvitationAccept,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Accept organization invitation"""
    # Get invitation
    result = await db.execute(
        select(Invitation).where(Invitation.token == accept_data.token)
    )
    invitation = result.scalar_one_or_none()
    
    if not invitation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Invalid invitation token"
        )
    
    if invitation.status != "pending":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invitation already used or expired"
        )
    
    if invitation.expires_at < datetime.utcnow():
        invitation.status = "expired"
        await db.commit()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invitation has expired"
        )
    
    # Add user as member
    member = OrganizationMember(
        id=uuid.uuid4(),
        organization_id=invitation.organization_id,
        user_id=current_user.id,
        role=invitation.role,
        invited_by=invitation.invited_by,
        is_active=True,
    )
    
    db.add(member)
    
    # Update invitation
    invitation.status = "accepted"
    invitation.accepted_at = datetime.utcnow()
    
    await db.commit()
    
    logger.info(f"User {current_user.email} accepted invitation")
    
    return {"message": "Invitation accepted successfully"}


# ==================== Parent-Student Links ====================

@router.post("/{organization_id}/parent-links", response_model=ParentStudentLinkResponse, status_code=status.HTTP_201_CREATED)
async def create_parent_student_link(
    organization_id: uuid.UUID,
    link_data: ParentStudentLinkCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Link parent to student (admin or teacher)"""
    # Check permission
    admin_check = await db.execute(
        select(OrganizationMember).where(
            OrganizationMember.organization_id == organization_id,
            OrganizationMember.user_id == current_user.id,
            or_(
                OrganizationMember.role == "school_admin",
                OrganizationMember.role == "sub_admin",
                OrganizationMember.role == "teacher"
            )
        )
    )
    if not admin_check.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins or teachers can create parent-student links"
        )
    
    # Check if link already exists
    existing = await db.execute(
        select(ParentStudentLink).where(
            ParentStudentLink.parent_id == current_user.id,
            ParentStudentLink.student_id == link_data.student_id,
            ParentStudentLink.organization_id == organization_id
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Link already exists"
        )
    
    # Create link
    link = ParentStudentLink(
        id=uuid.uuid4(),
        parent_id=current_user.id,
        student_id=link_data.student_id,
        organization_id=organization_id,
        relationship=link_data.relationship,
        can_view_chats=link_data.can_view_chats,
        linked_by=current_user.id,
    )
    
    db.add(link)
    await db.commit()
    await db.refresh(link)
    
    logger.info(f"Parent-student link created")
    
    return link


@router.get("/{organization_id}/parent-links", response_model=List[ParentStudentLinkResponse])
async def list_parent_student_links(
    organization_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """List parent-student links in organization"""
    # Get links where user is parent or student
    query = select(ParentStudentLink).where(
        ParentStudentLink.organization_id == organization_id,
        or_(
            ParentStudentLink.parent_id == current_user.id,
            ParentStudentLink.student_id == current_user.id
        )
    )
    
    result = await db.execute(query)
    links = result.scalars().all()
    
    return links


@router.delete("/{organization_id}/parent-links/{link_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_parent_student_link(
    organization_id: uuid.UUID,
    link_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Delete parent-student link (admin only)"""
    # Check admin permission
    admin_check = await db.execute(
        select(OrganizationMember).where(
            OrganizationMember.organization_id == organization_id,
            OrganizationMember.user_id == current_user.id,
            or_(
                OrganizationMember.role == "school_admin",
                OrganizationMember.role == "sub_admin"
            )
        )
    )
    if not admin_check.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins can delete links"
        )
    
    # Delete link
    result = await db.execute(
        select(ParentStudentLink).where(
            ParentStudentLink.id == link_id,
            ParentStudentLink.organization_id == organization_id
        )
    )
    link = result.scalar_one_or_none()
    
    if not link:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Link not found"
        )
    
    await db.delete(link)
    await db.commit()
    
    logger.info(f"Parent-student link deleted")
