// B54/B55 customer contract. No network, credentials or new API endpoint.
const nullableText={type:['string','null']};
const nullableTime={type:['string','null'],format:'date-time'};
const bookingFields={booking_uid:{...nullableText},start:{...nullableTime},end:{...nullableTime},
 attendee_name:{...nullableText},attendee_email:{...nullableText},
 service:{type:['string','number','null']},timezone:{...nullableText}};
export const callBookingsSchema={
 type:'object',additionalProperties:true,
 required:['event','call_id','agent_id','from','to','number','ended_at','timeline','final'],
 properties:{
  event:{type:'string',const:'call.bookings'},
  call_id:{...nullableText},agent_id:{...nullableText},from:{...nullableText},to:{...nullableText},number:{...nullableText},
  ended_at:{type:'string',format:'date-time',description:'Engine call-end time in UTC; not webhook delivery time.'},
  timeline:{type:'array',minItems:1,description:'Ordered confirmed calendar mutations during this call.',items:{
   type:'object',additionalProperties:true,required:['action',...Object.keys(bookingFields),'at'],
   properties:{action:{type:'string',enum:['created','rescheduled','cancelled']},...structuredClone(bookingFields),
    at:{type:'string',format:'date-time',description:'Engine receipt time of the successful mutation, in UTC.'}},
  }},
  final:{type:'array',minItems:1,description:'One result per resulting booking UID. This is not a full calendar inventory.',items:{
   type:'object',additionalProperties:true,required:['status',...Object.keys(bookingFields)],
   properties:{status:{type:'string',enum:['active','cancelled']},...structuredClone(bookingFields)},
  }},
 },
};
const initial={booking_uid:'booking_example',start:'2030-11-04T10:00:00.000Z',end:'2030-11-04T10:30:00.000Z',
 attendee_name:'Sam Carter',attendee_email:'sam@example.test',service:'Consultation',timezone:'Europe/London'};
const later={start:'2030-11-04T11:00:00.000Z',end:'2030-11-04T11:30:00.000Z'};
const row=(action,values={},at='2030-11-04T09:01:00.000Z')=>({action,...initial,...values,at});
const final=(status,values={})=>({status,...initial,...values});
const event=(timeline,results)=>({event:'call.bookings',call_id:'call_example',agent_id:'agent_example',
 from:'+12025550101',to:'+12025550100',number:'+12025550100',ended_at:'2030-11-04T09:05:00.000Z',timeline,final:results});
export const bookingExamples={
 create_move:{summary:'Create then move: one active booking at the moved time.',value:event([
  row('created'),row('rescheduled',later,'2030-11-04T09:02:00.000Z')],[final('active',later)])},
 create_cancel:{summary:'Create then cancel: one cancelled result, zero active.',value:event([
  row('created'),row('cancelled',{},'2030-11-04T09:02:00.000Z')],[final('cancelled')])},
 create_move_cancel:{summary:'Create, move, cancel: cancelled at the last known time.',value:event([
  row('created'),row('rescheduled',later,'2030-11-04T09:02:00.000Z'),row('cancelled',later,'2030-11-04T09:03:00.000Z')],[final('cancelled',later)])},
 move_existing:{summary:'Move an existing booking: one active result at its new time.',value:event([
  row('rescheduled',later)],[final('active',later)])},
 two_bookings:{summary:'Two independent booking UIDs: two active results.',value:event([
  row('created'),row('created',{booking_uid:'booking_second',...later},'2030-11-04T09:02:00.000Z')],
  [final('active'),final('active',{booking_uid:'booking_second',...later})])},
 replacement_uid:{summary:'A replacement UID is resolved in final; timeline retains original action IDs.',value:event([
  row('created'),row('rescheduled',later,'2030-11-04T09:02:00.000Z')],[final('active',{...later,booking_uid:'booking_replacement'})])},
 unknown_fields:{summary:'Preserve nullable unknown fields and numeric legacy service.',value:event([
  row('rescheduled',{end:null,attendee_name:null,attendee_email:null,service:42,timezone:null})],
  [final('active',{end:null,attendee_name:null,attendee_email:null,service:42,timezone:null})])},
};
export const bookingWebhook={
 post:{summary:'Receive confirmed post-call booking results',
  description:'One logical event per ended call and configured destination when a calendar mutation succeeded. Verify the raw-body signature before parsing. Deduplicate (trusted account, event, call_id) per receiver; deliveries can repeat, be delayed or fail.',
  security:[],parameters:[{in:'header',name:'X-Nixflex-Signature',required:true,
   description:'HMAC-SHA256 over timestamp.raw_body using the privately provisioned signing secret. Missing signing material retries; call.bookings is never sent unsigned.',
   schema:{type:'string',pattern:'^t=[0-9]+,v1=[a-f0-9]{64}$'}}],
  requestBody:{required:true,content:{'application/json':{schema:callBookingsSchema,examples:bookingExamples}}},
  responses:{'200':{description:'Receiver has durably stored the verified event, or already has this logical event. Return 2xx directly; do not redirect.'}},
 },
};
const errorSchema=codes=>({type:'object',required:['error'],properties:{error:{type:'object',
 required:['type','code','message','doc_url','details'],properties:{type:{type:'string'},code:{type:'string',enum:codes},
 message:{type:'string'},doc_url:{type:'string',format:'uri'},details:{type:'object',additionalProperties:true}}}}});
