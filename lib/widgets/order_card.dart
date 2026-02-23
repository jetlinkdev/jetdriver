import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/order.dart';

/// Order card widget for displaying order information
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onBidPressed;
  final VoidCallback? onDeclinePressed;
  final VoidCallback? onArrivePressed;
  final VoidCallback? onCompletePressed;
  final bool isBidSubmitted;

  const OrderCard({
    super.key,
    required this.order,
    this.onBidPressed,
    this.onDeclinePressed,
    this.onArrivePressed,
    this.onCompletePressed,
    this.isBidSubmitted = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final fareText = currencyFormat.format(order.fare);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardGreyGradientStart,
              AppColors.cardGreyGradientEnd,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with order ID and fare
            _buildHeader(fareText),
            
            // Route visualization
            _buildRoute(),
            
            // Order details
            _buildDetails(),
            
            // Action buttons
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String fareText) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${order.id}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fareText,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    String statusText;
    Color statusColor;

    if (order.status == 'accepted') {
      statusText = 'Accepted';
      statusColor = Colors.green;
    } else if (order.status == 'driver_arrived') {
      statusText = 'Arrived';
      statusColor = Colors.blue;
    } else if (order.status == 'completed') {
      statusText = 'Completed';
      statusColor = Colors.grey;
    } else if (order.bidStatus == 'pending') {
      statusText = 'Bid Pending';
      statusColor = Colors.orange;
    } else {
      statusText = 'Available';
      statusColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRoute() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route dots and line
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 20,
                color: Colors.white30,
              ),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4444),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Location texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.pickup,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  '↓',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.destination,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.payment,
            label: 'Payment',
            value: order.payment,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.note,
            label: 'Notes',
            value: order.notes.isEmpty ? '-' : order.notes,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.access_time,
            label: 'Time',
            value: order.time != null
                ? '${order.time!.hour.toString().padLeft(2, '0')}:${order.time!.minute.toString().padLeft(2, '0')}'
                : 'Now',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white54,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    // Check order status and show appropriate actions
    if (order.status == 'completed') {
      return _buildCompletedStatus();
    }

    if (order.status == 'driver_arrived') {
      return _buildArrivedActions();
    }

    if (order.status == 'accepted') {
      return _buildAcceptedStatus();
    }

    if (order.bidStatus == 'pending' || order.driverId != null) {
      return _buildBidPendingStatus();
    }

    return _buildBidActions();
  }

  Widget _buildBidActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (onDeclinePressed != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDeclinePressed,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Decline'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          if (onDeclinePressed != null) const SizedBox(width: 8),
          if (onBidPressed != null)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onBidPressed,
                icon: const Icon(Icons.attach_money, size: 18),
                label: const Text('Submit Bid'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBidPendingStatus() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Bid submitted - Waiting for acceptance',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedStatus() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (onArrivePressed != null)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onArrivePressed,
                icon: const Icon(Icons.location_on, size: 18),
                label: const Text("I'm Here"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArrivedActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (onCompletePressed != null)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onCompletePressed,
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Complete Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedStatus() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '✓ Trip completed',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
