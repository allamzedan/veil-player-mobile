import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:veil_mobile/features/player/application/video_source_loader.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/platform_video_path_resolver.dart';
import 'package:video_player/video_player.dart';

Future<VideoSourceResult> loadVideoFromPlatformFileImpl(
  PlatformFile file,
) async {
  try {
    final resolved = await resolvePlatformVideoPath(file);
    if (!resolved.isSuccess) {
      return VideoSourceResult(
        unavailableMessage:
            resolved.errorMessage ?? AppStrings.playerVideoPlaybackUnavailable,
      );
    }
    return loadVideoFromPathImpl(resolved.path!);
  } on Object {
    return VideoSourceResult(
      unavailableMessage: AppStrings.playerVideoPlaybackUnavailable,
    );
  }
}

Future<VideoSourceResult> loadVideoFromPathImpl(String path) async {
  try {
    final controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    return VideoSourceResult(controller: controller);
  } on Object {
    return VideoSourceResult(
      unavailableMessage: AppStrings.playerVideoPlaybackUnavailable,
    );
  }
}
