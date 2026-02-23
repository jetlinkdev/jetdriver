import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_config.dart';
import '../constants/hive_constants.dart';
import '../constants/intent_constants.dart';
import '../constants/api_constants.dart';
import '../models/order.dart';
import '../services/websocket_service.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

/// Driver status enum
enum DriverStatus {
  available,
  busy,
  offline,
}

/// Service for managing driver state and orders
class DriverService extends ChangeNotifier {
  static DriverService? _instance;
  static DriverService get instance => _instance ??= DriverService._();

  DriverService._();

  // Driver information
  String _driverId = '';
  DriverStatus _driverStatus = DriverStatus.available;
  String _webSocketUrl = '';
  bool _isDriverRegistered = false;
  String _vehicleType = '';
  String _vehiclePlate = '';
  bool _isVerified = false;

  // Orders list
  final List<Order> _orders = [];

  // WebSocket service
  final WebSocketService _wsService = WebSocketService.instance;
  StreamSubscription? _messageSubscription;

  // Getters
  String get driverId => _driverId;
  DriverStatus get driverStatus => _driverStatus;
  String get webSocketUrl => _webSocketUrl;
  List<Order> get orders => List.unmodifiable(_orders);
  bool get isConnected => _wsService.isConnected;
  bool get isDriverRegistered => _isDriverRegistered;
  String get vehicleType => _vehicleType;
  String get vehiclePlate => _vehiclePlate;
  bool get isVerified => _isVerified;

  /// Initialize driver service
  Future<void> initialize() async {
    // Load saved settings
    await _loadSettings();
    
    // Setup WebSocket message listener
    _setupMessageListener();
  }

  /// Load saved settings from Hive
  Future<void> _loadSettings() async {
    final box = await Hive.openBox(HiveConstants.driverSettingsBox);
    _driverId = box.get(HiveConstants.driverIdKey, defaultValue: HiveConstants.defaultDriverId);
    _webSocketUrl = box.get(HiveConstants.websocketUrlKey, defaultValue: AppConfig.defaultWebSocketUrl);
    final statusIndex = box.get(HiveConstants.driverStatusKey, defaultValue: 0);
    _driverStatus = DriverStatus.values[statusIndex];

    notifyListeners();
  }

  /// Save settings to Hive
  Future<void> _saveSettings() async {
    final box = await Hive.openBox(HiveConstants.driverSettingsBox);
    await box.put(HiveConstants.driverIdKey, _driverId);
    await box.put(HiveConstants.websocketUrlKey, _webSocketUrl);
    await box.put(HiveConstants.driverStatusKey, _driverStatus.index);
  }

  /// Update driver ID
  Future<void> setDriverId(String id) async {
    _driverId = id;
    await _saveSettings();
    notifyListeners();
  }

  /// Update WebSocket URL
  Future<void> setWebSocketUrl(String url) async {
    _webSocketUrl = url;
    await _saveSettings();
    notifyListeners();
  }

  /// Update driver status
  Future<void> setDriverStatus(DriverStatus status) async {
    _driverStatus = status;
    await _saveSettings();
    notifyListeners();
  }

  /// Connect to WebSocket server
  Future<bool> connect() async {
    if (_webSocketUrl.isEmpty) {
      Logger.instance.warning('WebSocket URL is not set');
      return false;
    }

    _wsService.enableAutoReconnect();
    return await _wsService.connect(_webSocketUrl);
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _wsService.disconnect();
  }

  /// Setup WebSocket message listener
  void _setupMessageListener() {
    _messageSubscription = _wsService.messageStream.listen((message) {
      _handleWebSocketMessage(message);
    });
  }

  /// Handle incoming WebSocket messages
  void _handleWebSocketMessage(WebSocketMessage message) {
    debugPrint('Received message: ${message.intent}');

    switch (message.intent) {
      case IntentConstants.newOrderAvailable:
        _handleNewOrder(message.data);
        break;
      case IntentConstants.bidAccepted:
        _handleBidAccepted(message.data);
        break;
      case IntentConstants.bidRejected:
        _handleBidRejected(message.data);
        break;
      case IntentConstants.auth:
        _handleAuth(message.data);
        break;
      case IntentConstants.driverRegistered:
        _handleDriverRegistered(message.data);
        break;
      case IntentConstants.driverStatus:
        _handleDriverStatus(message.data);
        break;
      case IntentConstants.pong:
        debugPrint('Pong received from server');
        break;
      case IntentConstants.error:
        debugPrint('Error from server: ${message.data}');
        break;
      default:
        debugPrint('Unknown intent: ${message.intent}');
    }
  }

  /// Handle auth response
  void _handleAuth(dynamic data) {
    if (data is Map<String, dynamic>) {
      final user = data['user'] as Map<String, dynamic>?;
      if (user != null) {
        _isDriverRegistered = user['role'] == 'driver';
        _isVerified = user['isVerified'] ?? false;
        _vehicleType = user['vehicleType'] ?? '';
        _vehiclePlate = user['vehiclePlate'] ?? '';
        debugPrint('Auth response: isDriver=$_isDriverRegistered, verified=$_isVerified');
        notifyListeners();
      }
    }
  }

  /// Handle driver registration success
  void _handleDriverRegistered(dynamic data) {
    if (data is Map<String, dynamic>) {
      final user = data['user'] as Map<String, dynamic>?;
      if (user != null) {
        _isDriverRegistered = true;
        _isVerified = true;
        _vehicleType = user['vehicleType'] ?? '';
        _vehiclePlate = user['vehiclePlate'] ?? '';
        debugPrint('Driver registration successful');
        notifyListeners();
      }
    }
  }

