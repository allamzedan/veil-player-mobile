import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_validator.dart';

/// Lightweight UI states for the track builder.
enum TrackBuilderUiStatus { draft, editing, readyToSave, requiresAttention }

/// UI and persistence state for the manual track builder.
class TrackBuilderState {
  const TrackBuilderState({
    required this.track,
    this.hasUnsavedChanges = false,
    this.isPersisted = false,
    this.statusMessage,
    this.showValidationErrors = false,
  });

  final VeilTrack track;
  final bool hasUnsavedChanges;
  final bool isPersisted;
  final String? statusMessage;

  /// When true, validation errors are shown in the UI.
  final bool showValidationErrors;

  List<String> get validationErrors => VeilTrackValidator.validate(track);

  bool get isValid => validationErrors.isEmpty;

  TrackBuilderUiStatus get uiStatus {
    if (showValidationErrors && validationErrors.isNotEmpty) {
      return TrackBuilderUiStatus.requiresAttention;
    }
    if (isValid && (isPersisted || _hasMeaningfulContent)) {
      return TrackBuilderUiStatus.readyToSave;
    }
    if (hasUnsavedChanges || _hasMeaningfulContent || isPersisted) {
      return TrackBuilderUiStatus.editing;
    }
    return TrackBuilderUiStatus.draft;
  }

  bool get _hasMeaningfulContent =>
      track.title.trim().isNotEmpty || track.segments.isNotEmpty;

  TrackBuilderState copyWith({
    VeilTrack? track,
    bool? hasUnsavedChanges,
    bool? isPersisted,
    String? statusMessage,
    bool? showValidationErrors,
    bool clearStatusMessage = false,
  }) {
    return TrackBuilderState(
      track: track ?? this.track,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isPersisted: isPersisted ?? this.isPersisted,
      statusMessage: clearStatusMessage
          ? null
          : (statusMessage ?? this.statusMessage),
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
    );
  }
}

/// Result of a builder storage or import operation.
class TrackBuilderOperationResult {
  const TrackBuilderOperationResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}
