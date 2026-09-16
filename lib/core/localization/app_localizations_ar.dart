part of 'app_localizations.dart';

class AppLocalizationsAr extends AppLocalizations {
  const AppLocalizationsAr() : super._(AppLanguageCode.ar);

  @override
  String get appName => 'VEIL Player Mobile';

  // Route titles
  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get libraryTitle => 'المكتبة';

  @override
  String get playerTitle => 'المشغّل';

  @override
  String get trackBuilderTitle => 'منشئ المسارات';

  @override
  String get settingsTitle => 'الإعدادات';

  // Navigation labels
  @override
  String get navHome => 'الرئيسية';

  @override
  String get navLibrary => 'المكتبة';

  @override
  String get navPlayer => 'المشغّل';

  @override
  String get navBuilder => 'المنشئ';

  @override
  String get navSettings => 'الإعدادات';

  // Home
  @override
  String get homeDescription => 'شاهد الفيديو مع مسارات VEIL على جهازك.';

  @override
  String get openPlayer => 'فتح المشغّل';

  @override
  String get openPlayerSubtitle =>
      'اختر فيديو ومسار VEIL لتحضير التشغيل.';

  @override
  String get openVideo => 'فتح فيديو';

  @override
  String get openVideoSubtitle => 'اختر فيديو من جهازك وابدأ المشاهدة.';

  @override
  String get trackBuilderCard => 'منشئ المسارات';

  @override
  String get trackBuilderCardSubtitle =>
      'إنشاء وتعديل مسارات VEIL على الهاتف.';

  @override
  String get openLibrary => 'المكتبة';

  @override
  String get openLibrarySubtitle =>
      'الفيديوهات والمسارات الأخيرة وجلستك الأخيرة.';

  // Library
  @override
  String get libraryEmptyTitle => 'لا توجد مسارات محفوظة';

  @override
  String get libraryEmptyMessage =>
      'أنشئ مسارًا في منشئ المسارات واحفظه، وسيظهر هنا.';

  @override
  String get libraryLoadError => 'تعذّر تحميل المسارات المحفوظة';

  @override
  String get libraryRefresh => 'تحديث';

  @override
  String get libraryCreateTrack => 'مسار جديد';

  @override
  String get libraryEditTrack => 'تعديل';

  @override
  String get libraryValidationValid => 'صالح';

  @override
  String get libraryValidationInvalid => 'يحتوي على مشاكل';

  @override
  String get librarySavedTracksSection => 'المسارات المحفوظة';

  // Media history
  @override
  String get libraryRecentVideosSection => 'الفيديوهات الأخيرة';

  @override
  String get libraryRecentTracksSection => 'المسارات الأخيرة';

  @override
  String get libraryLastSessionSection => 'الجلسة الأخيرة';

  @override
  String get libraryNoRecentVideos => 'لا توجد فيديوهات حديثة بعد';

  @override
  String get libraryNoRecentTracks => 'لا توجد مسارات حديثة بعد';

  @override
  String get libraryNoLastSession => 'لا توجد جلسة محفوظة بعد';

  @override
  String get libraryOpenVideo => 'فتح';

  @override
  String get libraryOpenTrack => 'فتح';

  @override
  String get libraryRemoveFromHistory => 'إزالة من السجل';

  @override
  String get libraryResumeSession => 'استئناف';

  @override
  String get libraryHistoryRemoved => 'تمت الإزالة من السجل';

  @override
  String get continueLastSession => 'متابعة الجلسة الأخيرة';

  @override
  String get lastSessionUnavailable => 'لا توجد جلسة محفوظة للاستئناف';

  @override
  String get mediaHistorySourceUnavailable =>
      'لا يمكن إعادة فتح هذا العنصر على هذا الجهاز.';

  @override
  String mediaHistorySourceMissing(String filename) =>
      'الملف "$filename" لم يعد متاحًا على هذا الجهاز.';

  @override
  String lastSessionVideoMissing(String filename) =>
      'الفيديو "$filename" لم يعد متاحًا على هذا الجهاز.';

  @override
  String lastSessionTrackMissing(String filename) =>
      'المسار "$filename" لم يعد متاحًا على هذا الجهاز.';

  @override
  String lastSessionSubtitleMissing(String filename) =>
      'ملف الترجمة "$filename" لم يعد متاحًا على هذا الجهاز.';

  @override
  String continueLastSessionSubtitle(String videoName) =>
      'استئناف $videoName من حيث توقفت.';

  @override
  String libraryRecentVideoMeta(String duration, String position) =>
      '$duration · استُئنف عند $position';

  @override
  String libraryRecentTrackMeta(int segmentCount) =>
      segmentCount == 1 ? 'مقطع واحد' : '$segmentCount مقاطع';

  @override
  String libraryLastSessionMeta(String position, String speed) =>
      '$position · $speed';

