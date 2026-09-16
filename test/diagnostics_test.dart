import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/diagnostics/diagnostics_report_builder.dart';
import 'package:veil_mobile/core/diagnostics/diagnostics_snapshot.dart';
import 'package:veil_mobile/core/diagnostics/runtime_health.dart';
import 'package:veil_mobile/core/localization/app_locale.dart';
import 'package:veil_mobile/features/player/application/player_runtime_state.dart';
import 'package:veil_mobile/features/player/application/player_setup_state.dart';

void main() {
  group('RuntimeHealthChecker', () {
    test('evaluates loaded media and runtime flags', () {
      const setup = PlayerSetupState(
        selectedTrack: null,
        videoPlaybackStatus: PlayerVideoPlaybackStatus.ready,
        subtitleCues: [],
      );
      const runtime = PlayerRuntimeState(isRuntimeEnabled: false);

      final health = RuntimeHealthChecker.evaluate(setup: setup, runtime: runtime);

      expect(health.videoLoaded, isTrue);
      expect(health.trackLoaded, isFalse);
      expect(health.subtitleLoaded, isFalse);
      expect(health.runtimeActive, isFalse);
    });
  });

  group('DiagnosticsReportBuilder', () {
    test('includes app, health, player, and QA checklist sections', () {
      const setup = PlayerSetupState(
        selectedVideoName: 'clip.mp4',
        selectedTrackTitle: 'Demo track',
        videoPlaybackStatus: PlayerVideoPlaybackStatus.ready,
      );
      const runtime = PlayerRuntimeState(isRuntimeEnabled: true);
      final snapshot = DiagnosticsSnapshot(
        appVersion: '0.2.3+1',
        platformName: 'Android',
        localeCode: 'en',
        localePreference: LocalePreference.en,
        themeModeLabel: 'Dark',
        planLabel: 'Free',
        buildMode: 'debug',
        packageId: 'com.veil.mobile',
        dartSdkVersion: '3.12.0',
        currentRoute: '/settings/diagnostics',
        health: RuntimeHealthChecker.evaluate(setup: setup, runtime: runtime),
        setup: setup,
        runtime: runtime,
        completedQaItems: {'arabicUi'},
        generatedAt: DateTime.utc(2026, 5, 19),
      );

      final report = DiagnosticsReportBuilder.build(snapshot);

      expect(report, contains('VEIL Player Mobile Diagnostics Report'));
      expect(report, contains('App version: 0.2.3+1'));
      expect(report, contains('Current route: /settings/diagnostics'));
      expect(report, contains('Video: clip.mp4'));
      expect(report, contains('Track title: Demo track'));
      expect(report, contains('[x] Arabic UI'));
      expect(report, contains('[ ] Open MP4 video'));
    });
  });
}
