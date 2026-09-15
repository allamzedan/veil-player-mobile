/// Origin of a recovery draft.
enum RecoveryDraftSource {
  player,
  trackBuilder;

  String get storageKey => name;

  static RecoveryDraftSource fromStorage(String value) {
    return RecoveryDraftSource.values.firstWhere(
      (s) => s.name == value,
      orElse: () => RecoveryDraftSource.player,
    );
  }
}

/// Why the draft was written.
enum RecoveryDraftReason {
  autosave,
  background,
  manual,
  crashRecovery;

  static RecoveryDraftReason fromStorage(String value) {
    return RecoveryDraftReason.values.firstWhere(
      (r) => r.name == value,
      orElse: () => RecoveryDraftReason.autosave,
    );
  }
}

/// Local-only unsaved VEIL track draft for crash/background recovery.
class RecoveryDraft {
  const RecoveryDraft({
    required this.id,
    required this.source,
    required this.trackTitle,
    required this.trackJson,
    required this.updatedAt,
    required this.reason,
    required this.segmentCount,
    required this.isDirty,
    this.trackId,
    this.videoName,
    this.videoPath,
  });

  final String id;
  final RecoveryDraftSource source;
  final String? trackId;
  final String trackTitle;
  final String trackJson;
  final String? videoName;
  final String? videoPath;
  final DateTime updatedAt;
  final RecoveryDraftReason reason;
  final int segmentCount;
  final bool isDirty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'source': source.name,
    'trackId': trackId,
    'trackTitle': trackTitle,
    'trackJson': trackJson,
    'videoName': videoName,
    'videoPath': videoPath,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'reason': reason.name,
    'segmentCount': segmentCount,
    'isDirty': isDirty,
  };

  factory RecoveryDraft.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final trackJson = json['trackJson'] as String?;
    final trackTitle = json['trackTitle'] as String?;
    if (id == null || trackJson == null || trackTitle == null) {
      throw const FormatException('Recovery draft is missing required fields.');
    }

    return RecoveryDraft(
      id: id,
      source: RecoveryDraftSource.fromStorage(
        json['source'] as String? ?? RecoveryDraftSource.player.name,
      ),
      trackId: json['trackId'] as String?,
      trackTitle: trackTitle,
      trackJson: trackJson,
      videoName: json['videoName'] as String?,
      videoPath: json['videoPath'] as String?,
      updatedAt: _parseUpdatedAt(json['updatedAt']),
      reason: RecoveryDraftReason.fromStorage(
        json['reason'] as String? ?? RecoveryDraftReason.autosave.name,
      ),
      segmentCount: _readInt(json['segmentCount']),
      isDirty: json['isDirty'] as bool? ?? true,
    );
  }

  /// Returns `null` when [json] is not a valid recovery draft.
  static RecoveryDraft? tryFromJson(Map<String, dynamic> json) {
    try {
      return RecoveryDraft.fromJson(json);
    } on Object {
      return null;
    }
  }

  static DateTime _parseUpdatedAt(dynamic value) {
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } on Object {
        return DateTime.now().toUtc();
      }
    }
    return DateTime.now().toUtc();
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return 0;
  }

  RecoveryDraft copyWith({
    String? id,
    RecoveryDraftSource? source,
    String? trackId,
    String? trackTitle,
    String? trackJson,
    String? videoName,
    String? videoPath,
    DateTime? updatedAt,
    RecoveryDraftReason? reason,
    int? segmentCount,
    bool? isDirty,
  }) {
    return RecoveryDraft(
      id: id ?? this.id,
      source: source ?? this.source,
      trackId: trackId ?? this.trackId,
      trackTitle: trackTitle ?? this.trackTitle,
      trackJson: trackJson ?? this.trackJson,
      videoName: videoName ?? this.videoName,
      videoPath: videoPath ?? this.videoPath,
      updatedAt: updatedAt ?? this.updatedAt,
      reason: reason ?? this.reason,
      segmentCount: segmentCount ?? this.segmentCount,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}
