import assert from 'node:assert/strict'
import fs from 'node:fs'
import path from 'node:path'
import {readBlobs,extract,verifyValues} from './ai-rules-source.mjs'

export const root=path.resolve(import.meta.dirname,'..')
export const read=file=>fs.readFileSync(path.join(root,file),'utf8').replaceAll('\r\n','\n')
export const json=file=>JSON.parse(read(file))
const folder='spec-source/ai-rules/'
export function readFacts(){
 const index=json(folder+'index.json'),names=Object.keys(index.features)
 const actual=fs.readdirSync(path.join(root,folder,'features')).sort()
 assert.deepEqual(actual,names.map(n=>n+'.json').sort(),'Missing or surplus feature file')
 const features=names.map(n=>{const f=json(folder+'features/'+n+'.json');assert.equal(f.feature,n);return f})
 const publicOps=new Set(Object.entries(json('api-reference/public.openapi.json').paths).flatMap(([p,methods])=>Object.keys(methods).filter(m=>/^(get|put|post|patch|delete)$/.test(m)).map(m=>m.toUpperCase()+' /v1'+p)))
 return {features,index,publicOps}
}
function shape(v,s,where){
 if(s.const!==undefined)assert.equal(v,s.const,where)
 if(s.enum)assert.ok(s.enum.includes(v),where+' enum')
 if(s.type==='object'){
  assert.ok(v&&typeof v==='object'&&!Array.isArray(v),where)
  for(const k of s.required||[])assert.ok(Object.hasOwn(v,k),where+' missing '+k)
  for(const [k,x] of Object.entries(v)){
   if(s.additionalProperties===false)assert.ok(s.properties?.[k],where+' unexpected '+k)
   if(s.properties?.[k])shape(x,s.properties[k],where+'.'+k)
  }
 }
 if(s.type==='string'){
  assert.equal(typeof v,'string',where);if(s.minLength)assert.ok(v.trim().length>=s.minLength,where)
  if(s.pattern)assert.match(v,new RegExp(s.pattern),where)
  if(s.format==='date')assert.match(v,/^\d{4}-\d{2}-\d{2}$/,where)
 }
 if(s.type==='array'){
  assert.ok(Array.isArray(v)&&v.length>=(s.minItems||0),where)
  if(s.uniqueItems)assert.equal(new Set(v).size,v.length,where)
  v.forEach((x,i)=>shape(x,s.items,where+'['+i+']'))
 }
 for(const clause of s.allOf||[])if(v.kind===clause.if.properties.kind.const)
  for(const k of clause.then.required)assert.ok(Object.hasOwn(v,k),where+' missing '+k)
}
export function validateShape(features,index){
 const schema=json(folder+'schema.json'),ids=new Set()
 for(const f of features){
  shape(f,schema,f.feature);assert.equal(f.checked.engine,index.engine)
  for(const kind of schema.properties.rules.items.properties.kind.enum)assert.ok(f.rules.some(r=>r.kind===kind),f.feature+' missing '+kind)
  for(const r of f.rules){assert.ok(!ids.has(r.id),'Duplicate '+r.id);ids.add(r.id)
   if(r.policy)assert.ok(index.policy[r.policy],r.id+' unknown policy')
   if(r.sourceList)assert.ok(r.value!==undefined,r.id+' missing value')
  }
 }
}
export function validateBoundary(features,index,publicOps){
 const primary=Object.values(index.features).flatMap(f=>f.operations)
 assert.deepEqual([...primary].sort(),[...publicOps].sort(),'Every public operation needs exactly one primary owner')
 const all=features.flatMap(f=>f.rules),find=id=>all.find(r=>r.id===id)
 for(const r of all.filter(r=>r.kind==='api'))for(const op of [r.value].flat())assert.ok(publicOps.has(op),r.id+' unpublished '+op)
 for(const r of all)assert.doesNotMatch(r.text+' '+(r.instead||''),/\/api\/|\b(?:staging-api|partner payouts|support tickets)\b/i,r.id)
 for(const r of [find('act-tags'),find('in-tags')])assert.ok(r.value.every(x=>!/VOICEMAIL|HEARD:/.test(x)),r.id+' private marker')
 const number=find('num-settings')
 for(const field of ['voice_pair_version','created_at','provider','api_key_id'])assert.ok(!number.value.includes(field),'Read-only field '+field)
 const reuse=find('camp-reuse')
 assert.match(reuse.text,/SMS creation always generates a fresh ID/,reuse.id)
}
export function verifySpan(rule,ref,blob){
 const {start,end}=evidenceRef(ref)
 assert.ok(blob,rule+' unapproved source '+ref)
 assert.ok(start<=end&&end<=blob.text.trimEnd().split('\n').length,rule+' invalid span '+ref)
}
export function evidenceRef(ref){
 const [,repo='engine',file,start,end]=/^(?:(engine|dashboard|docs)@)?([^:]+):(\d+)(?:-(\d+))?$/.exec(ref)||[]
 assert.ok(file,'Invalid evidence '+ref);return {repo,file,start:+start,end:+(end||start)}
}
export function verifySources(data,repos,ref,{refresh=false}={}){
 const {index,features}=data,all=features.flatMap(f=>f.rules),before={},current={}
 const sourceIds=new Set(all.map(r=>r.sourceList).filter(Boolean))
 for(const repo of ['engine','dashboard','docs']){
  assert.ok(repos[repo],'Missing read-only '+repo+' checkout')
  before[repo]=readBlobs(repos[repo],index[repo],index.sources[repo])
  current[repo]=repo==='engine'&&ref!==index.engine?readBlobs(repos.engine,ref,index.sources.engine):before[repo]
 }
 const values=extract(file=>current.engine.get(file)?.text)
 assert.deepEqual([...sourceIds].sort(),Object.keys(values).sort(),'Each extracted contract must be represented')
 for(const r of all)for(const s of r.evidence){
  const {repo,file}=evidenceRef(s)
  verifySpan(r.id,s,before[repo].get(file))
 }
 for(const r of all.filter(r=>r.kind==='error')){
  const spans=r.evidence.map(evidenceRef).map(a=>current[a.repo].get(a.file).text.split('\n').slice(a.start-1,a.end).join('\n'))
  assert.ok(spans.some(s=>s.includes("'"+r.value+"'")||s.includes(r.value+':')),r.id+' missing machine code '+r.value)
 }
 if(!refresh)verifyValues(all,values)
 for(const repo of Object.keys(current))for(const [file,blob] of current[repo])if(blob.oid!==before[repo].get(file).oid){
  const affected=all.filter(r=>r.evidence.some(x=>evidenceRef(x).file===file)||r.sourceList)
  throw Error(file+' changed since '+index[repo]+'. Review evidence, consumer and pin before --write. Affected: '+affected.map(r=>r.id).join(', '))
 }
 if(refresh)for(const r of all)if(r.sourceList)r.value=values[r.sourceList]
 return values
}
