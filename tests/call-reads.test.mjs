import {test} from 'node:test';
import a from 'node:assert/strict';
import {readLegacyFileSync as readFileSync} from './support/read-legacy-spec.mjs';
const read=p=>readFileSync(new URL('../'+p,import.meta.url),'utf8');
test('call read drafts name bounded filters, nullable proof, retention and short links with billing excluded from public documentation',()=>{
 const page=['get-calls-history','get','get-calls-id-recording'].map(p=>read('api-reference/calls/'+p+'.mdx')).join('\n');
 for(const term of ['next_cursor','cost_unknown','failed:','customer_bucket','not_recorded','unknown','pending_deletion','300 seconds','not a frozen']){
  a.ok(page.includes(term),term);
 }
 a.doesNotMatch(page,/## Billing|calls\.billing|recorded_cost/);a.match(page,/does not prove recording/);
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
