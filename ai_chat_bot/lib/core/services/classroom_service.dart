import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/classroom.dart';

/// Service for classroom API operations
class ClassroomService {
  final String baseUrl;
  String? _accessToken;

  ClassroomService({required this.baseUrl});

  /// Initialize service and load stored token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }

  /// Set access token
  void setToken(String token) {
    _accessToken = token;
  }

  /// Create a new classroom
  Future<Classroom> createClassroom(CreateClassroomRequest request) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/classrooms/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return Classroom.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to create classroom');
    }
  }

  /// Get list of classrooms
  Future<List<Classroom>> listClassrooms({
    String? organizationId,
    bool? isActive,
  }) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final queryParams = <String, String>{};
    if (organizationId != null) queryParams['organization_id'] = organizationId;
    if (isActive != null) queryParams['is_active'] = isActive.toString();

    final uri = Uri.parse('$baseUrl/api/v2/classrooms/')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Classroom.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception('Failed to fetch classrooms');
    }
  }

  /// Get classroom by ID
  Future<Classroom> getClassroom(String classroomId) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v2/classrooms/$classroomId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      return Classroom.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Classroom not found');
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied');
    } else {
      throw Exception('Failed to fetch classroom');
    }
  }

  /// Update classroom
  Future<Classroom> updateClassroom(
    String classroomId,
    UpdateClassroomRequest request,
  ) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/v2/classrooms/$classroomId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return Classroom.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Classroom not found');
    } else if (response.statusCode == 403) {
      throw Exception('Only classroom owner can update');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to update classroom');
    }
  }

  /// Delete classroom
  Future<void> deleteClassroom(String classroomId) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/api/v2/classrooms/$classroomId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Classroom not found');
    } else if (response.statusCode == 403) {
      throw Exception('Only classroom owner can delete');
    } else {
      throw Exception('Failed to delete classroom');
    }
  }

  /// Add member to classroom
  Future<ClassroomMember> addMember(
    String classroomId,
    String userId,
    String role,
  ) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/classrooms/$classroomId/members'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode({
        'classroom_id': classroomId,
        'user_id': userId,
        'role': role,
      }),
    );

    if (response.statusCode == 201) {
      return ClassroomMember.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      throw Exception('User is already a member');
    } else if (response.statusCode == 403) {
      throw Exception('Only classroom owner can add members');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to add member');
    }
  }

  /// List classroom members
  Future<List<ClassroomMember>> listMembers(
    String classroomId, {
    bool? isActive,
  }) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final queryParams = <String, String>{};
    if (isActive != null) queryParams['is_active'] = isActive.toString();

    final uri = Uri.parse('$baseUrl/api/v2/classrooms/$classroomId/members')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ClassroomMember.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch members');
    }
  }

  /// Remove member from classroom
  Future<void> removeMember(String classroomId, String memberId) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/api/v2/classrooms/$classroomId/members/$memberId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Member not found');
    } else if (response.statusCode == 403) {
      throw Exception('Only classroom owner can remove members');
    } else {
      throw Exception('Failed to remove member');
    }
  }
}
