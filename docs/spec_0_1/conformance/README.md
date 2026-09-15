# VEIL Conformance Corpus 0.1

This directory contains the imported frozen VEIL Conformance Corpus 0.1 used
by Mobile's conformance adapter.

- Canonical source: https://github.com/allamzedan/veil
- Corpus version: 0.1
- Vector count: 113
- License: CC0 1.0 Universal
- Local runner: `test/conformance/spec_0_1_harness_test.dart`

The corpus is separately licensed and is not covered by this repository's
Apache-2.0 license. The full CC0 text is retained as `CC0-1.0.txt`.

The canonical VEIL repository remains normative. This imported copy exists for
deterministic implementation testing and must not be edited to accommodate
Mobile behavior.

Current Mobile result within its declared capability scope:

```text
104 PASS
0 FAIL
9 N/A
0 UNTESTABLE
```

All nine N/A vectors are Provider Integration/YouTube vectors outside Mobile's
declared scope.
