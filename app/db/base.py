"""
SQLAlchemy Base and Model Imports
"""

from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    """Base class for all database models"""
    pass


# Import all models here for Alembic auto-generation
from app.db.models.user import User  # noqa
from app.db.models.organization import Organization, OrganizationMember  # noqa
from app.db.models.classroom import Classroom, ClassroomMember  # noqa
from app.db.models.document import Document  # noqa
from app.db.models.conversation import Conversation, Message  # noqa
from app.db.models.invitation import Invitation  # noqa
from app.db.models.parent_student_link import ParentStudentLink  # noqa
from app.db.models.analytics_event import AnalyticsEvent  # noqa
