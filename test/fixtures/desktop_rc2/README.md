# Desktop RC2 interoperability fixtures

These fixtures exercise deterministic VEIL Player Desktop to VEIL Mobile
interoperability. Desktop is a non-normative implementation reference; the
canonical VEIL specification remains authoritative.

Reference Desktop source commit:
`e99f262ae9ea172b495a231794c38f1025910728`

## Coverage

- A: basic local-media document
- B/C: Skip with positive and negative global offsets
- D/E/F: Mute, Mask, and Bookmark
- G: multiple supported item types
- H: disabled items
- I/J: metadata-v1 and manual-unbound identity
- K: unknown additive field
- L: isolated unknown future item beside a known item
- M: style-less Mask
- N: duplicate item IDs accepted by the Reader
- O: malformed known item rejected as a document

`expected.json` records the expected parser/runtime outcomes.

## Deterministic generation

The generator fixes `exportedAt` at `2026-09-15T00:00:00.000Z` and invokes the
Desktop RC2 writer. From a VEIL Player Desktop checkout with its dependencies
installed, run the equivalent of:

```text
copy <veil-mobile>/tool/generate_desktop_rc2_fixtures.ts <veil-player>/tmp-ui-verify/
cd <veil-player>
npx vite-node tmp-ui-verify/generate_desktop_rc2_fixtures.ts . <veil-mobile>/test/fixtures/desktop_rc2
```

Remove the temporary generator copy from the Desktop checkout afterward. The
Desktop parser probe is `tool/desktop_rc2_parse_probe.ts`. Paths are supplied
by the caller; no private machine path is embedded in the fixtures.

## Synthetic media and verified hashes

`synthetic-veil-6s.wav` is a small, programmatically generated six-second WAV
created solely for interoperability testing; it contains no copyrighted media.

```text
Desktop-authored real .veil
E23142DCF3EE3E0A84B33B7A2CD070412300265B975AE1E29D18FBB90279F7C3

Synthetic WAV
4ADF544841103D2088E78D7FD84FBD930E7121591DE593A95ABBEDBDDD59B97A

Mobile-authored .veil
5F5DD01717BB2FD19E70D75B732B6B76777856C581376B2A114A801E9DEFFC2B
```

Important expected results include `ACCEPT_PARTIAL` with an inert unknown item
for L, Reader `ACCEPT` for N, and `REJECT_DOCUMENT` for O.
