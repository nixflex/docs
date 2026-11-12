// Whole-site source gate for the final coordinated tree. Historical gates stay frozen.
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {productionOnly} from './public-production-policy.mjs';
const root=path.resolve(import.meta.dirname,'..'),args=process.argv.slice(2);
const read=p=>fs.readFileSync(path.join(root,p),'utf8').replaceAll('\r\n','\n');
const json=p=>JSON.parse(read(p));
const plan=json('spec-source/c15-pages.json'),site=json('spec-source/c10-site.json'),config=json('docs.json'),spec=json('api-reference/public.openapi.json');
const result={status:'working',checks:[],failures:[],counts:{}};
const check=(ok,label)=>{result.checks.push({status:ok?'PASS':'FAIL',label});if(!ok)result.failures.push(label);};
const same=(a,b)=>JSON.stringify([...a].sort())===JSON.stringify([...b].sort());
const git=(ref,file)=>execFileSync('git',['show',ref+':'+file],{cwd:root,encoding:'utf8',maxBuffer:16e6}).replaceAll('\r\n','\n');
const flatten=v=>typeof v==='string'?[v]:Array.isArray(v)?v.flatMap(flatten):['tabs','groups','pages'].flatMap(k=>v?.[k]?flatten(v[k]):[]);
const nav=flatten(config.navigation),all=new Set(nav),api=flatten(config.navigation.tabs[2]);
const meta=(s,k)=>{const value=s.match(new RegExp('^'+k+': (.*)$','m'))?.[1];return value?JSON.parse(value):'';};
const methods=['get','post','put','patch','delete'];
const operations=o=>Object.entries(o.paths).flatMap(([route,item])=>Object.entries(item).filter(([method])=>methods.includes(method)).map(([method,operation])=>({key:method.toUpperCase()+' '+route,id:operation.operationId,operation})));
const ops=operations(spec),prior=operations(JSON.parse(git(plan.baseline,'api-reference/public.openapi.json')));
check(JSON.stringify(config.navigation.tabs.map(t=>t.tab))===JSON.stringify(['Business guide','Developer guide','API reference','SDKs & CLI','Build with AI']),'Five requested tabs in order');
const expectedGroups=['Get started','Agents','Knowledge','Phone numbers','Calls','Call actions','Bookings','Voice campaigns','SMS','Website agent','Webhooks','Integrations','Bring your own','Team','Account','Switch to Nixflex','Reference'];
check(flatten(config.navigation.tabs[4])[0]==='guides/developer/build-with-ai','Shared app/SaaS overview is first in Build with AI');
check(config.navigation.tabs.slice(0,2).every(t=>t.groups.every(g=>g.group!=='Build with AI')),'App/SaaS groups moved out of audience menus');
check(JSON.stringify(config.navigation.tabs[1].groups.map(g=>g.group))===JSON.stringify(expectedGroups),'Exact approved Developer groups and order');
check(nav.length===all.size&&same(nav,Object.keys(plan.metadata))&&same(nav,site.pages.map(p=>p.slug)),'Navigation, metadata and manifest have the same unique page set');
check(ops.length===151&&new Set(ops.map(o=>o.id)).size===151,'151 public operations with unique IDs');
check(prior.every(old=>ops.some(o=>o.key===old.key&&o.id===old.id)),'All 149 C14 operation IDs preserved');
check(same(ops.filter(o=>!prior.some(p=>p.key===o.key)).map(o=>o.key),['DELETE /calls/batch/{id}','GET /campaigns/{id}']),'Only B57 deletion and B59 campaign detail added');
const inventory=json('spec-source/public-operations.json').filter(r=>r.public).map(r=>r.method+' '+r.path.replace(/^\/v1/,'').replace(/:([A-Za-z0-9_]+)/g,'{$1}'));
check(same(inventory,ops.map(o=>o.key)),'Public inventory equals published operation set');
const titles=new Set(),descriptions=new Set(),bindings=[],incoming=new Map(),redirects=new Map(config.redirects.map(r=>[r.source,r.destination]));
const files=dir=>fs.readdirSync(path.join(root,dir),{withFileTypes:true}).flatMap(e=>e.name.startsWith('.')||['node_modules','spec-source','templates','scripts','tests'].includes(e.name)?[]:e.isDirectory()?files(path.posix.join(dir,e.name)):[path.posix.join(dir,e.name)]);
const intended=files('').filter(f=>f.endsWith('.mdx')).map(f=>f.slice(0,-4)).filter(s=>!site.excluded.includes(s));
check(same(intended,nav),'No orphan or duplicate public MDX files outside navigation');
for(const tab of config.navigation.tabs)for(const group of tab.groups||[]){
 check(group.expanded===true,tab.tab+': '+group.group+' expanded');
 if(['Business guide','Developer guide'].includes(tab.tab)&&!['Get started','Build with AI','Switch to Nixflex'].includes(group.group)){
  const first=flatten(group)[0],label=plan.metadata[first].sidebarTitle;
  check(label==='Overview'||['Bookings','Website agent','Webhooks','Team'].includes(label),tab.tab+': '+group.group+' starts with overview ('+label+')');
 }
}
for(const slug of nav){
 const text=read(slug+'.mdx'),title=meta(text,'title'),description=meta(text,'description'),label=meta(text,'sidebarTitle');
 check(productionOnly(text),slug+' production-only public content');
 check(title.length>0&&title.length<=60&&!titles.has(title.toLowerCase()),slug+' unique title <=60');titles.add(title.toLowerCase());
 check(description.length>0&&description.length<=160&&!descriptions.has(description.toLowerCase()),slug+' unique description <=160');descriptions.add(description.toLowerCase());
 check(label.split(/\s+/).length>=1&&label.split(/\s+/).length<=4,slug+' sidebar label has 1–4 words');
 check(meta(text,'canonical')==='https://docs.nixflex.com/'+(slug==='index'?'':slug),slug+' one production canonical');
 check(!/^(?:hidden|noindex):\s*true\b|^robots:.*noindex/m.test(text),slug+' has no noindex');
 const markup=text.replace(/```[^\n]*\n[\s\S]*?```/g,'');
 check(!/^# |<h1[ >]/m.test(markup),slug+' uses native single H1');
 check(!/DOCS-PENDING|pending B57|coming soon|\bTODO\b|\bTBD\b/i.test(text),slug+' complete public copy');
 check([...text.matchAll(/(?:MCP has |candidate has \*\*)(\d+) registered tools/g)].every(m=>Number(m[1])===plan.kits.mcp.tools),slug+' current MCP inventory count');
 check(!/\bclon(?:e|es|ed|ing)\b/i.test(text),slug+' removed feature absent');
 const byoc=/your-own|byo-storage/.test(slug);
 const copy=text.replace(/https?:\/\/[^\s)"<>]+/g,'');
 check(byoc||!/\b(?:anthropic|openai|groq|supabase|railway|vercel|stripe|sendgrid|assemblyai|elevenlabs)\b/i.test(copy),slug+' internal providers absent outside customer-owned connection guide');
 check(!text.includes('<style>'),slug+' shared styles');
 const plain=text.replace(/```[^\n]*\n[\s\S]*?```/g,'').replace(/`[^`\n]+`/g,'');
 check(!/(?<!-)--[a-z][a-z0-9-]*/.test(plain),slug+' literal CLI flags stay in code');
 const binding=meta(text,'openapi');
 if(binding){
  const key=binding.replace('/api-reference/public.openapi.json ','');bindings.push(key);
  const op=ops.find(o=>o.key===key);check(!!op,slug+' binds an actual public operation');
  check((text.match(/^## /gm)||[]).length===8,slug+' eight endpoint sections');
  if(op){
   const errors=text.match(/^## Errors\s*\n([\s\S]*?)(?=^## |$(?![\s\S]))/m)?.[1]||'';
   for(const [status,response]of Object.entries(op.operation.responses).filter(([status])=>Number(status)>=400)){
    const media=response.content?.['application/json'],codes=[...(media?.schema?.properties?.error?.properties?.code?.enum||[]),...[media?.example,...Object.values(media?.examples||{}).map(x=>x.value)].map(x=>x?.error?.code).filter(Boolean)];
    check(new RegExp('(?<!\\d)'+status+'(?!\\d)').test(errors)&&codes.every(code=>errors.includes(code)),slug+' describes HTTP '+status+' and its explicit codes');
   }
  }
 }
 for(const m of text.matchAll(/(?:\]\(|href=["'])(\/[^\s)"']+)/g)){
  const uri=decodeURI(m[1].split(/[?#]/)[0]),target=uri==='/'?'index':uri.slice(1).replace(/\.(?:mdx?|html)$/,'');
  check(all.has(target)||fs.existsSync(path.join(root,uri.slice(1)))||redirects.has(uri),slug+' local target exists: '+uri);
  if(all.has(target)&&target!==slug)incoming.set(target,(incoming.get(target)||0)+1);
 }
}
check(same(bindings,ops.map(o=>o.key)),'Every public operation has exactly one endpoint page');
check(config.seo?.indexing==='all'&&config.seo?.metatags?.canonical==='https://docs.nixflex.com','Global indexing and canonical origin');
check(!Object.keys(config.seo?.metatags||{}).some(k=>['title','description','og:title','og:description','og:image','twitter:title','twitter:description','twitter:image','robots'].includes(k)),'No global metadata override replaces per-page title/description/image');
check(redirects.size===config.redirects.length,'Redirect sources unique');
for(const r of config.redirects){
 const from=r.source.split('#')[0],to=r.destination.split('#')[0];
 check(from!==to,'No self redirect: '+from);check(!redirects.has(to),'No redirect chain: '+from);
 check(r.permanent===true,'Explicit permanent redirect: '+from);
 check(all.has(to==='/'?'index':to.slice(1))||fs.existsSync(path.join(root,to.slice(1)))||from.includes(':')||/^https:/.test(to),'Redirect target exists: '+from);
 check(!all.has(from==='/'?'index':from.slice(1)),'Redirect does not shadow a current page: '+from);
}
for(const [b,d]of Object.entries(plan.audiencePairs)){
 check(read(b+'.mdx').includes('(/'+d+')'),b+' links to its Developer guide');
 check(read(d+'.mdx').includes('(/'+b+')'),d+' links back to '+b);
}
for(const [old,target]of Object.entries(plan.retired)){
 check(!fs.existsSync(path.join(root,old+'.mdx'))&&redirects.get('/'+old)==='/'+target,old+' consolidated with direct redirect');
}
const tracked=execFileSync('git',['ls-tree','-r','--name-only',plan.baseline,'tests','scripts'],{cwd:root,encoding:'utf8'}).trim().split(/\r?\n/);
const locked=tracked.filter(p=>p.startsWith('tests/')||/\/(?:check-|validate-|C[3-8]-TEST)/.test(p)||p==='scripts/c11-content-policy.mjs');
// C271451 is the live C16 baseline. Fahim approved C17 changes only to
// production-only examples and the renamed/moved Build with AI navigation.
for(const file of locked){
 const approved=plan.approvedC17LockedHashes?.[file];
 const unchanged=approved?createHash('sha256').update(read(file)).digest('hex')===approved:read(file)===git(plan.lockedBaseline,file);
 check(unchanged,file+' matches live C16 baseline or exact approved C17 edit');
}
for(const file of ['docs.json','api-reference/public.openapi.json',...files('snippets').filter(f=>f!=='snippets/snippet-intro.mdx')]){
 check(productionOnly(read(file)),file+' production-only public asset');
}
for(const file of new Set(Object.values(plan.sources)))check(productionOnly(read(file)),file+' production-only active authoring source');
check(fs.existsSync(path.join(root,'logo/light.svg'))&&fs.existsSync(path.join(root,'logo/dark.svg'))&&read('favicon.svg').includes('#050706'),'Final voice-ring logo assets present');
check(read('.mintignore').includes('spec-source/')&&read('.mintignore').includes('scripts/')&&read('.mintignore').includes('DOCS-STYLE-GUIDE.md'),'Authoring sources excluded from public output');
result.counts={pages:nav.length,apiPages:api.length,operations:ops.length,authoredSources:Object.keys(plan.sources).length,audiencePairs:Object.keys(plan.audiencePairs).length,lockedFiles:locked.length,redirects:redirects.size,checks:result.checks.length,tabs:Object.fromEntries(config.navigation.tabs.map(t=>[t.tab,flatten(t).length]))};
result.pagesWithoutBodyInboundLink=nav.filter(s=>!incoming.has(s));
result.status=result.failures.length?'FAIL':'PASS';
if(args.includes('--out'))fs.writeFileSync(args[args.indexOf('--out')+1],JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({status:result.status,counts:result.counts,failures:result.failures,withoutBodyInbound:result.pagesWithoutBodyInboundLink},null,2));process.exitCode=result.failures.length?1:0;
