import { test } from 'node:test';
import a from 'node:assert/strict';
import {readLegacyFileSync as readFileSync} from './support/read-legacy-spec.mjs';
const read = name => readFileSync(new URL('../' + name, import.meta.url), 'utf8');

test('Batch3 navigation and channel matrix distinguish public website from owner tests', () => {
  const nav = read('docs.json'), matrix = read('concepts/agent-channels.mdx');
  JSON.parse(nav);
  for (const page of ['agent-channels', 'agent-inheritance']) a.ok(nav.includes('concepts/' + page));
  for (const text of ['Inbound phone', 'Outbound phone', 'Website chat', 'Website voice',
    'separate authenticated browser-call path', 'Per-call `prompt`', "Number's `web_prompt`",
    '300 seconds', '10 seconds', 'switch off']) a.ok(matrix.includes(text), text);
  a.match(matrix, /phone welcome cleared/); a.match(matrix, /catalog mode prioritizes agent/);
  a.match(read('concepts/voices.mdx'), /non-null agent catalog key takes priority/);
});

test('Batch3 inert fields stay inert in prose and schema descriptions', () => {
  const matrix = read('concepts/agent-channels.mdx');
  const schema = JSON.parse(read('api-reference/schemas/agent-request.json'));
  for (const field of ['llm_model', 'fallback_message', 'interruption_sensitivity', 'voice_speed', 'func_send_sms', 'func_cold_transfer']) {
    a.ok(matrix.includes(field)); a.match(schema.properties[field].description, /[Cc]ompatibility/);
  }
  a.match(schema.properties.func_end_call.description, /not a blanket prohibition/);
  a.doesNotMatch(read('concepts/agents.mdx'), /Fine-tunes how easily|it was still saved|calls in progress finish first/);
});

test('Batch3 privacy rules separate remembering, greeting, recording and number provenance', () => {
  const page = read('concepts/agent-inheritance.mdx');
  for (const text of ['Off | On', 'agent OFF + number ON records', 'API-imported number',
    'no fallback to agent', 'per-call template, then the agent template',
    'does not erase saved caller records', 'Carrier AMD', '90 / 30 / 7 / 1 / 0']) a.ok(page.includes(text), text);
  a.match(page, /Changing the account default is not a bulk edit/);
  a.match(page, /Customer-owned storage\s+is excluded/);
});

test('Batch3 website functions are per-number and do not grant built-in phone actions', () => {
  const page = read('concepts/agent-inheritance.mdx'), web = read('concepts/web-calls.mdx');
  a.match(page, /`web_functions_enabled` defaults OFF/);
  a.match(page, /not an agent-wide or per-function website approval/);
  a.match(page, /does not enable built-in website booking, availability,/);
  a.match(web, /does not enable built-in calendar booking, SMS, transfers, keypad or telephone-menu navigation/);
  a.doesNotMatch(web, /Everything is inherited|Same agent, same prompt|have it collect a mobile number first/);
});

test('Batch3 language page gives route-specific coverage, not a universal ten-language promise', () => {
  const page = read('concepts/languages.mdx');
  a.match(page, /depend on the selected route/); a.match(page, /cannot add support/);
  a.match(page, /20 entries/); a.match(page, /450-byte/);
  a.match(page, /SMS and website chat do not use speech recognition/);
  a.doesNotMatch(page, /Automatic switching between these ten|All 15 work end to end/);
});

test('Batch3 recording and retention avoid universal deletion/compliance promises', () => {
  const recording = read('advanced/call-recording.mdx'), retention = read('concepts/data-retention.mdx');
  a.match(recording, /Agent off plus number on still enables/);
  a.match(recording, /Customer-bucket files need the customer/); a.match(retention, /processing_enabled/);
  a.match(retention, /not the\s+customer's own bucket/);
  a.doesNotMatch(retention, /GDPR compliant by default|every day at \*\*3 AM|Call deletion is immediate/);
  a.match(read('actions/end-call.mdx'), /Carrier AMD can end the call/);
});
