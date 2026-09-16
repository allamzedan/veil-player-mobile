import 'package:veil_mobile/core/app/app_version.dart';
import 'package:veil_mobile/core/localization/app_locale.dart';

part 'app_localizations_ar.dart';

/// Locale-aware user-facing strings for VEIL Player Mobile.
class AppLocalizations {
  const AppLocalizations._(this.languageCode);

  final String languageCode;

  bool get isRtl => languageCode == AppLanguageCode.ar;

  static const AppLocalizations en = AppLocalizations._(AppLanguageCode.en);
  static const AppLocalizations ar = AppLocalizationsAr();

  factory AppLocalizations.forLanguageCode(String code) {
    if (code == AppLanguageCode.ar) {
      return ar;
    }
    return en;
  }

  String get appName => 'VEIL Player Mobile';

  // Route titles
  String get homeTitle => 'Home';
  String get libraryTitle => 'Library';
  String get playerTitle => 'Player';
  String get trackBuilderTitle => 'Track Builder';
  String get settingsTitle => 'Settings';

  // Navigation labels
  String get navHome => 'Home';
  String get navLibrary => 'Library';
  String get navPlayer => 'Player';
  String get navBuilder => 'Builder';
  String get navSettings => 'Settings';

  // Home
  String get homeDescription => 'Watch with VEIL tracks on your device.';
  String get openPlayer => 'Open Player';
  String get openPlayerSubtitle =>
      'Select a video and VEIL track to prepare playback.';
  String get openVideo => 'Open Video';
  String get openVideoSubtitle => 'Pick a video from your device and start watching.';
  String get trackBuilderCard => 'Track Builder';
  String get trackBuilderCardSubtitle =>
      'Create and edit VEIL tracks on mobile.';
  String get openLibrary => 'Library';
  String get openLibrarySubtitle =>
      'Recent videos, tracks, and your last session.';

  // Library
  String get libraryEmptyTitle => 'No saved tracks';
  String get libraryEmptyMessage =>
      'Create a track in Track Builder, save it, and it will appear here.';
  String get libraryLoadError => 'Could not load saved tracks';
  String get libraryRefresh => 'Refresh';
  String get libraryCreateTrack => 'New track';
  String get libraryEditTrack => 'Edit';
  String get libraryValidationValid => 'Valid';
  String get libraryValidationInvalid => 'Has issues';
  String get librarySavedTracksSection => 'Saved Tracks';

  // Media history
  String get libraryRecentVideosSection => 'Recent Videos';
  String get libraryRecentTracksSection => 'Recent Tracks';
  String get libraryLastSessionSection => 'Last Session';
  String get libraryNoRecentVideos => 'No recent videos yet';
  String get libraryNoRecentTracks => 'No recent tracks yet';
  String get libraryNoLastSession => 'No saved session yet';
  String get libraryOpenVideo => 'Open';
  String get libraryOpenTrack => 'Open';
  String get libraryRemoveFromHistory => 'Remove from history';
  String get libraryResumeSession => 'Resume';
  String get libraryHistoryRemoved => 'Removed from history';
  String get continueLastSession => 'Continue Last Session';
  String get lastSessionUnavailable => 'No saved session to resume';
  String get mediaHistorySourceUnavailable =>
      'This item cannot be reopened on this device.';
  String mediaHistorySourceMissing(String filename) =>
      'The file "$filename" is no longer available on this device.';
  String lastSessionVideoMissing(String filename) =>
      'The video "$filename" is no longer available on this device.';
  String lastSessionTrackMissing(String filename) =>
      'The track "$filename" is no longer available on this device.';
  String lastSessionSubtitleMissing(String filename) =>
      'The subtitle "$filename" is no longer available on this device.';
  String continueLastSessionSubtitle(String videoName) =>
      'Resume $videoName from where you left off.';
  String libraryRecentVideoMeta(String duration, String position) =>
      '$duration · resumed at $position';
  String libraryRecentTrackMeta(int segmentCount) =>
      '$segmentCount segment${segmentCount == 1 ? '' : 's'}';
  String libraryLastSessionMeta(String position, String speed) =>
      '$position · $speed';

  // Android Open With
  String get openIntentFileUnavailable =>
      'Could not open the selected file on this device.';
  String openIntentUnsupportedFile(String filename) =>
      'VEIL Player Mobile cannot open "$filename". Try a video or VEIL JSON track file.';

