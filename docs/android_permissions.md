# Android permissions

Audit of VEIL Player Mobile Android permissions for beta and Play Store release.

## Summary

| Permission | Source | Needed? |
|------------|--------|---------|
| `INTERNET` | Debug/profile overlay; may merge from plugins in release | Optional — network video URLs only |
| `ACCESS_NETWORK_STATE` | Plugin merge (e.g. video / connectivity) | Yes — standard for network-aware playback |
| `WAKE_LOCK` | Plugin merge | Yes — keeps screen on during playback |

**No dangerous permissions** (location, camera, microphone, contacts, SMS, phone) are declared.

**No legacy storage permissions** (`READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `MANAGE_EXTERNAL_STORAGE`) in the app manifest. File access uses:

- Android **Storage Access Framework** (`content://` URIs) via `file_picker` and Open With intents
- App **cache directory** for copying inbound `content://` files (`MainActivity`)

## Manifest locations

| File | Purpose |
|------|---------|
| `android/app/src/main/AndroidManifest.xml` | Production manifest (launcher, Open With intent filters) |
| `android/app/src/debug/AndroidManifest.xml` | Adds `INTERNET` for Flutter tooling (hot reload, debugger) |
| `android/app/src/profile/AndroidManifest.xml` | Adds `INTERNET` for profile builds |

Release APKs built with `flutter build apk --release` do **not** include debug/profile overlays. Verify merged manifest after dependency changes:

```bash
flutter build apk --release
# Inspect build/app/intermediates/merged_manifests/release/
```

## Intent filters (not permissions)

Open With handlers are declared on `MainActivity` for:

- `video/*`
- `application/json`
- `text/plain` + `.json` / `.veil.json` path patterns
- `content://` and `file://` path patterns for `.mp4`, `.mkv`, `.webm`, `.json`, `.veil.json`

These do not grant storage access by themselves; the user chooses files via the system picker or share sheet.

## Minimization policy

1. Do not add permissions unless a feature requires them.
2. Prefer SAF / `content://` over broad storage reads.
3. Document any new permission in this file before merging.
4. Re-audit merged manifest before each Play Store upload.

## Package identity

- **applicationId:** `com.veil.mobile`
- **namespace:** `com.veil.mobile`
- **App label:** `VEIL Player Mobile` (`res/values/strings.xml`)

## Related docs

- [release_readiness.md](release_readiness.md) — build and signing
- [qa_checklist.md](qa_checklist.md) — manual device QA
