import 'package:flutter/material.dart';

/// Color constants used throughout the app
class AppColors {
  // Primary colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryBlue = Colors.blue;
  static const Color primaryRed = Colors.red;
  static const Color primaryOrange = Colors.orange;

  // Background colors
  static const Color scaffoldBackground = Color(0xFF16213E);
  static const Color cardBackground = Color(0xFF1A1A2E);
  static const Color greyBackground = Color(0xFF1A1A2E);

  // Gradient colors
  static const Color gradientGreenStrong = Color(0xFF4CAF50);
  static const Color gradientGreenLight = Color(0xFF4CAF50);
  static const Color gradientRedStrong = Color(0xFFFF4444);
  static const Color gradientGreyDark = Color(0xFF16213E);

  // Opacity variants
  static const Color greenOpacity20 = Color(0x334CAF50);
  static const Color greenOpacity10 = Color(0x1A4CAF50);
  static const Color greenOpacity5 = Color(0x0D4CAF50);
  static const Color greenOpacity30 = Color(0x4D4CAF50);
  static const Color redOpacity20 = Color(0x33FF4444);
  static const Color redOpacity10 = Color(0x1AFF4444);
  static const Color redOpacity5 = Color(0x0DFF4444);
  static const Color whiteOpacity5 = Color(0x0DFFFFFF);
  static const Color whiteOpacity10 = Color(0x1AFFFFFF);
  static const Color whiteOpacity20 = Color(0x33FFFFFF);

  // Text colors
  static const Color textWhite = Colors.white;
  static const Color textWhite70 = Colors.white70;
  static const Color textWhite54 = Colors.white54;
  static const Color textWhite38 = Colors.white38;
  static const Color textBlack87 = Colors.black87;

  // Status colors
  static const Color statusAvailable = Color(0xFF4CAF50);
  static const Color statusBusy = Colors.orange;
  static const Color statusOffline = Colors.red;
  static const Color statusAccepted = Colors.green;
  static const Color statusArrived = Colors.blue;
  static const Color statusCompleted = Colors.grey;
  static const Color statusPending = Colors.orange;

  // Icon colors
  static const Color iconGreen = Color(0xFF4CAF50);
  static const Color iconRed = Color(0xFFFF4444);
  static const Color iconGrey = Colors.white54;

  // Border colors
  static const Color borderGreen = Color(0xFF4CAF50);
  static const Color borderRed = Colors.red;
  static const Color borderWhite10 = Color(0x1AFFFFFF);

  // Button colors
  static const Color buttonGreen = Color(0xFF4CAF50);
  static const Color buttonBlue = Colors.blue;
  static const Color buttonRed = Colors.red;
  static const Color buttonWhite = Colors.white;

  // Card decoration colors
  static const Color cardGreenGradientStart = Color(0x334CAF50);
  static const Color cardGreenGradientEnd = Color(0x0D4CAF50);
  static const Color cardRedGradientStart = Color(0x33FF4444);
  static const Color cardRedGradientEnd = Color(0x0DFF4444);
  static const Color cardGreyGradientStart = Color(0xFF1A1A2E);
  static const Color cardGreyGradientEnd = Color(0xFF16213E);

  // Shadow colors
  static const Color shadowGreen = Color(0x664CAF50);
  static const Color shadowRed = Color(0x66FF4444);
  static const Color shadowBlack = Colors.black26;

  // Helper methods for opacity (Material 3 compliant)
  static Color withValues(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }

  static Color getGradientGreenStart(double alpha) {
    return gradientGreenStrong.withValues(alpha: alpha);
  }

  static Color getGradientGreenEnd(double alpha) {
    return gradientGreenLight.withValues(alpha: alpha * 0.25);
  }
}
