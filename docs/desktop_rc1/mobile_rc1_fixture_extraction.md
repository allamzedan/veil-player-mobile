# VEIL DESKTOP 0.8.0-RC1 MOBILE FIXTURE EXTRACTION

## 1. Canonical Baseline

This audit is against `v0.8.0-rc1`, peeled to `cb96798ccd4dd4d2576d5e64905cc922ae99de04` (branch `master`, app version `0.8.0`). The worktree had only generated release-output dirt; no production source was changed. The six existing WIP stashes were left untouched.

## 2. Evidence Sources

Primary evidence is the frozen executable source and tests: `src/lib/trackSchema.ts` (`veilTrackSchema`, `parseVeilTrackJson`), `src/lib/trackSerialization.ts` (`buildVeilTrackFromStore`, `deserializeVeilTrackToStorePayload`, `parseAndDeserializeTrackJson`), `src/types/track.ts`, `src/lib/fingerprint.ts` (`buildMetadataFingerprint`, `compareTrackVideoToCurrent`), `src/lib/reconciler.ts` (`reconcilePlayback`), `src/lib/youtubeRangePlayback.ts` (`YouTubeRangePlaybackGuard`, `resolveChainedSkipEnd`), and `src/lib/trackGrouping.ts`. Tests include `trackSchema.test.ts`, `trackMatching.test.ts`, `crossPlatformVeilCompatibility.test.ts`, `youtubeRangePlayback.test.ts`, `youtubeUnsupportedItems.test.ts`, and `youtubeVolumeConsistency.test.ts`. `docs/track-format.md` was used only where consistent with source.

## 3. Exact 1.6.0 Root JSON Shape

The local RC1 serializer creates, in this deterministic order: `version`, `app`, `appVersion`, `exportedAt`, `video`, `globalOffsetSeconds`, `trackMetadata`, `items`, optional `groups`, optional `anchors`, and `subtitleCover`. The YouTube serializer instead creates `media` and omits local `video` and `subtitleCover`; it includes preserved unsupported items and bookmarks.

Local `video` is `{ name, duration, fileSize, resolution: { width, height }, fingerprint: { method, value } }`. `binding` is omitted for ordinary metadata-bound exports and is used for unbound tracks. `trackMetadata` is emitted by the builder even when `{}`. Local `subtitleCover` is emitted with mode and region rectangle. Empty `groups` and `anchors` are omitted. Items are emitted as one array in store order: masks, mutes, skips, bookmarks. `JSON.stringify(track, null, 2)` is the export formatter; it does not sort keys.

## 4. Persisted Field Matrix

