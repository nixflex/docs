import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import {bookingExamples} from '../scripts/c12-webhook-contracts.mjs';
import {bookingReadExamples} from '../scripts/c13-contracts.mjs';
const root=path.resolve(import.meta.dirname,'..');
const page=fs.readFileSync(path.join(root,'guides/developer/call-history.mdx'),'utf8');
const source=[...page.matchAll(/```javascript[^\n]*\n([\s\S]*?)```/g)].map(m=>m[1]).find(s=>s.includes('function bookingView('));
assert.ok(source,'The tested helper must be the example on the published guide');
const view=vm.runInNewContext(source+'\nbookingView;',Object.create(null),{timeout:1000});
test('C13 booking UI never turns unavailable, processing or deleted into zero bookings',()=>{
 for(const [state,example]of Object.entries(bookingReadExamples)){
  const result=view(example.value);
  assert.equal(result.state,state);
  assert.equal(result.activeBookings,state==='ready'?1:state==='none'?0:null);
 }
});
test('C13 booking UI counts final active bookings after moves and cancellations',()=>{
 for(const [name,count]of Object.entries({create_move:1,create_cancel:0,create_move_cancel:0,move_existing:1,two_bookings:2,replacement_uid:1,unknown_fields:1})){
  assert.equal(view({call_id:'call_example',state:'ready',result:bookingExamples[name].value}).activeBookings,count,name);
 }
});
test('C13 booking UI refuses malformed and unknown response shapes',()=>{
 for(const value of [null,{}, {call_id:3,state:'none',result:null},{call_id:'call_example',state:'ready',result:null},{call_id:'call_example',state:'none',result:{}},{call_id:'call_example',state:'complete',result:null}])assert.throws(()=>view(value));
});
