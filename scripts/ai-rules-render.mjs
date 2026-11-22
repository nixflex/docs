import assert from 'node:assert/strict'
import {json,read,validateBoundary} from './ai-rules-data.mjs'
const origin='https://docs.nixflex.com'
const begin='{/* NIXFLEX_RULES_START */}',end='{/* NIXFLEX_RULES_END */}'
const flatten=v=>typeof v==='string'?[v]:Array.isArray(v)?v.flatMap(flatten):['groups','pages'].flatMap(k=>v[k]?flatten(v[k]):[])
const code=s=>String.fromCharCode(96)+s+String.fromCharCode(96)
export function coverage(data){
 const {index,features,publicOps}=data,plan=json('spec-source/c15-pages.json')
 validateBoundary(features,index,publicOps)
 const pages=Object.values(index.features).flatMap(f=>f.pages)
 assert.deepEqual([...pages,...index.generalPages].sort(),Object.keys(plan.metadata).sort(),'Unmapped, extra or duplicate page')
 assert.deepEqual(flatten(plan.navigation.tabs).sort(),Object.keys(plan.metadata).sort(),'Navigation coverage')
 for(const [slug,f] of Object.entries(index.features))for(const p of f.pages){
  if(p===index.guide)continue
  const m=read(p+'.mdx').match(/^openapi: "\/api-reference\/public.openapi.json ([A-Z]+) (.*?)"$/m)
  if(m)assert.ok(f.operations.includes(m[1]+' /v1'+m[2]),slug+' wrong endpoint owner '+p)
 }
}
export function patchPage(text,feature,links=''){
 const start=text.indexOf(begin),finish=text.indexOf(end)
 if(start!==-1||finish!==-1){
  assert.ok(start>=0&&finish>start&&text.indexOf(begin,start+1)<0&&text.indexOf(end,finish+1)<0,'Malformed rules block')
  text=text.slice(0,start)+text.slice(finish+end.length+1)
 }
 const head=text.match(/^---\n[\s\S]*?\n---\n/)
 assert.ok(head,'Page needs closed frontmatter')
 const block=begin+'\n\nimport NixflexRules from \'/snippets/ai-rules/'+feature+'.mdx\';\n\n<NixflexRules />\n'+links+'\n'+end+'\n'
 return head[0]+block+text.slice(head[0].length)
}
function fields(value){
 if(Array.isArray(value))return value.map(x=>code(x)).join(', ')
 if(value&&typeof value==='object')return Object.entries(value).map(([k,v])=>code(k)+' '+fields(v)).join(' · ')
 return typeof value==='number'?value.toLocaleString('en-US'):String(value)
}
const internalTables=new Set(['agents.input','agents.readColumns','numbers.readColumns','organisations.permissions'])
function context(features){
 const lookup=new Map(features.flatMap(f=>f.rules.map(r=>[r.id,{r,f}])))
 const get=id=>{assert.ok(lookup.has(id),'Unknown rule ID '+id);return lookup.get(id)}
 const fill=s=>s.replace(/\[\[([\w-]+)(?:\.(\w+))?\]\]/g,(_,id,key)=>{
  const v=get(id).r.value,n=key?v[key]:v;assert.ok(n!==undefined,id);return fields(n)
 })
 const describe=(id,options={})=>{
  const {r}=get(id)
  let s=fill(r.text)
  if(r.instead)s+=' '+fill(r.instead)
  if(options.why&&r.why)s+=' '+fill(r.why)
  if(r.sourceList&&!internalTables.has(r.sourceList)&&!r.text.includes('[['+id+']]'))s+=' '+fields(r.value)+'.'
  if(r.kind==='api')s+=' '+fields([r.value].flat())+'.'
  return s.split(/(\x60[^\x60]*\x60)/).map((part,i)=>i%2?part:part.replace(/t=<timestamp>,v1=<hex>|\{\{\w+\}\}|(?:GET|POST|DELETE|PUT|PATCH) \/v1\/[\w/{\}-]+/g,code)).join('')
 }
 return {get,describe}
}
const labels={fixed:'FIXED',unavailable:'NOT OFFERED → do this instead',change:'YOU CAN CHANGE'}
function box(f,index,c){
 const chosen=Object.keys(labels).map(kind=>{
  const r=f.feature==='phone-numbers'&&kind==='change'?c.get('num-settings').r:index.features[f.feature].short.map(id=>c.get(id).r).find(r=>r.kind===kind)||f.rules.find(r=>r.kind===kind)
  return '**'+labels[kind]+' · '+r.scope+'** '+c.describe(r.id)
 })
 const scope=f.rules.find(r=>r.kind==='does')
 chosen.push('**SCOPE · '+scope.scope+'** '+c.describe(scope.id))
 for(const id of index.extra[f.feature]||[])if(!chosen.some(s=>s.includes(c.get(id).r.text)))chosen.push(c.describe(id))
 chosen.push('[Read the compact AI rules]('+origin+'/ai-rules.md#'+f.feature+')')
 // Braces and angle brackets in wire examples are literal text in MDX.
 return chosen.join('\n\n').split(/(\x60[^\x60]*\x60)/).map((s,i)=>i%2?s:s.replaceAll('{','&#123;').replaceAll('}','&#125;').replaceAll('<','&lt;')).join('')+'\n'
}
function guide(facts,c){
 const {index,features}=facts
 let s='# Nixflex rules for AI\n\nReviewed '+index.date+' against production engine '+code(index.engine)+'. Refresh project copies from '+origin+'/ai-rules.md. Append the rules to your project instructions or attach the file to a chat that cannot read your workspace.\n\n'
 s+=index.lead.map(id=>c.describe(id)).join('\n\n')+'\n\n## Find a feature\n\n'
 s+=features.map(f=>'['+f.title+'](#'+f.feature+')').join(' · ')+'\n'
 for(const f of features){
  s+='\n<a id="'+f.feature+'"></a>\n\n## '+f.title+'\n\n'
  const rows=index.features[f.feature].short.map(id=>c.get(id).r),scope=f.rules.find(r=>r.kind==='does')
  for(const kind of Object.keys(labels)){
   const picked=rows.filter(r=>r.kind===kind);if(!picked.length)picked.push(f.rules.find(r=>r.kind===kind))
   s+='**'+labels[kind]+'** '+picked.map(r=>c.describe(r.id)).join(' ')+'\n\n'
  }
  s+='**SCOPE · '+scope.scope+'** '+c.describe(scope.id)+'\n'
  for(const r of rows.filter(r=>!Object.hasOwn(labels,r.kind)&&r.id!==scope.id))s+='\n'+c.describe(r.id)+'\n'
 }
 return s
}
function sharedPage(index,c,meta){
 let s='---\n'+Object.entries({...meta,canonical:origin+'/'+index.guide}).map(([k,v])=>k+': '+JSON.stringify(v)).join('\n')+'\n---\n\n'
 s+='## Choose what each customer needs\n\n| Scope | Decision |\n| --- | --- |\n'
 for(const id of index.guideRows){const {r,f}=c.get(id);s+='| ['+r.scope+']('+origin+'/ai-rules.md#'+f.feature+') | '+c.describe(id).replaceAll('|','\\|')+' |\n'}
 s+='\n## Two customers, one agent\n\nOak and Stone and Harbour Dental each have a business number. Assign both numbers to the same agent if they share knowledge, language and call settings. Map the signed-in customer to its business number on your server. Keep the credential there.\n\n'
 s+=c.describe('in-opening')+' Give Harbour Dental its own opening instruction in its number profile. Configure each business’s SMS and website profiles separately. '+c.describe('out-profile')+'\n\n'
 s+='When Oak and Stone calls back a customer, resolve its saved number and send that value in '+code('from_number')+'. On a verified booking event, match the business number to Oak and Stone before displaying the result. If Harbour Dental later needs private clinical knowledge, assign its number to a different agent. '+c.describe('bill-price')+'\n'
 return s
}
function llms(plan){
 let s='# Nixflex documentation\n\n- [Nixflex rules for AI]('+origin+'/ai-rules.md)\n- [Full documentation for AI]('+origin+'/llms-full.txt)\n- [Public OpenAPI]('+origin+'/api-reference/public.openapi.json)\n'
 const config=json('docs.json'),external=new Set()
 function visit(v){if(!v||typeof v!=='object')return;if(typeof v.href==='string'&&/^(https:|mailto:)/.test(v.href))external.add(v.href);Object.values(v).forEach(visit)}
 visit(config)
 for(const t of plan.navigation.tabs){s+='\n## '+t.tab+'\n\n';for(const p of flatten(t))s+='- ['+plan.metadata[p].title+']('+origin+'/'+(p==='index'?'':p)+'): '+plan.metadata[p].description+'\n'}
 for(const url of external)s+='\n- ['+(new URL(url).hostname||'Email support')+']('+url+')'
 return s.trimEnd()+'\n'
}
export function render(data){
 const {index,features}=data,c=context(features),plan=json('spec-source/c15-pages.json')
 const body=guide(data,c),out=new Map(['ai-rules.md','CLAUDE.md','AGENTS.md'].map(k=>[k,body]))
 out.set(index.downloadAsset,body)
 out.set('llms.txt',llms(plan))
 for(const f of features){
  out.set('snippets/ai-rules/'+f.feature+'.mdx',box(f,index,c))
  for(const p of index.features[f.feature].pages){
   const original=p===index.guide?sharedPage(index,c,plan.metadata[p]):read(p+'.mdx')
   let links=''
   if(['index','guides/developer/build-with-ai'].includes(p))links='\n[Read the rules]('+origin+'/ai-rules.md) · <a href="/downloads/nixflex-ai-rules.txt" download="AGENTS.md">Download AGENTS.md</a> · <a href="/downloads/nixflex-ai-rules.txt" download="CLAUDE.md">Download CLAUDE.md</a> · [Many customers on one shared agent](/'+index.guide+')\n'
   out.set(p+'.mdx',patchPage(original,f.feature,links))
  }
 }
 return out
}
export function validateOutputs(out,data){
 const s=out.get('ai-rules.md');assert.equal(s,out.get(data.index.downloadAsset),'Static download differs');assert.equal(s,out.get('CLAUDE.md'),'CLAUDE.md differs');assert.equal(s,out.get('AGENTS.md'),'AGENTS.md differs')
 assert.ok(Buffer.byteLength(s)<=28*1024,'Rules exceed 28 KiB: '+Buffer.byteLength(s));assert.ok(s.endsWith('\n'))
 const redirectRows=json('docs.json').redirects,asset='https://docs.nixflex.com/'+data.index.downloadAsset
 for(const name of ['ai-rules','AGENTS','CLAUDE'])assert.ok(redirectRows.some(r=>r.source==='/'+name&&r.destination===asset),'Missing raw download redirect '+name)
 assert.equal(out.get('llms.txt').match(/\]\(([^)]+)\)/)?.[1],origin+'/ai-rules.md','First listing')
 for(const [f,rows] of Object.entries(data.index.features)){
  assert.ok(s.includes('<a id="'+f+'"></a>'),f)
  for(const p of rows.pages){const page=out.get(p+'.mdx');assert.ok(page?.includes(begin)&&page.includes('/'+f+'.mdx')&&page.indexOf(begin)===page.lastIndexOf(begin),p)}
 }
}