| JSON path | Type / requirement | Defaults, normalization, validation, omission | Classification |
|---|---|---|---|
| `version` | exact string, required | One of `1.0.0`…`1.6.0`; no semantic forward acceptance | CANONICAL |
| `app` | literal `"VEIL"`, required | Other values reject | CANONICAL |
| `appVersion` | string, optional | Builder writes running `APP_VERSION`; parser does not verify its value | DESKTOP DETAIL |
| `exportedAt` | string, optional | Builder writes current ISO timestamp; parser only checks string type | DESKTOP DETAIL |
| `video.name` | string, required for local metadata binding | Empty/whitespace name rejects unless binding is `unbound` | CANONICAL |
| `video.duration` | finite number >= 0, required | Seconds; no clamping | CANONICAL |
| `video.fileSize` | finite number or `null`, required | Bytes; `null` becomes `unknown` in fingerprint comparison | CANONICAL |
| `video.resolution.width/height` | finite numbers >= 0, required | Pixels; `0x0` is allowed and treated as audio-compatible | CANONICAL |
| `video.fingerprint` | method enum + nonempty string, required | `metadata-v1` is generated from name/size/rounded duration/width/height; no hash algorithm | CANONICAL |
| `media` | YouTube object, optional | For 1.6.0: provider and 11-character videoId are validated; `provider + videoId` is identity | CANONICAL |
| `globalOffsetSeconds` | finite number, required | Seconds; reconciliation uses `currentTime + offset`; no omission | CANONICAL |
| `trackMetadata` | object, optional | Parser passthroughs unknown metadata keys; store/export sanitizer trims, clamps, deduplicates tags, floors downloads, and omits empty ordinary text | CANONICAL for defined fields; unknown metadata is LEGACY / QUESTIONABLE |
| `items` | array, required | Union of mask/mute/skip/bookmark; invalid member rejects the whole parse | CANONICAL |
| item `id`, `type`, `start`, `end` | string/type/timestamps | Range items require finite `start >= 0`, finite end, and `end > start`; parser does not enforce unique IDs | CANONICAL |
| item `enabled` | boolean, optional | Omitted parses; load normalization makes it `true`; only `false` disables playback | CANONICAL |
| item `label`, `notes`, `locked` | string/string/boolean, optional | Parser validates types; load normalization makes `locked` explicit false for range items and bookmarks; labels/notes are not generally trimmed by range normalization | CANONICAL |
| mask `rect` | four finite percentages | Minimum width/height comes from `MIN_MASK_SIZE`; nonnegative origin and rectangle within 100% required; zero-size/negative/out-of-bounds rejects | CANONICAL |
| mask `style` | solid/color/opacity, optional presentation | opacity 0..1; presentation enum; unknown keys stripped | CANONICAL |
| mask `source` | `{ kind: manual|srt }`, optional | Generated subtitle masks are ordinary masks with `source.kind = "srt"` | CANONICAL |
| mask `fadeInMs/fadeOutMs` | finite number 0..5000, optional | Milliseconds; unknown fields stripped | CANONICAL |
| bookmark `id` | nonempty string, optional | Missing/blank ID is accepted by parser; load creates a generated ID | CANONICAL with nondeterministic fallback |
| bookmark `end` | nonnegative number, optional | Parser accepts a different end; load normalizes to `end = start` | CANONICAL |
| `groups` | array of group objects, optional | Empty omitted by builder; load trims label, defaults blank label to `Group`, drops invalid/dangling/duplicate item references, strips invalid color token | CANONICAL shape; UI membership behavior is DESKTOP DETAIL |
| `anchors` | array, optional | Load drops anchors with nonfinite/negative time and trims/removes blank labels; IDs are not regenerated | CANONICAL shape; generated cue-anchor policy is DESKTOP DETAIL |
| `subtitleCover` | mode enum + optional rect | Mode `show`, `smartCover`, or `regionCover`; absent load default is `show` and default rect is 10/78/80/18 | CANONICAL |

`rating` and `downloads` are accepted reserved metadata fields; `signature` is accepted and preserved when nonblank. They are not playback inputs. No absolute media path is persisted by the local serializer.

## 5. Runtime-Only Desktop State

The following are not part of the interchange contract: `videoSrc`, blob/object URLs, absolute `videoFilePath`, HTML media element state, player adapter state, `playerVolume`, `playerMuted`, `effectiveMuted`, skip latch, selected items, dirty state, subtitle cue arrays, `subtitleFileName`, `showSubtitleText`, undo history, UI group visibility/solo state, fullscreen state, and session/recent-file state. `appVersion`/`exportedAt` are persisted provenance fields, not runtime playback state.

## 6. Schema Version Acceptance Matrix

| Input | Accepted? | Migration / result | Failure |
|---|---:|---|---|
| 1.4.0 | yes | Parsed as 1.4.0; no version rewrite | — |
| 1.5.0 | yes | Parsed as 1.5.0; bookmarks are allowed by current union | — |
| 1.6.0 | yes | Current schema; builder writes this | — |
| 1.6.1 | no | No patch-forward migration | `Unsupported track version (1.6.1)` |
| 1.7.0 | no | No minor-forward migration | `Unsupported track version (1.7.0)` |
| 2.0.0 | no | No major-forward migration | `Unsupported track version (2.0.0)` |
| missing | no | Zod runs and reports required `version` | schema failure, not version-message precheck |
| `null` | no | Version precheck reports invalid | unsupported-version message |
| numeric `1.6` | no | Exact string enum; precheck stringifies number | unsupported-version message |
| `"1"`, `"1.6"`, `"v1.6.0"`, `"abc"`, `""`, `"01.06.00"` | no | Exact-string comparison | unsupported-version message |

