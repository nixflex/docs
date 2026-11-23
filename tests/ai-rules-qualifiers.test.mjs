import assert from 'node:assert/strict'
import test from 'node:test'
import {json, read} from '../scripts/ai-rules-data.mjs'

const guide = read('ai-rules.md')
const resumeRule = 'Resume covers only unattempted work in the existing running launch, and neither resume nor reuse replays completed work.'

function featureText(feature) {
  const marker = '<a id="' + feature + '"></a>'
  assert.ok(guide.includes(marker), feature)
  return guide.split(marker)[1].split('<a id="')[0].trim().split('\n').slice(2).join('\n')
}

test('DOC2D-18 the webhook opening qualifies the one-secret claim before retrieval instructions', () => {
  const section = featureText('webhooks')
  const opening = section.split('\n')[0]
  assert.match(opening, /^\*\*MUST\*\* With organisations enabled, [^.]*one signing secret[^.]*\./)
  assert.match(opening, /human Owner.*dashboard/)
  assert.match(opening, /[Nn]ever ask.*chat.*AI tools/)
  assert.ok(opening.length <= 175)
  const secretRead = section.split('\n\n').find(p => p.includes('GET /v1/organisation/signing-secret'))
  assert.match(secretRead, /With organisations enabled,/)
  assert.ok(read('snippets/ai-rules/webhooks.mdx').includes(opening))
})

test('DOC2D-28 the opening and every campaign rule explaining resume or reuse carry the same complete sentence', () => {
  const section = featureText('campaigns')
  assert.equal(section.split('\n')[0].replace(/\\$/, ''), '**MUST** ' + resumeRule)
  const snippet = read('snippets/ai-rules/campaigns.mdx')
  for (const text of [section, snippet]) {
    for (const paragraph of text.split('\n\n').filter(p => /\b(?:resume|reuse_campaign_id|reuse)\b/i.test(p))) {
      assert.ok(paragraph.includes(resumeRule), paragraph)
    }
  }
  assert.ok(snippet.split('\n')[0].includes('**MUST** ' + resumeRule))
  const pages = json('spec-source/ai-rules/index.json').features.campaigns.pages
  for (const page of pages) assert.ok(read(page + '.mdx').includes('/snippets/ai-rules/campaigns.mdx'), page)
})
