import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'..'),read=p=>fs.readFileSync(path.join(root,p),'utf8'),json=p=>JSON.parse(read(p));
const spec=json('api-reference/public.openapi.json'),calendar='/integrations/google-calendar/number/{phoneNumber}';
test('C10 preserves D-owned files and assigns all published pages to exactly one of five tabs',()=>{
 const plan=json('spec-source/c10-site.json');
 assert.equal(new Set(plan.pages.map(p=>p.slug)).size,plan.pages.length);
 assert.deepEqual(json('docs.json').navigation.tabs.map(t=>t.tab),['Business guide','Developer guide','API reference','SDKs & CLI','AI tools']);
 // D1 merge base: C must not quietly rewrite D's content or metadata.
 for(const row of plan.pages.filter(p=>p.owner==='D')){
  const original=execFileSync('git',['show',plan.ownershipBaseline+':'+row.slug+'.mdx'],{cwd:root,encoding:'utf8'});
  assert.equal(read(row.slug+'.mdx').replaceAll('\r\n','\n'),original.replaceAll('\r\n','\n'),row.slug);
 }
});
test('C10 calendar shapes preserve nullable status, strict boolean settings and all seven days',()=>{
 const ops=spec.paths[calendar];assert.deepEqual(Object.keys(ops).sort(),['delete','get','patch']);
 const status=ops.get.responses['200'].content['application/json'].schema;
 assert.deepEqual(status.required.sort(),['account_email','calendar_id','connected','connected_at','needs_reconnect','send_invites'].sort());
 assert.deepEqual(status.properties.account_email.type,['string','null']);
 const settings=ops.patch.requestBody.content['application/json'].schema;
 assert.equal(settings.additionalProperties,false);assert.equal(settings.minProperties,1);
 assert.equal(settings.properties.send_invites.type,'boolean');
 assert.equal(settings.properties.hours.required.length,7);assert.deepEqual(settings.properties.slot_minutes.enum,[15,30,45,60]);
 assert.match(ops.patch.responses['400'].description,/invalid_send_invites/);
 const connect=spec.paths[calendar+'/connect'].post.requestBody.content['application/json'].schema;
 assert.deepEqual(connect.required,['return_url']);assert.equal(connect.additionalProperties,false);
});
test('C10 carrier setup preserves wire names, exact pairs and non-retryable unknown outcomes',()=>{
 const op=spec.paths['/phone-numbers/{phoneNumber}/credentials'].post;
 const branches=op.requestBody.content['application/json'].schema.oneOf;
 assert.equal(branches.length,2);for(const b of branches){assert.equal(b.additionalProperties,false);assert.equal(b.required.length,2);}
 assert.deepEqual(branches[0].required,['twilio_sid','twilio_token']);assert.deepEqual(branches[1].required,['telnyx_api_key','telnyx_connection_id']);
 assert.equal(op.responses['200'].content['application/json'].schema.additionalProperties,false);
 assert.match(op.responses['503'].description,/carrier_outcome_unknown.*credential_save_pending/);
 const page=read('api-reference/phone-numbers/credentials.mdx');assert.match(page,/stop automatic retries/i);assert.match(page,/identical details/);assert.match(page,/Do not delete and re-import/);
 const sms=spec.paths['/sms'].post.responses['409'];assert.match(JSON.stringify(sms),/do_not_contact/);
});
test('C10 new operation IDs are unique and all existing IDs remain stable',()=>{
 const previous=JSON.parse(execFileSync('git',['show','a427290:api-reference/public.openapi.json'],{cwd:root,encoding:'utf8',maxBuffer:10*1024*1024}));
 for(const [p,ops]of Object.entries(previous.paths))for(const [m,op]of Object.entries(ops))assert.equal(spec.paths[p][m].operationId,op.operationId,p);
 const ids=Object.values(spec.paths).flatMap(ops=>Object.values(ops).map(op=>op.operationId));assert.equal(ids.length,147);assert.equal(new Set(ids).size,147);
});
