import { readFileSync } from 'node:fs'

const parserPath = process.argv[2]
const documentPath = process.argv[3]
if (!parserPath || !documentPath) {
  throw new Error('Usage: vite-node desktop_rc2_parse_probe.ts <trackSchema.ts> <file>')
}
const normalizedParserPath = parserPath.replaceAll('\\', '/')
const parserModule = /^[A-Za-z]:\//.test(normalizedParserPath)
  ? `/@fs/${normalizedParserPath}`
  : normalizedParserPath
const { parseVeilTrackJson } = await import(parserModule)
const result = parseVeilTrackJson(readFileSync(documentPath, 'utf8'))
console.log(JSON.stringify({ ok: result.ok, status: result.status }))
if (!result.ok) process.exit(1)
