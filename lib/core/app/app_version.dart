/// App version metadata. Keep [pubspecLine] in sync with `pubspec.yaml` `version`.
abstract final class AppVersion {
  /// Full pubspec version line, e.g. `0.2.3+1`.
  static const String pubspecLine = '0.2.3+1';

  static String get versionName {
    final parts = pubspecLine.split('+');
    return parts.first;
  }

  static String get buildNumber {
    final parts = pubspecLine.split('+');
    return parts.length > 1 ? parts[1] : '1';
  }

  /// Shown in Settings → About.
  static String get settingsDisplay => pubspecLine;
}
