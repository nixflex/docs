// Rebuild the completed Developer/client guides from immutable authored source.
import fs from 'node:fs';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8').replaceAll('\r\n','\n');
const write=(p,s)=>{const f=path.join(root,p);fs.mkdirSync(path.dirname(f),{recursive:true});if(!fs.existsSync(f)||read(p)!==s)fs.writeFileSync(f,s);};
const plan=JSON.parse(read('spec-source/c14-pages.json'));
const slug=s=>s.replace(/<[^>]+>/g,'').replace(/\[([^\]]+)\]\([^)]*\)/g,'$1').toLowerCase().replace(/[^\p{L}\p{N}_\-\s]/gu,'').trim().replace(/\s+/g,'-');
const pending='<Warning>\n**DOCS-PENDING — deletion update.** The next engine release changes call/campaign deletion. Its final response contract has not yet been supplied for this documentation review. The details below describe the reviewed B56 contract, not a verified B57 result. Do not use these deletion examples for the new release until this note is resolved.\n</Warning>';
for(const row of plan.pages){
 let s=read(row.source).trimEnd();
 const ids=new Set([...s.matchAll(/\bid=["']([^"']+)["']/g)].map(m=>m[1]));
 const seen=new Map();
 for(const match of s.replace(/```[^\n]*\n[\s\S]*?```/g,'').matchAll(/^#{2,6}\s+(.+)$/gm)){
  const key=slug(match[1]),count=seen.get(key)||0;seen.set(key,count+1);ids.add(key+(count?'-'+count:''));
 }
 const old=(row.legacyAnchors||[]).filter(id=>!ids.has(id));
 if(old.length)s+='\n\n{/* Preserve existing task links after reorganising the guide. */}\n'+old.map(id=>'<span id="'+id+'"></span>').join('\n');
 if((plan.pendingDeletionPages||[]).includes(row.slug)){
  const end=s.indexOf('\n</div>',s.indexOf('<div className="nxf-audience">'));
  if(end<0)throw Error('Missing audience switch: '+row.slug);
  s=s.slice(0,end+7)+'\n\n'+pending+s.slice(end+7);
 }
 write(row.slug+'.mdx',s+'\n');
}
for(const p of plan.pendingDeletionPages.filter(p=>p.startsWith('api-reference/'))){
 let s=read(p+'.mdx');
 if(s.includes('DOCS-PENDING'))throw Error('An API pending note must start from fresh C13 source: '+p);
 const at=s.indexOf('\n## ');if(at<0)throw Error('Missing API section: '+p);
 s=s.slice(0,at)+'\n\n'+pending+'\n'+s.slice(at);write(p+'.mdx',s);
}
console.log('C14: rebuilt '+plan.pages.length+' Developer/client pages; '+plan.pendingDeletionPages.length+' deletion pages explicitly pending B57.');
