// Offline B56 response proof: pinned engine functions, fake RPCs and synthetic call intents.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {b56Source} from './c13-engine-source.mjs';
import {requestIdExample} from './c13-contracts.mjs';
const root=path.resolve(import.meta.dirname,'..'),args=process.argv.slice(2);
const arg=n=>args[args.indexOf(n)+1];
assert.ok(args.includes('--engine')&&args.includes('--modules')&&args.includes('--out'));
const source=b56Source(arg('--engine')),require=createRequire(import.meta.url);
const Ajv=require(path.resolve(arg('--modules'),'ajv/dist/2020.js')).default,formats=require(path.resolve(arg('--modules'),'ajv-formats'));
const ajv=new Ajv({strict:false,allErrors:true});formats(ajv);
const spec=JSON.parse(fs.readFileSync(path.join(root,'api-reference/public.openapi.json'),'utf8'));
const book=source.load('api/calls/bookingRead.js'),journal=source.load('api/calls/outboundRequests.js');
const paths={book:'/calls/{id}/bookings',request:'/calls/outbound/requests/{request_id}',launch:'/calls/outbound'};
const result={status:'working',sourceCommit:source.commit,sourceMode:'Pinned Git blobs in isolated VM; active source ignored',sourceSha256:{},schemaCases:0,bookingCases:0,requestReadCases:0,launchCases:0,uuidCases:0,dispatches:0,networkRequests:0,realEnvironmentReads:0};
for(const file of ['api/calls/bookingRead.js','api/calls/outboundRequests.js','api/routes.js','sql/security-auth/B56_01_dashboard_calls.sql'])result.sourceSha256[file]=crypto.createHash('sha256').update(source.read(file)).digest('hex');
const plain=x=>JSON.parse(JSON.stringify(x));
const validators=new Map();
function valid(which,status,value){
 const method=which==='launch'?'post':'get',key=which+status;
 if(!validators.has(key))validators.set(key,ajv.compile(spec.paths[paths[which]][method].responses[String(status)].content['application/json'].schema));
 const check=validators.get(key);assert.ok(check(value),key+' '+JSON.stringify(check.errors));result.schemaCases++;
}
function response(){return {statusCode:200,headers:{},body:null,set(k,v){this.headers[k]=v;return this;},status(n){this.statusCode=n;return this;},json(v){this.body=plain(v);return this;}};}
const fakeRpc=value=>({rpc(){return {abortSignal:async()=>({data:value,error:null})};}});
const brokenRpc={rpc(){return {abortSignal:async()=>({data:null,error:{code:'fixture'}})};}};
const call={call_id:'call_example',agent_id:'agent_example',from_number:'+12025550101',to_number:'+12025550100',call_direction:'inbound',end_timestamp:Date.parse('2030-11-04T09:05:00Z')};
const event=spec.webhooks['call.bookings'].post.requestBody.content['application/json'].examples.create_move.value;
const rows=event.timeline.map(({at,...row})=>({...row,_call_booking:{at}}));
const complete={_call_booking_result:{version:1,complete:true}};
for(const [input,state] of [
 [{state:'retained',call,bookings:rows},'ready'],
 [{state:'retained',call,bookings:[complete]},'none'],
 [{state:'retained',call,bookings:[]},'unavailable'],
 [{state:'retained',call,bookings:[event.timeline[0],complete]},'unavailable'],
 [{state:'retained',call,bookings:[rows[0],event.timeline[1]]},'unavailable'],
 ...['processing','deleted','unavailable'].map(state=>[{state},state]),
 ]){
 const value=plain(book.project(input,call.call_id));assert.equal(value.state,state);assert.equal(value.result===null,state!=='ready');valid('book',200,value);result.bookingCases++;
 if(state==='ready')assert.deepEqual(value.result,event);
 }
