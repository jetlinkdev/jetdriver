import 'package:flutter/material.dart';
import 'package:jetdriver/app.dart';
import 'package:jetdriver/config/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'utils/logger.dart';
import 'services/websocket_service.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize WebSocket
  await _initializeWebSocket();

  runApp(const JetdriverApp());
}

/// Initialize WebSocket connection with global handlers
Future<void> _initializeWebSocket() async {
  final wsService = WebSocketService.instance;
  final logger = Logger.instance;

  // Enable auto-reconnection
  wsService.enableAutoReconnect();

  // Setup global WebSocket event handlers
  wsService.onConnected = () {
    logger.success('✅ WebSocket connected');
  };

  wsService.onDisconnected = () {
    logger.warning('❌ WebSocket disconnected');
  };

  wsService.onError = (String error) {
    logger.error('⚠️ WebSocket error: $error');
  };

  wsService.onMessageReceived = (message) {
    // Global message handler - messages will be broadcast via stream
    // Individual screens can subscribe to the message stream
    logger.info('📨 WebSocket message: ${message.intent}');
  };

  // Connect to WebSocket server
  await wsService.connect(AppConfig.defaultWebSocketUrl);
}