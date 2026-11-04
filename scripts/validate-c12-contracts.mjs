// Supplemental C12 proof. Existing validators and locked tests are unchanged.
// Run with --modules <Mint node_modules> --engine <read-only engine checkout> --out <artifact folder>.
// Only pure engine functions and a mock campaign RPC are used. No network or credentials.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import vm from 'node:vm';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {execFileSync} from 'node:child_process';
import {pinnedEngine} from './c12-engine-source.mjs';
const root=path.resolve(import.meta.dirname,'..');
const args=process.argv.slice(2),arg=n=>args.includes(n)?args[args.indexOf(n)+1]:undefined;
const modules=arg('--modules'),engine=arg('--engine'),out=arg('--out');
assert.ok(modules&&engine&&out,'Provide --modules, --engine and --out');
const require=createRequire(import.meta.url);
const Ajv=require(path.resolve(modules,'ajv/dist/2020.js')).default;
const addFormats=require(path.resolve(modules,'ajv-formats'));
const ajv=new Ajv({strict:false,allErrors:true});addFormats(ajv);
const source=pinnedEngine(engine,arg('--engine-ref'));
const spec=JSON.parse(fs.readFileSync(path.join(root,'api-reference/public.openapi.json'),'utf8'));
const media=spec.webhooks['call.bookings'].post.requestBody.content['application/json'];
const validateBooking=ajv.compile(media.schema);
const results={status:'working',sourceCommit:source.commit,sourceMode:'committed Git blobs in isolated VM; active worktree ignored',
 engineFiles:{},webhookExamples:0,schemaCases:0,engineCases:0,receiverCases:0,campaignCases:0,callDeletionCases:0,networkRequests:0};
for(const file of ['shared/features/callBookings.js','shared/data/bookingPayload.js','api/campaignDelete.js','api/errorHelper.js','shared/deletion/deleteGuard.js']){
 results.engineFiles[file]=crypto.createHash('sha256').update(source.read(file)).digest('hex');
}
const clone=x=>structuredClone(x);
function accepted(value){assert.ok(validateBooking(value),JSON.stringify(validateBooking.errors));results.schemaCases++;}
function refused(value){assert.equal(validateBooking(value),false,'Malformed booking payload accepted');results.schemaCases++;}
for(const {value} of Object.values(media.examples)){accepted(value);results.webhookExamples++;}
const sample=media.examples.create_move.value;
accepted({...clone(sample),call_id:null,agent_id:null,from:null,to:null,number:null});
accepted({...clone(sample),future_field:{opaque:true}});
for(const key of media.schema.required){const value=clone(sample);delete value[key];refused(value);}
for(const changes of [{event:'call.completed'},{timeline:[]},{final:[]},{ended_at:null},{ended_at:'not-a-date'},{call_id:123}])refused({...clone(sample),...changes});
for(const changes of [{action:'already_exists'},{start:'2030-99-99T10:00:00Z'},{attendee_email:42},{service:{value:42}}]){
 const value=clone(sample);Object.assign(value.timeline[0],changes);refused(value);
}
const wrongStatus=clone(sample);wrongStatus.final[0].status='completed';refused(wrongStatus);

// Execute the pure source projection against documented examples, including a replacement UID.
const engineBookings=source.load('shared/features/callBookings.js');
const call={call_id:'call_example',agent_id:'agent_example',from_number:'+12025550101',to_number:'+12025550100',
 call_direction:'inbound',end_timestamp:Date.parse('2030-11-04T09:05:00.000Z')};
