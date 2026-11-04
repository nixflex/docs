import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const cases=JSON.parse(read('spec-source/c8-read-cases.json'));
const spec=JSON.parse(read('api-reference/public.openapi.json'));
const shape=p=>p.replace(/^\/v1/,'').replace(/:[^/]+|\{[^}]+\}/g,'{}');
for(const c of cases){
 const p=Object.keys(spec.paths).find(p=>shape(p)===shape(c.path));
 c.schema=spec.paths[p].get.responses['200'].content['application/json'].schema;
}
if(cases.length!==55)throw Error('Expected 55 safe GET shapes, including Google Calendar status');
const writes=JSON.parse(read('spec-source/public-operations.json')).filter(c=>c.public&&c.method!=='GET');
const names=writes.map(c=>"'row "+c.number+' '+c.method+' '+c.path+"'").join(',\n ');
const template=read('scripts/c8-runner-template.ps1');
fs.writeFileSync(path.join(root,'scripts/C8-TEST.ps1'),template.replace('__CASES__',JSON.stringify(cases,null,2)).replace('__WRITES__',names));
console.log(`Built C8 GET-only runner: ${cases.length} read schemas, 4 retired GETs, ${writes.length+2} explicit manual checks.`);
