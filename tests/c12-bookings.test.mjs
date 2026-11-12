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
 assert.equal(Object.values(spec.paths).flatMap(Object.keys).filter(x=>['get','post','put','patch','delete'].includes(x)).length,151);
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

test('B57 campaign deletion preserves history and separates queued from unconfirmed outcomes',()=>{
 for(const path of ['/sms/campaigns/{id}','/calls/batch/{id}']){
  const responses=spec.paths[path].delete.responses;
  const success=responses['200'].content['application/json'];
  assert.deepEqual(success.schema.required,['campaign_id','deleted','message']);
  assert.deepEqual(success.examples.deleted.value,{campaign_id:'campaign_example',deleted:true,message:'Campaign deleted'});
  assert.ok(responses['400']);assert.ok(responses['403']);assert.ok(responses['404']);
  assert.ok(!responses['409']);assert.ok(!responses['500']);
  const errors=responses['503'].content['application/json'].examples;
  assert.deepEqual(errors.hangup_pending.value.error.details,{deleted:false,retry_pending:true});
  assert.equal(errors.hangup_pending.value.error.code,'hangup_pending');
  assert.equal(errors.deletion_unavailable.value.error.code,'deletion_unavailable');
  assert.deepEqual(errors.deletion_unavailable.value.error.details,{deleted:false});
 }
});

test('B57 single-call deletion tracks recording cleanup separately from completed content deletion',()=>{
 const responses=spec.paths['/calls/{id}'].delete.responses;
 const success=responses['200'].content['application/json'];
 assert.deepEqual(success.schema.required,['call_id','deleted','recording_deleted','recording_cleanup']);
 assert.deepEqual(success.schema.properties.recording_cleanup.enum,['carrier_best_effort','queued']);
 assert.equal(success.examples.cleaned.value.recording_deleted,true);
 assert.equal(success.examples.cleaned.value.recording_cleanup,'carrier_best_effort');
 assert.equal(success.examples.cleanup_queued.value.recording_deleted,false);
 assert.equal(success.examples.cleanup_queued.value.recording_cleanup,'queued');
 for(const item of Object.values(success.examples))assert.equal(item.value.deleted,true);
 assert.match(success.schema.properties.recording_deleted.description,/not proof/);
 assert.ok(!responses['409']);assert.ok(!responses['500']);
 const errors=responses['503'].content['application/json'].examples;
 assert.deepEqual(errors.hangup_pending.value.error.details,{deleted:false,retry_pending:true});
 assert.deepEqual(errors.deletion_unavailable.value.error.details,{deleted:false});
 assert.equal(errors.deletion_unavailable.value.error.code,'deletion_unavailable');
});
