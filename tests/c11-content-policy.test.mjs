import {test} from 'node:test';
import assert from 'node:assert/strict';
import {supplierLeak,unreviewedCarrierCopy,productionCanonical} from '../scripts/c11-content-policy.mjs';
test('C11 client documentation exception cannot hide supplier claims or other URLs',()=>{
 const link='[guide](https://developers.openai.com/api/docs/guides/secure-mcp-tunnels)';
 assert.equal(supplierLeak('ai-tools/chatgpt',link),false);
 assert.equal(supplierLeak('ai-tools/chatgpt',link+' OpenAI powers our calls'),true);
 assert.equal(supplierLeak('ai-tools/chatgpt','[guide](https://developers.openai.com/other)'),true);
 assert.equal(supplierLeak('reference/faq',link),true);
});
test('C11 reviewed carrier setup exception still flags new carrier claims',()=>{
 const copy='Twilio and Telnyx have supported setup paths. Use the instructions for your chosen carrier and number; do not assume every number has identical calling, messaging or verification requirements. See [phone number concepts](/concepts/phone-numbers).';
 assert.equal(unreviewedCarrierCopy('reference/faq',copy),false);
 assert.equal(unreviewedCarrierCopy('reference/faq',copy+' Twilio stores all recordings.'),true);
 assert.equal(unreviewedCarrierCopy('reference/pricing',copy),true);
});
test('C11 generated home canonical may normalize index, while other paths remain exact',()=>{
 assert.equal(productionCanonical('index','https://docs.nixflex.com'),true);
 assert.equal(productionCanonical('index','https://docs.nixflex.com/'),true);
 assert.equal(productionCanonical('index','https://docs.nixflex.com/index'),true);
 assert.equal(productionCanonical('business','https://docs.nixflex.com/business'),true);
 assert.equal(productionCanonical('business','https://docs.nixflex.com'),false);
 assert.equal(productionCanonical('business','https://docs.nixflex.com/business-old'),false);
 assert.equal(productionCanonical('index','http://docs.nixflex.com'),false);
 assert.equal(productionCanonical('index','https://staging.example.test'),false);
});
