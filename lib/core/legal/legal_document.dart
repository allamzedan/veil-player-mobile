/// Bundled legal document identifiers.
enum LegalDocumentId {
  privacyPolicy(
    assetPath: 'docs/legal/privacy_policy.md',
  ),
  termsOfUse(
    assetPath: 'docs/legal/terms_of_use.md',
  );

  const LegalDocumentId({required this.assetPath});

  final String assetPath;
}
