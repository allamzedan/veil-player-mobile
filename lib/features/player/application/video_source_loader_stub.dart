import 'package:file_picker/file_picker.dart';
import 'package:veil_mobile/features/player/application/video_source_loader.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

Future<VideoSourceResult> loadVideoFromPlatformFileImpl(
  PlatformFile file,
) async {
  return VideoSourceResult(
    unavailableMessage: AppStrings.playerVideoPlaybackUnavailable,
  );
}

Future<VideoSourceResult> loadVideoFromPathImpl(String path) async {
  return VideoSourceResult(
    unavailableMessage: AppStrings.playerVideoPlaybackUnavailable,
  );
}
