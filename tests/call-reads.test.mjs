import {test} from 'node:test';
import a from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const read=p=>readFileSync(new URL('../'+p,import.meta.url),'utf8');
test('call read drafts name bounded filters, nullable proof, retention and short links without billing changes',()=>{
 const page=read('api-reference/calls/read-views.mdx');
 for(const term of ['next_cursor','cost_unknown','failed:','customer_bucket','not_recorded','unknown','pending_deletion','300 seconds','conservative','not a frozen','recorded_cost']){
  a.ok(page.includes(term),term);
 }
 a.match(page,/no new rate, credit, refund or charge/);a.match(page,/not a claim/);
 a.ok(read('docs.json').includes('api-reference/calls/read-views'));
});
test('call read OpenAPI external paths and nullable schema resolve; legacy array contract stays',()=>{
 const root=JSON.parse(read('api-reference/openapi.json')),part=JSON.parse(read('api-reference/call-reads.openapi.json'));
 for(const path of ['/calls/history','/calls/{id}/recording','/calls/{id}/billing']){
  a.ok(root.paths[path].$ref);a.ok(part.paths[path].get);a.ok(part.paths[path].get.responses['503']);
 }
 a.equal(root.paths['/calls'].get.responses['200'].content['application/json'].schema.type,'array');
 a.deepEqual(part.components.schemas.Billing.properties.ai_billed_ms.type,['integer','null']);
 a.ok(root.paths['/calls/{id}'].get.parameters.some(p=>p.name==='view'));
});