  // Android Open With
  @override
  String get openIntentFileUnavailable =>
      'تعذّر فتح الملف المحدد على هذا الجهاز.';

  @override
  String openIntentUnsupportedFile(String filename) =>
      'لا يمكن لـ VEIL Player Mobile فتح "$filename". جرّب ملف فيديو أو مسار VEIL بصيغة JSON.';

  @override
  String get trackNotFound => 'لم يُعثر على المسار المحفوظ';

  @override
  String get playerEmptyTitle => 'التشغيل';

  @override
  String get playerOpenVideo => 'فتح فيديو';

  @override
  String get playerLoadTrack => 'تحميل مسار VEIL';

  @override
  String get playerNoVideoSelected => 'لم يُحدَّد فيديو';

  @override
  String get playerInfoVideo => 'الفيديو';

  @override
  String get playerInfoTrack => 'المسار';

  @override
  String get playerInfoStatus => 'الحالة';

  @override
  String get playerStatusWaiting => 'في انتظار الإعداد';

  @override
  String get playerStatusMissingVideo => 'الفيديو مفقود';

  @override
  String get playerStatusMissingTrack => 'المسار مفقود';

  @override
  String get playerOpenVideoShort => 'فتح فيديو';

  @override
  String get playerLoadTrackShort => 'تحميل مسار';

  @override
  String get playerNoTrackSelected => 'لم يُحمَّل مسار VEIL';

  @override
  String get playerSelectedVideo => 'الفيديو المحدد';

  @override
  String get playerSelectedTrack => 'المسار المحمّل';

  @override
  String get playerTrackLoadError =>
      'تعذّر تحميل ملف مسار VEIL المحدد.';

  @override
  String get playerVideoPickCancelled => 'تم إلغاء اختيار الفيديو';

  @override
  String get playerTrackPickCancelled => 'تم إلغاء اختيار المسار';

  @override
  String get playerSetupIntro =>
      'حضّر فيديو ومسار VEIL للتشغيل.';

  @override
  String get playerClearVideo => 'مسح الفيديو';

  @override
  String get playerClearTrack => 'مسح المسار';

  @override
  String get playerStartPlayback => 'بدء التشغيل';

  @override
  String get playerReadyForPlayback => 'جاهز للتشغيل';

  @override
  String get playerReadyWithVeilTrack => 'جاهز مع مسار VEIL';

  @override
  String get playerVideoReady => 'الفيديو جاهز';

  @override
  String get playerVideoPlaybackUnavailable =>
      'تم اختيار الفيديو، لكن التشغيل المحلي غير متاح في هذه البيئة.';

  @override
  String playerVideoTooLarge(int bytes) {
    if (bytes > 0) {
      return 'يتجاوز هذا الفيديو (${playerVideoSizeLabel(bytes)}) حد 500 ميجابايت في هذه النسخة التجريبية. جرّب ملفًا أصغر أو افتحه من مدير ملفات يمنح وصولًا مباشرًا.';
    }
    return 'يتجاوز هذا الفيديو حد 500 ميجابايت في هذه النسخة التجريبية. جرّب ملفًا أصغر.';
  }

  @override
  String get playerOpenVideoHelper => 'افتح فيديو للبدء';

  @override
  String get playerAddVeilTrackSuggestion => 'إضافة مسار VEIL؟';

  @override
  String get playerVeilActive => 'VEIL نشط';

  @override
  String get playerRuntimeEffectsDivider => ' / ';

  @override
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

  @override
  String get playerDetails => 'التفاصيل';

  @override
  String get playerChangeVideo => 'فتح فيديو آخر';

  @override
  String get playerLoadVeilTrack => 'تحميل مسار VEIL';

  @override
  String get playerVideoInitializing => 'جارٍ تحميل الفيديو…';

  @override
  String get playerValidationWarnings => 'تحذيرات';

  @override
  String get playerErrorNoVideo => 'حدّد ملف فيديو للمتابعة.';

  @override
  String get playerErrorNoTrack => 'حمّل مسار VEIL للمتابعة.';

  @override
  String get playerErrorInvalidTrack => 'مسار VEIL المحدد غير صالح.';

  @override
  String get playerWarningVideoNameMismatch =>
      'اسم فيديو المسار لا يطابق الملف المحدد بشكل وثيق.';

  @override
  String get playerTrackSegments => 'المقاطع';

  @override
  String get playerTrackSegmentsTitle => 'مقاطع المسار';

  @override
  String get playerNoSegmentsYet => 'لا توجد إجراءات VEIL بعد';

  @override
  String get playerSegmentJumpTo => 'الانتقال إلى';

  @override
  String get playerSegmentDuplicate => 'تكرار';

  @override
  String get playerSegmentDeleteTitle => 'حذف المقطع؟';

  @override
  String get playerSegmentDeleteMessage =>
      'سيُزال إجراء VEIL هذا من المسار.';