const receipt=(row,next=null)=>{const {at,...booking}=row;return {...booking,_call_booking:{at,next_uid:next}};};
for(const [name,{value}] of Object.entries(media.examples)){
 const rows=value.timeline.map((row,i)=>receipt(row,name==='replacement_uid'&&i===1?'booking_replacement':null));
 const actual=engineBookings.build(call,rows);assert.deepEqual(JSON.parse(JSON.stringify(actual)),value,name);accepted(actual);results.engineCases++;
}
const created=sample.timeline[0];
const nullMove={...sample.timeline[1],end:null,attendee_name:null,attendee_email:null,service:null,timezone:null};
const retained=engineBookings.build(call,[receipt(created),receipt(nullMove)]);
assert.equal(retained.timeline[1].end,null);assert.equal(retained.final[0].end,created.end);
assert.equal(retained.final[0].start,nullMove.start);assert.equal(retained.final[0].attendee_name,created.attendee_name);
accepted(retained);results.engineCases++;
const outbound=engineBookings.build({...call,call_direction:'outbound'},[receipt(created)]);
assert.equal(outbound.number,call.from_number);accepted(outbound);results.engineCases++;
for(const rows of [[],[created],[{...receipt(created),action:'already_exists'}],[{...receipt(created),booking_uid:null}],
 [{...receipt(created),_call_booking:{at:'invalid'}}]]){
 assert.equal(engineBookings.has(rows),false);assert.equal(engineBookings.build(call,rows).timeline.length,0);results.engineCases++;
}
for(const [success,outcome,source,expected] of [[true,'created',{_gcal:true},true],[true,'rescheduled',{_calcom:true},true],
 [false,'created',{_gcal:true},false],[true,'already_exists',{_gcal:true},false],[true,'created',{},false]]){
 const booking={...created,action:outcome};delete booking.at;
 engineBookings.mark({success,outcome,booking},source);
 assert.equal(engineBookings.has(engineBookings.persist([booking])),expected);results.engineCases++;
}

// Execute only the public calculation snippets, with synthetic values; no SDK, HTTP or DB code.
const page=fs.readFileSync(path.join(root,'api-reference/call-bookings.mdx'),'utf8');
const javascript=page.match(/```javascript\s*\n([\s\S]*?)```/)[1];
const helper=vm.runInNewContext(javascript+'\nbookingResult;');
const counts={create_move:1,create_cancel:0,create_move_cancel:0,move_existing:1,two_bookings:2,replacement_uid:1,unknown_fields:1};
for(const [name,count] of Object.entries(counts)){
 const got=helper(media.examples[name].value,'account_fixture');
 assert.equal(got.activeBookings,count);assert.deepEqual(JSON.parse(got.dedupeKey),['account_fixture','call.bookings','call_example']);results.receiverCases++;
}
assert.notEqual(helper(sample,'account_one').dedupeKey,helper(sample,'account_two').dedupeKey);results.receiverCases++;
for(const value of [{...sample,call_id:null},{...sample,event:'call.completed'}]){assert.throws(()=>helper(value,'account_fixture'));results.receiverCases++;}
const python=page.match(/```python\s*\n([\s\S]*?)```/)[1];
const pythonCases=Object.entries(counts).map(([name,count])=>({event:media.examples[name].value,count}));
const program=python+`\nimport json,sys\nfor item in json.load(sys.stdin):\n    result=booking_result(item['event'],'account_fixture')\n    assert result['active_bookings']==item['count']\n    assert result['dedupe_key']==('account_fixture','call.bookings','call_example')\ntry:\n    booking_result({'event':'call.bookings','call_id':None},'account_fixture')\nexcept ValueError:\n    pass\nelse:\n    raise AssertionError('null call ID was accepted')\n`;
execFileSync(process.env.NXF_PYTHON||'python',['-X','utf8','-c',program],{input:JSON.stringify(pythonCases),stdio:['pipe','pipe','pipe']});
results.receiverCases+=pythonCases.length+1;

// Exercise B54's actual wrapper with a fake DB result; the fake is never connected.
const remove=source.load('api/campaignDelete.js').remove;
const deleteResponses=spec.paths['/sms/campaigns/{id}'].delete.responses;
for(const [dbResult,status,code] of [
 [{data:{status:'campaign_settlement_pending'}},409,'campaign_settlement_pending'],
 [{error:{code:'55006',message:'final settlement pending'}},409,'campaign_settlement_pending'],
 [{data:{status:'campaign_in_progress'}},409,'campaign_in_progress'],
 [{data:{status:'deleted'}},200,null],[{data:{status:'not_found'}},200,null],
 [{error:{code:'unavailable'}},503,'deletion_unavailable'],[{data:null},503,'deletion_unavailable'],
 [{data:{status:'unknown'}},503,'deletion_unavailable'],
 ]){
 let calls=0,actualStatus=200,body;
 const db={rpc(name,params){calls++;assert.equal(name,'campaign_delete_settled');assert.equal(params.p_kind,'sms');
  assert.equal(params.p_owner,'owner_fixture');assert.equal(params.p_campaign,'campaign_fixture');
  return {abortSignal(){return Promise.resolve(dbResult);}};}};
 const res={status(value){actualStatus=value;return this;},json(value){body=value;return value;}};
 await remove(db,'owner_fixture','sms','campaign_fixture',res);
 assert.equal(calls,1);assert.equal(actualStatus,status);assert.equal(body.error?.code||null,code);
 const mediaResponse=deleteResponses[String(status)].content['application/json'];
 const verify=ajv.compile(mediaResponse.schema);assert.ok(verify(body),JSON.stringify(verify.errors));
 if(code==='campaign_settlement_pending')assert.equal(body.error.details.deleted,false);
 results.campaignCases++;
}
const conflict=ajv.compile(deleteResponses['409'].content['application/json'].schema);
const settlement=clone(deleteResponses['409'].content['application/json'].examples.settlement.value);
for(const details of [{deleted:true},{}]){const value=clone(settlement);value.error.details=details;assert.equal(conflict(value),false);results.campaignCases++;}

