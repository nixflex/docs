// Use the dependencies bundled with the installed Mintlify CLI. No API requests.
// node scripts/validate-c9-examples.mjs --modules <node_modules> --out <artifact folder>
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {execFileSync} from 'node:child_process';
import {createRequire} from 'node:module';
import assert from 'node:assert/strict';
const args=process.argv.slice(2),arg=n=>args[args.indexOf(n)+1];
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..'),modules=arg('--modules'),out=arg('--out');
assert.ok(modules&&out,'Provide --modules and --out');
const require=createRequire(import.meta.url),Ajv=require(path.resolve(modules,'ajv/dist/2020.js')).default;
const ts=require(path.resolve(modules,'typescript/lib/typescript.js'));
const ajv=new Ajv({strict:false,validateFormats:false,allErrors:true});
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const spec=JSON.parse(read('api-reference/public.openapi.json')),plan=JSON.parse(read('spec-source/c10-site.json'));
const {validate}=await import(pathToFileURL(path.resolve(modules,'@mintlify/openapi-parser/dist/index.js')).href);
const structural=await validate(spec);assert.ok(structural.valid,JSON.stringify(structural.errors));
let schemas=0,examples=0;
function mediaCheck(media,label){if(!media.schema)return;const v=ajv.compile(media.schema);schemas++;
 for(const ex of [...(media.example===undefined?[]:[media.example]),...Object.values(media.examples||{}).filter(x=>x.value!==undefined).map(x=>x.value)]){assert.ok(v(ex),label+' '+JSON.stringify(v.errors));examples++;}
}
for(const [p,ops]of Object.entries(spec.paths))for(const [m,op]of Object.entries(ops)){
 for(const media of Object.values(op.requestBody?.content||{}))mediaCheck(media,m+' '+p+' request');
 for(const [status,response]of Object.entries(op.responses))for(const media of Object.values(response.content||{}))mediaCheck(media,m+' '+p+' '+status);
}
const dir=path.resolve(out,'syntax');fs.mkdirSync(dir,{recursive:true});
// Check sensitive new contracts with both accepted and refused shapes.
let contractCases=0;
const calendar=spec.paths['/integrations/google-calendar/number/{phoneNumber}'];
function cases(schema,accepted,rejected){const v=ajv.compile(schema);for(const value of accepted){assert.ok(v(value),JSON.stringify(v.errors));contractCases++;}for(const value of rejected){assert.equal(v(value),false,'Invalid contract shape accepted');contractCases++;}}
cases(calendar.patch.requestBody.content['application/json'].schema,
 [{send_invites:true},{send_invites:false},{timezone:'Europe/London'}],
 [{},{send_invites:'false'},{send_invites:null},{send_invites:0},{send_invites:{}},{send_invites:true,other:true},{hours:{monday:null}}]);
const status=calendar.get.responses['200'].content['application/json'].example;
const missing={...status};delete missing.send_invites;
cases(calendar.get.responses['200'].content['application/json'].schema,[status,{...status,connected:true,needs_reconnect:true,send_invites:false}],
 [missing,{...status,send_invites:'true'},{...status,account_email:42}]);
const credentials=spec.paths['/phone-numbers/{phoneNumber}/credentials'].post;
const twilio={twilio_sid:'AC'+'0'.repeat(32),twilio_token:'synthetic-example'},telnyx={telnyx_api_key:'synthetic-example',telnyx_connection_id:'fixture'};
cases(credentials.requestBody.content['application/json'].schema,[twilio,telnyx],
 [{...twilio,...telnyx},{twilio_sid:twilio.twilio_sid},{...twilio,twilio_token:' '},{...telnyx,telnyx_api_key:'line\nbreak'},{...twilio,agent_id:'agent_fixture'}]);
