import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import {bookingExamples} from '../scripts/c12-webhook-contracts.mjs';
const root=path.resolve(import.meta.dirname,'..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const spec=JSON.parse(read('api-reference/public.openapi.json'));
const page=read('api-reference/call-bookings.mdx');
const helper=vm.runInNewContext(page.match(/```javascript\s*\n([\s\S]*?)```/)[1]+'\nbookingResult;');

test('C12 exposes booking events separately from callable operations and keeps the page example in sync',()=>{
 assert.equal(Object.values(spec.paths).flatMap(Object.keys).filter(x=>['get','post','put','patch','delete'].includes(x)).length,149);
 assert.ok(!Object.keys(spec.paths).some(x=>x.includes('call.bookings')));
 const event=spec.webhooks['call.bookings'].post;
 assert.deepEqual(event.security,[]);
 assert.equal(event.parameters.find(x=>x.name==='X-Nixflex-Signature').required,true);
 assert.deepEqual(event.requestBody.content['application/json'].examples,bookingExamples);
 assert.deepEqual(JSON.parse(page.match(/```json\s*\n([\s\S]*?)```/)[1]),bookingExamples.create_move.value);
 assert.match(page,/\[receiver guide and verifier\]\(\/advanced\/webhooks#3-verify-exact-request-bytes\)/);
 assert.match(page,/\[Build a signed event receiver\]\(\/advanced\/webhooks\)/);
});

test('C12 receiver counts final active results instead of the number of actions',()=>{
 for(const [name,count] of Object.entries({create_move:1,create_cancel:0,create_move_cancel:0,move_existing:1,two_bookings:2,replacement_uid:1,unknown_fields:1})){
  assert.equal(helper(bookingExamples[name].value,'account_fixture').activeBookings,count,name);
 }
});

test('C12 receiver separates accounts and calls and refuses missing dedupe identity',()=>{
 const value=bookingExamples.create_move.value;
 const original=helper(value,'account_fixture').dedupeKey;
 assert.deepEqual(JSON.parse(original),['account_fixture','call.bookings','call_example']);
 assert.notEqual(helper(value,'account_other').dedupeKey,original);
 assert.notEqual(helper({...value,call_id:'call_other'},'account_fixture').dedupeKey,original);
 for(const changes of [{call_id:null},{call_id:''},{event:'call.completed'}]){
  assert.throws(()=>helper({...value,...changes},'account_fixture'));
 }
 assert.throws(()=>helper(value,''));
 assert.throws(()=>helper(value,null));
});

test('C12 SMS deletion preserves its success receipt and distinguishes settlement from an unknown result',()=>{
 const responses=spec.paths['/sms/campaigns/{id}'].delete.responses;
 assert.equal(responses['200'].content['application/json'].example.message,'Campaign deleted');
 assert.ok(!responses['400']);assert.ok(!responses['500']);
 const errors=responses['409'].content['application/json'].examples;
 assert.equal(errors.settlement.value.error.code,'campaign_settlement_pending');
 assert.equal(errors.settlement.value.error.details.deleted,false);
 assert.equal(errors.running.value.error.code,'campaign_in_progress');
 assert.equal(responses['503'].content['application/json'].example.error.code,'deletion_unavailable');
});

test('C12 single-call deletion describes guarded refusals and the empty-recording success receipt',()=>{
 const responses=spec.paths['/calls/{id}'].delete.responses;
 const success=responses['200'].content['application/json'];
 assert.deepEqual(success.schema.required,['call_id','deleted','recording_deleted']);
 assert.equal(success.examples.empty_recording.value.recording_deleted,false);
 assert.equal(success.examples.empty_recording.value.deleted,true);
 assert.match(success.schema.properties.recording_deleted.description,/not proof/);
 const conflicts=responses['409'].content['application/json'];
 assert.deepEqual(Object.keys(conflicts.examples).sort(),['call_in_progress','cleanup_pending_confirmation','deletion_cleanup_failed','deletion_unsettled','recording_cleanup_pending']);
 for(const item of Object.values(conflicts.examples)){
  assert.equal(item.value.error.details.deleted,false);
  assert.equal(item.value.error.details.safe_to_retry,false);
 }
 assert.equal(responses['503'].content['application/json'].examples.deletion_unavailable.value.error.code,'deletion_unavailable');
 assert.ok(!responses['500']);
});
