# VEIL Player Mobile branding

Product identity reference for launcher name, app icons, in-app marks, and native splash.

## Launcher name

| Platform | Value | Location |
|----------|-------|----------|
| Android | **VEIL Player Mobile** | `android/app/src/main/res/values/strings.xml` → `app_name` |
| iOS | **VEIL Player Mobile** | `ios/Runner/Info.plist` → `CFBundleDisplayName` |
| iOS bundle id | **com.veil.mobile** | `ios/Runner.xcodeproj` → `PRODUCT_BUNDLE_IDENTIFIER` |
| In-app | **VEIL Player Mobile** | `lib/shared/constants/app_strings.dart` → `appName` |

Android manifest references `@string/app_name` in `AndroidManifest.xml`.

## Brand assets (v1)

| File | Purpose | Status |
|------|---------|--------|
| `assets/branding/app_icon.png` | Launcher icon master (1024×1024 PNG) | **In use** |
| `assets/branding/splash_logo.png` | Centered splash logo | **In use** |

If `splash_logo.png` is removed, point `flutter_native_splash.image` at `app_icon.png` until a dedicated splash asset exists.

See also `assets/branding/README.md`.

## App launcher icon (v1)

Generated from `assets/branding/app_icon.png` via [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons).

### Configuration (`pubspec.yaml`)

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: assets/branding/app_icon.png
  adaptive_icon_background: "#121212"
  adaptive_icon_foreground: assets/branding/app_icon.png
  remove_alpha_ios: true
```

### Regenerate after replacing the master icon

```bash
flutter pub get
dart run flutter_launcher_icons
```

Then rebuild and verify on device.

**Android** — updates `mipmap-*` PNGs, adaptive icon layers (`mipmap-anydpi-v26/ic_launcher.xml`), and `values/colors.xml` (`ic_launcher_background`).

**iOS** — updates `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.

Adaptive background: `#121212` (matches dark theme and splash).

### Manual fallback paths (Android)

```
android/app/src/main/res/mipmap-mdpi/ic_launcher.png      (48×48)
android/app/src/main/res/mipmap-hdpi/ic_launcher.png      (72×72)
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png     (96×96)
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png    (144×144)
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png   (192×192)
```

Adaptive (API 26+): `mipmap-anydpi-v26/ic_launcher.xml`, `drawable-*dpi/ic_launcher_foreground.png`, `drawable/ic_launcher_background.xml`.

## Native splash screen (v1)

Generated via [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash).

### Configuration (`pubspec.yaml`)

```yaml
flutter_native_splash:
  color: "#121212"
  image: assets/branding/splash_logo.png
  android_12:
    color: "#121212"
    image: assets/branding/splash_logo.png
```

Background `#121212` matches `lib/app/theme.dart` dark shell.

### Regenerate after replacing splash artwork

```bash
flutter pub get
dart run flutter_native_splash:create
```

To remove generated splash and revert: `dart run flutter_native_splash:remove`

### Generated outputs

| Platform | Key paths |
|----------|-----------|
| Android | `drawable/launch_background.xml`, `drawable/background.png`, `drawable/splash.png`, `values-v31/styles.xml` (Android 12+) |
| iOS | `ios/Runner/Assets.xcassets/LaunchImage.imageset/`, `LaunchBackground.imageset/` |
| Web | `web/index.html`, `web/splash/` (if building for web) |

`LaunchTheme` in `android/app/src/main/res/values/styles.xml` references `@drawable/launch_background`.

## Replace icon or splash later

1. Replace the master PNG in `assets/branding/` (keep filenames or update `pubspec.yaml` paths).
2. Run the matching generator command above.
3. Rebuild (`flutter build apk` / Xcode archive on Mac).
4. Uninstall the old app on test devices if the launcher icon is cached.

Do not commit invented artwork — only replace with approved brand files.

## In-app visual identity

| Element | Implementation |
|---------|----------------|
| Home | `AppBrandMark` (neutral `play_circle_outline` icon) + tagline — no duplicate product title |
| Settings About | `AppBrandMark` + product name + version |
| Player | No in-app logo during playback |

Widget: `lib/shared/widgets/app_brand_mark.dart` — replace with `Image.asset` when `assets/branding/app_logo.png` exists (future).

## Version alignment

Keep `AppVersion.pubspecLine` in sync when bumping releases:

- `pubspec.yaml` → `version: 0.2.3+1`
- `lib/core/app/app_version.dart` → `pubspecLine`
- `lib/core/veil/veil_track_codec.dart` → `mobileExportAppVersion` (export metadata)

## Related docs

- [ios_preparation.md](ios_preparation.md) — iOS `AppIcon.appiconset`
- [../README.md](../README.md) — validated Android build commands
