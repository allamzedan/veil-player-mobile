# VEIL Player Mobile branding assets

Project-owned VEIL Player Mobile artwork for launcher icons and native splash.
Copyright 2026 Allam Zedan; distributed with the original Mobile source under
Apache-2.0. No third-party artwork source is identified.

**Do not commit invented or unlicensed logos.**

## Files

| File | Purpose |
|------|---------|
| `app_icon.png` | Master launcher icon (1024×1024 PNG) |
| `splash_logo.png` | Centered splash logo |

If `splash_logo.png` is unavailable, set `flutter_native_splash.image` to `app_icon.png` in `pubspec.yaml` until a dedicated splash asset is added.

## `app_icon.png` requirements

- **Size:** 1024×1024 px (square)
- **Format:** PNG
- **Transparency:** Avoid for iOS App Store; `remove_alpha_ios: true` is enabled in generator config
- **Safe margins:** Keep the mark inside the center ~66% — Android adaptive icons crop outer edges
- **Shape:** Simple, readable at 48×48 dp on light and dark home screens

## `splash_logo.png` requirements

- **Size:** ~512×512 px or larger (centered on splash)
- **Format:** PNG
- **Background:** Transparent OK — splash fill is `#121212`

## Generate launcher icons

```bash
flutter pub get
dart run flutter_launcher_icons
```

## Generate native splash

```bash
flutter pub get
dart run flutter_native_splash:create
```

See [docs/branding.md](../../docs/branding.md) for full paths, Android 12 details, and how to replace assets later.
