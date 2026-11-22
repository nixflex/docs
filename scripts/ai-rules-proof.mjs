import assert from 'node:assert/strict'
import {createHash} from 'node:crypto'
import fs from 'node:fs'
import path from 'node:path'
import {pathToFileURL} from 'node:url'
import {read,root,json} from './ai-rules-data.mjs'

export const digest=x=>createHash('sha256').update(x).digest('hex')
export function validateRecord({runs},rules,questions,readAnswers){
 assert.deepEqual(runs.map(r=>r.family).sort(),['claude','codex-chatgpt'])
 assert.equal(new Set(runs.map(r=>r.id)).size,2,'Separate run IDs required')
 assert.equal(new Set(runs.map(r=>r.answers)).size,2,'Separate raw answer files required')
 const pin=json('spec-source/ai-rules/index.json').engine
 for(const r of runs){
  assert.equal(r.engine,pin,'Record the reviewed engine pin')
  assert.ok(r.id&&r.model&&r.reviewer&&r.fresh===true,'Missing independent run or reviewer')
  assert.match(r.date,/^\d{4}-\d{2}-\d{2}$/);assert.equal(r.rulesSha256,digest(rules));assert.equal(r.questionsSha256,digest(questions))
  assert.match(r.answers,/^[a-zA-Z0-9_-]+\.md$/);const raw=readAnswers(r.answers)
  assert.ok(raw.length);assert.equal(r.answersSha256,digest(raw),'Raw answer digest mismatch')
  assert.deepEqual(r.scores.map(s=>s.question),Array.from({length:30},(_,i)=>i+1))
  assert.ok(r.scores.every(s=>s.pass===true),'30/30 required for each run')
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(process.argv[1]).href){
 const [mode,dest]=process.argv.slice(2);assert.ok(dest&&['--packet','--record'].includes(mode),'Supply --packet path or --record path')
 const p=path.resolve(dest),rel=path.relative(root,p);assert.ok(rel.startsWith('..'+path.sep)||path.isAbsolute(rel),'Keep proof files outside the public site')
 const rules=fs.readFileSync(path.join(root,'ai-rules.md')),q=read('tests/fixtures/ai-rules/questions.txt')
 assert.deepEqual([...q.matchAll(/^(\d+)\. /gm)].map(m=>+m[1]),Array.from({length:30},(_,i)=>i+1))
 if(mode==='--packet')fs.writeFileSync(p,Buffer.concat([rules,Buffer.from('\n'+q)]))
 else validateRecord(JSON.parse(fs.readFileSync(p)),rules,q,name=>fs.readFileSync(path.join(path.dirname(p),name)))
 console.log(mode+' verified; rules SHA-256 '+digest(rules))
}
