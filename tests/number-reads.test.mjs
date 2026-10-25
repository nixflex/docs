import {test} from 'node:test';
import a from 'node:assert/strict';
import {readFileSync,existsSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
const root=resolve(import.meta.dirname,'..');
const file=resolve(root,'api-reference/openapi.json');
const api=JSON.parse(readFileSync(file,'utf8'));
const definitions=JSON.parse(readFileSync(resolve(root,'api-reference/phone-number-reads.json'),'utf8'));
const fields=['inbound_enabled','outbound_enabled','sms_reply_enabled','web_agent_enabled','web_calls_enabled','web_functions_enabled','monitor_enabled'];
test('Group2 OpenAPI has authenticated GET and paged list without a new required list argument',()=>{
  const route=api.paths['/phone-numbers/{phoneNumber}'];a.equal(route.get.operationId,'getPhoneNumber');a.deepEqual(route.get.security,[{bearerAuth:[]}]);a.ok(route.patch&&route.delete);
  const params=api.paths['/phone-numbers'].get.parameters;a.equal(params.length,4);a.ok(params.every(p=>!p.required));
  a.equal(api.paths['/phone-numbers'].get.responses['200'].content['application/json'].schema.$ref,'phone-number-reads.json#/NumberListResponse');
  a.match(definitions.NumberListResponse.properties.count.description,/NOT the account total/);
});
test('Group2 response fields safe and complete; seven booleans typed; source/status never writable',()=>{
  const detail=definitions.PhoneNumberDetails;
  a.equal(detail.additionalProperties,false);a.deepEqual(detail.required.sort(),Object.keys(detail.properties).sort());
  for(const name of fields){a.equal(api.components.schemas.PhoneNumberUpdate.properties[name].type,'boolean');a.ok(detail.properties[name]);}
  a.equal(detail.properties.source.readOnly,true);a.equal(api.components.schemas.PhoneNumberUpdate.properties.source,undefined);
  a.equal(api.components.schemas.PhoneNumberUpdate.properties.telnyx_key_verified_at,undefined);
  a.equal(definitions.TelnyxKeyStatus.properties.fingerprint.maxLength,16);
  a.doesNotMatch(JSON.stringify(detail),/api_key_id|twilio_auth_token|telnyx_api_key|dashboard_import_id/);
});
test('Group2 all OpenAPI local refs resolve including the external schema file',()=>{
  const visited=new Set();
  function walk(value,current){if(!value||typeof value!=='object')return;
    if(value.$ref){const [relative,pointer]=value.$ref.split('#');a.ok(!relative?.startsWith('http'),'external network ref not expected');
      const dest=relative?resolve(dirname(current),relative):current;const key=dest+'#'+pointer;
      if(!visited.has(key)){visited.add(key);let target=JSON.parse(readFileSync(dest,'utf8'));for(const part of (pointer||'').split('/').slice(1))target=target?.[part.replace(/~1/g,'/').replace(/~0/g,'~')];a.notEqual(target,undefined,key);walk(target,dest);}
    }
    for(const child of Object.values(value))walk(child,current);
  }walk(api,file);
});
test('Group2 new pages are navigable and examples explain saved versus effective state',()=>{
  const nav=JSON.stringify(JSON.parse(readFileSync(resolve(root,'docs.json'),'utf8')));
  for(const page of ['get','switches']){a.ok(nav.includes('api-reference/phone-numbers/'+page));a.ok(existsSync(resolve(root,'api-reference/phone-numbers',page+'.mdx')));}
  const switches=readFileSync(resolve(root,'api-reference/phone-numbers/switches.mdx'),'utf8');for(const f of fields)a.ok(switches.includes(f));
  a.match(switches,/web_calls_effective/);a.match(switches,/unpublished/);
});
