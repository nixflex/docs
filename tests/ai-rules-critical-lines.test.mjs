import assert from 'node:assert/strict'
import test from 'node:test'
import {read} from '../scripts/ai-rules-data.mjs'

const guide = read('ai-rules.md')
function section(id) {
  const marker = '<a id="' + id + '"></a>'
  assert.ok(guide.includes(marker), id)
  return guide.split(marker)[1].split('<a id="')[0].trim().split(/\n\s*\n/).slice(1)
}

for (const [id, feature, required] of [
  ['02', 'outbound-actions-variables', ['[SEND_SMS: message]', '[TRANSFER: phone_number]', 'incall_sms_enabled']],
  ['18', 'webhooks', ['organisations enabled', 'human Owner', 'dashboard', 'AI tools', 'chat']],
]) {
  test('DOC2C-' + id + ' starts the actual feature with its short MUST line', () => {
    const line = section(feature)[0].split('\n')[0]
    assert.match(line, /^\*\*MUST\*\* /)
    assert.ok(line.length <= 175)
    for (const term of required) assert.ok(line.includes(term), term)
  })
}

for (const [id, feature, required] of [
  ['15', 'knowledge', [/410 number_knowledge_removed/, /separate agents/i, /channels/i]],
  ['20', 'inbox-history', [/inbox number discovery is account-wide/i, /DELETE \/v1\/calls/, /related recordings/i, /sms_deleted=0/]],
  ['28', 'campaigns', [/unattempted/i, /running launch/i, /reuse/i, /replays? completed work/i, /fresh ID/i]],
]) {
  test('DOC2C-' + id + ' keeps the exact outcome with the operational rule', () => {
    assert.ok(section(feature).some(p => required.every(pattern => pattern.test(p))))
  })
}
