// Finite public contracts. Accept only the literal grammar recognised here.
import assert from 'node:assert/strict'
import {one,strings} from './ai-rules-source.mjs'
const num=(s,re)=>Number(one(s,re))
function object(s){
 const json=s.replace(/([,{]\s*)([a-z_]\w*)\s*:/g,'$1"$2":').replace(/'([a-z0-9_]+)'/g,'"$1"')
 return JSON.parse(json)
}
const wordList=(s,key)=>one(s,new RegExp(key+" = (?:new Set\\()?\\('([^']+)'\\)\\.split","g")).split(' ')
export function extractMore(get){
 const a=get('api/agents/input.js'),tables=k=>object(one(a,new RegExp('const '+k+' = (\\{[\\s\\S]*?\\});','g')))
 const roles=JSON.parse(get('shared/organisations/policy.json'));delete roles.version
 const p=get('shared/features/numberReadProjection.js'),sched=get('outbound/features/campaignSchedule.js'),history=get('api/calls/historyQuery.js')
 const booking=get('shared/features/callBookings.js')
 const keys=one(booking,/return \{(event:'call\.bookings'[\s\S]*?)\};/g).split(/,(?=\s*[a-z_]+:)/).map(x=>one(x,/^\s*([a-z_]+):/g))
 const columns=s=>strings(s.replace(/\/\/[^\n]*/g,''))
 const list=columns(one(p,/const list = \[([\s\S]*?)\];/g)), omit=one(p,/list.filter\(k => k !== '(\w+)'\)/g)
 const details=columns(one(p,/\.concat\(\[([\s\S]*?)\]\)/g))
 const filters=object(one(history,/Object\.entries\((\{ direction: [\s\S]*?\})\)/g))
 const groups={booleans:wordList(a,'booleanFields'),text:tables('textLimits'),nullable:wordList(a,'nullable'),ranges:tables('ranges'),choices:tables('enums'),special:strings(one(a,/const special = \[([^\]]+)\]/g))}
 assert.match(a,/const known = new Set\(\[\.\.\.booleanFields, \.\.\.Object.keys\(textLimits\), \.\.\.Object.keys\(ranges\), \.\.\.Object.keys\(enums\), \.\.\.special\]\)/)
 return {
  'agents.input':groups,'agents.readColumns':columns(one(get('api/agentFields.js'),/var AGENT_RESPONSE_COLUMNS = \[([\s\S]*?)\]/g)),
  'numbers.readColumns':{list,detail:[...list.filter(x=>x!==omit),...details]},
  'agents.keytermMax':num(get('api/agents/keyterms.js'),/const limit=(\d+),/g),
  'agents.extractionTypes':strings(one(get('api/agents/extraction.js'),/\[([^\][\n]+)\]\.includes\(field.type\)/g)),
  'organisations.permissions':roles,
  'contact.stopWords':strings(one(get('shared/features/smsOptOut.js'),/const WORDS=new Set\(\[([\s\S]*?)\]\)/g)),
  'contact.holds':strings(one(get('shared/features/campaignContact.js'),/const HOLDS=new Set\(\[([\s\S]*?)\]\)/g)),
  'campaigns.schedule':{days:strings(one(sched,/var DAYS = \[([^\]]+)\]/g)),min:num(sched,/v >= (\d+) && v <=/g),max:num(sched,/v >= \d+ && v <= (\d+)/g)},
  'history.filters':filters,'webhooks.bookingKeys':keys,'bookings.googleSettings':strings(one(get('shared/integrations/googleCalendarSettings.js'),/k=>!\[([^\]]+)\]\.includes\(k\)/g)),
  'retention.days':JSON.parse(one(get('api/retention.js'),/days=Object.freeze\((\[[0-9,]+\])\)/g)),
  'limits.concurrent':num(get('shared/utils/concurrencyGuard.js'),/var DEFAULT_PER_KEY_CAP = (\d+);/g),
  'limits.requestsPerMinute':num(get('api/auth.js'),/var RL_DEFAULT_PER_MINUTE = (\d+);/g)
 }
}
