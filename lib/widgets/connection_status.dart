import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

/// Connection status indicator widget
class ConnectionStatusWidget extends StatelessWidget {
  final VoidCallback? onPingPressed;

  const ConnectionStatusWidget({
    super.key,
    this.onPingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStatus>(
      stream: _connectionStatusStream(),
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectionStatus.disconnected;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getStatusColor(status),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(status).withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status text
              Text(
                _getStatusText(status),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              // Ping button
              if (onPingPressed != null)
                TextButton(
                  onPressed: status == ConnectionStatus.connecting ? null : onPingPressed,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Ping',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Stream<ConnectionStatus> _connectionStatusStream() async* {
    // Initial status
    yield WebSocketService.instance.connectionStatus;
    
    // This is a simple implementation
    // In production, you'd want to use a proper state management solution
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      yield WebSocketService.instance.connectionStatus;
    }
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.error:
        return Colors.red;
      case ConnectionStatus.disconnected:
        return Colors.red;
    }
  }

  String _getStatusText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.error:
        return 'Error';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
    }
  }
}
