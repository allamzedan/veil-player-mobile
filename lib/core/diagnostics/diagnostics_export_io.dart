import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:veil_mobile/core/diagnostics/diagnostics_export_result.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_error_messages.dart';

Future<DiagnosticsExportResult> exportDiagnosticsReport({
  required String report,
}) async {
  try {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    const fileName = 'veil_mobile_diagnostics.txt';
    final file = File('${directory.path}/veil_diagnostics_$timestamp.txt');
    await file.writeAsString(report);

    final xFile = XFile(
      file.path,
      mimeType: 'text/plain',
      name: fileName,
    );
    await SharePlus.instance.share(
      ShareParams(files: [xFile], fileNameOverrides: [fileName]),
    );

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
