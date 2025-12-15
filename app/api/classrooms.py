"""
Classroom API Routes
Handles classroom CRUD operations and member management
"""

import uuid
from datetime import datetime
from typing import Annotated, List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.auth import get_current_user
from app.core.logging import get_logger
from app.db.models.user import User
from app.db.models.classroom import Classroom, ClassroomMember
from app.db.session import get_db
from app.schemas.classroom import (
    ClassroomCreate,
    ClassroomUpdate,
    ClassroomResponse,
    ClassroomMemberCreate,
    ClassroomMemberUpdate,
    ClassroomMemberResponse,
)

logger = get_logger(__name__)

router = APIRouter(prefix="/api/v2/classrooms", tags=["Classrooms"])


@router.post("/", response_model=ClassroomResponse, status_code=status.HTTP_201_CREATED)
async def create_classroom(
    classroom_data: ClassroomCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """
    Create a new classroom
    
    - **name**: Classroom name (required)
    - **description**: Optional description
    - **organization_id**: Optional organization ID
    - **subject**: Optional subject
    - **grade_level**: Optional grade level
    - **academic_year**: Optional academic year
    - **settings**: Optional settings dictionary
    """
    # Generate unique collection name
    collection_name = f"classroom_{uuid.uuid4().hex[:16]}"
    
    classroom = Classroom(
        id=uuid.uuid4(),
        name=classroom_data.name,
        description=classroom_data.description,
        organization_id=classroom_data.organization_id,
        owner_id=current_user.id,
        owner_type="teacher",
        subject=classroom_data.subject,
        grade_level=classroom_data.grade_level,
        academic_year=classroom_data.academic_year,
        settings=classroom_data.settings,
        chroma_collection_name=collection_name,
        is_active=True,
    )
    
    db.add(classroom)
    await db.commit()
    await db.refresh(classroom)
    
    logger.info(f"Classroom created: {classroom.name} by {current_user.email}")
    
    return classroom


@router.get("/", response_model=List[ClassroomResponse])
async def list_classrooms(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    organization_id: uuid.UUID = None,
    is_active: bool = True,
):
    """
    List classrooms owned by or accessible to current user
    
    - **organization_id**: Filter by organization (optional)
    - **is_active**: Filter by active status (default: True)
    """
    # Get classrooms owned by user
    query = select(Classroom).where(Classroom.owner_id == current_user.id)
    
    if organization_id:
        query = query.where(Classroom.organization_id == organization_id)
    
    if is_active is not None:
        query = query.where(Classroom.is_active == is_active)
    
    result = await db.execute(query)
    classrooms = result.scalars().all()
    
    # TODO: Also include classrooms where user is a member
    
    return classrooms


@router.get("/{classroom_id}", response_model=ClassroomResponse)
async def get_classroom(
    classroom_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Get classroom by ID"""
    result = await db.execute(
        select(Classroom).where(Classroom.id == classroom_id)
    )
    classroom = result.scalar_one_or_none()
    
    if not classroom:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Classroom not found"
        )
    
    # Check access permission
    # TODO: Check if user is owner or member
    if classroom.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied"
        )
    
    return classroom


@router.put("/{classroom_id}", response_model=ClassroomResponse)
async def update_classroom(
    classroom_id: uuid.UUID,
    classroom_data: ClassroomUpdate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Update classroom details"""
    result = await db.execute(
        select(Classroom).where(Classroom.id == classroom_id)
    )
    classroom = result.scalar_one_or_none()
    
    if not classroom:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Classroom not found"
        )
    
    # Check ownership
    if classroom.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only classroom owner can update"
        )
    
    # Update fields
    update_data = classroom_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(classroom, field, value)
    
    classroom.updated_at = datetime.utcnow()
    
    await db.commit()
    await db.refresh(classroom)
    
    logger.info(f"Classroom updated: {classroom.name}")
    
    return classroom


@router.delete("/{classroom_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_classroom(
    classroom_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Delete classroom (soft delete by setting is_active=False)"""
    result = await db.execute(
        select(Classroom).where(Classroom.id == classroom_id)
    )
    classroom = result.scalar_one_or_none()
    
    if not classroom:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Classroom not found"
        )
    
    # Check ownership
    if classroom.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only classroom owner can delete"
        )
    
    # Soft delete
    classroom.is_active = False
    classroom.updated_at = datetime.utcnow()
    
    await db.commit()
    
    logger.info(f"Classroom deleted: {classroom.name}")


@router.post("/{classroom_id}/members", response_model=ClassroomMemberResponse, status_code=status.HTTP_201_CREATED)
async def add_classroom_member(
    classroom_id: uuid.UUID,
    member_data: ClassroomMemberCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Add a member to classroom"""
    # Verify classroom exists and user has permission
    result = await db.execute(
        select(Classroom).where(Classroom.id == classroom_id)
    )
    classroom = result.scalar_one_or_none()
    
    if not classroom:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Classroom not found"
        )
    
    if classroom.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only classroom owner can add members"
        )
    
    # Check if user is already a member
    existing = await db.execute(
        select(ClassroomMember).where(
            ClassroomMember.classroom_id == classroom_id,
            ClassroomMember.user_id == member_data.user_id
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User is already a member"
        )
    
    # Add member
    member = ClassroomMember(
        id=uuid.uuid4(),
        classroom_id=classroom_id,
        user_id=member_data.user_id,
        role=member_data.role,
        invited_by=current_user.id,
        is_active=True,
    )
    
    db.add(member)
    await db.commit()
    await db.refresh(member)
    
    logger.info(f"Member added to classroom {classroom.name}")
    
    return member


@router.get("/{classroom_id}/members", response_model=List[ClassroomMemberResponse])
async def list_classroom_members(
    classroom_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    is_active: bool = True,
):
    """List members of a classroom"""
    # Verify access
    result = await db.execute(
        select(Classroom).where(Classroom.id == classroom_id)
    )
    classroom = result.scalar_one_or_none()
    
    if not classroom:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Classroom not found"
        )
    
    # TODO: Check if user is owner or member
    
    # Get members
    query = select(ClassroomMember).where(ClassroomMember.classroom_id == classroom_id)
    
    if is_active is not None:
        query = query.where(ClassroomMember.is_active == is_active)
    
    result = await db.execute(query)
    members = result.scalars().all()
    
    return members


@router.delete("/{classroom_id}/members/{member_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_classroom_member(
    classroom_id: uuid.UUID,
    member_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Remove a member from classroom"""
    # Verify classroom ownership
    result = await db.execute(
        select(Classroom).where(Classroom.id == classroom_id)
    )
    classroom = result.scalar_one_or_none()
    
    if not classroom:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Classroom not found"
        )
    
    if classroom.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only classroom owner can remove members"
        )
    
    # Get member
    result = await db.execute(
        select(ClassroomMember).where(
            ClassroomMember.id == member_id,
            ClassroomMember.classroom_id == classroom_id
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
    
    logger.info(f"Member removed from classroom {classroom.name}")
