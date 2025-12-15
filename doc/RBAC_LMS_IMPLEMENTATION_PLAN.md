# 🎓 Role-Based Access Control (RBAC) LMS Implementation Plan

**Version:** 2.0.0  
**Project:** Centralized AI Learning Management System  
**Date:** December 16, 2025  
**Status:** Implementation Planning

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [User Roles & Permissions](#user-roles--permissions)
4. [Authentication & Authorization](#authentication--authorization)
5. [Database Schema](#database-schema)
6. [Feature Implementation Plan](#feature-implementation-plan)
7. [API Endpoints](#api-endpoints)
8. [Flutter App Structure](#flutter-app-structure)
9. [Implementation Phases](#implementation-phases)
10. [Security Considerations](#security-considerations)

---

## 🎯 Overview

### Current State

- Single-user RAG chatbot with document upload
- Basic API key authentication
- No user management or role-based access
- ChromaDB for vector storage (single collection)

### Target State

- Multi-tenant, role-based LMS platform
- User authentication with JWT tokens
- Organization-based access control
- Isolated classroom environments
- Teacher-student relationship management
- Advanced analytics and monitoring
- Parent portal integration

---

## 🏗️ System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile/Web App                    │
│  ┌──────────┬──────────┬──────────┬──────────┬───────────┐ │
│  │  Auth    │Dashboard │Classroom │Analytics │  Profile  │ │
│  └──────────┴──────────┴──────────┴──────────┴───────────┘ │
└────────────────────────┬────────────────────────────────────┘
                         │ REST API (JWT Auth)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     FastAPI Backend                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Auth Service  │  User Mgmt  │  Classroom Service   │  │
│  │  Role Service  │  Org Mgmt   │  Analytics Service   │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                                │
│  ┌──────────────┬──────────────┬──────────────────────────┐│
│  │ PostgreSQL   │  ChromaDB    │     Redis Cache          ││
│  │ (Users,Orgs) │  (Vectors)   │  (Sessions, Tokens)      ││
│  └──────────────┴──────────────┴──────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### Multi-Tenancy Strategy

**Namespace Isolation:**

- Each organization gets unique namespace
- ChromaDB collections: `org_{org_id}_classroom_{classroom_id}`
- Document storage: `uploads/org_{org_id}/classroom_{classroom_id}/`
- Ensures complete data isolation between organizations and classrooms

---

## 👥 User Roles & Permissions

### Role Hierarchy

```
System Administrator (Future)
    │
    ├── Organization Admin
    │       │
    │       ├── Sub-Admin
    │       │       │
    │       │       ├── Teacher
    │       │       │       │
    │       │       │       └── Student
    │       │       │
    │       │       └── Parent (Read-only access to child's data)
    │       │
    │       └── Teacher (Direct reporting)
    │
    └── General User (Personal account, can create personal classrooms)
```

### Role Definitions

#### 1. **General User** (Individual Account)

**Capabilities:**

- Sign up independently
- Create personal classrooms
- Upload documents to personal classrooms
- Chat with AI in personal context
- Switch to organization accounts if invited
- Manage personal profile

**Restrictions:**

- Cannot create organizations
- Cannot invite other users
- Limited to personal use

---

#### 2. **Organization Admin**

**Capabilities:**

- Create and manage organization
- Invite and manage all roles (sub-admins, teachers, students, parents)
- View all classrooms and conversations
- Access comprehensive analytics dashboard
- Manage organization settings
- Approve/reject user join requests
- Remove users from organization
- View all uploaded documents
- Monitor system usage and costs

**Restrictions:**

- Cannot access personal classrooms of users outside organization
- Cannot modify individual classroom content (read-only)

---

#### 3. **Sub-Admin**

**Capabilities:**

- Manage teachers and students (CRUD operations)
- View analytics for assigned departments/groups
- Monitor classroom activities
- Invite teachers and students
- Generate reports for admin
- Moderate content flags

**Restrictions:**

- Cannot manage other sub-admins
- Cannot change organization settings
- Limited analytics (only assigned scope)

---

#### 4. **Teacher**

**Capabilities:**

- Create classrooms
- Add students to classrooms
- Upload course materials and documents
- Configure classroom settings (AI parameters, visibility)
- Monitor all student chats in their classrooms
- View individual student analytics:
  - Questions asked
  - Topics explored
  - Engagement metrics
  - Learning patterns
- Export student progress reports
- Pin important messages
- Create assignments (future)

**Restrictions:**

- Cannot delete student messages
- Cannot access other teachers' classrooms
- Cannot modify student-uploaded documents
- Cannot remove students from organization

---

#### 5. **Student**

**Capabilities:**

- Join assigned classrooms
- Create unlimited personal chats within classroom
- Upload personal reference documents
- Access teacher-provided materials (read-only)
- View own chat history
- Search within classroom resources
- Export own conversations

**Restrictions:**

- Cannot see other students' chats
- Cannot modify teacher-uploaded documents
- Cannot remove classroom materials
- Cannot invite other students

---

#### 6. **Parent**

**Capabilities:**

- View linked child's classroom list
- Read child's chat history (optional teacher setting)
- View child's analytics and progress
- Receive notifications about child's activity
- Message teachers (future)

**Restrictions:**

- Read-only access
- Cannot chat with AI
- Cannot upload documents
- Cannot modify any content

---

## 🔐 Authentication & Authorization

### Authentication Flow

#### 1. Sign Up Flow

```
User submits: Email, Password, Full Name, Account Type
    ↓
Backend validates and creates user
    ↓
Email verification sent (optional)
    ↓
User confirms email
    ↓
JWT tokens issued (Access + Refresh)
    ↓
User redirected to dashboard
```

#### 2. Login Flow

```
User submits: Email, Password
    ↓
Backend validates credentials
    ↓
Check active organization (if multiple)
    ↓
Generate JWT tokens
    ↓
Return: Access Token, Refresh Token, User Profile
    ↓
Flutter app stores tokens securely
```

#### 3. Organization Invitation Flow

```
Admin sends invitation to email
    ↓
Non-user: Receives sign-up link with invitation token
Existing user: Receives notification + organization link
    ↓
User accepts invitation
    ↓
Backend creates organization membership
    ↓
User can switch between personal and organization accounts
```

#### 4. Organization Switching Flow

```
User selects organization from profile menu
    ↓
Backend validates membership
    ↓
Issues new JWT with organization context
    ↓
UI updates to show organization resources
```

### JWT Token Structure

```json
{
  "sub": "user_id",
  "email": "user@example.com",
  "role": "teacher",
  "org_id": "org_uuid",
  "org_name": "Example School",
  "permissions": ["classroom.create", "student.view", "analytics.view"],
  "exp": 1734345600,
  "iat": 1734259200,
  "context": "organization" // or "personal"
}
```

### Authorization Middleware

**Permission Decorators:**

```python
@require_role(["teacher", "admin"])
@require_permission("classroom.create")
@require_organization_membership()
@require_classroom_access(classroom_id)
```

---

## 🗄️ Database Schema

### PostgreSQL Tables

#### **users**

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    profile_picture_url TEXT,
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_login_at TIMESTAMP,
    preferences JSONB DEFAULT '{}',
    CONSTRAINT email_lowercase CHECK (email = LOWER(email))
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
```

---

#### **organizations**

```sql
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    logo_url TEXT,
    website VARCHAR(255),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    address TEXT,
    settings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_organizations_slug ON organizations(slug);
```

---

#### **organization_members**

```sql
CREATE TABLE organization_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL, -- 'admin', 'sub_admin', 'teacher', 'student', 'parent'
    department VARCHAR(100),
    joined_at TIMESTAMP DEFAULT NOW(),
    invited_by UUID REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'suspended', 'pending'
    metadata JSONB DEFAULT '{}',
    UNIQUE(organization_id, user_id)
);

CREATE INDEX idx_org_members_org ON organization_members(organization_id);
CREATE INDEX idx_org_members_user ON organization_members(user_id);
CREATE INDEX idx_org_members_role ON organization_members(role);
```

---

#### **classrooms**

```sql
CREATE TABLE classrooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    owner_type VARCHAR(20) NOT NULL, -- 'user' or 'teacher'
    subject VARCHAR(100),
    grade_level VARCHAR(50),
    academic_year VARCHAR(20),
    settings JSONB DEFAULT '{}', -- AI config, visibility, etc.
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    chroma_collection_name VARCHAR(255) UNIQUE NOT NULL
);

CREATE INDEX idx_classrooms_org ON classrooms(organization_id);
CREATE INDEX idx_classrooms_owner ON classrooms(owner_id);
CREATE INDEX idx_classrooms_chroma ON classrooms(chroma_collection_name);
```

---

#### **classroom_members**

```sql
CREATE TABLE classroom_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL, -- 'teacher', 'student', 'observer'
    joined_at TIMESTAMP DEFAULT NOW(),
    last_accessed_at TIMESTAMP,
    UNIQUE(classroom_id, user_id)
);

CREATE INDEX idx_classroom_members_classroom ON classroom_members(classroom_id);
CREATE INDEX idx_classroom_members_user ON classroom_members(user_id);
```

---

#### **documents**

```sql
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    uploader_id UUID NOT NULL REFERENCES users(id),
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100),
    file_type VARCHAR(50),
    visibility VARCHAR(20) DEFAULT 'classroom', -- 'classroom' or 'personal'
    chunk_count INTEGER DEFAULT 0,
    processing_status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
    processing_error TEXT,
    uploaded_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_documents_classroom ON documents(classroom_id);
CREATE INDEX idx_documents_uploader ON documents(uploader_id);
CREATE INDEX idx_documents_status ON documents(processing_status);
```

---

#### **conversations**

```sql
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_message_at TIMESTAMP,
    message_count INTEGER DEFAULT 0
);

CREATE INDEX idx_conversations_classroom ON conversations(classroom_id);
CREATE INDEX idx_conversations_user ON conversations(user_id);
CREATE INDEX idx_conversations_updated ON conversations(updated_at DESC);
```

---

#### **messages**

```sql
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL, -- 'user' or 'assistant'
    content TEXT NOT NULL,
    sources JSONB DEFAULT '[]', -- Referenced document chunks
    token_count INTEGER,
    model_used VARCHAR(100),
    latency_ms INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_created ON messages(created_at);
```

---

#### **invitations**

```sql
CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    invited_by UUID NOT NULL REFERENCES users(id),
    email VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'accepted', 'expired', 'revoked'
    expires_at TIMESTAMP NOT NULL,
    accepted_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_invitations_token ON invitations(token);
CREATE INDEX idx_invitations_email ON invitations(email);
CREATE INDEX idx_invitations_status ON invitations(status);
```

---

#### **parent_student_links**

```sql
CREATE TABLE parent_student_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    relationship VARCHAR(50), -- 'father', 'mother', 'guardian'
    can_view_chats BOOLEAN DEFAULT TRUE,
    linked_at TIMESTAMP DEFAULT NOW(),
    linked_by UUID REFERENCES users(id),
    UNIQUE(parent_id, student_id, organization_id)
);

CREATE INDEX idx_parent_links_parent ON parent_student_links(parent_id);
CREATE INDEX idx_parent_links_student ON parent_student_links(student_id);
```

---

#### **analytics_events**

```sql
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    classroom_id UUID REFERENCES classrooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL, -- 'message_sent', 'document_uploaded', 'login', etc.
    event_data JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_analytics_org ON analytics_events(organization_id);
CREATE INDEX idx_analytics_classroom ON analytics_events(classroom_id);
CREATE INDEX idx_analytics_user ON analytics_events(user_id);
CREATE INDEX idx_analytics_type ON analytics_events(event_type);
CREATE INDEX idx_analytics_created ON analytics_events(created_at);
```

---

### ChromaDB Collections Strategy

**Namespace Pattern:**

```
Personal User: user_{user_id}_classroom_{classroom_id}
Organization: org_{org_id}_classroom_{classroom_id}
```

**Metadata Schema:**

```python
{
    "document_id": "uuid",
    "classroom_id": "uuid",
    "uploader_id": "uuid",
    "uploader_role": "teacher|student",
    "visibility": "classroom|personal",
    "filename": "example.pdf",
    "upload_date": "2025-12-16T10:30:00Z",
    "chunk_index": 5,
    "chunk_total": 20
}
```

---

## 🎯 Feature Implementation Plan

### Phase 1: Core Authentication & User Management

#### 1.1 Backend - Authentication System

**Priority: P0 (Critical)**

**Tasks:**

- [ ] Install dependencies: `passlib`, `python-jose[cryptography]`, `python-multipart`, `psycopg2-binary`, `sqlalchemy`, `alembic`
- [ ] Create database models (SQLAlchemy)
- [ ] Implement password hashing (bcrypt)
- [ ] Create JWT token generation and validation
- [ ] Build user registration endpoint
- [ ] Build login endpoint
- [ ] Build token refresh endpoint
- [ ] Build password reset flow (email token)
- [ ] Implement email verification
- [ ] Add authentication middleware
- [ ] Create user profile endpoints (GET/PUT)

**Files to Create:**

```
app/
├── db/
│   ├── __init__.py
│   ├── base.py
│   ├── session.py
│   └── models/
│       ├── __init__.py
│       ├── user.py
│       ├── organization.py
│       ├── classroom.py
│       └── document.py
├── core/
│   ├── security.py (update)
│   ├── auth.py
│   └── permissions.py
├── api/
│   └── v2/
│       ├── __init__.py
│       ├── auth.py
│       ├── users.py
│       └── organizations.py
└── schemas/
    ├── auth.py
    └── user.py
```

---

#### 1.2 Flutter - Authentication UI

**Priority: P0 (Critical)**

**Tasks:**

- [ ] Create authentication service (HTTP client)
- [ ] Implement secure token storage (flutter_secure_storage)
- [ ] Build login screen
- [ ] Build sign-up screen
- [ ] Build password reset screen
- [ ] Build email verification screen
- [ ] Implement auto-login with refresh token
- [ ] Create authentication state provider
- [ ] Add biometric authentication (optional)

**Files to Create:**

```
lib/
├── core/
│   ├── services/
│   │   ├── auth_service.dart
│   │   └── secure_storage_service.dart
│   └── providers/
│       └── auth_provider.dart
├── features/
│   └── auth/
│       ├── screens/
│       │   ├── login_screen.dart
│       │   ├── signup_screen.dart
│       │   ├── forgot_password_screen.dart
│       │   └── verify_email_screen.dart
│       └── widgets/
│           ├── auth_text_field.dart
│           ├── auth_button.dart
│           └── social_login_buttons.dart
└── models/
    ├── user_model.dart
    └── auth_response.dart
```

---

### Phase 2: Role-Based Access Control (RBAC)

#### 2.1 Backend - RBAC Implementation

**Priority: P0 (Critical)**

**Tasks:**

- [ ] Create role and permission tables
- [ ] Implement role middleware decorators
- [ ] Create permission checking functions
- [ ] Build role assignment endpoints
- [ ] Implement organization creation
- [ ] Build organization member management
- [ ] Create invitation system (email invites)
- [ ] Implement organization switching logic
- [ ] Add audit logging for permission changes

**Files to Create:**

```
app/
├── db/models/
│   ├── role.py
│   ├── permission.py
│   └── organization_member.py
├── core/
│   ├── rbac.py
│   └── permissions.py
├── api/v2/
│   ├── organizations.py
│   ├── invitations.py
│   └── roles.py
└── services/
    ├── organization_service.py
    └── invitation_service.py
```

---

#### 2.2 Flutter - Role Management UI

**Priority: P1 (High)**

**Tasks:**

- [ ] Create organization switcher widget
- [ ] Build admin dashboard
- [ ] Build user invitation screen
- [ ] Implement role selection dropdown
- [ ] Create member management screen
- [ ] Add permission-based UI rendering
- [ ] Build organization settings screen

**Files to Create:**

```
lib/
├── features/
│   ├── organization/
│   │   ├── screens/
│   │   │   ├── organization_dashboard.dart
│   │   │   ├── create_organization_screen.dart
│   │   │   ├── manage_members_screen.dart
│   │   │   └── invite_users_screen.dart
│   │   └── widgets/
│   │       ├── organization_switcher.dart
│   │       ├── member_card.dart
│   │       └── role_badge.dart
│   └── admin/
│       └── screens/
│           └── admin_dashboard.dart
└── models/
    ├── organization_model.dart
    └── member_model.dart
```

---

### Phase 3: Classroom Management

#### 3.1 Backend - Classroom System

**Priority: P0 (Critical)**

**Tasks:**

- [ ] Update ChromaDB integration for multi-tenant collections
- [ ] Create classroom CRUD endpoints
- [ ] Implement classroom member management
- [ ] Build document upload with namespace isolation
- [ ] Update RAG pipeline for classroom context
- [ ] Implement conversation threading per user
- [ ] Add classroom settings (AI parameters, visibility)
- [ ] Create document sharing logic (teacher vs student)
- [ ] Implement search within classroom scope

**Files to Create:**

```
app/
├── api/v2/
│   ├── classrooms.py
│   ├── classroom_members.py
│   └── classroom_documents.py
├── services/
│   ├── classroom_service.py
│   └── rag/
│       └── multi_tenant_vector_store.py (update vector_store.py)
└── db/models/
    ├── classroom.py
    └── classroom_member.py
```

---

#### 3.2 Flutter - Classroom UI

**Priority: P0 (Critical)**

**Tasks:**

- [ ] Create classroom list screen
- [ ] Build classroom creation form
- [ ] Implement classroom detail screen
- [ ] Add student enrollment interface
- [ ] Build document browser for classroom
- [ ] Create conversation list per classroom
- [ ] Update chat screen with classroom context
- [ ] Add classroom settings screen

**Files to Create:**

```
lib/
├── features/
│   ├── classroom/
│   │   ├── screens/
│   │   │   ├── classroom_list_screen.dart
│   │   │   ├── create_classroom_screen.dart
│   │   │   ├── classroom_detail_screen.dart
│   │   │   ├── classroom_settings_screen.dart
│   │   │   └── manage_students_screen.dart
│   │   └── widgets/
│   │       ├── classroom_card.dart
│   │       ├── student_list_tile.dart
│   │       └── classroom_stats_widget.dart
│   └── chat/
│       └── screens/
│           └── classroom_chat_screen.dart (update existing)
└── models/
    └── classroom_model.dart
```

---

### Phase 4: Teacher & Student Features

#### 4.1 Backend - Teacher Features

**Priority: P1 (High)**

**Tasks:**

- [ ] Build student chat monitoring endpoints
- [ ] Create student analytics aggregation
- [ ] Implement bulk document upload
- [ ] Add chat flagging/pinning system
- [ ] Create export functionality (PDF reports)
- [ ] Build student progress tracking
- [ ] Implement teacher dashboard data API

**Files to Create:**

```
app/
├── api/v2/
│   ├── teacher_analytics.py
│   ├── student_monitoring.py
│   └── reports.py
└── services/
    ├── analytics_service.py
    └── report_generator.py
```

---

#### 4.2 Flutter - Teacher Dashboard

**Priority: P1 (High)**

**Tasks:**

- [ ] Build teacher dashboard
- [ ] Create student monitoring screen
- [ ] Implement chat viewer (read-only for students)
- [ ] Add analytics charts (engagement, questions)
- [ ] Build report export UI
- [ ] Create bulk document upload interface

**Files to Create:**

```
lib/
├── features/
│   └── teacher/
│       ├── screens/
│       │   ├── teacher_dashboard.dart
│       │   ├── student_monitoring_screen.dart
│       │   ├── student_chat_viewer_screen.dart
│       │   └── classroom_analytics_screen.dart
│       └── widgets/
│           ├── student_engagement_chart.dart
│           ├── chat_preview_card.dart
│           └── analytics_summary_widget.dart
└── services/
    └── analytics_service.dart
```

---

#### 4.3 Backend - Student Features

**Priority: P1 (High)**

**Tasks:**

- [ ] Implement personal chat isolation
- [ ] Create student document upload (personal visibility)
- [ ] Build chat history endpoints (user-scoped)
- [ ] Add resource browsing (teacher materials)

---

#### 4.4 Flutter - Student Interface

**Priority: P1 (High)**

**Tasks:**

- [ ] Build student classroom view
- [ ] Create personal chat interface
- [ ] Implement document upload (personal)
- [ ] Add resource browser (teacher materials)

---

### Phase 5: Analytics & Monitoring

#### 5.1 Backend - Analytics Engine

**Priority: P2 (Medium)**

**Tasks:**

- [ ] Create analytics event tracking
- [ ] Build aggregation queries (PostgreSQL)
- [ ] Implement real-time metrics (Redis cache)
- [ ] Create admin analytics endpoints
- [ ] Build organization-wide reports
- [ ] Add cost tracking (token usage)

**Files to Create:**

```
app/
├── db/models/
│   └── analytics_event.py
├── services/
│   ├── analytics/
│   │   ├── __init__.py
│   │   ├── event_tracker.py
│   │   ├── aggregator.py
│   │   └── dashboard_builder.py
│   └── cache/
│       └── redis_service.py
└── api/v2/
    └── analytics.py
```

---

#### 5.2 Flutter - Analytics Dashboard

**Priority: P2 (Medium)**

**Tasks:**

- [ ] Build organization analytics screen
- [ ] Create teacher analytics screen
- [ ] Implement charts (fl_chart package)
- [ ] Add date range filtering
- [ ] Create export functionality

**Files to Create:**

```
lib/
├── features/
│   └── analytics/
│       ├── screens/
│       │   ├── org_analytics_screen.dart
│       │   ├── teacher_analytics_screen.dart
│       │   └── student_progress_screen.dart
│       └── widgets/
│           ├── usage_chart.dart
│           ├── engagement_chart.dart
│           └── analytics_filter.dart
└── services/
    └── analytics_api_service.dart
```

---

### Phase 6: Parent Portal

#### 6.1 Backend - Parent Features

**Priority: P2 (Medium)**

**Tasks:**

- [ ] Create parent-student linking system
- [ ] Build parent dashboard endpoints
- [ ] Implement read-only chat access
- [ ] Add notification system for parents
- [ ] Create progress report generation

---

#### 6.2 Flutter - Parent Interface

**Priority: P2 (Medium)**

**Tasks:**

- [ ] Build parent dashboard
- [ ] Create child selector
- [ ] Implement read-only chat viewer
- [ ] Add progress report viewer

---

## 🔌 API Endpoints

### Authentication Endpoints

```
POST   /api/v2/auth/register
POST   /api/v2/auth/login
POST   /api/v2/auth/refresh
POST   /api/v2/auth/logout
POST   /api/v2/auth/forgot-password
POST   /api/v2/auth/reset-password
POST   /api/v2/auth/verify-email
GET    /api/v2/auth/me
```

### User Management

```
GET    /api/v2/users/me
PUT    /api/v2/users/me
GET    /api/v2/users/{user_id}
PUT    /api/v2/users/{user_id}/password
DELETE /api/v2/users/{user_id}
```

### Organization Management

```
POST   /api/v2/organizations
GET    /api/v2/organizations
GET    /api/v2/organizations/{org_id}
PUT    /api/v2/organizations/{org_id}
DELETE /api/v2/organizations/{org_id}
POST   /api/v2/organizations/{org_id}/switch
GET    /api/v2/organizations/{org_id}/members
POST   /api/v2/organizations/{org_id}/members
PUT    /api/v2/organizations/{org_id}/members/{member_id}
DELETE /api/v2/organizations/{org_id}/members/{member_id}
```

### Invitation System

```
POST   /api/v2/invitations
GET    /api/v2/invitations
GET    /api/v2/invitations/{token}
POST   /api/v2/invitations/{token}/accept
DELETE /api/v2/invitations/{invitation_id}
```

### Classroom Management

```
POST   /api/v2/classrooms
GET    /api/v2/classrooms
GET    /api/v2/classrooms/{classroom_id}
PUT    /api/v2/classrooms/{classroom_id}
DELETE /api/v2/classrooms/{classroom_id}
POST   /api/v2/classrooms/{classroom_id}/members
GET    /api/v2/classrooms/{classroom_id}/members
DELETE /api/v2/classrooms/{classroom_id}/members/{member_id}
GET    /api/v2/classrooms/{classroom_id}/documents
POST   /api/v2/classrooms/{classroom_id}/documents
DELETE /api/v2/classrooms/{classroom_id}/documents/{doc_id}
```

### Chat & Conversations

```
POST   /api/v2/classrooms/{classroom_id}/conversations
GET    /api/v2/classrooms/{classroom_id}/conversations
GET    /api/v2/conversations/{conversation_id}
DELETE /api/v2/conversations/{conversation_id}
POST   /api/v2/conversations/{conversation_id}/messages
GET    /api/v2/conversations/{conversation_id}/messages
POST   /api/v2/conversations/{conversation_id}/query (RAG query)
```

### Teacher Monitoring

```
GET    /api/v2/teacher/classrooms/{classroom_id}/students
GET    /api/v2/teacher/students/{student_id}/conversations
GET    /api/v2/teacher/students/{student_id}/analytics
GET    /api/v2/teacher/classrooms/{classroom_id}/analytics
POST   /api/v2/teacher/reports/generate
```

### Analytics

```
GET    /api/v2/analytics/organization/{org_id}
GET    /api/v2/analytics/classroom/{classroom_id}
GET    /api/v2/analytics/user/{user_id}
GET    /api/v2/analytics/usage
GET    /api/v2/analytics/engagement
```

### Parent Portal

```
GET    /api/v2/parent/children
GET    /api/v2/parent/children/{student_id}/classrooms
GET    /api/v2/parent/children/{student_id}/conversations
GET    /api/v2/parent/children/{student_id}/analytics
```

---

## 📱 Flutter App Structure

### Updated Directory Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   └── api_config.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── route_constants.dart
│   │   └── permission_constants.dart
│   ├── models/
│   │   ├── theme_style.dart (existing)
│   │   ├── user_model.dart
│   │   ├── organization_model.dart
│   │   ├── classroom_model.dart
│   │   ├── conversation_model.dart
│   │   └── message_model.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── organization_provider.dart
│   │   ├── classroom_provider.dart
│   │   ├── theme_provider.dart (existing)
│   │   └── user_provider.dart
│   ├── services/
│   │   ├── api/
│   │   │   ├── api_client.dart
│   │   │   ├── auth_api.dart
│   │   │   ├── organization_api.dart
│   │   │   ├── classroom_api.dart
│   │   │   ├── chat_api.dart
│   │   │   └── analytics_api.dart
│   │   ├── storage/
│   │   │   ├── secure_storage_service.dart
│   │   │   └── local_storage_service.dart
│   │   └── navigation/
│   │       └── navigation_service.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── permission_helper.dart
│   └── widgets/
│       ├── custom_app_bar.dart
│       ├── loading_widget.dart
│       ├── error_widget.dart
│       └── empty_state_widget.dart
│
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   ├── forgot_password_screen.dart
│   │   │   └── verify_email_screen.dart
│   │   └── widgets/
│   │       ├── auth_text_field.dart
│   │       └── auth_button.dart
│   │
│   ├── dashboard/
│   │   ├── screens/
│   │   │   ├── main_dashboard_screen.dart
│   │   │   ├── admin_dashboard_screen.dart
│   │   │   ├── teacher_dashboard_screen.dart
│   │   │   └── student_dashboard_screen.dart
│   │   └── widgets/
│   │       ├── dashboard_card.dart
│   │       └── quick_action_button.dart
│   │
│   ├── organization/
│   │   ├── screens/
│   │   │   ├── organization_list_screen.dart
│   │   │   ├── create_organization_screen.dart
│   │   │   ├── organization_detail_screen.dart
│   │   │   └── manage_members_screen.dart
│   │   └── widgets/
│   │       ├── organization_switcher.dart
│   │       ├── member_card.dart
│   │       └── invitation_dialog.dart
│   │
│   ├── classroom/
│   │   ├── screens/
│   │   │   ├── classroom_list_screen.dart
│   │   │   ├── create_classroom_screen.dart
│   │   │   ├── classroom_detail_screen.dart
│   │   │   └── classroom_settings_screen.dart
│   │   └── widgets/
│   │       ├── classroom_card.dart
│   │       └── student_list_tile.dart
│   │
│   ├── chat/ (existing - to be updated)
│   │   ├── screens/
│   │   │   ├── chat_screen.dart
│   │   │   └── conversation_list_screen.dart
│   │   └── widgets/
│   │       ├── message_bubble.dart
│   │       └── typing_indicator.dart
│   │
│   ├── documents/
│   │   ├── screens/
│   │   │   ├── document_list_screen.dart
│   │   │   └── document_upload_screen.dart
│   │   └── widgets/
│   │       └── document_card.dart
│   │
│   ├── analytics/
│   │   ├── screens/
│   │   │   ├── analytics_dashboard_screen.dart
│   │   │   └── student_analytics_screen.dart
│   │   └── widgets/
│   │       ├── usage_chart.dart
│   │       └── engagement_chart.dart
│   │
│   ├── teacher/
│   │   ├── screens/
│   │   │   ├── student_monitoring_screen.dart
│   │   │   └── student_chat_viewer_screen.dart
│   │   └── widgets/
│   │       └── student_engagement_card.dart
│   │
│   ├── parent/
│   │   ├── screens/
│   │   │   ├── parent_dashboard_screen.dart
│   │   │   └── child_progress_screen.dart
│   │   └── widgets/
│   │       └── child_selector.dart
│   │
│   └── profile/
│       ├── screens/
│       │   ├── profile_screen.dart
│       │   └── edit_profile_screen.dart
│       └── widgets/
│           └── profile_avatar.dart
│
└── routes/
    ├── app_router.dart
    └── route_guards.dart
```

---

## 📅 Implementation Phases

### **Phase 1: Foundation (Weeks 1-3)**

**Goal:** Authentication & User Management

**Deliverables:**

- ✅ PostgreSQL database setup with Alembic migrations
- ✅ User registration and login (backend + frontend)
- ✅ JWT authentication
- ✅ Profile management
- ✅ Password reset flow
- ✅ Flutter authentication screens

**Success Criteria:**

- Users can sign up and log in
- Tokens are securely stored
- Password reset works

---

### **Phase 2: Organizations & RBAC (Weeks 4-6)**

**Goal:** Multi-tenant organization structure

**Deliverables:**

- ✅ Organization creation and management
- ✅ Role-based access control
- ✅ Invitation system (email invites)
- ✅ Organization member management
- ✅ Organization switcher UI
- ✅ Admin dashboard

**Success Criteria:**

- Admins can create organizations
- Admins can invite users with roles
- Users can switch between personal and organization accounts
- Role-based UI rendering works

---

### **Phase 3: Classrooms (Weeks 7-9)**

**Goal:** Core classroom functionality

**Deliverables:**

- ✅ Classroom creation and management
- ✅ Multi-tenant ChromaDB collections
- ✅ Student enrollment
- ✅ Document upload with namespace isolation
- ✅ Classroom-scoped conversations
- ✅ Classroom UI (list, create, detail)

**Success Criteria:**

- Teachers can create classrooms
- Students can be added to classrooms
- Documents are isolated per classroom
- Conversations are scoped to classrooms
- Each classroom has separate ChromaDB collection

---

### **Phase 4: Chat & RAG (Weeks 10-11)**

**Goal:** Enhanced chat experience

**Deliverables:**

- ✅ Personal chat isolation per student
- ✅ Teacher document sharing
- ✅ Student personal document upload
- ✅ Updated RAG pipeline with classroom context
- ✅ Conversation threading
- ✅ Updated chat UI

**Success Criteria:**

- Students can create personal chats
- Teacher documents are accessible to all students
- Student documents only affect their own chats
- RAG queries respect classroom boundaries

---

### **Phase 5: Teacher Features (Weeks 12-13)**

**Goal:** Teacher monitoring and analytics

**Deliverables:**

- ✅ Student chat monitoring
- ✅ Student analytics (questions, engagement)
- ✅ Teacher dashboard
- ✅ Report generation
- ✅ Bulk document upload

**Success Criteria:**

- Teachers can view all student chats
- Analytics show student engagement
- Reports can be exported
- Teachers can upload multiple documents at once

---

### **Phase 6: Analytics & Monitoring (Weeks 14-15)**

**Goal:** Organization-wide insights

**Deliverables:**

- ✅ Analytics event tracking
- ✅ Organization analytics dashboard
- ✅ Usage reports
- ✅ Cost tracking (token usage)
- ✅ Charts and visualizations

**Success Criteria:**

- Admins can view organization-wide analytics
- Usage patterns are visible
- Token costs are tracked

---

### **Phase 7: Parent Portal (Week 16)**

**Goal:** Parent engagement

**Deliverables:**

- ✅ Parent-student linking
- ✅ Read-only chat access
- ✅ Progress reports for parents
- ✅ Parent dashboard

**Success Criteria:**

- Parents can view their child's classrooms
- Parents can see child's progress
- Chat access respects teacher settings

---

### **Phase 8: Polish & Testing (Weeks 17-18)**

**Goal:** Production readiness

**Deliverables:**

- ✅ Comprehensive testing (unit, integration, E2E)
- ✅ Performance optimization
- ✅ Security audit
- ✅ Documentation
- ✅ Deployment scripts
- ✅ User onboarding flow

**Success Criteria:**

- All critical paths tested
- Load testing completed
- Security vulnerabilities addressed
- Documentation complete

---

## 🔒 Security Considerations

### 1. **Authentication Security**

- ✅ Passwords hashed with bcrypt (cost factor 12)
- ✅ JWT tokens with short expiry (15 min access, 7 day refresh)
- ✅ Refresh token rotation
- ✅ Secure token storage (flutter_secure_storage)
- ✅ HTTPS-only in production
- ✅ Rate limiting on auth endpoints
- ✅ Account lockout after failed attempts
- ✅ Email verification required

### 2. **Authorization Security**

- ✅ Role-based access control (RBAC)
- ✅ Permission checks on every API call
- ✅ Classroom membership validation
- ✅ Organization membership validation
- ✅ Document visibility enforcement
- ✅ Conversation ownership validation

### 3. **Data Isolation**

- ✅ Namespace-based ChromaDB collections
- ✅ PostgreSQL row-level security (RLS)
- ✅ Organization-scoped queries
- ✅ Classroom-scoped queries
- ✅ User-scoped personal data

### 4. **File Upload Security**

- ✅ File type validation (whitelist)
- ✅ File size limits
- ✅ Virus scanning (ClamAV integration)
- ✅ Sanitized filenames
- ✅ Secure storage paths
- ✅ Signed URLs for downloads

### 5. **API Security**

- ✅ CORS configuration
- ✅ Rate limiting (per user, per IP)
- ✅ Input validation (Pydantic)
- ✅ SQL injection prevention (SQLAlchemy ORM)
- ✅ XSS prevention
- ✅ CSRF protection

### 6. **Privacy & Compliance**

- ✅ GDPR compliance (data export, deletion)
- ✅ FERPA compliance (student data protection)
- ✅ Audit logging
- ✅ Data retention policies
- ✅ User consent management

---

## 🚀 Deployment Considerations

### Infrastructure

```yaml
# docker-compose.production.yml
version: "3.8"
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: lms_db
      POSTGRES_USER: lms_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD}

  backend:
    build: .
    environment:
      DATABASE_URL: postgresql://lms_user:${DB_PASSWORD}@postgres/lms_db
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      JWT_SECRET: ${JWT_SECRET}
    depends_on:
      - postgres
      - redis

  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
```

### Environment Variables

```bash
# Backend
DATABASE_URL=postgresql://user:pass@localhost/lms_db
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-secret-key-here
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=7

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# LLM
OLLAMA_BASE_URL=http://localhost:11434
GROQ_API_KEY=your-groq-key

# Storage
UPLOAD_DIR=./data/uploads
MAX_UPLOAD_SIZE=50MB

# Flutter
API_BASE_URL=https://api.yourdomain.com
WS_BASE_URL=wss://api.yourdomain.com
```

---

## 📊 Success Metrics

### Technical Metrics

- API response time < 200ms (p95)
- RAG query latency < 2s
- Database query time < 50ms
- Uptime > 99.9%

### User Metrics

- User registration completion rate > 80%
- Daily active users (DAU)
- Average classrooms per teacher
- Average messages per student
- Document upload success rate > 95%

### Business Metrics

- Organization sign-up rate
- Teacher adoption rate
- Student engagement score
- Parent portal usage
- Token cost per conversation

---

## 📚 Documentation Requirements

### 1. **API Documentation**

- OpenAPI/Swagger spec
- Endpoint descriptions
- Request/response examples
- Authentication guide

### 2. **User Guides**

- Admin user guide
- Teacher user guide
- Student user guide
- Parent user guide

### 3. **Developer Documentation**

- Setup guide
- Architecture overview
- Database schema
- Deployment guide
- Contributing guide

### 4. **Video Tutorials**

- Platform overview
- Creating classrooms
- Inviting users
- Using AI chat
- Viewing analytics

---

## 📋 Summary of the Plan

The document includes:

### **🎯 Core Features Covered:**

1. **Role-Based Access Control (RBAC)**
   - 6 user roles: General User, Organization Admin, Sub-Admin, Teacher, Student, Parent
   - Detailed permissions for each role
   - Organization switching capability

2. **Authentication System**
   - JWT-based authentication
   - Sign-up/Login flows
   - Email verification
   - Password reset
   - Invitation system for organizations

3. **Classroom Management**
   - Isolated classroom environments
   - Namespace-based ChromaDB collections
   - Teacher can create classes and add students
   - Document isolation (teacher vs student uploads)
   - Personal chats per student that don't affect others

4. **Teacher Features**
   - Student monitoring dashboard
   - View all student chats
   - Individual student analytics
   - Bulk document upload
   - Report generation

5. **Organization Features**
   - Multi-tenant architecture
   - Comprehensive analytics
   - User management and invitations
   - View all connected accounts

6. **Complete Database Schema**
   - PostgreSQL tables for users, organizations, classrooms, documents, conversations, etc.
   - ChromaDB namespace strategy for data isolation

7. **Implementation Phases**
   - 8 phases over 18 weeks
   - Detailed tasks for backend (Python/FastAPI) and frontend (Flutter)
   - File structure for both applications

8. **50+ API Endpoints**
   - Authentication, Organizations, Classrooms, Chat, Analytics, Teacher Monitoring, Parent Portal

9. **Security Considerations**
   - Authentication security, data isolation, file upload security, API security, privacy compliance

The plan is production-ready and addresses all your requirements including the critical data isolation requirement where student chats and documents never affect other students, and each classroom maintains its own separate environment.

## 🎉 Next Steps

1. **Review and Approve Plan**

   - Stakeholder review
   - Timeline confirmation
   - Resource allocation

2. **Setup Development Environment**

   - PostgreSQL installation
   - Redis setup
   - Development database seed

3. **Start Phase 1 Implementation**

   - Create Git branches
   - Setup CI/CD pipeline
   - Begin coding

4. **Weekly Progress Reviews**
   - Sprint planning
   - Demo sessions
   - Retrospectives

---

## 📝 Notes

- This plan assumes a team of 2-3 developers
- Timeline: ~18 weeks (4.5 months)
- Can be parallelized with more resources
- Phases can be adjusted based on priorities
- MVP can be achieved by end of Phase 4 (Week 11)

---

**Document Version:** 1.0  
**Last Updated:** December 16, 2025  
**Author:** AI Planning Assistant  
**Status:** Awaiting Approval
