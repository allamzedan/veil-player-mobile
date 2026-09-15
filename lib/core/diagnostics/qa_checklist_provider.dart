import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/diagnostics/qa_checklist.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';

const _storageKey = 'qa_checklist_completed';

final qaChecklistProvider =
    NotifierProvider<QaChecklistController, Set<String>>(
      QaChecklistController.new,
    );

class QaChecklistController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final stored =
        ref.read(sharedPreferencesProvider).getStringList(_storageKey) ??
        const <String>[];
    return stored.toSet();
  }

  bool isCompleted(QaChecklistItemId item) => state.contains(item.storageKey);

  Future<void> setCompleted(QaChecklistItemId item, bool completed) async {
    final next = Set<String>.from(state);
    if (completed) {
      next.add(item.storageKey);
    } else {
      next.remove(item.storageKey);
    }
    state = next;
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_storageKey, next.toList()..sort());
  }
}
