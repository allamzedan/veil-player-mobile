/// True when [uri] is an Android external file intent, not an in-app route.
bool isExternalFileUri(Uri uri) {
  final scheme = uri.scheme.toLowerCase();
  return scheme == 'content' || scheme == 'file';
}

/// True when a GoRouter location string is an external file URI.
bool isExternalFileRoute(String location) {
  final trimmed = location.trim();
  final lower = trimmed.toLowerCase();
  return lower.startsWith('content://') || lower.startsWith('file://');
}
