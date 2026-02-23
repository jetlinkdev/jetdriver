import 'package:flutter/foundation.dart';

/// Log entry model
class LogEntry {
  final DateTime timestamp;
  final String message;
  final LogLevel level;

  LogEntry({
    required this.timestamp,
    required this.message,
    this.level = LogLevel.info,
  });

  @override
  String toString() {
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
    return '[$timeStr] $message';
  }
}

/// Log level enum
enum LogLevel {
  info,
  warning,
  error,
  success,
}

/// Logger service for activity logs
class Logger extends ChangeNotifier {
  static Logger? _instance;
  static Logger get instance => _instance ??= Logger._();

  Logger._();

  final List<LogEntry> _logs = [];
  static const int _maxLogs = 100;

  /// Get all logs
  List<LogEntry> get logs => List.unmodifiable(_logs);

  /// Add a log entry
  void log(String message, {LogLevel level = LogLevel.info}) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      message: message,
      level: level,
    );

    _logs.insert(0, entry); // Add to beginning

    // Limit log entries
    if (_logs.length > _maxLogs) {
      _logs.removeLast();
    }

    debugPrint('[${level.name.toUpperCase()}] $message');
    notifyListeners();
  }

  /// Add info log
  void info(String message) {
    log(message, level: LogLevel.info);
  }

  /// Add warning log
  void warning(String message) {
    log(message, level: LogLevel.warning);
  }

  /// Add error log
  void error(String message) {
    log(message, level: LogLevel.error);
  }

  /// Add success log
  void success(String message) {
    log(message, level: LogLevel.success);
  }

  /// Clear all logs
  void clear() {
    _logs.clear();
    notifyListeners();
  }

  /// Get color for log level
  static String getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return '#4CAF50'; // Green
      case LogLevel.warning:
        return '#FFA000'; // Orange
      case LogLevel.error:
        return '#F44336'; // Red
      case LogLevel.success:
        return '#8BC34A'; // Light Green
    }
  }
}

/// Extension for easy logging
extension LoggerExtension on String {
  void logInfo() => Logger.instance.info(this);
  void logWarning() => Logger.instance.warning(this);
  void logError() => Logger.instance.error(this);
  void logSuccess() => Logger.instance.success(this);
}
