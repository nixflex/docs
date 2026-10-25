import {test} from 'node:test';
import a from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const read=name=>JSON.parse(readFileSync(new URL('../api-reference/'+name,import.meta.url)));
test('Batch1 draft links shared agent schemas, all newly writable settings, safe reads and update-only retention',()=>{
 const root=read('openapi.json'),input=read('schemas/agent-request.json'),output=read('schemas/agent-response.json'),update=read('schemas/agent-update.json');
 a.equal(root.components.schemas.Agent.$ref,'./schemas/agent-response.json');
 a.equal(root.paths['/agents/{id}'].put.requestBody.content['application/json'].schema.$ref,'#/components/schemas/AgentUpdate');
 for(const field of ['voice_key','response_eagerness','stt_confidence','stt_max_silence_ms','timezone','incall_sms_enabled','post_call_sms_enabled','post_call_sms_template','data_extraction_fields','voicemail_leave_enabled','voicemail_message','remember_callers','wait_tag_seconds','ivr_timeout_seconds']){a.ok(input.properties[field],field);a.ok(output.properties[field],field);}
 a.equal(input.properties.temperature.minimum,0);a.equal(input.properties.temperature.maximum,0.7);
 a.equal(input.properties.call_retention_days,undefined);a.deepEqual(update.allOf[1].properties.call_retention_days.enum,[90,30,7,1,0]);
 a.equal(output.properties.twilio_auth_token,undefined);a.equal(output.additionalProperties,false);a.ok(output.properties.warnings);
});
test('Batch1 draft states soft disable, warnings, honest 404/503 and unchanged pickup',()=>{
 const page=name=>readFileSync(new URL('../api-reference/agents/'+name+'.mdx',import.meta.url),'utf8');
 a.match(page('delete'),/is_active=false/);a.match(page('delete'),/does not detach/);a.match(page('delete'),/Agent deleted/);
 a.match(page('get'),/404 not_found/);a.match(page('get'),/503 agent_store_unavailable/);
 a.match(page('update'),/unknown_fields/);a.match(page('contract'),/Pickup delay is the deliberate legacy exception/);
});
