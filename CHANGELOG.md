# Changelog

All notable changes to VEIL Player Mobile are documented in this file.

## 0.2.3+1 — Closed Beta RC4

Fourth closed-beta release candidate. Packages Beta UX Fixes v2 into an RC build cut. Version/docs/build only — no new features beyond already implemented work.

### Included in RC4

- Home **Open Video** now opens the video picker directly
- Player supports **Open another video** from details and overflow paths
- Fixed Player tab-return single-tap behavior (tap-to-play/pause restored)
- Cleaner Library layout with folder/media-first hierarchy
- Folder browsing foundation with Android-storage fallback messaging
- Dedicated Bookmarks sheet for list/jump/edit/delete flow
- End-of-video next-suggestion screen foundation
- **Autoplay next video** setting defaults to off
- Splash timing improved for slightly longer cold-start hold
- VEIL export default extension updated to `.veil` (with backward-compatible import)
- Settings → About includes developer attribution

---

## 0.2.2+1 — Closed Beta RC3

Third closed-beta release candidate. Packages crash fixes, storage hardening, and player gesture improvements on top of RC2. Version/docs/build cut only — no new features beyond what already shipped since RC2.

### Stability & memory

- Fixed video file picker OOM crash (`ByteArrayOutputStream` when switching videos)
- Video files are no longer loaded fully into memory (`withData: false`; path/stream copy only)
- Added 500 MB beta video size guard with friendly warning

### Player fixes

- Fixed +VEIL menu crash with bookmark-only tracks (null export subtitle)
- Replaced misleading full-screen “Storage operation failed” widget error fallback
- Hardened autosave and history storage failures — compact snackbar, player stays visible

### Player gestures

- Right-side vertical swipe controls volume (0–100%, persisted)
- Left-side vertical swipe controls in-app brightness dim (0–100%, persisted)
- VEIL mute runtime still forces silence; user volume restores after mute segment ends

### Carried forward from RC2

- Bookmark segments, track schema docs, Subtitle Settings v2, Track Packs foundation

### Known scope limits (beta)

- Local-only; no cloud sync or accounts
- Android-first; iOS not packaged in this candidate
- Pro subscription features are planned but not enabled
- Release APK is debug-signed until a production keystore is configured
- Videos over **500 MB** are blocked in this beta build

---

## 0.2.1+1 — Closed Beta RC2

Second closed-beta release candidate. Packages bookmark segments, track schema documentation, beta UX fixes, and Subtitle Settings v2 on top of the RC1 baseline. No new features beyond what shipped since RC1.

### Beta UX fixes

- Track Builder UX v1 — quick-add row, segment search/filters, clearer segment cards
- Improved time input validation and library section visibility
- Mask rect resize handles and related player/setup polish

### Subtitle Settings v2

- Font size, position, background toggle/opacity, and delay adjustment
- Settings persisted locally and applied during fullscreen playback
- Subtitle cues render with VEIL masks above them

### Bookmark segments

- Bookmark item type for non-destructive timeline markers (title + optional note)
- Quick add from player (+ VEIL → Bookmark) and Track Builder
- Timeline bookmark markers; bookmarks export/import in desktop-compatible JSON
- Bookmarks are informational only — excluded from mask/mute/skip runtime

### Track schema documentation

- `docs/track_schema.md` — desktop VEIL track JSON and item types (mask, mute, skip, bookmark)
- `docs/track_pack_schema.md` — `.veilpack.json` pack format
- Example files under `docs/examples/`
- Compatibility regression tests in `test/track_schema_compatibility_test.dart`

### Track Packs foundation

- Local `.veilpack.json` import/export and library collections
- Embedded desktop-compatible track JSON per pack entry
- Malformed pack entries skipped on import without failing the pack

### Reliability (carried forward from RC1)

- 146 automated tests; analyzer clean
- Autosave/recovery, diagnostics export, defensive import parsing
- English/Arabic UI with RTL support

### Known scope limits (beta)

- Local-only; no cloud sync or accounts
- Android-first; iOS not packaged in this candidate
- Pro subscription features are planned but not enabled
- Release APK is debug-signed until a production keystore is configured

---

## 0.2.0+1 — Closed Beta Candidate

First testable closed-beta release. Feature development is frozen for this milestone.

### Playback & media

- Local video playback (MP4, MKV, WEBM)
- Fullscreen immersive mode with rotation support
- Player gestures: tap chrome, double-tap seek, long-press 2x speed, horizontal scrub
- Recent sessions and Continue Last Session
- Android Open With for video and VEIL track files

### VEIL tracks

- Import and export desktop-compatible `.veil.json` tracks
- Mask, mute, and skip runtime evaluation during playback
- Quick authoring from the player (mask placement, duration presets)
- Segment Manager: add, edit, duplicate, delete, and jump to segments
- Track preview and track details (read-only inspection)
- Track Packs: local `.veilpack.json` import/export and collections

### Subtitles

- Load `.srt` and `.vtt` subtitle files
- Toggle subtitles during playback
- **Subtitle Settings v2** — font size, position, background toggle/opacity, and delay adjustment (persisted locally)
- Subtitle cues render with VEIL masks above them in fullscreen

### Authoring & library

- Track Builder for full segment editing
- Saved tracks library with validation status
- Media history: recent videos, recent tracks, last session

### Localization & UX

- English and Arabic UI with RTL support
- System, English, and Arabic language preferences

### Reliability

- Autosave and recovery drafts (Player and Track Builder)
- Diagnostics screen with exportable bug-report text
- In-app QA checklist for manual verification
- Defensive import parsing and friendly error messages

### Legal

- In-app Privacy Policy and Terms of Use (local assets)

### Known scope limits (beta)

- Local-only; no cloud sync or accounts
- Android-first; iOS not packaged in this candidate
- Pro subscription features are planned but not enabled
- Release APK is debug-signed until a production keystore is configured
