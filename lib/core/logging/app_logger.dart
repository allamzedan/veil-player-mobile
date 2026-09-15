import 'package:flutter/foundation.dart';

/// Application logging facade. Uses [debugPrint] today; swap for Crashlytics later.
abstract final class AppLogger {
  static void info(String message, [Object? detail, StackTrace? stackTrace]) {
    _log('INFO', message, detail, stackTrace);
  }

  static void warning(String message, [Object? detail, StackTrace? stackTrace]) {
    _log('WARNING', message, detail, stackTrace);
  }

  static void error(String message, [Object? detail, StackTrace? stackTrace]) {
    _log('ERROR', message, detail, stackTrace);
  }

  static void _log(
    String level,
    String message,
    Object? detail,
    StackTrace? stackTrace,
  ) {
    final buffer = StringBuffer('[$level] $message');
    if (detail != null) {
      buffer.write(': $detail');
    }
    debugPrint(buffer.toString());
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
