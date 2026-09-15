# VEIL Track JSON Schema

This document describes the **desktop-compatible VEIL track** format exported by VEIL Mobile and VEIL Desktop. Mobile also supports a legacy storage format (`format: "veil.track"`) documented in [Compatibility](#compatibility-notes).

**Reference examples:** [examples/sample_track.json](examples/sample_track.json), [examples/sample_track_with_bookmark.json](examples/sample_track_with_bookmark.json)

---

## Document root (desktop export)

Desktop tracks are JSON objects identified by `"app": "VEIL"` and an `items` array.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `version` | string | yes | Track schema version (currently `1.4.0`) |
| `app` | string | yes | Always `"VEIL"` for desktop-compatible documents |
| `appVersion` | string | yes | Exporter version (e.g. `VEIL Mobile 0.2.0`) |
| `exportedAt` | string (ISO 8601 UTC) | yes | Export timestamp |
| `video` | object | yes | Bound video metadata (see below) |
| `globalOffsetSeconds` | number | yes | Playback offset applied at runtime (often `0`) |
| `trackMetadata` | object | yes | Creation/update timestamps |
| `items` | array | yes | Timed segments (mask, mute, skip, bookmark) |
| `subtitleCover` | object | yes | Default subtitle mask region for desktop |

Optional top-level fields may appear from future exporters or be preserved in `rawExtra` on import.

### `video`

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Original filename or display name |
| `duration` | number | Duration in seconds |
| `fileSize` | number | File size in bytes |
| `resolution` | object | `{ "width": number, "height": number }` |
| `fingerprint` | object | `{ "method": string, "value": string }` — `metadata-v1` or `manual-unbound` |

### `trackMetadata`

| Field | Type | Description |
|-------|------|-------------|
| `createdAt` | string (ISO 8601 UTC) | Track creation time |
| `updatedAt` | string (ISO 8601 UTC) | Last modification time |

### `subtitleCover`

| Field | Type | Description |
|-------|------|-------------|
| `mode` | string | e.g. `"smartCover"` |
| `regionRect` | object | Percent rect: `xPercent`, `yPercent`, `widthPercent`, `heightPercent` |

---

## Item types (`items[]`)

All items share a common timing envelope. Times are in **seconds** (integer or decimal).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Unique segment UUID |
| `type` | string | yes | `mask`, `mute`, `skip`, or `bookmark` |
| `enabled` | boolean | yes | Whether the item is active |
| `start` | number | yes | Start time in seconds |
| `end` | number | yes | End time in seconds |
| `label` | string | no | Human-readable title (used as bookmark title) |
| `notes` | string | no | Optional annotation |

### `mask`

Runtime action — covers a rectangular region during playback.

Additional fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `rect` | object | yes | `xPercent`, `yPercent`, `widthPercent`, `heightPercent` |
| `style` | object | yes | `mode` (`solid`), `color` (hex), `opacity` (0–1) |
| `source` | object | yes | `{ "kind": "manual" }` on export |

Requires `end > start`.

### `mute`

Runtime action — silences audio between `start` and `end`.

No `rect`, `style`, or `source`. Requires `end > start`.

### `skip`

Runtime action — seeks forward past the segment between `start` and `end`.

No `rect`, `style`, or `source`. Requires `end > start`.

### `bookmark`

**Informational only** — does not affect playback, masking, muting, or skipping.

| Field | Notes |
|-------|-------|
| `start` / `end` | Equal for point bookmarks (`end == start`) |
| `label` | Bookmark title (recommended) |
| `notes` | Optional note |

Legacy mobile-only `marker` segments are **not exported** to desktop JSON.

---

## Legacy mobile format (`veil.track`)

Used for on-device storage and some imports:

| Field | Description |
|-------|-------------|
| `format` | `"veil.track"` |
| `segments` | Array of mobile segment objects (`startMs` / `endMs` in milliseconds) |
| `title`, `id`, `version`, `createdAt`, `updatedAt` | Track metadata |

VEIL Mobile accepts both formats on import.

---

## Compatibility notes

### Forward compatibility

- Clients **should ignore** item types they do not understand rather than failing the entire document.
- VEIL Mobile skips malformed or unknown items during import and loads the rest of the track.
- Unknown top-level keys are preserved in `rawExtra` when possible.

### Bookmarks vs runtime actions

| Type | Affects playback |
|------|------------------|
| `mask`, `mute`, `skip` | Yes — runtime VEIL actions |
| `bookmark` | No — navigation/reference only |
| `marker` (mobile legacy) | No — omitted from desktop export |

### Non-destructive guarantee

VEIL tracks are **sidecar metadata**. The original video file is never modified. All actions are applied at playback time only.

### Desktop interop

- Exported tracks target VEIL Desktop schema version `1.4.0`.
- Mask items use `source.kind: "manual"` (not `manual-mobile`).
- Mobile-created tracks include required `video` and `subtitleCover` blocks for desktop validation.

---

## Related

- [track_pack_schema.md](track_pack_schema.md) — bundling multiple tracks
- [examples/](examples/) — sample JSON files
- `lib/core/veil/veil_track_codec.dart` — encode/decode implementation
