import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Authentication service for user login, registration, and token management
class AuthService {
  final String baseUrl;
  String? _accessToken;
  String? _refreshToken;
  User? _currentUser;

  AuthService({required this.baseUrl});

  // Getters
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _accessToken != null && _currentUser != null;

  /// Initialize service by loading stored tokens
  Future<void> init() async {
    await _loadStoredTokens();
    if (_accessToken != null) {
      try {
        await fetchCurrentUser();
      } catch (e) {
        // Token might be expired, try to refresh
        if (_refreshToken != null) {
          await refreshAccessToken();
        }
      }
    }
  }

  /// Register a new user
  Future<User> register(RegisterData data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode == 201) {
      final userData = jsonDecode(response.body);
      return User.fromJson(userData);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed');
    }
  }

  /// Login with email and password
  Future<void> login(LoginCredentials credentials) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(credentials.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = AuthToken.fromJson(data);

      _accessToken = token.accessToken;
      _refreshToken = token.refreshToken;

      await _saveTokens();
      await fetchCurrentUser();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Login failed');
    }
  }

  /// Fetch current user information
  Future<User> fetchCurrentUser() async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v2/auth/me'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      _currentUser = User.fromJson(userData);
      return _currentUser!;
    } else if (response.statusCode == 401) {
      // Token expired, try to refresh
      if (_refreshToken != null) {
        await refreshAccessToken();
        return fetchCurrentUser();
      }
      throw Exception('Session expired');
    } else {
      throw Exception('Failed to fetch user information');
    }
  }

  /// Refresh access token using refresh token
  Future<void> refreshAccessToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = AuthToken.fromJson(data);

      _accessToken = token.accessToken;
      _refreshToken = token.refreshToken;

      await _saveTokens();
    } else {
      // Refresh token expired, need to login again
      await logout();
      throw Exception('Session expired, please login again');
    }
  }

  /// Logout and clear all stored authentication data
  Future<void> logout() async {
    try {
      // Call backend logout endpoint to blacklist token
      if (_accessToken != null) {
        await http.post(
          Uri.parse('$baseUrl/api/v2/auth/logout'),
          headers: {'Authorization': 'Bearer $_accessToken'},
        ).timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      // Continue with logout even if backend call fails
      print('Backend logout failed: $e');
    }

    // Clear in-memory authentication state
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;

    // Clear all authentication-related data from local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');

    // Optional: Clear any other cached user data
    // await prefs.remove('user_profile');
    // await prefs.remove('last_sync_time');

    print('Logout completed - all session data cleared');
  }

  /// Verify email with token
  Future<void> verifyEmail(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/auth/verify-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Email verification failed');
    }
  }

  /// Save tokens to local storage
  Future<void> _saveTokens() async {
    final prefs = await SharedPreferences.getInstance();
    if (_accessToken != null) {
      await prefs.setString('access_token', _accessToken!);
    }
    if (_refreshToken != null) {
      await prefs.setString('refresh_token', _refreshToken!);
    }
  }

  /// Load tokens from local storage
  Future<void> _loadStoredTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  /// Make authenticated HTTP request with automatic token refresh
  Future<http.Response> authenticatedRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$baseUrl$path');
    final requestHeaders = {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
      ...?headers,
    };

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: requestHeaders);
        break;
      case 'POST':
        response = await http.post(
          uri,
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: requestHeaders);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    // Handle token expiration
    if (response.statusCode == 401 && _refreshToken != null) {
      await refreshAccessToken();
      // Retry the request with new token
      return authenticatedRequest(method, path, body: body, headers: headers);
    }

    return response;
  }
}
