import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

test('Whole-site URL normalization keeps the canonical home in generated page sets', () => {
 const source = fs.readFileSync(new URL('../scripts/check-c10-site.mjs', import.meta.url), 'utf8');
 const definition = source.match(/^const apiPath=u=>.*;$/m)?.[0];
 assert.ok(definition, 'Read the actual release-checker normalizer');
 const normalize = vm.runInNewContext(definition + '\napiPath;', {URL});
 for (const input of ['https://docs.nixflex.com', 'https://docs.nixflex.com/', '/', '/index', '/index.md', '/index.html']) {
  assert.equal(normalize(input), 'index', input);
 }
 for (const input of ['/api-reference/call-bookings', '/api-reference/call-bookings/', '/api-reference/call-bookings.md']) {
  assert.equal(normalize(input), 'api-reference/call-bookings', input);
 }
 for (const input of ['/api-reference/public.openapi.json', '/images/logo.svg', 'https://[invalid']) {
  assert.equal(normalize(input), null, input);
 }
});
