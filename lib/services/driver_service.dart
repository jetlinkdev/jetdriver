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
  String _userRole = 'customer'; // Store user role (customer/driver)
  String _phoneNumber = ''; // Store phone number

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
  String get userRole => _userRole;
  String get phoneNumber => _phoneNumber;

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

  /// Send JSON message via WebSocket
  void sendJson(Map<String, dynamic> json) {
    _wsService.sendJson(json);
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
      case IntentConstants.orderCancelled:
        _handleOrderCancelled(message.data);
        break;
      case IntentConstants.tripCompleted:
        _handleTripCompleted(message.data);
        break;
      case IntentConstants.myBids:
        _handleMyBids(message.data);
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
      // NEW: Handle additional server responses
      case IntentConstants.authProfileNeeded:
        _handleAuthProfileNeeded(message.data);
        break;
      case IntentConstants.orderStateSync:
        _handleOrderStateSync(message.data);
        break;
      case IntentConstants.existingOrderFound:
        _handleExistingOrderFound(message.data);
        break;
      case IntentConstants.newBidReceived:
        _handleNewBidReceived(message.data);
        break;
      case IntentConstants.driverArrivedResponse:
        _handleDriverArrivedResponse(message.data);
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
        _userRole = user['role'] ?? 'customer';
        _isVerified = user['isVerified'] ?? false;
        _vehicleType = user['vehicleType'] ?? '';
        _vehiclePlate = user['vehiclePlate'] ?? '';
        _phoneNumber = user['phoneNumber'] ?? '';
        debugPrint('Auth response: role=$_userRole, isDriver=$_isDriverRegistered, verified=$_isVerified, phone=$_phoneNumber');
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
      _userRole = data['isDriver'] == true ? 'driver' : 'customer';
      debugPrint('Driver status: isDriver=$_isDriverRegistered, verified=$_isVerified, role=$_userRole');
      notifyListeners();
    }
  }

  /// Handle auth_profile_needed response - user needs to complete profile
  void _handleAuthProfileNeeded(dynamic data) {
    debugPrint('Auth profile needed: ${data?['message']}');
    // This intent indicates the user needs to complete their profile
    // The UI should show a dialog to collect email, displayName, phoneNumber
    // For now, we just log it - the home_screen will handle showing the dialog
    notifyListeners();
  }

  /// Handle order_state_sync - sync order state after reconnect
  void _handleOrderStateSync(dynamic data) {
    if (data is Map<String, dynamic>) {
      debugPrint('Order state synced: ${data['ui_state']} for order #${data['order_id']}');
      
      // Sync order data from server
      final orderId = data['order_id'] as int?;
      if (orderId != null) {
        // Check if order already exists
        final existingIndex = _orders.indexWhere((o) => o.id == orderId);
        
        if (existingIndex != -1) {
          // Update existing order with latest data
          _orders[existingIndex] = _orders[existingIndex].copyWith(
            status: data['status'] as String? ?? _orders[existingIndex].status,
            bidPrice: (data['bid_price'] as num?)?.toDouble() ?? _orders[existingIndex].bidPrice,
            estimatedArrivalTime: data['estimated_arrival_time'] != null
                ? DateTime.fromMillisecondsSinceEpoch((data['estimated_arrival_time'] as int) * 1000)
                : _orders[existingIndex].estimatedArrivalTime,
          );
        } else {
          // Create new order from sync data
          final order = Order(
            id: orderId,
            userId: data['user_id'] as String? ?? '',
            driverId: data['driver_id'] as String?,
            pickup: data['pickup'] as String? ?? '',
            pickupLatitude: (data['pickup_latitude'] as num?)?.toDouble() ?? 0.0,
            pickupLongitude: (data['pickup_longitude'] as num?)?.toDouble() ?? 0.0,
            destination: data['destination'] as String? ?? '',
            destinationLatitude: (data['destination_latitude'] as num?)?.toDouble() ?? 0.0,
            destinationLongitude: (data['destination_longitude'] as num?)?.toDouble() ?? 0.0,
            notes: data['notes'] as String? ?? '',
            payment: data['payment'] as String? ?? APIConstants.paymentCash,
            status: data['status'] as String? ?? APIConstants.orderStatusPending,
            fare: (data['fare'] as num?)?.toDouble() ?? 0.0,
            bidPrice: (data['bid_price'] as num?)?.toDouble(),
            estimatedArrivalTime: data['estimated_arrival_time'] != null
                ? DateTime.fromMillisecondsSinceEpoch((data['estimated_arrival_time'] as int) * 1000)
                : null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          _orders.add(order);
        }
        
        debugPrint('Order #${orderId} synced with status: ${data['ui_state']}');
        notifyListeners();
      }
      
      // Handle existing bids from server
      final bids = data['bids'] as List?;
      if (bids != null) {
        debugPrint('Synced ${bids.length} existing bids');
        for (var bidData in bids) {
          if (bidData is Map<String, dynamic>) {
            final bidOrderId = bidData['order_id'] as int?;
            if (bidOrderId != null) {
              final orderIndex = _orders.indexWhere((o) => o.id == bidOrderId);
              if (orderIndex != -1) {
                _orders[orderIndex] = _orders[orderIndex].copyWith(
                  driverId: bidData['driver_id'] as String?,
                  bidPrice: (bidData['bid_price'] as num?)?.toDouble(),
                  bidStatus: 'pending',
                );
              }
            }
          }
        }
        notifyListeners();
      }
    }
  }

  /// Handle existing_order_found - user already has active order
  void _handleExistingOrderFound(dynamic data) {
    if (data is Map<String, dynamic>) {
      final orderId = data['order_id'] as int?;
      final uiState = data['ui_state'] as String?;
      debugPrint('Existing order found: #${orderId} with state: ${uiState}');
      
      if (orderId != null) {
        // Update or create order in local state
        final existingIndex = _orders.indexWhere((o) => o.id == orderId);
        if (existingIndex != -1) {
          _orders[existingIndex] = _orders[existingIndex].copyWith(
            status: data['status'] as String? ?? _orders[existingIndex].status,
          );
        }
        notifyListeners();
      }
    }
  }

  /// Handle new_bid_received - notification when a new bid is placed
  void _handleNewBidReceived(dynamic data) {
    if (data is Map<String, dynamic>) {
      debugPrint('New bid received: ${data['driver_id']} for order #${data['order_id']}');
      // This is mainly for customer app, but driver can log it for awareness
      // In a competitive scenario, drivers might want to know about other bids
    }
  }

  /// Handle driver_arrived response - confirmation that driver arrival was recorded
  void _handleDriverArrivedResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      final orderId = data['order_id'] as int?;
      final status = data['status'] as String?;
      debugPrint('Driver arrived confirmed for order #${orderId}: ${status}');
      
      if (orderId != null) {
        final orderIndex = _orders.indexWhere((o) => o.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = _orders[orderIndex].copyWith(
            status: APIConstants.orderStatusDriverArrived,
          );
          notifyListeners();
        }
      }
    }
  }

  /// Handle new order available
  void _handleNewOrder(dynamic data) {
    if (data is Map<String, dynamic>) {
      final order = Order.fromJson(data);
      
      // Check if order already exists to prevent duplication
      final existingIndex = _orders.indexWhere((o) => o.id == order.id);
      if (existingIndex != -1) {
        // Update existing order
        _orders[existingIndex] = order;
        debugPrint('Order #${order.id} updated');
      } else {
        // Add new order
        _orders.add(order);
        debugPrint('New order received: #${order.id}');
      }
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

  /// Handle order cancelled
  void _handleOrderCancelled(dynamic data) {
    if (data is Map<String, dynamic>) {
      final orderId = data['order_id'] as int?;
      if (orderId != null) {
        final orderIndex = _orders.indexWhere((o) => o.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = _orders[orderIndex].copyWith(
            status: APIConstants.orderStatusCancelled,
          );
          debugPrint('Order #$orderId cancelled');
          notifyListeners();
        }
      }
    }
  }

  /// Handle trip completed
  void _handleTripCompleted(dynamic data) {
    if (data is Map<String, dynamic>) {
      final orderId = data['order_id'] as int?;
      if (orderId != null) {
        final orderIndex = _orders.indexWhere((o) => o.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = _orders[orderIndex].copyWith(
            status: APIConstants.orderStatusCompleted,
          );
          debugPrint('Trip #$orderId completed');
          notifyListeners();
        }
      }
    }
  }

  /// Handle my bids response
  void _handleMyBids(dynamic data) {
    if (data is Map<String, dynamic>) {
      final bids = data['bids'] as List?;
      if (bids != null) {
        debugPrint('Received ${bids.length} existing bids');
        
        // Process each bid and update orders
        for (var bidData in bids) {
          if (bidData is Map<String, dynamic>) {
            final order = Order.fromJson(bidData);
            
            // Check if order already exists
            final existingIndex = _orders.indexWhere((o) => o.id == order.id);
            if (existingIndex != -1) {
              // Update existing order with bid info
              _orders[existingIndex] = _orders[existingIndex].copyWith(
                driverId: order.driverId,
                bidPrice: order.bidPrice,
                bidStatus: 'pending',
              );
            } else {
              // Add new order
              _orders.add(order.copyWith(bidStatus: 'pending'));
            }
          }
        }
        notifyListeners();
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
        'phoneNumber': _phoneNumber, // Include phone number if available
      },
      IntentConstants.timestampKey: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };

    _wsService.sendJson(authData);
    debugPrint('Auth sent to server');

    // Request existing bids after auth
    Future.delayed(const Duration(milliseconds: 500), () {
      _wsService.sendGetMyBids();
      debugPrint('Get my bids request sent');
    });
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
    String? phoneNumber,
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
        'phoneNumber': phoneNumber ?? _phoneNumber, // Use provided or stored phone number
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
