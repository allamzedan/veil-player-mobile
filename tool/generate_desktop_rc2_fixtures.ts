import fs from 'node:fs'
import path from 'node:path'

const desktopRoot = process.argv[2]
if (!desktopRoot) {
  throw new Error('Usage: vite-node generate_desktop_rc2_fixtures.ts <desktop-root>')
}

const exportedAt = '2026-09-15T00:00:00.000Z'
const RealDate = Date
class FixedDate extends RealDate {
  constructor(value?: string | number) {
    super(value ?? exportedAt)
  }
  static override now(): number {
    return RealDate.parse(exportedAt)
  }
}
globalThis.Date = FixedDate as DateConstructor

const viteFileModule = (file: string) =>
  `/@fs/${file.replaceAll('\\', '/')}`
const serializationModule = viteFileModule(
  path.join(desktopRoot, 'src/lib/trackSerialization.ts'),
)
const unboundModule = viteFileModule(
  path.join(desktopRoot, 'src/lib/unboundTrack.ts'),
)
const { buildVeilTrackFromStore } = await import(serializationModule)
const { buildVeilTrackFromManualBuilderBatch } = await import(unboundModule)

const outputDirectory = process.argv[3]
  ? path.resolve(process.argv[3])
  : path.resolve('test/fixtures/desktop_rc2')
const mediaName = 'synthetic-veil-6s.wav'
const mediaBytes = 96044

const mute = (id: string, start: number, end: number, enabled = true) => ({
  id,
  type: 'mute' as const,
  start,
  end,
  enabled,
  locked: false,
})
const skip = (id: string, start: number, end: number, enabled = true) => ({
  id,
  type: 'skip' as const,
  start,
  end,
  enabled,
  locked: false,
})
const bookmark = (
  id: string,
  start: number,
  enabled = true,
  label = 'Reference point',
) => ({
  id,
  type: 'bookmark' as const,
  start,
  end: start,
  enabled,
  locked: false,
  label,
})
const mask = (id: string, start: number, end: number, enabled = true) => ({
  id,
  type: 'mask' as const,
  start,
  end,
  enabled,
  locked: false,
  rect: {
    xPercent: 10,
    yPercent: 10,
    widthPercent: 30,
    heightPercent: 20,
  },
  style: { mode: 'solid' as const, color: '#000000', opacity: 0.8 },
  source: { kind: 'manual' as const },
})

function desktopDocument(overrides: Record<string, unknown> = {}) {
  const state = {
    masks: [],
    mutes: [],
    skips: [],
    bookmarks: [],
    preservedUnknownItems: [],
    preservedUnknownRootFields: {},
    globalOffsetSeconds: 0,
    trackMetadata: {
      title: 'VEIL RC2 synthetic interoperability',
      createdAt: exportedAt,
    },
    groups: [],
    anchors: [],
    subtitleCoverMode: 'show',
    regionCoverRect: {
      xPercent: 10,
      yPercent: 78,
      widthPercent: 80,
      heightPercent: 18,
    },
    videoMetadata: {
      name: mediaName,
      duration: 6,
      fileSize: mediaBytes,
      width: 0,
      height: 0,
    },
    videoFileName: mediaName,
    mediaSource: null,
    ...overrides,
  }
  const document = buildVeilTrackFromStore(state)
  if (!document) throw new Error('Desktop writer unexpectedly returned null')
  return structuredClone(document) as Record<string, any>
}

