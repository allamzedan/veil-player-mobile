import 'package:veil_mobile/core/localization/app_localizations.dart';
import 'package:veil_mobile/core/localization/app_localizations_holder.dart';

/// Backward-compatible access to localized strings.
abstract final class AppStrings {
  static AppLocalizations get _l => AppLocalizationsHolder.current;

  static String get appName => _l.appName;
  static String get homeTitle => _l.homeTitle;
  static String get libraryTitle => _l.libraryTitle;
  static String get playerTitle => _l.playerTitle;
  static String get trackBuilderTitle => _l.trackBuilderTitle;
  static String get settingsTitle => _l.settingsTitle;
  static String get navHome => _l.navHome;
  static String get navLibrary => _l.navLibrary;
  static String get navPlayer => _l.navPlayer;
  static String get navBuilder => _l.navBuilder;
  static String get navSettings => _l.navSettings;
  static String get homeDescription => _l.homeDescription;
  static String get openPlayer => _l.openPlayer;
  static String get openPlayerSubtitle => _l.openPlayerSubtitle;
  static String get openVideo => _l.openVideo;
  static String get openVideoSubtitle => _l.openVideoSubtitle;
  static String get trackBuilderCard => _l.trackBuilderCard;
  static String get trackBuilderCardSubtitle => _l.trackBuilderCardSubtitle;
  static String get openLibrary => _l.openLibrary;
  static String get openLibrarySubtitle => _l.openLibrarySubtitle;
  static String get libraryEmptyTitle => _l.libraryEmptyTitle;
  static String get libraryEmptyMessage => _l.libraryEmptyMessage;
  static String get libraryLoadError => _l.libraryLoadError;
  static String get libraryRefresh => _l.libraryRefresh;
  static String get libraryCreateTrack => _l.libraryCreateTrack;
  static String get libraryEditTrack => _l.libraryEditTrack;
  static String get libraryValidationValid => _l.libraryValidationValid;
  static String get libraryValidationInvalid => _l.libraryValidationInvalid;
  static String get librarySavedTracksSection => _l.librarySavedTracksSection;
  static String get libraryRecentVideosSection => _l.libraryRecentVideosSection;
  static String get libraryRecentTracksSection => _l.libraryRecentTracksSection;
  static String get libraryLastSessionSection => _l.libraryLastSessionSection;
  static String get libraryNoRecentVideos => _l.libraryNoRecentVideos;
  static String get libraryNoRecentTracks => _l.libraryNoRecentTracks;
  static String get libraryNoLastSession => _l.libraryNoLastSession;
  static String get libraryOpenVideo => _l.libraryOpenVideo;
  static String get libraryOpenTrack => _l.libraryOpenTrack;
  static String get libraryRemoveFromHistory => _l.libraryRemoveFromHistory;
  static String get libraryResumeSession => _l.libraryResumeSession;
  static String get libraryHistoryRemoved => _l.libraryHistoryRemoved;
  static String get continueLastSession => _l.continueLastSession;
  static String get lastSessionUnavailable => _l.lastSessionUnavailable;
  static String get mediaHistorySourceUnavailable => _l.mediaHistorySourceUnavailable;
  static String get openIntentFileUnavailable => _l.openIntentFileUnavailable;
  static String get trackNotFound => _l.trackNotFound;
  static String get playerEmptyTitle => _l.playerEmptyTitle;
  static String get playerOpenVideo => _l.playerOpenVideo;
  static String get playerLoadTrack => _l.playerLoadTrack;
  static String get playerNoVideoSelected => _l.playerNoVideoSelected;
  static String get playerInfoVideo => _l.playerInfoVideo;
  static String get playerInfoTrack => _l.playerInfoTrack;
  static String get playerInfoStatus => _l.playerInfoStatus;
  static String get playerStatusWaiting => _l.playerStatusWaiting;
  static String get playerStatusMissingVideo => _l.playerStatusMissingVideo;
  static String get playerStatusMissingTrack => _l.playerStatusMissingTrack;
  static String get playerOpenVideoShort => _l.playerOpenVideoShort;
  static String get playerLoadTrackShort => _l.playerLoadTrackShort;
  static String get playerNoTrackSelected => _l.playerNoTrackSelected;
  static String get playerSelectedVideo => _l.playerSelectedVideo;
  static String get playerSelectedTrack => _l.playerSelectedTrack;
  static String get playerTrackLoadError => _l.playerTrackLoadError;
  static String get playerVideoPickCancelled => _l.playerVideoPickCancelled;
  static String get playerTrackPickCancelled => _l.playerTrackPickCancelled;
  static String get playerSetupIntro => _l.playerSetupIntro;
  static String get playerClearVideo => _l.playerClearVideo;
  static String get playerClearTrack => _l.playerClearTrack;
  static String get playerStartPlayback => _l.playerStartPlayback;
  static String get playerReadyForPlayback => _l.playerReadyForPlayback;
  static String get playerReadyWithVeilTrack => _l.playerReadyWithVeilTrack;
  static String get playerVideoReady => _l.playerVideoReady;
  static String get playerVideoPlaybackUnavailable => _l.playerVideoPlaybackUnavailable;
  static String playerVideoTooLarge(int bytes) => _l.playerVideoTooLarge(bytes);
  static String get playerOpenVideoHelper => _l.playerOpenVideoHelper;
  static String get playerAddVeilTrackSuggestion => _l.playerAddVeilTrackSuggestion;
  static String get playerVeilActive => _l.playerVeilActive;
  static String get playerRuntimeEffectsDivider => _l.playerRuntimeEffectsDivider;
  static String get playerDetails => _l.playerDetails;
  static String get playerChangeVideo => _l.playerChangeVideo;
  static String get playerLoadVeilTrack => _l.playerLoadVeilTrack;
  static String get playerVideoInitializing => _l.playerVideoInitializing;
  static String get playerValidationWarnings => _l.playerValidationWarnings;
  static String get playerErrorNoVideo => _l.playerErrorNoVideo;
  static String get playerErrorNoTrack => _l.playerErrorNoTrack;
  static String get playerErrorInvalidTrack => _l.playerErrorInvalidTrack;
  static String get playerWarningVideoNameMismatch => _l.playerWarningVideoNameMismatch;
  static String get playerTrackSegments => _l.playerTrackSegments;
  static String get playerTrackSegmentsTitle => _l.playerTrackSegmentsTitle;
  static String get playerNoSegmentsYet => _l.playerNoSegmentsYet;
  static String get playerSegmentJumpTo => _l.playerSegmentJumpTo;
  static String get playerSegmentDuplicate => _l.playerSegmentDuplicate;
  static String get playerSegmentDeleteTitle => _l.playerSegmentDeleteTitle;
  static String get playerSegmentDeleteMessage => _l.playerSegmentDeleteMessage;
  static String get playerMaskEditorTitle => _l.playerMaskEditorTitle;
  static String get playerMaskEditPosition => _l.playerMaskEditPosition;
  static String get playerSegmentStartTime => _l.playerSegmentStartTime;
  static String get playerSegmentEndTime => _l.playerSegmentEndTime;
  static String get playerTrackVideoMeta => _l.playerTrackVideoMeta;
  static String get playerVideoSize => _l.playerVideoSize;
  static String get playerFullscreen => _l.playerFullscreen;
  static String get playerExitFullscreen => _l.playerExitFullscreen;
  static String get playerSubtitles => _l.playerSubtitles;
  static String get playerSubtitlesOff => _l.playerSubtitlesOff;
  static String get playerSubtitlesOn => _l.playerSubtitlesOn;
  static String get playerPickSubtitle => _l.playerPickSubtitle;
  static String get playerReplaceSubtitle => _l.playerReplaceSubtitle;
  static String get playerSubtitleLoadError => _l.playerSubtitleLoadError;
  static String get playerSubtitleEmpty => _l.playerSubtitleEmpty;
  static String get playerSubtitleSettings => _l.playerSubtitleSettings;
  static String get playerSubtitleSettingsTitle => _l.playerSubtitleSettingsTitle;
  static String get playerSubtitleFontSize => _l.playerSubtitleFontSize;
  static String get playerSubtitleFontSizeSmall => _l.playerSubtitleFontSizeSmall;
  static String get playerSubtitleFontSizeMedium =>
      _l.playerSubtitleFontSizeMedium;
  static String get playerSubtitleFontSizeLarge => _l.playerSubtitleFontSizeLarge;
  static String get playerSubtitlePosition => _l.playerSubtitlePosition;
  static String get playerSubtitlePositionBottom => _l.playerSubtitlePositionBottom;
  static String get playerSubtitlePositionMiddle =>
      _l.playerSubtitlePositionMiddle;
  static String get playerSubtitlePositionTop => _l.playerSubtitlePositionTop;
  static String get playerSubtitleBackground => _l.playerSubtitleBackground;
  static String get playerSubtitleBackgroundOpacity =>
      _l.playerSubtitleBackgroundOpacity;
  static String get playerSubtitleDelay => _l.playerSubtitleDelay;
  static String get playerSubtitleDelayReset => _l.playerSubtitleDelayReset;
  static String get playerSubtitleDelayMinus500 => _l.playerSubtitleDelayMinus500;
  static String get playerSubtitleDelayMinus100 => _l.playerSubtitleDelayMinus100;
  static String get playerSubtitleDelayPlus100 => _l.playerSubtitleDelayPlus100;
  static String get playerSubtitleDelayPlus500 => _l.playerSubtitleDelayPlus500;
  static String get playerPlaybackSpeed => _l.playerPlaybackSpeed;
  static String get playerSeekBackOverlay => _l.playerSeekBackOverlay;
  static String get playerSeekForwardOverlay => _l.playerSeekForwardOverlay;
  static String get playerSpeedBoostOverlay => _l.playerSpeedBoostOverlay;
  static String playerVolumeOverlay(int percent) =>
      _l.playerVolumeOverlay(percent);
  static String playerBrightnessOverlay(int percent) =>
      _l.playerBrightnessOverlay(percent);
  static String get playerVeilQuickAction => _l.playerVeilQuickAction;
  static String get playerQuickAddMask => _l.playerQuickAddMask;
  static String get playerQuickAddMute => _l.playerQuickAddMute;
  static String get playerQuickAddSkip => _l.playerQuickAddSkip;
  static String get playerQuickAddBookmark => _l.playerQuickAddBookmark;
  static String get playerBookmarks => _l.playerBookmarks;
  static String get playerBookmarksEmpty => _l.playerBookmarksEmpty;
  static String get playerEndScreenTitle => _l.playerEndScreenTitle;
  static String get playerReplay => _l.playerReplay;
  static String get playerPlayNext => _l.playerPlayNext;
  static String get playerChooseVideo => _l.playerChooseVideo;
  static String playerEndCountdown(int seconds) => _l.playerEndCountdown(seconds);
  static String get playerOpenManualBuilder => _l.playerOpenManualBuilder;
  static String get playerQuickActionTitle => _l.playerQuickActionTitle;
  static String get playerQuickActionAt => _l.playerQuickActionAt;
  static String get playerQuickDuration => _l.playerQuickDuration;
  static String get playerQuickDuration3s => _l.playerQuickDuration3s;
  static String get playerQuickDuration5s => _l.playerQuickDuration5s;
  static String get playerQuickDuration10s => _l.playerQuickDuration10s;
  static String get playerQuickDurationCustom => _l.playerQuickDurationCustom;
  static String get playerQuickCustomSecondsHint => _l.playerQuickCustomSecondsHint;
  static String get playerQuickInvalidDuration => _l.playerQuickInvalidDuration;
  static String get playerQuickActionRequiresVideo => _l.playerQuickActionRequiresVideo;
  static String get playerQuickActionAdded => _l.playerQuickActionAdded;
  static String get playerQuickActionAddedHint => _l.playerQuickActionAddedHint;
  static String get playerExportTrack => _l.playerExportTrack;
  static String get playerPreviewJson => _l.playerPreviewJson;
  static String get playerExportTrackSuccess => _l.playerExportTrackSuccess;
  static String get playerExportTrackFailed => _l.playerExportTrackFailed;
  static String get playerUnsavedTrackHint => _l.playerUnsavedTrackHint;
  static String get playerQuickMaskPlacementTitle => _l.playerQuickMaskPlacementTitle;
  static String get playerQuickMaskPlacementHint => _l.playerQuickMaskPlacementHint;
  static String get playerQuickMaskConfirm => _l.playerQuickMaskConfirm;
  static String get addSegment => _l.addSegment;
  static String get trackTitleLabel => _l.trackTitleLabel;
  static String get trackTitleHint => _l.trackTitleHint;
  static String get validationValid => _l.validationValid;
  static String get validationInvalid => _l.validationInvalid;
  static String get validationRequiresAttention => _l.validationRequiresAttention;
  static String get validationFixHint => _l.validationFixHint;
  static String get noSegmentsTitle => _l.noSegmentsTitle;
  static String get noSegmentsMessage => _l.noSegmentsMessage;
  static String get trackBuilderNoActionsYet => _l.trackBuilderNoActionsYet;
  static String get trackBuilderSegmentSearchHint =>
      _l.trackBuilderSegmentSearchHint;
  static String get trackBuilderNoMatchingActions =>
      _l.trackBuilderNoMatchingActions;
  static String get trackBuilderFilterAll => _l.trackBuilderFilterAll;
  static String get trackBuilderFilterMasks => _l.trackBuilderFilterMasks;
  static String get trackBuilderFilterMutes => _l.trackBuilderFilterMutes;
  static String get trackBuilderFilterSkips => _l.trackBuilderFilterSkips;
  static String trackBuilderActionsTotal(int count) =>
      _l.trackBuilderActionsTotal(count);
  static String trackBuilderMaskCount(int count) =>
      _l.trackBuilderMaskCount(count);
  static String trackBuilderMuteCount(int count) =>
      _l.trackBuilderMuteCount(count);
  static String trackBuilderSkipCount(int count) =>
      _l.trackBuilderSkipCount(count);
  static String get trackBuilderQuickAddMask => _l.trackBuilderQuickAddMask;
  static String get trackBuilderQuickAddMute => _l.trackBuilderQuickAddMute;
  static String get trackBuilderQuickAddSkip => _l.trackBuilderQuickAddSkip;
  static String get trackBuilderQuickAddBookmark => _l.trackBuilderQuickAddBookmark;
  static String get trackBuilderFilterBookmarks => _l.trackBuilderFilterBookmarks;
  static String trackBuilderBookmarkCount(int count) =>
      _l.trackBuilderBookmarkCount(count);
  static String get jsonPreview => _l.jsonPreview;
  static String get jsonPreviewTitle => _l.jsonPreviewTitle;
  static String get close => _l.close;
  static String get newTrack => _l.newTrack;
  static String get segmentCount => _l.segmentCount;
  static String get saveTrack => _l.saveTrack;
  static String get importJson => _l.importJson;
  static String get importJsonFromFile => _l.importJsonFromFile;
  static String get importJsonPaste => _l.importJsonPaste;
  static String get exportJson => _l.exportJson;
  static String get moreActions => _l.moreActions;
  static String get copyJson => _l.copyJson;
  static String get copyJsonSuccess => _l.copyJsonSuccess;
  static String get importJsonTitle => _l.importJsonTitle;
  static String get importJsonHint => _l.importJsonHint;
  static String get importJsonAction => _l.importJsonAction;
  static String get exportJsonTitle => _l.exportJsonTitle;
  static String get saveSuccess => _l.saveSuccess;
  static String get saveValidationFailed => _l.saveValidationFailed;
  static String get importSuccess => _l.importSuccess;
  static String get importValidationFailed => _l.importValidationFailed;
  static String get importInvalidJson => _l.importInvalidJson;
  static String get storageUnknownError => _l.storageUnknownError;
  static String get storageWriteFailedKeepVideoOpen =>
      _l.storageWriteFailedKeepVideoOpen;
  static String get widgetBuildErrorFallback => _l.widgetBuildErrorFallback;
  static String get delete => _l.delete;
  static String get deleteSuccess => _l.deleteSuccess;
  static String get deleteNotSaved => _l.deleteNotSaved;
  static String get deleteTrackTitle => _l.deleteTrackTitle;
  static String get untitledTrack => _l.untitledTrack;
  static String get newTrackConfirmTitle => _l.newTrackConfirmTitle;
  static String get newTrackConfirmMessage => _l.newTrackConfirmMessage;
  static String get continueAction => _l.continueAction;
  static String get trackStatusSaved => _l.trackStatusSaved;
  static String get trackStatusLoaded => _l.trackStatusLoaded;
  static String get trackStatusImported => _l.trackStatusImported;
  static String get trackStatusDraft => _l.trackStatusDraft;
  static String get trackStatusNew => _l.trackStatusNew;
  static String get trackStatusUnsaved => _l.trackStatusUnsaved;
  static String get trackStatusReadyToSave => _l.trackStatusReadyToSave;
  static String get trackStatusSavedIdle => _l.trackStatusSavedIdle;
  static String get trackMetadataTitle => _l.trackMetadataTitle;
  static String get trackMetadataCollapsedHint => _l.trackMetadataCollapsedHint;
  static String get trackMetadataNone => _l.trackMetadataNone;
  static String get trackMetadataNoneExpanded => _l.trackMetadataNoneExpanded;
  static String get trackVideoName => _l.trackVideoName;
  static String get trackSourceApp => _l.trackSourceApp;
  static String get trackSourceAppVersion => _l.trackSourceAppVersion;
  static String get trackVideoDuration => _l.trackVideoDuration;
  static String get trackVideoResolution => _l.trackVideoResolution;
  static String get trackGlobalOffset => _l.trackGlobalOffset;
  static String get trackExportedAt => _l.trackExportedAt;
  static String get trackSubtitleCover => _l.trackSubtitleCover;
  static String get trackSubtitleCoverPresent => _l.trackSubtitleCoverPresent;
  static String get segmentEnabled => _l.segmentEnabled;
  static String get segmentDisabled => _l.segmentDisabled;
  static String get untitledVeilTrack => _l.untitledVeilTrack;
  static String get segmentEdit => _l.segmentEdit;
  static String get segmentDelete => _l.segmentDelete;
  static String get segmentStart => _l.segmentStart;
  static String get segmentEnd => _l.segmentEnd;
  static String get segmentLabel => _l.segmentLabel;
  static String get segmentNotes => _l.segmentNotes;
  static String get segmentNoLabel => _l.segmentNoLabel;
  static String get segmentReorder => _l.segmentReorder;
  static String get segmentTypeMask => _l.segmentTypeMask;
  static String get segmentTypeMute => _l.segmentTypeMute;
  static String get segmentTypeSkip => _l.segmentTypeSkip;
  static String get segmentTypeMarker => _l.segmentTypeMarker;
  static String get segmentTypeBookmark => _l.segmentTypeBookmark;
  static String get segmentTypeBookmarks => _l.segmentTypeBookmarks;
  static String get bookmarkTitle => _l.bookmarkTitle;
  static String get bookmarkNote => _l.bookmarkNote;
  static String get bookmarkTime => _l.bookmarkTime;
  static String get bookmarkTitleRequired => _l.bookmarkTitleRequired;
  static String get segmentEditorTitleAdd => _l.segmentEditorTitleAdd;
  static String get segmentEditorTitleEdit => _l.segmentEditorTitleEdit;
  static String get segmentTypeField => _l.segmentTypeField;
  static String get segmentStartMs => _l.segmentStartMs;
  static String get segmentEndMs => _l.segmentEndMs;
  static String get segmentTimeHint => _l.segmentTimeHint;
  static String get segmentLabelField => _l.segmentLabelField;
  static String get segmentNotesField => _l.segmentNotesField;
  static String get save => _l.save;
  static String get cancel => _l.cancel;
  static String get segmentEditorInvalidTiming => _l.segmentEditorInvalidTiming;
  static String get segmentEditorInvalidMs => _l.segmentEditorInvalidMs;
  static String get segmentEditorInvalidTimeFormat =>
      _l.segmentEditorInvalidTimeFormat;
  static String get adjustTiming => _l.adjustTiming;
  static String get startTimeLabel => _l.startTimeLabel;
  static String get endTimeLabel => _l.endTimeLabel;
  static String get samplePacks => _l.samplePacks;
  static String get libraryOpenVideoAction => _l.libraryOpenVideoAction;
  static String get libraryFoldersSection => _l.libraryFoldersSection;
  static String get libraryBrowseVideos => _l.libraryBrowseVideos;
  static String get libraryChooseFolder => _l.libraryChooseFolder;
  static String get libraryFolderScanRestricted => _l.libraryFolderScanRestricted;
  static String get libraryFolderEmpty => _l.libraryFolderEmpty;
  static String get libraryRemoveFolder => _l.libraryRemoveFolder;
  static String get settingsAboutSection => _l.settingsAboutSection;
  static String get settingsAboutTagline => _l.settingsAboutTagline;
  static String get settingsAboutDesktopTracks => _l.settingsAboutDesktopTracks;
  static String get settingsAboutBuildNote => _l.settingsAboutBuildNote;
  static String get settingsAboutDeveloper => _l.settingsAboutDeveloper;
  static String get settingsPlaybackSection => _l.settingsPlaybackSection;
  static String get settingsAutoplayNextVideo => _l.settingsAutoplayNextVideo;
  static String get settingsAutoplayNextVideoSubtitle =>
      _l.settingsAutoplayNextVideoSubtitle;
  static String get settingsLegalSection => _l.settingsLegalSection;
  static String get settingsPrivacyPolicy => _l.settingsPrivacyPolicy;
  static String get settingsPrivacyPolicyValue => _l.settingsPrivacyPolicyValue;
  static String get settingsTermsOfUse => _l.settingsTermsOfUse;
  static String get settingsTermsOfUseValue => _l.settingsTermsOfUseValue;
  static String get legalArabicTranslationNotice => _l.legalArabicTranslationNotice;
  static String get legalDocumentLoadError => _l.legalDocumentLoadError;
  static String get settingsVersion => _l.settingsVersion;
  static String get settingsVersionValue => _l.settingsVersionValue;
  static String get routeNotFoundTitle => _l.routeNotFoundTitle;
  static String get routeNotFoundMessage => _l.routeNotFoundMessage;
  static String get routeGoHome => _l.routeGoHome;
  static String get openIntentUnexpectedError => _l.openIntentUnexpectedError;
  static String get settingsLanguageSection => _l.settingsLanguageSection;
  static String get settingsLanguageSystem => _l.settingsLanguageSystem;
  static String get settingsLanguageEnglish => _l.settingsLanguageEnglish;
  static String get settingsLanguageArabic => _l.settingsLanguageArabic;
  static String get settingsPlanSection => _l.settingsPlanSection;
  static String get settingsCurrentPlan => _l.settingsCurrentPlan;
  static String get settingsCurrentPlanFree => _l.settingsCurrentPlanFree;
  static String get settingsProFeatures => _l.settingsProFeatures;
  static String get settingsProFeaturesValue => _l.settingsProFeaturesValue;
  static String get settingsUpgrade => _l.settingsUpgrade;
  static String get settingsUpgradeComingLater => _l.settingsUpgradeComingLater;
  static String get settingsDiagnosticsSection => _l.settingsDiagnosticsSection;
  static String get settingsOpenDiagnostics => _l.settingsOpenDiagnostics;
  static String get settingsOpenDiagnosticsSubtitle => _l.settingsOpenDiagnosticsSubtitle;
  static String get diagnosticsTitle => _l.diagnosticsTitle;
  static String get diagnosticsAppInfoSection => _l.diagnosticsAppInfoSection;
  static String get diagnosticsHealthSection => _l.diagnosticsHealthSection;
  static String get diagnosticsQaChecklistSection => _l.diagnosticsQaChecklistSection;
  static String get diagnosticsExportButton => _l.diagnosticsExportButton;
  static String get diagnosticsExportSuccess => _l.diagnosticsExportSuccess;
  static String get diagnosticsExportFailed => _l.diagnosticsExportFailed;
  static String get diagnosticsLabelAppVersion => _l.diagnosticsLabelAppVersion;
  static String get diagnosticsLabelPlatform => _l.diagnosticsLabelPlatform;
  static String get diagnosticsLabelLocale => _l.diagnosticsLabelLocale;
  static String get diagnosticsLabelThemeMode => _l.diagnosticsLabelThemeMode;
  static String get diagnosticsThemeDark => _l.diagnosticsThemeDark;
  static String get diagnosticsLabelPlan => _l.diagnosticsLabelPlan;
  static String get diagnosticsLabelBuildMode => _l.diagnosticsLabelBuildMode;
  static String get diagnosticsLabelPackageId => _l.diagnosticsLabelPackageId;
  static String get diagnosticsLabelDartSdk => _l.diagnosticsLabelDartSdk;
  static String get diagnosticsBuildDebug => _l.diagnosticsBuildDebug;
  static String get diagnosticsBuildProfile => _l.diagnosticsBuildProfile;
  static String get diagnosticsBuildRelease => _l.diagnosticsBuildRelease;
  static String get diagnosticsHealthTrackLoaded => _l.diagnosticsHealthTrackLoaded;
  static String get diagnosticsHealthVideoLoaded => _l.diagnosticsHealthVideoLoaded;
  static String get diagnosticsHealthSubtitleLoaded => _l.diagnosticsHealthSubtitleLoaded;
  static String get diagnosticsHealthRuntimeActive => _l.diagnosticsHealthRuntimeActive;
  static String get diagnosticsStatusYes => _l.diagnosticsStatusYes;
  static String get diagnosticsStatusNo => _l.diagnosticsStatusNo;
  static String get qaChecklistOpenMp4 => _l.qaChecklistOpenMp4;
  static String get qaChecklistOpenVeilJson => _l.qaChecklistOpenVeilJson;
  static String get qaChecklistCreateMask => _l.qaChecklistCreateMask;
  static String get qaChecklistExportTrack => _l.qaChecklistExportTrack;
  static String get qaChecklistFullscreen => _l.qaChecklistFullscreen;
  static String get qaChecklistSubtitles => _l.qaChecklistSubtitles;
  static String get qaChecklistArabicUi => _l.qaChecklistArabicUi;
  static String get qaChecklistSessionRestore => _l.qaChecklistSessionRestore;
  static String get qaChecklistOpenWithIntent => _l.qaChecklistOpenWithIntent;
  static String get qaChecklistSegmentManager => _l.qaChecklistSegmentManager;
  static String get settingsRecoverySection => _l.settingsRecoverySection;
  static String get settingsOpenRecovery => _l.settingsOpenRecovery;
  static String get settingsOpenRecoverySubtitle => _l.settingsOpenRecoverySubtitle;
  static String get recoveryTitle => _l.recoveryTitle;
  static String get recoveryDraftFoundTitle => _l.recoveryDraftFoundTitle;
  static String get recoveryDraftFoundMultipleMessage => _l.recoveryDraftFoundMultipleMessage;
  static String get recoveryRestore => _l.recoveryRestore;
  static String get recoveryDismiss => _l.recoveryDismiss;
  static String get recoveryDiscardDraft => _l.recoveryDiscardDraft;
  static String get recoveryDraftRestored => _l.recoveryDraftRestored;
  static String get recoveryDraftDiscarded => _l.recoveryDraftDiscarded;
  static String get recoveryRestoreFailed => _l.recoveryRestoreFailed;
  static String get recoveryNoDrafts => _l.recoveryNoDrafts;
  static String get recoveryPlayerDraft => _l.recoveryPlayerDraft;
  static String get recoveryTrackBuilderDraft => _l.recoveryTrackBuilderDraft;
  static String get recoverySourcePlayer => _l.recoverySourcePlayer;
  static String get recoverySourceTrackBuilder => _l.recoverySourceTrackBuilder;
  static String get recoverySegmentCount => _l.recoverySegmentCount;
  static String get recoveryUpdatedAt => _l.recoveryUpdatedAt;
  static String get recoveryDirty => _l.recoveryDirty;
  static String mediaHistorySourceMissing(String filename) => _l.mediaHistorySourceMissing(filename);
  static String lastSessionVideoMissing(String filename) => _l.lastSessionVideoMissing(filename);
  static String lastSessionTrackMissing(String filename) => _l.lastSessionTrackMissing(filename);
  static String lastSessionSubtitleMissing(String filename) => _l.lastSessionSubtitleMissing(filename);
  static String continueLastSessionSubtitle(String videoName) => _l.continueLastSessionSubtitle(videoName);
  static String libraryRecentVideoMeta(String duration, String position) => _l.libraryRecentVideoMeta(duration, position);
  static String libraryRecentTrackMeta(int segmentCount) => _l.libraryRecentTrackMeta(segmentCount);
  static String libraryLastSessionMeta(String position, String speed) => _l.libraryLastSessionMeta(position, speed);
  static String openIntentUnsupportedFile(String filename) => _l.openIntentUnsupportedFile(filename);
  static String playerRuntimeEffectsLabel({
    required bool hasMask,
    required bool hasMute,
    required bool hasSkip,
  }) => _l.playerRuntimeEffectsLabel(hasMask: hasMask, hasMute: hasMute, hasSkip: hasSkip);
  static String playerSubtitleLoaded(int cueCount) => _l.playerSubtitleLoaded(cueCount);
  static String playerVideoSizeLabel(int bytes) => _l.playerVideoSizeLabel(bytes);
  static String formatVideoDuration(double seconds) => _l.formatVideoDuration(seconds);
  static String deleteTrackMessage(String title) => _l.deleteTrackMessage(title);
  static String savedTrackMeta({
    required int segmentCount,
    required String updatedAt,
  }) => _l.savedTrackMeta(segmentCount: segmentCount, updatedAt: updatedAt);
  static String segmentTypeLabel(String typeName) => _l.segmentTypeLabel(typeName);
  static String recoveryDraftFoundMessage(String trackTitle) => _l.recoveryDraftFoundMessage(trackTitle);
  static String get trackDetailsTitle => _l.trackDetailsTitle;
  static String get trackSummarySection => _l.trackSummarySection;
  static String get trackAffectedTimeSection => _l.trackAffectedTimeSection;
  static String get trackTotalActions => _l.trackTotalActions;
  static String get trackViewAllSegments => _l.trackViewAllSegments;
  static String get trackPreviewTrack => _l.trackPreviewTrack;
  static String get trackPreviewDialogTitle => _l.trackPreviewDialogTitle;
  static String get trackPreviewLoad => _l.trackPreviewLoad;
  static String get trackViewTrackDetails => _l.trackViewTrackDetails;
  static String get trackVideoSection => _l.trackVideoSection;
  static String get trackMetadataSection => _l.trackMetadataSection;
  static String get trackFingerprintMethod => _l.trackFingerprintMethod;
  static String get trackVideoUnknown => _l.trackVideoUnknown;
  static String get trackCreatedLabel => _l.trackCreatedLabel;
  static String get trackUpdatedLabel => _l.trackUpdatedLabel;
  static String get trackActionPreviewSection => _l.trackActionPreviewSection;
  static String trackAffectedSeconds(double seconds) => _l.trackAffectedSeconds(seconds);
  static String trackExportSummary({
    required int totalActions,
    required int maskCount,
    required int muteCount,
    required int skipCount,
  }) => _l.trackExportSummary(
    totalActions: totalActions,
    maskCount: maskCount,
    muteCount: muteCount,
    skipCount: skipCount,
  );
  static String get playerEmptyMediaTitle => _l.playerEmptyMediaTitle;
  static String get playerEmptyOpenWithHint => _l.playerEmptyOpenWithHint;
  static String playerVeilActionsIndicator(int actionCount) =>
      _l.playerVeilActionsIndicator(actionCount);
  static String get libraryTrackPacksSection => _l.libraryTrackPacksSection;
  static String get trackPackImport => _l.trackPackImport;
  static String get trackPackExport => _l.trackPackExport;
  static String get trackPackSelectTracks => _l.trackPackSelectTracks;
  static String get trackPackCancelSelection => _l.trackPackCancelSelection;
  static String get trackPackExportSelected => _l.trackPackExportSelected;
  static String get trackPackNoPacks => _l.trackPackNoPacks;
  static String get trackPackPreviewTitle => _l.trackPackPreviewTitle;
  static String get trackPackImportAction => _l.trackPackImportAction;
  static String get trackPackImportSuccess => _l.trackPackImportSuccess;
  static String get trackPackDeleteSuccess => _l.trackPackDeleteSuccess;
  static String get trackPackExportSuccess => _l.trackPackExportSuccess;
  static String get trackPackExportFailed => _l.trackPackExportFailed;
  static String get trackPackImportFailed => _l.trackPackImportFailed;
  static String get trackPackDetailsTitle => _l.trackPackDetailsTitle;
  static String get trackPackAuthorLabel => _l.trackPackAuthorLabel;
  static String get trackPackTrackCountLabel => _l.trackPackTrackCountLabel;
  static String get trackPackTagsLabel => _l.trackPackTagsLabel;
  static String get trackPackTrackListTitle => _l.trackPackTrackListTitle;
  static String get trackPackNoTracks => _l.trackPackNoTracks;
  static String get trackPackTrackDecodeFailed => _l.trackPackTrackDecodeFailed;
  static String get trackPackExportDialogTitle => _l.trackPackExportDialogTitle;
  static String get trackPackTitleLabel => _l.trackPackTitleLabel;
  static String get trackPackDescriptionLabel => _l.trackPackDescriptionLabel;
  static String get trackPackTagsInputLabel => _l.trackPackTagsInputLabel;
  static String get trackPackDeleteTitle => _l.trackPackDeleteTitle;
  static String trackPackDeleteMessage(String title) =>
      _l.trackPackDeleteMessage(title);
  static String trackPackMeta({
    required String author,
    required int trackCount,
  }) => _l.trackPackMeta(author: author, trackCount: trackCount);
  static String trackPackTrackStats({
    required int maskCount,
    required int muteCount,
    required int skipCount,
  }) => _l.trackPackTrackStats(
    maskCount: maskCount,
    muteCount: muteCount,
    skipCount: skipCount,
  );
}
