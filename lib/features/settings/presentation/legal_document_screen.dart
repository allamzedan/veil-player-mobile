import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/legal/legal_document.dart';
import 'package:veil_mobile/core/localization/app_locale.dart';
import 'package:veil_mobile/core/localization/localization_provider.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/widgets/app_scaffold.dart';

class LegalDocumentScreen extends ConsumerWidget {
  const LegalDocumentScreen({
    super.key,
    required this.documentId,
    required this.title,
  });

  final LegalDocumentId documentId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(resolvedLocaleProvider);
    final showArabicNotice = locale.languageCode == AppLanguageCode.ar;

    return AppScaffold(
      title: title,
      showBackButton: true,
      body: FutureBuilder<String>(
        future: rootBundle.loadString(documentId.assetPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(AppStrings.legalDocumentLoadError),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              if (showArabicNotice) ...[
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      AppStrings.legalArabicTranslationNotice,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              LegalMarkdownBody(markdown: snapshot.data!),
            ],
          );
        },
      ),
    );
  }
}

/// Minimal markdown rendering for legal documents (headings, bullets, body).
class LegalMarkdownBody extends StatelessWidget {
  const LegalMarkdownBody({super.key, required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[];

    for (final line in markdown.split('\n')) {
      final trimmed = line.trimRight();
      if (trimmed.isEmpty) {
        children.add(const SizedBox(height: 8));
        continue;
      }

      if (trimmed.startsWith('# ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              trimmed.substring(2),
              style: theme.textTheme.titleLarge,
            ),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('## ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 6),
            child: Text(
              trimmed.substring(3),
              style: theme.textTheme.titleMedium,
            ),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('- ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(
                  child: Text(
                    trimmed.substring(2),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('> ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              trimmed.substring(2),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
        continue;
      }

      if (trimmed == '---') {
        children.add(const Divider(height: 24));
        continue;
      }

      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            trimmed,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: trimmed.startsWith('**') && trimmed.endsWith('**')
                  ? FontWeight.w600
                  : null,
            ),
          ),
        ),
      );
    }

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
