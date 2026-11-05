// B56 public contracts, reviewed against committed engine f6ff94d. No network or credentials.
import {callBookingsSchema,bookingExamples} from './c12-webhook-contracts.mjs';

export const engineRef='f6ff94dfe87611dfb8ac96adfafa61e568caf2b5';
export const requestIdExample='9f9aa2b2-4b77-4fa1-9071-9cf6747a9082';
export const requestIdSchema={type:'string',format:'uuid',pattern:'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89aAbB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',description:'Account-scoped UUID for one call intent. Save it before sending. Reusing it never starts a second call; changed input conflicts.'};
const nullableText={type:['string','null']};
const noStore={'Cache-Control':{description:'Do not cache private request or booking state.',schema:{type:'string',const:'no-store'}}};
const response=(description,schema,examples)=>({description,headers:structuredClone(noStore),content:{'application/json':{schema,examples}}});
const errorSchema=(codes)=>({type:'object',required:['error'],properties:{error:{type:'object',required:['type','code','message','doc_url','details'],properties:{
 type:{type:'string'},code:{type:'string',...(codes?{enum:codes}:{})},message:{type:'string'},doc_url:{type:'string',format:'uri'},details:{type:'object',additionalProperties:true},
},additionalProperties:true}},additionalProperties:true});
const err=(status,code,message,details={})=>({error:{type:({400:'invalid_request',401:'authentication_error',403:'permission_denied',404:'not_found',409:'conflict',429:'rate_limit'})[status]||'server_error',code,message,doc_url:'https://docs.nixflex.com/errors/'+code,details}});
const example=value=>({value});
export const c13Errors=[
 [404,'not_found','The identifier is invalid, missing or belongs to another account.','Check the owned identifier. Do not infer whether another account has this resource.'],
 [503,'call_bookings_unavailable','The booking result could not be read.','Keep the result unavailable. Retry this read with bounded backoff; do not show no bookings.'],
 [400,'invalid_request_id','The supplied request_id is not a supported UUID.','Create and save one valid UUID for the deliberate call intent before its first submission.'],
 [409,'request_id_conflict','This account already used the UUID with different call details.','Reconcile the existing request. Do not change its payload or automatically allocate a replacement ID.'],
 [409,'outbound_request_pending','The same call request is still pending.','Read the same request ID and call history. Wait; do not submit a new call.'],
 [409,'outbound_request_unknown','The saved request has an uncertain outcome.','Retain its UUID and check call history. Never automatically redial with a new ID.'],
 [503,'outbound_request_unknown','The call result or its final journal update could not be confirmed.','Treat the outcome as unknown and preserve request_id. Check its status before another deliberate intent.'],
 [503,'outbound_request_unavailable','The request journal could not be checked.','For a launch, retain unknown and safe_to_retry:false: an earlier attempt may have dialled. Retry the status read, not a new launch.'],
 [409,'outbound_request_rejected','A recorded refusal was replayed without dispatch.','Review the returned reason and original status. A fresh UUID is a new explicit intent, not an automatic retry.'],
];

export const bookingReadSchema={oneOf:['ready','none','processing','deleted','unavailable'].map(state=>({
 type:'object',required:['call_id','state','result'],additionalProperties:true,properties:{
  call_id:{type:'string',minLength:1,maxLength:200},state:{type:'string',const:state},
  result:state==='ready'?structuredClone(callBookingsSchema):{type:'null',description:'No authoritative booking result is returned in this state.'},
 },
}))};
export const bookingReadExamples=Object.fromEntries(['ready','none','processing','deleted','unavailable'].map(state=>[state,{
 summary:({ready:'Confirmed mutations and their final results.',none:'Completed booking evidence confirms no successful mutation.',processing:'Tracked call or post-call work is still running.',deleted:'Retained booking content is no longer available.',unavailable:'The retained evidence cannot establish a result.'})[state],
 value:{call_id:'call_example',state,result:state==='ready'?structuredClone(bookingExamples.create_move.value):null},
}]));
export const requestReadSchema={type:'object',required:['request_id','state','call_id','reason'],additionalProperties:true,properties:{
 request_id:{...requestIdSchema},state:{type:'string',enum:['pending','accepted','rejected','unknown']},
 call_id:{...nullableText,description:'Known call identifier, or null. Unknown does not prove that no call was placed.'},
 reason:{...nullableText,description:'Bounded machine-readable refusal/failure reason when retained; otherwise null.'},
}};
export const requestReadExamples=Object.fromEntries(['pending','accepted','rejected','unknown'].map(state=>[state,example({
 request_id:requestIdExample,state,call_id:state==='accepted'?'call_example':null,reason:state==='rejected'?'outside_hours':null,
})]));

