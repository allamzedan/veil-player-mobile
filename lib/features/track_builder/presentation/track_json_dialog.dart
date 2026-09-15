import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

/// Shows formatted VEIL track JSON in a scrollable, selectable dialog.
Future<void> showTrackJsonDialog({
  required BuildContext context,
  required String title,
  required String json,
  bool enableCopy = true,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: SelectableText(
            json,
            style: Theme.of(
              dialogContext,
            ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
        ),
      ),
      actions: [
        if (enableCopy)
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(AppStrings.copyJsonSuccess)),
                );
              }
            },
            child: Text(AppStrings.copyJson),
          ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(AppStrings.close),
        ),
      ],
    ),
  );
}