  @override
  String get playerMaskEditorTitle => 'محرّر القناع';

  @override
  String get playerMaskEditPosition => 'تعديل الموضع والحجم';

  @override
  String get playerSegmentStartTime => 'وقت البداية (بالثواني)';

  @override
  String get playerSegmentEndTime => 'وقت النهاية (بالثواني)';

  @override
  String get playerTrackVideoMeta => 'بيانات فيديو المسار';

  @override
  String get playerVideoSize => 'حجم الملف';

  @override
  String get playerFullscreen => 'ملء الشاشة';

  @override
  String get playerExitFullscreen => 'الخروج من ملء الشاشة';

  @override
  String get playerSubtitles => 'الترجمة';

  @override
  String get playerSubtitlesOff => 'الترجمة معطّلة';

  @override
  String get playerSubtitlesOn => 'الترجمة مفعّلة';

  @override
  String get playerPickSubtitle => 'اختيار ملف ترجمة';

  @override
  String get playerReplaceSubtitle => 'استبدال ملف الترجمة';

  @override
  String get playerSubtitleLoadError =>
      'تعذّر تحميل ملف الترجمة المحدد.';

  @override
  String get playerSubtitleEmpty =>
      'لم يُعثر على عناصر ترجمة في هذا الملف.';

  @override
  String playerSubtitleLoaded(int cueCount) => cueCount == 1
      ? 'تم تحميل عنصر ترجمة واحد.'
      : 'تم تحميل $cueCount عناصر ترجمة.';

  @override
  String get playerSubtitleSettings => 'إعدادات الترجمة';

  @override
  String get playerSubtitleSettingsTitle => 'إعدادات الترجمة';

  @override
  String get playerSubtitleFontSize => 'حجم الخط';

  @override
  String get playerSubtitleFontSizeSmall => 'صغير';

  @override
  String get playerSubtitleFontSizeMedium => 'متوسط';

  @override
  String get playerSubtitleFontSizeLarge => 'كبير';

  @override
  String get playerSubtitlePosition => 'الموضع';

  @override
  String get playerSubtitlePositionBottom => 'أسفل';

  @override
  String get playerSubtitlePositionMiddle => 'وسط';

  @override
  String get playerSubtitlePositionTop => 'أعلى';

  @override
  String get playerSubtitleBackground => 'الخلفية';

  @override
  String get playerSubtitleBackgroundOpacity => 'شفافية الخلفية';

  @override
  String get playerSubtitleDelay => 'التأخير';

  @override
  String get playerSubtitleDelayReset => 'إعادة ضبط';

  @override
  String get playerSubtitleDelayMinus500 => '-500ms';

  @override
  String get playerSubtitleDelayMinus100 => '-100ms';

  @override
  String get playerSubtitleDelayPlus100 => '+100ms';

  @override
  String get playerSubtitleDelayPlus500 => '+500ms';

  @override
  String get playerPlaybackSpeed => 'سرعة التشغيل';

  @override
  String get playerSeekBackOverlay => '-10s';

  @override
  String get playerSeekForwardOverlay => '+10s';

  @override
  String get playerSpeedBoostOverlay => '2x';

  @override
  String playerVolumeOverlay(int percent) => 'الصوت $percent%';

  @override
  String playerBrightnessOverlay(int percent) => 'السطوع $percent%';

  @override
  String get playerVeilQuickAction => 'VEIL';

  @override
  String get playerQuickAddMask => 'إضافة قناع';

  @override
  String get playerQuickAddMute => 'إضافة كتم';

  @override
  String get playerQuickAddSkip => 'إضافة تخطّي';

  @override
  String get playerQuickAddBookmark => 'إشارة مرجعية';

  @override
  String get playerBookmarks => 'الإشارات المرجعية';

  @override
  String get playerBookmarksEmpty => 'لا توجد إشارات مرجعية على هذا المسار بعد.';

  @override
  String get playerEndScreenTitle => 'التالي';

  @override
  String get playerReplay => 'إعادة';

  @override
  String get playerPlayNext => 'التالي';

  @override
  String get playerChooseVideo => 'اختر فيديو';

  @override
  String playerEndCountdown(int seconds) => 'التالي خلال $seconds…';

  @override
  String get playerOpenManualBuilder => 'فتح المنشئ اليدوي';

  @override
  String get playerQuickActionTitle => 'إجراء سريع';

  @override
  String get playerQuickActionAt => 'عند وقت التشغيل';

  @override
  String get playerQuickDuration => 'المدة';

  @override
  String get playerQuickDuration3s => '3 ثوانٍ';

  @override
  String get playerQuickDuration5s => '5 ثوانٍ';

  @override
  String get playerQuickDuration10s => '10 ثوانٍ';

  @override
  String get playerQuickDurationCustom => 'مخصّص';

  @override
  String get playerQuickCustomSecondsHint => 'ثوانٍ';

