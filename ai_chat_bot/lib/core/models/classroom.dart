/// Classroom model for learning groups
class Classroom {
  final String id;
  final String name;
  final String? description;
  final String? organizationId;
  final String ownerId;
  final String ownerType; // 'user' or 'teacher'
  final String? subject;
  final String? gradeLevel;
  final String? academicYear;
  final Map<String, dynamic> settings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String chromaCollectionName;

  Classroom({
    required this.id,
    required this.name,
    this.description,
    this.organizationId,
    required this.ownerId,
    required this.ownerType,
    this.subject,
    this.gradeLevel,
    this.academicYear,
    required this.settings,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.chromaCollectionName,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      organizationId: json['organization_id'],
      ownerId: json['owner_id'],
      ownerType: json['owner_type'],
      subject: json['subject'],
      gradeLevel: json['grade_level'],
      academicYear: json['academic_year'],
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      chromaCollectionName: json['chroma_collection_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'organization_id': organizationId,
      'owner_id': ownerId,
      'owner_type': ownerType,
      'subject': subject,
      'grade_level': gradeLevel,
      'academic_year': academicYear,
      'settings': settings,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'chroma_collection_name': chromaCollectionName,
    };
  }

  Classroom copyWith({
    String? id,
    String? name,
    String? description,
    String? organizationId,
    String? ownerId,
    String? ownerType,
    String? subject,
    String? gradeLevel,
    String? academicYear,
    Map<String, dynamic>? settings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? chromaCollectionName,
  }) {
    return Classroom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      organizationId: organizationId ?? this.organizationId,
      ownerId: ownerId ?? this.ownerId,
      ownerType: ownerType ?? this.ownerType,
      subject: subject ?? this.subject,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      academicYear: academicYear ?? this.academicYear,
      settings: settings ?? this.settings,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      chromaCollectionName: chromaCollectionName ?? this.chromaCollectionName,
    );
  }
}

/// Classroom member model
class ClassroomMember {
  final String id;
  final String classroomId;
  final String userId;
  final String role; // 'teacher', 'student', 'assistant'
  final DateTime joinedAt;
  final bool isActive;
  final String? invitedBy;
  final DateTime? lastAccessedAt;

  ClassroomMember({
    required this.id,
    required this.classroomId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.isActive,
    this.invitedBy,
    this.lastAccessedAt,
  });

  factory ClassroomMember.fromJson(Map<String, dynamic> json) {
    return ClassroomMember(
      id: json['id'],
      classroomId: json['classroom_id'],
      userId: json['user_id'],
      role: json['role'],
      joinedAt: DateTime.parse(json['joined_at']),
      isActive: json['is_active'],
      invitedBy: json['invited_by'],
      lastAccessedAt: json['last_accessed_at'] != null
          ? DateTime.parse(json['last_accessed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classroom_id': classroomId,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'is_active': isActive,
      'invited_by': invitedBy,
      'last_accessed_at': lastAccessedAt?.toIso8601String(),
    };
  }
}

/// Create classroom request
class CreateClassroomRequest {
  final String name;
  final String? description;
  final String? organizationId;
  final String? subject;
  final String? gradeLevel;
  final String? academicYear;
  final Map<String, dynamic>? settings;

  CreateClassroomRequest({
    required this.name,
    this.description,
    this.organizationId,
    this.subject,
    this.gradeLevel,
    this.academicYear,
    this.settings,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'organization_id': organizationId,
      'subject': subject,
      'grade_level': gradeLevel,
      'academic_year': academicYear,
      'settings': settings ?? {},
    };
  }
}

/// Update classroom request
class UpdateClassroomRequest {
  final String? name;
  final String? description;
  final String? subject;
  final String? gradeLevel;
  final String? academicYear;
  final Map<String, dynamic>? settings;
  final bool? isActive;

  UpdateClassroomRequest({
    this.name,
    this.description,
    this.subject,
    this.gradeLevel,
    this.academicYear,
    this.settings,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (subject != null) json['subject'] = subject;
    if (gradeLevel != null) json['grade_level'] = gradeLevel;
    if (academicYear != null) json['academic_year'] = academicYear;
    if (settings != null) json['settings'] = settings;
    if (isActive != null) json['is_active'] = isActive;
    return json;
  }
}