There is no migration selector in RC1: accepted historical versions are validated by the same schema and retain their version. A parse failure returns `{ ok: false, message }` before store deserialization, so active state is not touched by this path. This is proven by `parseVeilTrackJson` and `parseAndDeserializeTrackJson`.

## 7. Media Identity / Fingerprint

`buildMetadataFingerprint` creates `metadata-v1` as `fileName|fileSizeToken|roundedDuration|width|height`; duration is rounded to milliseconds and file size is bytes. It is a metadata token, not a cryptographic hash. Comparison separately checks exact filename (case-sensitive, no basename normalization), exact file-size token, duration difference `> 0.5` seconds after millisecond rounding, resolution, and exact fingerprint value. A `0x0` versus `0x0` resolution difference is suppressed for audio.

The path does not participate in identity. Renaming the same media produces a filename and fingerprint mismatch, but does not block import. Changing size, materially changing duration, resolution, or the token produces warnings classified by `trackMatching.ts`; the importer can still proceed after confirmation. A missing local video block is a schema rejection, while an unbound track (`binding: unbound`, `manual-unbound`) intentionally applies timings as-is. YouTube uses `provider + videoId`; canonical URL is not the authoritative identity. Matching sidecar filename candidates is separate Desktop filesystem behavior (`matchingVeilPaths.ts`).

## 8. Mute Semantics

The executable reconciler finds enabled items whose adjusted time satisfies `start <= currentTime + globalOffsetSeconds <= end`. `YouTubeRangePlaybackGuard` derives `rangeMuted = activeMutes.length > 0` and `effectiveMuted = userMuted || rangeMuted || volume === 0`. The local `VideoPlayer` uses the same effective-muted projection for the media adapter.

Therefore RC1 captures neither prior volume nor prior mute state, does not set persisted volume, and does not overwrite the user’s `userMuted` or `volume`. Volume remains an independent user-controlled value while range mute is active; changing volume or explicit mute changes the user inputs, while effective output remains muted until the range is inactive. On exit the original user inputs are already intact. This is observably compatible with a Mobile volume-only implementation only if it preserves the same observable rules: range mute must not destroy user mute/volume state, and volume changes during the range must be reflected after exit. Internal representation need not be identical.

Overlapping mutes are simply a nonempty active set; there is no capture stack and no overlap ordering. Seeking into/out, pausing, media replacement, timeline replacement, or disabling an item recomputes the set on the next ready reconciliation. Ready=false yields no range mute. These details are proved by `reconciler.ts`, `youtubeRangePlayback.ts`, `VideoPlayer.tsx`, and `youtubeRangePlayback.test.ts`.

## 9. Boundary Semantics

The exact production operators are `item.start > adjustedTime || adjustedTime > item.end` in `reconciler.ts`: both endpoints are inclusive for Mask, Mute, and Skip.

| time | Mask active | Mute active / enforced | Skip active / eligible |
|---:|:---:|:---:|:---:|
| 9.999999 | no | no / no | no / no |
| 10.000000 | yes | yes / yes | yes / yes if playing |
| 10.000001 | yes | yes / yes | yes / yes if playing |
| 19.999999 | yes | yes / yes | yes / yes if playing |
| 20.000000 | yes | yes / yes | yes / yes if playing |
| 20.000001 | no | no / no | no / no |

Paused Skip is active in the reconciliation result but is not eligible to trigger a seek because the guard requires `playing`.

## 10. Overlapping / Adjacent Skip Semantics

For a playing direct seek to 16 with `skip-a 10→20` and `skip-b 15→30`, active skips contain both items. `resolveChainedSkipEnd` starts at max active end (30), sorts all enabled skips by start/end/id, and returns 30. The guard sets latch `{ start: 10, target: 30 }` and requests target 30. The following pass at 30 has no new target because the latch remains; it is cleared only after leaving the latch interval or explicit reset/source/load-generation change. Paused at 16 returns active skips but no target and no latch.