  @override
  String get playerQuickInvalidDuration => 'أدخل مدة صالحة.';

  @override
  String get playerQuickActionRequiresVideo =>
      'افتح فيديو قبل إضافة إجراءات VEIL.';

  @override
  String get playerQuickActionAdded => 'تمت إضافة إجراء VEIL';

  @override
  String get playerQuickActionAddedHint => 'صدّره للاحتفاظ به';

  @override
  String get playerExportTrack => 'تصدير المسار';

  @override
  String get playerPreviewJson => 'معاينة JSON';

  @override
  String get playerExportTrackSuccess => 'تم تصدير ملف المسار.';

  @override
  String get playerExportTrackFailed => 'تعذّر تصدير ملف المسار.';

  @override
  String get playerUnsavedTrackHint => 'تغييرات غير محفوظة في المسار';

  @override
  String get playerQuickMaskPlacementTitle => 'وضع القناع';

  @override
  String get playerQuickMaskPlacementHint =>
      'اسحب للتحريك. غيّر الحجم من أي مقبض زاوية.';

  @override
  String get playerQuickMaskConfirm => 'تأكيد';

  @override
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
  @override
  String get addSegment => 'إضافة مقطع';

  @override
  String get trackTitleLabel => 'عنوان المسار';

  @override
  String get trackTitleHint => 'أدخل عنوان المسار';

  @override
  String get validationValid => 'المسار صالح';

  @override
  String get validationInvalid => 'مشاكل في التحقق';

  @override
  String get validationRequiresAttention => 'يتطلب انتباهًا';

  @override
  String get validationFixHint =>
      'أصلح هذه المشاكل لحفظ المسار أو تصديره.';

  @override
  String get noSegmentsTitle => 'لا توجد مقاطع';

  @override
  String get noSegmentsMessage => 'أضف مقطعًا لبدء بناء هذا المسار.';

  @override
  String get trackBuilderNoActionsYet => 'لا توجد إجراءات VEIL بعد';

  @override
  String get trackBuilderSegmentSearchHint => 'بحث في الإجراءات';

  @override
  String get trackBuilderNoMatchingActions => 'لا توجد إجراءات مطابقة';

  @override
  String get trackBuilderFilterAll => 'الكل';

  @override
  String get trackBuilderFilterMasks => 'أقنعة';

  @override
  String get trackBuilderFilterMutes => 'كتم';

  @override
  String get trackBuilderFilterSkips => 'تخطّي';

  @override
  String trackBuilderActionsTotal(int count) =>
      count == 1 ? 'إجراء واحد' : '$count إجراءات';

  @override
  String trackBuilderMaskCount(int count) =>
      count == 1 ? 'قناع واحد' : '$count أقنعة';

  @override
  String trackBuilderMuteCount(int count) =>
      count == 1 ? 'كتم واحد' : '$count كتم';

  @override
  String trackBuilderSkipCount(int count) =>
      count == 1 ? 'تخطّي واحد' : '$count تخطّي';

  @override
  String get trackBuilderQuickAddMask => 'قناع';

  @override
  String get trackBuilderQuickAddMute => 'كتم';

  @override
  String get trackBuilderQuickAddSkip => 'تخطّي';

  @override
  String get trackBuilderQuickAddBookmark => 'إشارة مرجعية';

  @override
  String get trackBuilderFilterBookmarks => 'إشارات مرجعية';

  @override
  String trackBuilderBookmarkCount(int count) =>
      count == 1 ? 'إشارة مرجعية واحدة' : '$count إشارات مرجعية';

  @override
  String get jsonPreview => 'معاينة JSON';

  @override
  String get jsonPreviewTitle => 'JSON المسار';

  @override
  String get close => 'إغلاق';

  @override
  String get newTrack => 'مسار جديد';

  @override
  String get segmentCount => 'المقاطع';

  @override
  String get saveTrack => 'حفظ المسار';

  @override
  String get importJson => 'استيراد JSON';

  @override
  String get importJsonFromFile => 'استيراد JSON من ملف';

  @override
  String get importJsonPaste => 'لصق JSON';

  @override
  String get exportJson => 'تصدير JSON';

  @override
  String get moreActions => 'المزيد من الإجراءات';

  @override
  String get copyJson => 'نسخ JSON';

  @override
  String get copyJsonSuccess => 'تم نسخ JSON إلى الحافظة';

  @override
  String get importJsonTitle => 'استيراد JSON المسار';

  @override
  String get importJsonHint => 'الصق JSON مسار VEIL هنا';

  @override
  String get importJsonAction => 'استيراد';

  @override
  String get exportJsonTitle => 'تصدير JSON المسار';

  @override
  String get saveSuccess => 'تم حفظ المسار محليًا';

  @override
  String get saveValidationFailed =>
      'أصلح مشاكل التحقق قبل الحفظ';

  @override
  String get importSuccess => 'تم استيراد المسار';

