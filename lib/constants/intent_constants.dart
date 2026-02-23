/// WebSocket intent constants for communication with backend
class IntentConstants {
  // Client -> Server intents
  static const String ping = 'ping';
  static const String submitBid = 'submit_bid';
  static const String driverArrived = 'driver_arrived';
  static const String completeTrip = 'complete_trip';
  static const String auth = 'auth';
  static const String driverRegistration = 'driver_registration';
  static const String checkDriverStatus = 'check_driver_status';

  // Server -> Client intents
  static const String pong = 'pong';
  static const String newOrderAvailable = 'new_order_available';
  static const String bidAccepted = 'bid_accepted';
  static const String bidRejected = 'bid_rejected';
  static const String driverRegistered = 'driver_registered';
  static const String driverStatus = 'driver_status';
  static const String error = 'error';

  // Intent data keys
  static const String intentKey = 'intent';
  static const String dataKey = 'data';
  static const String timestampKey = 'timestamp';
  static const String clientIdKey = 'clientId';

  // Bid data keys
  static const String orderIdKey = 'order_id';
  static const String driverIdKey = 'driver_id';
  static const String bidPriceKey = 'bid_price';
  static const String estimatedArrivalTimeKey = 'estimated_arrival_time';
}
