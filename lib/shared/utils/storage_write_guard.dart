import 'package:veil_mobile/core/logging/app_logger.dart';

/// Runs a local persistence write without crashing the app.
abstract final class StorageWriteGuard {
  static Future<T?> run<T>(
    Future<T> Function() action, {
    required String operation,
  }) async {
    try {
      return await action();
    } on Object catch (error, stackTrace) {
      AppLogger.error('Storage write failed: $operation', error, stackTrace);
      return null;
    }
  }

  static Future<bool> runBool(
    Future<void> Function() action, {
    required String operation,
  }) async {
    try {
      await action();
      return true;
    } on Object catch (error, stackTrace) {
      AppLogger.error('Storage write failed: $operation', error, stackTrace);
      return false;
    }
  }
}