  @override
  String get importValidationFailed =>
      'المسار المستورد يحتوي على مشاكل في التحقق';

  @override
  String get importInvalidJson =>
      'JSON مسار VEIL غير صالح. تحقق من الصيغة وحاول مجددًا.';

  @override
  String get storageUnknownError => 'فشلت عملية التخزين';

  @override
  String get storageWriteFailedKeepVideoOpen =>
      'فشلت عملية التخزين. الفيديو الحالي ما زال مفتوحًا.';

  @override
  String get widgetBuildErrorFallback =>
      'حدث خطأ أثناء عرض هذه الشاشة.';

  @override
  String get delete => 'حذف';

  @override
  String get deleteSuccess => 'تم حذف المسار';

  @override
  String get deleteNotSaved => 'المسار الحالي غير محفوظ محليًا';

  @override
  String get deleteTrackTitle => 'حذف المسار المحفوظ؟';

  @override
  String get untitledTrack => 'مسار بلا عنوان';

  @override
  String get newTrackConfirmTitle => 'بدء مسار جديد؟';

  @override
  String get newTrackConfirmMessage =>
      'ستُفقد التغييرات غير المحفوظة. المتابعة؟';

  @override
  String get continueAction => 'متابعة';

  @override
  String get trackStatusSaved => 'محفوظ محليًا';

  @override
  String get trackStatusLoaded => 'تم تحميل المسار';

  @override
  String get trackStatusImported => 'تم استيراد المسار';

  @override
  String get trackStatusDraft => 'مسار مسوّدة';

  @override
  String get trackStatusNew => 'تم بدء مسار جديد';

  @override
  String get trackStatusUnsaved => 'تغييرات غير محفوظة';

  @override
  String get trackStatusReadyToSave => 'جاهز للحفظ';

  @override
  String get trackStatusSavedIdle => 'محفوظ';

  @override
  String get trackMetadataTitle => 'بيانات المسار';

  @override
  String get trackMetadataCollapsedHint => 'اضغط للتوسيع';

  @override
  String get trackMetadataNone => 'لا توجد بيانات';

  @override
  String get trackMetadataNoneExpanded =>
      'لا تتوفر بيانات سطح المكتب لهذا المسار.';

  @override
  String get trackVideoName => 'الفيديو';

  @override
  String get trackSourceApp => 'التطبيق المصدر';

  @override
  String get trackSourceAppVersion => 'إصدار المصدر';

  @override
  String get trackVideoDuration => 'المدة';

  @override
  String get trackVideoResolution => 'الدقة';

  @override
  String get trackGlobalOffset => 'الإزاحة العامة';

  @override
  String get trackExportedAt => 'آخر تصدير';

  @override
  String get trackSubtitleCover => 'غلاف الترجمة';

  @override
  String get trackSubtitleCoverPresent => 'مُعدّ';

  @override
  String get segmentEnabled => 'مفعّل';

  @override
  String get segmentDisabled => 'معطّل';

  @override
  String get untitledVeilTrack => 'مسار VEIL بلا عنوان';

  @override
  String formatVideoDuration(double seconds) {
    final totalSeconds = seconds.floor();
    final minutes = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${minutes}m ${secs}s';
  }

  @override
  String deleteTrackMessage(String title) {
    final displayTitle = title.trim().isEmpty ? untitledTrack : title;
    return 'حذف "$displayTitle" من التخزين المحلي؟';
  }

  @override
  String savedTrackMeta({
    required int segmentCount,
    required String updatedAt,
  }) {
    return '$segmentCount مقاطع · آخر تحديث $updatedAt';
  }

  // Segment card
  @override
  String get segmentEdit => 'تعديل المقطع';

  @override
  String get segmentDelete => 'حذف المقطع';

  @override
  String get segmentStart => 'البداية';

  @override
  String get segmentEnd => 'النهاية';

  @override
  String get segmentLabel => 'التسمية';

  @override
  String get segmentNotes => 'ملاحظات';

  @override
  String get segmentNoLabel => 'بلا تسمية';

  @override
  String get segmentReorder => 'إعادة ترتيب المقطع';

  // Segment types
  @override
  String get segmentTypeMask => 'قناع';

  @override
  String get segmentTypeMute => 'كتم';

  @override
  String get segmentTypeSkip => 'تخطّي';

  @override
  String get segmentTypeMarker => 'علامة';

  @override
  String get segmentTypeBookmark => 'إشارة مرجعية';

  @override
  String get segmentTypeBookmarks => 'إشارات مرجعية';

  @override
  String get bookmarkTitle => 'العنوان';

  @override
  String get bookmarkNote => 'ملاحظة (اختياري)';

  @override
  String get bookmarkTime => 'الوقت';

  @override
  String get bookmarkTitleRequired => 'أدخل عنوان الإشارة المرجعية.';

