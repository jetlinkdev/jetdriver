import '../constants/hive_constants.dart';

/// Application configuration for Jetdriver
class AppConfig {
  // WebSocket server URL
  // Updated to the current ngrok URL
  static const String defaultWebSocketUrl = 'wss://3b52-2404-c0-3194-2aad-a2de-acf2-bd3d-3ce4.ngrok-free.app/ws';

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
