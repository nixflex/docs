import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
const root=path.resolve(import.meta.dirname,'..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const defs=Object.values(JSON.parse(read('spec-source/c5-campaigns.json')).operations);
test('K3 examples use methods on all 27 pages and preserve the five outreach exceptions',()=>{
 const exclusions=[92,94,99,181,183];
 const reason='MCP does not offer this operation because it can enable outreach; use the API, Node, CLI or Python.';
 for(const d of defs){
  const page=read(d.slug+'.mdx');
  assert.doesNotMatch(page,/direct HTTP/);
  for(const key of ['node','python','cli','curl'])assert.ok(page.includes(d.kitExamples[key]),d.number+' '+key);
  if(exclusions.includes(d.number)){assert.equal(d.kitExamples.mcp,null);assert.ok(page.includes(reason));}
  else {assert.ok(JSON.parse(d.kitExamples.mcp).name);assert.ok(page.includes('```json MCP'));}
  if(d.method==='GET'){assert.equal(d.exampleBody,undefined);assert.doesNotMatch(d.kitExamples.curl,/--data/);assert.doesNotMatch(d.kitExamples.cli,/WriteAllText/);}
  if([53,175,178].includes(d.number))assert.doesNotMatch(d.kitExamples.node,/opaque\+|recipient_cursor|message_cursor|before_id/);
 }
 assert.equal(defs.length,27);
});
test('agent schemas allow grandfathered values while documenting the changed-list limit and exact error',()=>{
 const spec=JSON.parse(read('api-reference/public.openapi.json'));
 for(const [p,m] of [['/agents','post'],['/agents/{id}','put']]){
  const op=spec.paths[p][m],field=op.requestBody.content['application/json'].schema.properties.boosted_keywords;
  assert.equal(field['x-max-nonempty-comma-terms'],20);
  assert.match(field.description,/20 nonempty comma-separated/);
  assert.match(field.description,/repeated terms count separately/);
  assert.equal(op.responses['400'].content['application/json'].example.error.message,'Keep up to 20 words - remove some to save');
  if(m==='post')assert.equal(field.maxLength,2000);
  else {assert.equal(field.maxLength,undefined);assert.match(field.description,/exact unchanged string/);}
 }
 for(const p of ['create','update','contract']){
  const page=read('api-reference/agents/'+p+'.mdx');assert.doesNotMatch(page,/50 (?:nonempty|comma-separated)/);
  assert.match(page,/Keep up to 20 words - remove some to save/);
  assert.doesNotMatch(page,/knowledge_keyterms/);
 }
});
test('C7 PS5.1 guard, consumed errors, bounded read retry and authenticated fixture flow',()=>{
 const r=spawnSync('powershell.exe',['-NoProfile','-ExecutionPolicy','Bypass','-File',path.join(root,'tests/support/c7-safe-harness.ps1')],{cwd:root,encoding:'utf8',timeout:60000});
 assert.equal(r.status,0,r.stdout+'\n'+r.stderr);
 assert.match(r.stdout,/27 unsafe requests blocked/);
 assert.match(r.stdout,/11 mocked reads\/previews and two validation refusals/);
});
