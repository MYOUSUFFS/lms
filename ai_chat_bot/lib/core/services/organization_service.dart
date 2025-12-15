import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/organization.dart';

/// Service for organization API operations
class OrganizationService {
  final String baseUrl;
  String? _accessToken;

  OrganizationService({required this.baseUrl});

  /// Initialize service and load stored token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }

  /// Set access token
  void setToken(String token) {
    _accessToken = token;
  }

  /// Create a new organization
  Future<Organization> createOrganization(
      CreateOrganizationRequest request) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/organizations/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return Organization.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to create organization');
    }
  }

  /// Get list of organizations
  Future<List<Organization>> listOrganizations({
    int skip = 0,
    int limit = 100,
  }) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v2/organizations/?skip=$skip&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Organization.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception('Failed to load organizations');
    }
  }

  /// Get organization by ID
  Future<Organization> getOrganization(String organizationId) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v2/organizations/$organizationId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      return Organization.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else if (response.statusCode == 404) {
      throw Exception('Organization not found');
    } else {
      throw Exception('Failed to load organization');
    }
  }

  /// Update organization
  Future<Organization> updateOrganization(
    String organizationId,
    UpdateOrganizationRequest request,
  ) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/v2/organizations/$organizationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return Organization.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else if (response.statusCode == 403) {
      throw Exception('Permission denied');
    } else if (response.statusCode == 404) {
      throw Exception('Organization not found');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to update organization');
    }
  }

  /// Delete organization
  Future<void> deleteOrganization(String organizationId) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/api/v2/organizations/$organizationId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else if (response.statusCode == 403) {
      throw Exception('Permission denied');
    } else if (response.statusCode == 404) {
      throw Exception('Organization not found');
    } else {
      throw Exception('Failed to delete organization');
    }
  }

  /// Add member to organization
  Future<OrganizationMember> addMember(
    String organizationId,
    AddMemberRequest request,
  ) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/organizations/$organizationId/members'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return OrganizationMember.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else if (response.statusCode == 403) {
      throw Exception('Permission denied');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to add member');
    }
  }

  /// Get organization members
  Future<List<OrganizationMember>> listMembers(String organizationId) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v2/organizations/$organizationId/members'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => OrganizationMember.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception('Failed to load members');
    }
  }

  /// Remove member from organization
  Future<void> removeMember(String organizationId, String memberId) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.delete(
      Uri.parse(
          '$baseUrl/api/v2/organizations/$organizationId/members/$memberId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else if (response.statusCode == 403) {
      throw Exception('Permission denied');
    } else {
      throw Exception('Failed to remove member');
    }
  }

  /// Create invitation
  Future<Invitation> createInvitation(
    String organizationId,
    CreateInvitationRequest request,
  ) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/organizations/$organizationId/invitations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return Invitation.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else if (response.statusCode == 403) {
      throw Exception('Permission denied');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to create invitation');
    }
  }

  /// Get organization invitations
  Future<List<Invitation>> listInvitations(String organizationId) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v2/organizations/$organizationId/invitations'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Invitation.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception('Failed to load invitations');
    }
  }

  /// Accept invitation
  Future<OrganizationMember> acceptInvitation(String token) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/organizations/invitations/$token/accept'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      return OrganizationMember.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else if (response.statusCode == 404) {
      throw Exception('Invitation not found or expired');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to accept invitation');
    }
  }
}
