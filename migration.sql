INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Generating static SQL
INFO  [alembic.runtime.migration] Will assume transactional DDL.
BEGIN;

CREATE TABLE alembic_version (
    version_num VARCHAR(32) NOT NULL, 
    CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
);

INFO  [alembic.runtime.migration] Running upgrade  -> e6fa013c030d, initial_schema
-- Running upgrade  -> e6fa013c030d

CREATE TABLE users (
    id UUID NOT NULL, 
    email VARCHAR(255) NOT NULL, 
    password_hash VARCHAR(255) NOT NULL, 
    full_name VARCHAR(255) NOT NULL, 
    is_active BOOLEAN DEFAULT 'true' NOT NULL, 
    is_email_verified BOOLEAN DEFAULT 'false' NOT NULL, 
    email_verified_at TIMESTAMP WITH TIME ZONE, 
    avatar_url VARCHAR(500), 
    phone VARCHAR(50), 
    bio TEXT, 
    preferences JSONB DEFAULT '{}' NOT NULL, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    last_login_at TIMESTAMP WITH TIME ZONE, 
    PRIMARY KEY (id), 
    UNIQUE (email)
);

CREATE INDEX idx_users_email ON users (email);

CREATE TABLE organizations (
    id UUID NOT NULL, 
    name VARCHAR(255) NOT NULL, 
    slug VARCHAR(255) NOT NULL, 
    description TEXT, 
    logo_url VARCHAR(500), 
    website VARCHAR(500), 
    is_active BOOLEAN DEFAULT 'true' NOT NULL, 
    settings JSONB DEFAULT '{}' NOT NULL, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    PRIMARY KEY (id), 
    UNIQUE (slug)
);

CREATE INDEX idx_orgs_slug ON organizations (slug);

CREATE TABLE organization_members (
    id UUID NOT NULL, 
    organization_id UUID NOT NULL, 
    user_id UUID NOT NULL, 
    role VARCHAR(50) NOT NULL, 
    department VARCHAR(100), 
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    invited_by UUID, 
    status VARCHAR(20) DEFAULT 'active' NOT NULL, 
    member_metadata JSONB DEFAULT '{}' NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(organization_id) REFERENCES organizations (id) ON DELETE CASCADE, 
    FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
    FOREIGN KEY(invited_by) REFERENCES users (id), 
    CONSTRAINT uq_org_member UNIQUE (organization_id, user_id)
);

CREATE INDEX idx_org_members_org ON organization_members (organization_id);

CREATE INDEX idx_org_members_user ON organization_members (user_id);

CREATE INDEX idx_org_members_role ON organization_members (role);

CREATE TABLE classrooms (
    id UUID NOT NULL, 
    organization_id UUID NOT NULL, 
    name VARCHAR(255) NOT NULL, 
    description TEXT, 
    owner_id UUID NOT NULL, 
    owner_type VARCHAR(20) DEFAULT 'teacher' NOT NULL, 
    chroma_collection_name VARCHAR(255) NOT NULL, 
    is_active BOOLEAN DEFAULT 'true' NOT NULL, 
    settings JSONB DEFAULT '{}' NOT NULL, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(organization_id) REFERENCES organizations (id) ON DELETE CASCADE, 
    FOREIGN KEY(owner_id) REFERENCES users (id) ON DELETE CASCADE, 
    UNIQUE (chroma_collection_name)
);

CREATE INDEX idx_classrooms_org ON classrooms (organization_id);

CREATE INDEX idx_classrooms_owner ON classrooms (owner_id);

CREATE TABLE classroom_members (
    id UUID NOT NULL, 
    classroom_id UUID NOT NULL, 
    user_id UUID NOT NULL, 
    role VARCHAR(50) NOT NULL, 
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(classroom_id) REFERENCES classrooms (id) ON DELETE CASCADE, 
    FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
    CONSTRAINT uq_classroom_member UNIQUE (classroom_id, user_id)
);

CREATE INDEX idx_classroom_members_classroom ON classroom_members (classroom_id);

CREATE INDEX idx_classroom_members_user ON classroom_members (user_id);