  @override
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
  @override
  String get segmentEditorTitleAdd => 'إضافة مقطع';

  @override
  String get segmentEditorTitleEdit => 'تعديل المقطع';

  @override
  String get segmentTypeField => 'النوع';

  @override
  String get segmentStartMs => 'وقت البداية';

  @override
  String get segmentEndMs => 'وقت النهاية';

  @override
  String get segmentTimeHint => 'HH:MM:SS';

  @override
  String get segmentLabelField => 'التسمية (اختياري)';

  @override
  String get segmentNotesField => 'ملاحظات (اختياري)';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get segmentEditorInvalidTiming =>
      'يجب أن يكون وقت النهاية بعد وقت البداية.';

  @override
  String get segmentEditorInvalidMs =>
      'صيغة وقت غير صالحة. استخدم HH:MM:SS.';

  @override
  String get segmentEditorInvalidTimeFormat =>
      'صيغة وقت غير صالحة. استخدم HH:MM:SS.';

  @override
  String get adjustTiming => 'ضبط التوقيت';

  @override
  String get startTimeLabel => 'وقت البداية';

  @override
  String get endTimeLabel => 'وقت النهاية';

  @override
  String get samplePacks => 'حزم نموذجية';

  @override
  String get libraryOpenVideoAction => 'فتح فيديو';

  @override
  String get libraryFoldersSection => 'المجلدات';

  @override
  String get libraryBrowseVideos => 'تصفح الفيديوهات';

  @override
  String get libraryChooseFolder => 'اختر مجلدًا';

  @override
  String get libraryFolderScanRestricted =>
      'تعذّر عرض الفيديوهات في هذا المجلد على هذا الجهاز. استخدم فتح فيديو لاختيار ملف.';

  @override
  String get libraryFolderEmpty => 'لا توجد فيديوهات في هذا المجلد';

  @override
  String get libraryRemoveFolder => 'إزالة المجلد';

  // Settings
  @override
  String get settingsAboutSection => 'حول التطبيق';

  @override
  String get settingsAboutTagline =>
      'مشغّل VEIL للهاتف ومنشئ مسارات خفيف';

  @override
  String get settingsAboutDesktopTracks =>
      'مسارات VEIL المتوافقة مع سطح المكتب';

  @override
  String get settingsAboutBuildNote => 'إصدار تطوير مبكر';

  @override
  String get settingsAboutDeveloper => 'المطوّر: Allam Zedan';

  @override
  String get settingsPlaybackSection => 'التشغيل';

  @override
  String get settingsAutoplayNextVideo => 'تشغيل الفيديو التالي تلقائيًا';

  @override
  String get settingsAutoplayNextVideoSubtitle =>
      'عند انتهاء الفيديو، تشغيل الفيديو التالي المقترح بعد عدّ تنازلي قصير.';

  @override
  String get settingsLegalSection => 'قانوني';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsPrivacyPolicyValue => 'عرض داخل التطبيق';

  @override
  String get settingsTermsOfUse => 'شروط الاستخدام';

  @override
  String get settingsTermsOfUseValue => 'عرض داخل التطبيق';

  @override
  String get legalArabicTranslationNotice =>
      'الترجمة القانونية العربية قادمة لاحقًا. يُطبَّق النص الإنجليزي أدناه مؤقتًا.';

  @override
  String get legalDocumentLoadError =>
      'تعذّر تحميل هذا المستند القانوني. حاول مجددًا لاحقًا.';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get settingsVersionValue => AppVersion.settingsDisplay;

  // Navigation errors
  @override
  String get routeNotFoundTitle => 'الصفحة غير موجودة';

  @override
  String get routeNotFoundMessage =>
      'هذه الشاشة غير متاحة. ارجع إلى الرئيسية وحاول مجددًا.';

  @override
  String get routeGoHome => 'الذهاب إلى الرئيسية';

  @override
  String get openIntentUnexpectedError =>
      'تعذّر فتح الملف المحدد. حاول مجددًا أو اختر الملف من داخل التطبيق.';

  // Language
  @override
  String get settingsLanguageSection => 'اللغة';

  @override
  String get settingsLanguageSystem => 'افتراضي النظام';

  @override
  String get settingsLanguageEnglish => 'الإنجليزية';

  @override
  String get settingsLanguageArabic => 'العربية';

  // Plan / monetization (planning only)
  @override
  String get settingsPlanSection => 'الخطة';

  @override
  String get settingsCurrentPlan => 'الخطة الحالية';

  @override
  String get settingsCurrentPlanFree => 'مجاني';

  @override
  String get settingsProFeatures => 'ميزات Pro';

  @override
  String get settingsProFeaturesValue => 'قريبًا';

  @override
  String get settingsUpgrade => 'الترقية إلى Pro';

  @override
  String get settingsUpgradeComingLater => 'قريبًا';

  // Diagnostics / beta QA
  @override
  String get settingsDiagnosticsSection => 'التشخيص';

