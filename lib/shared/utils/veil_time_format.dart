/// Formats millisecond timestamps for display (mm:ss.mmm).
abstract final class VeilTimeFormat {
  static String formatMs(int milliseconds) {
    final clamped = milliseconds < 0 ? 0 : milliseconds;
    final totalSeconds = clamped ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final ms = clamped % 1000;

    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');
    final msStr = ms.toString().padLeft(3, '0');

    return '$minutesStr:$secondsStr.$msStr';
  }
}
