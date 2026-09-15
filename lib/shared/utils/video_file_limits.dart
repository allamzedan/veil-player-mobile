/// Guardrails for local video files to avoid loading very large media into memory.
abstract final class VideoFileLimits {
  /// Maximum video file size supported in the closed beta (500 MB).
  static const int maxVideoBytes = 500 * 1024 * 1024;

  static bool isWithinLimit(int? bytes) {
    if (bytes == null || bytes <= 0) {
      return true;
    }
    return bytes <= maxVideoBytes;
  }
}
