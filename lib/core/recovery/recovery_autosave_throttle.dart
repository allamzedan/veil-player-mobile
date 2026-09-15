/// Limits autosave frequency unless a forced save is requested.
class RecoveryAutosaveThrottle {
  RecoveryAutosaveThrottle({this.minInterval = const Duration(seconds: 5)});

  final Duration minInterval;
  DateTime? _lastSavedAt;

  bool shouldSave({required bool force}) {
    if (force) {
      return true;
    }
    final last = _lastSavedAt;
    if (last == null) {
      return true;
    }
    return DateTime.now().difference(last) >= minInterval;
  }

  void markSaved([DateTime? at]) {
    _lastSavedAt = at ?? DateTime.now();
  }

  void reset() {
    _lastSavedAt = null;
  }
}
