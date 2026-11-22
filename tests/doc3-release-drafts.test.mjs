import test from 'node:test'
import assert from 'node:assert/strict'
import {readFileSync} from 'node:fs'

const drafts = new URL('../spec-source/doc3-drafts/', import.meta.url)
const read = name => readFileSync(new URL(name, drafts), 'utf8')
const added = name => read(name).split(/\r?\n/).filter(line => line.startsWith('+') && !line.startsWith('+++')).join('\n')
const setting = 'require_from_number_for_shared_agent'

test('DOC3-SETTINGS read and write expose the matching public contract and distinct roles', () => {
  for (const method of ['get', 'patch']) {
    const page = read('release-a/' + method + '-outbound-settings.mdx.txt')
    assert.ok(page.includes(method.toUpperCase() + ' /organisation/outbound-settings'))
    for (const text of [setting, '## Authentication', '## Request fields', '## Response fields', '## Example request', '## Example response', '## Errors', '## Retry and idempotency']) assert.ok(page.includes(text), text)
    assert.match(page, method === 'get' ? /Owner, Admin or Member/ : /Only the Owner or the organisation key can update it/)
    assert.ok(page.includes('https://api.nixflex.com/v1/organisation/outbound-settings'))
  }
})
test('DOC3-CALLS distinguishes sender selection, strict admission and request receipts', () => {
  const lines = added('release-a/pages.patch')
  for (const term of ['from_number_required', 'settled', 'prompt_validation', 'prompt_too_short','min_length','request_id_conflict','invalid_prompt_validation','invalid_settings']) {
    assert.ok(lines.includes(term), term)
  }
  assert.match(lines,/shared agent/i)
  assert.match(lines,/before dispatch|before dialling/i)
})
test('DOC3-SPEC documents strict wire fields without imposing a global ten-character requirement', () => {
  const lines = added('release-a/contract.patch')
  for (const term of [setting,'prompt_validation','from_number_required','prompt_too_short','additionalProperties','readOrganisationOutboundSettings','updateOrganisationOutboundSettings']) assert.ok(lines.includes(term), term)
  assert.match(read('release-a/contract.patch'), /^-\s*"minLength": 10/m)
})
test('DOC3-HELP uses the ticket controls and the real customer visibility and retry rules', () => {
  const lines = added('sc2-help/pages.patch')
  for (const term of ['Settings → Help','Support tickets','New ticket','My tickets','Retry same request','Reply and reopen','Mark solved','Member']) assert.ok(lines.includes(term), term)
  assert.doesNotMatch(lines,/\/api\/|\/v1\/support|payout/i)
})
test('DOC3-APP distinguishes phone app navigation and contact from dashboard tickets', () => {
  const lines = added('sc2-app/pages.patch')
  for (const name of ['Home', 'Inbox', 'Agents', 'Numbers', 'Outbound', 'Account', 'Help', 'Copy email address', 'support@nixflex.com']) assert.ok(lines.includes(name), name)
  assert.doesNotMatch(lines, /App Store|Google Play|\/api\/|payout/i)
})
