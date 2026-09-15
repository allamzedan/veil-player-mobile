// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:veil_mobile/features/player/application/video_source_loader.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:video_player/video_player.dart';

Future<VideoSourceResult> loadVideoFromPlatformFileImpl(
  PlatformFile file,
) async {
  try {
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      return VideoSourceResult(
        unavailableMessage: AppStrings.playerVideoPlaybackUnavailable,
      );
    }

    final blob = html.Blob([Uint8List.fromList(bytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();

    return VideoSourceResult(
      controller: controller,
      revokeOnDispose: () async {
        html.Url.revokeObjectUrl(url);
      },
    );
  } on Object {
    return VideoSourceResult(
      unavailableMessage: AppStrings.playerVideoPlaybackUnavailable,
    );
  }
}

Future<VideoSourceResult> loadVideoFromPathImpl(String path) async {
  return VideoSourceResult(
    unavailableMessage: AppStrings.playerVideoPlaybackUnavailable,
  );
}
