import 'dart:io';

import 'package:veil_mobile/shared/utils/video_folder_scanner.dart';

VideoFolderScanResult scanVideoFolderImpl(String folderPath) {
  if (folderPath.trim().isEmpty) {
    return const VideoFolderScanResult.restricted(null);
  }

  try {
    final directory = Directory(folderPath);
    if (!directory.existsSync()) {
      return const VideoFolderScanResult.restricted(null);
    }

    final entries = <FolderVideoEntry>[];
    for (final entity in directory.listSync(followLinks: false)) {
      if (entity is! File) {
        continue;
      }
      final path = entity.path;
      if (!VideoFolderExtensions.isVideoFile(path)) {
        continue;
      }
      final parts = path.split(Platform.pathSeparator);
      entries.add(
        FolderVideoEntry(
          path: path,
          filename: parts.isNotEmpty ? parts.last : path,
        ),
      );
    }

    entries.sort((a, b) => a.filename.toLowerCase().compareTo(b.filename.toLowerCase()));
    return VideoFolderScanResult.videos(entries);
  } on Object {
    return const VideoFolderScanResult.restricted(null);
  }
}
