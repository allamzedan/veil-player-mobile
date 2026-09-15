import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/subtitles/subtitle_settings.dart';

void main() {
  group('SubtitleSettings', () {
    test('defaults match expected values', () {
      const settings = SubtitleSettings.defaults;

      expect(settings.fontSize, SubtitleFontSize.medium);
      expect(settings.position, SubtitlePosition.bottom);
      expect(settings.backgroundEnabled, isTrue);
      expect(settings.backgroundOpacity, 0.58);
      expect(settings.delayMs, 0);
      expect(settings.fontSizePx, 16);
    });

    test('effectivePositionMs applies delay', () {
      const settings = SubtitleSettings(delayMs: 300);

      expect(settings.effectivePositionMs(1000), 1300);
      expect(settings.effectivePositionMs(0), 300);
    });

    test('effectivePositionMs supports negative delay', () {
      const settings = SubtitleSettings(delayMs: -200);

      expect(settings.effectivePositionMs(1000), 800);
    });

    test('formatDelayLabel shows signed milliseconds', () {
      expect(const SubtitleSettings().formatDelayLabel(), '0ms');
      expect(
        const SubtitleSettings(delayMs: 300).formatDelayLabel(),
        '+300ms',
      );
      expect(
        const SubtitleSettings(delayMs: -200).formatDelayLabel(),
        '-200ms',
      );
    });

    test('toJson and fromJson round-trip', () {
      const settings = SubtitleSettings(
        fontSize: SubtitleFontSize.large,
        position: SubtitlePosition.top,
        backgroundEnabled: false,
        backgroundOpacity: 0.25,
        delayMs: 150,
      );

      final restored = SubtitleSettings.fromJson(settings.toJson());

      expect(restored.fontSize, settings.fontSize);
      expect(restored.position, settings.position);
      expect(restored.backgroundEnabled, settings.backgroundEnabled);
      expect(restored.backgroundOpacity, settings.backgroundOpacity);
      expect(restored.delayMs, settings.delayMs);
    });

    test('fromStorage returns defaults for invalid JSON', () {
      expect(SubtitleSettings.fromStorage(null), SubtitleSettings.defaults);
      expect(SubtitleSettings.fromStorage(''), SubtitleSettings.defaults);
      expect(SubtitleSettings.fromStorage('not-json'), SubtitleSettings.defaults);
      expect(
        SubtitleSettings.fromStorage(jsonEncode(['bad'])),
        SubtitleSettings.defaults,
      );
    });

    test('fromJson clamps opacity and tolerates unknown enums', () {
      final settings = SubtitleSettings.fromJson({
        'fontSize': 'unknown',
        'position': 'unknown',
        'backgroundEnabled': true,
        'backgroundOpacity': 2.0,
        'delayMs': 42,
      });

      expect(settings.fontSize, SubtitleFontSize.medium);
      expect(settings.position, SubtitlePosition.bottom);
      expect(settings.backgroundOpacity, 1.0);
      expect(settings.delayMs, 42);
    });
  });
}
