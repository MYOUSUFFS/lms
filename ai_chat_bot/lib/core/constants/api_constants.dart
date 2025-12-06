/// API Constants for the LMS Chat Application
class ApiConstants {
  // Base URL - Change this to your server address
  static const String baseUrl = 'http://192.168.1.6:8000';

  // API Version
  static const String apiVersion = 'v1';

  // Full API Base
  static String get apiBase => '$baseUrl/api/$apiVersion';

  // Endpoints
  static String get chatEndpoint => '$apiBase/chat';
  static String get chatStreamEndpoint => '$apiBase/chat/stream';
  static String get queryEndpoint => '$apiBase/query';
  static String get queryStreamEndpoint => '$apiBase/query/stream';
  static String get documentsEndpoint => '$apiBase/documents';
  static String get healthEndpoint => '$apiBase/health';

  // Default API Key (should be configured by user)
  static const String defaultApiKey =
      'c0d78bb73e0d18072d55fc2ef3bacdd40510263b67030f9e746debcce8e9c292';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 120);
}
