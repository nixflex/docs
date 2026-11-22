import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const read = file => readFileSync(new URL('../' + file, import.meta.url), 'utf8');
const page = slug => read(slug + '.mdx');
const operations = JSON.parse(read('api-reference/public.openapi.json')).paths;
const request = path => operations[path].post.requestBody.content['application/json'].schema;

test('DOC1A-01 outbound call contract distinguishes a usable purpose, custom variables and built-ins', () => {
  assert.equal(request('/calls/outbound').properties.prompt.minLength, 10);
  assert.doesNotMatch(request('/calls/outbound').properties.dynamic_vars.description, /supported placeholder names/i);
  const variables = page('concepts/variables');
  for (const key of ['caller_phone','business_phone','current_date','current_time','tomorrow_date','call_id','agent_id',
    'call_direction','current_iso_date','current_iso_time','tomorrow_iso_date','current_day_of_week','current_timezone',
    'upcoming_days','caller_history','caller_name','business_name']) assert.ok(variables.includes(key), key);
  assert.match(page('api-reference/calls/create-outbound'), /\]\(\/concepts\/variables\)/);
});

test('DOC1A-02 campaign and calendar creation pages link to their published controls', () => {
  for (const slug of ['api-reference/calls/batch-create','guides/developer/campaigns']) {
    assert.match(page(slug), /\]\(\/api-reference\/voice-campaigns\/delete\)/);
    assert.doesNotMatch(page(slug), /no public voice campaign delet/i);
  }
  for (const verb of ['get','put','delete']) {
    assert.match(page('api-reference/integration-settings/' + verb + '-integrations-calcom-number-phoneNumber'),
      /\]\(\/api-reference\/integration-settings\/google-calendar\)/);
  }
  for (const slug of ['api-reference/calls/batch-create','api-reference/sms/campaigns-create']) {
    const examples = page(slug).split('## Example request')[1].split('## Example response')[0];
    for (const block of examples.matchAll(/```[^\n]*\n([\s\S]*?)```/g)) {
      assert.equal(block[1].includes('window_start_minutes'), block[1].includes('window_end_minutes'),
        slug + ' must supply both window bounds or omit both');
    }
  }
  assert.ok(request('/calls/batch').properties.reuse_campaign_id);
  assert.equal(request('/sms/campaigns').properties.reuse_campaign_id, undefined);
});

test('DOC1A-03 number import publishes the private input contract for each carrier', () => {
  const schema = request('/phone-numbers');
  for (const key of ['twilio_sid','twilio_token','telnyx_api_key','telnyx_connection_id','telnyx_public_key']) {
    assert.ok(schema.properties[key], key);
    assert.ok(page('api-reference/phone-numbers/import').includes(key), key);
  }
  assert.equal(schema.properties.twilio_token.writeOnly, true);
  assert.equal(schema.properties.telnyx_api_key.writeOnly, true);
  assert.deepEqual(schema.oneOf.map(branch => branch.required), [['twilio_sid','twilio_token'],['telnyx_api_key','telnyx_connection_id']]);
});
