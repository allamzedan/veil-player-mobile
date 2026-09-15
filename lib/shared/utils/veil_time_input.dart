import 'package:veil_mobile/core/veil/veil_segment_type.dart';

/// Parses and formats user-facing segment times as `HH:MM:SS`.
abstract final class VeilTimeInput {
  static const int defaultStartMs = 0;
  static const int defaultEndMs = 1000;

  /// Formats milliseconds as `HH:MM:SS` (hours included when non-zero).
  static String formatMs(int milliseconds) {
    final clamped = milliseconds < 0 ? 0 : milliseconds;
    final totalSeconds = clamped ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Compact display for segment cards: `MM:SS` or `HH:MM:SS` when needed.
  static String formatMsShort(int milliseconds) {
    final clamped = milliseconds < 0 ? 0 : milliseconds;
    final totalSeconds = clamped ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return formatMs(clamped);
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Human-readable segment duration from start/end in milliseconds.
  static String formatDurationMs(int startMs, int endMs) {
    final durationMs = (endMs - startMs).clamp(0, 1 << 31);
    return formatMsShort(durationMs);
  }

  /// Parses `HH:MM:SS`, `MM:SS`, or plain seconds into milliseconds.
  static int? tryParseMs(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return null;
    }

    if (RegExp(r'^\d+$').hasMatch(text)) {
      return int.tryParse(text)! * 1000;
    }

    final parts = text.split(':');
    if (parts.length == 2) {
      if (!_colonPartsValid(parts)) {
        return null;
      }
      return _parseHms('0', parts[0], parts[1], null);
    }
    if (parts.length == 3) {
      if (!_colonPartsValid(parts)) {
        return null;
      }
      return _parseHms(parts[0], parts[1], parts[2], null);
    }

    return null;
  }

  static bool _colonPartsValid(List<String> parts) {
    if (parts.length == 2 || parts.length == 3) {
      return parts.every(
        (part) => RegExp(r'^\d{2}$').hasMatch(part.trim()),
      );
    }
    return false;
  }

  static int? _parseHms(
    String hoursPart,
    String minutesPart,
    String secondsPart,
    String? fallbackSeconds,
  ) {
    final hours = int.tryParse(hoursPart.trim());
    final minutes = int.tryParse(minutesPart.trim());
    final seconds = int.tryParse(
      (fallbackSeconds ?? secondsPart).trim(),
    );
    if (hours == null || minutes == null || seconds == null) {
      return null;
    }
    if (minutes < 0 || minutes > 59 || seconds < 0 || seconds > 59) {
      return null;
    }
    if (hours < 0) {
      return null;
    }
    return ((hours * 3600) + (minutes * 60) + seconds) * 1000;
  }

  /// Returns `true` when [endMs] is strictly after [startMs].
  static bool isValidRange(int startMs, int endMs) => endMs > startMs;

  /// Point segments (bookmark/marker) allow equal start and end.
  static bool isValidTimingForType(
    VeilSegmentType type,
    int startMs,
    int endMs,
  ) {
    if (type == VeilSegmentType.marker || type == VeilSegmentType.bookmark) {
      return endMs >= startMs;
    }
    return isValidRange(startMs, endMs);
  }
}
