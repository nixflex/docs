// Run last, after API builders and after applying a D2 navigation proposal.
import fs from 'node:fs';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const write=(p,s)=>{if(!fs.existsSync(path.join(root,p))||read(p)!==s)fs.writeFileSync(path.join(root,p),s);};
const config=JSON.parse(read('docs.json'));
const flatten=v=>typeof v==='string'?[v]:Array.isArray(v)?v.flatMap(flatten):['groups','pages'].flatMap(k=>v?.[k]?flatten(v[k]):[]);
const meta=(s,k)=>{const value=s.split(/^---\s*$/m)[1]?.match(new RegExp('^'+k+':\\s*(.*)$','m'))?.[1];if(!value)return '';try{return JSON.parse(value);}catch{return value.replace(/^'|'$/g,'');}};
const pages=[];
for(const tab of config.navigation.tabs)for(const slug of flatten(tab)){
 const owner=tab.tab==='Business guide'||slug.startsWith('ai-tools/')?'D':'C';
 let s=read(slug+'.mdx');const title=meta(s,'title'),description=meta(s,'description');
 if(owner==='C'){
  const parts=s.split(/^---\s*$/m),line='canonical: '+JSON.stringify('https://docs.nixflex.com/'+slug);
  parts[1]=/^canonical:/m.test(parts[1])?parts[1].replace(/^canonical:.*$/m,line):parts[1].trimEnd()+'\n'+line+'\n';
  s=parts.join('---');write(slug+'.mdx',s);
 }
 pages.push({slug,tab:tab.tab,owner,title,description,searchPhrase:title.replace(/[.:].*$/,'')+' Nixflex',canonical:meta(s,'canonical')});
}
if(new Set(pages.map(p=>p.slug)).size!==pages.length)throw Error('A page appears in more than one tab');
const prior=fs.existsSync(path.join(root,'spec-source/c10-site.json'))?JSON.parse(read('spec-source/c10-site.json')):{};
const retiredMcp=config.redirects.some(r=>r.source==='/mcp/overview'&&r.destination==='/ai-tools/overview');
const manifest={baseline:'a42729000b7c9afb39c66b596a9f52d62b944734',ownershipBaseline:prior.ownershipBaseline||'4a26f2f',engine:'89e4d47f430685eacba21e4906ece34e9c718714',canonicalOrigin:'https://docs.nixflex.com',pages,excluded:['api-reference/phone-numbers/monitor','snippets/snippet-intro','snippets/guides/signature-verification',...(retiredMcp?['mcp/overview']:[])],moved:[{from:'integrations/twilio',to:'integrations/number-connection'},{from:'integrations/telnyx',to:'integrations/number-connection'},...(retiredMcp?[{from:'mcp/overview',to:'ai-tools/overview'}]:[])]};
write('spec-source/c10-site.json',JSON.stringify(manifest,null,2)+'\n');
console.log('Mapped '+pages.length+' pages into five tabs; D-owned content untouched.');
