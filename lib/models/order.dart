import '../constants/api_constants.dart';

/// Order model representing a ride-hailing order from backend
class Order {
  final int id;
  final String userId;
  final String? driverId;
  final String pickup;
  final double pickupLatitude;
  final double pickupLongitude;
  final String destination;
  final double destinationLatitude;
  final double destinationLongitude;
  final String notes;
  final DateTime? time;
  final String payment;
  final String status; // pending, accepted, driver_arrived, in_progress, completed, cancelled
  final double fare;
  final double? bidPrice;
  final DateTime? estimatedArrivalTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Local state for UI (not from backend)
  final String? bidStatus; // pending, accepted, rejected (for tracking bid status locally)

  Order({
    required this.id,
    required this.userId,
    this.driverId,
    required this.pickup,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destination,
    required this.destinationLatitude,
    required this.destinationLongitude,
    this.notes = '',
    this.time,
    required this.payment,
    required this.status,
    this.fare = 0,
    this.bidPrice,
    this.estimatedArrivalTime,
    required this.createdAt,
    required this.updatedAt,
    this.bidStatus,
  });

  /// Create Order from JSON (WebSocket message)
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      userId: json['userId'] as String? ?? '',
      driverId: json['driverId'] as String?,
      pickup: json['pickup'] as String? ?? '',
      pickupLatitude: (json['pickupLatitude'] as num?)?.toDouble() ?? 0.0,
      pickupLongitude: (json['pickupLongitude'] as num?)?.toDouble() ?? 0.0,
      destination: json['destination'] as String? ?? '',
      destinationLatitude: (json['destinationLatitude'] as num?)?.toDouble() ?? 0.0,
      destinationLongitude: (json['destinationLongitude'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String? ?? '',
      time: json['time'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((json['time'] as int) * 1000) 
          : null,
      payment: json['payment'] as String? ?? APIConstants.paymentCash,
      status: json['status'] as String? ?? APIConstants.orderStatusPending,
      fare: (json['fare'] as num?)?.toDouble() ?? 0.0,
      bidPrice: (json['bidPrice'] as num?)?.toDouble(),
      estimatedArrivalTime: json['estimatedArrivalTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['estimatedArrivalTime'] as int) * 1000)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['createdAt'] as int) * 1000)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['updatedAt'] as int) * 1000)
          : DateTime.now(),
      bidStatus: json['bidStatus'] as String?,
    );
  }

  /// Convert Order to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'driverId': driverId,
      'pickup': pickup,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'destination': destination,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'notes': notes,
      'time': time != null ? time!.millisecondsSinceEpoch ~/ 1000 : null,
      'payment': payment,
      'status': status,
      'fare': fare,
      'bidPrice': bidPrice,
      'estimatedArrivalTime': estimatedArrivalTime != null 
          ? estimatedArrivalTime!.millisecondsSinceEpoch ~/ 1000 
          : null,
      'createdAt': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updatedAt': updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Create a copy of this Order with updated fields
  Order copyWith({
    int? id,
    String? userId,
    String? driverId,
    String? pickup,
    double? pickupLatitude,
    double? pickupLongitude,
    String? destination,
    double? destinationLatitude,
    double? destinationLongitude,
    String? notes,
    DateTime? time,
    String? payment,
    String? status,
    double? fare,
    double? bidPrice,
    DateTime? estimatedArrivalTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bidStatus,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      driverId: driverId ?? this.driverId,
      pickup: pickup ?? this.pickup,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      destination: destination ?? this.destination,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      notes: notes ?? this.notes,
      time: time ?? this.time,
      payment: payment ?? this.payment,
      status: status ?? this.status,
      fare: fare ?? this.fare,
      bidPrice: bidPrice ?? this.bidPrice,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bidStatus: bidStatus ?? this.bidStatus,
    );
  }

  /// Check if driver has already placed a bid on this order
  bool get hasBidded => driverId != null && bidPrice != null;

  /// Check if order is in a state that allows bidding
  bool get canBid => status == APIConstants.orderStatusPending && !hasBidded;

  /// Check if order is accepted (bid was accepted by user)
  bool get isAccepted => status == APIConstants.orderStatusAccepted;

  /// Check if driver has arrived at pickup location
  bool get hasArrived => status == APIConstants.orderStatusDriverArrived;

  /// Check if trip is completed
  bool get isCompleted => status == APIConstants.orderStatusCompleted;

  /// Check if order is cancelled
  bool get isCancelled => status == APIConstants.orderStatusCancelled;
}