export function applyC13Contracts(spec){
 const common=spec.paths['/calls/outbound'].post.responses;
 const auth=()=>({
  '401':structuredClone(common['401']),
  '403':response('permission_denied: The account or personal session cannot access this operation. Resolve access through an authorised person.',errorSchema(),{permission:example(err(403,'permission_denied','You do not have access to this section.'))}),
  '429':structuredClone(common['429']),
 });
 spec.paths['/calls/{id}/bookings']={get:{
  tags:['Calls'],summary:'Read call booking results',operationId:'getCallBookings',security:[{bearerAuth:[]}],
  description:'Read the authoritative retained booking result for one owned call. ready returns the signed-event public projection as data, not a delivery signature. none requires confirmed completed evidence with no successful mutations. processing means unfinished tracked work. deleted covers deleted, immediately scheduled, expired or purging content. unavailable covers old, partial, unstamped or unconfirmed evidence, including terminal unsuccessful calls. Do not infer bookings from a transcript or recover erased data from logs. This is the result of this call, not current calendar inventory.',
  parameters:[{in:'path',name:'id',required:true,description:'Owned call identifier. Invalid, missing and foreign identifiers share the same 404.',schema:{type:'string',minLength:1,maxLength:200}}],
  responses:{'200':response('Booking state. Only ready returns a non-null result.',bookingReadSchema,bookingReadExamples),...auth(),
   '404':response('not_found: Call identifier is invalid, missing or foreign. Check the owned ID.',errorSchema(['not_found']),{not_found:example(err(404,'not_found','Call not found.'))}),
   '503':response('call_bookings_unavailable: The read failed. Retry the read with bounded backoff; never show none.',errorSchema(['call_bookings_unavailable']),{unavailable:example(err(503,'call_bookings_unavailable','The booking result could not be checked. Try again shortly.'))}),
  },
 }};
 spec.paths['/calls/outbound/requests/{request_id}']={get:{
  tags:['Calls'],summary:'Read an outbound call request',operationId:'getOutboundCallRequest',security:[{bearerAuth:[]}],
  description:'Read the durable state of one account-scoped outbound request UUID. This does not dispatch, reserve capacity or charge. Pending records display unknown after 15 minutes and are never recycled. A 404 is shared by invalid, absent and foreign IDs; it is not evidence that an uncertain call is safe to redial. Preserve the request ID across lost responses and process restarts.',
  parameters:[{in:'path',name:'request_id',required:true,description:'The UUID saved for the original call intent.',schema:{...requestIdSchema}}],
  responses:{'200':response('Current request state; call_id and reason can be null.',requestReadSchema,requestReadExamples),...auth(),
   '404':response('not_found: UUID is invalid, missing or foreign. Reconcile the original intent; do not automatically redial.',errorSchema(['not_found']),{not_found:example(err(404,'not_found','Request not found.'))}),
   '503':response('outbound_request_unavailable: The status read failed. Keep the previous uncertainty and retry the read.',errorSchema(['outbound_request_unavailable']),{unavailable:example(err(503,'outbound_request_unavailable','The call request could not be checked. Try again shortly.'))}),
  },
 }};
 const post=spec.paths['/calls/outbound'].post;
 post.description+=' Optional request_id enables one durable account-scoped call intent. Required prompt and existing behavior without request_id remain unchanged. Save the UUID before sending; same input and ID can replay a recorded acceptance, but pending/unknown never dispatch again. A new UUID is a new explicit call intent, not a retry strategy.';
 const request=post.requestBody.content['application/json'];request.schema.properties.request_id={...requestIdSchema};
 request.examples={legacy:example(request.example),journalled:example({...request.example,request_id:requestIdExample})};delete request.example;
 const success=post.responses['201'].content['application/json'];
 Object.assign(success.schema.properties,{request_id:{...requestIdSchema,description:'Present when this launch supplied request_id. Keep it for reconciliation.'},request_status:{type:'string',const:'unconfirmed',description:'The call ID is known but its final journal acknowledgement was not confirmed. Never redial automatically.'}});
 success.examples={legacy:example(success.example),journalled:example({...success.example,request_id:requestIdExample}),unconfirmed:example({...success.example,request_id:requestIdExample,request_status:'unconfirmed',safe_to_retry:false})};delete success.example;
 post.responses['201'].description='Call initiated, not completed. With request_id, save both IDs. request_status:unconfirmed still preserves the known accepted call and safe_to_retry:false.';
 post.responses['200']=response('The same accepted request was replayed. No second dispatch; the response omits original to/from fields.',{
  type:'object',additionalProperties:true,required:['call_id','request_id','status','replayed'],properties:{call_id:{type:'string'},request_id:{...requestIdSchema},status:{type:'string',const:'initiated'},replayed:{type:'boolean',const:true}},
 },{replayed:example({call_id:'call_example',request_id:requestIdExample,status:'initiated',replayed:true})});
 for(const status of ['400','409','503']){
  const rows=c13Errors.filter(r=>String(r[0])===status&&r[1]!=='call_bookings_unavailable'&&r[1]!=='outbound_request_rejected');
  post.responses[status].description+=' '+rows.map(([,code,meaning,action])=>code+': '+meaning+' '+action).join(' ');
  const media=post.responses[status].content['application/json'];media.examples||={};
  for(const [,code,meaning] of rows){
   const state=code==='outbound_request_pending'?'pending':'unknown';
   const details=['outbound_request_pending','outbound_request_unknown','outbound_request_unavailable'].includes(code)?{request_id:requestIdExample,state,safe_to_retry:false}:{};
   media.examples[code]=example(err(Number(status),code,meaning,details));
  }
  if(status==='409'||status==='503'){
   const uncertain=status==='409'?['outbound_request_pending','outbound_request_unknown']:['outbound_request_unknown','outbound_request_unavailable'];
   media.schema.allOf=[...(media.schema.allOf||[]),{if:{properties:{error:{properties:{code:{enum:uncertain}},required:['code']}},required:['error']},then:{properties:{error:{required:['details'],properties:{details:{type:'object',required:['request_id','state','safe_to_retry'],properties:{request_id:{...requestIdSchema},state:{enum:status==='409'?['pending','unknown']:['unknown']},safe_to_retry:{const:false}}}}}}}}];
  }
 }
}
