# VEIL Track Pack Schema (`.veilpack.json`)

Track packs bundle multiple VEIL tracks into a single portable JSON file for library import/export.

**Reference example:** [examples/sample_pack.veilpack.json](examples/sample_pack.veilpack.json)

---

## File format

| Property | Value |
|----------|-------|
| Extension | `.veilpack.json` |
| Format id | `"veil.pack"` |
| MIME (typical) | `application/json` |

---

## Document root

```json
{
  "format": "veil.pack",
  "version": "1.0.0",
  "pack": { ... }
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `format` | string | yes | Must be `"veil.pack"` |
| `version` | string | yes | Pack envelope version (default `1.0.0`) |
| `pack` | object | yes | Pack metadata and tracks |

---

## `pack` object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Pack UUID |
| `title` | string | yes | Display name |
| `description` | string | no | Longer description |
| `author` | string | no | Creator label (default `VEIL Mobile`) |
| `createdAt` | string (ISO 8601 UTC) | yes | Creation time |
| `updatedAt` | string (ISO 8601 UTC) | yes | Last update time |
| `tags` | string[] | no | Free-form tags for library filtering |
| `tracks` | array | yes | Embedded track entries |

---

## `tracks[]` entries

Each entry wraps one full VEIL track document:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `trackTitle` | string | yes | Display title in pack UI |
| `trackJson` | object **or** string | yes | Full desktop VEIL track JSON |

On export, `trackJson` is embedded as a parsed object. String-encoded JSON is also accepted on import.

Embedded `trackJson` follows [track_schema.md](track_schema.md) — including `items` with `mask`, `mute`, `skip`, and `bookmark` types.

---

## Compatibility assumptions

### Bookmarks in packs

- Bookmark items inside embedded tracks are preserved automatically.
- No special pack-level handling is required; bookmarks travel with the embedded track JSON.
- Bookmarks remain informational only (see [track_schema.md](track_schema.md#compatibility-notes)).

### Import resilience

- Malformed entries in `tracks[]` are **skipped**; valid entries still import.
- Each embedded track is decoded with the same rules as standalone `.veil.json` import.
- Unsupported item types inside a track are skipped without failing the pack.

### Runtime scope

- Track packs store metadata only. They do not contain video bytes.
- Playback still requires the user to open the matching local video file.
- VEIL actions (`mask` / `mute` / `skip`) apply at playback time; the source video is never modified.

### Versioning

- `format` + root `version` identify the pack envelope.
- Individual tracks carry their own `version` field (`1.4.0` for desktop tracks).
- Clients should tolerate newer envelope or track versions when unknown fields are present.

---

## Related

- [track_schema.md](track_schema.md) — embedded track JSON
- `lib/core/track_packs/track_pack_codec.dart` — implementation
