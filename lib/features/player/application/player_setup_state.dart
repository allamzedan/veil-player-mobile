import 'package:veil_mobile/core/subtitles/subtitle_parser.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';

/// Local video playback readiness for the player screen.
enum PlayerVideoPlaybackStatus { none, loading, ready, unavailable }

/// Preparation and playback state for the player screen.
class PlayerSetupState {
  const PlayerSetupState({
    this.selectedVideoName,
    this.selectedVideoPath,
    this.selectedVideoSize,
    this.selectedTrack,
    this.selectedTrackTitle,
    this.selectedTrackPath,
    this.selectedTrackFileName,
    this.validationMessages = const [],
    this.isReadyForPlayback = false,
    this.errorMessage,
    this.isLoading = false,
    this.videoPlaybackStatus = PlayerVideoPlaybackStatus.none,
    this.videoUnavailableMessage,
    this.videoRevision = 0,
    this.playbackSpeed = 1.0,
    this.selectedSubtitleName,
    this.selectedSubtitlePath,
    this.subtitleCues = const [],
    this.subtitlesEnabled = false,
    this.activeSubtitleText,
    this.hasUnsavedTrackChanges = false,
    this.storageSnackMessage,
  });

  final String? selectedVideoName;
  final String? selectedVideoPath;
  final int? selectedVideoSize;
  final VeilTrack? selectedTrack;
  final String? selectedTrackTitle;
  final String? selectedTrackPath;
  final String? selectedTrackFileName;
  final List<String> validationMessages;
  final bool isReadyForPlayback;
  final String? errorMessage;
  final bool isLoading;
  final PlayerVideoPlaybackStatus videoPlaybackStatus;
  final String? videoUnavailableMessage;

  /// Bumps when the underlying video controller instance changes.
  final int videoRevision;

  final double playbackSpeed;
  final String? selectedSubtitleName;
  final String? selectedSubtitlePath;
  final List<SubtitleCue> subtitleCues;
  final bool subtitlesEnabled;
  final String? activeSubtitleText;
  final bool hasUnsavedTrackChanges;
  final String? storageSnackMessage;

  int? get segmentCount => selectedTrack?.segments.length;

  String? get trackVideoName => selectedTrack?.videoName;

  bool get isVideoReady =>
      videoPlaybackStatus == PlayerVideoPlaybackStatus.ready;

  bool get hasVideoSelection => selectedVideoName != null;

  bool get hasSubtitleFile => subtitleCues.isNotEmpty;

  /// Backward-compatible alias used by existing UI.
  String? get subtitleFileName => selectedSubtitleName;

  String get playbackSpeedLabel {
    if (playbackSpeed == playbackSpeed.roundToDouble()) {
      return '${playbackSpeed.toInt()}x';
    }
    return '${playbackSpeed}x';
  }

  PlayerSetupState copyWith({
    String? selectedVideoName,
    String? selectedVideoPath,
    int? selectedVideoSize,
    VeilTrack? selectedTrack,
    String? selectedTrackTitle,
    String? selectedTrackPath,
    String? selectedTrackFileName,
    List<String>? validationMessages,
    bool? isReadyForPlayback,
    String? errorMessage,
    bool? isLoading,
    PlayerVideoPlaybackStatus? videoPlaybackStatus,
    String? videoUnavailableMessage,
    int? videoRevision,
    double? playbackSpeed,
    String? selectedSubtitleName,
    String? selectedSubtitlePath,
    List<SubtitleCue>? subtitleCues,
    bool? subtitlesEnabled,
    String? activeSubtitleText,
    bool? hasUnsavedTrackChanges,
    String? storageSnackMessage,
    bool clearVideo = false,
    bool clearTrack = false,
    bool clearError = false,
    bool clearWarnings = false,
    bool clearVideoUnavailable = false,
    bool clearSubtitle = false,
    bool clearActiveSubtitle = false,
    bool clearStorageSnack = false,
  }) {
    return PlayerSetupState(
      selectedVideoName: clearVideo
          ? null
          : (selectedVideoName ?? this.selectedVideoName),
      selectedVideoPath: clearVideo
          ? null
          : (selectedVideoPath ?? this.selectedVideoPath),
      selectedVideoSize: clearVideo
          ? null
          : (selectedVideoSize ?? this.selectedVideoSize),
      selectedTrack: clearTrack ? null : (selectedTrack ?? this.selectedTrack),
      selectedTrackTitle: clearTrack
          ? null
          : (selectedTrackTitle ?? this.selectedTrackTitle),
      selectedTrackPath: clearTrack
          ? null
          : (selectedTrackPath ?? this.selectedTrackPath),
      selectedTrackFileName: clearTrack
          ? null
          : (selectedTrackFileName ?? this.selectedTrackFileName),
      validationMessages: clearWarnings
          ? const []
          : (validationMessages ?? this.validationMessages),
      isReadyForPlayback: isReadyForPlayback ?? this.isReadyForPlayback,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
      videoPlaybackStatus: clearVideo
          ? PlayerVideoPlaybackStatus.none
          : (videoPlaybackStatus ?? this.videoPlaybackStatus),
      videoUnavailableMessage: clearVideo || clearVideoUnavailable
          ? null
          : (videoUnavailableMessage ?? this.videoUnavailableMessage),
      videoRevision: videoRevision ?? this.videoRevision,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      selectedSubtitleName: clearSubtitle
          ? null
          : (selectedSubtitleName ?? this.selectedSubtitleName),
      selectedSubtitlePath: clearSubtitle
          ? null
          : (selectedSubtitlePath ?? this.selectedSubtitlePath),
      subtitleCues: clearSubtitle
          ? const []
          : (subtitleCues ?? this.subtitleCues),
      subtitlesEnabled: clearSubtitle
          ? false
          : (subtitlesEnabled ?? this.subtitlesEnabled),
      activeSubtitleText: clearSubtitle || clearActiveSubtitle
          ? null
          : (activeSubtitleText ?? this.activeSubtitleText),
      hasUnsavedTrackChanges:
          hasUnsavedTrackChanges ?? this.hasUnsavedTrackChanges,
      storageSnackMessage: clearStorageSnack
          ? null
          : (storageSnackMessage ?? this.storageSnackMessage),
    );
  }
}
