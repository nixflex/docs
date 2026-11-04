// Apply the actual D2 NAV-FOR-C format only after its pushed branch is merged.
// node scripts/apply-d2-navigation.mjs --proposal <NAV-FOR-C.json> [--check]
// Writes C-owned navigation/manifest/ignore files only. Never edits D's MDX.
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync,spawnSync} from 'node:child_process';
const root=path.resolve(import.meta.dirname,'..'),args=process.argv.slice(2);
const flag=args.indexOf('--proposal');if(flag<0||!args[flag+1])throw Error('Provide --proposal NAV-FOR-C.json');
const parse=p=>JSON.parse(fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''));
const proposal=parse(path.resolve(args[flag+1])),config=parse(path.join(root,'docs.json'));
const locked=['Business guide','Developer guide','API reference','SDKs & CLI','AI tools'];
if(JSON.stringify(proposal.locked_tab_order)!==JSON.stringify(locked))throw Error('Unexpected tab order');
const flatten=v=>typeof v==='string'?[v]:Array.isArray(v)?v.flatMap(flatten):['groups','pages'].flatMap(k=>v?.[k]?flatten(v[k]):[]);
for(const tab of proposal.tabs_to_populate){
 if(!['Business guide','AI tools'].includes(tab.tab))throw Error('D2 proposal touches a C-owned tab');
 const existing=config.navigation.tabs.find(t=>t.tab===tab.tab);if(!existing)throw Error('Missing tab');
 const groups=[...tab.groups].sort((a,b)=>a.order-b.order).map(g=>({group:g.group,pages:[...g.pages].sort((a,b)=>a.order-b.order).map(p=>{
  if(!/^[A-Za-z0-9/_-]+$/.test(p.path)||p.path.startsWith('/'))throw Error('Invalid page path');return p.path;
 })}));
 const next=new Set(flatten(groups));
 const remainder=flatten(existing).filter(p=>!next.has(p)&&!proposal.redirect_requests.some(r=>r.source==='/'+p));
 if(remainder.length)groups.push({group:tab.tab==='Business guide'?'About Nixflex and help':'Related tools',pages:remainder});
 existing.groups=groups;
}
for(const r of proposal.redirect_requests){
 if(r.source!=='/mcp/overview'||r.destination!=='/ai-tools/overview')throw Error('Unexpected D2 redirect');
 const old=config.redirects.find(x=>x.source===r.source);if(old&&old.destination!==r.destination)throw Error('Redirect conflict');
 if(!old)config.redirects.push({source:r.source,destination:r.destination});
}
const pages=flatten(config.navigation.tabs);
if(new Set(pages).size!==pages.length)throw Error('Duplicate page assignment');
const missing=pages.filter(p=>!fs.existsSync(path.join(root,p+'.mdx')));
const merged=spawnSync('git',['merge-base','--is-ancestor','origin/codex/d2-business-ai','HEAD'],{cwd:root,stdio:'pipe'}).status===0;
const result={pages:pages.length,tabs:Object.fromEntries(config.navigation.tabs.map(t=>[t.tab,flatten(t).length])),missing,remoteBranchMerged:merged};
if(args.includes('--check')){console.log(JSON.stringify(result,null,2));process.exitCode=missing.length||!merged?2:0;}
else{
 if(missing.length||!merged)throw Error('D2 is not ready: merge the pushed branch and check all page files before applying navigation.');
 const baseline=execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim();
 const plan=parse(path.join(root,'spec-source/c10-site.json'));plan.ownershipBaseline=baseline;
 fs.writeFileSync(path.join(root,'docs.json'),JSON.stringify(config,null,2)+'\n');
 fs.writeFileSync(path.join(root,'spec-source/c10-site.json'),JSON.stringify(plan,null,2)+'\n');
 const ignore=path.join(root,'.mintignore'),text=fs.readFileSync(ignore,'utf8');
 if(!text.split(/\r?\n/).includes('mcp/overview.mdx'))fs.appendFileSync(ignore,'\n# Retired MCP entry is served by a redirect to AI tools.\nmcp/overview.mdx\n');
 execFileSync(process.execPath,[path.join(root,'scripts/build-c10-site.mjs')],{cwd:root,stdio:'inherit'});
 console.log(JSON.stringify({...result,ownershipBaseline:baseline},null,2));
}
