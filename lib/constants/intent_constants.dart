/// WebSocket intent constants for communication with backend
class IntentConstants {
  // Client -> Server intents
  static const String ping = 'ping';
  static const String submitBid = 'submit_bid';
  static const String driverArrived = 'driver_arrived';
  static const String completeTrip = 'complete_trip';
  static const String auth = 'auth';
  static const String completeProfile = 'complete_profile';
  static const String driverRegistration = 'driver_registration';
  static const String checkDriverStatus = 'check_driver_status';
  static const String updateDriverStatus = 'update_driver_status';
  static const String getMyBids = 'get_my_bids';

  // Server -> Client intents
  static const String pong = 'pong';
  static const String newOrderAvailable = 'new_order_available';
  static const String bidAccepted = 'bid_accepted';
  static const String bidRejected = 'bid_rejected';
  static const String orderCancelled = 'order_cancelled';
  static const String tripCompleted = 'trip_completed';
  static const String myBids = 'my_bids';
  static const String driverRegistered = 'driver_registered';
  static const String driverStatus = 'driver_status';
  static const String error = 'error';
  // Additional server -> client intents
  static const String authProfileNeeded = 'auth_profile_needed';
  static const String orderStateSync = 'order_state_sync';
  static const String existingOrderFound = 'existing_order_found';
  static const String newBidReceived = 'new_bid_received';
  static const String driverArrivedResponse = 'driver_arrived';

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
