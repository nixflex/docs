import {test} from 'node:test';
import assert from 'node:assert/strict';
import {productionOnly} from '../scripts/public-production-policy.mjs';

test('Publication gate rejects test service leaks in prose, metadata and examples',()=>{
 for(const content of [
  'Use staging for this example.',
  'description: "STAGING setup"',
  '```bash\ncurl https://nixflex-voice-engine-staging.up.railway.app/v1/usage\n```',
  '{"servers":[{"url":"https://internal.railway.app"}]}',
  'wss://internal.RAILWAY.APP/socket',
  '$NXF_STAGING_KEY',
  'process.env.NXF_API_KEY',
 ])assert.equal(productionOnly(content),false,content);
 assert.equal(productionOnly('https://api.nixflex.com/v1/usage\nwss://api.nixflex.com\nNIXFLEX_API_KEY'),true);
});
