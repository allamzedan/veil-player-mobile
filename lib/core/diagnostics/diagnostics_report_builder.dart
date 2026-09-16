import 'package:veil_mobile/core/diagnostics/diagnostics_snapshot.dart';
import 'package:veil_mobile/core/diagnostics/qa_checklist.dart';

/// Builds a plain-text diagnostics report for beta bug collection.
abstract final class DiagnosticsReportBuilder {
  static String build(DiagnosticsSnapshot snapshot) {
    final buffer = StringBuffer()
      ..writeln('VEIL Player Mobile Diagnostics Report')
      ..writeln('Generated (UTC): ${snapshot.generatedAt.toIso8601String()}')
      ..writeln()
      ..writeln('== App ==')
      ..writeln('App version: ${snapshot.appVersion}')
      ..writeln('Platform: ${snapshot.platformName}')
      ..writeln('Locale: ${snapshot.localeCode}')
      ..writeln('Locale preference: ${snapshot.localePreference.name}')
      ..writeln('Theme: ${snapshot.themeModeLabel}')
      ..writeln('Plan: ${snapshot.planLabel}')
      ..writeln('Build mode: ${snapshot.buildMode}')
      ..writeln('Package id: ${snapshot.packageId}')
      ..writeln('Dart SDK: ${snapshot.dartSdkVersion}')
      ..writeln()
      ..writeln('== Navigation ==')
      ..writeln('Current route: ${snapshot.currentRoute}')
      ..writeln()
      ..writeln('== Runtime health ==')
      ..writeln('Track loaded: ${_yesNo(snapshot.health.trackLoaded)}')
      ..writeln('Video loaded: ${_yesNo(snapshot.health.videoLoaded)}')
      ..writeln('Subtitle loaded: ${_yesNo(snapshot.health.subtitleLoaded)}')
      ..writeln('VEIL runtime active: ${_yesNo(snapshot.health.runtimeActive)}')
      ..writeln()
      ..writeln('== Player state ==')
      ..writeln(
        'Video: ${snapshot.setup.selectedVideoName ?? 'none'}',
      )
      ..writeln(
        'Video path: ${snapshot.setup.selectedVideoPath ?? 'none'}',
      )
      ..writeln(
        'Video status: ${snapshot.setup.videoPlaybackStatus.name}',
      )
      ..writeln(
        'Track title: ${snapshot.setup.selectedTrackTitle ?? 'none'}',
      )
      ..writeln(
        'Track file: ${snapshot.setup.selectedTrackFileName ?? 'none'}',
      )
      ..writeln(
        'Track path: ${snapshot.setup.selectedTrackPath ?? 'none'}',
      )
      ..writeln(
        'Track segments: ${snapshot.setup.segmentCount ?? 0}',
      )
      ..writeln(
        'Subtitle: ${snapshot.setup.selectedSubtitleName ?? 'none'}',
      )
      ..writeln(
        'Subtitle cues: ${snapshot.setup.subtitleCues.length}',
      )
      ..writeln(
        'Subtitles enabled: ${_yesNo(snapshot.setup.subtitlesEnabled)}',
      )
      ..writeln('Playback speed: ${snapshot.setup.playbackSpeed}x')
      ..writeln(
        'Ready for playback: ${_yesNo(snapshot.setup.isReadyForPlayback)}',
      )
      ..writeln(
        'Unsaved track changes: ${_yesNo(snapshot.setup.hasUnsavedTrackChanges)}',
      )
      ..writeln(
        'Active runtime effects: mask=${snapshot.runtime.hasActiveMask}, '
        'mute=${snapshot.runtime.hasActiveMute}, '
        'skip=${snapshot.runtime.hasActiveSkip}',
      );
    if (snapshot.setup.errorMessage != null) {
      buffer.writeln('Error: ${snapshot.setup.errorMessage}');
    }
    if (snapshot.setup.validationMessages.isNotEmpty) {
      buffer
        ..writeln('Validation messages:')
        ..writeln(snapshot.setup.validationMessages.join('\n'));
    }
    buffer
      ..writeln()
      ..writeln('== QA checklist ==');
    for (final item in qaChecklistItems) {
      final done = snapshot.completedQaItems.contains(item.storageKey);
      buffer.writeln('[${done ? 'x' : ' '}] ${item.exportLabel()}');
    }
    return buffer.toString().trimRight();
  }

  static String _yesNo(bool value) => value ? 'yes' : 'no';
}
