// Overnight Nov 4-5, Part 4: splits the dialogue export into zone-coherent chunks for the rewrite (docs/dialogue/rewrite_nov5/chunks/), each row
// with the phrases a test asserts ("Must keep", from docs/dialogue/critic_oct31/protected_phrases.json), and merges the finished chunks back.
//   node tools/dialogue_rewrite_chunks.js --split [--csv=docs/dialogue/edit_nov5_before/before_nov5.csv]
//   node tools/dialogue_rewrite_chunks.js --merge [--out=docs/dialogue/rewrite_nov5/suggestions_all.csv]
// A finished chunk is chunk_NN_done.csv with the columns ID, Effective line, Suggested line (only the rows that change); --merge joins them
// into one suggestions file for tools/dialogue_critic_check.js --check and writes the edit CSV with "New line" filled
// (docs/dialogue/rewrite_nov5/edit_rewrite.csv) for tools/apply_dialogue_pass.js --csv.
const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '..');
const args = Object.fromEntries(process.argv.slice(2).map((a) => { const [k, v] = a.replace(/^--/, '').split('='); return [k, v === undefined ? true : v]; }));
const CSV = args.csv || 'docs/dialogue/edit_nov5_before/before_nov5.csv';
const DIR = 'docs/dialogue/rewrite_nov5';

function parseCsv(text) {
	text = text.replace(/^﻿/, '');
	const rows = [];
	let r = [], f = '', q = false;
	for (let i = 0; i < text.length; i++) {
		const c = text[i];
		if (q) {
			if (c === '"') { if (text[i + 1] === '"') { f += '"'; i++; } else q = false; } else f += c;
		} else if (c === '"') q = true;
		else if (c === ',') { r.push(f); f = ''; }
		else if (c === '\n') { r.push(f); rows.push(r); r = []; f = ''; }
		else if (c !== '\r') f += c;
	}
	if (f || r.length) { r.push(f); rows.push(r); }
	const head = rows.shift();
	return rows.filter((x) => x.length > 1).map((x) => Object.fromEntries(head.map((h, i) => [h, x[i] || ''])));
}
const q = (s) => '"' + String(s).replace(/"/g, '""') + '"';
const write = (file, head, rows) => fs.writeFileSync(path.resolve(root, file), '﻿' + [head.map(q).join(',')].concat(rows.map((r) => head.map((h) => q(r[h] || '')).join(','))).join('\n') + '\n');

// [chunk name, areas]
const CHUNKS = [
	['01_prologue_crosspath_a', ['Prologue (Opening Forest)'], 0, 230],
	['02_crosspath_b', ['Crosspath (first visit)'], 230, 9999],
	['03_gainlands', ['Gainlands / gatekeeper', 'Gainlands', 'Gainlands / S-IRON']],
	['04_gainlands_hog', ['Gainlands / The House of Gains', 'Gainlands / after freeing']],
	['05_buffet', ['Endless Buffet / gatekeeper', 'Endless Buffet', 'Endless Buffet / Omakase']],
	['06_buffet_kitchen', ['Endless Buffet / The Test Kitchen', 'Endless Buffet / after freeing']],
	['07_dna', ['D.N.A. / gatekeeper', 'D.N.A.', 'D.N.A. / The Waiting Room of Eternity']],
	['08_dna_hall', ['D.N.A. / The Hall of Final Approvals', 'D.N.A. / after freeing']],
	['09_dump', ['Verdant Dump / gatekeeper', 'Verdant Dump', 'Verdant Dump / The Trash Panda Throne']],
	['10_dump_rotheart', ['Verdant Dump / The Rotheart', 'Verdant Dump / after freeing']],
	['11_crosspath_between', ['Crosspath (between zones)', 'Crosspath (between zones) / The Forgotten Vault']],
	['12_capital_a', ['The Capital'], 0, 266],
	['13_capital_b', ['The Capital'], 266, 9999],
	['14_castle', ['The Capital / The Paste Works', 'The Capital / The Old Service Tunnels', "The Capital / Primm's Castle"]],
	['15_ending_postgame', ['The Capital / after freeing', 'Ending', 'Postgame', 'Postgame / The Ascent of Mount Swolympus', 'Postgame / The Path-ology Lab']],
];

function split() {
	const rows = parseCsv(fs.readFileSync(path.resolve(root, CSV), 'utf8'));
	const prot = JSON.parse(fs.readFileSync(path.resolve(root, 'docs/dialogue/critic_oct31/protected_phrases.json'), 'utf8'));
	fs.mkdirSync(path.resolve(root, DIR, 'chunks'), { recursive: true });
	let total = 0;
	for (const [name, areas, from, to] of CHUNKS) {
		let picked = rows.filter((r) => areas.includes(r['Zone/Area']));
		if (from !== undefined) {
			// a split area: the first chunk also takes every row of its other areas
			const own = picked.filter((r) => r['Zone/Area'] === areas[areas.length - 1] || areas.length === 1);
			picked = picked.filter((r) => !own.includes(r)).concat(own.slice(from, to));
			if (name.startsWith('01')) picked = rows.filter((r) => r['Zone/Area'] === 'Prologue (Opening Forest)').concat(rows.filter((r) => r['Zone/Area'] === 'Crosspath (first visit)').slice(0, to));
			if (name.startsWith('02')) picked = rows.filter((r) => r['Zone/Area'] === 'Crosspath (first visit)').slice(from);
		}
		const out = picked.map((r) => ({ ...r, 'Must keep': (prot[r.ID] || []).map((x) => (typeof x === 'string' ? x : x.phrase)).join(' || ') }));
		write(`${DIR}/chunks/chunk_${name}.csv`, ['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'Must keep'], out);
		total += out.length;
		console.log(`chunk_${name}: ${out.length} rows`);
	}
	console.log(`total ${total} of ${rows.length}`);
}

function merge() {
	const rows = parseCsv(fs.readFileSync(path.resolve(root, CSV), 'utf8'));
	const byId = new Map(rows.map((r) => [r.ID, r]));
	const all = [];
	for (const file of fs.readdirSync(path.resolve(root, DIR)).filter((f) => /^chunk_.*_done\.csv$/.test(f)).sort()) {
		for (const s of parseCsv(fs.readFileSync(path.resolve(root, DIR, file), 'utf8'))) {
			if (!s['Suggested line'] || !byId.has(s.ID)) continue;
			all.push({ ID: s.ID, 'Effective line': byId.get(s.ID)['Current line'], 'Suggested line': s['Suggested line'] });
			byId.get(s.ID)['New line'] = s['Suggested line'];
		}
	}
	write(args.out || `${DIR}/suggestions_all.csv`, ['ID', 'Effective line', 'Suggested line'], all);
	write(`${DIR}/edit_rewrite.csv`, ['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line'], rows);
	console.log(`merged ${all.length} rewritten lines`);
}

if (args.split) split();
else if (args.merge) merge();
else console.log('usage: --split | --merge');
