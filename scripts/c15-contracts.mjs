// Final content-deletion contract: engine 9da04ec, dashboard e79c6d3.
// Bulk call deletion and account closure deliberately keep their separate contracts.
export const engineRef = '9da04ec91ccee8d8997b2d6a89eb0e2c69aeb50d';
const example = value => ({value});
const response = (description, schema, examples) => ({description, content:{'application/json':{schema, examples}}});
const error = (status, code, message, details={}) => ({error:{type:({400:'invalid_request',403:'permission_denied',404:'not_found'})[status]||'server_error',code,message,doc_url:'https://docs.nixflex.com/errors/'+code,details}});
const errors = codes => ({type:'object',required:['error'],properties:{error:{type:'object',required:['type','code','message','doc_url','details'],properties:{type:{type:'string'},code:{type:'string',enum:codes},message:{type:'string'},doc_url:{type:'string',format:'uri'},details:{type:'object',additionalProperties:true}},additionalProperties:true}},additionalProperties:true});
export const callDeletedSchema = {type:'object',required:['call_id','deleted','recording_deleted','recording_cleanup'],properties:{
  call_id:{type:'string',description:'The owned call ID from the request.'},
  deleted:{type:'boolean',const:true,description:'The call content has been removed from customer views after confirmed hang-up.'},
  recording_deleted:{type:'boolean',description:'True only when the Nixflex recording copy is confirmed absent. This is not proof of carrier or customer-storage erasure.'},
  recording_cleanup:{type:'string',enum:['carrier_best_effort','queued'],description:'queued means Nixflex-copy cleanup is still tracked. carrier_best_effort means that copy is confirmed absent; carrier cleanup remains best effort.'},
},additionalProperties:true};
export const campaignDeletedSchema = {type:'object',required:['campaign_id','deleted','message'],properties:{campaign_id:{type:'string'},deleted:{type:'boolean',const:true},message:{type:'string',const:'Campaign deleted'}},additionalProperties:true};
export const callDeleteExamples = {
  cleaned:example({call_id:'call_example',deleted:true,recording_deleted:true,recording_cleanup:'carrier_best_effort'}),
  cleanup_queued:example({call_id:'call_example',deleted:true,recording_deleted:false,recording_cleanup:'queued'}),
};
export function deletionResponses(kind, common){
  const call = kind==='call';
  const message = call?'The call has not confirmed it ended yet. Deletion is queued and will finish once hang-up is confirmed.':'Waiting work is cancelled. Some calls have not confirmed they ended yet. Deletion is queued and will finish once hang-up is confirmed.';
  return {
    '200':response(call?'Call content deleted. Recording cleanup has its own explicit state.':'Campaign and recipient list removed. Sent history and used charges remain.',call?callDeletedSchema:campaignDeletedSchema,call?callDeleteExamples:{deleted:example({campaign_id:'campaign_example',deleted:true,message:'Campaign deleted'})}),
    '400':response('invalid_delete: The identifier must contain 1–200 characters.',errors(['invalid_delete']),{invalid_delete:example(error(400,'invalid_delete','Choose a valid call or campaign.'))}),
    '401':structuredClone(common['401']),
    '403':response('permission_denied: Owner or Admin authority is required. A Member cannot delete content.',errors(['permission_denied']),{permission_denied:example(error(403,'permission_denied','Only an Admin or the Owner can do this.'))}),
    '404':response('not_found: The item is missing or belongs to another account. These cases have the same response.',errors(['not_found']),{not_found:example(error(404,'not_found',call?'Call not found.':'Campaign not found.'))}),
    '429':structuredClone(common['429']),
    '503':response('hangup_pending: Hang-up is unconfirmed and durable deletion will continue. deletion_unavailable: The result could not be confirmed; check the list and repeat the same DELETE to resume any existing request safely.',errors(['hangup_pending','deletion_unavailable']),{
      hangup_pending:example(error(503,'hangup_pending',message,{deleted:false,retry_pending:true})),
      deletion_unavailable:example(error(503,'deletion_unavailable','Deletion could not be confirmed. Check the list and try Delete again; an existing request will safely resume.',{deleted:false})),
    }),
  };
}
export function applyC15Contracts(spec){
  // B59 dd95cfb: reuse the exact safe list item, including every nullable field.
  const list=spec.paths['/campaigns'].get.responses;
  const item=structuredClone(list['200'].content['application/json'].schema.properties.campaigns.items);
  const campaign={campaign_id:'campaign_example',agent_id:'agent_example',name:'Appointment reminders',prompt:null,from_number:'+12025550123',schedule_type:'schedule',scheduled_date:'2026-11-20',window_start_minutes:540,window_end_minutes:1020,window_days:['mon','tue','wed','thu','fri'],timezone:'America/New_York',source:'api',status:'scheduled',total_count:10,done_count:0,failed_count:0,voicemail_count:0,started_at:null,completed_at:null,created_at:'2026-11-12T00:00:00Z',updated_at:'2026-11-12T00:00:00Z',allow_wider_hours:false};
  spec.paths['/campaigns/{id}']={get:{
    tags:['Voice campaigns'],summary:'Get a voice campaign',operationId:'getVoiceCampaign',security:[{bearerAuth:[]}],
    description:'Read one owned voice campaign with the same fields as a campaign-list item. No recipients are included. Wider-hours confirmation uses current saved evidence; an evidence-read failure returns 503 rather than false. Missing, foreign, deleted and invalid IDs have the same 404. Responses use Cache-Control: no-store.',
    parameters:[{name:'id',in:'path',required:true,description:'Exact owned campaign identifier. Invalid, missing, foreign and deleted IDs share a 404.',schema:{type:'string',minLength:1,maxLength:200}}],
    responses:{
      '200':{...response('Owned campaign detail.',{type:'object',required:['campaign'],properties:{campaign:item},additionalProperties:false},{campaign:example({campaign})}),headers:{'Cache-Control':{description:'Do not store this response.',schema:{type:'string',const:'no-store'}}}},
      '401':structuredClone(list['401']),
      '403':response('permission_denied: The authenticated principal is not allowed to access this account.',errors(['permission_denied']),{permission_denied:example(error(403,'permission_denied','You do not have permission to do this.'))}),
      '404':response('not_found: Invalid, missing, foreign or deleted campaign.',errors(['not_found']),{not_found:example(error(404,'not_found','Campaign not found.'))}),
      '429':structuredClone(list['429']),
      '503':response('campaign_unavailable: Campaign details or current wider-hours evidence could not be read.',errors(['campaign_unavailable']),{campaign_unavailable:example(error(503,'campaign_unavailable','Campaign details could not be checked. Please retry.'))}),
    },
  }};
  const common=spec.paths['/calls/{id}'].delete.responses;
  for(const [route,kind,summary,operationId] of [
    ['/calls/{id}','call','Delete a call','deleteCall'],
    ['/calls/batch/{id}','voice','Delete a voice campaign','deleteVoiceCampaign'],
    ['/sms/campaigns/{id}','sms','Delete an SMS campaign','deleteSmsCampaign'],
  ]){
    const call=kind==='call';
    const prior=spec.paths[route]?.delete;
    (spec.paths[route]||={}).delete={
      tags:[call?'Calls':kind==='voice'?'Voice campaigns':'SMS campaigns'],summary,operationId:prior?.operationId||operationId,
      security:[{bearerAuth:[]}],
      description:(call?'Hang up a running owned call, then remove its content. Recording cleanup can remain queued after content deletion.':'Cancel waiting campaign work, hang up its running calls, then remove the campaign and recipient list. Calls already made and SMS already sent remain in history.')+' Owner and Admin may delete; Member may not. Used charges and required financial evidence remain; no refund is made. A hangup_pending response queues durable completion without waiting for settlement. Repeating the same DELETE safely resumes the same request. A lost response is not confirmed success. Customer-managed copies are outside this operation. Bulk call deletion and account closure have separate contracts.',
      parameters:[{name:'id',in:'path',required:true,description:'Owned '+(call?'call':'campaign')+' identifier. Missing and foreign IDs have the same 404.',schema:{type:'string',minLength:1,maxLength:200}}],
      responses:deletionResponses(kind,common),
    };
  }
  function bookingSetting(value){
    if(!value||typeof value!=='object')return;
    for(const [key,child]of Object.entries(value)){
      if(key==='require_booking_confirmation'&&child&&typeof child==='object'){
        child.description='Saved confirmation setting for supported calendar changes. A new voice booking always requires one combined read-back and one clear yes, even when false. A null number override inherits the agent.';
      }
      bookingSetting(child);
    }
  }
  bookingSetting(spec.paths);
}