// Only the response guard and a fake read RPC run here; no call is deleted.
const guard=source.load('shared/deletion/deleteGuard.js');
const callResponses=spec.paths['/calls/{id}'].delete.responses;
const verifyCall=Object.fromEntries(['200','409','503'].map(status=>[status,ajv.compile(callResponses[status].content['application/json'].schema)]));
function guardedReply(cause,status,code){
 let actualStatus,body;
 guard.reply({status(value){actualStatus=value;return this;},json(value){body=value;return value;}},cause);
 assert.equal(actualStatus,status);assert.equal(body.error.code,code);
 assert.ok(verifyCall[status](body),JSON.stringify(verifyCall[status].errors));
 assert.equal(body.error.details.deleted,false);assert.equal(body.error.details.safe_to_retry,false);
 results.callDeletionCases++;return body;
}
for(const status of ['409','503'])for(const [code,example] of Object.entries(callResponses[status].content['application/json'].examples)){
 assert.equal(example.value.error.message,guard.messages[code]);
 for(const due of [null,'2030-11-04T10:00:00.000Z']){
  const body=guardedReply(guard.failure(code,due),Number(status),code);
  assert.equal(body.error.details.review_due,due);
 }
}
guardedReply(Error('synthetic unexpected cleanup failure'),409,'deletion_cleanup_failed');
for(const reply of [{error:{message:'synthetic unavailable'}},{data:null},{data:{ok:'yes'}},{data:{ok:false,reason:'unknown_reason'}}]){
 const db={rpc(name,parameters){assert.equal(name,'data_delete_guard');assert.equal(parameters.p_scope,'call');
  assert.equal(parameters.p_owner,'owner_fixture');assert.equal(parameters.p_id,'call_fixture');
  return {abortSignal(){return Promise.resolve(reply);}};}};
 await assert.rejects(()=>guard.requireSafe(db,'owner_fixture','call','call_fixture'),cause=>{
  guardedReply(cause,503,'deletion_unavailable');return true;
 });
}
const refusal=clone(callResponses['409'].content['application/json'].examples.recording_cleanup_pending.value);
for(const changes of [{deleted:true},{account_locked:true},{safe_to_retry:true},{review_due:'not-a-date'}]){
 const value=clone(refusal);Object.assign(value.error.details,changes);assert.equal(verifyCall['409'](value),false);results.callDeletionCases++;
}
for(const name of ['deleted','reason','review_due','safe_to_retry','account_locked']){
 const value=clone(refusal);delete value.error.details[name];assert.equal(verifyCall['409'](value),false);results.callDeletionCases++;
}
for(const example of Object.values(callResponses['200'].content['application/json'].examples)){
 assert.ok(verifyCall['200'](example.value));results.callDeletionCases++;
}
for(const changes of [{deleted:false},{recording_deleted:null}]){
 const value={...callResponses['200'].content['application/json'].examples.empty_recording.value,...changes};
 assert.equal(verifyCall['200'](value),false);results.callDeletionCases++;
}
results.status='PASS';fs.mkdirSync(out,{recursive:true});
fs.writeFileSync(path.join(out,'C12-CONTRACTS.json'),JSON.stringify(results,null,2)+'\n');
console.log(JSON.stringify(results));
