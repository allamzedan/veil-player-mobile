import 'package:file_picker/file_picker.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

import 'platform_video_path_resolver.dart';

Future<PlatformVideoPathResult> resolvePlatformVideoPathImpl(
  PlatformFile file,
) async {
  return PlatformVideoPathResult(
    errorMessage: AppStrings.playerVideoPlaybackUnavailable,
  );
}
