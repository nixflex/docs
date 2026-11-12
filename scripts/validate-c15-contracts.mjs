// Execute the accepted B57 boundary with fake storage/carriers, then validate its
// actual responses against the published schemas. No network or environment reads.
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {createRequire} from 'node:module';
const args=process.argv.slice(2),arg=name=>args[args.indexOf(name)+1];
assert.ok(args.includes('--engine')&&args.includes('--modules')&&args.includes('--out'));
const root=path.resolve(import.meta.dirname,'..'),engine=arg('--engine');
const revision='9da04ec91ccee8d8997b2d6a89eb0e2c69aeb50d';
const result={status:'working',revision,networkRequests:0,environmentReads:0,cases:[],sourceSha256:{}};
const source=file=>{
 const value=execFileSync('git',['show',revision+':'+file],{cwd:engine,encoding:'utf8',maxBuffer:4e6}).replaceAll('\r\n','\n');
 result.sourceSha256[file]=crypto.createHash('sha256').update(value).digest('hex');return value;
};
function load(file,dependencies={}){
 const module={exports:{}};
 const context={module,exports:module.exports,AbortSignal,Date,Promise,Set,require:name=>{
  if(Object.hasOwn(dependencies,name))return dependencies[name];throw Error('Unexpected dependency '+name+' in '+file);
 }};
 vm.runInNewContext(source(file),context,{filename:file,timeout:1000});return module.exports;
}
const plain=x=>JSON.parse(JSON.stringify(x));
const spec=JSON.parse(fs.readFileSync(path.join(root,'api-reference/public.openapi.json'),'utf8'));
const require=createRequire(import.meta.url),Ajv=require(path.resolve(arg('--modules'),'ajv/dist/2020.js')).default;
const ajv=new Ajv({strict:false,allErrors:true});require(path.resolve(arg('--modules'),'ajv-formats'))(ajv);
const validator=new Map();
function valid(route,status,body){
 const key=route+status;
 if(!validator.has(key))validator.set(key,ajv.compile(spec.paths[route].delete.responses[status].content['application/json'].schema));
 const check=validator.get(key);assert.ok(check(body),key+' '+JSON.stringify(check.errors));
}
const errors=load('api/errorHelper.js'),boundary=load('api/contentDelete.js',{'./errorHelper':errors});
const response=()=>({statusCode:200,body:null,status(n){this.statusCode=n;return this;},json(value){this.body=plain(value);return this;}});
const routes=[['call','/calls/{id}'],['voice','/calls/batch/{id}'],['sms','/sms/campaigns/{id}']];
for(const [kind,route]of routes){
 for(const input of [undefined,null,'',123,'x'.repeat(201)]){
  let dispatched=0;const res=response();await boundary.remove({},'owner_fixture',kind,input,res,{run:async()=>{dispatched++;}});
  assert.equal(res.statusCode,400);assert.equal(res.body.error.code,'invalid_delete');assert.equal(dispatched,0);valid(route,400,res.body);
  result.cases.push(kind+' invalid ID rejected before deletion');
 }
 for(const [state,status,code]of [['not_found',404,'not_found'],['hangup_pending',503,'hangup_pending'],['unexpected',503,'deletion_unavailable']]){
  const res=response();await boundary.remove({},'owner_fixture',kind,'item_fixture',res,{run:async()=>({status:state})});
  assert.equal(res.statusCode,status);assert.equal(res.body.error.code,code);valid(route,status,res.body);
  if(code==='hangup_pending')assert.deepEqual(res.body.error.details,{deleted:false,retry_pending:true});
  if(code==='deletion_unavailable')assert.deepEqual(res.body.error.details,{deleted:false});
  result.cases.push(kind+' '+code+' response');
 }
 for(const recording of [false,true]){
  const res=response();await boundary.remove({},'owner_fixture',kind,'item_fixture',res,{run:async()=>({status:'deleted',recording_deleted:recording})});
  assert.equal(res.statusCode,200);assert.equal(res.body.deleted,true);valid(route,200,res.body);
  if(kind==='call')assert.deepEqual(res.body,{call_id:'item_fixture',deleted:true,recording_deleted:recording,recording_cleanup:recording?'carrier_best_effort':'queued'});
  else assert.deepEqual(res.body,{campaign_id:'item_fixture',deleted:true,message:'Campaign deleted'});
  result.cases.push(kind+' deletion success, recording '+recording);
 }
 const res=response();await boundary.remove({},'owner_fixture',kind,'item_fixture',res,{run:async()=>{throw Error('fake transport');}});
 assert.equal(res.statusCode,503);assert.equal(res.body.error.code,'deletion_unavailable');valid(route,503,res.body);result.cases.push(kind+' failed transport stays unconfirmed');
 assert.ok(!spec.paths[route].delete.responses['409'],'No superseded settlement refusal on '+route);
}
let discarded=[];
const worker=load('shared/deletion/contentDelete.js',{'./erasureTransport':{bounded:async work=>work},'./recordingSave':{discardCall:id=>discarded.push(id)}});
function fakeDb({calls=[],commit='deleted',begin='requested',fail=null}={}){
 const trace=[];return {trace,rpc(name,params){trace.push({name,params:plain(params)});return {abortSignal:async()=>({error:fail===name?{code:'fixture'}:null,data:name==='content_delete_begin'?{status:begin}:name==='content_delete_calls'?calls:name==='content_delete_commit'?{status:commit}:{ok:true}})};}};
}
for(const stopped of [true,false]){
 const db=fakeDb({calls:[{api_key_id:'owner_fixture',call_id:'call_fixture'}],commit:stopped?'deleted':'hangup_pending'}),events=[];
 const actual=await worker.processRequest(db,'owner_fixture','call','call_fixture',{stop:async call=>{events.push('stop');return stopped;},cleanup:async()=>{events.push('cleanup');return true;}});
 assert.equal(actual.status,stopped?'deleted':'hangup_pending');
 assert.deepEqual(events,stopped?['stop','cleanup']:['stop']);
 assert.deepEqual(db.trace.map(x=>x.name),['content_delete_begin','content_delete_calls','content_delete_stopped','content_delete_commit']);
 assert.equal(db.trace[2].params.p_stopped,stopped);
 result.cases.push('Hang-up '+stopped+' precedes content commit; cleanup only follows deletion');
}
for(const cleanup of [async()=>false,async()=>{throw Error('fake storage failure');}]){
 const value=await worker.processRequest(fakeDb(),'owner_fixture','call','call_fixture',{cleanup});
 assert.equal(value.status,'deleted');assert.equal(value.recording_deleted,false);result.cases.push('Storage uncertainty keeps confirmed content deletion and queued cleanup');
}
for(const kind of ['voice','sms']){
 let cleaned=false;const value=await worker.processRequest(fakeDb(),'owner_fixture',kind,'campaign_fixture',{cleanup:async()=>{cleaned=true;return true;}});
 assert.equal(value.status,'deleted');assert.equal(cleaned,false);result.cases.push(kind+' campaign deletion does not sweep sent call recordings');
}
const foreign=fakeDb({calls:[{api_key_id:'other_fixture',call_id:'call_fixture'}]});let stoppedForeign=false;
await assert.rejects(worker.processRequest(foreign,'owner_fixture','call','call_fixture',{stop:async()=>{stoppedForeign=true;return true;}}),/delete_scope/);
assert.equal(stoppedForeign,false);assert.ok(!foreign.trace.some(r=>r.name==='content_delete_commit'));result.cases.push('Foreign owner rejected before stop or commit');
const missing=fakeDb({begin:'not_found'});assert.equal((await worker.processRequest(missing,'owner_fixture','call','missing_fixture')).status,'not_found');assert.equal(missing.trace.length,1);result.cases.push('Missing owned lookup stops at begin');
for(const fail of ['content_delete_begin','content_delete_calls','content_delete_commit']){
 await assert.rejects(worker.processRequest(fakeDb({fail}),'owner_fixture','call','call_fixture'),/deletion_unconfirmed/);result.cases.push(fail+' failure is not deletion proof');
}
const roles=JSON.parse(source('shared/organisations/policy.json'));
const policy=load('shared/organisations/policy.js',{'./policy.json':roles,'./readOperation':{calculation:()=>false}});
for(const [,route]of routes){
 const action=policy.action('DELETE','/v1'+route.replace('{id}','item_fixture'));
 assert.equal(action,'write');assert.equal(policy.allows('owner',action),true);assert.equal(policy.allows('admin',action),true);assert.equal(policy.allows('member',action),false);result.cases.push(route+' Owner/Admin allowed; Member denied');
}
const spelling=load('shared/features/bookingSpelling.js',{'./bookingSpellingWords':{},'./bookingEmail':{}});
for(const calendar of ['gcal','calcom'])for(const setting of [true,false,null]){
 const row={['_'+calendar]:true,['_'+calendar+'Action']:'book_appointment'};
 assert.equal(spelling.applies({channel:'voice',require_booking_confirmation:setting},row),true);
 assert.equal(spelling.applies({channel:'sms',require_booking_confirmation:setting},row),false);
 row['_'+calendar+'Action']='confirm_details';assert.equal(spelling.applies({channel:'voice'},row,{existing_booking:true}),false);
 result.cases.push(calendar+' voice gate independent of old '+setting+' setting; SMS/existing booking excluded');
}
result.status='PASS';result.count=result.cases.length;result.scope='Pinned source and fake dependencies only; no live carrier, calendar, database or cleanup claim';
fs.writeFileSync(arg('--out'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({status:result.status,cases:result.count,revision,networkRequests:0}));
