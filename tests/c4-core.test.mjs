import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
const root=path.resolve(import.meta.dirname,'..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const defs=Object.values(JSON.parse(read('spec-source/c4-core.json')).operations);
const spec=JSON.parse(read('api-reference/public.openapi.json'));
const config=JSON.parse(read('docs.json'));
const sections=['Authentication','Request fields','Response fields','Example request','Example response','Errors','Retry and idempotency','Related endpoints'];
test('C4 has 19 complete nine-part pages with sized metadata, schema bindings and resolved links',()=>{
 assert.equal(defs.length,19);
 const catalog=read('api-reference/errors.mdx');
 const titles=new Set(),descriptions=new Set();
 for(const d of defs){
  const page=read(d.slug+'.mdx');
  assert.deepEqual([...page.matchAll(/^## (.+)$/gm)].map(m=>m[1]),sections,d.slug);
  assert.ok(d.title.length>=50&&d.title.length<=60,d.slug);
  assert.ok(d.description.length>=130&&d.description.length<=160,d.slug);
  assert.ok(!titles.has(d.title)&&!descriptions.has(d.description));titles.add(d.title);descriptions.add(d.description);
  assert.ok(page.includes('/api-reference/public.openapi.json '+d.method+' '+d.specPath));
  assert.ok(spec.paths[d.specPath][d.method.toLowerCase()].responses[d.status]);
  assert.equal((page.match(/\x60\x60\x60(?:bash|javascript|python) /g)||[]).length,4);
  assert.doesNotMatch(page,/twilio|telnyx|openai|anthropic|deepgram|inworld|elevenlabs|supabase|groq/i);
  for(const match of page.matchAll(/\]\((\/[^)]+)\)/g)){
   const [target,anchor]=match[1].split('#');
   assert.ok(fs.existsSync(path.join(root,target+'.mdx')),d.slug+' -> '+target);
   if(target==='/api-reference/errors'&&anchor)assert.ok(catalog.includes('id="'+anchor+'"'),anchor);
  }
 }
});
test('C4 public contracts preserve update, paging, context and number-move boundaries',()=>{
 const update=spec.paths['/agents/{id}'].put.requestBody.content['application/json'].schema;
 assert.deepEqual(update.properties.call_retention_days.enum,[90,30,7,1,0]);
 assert.equal(update.properties.temperature.default,undefined);
 const number=spec.paths['/phone-numbers/{phoneNumber}'].patch.requestBody.content['application/json'].schema;
 assert.equal(number.oneOf.length,2);
 const move=number.oneOf.find(s=>s.properties?.agent_id);
 assert.deepEqual(move.required,['agent_id']);assert.equal(move.additionalProperties,false);
 assert.equal(spec.paths['/calls/history'].get.parameters.find(p=>p.name==='limit').schema.maximum,200);
 assert.equal(spec.paths['/voices'].get.parameters.find(p=>p.name==='limit').schema.maximum,100);
 assert.deepEqual(spec.paths['/keys'].post.security,[]);
 assert.equal(spec.paths['/phone-numbers/{phoneNumber}/callers/import'].post.requestBody.content['application/json'].schema.properties.callers.maxItems,1000);
 assert.equal(spec.paths['/sms'].post.requestBody.content['application/json'].schema.properties.to_number,undefined);
 const baseline=spawnSync('git',['show','1050437:api-reference/public.openapi.json'],{cwd:root,encoding:'utf8',maxBuffer:8*1024*1024});assert.equal(baseline.status,0);
 const previous=JSON.parse(baseline.stdout);for(const d of defs){const old=previous.paths[d.specPath]?.[d.method.toLowerCase()];if(old)assert.equal(spec.paths[d.specPath][d.method.toLowerCase()].operationId,old.operationId,'Existing operation IDs stay stable');}
 assert.match(read('api-reference/phone-numbers/import.mdx'),/neutral fields alone are not a successful import/);
 assert.match(read('api-reference/caller-context/import.mdx'),/not atomic/);
});
test('C4 replaced aggregates redirect and only the API tab navigation changed',()=>{
 for(const [source,destination]of Object.entries({
  '/api-reference/calls/read-views':'/api-reference/calls/get-calls-history',
  '/api-reference/phone-numbers/move':'/api-reference/phone-numbers/update#move-to-another-agent',
  '/api-reference/phone-numbers/switches':'/api-reference/phone-numbers/update#number-controls'
 })){assert.equal(config.redirects.find(r=>r.source===source)?.destination,destination);assert.ok(!fs.existsSync(path.join(root,source+'.mdx')));}
 const base=spawnSync('git',['show','1050437:docs.json'],{cwd:root,encoding:'utf8'});assert.equal(base.status,0);
 const old=JSON.parse(base.stdout).navigation.tabs;
 for(const tab of config.navigation.tabs.filter(t=>t.tab!=='API reference'))assert.deepEqual(tab,old.find(t=>t.tab===tab.tab));
});
test('C4 pending manual tests cannot be mistaken for successful staging writes',()=>{
 const coverage=read('COVERAGE.md');
 for(const id of [1,2,96,165,166,168,169,172,174])assert.match(coverage,new RegExp('\\| '+id+' \\| pending manual test \\|'));
 assert.match(coverage,/NXF_STAGING_KEY.*absent/);
 const missing=read('MISSING-PAGES.md');const remaining=coverage.match(/\| toBuild \| (\d+) \|/)[1];assert.ok(missing.includes(remaining+' public operations'));
 for(const d of defs)assert.ok(!missing.split('\n').some(line=>line.startsWith('| '+d.number+' | `')));
});
test('C4 PowerShell 5.1 guards, missing key and finally cleanup pass with transport replaced',()=>{
 const result=spawnSync('powershell.exe',['-NoProfile','-ExecutionPolicy','Bypass','-File',path.join(root,'tests/support/c4-safe-harness.ps1')],{cwd:root,encoding:'utf8',timeout:60000});
 assert.equal(result.status,0,result.stdout+'\n'+result.stderr);
 assert.match(result.stdout,/15 unsafe requests blocked/);
 assert.match(result.stdout,/normal.*PASS=30 FAIL=0 PENDING=10/);
 assert.match(result.stdout,/failed-update.*cleanup verified/);
 assert.match(result.stdout,/lost-create.*cleanup verified/);
});
