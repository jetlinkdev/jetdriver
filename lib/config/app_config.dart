import '../constants/hive_constants.dart';

/// Application configuration for Jetdriver
class AppConfig {
  // WebSocket server URL
  // Default to the current ngrok URL
  static const String defaultWebSocketUrl = 'wss://369b-2404-c0-3476-1536-2972-796b-65ee-45ff.ngrok-free.app/ws';

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
