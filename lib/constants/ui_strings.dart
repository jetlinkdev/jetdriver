/// UI string constants for the app
class UIStrings {
  // App names
  static const String appName = 'Jetlink Driver';

  // Home screen
  static const String homeTab = 'Home';
  static const String earningsTab = 'Earnings';
  static const String profileTab = 'Profile';
  static const String availableOrders = 'Available Orders';
  static const String noOrdersAvailable = 'No orders available';
  static const String waitingForNewOrders = 'Waiting for new orders...\nGo online to start receiving orders';
  static const String orderCount = 'order';
  static const String ordersCount = 'orders';

  // Earnings screen
  static const String earningsTitle = 'Earnings';
  static const String earningsSubtitle = 'Track your income and trip history';
  static const String todaysSummary = 'Today\'s Summary';
  static const String weeklySummary = 'Weekly Summary';
  static const String payoutInformation = 'Payout Information';
  static const String comingSoon = 'Coming soon';

  // Profile screen
  static const String profileTitle = 'Profile';
  static const String profileSubtitle = 'Manage your account and settings';
  static const String driverSettings = 'Driver Settings';
  static const String driverSettingsSubtitle = 'Manage your driver profile';
  static const String notifications = 'Notifications';
  static const String helpSupport = 'Help & Support';
  static const String logout = 'Logout';

  // Connection status
  static const String connected = 'Connected';
  static const String connecting = 'Connecting...';
  static const String disconnected = 'Disconnected';
  static const String connectionError = 'Error';
  static const String ping = 'Ping';

  // Driver status
  static const String youAreOnline = 'You\'re Online';
  static const String youAreOffline = 'You\'re Offline';
  static const String canReceiveOrders = 'You can receive orders';
  static const String wontReceiveOrders = 'You won\'t receive orders';
  static const String driverIsNowOnline = 'Driver is now online';
  static const String driverIsNowOffline = 'Driver is now offline';

  // Order actions
  static const String decline = 'Decline';
  static const String submitBid = 'Submit Bid';
  static const String imHere = "I'm Here";
  static const String completeTrip = 'Complete Trip';
  static const String bidSubmitted = 'Bid submitted - Waiting for acceptance';
  static const String tripCompleted = '✓ Trip completed';

  // Order statuses
  static const String statusAvailable = 'Available';
  static const String statusAccepted = 'Accepted';
  static const String statusArrived = 'Arrived';
  static const String statusCompleted = 'Completed';
  static const String bidPending = 'Bid Pending';

  // Bid bottom sheet
  static const String bidBottomSheetTitle = 'Submit Bid';
  static const String yourBidPrice = 'Your Bid Price (IDR)';
  static const String enterBidAmount = 'Enter your bid amount';
  static const String estimatedArrivalTime = 'Estimated Arrival Time (minutes)';
  static const String enterMinutes = 'Enter minutes until arrival at pickup';
  static const String minutes = 'min';
  static const String baseFare = 'Base Fare';

  // Validation messages
  static const String pleaseEnterBidAmount = 'Please enter a bid amount';
  static const String pleaseEnterValidAmount = 'Please enter a valid amount';
  static const String pleaseEnterEstimatedTime = 'Please enter estimated time';
  static const String pleaseEnterValidMinutes = 'Please enter valid minutes';

  // Settings screen
  static const String settingsTitle = 'Settings';
  static const String driverSettingsSection = 'Driver Settings';
  static const String connectionSettings = 'Connection Settings';
  static const String account = 'Account';
  static const String driverId = 'Driver ID';
  static const String status = 'Status';
  static const String websocketUrl = 'WebSocket URL';
  static const String saveSettings = 'Save Settings';
  static const String settingsSavedSuccessfully = 'Settings saved successfully';
  static const String logoutTitle = 'Logout';
  static const String logoutConfirmation = 'Are you sure you want to logout?';
  static const String cancel = 'Cancel';
  static const String signOutFromAccount = 'Sign out from your account';

  // Welcome dialog
  static const String signInToStart = 'Sign in to start accepting rides';
  static const String signInWithGoogle = 'Sign in with Google';
  static const String termsAndConditions = 'By signing in, you agree to our Terms of Service and Privacy Policy';

  // Logger messages
  static const String userLoggedIn = 'User logged in';
  static const String userLoggedOut = 'User logged out';
  static const String loginFailed = 'Login failed';
  static const String pingSentToServer = 'Ping sent to server';
  static const String bidSubmittedLog = 'Bid submitted: Rp ';
  static const String etaMinutes = ' ETA: ';
  static const String min = ' min';
  static const String orderDeclined = 'Order #';
  static const String declined = ' declined';
  static const String arrivalNotificationSent = 'Arrival notification sent for Order #';
  static const String tripCompletionSent = 'Trip completion sent for Order #';

  // Time and payment
  static const String payment = 'Payment';
  static const String notes = 'Notes';
  static const String time = 'Time';
  static const String now = 'Now';
}
