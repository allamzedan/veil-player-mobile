// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_error_messages.dart';
import 'package:veil_mobile/shared/utils/veil_track_file_export_stub.dart';

Future<VeilTrackExportResult> exportVeilTrackJsonFile({
  required String json,
  required String fileName,
}) async {
  try {
    final safeName = fileName.endsWith('.json') ? fileName : '$fileName.json';
    final bytes = utf8.encode(json);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', safeName)
      ..click();
    html.Url.revokeObjectUrl(url);
    anchor.remove();

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
    final safeName = fileName.endsWith('.veilpack.json')
        ? fileName
        : '$fileName.veilpack.json';
    final bytes = utf8.encode(json);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', safeName)
      ..click();
    html.Url.revokeObjectUrl(url);
    anchor.remove();

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