  String get trackNotFound => 'Saved track not found';
  String get playerEmptyTitle => 'Playback';
  String get playerOpenVideo => 'Open video';
  String get playerLoadTrack => 'Load VEIL track';
  String get playerNoVideoSelected => 'No video selected';
  String get playerInfoVideo => 'Video';
  String get playerInfoTrack => 'Track';
  String get playerInfoStatus => 'Status';
  String get playerStatusWaiting => 'Waiting for setup';
  String get playerStatusMissingVideo => 'Missing video';
  String get playerStatusMissingTrack => 'Missing track';
  String get playerOpenVideoShort => 'Open video';
  String get playerLoadTrackShort => 'Load track';
  String get playerNoTrackSelected => 'No VEIL track loaded';
  String get playerSelectedVideo => 'Selected video';
  String get playerSelectedTrack => 'Loaded track';
  String get playerTrackLoadError =>
      'Could not load the selected VEIL track file.';
  String get playerVideoPickCancelled => 'Video selection cancelled';
  String get playerTrackPickCancelled => 'Track selection cancelled';
  String get playerSetupIntro => 'Prepare a video and VEIL track for playback.';
  String get playerClearVideo => 'Clear video';
  String get playerClearTrack => 'Clear track';
  String get playerStartPlayback => 'Start playback';
  String get playerReadyForPlayback => 'Ready for playback';
  String get playerReadyWithVeilTrack => 'Ready with VEIL track';
  String get playerVideoReady => 'Video ready';
  String get playerVideoPlaybackUnavailable =>
      'Video selected, but local playback is not available in this environment.';
  String playerVideoTooLarge(int bytes) {
    if (bytes > 0) {
      return 'This video (${playerVideoSizeLabel(bytes)}) exceeds the 500 MB limit for this beta. Try a smaller file or open it from a file manager that provides direct access.';
    }
    return 'This video exceeds the 500 MB limit for this beta. Try a smaller file.';
  }
  String get playerOpenVideoHelper => 'Open a video to begin';
  String get playerAddVeilTrackSuggestion => 'Add VEIL track?';
  String get playerVeilActive => 'VEIL Active';
  String get playerRuntimeEffectsDivider => ' / ';

  String playerRuntimeEffectsLabel({
    required bool hasMask,
    required bool hasMute,
    required bool hasSkip,
  }) {
    final parts = <String>[];
    if (hasMask) {
      parts.add(segmentTypeMask);
    }
    if (hasMute) {
      parts.add(segmentTypeMute);
    }
    if (hasSkip) {
      parts.add(segmentTypeSkip);
    }
    return parts.join(playerRuntimeEffectsDivider);
  }

