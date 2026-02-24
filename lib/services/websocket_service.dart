import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';
import '../constants/intent_constants.dart';
import '../utils/logger.dart';

/// WebSocket message structure
class WebSocketMessage {
  final String intent;
  final dynamic data;
  final int timestamp;
  final String? clientId;

  WebSocketMessage({
    required this.intent,
    this.data,
    required this.timestamp,
    this.clientId,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      intent: json['intent'] as String,
      data: json['data'],
      timestamp: json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      clientId: json['clientId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intent': intent,
      'data': data,
      'timestamp': timestamp,
      if (clientId != null) 'clientId': clientId,
    };
  }
}

/// Connection status enum
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// WebSocket service for real-time communication with backend
class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._();

  WebSocketService._();

  WebSocketChannel? _channel;
  Timer? _pingTimer;
  StreamSubscription? _subscription;
  
  // Connection state
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  bool _shouldReconnect = false;
  int _reconnectionAttempts = 0;
  String? _currentUrl;

  // StreamController for broadcasting messages to all subscribers
  final _messageController = StreamController<WebSocketMessage>.broadcast();

  /// Stream for screens to subscribe to WebSocket messages
  Stream<WebSocketMessage> get messageStream => _messageController.stream;

  /// Connection status getter
  ConnectionStatus get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus == ConnectionStatus.connected;
  bool get isConnecting => _connectionStatus == ConnectionStatus.connecting;

  /// Callbacks for handling different WebSocket events
  Function()? onConnected;
  Function()? onDisconnected;
  Function(String)? onError;
  Function(WebSocketMessage)? onMessageReceived;

  /// Connect to WebSocket server
  Future<bool> connect(String url) async {
    try {
      if (isConnected) {
        Logger.instance.warning('WebSocket is already connected');
        return true;
      }

      _connectionStatus = ConnectionStatus.connecting;
      _currentUrl = url;

      // Connect to WebSocket
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      // Setup listeners
      _setupListeners();
      _startPingTimer();

      _connectionStatus = ConnectionStatus.connected;
      _reconnectionAttempts = 0;
      onConnected?.call();
      Logger.instance.success('Connected to WebSocket server');

      return true;
    } catch (e) {
      Logger.instance.error('WebSocket connection failed: $e');
      _connectionStatus = ConnectionStatus.error;
      onError?.call('Connection failed: $e');
      
      if (_shouldReconnect) {
        _scheduleReconnection();
      }
      
      return false;
    }
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _shouldReconnect = false;
    _stopPingTimer();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _connectionStatus = ConnectionStatus.disconnected;
    onDisconnected?.call();
  }

  /// Enable auto-reconnection
  void enableAutoReconnect() {
    _shouldReconnect = true;
  }

  /// Disable auto-reconnection
  void disableAutoReconnect() {
    _shouldReconnect = false;
  }

  /// Send a text message
  void sendText(String text) {
    if (!isConnected) {
      Logger.instance.warning('Cannot send message: WebSocket is not connected');
      return;
    }

    try {
      _channel!.sink.add(text);
    } catch (e) {
      Logger.instance.error('Error sending text: $e');
      onError?.call('Send error: $e');
    }
  }

  /// Send a JSON message
  void sendJson(Map<String, dynamic> json) {
    sendText(jsonEncode(json));
  }

