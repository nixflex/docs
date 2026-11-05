// Source proof plus real generated-site proof. Never manufacture sitemap/llms evidence.
// node scripts/check-c9-seo.mjs [--site http://localhost:3339] [--llms-file actual-export-llms.txt] [--html-dir actual-export-folder] [--require-generated] [--out path.json]
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {execFileSync} from 'node:child_process';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const args=process.argv.slice(2),arg=n=>args[args.indexOf(n)+1];
const read=p=>fs.readFileSync(path.join(root,p),'utf8'),json=p=>JSON.parse(read(p));
const config=json('docs.json'),plan=json('spec-source/c9-pages.json');
const report={source:[],generated:[],counts:{},pending:[],failures:[]};
function check(ok,message,group='source'){report[group].push({status:ok?'PASS':'FAIL',message});if(!ok)report.failures.push(message);}
function flatten(v){if(typeof v==='string')return [v];if(Array.isArray(v))return v.flatMap(flatten);return ['pages','groups'].flatMap(k=>v?.[k]?flatten(v[k]):[]);}
const nav=flatten(config.navigation.tabs.find(t=>t.tab==='API reference'));
const same=(a,b)=>a.length===b.length&&[...a].sort().every((v,i)=>v===[...b].sort()[i]);
const files=d=>fs.readdirSync(path.join(root,d),{withFileTypes:true}).flatMap(e=>e.isDirectory()?files(d+'/'+e.name):[d+'/'+e.name]);
const intended=files('api-reference').filter(p=>p.endsWith('.mdx')).map(p=>p.slice(0,-4)).filter(p=>!plan.excluded.includes(p));
const meta=(s,k)=>{const v=s.split('---')[1]?.match(new RegExp('^'+k+':\\s*(.*)$','m'))?.[1]?.trim();if(!v)return '';try{return JSON.parse(v);}catch{return v.replace(/^'|'$/g,'');}};
check(new Set(nav).size===nav.length&&same(nav,intended)&&same(nav,plan.pages.map(p=>p.slug)),'Public files, plan and navigation are the same set');
report.counts.navigation=nav.length;report.counts.intendedFiles=intended.length;report.counts.excluded=plan.excluded.length;
const before=JSON.parse(execFileSync('git',['show',plan.baseline+':docs.json'],{cwd:root,encoding:'utf8'}));
check(JSON.stringify(config.navigation.tabs.map(t=>t.tab))===JSON.stringify(['Business guide','Developer guide','API reference','SDKs & CLI','AI tools']),'Locked five-tab order');
check(before.redirects.every(r=>config.redirects.some(n=>n.source===r.source&&n.destination===r.destination)),'Existing redirects preserved');
check(plan.moved.every(r=>config.redirects.some(n=>n.source==='/'+r.from&&n.destination==='/'+r.to)),'Every moved URL has a redirect ('+plan.moved.length+' moves)');
const former=flatten(before.navigation.tabs.find(t=>t.tab==='API reference'));
check(former.every(p=>nav.includes(p)||plan.moved.some(r=>r.from===p)),'Every previous public API URL remains reachable');
const titles=new Set(),descriptions=new Set(),links=[],carrier=[];
const redirectMap=new Map(config.redirects.map(r=>[r.source,r.destination]));
function resolves(url,seen=new Set()){
 const pathname=decodeURI(url.split(/[?#]/)[0]);if(seen.has(pathname))return false;seen.add(pathname);
 if(redirectMap.has(pathname))return resolves(redirectMap.get(pathname),seen);
 return ['', '.mdx','.md'].some(ext=>fs.existsSync(path.join(root,pathname.slice(1)+ext)));
}
let endpoints=0;
for(const slug of nav){
 const s=read(slug+'.mdx'),title=meta(s,'title'),desc=meta(s,'description');
 check(title.length>0&&title.length<=60&&!titles.has(title.toLowerCase()),slug+' unique title <=60');titles.add(title.toLowerCase());
 check(desc.length>0&&desc.length<=160&&!descriptions.has(desc.toLowerCase()),slug+' unique description <=160');descriptions.add(desc.toLowerCase());
 check(meta(s,'canonical')==='https://docs.nixflex.com/'+slug,slug+' production canonical');
 check(!/^(?:hidden|noindex):\s*true\b|^robots:.*noindex/m.test(s)&&config.seo?.indexing==='all',slug+' indexable');
 check(!/\b(?:openai|anthropic|deepgram|inworld|elevenlabs|supabase|groq)\b/i.test(s),slug+' speech/model supplier scan');
 if(/twilio|telnyx/i.test(s))carrier.push(slug);
 if(/^openapi:/m.test(s)){endpoints++;check((s.match(/^## /gm)||[]).length===8,slug+' eight endpoint sections');}
 for(const m of s.matchAll(/(?:\]\(|href=["'])(\/[^\s)"']+)/g))if(!resolves(m[1]))links.push({slug,url:m[1]});
}
report.counts.endpointPages=endpoints;report.carrierContractPages=carrier;
check(endpoints===149,'All 149 operations have text endpoint pages');
check(links.length===0,'Internal page and asset links resolve');report.brokenLinks=links;
const apiPath=u=>{try{const p=new URL(u,'https://docs.nixflex.com').pathname.replace(/\.(md|html)$/,'').replace(/\/$/,'');return p.startsWith('/api-reference/')&&!p.endsWith('.json')?p.slice(1):null;}catch{return null;}};
async function fetchText(u){const r=await fetch(u,{signal:AbortSignal.timeout(20000)});if(!r.ok)throw Error('HTTP '+r.status+' '+u);return await r.text();}
if(args.includes('--site')){
 const origin=arg('--site').replace(/\/$/,'');report.site=origin;
 let sitemap=[],llms=[];
 try{
  const raw=await fetchText(origin+'/sitemap.xml');
  const locs=[...raw.matchAll(/<loc>([^<]+)<\/loc>/g)].map(m=>m[1]);
  const docs=raw.includes('<sitemapindex')?await Promise.all(locs.map(u=>fetchText(origin+new URL(u).pathname))):[raw];
  sitemap=[...new Set(docs.flatMap(t=>[...t.matchAll(/<loc>([^<]+)<\/loc>/g)].map(m=>apiPath(m[1])).filter(Boolean)))];
  check(same(nav,sitemap),'Actual generated sitemap matches API navigation','generated');report.counts.generatedSitemap=sitemap.length;
 }catch(e){report.pending.push('Generated sitemap unavailable: '+e.message);}
 try{
  const raw=args.includes('--llms-file')?fs.readFileSync(arg('--llms-file'),'utf8'):await fetchText(origin+'/llms.txt');
  llms=[...new Set([...raw.matchAll(/\]\(([^)]+)\)/g)].map(m=>apiPath(m[1])).filter(Boolean))];
  check(same(nav,llms),'Actual generated llms.txt matches API navigation','generated');report.counts.generatedLlms=llms.length;
 }catch(e){report.pending.push('Generated llms.txt unavailable: '+e.message);}
 let next=0,md=0,html=0,canonical=0,done=0;const pageErrors=[];
 await Promise.all(Array.from({length:2},async()=>{while(next<nav.length){const slug=nav[next++];try{
  const markdown=await fetchText(origin+'/'+slug+'.md');
  if(markdown.includes('<!DOCTYPE')||markdown.length<180||!markdown.toLowerCase().includes(plan.pages.find(p=>p.slug===slug).title.toLowerCase()))throw Error('Markdown export is not readable page text');md++;
  const raw=args.includes('--html-dir')?fs.readFileSync(path.join(arg('--html-dir'),slug,'index.html'),'utf8'):await fetchText(origin+'/'+slug);
  const visible=raw.replace(/<script\b[^>]*>[\s\S]*?<\/script>/gi,'').replace(/<style\b[^>]*>[\s\S]*?<\/style>/gi,'');
  if(!/<h1\b/.test(visible)||visible.replace(/<[^>]+>/g,'').length<200)throw Error('Missing server-rendered page text');
  if(/^openapi:/m.test(read(slug+'.mdx'))&&!/Request fields|Request Fields/.test(visible))throw Error('Missing server-rendered endpoint sections');html++;
  const tags=raw.match(/<link\b[^>]*>/gi)||[];
  if(!tags.some(tag=>/rel=["']canonical["']/.test(tag)&&tag.includes('https://docs.nixflex.com/'+slug)))throw Error('Missing production canonical in generated HTML');canonical++;
 }catch(e){pageErrors.push({slug,error:e.message});}done++;if(done%25===0)console.error('Generated page checks: '+done+'/'+nav.length);}}));
 report.counts.readableMarkdown=md;report.counts.serverRenderedHtml=html;report.counts.generatedCanonicals=canonical;report.pageErrors=pageErrors;
 check(md===nav.length,'Every generated Markdown page is readable','generated');check(html===nav.length,'Every HTML page includes server-rendered text','generated');
 check(canonical===nav.length,'Every generated HTML page has its production canonical','generated');
}else report.pending.push('Run with --site against an actual Mintlify preview/deployment to verify generated sitemap, llms.txt, Markdown and HTML. Source files are not proof of generated indexes.');
report.status=report.failures.length?'FAIL':report.pending.length?'SOURCE_PASS_GENERATED_PENDING':'PASS';
if(args.includes('--out'))fs.writeFileSync(arg('--out'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({status:report.status,counts:report.counts,failures:report.failures,brokenLinks:report.brokenLinks,pending:report.pending},null,2));
// Release checks must not treat unavailable generated artifacts as a passing gate.
process.exitCode=report.failures.length||(args.includes('--require-generated')&&report.pending.length)?1:0;