CREATE TABLE documents (
    id UUID NOT NULL, 
    classroom_id UUID NOT NULL, 
    uploader_id UUID NOT NULL, 
    filename VARCHAR(500) NOT NULL, 
    file_path VARCHAR(1000) NOT NULL, 
    file_size BIGINT NOT NULL, 
    mime_type VARCHAR(100) NOT NULL, 
    visibility VARCHAR(20) DEFAULT 'classroom' NOT NULL, 
    processing_status VARCHAR(50) DEFAULT 'pending' NOT NULL, 
    chunk_count INTEGER DEFAULT '0' NOT NULL, 
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    doc_metadata JSONB DEFAULT '{}' NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(classroom_id) REFERENCES classrooms (id) ON DELETE CASCADE, 
    FOREIGN KEY(uploader_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE INDEX idx_documents_classroom ON documents (classroom_id);

CREATE INDEX idx_documents_uploader ON documents (uploader_id);

CREATE INDEX idx_documents_status ON documents (processing_status);

CREATE TABLE conversations (
    id UUID NOT NULL, 
    classroom_id UUID NOT NULL, 
    user_id UUID NOT NULL, 
    title VARCHAR(500), 
    message_count INTEGER DEFAULT '0' NOT NULL, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    last_message_at TIMESTAMP WITH TIME ZONE, 
    PRIMARY KEY (id), 
    FOREIGN KEY(classroom_id) REFERENCES classrooms (id) ON DELETE CASCADE, 
    FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE INDEX idx_conversations_classroom ON conversations (classroom_id);

CREATE INDEX idx_conversations_user ON conversations (user_id);

CREATE TABLE messages (
    id UUID NOT NULL, 
    conversation_id UUID NOT NULL, 
    role VARCHAR(50) NOT NULL, 
    content TEXT NOT NULL, 
    sources JSONB, 
    token_count INTEGER, 
    model_used VARCHAR(100), 
    latency_ms INTEGER, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(conversation_id) REFERENCES conversations (id) ON DELETE CASCADE
);

CREATE INDEX idx_messages_conversation ON messages (conversation_id);

CREATE INDEX idx_messages_created ON messages (created_at);

CREATE TABLE invitations (
    id UUID NOT NULL, 
    organization_id UUID NOT NULL, 
    email VARCHAR(255) NOT NULL, 
    role VARCHAR(50) NOT NULL, 
    token VARCHAR(255) NOT NULL, 
    invited_by UUID NOT NULL, 
    status VARCHAR(20) DEFAULT 'pending' NOT NULL, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL, 
    accepted_at TIMESTAMP WITH TIME ZONE, 
    PRIMARY KEY (id), 
    FOREIGN KEY(organization_id) REFERENCES organizations (id) ON DELETE CASCADE, 
    FOREIGN KEY(invited_by) REFERENCES users (id), 
    UNIQUE (token)
);

CREATE INDEX idx_invitations_org ON invitations (organization_id);

CREATE INDEX idx_invitations_email ON invitations (email);

CREATE INDEX idx_invitations_token ON invitations (token);

CREATE TABLE parent_student_links (
    id UUID NOT NULL, 
    parent_id UUID NOT NULL, 
    student_id UUID NOT NULL, 
    organization_id UUID NOT NULL, 
    relationship_type VARCHAR(50), 
    can_view_chats BOOLEAN DEFAULT 'true' NOT NULL, 
    linked_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    linked_by UUID, 
    PRIMARY KEY (id), 
    FOREIGN KEY(parent_id) REFERENCES users (id) ON DELETE CASCADE, 
    FOREIGN KEY(student_id) REFERENCES users (id) ON DELETE CASCADE, 
    FOREIGN KEY(organization_id) REFERENCES organizations (id) ON DELETE CASCADE, 
    FOREIGN KEY(linked_by) REFERENCES users (id), 
    CONSTRAINT uq_parent_student_org UNIQUE (parent_id, student_id, organization_id)
);

CREATE INDEX idx_parent_links_parent ON parent_student_links (parent_id);

CREATE INDEX idx_parent_links_student ON parent_student_links (student_id);

CREATE TABLE analytics_events (
    id UUID NOT NULL, 
    organization_id UUID, 
    classroom_id UUID, 
    user_id UUID, 
    event_type VARCHAR(100) NOT NULL, 
    event_data JSONB DEFAULT '{}' NOT NULL, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(organization_id) REFERENCES organizations (id) ON DELETE CASCADE, 
    FOREIGN KEY(classroom_id) REFERENCES classrooms (id) ON DELETE CASCADE, 
    FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE INDEX idx_analytics_org ON analytics_events (organization_id);

CREATE INDEX idx_analytics_classroom ON analytics_events (classroom_id);

CREATE INDEX idx_analytics_user ON analytics_events (user_id);

CREATE INDEX idx_analytics_type ON analytics_events (event_type);

CREATE INDEX idx_analytics_created ON analytics_events (created_at);

INSERT INTO alembic_version (version_num) VALUES ('e6fa013c030d') RETURNING alembic_version.version_num;

COMMIT;