  @override
  String get settingsOpenDiagnostics => 'التشخيص';

  @override
  String get settingsOpenDiagnosticsSubtitle =>
      'أدوات اختبار بيتا وتقارير الأخطاء';

  @override
  String get diagnosticsTitle => 'التشخيص';

  @override
  String get diagnosticsAppInfoSection => 'معلومات التطبيق';

  @override
  String get diagnosticsHealthSection => 'صحة التشغيل';

  @override
  String get diagnosticsQaChecklistSection => 'قائمة فحص QA';

  @override
  String get diagnosticsExportButton => 'تصدير التشخيص';

  @override
  String get diagnosticsExportSuccess => 'تمت مشاركة تقرير التشخيص';

  @override
  String get diagnosticsExportFailed => 'تعذّر تصدير التشخيص';

  @override
  String get diagnosticsLabelAppVersion => 'إصدار التطبيق';

  @override
  String get diagnosticsLabelPlatform => 'المنصّة';

  @override
  String get diagnosticsLabelLocale => 'اللغة';

  @override
  String get diagnosticsLabelThemeMode => 'السمة';

  @override
  String get diagnosticsThemeDark => 'داكن';

  @override
  String get diagnosticsLabelPlan => 'الخطة';

  @override
  String get diagnosticsLabelBuildMode => 'وضع البناء';

  @override
  String get diagnosticsLabelPackageId => 'معرّف الحزمة';

  @override
  String get diagnosticsLabelDartSdk => 'Dart SDK';

  @override
  String get diagnosticsBuildDebug => 'تصحيح';

  @override
  String get diagnosticsBuildProfile => 'ملفّي';

  @override
  String get diagnosticsBuildRelease => 'إصدار';

  @override
  String get diagnosticsHealthTrackLoaded => 'المسار محمّل';

  @override
  String get diagnosticsHealthVideoLoaded => 'الفيديو محمّل';

  @override
  String get diagnosticsHealthSubtitleLoaded => 'الترجمة محمّلة';

  @override
  String get diagnosticsHealthRuntimeActive => 'VEIL نشط';

  @override
  String get diagnosticsStatusYes => 'نعم';

  @override
  String get diagnosticsStatusNo => 'لا';

  @override
  String get qaChecklistOpenMp4 => 'فتح فيديو MP4';

  @override
  String get qaChecklistOpenVeilJson => 'فتح مسار VEIL JSON';

  @override
  String get qaChecklistCreateMask => 'إنشاء مقطع قناع';

  @override
  String get qaChecklistExportTrack => 'تصدير المسار';

  @override
  String get qaChecklistFullscreen => 'تشغيل بملء الشاشة';

  @override
  String get qaChecklistSubtitles => 'تحميل الترجمة';

  @override
  String get qaChecklistArabicUi => 'واجهة عربية';

  @override
  String get qaChecklistSessionRestore => 'استئناف الجلسة';

  @override
  String get qaChecklistOpenWithIntent => 'فتح من مدير الملفات';

  @override
  String get qaChecklistSegmentManager => 'إدارة المقاطع';

  // Recovery / autosave
  @override
  String get settingsRecoverySection => 'الاستعادة';

  @override
  String get settingsOpenRecovery => 'الاستعادة';

  @override
  String get settingsOpenRecoverySubtitle =>
      'عرض أو استعادة مسودات VEIL غير المحفوظة';

  @override
  String get recoveryTitle => 'الاستعادة';

  @override
  String get recoveryDraftFoundTitle => 'تم العثور على مسودة VEIL غير محفوظة';

  @override
  String recoveryDraftFoundMessage(String trackTitle) =>
      'استعادة عملك غير المحفوظ على "$trackTitle"؟';

  @override
  String get recoveryDraftFoundMultipleMessage =>
      'وُجدت مسودات غير محفوظة في المشغّل ومنشئ المسارات. استعد الأحدث أو افتح الاستعادة من الإعدادات.';

  @override
  String get recoveryRestore => 'استعادة';

  @override
  String get recoveryDismiss => 'تجاهل';

  @override
  String get recoveryDiscardDraft => 'حذف المسودة';

  @override
  String get recoveryDraftRestored => 'تمت استعادة المسودة';

  @override
  String get recoveryDraftDiscarded => 'تم حذف المسودة';

  @override
  String get recoveryRestoreFailed => 'تعذّرت استعادة هذه المسودة';

  @override
  String get recoveryNoDrafts => 'لا توجد مسودات استعادة';

  @override
  String get recoveryPlayerDraft => 'مسودة المشغّل';

  @override
  String get recoveryTrackBuilderDraft => 'مسودة منشئ المسارات';

  @override
  String get recoverySourcePlayer => 'المشغّل';

  @override
  String get recoverySourceTrackBuilder => 'منشئ المسارات';

