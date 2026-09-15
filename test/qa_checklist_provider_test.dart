import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/core/diagnostics/qa_checklist.dart';
import 'package:veil_mobile/core/diagnostics/qa_checklist_provider.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';

void main() {
  group('QaChecklistController', () {
    Future<ProviderContainer> createContainer() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      return ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    }

    test('persists completed checklist items', () async {
      final container = await createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(qaChecklistProvider.notifier);
      expect(notifier.isCompleted(QaChecklistItemId.openMp4), isFalse);

      await notifier.setCompleted(QaChecklistItemId.openMp4, true);
      expect(container.read(qaChecklistProvider), {'openMp4'});
      expect(notifier.isCompleted(QaChecklistItemId.openMp4), isTrue);

      await notifier.setCompleted(QaChecklistItemId.openMp4, false);
      expect(container.read(qaChecklistProvider), isEmpty);
    });
  });
}