Reversing serialized item order produces the same result: the algorithm sorts by time, so this overlap behavior is order-independent and therefore canonical for the RC1 guard. Adjacent `10→20` and `20→30` chains to 30 because the extension test is `skip.start <= end + PLAYBACK_EPSILON`; at exactly 20, paused produces no target, while playing produces target 30. `youtubeRangePlayback.test.ts` additionally proves 10→20, 18→30, 30→40 resolves to 40.

The latch and adapter-generation/source reset are Desktop playback implementation details; the observable “one playing skip operation may jump through overlapping/adjacent ranges” is compatibility-relevant but should be treated as LEGACY / QUESTIONABLE until cross-platform policy explicitly adopts chained skips.

## 11. Invalid Structure Matrix

Parser/schema invalidity rejects the whole track; RC1 does not drop malformed union members individually. The following compact matrix records the exact result (all are `REJECT WHOLE TRACK` unless stated otherwise):

| Cases | Result / normalization | Classification |
|---|---|---|
| missing start/end; string start/end; null timestamp; NaN-equivalent JSON; negative start; missing/negative end; end before start | reject; JSON cannot represent NaN, and non-finite values are rejected by `finite()` | CANONICAL |
| zero-length Mask/Mute/Skip | reject (`end <= start`) | CANONICAL |
| zero-length Bookmark | accept; bookmark is point-like and load keeps `start=end` | CANONICAL |
| Bookmark end != start; missing Bookmark end | accept; load normalizes end to start | CANONICAL |
| missing Bookmark ID | accept; load generates an ID | CANONICAL, nondeterministic fallback |
| missing Bookmark enabled/label/notes | accept; load defaults enabled=true, label=`Bookmark`, notes=`""` | CANONICAL |
| Mask x/y < 0; width/height < 0 or below minimum; x/y > 100; width/height > 100; rectangle past 100% | reject via `percentRectSchema` | CANONICAL |
| duplicate IDs, including across types | accept; no uniqueness refinement; grouping uses IDs and can therefore be ambiguous | LEGACY / QUESTIONABLE |
| unknown item type; item null/string/array | reject whole track; union has no unsupported-item branch | CANONICAL |
| arbitrary unknown fields on a valid item | accept but Zod object strips them; they do not reserialize | CANONICAL |
| arbitrary unknown root field | accept but root Zod object strips it; it does not reserialize | CANONICAL |
| unknown group/anchor fields | accept and strip unknown fields; malformed known fields reject whole track | CANONICAL |
| missing items; items null/non-array | reject whole track | CANONICAL |
| missing local media object | reject whole local track; YouTube 1.6.0 may use `media` instead | CANONICAL |
| malformed fingerprint object | reject whole track (method enum/value nonempty) | CANONICAL |

Valid items do not survive a track-level parse failure because store payload creation is not reached. The only post-parse drops are normalization drops: invalid/dangling/duplicate group references and invalid anchors, not malformed item records.

## 12. Unknown / Unsupported Data Preservation

Root unknown properties are accepted then stripped by the default Zod object behavior. Item unknown properties are likewise stripped. `trackMetadata` is explicitly `.passthrough()` and its unknown keys survive parsing; however `sanitizeTrackMetadata` reconstructs only defined metadata keys, so arbitrary metadata keys are not guaranteed through load → store payload → export.

There is no generic preserved-unsupported-items mechanism. On YouTube, masks are deliberately placed in `preservedUnsupportedItems` by `deserializeVeilTrackToStorePayload`; the tested YouTube save/reopen path re-emits preserved masks and also keeps Mute/Skip items in their executable arrays/items. An unknown item type is rejected before that path. Provider-specific preservation is therefore a YouTube/Desktop policy, not a general parser contract. Old-schema fields accepted by the current schema survive only when they are still in the current known shape.

## 13. Groups / Anchors

Groups serialize as `{ id: string, label: nonempty string, itemIds: string[], colorToken?: "g1"…"g6" }`. Anchors serialize as `{ id: string, time: finite >=0, label?: string, kind?: "manual"|"cue"|"bookmark" }`. IDs are opaque nonempty strings; item references are IDs, not array indexes.

