/// Result of exporting a VEIL track JSON file.
class VeilTrackExportResult {
  const VeilTrackExportResult({
    required this.success,
    required this.message,
    this.usedShareFallback = false,
  });

  final bool success;
  final String message;
  final bool usedShareFallback;
}

/// Platform-neutral fallback when no IO/web implementation is linked.
Future<VeilTrackExportResult> exportVeilTrackJsonFile({
  required String json,
  required String fileName,
}) async {
  return const VeilTrackExportResult(
    success: false,
    message: 'File export is not available on this platform.',
  );
}

Future<VeilTrackExportResult> exportVeilTrackPackJsonFile({
  required String json,
  required String fileName,
}) async {
  return const VeilTrackExportResult(
    success: false,
    message: 'File export is not available on this platform.',
  );
}
