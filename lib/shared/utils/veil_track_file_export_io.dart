import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_error_messages.dart';
import 'package:veil_mobile/shared/utils/veil_track_file_export_stub.dart';

Future<VeilTrackExportResult> exportVeilTrackJsonFile({
  required String json,
  required String fileName,
}) async {
  try {
    final directory = await getTemporaryDirectory();
    final safeName = fileName.endsWith('.veil') ||
            fileName.endsWith('.veil.json') ||
            fileName.endsWith('.json')
        ? fileName
        : '$fileName.veil';
    final file = File('${directory.path}/$safeName');
    await file.writeAsString(json);

    final xFile = XFile(
      file.path,
      mimeType: 'application/json',
      name: safeName,
    );
    final result = await SharePlus.instance.share(
      ShareParams(files: [xFile], fileNameOverrides: [safeName]),
    );

    if (result.status == ShareResultStatus.dismissed) {
      return VeilTrackExportResult(
        success: true,
        message: 'Track file ready at ${file.path}',
        usedShareFallback: true,
      );
    }

    return VeilTrackExportResult(
      success: true,
      message: AppStrings.playerExportTrackSuccess,
    );
  } on Object catch (error) {
    return VeilTrackExportResult(
      success: false,
      message: VeilErrorMessages.fromException(error),
    );
  }
}

Future<VeilTrackExportResult> exportVeilTrackPackJsonFile({
  required String json,
  required String fileName,
}) async {
  try {
    final directory = await getTemporaryDirectory();
    final safeName = fileName.endsWith('.veilpack.json')
        ? fileName
        : '$fileName.veilpack.json';
    final file = File('${directory.path}/$safeName');
    await file.writeAsString(json);

    final xFile = XFile(
      file.path,
      mimeType: 'application/json',
      name: safeName,
    );
    final result = await SharePlus.instance.share(
      ShareParams(files: [xFile], fileNameOverrides: [safeName]),
    );

    if (result.status == ShareResultStatus.dismissed) {
      return VeilTrackExportResult(
        success: true,
        message: 'Track pack ready at ${file.path}',
        usedShareFallback: true,
      );
    }

    return VeilTrackExportResult(
      success: true,
      message: AppStrings.trackPackExportSuccess,
    );
  } on Object catch (error) {
    return VeilTrackExportResult(
      success: false,
      message: VeilErrorMessages.fromException(error),
    );
  }
}
