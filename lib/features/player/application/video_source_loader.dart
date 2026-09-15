import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

import 'video_source_loader_stub.dart'
    if (dart.library.io) 'video_source_loader_io.dart'
    if (dart.library.html) 'video_source_loader_web.dart';

/// Result of attempting to open a local video for playback.
class VideoSourceResult {
  const VideoSourceResult({
    this.controller,
    this.unavailableMessage,
    this.revokeOnDispose,
  });

  final VideoPlayerController? controller;
  final String? unavailableMessage;

  /// Optional cleanup callback (e.g. revoke blob URLs on web).
  final Future<void> Function()? revokeOnDispose;
}

/// Creates an initialized [VideoPlayerController] from a picked file.
Future<VideoSourceResult> loadVideoFromPlatformFile(PlatformFile file) {
  return loadVideoFromPlatformFileImpl(file);
}

/// Creates an initialized [VideoPlayerController] from a local file path.
Future<VideoSourceResult> loadVideoFromPath(String path) {
  return loadVideoFromPathImpl(path);
}