  @override
  String get recoverySegmentCount => 'المقاطع';

  @override
  String get recoveryUpdatedAt => 'آخر تحديث';

  @override
  String get recoveryDirty => 'غير محفوظ';

  // Track preview & details
  @override
  String get trackDetailsTitle => 'تفاصيل المسار';

  @override
  String get trackSummarySection => 'ملخص المسار';

  @override
  String get trackAffectedTimeSection => 'الوقت المتأثر';

  @override
  String get trackTotalActions => 'إجمالي الإجراءات';

  @override
  String get trackViewAllSegments => 'عرض كل المقاطع';

  @override
  String get trackPreviewTrack => 'معاينة المسار';

  @override
  String get trackPreviewDialogTitle => 'معاينة المسار';

  @override
  String get trackPreviewLoad => 'تحميل المسار';

  @override
  String get trackViewTrackDetails => 'عرض تفاصيل المسار';

  @override
  String get trackVideoSection => 'الفيديو';

  @override
  String get trackMetadataSection => 'البيانات الوصفية';

  @override
  String get trackFingerprintMethod => 'طريقة البصمة';

  @override
  String get trackVideoUnknown => 'غير معروف';

  @override
  String get trackCreatedLabel => 'تاريخ الإنشاء';

  @override
  String get trackUpdatedLabel => 'تاريخ التحديث';

  @override
  String get trackActionPreviewSection => 'الإجراءات';

  @override
  String trackAffectedSeconds(double seconds) {
    final rounded = (seconds * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) {
      return '${rounded.toInt()} ث';
    }
    return '$rounded ث';
  }

  @override
  String trackExportSummary({
    required int totalActions,
    required int maskCount,
    required int muteCount,
    required int skipCount,
  }) {
    return 'المسار: $totalActions إجراء\n'
        'أقنعة: $maskCount\n'
        'كتم: $muteCount\n'
        'تخطّي: $skipCount';
  }

  @override
  String get playerEmptyMediaTitle => 'افتح فيديو';

  @override
  String get playerEmptyOpenWithHint => 'أو استخدم "فتح باستخدام" من أندرويد';

  @override
  String playerVeilActionsIndicator(int actionCount) {
    return 'VEIL • $actionCount إجراء';
  }

  @override
  String get libraryTrackPacksSection => 'حزم المسارات';

  @override
  String get trackPackImport => 'استيراد حزمة';

  @override
  String get trackPackExport => 'تصدير حزمة';

  @override
  String get trackPackSelectTracks => 'تحديد المسارات';

  @override
  String get trackPackCancelSelection => 'إلغاء';

  @override
  String get trackPackExportSelected => 'تصدير كحزمة';

  @override
  String get trackPackNoPacks =>
      'لا توجد حزم مسارات بعد. استورد ملف .veilpack.json.';

  @override
  String get trackPackPreviewTitle => 'استيراد حزمة مسارات';

  @override
  String get trackPackImportAction => 'استيراد';

  @override
  String get trackPackImportSuccess => 'تم استيراد حزمة المسارات.';

  @override
  String get trackPackDeleteSuccess => 'تمت إزالة حزمة المسارات.';

  @override
  String get trackPackExportSuccess => 'تم تصدير حزمة المسارات.';

  @override
  String get trackPackExportFailed => 'تعذّر تصدير حزمة المسارات.';

  @override
  String get trackPackImportFailed => 'تعذّر استيراد حزمة المسارات.';

  @override
  String get trackPackDetailsTitle => 'تفاصيل الحزمة';

  @override
  String get trackPackAuthorLabel => 'المؤلف';

  @override
  String get trackPackTrackCountLabel => 'المسارات';

  @override
  String get trackPackTagsLabel => 'الوسوم';

  @override
  String get trackPackTrackListTitle => 'مسارات الحزمة';

  @override
  String get trackPackNoTracks => 'لا تحتوي هذه الحزمة على مسارات.';

  @override
  String get trackPackTrackDecodeFailed => 'تعذّر قراءة بيانات المسار.';

  @override
  String get trackPackExportDialogTitle => 'تصدير حزمة مسارات';

  @override
  String get trackPackTitleLabel => 'عنوان الحزمة';

  @override
  String get trackPackDescriptionLabel => 'الوصف';

  @override
  String get trackPackTagsInputLabel => 'الوسوم (مفصولة بفواصل)';

  @override
  String get trackPackDeleteTitle => 'حذف حزمة المسارات';

  @override
  String trackPackDeleteMessage(String title) =>
      'إزالة "$title" من المكتبة؟';

  @override
  String trackPackMeta({required String author, required int trackCount}) =>
      '$author • $trackCount مسارات';

  @override
  String trackPackTrackStats({
    required int maskCount,
    required int muteCount,
    required int skipCount,
  }) {
    return 'أقنعة: $maskCount • كتم: $muteCount • تخطّي: $skipCount';
  }
}
