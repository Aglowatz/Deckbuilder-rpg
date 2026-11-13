// Nov 13: builds an edit CSV (the format tools/apply_dialogue_pass.js --csv= expects) from scene files written by hand.
//   node tools/dialogue_scene_build.js --base=docs/dialogue/rewrite_nov13_base.csv --out=docs/dialogue/rewrite_nov13_t1.csv <scene files...>
// A scene file is plain text:
//   ## purpose: one line saying what the conversation must achieve      (kept for the reader; ignored here)
//   @intro::memory.4.after              the key: <file alias>::<key>
//   0| the new text of line 0
//   3| the new text of line 3            (lines not listed keep their text)
//   intro::town.name::0| one-off line with its whole id
// File aliases: intro, capital, gainlands, gourmand, dna, refusemancer (the story .tres files), scenes (story_scenes.json::scenes/...),
// boss, enc, dc, qd, zq, npc, well. Every row is checked here first: the id exists in the base export, the same {tokens}, the same leading
// [tag], the same %s/%d, plain ASCII, at most 240 characters (barks under 90), and not a duplicate. Problems are printed and exit code 1.
// --ids=<file> also writes the ids of the rows (for --revert=).
const fs = require('fs');
const path = require('path');
const { root, parseCsv, csvq } = require('./dialogue_ids');

const args = {}, files = [];
for (const a of process.argv.slice(2)) { const m = a.match(/^--([a-z-]+)(?:=(.*))?$/); if (m) args[m[1]] = m[2] ?? true; else files.push(a); }
const ALIAS = { intro: 'data/story/intro_story.tres', capital: 'data/story/capital_story.tres', gainlands: 'data/story/gainlands_story.tres',
	gourmand: 'data/story/gourmand_story.tres', dna: 'data/story/dna_story.tres', refusemancer: 'data/story/refusemancer_story.tres',
	boss: 'data/encounters/boss_intros.json', enc: 'data/encounters/encounter_scripts.json', dc: 'data/dungeons/dungeon_content.json',
	qd: 'core/quests/quest_definitions.gd', zq: 'core/quests/zone_quest_definitions.gd', npc: 'data/npcs/npcs.json', well: 'data/story/old_well_story.json' };
function fullKey(k) {
	if (k.startsWith('scenes/')) return 'data/story/story_scenes.json::' + k;
	const i = k.indexOf('::');
	const a = k.slice(0, i);
	return (ALIAS[a] || a) + k.slice(i);
}
const base = parseCsv(fs.readFileSync(path.resolve(root, args.base), 'utf8'));
const byId = new Map(base.map((r) => [r.ID, r]));
const tokensOf = (s) => (s.match(/\{[a-z_]+\}/g) || []).sort().join('');
const tagOf = (s) => (s.match(/^\[[a-z_]+\]/) || [''])[0];
const phOf = (s) => (s.match(/%[sd]/g) || []).join('');
const rows = [], problems = [], seen = new Set();
for (const f of files) {
	let key = null, n = 0;
	for (const raw of fs.readFileSync(path.resolve(root, f), 'utf8').split(/\r?\n/)) {
		n++;
		const line = raw.trimEnd();
		if (!line || line.startsWith('#')) continue;
		if (line.startsWith('@')) { key = fullKey(line.slice(1).trim()); continue; }
		const m = line.match(/^([^|]+)\| ?(.*)$/);
		if (!m) { problems.push(`${f}:${n}: not a line: ${line.slice(0, 60)}`); continue; }
		const id = /^\d+$/.test(m[1]) ? `${key}::${m[1]}` : fullKey(m[1]);
		const text = m[2];
		const b = byId.get(id);
		const where = `${f}:${n} ${id}`;
		if (!b) { problems.push(`${where}: no such id in the base export`); continue; }
		if (seen.has(id)) { problems.push(`${where}: written twice`); continue; }
		seen.add(id);
		const old = b['Current line'];
		if (text === old) continue;
		const bad = [];
		if (tokensOf(old) !== tokensOf(text)) bad.push(`tokens ${tokensOf(old) || '-'} -> ${tokensOf(text) || '-'}`);
		if (tagOf(old) !== tagOf(text)) bad.push(`tag ${tagOf(old) || '-'} -> ${tagOf(text) || '-'}`);
		if (phOf(old) !== phOf(text)) bad.push('%s/%d changed');
		const odd = [...text].filter((c) => (c < ' ' || c > '~') && !old.includes(c));
		if (odd.length) bad.push(`not ASCII: ${[...new Set(odd)].join('')}`);
		const bark = id.includes('npcs.json::');
		const offBox = /\.gd::|dungeon_content\.json::dungeons\/|encounter_scripts\.json::/.test(id);
		const cap = bark ? 89 : offBox ? Math.max(240, Math.ceil(old.length * 1.25)) : 240;
		if (text.length > cap) bad.push(`${text.length} characters (max ${cap})`);
		if (!text.trim()) bad.push('empty');
		if (bad.length) problems.push(`${where}: ${bad.join('; ')}`);
		rows.push({ ...b, 'New line': text });
	}
}
const head = ['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line'];
if (args.out) {
	fs.writeFileSync(path.resolve(root, args.out), '﻿' + [head.map(csvq).join(',')].concat(rows.map((r) => head.map((h) => csvq(r[h])).join(','))).join('\r\n') + '\r\n');
	// The export snapshot of the base travels with the CSV, so a re-encoded Current line still matches.
	const snapFrom = path.resolve(root, args.base.replace(/\.csv$/i, ''), 'export_snapshot.json');
	const outDir = path.resolve(root, args.out.replace(/\.csv$/i, ''));
	fs.mkdirSync(outDir, { recursive: true });
	if (fs.existsSync(snapFrom) && !fs.existsSync(path.join(outDir, 'export_snapshot.json'))) fs.copyFileSync(snapFrom, path.join(outDir, 'export_snapshot.json'));
}
if (args.ids) fs.writeFileSync(path.resolve(root, args.ids), rows.map((r) => r.ID).join('\n') + '\n');
if (args.check) {
	// The "ID, Effective line, Suggested line" form tools/dialogue_critic_check.js --check= reads.
	fs.writeFileSync(path.resolve(root, args.check), [['ID', 'Effective line', 'Suggested line'].map(csvq).join(',')].concat(rows.map((r) => [r.ID, r['Current line'], r['New line']].map(csvq).join(','))).join('\r\n') + '\r\n');
}
console.log(problems.join('\n'));
const avg = rows.length ? Math.round(rows.reduce((s, r) => s + r['New line'].length, 0) / rows.length) : 0;
console.log(`${rows.length} rows changed, ${problems.length} problems, average new length ${avg}`);
process.exit(problems.length ? 1 : 0);
