import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
const root=path.resolve(import.meta.dirname,'..'),read=p=>fs.readFileSync(path.join(root,p),'utf8');
const defs=Object.values(JSON.parse(read('spec-source/c6-team-integrations.json')).operations),spec=JSON.parse(read('api-reference/public.openapi.json'));
test('C6 has 45 complete, linked and white-label operation pages with matching schemas',()=>{
 assert.equal(defs.length,45);const catalog=read('api-reference/errors.mdx');
 for(const d of defs){const page=read(d.slug+'.mdx');
 assert.deepEqual([...page.matchAll(/^## (.+)$/gm)].map(m=>m[1]),['Authentication','Request fields','Response fields','Example request','Example response','Errors','Retry and idempotency','Related endpoints']);
 assert.ok(page.includes('/api-reference/public.openapi.json '+d.method+' '+d.specPath));
 assert.equal((page.match(/\x60\x60\x60(?:bash|javascript|python|powershell) /g)||[]).length,d.sensitive?0:4);
 assert.doesNotMatch(page,/twilio|telnyx|openai|anthropic|deepgram|inworld|elevenlabs|supabase|groq/i);
 for(const m of page.matchAll(/\]\((\/[^)]+)\)/g)){const [target,anchor]=m[1].split('#');assert.ok(fs.existsSync(path.join(root,target+'.mdx')),target);if(target==='/api-reference/errors')assert.ok(catalog.includes('id="'+anchor+'"'),anchor);}
 assert.ok(spec.paths[d.specPath][d.method.toLowerCase()].responses['401']);
 }
});
test('C6 preserves the real organisation authority, activity and uncertain membership contract',()=>{
 const get=p=>spec.paths[p].get.responses['200'].content['application/json'].schema;
 assert.equal(get('/organisation').properties.user_id.type.includes('null'),true);
 assert.equal(get('/organisation/activity').properties.events.items.properties.id.type,'string');
 assert.ok(get('/organisation/activity').properties.events.items.properties.sentence);
 assert.equal(get('/organisation/activity').properties.events.items.properties.action,undefined);
 assert.ok(spec.paths['/organisation/activity'].get.responses['200'].content['text/csv']);
 assert.deepEqual(spec.paths['/organisation/activity'].get.parameters.map(p=>p.name),['before','actor','from','to','format']);
 for(const method of ['patch','delete'])assert.ok(spec.paths['/organisation/members/{id}'][method].responses['202']);
 assert.match(read('api-reference/organisation/roles.mdx'),/Admin.*Member invitations only/);
 assert.match(read('api-reference/organisation/get-organisation-activity.mdx'),/500 is not a total export limit/);
 assert.match(read('api-reference/organisation/post-organisation-claim-invite.mdx'),/accepts the existing API key only/);
 assert.equal(spec.paths['/organisation/accept'],undefined);assert.equal(spec.paths['/organisation/transfer'],undefined);
 assert.match(read('api-reference/organisation/get-organisation-signing-secret.mdx'),/Dashboard only/);
 assert.doesNotMatch(read('api-reference/organisation/get-organisation-signing-secret.mdx'),/<RequestExample>|```(?:bash|javascript|python|powershell)/);
});
test('C6 integration schemas preserve secret flags, defaults, replacement and partial-update rules',()=>{
 const cal=spec.paths['/integrations/calcom/number/{phoneNumber}'];
 assert.ok(cal.put.responses['409']);assert.equal(cal.get.responses['200'].content['application/json'].schema.properties.api_key,undefined);
 assert.equal(cal.get.responses['200'].content['application/json'].schema.properties.api_key_set.type,'boolean');
 const make=spec.paths['/integrations/make/number/{phoneNumber}'].put.requestBody.content['application/json'].schema;
 assert.deepEqual(make.anyOf,[{required:['post_call_url']},{required:['in_call_url']}]);
 const cf=spec.paths['/integrations/custom-functions/number/{phoneNumber}/{id}'].patch.requestBody.content['application/json'].schema;
 assert.equal(cf.properties.timeout_ms.default,undefined);assert.equal(cf.minProperties,1);
 assert.match(read('api-reference/integration-settings/delete-integrations-slack-number-phoneNumber.mdx'),/missing configuration also returns success/);
 assert.match(read('api-reference/integration-settings/delete-integrations-precall-number-phoneNumber.mdx'),/restores the agent default/);
});
test('C6 covers only the approved groups and keeps all successful writes pending',()=>{
 const missing=read('MISSING-PAGES.md'),coverage=read('COVERAGE.md');assert.match(missing,/No missing public operation pages/);
 const rows=missing.split('\n').filter(l=>/^\| \d+ \|/.test(l));assert.equal(rows.length,20);assert.ok(rows.every(l=>l.includes('knowledge')));
 for(const d of defs){assert.ok(!rows.some(l=>l.startsWith('| '+d.number+' |')));if(d.method!=='GET'||d.sensitive)assert.ok(coverage.includes('| '+d.number+' | pending manual test |'));}
 const previous=spawnSync('git',['show','ad36141:docs.json'],{cwd:root,encoding:'utf8'});assert.equal(previous.status,0);
 const config=JSON.parse(read('docs.json')),old=JSON.parse(previous.stdout);for(const tab of config.navigation.tabs.filter(t=>t.tab!=='API reference'))assert.deepEqual(tab,old.navigation.tabs.find(t=>t.tab===tab.tab));
});
test('all 19 C4 pages use K2 methods with explicit unpublished candidate limits',()=>{
 const core=Object.values(JSON.parse(read('spec-source/c4-core.json')).operations);assert.equal(core.length,19);
 for(const d of core){const p=read(d.slug+'.mdx');assert.doesNotMatch(p,/direct HTTP/);assert.match(p,/unpublished/);assert.ok(d.kitExamples.node&&d.kitExamples.python&&d.kitExamples.cli);}
 assert.match(read('api-reference/account/create-key.mdx'),/signup is intentionally absent from MCP/);
 assert.match(read('api-reference/caller-context/import.mdx'),/--body @callers.json/);
 assert.match(coverageText(),/44 tools/);
 function coverageText(){return read('COVERAGE.md');}
});
test('C6 PS5.1 transport, request guards and row 55 boolean regression pass offline',()=>{
 const r=spawnSync('powershell.exe',['-NoProfile','-ExecutionPolicy','Bypass','-File',path.join(root,'tests/support/c6-safe-harness.ps1')],{cwd:root,encoding:'utf8',timeout:60000});
 assert.equal(r.status,0,r.stdout+'\n'+r.stderr);assert.match(r.stdout,/42 unsafe requests blocked/);assert.match(r.stdout,/15 read examples, 61 total checks, 31 manual checks/);
});
