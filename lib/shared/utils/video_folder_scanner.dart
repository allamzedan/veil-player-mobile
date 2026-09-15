import 'video_folder_scanner_stub.dart'
    if (dart.library.io) 'video_folder_scanner_io.dart';

/// A video file discovered inside a saved folder.
class FolderVideoEntry {
  const FolderVideoEntry({required this.path, required this.filename});

  final String path;
  final String filename;
}

/// Result of scanning a folder for playable videos.
class VideoFolderScanResult {
  const VideoFolderScanResult.videos(this.videos)
      : restricted = false,
        message = null;

  const VideoFolderScanResult.restricted(this.message)
      : videos = const [],
        restricted = true;

  final List<FolderVideoEntry> videos;
  final bool restricted;
  final String? message;
}

/// Supported video extensions for folder browsing.
abstract final class VideoFolderExtensions {
  static const extensions = ['.mp4', '.mkv', '.webm', '.mov'];

  static bool isVideoFile(String path) {
    final lower = path.toLowerCase();
    for (final extension in extensions) {
      if (lower.endsWith(extension)) {
        return true;
      }
    }
    return false;
  }
}

/// Scans [folderPath] for supported video files, or reports restricted access.
VideoFolderScanResult scanVideoFolder(String folderPath) =>
    scanVideoFolderImpl(folderPath);
