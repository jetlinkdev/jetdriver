/// Application configuration for Jetdriver
class AppConfig {
  // Backend API base URL
  // Updated to the current ngrok URL
  static const String baseUrl = 'https://3bfc-2404-c0-3074-3980-ced5-b0e1-5fb2-4a.ngrok-free.app/api';

  // WebSocket server URL
  // Updated to the current ngrok URL
  static const String defaultWebSocketUrl = 'wss://3bfc-2404-c0-3074-3980-ced5-b0e1-5fb2-4a.ngrok-free.app/ws';

  // App version
  static const String appVersion = '1.0.0';

  // Driver status options
  static const List<String> driverStatuses = ['available', 'busy', 'offline'];

  // Connection retry settings
  static const int maxReconnectionAttempts = 5;
  static const Duration reconnectionDelay = Duration(seconds: 3);

  // Ping interval (must be less than server's pingInterval)
  static const Duration pingInterval = Duration(seconds: 30);
}
