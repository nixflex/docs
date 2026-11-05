// Independent C13 scope gate. This never changes or overrides the locked historical gates.
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {supplierLeak,unreviewedCarrierCopy} from './c11-content-policy.mjs';
const root=path.resolve(import.meta.dirname,'..'),args=process.argv.slice(2);
const read=p=>fs.readFileSync(path.join(root,p),'utf8'),json=p=>JSON.parse(read(p));
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
check(nav.length===279&&new Set(nav).size===279&&same(nav,site.pages.map(p=>p.slug)),'279 unique pages exactly match the whole-site manifest');
check(api.length===162&&same(api,plan.api.map(p=>p.slug)),'162 API pages exactly match the editorial plan');
check(same(plan.developerSamples,['quickstart','actions/booking-confirmation','actions/google-calendar','guides/developer/call-history','advanced/webhooks']),'Exactly five selected Developer samples');
let groups=0;function visit(v){if(Array.isArray(v))v.forEach(visit);else if(v&&typeof v==='object'){if(v.group){groups++;check(v.expanded===true,'Expanded navigation: '+v.group);}Object.values(v).forEach(visit);}}visit(config.navigation);
const titles=new Set(),descriptions=new Set(),bindings=[];
for(const row of site.pages){
 const s=read(row.slug+'.mdx'),title=meta(s,'title'),description=meta(s,'description');
 check(title.length>0&&title.length<=60&&!titles.has(title.toLowerCase()),row.slug+' unique title <=60');titles.add(title.toLowerCase());
 check(description.length>0&&description.length<=160&&!descriptions.has(description.toLowerCase()),row.slug+' unique description <=160');descriptions.add(description.toLowerCase());
 check(meta(s,'canonical')==='https://docs.nixflex.com/'+row.slug,row.slug+' production canonical');
 check(!supplierLeak(row.slug,s),row.slug+' white-label model/speech copy');
 if(row.owner==='D'){
  check(s.replace(/\r\n/g,'\n')===git(site.ownershipBaseline,row.slug+'.mdx'),row.slug+' D5 content unchanged');
  check(!unreviewedCarrierCopy(row.slug,s),row.slug+' approved carrier wording');
 }
 if(row.tab==='API reference'||plan.developerSamples.includes(row.slug)){
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
   }
  }
 }
}
check(same(bindings,ops.map(o=>o.key)),'Every public operation has exactly one endpoint page');
const catalog=read('api-reference/errors.mdx'),ids=[...catalog.matchAll(/<span id="([^"]+)"/g)].map(m=>m[1]);
check(new Set(ids).size===ids.length,'Error catalog anchors are unique');
for(const r of config.redirects.filter(r=>r.source.startsWith('/errors/')&&!r.source.includes(':')))check(ids.includes(r.destination.split('#')[1]),r.source+' resolves to an explicit error anchor');
const originalConfig=JSON.parse(git('1dce38d','docs.json'));
check(JSON.stringify(config.contextual)===JSON.stringify(originalConfig.contextual),'Existing real contextual menu preserved');
check(same(config.navigation.tabs.map(t=>t.tab),originalConfig.navigation.tabs.map(t=>t.tab)),'Five existing tabs preserved');
const changed=execFileSync('git',['diff','--name-only','1dce38d','--','*.mdx'],{cwd:root,encoding:'utf8'}).trim().split(/\r?\n/).filter(Boolean);
check(changed.filter(p=>!p.startsWith('api-reference/')).every(p=>plan.developerSamples.includes(p.slice(0,-4))),'No additional Developer, SDK or D-owned page rewritten');
const tracked=execFileSync('git',['ls-tree','-r','--name-only','1dce38d','tests','scripts'],{cwd:root,encoding:'utf8'}).trim().split(/\r?\n/);
const locked=tracked.filter(p=>p.startsWith('tests/')||/\/(?:check-|validate-|C[3-8]-TEST)/.test(p));
for(const p of locked)check(read(p).replace(/\r\n/g,'\n')===git('1dce38d',p),p+' frozen after approved C12 correction');
for(const p of ['DOCS-STYLE-GUIDE.md','FEATURE-PAGES-PLAN.md','templates/business.mdx.template','templates/developer.mdx.template','templates/api-endpoint.mdx.template','templates/webhook-event.mdx.template'])check(fs.existsSync(path.join(root,p)),p+' permanent authoring resource');
check(read('.mintignore').includes('templates/')&&read('.mintignore').includes('DOCS-STYLE-GUIDE.md'),'Authoring resources excluded from publication');
result.counts={pages:nav.length,apiPages:api.length,operations:ops.length,developerSamples:plan.developerSamples.length,dOwned:site.pages.filter(p=>p.owner==='D').length,expandedGroups:groups,lockedFiles:locked.length};
result.status=result.failures.length?'FAIL':'PASS';
if(args.includes('--out'))fs.writeFileSync(args[args.indexOf('--out')+1],JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({status:result.status,counts:result.counts,failures:result.failures},null,2));
process.exitCode=result.failures.length?1:0;
