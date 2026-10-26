import {test} from 'node:test';
import a from 'node:assert/strict';
import {execFile} from 'node:child_process';
import {promisify} from 'node:util';
import {fileURLToPath} from 'node:url';
const run=promisify(execFile);
const script=fileURLToPath(new URL('../scripts/test-area3-batch2-staging.ps1',import.meta.url));
const wrapper=fileURLToPath(new URL('./support/call-reads-powershell.ps1',import.meta.url));
// Do not let a PowerShell 7 parent's PSModulePath load incompatible modules in 5.1.
const env=Object.fromEntries(Object.entries(process.env).filter(([k])=>/^(path|systemroot|windir|comspec|temp|tmp|pathext)$/i.test(k)));
for(const [shell,major] of [['powershell.exe',5],['pwsh.exe',7]]){
 test(`real staging helper sends separate URL-encoded filters under PowerShell ${major}`,async()=>{
  for(const withDates of [false,true]){
   const args=['-NoProfile','-NonInteractive','-ExecutionPolicy','Bypass','-File',wrapper,'-ScriptPath',script,...(withDates?['-WithDates']:[])];
   const {stdout}=await run(shell,args,{windowsHide:true,timeout:30000,env});
   const result=JSON.parse(stdout.trim());a.equal(Number(result.version.split('.')[0]),major);
   const url=new URL(result.uris[0]);a.equal(url.origin,'https://nixflex-voice-engine-staging.up.railway.app');a.equal(url.pathname,'/v1/calls/history');
   a.deepEqual(Object.fromEntries(url.searchParams),{number:'+12025550100',outcome:'failed',period:'month',limit:'25',...(withDates?{since:'2026-10-25T00:00:00+01:00',until:'2026-10-26T12:34:56Z'}:{})});
   a.match(url.search,/number=%2B12025550100&outcome=failed&period=month&limit=25/);
   a.deepEqual(Object.fromEntries(new URL(result.uris[1]).searchParams),{limit:'25',cursor:'next+/='});
   a.equal(result.uris.length,5);a.deepEqual(result.hasAuth,[true,true,true,false,true]);
  }
 });
}
