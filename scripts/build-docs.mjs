// Deterministic source build. No network and no customer API requests.
import {execFileSync} from 'node:child_process';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'..');
// C8-TEST.ps1 is a frozen test artifact. Regenerate it only with explicit test-change approval.
for(const name of ['build-c4-pages','build-c5-pages','build-c6-pages','build-c8-pages','build-public-openapi','build-c9-pages','build-c13-pages','build-c14-pages','build-c15-pages','build-c10-site']){
 execFileSync(process.execPath,[path.join(root,'scripts',name+'.mjs')],{cwd:root,stdio:'inherit'});
}
