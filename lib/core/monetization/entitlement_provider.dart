import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/monetization/entitlement.dart';
import 'package:veil_mobile/core/monetization/monetization_plan.dart';

/// Current user entitlement. Always [Entitlement.free] until billing exists.
final entitlementProvider = Provider<Entitlement>((ref) {
  return Entitlement.free;
});

/// Convenience for feature checks in widgets and controllers.
bool canUseFeatureForRef(WidgetRef ref, VeilFeature feature) {
  return canUseFeature(ref.read(entitlementProvider), feature);
}

/// Convenience for feature checks without Riverpod.
bool canUseCurrentFeature(VeilFeature feature) {
  return canUseFeature(Entitlement.free, feature);
}