Parser validation rejects malformed group/anchor records. On store load, group labels are trimmed (blank becomes `Group`), invalid color tokens are omitted, references to nonexistent items are dropped, and an item referenced more than once is retained only in the first group occurrence. Anchor load drops invalid time values and trims/removes blank labels. Dangling group references do not reject the track. The serializer omits empty group/anchor arrays. Shape is a CANONICAL VEIL CONTRACT; cue-anchor generation limit/order and group visibility/solo behavior are DESKTOP DETAILS.

## 14. Subtitle Persistence

Persisted subtitle-related state is only `subtitleCover.mode` and, optionally, `subtitleCover.regionRect`, plus ordinary generated Mask items. `showSubtitleText`, `subtitleCoverMode` before export, `regionCoverRect` before export, subtitle filename, SRT cue arrays, and cue session state are runtime/UI state. Generated per-cue subtitle masks are ordinary `mask` items with `source: { kind: "srt" }` and are persisted like any other mask. SRT cue arrays themselves are not serialized.

## 15. Compatibility Fixtures

Fixtures in `docs/compatibility_fixtures/rc1/` use the actual 1.6.0 envelope and serializer field order, with deterministic media metadata, IDs, and timestamps. They are semantically stable through parse → deserialize; the runtime builder would change `exportedAt`, `updatedAt`, and generated IDs when those inputs are not injected. Required fixtures: `rc1-empty-local.veil`, `rc1-mask.veil`, `rc1-mute.veil`, `rc1-overlapping-mutes.veil`, `rc1-skip.veil`, `rc1-bookmark.veil`, `rc1-bookmark-unicode.veil`, `rc1-disabled-items.veil`, and `rc1-global-offset.veil`. Edge fixtures also include `rc1-overlapping-skips.veil` and `rc1-adjacent-skips.veil`.

The fixture envelope was derived from `buildVeilTrackFromStore` and formatted as `serializeTrackForExport`; the frozen parser and the existing full Vitest suite passed, including schema, matching, cross-platform, YouTube preservation, volume, and range-playback tests. These fixtures are not byte-round-trip claims for normalized inputs: missing defaults or bookmark IDs become explicit/generated in the store payload.

## 16. CANONICAL VEIL CONTRACT

Mobile and future implementations should reproduce: exact supported version strings; root/media/item shapes; strict malformed-track rejection; inclusive range boundaries; enabled=false exclusion; bookmark point normalization; global-offset arithmetic; mask geometry/style constraints; metadata-v1 fields and 0.5-second duration mismatch threshold when matching is implemented; path-independent identity; YouTube provider/videoId identity; subtitle-cover persistence; and semantic preservation of valid items after a confirmed media mismatch.

## 17. DESKTOP IMPLEMENTATION DETAILS

Do not standardize: Electron file/sidecar candidate paths; absolute local paths and object URLs; appVersion/exportedAt timestamps; Zustand split arrays; HTML media mute/volume plumbing; skip latch internals; UI selection/dirty/history state; cue-anchor sampling; and group visibility/solo UI. These are implementation architecture or Desktop UX.

## 18. LEGACY / QUESTIONABLE RC1 BEHAVIOR

Do not silently promote: duplicate item IDs; arbitrary metadata passthrough assumptions; YouTube preservation asymmetry; chained overlap/adjacent Skip behavior; and the current warning-tier wording/classification. Preserve for RC1 compatibility where necessary, but require a separate cross-platform decision before making them normative.

## 19. Items Requiring Cross-Platform Decision

Decide separately whether Mobile should expose/implement groups and anchors, whether chained skips are normative, how duplicate IDs are repaired, whether unknown metadata should survive a full load/save cycle, whether YouTube range items remain executable, and how warning tiers are presented. None of these decisions justify changing the RC1 schema or Desktop behavior in this audit.

## 20. Mobile MUST MATCH Summary

Use exact `1.6.0`, strict parser behavior, inclusive `[start,end]` execution, `current + globalOffsetSeconds`, disabled-item exclusion, bookmark point semantics, metadata-only matching fields, no path identity, warning-not-blocking media mismatch, and effective mute semantics that preserve user mute/volume state. Treat Desktop file paths, runtime state, UI policy, and skip-latch mechanics as non-contract details unless the observable behavior is intentionally adopted by a separate decision.