const saved=credentials.responses['200'].content['application/json'].example;
cases(credentials.responses['200'].content['application/json'].schema,[saved],[{...saved,twilio_token:'must-never-return'},{...saved,updated:false}]);
const counts={javascript:0,typescript:0,python:0,bash:0,powershell:0,json:0,toml:0};let bash='',py=[],js=[],toml=[];
for(const row of [...plan.pages,{slug:'snippets/guides/signature-verification'}]){
 const page=read(row.slug+'.mdx');
 let i=0;
 for(const [,lang,code] of page.matchAll(/```(javascript|typescript|python|bash|powershell|json|toml)\b[^\n]*\n([\s\S]*?)```/g)){
  i++;counts[lang]++;if(lang==='json'){JSON.parse(code);continue;}
  if(lang==='typescript'){
   const parsed=ts.createSourceFile(row.slug+'.ts',code,ts.ScriptTarget.Latest,true,ts.ScriptKind.TS);
   assert.equal(parsed.parseDiagnostics.length,0,row.slug+' TypeScript syntax');continue;
  }
  const file=path.join(dir,row.slug.replaceAll('/','_')+'-'+i+({javascript:'.mjs',python:'.py',bash:'.sh',powershell:'.ps1',toml:'.toml'}[lang]));fs.writeFileSync(file,code);
  if(lang==='toml')toml.push(file);
  if(lang==='javascript')js.push(file);if(lang==='python')py.push(file);if(lang==='bash')bash+='\n(\n'+code+'\n)\n';
 }
 const binding=page.match(/^openapi: "[^"\n]* (GET|POST|PUT|PATCH|DELETE) ([^"\n]+)"/m);
 const example=page.match(/<ResponseExample>[\s\S]*?```json[^\n]*\n([\s\S]*?)```/);
 if(example&&binding){const op=spec.paths[binding[2]][binding[1].toLowerCase()];const s=Object.entries(op.responses).find(([status,r])=>/^2\d\d$/.test(status)&&r.content?.['application/json']?.schema)?.[1].content['application/json'].schema;
  if(s){const v=ajv.compile(s);assert.ok(v(JSON.parse(example[1])),row.slug+' response '+JSON.stringify(v.errors));examples++;}}
}
// Parse without executing the examples. Python/Bash/PowerShell executables may be overridden.
for(const file of js)execFileSync(process.execPath,['--check',file],{stdio:'pipe'});
fs.writeFileSync(path.join(dir,'python-files.json'),JSON.stringify(py));
fs.writeFileSync(path.join(dir,'toml-files.json'),JSON.stringify(toml));
execFileSync(process.env.NXF_PYTHON||'python',['-X','utf8','-c','import tomllib,json,sys;[tomllib.load(open(p,"rb")) for p in json.load(open(sys.argv[1],encoding="utf-8"))]',path.join(dir,'toml-files.json')]);
execFileSync(process.env.NXF_PYTHON||'python',['-X','utf8','-c','import ast,json,sys;[ast.parse(open(p,encoding="utf-8").read(),filename=p) for p in json.load(open(sys.argv[1],encoding="utf-8"))]',path.join(dir,'python-files.json')]);
fs.writeFileSync(path.join(dir,'all.sh'),bash);execFileSync(process.env.NXF_BASH||'bash',['-n',path.join(dir,'all.sh')]);
fs.writeFileSync(path.join(dir,'parse.ps1'),`$ErrorActionPreference='Stop'\nGet-ChildItem -LiteralPath '${dir.replaceAll("'","''")}' -Filter *.ps1 | ForEach-Object { $t=$null;$e=$null;[Management.Automation.Language.Parser]::ParseFile($_.FullName,[ref]$t,[ref]$e)|Out-Null;if($e.Count){throw ('Example syntax error: '+$_.Name)} }\n`);
execFileSync('powershell.exe',['-NoProfile','-File',path.join(dir,'parse.ps1')]);
const result={openapi:structural.valid,version:structural.version,schemas,examples,contractCases,syntax:counts};
fs.writeFileSync(path.resolve(out,'OPENAPI-EXAMPLES.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
