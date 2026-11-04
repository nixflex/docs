import {test} from 'node:test';import a from 'node:assert/strict';import {readLegacyFileSync} from './support/read-legacy-spec.mjs'; const fs = {readFileSync:readLegacyFileSync};
test('organisation draft keeps safety blockers, single balance/key, personal auth and honest delivery visible',()=>{
 const text=fs.readFileSync('concepts/organisations.mdx','utf8');
 for(const s of ['share agents, phone numbers, work and balance','personal login is not its shared API credential','24 hours','50 seats','20 new or resent','disconnection pending','committed human takeover','personal Owner dashboard flow','410 dashboard_owner_required','accepted closure is not proof'])a.ok(text.includes(s),s);
 a.ok(fs.readFileSync('api-reference/organisation/roles.mdx','utf8').includes('live_disconnect_pending'));
});
test('organisation OpenAPI external paths resolve and do not offer key-based personal owner actions',()=>{
 const root=JSON.parse(fs.readFileSync('api-reference/openapi.json')),part=JSON.parse(fs.readFileSync('api-reference/organisations.openapi.json'));
 for(const [path,ops]of Object.entries(part.paths)){a.ok(root.paths[path].$ref.includes('organisations.openapi.json'));for(const op of Object.values(ops)){a.ok(op.responses['403']);a.ok(op.responses['503'])}}
 a.ok(Object.keys(part.paths).every(p=>!/leave|transfer|account\/delete/.test(p)));a.ok(part.paths['/organisation/activity'].get.responses['200'].content['text/csv']);
});
