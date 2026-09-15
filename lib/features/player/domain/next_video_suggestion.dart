import 'package:veil_mobile/features/library/application/media_history_controller.dart';
import 'package:veil_mobile/shared/utils/video_folder_scanner.dart';

/// Suggested next video after playback ends.
class NextVideoSuggestion {
  const NextVideoSuggestion({required this.path, required this.filename});

  final String path;
  final String filename;
}

/// Resolves the next video from folder listing or recent history.
abstract final class NextVideoSuggestionResolver {
  static NextVideoSuggestion? resolve({
    required String? currentVideoPath,
    required MediaHistoryState history,
    required List<FolderVideoEntry> folderVideos,
  }) {
    if (folderVideos.isNotEmpty && currentVideoPath != null) {
      final index = folderVideos.indexWhere(
        (entry) => entry.path == currentVideoPath,
      );
      if (index >= 0 && index + 1 < folderVideos.length) {
        final next = folderVideos[index + 1];
        return NextVideoSuggestion(path: next.path, filename: next.filename);
      }
      if (index < 0 && folderVideos.isNotEmpty) {
        final first = folderVideos.first;
        if (first.path != currentVideoPath) {
          return NextVideoSuggestion(path: first.path, filename: first.filename);
        }
      }
    }

    for (final entry in history.recentVideos) {
      final path = entry.path;
      if (path == null || path.isEmpty || path == currentVideoPath) {
        continue;
      }
      return NextVideoSuggestion(path: path, filename: entry.filename);
    }

    return null;
  }
}
