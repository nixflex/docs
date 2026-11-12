import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
const root=path.resolve(import.meta.dirname,'..'),read=p=>fs.readFileSync(path.join(root,p),'utf8');
const defs=Object.values(JSON.parse(read('spec-source/c8-knowledge.json')).operations),spec=JSON.parse(read('api-reference/public.openapi.json'));
test('all historical public operations plus the requested keyterm read have stable, linked pages',()=>{
 const allow=JSON.parse(read('spec-source/public-operations.json'));assert.equal(allow.filter(r=>r.number<=191&&r.public).length,141);assert.equal(allow.filter(r=>r.public).length,151);assert.equal(defs.length,40);
 const nav=JSON.parse(read('docs.json')).navigation.tabs.find(t=>t.tab==='API reference').groups.find(g=>g.group==='Knowledge');assert.equal(nav.pages.length,40);
 const before=spawnSync('git',['show','2da2612:api-reference/public.openapi.json'],{cwd:root,encoding:'utf8',maxBuffer:20*1024*1024});assert.equal(before.status,0);for(const [p,item]of Object.entries(JSON.parse(before.stdout).paths))for(const [m,op]of Object.entries(item))assert.equal(spec.paths[p][m].operationId,op.operationId);
 const errors=read('api-reference/errors.mdx');for(const d of defs){const page=read(d.slug+'.mdx');assert.ok(nav.pages.includes(d.slug));assert.equal((page.match(/^## /gm)||[]).length,8);assert.ok(spec.paths[d.specPath][d.method.toLowerCase()]);for(const e of d.errors)assert.ok(errors.includes('id="'+e[1]+'"'),e[1]);assert.doesNotMatch(page,/twilio|telnyx|openai|anthropic|deepgram|inworld|elevenlabs|supabase|groq/i);}
});
test('K4 examples cover 44 operations and keep signing-secret retrieval dashboard-only',()=>{
 const ds=Object.values(JSON.parse(read('spec-source/c6-team-integrations.json')).operations);let mcp=0,excluded=0;
 for(const d of ds){const page=read(d.slug+'.mdx');if(d.number===158){assert.doesNotMatch(page,/<RequestExample>|```(?:bash|javascript|python|powershell)/);continue;}for(const k of ['node','python','cli'])assert.ok(d.kitExamples[k]);assert.doesNotMatch(page,/direct HTTP/);if(d.kitExamples.mcp){assert.ok(JSON.parse(d.kitExamples.mcp).name);mcp++;}else{assert.match(d.kitExamples.mcpException,/MCP does not offer this operation because/);excluded++;}}
 assert.equal(mcp,26);assert.equal(excluded,18);
});
test('B49f keyterm schemas document conditional limits without rejecting grandfathered updates',()=>{
 for(const [p,m]of [['/agents','post'],['/agents/{id}','put']]){const op=spec.paths[p][m],s=op.requestBody.content['application/json'].schema.properties.boosted_keywords;assert.equal(s['x-max-nonempty-comma-terms'],20);assert.equal(s['x-max-trimmed-term-codepoints'],50);assert.equal(s['x-max-conservative-keyterm-bytes'],450);assert.equal(op.responses['400'].content['application/json'].examples.term_length.value.error.details.limit,50);assert.equal(op.responses['400'].content['application/json'].examples.list_bytes.value.error.details.actual_bytes,453);if(m==='put')assert.equal(s.maxLength,undefined);}
 assert.ok(spec.paths['/agents/{target}/knowledge-keyterms'].get.responses['200'].content['application/json'].schema.properties.knowledge_keyterms);
});
test('C8 consolidated PS5.1 runner refuses writes, protects fixtures and checks all read shapes',()=>{
 const r=spawnSync('powershell.exe',['-NoProfile','-ExecutionPolicy','Bypass','-File',path.join(root,'tests/support/c8-safe-harness.ps1')],{cwd:root,encoding:'utf8',timeout:60000});assert.equal(r.status,0,r.stdout+'\n'+r.stderr);assert.match(r.stdout,/15 unsafe requests blocked/);assert.match(r.stdout,/55 public read shapes \+ 4 GET tombstones; 92 manual exclusions/);
});

test("K5 knowledge examples use verified methods and 19 registered MCP tools",()=>{
 let registered=0,excluded=0;
 for(const d of defs){const p=read(d.slug+".mdx");assert.ok(d.kitExamples.node.includes("c.knowledge."+d.kitMethod.node));assert.ok(d.kitExamples.python.includes("c.knowledge."+d.kitMethod.python));assert.doesNotMatch(p,/direct HTTP/);
  if(d.kitExamples.mcp){assert.ok(JSON.parse(d.kitExamples.mcp).name);assert.match(p,/```json MCP/);registered++;}
  else {assert.match(p,/MCP does not offer this operation/);assert.doesNotMatch(p,/```json MCP/);excluded++;}
 }
 assert.equal(registered,19);assert.equal(excluded,21);assert.equal(defs.filter(d=>d.kitExamples.mcpPending).length,0);
});
