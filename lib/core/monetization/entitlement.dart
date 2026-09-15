/// User subscription tier (planning only — no billing in v1).
enum MonetizationTier { free, pro }

/// Active entitlement for the current user session.
class Entitlement {
  const Entitlement({required this.tier});

  final MonetizationTier tier;

  bool get isPro => tier == MonetizationTier.pro;
  bool get isFree => tier == MonetizationTier.free;

  static const free = Entitlement(tier: MonetizationTier.free);
  static const pro = Entitlement(tier: MonetizationTier.pro);
}
