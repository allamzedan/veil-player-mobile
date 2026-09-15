import 'package:file_picker/file_picker.dart';
import 'package:veil_mobile/platform/android_open_intent.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/local_file_access.dart';
import 'package:veil_mobile/shared/utils/video_file_limits.dart';

import 'platform_video_path_resolver.dart';

Future<PlatformVideoPathResult> resolvePlatformVideoPathImpl(
  PlatformFile file,
) async {
  final path = file.path?.trim();
  if (path != null && path.isNotEmpty && localFileExists(path)) {
    return _resultForLocalPath(path, file.size);
  }

  final identifier = file.identifier?.trim();
  if (identifier != null &&
      identifier.isNotEmpty &&
      identifier.startsWith('content://')) {
    final size = await queryAndroidOpenableSize(identifier) ?? file.size;
    if (!VideoFileLimits.isWithinLimit(size)) {
      return PlatformVideoPathResult(
        errorMessage: AppStrings.playerVideoTooLarge(size),
      );
    }

    final resolved = await resolveAndroidOpenablePath(identifier);
    if (resolved == null || resolved.isEmpty) {
      return PlatformVideoPathResult(
        errorMessage: AppStrings.openIntentFileUnavailable,
      );
    }
    return _resultForLocalPath(resolved, size);
  }

  return PlatformVideoPathResult(
    errorMessage: AppStrings.playerVideoPlaybackUnavailable,
  );
}

Future<PlatformVideoPathResult> _resultForLocalPath(
  String path,
  int pickerSize,
) async {
  final size = pickerSize > 0 ? pickerSize : await localVideoFileSize(path);
  if (!VideoFileLimits.isWithinLimit(size)) {
    return PlatformVideoPathResult(
      errorMessage: AppStrings.playerVideoTooLarge(size ?? pickerSize),
    );
  }
  return PlatformVideoPathResult(
    path: path,
    sizeBytes: size ?? (pickerSize > 0 ? pickerSize : null),
  );
}
