import test from 'node:test'
import assert from 'node:assert/strict'
import {readFacts,read} from '../scripts/ai-rules-data.mjs'
import {render,coverage,validateOutputs,patchPage} from '../scripts/ai-rules-render.mjs'
import {validateRecord,digest} from '../scripts/ai-rules-proof.mjs'

test('DOC-AI-COVERAGE-01 maps public operations and feature pages exactly once',()=>{
 const data=readFacts();coverage(data)
 for(const edit of [i=>i.features.organisations.operations.pop(),i=>i.features.organisations.pages.pop(),i=>i.features.sms.pages.push(i.features.organisations.pages[0])]){
  const c=structuredClone(data);edit(c.index);assert.throws(()=>coverage(c))
 }
})
test('DOC-AI-RENDER-01 checks first listing, exact bytes, scope boxes and deterministic rendering',()=>{
 const data=readFacts(),out=render(data)
 validateOutputs(out,data);assert.deepEqual(render(data),out)
 const pricing='Agents are unlimited. There is no fee per agent. Customers pay only for usage (minutes and texts).'
 for(const file of ['ai-rules.md','AGENTS.md','CLAUDE.md','snippets/ai-rules/agents-voices.mdx','snippets/ai-rules/billing-usage.mdx',data.index.guide+'.mdx'])assert.ok(out.get(file).includes(pricing),file)
 for(const f of data.features){
  const snippet='snippets/ai-rules/'+f.feature+'.mdx',box=out.get(snippet)
  for(const label of ['FIXED','NOT OFFERED','YOU CAN CHANGE','SCOPE'])assert.ok(box.includes(label),snippet+' '+label)
  assert.ok(data.index.features[f.feature].pages.length&&data.index.features[f.feature].pages.every(p=>out.get(p+'.mdx').includes('/'+snippet)))
 }
 for(const file of ['snippets/ai-rules/agents-voices.mdx','snippets/ai-rules/phone-numbers.mdx','snippets/ai-rules/inbound-calls.mdx'])assert.match(out.get(file),/Start every call with: Thank you for calling Oak and Stone/)
 const docs=out.get('ai-rules.md')
 for(const term of ['POST /v1/phone-numbers','DELETE /v1/calls/{id}','recipients[].variables','caller_history','missing_voice_details','sms_deleted=0'])assert.ok(docs.includes(term),term)
 for(const name of ['llms.txt','AGENTS.md','CLAUDE.md','ai-rules.md']){
  const bad=new Map(out);bad.set(name,name==='llms.txt'?'[Another listing](https://example.com)\n'+bad.get(name):bad.get(name)+'x')
  assert.throws(()=>validateOutputs(bad,data))
 }
 const text='---\ntitle: Example\n---\n\nExisting body.\n',patched=patchPage(text,'knowledge')
 assert.equal(patchPage(patched,'knowledge'),patched);assert.ok(patched.endsWith('\n\nExisting body.\n'))
 const bad=structuredClone(data);bad.index.guideRows.push('absent-rule');assert.throws(()=>render(bad))
})
test('DOC-AI-PROOF-01 accepts only two complete independent passes against the same packet',()=>{
 const guide=read('ai-rules.md'),questions=read('tests/fixtures/ai-rules/questions.txt')
 const runs=['claude','codex-chatgpt'].map((family,i)=>({family,engine:readFacts().index.engine,id:'fixture-'+i,model:'explicit fixture',date:'2026-11-22',fresh:true,reviewer:'fixture reviewer',rulesSha256:digest(guide),questionsSha256:digest(questions),answers:'answers-'+i+'.md',answersSha256:digest('Fixture response '+i),scores:Array.from({length:30},(_,n)=>({question:n+1,pass:true}))}))
 const load=name=>'Fixture response '+Number(name.at(-4))
 validateRecord({runs},guide,questions,load)
 for(const edit of [r=>r[0].scores[29].pass=false,r=>r[1].id=r[0].id,r=>r[0].rulesSha256='wrong',r=>r[0].engine='wrong',r=>r[1].family='claude',r=>r[0].answersSha256='wrong',r=>r[0].scores.pop()]){
  const c=structuredClone(runs);edit(c);assert.throws(()=>validateRecord({runs:c},guide,questions,load))
 }
})
