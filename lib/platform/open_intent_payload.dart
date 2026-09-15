/// Payload for an Android ACTION_VIEW open intent.
class OpenIntentPayload {
  const OpenIntentPayload({required this.uri, this.mimeType, this.displayName});

  final String uri;
  final String? mimeType;
  final String? displayName;

  factory OpenIntentPayload.fromMap(Map<dynamic, dynamic> map) {
    return OpenIntentPayload(
      uri: map['uri'] as String? ?? '',
      mimeType: map['mimeType'] as String?,
      displayName: map['displayName'] as String?,
    );
  }
}
