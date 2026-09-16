# VEIL Player Mobile

VEIL Player Mobile is an open-source, non-normative mobile implementation of the
[VEIL Interoperability Specification](https://github.com/allamzedan/veil).
The normative authority is **VEIL Interoperability Specification 0.1**; this
repository is an implementation, not a second copy of the specification.

- Application version: `0.2.3+1`
- Validated release target: Android
- Desktop sibling: [VEIL Player](https://github.com/allamzedan/veil-player)

Flutter scaffolding for other platforms is retained, but those targets have
not received the Android release validation described here.

## Capability scope and conformance

VEIL Player Mobile is VEIL Spec 0.1 conforming within its declared capability scope:

- Reader
- Writer
- Playback
- Local Media Identity
- Canonical Validation
- Resource Safety

Provider Integration is not claimed. Provider/YouTube integration is not
supported.

Frozen VEIL Conformance Corpus 0.1 result:

```text
104 PASS
0 FAIL
9 N/A
0 UNTESTABLE
```

The nine N/A vectors are Provider Integration/YouTube vectors outside the
declared Mobile capability scope. This is not a claim of 113/113 PASS.

## What it does

VEIL Player Mobile opens supported local media, reads and writes canonical `.veil`
files, and executes supported Skip, Mute, Mask, and Bookmark semantics. It
implements local media identity and interoperates with VEIL Player Desktop.
Processing is local and non-destructive; VEIL actions do not alter the source
media file.

## Security model

`.veil` files are passive declarative data. Parsing a file does not grant it
authority to execute arbitrary code or processes, access arbitrary files, or
perform arbitrary network requests. Resource limits and canonical validation
are applied within Mobile's declared scope. This is an implementation summary,
not a security guarantee beyond the normative specification.

## Build and test

Validated toolchain:

- Flutter 3.44.0 stable
- Dart 3.12.0
- Android compile SDK 36 and target SDK 36
- Gradle 9.1.0
- Android Gradle Plugin 8.11.1
- Kotlin plugin 2.3.20
- Java language level 17

The successful local Android build used a JDK 21 runtime. JDK 21 is not a VEIL
requirement; use a JDK compatible with the pinned Flutter/Gradle toolchain.

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Run the frozen corpus adapter directly with:

```bash
flutter test test/conformance/spec_0_1_harness_test.dart --reporter expanded
```

`pubspec.lock` is committed because this is an application repository.

## Interoperability evidence

Desktop-to-Mobile and Mobile-to-Desktop fixtures are under
[`test/fixtures`](test/fixtures). The Desktop RC2 fixture set documents its
provenance and deterministic generation in
[`test/fixtures/desktop_rc2/README.md`](test/fixtures/desktop_rc2/README.md).
VEIL Player Desktop is a non-normative implementation reference.

## Privacy and licensing

See the [privacy policy](docs/legal/privacy_policy.md).

VEIL Player Mobile original source code and project-owned branding are provided under
the Apache License 2.0. Copyright 2026 Allam Zedan.

The imported frozen VEIL Conformance Corpus 0.1 remains under CC0 1.0
Universal. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) and the corpus
[licensing notice](docs/spec_0_1/conformance/README.md).

Contributions are welcome under [CONTRIBUTING.md](CONTRIBUTING.md). Security
reports should follow [SECURITY.md](SECURITY.md).
