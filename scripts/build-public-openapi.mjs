import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {paths as c10Paths} from './c10-contracts.mjs';
import {applyC12Contracts} from './c12-webhook-contracts.mjs';
import {applyC13Contracts} from './c13-contracts.mjs';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const read = async p => {
  const source = p.startsWith('api-reference/') && p !== 'api-reference/public.openapi.json'
    ? p.replace('api-reference/', 'spec-source/legacy/') + '.src' : p;
  return JSON.parse(await fs.readFile(path.resolve(root, source), 'utf8'));
};
const cache = new Map();
async function doc(file) {
  if (!cache.has(file)) cache.set(file, await read(file));
  return cache.get(file);
}
function pointer(value, fragment) {
  return fragment.split('/').slice(1).reduce((v, k) => v[k.replaceAll('~1', '/').replaceAll('~0', '~')], value);
}
async function expand(value, file, stack = []) {
  if (Array.isArray(value)) return Promise.all(value.map(v => expand(v, file, stack)));
  if (!value || typeof value !== 'object') return value;
  if (value.$ref) {
    const [target, fragment = ''] = value.$ref.split('#');
    if (/^https?:/.test(target)) throw Error('Remote reference forbidden: ' + target);
    const dest = target ? path.posix.normalize(path.posix.join(path.posix.dirname(file), target)) : file;
    const key = dest + '#' + fragment;
    if (stack.includes(key)) throw Error('Cyclic reference: ' + key);
    const base = await expand(pointer(await doc(dest), fragment), dest, [...stack, key]);
    const siblings = { ...value }; delete siblings.$ref;
    return { ...base, ...await expand(siblings, file, stack) };
  }
  return Object.fromEntries(await Promise.all(Object.entries(value).map(async ([k, v]) => [k, await expand(v, file, stack)])));
}

const allow = await read('spec-source/public-operations.json');
const shape = p => p.replace(/^\/v1/, '').replace(/:[^/]+|\{[^}]+\}/g, '{}');
const publicKeys = new Set(allow.filter(r => r.public).map(r => r.method + ' ' + shape(r.path)));
const source = await expand(await doc('api-reference/openapi.json'), 'api-reference/openapi.json');
const paths = {};
for (const [p, item] of Object.entries(source.paths)) {
  for (const [method, operation] of Object.entries(item)) {
    if (!['get', 'post', 'put', 'patch', 'delete', 'head', 'options'].includes(method)) continue;
    if (!publicKeys.has(method.toUpperCase() + ' ' + shape(p))) continue;
    (paths[p] ||= {})[method] = { ...operation };
    if (item.parameters) paths[p][method].parameters = [...item.parameters, ...(operation.parameters || [])];
  }
}
const overrides = await read('spec-source/public-overrides.json');
Object.assign(overrides.paths,c10Paths);
for (const [p, item] of Object.entries(overrides.paths)) {
  for (const [method, operation] of Object.entries(item)) {
    if (!publicKeys.has(method.toUpperCase() + ' ' + shape(p))) throw Error('Override is not public: ' + method + ' ' + p);
    (paths[p] ||= {})[method] = operation;
  }
}

const brand = /twilio|telnyx|openai|anthropic|deepgram|inworld|elevenlabs|supabase|groq/i;
function clean(value) {
  if (Array.isArray(value)) return value.map(clean);
  if (!value || typeof value !== 'object') return value;
  const out = {};
  for (const [k, v] of Object.entries(value)) {
    if (brand.test(k) || ['x-codeSamples', 'x-code-samples'].includes(k)) continue;
    if (k === 'properties') {
      out[k] = Object.fromEntries(Object.entries(v)
        .filter(([name, schema]) => !brand.test(name) && !(schema.enum || []).some(x => brand.test(String(x))))
        .map(([name, schema]) => [name, clean(schema)]));
    } else if (['description', 'summary', 'title'].includes(k) && typeof v === 'string') {
      out[k] = v.replace(/Twilio|Telnyx|OpenAI|Anthropic|Deepgram|Inworld|ElevenLabs|Supabase|Groq/gi, 'service');
    } else if (['example', 'examples', 'default'].includes(k) && brand.test(JSON.stringify(v))) {
      continue;
    } else out[k] = clean(v);
  }
  if (out.required && out.properties) out.required = out.required.filter(k => Object.hasOwn(out.properties, k));
  if (out.required?.length === 0) delete out.required;
  // Input fragments use both 3.0 nullable and 3.1 unions. Publish one 3.1 dialect.
  if (out.nullable === true && typeof out.type === 'string') out.type = [out.type, 'null'];
  delete out.nullable;
  return out;
}

const result = {
  openapi: '3.1.0',
  info: {
    title: 'Nixflex public API', version: '1.0.0',
    description: 'Nixflex API reference for agents, calls, messaging, knowledge, organisations and integrations. Authenticate with the owning account and follow each operation’s permissions, response and retry contract.'
  },
  servers: [{ url: 'https://api.nixflex.com/v1' }],
  security: [{ bearerAuth: [] }],
  paths: clean(paths),
  components: { securitySchemes: { bearerAuth: {
    type: 'http', scheme: 'bearer',
    description: 'KEY_ID:KEY_SECRET from the owning account. Keep it server-side. A verified personal dashboard Bearer session may be used where the operation documents role-based access.'
  } } }
};
let count = 0;
// Carrier field names and enum values are required for this setup operation.
result.paths['/phone-numbers/{phoneNumber}/credentials']=structuredClone(c10Paths['/phone-numbers/{phoneNumber}/credentials']);
applyC12Contracts(result);
applyC13Contracts(result);
const ids = new Set();
for (const [p, item] of Object.entries(result.paths)) {
  for (const [method, op] of Object.entries(item)) {
    count++;
    // Error field examples in older fragments described a different status.
    // Keep operation-specific wire examples, but remove misleading generic defaults.
    for (const [status, response] of Object.entries(op.responses || {})) {
      if (Number(status) < 400) continue;
      const error = response.content?.['application/json']?.schema?.properties?.error;
      if (error?.properties) {
        for (const field of Object.values(error.properties)) delete field.example;
        error.required = [...new Set([...(error.required || []), 'type', 'code', 'message', 'doc_url'])];
      }
      const media=response.content?.['application/json'];
      const values=[media?.example,...Object.values(media?.examples||{}).map(e=>e.value)];
      for(const value of values){
        if(!value?.error?.code)continue;
        const e=value.error;
        e.type=({400:'invalid_request',401:'authentication_error',402:'payment_required',403:'permission_denied',404:'not_found',409:'conflict',422:'invalid_request',429:'rate_limit'})[status]||(Number(status)>=500?'server_error':'error');
        e.doc_url||='https://docs.nixflex.com/errors/'+e.code;
        e.details||={};
      }
    }
    op.operationId ||= method + p.replace(/[^a-zA-Z0-9]+/g, '_');
    if (ids.has(op.operationId)) throw Error('Duplicate operationId: ' + op.operationId);
    ids.add(op.operationId);
  }
}
if (JSON.stringify(result).includes('"$ref"')) throw Error('Bundle still contains references');
await fs.writeFile(path.join(root, 'api-reference/public.openapi.json'), JSON.stringify(result, null, 2) + '\n');
console.log('Bundled ' + count + ' approved public operations; no external references.');