  String get playerDetails => 'Details';
  String get playerChangeVideo => 'Open another video';
  String get playerLoadVeilTrack => 'Load VEIL track';
  String get playerVideoInitializing => 'Loading video…';
  String get playerValidationWarnings => 'Warnings';
  String get playerErrorNoVideo => 'Select a video file to continue.';
  String get playerErrorNoTrack => 'Load a VEIL track to continue.';
  String get playerErrorInvalidTrack => 'The selected VEIL track is invalid.';
  String get playerWarningVideoNameMismatch =>
      'Track video name does not closely match the selected file.';
  String get playerTrackSegments => 'Segments';
  String get playerTrackSegmentsTitle => 'Track Segments';
  String get playerNoSegmentsYet => 'No VEIL actions yet';
  String get playerSegmentJumpTo => 'Jump To';
  String get playerSegmentDuplicate => 'Duplicate';
  String get playerSegmentDeleteTitle => 'Delete segment?';
  String get playerSegmentDeleteMessage =>
      'This VEIL action will be removed from the track.';
  String get playerMaskEditorTitle => 'Mask Editor';
  String get playerMaskEditPosition => 'Edit Position & Size';
  String get playerSegmentStartTime => 'Start time (seconds)';
  String get playerSegmentEndTime => 'End time (seconds)';
  String get playerTrackVideoMeta => 'Track video metadata';
  String get playerVideoSize => 'File size';
  String get playerFullscreen => 'Fullscreen';
  String get playerExitFullscreen => 'Exit fullscreen';
  String get playerSubtitles => 'Subtitles';
  String get playerSubtitlesOff => 'Subtitles off';
  String get playerSubtitlesOn => 'Subtitles on';
  String get playerPickSubtitle => 'Pick subtitle file';
  String get playerReplaceSubtitle => 'Replace subtitle file';
  String get playerSubtitleLoadError =>
      'Could not load the selected subtitle file.';
  String get playerSubtitleEmpty => 'No subtitle cues were found in this file.';
  String playerSubtitleLoaded(int cueCount) =>
      'Loaded $cueCount subtitle cue${cueCount == 1 ? '' : 's'}.';
  String get playerSubtitleSettings => 'Subtitle settings';
  String get playerSubtitleSettingsTitle => 'Subtitle settings';
  String get playerSubtitleFontSize => 'Font size';
  String get playerSubtitleFontSizeSmall => 'Small';
  String get playerSubtitleFontSizeMedium => 'Medium';
  String get playerSubtitleFontSizeLarge => 'Large';
  String get playerSubtitlePosition => 'Position';
  String get playerSubtitlePositionBottom => 'Bottom';
  String get playerSubtitlePositionMiddle => 'Middle';
  String get playerSubtitlePositionTop => 'Top';
  String get playerSubtitleBackground => 'Background';
  String get playerSubtitleBackgroundOpacity => 'Background opacity';
  String get playerSubtitleDelay => 'Delay';
  String get playerSubtitleDelayReset => 'Reset';
  String get playerSubtitleDelayMinus500 => '-500ms';
  String get playerSubtitleDelayMinus100 => '-100ms';
  String get playerSubtitleDelayPlus100 => '+100ms';
  String get playerSubtitleDelayPlus500 => '+500ms';
  String get playerPlaybackSpeed => 'Playback speed';
  String get playerSeekBackOverlay => '-10s';
  String get playerSeekForwardOverlay => '+10s';
  String get playerSpeedBoostOverlay => '2x';
  String playerVolumeOverlay(int percent) => 'Volume $percent%';
  String playerBrightnessOverlay(int percent) => 'Brightness $percent%';
  String get playerVeilQuickAction => 'VEIL';
  String get playerQuickAddMask => 'Add Mask';
  String get playerQuickAddMute => 'Add Mute';
  String get playerQuickAddSkip => 'Add Skip';
  String get playerQuickAddBookmark => 'Bookmark';
  String get playerBookmarks => 'Bookmarks';
  String get playerBookmarksEmpty => 'No bookmarks on this track yet.';
  String get playerEndScreenTitle => 'Up next';
  String get playerReplay => 'Replay';
  String get playerPlayNext => 'Play Next';
  String get playerChooseVideo => 'Choose Video';
  String playerEndCountdown(int seconds) => 'Playing next in $seconds…';
  String get playerOpenManualBuilder => 'Open Manual Builder';
  String get playerQuickActionTitle => 'Quick action';
  String get playerQuickActionAt => 'At playback time';
  String get playerQuickDuration => 'Duration';
  String get playerQuickDuration3s => '3 seconds';
  String get playerQuickDuration5s => '5 seconds';
  String get playerQuickDuration10s => '10 seconds';
  String get playerQuickDurationCustom => 'Custom';
  String get playerQuickCustomSecondsHint => 'Seconds';
  String get playerQuickInvalidDuration => 'Enter a valid duration.';
  String get playerQuickActionRequiresVideo =>
      'Open a video before adding VEIL actions.';
  String get playerQuickActionAdded => 'VEIL action added';
  String get playerQuickActionAddedHint => 'Export to keep it';
  String get playerExportTrack => 'Export Track';
  String get playerPreviewJson => 'Preview JSON';
  String get playerExportTrackSuccess => 'Track file exported.';
  String get playerExportTrackFailed => 'Could not export track file.';
  String get playerUnsavedTrackHint => 'Unsaved track changes';
  String get playerQuickMaskPlacementTitle => 'Place mask';
  String get playerQuickMaskPlacementHint =>
      'Drag to move. Resize from any corner handle.';
  String get playerQuickMaskConfirm => 'Confirm';

