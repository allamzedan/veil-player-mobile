import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/app/open_intent_bootstrap.dart';
import 'package:veil_mobile/app/veil_mobile_app.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

void main() {
  testWidgets('Home screen loads', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const OpenIntentBootstrap(child: VeilMobileApp()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.homeTitle), findsWidgets);
    expect(find.text(AppStrings.homeDescription), findsOneWidget);
  });
}
