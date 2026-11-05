// Apply the permanent C13 editorial plan after the contract builders, before the site manifest.
import fs from 'node:fs';
import path from 'node:path';
import {c13Errors,requestIdExample,bookingReadExamples,requestReadExamples} from './c13-contracts.mjs';
const root=path.resolve(import.meta.dirname,'..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const write=(p,s)=>{if(!fs.existsSync(path.join(root,p))||read(p)!==s)fs.writeFileSync(path.join(root,p),s);};
const json=p=>JSON.parse(read(p)),plan=json('spec-source/c13-pages.json'),spec=json('api-reference/public.openapi.json');
const esc=s=>String(s).replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;');
const cells=s=>s.replaceAll('|','&#124;').replaceAll('\n',' ');
const table=(heads,rows)=>'| '+heads.join(' | ')+' |\n| '+heads.map(()=>'---').join(' | ')+' |\n'+rows.map(r=>'| '+r.map(cells).join(' | ')+' |').join('\n');
export const facts=rows=>'<div className="nxf-facts">\n'+rows.map(([a,b])=>'  <div><small>'+esc(a)+'</small><strong>'+esc(b)+'</strong></div>').join('\n')+'\n</div>';
export const panel=points=>'<div className="nxf-important">\n\n**The important part**\n\n'+points.map(p=>'- '+p).join('\n')+'\n\n</div>';
export const audience=(business,developer)=>'<div className="nxf-audience">\n\n[Business guide](/'+business+') · [Developer guide](/'+developer+') · [Glossary](/guides/glossary)\n\n</div>';
const setMeta=(text,values)=>{const parts=text.split(/^---\s*$/m);for(const [key,value]of Object.entries(values)){const line=key+': '+JSON.stringify(value),re=new RegExp('^'+key+':.*$','m');parts[1]=re.test(parts[1])?parts[1].replace(re,line):parts[1].trimEnd()+'\n'+line+'\n';}return parts.join('---');};
const replaceSection=(s,heading,body)=>s.replace(new RegExp('(^## '+heading+'\\n)[\\s\\S]*?(?=^## |$(?![\\s\\S]))','m'),'$1\n'+body.trim()+'\n\n');
const code=(lang,label,body)=>'```'+lang+' '+label+'\n'+body+'\n```';
const specific={
 invalid_return_url:'Use HTTPS or an approved app scheme; remove forbidden URL parts.',invalid_settings:'Send only supported setting fields, using their documented types.',invalid_timezone:'Supply a valid IANA time zone such as Europe/London.',invalid_hours:'Send a valid working_hours object containing all seven days.',invalid_slot_minutes:'Use an allowed whole-number slot length from the request contract.',invalid_calendar_id:'Supply a valid calendar ID accessible to the connected account.',invalid_send_invites:'Send the JSON boolean true or false, or omit the field to keep its saved value.',
 already_connected:'Read the connection status; do not create another consent flow for an already connected number.',booking_provider_conflict:'Choose one provider and disconnect the unwanted connection deliberately.',agent_not_assigned:'Assign an eligible owned agent to this number before connecting the calendar.',expired_link:'Start a fresh consent flow after checking the current connection.',not_connected:'Connect this number before changing calendar settings.',not_configured:'Ask the operator to complete the required service configuration.',guard_unavailable:'Wait for the access check to recover; do not bypass it.',
 invalid_credentials:'Supply exactly one complete supported credential pair through private secret handling.',carrier_mismatch:'Use credentials for this number\u2019s existing carrier; this endpoint does not migrate it.',number_operation_pending:'Wait for the existing number operation to settle and read the number again.',number_release_pending:'Wait for removal/release work to settle; do not overwrite credentials during it.',credential_save_pending:'The carrier change is confirmed. Deliberately retry identical details only to finish the local save.',carrier_outcome_unknown:'Reconcile the existing carrier change; do not submit different credentials or assume no change occurred.',
 call_bookings_unavailable:'Retry the read with bounded backoff. Keep the result unavailable; never display none.',outbound_request_unavailable:'Keep the saved UUID and retry this status read with bounded backoff. Do not launch another call.',
};
const meanings={invalid_return_url:'The return destination is not allowed.',invalid_settings:'The settings object contains unsupported fields or values.',invalid_timezone:'The time zone is invalid.',invalid_hours:'The weekly hours shape or a time interval is invalid.',invalid_slot_minutes:'The slot length is outside the supported values.',invalid_calendar_id:'The calendar identifier is invalid.',invalid_send_invites:'The invitation switch is not a boolean.',already_connected:'This number already has a calendar connection.',booking_provider_conflict:'Another booking provider is active.',agent_not_assigned:'The number has no eligible agent.',expired_link:'The consent or connection state is no longer current.',not_connected:'The number has no active calendar connection.',not_configured:'The required service configuration is unavailable.',guard_unavailable:'The access check could not be completed.',invalid_credentials:'The supplied credential pair is invalid.',carrier_mismatch:'The credentials do not match the existing number carrier.',number_operation_pending:'Another number operation is unfinished.',number_release_pending:'Number removal or release is unfinished.',credential_save_pending:'The carrier change succeeded; its local save is unfinished.',carrier_outcome_unknown:'The carrier change outcome cannot be confirmed.',permission_denied:'This actor cannot perform the operation.',account_unavailable:'The account is unavailable for this operation.',account_disabled:'The account cannot access this operation.',number_not_found:'The number is absent or inaccessible to this account.',number_not_in_account:'The number does not belong to this account.',rate_limit_exceeded:'The request limit was reached.',calendar_unavailable:'The calendar operation or status check could not be completed.',carrier_unavailable:'The carrier could not complete the request.',credential_update_unavailable:'The credential change could not be confirmed.',unauthorized:'The credential is missing or invalid.',invalid_phone_format:'The phone number is not valid E.164.',invalid_period:'The requested period is invalid.',invalid_query:'The query contains an invalid, unknown or duplicate field.',usage_unavailable:'Usage could not be read; it is not zero usage.'};
function action(status,method,codes){
 const targeted=codes.map(c=>specific[c]).filter(Boolean);if(targeted.length)return [...new Set(targeted)].join(' ');
 if(status==='400'||status==='422')return 'Correct the named field or query using the request table before trying again.';
 if(status==='401')return 'Check the full account credential and API host privately; stop the retry loop.';
 if(status==='403')return 'Resolve the account or role restriction through an authorised person.';
 if(status==='404')return 'Check the exact owned identifier and current resource state; do not probe another account.';
 if(status==='409')return 'Read current state and resolve the named conflict before another deliberate action.';
 if(status==='429')return method==='GET'?'Wait at least Retry-After and use a bounded read retry.':'Stop automatic retries; wait for the limit and reconcile state before a deliberate action.';
 return method==='GET'?'Keep the last result unknown and use bounded read retries; do not replace it with empty data.':'Treat the outcome as uncertain and read the affected resource before another deliberate change.';
}
function manualErrors(op,method){return table(['Status / code','What it means','What to do'],Object.entries(op.responses).filter(([s])=>Number(s)>=400).flatMap(([status,r])=>{
 const codes=[...new Set(r.description.match(/\b[a-z]+(?:_[a-z]+)+\b|\bunauthorized\b/g)||[])].filter(c=>!['safe_to_retry','not_sent'].includes(c));
 return codes.length?codes.map(c=>[status+' · `'+c+'`',meanings[c]||r.description.replace(/\. Standard error envelope;.*$/,'').replace(/^[a-z_]+: /,''),action(status,method,[c])]):[[status,r.description,action(status,method,[])]];
}));}
const journalSection=`Save one UUID before the first request for an intended call. Persist it with the request payload so a process restart cannot accidentally create a new intent. Supply it as the JSON field \`request_id\`, not an Idempotency-Key header.

| Result | What it proves | Next action |
| --- | --- | --- |
| 201 initiated | A call was accepted; completion is still unknown. | Save call_id and request_id; read the call. |
| 200 replayed:true | This UUID already has an accepted call. | Use the same call_id; no second dispatch occurred. |
| 409 outbound_request_pending / outbound_request_unknown | The existing intent cannot be launched again. | Keep the UUID and read request status. |
| 409 request_id_conflict | The same UUID was used with changed input. | Reconcile the original payload; do not automatically replace the UUID. |
| 503 with details.safe_to_retry:false | The journal or launch outcome is uncertain. | Keep the UUID and use bounded status reads. |

A 201 can also include \`request_status:"unconfirmed"\` and \`safe_to_retry:false\`: the call ID is known even though the final journal acknowledgement was lost. Never redial it. A new UUID is a new explicit call intent. Requests without request_id retain their existing behaviour and have no launch replay protection.

Read [outbound request status](/api-reference/calls/get-outbound-request). A 404 or an empty history page does not prove that an uncertain call was never placed.`;
for(const row of plan.api){
 let s=read(row.source||row.slug+'.mdx').replace(/\r\n/g,'\n').replace(/<style>\{`[\s\S]*?`\}<\/style>\s*/g,'');
 s=setMeta(s,{title:row.title,sidebarTitle:row.sidebarTitle,description:row.description,canonical:'https://docs.nixflex.com/'+row.slug});
 const split=s.split(/^---\s*$/m),body=split.slice(2).join('---').trim(),firstHeading=body.indexOf('\n## ');
 let pre=firstHeading<0?body:body.slice(0,firstHeading),rest=firstHeading<0?'':body.slice(firstHeading).trimStart();
 // Preserve supplementary preamble paragraphs but replace the old lead and page-local style.
 const paragraphs=pre.split(/\n\s*\n/);let extra=(row.source&&!row.method?paragraphs:paragraphs.slice(1)).join('\n\n');
 if(row.slug==='api-reference/calls/client-safety')extra='These examples describe reviewed kit candidates, not a claim that the same methods are in your installed client. Verify [release status](/sdks/ecosystem) before using them.';
 const op=row.method?spec.paths[row.path][row.method.toLowerCase()]:null;
 const factRows=op?[['Method',row.method],['Success',Object.keys(op.responses).filter(s=>/^2\d\d$/.test(s)).join(' / ')],['Scope',row.slug==='api-reference/account/create-key'?'New API account':'Owning account']]:[['Guide','API reference'],['Topic',row.sidebarTitle]];
 s=split.slice(0,2).join('---')+'---\n\n'+row.lead+'\n\n'+facts(factRows)+'\n\n'+panel(row.important)+'\n\n'+audience(row.business,row.developer)+'\n\n'+(row.introDetails?row.introDetails+'\n\n':'')+(extra?extra+'\n\n':'')+rest;
 if(op){
  if(/\| Status \| Meaning \|/.test(s))s=s.replace(/\| Status \| Meaning \|\n\|[^\n]+\n(?:\|[^\n]+\n?)+/,manualErrors(op,row.method)+'\n');
  // Keep the endpoint's eight established anchors. Related links are chosen by task.
  const siblings=plan.api.filter(p=>p.developer===row.developer&&p.slug!==row.slug&&p.method);
  const next=siblings.slice(0,2).map(p=>'- ['+p.title+'](/'+p.slug+')');
  if(!next.length)next.push('- [Retry rules](/api-reference/retries)');
  s=replaceSection(s,'Related endpoints',[...next,'- [Errors and recovery](/api-reference/errors#error-envelope)'].join('\n'));
 }
 if(row.slug==='api-reference/introduction')s=s.replace('all 147 documented public operations','all 149 documented public operations');
 if(['api-reference/idempotency','api-reference/retries','api-reference/calls/client-safety'].includes(row.slug)){
  s=s.replace('There is no general replay promise for agent creation, outbound calls, SMS, campaigns or key rotation.','Agent creation, outbound calls without request_id, SMS, campaigns and key rotation have no general replay promise.');
  s+='\n\n## Reconcile an outbound request UUID\n\n'+journalSection+'\n';
 }
 if(row.slug==='api-reference/call-bookings')s+='\n\n## Read a retained booking result\n\nUse [GET call booking results](/api-reference/calls/get-bookings) when reconciling a missed event. The read distinguishes ready, none, processing, deleted and unavailable. Only ready includes this public event projection as result; it is data without a delivery signature. An absent event or a completed call alone does not prove there were no bookings.\n';
 if(row.slug==='api-reference/errors'){
  s=s.replace('## Response shape','<span id="error-envelope"></span>\n\n## Response shape');
  for(const [c,fix]of Object.entries(specific))s=s.replace(new RegExp('(\\| <span id="'+c+'">[^\\n]+?\\| \\d+ \\| )[^\\n]*?( \\|)','g'),'$1'+fix+'$2');
  const grouped=new Map();
  for(const [status,c,meaning,fix]of c13Errors){if(new RegExp('id="'+c+'"').test(s))continue;const prior=grouped.get(c);if(prior){prior[1]+=' / '+status;prior[2]+=' '+meaning;prior[3]+=' '+fix;}else grouped.set(c,['<span id="'+c+'">'+c+'</span>',String(status),meaning,fix]);}
  s+='\n\n## Call request and booking read errors\n\n'+table(['Code','Status','What it means','What to do'],[...grouped.values()])+'\n';
 }
 if(row.slug==='api-reference/calls/get-bookings'){
  s=replaceSection(s,'Retry and idempotency','This read does not place a call or change a booking. Retry temporary read failures with bounded backoff. Refresh processing only within a chosen time limit; preserve deleted and unavailable as distinct results. This endpoint is not paginated.');
  s=replaceSection(s,'Response fields',`\`200 OK\` returns \`call_id\`, \`state\` and \`result\`. The response is \`Cache-Control: no-store\`.

${table(['State','Result','What to show'],[['ready','Confirmed object','Show timeline and final from the retained result of this call.'],['none','null','No successful mutation, established by complete booking evidence.'],['processing','null','Tracked call or post-call work is unfinished; offer a bounded refresh.'],['deleted','null','Content was removed, immediately scheduled for deletion, expired or is being purged.'],['unavailable','null','Old, partial or unconfirmed evidence; no definitive booking result.']])}

For ready, result has the complete [call.bookings payload](/api-reference/call-bookings#payload). Count active rows in final; timeline counts actions. This is not the current calendar inventory. Do not infer none from a transcript, an empty legacy array or an unsuccessful call.`);
  s=replaceSection(s,'Example response','<ResponseExample>\n\n'+Object.entries(bookingReadExamples).map(([name,e])=>code('json',name,JSON.stringify(e.value,null,2))).join('\n\n')+'\n\n</ResponseExample>');
 }
 if(row.slug==='api-reference/calls/get-outbound-request'){
  s=replaceSection(s,'Retry and idempotency','This read does not reserve an intent, place a call or charge the account. Retry temporary read failures with bounded backoff while keeping the saved UUID. A failed read or 404 is not permission to launch with a new UUID. This endpoint is not paginated.');
  s=replaceSection(s,'Response fields',`\`200 OK\` returns \`request_id\`, \`state\`, \`call_id\` and \`reason\`. The last two fields can be null. The response is \`Cache-Control: no-store\`.

${table(['State','Meaning','Next action'],[['pending','The saved intent is still being checked.','Keep the UUID and refresh the read with a limit.'],['accepted','A call ID was recorded; the call may not be complete.','Read that call ID.'],['rejected','A bounded refusal was recorded.','Review reason and correct the cause before a new deliberate intent.'],['unknown','The launch outcome cannot be confirmed.','Keep the UUID and reconcile; never automatically redial.']])}

Pending records display unknown after 15 minutes. They are never recycled into another dispatch. Neither a 404 nor an unavailable status read makes a new UUID safe automatically.`);
  s=replaceSection(s,'Example response','<ResponseExample>\n\n'+Object.entries(requestReadExamples).map(([name,e])=>code('json',name,JSON.stringify(e.value,null,2))).join('\n\n')+'\n\n</ResponseExample>');
 }
 if(row.slug==='api-reference/calls/create-outbound'){
  s=s.replace('## Response fields','## Response fields');
  s=s.replace('## Example request',`HTTP 200 is the accepted replay shape: \`call_id\`, \`request_id\`, \`status:"initiated"\` and \`replayed:true\`. Unlike the first 201 response, it does not require \`to\` or \`from\`.\n\n## Example request`);
  const body={agent_id:'agent_example',to_number:'+12025550101',prompt:'Confirm the requested appointment',request_id:requestIdExample};
  const curl=`# Save NXF_REQUEST_ID durably before this first deliberate launch.\n# Set NXF_TO_NUMBER to an approved recipient; this can place a real call.\ncurl --request POST \\\n+  --url 'https://api.nixflex.com/v1/calls/outbound' \\\n+  --header "Authorization: Bearer $NXF_API_KEY" \\\n+  --header 'Content-Type: application/json' \\\n+  --data "{\\"agent_id\\":\\"$NXF_AGENT_ID\\",\\"to_number\\":\\"$NXF_TO_NUMBER\\",\\"prompt\\":\\"Confirm the requested appointment\\",\\"request_id\\":\\"$NXF_REQUEST_ID\\"}"`;
  const legacy=json('spec-source/c4-core.json').operations['96'].kitExamples;
  const examples='<RequestExample>\n\n'+[code('bash','cURL · saved UUID',curl.replace(/^\+/gm,'').replace('https://api.nixflex.com','https://nixflex-voice-engine-staging.up.railway.app').replace('$NXF_API_KEY','$NXF_STAGING_KEY')),code('javascript','Node · without UUID',legacy.node),code('python','Python · without UUID',legacy.python),code('bash','CLI · without UUID',legacy.cli)].join('\n\n')+'\n\n</RequestExample>';
  s=replaceSection(s,'Example request','These examples use staging and can place a real call. Set NXF_STAGING_KEY, the owned agent and number, and an approved recipient before running. The cURL example also needs a durably saved NXF_REQUEST_ID. Keep the host and credential in the same environment.\n\nThe cURL tab demonstrates the new request UUID. Node/CLI 0.11.0 and Python 0.4.0 are reviewed unpublished candidates; their existing examples below omit request_id and retain the older launch behaviour. Use the cURL request when UUID reconciliation is needed until support is verified in the installed client. No example retries a write.\n\n'+examples+'\n\nA minimal UUID request body is shown below. The UUID is illustrative; never reuse a documentation UUID for live work.\n\n'+code('json','Request shape',JSON.stringify(body,null,2)));
  const post=spec.paths['/calls/outbound'].post;
  s=replaceSection(s,'Example response','Illustrative accepted replay and first-launch responses. Save both identifiers privately.\n\n<ResponseExample>\n\n'+code('json','200 · accepted replay',JSON.stringify(post.responses['200'].content['application/json'].examples.replayed.value,null,2))+'\n\n'+code('json','201 · first acceptance',JSON.stringify(post.responses['201'].content['application/json'].examples.journalled.value,null,2))+'\n\n'+code('json','201 · journal acknowledgement lost',JSON.stringify(post.responses['201'].content['application/json'].examples.unconfirmed.value,null,2))+'\n\n</ResponseExample>');
  s=replaceSection(s,'Retry and idempotency',journalSection);
  s=replaceSection(s,'Related endpoints','- [Read the saved outbound request](/api-reference/calls/get-outbound-request)\n- [Read the accepted call](/api-reference/calls/get)\n- [Client outcomes and retry rules](/api-reference/calls/client-safety)');
 }
 if(!op&&!s.includes('## Next steps'))s+='\n\n## Next steps\n\n'+[['API overview','api-reference/introduction'],['Errors and recovery','api-reference/errors'],['Retry rules','api-reference/retries'],['Authentication','api-reference/authentication']].filter(([,p])=>p!==row.slug).slice(0,3).map(([label,p])=>'- ['+label+'](/'+p+')').join('\n')+'\n';
 write(row.slug+'.mdx',s.trimEnd()+'\n');
}
// The five sample guides have authoritative source copies. No other Developer content is changed.
for(const slug of plan.developerSamples)write(slug+'.mdx',read('spec-source/c13-developer/'+slug.replaceAll('/','--')+'.mdx.txt'));
const config=json('docs.json');
config.styling={...config.styling,codeblocks:'dark'};
const expand=node=>{if(Array.isArray(node))node.forEach(expand);else if(node&&typeof node==='object'){if(node.group)node.expanded=true;Object.values(node).forEach(expand);}};
expand(config.navigation);
for(const [,c]of c13Errors)if(!config.redirects.some(r=>r.source==='/errors/'+c))config.redirects.push({source:'/errors/'+c,destination:'/api-reference/errors#'+c});
write('docs.json',JSON.stringify(config,null,2)+'\n');
console.log('C13: rewrote '+plan.api.length+' API pages and '+plan.developerSamples.length+' Developer samples; all navigation groups expanded.');
