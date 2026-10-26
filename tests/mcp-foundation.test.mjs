import {test} from 'node:test';
import a from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const page=readFileSync(new URL('../mcp/overview.mdx',import.meta.url),'utf8');
test('MCP foundation draft is honest about publication, storage, target and supported clients',()=>{
 for(const text of ['unpublished draft','Claude Code','Codex','Cursor','VS Code setup is retired',
  'plaintext','coming soon','staging.up.railway.app','cmd.exe','0.3.1','get_usage only'])a.ok(page.includes(text),text);
 for(const obsolete of ['your key never leaves your computer','Your key stays local','taking the latest','desktop apps do not expand'])a.ok(!page.includes(obsolete));
 a.ok(page.includes('A workflow file alone is not evidence of a Mac pass'));
});
