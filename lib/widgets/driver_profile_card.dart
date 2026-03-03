import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/driver_service.dart';

/// Driver profile card widget
class DriverProfileCard extends StatelessWidget {
  final String driverId;
  final DriverStatus status;
  final VoidCallback? onSettingsPressed;

  const DriverProfileCard({
    super.key,
    required this.driverId,
    required this.status,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Driver Avatar
          Container(
            width: 56,
            height: 56,
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
                width: 32,
                height: 32,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Driver Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverId,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                _buildStatusBadge(),
              ],
            ),
          ),
          // Settings Button
          IconButton(
            onPressed: onSettingsPressed,
            icon: const Icon(Icons.settings, color: Colors.white70),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isOnline = status != DriverStatus.offline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? status.name.toUpperCase() : 'OFFLINE',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
