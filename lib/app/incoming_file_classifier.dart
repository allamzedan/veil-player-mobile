/// Classification for files opened via Android "Open with".
enum IncomingFileKind { video, track, unsupported }

abstract final class IncomingFileClassifier {
  static const _videoExtensions = [
    '.mp4',
    '.mkv',
    '.webm',
    '.avi',
    '.mov',
    '.m4v',
    '.3gp',
    '.wmv',
  ];

  static IncomingFileKind classify({
    required String filename,
    String? mimeType,
  }) {
    final lower = filename.toLowerCase();
    final normalizedMime = mimeType?.toLowerCase();

    if (normalizedMime != null && normalizedMime.startsWith('video/')) {
      return IncomingFileKind.video;
    }

    for (final extension in _videoExtensions) {
      if (lower.endsWith(extension)) {
        return IncomingFileKind.video;
      }
    }

    if (_isVeilTrackFile(lower, normalizedMime)) {
      return IncomingFileKind.track;
    }

    return IncomingFileKind.unsupported;
  }

  static bool _isVeilTrackFile(String lowerFilename, String? mimeType) {
    if (lowerFilename.endsWith('.veil.json') ||
        lowerFilename.endsWith('.veil')) {
      return true;
    }
    if (!lowerFilename.endsWith('.json')) {
      return false;
    }
    if (mimeType == null || mimeType == 'application/json') {
      return true;
    }
    return false;
  }
}
