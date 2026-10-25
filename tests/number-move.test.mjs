import {test} from 'node:test';
import a from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const read=p=>readFileSync(new URL('../'+p,import.meta.url),'utf8');
test('D7 draft covers agent-only update, scoped error semantics, all kits and dashboard owner handoff',()=>{
 const d=read('api-reference/phone-numbers/move.mdx'),m=JSON.parse(read('api-reference/phone-number-move.json'));
 a.equal(m.Request.additionalProperties,false);a.deepEqual(m.Request.required,['agent_id']);
 a.deepEqual(m.UpdateRequest.oneOf[1].allOf[1],{not:{required:['agent_id']}});
 for(const s of ['local/unpublished','number_busy','number_move_unconfirmed','phoneNumbers.move','phone_numbers.move','numbers move','numbers update','update_phone_number','Owner-session-only','website instructions','Never delete and'])a.ok(d.includes(s),s);
 const root=JSON.parse(read('api-reference/openapi.json')),patch=root.paths['/phone-numbers/{phoneNumber}'].patch;
 a.equal(patch.requestBody.content['application/json'].schema.$ref,'phone-number-move.json#/UpdateRequest');
 a.ok(patch.responses['409']);a.ok(patch.responses['503']);
 a.doesNotMatch(read('concepts/phone-numbers.mdx'),/To move a number.*delete the existing record/);
});
