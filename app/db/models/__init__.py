"""
Database models initialization
"""

from app.db.models.user import User
from app.db.models.organization import Organization, OrganizationMember
from app.db.models.classroom import Classroom, ClassroomMember
from app.db.models.document import Document
from app.db.models.conversation import Conversation, Message
from app.db.models.invitation import Invitation
from app.db.models.parent_student_link import ParentStudentLink
from app.db.models.analytics_event import AnalyticsEvent

__all__ = [
    "User",
    "Organization",
    "OrganizationMember",
    "Classroom",
    "ClassroomMember",
    "Document",
    "Conversation",
    "Message",
    "Invitation",
    "ParentStudentLink",
    "AnalyticsEvent",
]
