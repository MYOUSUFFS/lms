"""
Permission and authorization utilities
"""

from enum import Enum
from typing import List, Optional
from functools import wraps

from fastapi import HTTPException, status


class UserRole(str, Enum):
    """User roles in the system"""
    ADMIN = "admin"
    SUB_ADMIN = "sub_admin"
    TEACHER = "teacher"
    STUDENT = "student"
    PARENT = "parent"
    USER = "user"  # General user (personal account)


class Permission(str, Enum):
    """System permissions"""
    # Organization permissions
    ORG_CREATE = "org.create"
    ORG_UPDATE = "org.update"
    ORG_DELETE = "org.delete"
    ORG_VIEW = "org.view"
    ORG_MANAGE_MEMBERS = "org.manage_members"
    
    # Classroom permissions
    CLASSROOM_CREATE = "classroom.create"
    CLASSROOM_UPDATE = "classroom.update"
    CLASSROOM_DELETE = "classroom.delete"
    CLASSROOM_VIEW = "classroom.view"
    CLASSROOM_MANAGE_MEMBERS = "classroom.manage_members"
    
    # Document permissions
    DOCUMENT_UPLOAD = "document.upload"
    DOCUMENT_VIEW = "document.view"
    DOCUMENT_DELETE = "document.delete"
    
    # Chat permissions
    CHAT_CREATE = "chat.create"
    CHAT_VIEW_OWN = "chat.view_own"
    CHAT_VIEW_ALL = "chat.view_all"  # Teachers can view student chats
    
    # Analytics permissions
    ANALYTICS_VIEW_OWN = "analytics.view_own"
    ANALYTICS_VIEW_CLASSROOM = "analytics.view_classroom"
    ANALYTICS_VIEW_ORG = "analytics.view_org"
    
    # User management permissions
    USER_INVITE = "user.invite"
    USER_UPDATE = "user.update"
    USER_DELETE = "user.delete"


# Role-permission mapping
ROLE_PERMISSIONS = {
    UserRole.ADMIN: [
        # All permissions
        Permission.ORG_CREATE,
        Permission.ORG_UPDATE,
        Permission.ORG_DELETE,
        Permission.ORG_VIEW,
        Permission.ORG_MANAGE_MEMBERS,
        Permission.CLASSROOM_CREATE,
        Permission.CLASSROOM_UPDATE,
        Permission.CLASSROOM_DELETE,
        Permission.CLASSROOM_VIEW,
        Permission.CLASSROOM_MANAGE_MEMBERS,
        Permission.DOCUMENT_UPLOAD,
        Permission.DOCUMENT_VIEW,
        Permission.DOCUMENT_DELETE,
        Permission.CHAT_CREATE,
        Permission.CHAT_VIEW_OWN,
        Permission.CHAT_VIEW_ALL,
        Permission.ANALYTICS_VIEW_OWN,
        Permission.ANALYTICS_VIEW_CLASSROOM,
        Permission.ANALYTICS_VIEW_ORG,
        Permission.USER_INVITE,
        Permission.USER_UPDATE,
        Permission.USER_DELETE,
    ],
    UserRole.SUB_ADMIN: [
        Permission.ORG_VIEW,
        Permission.ORG_MANAGE_MEMBERS,
        Permission.CLASSROOM_VIEW,
        Permission.CLASSROOM_MANAGE_MEMBERS,
        Permission.DOCUMENT_VIEW,
        Permission.ANALYTICS_VIEW_CLASSROOM,
        Permission.USER_INVITE,
        Permission.USER_UPDATE,
    ],
    UserRole.TEACHER: [
        Permission.CLASSROOM_CREATE,
        Permission.CLASSROOM_UPDATE,
        Permission.CLASSROOM_VIEW,
        Permission.CLASSROOM_MANAGE_MEMBERS,
        Permission.DOCUMENT_UPLOAD,
        Permission.DOCUMENT_VIEW,
        Permission.DOCUMENT_DELETE,
        Permission.CHAT_CREATE,
        Permission.CHAT_VIEW_OWN,
        Permission.CHAT_VIEW_ALL,
        Permission.ANALYTICS_VIEW_OWN,
        Permission.ANALYTICS_VIEW_CLASSROOM,
    ],
    UserRole.STUDENT: [
        Permission.CLASSROOM_VIEW,
        Permission.DOCUMENT_UPLOAD,
        Permission.DOCUMENT_VIEW,
        Permission.CHAT_CREATE,
        Permission.CHAT_VIEW_OWN,
        Permission.ANALYTICS_VIEW_OWN,
    ],
    UserRole.PARENT: [
        Permission.CLASSROOM_VIEW,
        Permission.DOCUMENT_VIEW,
        Permission.CHAT_VIEW_ALL,  # For child's chats
        Permission.ANALYTICS_VIEW_OWN,
    ],
    UserRole.USER: [
        Permission.CLASSROOM_CREATE,
        Permission.CLASSROOM_UPDATE,
        Permission.CLASSROOM_VIEW,
        Permission.DOCUMENT_UPLOAD,
        Permission.DOCUMENT_VIEW,
        Permission.DOCUMENT_DELETE,
        Permission.CHAT_CREATE,
        Permission.CHAT_VIEW_OWN,
        Permission.ANALYTICS_VIEW_OWN,
    ],
}


def get_role_permissions(role: UserRole) -> List[Permission]:
    """Get all permissions for a given role"""
    return ROLE_PERMISSIONS.get(role, [])


def has_permission(user_role: UserRole, required_permission: Permission) -> bool:
    """Check if a role has a specific permission"""
    role_perms = get_role_permissions(user_role)
    return required_permission in role_perms


def require_role(allowed_roles: List[UserRole]):
    """Decorator to require specific roles"""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # This will be implemented with actual user context
            # For now, it's a placeholder
            return await func(*args, **kwargs)
        return wrapper
    return decorator


def require_permission(required_permission: Permission):
    """Decorator to require specific permission"""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # This will be implemented with actual user context
            # For now, it's a placeholder
            return await func(*args, **kwargs)
        return wrapper
    return decorator


def check_classroom_access(user_id: str, classroom_id: str, required_role: Optional[UserRole] = None) -> bool:
    """Check if user has access to a classroom"""
    # This will be implemented with actual database queries
    # For now, it's a placeholder
    return True


def check_organization_membership(user_id: str, organization_id: str) -> bool:
    """Check if user is a member of an organization"""
    # This will be implemented with actual database queries
    # For now, it's a placeholder
    return True
