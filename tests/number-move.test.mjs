import {test} from 'node:test';
import a from 'node:assert/strict';
import {readLegacyFileSync as readFileSync} from './support/read-legacy-spec.mjs';
const read=p=>readFileSync(new URL('../'+p,import.meta.url),'utf8');
test('Number update covers the separate move body, scoped refusals and preserved settings',()=>{
 const d=read('api-reference/phone-numbers/update.mdx'),m=JSON.parse(read('api-reference/phone-number-move.json'));
 a.equal(m.Request.additionalProperties,false);a.deepEqual(m.Request.required,['agent_id']);
 a.deepEqual(m.UpdateRequest.oneOf[1].allOf[1],{not:{required:['agent_id']}});
 for(const s of ['number_busy','number_move_unconfirmed','number_move_disabled','numbers update','agent_id','Do not combine','Move to another agent','Never delete and'])a.ok(d.includes(s),s);
 const root=JSON.parse(read('api-reference/openapi.json')),patch=root.paths['/phone-numbers/{phoneNumber}'].patch;
 a.equal(patch.requestBody.content['application/json'].schema.$ref,'phone-number-move.json#/UpdateRequest');
 a.ok(patch.responses['409']);a.ok(patch.responses['503']);
 a.doesNotMatch(read('concepts/phone-numbers.mdx'),/To move a number.*delete the existing record/);
});
