import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
const root=path.resolve(import.meta.dirname,'..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const defs=Object.values(JSON.parse(read('spec-source/c5-campaigns.json')).operations);
const spec=JSON.parse(read('api-reference/public.openapi.json'));
const config=JSON.parse(read('docs.json'));
test('C5 has all 27 approved pages, complete sections, matching bindings and valid error links',()=>{
 assert.equal(defs.length,27);const catalog=read('api-reference/errors.mdx');
 for(const d of defs){const page=read(d.slug+'.mdx');
  assert.deepEqual([...page.matchAll(/^## (.+)$/gm)].map(m=>m[1]),['Authentication','Request fields','Response fields','Example request','Example response','Errors','Retry and idempotency','Related endpoints']);
  assert.ok(page.includes('/api-reference/public.openapi.json '+d.method+' '+d.specPath));
  assert.ok(spec.paths[d.specPath][d.method.toLowerCase()].responses[d.status]);
  assert.equal((page.match(/\x60\x60\x60(?:bash|javascript|python) /g)||[]).length,4);
  assert.doesNotMatch(page,/twilio|telnyx|openai|anthropic|deepgram|inworld|elevenlabs|supabase|groq/i);
  for(const match of page.matchAll(/\]\((\/[^)]+)\)/g)){const [target,anchor]=match[1].split('#');assert.ok(fs.existsSync(path.join(root,target+'.mdx')),target);if(target==='/api-reference/errors'&&anchor)assert.ok(catalog.includes('id="'+anchor+'"'),anchor);}
 }
});
test('campaign contracts separate creation, launch, reply settings, paging and uncertain outcomes',()=>{
 const voice=spec.paths['/calls/batch'].post, sms=spec.paths['/sms/campaigns'].post;
 for(const op of [voice,sms]){const body=op.requestBody.content['application/json'].schema;
  assert.equal(body.properties.schedule_type.default,'now');assert.equal(body.properties.draft,undefined);
  assert.equal(body.properties.consent_confirmed.default,false);
  assert.equal(body.properties.duplicate_policy.default,'warn');
  assert.match(body.properties.duplicate_policy.description,/advisory/);
  assert.ok(body.properties.recipients.items.properties.timezone);assert.ok(op.responses['500']);
 }
 assert.equal(sms.requestBody.content['application/json'].schema.properties.message,undefined);
 assert.ok(sms.requestBody.content['application/json'].schema.properties.message_template);
 assert.equal(sms.requestBody.content['application/json'].schema.properties.reuse_campaign_id,undefined);
 assert.ok(voice.requestBody.content['application/json'].schema.properties.reuse_campaign_id);
 const detail=spec.paths['/sms/campaigns/{id}'].get;
 assert.equal(detail.parameters.find(p=>p.name==='limit').schema.maximum,500);
 assert.ok(detail.parameters.find(p=>p.name==='recipient_cursor'));assert.ok(detail.parameters.find(p=>p.name==='message_cursor'));
 const update=spec.paths['/sms/campaigns/{id}'].patch;
 assert.deepEqual(Object.keys(update.requestBody.content['application/json'].schema.properties),['is_active','reply_context_prompt','reply_window_hours']);
 assert.ok(update.responses['200'].content['application/json'].schema.properties.campaign_id);
 assert.equal(update.responses['200'].content['application/json'].schema.properties.campaign,undefined);
 assert.match(read('api-reference/calls/batch-create.mdx'),/warn.*still allows/);
 assert.match(read('api-reference/sms/campaigns-list.mdx'),/malformed before cursor currently returns 500/);
});
test('web updates require revision, expose current B18 fields and preserve read acknowledgements',()=>{
 const update=spec.paths['/agent-web/{number}'].patch.requestBody.content['application/json'].schema;
 assert.deepEqual(update.required,['revision','settings']);
 const settings=update.properties.settings.properties;
 assert.equal(settings.web_prompt.maxLength,16000);assert.equal(settings.web_design.maximum,10);
 assert.equal(settings.web_appearance.properties.contactFields.maxItems,9);
 assert.equal(settings.web_appearance.properties.beforeCall.properties.fields.maxItems,9);
 assert.equal(settings.web_agent_enabled,undefined);
 const thread=spec.paths['/agent-inbox/{channel}/{number}/thread/{thread}'];
 assert.equal(thread.patch.requestBody.content['application/json'].schema.properties.read_version.type,'string');
 assert.equal(thread.get.responses['200'].content['application/json'].schema.properties.read_version.type,'string');
 assert.equal(spec.paths['/contact-hours/preview'].post.requestBody.content['application/json'].schema.properties.recipients.maxItems,20);
 assert.match(read('api-reference/contact-controls/get-contact-suppressions.mdx'),/does not combine/);
});
test('C5 preserves old operation IDs, all other tabs and the current remaining-operation ledger',()=>{
 const previous=spawnSync('git',['show','efcf970:api-reference/public.openapi.json'],{cwd:root,encoding:'utf8',maxBuffer:8*1024*1024});assert.equal(previous.status,0);
 const oldSpec=JSON.parse(previous.stdout);for(const d of defs){const old=oldSpec.paths[d.specPath]?.[d.method.toLowerCase()];if(old)assert.equal(spec.paths[d.specPath][d.method.toLowerCase()].operationId,old.operationId);}
 const previousConfig=spawnSync('git',['show','efcf970:docs.json'],{cwd:root,encoding:'utf8'});assert.equal(previousConfig.status,0);
 const oldConfig=JSON.parse(previousConfig.stdout);for(const tab of config.navigation.tabs.filter(t=>t.tab!=='API reference'))assert.deepEqual(tab,oldConfig.navigation.tabs.find(t=>t.tab===tab.tab));
 const missing=read('MISSING-PAGES.md');assert.ok(missing.includes(read('COVERAGE.md').match(/\| toBuild \| (\d+) \|/)[1]+' public operations'));
 for(const d of defs)assert.ok(!missing.split('\n').some(line=>line.startsWith('| '+d.number+' | ')));
 const coverage=read('COVERAGE.md');for(const n of [54,59,90,91,92,93,94,99,101,176,177,179,180,181,182,183])assert.ok(coverage.includes('| '+n+' | pending manual test |'));
});
test('PowerShell 5.1 reads consumed errors and refuses all authenticated mutation paths',()=>{
 const r=spawnSync('powershell.exe',['-NoProfile','-ExecutionPolicy','Bypass','-File',path.join(root,'tests/support/c5-safe-harness.ps1')],{cwd:root,encoding:'utf8',timeout:60000});
 assert.equal(r.status,0,r.stdout+'\n'+r.stderr);assert.match(r.stdout,/27 consumed-stream ErrorDetails refusals/);assert.match(r.stdout,/23 unsafe mutations blocked/);assert.match(r.stdout,/stream fallback preserved/);
});
