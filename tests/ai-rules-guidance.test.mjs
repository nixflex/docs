import assert from 'node:assert/strict'
import test from 'node:test'
import {read} from '../scripts/ai-rules-data.mjs'

// A reader landing directly on a feature must find the instruction and its limits together.
const guide = read('ai-rules.md')
function checkPassage(section, terms) {
  const start = '<a id="' + section + '"></a>'
  assert.ok(guide.includes(start), section)
  const paragraphs = guide.split(start)[1].split('<a id="')[0].split(/\n\s*\n/)
  const match = paragraphs.some(p => terms.every(term => typeof term === 'string' ? p.includes(term) : term.test(p)))
  assert.ok(match, section + ' needs a single passage covering ' + terms.join(', '))
}

const cases = [
  ['02', 'outbound-actions-variables', ['[TRANSFER: phone_number]', '[SEND_SMS: message]', '[WAIT]', '[END_CALL]', '[IVR]', '[PRESS: digits]', '[IVR_END]', 'incall_sms_enabled', /outbound.only/i, /custom function/i]],
  ['08', 'phone-numbers', ['POST /v1/phone-numbers', 'phone_number', 'agent_id', /customer.*own/i, /active agent|active.*agent_id/i, /one complete/i, 'twilio_sid', 'twilio_token', 'telnyx_api_key', 'telnyx_connection_id', /optional.*telnyx_public_key|telnyx_public_key.*optional/i, /browser/i, /chat|AI prompt/i]],
  ['09', 'account-access', [/internal staging|staging.*internal/i, /no self-service|cannot provision/i, /fixtures/i, /owned test number/i, /provision/i]],
  ['12', 'sms', ['incall_sms_enabled', /SMS-capable/i, /credential/i, /inbound/i, /outbound/i, /caller/i, /opt-out|STOP/i, /another tenant/i]],
  ['13', 'agents-voices', [/dynamic greeting/i, 'custom_prompt', 'welcome_message', /pickup delay/i, /language/i, /general.*timezone/i, /separate agent/i, /booking timezone/i]],
  ['14', 'agents-voices', [/whole/i, /complete/i, /primary/i, /backup/i, 'voice_pair_inherit', 'voice_id', /unavailable/i]],
  ['18', 'webhooks', [/organisation/i, /human Owner/i, /dashboard/i, /Admin.*Member/i, /API credential/i, /never ask/i, /chat/i]],
  ['21', 'billing-usage', [/unlimited/i, /no fee per agent/i, /minutes and texts/i, /shared agent/i, /own number/i, /number prompt/i, /knowledge/i, /agent settings/i]],
  ['23', 'phone-numbers', ['custom_prompt', /import/i, 'PATCH', '8,000', '12,000', 'custom_prompt_too_long', /agent.*knowledge/i]],
  ['25', 'website-agent', ['sms_prompt', 'web_prompt', 'custom_prompt', /agent knowledge/i, /channel rules/i]],
  ['27', 'outbound-actions-variables', [/flag.*off/i, /each row|every row/i, /missing|absent/i, /null/i, /blank/i, /non-system|custom value/i, 'missing_voice_details', 'unsupported_voice_placeholder']],
  ['30', 'bookings-calendars', [/new/i, /voice/i, 'Google Calendar', 'Cal.com', /name/i, /email/i, /read-back/i, /later/i, /yes/i, /write/i, 'require_booking_confirmation=false', /reschedul/i, /cancel/i, /existing/i, /SMS/]],
]
for (const [id, section, terms] of cases) {
  test('DOC2B-' + id + ' keeps the production rule and its scope together', () => checkPassage(section, terms))
}

test('DOC2B examples preserve variable sources and booking event verification order', () => {
  checkPassage('outbound-actions-variables', ['{{pickup_time}}', /case-sensitive/i, 'dynamic_vars', 'CSV', 'recipients[].variables'])
  checkPassage('webhooks', ['call.bookings', /no account field/i, /per-number secret/i, /after signature verification/i, /tenant table/i, /to number inbound/i, /from number outbound/i])
  checkPassage('webhooks', ['HMAC-SHA256', 'timestamp', 'raw request body', 'constant time', 'freshness'])
})
