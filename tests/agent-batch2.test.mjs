import {test} from 'node:test';
import a from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const read=name=>JSON.parse(readFileSync(new URL('../api-reference/'+name,import.meta.url)));
test('Batch2 OpenAPI list links strict bounds and additive status/search without changing bare array',()=>{
 const root=read('openapi.json'),params=read('schemas/agent-list-parameters.json'),get=root.paths['/agents'].get;
 a.deepEqual(get.parameters.map(p=>p.$ref),['limit','offset','status','search'].map(p=>'./schemas/agent-list-parameters.json#/'+p));
 a.equal(params.limit.schema.minimum,1);a.equal(params.limit.schema.maximum,200);
 a.equal(params.offset.schema.maximum,1000000);a.equal(params.offset.schema.default,0);
 a.deepEqual(params.status.schema.enum,['active','disabled','all']);a.equal(params.status.schema.default,'active');
 a.equal(params.search.schema.maxLength,200);a.equal(get.responses[200].content['application/json'].schema.type,'array');
 a.match(get.description,/agent_id DESC/);
});
test('Batch2 defaults are create-only, explicit values win, pickup and soft disable remain honest',()=>{
 const input=read('schemas/agent-request.json'),page=readFileSync(new URL('../api-reference/agents/create.mdx',import.meta.url),'utf8');
 for(const text of ['dynamic_greeting true','max_call_duration_seconds 300','silence_hangup_seconds 10','Update is partial, never applies create defaults'])a.ok(input.description.includes(text));
 a.match(page,/300 \/ 10/);a.match(page,/No existing agent is migrated/);a.match(page,/pickup handling remain unchanged/);
 a.equal(read('schemas/agent-update.json').allOf[0].$ref,'./agent-request.json');
});
