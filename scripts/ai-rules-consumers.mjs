// Independent checks on the code paths that consume the public input.
import assert from 'node:assert/strict'
import {one,strings} from './ai-rules-source.mjs'
import {callBookingsSchema} from './c12-webhook-contracts.mjs'

export function checkCampaignConsumer(routes,creator){
 assert.match(routes,/createSmsCampaign\(\{[\s\S]*?reuse_campaign_id: req\.body\.reuse_campaign_id/)
 const body=one(creator,/async function createSmsCampaign\(params\) \{([\s\S]*?)\n\}/g)
 assert.match(body,/var campaignId = generateCampaignId\(\);/);assert.doesNotMatch(body,/params\.reuse_campaign_id/)
 assert.match(body,/createAtomic\(supabase, 'sms', params.api_key_id,\s*campaignId,/)
}
export function extraContracts(get,limits,bookingKeys){
 const routes=get('api/routes.js')
 checkCampaignConsumer(routes,get('outbound/features/smsCampaigns.js'))
 assert.deepEqual(bookingKeys,callBookingsSchema.required)
 const event=one(get('shared/features/callBookings.js'),/return \{event:'([^']+)',call_id:/g)
 assert.equal(event,callBookingsSchema.properties.event.const)
 const spelling=get('shared/features/bookingSpelling.js')
 const actions=[...one(spelling,/function applies\([^)]*\)\{([\s\S]*?)\n\}/g).matchAll(/action==='(\w+)'/g)].map(m=>m[1])
 assert.match(spelling,/action==='confirm_details'&&args.existing_booking!==true/)
 const template=get('shared/utils/replaceVariables.js'),validator=get('shared/features/singleContactPolicy.js')
 const pattern=one(validator,/if\(!\/\^(.+?)\$\/\.test\(key\)\)/g)
 assert.ok(template.includes('replace(/{{('+pattern+')}}/g'), 'Placeholder validator differs from substitution')
 const extraction=get('api/agents/extraction.js')
 const asNumber=(s,re)=>Number(one(s,re))
 const list=get('api/agents/list.js'),k=get('knowledge/sessions.js'),kbTest=get('knowledge/tester.js')
 assert.match(kbTest,/input\.text\.length<=limits\.messageChars/);assert.match(kbTest,/\.slice\(-limits\.messages\)/)
 assert.match(get('shared/utils/concurrencyGuard.js'),/Number\(r\.data\.max_concurrent\) > 0\) \? Number\(r\.data\.max_concurrent\) : DEFAULT_PER_KEY_CAP/)
 assert.match(get('api/auth.js'),/limitPerMinute > 0\) \? limitPerMinute : RL_DEFAULT_PER_MINUTE/)
 const numPatch=one(routes,/router\.patch\('\/phone-numbers\/:phoneNumber',([\s\S]+?)if \(!result\.ok\)/g)
 for(const term of ['numberMove','telnyx_public_key','voicePairBody: req.body','numberControls: req.body','apiKeyId:    req.developer.key_id'])assert.ok(numPatch.includes(term),'Number PATCH no longer hands off '+term)
 const signals=[['[WAIT]','outbound/call/conversation.js','[WAIT]'],['[END_CALL]','outbound/call/conversation.js','[END_CALL]'],['[TRANSFER','outbound/call/callManager.js','transferTarget'],['[SEND_SMS','outbound/features/midCallSms.js','SEND_SMS'],['[PRESS','outbound/call/conversation.js','[PRESS'],['[IVR]','outbound/call/conversation.js','[IVR]'],['[IVR_END]','outbound/call/conversation.js','[IVR_END]']]
 for(const [tag,file,witness] of signals)assert.ok(get(file).replaceAll('\\','').includes(witness),'Review handler '+file+' for '+tag)
 return {'outbound.placeholderGrammar':pattern,'bookings.newVoiceActions':actions,
  'knowledge.testBounds':{sessionsPerDay:asNumber(k,/recent\.n>=(\d+)/g),messageChars:limits.messageChars,historyMessages:limits.messages},
  'knowledge.packDefault':asNumber(get('knowledge/livePolicy.js'),/bounded\(env\.NXF_KB_PACK_TOKENS,(\d+),/g),
  'agents.extractionBounds':{fields:asNumber(extraction,/fields\.length > (\d+)/g),properties:strings(one(extraction,/!\[([^\]]+)\]\.includes\(k\)/g)),choices:asNumber(extraction,/field\.choices\.length > (\d+)/g)},
  'agents.listStatus':strings(one(list,/!\[([^\]]+)\]\.includes\(status\)/g))}
}