assert.equal(book.project(null,call.call_id),null);result.bookingCases++;
for(const value of [{state:'retained',call:{call_id:'foreign'},bookings:[]},{state:'unexpected',call,bookings:[]}]){assert.throws(()=>book.project(value,call.call_id));result.bookingCases++;}
for(const [db,req,status,code] of [
 [fakeRpc({state:'retained',call,bookings:[complete]}),{params:{id:call.call_id},developer:{key_id:'account_fixture'}},200,null],
 [fakeRpc(null),{params:{id:'missing'},developer:{key_id:'account_fixture'}},404,'not_found'],
 [fakeRpc(null),{params:{id:''},developer:{key_id:'account_fixture'}},404,'not_found'],
 [fakeRpc(null),{params:{id:'x'.repeat(201)},developer:{key_id:'account_fixture'}},404,'not_found'],
 [brokenRpc,{params:{id:call.call_id},developer:{key_id:'account_fixture'}},503,'call_bookings_unavailable'],
 [fakeRpc(null),{params:{id:call.call_id}},401,'unauthorized'],
 ]){const res=response();await book.handler(()=>db,r=>r.developer?.key_id)(req,res);assert.equal(res.statusCode,status);if(code)assert.equal(res.body.error.code,code);assert.equal(res.headers['Cache-Control'],'no-store');valid('book',status,res.body);result.bookingCases++;}

