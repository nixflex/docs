import { test } from 'node:test';
import a from 'node:assert/strict';
import {readLegacyFileSync as readFileSync} from './support/read-legacy-spec.mjs';
const read=p=>readFileSync(new URL('../'+p,import.meta.url),'utf8');
test('calls safety draft aligns four client variables and one-attempt policy',()=>{
  const safety=read('api-reference/calls/client-safety.mdx'),outbound=read('api-reference/calls/create-outbound.mdx');
  for(const term of ['dynamic_vars','{{name}}','CLI','Python','MCP','POST/PUT/PATCH/DELETE','NixflexOutcomeUnknownError','1–200'])a.ok(safety.includes(term),term);
  a.match(safety,/not\s+a\s+snapshot/);
  a.match(outbound,/client-safety/);a.doesNotMatch(outbound,/stored nowhere/);
  a.match(safety,/not an exactly-once/);a.match(safety,/not a claim/);
  a.match(read('sdks/python.mdx'),/GET-only/);a.doesNotMatch(read('sdks/python.mdx'),/GET\/HEAD/);
});
test('single deletion resumes queued hang-up while bulk deletion keeps its guarded contract',()=>{
  const one=read('api-reference/calls/delete.mdx'),all=read('api-reference/calls/delete-all.mdx');
  for(const term of ['hangup_pending','retry_pending','deletion_unavailable','recording_cleanup','carrier_best_effort'])a.ok(one.includes(term));
  a.match(all,/does \*\*not\*\* delete SMS/);a.match(all,/safe_to_retry=false/);
  a.match(one,/does not certify carrier erasure/);a.match(all,/not proof/);
  a.doesNotMatch(one,/removed immediately/);a.doesNotMatch(all,/once everything is gone/);
});
test('OpenAPI only describes canonical variables and guarded deletion; safety page is navigable',()=>{
  const spec=JSON.parse(read('api-reference/openapi.json'));
  a.match(spec.components.schemas.OutboundCallCreate.properties.dynamic_vars.description,/\{\{name\}\}/);
  a.match(spec.paths['/calls'].delete.description,/does not delete SMS/);
  a.match(spec.paths['/calls/{id}'].delete.description,/409\/503/);
  a.ok(JSON.parse(read('docs.json')));a.ok(read('docs.json').includes('api-reference/calls/client-safety'));
});
