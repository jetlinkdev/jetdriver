import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/ui_strings.dart';
import '../models/order.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../utils/logger.dart';
import '../utils/helper.dart';
import '../widgets/order_card.dart';
import '../widgets/bid_bottom_sheet.dart';
import '../widgets/earnings_card.dart';
import '../routes/app_routes.dart';

/// Main home screen for driver app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _driverIdController = TextEditingController();
  final _wsUrlController = TextEditingController();
  final _logger = Logger.instance;
  final _driverService = DriverService.instance;
  final _authService = AuthService();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _driverService.initialize();
    setState(() {
      _driverIdController.text = _driverService.driverId;
      _wsUrlController.text = _driverService.webSocketUrl;
    });

    // User is already authenticated (checked by SplashScreen)
    // Connect to WebSocket and check driver status
    _initializeDriver();
  }

  Future<void> _initializeDriver() async {
    // Connect to WebSocket
    final connected = await _driverService.connect();
    if (connected && mounted) {
      // Send auth to backend
      await _driverService.sendAuth();

      // Check driver registration status after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _driverService.checkDriverStatus();
          _checkAndShowRegistrationDialog();
        }
      });
    }
  }

  void _checkAndShowRegistrationDialog() {
    // DEPRECATED: Registration now handled at WelcomeScreen
    // User should never reach here without being registered
    debugPrint('HomeScreen loaded: isDriverRegistered=${_driverService.isDriverRegistered}');
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    _logger.info(UIStrings.userLoggedOut);

    if (mounted) {
      // Navigate to welcome screen using named route
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
    }
  }

  void _showBidDialog(Order order) async {
    final result = await BidBottomSheet.show(context, order);
    if (result != null && mounted) {
      final bidPrice = result['bidPrice'] as double;
      final etaMinutes = result['etaMinutes'] as int;

      // Show loading dialog
      _showLoadingDialog('Submitting your bid...');

      final success = await _driverService.submitBid(
        orderId: order.id,
        bidPrice: bidPrice,
        etaMinutes: etaMinutes,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        if (success) {
          _logger.success('Bid accepted for order #${order.id}');
          UIHelper.showSnackBar(
            context,
            '🎉 Your bid was accepted!',
            backgroundColor: AppColors.primaryGreen,
          );
        } else {
          _logger.warning('Bid submitted but not accepted for order #${order.id}');
          UIHelper.showSnackBar(
            context,
            'Your bid has been submitted. Waiting for customer decision...',
            backgroundColor: AppColors.primaryBlue,
          );
        }
      }
    }
  }

  /// Navigate to trip map screen
  void _navigateToTripMap(Order order) {
    Navigator.of(context).pushNamed(AppRoutes.tripMap, arguments: order);
  }

  /// Show loading dialog with spinner
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        content: Row(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeclineConfirmation(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          UIStrings.decline,
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to decline this order?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(UIStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryRed),
            child: const Text(UIStrings.decline),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _driverService.declineOrder(order.id);
        _logger.warning(
          '${UIStrings.orderDeclined}${order.id}${UIStrings.declined}',
        );
      }
    });
  }

  void _showArrivalConfirmation(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Arrival Confirmation',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you have arrived at the pickup location for Order #${order.id}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(UIStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
            child: const Text(UIStrings.imHere),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _showLoadingDialog('Confirming arrival...');

      final success = await _driverService.sendArrival(order.id);

      if (mounted) Navigator.pop(context);

      if (success && mounted) {
        _logger.success('Arrival confirmed for order #${order.id}');
        UIHelper.showSnackBar(
          context,
          'Arrival confirmed!',
          backgroundColor: AppColors.primaryGreen,
        );
      } else if (mounted) {
        _logger.error('Failed to confirm arrival for order #${order.id}');
        UIHelper.showSnackBar(
          context,
          'Failed to confirm arrival',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  void _showCompleteConfirmation(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          UIStrings.completeTrip,
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to complete this trip for Order #${order.id}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(UIStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
            ),
            child: const Text(UIStrings.completeTrip),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _showLoadingDialog('Completing trip...');

      final success = await _driverService.sendTripCompletion(order.id);

      if (mounted) Navigator.pop(context);

      if (success && mounted) {
        _logger.success('Trip completed for order #${order.id}');
        UIHelper.showSnackBar(
          context,
          '🎉 Trip completed successfully!',
          backgroundColor: AppColors.primaryGreen,
        );
      } else if (mounted) {
        _logger.error('Failed to complete trip for order #${order.id}');
        UIHelper.showSnackBar(
          context,
          'Failed to complete trip',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  void _navigateToSettings() {
    Navigator.of(context).pushNamed(AppRoutes.settings);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _driverService,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: _selectedIndex == 0
              ? _buildHomeTab()
              : _selectedIndex == 1
              ? _buildEarningsTab()
              : _buildProfileTab(),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        // Header with connection status
        _buildHeader(),

        const SizedBox(height: 16),

        // Earnings Card
        const EarningsCard(),

        const SizedBox(height: 24),

        // Orders section
        Expanded(child: _buildOrdersList()),
      ],
    );
  }

  Widget _buildEarningsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            UIStrings.earningsTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            UIStrings.earningsSubtitle,
            style: TextStyle(fontSize: 14, color: Colors.white54),
          ),
          const SizedBox(height: 24),

          // Today's Summary Card
          const EarningsCard(),

          const SizedBox(height: 24),

          // Weekly Summary (placeholder)
          _buildWeeklySummaryCard(),

          const SizedBox(height: 24),

          // Payout Info (placeholder)
          _buildPayoutInfoCard(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            UIStrings.profileTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            UIStrings.profileSubtitle,
            style: TextStyle(fontSize: 14, color: Colors.white54),
          ),
          const SizedBox(height: 24),

          // Profile Header
          Consumer<DriverService>(
            builder: (context, service, child) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF4CAF50).withValues(alpha: 0.2),
                      const Color(0xFF4CAF50).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4CAF50),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.string(
                          '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="white"><path d="M18.92 6.01C18.72 5.42 18.16 5 17.5 5h-11c-.66 0-1.22.42-1.42 1.01L3 12v8c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-1h12v1c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-8l-2.08-5.99zM6.5 16c-.83 0-1.5-.67-1.5-1.5S5.67 13 6.5 13s1.5.67 1.5 1.5S7.33 16 6.5 16zm11 0c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zM5 11l1.5-4.5h11L19 11H5z"/></svg>''',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.driverId,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  service.driverStatus != DriverStatus.offline
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              service.driverStatus != DriverStatus.offline
                                  ? service.driverStatus.name.toUpperCase()
                                  : 'OFFLINE',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Settings Menu
          _buildProfileMenuItem(
            icon: Icons.person_outline,
            title: UIStrings.driverSettings,
            subtitle: UIStrings.driverSettingsSubtitle,
            onTap: _navigateToSettings,
          ),

          const SizedBox(height: 8),

          _buildProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: UIStrings.notifications,
            subtitle: UIStrings.comingSoon,
            enabled: false,
          ),

          const SizedBox(height: 8),

          _buildProfileMenuItem(
            icon: Icons.help_outline,
            title: UIStrings.helpSupport,
            subtitle: UIStrings.comingSoon,
            enabled: false,
          ),

          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                UIStrings.logout,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteOpacity5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                UIStrings.weeklySummary,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            UIStrings.comingSoon,
            style: TextStyle(fontSize: 14, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteOpacity5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                UIStrings.payoutInformation,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            UIStrings.comingSoon,
            style: TextStyle(fontSize: 14, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteOpacity5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: enabled ? AppColors.primaryGreen : Colors.white54,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: enabled ? Colors.white : Colors.white54,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
        trailing: enabled
            ? const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              )
            : null,
        onTap: enabled ? onTap : null,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: UIStrings.homeTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: UIStrings.earningsTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: UIStrings.profileTab,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            UIStrings.appName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          Consumer<DriverService>(
            builder: (context, service, child) {
              final isOnline = service.driverStatus != DriverStatus.offline;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Online/Offline Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOnline ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOnline ? service.driverStatus.name.toUpperCase() : 'OFFLINE',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Online/Offline Switch
                  Switch(
                    value: isOnline,
                    onChanged: (value) {
                      final newStatus = value
                          ? DriverStatus.available
                          : DriverStatus.offline;
                      service.setDriverStatus(newStatus);
                      _logger.info(
                        value ? 'Driver is now online' : 'Driver is now offline',
                      );
                      if (mounted) {
                        UIHelper.showSnackBar(
                          context,
                          value ? 'You are now online' : 'You are now offline',
                          backgroundColor: value ? AppColors.primaryGreen : Colors.red,
                        );
                      }
                    },
                    activeThumbColor: AppColors.primaryGreen,
                    activeTrackColor: Colors.green.shade200,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return Consumer<DriverService>(
      builder: (context, service, child) {
        final orders = service.orders;

        if (orders.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    UIStrings.availableOrders,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${orders.length} ${orders.length != 1 ? UIStrings.ordersCount : UIStrings.orderCount}',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return OrderCard(
                    order: order,
                    onBidPressed: order.canBid
                        ? () => _showBidDialog(order)
                        : null,
                    onDeclinePressed: order.canBid
                        ? () => _showDeclineConfirmation(order)
                        : null,
                    onArrivePressed: order.isAccepted
                        ? () => _showArrivalConfirmation(order)
                        : null,
                    onCompletePressed: order.hasArrived
                        ? () => _showCompleteConfirmation(order)
                        : null,
                    onViewTripPressed: () => _navigateToTripMap(order),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox,
              size: 60,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            UIStrings.noOrdersAvailable,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            UIStrings.waitingForNewOrders,
            style: TextStyle(fontSize: 14, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _driverIdController.dispose();
    _wsUrlController.dispose();
    super.dispose();
  }
}
