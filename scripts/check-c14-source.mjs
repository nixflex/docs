// Independent C14 scope gate. Historical tests and validators remain unchanged.
// Extends the accepted C13 invariants to all Developer/client pages and the exact D6 merge.
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {supplierLeak,unreviewedCarrierCopy} from './c11-content-policy.mjs';
const root=path.resolve(import.meta.dirname,'..'),args=process.argv.slice(2);
const read=p=>fs.readFileSync(path.join(root,p),'utf8'),json=p=>JSON.parse(read(p));
const c14=json('spec-source/c14-pages.json');
const plan=json('spec-source/c13-pages.json'),site=json('spec-source/c10-site.json'),config=json('docs.json'),spec=json('api-reference/public.openapi.json');
const result={status:'PASS',checks:[],failures:[],counts:{}};
const check=(ok,label)=>{result.checks.push({status:ok?'PASS':'FAIL',label});if(!ok)result.failures.push(label);};
const same=(a,b)=>JSON.stringify([...a].sort())===JSON.stringify([...b].sort());
const meta=(s,k)=>{const m=s.match(new RegExp('^'+k+': (.*)$','m'));return m?JSON.parse(m[1]):'';};
const git=(ref,p)=>execFileSync('git',['show',ref+':'+p],{cwd:root,encoding:'utf8',maxBuffer:12*1024*1024}).replace(/\r\n/g,'\n');
const methods=['get','post','put','patch','delete'];
const operations=s=>Object.entries(s.paths).flatMap(([p,ops])=>Object.entries(ops).filter(([m])=>methods.includes(m)).map(([m,op])=>({key:m+' '+p,id:op.operationId})));
const ops=operations(spec),previous=operations(JSON.parse(git('1dce38d','api-reference/public.openapi.json')));
check(ops.length===149&&new Set(ops.map(o=>o.id)).size===149,'149 unique public operation IDs');
check(previous.every(o=>ops.some(n=>n.key===o.key&&n.id===o.id)),'All 147 existing operation IDs preserved');
check(same(ops.filter(o=>!previous.some(p=>p.key===o.key)).map(o=>o.key),['get /calls/{id}/bookings','get /calls/outbound/requests/{request_id}']),'Only the two authorised B56 operations were added');
const flatten=v=>typeof v==='string'?[v]:Array.isArray(v)?v.flatMap(flatten):['tabs','groups','pages'].flatMap(k=>v?.[k]?flatten(v[k]):[]);
const nav=flatten(config.navigation),api=flatten(config.navigation.tabs.find(t=>t.tab==='API reference'));
check(nav.length===306&&new Set(nav).size===306&&same(nav,site.pages.map(p=>p.slug)),'306 unique pages exactly match the whole-site manifest');
check(api.length===162&&same(api,plan.api.map(p=>p.slug)),'162 API pages exactly match the editorial plan');
check(same(plan.developerSamples,['quickstart','actions/booking-confirmation','actions/google-calendar','guides/developer/call-history','advanced/webhooks']),'Original five accepted Developer sample routes preserved');
let groups=0;function visit(v){if(Array.isArray(v))v.forEach(visit);else if(v&&typeof v==='object'){if(v.group){groups++;check(v.expanded===true,'Expanded navigation: '+v.group);}Object.values(v).forEach(visit);}}visit(config.navigation);
const titles=new Set(),descriptions=new Set(),bindings=[];
for(const row of site.pages){
 const s=read(row.slug+'.mdx'),title=meta(s,'title'),description=meta(s,'description');
 check(title.length>0&&title.length<=60&&!titles.has(title.toLowerCase()),row.slug+' unique title <=60');titles.add(title.toLowerCase());
 check(description.length>0&&description.length<=160&&!descriptions.has(description.toLowerCase()),row.slug+' unique description <=160');descriptions.add(description.toLowerCase());
 check(meta(s,'canonical')==='https://docs.nixflex.com/'+row.slug,row.slug+' production canonical');
 check(!supplierLeak(row.slug,s),row.slug+' white-label model/speech copy');
 check(!/\bclon(?:e|es|ed|ing)\b/i.test(s),row.slug+' no removed voice-feature wording in public copy');
 const flagProse=s.replace(/```[^\n]*\n[\s\S]*?```/g,'').replace(/`[^`\n]+`/g,'');
 check(!/(?<!-)--[a-z][a-z0-9-]*/.test(flagProse),row.slug+' keeps CLI flags in code so typography cannot change their spelling');
 if(row.owner==='D'){
  check(s.replace(/\r\n/g,'\n')===git(site.ownershipBaseline,row.slug+'.mdx'),row.slug+' accepted D6 content unchanged');
  check(!unreviewedCarrierCopy(row.slug,s),row.slug+' approved carrier wording');
 }
 if(row.tab==='API reference'||c14.pages.some(p=>p.slug===row.slug)){
  check(['nxf-facts','nxf-important','nxf-audience'].every(c=>(s.match(new RegExp('className="'+c+'"','g'))||[]).length===1),row.slug+' exactly one facts panel, key-point panel and audience switch');
  check(meta(s,'sidebarTitle').length>0&&meta(s,'sidebarTitle').length<=36,row.slug+' short sidebar title');
  check(!s.includes('<style>'),row.slug+' shared styles only');
  const markup=s.replace(/```[^\n]*\n[\s\S]*?```/g,'');
  const imports=[...markup.matchAll(/^import\s+[^\n]+?from\s+["']([^"']+)["'];?/gm)].map(m=>m[1]);
  check(imports.every(p=>p.startsWith('/')||p.startsWith('./')||p.startsWith('../')),row.slug+' page imports stay local; SDK imports remain inside examples');
  const editorial=plan.api.find(p=>p.slug===row.slug);
  if(editorial){
   check(s.includes('](/'+editorial.business+')')&&s.includes('](/'+editorial.developer+')'),row.slug+' audience links');
   check(editorial.important.length>=2&&editorial.important.length<=4,row.slug+' two to four reviewed key points');
   if(editorial.method){
    bindings.push(editorial.method.toLowerCase()+' '+editorial.path);
    check((s.match(/^## /gm)||[]).length===8,row.slug+' preserves eight endpoint sections');
    check(/What to do|Recovery|Handling/.test(s),row.slug+' recovery guidance beside errors');
    const errorSection=s.match(/^## Errors\s*\n([\s\S]*?)(?=^## |$(?![\s\S]))/m)?.[1]||'';
    for(const [status,response]of Object.entries(spec.paths[editorial.path][editorial.method.toLowerCase()].responses).filter(([status])=>Number(status)>=400)){
     const media=response.content?.['application/json'];
     const codes=[...(media?.schema?.properties?.error?.properties?.code?.enum||[]),...[media?.example,...Object.values(media?.examples||{}).map(e=>e.value)].map(e=>e?.error?.code).filter(Boolean)];
     check(new RegExp('(?<!\\d)'+status+'(?!\\d)').test(errorSection)&&codes.every(code=>errorSection.includes(code)),row.slug+' error '+status+' and explicit codes have page guidance');
    }
   }
  }
 }
}
check(same(bindings,ops.map(o=>o.key)),'Every public operation has exactly one endpoint page');
const catalog=read('api-reference/errors.mdx'),ids=[...catalog.matchAll(/<span id="([^"]+)"/g)].map(m=>m[1]);
check(new Set(ids).size===ids.length,'Error catalog anchors are unique');
for(const line of read('spec-source/c13-concepts/errors.mdx.txt').split(/\r?\n/)){
 const match=line.match(/^\| <span id="([a-z_]+)">/),columns=line.split('|');
 if(!match||columns.length!==6)continue;
 const generated=catalog.split(/\r?\n/).find(row=>row.startsWith('| <span id="'+match[1]+'">'));
 check(generated?.split('|')[3].trim()===columns[3].trim(),match[1]+' retains its error meaning separately from recovery');
}
for(const r of config.redirects.filter(r=>r.source.startsWith('/errors/')&&!r.source.includes(':')))check(ids.includes(r.destination.split('#')[1]),r.source+' resolves to an explicit error anchor');
const originalConfig=JSON.parse(git('1dce38d','docs.json'));
check(JSON.stringify(config.contextual)===JSON.stringify(originalConfig.contextual),'Existing real contextual menu preserved');
check(same(config.navigation.tabs.map(t=>t.tab),originalConfig.navigation.tabs.map(t=>t.tab)),'Five existing tabs preserved');
const c14Slugs=c14.pages.map(p=>p.slug);
check(c14Slugs.length===95&&new Set(c14Slugs).size===95,'95 unique authored Developer/client sources');
check(same(c14Slugs,site.pages.filter(p=>['Developer guide','SDKs & CLI'].includes(p.tab)).map(p=>p.slug)),'Every Developer and client page has an authoritative C14 source');
check(c14.newPages.length===22&&new Set(c14.newPages).size===22,'22 complete new task pages');
check(site.pages.filter(p=>p.tab==='Developer guide').length===87,'87 Developer pages');
check(site.pages.filter(p=>p.tab==='SDKs & CLI').length===8,'Eight SDK/CLI/MCP pages');
check(site.pages.filter(p=>p.owner==='D').length===49,'49 accepted D-owned pages');
check(read('api-reference/public.openapi.json').replaceAll('\r\n','\n')===git(c14.baseline,'api-reference/public.openapi.json'),'Public OpenAPI remains the reviewed B56 contract; no guessed B57 semantics');
for(const row of c14.pages){
 const source=read(row.source),page=read(row.slug+'.mdx');
 check(source.length>1000,row.slug+' substantive immutable source');
 check(['written_and_reviewed','body_reviewed_and_rewritten','accepted_sample_reviewed'].includes(row.review),row.slug+' editorial review recorded');
 const facts=source.match(/<div className="nxf-facts">([\s\S]*?)\n<\/div>/)?.[1]||'';
 const important=source.match(/<div className="nxf-important">([\s\S]*?)\n<\/div>/)?.[1]||'';
 check((facts.match(/<small>/g)||[]).length>=2&&(facts.match(/<small>/g)||[]).length<=4,row.slug+' two to four facts');
 check((important.match(/^- /gm)||[]).length>=2&&(important.match(/^- /gm)||[]).length<=4,row.slug+' two to four key points');
 check(source.includes('](/guides/glossary)')&&source.includes('[Business guide]('),row.slug+' audience and glossary links');
 check(!/TODO|TBD|coming soon|round [23]/i.test(source),row.slug+' no unfinished public prose');
 check(!/\bclon(?:e|es|ed|ing)\b/i.test(page),row.slug+' no removed voice-feature wording');
}
for(const slug of c14.pendingDeletionPages)check(read(slug+'.mdx').includes('DOCS-PENDING'),slug+' explicit B57 pending note');
const tracked=execFileSync('git',['ls-tree','-r','--name-only',c14.baseline,'tests','scripts'],{cwd:root,encoding:'utf8'}).trim().split(/\r?\n/);
const locked=tracked.filter(p=>p.startsWith('tests/')||/\/(?:check-|validate-|C[3-8]-TEST)/.test(p)||p==='scripts/c11-content-policy.mjs');
for(const p of locked)check(read(p).replace(/\r\n/g,'\n')===git(c14.baseline,p),p+' frozen at the approved C13 baseline');
for(const p of ['DOCS-STYLE-GUIDE.md','FEATURE-PAGES-PLAN.md','templates/business.mdx.template','templates/developer.mdx.template','templates/api-endpoint.mdx.template','templates/webhook-event.mdx.template'])check(fs.existsSync(path.join(root,p)),p+' permanent authoring resource');
check(read('.mintignore').includes('templates/')&&read('.mintignore').includes('DOCS-STYLE-GUIDE.md'),'Authoring resources excluded from publication');
result.counts={pages:nav.length,apiPages:api.length,operations:ops.length,developerPages:87,clientPages:8,authoredPages:c14Slugs.length,newPages:c14.newPages.length,pendingDeletionPages:c14.pendingDeletionPages.length,dOwned:site.pages.filter(p=>p.owner==='D').length,expandedGroups:groups,lockedFiles:locked.length};
result.status=result.failures.length?'FAIL':'PASS';
if(args.includes('--out'))fs.writeFileSync(args[args.indexOf('--out')+1],JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({status:result.status,counts:result.counts,failures:result.failures},null,2));
process.exitCode=result.failures.length?1:0;
