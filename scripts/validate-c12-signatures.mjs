// Execute the documented verifiers against the real sender in a sealed VM.
// All transport, signing-store and recovery dependencies are fake. No real engine environment is read.
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {pinnedEngine} from './c12-engine-source.mjs';
const args=process.argv.slice(2),arg=n=>args.includes(n)?args[args.indexOf(n)+1]:undefined;
const engine=arg('--engine'),out=arg('--out');assert.ok(engine&&out);
const root=path.resolve(import.meta.dirname,'..');
const snippet=fs.readFileSync(path.join(root,'snippets/guides/signature-verification.mdx'),'utf8');
const js=snippet.match(/```javascript[^\n]*\n([\s\S]*?)```/)[1].replace(/^import[^\n]+\n/m,'').replace('export function','function');
const verify=vm.runInNewContext(js+'\nverifyNixflex;',{Buffer,createHmac:crypto.createHmac,timingSafeEqual:crypto.timingSafeEqual});
const source=pinnedEngine(engine,arg('--engine-ref'));
const senderSource=source.read('shared/features/webhook.js');
const timestamp=1920013200,secret='synthetic-signing-fixture',fixtures=[];
let senderCases=0,verifierCases=0,fakeRequests=0;
function sender(signingSecret,{failFirst=false,failAll=false}={}){
 let attempt=0;const sent=[];
 const transport={request(options,receive){
  attempt++;let raw='',errorHandler;
  return {on(type,fn){if(type==='error')errorHandler=fn;},setTimeout(){},destroy(){},write(value){raw+=value;},end(){
   fakeRequests++;if(failAll||(failFirst&&attempt===1)){errorHandler(Error('synthetic transport failure'));return;}
   sent.push({options,raw});receive({statusCode:204,resume(){}});
  }};
 }};
 const deps={https:transport,http:transport,crypto,
  '@supabase/supabase-js':{createClient(){return {}; }},
  '../organisations/config':{enabled(){return true;}},
  '../organisations/signing':{async read(){return {data:signingSecret?{key_secret:signingSecret}:null};}},
  '../workRecovery/runtime':{async checkJob(){}},
 };
 const context={module:{exports:{}},require(name){assert.ok(Object.hasOwn(deps,name),'Unexpected dependency: '+name);return deps[name];},
  process:{env:{SUPABASE_URL:'https://synthetic.invalid',SUPABASE_SERVICE_ROLE_KEY:'synthetic-only'}},
  console:{log(){},warn(){},error(){}},URL,Buffer,Date:class extends Date{static now(){return timestamp*1000;}},};
 vm.runInNewContext(senderSource,context,{filename:'isolated-webhook-sender.js'});
 return {send:context.module.exports.sendWebhook,sent,get attempts(){return attempt;}};
}
for(const payload of [{event:'call.bookings',note:'plain'},{event:'call.bookings',note:'Zoë / café / 東京 / 📅'},
 {event:'call.bookings',note:'line\nquote"slash\\',extra:null}]){
 const fake=sender(secret);await fake.send('https://receiver.invalid/events',payload,{apiKeyId:'account_fixture',requireSignature:true,returnResult:true});
 assert.equal(fake.attempts,1);const {raw,options}=fake.sent[0];
 assert.equal(options.headers['Content-Length'],Buffer.byteLength(raw));
 const header=options.headers['X-Nixflex-Signature'];
 assert.equal(verify(Buffer.from(raw),header,secret,timestamp*1000),true);senderCases++;verifierCases++;
 const base={body:Buffer.from(raw).toString('base64'),header,secret,now:timestamp,expected:true};fixtures.push(base);
 for(const [body,head,key,now,expected] of [
  [raw+' ',header,secret,timestamp,false],
  [JSON.stringify(payload,null,2),header,secret,timestamp,false],
  [raw,header,secret+'-wrong',timestamp,false],
  [raw,header,secret,timestamp+300,true],
  [raw,header,secret,timestamp+301,false],
  [raw,header,secret,timestamp-301,false],
  [raw,'',secret,timestamp,false],
  [raw,header+',v1='+ '0'.repeat(64),secret,timestamp,false],
  [raw,header.replace(/v1=(.*)/,(_,h)=>'v1='+h.toUpperCase()),secret,timestamp,true],
 ]){
  assert.equal(verify(Buffer.from(body),head,key,now*1000),expected);verifierCases++;
  fixtures.push({body:Buffer.from(body).toString('base64'),header:head,secret:key,now,expected});
 }
}
for(const apiKeyId of ['account_fixture',null]){
 const fake=sender(null);await assert.rejects(()=>fake.send('https://receiver.invalid/events',{event:'call.bookings'},
  {apiKeyId,requireSignature:true,returnResult:true}),/Webhook signing unavailable/);
 assert.equal(fake.attempts,0);senderCases++;
}
const legacy=sender(null);await legacy.send('https://receiver.invalid/events',{event:'call.completed'},
 {apiKeyId:'account_fixture',returnResult:true});
assert.equal(legacy.sent[0].options.headers['X-Nixflex-Signature'],undefined);senderCases++;
const retry=sender(secret,{failFirst:true});await retry.send('https://receiver.invalid/events',{event:'call.bookings'},
 {apiKeyId:'account_fixture',requireSignature:true,returnResult:true});assert.equal(retry.attempts,2);senderCases++;
const failed=sender(secret,{failAll:true});await assert.rejects(()=>failed.send('https://receiver.invalid/events',{event:'call.bookings'},
 {apiKeyId:'account_fixture',requireSignature:true,returnResult:true}),/synthetic transport failure/);assert.equal(failed.attempts,2);senderCases++;
const py=snippet.match(/```python[^\n]*\n([\s\S]*?)```/)[1];
execFileSync(process.env.NXF_PYTHON||'python',['-X','utf8','-c',py+`\nimport base64,json,sys\nfor case in json.load(sys.stdin):\n    actual=verify_nixflex(base64.b64decode(case['body']),case['header'],case['secret'],case['now'])\n    assert actual==case['expected'], case\n`],{input:JSON.stringify(fixtures),stdio:['pipe','pipe','pipe']});
const result={status:'PASS',sourceCommit:source.commit,sourceMode:'committed Git blob in isolated VM; active worktree ignored',senderCases,nodeVerifierCases:verifierCases,pythonVerifierCases:fixtures.length,
 syntheticTransportCalls:fakeRequests,networkRequests:0,realEngineEnvironmentReads:0,
 sourceSha256:crypto.createHash('sha256').update(senderSource).digest('hex')};
fs.mkdirSync(out,{recursive:true});fs.writeFileSync(path.join(out,'C12-SIGNATURES.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result));
