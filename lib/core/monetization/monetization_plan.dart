import 'package:veil_mobile/core/monetization/entitlement.dart';

/// Catalog of VEIL Mobile capabilities for free vs pro planning.
enum VeilFeature {
  // Free — currently implemented
  videoPlayback,
  loadVeilTracks,
  createEditLocalTracks,
  maskMuteSkipRuntime,
  quickActions,
  subtitles,
  recentSessions,
  exportImportBasicTracks,

  // Pro — planned, not implemented
  aiAssistedTrackCreation,
  batchProcessing,
  advancedSubtitleTools,
  cloudSync,
  crossDeviceWorkspace,
  premiumExportWorkflows,
  collaboration,
  advancedAnalytics,
}

/// Describes which tier a feature belongs to in the product plan.
abstract final class MonetizationPlan {
  static const Set<VeilFeature> freeFeatures = {
    VeilFeature.videoPlayback,
    VeilFeature.loadVeilTracks,
    VeilFeature.createEditLocalTracks,
    VeilFeature.maskMuteSkipRuntime,
    VeilFeature.quickActions,
    VeilFeature.subtitles,
    VeilFeature.recentSessions,
    VeilFeature.exportImportBasicTracks,
  };

  static const Set<VeilFeature> proFeatures = {
    VeilFeature.aiAssistedTrackCreation,
    VeilFeature.batchProcessing,
    VeilFeature.advancedSubtitleTools,
    VeilFeature.cloudSync,
    VeilFeature.crossDeviceWorkspace,
    VeilFeature.premiumExportWorkflows,
    VeilFeature.collaboration,
    VeilFeature.advancedAnalytics,
  };

  static bool isFreeFeature(VeilFeature feature) =>
      freeFeatures.contains(feature);

  static bool isProFeature(VeilFeature feature) =>
      proFeatures.contains(feature);

  static bool isPlannedOnly(VeilFeature feature) =>
      proFeatures.contains(feature);
}

/// Whether [entitlement] may use [feature].
///
/// v1: all implemented (free) features return `true`. Pro-only planned
/// features return `false` until built and entitled. Nothing in the app
/// gates core playback or track editing on this yet.
bool canUseFeature(Entitlement entitlement, VeilFeature feature) {
  if (MonetizationPlan.isFreeFeature(feature)) {
    return true;
  }
  if (MonetizationPlan.isProFeature(feature)) {
    return entitlement.isPro;
  }
  return false;
}
