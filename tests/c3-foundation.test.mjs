import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const json=p=>JSON.parse(read(p));
const config=json('docs.json'), spec=json('api-reference/public.openapi.json');
const allow=json('spec-source/public-operations.json');
const shape=p=>p.replace(/^\/v1/,'').replace(/:[^/]+|\{[^}]+\}/g,'{}');
const walk=d=>fs.readdirSync(path.join(root,d),{withFileTypes:true}).flatMap(e=>e.name.startsWith('.')||e.name==='node_modules'?[]:e.isDirectory()?walk(path.posix.join(d,e.name)):[path.posix.join(d,e.name)]);
const pages=walk('').filter(p=>p.endsWith('.mdx')&&!['api-reference/phone-numbers/monitor.mdx','snippets/snippet-intro.mdx'].includes(p));
const strings=v=>typeof v==='string'?[v]:v&&typeof v==='object'?Object.values(v).flatMap(strings):[];
const menu=strings(config.navigation);
const brand=/twilio|telnyx|openai|anthropic|deepgram|inworld|elevenlabs|supabase|groq/i;
function meta(text,key){const fm=text.match(/^---\r?\n([\s\S]*?)\r?\n---/)?.[1]||'';const raw=fm.match(new RegExp('^'+key+':\\s*(.*)$','m'))?.[1]?.trim()||'';return raw.startsWith('"')?JSON.parse(raw):raw.replace(/^'|'$/g,'');}
test('deployed bundle contains only allowlisted operations, unique IDs, no refs or provider names',()=>{
  assert.equal(spec.openapi,'3.1.0');assert.equal(allow.length,192);
  const approved=new Set(allow.filter(r=>r.public).map(r=>r.method+' '+shape(r.path)));
  const ids=new Set();for(const [p,ms]of Object.entries(spec.paths))for(const [m,op]of Object.entries(ms)){
    assert.ok(approved.has(m.toUpperCase()+' '+shape(p)),m+' '+p);assert.ok(op.operationId);assert.ok(!ids.has(op.operationId));ids.add(op.operationId);
  }
  assert.equal(ids.size,142);assert.doesNotMatch(JSON.stringify(spec),/"\$ref"/);assert.doesNotMatch(JSON.stringify(spec),brand);
  assert.equal(spec.paths['/keys'].post.security.length,0);
  assert.ok(spec.paths['/account/retention'].get);assert.ok(spec.paths['/organisation/name'].patch);
});
test('Create sample uses the bundle, preserves nine sections and normal defaults',()=>{
  const page=read('api-reference/agents/create.mdx');assert.match(page,/openapi: "\/api-reference\/public.openapi.json POST \/agents"/);
  assert.equal((page.match(/^## /gm)||[]).length,8); // Summary paragraph plus eight titled sections.
  assert.match(page,/Create an agent and receive its/);
  const op=spec.paths['/agents'].post, s=op.requestBody.content['application/json'].schema;
  assert.ok(!s.required?.length);assert.equal(s.properties.max_call_duration_seconds.default,300);
  assert.equal(s.properties.silence_hangup_seconds.default,10);assert.equal(s.properties.dynamic_greeting.default,true);
  assert.equal(s.properties.call_retention_days,undefined);assert.ok(op.responses['201']);
});
test('every intended MDX page is in the menu; titles unique and changed metadata sized',()=>{
  const titles=new Set();const extra=['concepts/voices.mdx','concepts/phone-numbers.mdx','actions/ivr-navigation.mdx','best-practices/ivr-navigation.mdx','advanced/your-own-llm.mdx','integrations/twilio.mdx','integrations/telnyx.mdx','sdks/ecosystem.mdx','sdks/other-languages.mdx'];
  for(const p of pages){assert.ok(menu.includes(p.slice(0,-4)),p+' is orphaned');const body=read(p),title=meta(body,'title'),description=meta(body,'description');assert.ok(title);assert.ok(!titles.has(title.toLowerCase()),title);titles.add(title.toLowerCase());assert.doesNotMatch(title+' '+description+' '+meta(body,'sidebarTitle'),brand);
    if(p.startsWith('api-reference/')||extra.includes(p)){assert.ok(title.length>=50&&title.length<=60,p+' title '+title.length);assert.ok(description.length>=130&&description.length<=160,p+' description '+description.length);}
  }
  assert.equal(config.seo.indexing,'all');assert.doesNotMatch(JSON.stringify(config.seo),brand);
});
test('engine error links and removed spec URLs have valid draft targets',()=>{
  const page=read('api-reference/errors.mdx'), anchors=[...page.matchAll(/<span id="([^"]+)"/g)].map(m=>m[1]);assert.equal(new Set(anchors).size,anchors.length);assert.ok(anchors.length>=253);
  for(const r of config.redirects.filter(r=>r.source.startsWith('/errors/')&&!r.source.includes(':'))){assert.ok(r.destination.startsWith('/api-reference/errors#'));assert.ok(anchors.includes(r.destination.split('#')[1]),r.source);}
  assert.ok(config.redirects.some(r=>r.source==='/errors/:code'&&r.destination==='/api-reference/errors#catalog'));
  for(const p of ['openapi.json','call-reads.openapi.json','organisations.openapi.json','phone-number-move.json','phone-number-reads.json','phone-number-usage.json','schemas/agent-extraction.json','schemas/agent-list-parameters.json','schemas/agent-request.json','schemas/agent-response.json','schemas/agent-update.json'])assert.ok(config.redirects.some(r=>r.source==='/api-reference/'+p&&r.destination==='/api-reference/public.openapi.json'),p);
});
