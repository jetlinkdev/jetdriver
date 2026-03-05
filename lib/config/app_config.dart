import '../constants/hive_constants.dart';

/// Application configuration for Jetdriver
class AppConfig {
  // Backend API base URL
  // Updated to the current ngrok URL
  static const String baseUrl = 'https://ebfe-2404-c0-3074-3980-61d1-6410-b91f-aeb9.ngrok-free.app/api';

  // WebSocket server URL
  // Updated to the current ngrok URL
  static const String defaultWebSocketUrl = 'wss://ebfe-2404-c0-3074-3980-61d1-6410-b91f-aeb9.ngrok-free.app/ws';

  // App version
  static const String appVersion = '1.0.0';

  // Driver status options
  static const List<String> driverStatuses = ['available', 'busy', 'offline'];

  // Connection retry settings
  static const int maxReconnectionAttempts = 5;
  static const Duration reconnectionDelay = Duration(seconds: 3);

  // Ping interval (must be less than server's pingInterval)
  static const Duration pingInterval = Duration(seconds: 30);

  // Default driver ID (moved to HiveConstants)
  static const String defaultDriverId = HiveConstants.defaultDriverId;
}
