// Read committed engine source without modifying or importing its active worktree.
import {execFileSync} from 'node:child_process';
import vm from 'node:vm';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';

export function pinnedEngine(engine, ref = '89e4d47f430685eacba21e4906ece34e9c718714') {
  assert.match(ref, /^[a-f0-9]{7,40}$/i, 'Use a reviewed engine commit hash');
  const git = args => execFileSync('git', args, {cwd: engine, encoding: 'utf8'});
  const commit = git(['rev-parse', ref + '^{commit}']).trim();
  const allowed = new Set(['shared/features/callBookings.js', 'shared/data/bookingPayload.js',
    'api/campaignDelete.js', 'api/errorHelper.js', 'shared/features/webhook.js']);
  const source = new Map(), modules = new Map();
  function read(file) {
    assert.ok(allowed.has(file), 'Unreviewed engine file: ' + file);
    if (!source.has(file)) source.set(file, git(['show', commit + ':' + file]));
    return source.get(file);
  }
  function load(file) {
    if (modules.has(file)) return modules.get(file).exports;
    const module = {exports: {}};
    modules.set(file, module);
    const require = name => {
      if (name === 'node:crypto') return crypto;
      assert.ok(name.startsWith('.'), 'Unreviewed dependency: ' + name);
      const target = path.posix.normalize(path.posix.join(path.posix.dirname(file), name));
      return load(target.endsWith('.js') ? target : target + '.js');
    };
    vm.runInNewContext(read(file), {module, require, AbortSignal, Date, setTimeout, clearTimeout}, {filename: file});
    return module.exports;
  }
  return {commit, read, load};
}
