import 'package:flutter/material.dart';
import '../services/driver_service.dart';

/// Online/Offline toggle widget for driver status
class OnlineToggle extends StatelessWidget {
  final DriverStatus currentStatus;
  final ValueChanged<DriverStatus> onStatusChanged;

  const OnlineToggle({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  bool get isOnline => currentStatus != DriverStatus.offline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOnline
              ? [
                  const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  const Color(0xFF4CAF50).withValues(alpha: 0.05),
                ]
              : [
                  Colors.red.withValues(alpha: 0.2),
                  Colors.red.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOnline ? const Color(0xFF4CAF50) : Colors.red,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOnline ? 'You\'re Online' : 'You\'re Offline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isOnline ? const Color(0xFF4CAF50) : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isOnline
                    ? 'You can receive orders'
                    : 'You won\'t receive orders',
                style: TextStyle(
                  fontSize: 12,
                  color: isOnline ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
            ],
          ),
          // Toggle Switch
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? const Color(0xFF4CAF50) : Colors.red,
              boxShadow: [
                BoxShadow(
                  color: (isOnline ? const Color(0xFF4CAF50) : Colors.red)
                      .withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Switch(
              value: isOnline,
              onChanged: (value) {
                onStatusChanged(
                  value ? DriverStatus.available : DriverStatus.offline,
                );
              },
              activeThumbColor: const Color(0xFF4CAF50),
              activeTrackColor: Colors.green.shade200,
            ),
          ),
        ],
      ),
    );
  }
}
