/// Organization model for multi-tenancy
class Organization {
  final String id;
  final String name;
  final String? description;
  final String
      type; // 'school', 'university', 'training_center', 'corporate', 'other'
  final Map<String, dynamic> settings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? logoUrl;
  final String? website;
  final String? contactEmail;
  final String? contactPhone;

  Organization({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.settings,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.logoUrl,
    this.website,
    this.contactEmail,
    this.contactPhone,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      logoUrl: json['logo_url'],
      website: json['website'],
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'settings': settings,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'logo_url': logoUrl,
      'website': website,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
    };
  }
}

/// Organization member model
class OrganizationMember {
  final String id;
  final String organizationId;
  final String userId;
  final String
      role; // 'school_admin', 'sub_admin', 'teacher', 'student', 'parent', 'guest'
  final DateTime joinedAt;
  final bool isActive;
  final String? userName;
  final String? userEmail;

  OrganizationMember({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.isActive,
    this.userName,
    this.userEmail,
  });

  factory OrganizationMember.fromJson(Map<String, dynamic> json) {
    return OrganizationMember(
      id: json['id'],
      organizationId: json['organization_id'],
      userId: json['user_id'],
      role: json['role'],
      joinedAt: DateTime.parse(json['joined_at']),
      isActive: json['is_active'],
      userName: json['user_name'],
      userEmail: json['user_email'],
    );
  }
}

/// Invitation model
class Invitation {
  final String id;
  final String organizationId;
  final String email;
  final String role;
  final String status; // 'pending', 'accepted', 'expired'
  final String? invitedBy;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? organizationName;

  Invitation({
    required this.id,
    required this.organizationId,
    required this.email,
    required this.role,
    required this.status,
    this.invitedBy,
    required this.createdAt,
    required this.expiresAt,
    this.organizationName,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'],
      organizationId: json['organization_id'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
      invitedBy: json['invited_by'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      organizationName: json['organization_name'],
    );
  }
}

/// Request models
class CreateOrganizationRequest {
  final String name;
  final String? description;
  final String type;
  final String? logoUrl;
  final String? website;
  final String? contactEmail;
  final String? contactPhone;

  CreateOrganizationRequest({
    required this.name,
    this.description,
    required this.type,
    this.logoUrl,
    this.website,
    this.contactEmail,
    this.contactPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'logo_url': logoUrl,
      'website': website,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
    };
  }
}

class UpdateOrganizationRequest {
  final String? name;
  final String? description;
  final String? logoUrl;
  final String? website;
  final String? contactEmail;
  final String? contactPhone;
  final bool? isActive;

  UpdateOrganizationRequest({
    this.name,
    this.description,
    this.logoUrl,
    this.website,
    this.contactEmail,
    this.contactPhone,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (logoUrl != null) map['logo_url'] = logoUrl;
    if (website != null) map['website'] = website;
    if (contactEmail != null) map['contact_email'] = contactEmail;
    if (contactPhone != null) map['contact_phone'] = contactPhone;
    if (isActive != null) map['is_active'] = isActive;
    return map;
  }
}

class AddMemberRequest {
  final String userId;
  final String role;

  AddMemberRequest({
    required this.userId,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role': role,
    };
  }
}

class CreateInvitationRequest {
  final String email;
  final String role;

  CreateInvitationRequest({
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'role': role,
    };
  }
}
