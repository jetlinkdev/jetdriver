import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import '../models/order.dart';
import '../constants/api_constants.dart';

/// Trip map screen showing route from pickup to destination
class TripMapScreen extends StatefulWidget {
  final Order order;

  const TripMapScreen({super.key, required this.order});

  @override
  State<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  List<LatLng> routeCoordinates = [];
  bool isLoadingRoute = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _parseRouteCoordinates();
  }

  /// Parse route coordinates from order (already stored in database)
  void _parseRouteCoordinates() {
    try {
      final routeCoordsString = widget.order.routeCoordinates;

      if (routeCoordsString == null || routeCoordsString.isEmpty) {
        setState(() {
          errorMessage = 'Route coordinates not available';
          isLoadingRoute = false;
        });
        return;
      }

      // Parse stringified JSON array: [[lon,lat], [lon,lat], ...]
      final List<dynamic> coordsJson = jsonDecode(routeCoordsString);

      final coordinates = coordsJson
          .map((coord) => LatLng(coord[0] as double, coord[1] as double))
          .toList();

      setState(() {
        routeCoordinates = coordinates;
        isLoadingRoute = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error parsing route: ${e.toString()}';
        isLoadingRoute = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickupMarker = LatLng(
      widget.order.pickupLatitude,
      widget.order.pickupLongitude,
    );
    final destinationMarker = LatLng(
      widget.order.destinationLatitude,
      widget.order.destinationLongitude,
    );

    // Calculate bounds to show both markers
    final allPoints = [pickupMarker, destinationMarker, ...routeCoordinates];
    final bounds = _calculateBounds(allPoints);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Trip Details'),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Order info card
          _buildOrderInfoCard(),

          // Map
          Expanded(
            child: isLoadingRoute && routeCoordinates.isEmpty
                ? _buildLoadingState()
                : _buildMap(bounds, pickupMarker, destinationMarker),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${widget.order.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              _buildStatusChip(),
            ],
          ),

          const SizedBox(height: 16),

          // Pickup location
          _buildLocationRow(
            icon: Icons.location_on,
            iconColor: Colors.green,
            label: 'Pickup',
            address: widget.order.pickup,
          ),

          const SizedBox(height: 12),

          // Destination location
          _buildLocationRow(
            icon: Icons.flag,
            iconColor: Colors.red,
            label: 'Destination',
            address: widget.order.destination,
          ),

          if (widget.order.fare > 0) ...[
            const SizedBox(height: 12),

            // Fare
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.attach_money,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fare',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'Rp ${widget.order.fare.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;

    switch (widget.order.status) {
      case APIConstants.orderStatusAccepted:
        chipColor = Colors.blue;
        statusText = 'Accepted';
        break;
      case APIConstants.orderStatusDriverArrived:
        chipColor = Colors.orange;
        statusText = 'Arrived';
        break;
      case APIConstants.orderStatusCompleted:
        chipColor = Colors.green;
        statusText = 'Completed';
        break;
      case APIConstants.orderStatusCancelled:
        chipColor = Colors.red;
        statusText = 'Cancelled';
        break;
      default:
        chipColor = Colors.grey;
        statusText = widget.order.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading route from database...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(LatLngBounds bounds, LatLng pickup, LatLng destination) {
    return FlutterMap(
      options: MapOptions(initialCenter: bounds.center, initialZoom: 13),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ferdifir.jetdriver',
        ),

        if (routeCoordinates.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routeCoordinates,
                strokeWidth: 5,
                color: const Color(0xFF4CAF50),
                borderStrokeWidth: 2,
                borderColor: Colors.white,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            // Pickup marker
            Marker(
              point: pickup,
              width: 80,
              height: 80,
              child: const Icon(
                Icons.location_on,
                color: Colors.green,
                size: 40,
              ),
            ),
            // Destination marker
            Marker(
              point: destination,
              width: 80,
              height: 80,
              child: const Icon(Icons.flag, color: Colors.red, size: 40),
            ),
          ],
        ),
      ],
    );
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points
        .map((p) => p.latitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLat = points
        .map((p) => p.latitude)
        .reduce((a, b) => a > b ? a : b);
    double minLon = points
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLon = points
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);

    // Add padding
    const padding = 0.01;
    return LatLngBounds(
      LatLng(minLat - padding, minLon - padding),
      LatLng(maxLat + padding, maxLon + padding),
    );
  }
}
