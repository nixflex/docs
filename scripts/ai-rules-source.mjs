// Read immutable, explicitly approved source blobs. Never import engine modules.
import assert from 'node:assert/strict'
import {execFileSync} from 'node:child_process'
import {isDeepStrictEqual} from 'node:util'
import {extraContracts} from './ai-rules-consumers.mjs'
import {extractMore} from './ai-rules-contracts.mjs'

export function readBlobs(repo,ref,allowed){
 assert.match(ref,/^[a-f0-9]{40}$/,'Supply the full reviewed commit')
 const git=(args,opts={})=>execFileSync('git',args,{cwd:repo,maxBuffer:64*1024*1024,...opts})
 assert.equal(git(['rev-parse',ref+'^{commit}'],{encoding:'utf8'}).trim(),ref)
 for(const p of allowed)assert.match(p,/^(?!.*\.\.)(?:[A-Za-z0-9_-]+\/)*[A-Za-z0-9_.-]+\.(?:js|jsx|json|sql|mdx|mjs)$/,'Unapproved source path')
 const buf=git(['cat-file','--batch'],{input:allowed.map(p=>ref+':'+p+'\n').join('')})
 const blobs=new Map();let pos=0
 for(const p of allowed){
  const end=buf.indexOf(10,pos),header=buf.toString('ascii',pos,end)
  const m=/^([a-f0-9]{40}) blob (\d+)$/.exec(header)
  assert.ok(m,'Missing source blob '+p);pos=end+1
  const bytes=Number(m[2]);blobs.set(p,{oid:m[1],text:buf.toString('utf8',pos,pos+bytes).replaceAll('\r\n','\n')});pos+=bytes+1
 }
 return blobs
}
export function readTags(js){
 const span=one(js,/Available tags:([\s\S]*?)WHO CONTROLS ACTIONS:/g)
 const tags=[...span.matchAll(/\[([^\[\]]+)\]/g)].map(m=>m[0])
 assert.ok(tags.length&&new Set(tags).size===tags.length,'Review action tag declaration')
 return tags
}
export function one(s,pattern){
 const matches=[...s.matchAll(new RegExp(pattern.source,[...new Set(pattern.flags+'g')].join('')))]
 assert.equal(matches.length,1,'Expected one matched declaration: '+pattern)
 return matches[0][1]
}
export function strings(s){
 const a=s.replace(/\/\/[^\n]*/g,'').trim().replace(/,\s*$/,'').split(',').map(v=>v.trim())
 return a.map(v=>one(v,/^'([^'\\]+)'$/g))
}
const subset=(o,keys)=>Object.fromEntries(keys.map(k=>{assert.ok(Object.hasOwn(o,k),k);return [k,o[k]]}))
export function extract(read){
 const get=p=>{const s=read(p);assert.equal(typeof s,'string','Missing source '+p);return s}
 const variables=get('shared/utils/callVariables.js'),policy=get('shared/features/singleContactPolicy.js')
 const keys=strings(one(variables,/var SYSTEM_VAR_KEYS = \[([\s\S]*?)\];/g))
 const exclusion=one(policy,/SYSTEM_VAR_KEYS\.filter\(k=>k!=='(\w+)'\)/g)
 const assigned=[...variables.split("if (typeof o.callerHistory")[0].matchAll(/^\s*vars\.(\w+)\s*=/gm)].map(m=>m[1])
 const automatic=keys.filter(k=>k!==exclusion);assert.deepEqual([...automatic].sort(),assigned.sort(),'Review outbound variable assignments')
 const imp=one(get('shared/features/numberImportInput.js'),/const fields=\{([^}]+)\}/g)
 const inventory=one(get('shared/features/phoneNumberImport.js'),/var UPDATABLE_FIELDS = \[([\s\S]*?)\];/g).replace(/\/\/[^\n]*/g,'')
 const fields=inventory.match(/\{[^{}]+\}/g)||[],names=fields.map(f=>one(f,/\bcol:\s*'(\w+)'/g))
 assert.match(inventory,/\.\.\.require\('\.\/numberControls'\)\.fields/)
 assert.equal(inventory.replace(/\.\.\.require\('\.\/numberControls'\)\.fields|\{[^{}]+\}|[\s,]/g,''),'','Review new number field expression')
 const max=Object.fromEntries(fields.flatMap((f,i)=>f.includes('max:')?[[names[i],Number(one(f,/\bmax:\s*(\d+)[ ,}]/g))]]:[]))
 const controls=one(get('shared/features/numberControls.js'),/const fields=\[([\s\S]*?)\]\s*\.map/g).match(/\[[^\[\]]+\]/g)
 const k=get('knowledge/policy.js'),scope=get('knowledge/scopes.js')
 const limits=Object.fromEntries([...one(k,/const limits = Object.freeze\(\{([\s\S]*?)\}\);/g).matchAll(/\b(\w+):\s*(\d+(?:\s*\*\s*\d+)*)(?=\s*[,} ]|$)/g)].map(m=>[m[1],m[2].split('*').reduce((a,n)=>a*Number(n),1)]))
 const importLimit=Number(one(get('shared/features/numberImportInput.js'),/customPrompt\.length\s*>\s*(\d+)/g))
 assert.equal(max.custom_prompt,importLimit,'Number import and PATCH custom_prompt limits differ')
 const more=extractMore(get)
 return {
  'outbound.publicTags':readTags(get('outbound/providers/outboundClaude.js')),
  'inbound.publicTags':readTags(get('inbound/providers/claude.js')),
  'outbound.systemVariables':automatic,
  'outbound.purposeMin':Number(one(get('shared/data/agentPrompt.js'),/promptOverride\.trim\(\)\.length >= (\d+)/g)),
  'numbers.importFields':imp.split(',').map(pair=>one(pair,/^\s*\w+:\s*'(\w+)'\s*$/g)),
  'numbers.updateFields':names,'numbers.textLimits':max,
  'numbers.controlFields':controls.map(pair=>strings(pair.slice(1,-1))[1]),
  'numbers.voicePairFields':strings(one(get('shared/tts/voicePair.js'),/const FIELDS = \[([^\]]+)\]/g)),
  'knowledge.channels':strings(one(k,/version: '[^']+', channels: \[([^\]]+)\]/g)),
  'knowledge.matchAndFallback':{match:strings(one(scope,/\[([^\]]+)\]\.includes\(out\.match\)/g)),defaultMatch:one(k,/match: '(\w+)'/g),notFoundMaxChars:Number(one(scope,/out.not_found.length<=(\d+)/g))},
  'knowledge.baseLimits':subset(limits,['sources','kbTokens','topics']),'knowledge.sourceLimits':subset(limits,['fileBytes','sourceTokens','pages']),
  'knowledge.accountBases':limits.bases,...more,...extraContracts(get,limits,more['webhooks.bookingKeys'])
 }
}
export function verifyValues(rules,values){
 for(const rule of rules.filter(r=>r.sourceList)){
  if(!Object.hasOwn(values,rule.sourceList)||!isDeepStrictEqual(rule.value,values[rule.sourceList]))
   throw Error(rule.id+' / '+rule.sourceList+' differs: reviewed '+JSON.stringify(rule.value)+'; source '+JSON.stringify(values[rule.sourceList])+'. Review the engine change before --write.')
 }
}
