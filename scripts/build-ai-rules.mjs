import assert from 'node:assert/strict'
import fs from 'node:fs'
import path from 'node:path'
import {readFacts,validateShape,verifySources,root} from './ai-rules-data.mjs'
import {render,coverage,validateOutputs} from './ai-rules-render.mjs'
const args=process.argv.slice(2)
const flag=n=>args.includes(n),arg=n=>{const i=args.indexOf(n);if(i>=0){assert.ok(args[i+1]&&!args[i+1].startsWith('--'),n+' requires a value');return args[i+1]}}
const write=flag('--write');assert.notEqual(write,flag('--check'),'Choose --check or --write')
const data=readFacts(),{features,index}=data
validateShape(features,index)
if(flag('--engine')||flag('--ref')||flag('--dashboard')){
 const engine=arg('--engine'),ref=arg('--ref');assert.ok(engine&&ref,'Release check requires --engine and --ref')
 const dashboard=arg('--dashboard')||path.resolve(engine,'../b50b-dashboard-gcal-status')
 verifySources(data,{engine,dashboard,docs:root},ref,{refresh:write})
 if(write)for(const f of features)save('spec-source/ai-rules/features/'+f.feature+'.json',JSON.stringify(f,null,2)+'\n')
}
coverage(data)
const out=render(data);validateOutputs(out,data)
const dir=path.join(root,'snippets/ai-rules')
if(fs.existsSync(dir))for(const name of fs.readdirSync(dir))assert.ok(out.has('snippets/ai-rules/'+name),'Unmapped snippet: '+name+'. Review its removal.')
for(const file of index.generalPages)assert.ok(!fs.readFileSync(path.join(root,file+'.mdx'),'utf8').includes('NIXFLEX_RULES_START'),'Orphan rules box: '+file)
for(const [file,content] of out)save(file,content)
console.log((write?'Generated':'Verified')+' '+features.length+' features, '+out.size+' outputs; '+Buffer.byteLength(out.get('ai-rules.md'))+' bytes')
function save(file,content){
 const target=path.join(root,file),existing=fs.existsSync(target)?fs.readFileSync(target,'utf8'):null
 const originalPage=file.endsWith('.mdx')&&!file.startsWith('snippets/')
 if((originalPage?existing?.replaceAll('\r\n','\n'):existing)===content)return
 if(!write)throw Error('Stale output '+file+'. Review and run --write.')
 fs.mkdirSync(path.dirname(target),{recursive:true});fs.writeFileSync(target,content)
}