const fixtures: Record<string, Record<string, any>> = {
  'A-basic-local.veil': desktopDocument(),
  'B-skip-positive-offset.veil': desktopDocument({
    skips: [skip('skip-positive', 3, 5)],
    globalOffsetSeconds: 2,
  }),
  'C-skip-negative-offset.veil': desktopDocument({
    skips: [skip('skip-negative', 1, 3)],
    globalOffsetSeconds: -1,
  }),
  'D-mute.veil': desktopDocument({ mutes: [mute('mute-1', 1, 2)] }),
  'E-mask.veil': desktopDocument({ masks: [mask('mask-1', 1, 2)] }),
  'F-bookmark.veil': desktopDocument({
    bookmarks: [bookmark('bookmark-1', 2.5)],
  }),
  'G-multiple-types.veil': desktopDocument({
    masks: [mask('mask-g', 2, 4)],
    mutes: [mute('mute-g', 1, 2)],
    skips: [skip('skip-g', 4, 5)],
    bookmarks: [bookmark('bookmark-g', 3, true, 'Middle')],
  }),
  'H-disabled-items.veil': desktopDocument({
    masks: [mask('mask-disabled', 1, 5, false)],
    mutes: [mute('mute-disabled', 1, 5, false)],
    skips: [skip('skip-disabled', 1, 5, false)],
    bookmarks: [bookmark('bookmark-disabled', 2, false)],
  }),
  'I-metadata-v1.veil': desktopDocument(),
  'J-manual-unbound.veil': buildVeilTrackFromManualBuilderBatch({
    masks: [],
    mutes: [mute('manual-mute', 1, 2)],
    skips: [],
  }),
  'K-unknown-additive-field.veil': desktopDocument(),
  'L-unknown-future-beside-known.veil': desktopDocument({
    mutes: [mute('known-l', 1, 2)],
  }),
  'M-style-less-mask.veil': desktopDocument({
    masks: [mask('mask-styleless', 1, 2)],
  }),
  'N-duplicate-item-ids.veil': desktopDocument({
    mutes: [mute('duplicate', 1, 2)],
    skips: [skip('unique-before-reader-mutation', 3, 4)],
  }),
  'O-malformed-known-item.veil': desktopDocument({
    mutes: [mute('malformed', 1, 2)],
  }),
  'real-desktop-to-mobile.veil': desktopDocument({
    masks: [mask('real-mask', 1, 2)],
    mutes: [mute('real-mute', 2, 3), mute('real-disabled', 0, 6, false)],
    skips: [skip('real-skip', 3.5, 4.5)],
    bookmarks: [bookmark('real-bookmark', 2.5, true, 'Observed bookmark')],
    globalOffsetSeconds: 0.5,
  }),
}

fixtures['K-unknown-additive-field.veil'].futureRoot = {
  displayHint: 'inert',
}
fixtures['L-unknown-future-beside-known.veil'].items.push({
  id: 'future-l',
  type: 'future-veil-action',
  enabled: true,
  payload: { uri: 'http://127.0.0.1/private', command: 'ignored' },
})
delete fixtures['M-style-less-mask.veil'].items[0].style
fixtures['N-duplicate-item-ids.veil'].items[1].id = 'duplicate'
delete fixtures['O-malformed-known-item.veil'].items[0].end

fs.mkdirSync(outputDirectory, { recursive: true })
for (const [name, document] of Object.entries(fixtures)) {
  fs.writeFileSync(
    path.join(outputDirectory, name),
    `${JSON.stringify(document, null, 2)}\n`,
  )
}

fs.writeFileSync(
  path.join(outputDirectory, 'expected.json'),
  `${JSON.stringify(
    {
      desktopHead: 'e99f262ae9ea172b495a231794c38f1025910728',
      writer: 'actual RC2 buildVeilTrackFromStore / buildVeilTrackFromManualBuilderBatch',
      generatedAt: exportedAt,
      expected: Object.fromEntries(
        Object.keys(fixtures).map((name) => [
          name,
          name === 'O-malformed-known-item.veil'
            ? 'REJECT_DOCUMENT'
            : name === 'L-unknown-future-beside-known.veil'
              ? 'ACCEPT_PARTIAL; unknown inert; known Mute active at host 1.5s'
              : 'ACCEPT',
        ]),
      ),
    },
    null,
    2,
  )}\n`,
)
