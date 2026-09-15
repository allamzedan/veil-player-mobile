import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/subtitles/subtitle_parser.dart';

void main() {
  group('SubtitleParser', () {
    test('parses common SRT timestamps and multiline cues', () {
      const content = '''
1
00:00:01,000 --> 00:00:04,000
First line
Second line

2
00:00:05.500 --> 00:00:07,250
Single cue
''';

      final cues = SubtitleParser.parse(content, filename: 'demo.srt');
      expect(cues, hasLength(2));
      expect(cues.first.startMs, 1000);
      expect(cues.first.endMs, 4000);
      expect(cues.first.text, 'First line\nSecond line');
      expect(cues[1].startMs, 5500);
      expect(cues[1].text, 'Single cue');
    });

    test('parses WebVTT timestamps and strips header', () {
      const content = '''
WEBVTT
Kind: captions

00:00:10.000 --> 00:00:12.500
Hello <b>world</b>

00:00:15,000 --> 00:00:16,000
Short cue
''';

      final cues = SubtitleParser.parse(content, filename: 'demo.vtt');
      expect(cues, hasLength(2));
      expect(cues.first.startMs, 10_000);
      expect(cues.first.text, 'Hello world');
      expect(cues[1].endMs, 16_000);
    });

    test('returns empty list for blank subtitle files', () {
      expect(SubtitleParser.parse('', filename: 'empty.srt'), isEmpty);
      expect(SubtitleParser.parse('   \n\n', filename: 'blank.vtt'), isEmpty);
    });

    test('ignores invalid cue blocks safely', () {
      const content = '''
broken block

1
00:00:01,000 --> 00:00:00,500
Invalid timing

2
00:00:02,000 --> 00:00:03,000
Valid cue
''';

      final cues = SubtitleParser.parse(content, filename: 'demo.srt');
      expect(cues, hasLength(1));
      expect(cues.single.text, 'Valid cue');
    });
  });

  group('SubtitleEvaluator', () {
    const cues = [
      SubtitleCue(startMs: 1000, endMs: 3000, text: 'A'),
      SubtitleCue(startMs: 3000, endMs: 5000, text: 'B'),
    ];

    test('finds active cue with end-exclusive boundary', () {
      expect(SubtitleEvaluator.activeTextAt(cues, 1500), 'A');
      expect(SubtitleEvaluator.activeTextAt(cues, 2999), 'A');
      expect(SubtitleEvaluator.activeTextAt(cues, 3000), 'B');
      expect(SubtitleEvaluator.activeTextAt(cues, 5000), isNull);
    });
  });
}
