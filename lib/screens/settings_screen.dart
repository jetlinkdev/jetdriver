import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/ui_strings.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../utils/logger.dart';

/// Settings screen for driver app
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _driverService = DriverService.instance;
  final _authService = AuthService();
  final _logger = Logger.instance;

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          UIStrings.logoutTitle,
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          UIStrings.logoutConfirmation,
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
            child: const Text(UIStrings.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _authService.signOut();
      _logger.info(UIStrings.userLoggedOut);
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        title: const Text(
          UIStrings.settingsTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Status Section
              _buildSectionTitle('Driver Status'),
              const SizedBox(height: 16),
              _buildDriverStatusCard(),

              const SizedBox(height: 24),

              // Account Section
              _buildSectionTitle(UIStrings.account),
              const SizedBox(height: 16),
              _buildAccountCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildDriverStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteOpacity5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<DriverStatus>(
        initialValue: _driverService.driverStatus,
        dropdownColor: AppColors.cardBackground,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Your Status',
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: AppColors.whiteOpacity5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: const Icon(Icons.flag, color: Colors.white70),
        ),
        items: DriverStatus.values.map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(status.name.toUpperCase()),
          );
        }).toList(),
        onChanged: (DriverStatus? newValue) {
          if (newValue != null) {
            _driverService.setDriverStatus(newValue);
          }
        },
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteOpacity5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primaryGreen,
          child: Icon(Icons.logout, color: Colors.white),
        ),
        title: const Text(
          UIStrings.logout,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        subtitle: const Text(
          UIStrings.signOutFromAccount,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
        onTap: _handleLogout,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
