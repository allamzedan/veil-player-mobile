# Contributing to VEIL Player Mobile

Thank you for contributing to VEIL Player Mobile.

1. Create a focused branch and keep changes within Mobile's declared product
   and VEIL capability scope.
2. Use the toolchain documented in `README.md` and run:

   ```bash
   flutter pub get
   flutter analyze
   flutter test
   flutter test test/conformance/spec_0_1_harness_test.dart --reporter expanded
   ```

3. Explain behavior changes and include focused tests.
4. Do not change normative VEIL semantics through this implementation. Raise
   specification issues in the canonical repository:
   https://github.com/allamzedan/veil
5. Do not modify the frozen conformance corpus or its expected outcomes. New
   implementation tests should be kept separate from frozen vectors.
6. Never commit credentials, signing material, private media, or generated
   build output.

Unless explicitly stated otherwise, contributions intentionally submitted to
this repository are made under its Apache License 2.0 licensing model as
applicable. No contributor license agreement is required by this document.
