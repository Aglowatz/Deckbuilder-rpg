// Nov 13: prints a scene file's changed lines as old / new pairs for the lead writer's review.
//   node tools/dialogue_scene_review.js --base=docs/dialogue/rewrite_nov13_base.csv docs/dialogue/rewrite_nov13/t2_buffet.txt [--new-only]
const fs = require('fs');
const path = require('path');
const { root, parseCsv } = require('./dialogue_ids');
const { execFileSync } = require('child_process');
const args = {}, files = [];
for (const a of process.argv.slice(2)) { const m = a.match(/^--([a-z-]+)(?:=(.*))?$/); if (m) args[m[1]] = m[2] ?? true; else files.push(a); }
const tmp = path.join(root, '_logs', 'review_tmp.csv');
try { execFileSync('node', [path.join(__dirname, 'dialogue_scene_build.js'), `--base=${args.base}`, `--check=${tmp}`, ...files], { stdio: 'ignore' }); } catch (e) { /* problems are printed by the build itself */ }
const speaker = new Map(parseCsv(fs.readFileSync(path.resolve(root, args.base), 'utf8')).map((r) => [r.ID, r.Speaker]));
let key = '';
for (const r of parseCsv(fs.readFileSync(tmp, 'utf8'))) {
	const k = r.ID.replace(/^.*?::/, '').replace(/::\d+$/, '');
	if (k !== key) { key = k; console.log(`\n@${k} [${(speaker.get(r.ID) || '').slice(0, 28)}]`); }
	if (!args['new-only']) console.log(`  - ${r['Effective line']}`);
	console.log(`  + ${r['Suggested line']}`);
}
