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
  final _driverIdController = TextEditingController();
  final _wsUrlController = TextEditingController();
  final _driverService = DriverService.instance;
  final _authService = AuthService();
  final _logger = Logger.instance;

  @override
  void initState() {
    super.initState();
    _driverIdController.text = _driverService.driverId;
    _wsUrlController.text = _driverService.webSocketUrl;
  }

  void _saveSettings() {
    _driverService.setDriverId(_driverIdController.text);
    _driverService.setWebSocketUrl(_wsUrlController.text);
    _logger.info('Settings saved');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(UIStrings.settingsSavedSuccessfully),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

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
              // Driver Settings Section
              _buildSectionTitle(UIStrings.driverSettingsSection),
              const SizedBox(height: 16),
              _buildDriverSettingsCard(),

              const SizedBox(height: 24),

              // Connection Settings Section
              _buildSectionTitle(UIStrings.connectionSettings),
              const SizedBox(height: 16),
              _buildConnectionSettingsCard(),

              const SizedBox(height: 24),

              // Account Section
              _buildSectionTitle(UIStrings.account),
              const SizedBox(height: 16),
              _buildAccountCard(),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    UIStrings.saveSettings,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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

  Widget _buildDriverSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteOpacity5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          TextField(
            controller: _driverIdController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: UIStrings.driverId,
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: AppColors.whiteOpacity5,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.person, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (BuildContext context) {
              return DropdownButtonFormField<DriverStatus>(
                initialValue: _driverService.driverStatus,
                dropdownColor: AppColors.cardBackground,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: UIStrings.status,
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: AppColors.whiteOpacity5,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.info_outline, color: Colors.white70),
                ),
                items: DriverStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _driverService.setDriverStatus(value);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteOpacity5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _wsUrlController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: UIStrings.websocketUrl,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: AppColors.whiteOpacity5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: const Icon(Icons.cloud, color: Colors.white70),
        ),
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
    _driverIdController.dispose();
    _wsUrlController.dispose();
    super.dispose();
  }
}
