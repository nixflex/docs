import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {unreviewedCarrierCopy} from '../scripts/c11-content-policy.mjs';
const root=path.resolve(import.meta.dirname,'..');
test('C12 D4 carrier exceptions permit reviewed configuration only',()=>{
 for(const slug of ['ai-tools/number-credentials','ai-tools/codex']){
  const page=fs.readFileSync(path.join(root,slug+'.mdx'),'utf8');
  assert.equal(unreviewedCarrierCopy(slug,page),false,slug);
  assert.equal(unreviewedCarrierCopy(slug,page+'\nTwilio stores every recording.'),true);
  assert.equal(unreviewedCarrierCopy(slug,page+'\nTelnyx powers Nixflex.'),true);
  assert.equal(unreviewedCarrierCopy('reference/pricing',page),true);
  assert.equal(unreviewedCarrierCopy(slug,page.replace('NIXFLEX_TWILIO_TOKEN','UNREVIEWED_TOKEN')),true);
 }
});
