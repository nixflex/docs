import {test} from 'node:test';
import a from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const read=p=>readFileSync(new URL('../'+p,import.meta.url),'utf8');
const root=JSON.parse(read('api-reference/openapi.json')),usage=JSON.parse(read('api-reference/phone-number-usage.json'));
test('Group3 OpenAPI exposes only an authenticated GET with defaulted periods/zone and precise monetary strings',()=>{
 a.equal(root.paths['/phone-numbers/{phoneNumber}/usage'].$ref,'phone-number-usage.json#/UsagePath');
 a.deepEqual(Object.keys(usage.UsagePath),['get']);a.deepEqual(usage.UsagePath.get.security,[{bearerAuth:[]}]);
 a.equal(usage.UsagePath.get.parameters[1].schema.default,'all');a.equal(usage.UsagePath.get.parameters[2].schema.default,'UTC');
 a.equal(usage.NumberUsage.properties.total_cost.type,'string');a.equal(usage.NumberUsage.additionalProperties,false);
 a.deepEqual(usage.NumberUsage.required.sort(),Object.keys(usage.NumberUsage.properties).sort());
 a.ok(usage.UsagePath.get.responses['503']);a.doesNotMatch(JSON.stringify(usage.NumberUsage),/api_key_id|key_secret|twilio_auth_token/);
});
test('Group3 draft includes every client surface and honest usage, unused, timezone and generation semantics',()=>{
 const doc=read('api-reference/phone-numbers/usage.mdx'),nav=read('docs.json');a.ok(nav.includes('api-reference/phone-numbers/usage'));
 for(const phrase of ['phoneNumbers.usage','phone_numbers.usage','numbers usage','list_phone_numbers','"usage":true','not a billing ledger','Same-owner re-import','UTC','Unused','local/unpublished'])a.ok(doc.includes(phrase),phrase);
});
