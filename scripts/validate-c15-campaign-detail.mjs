// B59's committed read handler, isolated from databases, credentials and network.
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import assert from 'node:assert/strict';
import {isDeepStrictEqual} from 'node:util';
import {execFileSync} from 'node:child_process';
import {createRequire} from 'node:module';
import {createHash} from 'node:crypto';
const args=process.argv.slice(2),arg=n=>args[args.indexOf(n)+1];
const revision='dd95cfb94decacdb0b6d0f99da9c7fbbe8fb7dd2',root=path.resolve(import.meta.dirname,'..');
const result={status:'working',revision,networkRequests:0,environmentReads:0,cases:[],sourceSha256:{}};
const source=file=>{const s=execFileSync('git',['show',revision+':'+file],{cwd:arg('--engine'),encoding:'utf8'}).replaceAll('\r\n','\n');result.sourceSha256[file]=createHash('sha256').update(s).digest('hex');return s;};
const plain=x=>JSON.parse(JSON.stringify(x));
function load(file,dependencies={}){const module={exports:{}};vm.runInNewContext(source(file),{module,exports:module.exports,AbortSignal,require:name=>{assert.ok(Object.hasOwn(dependencies,name));return dependencies[name];}},{filename:file,timeout:1000});return module.exports;}
const errors=load('api/errorHelper.js'),hours=load('api/campaignHours.js',{'node:util':{isDeepStrictEqual:(a,b)=>isDeepStrictEqual(plain(a),plain(b))}});
const handler=load('api/voiceCampaignRead.js',{'./errorHelper':errors,'./campaignHours':hours});
const routes=source('api/routes.js'),box={};vm.runInNewContext(routes.slice(routes.indexOf('var CAMPAIGN_LIST_COLUMNS'),routes.indexOf("router.get('/campaigns',")),box);
assert.match(routes,/require\('\.\/dashboardReads'\)\.get\(router, '\/campaigns\/:id'/);
const spec=JSON.parse(fs.readFileSync(path.join(root,'api-reference/public.openapi.json'),'utf8'));
const operation=spec.paths['/campaigns/{id}'].get;
assert.equal(operation.operationId,'getVoiceCampaign');assert.deepEqual(operation.responses['200'].content['application/json'].schema.properties.campaign,spec.paths['/campaigns'].get.responses['200'].content['application/json'].schema.properties.campaigns.items);
const require=createRequire(import.meta.url),Ajv=require(path.resolve(arg('--modules'),'ajv/dist/2020.js')).default,ajv=new Ajv({strict:false,allErrors:true});require(path.resolve(arg('--modules'),'ajv-formats'))(ajv);
const checks=Object.fromEntries(Object.entries(operation.responses).map(([status,response])=>[status,ajv.compile(response.content['application/json'].schema)]));
const sample=operation.responses['200'].content['application/json'].examples.campaign.value.campaign;
const revisionId='11111111-1111-4111-8111-111111111111';
function database(options={}){
 const queries=[],row={...sample,api_key_id:options.foreign?'other':'owner',policy_revision:revisionId,user_deleted_at:options.deleted?'2026-11-12':null};
 return {queries,from(table){const filters=[],q={select(fields){q.fields=fields;queries.push({table,fields,filters});return q;},eq(k,v){filters.push([k,v]);return q;},is(k,v){filters.push([k,v]);return q;},in(k,v){filters.push([k,v]);return q;},order(){return q;},limit(){return q;},gt(){return q;},maybeSingle(){return q;},async abortSignal(signal){assert.ok(signal instanceof AbortSignal);
  if(table==='batch_calls')return options.failTable?{error:new Error('private data')}:{data:options.missing||!filters.every(([k,v])=>row[k]===v)?null:Object.fromEntries(q.fields.split(',').map(k=>k.trim()).map(k=>[k,row[k]]))};
  assert.equal(table,'campaign_policy_audit');assert.ok(filters.some(([k,v])=>k==='api_key_id'&&v==='owner'));
  return options.failEvidence?{error:new Error('private evidence')}:{data:options.noEvidence?[]:[{id:'22222222-2222-4222-8222-222222222222',campaign_id:sample.campaign_id,revision:options.stale?'33333333-3333-4333-8333-333333333333':revisionId,detail:{confirmed:true,start:sample.window_start_minutes,end:sample.window_end_minutes,days:sample.window_days}}]};
 }};return q;}};
}
const response=()=>({statusCode:200,headers:{},setHeader(k,v){this.headers[k]=v;},status(n){this.statusCode=n;return this;},json(body){this.body=plain(body);return this;}});
for(const [name,options,status,allowed]of [['current evidence',{},200,true],['no evidence',{noEvidence:true},200,false],['stale evidence',{stale:true},200,false],['missing',{missing:true},404],['foreign',{foreign:true},404],['deleted',{deleted:true},404],['table failure',{failTable:true},503],['evidence failure',{failEvidence:true},503]]){
 const db=database(options),res=response();await handler.handle(db,{developer:{key_id:'owner'},params:{id:sample.campaign_id}},res,box.CAMPAIGN_LIST_COLUMNS);
 assert.equal(res.statusCode,status,name);assert.equal(res.headers['Cache-Control'],'no-store');assert.ok(checks[status](res.body),JSON.stringify(checks[status].errors));
 assert.doesNotMatch(JSON.stringify(res.body),/private|policy_revision|api_key_id/);
 if(status===200)assert.equal(res.body.campaign.allow_wider_hours,allowed);
 else assert.equal(res.body.error.code,status===404?'not_found':'campaign_unavailable');
 result.cases.push(name);
}
for(const id of ['',undefined,123,'a'.repeat(201)]){const db=database(),res=response();await handler.handle(db,{developer:{key_id:'owner'},params:{id}},res,box.CAMPAIGN_LIST_COLUMNS);assert.equal(res.statusCode,404);assert.equal(db.queries.length,0);assert.ok(checks[404](res.body));result.cases.push('invalid ID before read: '+String(id).slice(0,12));}
const db=database(),res=response();await handler.handle(db,{params:{id:sample.campaign_id}},res,box.CAMPAIGN_LIST_COLUMNS);assert.equal(res.statusCode,404);assert.equal(db.queries.length,0);result.cases.push('missing account before read');
result.status='PASS';fs.writeFileSync(arg('--out'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({status:result.status,cases:result.cases.length,revision,networkRequests:0}));
