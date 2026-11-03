// Run after build-c4/c5/c6/c8-pages and build-public-openapi.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {sample} from './c8-page-content.mjs';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const write=(p,s)=>{const file=path.join(root,p);if(!fs.existsSync(file)||fs.readFileSync(file,'utf8')!==s)fs.writeFileSync(file,s);};
const json=p=>JSON.parse(read(p));
const plan=json('spec-source/c9-pages.json'), spec=json('api-reference/public.openapi.json');
const safe=s=>String(s??'').replaceAll('|','&#124;').replaceAll('\n',' ');
const table=(heads,rows)=>'| '+heads.join(' | ')+' |\n| '+heads.map(()=>'---').join(' | ')+' |\n'+rows.map(r=>'| '+r.map(safe).join(' | ')+' |').join('\n');
const type=s=>Array.isArray(s.type)?s.type.join(' or '):s.type||(s.anyOf||s.oneOf?'alternative shapes':'value');
const limits=s=>[s.description,s.enum?'Allowed: '+s.enum.join(', '):'',s.maximum!==undefined?'Maximum '+s.maximum:'',s.minimum!==undefined?'Minimum '+s.minimum:'',s.maxLength?'At most '+s.maxLength+' characters':'',s.default!==undefined?'Default: '+JSON.stringify(s.default):''].filter(Boolean).join(' ');
function fields(s,p='',depth=0){
 if(depth>5)return [];
 if(s.anyOf||s.oneOf)return (s.anyOf||s.oneOf).flatMap(b=>fields(b,p,depth+1));
 if(s.type==='array')return [[p||'[]','array',limits(s)||'Returned items.'],...fields(s.items||{},p+'[]',depth+1)];
 return Object.entries(s.properties||{}).flatMap(([n,v])=>{const key=p?p+'.'+n:n;return [['`'+key+'`',type(v),limits(v)||((s.required||[]).includes(n)?'Always returned.':'Optional saved value.')],...(v.properties||v.items?fields(v.items||v,v.items?key+'[]':key,depth+1):[])];});
}
const code=(lang,label,text)=>'```'+lang+' '+label+'\n'+text+'\n```';
for(const d of json('spec-source/c9-manual-pages.json')){
 const row=plan.pages.find(p=>p.slug===d.slug),op=spec.paths[d.path][d.method.toLowerCase()];
 const success=Object.entries(op.responses).find(([s])=>/^2\d\d$/.test(s));
 const rs=success[1].content?.['application/json']?.schema||{};
 const request=op.requestBody?.content?.['application/json']?.schema;
 const requestTable=request?table(['Field','Type','Required','Default','Limits and meaning'],Object.entries(request.properties||{}).map(([n,s])=>['`'+n+'`',type(s),(request.required||[]).includes(n)?'Yes':'No',s.default!==undefined?JSON.stringify(s.default):d.method==='PUT'?'Unchanged':'Omitted',limits(s)])):'';
 const params=table(['Field','Type','Required','Default and limits'],(op.parameters||[]).map(p=>['`'+p.name+'` ('+p.in+')',type(p.schema),p.required?'Yes':'No',limits({...p.schema,description:p.description||p.schema.description})]));
 const url='https://api.nixflex.com/v1'+d.path.replace(/\{([^}]+)\}/g,(_,p)=>p==='phoneNumber'?'%2B12025550123':p==='callerNumber'?'%2B12025550101':p==='id'&&d.path.startsWith('/agents')?'agent_example':'call_example');
 const body=d.exampleBody;
 const curl=`curl --request ${d.method} \\\n+  --url '${url}' \\\n+  --header "Authorization: Bearer $NXF_API_KEY"`+(body?` \\\n+  --header 'Content-Type: application/json' \\\n+  --data '${JSON.stringify(body)}'`:'');
 const node=`const response = await fetch('${url}', {\n  method: '${d.method}',\n  headers: { Authorization: \`Bearer \${process.env.NXF_API_KEY}\`${body?", 'Content-Type': 'application/json'":''} },${body?'\n  body: JSON.stringify('+JSON.stringify(body)+'),':''}\n});\nif (!response.ok) throw new Error(\`HTTP \${response.status}\`);\nconst result = await response.json();\n// Handle the private result without logging it.`;
 const py=`import os, json\nfrom urllib.request import Request, urlopen\n\nrequest = Request('${url}', method='${d.method}',\n    headers={'Authorization': 'Bearer ' + os.environ['NXF_API_KEY']${body?", 'Content-Type': 'application/json'":''}}${body?',\n    data=json.dumps('+JSON.stringify(body)+').encode("utf-8")':''})\nwith urlopen(request, timeout=30) as response:\n    result = json.load(response)\n# Handle the private result without logging it.`;
 const ps=`$headers = @{ Authorization = "Bearer $env:NXF_API_KEY" }\n${body?"$body = '"+JSON.stringify(body)+"'\n":''}$result = Invoke-RestMethod -Method ${d.method} -Uri '${url}' -Headers $headers -DisableKeepAlive${body?' -ContentType "application/json" -Body ([Text.Encoding]::UTF8.GetBytes($body))':''}\n# Handle $result privately.`;
 const errs=table(['Status','Meaning'],Object.entries(op.responses).filter(([s])=>Number(s)>=400).map(([s,r])=>[s,r.description]));
 const response=d.exampleResponse??sample(rs);
 write(d.slug+'.mdx','---\ntitle: '+JSON.stringify(row.title)+'\ndescription: '+JSON.stringify(row.description)+'\nopenapi: '+JSON.stringify('/api-reference/public.openapi.json '+d.method+' '+d.path)+'\nplayground: "simple"\n---\n\n'+d.summary+'\n\n## Authentication\n\nUse `Authorization: Bearer KEY_ID:KEY_SECRET` for the owning account. An organisation API key has Owner authority. Personal sessions use the role rules documented in [Authentication](/api-reference/authentication); do not treat a Member session as an API key.\n\n## Request fields\n\n'+params+'\n\n'+(request?requestTable:'Do not send a request body.')+'\n\n'+d.notes+'\n\n## Response fields\n\n`'+success[0]+'` returns the following shape.\n\n'+table(['Field','Type','Meaning'],fields(rs))+'\n\n'+d.responseNotes+'\n\n## Example request\n\nProduction HTTP examples. Replace the placeholder identifiers with resources owned by the account. Set `NXF_API_KEY` privately; never print it.\n\n<RequestExample>\n\n'+[code('bash','cURL (Bash)',curl),code('javascript','Node (HTTP)',node),code('python','Python (HTTP)',py),code('powershell','PowerShell (HTTP)',ps)].join('\n\n')+'\n\n</RequestExample>\n\n## Example response\n\nIllustrative response with placeholder identifiers.\n\n<ResponseExample>\n\n'+code('json','Response',JSON.stringify(response,null,2))+'\n\n</ResponseExample>\n\n## Errors\n\nBranch on `error.code`, not the wording of `error.message`. The envelope includes `type`, `code`, `message`, `doc_url` and `details`.\n\n'+errs+'\n\n'+d.errorNotes+'\n\n## Retry and idempotency\n\n'+(d.method==='GET'?'Use bounded retries only for temporary read failures. Keep the same filters while paging.':'Disable automatic write retries. A lost response leaves the result uncertain; read the affected resource before another deliberate action. No general Idempotency-Key replay guarantee applies.')+' See [retry rules](/api-reference/retries).\n\n## Related endpoints\n\n- [API overview](/api-reference/introduction)\n- [Errors and recovery](/api-reference/errors)\n- [Pagination](/api-reference/pagination)\n');
}
const config=json('docs.json');
config.navigation.tabs.find(t=>t.tab==='API reference').groups=plan.groups;
write('docs.json',JSON.stringify(config,null,2)+'\n');
for(const row of plan.pages){
 let text=read(row.slug+'.mdx');
 const parts=text.split(/^---\s*$/m);let fm=parts[1];
 for(const [key,value] of Object.entries({title:row.title,sidebarTitle:row.slug.endsWith('/google-calendar')?'Google Calendar (coming)':row.title,description:row.description,canonical:plan.canonicalOrigin+'/'+row.slug})){
  const line=key+': '+JSON.stringify(value),pattern=new RegExp('^'+key+':.*$','m');fm=pattern.test(fm)?fm.replace(pattern,line):fm.trimEnd()+'\n'+line+'\n';
 }
 parts[1]=fm; text=parts.join('---');
 text=text.replaceAll('This successful operation is pending manual test; the C8 check does not run it.','Review the request before changing state and disable automatic write retries.');
  text=text.replaceAll('This is a successful-write example, pending manual test. Run it only with an approved disposable fixture.','This example changes state. Review the target and payload before running it.');
  text=text.replaceAll('This successful write remains pending manual test.','Review the target and payload before this write.');
  text=text.replaceAll('Successful retrieval is pending manual test; do not use an assistant or smoke test to retrieve it.','Retrieve it privately through the Owner workflow.');
  text=text.replaceAll('C8’s no-write smoke test leaves this read pending manual test.','Treat this GET as an intentional action because it can persist repairs.');
  text=text.replace(/\bK[2345] examples/g,'These examples').replace(/\bK[2345] candidates/g,'client candidates');
 text=text.replace(/\bThe K4 MCP\b/g,'The MCP').replaceAll('/advanced/webhooks','/api-reference/webhooks');
 write(row.slug+'.mdx',text);
 const match=fm.match(/^openapi:\s*"[^"\n]*? (GET|POST|PUT|PATCH|DELETE) ([^"\n]+)"/m);
 if(match)spec.paths[match[2]][match[1].toLowerCase()].summary=row.title;
}
write('api-reference/public.openapi.json',JSON.stringify(spec,null,2)+'\n');
console.log('Applied '+plan.pages.length+' API titles, descriptions, canonicals and navigation; built 10 legacy endpoint templates.');
