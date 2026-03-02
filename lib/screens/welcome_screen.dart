import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../constants/app_colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../utils/helper.dart';
import 'home_screen.dart';
import 'driver_registration_screen.dart';

/// Welcome screen for users to choose login or register
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  String _loadingMessage = 'Signing in...';

  final AuthService _authService = AuthService();
  final DriverService _driverService = DriverService.instance;
  final ApiService _apiService = ApiService.instance;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Signing in with Google...';
    });

    try {
      // Step 1: Firebase Authentication
      final userCredential = await _authService.signInWithGoogle();

      if (!mounted) return;

      if (userCredential != null) {
        setState(() {
          _loadingMessage = 'Checking driver status...';
        });

        // Step 2: Check driver status via REST API
        final driverStatus = await _apiService.checkDriverStatus();

        if (!mounted) return;

        // Step 3: Navigate based on driver status
        if (driverStatus != null && driverStatus['isDriver'] == true) {
          // Driver sudah terdaftar → langsung ke HomeScreen
          debugPrint('Driver registered, navigating to HomeScreen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          // Driver belum terdaftar → WAJIB ke DriverRegistrationScreen dulu
          debugPrint('Driver not registered, navigating to DriverRegistrationScreen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DriverRegistrationScreen()),
          );
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        // Show error dialog
        _showErrorDialog('Sign in failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show error using UIHelper instead of dialog
      UIHelper.showSnackBar(context, 'Sign in failed: ${e.toString()}', backgroundColor: AppColors.primaryRed);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Sign In Error',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(),

                          // Logo and Title Section
                          _buildHeader(),

                          const Spacer(),

                          // Buttons Section
                          _buildButtons(),

                          const Spacer(),

                          // Footer
                          _buildFooter(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _loadingMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please wait...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_taxi,
            size: 60,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 32),

        // App Name
        const Text(
          'Jetdriver',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Tagline
        Text(
          'Drive & Earn with Jetlink',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Google Sign In Button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleGoogleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[800],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google Logo
                    Image.network(
                      'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image fails to load
                        return const Icon(Icons.g_mobiledata, size: 24, color: Colors.grey);
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 16),

        // Terms and Conditions
        Text(
          'By continuing, you agree to our',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // TODO: Open Terms of Service
              },
              child: const Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryGreen,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Text(
              ' & ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: Open Privacy Policy
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryGreen,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(
          color: Colors.white.withOpacity(0.1),
        ),
        const SizedBox(height: 16),
        Text(
          'Version ${AppConfig.appVersion}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '© 2024 Jetlink. All rights reserved.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
