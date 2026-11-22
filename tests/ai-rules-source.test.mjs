import test from 'node:test'
import assert from 'node:assert/strict'
import {readFacts,validateShape,validateBoundary,verifySpan} from '../scripts/ai-rules-data.mjs'
import {checkCampaignConsumer} from '../scripts/ai-rules-consumers.mjs'
import {verifyValues,readTags} from '../scripts/ai-rules-source.mjs'
test('DOC-AI-SHAPE-01 requires scoped, evidenced rules and reasons',()=>{
 const {features,index}=readFacts()
 validateShape(features,index)
 const duplicate=structuredClone(features);duplicate[1].rules[0].id=duplicate[0].rules[0].id
 assert.throws(()=>validateShape(duplicate,index),/Duplicate/)
 assert.throws(()=>verifySpan('example','api/example.js:2-6',{text:'one\ntwo\n'}),/invalid span/)
 for(const field of ['scope','why','evidence','instead']){
  const copy=structuredClone(features);delete copy[0].rules.find(r=>r.kind===(field==='instead'?'unavailable':'fixed'))[field]
  assert.throws(()=>validateShape(copy,index),new RegExp(field))
 }
})
test('DOC-AI-STALE-01 detects changed limits, built-ins and action declarations',()=>{
 const {features}=readFacts()
 for(const [name,key,changed] of [['phone-numbers','numbers.textLimits',{custom_prompt:12000}],['outbound-actions-variables','outbound.systemVariables',[]],['outbound-actions-variables','outbound.publicTags',['[NEW_ACTION]']]]){
  const r=features.find(f=>f.feature===name).rules.find(r=>r.sourceList===key)
  assert.throws(()=>verifyValues([r],{[key]:changed}),new RegExp(r.id))
 }
 const section="Available tags:\\n' + '[WAIT]\\n[EXTRA]\\n' + 'WHO CONTROLS ACTIONS:"
 assert.deepEqual(readTags(section),['[WAIT]','[EXTRA]'])
})
test('DOC-AI-BOUNDARY-01 refuses private APIs, private tags and unsupported writes',()=>{
 const {features,index,publicOps}=readFacts()
 validateBoundary(features,index,publicOps)
 for(const change of [r=>r.rules.find(x=>x.kind==='api').value='GET /api/private',
 r=>r.rules.find(x=>x.id==='act-tags').value.push('[VOICEMAIL]')]){
  const copy=structuredClone(features);change(copy.find(f=>f.feature==='outbound-actions-variables'));assert.throws(()=>validateBoundary(copy,index,publicOps))
 }
 const copy=structuredClone(features);copy.find(f=>f.feature==='phone-numbers').rules.find(r=>r.id==='num-settings').value.push('created_at')
 assert.throws(()=>validateBoundary(copy,index,publicOps),/Read-only/)
 const route='createSmsCampaign({reuse_campaign_id: req.body.reuse_campaign_id})'
 const creator="async function createSmsCampaign(params) {\nvar campaignId = generateCampaignId();\ncreateAtomic(supabase, 'sms', params.api_key_id, campaignId, campaignRow, recipientRows);\n}"
 checkCampaignConsumer(route,creator)
 assert.throws(()=>checkCampaignConsumer(route,creator.replace('generateCampaignId()','params.reuse_campaign_id || generateCampaignId()')))
})
