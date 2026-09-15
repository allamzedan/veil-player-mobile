export 'veil_track_file_export_stub.dart'
    if (dart.library.io) 'veil_track_file_export_io.dart'
    if (dart.library.html) 'veil_track_file_export_web.dart';

/// Sanitizes a track title for use as a filename stem.
String sanitizeVeilTrackFileName(String title) {
  var name = title.trim().toLowerCase();
  if (name.isEmpty) {
    return '';
  }
  name = name.replaceAll(RegExp(r'[^a-z0-9._-]+'), '_');
  name = name.replaceAll(RegExp(r'_+'), '_');
  return name.replaceAll(RegExp(r'^_|_$'), '');
}

/// Builds a suggested export filename for a VEIL track.
String veilTrackExportFileName({String? trackTitle}) {
  final sanitized = sanitizeVeilTrackFileName(trackTitle ?? '');
  if (sanitized.isNotEmpty) {
    return '$sanitized.veil';
  }
  final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
  return 'veil_track_$timestamp.veil';
}

/// Builds a suggested export filename for a VEIL track pack.
String veilTrackPackExportFileName({String? packTitle}) {
  final sanitized = sanitizeVeilTrackFileName(packTitle ?? '');
  if (sanitized.isNotEmpty) {
    return '$sanitized.veilpack.json';
  }
  final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
  return 'veil_pack_$timestamp.veilpack.json';
}
