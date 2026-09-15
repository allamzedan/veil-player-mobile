// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'package:veil_mobile/core/diagnostics/diagnostics_export_result.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_error_messages.dart';

Future<DiagnosticsExportResult> exportDiagnosticsReport({
  required String report,
}) async {
  try {
    const fileName = 'veil_mobile_diagnostics.txt';
    final bytes = utf8.encode(report);
    final blob = html.Blob([bytes], 'text/plain');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
    anchor.remove();

    return DiagnosticsExportResult(
      success: true,
      message: AppStrings.diagnosticsExportSuccess,
    );
  } on Object catch (error) {
    return DiagnosticsExportResult(
      success: false,
      message: VeilErrorMessages.fromException(error),
    );
  }
}
