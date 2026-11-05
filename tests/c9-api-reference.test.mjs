import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync,spawnSync} from 'node:child_process';
const root=path.resolve(import.meta.dirname,'..'),read=p=>fs.readFileSync(path.join(root,p),'utf8'),json=p=>JSON.parse(read(p));
const spec=json('api-reference/public.openapi.json'),plan=json('spec-source/c9-pages.json');
test('C9 preserves 160 reachable pages, bounded unique metadata, five tabs and old URLs',()=>{
 const out=JSON.parse(execFileSync(process.execPath,['scripts/check-c9-seo.mjs'],{cwd:root,encoding:'utf8'}));
 assert.equal(out.failures.length,0);assert.equal(out.counts.navigation,160);assert.equal(out.counts.endpointPages,147);
 assert.equal(out.status,'SOURCE_PASS_GENERATED_PENDING'); // Source evidence must not masquerade as generated-site proof.
 const strict=spawnSync(process.execPath,['scripts/check-c9-seo.mjs','--require-generated'],{cwd:root,encoding:'utf8'});
 assert.equal(strict.status,1,'A release gate must fail when generated artifacts are unavailable');
});
test('C9 voice schemas admit normalized null accents while preserving required fields',()=>{
 for(const p of ['/voices','/voices/{voice_key}']){
  let s=spec.paths[p].get.responses['200'].content['application/json'].schema;if(p==='/voices')s=s.properties.data.items;
  const accent=s.properties.accents.items;
  for(const name of ['language','locale','label'])assert.deepEqual(accent.properties[name].type,['string','null']);
  assert.ok(s.required.includes('voice_key'));assert.ok(s.required.includes('accents'));
 }
});
test('C9 documents precise disabled-agent, caller, booking and contact policy outcomes',()=>{
 const disabled=spec.paths['/agents/{id}'].delete.responses['200'].content['application/json'];assert.equal(disabled.schema.properties.message.const,'Agent deleted');
 assert.match(read('api-reference/agents/delete.mdx'),/is_active=false/);assert.match(read('api-reference/agents/get.mdx'),/is_active.*false/);
 const caller=spec.paths['/phone-numbers/{phoneNumber}/callers/{callerNumber}'].get;
 assert.equal(caller.responses['404'].content['application/json'].examples.caller_not_found.value.error.code,'caller_not_found');
 const cal=json('spec-source/c6-team-integrations.json').operations['12'];assert.ok(cal.errors.some(e=>e[0]===409&&e[1]==='booking_provider_conflict'));
 for(const slug of ['api-reference/calls/create-outbound','api-reference/sms/send']){
  const page=read(slug+'.mdx');for(const code of ['outside_hours','needs_timezone','contact_policy_unavailable','single_contact_policy','refused_before_dispatch'])assert.ok(page.includes(code));
  assert.match(page,/internal policy-check name, not an HTTP error code/);
 }
 const keyterms=spec.paths['/agents/{target}/knowledge-keyterms'].get.responses['200'].content['application/json'].schema;
 assert.equal(keyterms.required.length,6);assert.equal(keyterms.properties.manual_keyterms_limit.const,20);
});
test('C10 replaces the Google Calendar slot with supported public routes',()=>{
 assert.ok(plan.pages.some(p=>p.slug==='api-reference/integration-settings/google-calendar'));
 assert.ok(spec.paths['/integrations/google-calendar/number/{phoneNumber}/connect'].post);assert.ok(spec.paths['/integrations/google-calendar/number/{phoneNumber}'].get);
 assert.match(read('api-reference/introduction.mdx'),/production base URL is.*https:\/\/api.nixflex.com/);
 assert.match(read('api-reference/introduction.mdx'),/94 registered tools/);
});