  /// Send submit_bid request
  void sendSubmitBid({
    required int orderId,
    required String driverId,
    required double bidPrice,
    required int etaMinutes,
  }) {
    if (!isConnected) {
      Logger.instance.error('Cannot send bid: WebSocket is not connected');
      return;
    }

    try {
      final bidData = {
        IntentConstants.intentKey: IntentConstants.submitBid,
        IntentConstants.dataKey: {
          IntentConstants.orderIdKey: orderId,
          IntentConstants.driverIdKey: driverId,
          IntentConstants.bidPriceKey: bidPrice,
          IntentConstants.estimatedArrivalTimeKey: etaMinutes,
        },
        IntentConstants.timestampKey: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      sendJson(bidData);
      Logger.instance.info('Bid submitted for order #$orderId');
    } catch (e) {
      Logger.instance.error('Error sending bid: $e');
      onError?.call('Send bid error: $e');
    }
  }

  /// Send driver_arrived request
  void sendDriverArrived({
    required int orderId,
    required String driverId,
  }) {
    if (!isConnected) {
      Logger.instance.error('Cannot send arrival: WebSocket is not connected');
      return;
    }

    try {
      final arrivalData = {
        IntentConstants.intentKey: IntentConstants.driverArrived,
        IntentConstants.dataKey: {
          IntentConstants.orderIdKey: orderId,
          IntentConstants.driverIdKey: driverId,
        },
        IntentConstants.timestampKey: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      sendJson(arrivalData);
      Logger.instance.success('Driver arrival sent for order #$orderId');
    } catch (e) {
      Logger.instance.error('Error sending arrival: $e');
      onError?.call('Send arrival error: $e');
    }
  }

  /// Send complete_trip request
  void sendCompleteTrip({
    required int orderId,
    required String driverId,
  }) {
    if (!isConnected) {
      Logger.instance.error('Cannot complete trip: WebSocket is not connected');
      return;
    }

    try {
      final completeData = {
        IntentConstants.intentKey: IntentConstants.completeTrip,
        IntentConstants.dataKey: {
          IntentConstants.orderIdKey: orderId,
          IntentConstants.driverIdKey: driverId,
        },
        IntentConstants.timestampKey: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      sendJson(completeData);
      Logger.instance.success('Trip completion sent for order #$orderId');
    } catch (e) {
      Logger.instance.error('Error sending complete trip: $e');
      onError?.call('Send complete trip error: $e');
    }
  }

  /// Send get_my_bids request
  void sendGetMyBids() {
    if (!isConnected) {
      Logger.instance.error('Cannot get my bids: WebSocket is not connected');
      return;
    }

    try {
      final getBidsData = {
        IntentConstants.intentKey: IntentConstants.getMyBids,
        IntentConstants.dataKey: {},
        IntentConstants.timestampKey: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      sendJson(getBidsData);
      Logger.instance.info('Get my bids request sent');
    } catch (e) {
      Logger.instance.error('Error sending get my bids: $e');
      onError?.call('Send get my bids error: $e');
    }
  }

  /// Send ping message
  void sendPing() {
    if (!isConnected) {
      Logger.instance.warning('Cannot send ping: WebSocket is not connected');
      return;
    }

    try {
      final pingData = {
        IntentConstants.intentKey: IntentConstants.ping,
        IntentConstants.dataKey: {},
        IntentConstants.timestampKey: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      sendJson(pingData);
    } catch (e) {
      Logger.instance.error('Error sending ping: $e');
    }
  }

  /// Setup WebSocket listeners
  void _setupListeners() {
    _subscription = _channel!.stream.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDone,
    );
  }

  /// Handle incoming messages
  void _handleMessage(dynamic data) {
    try {
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          final message = WebSocketMessage.fromJson(decoded);
          
          // Broadcast to stream for all subscribers
          _messageController.add(message);

          // Also call legacy callback for backward compatibility
          onMessageReceived?.call(message);
        }
      }
    } catch (e) {
      Logger.instance.error('Error parsing message: $e');
    }
  }

  /// Handle WebSocket errors
  void _handleError(dynamic error) {
    Logger.instance.error('WebSocket error: $error');
    _connectionStatus = ConnectionStatus.error;
    onError?.call(error.toString());

    if (_shouldReconnect && _reconnectionAttempts < AppConfig.maxReconnectionAttempts) {
      _scheduleReconnection();
    }
  }

  /// Handle WebSocket connection closed
  void _handleDone() {
    Logger.instance.warning('WebSocket connection closed');
    _channel = null;
    _connectionStatus = ConnectionStatus.disconnected;
    onDisconnected?.call();

    if (_shouldReconnect && _reconnectionAttempts < AppConfig.maxReconnectionAttempts) {
      _scheduleReconnection();
    }
  }

  /// Schedule reconnection
  void _scheduleReconnection() {
    _reconnectionAttempts++;
    Logger.instance.info('Attempting to reconnect... ($_reconnectionAttempts/${AppConfig.maxReconnectionAttempts})');

    Future.delayed(AppConfig.reconnectionDelay, () {
      if (_shouldReconnect && _currentUrl != null) {
        connect(_currentUrl!);
      }
    });
  }

  /// Start ping timer
  void _startPingTimer() {
    _pingTimer = Timer.periodic(AppConfig.pingInterval, (timer) {
      if (isConnected) {
        sendPing();
      }
    });
  }

  /// Stop ping timer
  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  /// Dispose resources
  void dispose() {
    _messageController.close();
    disconnect();
  }
}
