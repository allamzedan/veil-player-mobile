import 'package:veil_mobile/core/veil/veil_track.dart';

/// Validates [VeilTrack] documents and returns human-readable errors.
abstract final class VeilTrackValidator {
  static List<String> validate(VeilTrack track, {bool forWriting = true}) {
    final errors = <String>[];

    if (track.title.trim().isEmpty) {
      errors.add('Track title must not be empty.');
    }

    final seenIds = <String>{};
    for (final segment in track.segments) {
      if (segment.startMs < 0 || segment.endMs < 0) {
        errors.add('Segment "${segment.id}" has negative timestamps.');
      }

      if (!segment.hasValidTiming) {
        errors.add('Segment "${segment.id}" has invalid timing.');
      }

      if (forWriting && !seenIds.add(segment.id)) {
        errors.add('Duplicate segment id: "${segment.id}".');
      }
    }

    return errors;
  }
}