  String playerVideoSizeLabel(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Track builder
  String get addSegment => 'Add Segment';
  String get trackTitleLabel => 'Track title';
  String get trackTitleHint => 'Enter track title';
  String get validationValid => 'Track is valid';
  String get validationInvalid => 'Validation issues';
  String get validationRequiresAttention => 'Requires attention';
  String get validationFixHint =>
      'Fix these issues to save or export this track.';
  String get noSegmentsTitle => 'No segments';
  String get noSegmentsMessage => 'Add a segment to start building this track.';
  String get trackBuilderNoActionsYet => 'No VEIL actions yet';
  String get trackBuilderSegmentSearchHint => 'Search actions';
  String get trackBuilderNoMatchingActions => 'No matching actions';
  String get trackBuilderFilterAll => 'All';
  String get trackBuilderFilterMasks => 'Masks';
  String get trackBuilderFilterMutes => 'Mutes';
  String get trackBuilderFilterSkips => 'Skips';
  String trackBuilderActionsTotal(int count) =>
      '$count Action${count == 1 ? '' : 's'}';
  String trackBuilderMaskCount(int count) =>
      '$count Mask${count == 1 ? '' : 's'}';
  String trackBuilderMuteCount(int count) =>
      '$count Mute${count == 1 ? '' : 's'}';
  String trackBuilderSkipCount(int count) =>
      '$count Skip${count == 1 ? '' : 's'}';
  String get trackBuilderQuickAddMask => 'Mask';
  String get trackBuilderQuickAddMute => 'Mute';
  String get trackBuilderQuickAddSkip => 'Skip';
  String get trackBuilderQuickAddBookmark => 'Bookmark';
  String get trackBuilderFilterBookmarks => 'Bookmarks';
  String trackBuilderBookmarkCount(int count) =>
      '$count Bookmark${count == 1 ? '' : 's'}';
  String get jsonPreview => 'JSON preview';
  String get jsonPreviewTitle => 'Track JSON';
  String get close => 'Close';
  String get newTrack => 'New track';
  String get segmentCount => 'Segments';
  String get saveTrack => 'Save track';
  String get importJson => 'Import JSON';
  String get importJsonFromFile => 'Import JSON from file';
  String get importJsonPaste => 'Paste JSON';
  String get exportJson => 'Export JSON';
  String get moreActions => 'More actions';
  String get copyJson => 'Copy JSON';
  String get copyJsonSuccess => 'JSON copied to clipboard';
  String get importJsonTitle => 'Import track JSON';
  String get importJsonHint => 'Paste VEIL track JSON here';
  String get importJsonAction => 'Import';
  String get exportJsonTitle => 'Export track JSON';
  String get saveSuccess => 'Track saved locally';
  String get saveValidationFailed => 'Fix validation issues before saving';
  String get importSuccess => 'Track imported';
  String get importValidationFailed => 'Imported track has validation issues';
  String get importInvalidJson =>
      'Invalid VEIL track JSON. Check format and try again.';
  String get storageUnknownError => 'Storage operation failed';
  String get storageWriteFailedKeepVideoOpen =>
      'Storage operation failed. Your current video is still open.';
  String get widgetBuildErrorFallback =>
      'Something went wrong while displaying this screen.';
  String get delete => 'Delete';
  String get deleteSuccess => 'Track deleted';
  String get deleteNotSaved => 'Current track is not saved locally';
  String get deleteTrackTitle => 'Delete saved track?';
  String get untitledTrack => 'Untitled track';
  String get newTrackConfirmTitle => 'Start a new track?';
  String get newTrackConfirmMessage =>
      'Unsaved changes will be lost. Continue?';
  String get continueAction => 'Continue';
  String get trackStatusSaved => 'Saved locally';
  String get trackStatusLoaded => 'Track loaded';
  String get trackStatusImported => 'Track imported';
  String get trackStatusDraft => 'Draft track';
  String get trackStatusNew => 'New track started';
  String get trackStatusUnsaved => 'Unsaved changes';
  String get trackStatusReadyToSave => 'Ready to save';
  String get trackStatusSavedIdle => 'Saved';
  String get trackMetadataTitle => 'Track metadata';
  String get trackMetadataCollapsedHint => 'Tap to expand';
  String get trackMetadataNone => 'No metadata';
  String get trackMetadataNoneExpanded =>
      'No desktop metadata is available for this track.';
  String get trackVideoName => 'Video';
  String get trackSourceApp => 'Source app';
  String get trackSourceAppVersion => 'Source version';
  String get trackVideoDuration => 'Duration';
  String get trackVideoResolution => 'Resolution';
  String get trackGlobalOffset => 'Global offset';
  String get trackExportedAt => 'Last exported';
  String get trackSubtitleCover => 'Subtitle cover';
  String get trackSubtitleCoverPresent => 'Configured';
  String get segmentEnabled => 'Enabled';
  String get segmentDisabled => 'Disabled';
  String get untitledVeilTrack => 'Untitled VEIL Track';

  String formatVideoDuration(double seconds) {
    final totalSeconds = seconds.floor();
    final minutes = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${minutes}m ${secs}s';
  }

  String deleteTrackMessage(String title) {
    final displayTitle = title.trim().isEmpty ? untitledTrack : title;
    return 'Delete "$displayTitle" from local storage?';
  }

  String savedTrackMeta({
    required int segmentCount,
    required String updatedAt,
  }) {
    return '$segmentCount segments · Updated $updatedAt';
  }

  // Segment card
  String get segmentEdit => 'Edit segment';
  String get segmentDelete => 'Delete segment';
  String get segmentStart => 'Start';
  String get segmentEnd => 'End';
  String get segmentLabel => 'Label';
  String get segmentNotes => 'Notes';
  String get segmentNoLabel => 'No label';
  String get segmentReorder => 'Reorder segment';

  // Segment types
  String get segmentTypeMask => 'Mask';
  String get segmentTypeMute => 'Mute';
  String get segmentTypeSkip => 'Skip';
  String get segmentTypeMarker => 'Marker';
  String get segmentTypeBookmark => 'Bookmark';
  String get segmentTypeBookmarks => 'Bookmarks';
  String get bookmarkTitle => 'Title';
  String get bookmarkNote => 'Note (optional)';
  String get bookmarkTime => 'Time';
  String get bookmarkTitleRequired => 'Enter a bookmark title.';

  String segmentTypeLabel(String typeName) {
    return switch (typeName) {
      'mask' => segmentTypeMask,
      'mute' => segmentTypeMute,
      'skip' => segmentTypeSkip,
      'marker' => segmentTypeMarker,
      'bookmark' => segmentTypeBookmark,
      _ => typeName,
    };
  }

  // Segment editor
  String get segmentEditorTitleAdd => 'Add segment';
  String get segmentEditorTitleEdit => 'Edit segment';
  String get segmentTypeField => 'Type';
  String get segmentStartMs => 'Start time';
  String get segmentEndMs => 'End time';
  String get segmentTimeHint => 'HH:MM:SS';
  String get segmentLabelField => 'Label (optional)';
  String get segmentNotesField => 'Notes (optional)';
  String get save => 'Save';
  String get cancel => 'Cancel';
  String get segmentEditorInvalidTiming => 'End time must be after start time.';
  String get segmentEditorInvalidMs => 'Invalid time format. Use HH:MM:SS.';
  String get segmentEditorInvalidTimeFormat =>
      'Invalid time format. Use HH:MM:SS.';
  String get adjustTiming => 'Adjust timing';
  String get startTimeLabel => 'Start time';
  String get endTimeLabel => 'End time';
  String get samplePacks => 'Sample Packs';
  String get libraryOpenVideoAction => 'Open Video';
  String get libraryFoldersSection => 'Folders';
  String get libraryBrowseVideos => 'Browse Videos';
  String get libraryChooseFolder => 'Choose folder';
  String get libraryFolderScanRestricted =>
      'Cannot list videos in this folder on this device. Use Open Video to pick a file instead.';
  String get libraryFolderEmpty => 'No videos found in this folder';
  String get libraryRemoveFolder => 'Remove folder';

  // Settings
  String get settingsAboutSection => 'About';
  String get settingsAboutTagline =>
      'Mobile VEIL player and lightweight track builder';
  String get settingsAboutDesktopTracks => 'Desktop-compatible VEIL tracks';
  String get settingsAboutBuildNote => 'Early development build';
  String get settingsAboutDeveloper => 'Developer: Allam Zedan';
  String get settingsPlaybackSection => 'Playback';
  String get settingsAutoplayNextVideo => 'Autoplay next video';
  String get settingsAutoplayNextVideoSubtitle =>
      'When a video ends, automatically play the suggested next video after a short countdown.';
  String get settingsLegalSection => 'Legal';
  String get settingsPrivacyPolicy => 'Privacy Policy';
  String get settingsPrivacyPolicyValue => 'View in app';
  String get settingsTermsOfUse => 'Terms of Use';
  String get settingsTermsOfUseValue => 'View in app';
  String get legalArabicTranslationNotice =>
      'Arabic legal translation coming later. The English document below applies for now.';
  String get legalDocumentLoadError =>
      'Could not load this legal document. Try again later.';
  String get settingsVersion => 'Version';
  String get settingsVersionValue => AppVersion.settingsDisplay;

  // Navigation errors
  String get routeNotFoundTitle => 'Page not found';
  String get routeNotFoundMessage =>
      'That screen is not available. Return home and try again.';
  String get routeGoHome => 'Go to Home';
  String get openIntentUnexpectedError =>
      'Could not open the selected file. Try again or pick the file from inside the app.';

  // Language
  String get settingsLanguageSection => 'Language';
  String get settingsLanguageSystem => 'System Default';
  String get settingsLanguageEnglish => 'English';
  String get settingsLanguageArabic => 'Arabic';

  // Plan / monetization (planning only)
  String get settingsPlanSection => 'Plan';
  String get settingsCurrentPlan => 'Current plan';
  String get settingsCurrentPlanFree => 'Free';
  String get settingsProFeatures => 'Pro features';
  String get settingsProFeaturesValue => 'Coming later';
  String get settingsUpgrade => 'Upgrade to Pro';
  String get settingsUpgradeComingLater => 'Coming later';

  // Diagnostics / beta QA
  String get settingsDiagnosticsSection => 'Diagnostics';
  String get settingsOpenDiagnostics => 'Diagnostics';
  String get settingsOpenDiagnosticsSubtitle =>
      'Beta QA tools and bug reports';
  String get diagnosticsTitle => 'Diagnostics';
  String get diagnosticsAppInfoSection => 'App info';
  String get diagnosticsHealthSection => 'Runtime health';
  String get diagnosticsQaChecklistSection => 'QA checklist';
  String get diagnosticsExportButton => 'Export diagnostics';
  String get diagnosticsExportSuccess => 'Diagnostics report shared';
  String get diagnosticsExportFailed => 'Could not export diagnostics';
  String get diagnosticsLabelAppVersion => 'App version';
  String get diagnosticsLabelPlatform => 'Platform';
  String get diagnosticsLabelLocale => 'Locale';
  String get diagnosticsLabelThemeMode => 'Theme';
  String get diagnosticsThemeDark => 'Dark';
  String get diagnosticsLabelPlan => 'Plan';
  String get diagnosticsLabelBuildMode => 'Build mode';
  String get diagnosticsLabelPackageId => 'Package id';
  String get diagnosticsLabelDartSdk => 'Dart SDK';
  String get diagnosticsBuildDebug => 'Debug';
  String get diagnosticsBuildProfile => 'Profile';
  String get diagnosticsBuildRelease => 'Release';
  String get diagnosticsHealthTrackLoaded => 'Track loaded';
  String get diagnosticsHealthVideoLoaded => 'Video loaded';
  String get diagnosticsHealthSubtitleLoaded => 'Subtitle loaded';
  String get diagnosticsHealthRuntimeActive => 'VEIL runtime active';
  String get diagnosticsStatusYes => 'Yes';
  String get diagnosticsStatusNo => 'No';
  String get qaChecklistOpenMp4 => 'Open MP4 video';
  String get qaChecklistOpenVeilJson => 'Open VEIL JSON track';
  String get qaChecklistCreateMask => 'Create mask segment';
  String get qaChecklistExportTrack => 'Export track';
  String get qaChecklistFullscreen => 'Fullscreen playback';
  String get qaChecklistSubtitles => 'Load subtitles';
  String get qaChecklistArabicUi => 'Arabic UI';
  String get qaChecklistSessionRestore => 'Session restore';
  String get qaChecklistOpenWithIntent => 'Open With from file manager';
  String get qaChecklistSegmentManager => 'Segment manager CRUD';

  // Recovery / autosave
  String get settingsRecoverySection => 'Recovery';
  String get settingsOpenRecovery => 'Recovery';
  String get settingsOpenRecoverySubtitle =>
      'View or restore unsaved VEIL drafts';
  String get recoveryTitle => 'Recovery';
  String get recoveryDraftFoundTitle => 'Unsaved VEIL draft found';
  String recoveryDraftFoundMessage(String trackTitle) =>
      'Restore your unsaved work on "$trackTitle"?';
  String get recoveryDraftFoundMultipleMessage =>
      'Unsaved Player and Track Builder drafts were found. Restore the most recent, or open Recovery in Settings.';
  String get recoveryRestore => 'Restore';
  String get recoveryDismiss => 'Dismiss';
  String get recoveryDiscardDraft => 'Discard draft';
  String get recoveryDraftRestored => 'Draft restored';
  String get recoveryDraftDiscarded => 'Draft discarded';
  String get recoveryRestoreFailed => 'Could not restore this draft';
  String get recoveryNoDrafts => 'No recovery drafts';
  String get recoveryPlayerDraft => 'Player draft';
  String get recoveryTrackBuilderDraft => 'Track Builder draft';
  String get recoverySourcePlayer => 'Player';
  String get recoverySourceTrackBuilder => 'Track Builder';
  String get recoverySegmentCount => 'Segments';
  String get recoveryUpdatedAt => 'Updated';
  String get recoveryDirty => 'Unsaved';

  // Track preview & details
  String get trackDetailsTitle => 'Track Details';
  String get trackSummarySection => 'Track Summary';
  String get trackAffectedTimeSection => 'Affected Time';
  String get trackTotalActions => 'Total Actions';
  String get trackViewAllSegments => 'View All Segments';
  String get trackPreviewTrack => 'Preview Track';
  String get trackPreviewDialogTitle => 'Track Preview';
  String get trackPreviewLoad => 'Load Track';
  String get trackViewTrackDetails => 'View Track Details';
  String get trackVideoSection => 'Video';
  String get trackMetadataSection => 'Metadata';
  String get trackFingerprintMethod => 'Fingerprint Method';
  String get trackVideoUnknown => 'Unknown';
  String get trackCreatedLabel => 'Created';
  String get trackUpdatedLabel => 'Updated';
  String get trackActionPreviewSection => 'Actions';

  String trackAffectedSeconds(double seconds) {
    final rounded = (seconds * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) {
      return '${rounded.toInt()} sec';
    }
    return '$rounded sec';
  }

  String trackExportSummary({
    required int totalActions,
    required int maskCount,
    required int muteCount,
    required int skipCount,
  }) {
    return 'Track: $totalActions actions\n'
        'Masks: $maskCount\n'
        'Mutes: $muteCount\n'
        'Skips: $skipCount';
  }

  // Immersive player
  String get playerEmptyMediaTitle => 'Open a Video';
  String get playerEmptyOpenWithHint => 'or use Open With from Android';

  String playerVeilActionsIndicator(int actionCount) {
    return 'VEIL • $actionCount actions';
  }

  // Track packs
  String get libraryTrackPacksSection => 'Track Packs';
  String get trackPackImport => 'Import Pack';
  String get trackPackExport => 'Export Pack';
  String get trackPackSelectTracks => 'Select Tracks';
  String get trackPackCancelSelection => 'Cancel';
  String get trackPackExportSelected => 'Export as Pack';
  String get trackPackNoPacks => 'No track packs yet. Import a .veilpack.json file.';
  String get trackPackPreviewTitle => 'Import Track Pack';
  String get trackPackImportAction => 'Import';
  String get trackPackImportSuccess => 'Track pack imported.';
  String get trackPackDeleteSuccess => 'Track pack removed.';
  String get trackPackExportSuccess => 'Track pack exported.';
  String get trackPackExportFailed => 'Could not export track pack.';
  String get trackPackImportFailed => 'Could not import track pack.';
  String get trackPackDetailsTitle => 'Pack Details';
  String get trackPackAuthorLabel => 'Author';
  String get trackPackTrackCountLabel => 'Tracks';
  String get trackPackTagsLabel => 'Tags';
  String get trackPackTrackListTitle => 'Tracks in Pack';
  String get trackPackNoTracks => 'This pack has no tracks.';
  String get trackPackTrackDecodeFailed => 'Could not read track data.';
  String get trackPackExportDialogTitle => 'Export Track Pack';
  String get trackPackTitleLabel => 'Pack title';
  String get trackPackDescriptionLabel => 'Description';
  String get trackPackTagsInputLabel => 'Tags (comma-separated)';
  String get trackPackDeleteTitle => 'Delete Track Pack';
  String trackPackDeleteMessage(String title) => 'Remove "$title" from your library?';
  String trackPackMeta({required String author, required int trackCount}) =>
      '$author • $trackCount tracks';

  String trackPackTrackStats({
    required int maskCount,
    required int muteCount,
    required int skipCount,
  }) {
    return 'Masks: $maskCount • Mutes: $muteCount • Skips: $skipCount';
  }
}
