import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';
import 'package:veil_mobile/shared/utils/local_file_access.dart';

/// Read-only statistics for a VEIL track document.
class TrackSummary {
  const TrackSummary({
    required this.title,
    required this.segmentCount,
    required this.maskCount,
    required this.muteCount,
    required this.skipCount,
    required this.bookmarkCount,
    required this.totalActions,
    required this.totalMaskedSeconds,
    required this.totalMutedSeconds,
    required this.totalSkippedSeconds,
    required this.createdAt,
    required this.updatedAt,
    this.videoName,
    this.videoDurationSeconds,
    this.fingerprintMethod,
  });

  final String title;
  final int segmentCount;
  final int maskCount;
  final int muteCount;
  final int skipCount;
  final int bookmarkCount;
  final int totalActions;
  final double totalMaskedSeconds;
  final double totalMutedSeconds;
  final double totalSkippedSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? videoName;
  final double? videoDurationSeconds;
  final String? fingerprintMethod;

  factory TrackSummary.fromTrack(VeilTrack track) {
    var maskCount = 0;
    var muteCount = 0;
    var skipCount = 0;
    var bookmarkCount = 0;
    var maskedSeconds = 0.0;
    var mutedSeconds = 0.0;
    var skippedSeconds = 0.0;

    for (final segment in track.segments) {
      if (!segment.enabled) {
        continue;
      }
      final durationSec = _segmentDurationSeconds(segment);
      switch (segment.type) {
        case VeilSegmentType.mask:
          maskCount++;
          maskedSeconds += durationSec;
        case VeilSegmentType.mute:
          muteCount++;
          mutedSeconds += durationSec;
        case VeilSegmentType.skip:
          skipCount++;
          skippedSeconds += durationSec;
        case VeilSegmentType.marker:
          break;
        case VeilSegmentType.bookmark:
          bookmarkCount++;
      }
    }

    return TrackSummary(
      title: track.title.trim().isEmpty
          ? VeilTrack.defaultUntitledTitle
          : track.title.trim(),
      segmentCount: track.segments.length,
      maskCount: maskCount,
      muteCount: muteCount,
      skipCount: skipCount,
      bookmarkCount: bookmarkCount,
      totalActions: maskCount + muteCount + skipCount,
      totalMaskedSeconds: maskedSeconds,
      totalMutedSeconds: mutedSeconds,
      totalSkippedSeconds: skippedSeconds,
      createdAt: track.createdAt,
      updatedAt: track.updatedAt,
      videoName: _resolveVideoName(track),
      videoDurationSeconds: track.videoDurationSeconds,
      fingerprintMethod: _resolveFingerprintMethod(track),
    );
  }

  static double _segmentDurationSeconds(VeilSegment segment) {
    if (!segment.hasValidTiming) {
      return 0;
    }
    if (segment.type == VeilSegmentType.marker ||
        segment.type == VeilSegmentType.bookmark) {
      return 0;
    }
    return (segment.endMs - segment.startMs) / 1000.0;
  }

  static String? _resolveVideoName(VeilTrack track) {
    final name = track.videoName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    final videoName = track.video?['name'] as String?;
    if (videoName != null && videoName.trim().isNotEmpty) {
      return videoName.trim();
    }
    return null;
  }

  static String? _resolveFingerprintMethod(VeilTrack track) {
    final fingerprint = track.video?['fingerprint'];
    if (fingerprint is Map<String, dynamic>) {
      final method = fingerprint['method'] as String?;
      if (method != null && method.isNotEmpty) {
        return method;
      }
    }
    return null;
  }
}

/// Preview row for a timed VEIL action.
class TrackActionPreview {
  const TrackActionPreview({
    required this.startMs,
    required this.endMs,
    required this.type,
  });

  final int startMs;
  final int endMs;
  final VeilSegmentType type;

  static const int defaultLimit = 10;

  static List<TrackActionPreview> fromTrack(
    VeilTrack track, {
    int limit = defaultLimit,
  }) {
    final actions = track.segments
        .where(
          (s) =>
              s.enabled &&
              s.type != VeilSegmentType.marker &&
              s.type != VeilSegmentType.bookmark &&
              s.hasValidTiming,
        )
        .map(
          (s) => TrackActionPreview(
            startMs: s.startMs,
            endMs: s.endMs,
            type: s.type,
          ),
        )
        .toList()
      ..sort((a, b) => a.startMs.compareTo(b.startMs));

    if (actions.length <= limit) {
      return actions;
    }
    return actions.sublist(0, limit);
  }
}

/// Loads a track JSON file for read-only preview (no player state changes).
Future<VeilTrack?> loadTrackFromPathForPreview(String path) async {
  if (!localFileExists(path)) {
    return null;
  }
  final content = await readLocalTextFile(path);
  if (content == null) {
    return null;
  }
  try {
    return VeilTrackCodec.tryDecode(content);
  } on Object {
    return null;
  }
}

VeilTrack? tryDecodeTrackJson(String content) {
  return VeilTrackCodec.tryDecode(content);
}