const error=(code,message,details={})=>({error:{type:code==='deletion_unavailable'?'server_error':'conflict',code,message,
 doc_url:'https://docs.nixflex.com/errors/'+code,details}});
export function applyC12Contracts(spec){
 spec.webhooks={...(spec.webhooks||{}),'call.bookings':structuredClone(bookingWebhook)};
 const remove=spec.paths['/sms/campaigns/{id}'].delete;
 remove.description='Delete an owned SMS campaign only after active work and settlement are resolved. Zero sent is not sufficient proof. Keep the row until confirmed success; a missing owned campaign returns the same success acknowledgement.';
 delete remove.responses['400'];delete remove.responses['500'];
 const pending='This campaign is waiting for its final send results and charges. It has not been deleted. Try again after settlement finishes.';
 const running='This campaign is still running. Cancel it or wait for it to finish before deleting it.';
 const unavailable='Deletion could not be checked. No deletion was confirmed.';
 const conflict=errorSchema(['campaign_settlement_pending','campaign_in_progress']);
 conflict.properties.error.properties.type.const='conflict';
 conflict.properties.error.allOf=[{if:{properties:{code:{const:'campaign_settlement_pending'}}},then:{properties:{details:{type:'object',required:['deleted'],properties:{deleted:{const:false}}}}}}];
 remove.responses['409']={description:'campaign_settlement_pending: final results/charges are unsettled; details.deleted=false. campaign_in_progress: cancel or wait for active work first.',
  content:{'application/json':{schema:conflict,examples:{settlement:{value:error('campaign_settlement_pending',pending,{deleted:false})},running:{value:error('campaign_in_progress',running)}}}}};
 remove.responses['503']={description:'deletion_unavailable: deletion could not be checked; no deletion confirmed.',
  content:{'application/json':{schema:errorSchema(['deletion_unavailable']),example:error('deletion_unavailable',unavailable)}}};
 spec.paths['/knowledge-bases/{kb}/drafts/{id}'].get.description='Read a draft without persisting repairs. Legacy normalization is projected with stable draft-scoped piece IDs; an explicit save or accept persists it. Keep the returned edit revision before editing.';
 spec.paths['/calls/{id}'].delete.description='Request guarded cleanup of one owned ended, settled call. A narrow skipped-recording case can complete only with fresh proof of no stored object, no carrier copy, closed upload fence and completed post-call/settlement work. Missing or unknown evidence remains refused. Bulk/account deletion is unchanged; a missing URL is not erasure proof.';
}
