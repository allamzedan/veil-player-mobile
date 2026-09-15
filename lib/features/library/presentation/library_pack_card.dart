import 'package:flutter/material.dart';
import 'package:veil_mobile/core/track_packs/track_pack.dart';
import 'package:veil_mobile/core/track_packs/track_pack_summary.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

class LibraryPackCard extends StatelessWidget {
  const LibraryPackCard({
    super.key,
    required this.pack,
    required this.onOpen,
    required this.onExport,
    required this.onDelete,
  });

  final TrackPack pack;
  final VoidCallback onOpen;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = TrackPackSummary.fromPack(pack);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 4, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      summary.title,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.trackPackMeta(
                        author: summary.author,
                        trackCount: summary.trackCount,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (summary.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        summary.tags.join(', '),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<_PackMenuAction>(
                onSelected: (action) {
                  switch (action) {
                    case _PackMenuAction.export:
                      onExport();
                    case _PackMenuAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _PackMenuAction.export,
                    child: Text(AppStrings.trackPackExport),
                  ),
                  PopupMenuItem(
                    value: _PackMenuAction.delete,
                    child: Text(AppStrings.delete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PackMenuAction { export, delete }
