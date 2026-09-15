import 'package:veil_mobile/core/localization/app_localizations.dart';

/// Manual QA checklist items derived from [docs/qa_checklist.md] concepts.
enum QaChecklistItemId {
  openMp4,
  openVeilJson,
  createMask,
  exportTrack,
  fullscreen,
  subtitles,
  arabicUi,
  sessionRestore,
  openWithIntent,
  segmentManager,
}

extension QaChecklistItemIdX on QaChecklistItemId {
  String get storageKey => name;

  String label(AppLocalizations strings) => switch (this) {
    QaChecklistItemId.openMp4 => strings.qaChecklistOpenMp4,
    QaChecklistItemId.openVeilJson => strings.qaChecklistOpenVeilJson,
    QaChecklistItemId.createMask => strings.qaChecklistCreateMask,
    QaChecklistItemId.exportTrack => strings.qaChecklistExportTrack,
    QaChecklistItemId.fullscreen => strings.qaChecklistFullscreen,
    QaChecklistItemId.subtitles => strings.qaChecklistSubtitles,
    QaChecklistItemId.arabicUi => strings.qaChecklistArabicUi,
    QaChecklistItemId.sessionRestore => strings.qaChecklistSessionRestore,
    QaChecklistItemId.openWithIntent => strings.qaChecklistOpenWithIntent,
    QaChecklistItemId.segmentManager => strings.qaChecklistSegmentManager,
  };

  /// English label for exported bug reports.
  String exportLabel() => switch (this) {
    QaChecklistItemId.openMp4 => 'Open MP4 video',
    QaChecklistItemId.openVeilJson => 'Open VEIL JSON track',
    QaChecklistItemId.createMask => 'Create mask segment',
    QaChecklistItemId.exportTrack => 'Export track',
    QaChecklistItemId.fullscreen => 'Fullscreen playback',
    QaChecklistItemId.subtitles => 'Load subtitles',
    QaChecklistItemId.arabicUi => 'Arabic UI',
    QaChecklistItemId.sessionRestore => 'Session restore',
    QaChecklistItemId.openWithIntent => 'Open With from file manager',
    QaChecklistItemId.segmentManager => 'Segment manager CRUD',
  };
}

const List<QaChecklistItemId> qaChecklistItems = QaChecklistItemId.values;
