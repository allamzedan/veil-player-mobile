# VEIL Mobile localization

Structure for multilingual support. English is the default; Arabic v1 provides full UI copy with RTL layout.

## Current state

| Item | Status |
|------|--------|
| Default language | English (`en`) |
| Arabic UI copy | **v1 complete** — Modern Standard Arabic in `app_localizations_ar.dart` |
| Arabic RTL layout | Enabled when Arabic or Arabic system locale is selected |
| Persistence | `shared_preferences` key `locale_preference` |
| Remaining QA | Manual RTL pass on all screens; some layouts may need pixel-level polish |

## Architecture

```
lib/core/localization/
  app_locale.dart              # LocalePreference enum + language codes
  app_localizations.dart       # English strings + factory
  app_localizations_ar.dart    # Arabic overrides (part of app_localizations.dart)
  app_localizations_holder.dart # Sync holder for non-widget code
  localization_provider.dart   # Riverpod: preference, locale, direction

lib/shared/constants/app_strings.dart  # Backward-compatible delegate → holder
```

### Accessing strings

**In widgets (preferred):**

```dart
ref.watch(appLocalizationsProvider).homeTitle;
// or
AppStrings.homeTitle; // delegates to AppLocalizationsHolder
```

**In controllers / services without context:**

```dart
AppStrings.playerTrackLoadError;
```

The holder is updated on each frame via `appLocalizationsSyncProvider` in `VeilMobileApp`.

### Material localizations

`MaterialApp` is configured with:

- `supportedLocales`: `en`, `ar`
- `localizationsDelegates`: Material, Widgets, Cupertino global delegates
- Explicit `Directionality` from `appTextDirectionProvider` for RTL

## Language setting

**Settings → Language**

| Option | Behavior |
|--------|----------|
| System Default | Uses device locale; Arabic device → `ar` + RTL, otherwise `en` |
| English | Forces `en` + LTR |
| Arabic | Forces `ar` + RTL with Arabic copy |

Stored values: `system`, `en`, `ar`.

## Arabic v1 scope

Translated in v1:

- Home, Library, Player, Track Builder, Settings, About
- Navigation labels and common actions (Save, Cancel, Delete, Edit, Export, Import, Open, Resume, Remove, Confirm)
- Player controls (+VEIL sheet, segments, fullscreen, subtitles, playback speed)
- Snackbars and common error messages
- Language and Plan settings sections

**Not translated (by design):** product name `VEIL`, technical terms like `JSON`, file/schema identifiers.

## Adding or updating strings

1. Add the English getter to `AppLocalizations` in `app_localizations.dart`.
2. Add the Arabic `@override` in `app_localizations_ar.dart` (MSA, concise; keep `VEIL` untranslated).
3. Regenerate the `AppStrings` delegate if needed:

   ```bash
   python tool/gen_app_strings_delegate.py
   ```

4. Add or update tests in `test/localization_ar_test.dart`.
5. Run manual RTL QA when the string appears in navigation, lists, sheets, or player chrome.

### Rules for future strings

1. **No hardcoded user-facing text** in widgets, snackbars, or dialogs — use `AppStrings` or `appLocalizationsProvider`.
2. **English first** — add English in the base class; Arabic is always an override in `app_localizations_ar.dart`.
3. **Keep copy short** — Arabic strings should not be much longer than English to avoid overflow in RTL.
4. **Leave brands and technical IDs untranslated** — `VEIL`, `JSON`, enum/type names shown to developers.
5. **Use directional layout** — prefer `EdgeInsetsDirectional`, `AlignmentDirectional`, and `PositionedDirectional` in new UI so RTL mirrors correctly.

### Optional ARB migration

Move strings to `lib/l10n/app_en.arb` and `app_ar.arb`, enable `flutter gen-l10n`, and replace hand-written classes — the Riverpod layer can stay.

## Remaining translation QA

Manual checks still recommended:

- [ ] Settings → Arabic → confirm all tabs and section headers
- [ ] Player: open video, load track, +VEIL sheet, segments list
- [ ] Track Builder and Library long labels on narrow phones
- [ ] Bottom sheets and snackbars — no major overflow or clipping
- [ ] Mask placement resize handle mirrors correctly in RTL

Pixel-perfect RTL alignment is out of scope for v1; report obvious breaks only.

## Verification

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Manual:

- Settings → Language → English (LTR)
- Settings → Language → Arabic (RTL, Arabic copy on main screens)
- Player playback and bottom sheets in RTL
