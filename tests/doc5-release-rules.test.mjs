import assert from 'node:assert/strict'
import test from 'node:test'
import {read, json} from '../scripts/ai-rules-data.mjs'

const rules = read('ai-rules.md')
function check(feature, terms) {
  const section = rules.split('<a id="' + feature + '"></a>')[1].split('<a id="')[0]
  for (const term of terms) assert.ok(section.includes(term), feature + ' requires ' + term)
}

test('DOC5-SENDER distinguishes optional fallback from mandatory selection and strict purpose', () => {
  check('outbound-calls', ['oldest eligible', 'disabled', 'Pending imports', '400 from_number_required',
    'prompt_validation=strict', '400 prompt_too_short', 'Owner or organisation API key'])
})
test('DOC5-BOOKING separates call time from calendar time and replaces stale approval', () => {
  check('bookings-calendars', ['calcom_timezone_override', 'null to inherit', 'number → agent → saved connection → Europe/London',
    'effective_calcom_timezone_source', 'changed across lookups', 'fresh yes', 'calendar write succeeds'])
})
test('DOC5-CAMPAIGN scopes the denominator and separates opt-out evidence from permission', () => {
  check('campaigns', ['business_number', '%2B', 'max 200', 'failed starts', 'Zero attempts', 'no detected voicemail', 'delivered + failed'])
  check('contact-controls', ['off by default', 'no switch', 'source=attributed', 'review_version', 'Keyword STOP', 'never supplies consent'])
})
test('DOC5-HELP binds personal reads, writes and receipts to the original workspace', () => {
  check('account-access', ['Your open chats', 'watch_ticket', 'X-Nixflex-Expected-Account', '409 account_changed',
    'Idempotency-Key', 'X-Expected-Revision', 'requests/{request_key}', 'current ticket and original receipt', 'missing or inaccessible'])
  const ops = Object.values(json('spec-source/ai-rules/index.json').releaseOperations).flat()
  assert.equal(ops.length, 10)
  assert.equal(new Set(ops).size, 10)
  assert.equal(ops.filter(op => op.includes('/v1/support/tickets')).length, 7)
  assert.ok(ops.every(op => op.includes(' /v1/') && !op.includes('weekly')))
})
