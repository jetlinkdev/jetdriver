/// API and backend-related constants
class APIConstants {
  // Order statuses
  static const String orderStatusPending = 'pending';
  static const String orderStatusAccepted = 'accepted';
  static const String orderStatusDriverArrived = 'driver_arrived';
  static const String orderStatusInProgress = 'in_progress';
  static const String orderStatusCompleted = 'completed';
  static const String orderStatusCancelled = 'cancelled';

  // Bid statuses
  static const String bidStatusPending = 'pending';
  static const String bidStatusAccepted = 'accepted';
  static const String bidStatusRejected = 'rejected';

  // Payment methods
  static const String paymentCash = 'Cash';

  // Driver ID prefix
  static const String driverIdPrefix = 'driver_';

  // Order JSON keys
  static const String orderIdKey = 'id';
  static const String orderUserIdKey = 'userId';
  static const String orderDriverIdKey = 'driverId';
  static const String orderPickupKey = 'pickup';
  static const String orderPickupLatitudeKey = 'pickupLatitude';
  static const String orderPickupLongitudeKey = 'pickupLongitude';
  static const String orderDestinationKey = 'destination';
  static const String orderDestinationLatitudeKey = 'destinationLatitude';
  static const String orderDestinationLongitudeKey = 'destinationLongitude';
  static const String orderNotesKey = 'notes';
  static const String orderTimeKey = 'time';
  static const String orderPaymentKey = 'payment';
  static const String orderStatusKey = 'status';
  static const String orderFareKey = 'fare';
  static const String orderBidPriceKey = 'bidPrice';
  static const String orderEstimatedArrivalTimeKey = 'estimatedArrivalTime';
  static const String orderCreatedAtKey = 'createdAt';
  static const String orderUpdatedAtKey = 'updatedAt';
  static const String orderBidStatusKey = 'bidStatus';

  // Error response keys
  static const String errorKey = 'error';
  static const String errorMessageKey = 'message';
  static const String errorCodeKey = 'code';
}
