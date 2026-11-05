import {execFileSync} from 'node:child_process';
import vm from 'node:vm';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pinnedEngine} from './c12-engine-source.mjs';
import {engineRef} from './c13-contracts.mjs';

export function b56Source(repo){
 const base=pinnedEngine(repo,engineRef),sources=new Map();
 const allowed=new Set(['api/calls/bookingRead.js','api/calls/outboundRequests.js','api/routes.js','sql/security-auth/B56_01_dashboard_calls.sql']);
 const read=file=>{assert.ok(allowed.has(file),'Unreviewed B56 source file');if(!sources.has(file))sources.set(file,execFileSync('git',['show',base.commit+':'+file],{cwd:repo,encoding:'utf8'}));return sources.get(file);};
 const load=file=>{
  assert.ok(['api/calls/bookingRead.js','api/calls/outboundRequests.js'].includes(file));
  const module={exports:{}};
  const require=name=>{
   if(name==='node:crypto')return crypto;
   if(name==='../errorHelper')return base.load('api/errorHelper.js');
   if(name==='../../shared/features/callBookings')return base.load('shared/features/callBookings.js');
   throw Error('Unreviewed dependency: '+name);
  };
  vm.runInNewContext(read(file),{module,require,AbortSignal,Date},{filename:file});return module.exports;
 };
 return {commit:base.commit,read,load};
}