  /// Handle driver status check response
  void _handleDriverStatus(dynamic data) {
    if (data is Map<String, dynamic>) {
      _isDriverRegistered = data['isDriver'] as bool? ?? false;
      _isVerified = data['isVerified'] as bool? ?? false;
      _vehicleType = data['vehicleType'] as String? ?? '';
      _vehiclePlate = data['vehiclePlate'] as String? ?? '';
      debugPrint('Driver status: isDriver=$_isDriverRegistered, verified=$_isVerified');
      notifyListeners();
    }
  }

  /// Handle new order available
  void _handleNewOrder(dynamic data) {
    if (data is Map<String, dynamic>) {
      final order = Order.fromJson(data);
      _orders.add(order);
      debugPrint('New order received: #${order.id}');
      notifyListeners();
    }
  }

  /// Handle bid accepted
  void _handleBidAccepted(dynamic data) {
    if (data is Map<String, dynamic>) {
      final orderId = data[IntentConstants.orderIdKey] as int?;
      if (orderId != null) {
        final orderIndex = _orders.indexWhere((o) => o.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = _orders[orderIndex].copyWith(
            status: APIConstants.orderStatusAccepted,
            bidStatus: APIConstants.bidStatusAccepted,
          );
          debugPrint('Bid accepted for order #$orderId');
          notifyListeners();
        }
      }
    }
  }

  /// Handle bid rejected
  void _handleBidRejected(dynamic data) {
    if (data is Map<String, dynamic>) {
      final orderId = data[IntentConstants.orderIdKey] as int?;
      if (orderId != null) {
        final orderIndex = _orders.indexWhere((o) => o.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = _orders[orderIndex].copyWith(
            bidStatus: APIConstants.bidStatusRejected,
          );
          debugPrint('Bid rejected for order #$orderId');
          notifyListeners();
        }
      }
    }
  }

  /// Submit bid for an order
  void submitBid({
    required int orderId,
    required double bidPrice,
    required int etaMinutes,
  }) {
    if (_driverId.isEmpty) {
      debugPrint('Driver ID is not set');
      return;
    }

    _wsService.sendSubmitBid(
      orderId: orderId,
      driverId: _driverId,
      bidPrice: bidPrice,
      etaMinutes: etaMinutes,
    );

    // Update local state
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        driverId: _driverId,
        bidPrice: bidPrice,
        bidStatus: 'pending',
      );
      notifyListeners();
    }
  }

  /// Send driver arrival notification
  void sendArrival(int orderId) {
    if (_driverId.isEmpty) {
      debugPrint('Driver ID is not set');
      return;
    }

    _wsService.sendDriverArrived(
      orderId: orderId,
      driverId: _driverId,
    );

    // Update local state
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        status: APIConstants.orderStatusDriverArrived,
      );
      notifyListeners();
    }
  }

  /// Send trip completion notification
  void sendTripCompletion(int orderId) {
    if (_driverId.isEmpty) {
      debugPrint('Driver ID is not set');
      return;
    }

    _wsService.sendCompleteTrip(
      orderId: orderId,
      driverId: _driverId,
    );

    // Update local state
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        status: APIConstants.orderStatusCompleted,
      );
      notifyListeners();
    }
  }

  /// Decline/remove an order from the list
  void declineOrder(int orderId) {
    _orders.removeWhere((o) => o.id == orderId);
    debugPrint('Order #$orderId declined/removed');
    notifyListeners();
  }

  /// Clear all orders
  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  /// Get order by ID
  Order? getOrderById(int orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  /// Get pending orders (orders that can accept bids)
  List<Order> getPendingOrders() {
    return _orders.where((o) => o.status == APIConstants.orderStatusPending).toList();
  }

  /// Get accepted orders
  List<Order> getAcceptedOrders() {
    return _orders.where((o) => o.status == APIConstants.orderStatusAccepted || o.status == APIConstants.orderStatusDriverArrived).toList();
  }

  /// Send auth message to backend
  Future<void> sendAuth() async {
    final user = AuthService().currentUser;
    if (user == null) {
      debugPrint('No authenticated user');
      return;
    }

    final authData = {
      IntentConstants.intentKey: IntentConstants.auth,
      IntentConstants.dataKey: {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
      },
      IntentConstants.timestampKey: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };

    _wsService.sendJson(authData);
    debugPrint('Auth sent to server');
  }

  /// Check driver registration status
  Future<void> checkDriverStatus() async {
    final user = AuthService().currentUser;
    if (user == null) {
      debugPrint('No authenticated user');
      return;
    }

    final statusData = {
      IntentConstants.intentKey: IntentConstants.checkDriverStatus,
      IntentConstants.dataKey: {
        'uid': user.uid,
      },
      IntentConstants.timestampKey: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };

    _wsService.sendJson(statusData);
    debugPrint('Driver status check sent');
  }

  /// Register as a driver
  Future<bool> registerDriver({
    required String vehicleType,
    required String vehiclePlate,
  }) async {
    final user = AuthService().currentUser;
    if (user == null) {
      debugPrint('No authenticated user');
      return false;
    }

    final regData = {
      IntentConstants.intentKey: IntentConstants.driverRegistration,
      IntentConstants.dataKey: {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'vehicleType': vehicleType,
        'vehiclePlate': vehiclePlate,
      },
      IntentConstants.timestampKey: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };

    _wsService.sendJson(regData);
    debugPrint('Driver registration sent');

    // Wait for response (handled in _handleDriverRegistered)
    return true;
  }

  /// Dispose resources
  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
