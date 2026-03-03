import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Earnings summary card widget
class EarningsCard extends StatelessWidget {
  final double todayEarnings;
  final int completedTrips;
  final Duration onlineDuration;

  const EarningsCard({
    super.key,
    this.todayEarnings = 0.0,
    this.completedTrips = 0,
    this.onlineDuration = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Today\'s Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.money,
                  label: 'Earnings',
                  value: currencyFormat.format(todayEarnings),
                  valueColor: const Color(0xFF4CAF50),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle,
                  label: 'Trips',
                  value: completedTrips.toString(),
                  valueColor: Colors.blue,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.access_time,
                  label: 'Online',
                  value: _formatDuration(onlineDuration),
                  valueColor: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: valueColor, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
