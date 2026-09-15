import 'package:file_picker/file_picker.dart';

import 'platform_video_path_resolver_stub.dart'
    if (dart.library.io) 'platform_video_path_resolver_io.dart';

/// Result of resolving a picked video to a local filesystem path.
class PlatformVideoPathResult {
  const PlatformVideoPathResult({
    this.path,
    this.sizeBytes,
    this.errorMessage,
  });

  final String? path;
  final int? sizeBytes;
  final String? errorMessage;

  bool get isSuccess => path != null && path!.isNotEmpty && errorMessage == null;
}

/// Resolves a [PlatformFile] to a local path without loading video bytes.
Future<PlatformVideoPathResult> resolvePlatformVideoPath(PlatformFile file) {
  return resolvePlatformVideoPathImpl(file);
}
