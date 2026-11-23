import assert from 'node:assert/strict'
import test from 'node:test'
import {json, read} from '../scripts/ai-rules-data.mjs'

const raw = 'https://raw.githubusercontent.com/nixflex/docs/main/'
const aliases = new Map()
for (const name of ['ai-rules', 'AGENTS', 'CLAUDE']) {
  aliases.set('/' + name, name + '.md')
  aliases.set('/' + name + '.md', name + '.md')
}

test('DOC2E-ROUTES all six public guide aliases lead directly to the matching raw Markdown file', () => {
  for (const config of ['docs.json', 'spec-source/c15-pages.json']) {
    const {redirects} = json(config)
    for (const [source, filename] of aliases) {
      const matches = redirects.filter(rule => rule.source === source)
      assert.equal(matches.length, 1, config + ' ' + source)
      assert.equal(matches[0].destination, raw + filename, source)
      assert.equal(read(filename), read('ai-rules.md'))
    }
  }
})

test('DOC2E-LINKS both entry pages offer a named download for each assistant and a stable guide link', () => {
  for (const page of ['index.mdx', 'guides/developer/build-with-ai.mdx']) {
    const body = read(page)
    assert.ok(body.includes('[Read the rules](https://docs.nixflex.com/ai-rules.md)'), page)
    assert.ok(body.includes("import { RulesDownload } from '/snippets/RulesDownload.jsx'"), page)
    for (const name of ['AGENTS.md', 'CLAUDE.md']) {
      assert.ok(body.includes('<RulesDownload name="' + name + '" />'), page + ' ' + name)
    }
    assert.ok(!body.includes('href="/downloads/nixflex-ai-rules.txt"'), page)
  }
})