for(const [id,expected] of [[requestIdExample,true],[requestIdExample.toUpperCase(),true],['00000000-0000-0000-0000-000000000000',false],['9f9aa2b2-4b77-9fa1-9071-9cf6747a9082',false],['9f9aa2b2-4b77-4fa1-0071-9cf6747a9082',false],['',false],[null,false],[42,false]]){assert.equal(journal.valid(id),expected);result.uuidCases++;}
for(const state of ['pending','accepted','rejected','unknown']){
 const db=fakeRpc({state,call_id:state==='accepted'?'call_example':null,reason:state==='rejected'?'outside_hours':null}),res=response();
 await journal.statusHandler(()=>db,()=> 'account_fixture')({params:{request_id:requestIdExample}},res);
 assert.equal(res.body.state,state);assert.equal(res.headers['Cache-Control'],'no-store');valid('request',200,res.body);result.requestReadCases++;
}
for(const [db,id,owner,status,code] of [[fakeRpc(null),requestIdExample,'account_fixture',404,'not_found'],[fakeRpc(null),'invalid','account_fixture',404,'not_found'],[brokenRpc,requestIdExample,'account_fixture',503,'outbound_request_unavailable'],[fakeRpc(null),requestIdExample,null,401,'unauthorized']]){
 const res=response();await journal.statusHandler(()=>db,()=>owner)({params:{request_id:id}},res);assert.equal(res.statusCode,status);assert.equal(res.body.error.code,code);valid('request',status,res.body);result.requestReadCases++;
}
function journalDb(){
 const entries=new Map(),control={beginFails:false,finishFails:false};
 return {entries,control,rpc(name,p){return {abortSignal:async()=>{
  const key=p.p_owner+':'+p.p_request.toLowerCase();
  if(name==='outbound_request_begin'){
   if(control.beginFails)return {error:{code:'fixture'}};
   const old=entries.get(key);if(old)return {data:old.hash!==p.p_hash?{conflict:true}:{...old,claimed:false}};
   const row={state:'pending',hash:p.p_hash,token:p.p_token};entries.set(key,row);return {data:{...row,claimed:true}};
  }
  assert.equal(name,'outbound_request_finish');if(control.finishFails)return {error:{code:'fixture'}};
  const old=entries.get(key);assert.equal(old.token,p.p_token);Object.assign(old,{state:p.p_state,call_id:p.p_call,reason:p.p_reason,http_status:p.p_http});return {data:{saved:true}};
 }};}};
}
const body={request_id:requestIdExample,agent_id:'agent_example',to_number:'+12025550101',prompt:'Confirm the requested appointment.'};
const req=(changes={})=>({developer:{key_id:'account_fixture'},body:{...body,...changes}});
const accepted=async(_req,res)=>{result.dispatches++;res.status(201).json({call_id:'call_example',status:'initiated',to:'+12025550101',from:'+12025550100'});};
async function launch(db,request,handler=accepted){const res=response();await journal.run(request,res,db,handler);valid('launch',res.statusCode,res.body);result.launchCases++;return res;}
const db=journalDb();let res=await launch(db,req());assert.equal(res.statusCode,201);assert.equal(res.body.request_id,requestIdExample);
res=await launch(db,req());assert.equal(res.statusCode,200);assert.equal(res.body.replayed,true);assert.equal(result.dispatches,1);assert.ok(!Object.hasOwn(res.body,'to'));
res=await launch(db,req({prompt:'Different intent'}));assert.equal(res.statusCode,409);assert.equal(res.body.error.code,'request_id_conflict');assert.equal(result.dispatches,1);
db.control.beginFails=true;res=await launch(db,req());assert.equal(res.statusCode,503);assert.equal(res.body.error.details.state,'unknown');assert.equal(res.body.error.details.safe_to_retry,false);assert.equal(result.dispatches,1);
db.control.beginFails=false;res=await launch(db,req());assert.equal(res.statusCode,200);assert.equal(result.dispatches,1);
for(const state of ['pending','unknown']){
 const held=journalDb();held.entries.set('account_fixture:'+requestIdExample,{state,hash:journal.fingerprint('account_fixture',body)});
 res=await launch(held,req());assert.equal(res.statusCode,409);assert.equal(res.body.error.code,'outbound_request_'+state);assert.equal(res.body.error.details.safe_to_retry,false);assert.equal(result.dispatches,1);
}
const ackLost=journalDb();ackLost.control.finishFails=true;res=await launch(ackLost,req());assert.equal(res.statusCode,201);assert.equal(res.body.request_status,'unconfirmed');assert.equal(res.body.safe_to_retry,false);assert.equal(result.dispatches,2);
res=await launch(ackLost,req());assert.equal(res.statusCode,409);assert.equal(result.dispatches,2);
for(const handler of [async()=>{throw Error('synthetic lost outcome');},async(_req,res)=>res.status(200).json({unexpected:true})]){
 res=await launch(journalDb(),req(),handler);assert.equal(res.statusCode,503);assert.equal(res.body.error.code,'outbound_request_unknown');assert.equal(res.body.error.details.safe_to_retry,false);
}
const rejected=journalDb(),refuse=async(_req,res)=>res.status(400).json({error:{type:'invalid_request',code:'missing_field',message:'Synthetic missing field',doc_url:'https://docs.nixflex.com/errors/missing_field',details:{}}});
res=await launch(rejected,req(),refuse);assert.equal(res.statusCode,400);assert.equal(res.body.error.details.state,'rejected');res=await launch(rejected,req());assert.equal(res.statusCode,400);assert.equal(res.body.error.code,'missing_field');assert.equal(result.dispatches,2);
res=await launch(journalDb(),req({request_id:'invalid'}));assert.equal(res.statusCode,400);assert.equal(res.body.error.code,'invalid_request_id');assert.equal(result.dispatches,2);
assert.equal(journal.fingerprint('account_fixture',{...body,dynamic_vars:{b:2,a:1}}),journal.fingerprint('account_fixture',{...body,dynamic_vars:{a:1,b:2}}));
assert.notEqual(journal.fingerprint('account_fixture',body),journal.fingerprint('other_account',body));
const post=spec.paths['/calls/outbound'].post;
assert.deepEqual(post.requestBody.content['application/json'].schema.required,['agent_id','to_number','prompt']);
assert.ok(!post.requestBody.content['application/json'].schema.required.includes('request_id'));
assert.match(source.read('api/routes.js'),/req\.body\?\.request_id !== undefined/);
// Negative schemas: unknown is never empty success, replay is never false, unsafe retry is rejected.
for(const [which,status,value] of [
 ['book',200,{call_id:'call_example',state:'none',result:event}],
 ['book',200,{call_id:'call_example',state:'ready',result:null}],
 ['request',200,{request_id:requestIdExample,state:'completed',call_id:null,reason:null}],
 ['launch',200,{call_id:'call_example',request_id:requestIdExample,status:'initiated',replayed:false}],
 ['launch',503,{error:{type:'server_error',code:'outbound_request_unknown',message:'Synthetic',doc_url:'https://docs.nixflex.com/errors/outbound_request_unknown',details:{request_id:requestIdExample,state:'unknown',safe_to_retry:true}}}],
 ]){assert.equal(validators.get(which+status)(value),false);result.schemaCases++;}
result.status='PASS';fs.mkdirSync(arg('--out'),{recursive:true});fs.writeFileSync(path.join(arg('--out'),'C13-CONTRACTS.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));
