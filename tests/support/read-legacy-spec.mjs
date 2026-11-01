// Historical regression fixtures moved out of the deployed API directory in C3.
// Public bundle coverage is checked separately by c3-foundation.test.mjs.
import {readFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
export function readLegacyFileSync(input, ...options) {
  let name = input instanceof URL ? fileURLToPath(input) : input;
  if (typeof name === 'string' && /(?:^|[\\/])api-reference[\\/].*\.json$/.test(name) && !name.endsWith('public.openapi.json')) {
    name = name.replace(/api-reference([\\/])/, 'spec-source$1legacy$1') + '.src';
  }
  return readFileSync(name, ...options);
}
