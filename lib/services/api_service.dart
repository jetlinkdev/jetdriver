import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';

/// API Service for REST API communication with backend
class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();

  ApiService._();

  final _logger = Logger.instance;
  
  // Backend API base URL
  // For Android emulator: use 10.0.2.2 instead of localhost
  // For iOS simulator: use localhost
  // For physical device: use your computer's IP address
  String baseUrl = 'http://10.0.2.2:8080/api';

  /// Get Firebase ID token
  Future<String?> _getIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _logger.error('No authenticated user');
        return null;
      }
      
      final idToken = await user.getIdToken();
      return idToken;
    } catch (e) {
      _logger.error('Failed to get ID token: $e');
      return null;
    }
  }

  /// Send HTTP request with Firebase auth token
  Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('Authentication required');
    }

    final url = Uri.parse('$baseUrl$endpoint');
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    _logger.info('API Request: $method $url');

    try {
      http.Response response;
      
      if (method == 'GET') {
        response = await http.get(url, headers: headers);
      } else if (method == 'POST') {
        response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      _logger.info('API Response: ${response.statusCode}');
      
      return response;
    } catch (e) {
      _logger.error('API request failed: $e');
      rethrow;
    }
  }

  /// Check if current user is registered as a driver
  /// Returns driver status information
  Future<Map<String, dynamic>?> checkDriverStatus() async {
    try {
      final response = await _request('GET', '/auth/driver-status');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          _logger.error('Check driver status failed: ${data['error']}');
          return null;
        }
      } else {
        _logger.error('Check driver status failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.error('Check driver status error: $e');
      return null;
    }
  }

  /// Register current user as a driver
  /// Returns true if successful
  Future<bool> registerDriver({
    required String vehicleType,
    required String vehiclePlate,
    required String phoneNumber,
    required String displayName,
    required String email,
  }) async {
    try {
      final response = await _request(
        'POST',
        '/auth/register-driver',
        body: {
          'vehicleType': vehicleType,
          'vehiclePlate': vehiclePlate,
          'phoneNumber': phoneNumber,
          'displayName': displayName,
          'email': email,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _logger.success('Driver registration successful');
          return true;
        } else {
          _logger.error('Registration failed: ${data['error']}');
          return false;
        }
      } else {
        final data = jsonDecode(response.body);
        _logger.error('Registration failed: ${data['error'] ?? response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.error('Registration error: $e');
      return false;
    }
  }

  /// Verify user authentication and get profile
  Future<Map<String, dynamic>?> verifyAuth() async {
    try {
      final response = await _request('POST', '/auth/verify');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          _logger.error('Verify auth failed: ${data['error']}');
          return null;
        }
      } else {
        _logger.error('Verify auth failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.error('Verify auth error: $e');
      return null;
    }
  }
}
