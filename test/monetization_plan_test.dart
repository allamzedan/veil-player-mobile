import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/monetization/entitlement.dart';
import 'package:veil_mobile/core/monetization/monetization_plan.dart';

void main() {
  group('MonetizationPlan', () {
    test('free and pro feature sets do not overlap', () {
      expect(
        MonetizationPlan.freeFeatures.intersection(
          MonetizationPlan.proFeatures,
        ),
        isEmpty,
      );
    });

    test('every VeilFeature is classified as free or pro', () {
      for (final feature in VeilFeature.values) {
        final isFree = MonetizationPlan.isFreeFeature(feature);
        final isPro = MonetizationPlan.isProFeature(feature);
        expect(isFree || isPro, isTrue);
        expect(isFree && isPro, isFalse);
      }
    });
  });

  group('canUseFeature', () {
    test('free tier allows all implemented free features', () {
      for (final feature in MonetizationPlan.freeFeatures) {
        expect(canUseFeature(Entitlement.free, feature), isTrue);
      }
    });

    test('free tier denies planned pro features', () {
      for (final feature in MonetizationPlan.proFeatures) {
        expect(canUseFeature(Entitlement.free, feature), isFalse);
      }
    });

    test('pro tier allows all features', () {
      for (final feature in VeilFeature.values) {
        expect(canUseFeature(Entitlement.pro, feature), isTrue);
      }
    });
  });
}
