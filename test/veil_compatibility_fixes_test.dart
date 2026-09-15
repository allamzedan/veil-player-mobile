import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/core/veil/veil_runtime_evaluator.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';

const desktopRoot = '''
{"version":"1.6.0","app":"VEIL","appVersion":"Desktop","exportedAt":"2026-01-01T00:00:00.000Z","video":{"name":"sample.mp4","duration":120,"fileSize":1,"resolution":{"width":1280,"height":720},"fingerprint":{"method":"manual-unbound","value":"sample.mp4"},"binding":"unbound"},"globalOffsetSeconds":0,"trackMetadata":{},"items":[]}
''';

VeilTrack decodeUnboundFixture(String source) => VeilTrackCodec.decode(
  source.replaceFirst('"fingerprint":', '"binding":"unbound","fingerprint":'),
);

void main() {
  test(
    'accepts known Desktop version and rejects future or malformed versions',
    () {
      expect(VeilTrackCodec.decode(desktopRoot).version, '1.6.0');
      expect(
        VeilTrackCodec.tryDecode(desktopRoot.replaceFirst('1.6.0', '99.0.0')),
        isNull,
      );
      expect(
        VeilTrackCodec.tryDecode(desktopRoot.replaceFirst('1.6.0', '99')),
        isNull,
      );
    },
  );

  test('normalizes imported bookmark defaults and differing end', () {
    final track = decodeUnboundFixture(
      '{"version":"1.6.0","app":"VEIL","appVersion":"Desktop","exportedAt":"2026-01-01T00:00:00.000Z","video":{"name":"sample.mp4","duration":120,"fileSize":1,"resolution":{"width":1280,"height":720},"fingerprint":{"method":"manual-unbound","value":"sample.mp4"}},"globalOffsetSeconds":0,"trackMetadata":{},"items":[{"type":"bookmark","start":12.5,"end":99}]}',
    );
    final item = track.segments.single;
    expect(item.id, isNotEmpty);
    expect(item.enabled, isTrue);
    expect(item.label, 'Bookmark');
    expect(item.notes, '');
    expect(item.startMs, 12500);
    expect(item.endMs, 12500);
  });

  test('preserves bookmark id, disabled state, Unicode and multiline notes', () {
    final track = decodeUnboundFixture(
      '{"version":"1.6.0","app":"VEIL","appVersion":"Desktop","exportedAt":"2026-01-01T00:00:00.000Z","video":{"name":"sample.mp4","duration":120,"fileSize":1,"resolution":{"width":1280,"height":720},"fingerprint":{"method":"manual-unbound","value":"sample.mp4"}},"globalOffsetSeconds":0,"trackMetadata":{},"items":[{"id":"b1","type":"bookmark","enabled":false,"start":2,"end":3,"label":"שלום","notes":"line one\\nline two"}]}',
    );
    final item = track.segments.single;
    expect(item.id, 'b1');
    expect(item.enabled, isFalse);
    expect(item.label, 'שלום');
    expect(item.notes, 'line one\nline two');
    expect(item.endMs, item.startMs);
    final roundTrip = VeilTrackCodec.decode(VeilTrackCodec.encode(track));
    expect(roundTrip.segments.single.notes, 'line one\nline two');
  });

  test('bookmark has no runtime effect and offset is shared', () {
    final track = VeilTrack.empty().copyWith(
      globalOffsetSeconds: 2,
      segments: [
        VeilSegment.bookmark(positionMs: 1000, title: 'Bookmark'),
        VeilSegment.mobileDefault(
          id: 'mask',
          type: VeilSegmentType.mask,
          startMs: 5000,
          endMs: 6000,
        ),
        VeilSegment.mobileDefault(
          id: 'mute',
          type: VeilSegmentType.mute,
          startMs: 5000,
          endMs: 6000,
        ),
        VeilSegment.mobileDefault(
          id: 'skip',
          type: VeilSegmentType.skip,
          startMs: 5000,
          endMs: 6000,
        ),
      ],
    );
    final active = VeilRuntimeEvaluator.activeSegmentsAt(track, 3000);
    expect(active.where((s) => s.type == VeilSegmentType.bookmark), isEmpty);
    expect(VeilRuntimeEvaluator.activeMasks(active), hasLength(1));
    expect(VeilRuntimeEvaluator.hasActiveMute(active), isTrue);
    expect(VeilRuntimeEvaluator.activeSkipSegment(active)?.id, 'skip');
  });

  test('future rejection does not partially replace active track', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final controller = container.read(playerSetupControllerProvider.notifier);
    final existing = VeilTrack.empty(title: 'Existing');
    controller.state = controller.state.copyWith(
      selectedTrack: existing,
      selectedTrackTitle: existing.title,
    );
    final error = await controller.loadTrackFromContent(
      content: desktopRoot.replaceFirst('1.6.0', '99.0.0'),
    );
    expect(error, isNotNull);
    expect(
      container.read(playerSetupControllerProvider).selectedTrack?.id,
      existing.id,
    );
  });
}
