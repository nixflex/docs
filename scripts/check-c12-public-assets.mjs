// Strict companion to the unchanged whole-site checker. Reads the docs site only.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const root = path.resolve(import.meta.dirname, '..');
function stable(value) {
  if (Array.isArray(value)) return value.map(stable);
  if (value && typeof value === 'object') return Object.fromEntries(Object.keys(value).sort().map(key => [key, stable(value[key])]));
  return value;
}
const digest = value => crypto.createHash('sha256').update(JSON.stringify(stable(value))).digest('hex');

export async function checkPublicSpec(site, expected) {
  const origin = new URL(site);
  if (!['http:', 'https:'].includes(origin.protocol) || origin.username || origin.password || origin.search || origin.hash) {
    throw new Error('Provide an HTTP(S) docs origin without credentials, query or fragment');
  }
  const url = site.replace(/\/$/, '') + '/api-reference/public.openapi.json';
  const report = {status: 'FAIL', url, expectedSemanticSha256: digest(expected), failures: []};
  try {
    const response = await fetch(url, {signal: AbortSignal.timeout(20000), redirect: 'error'});
    report.httpStatus = response.status;
    report.contentType = response.headers.get('content-type');
    if (!response.ok) throw new Error('HTTP ' + response.status + ': public OpenAPI download is unavailable');
    const actual = await response.json();
    report.actualSemanticSha256 = digest(actual);
    report.openapi = actual.openapi;
    report.httpOperations = Object.values(actual.paths || {}).reduce((count, methods) => count + Object.keys(methods).filter(method => ['get','post','put','patch','delete','head','options','trace'].includes(method)).length, 0);
    report.callBookingsWebhook = Boolean(actual.webhooks?.['call.bookings']);
    if (report.actualSemanticSha256 !== report.expectedSemanticSha256) throw new Error('Downloaded specification does not match the reviewed source');
    report.status = 'PASS';
  } catch (error) {
    report.failures.push(error instanceof Error ? error.message : String(error));
  }
  return report;
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  const args = process.argv.slice(2);
  const arg = key => args.includes(key) ? args[args.indexOf(key) + 1] : undefined;
  const site = arg('--site');
  if (!site) throw new Error('Provide --site with the exact docs preview or published origin');
  const source = JSON.parse(fs.readFileSync(path.join(root, 'api-reference/public.openapi.json'), 'utf8'));
  const report = await checkPublicSpec(site, source);
  if (arg('--out')) fs.writeFileSync(arg('--out'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report, null, 2));
  process.exitCode = report.status === 'PASS' ? 0 : 1;
}
