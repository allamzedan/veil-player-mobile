import 'package:veil_mobile/core/diagnostics/diagnostics_export_result.dart';

/// Platform-neutral fallback when no IO/web implementation is linked.
Future<DiagnosticsExportResult> exportDiagnosticsReport({
  required String report,
}) async {
  return const DiagnosticsExportResult(
    success: false,
    message: 'Diagnostics export is not available on this platform.',
  );
}
