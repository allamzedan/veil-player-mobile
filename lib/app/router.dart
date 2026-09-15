import 'package:go_router/go_router.dart';
import 'package:veil_mobile/app/external_file_route.dart';
import 'package:veil_mobile/core/legal/legal_document.dart';
import 'package:veil_mobile/features/home/presentation/home_screen.dart';
import 'package:veil_mobile/features/library/presentation/library_screen.dart';
import 'package:veil_mobile/features/player/presentation/player_screen.dart';
import 'package:veil_mobile/features/settings/presentation/diagnostics_screen.dart';
import 'package:veil_mobile/features/settings/presentation/legal_document_screen.dart';
import 'package:veil_mobile/features/settings/presentation/recovery_screen.dart';
import 'package:veil_mobile/features/settings/presentation/settings_screen.dart';
import 'package:veil_mobile/shared/widgets/route_error_screen.dart';
import 'package:veil_mobile/features/track_builder/presentation/track_builder_screen.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String library = '/library';
  static const String player = '/player';
  static const String trackBuilder = '/track-builder';
  static const String settings = '/settings';
  static const String settingsDiagnostics = '/settings/diagnostics';
  static const String settingsRecovery = '/settings/recovery';
  static const String settingsPrivacy = '/settings/privacy';
  static const String settingsTerms = '/settings/terms';

  static String trackBuilderEdit(String trackId) => '$trackBuilder/$trackId';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  redirect: (context, state) {
    final uri = state.uri;
    if (isExternalFileUri(uri) || isExternalFileRoute(state.uri.toString())) {
      return AppRoutes.home;
    }
    return null;
  },
  errorBuilder: (context, state) =>
      RouteErrorScreen(location: state.uri.toString()),
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: HomeScreen()),
    ),
    GoRoute(
      path: AppRoutes.library,
      name: 'library',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: LibraryScreen()),
    ),
    GoRoute(
      path: AppRoutes.player,
      name: 'player',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: PlayerScreen()),
    ),
    GoRoute(
      path: AppRoutes.trackBuilder,
      name: 'track-builder',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: TrackBuilderScreen()),
      routes: [
        GoRoute(
          path: ':trackId',
          name: 'track-builder-edit',
          pageBuilder: (context, state) {
            final trackId = state.pathParameters['trackId']!;
            return NoTransitionPage(
              child: TrackBuilderScreen(trackId: trackId),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SettingsScreen()),
      routes: [
        GoRoute(
          path: 'diagnostics',
          name: 'settings-diagnostics',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DiagnosticsScreen()),
        ),
        GoRoute(
          path: 'recovery',
          name: 'settings-recovery',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: RecoveryScreen()),
        ),
        GoRoute(
          path: 'privacy',
          name: 'settings-privacy',
          pageBuilder: (context, state) => NoTransitionPage(
            child: LegalDocumentScreen(
              documentId: LegalDocumentId.privacyPolicy,
              title: AppStrings.settingsPrivacyPolicy,
            ),
          ),
        ),
        GoRoute(
          path: 'terms',
          name: 'settings-terms',
          pageBuilder: (context, state) => NoTransitionPage(
            child: LegalDocumentScreen(
              documentId: LegalDocumentId.termsOfUse,
              title: AppStrings.settingsTermsOfUse,
            ),
          ),
        ),
      ],
    ),
  ],
);
