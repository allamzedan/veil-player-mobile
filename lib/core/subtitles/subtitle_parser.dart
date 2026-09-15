/// A single subtitle cue with millisecond timing.
class SubtitleCue {
  const SubtitleCue({
    required this.startMs,
    required this.endMs,
    required this.text,
  });

  final int startMs;
  final int endMs;
  final String text;

  bool isActiveAt(int positionMs) =>
      positionMs >= startMs && positionMs < endMs;
}

/// Parses `.srt` and `.vtt` subtitle files into [SubtitleCue] lists.
abstract final class SubtitleParser {
  static List<SubtitleCue> parse(String content, {String? filename}) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final lowerName = filename?.toLowerCase() ?? '';
    final isVtt =
        lowerName.endsWith('.vtt') ||
        trimmed.startsWith('WEBVTT') ||
        trimmed.startsWith('\uFEFFWEBVTT');

    final cues = isVtt ? _parseVtt(trimmed) : _parseSrt(trimmed);
    cues.sort((a, b) => a.startMs.compareTo(b.startMs));
    return cues;
  }
}

abstract final class SubtitleEvaluator {
  static SubtitleCue? activeCueAt(List<SubtitleCue> cues, int positionMs) {
    for (final cue in cues) {
      if (cue.isActiveAt(positionMs)) {
        return cue;
      }
    }
    return null;
  }

  static String? activeTextAt(List<SubtitleCue> cues, int positionMs) {
    return activeCueAt(cues, positionMs)?.text;
  }
}

List<SubtitleCue> _parseSrt(String content) {
  final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final blocks = normalized.split(RegExp(r'\n\s*\n'));
  final cues = <SubtitleCue>[];

  for (final block in blocks) {
    final cue = _parseCueBlock(block);
    if (cue != null) {
      cues.add(cue);
    }
  }

  return cues;
}

List<SubtitleCue> _parseVtt(String content) {
  var normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  if (normalized.startsWith('\uFEFF')) {
    normalized = normalized.substring(1);
  }

  final lines = normalized.split('\n');
  final body = <String>[];
  var skippingHeader = true;

  for (final line in lines) {
    final trimmed = line.trim();
    if (skippingHeader) {
      if (trimmed.isEmpty) {
        continue;
      }
      if (trimmed.startsWith('WEBVTT')) {
        continue;
      }
      if (trimmed.startsWith('NOTE') || trimmed.startsWith('STYLE')) {
        continue;
      }
      skippingHeader = false;
    }
    body.add(line);
  }

  return _parseSrt(body.join('\n'));
}

SubtitleCue? _parseCueBlock(String block) {
  final lines = block
      .split('\n')
      .map((line) => line.trimRight())
      .where((line) => line.isNotEmpty)
      .toList();

  if (lines.isEmpty) {
    return null;
  }

  var index = 0;
  if (_isNumericLine(lines[index])) {
    index++;
  }

  if (index >= lines.length) {
    return null;
  }

  final timing = _parseTimingLine(lines[index]);
  if (timing == null) {
    return null;
  }

  index++;
  if (index >= lines.length) {
    return null;
  }

  final textLines = <String>[];
  for (var i = index; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) {
      continue;
    }
    textLines.add(_stripMarkup(line));
  }

  if (textLines.isEmpty) {
    return null;
  }

  final text = textLines.join('\n').trim();
  if (text.isEmpty) {
    return null;
  }

  final startMs = timing.$1;
  final endMs = timing.$2;
  if (endMs <= startMs) {
    return null;
  }

  return SubtitleCue(startMs: startMs, endMs: endMs, text: text);
}

(int, int)? _parseTimingLine(String line) {
  final match = RegExp(
    r'^(\d{1,2}):(\d{2}):(\d{2})[,.](\d{3})\s*-->\s*(\d{1,2}):(\d{2}):(\d{2})[,.](\d{3})',
  ).firstMatch(line.trim());

  if (match == null) {
    final shortMatch = RegExp(
      r'^(\d{1,2}):(\d{2})[,.](\d{3})\s*-->\s*(\d{1,2}):(\d{2})[,.](\d{3})',
    ).firstMatch(line.trim());
    if (shortMatch == null) {
      return null;
    }

    final startMs = _toMs(
      hours: 0,
      minutes: int.parse(shortMatch.group(1)!),
      seconds: int.parse(shortMatch.group(2)!),
      millis: int.parse(shortMatch.group(3)!),
    );
    final endMs = _toMs(
      hours: 0,
      minutes: int.parse(shortMatch.group(4)!),
      seconds: int.parse(shortMatch.group(5)!),
      millis: int.parse(shortMatch.group(6)!),
    );
    return (startMs, endMs);
  }

  final startMs = _toMs(
    hours: int.parse(match.group(1)!),
    minutes: int.parse(match.group(2)!),
    seconds: int.parse(match.group(3)!),
    millis: int.parse(match.group(4)!),
  );
  final endMs = _toMs(
    hours: int.parse(match.group(5)!),
    minutes: int.parse(match.group(6)!),
    seconds: int.parse(match.group(7)!),
    millis: int.parse(match.group(8)!),
  );
  return (startMs, endMs);
}

int _toMs({
  required int hours,
  required int minutes,
  required int seconds,
  required int millis,
}) {
  return ((hours * 3600 + minutes * 60 + seconds) * 1000) + millis;
}

bool _isNumericLine(String line) => RegExp(r'^\d+$').hasMatch(line.trim());

String _stripMarkup(String line) {
  var value = line.trim();
  value = value.replaceAll(RegExp(r'<[^>]+>'), '');
  value = value.replaceAll(RegExp(r'\{[^}]+\}'), '');
  return value.trim();
}
