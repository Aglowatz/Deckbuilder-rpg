// Oct 31: checks for the dialogue critic pass (docs/dialogue/critic_suggestions_oct31.csv). No game file is read for writing or changed.
//   node tools/dialogue_critic_check.js --protect [--csv=docs/dialogue/edit_oct27.csv]
//       writes docs/dialogue/critic_oct31/protected_phrases.json: for every line of the edit CSV, the string literals of tests/**/*.gd that
//       its current text contains (a rewrite must keep them, or a GUT test may fail; the apply step would hold the row).
//   node tools/dialogue_critic_check.js --check=<suggestions.csv> [--csv=...] [--out=<report.md>]
//       validates every suggestion: the row exists and its Effective line matches the edit CSV, tokens / %s %d / [tag] unchanged, protected
//       phrases kept, no banned old name, no literal name where a token belongs, the length caps (220 for a dialogue box, barks under 90,
//       Quest Log and event screens up to a quarter longer than now). Prints one line per failure; exit code 1 when any fail.
const fs = require('fs');
const path = require('path');
const { root, parseCsv, csvq } = require('./dialogue_ids');

const args = Object.fromEntries(process.argv.slice(2).map((a) => { const m = a.match(/^--([a-z-]+)(?:=(.*))?$/); return m ? [m[1], m[2] ?? true] : [a, true]; }));
const EDIT = path.resolve(root, args.csv || 'docs/dialogue/edit_oct27.csv');
const DIR = path.join(root, 'docs/dialogue/critic_oct31');
const PROTECTED = path.join(DIR, 'protected_phrases.json');
const MAX_BOX = 220;
const MAX_BARK = 90;

const TOKENS = ['{villain}', '{villain_title}', '{prince}', '{prince_full}', '{royal_house}', '{king}', '{queen}', '{rescuer}', '{rescuer_full}', '{kingdom}',
	'{town}', '{capital}', '{pathordia}', '{showcase}', '{wanderer}'];
const TOKEN_NAMES = ['Primm', 'His Perfection', 'Tessar', 'Wayweaver', 'Crosspath', 'Pathordia', 'Showcase Quarter', 'Elowen'];
const noTokenFile = (id) => /npcs\.json::|\.txt::|boss_intros\.json::|encounter_scripts\.json::|dungeon_content\.json::dungeons\//.test(id);
const offBox = (id) => /\.gd::|dungeon_content\.json::dungeons\/|encounter_scripts\.json::/.test(id);

function walk(dir, out = []) {
	for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
		const p = path.join(dir, e.name);
		if (e.isDirectory()) walk(p, out); else if (e.name.endsWith('.gd')) out.push(p);
	}
	return out;
}

// String literals of the test scripts that could be asserted against dialogue (not paths, keys or ids).
function testLiterals() {
	const out = new Map();
	for (const file of walk(path.join(root, 'tests'))) {
		const text = fs.readFileSync(file, 'utf8');
		for (const m of text.matchAll(/"((?:[^"\\\n]|\\.)*)"/g)) {
			const s = m[1].replace(/\\"/g, '"').replace(/\\'/g, "'");
			if (s.length < 4 || s.includes('::') || s.includes('res://') || s.includes('%')) continue;
			if (/^[a-z0-9_.\/\-]+$/.test(s)) continue; // keys, flags, ids
			if (!/[A-Za-z]{3}/.test(s)) continue;
			if (!out.has(s)) out.set(s, new Set());
			out.get(s).add(path.relative(root, file).replace(/\\/g, '/'));
		}
	}
	return out;
}

function editRows() {
	return parseCsv(fs.readFileSync(EDIT, 'utf8'));
}
const effective = (r) => ((r['New line'] || '').trim() ? r['New line'] : r['Current line']) || '';

function protect() {
	const lits = testLiterals();
	const result = {};
	let n = 0;
	for (const r of editRows()) {
		const line = effective(r);
		const hits = [];
		for (const [s, files] of lits) {
			// Word-bounded so "Path" does not protect "Paths"; case-insensitive only for literals with a space (tests that lower-case a line).
			const re = new RegExp(`(^|[^A-Za-z])${s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}($|[^A-Za-z])`, s.includes(' ') ? 'i' : '');
			if (re.test(line)) hits.push({ phrase: s, tests: [...files].slice(0, 3) });
		}
		if (hits.length) { result[r.ID] = hits; n++; }
	}
	fs.mkdirSync(DIR, { recursive: true });
	fs.writeFileSync(PROTECTED, JSON.stringify(result, null, '\t') + '\n');
	console.log(`protected phrases: ${n} lines carry at least one test literal -> ${path.relative(root, PROTECTED)}`);
}

function bannedNames() {
	const text = fs.readFileSync(path.join(root, 'docs/design/canon.md'), 'utf8');
	const out = [];
	let inside = false;
	for (const raw of text.split('\n')) {
		const line = raw.trim();
		if (line.startsWith('## ')) { inside = line.toLowerCase().startsWith('## banned old names'); continue; }
		if (inside && line.startsWith('**')) break;
		if (inside && line.startsWith('- ')) out.push(line.slice(2).trim());
	}
	return out;
}

// What the plain tokens fill to (data/story/royal_family.tres, villain.tres), for literal-name -> token swaps.
function fills() {
	const read = (f) => Object.fromEntries([...fs.readFileSync(path.join(root, f), 'utf8').matchAll(/^(\w+) = "(.*)"$/gm)].map((m) => [m[1], m[2]]));
	const r = read('data/story/royal_family.tres'), v = read('data/story/villain.tres');
	return { '{villain}': v.villain_name, '{villain_title}': v.villain_title, '{town}': r.town, '{kingdom}': r.kingdom, '{showcase}': r.showcase,
		'{pathordia}': r.capital_liberated, '{royal_house}': r.royal_house, '{king}': r.king_name, '{queen}': r.queen_name };
}
const FILLS = fills();

// A multi-word phrase (8+ characters) a test literal names is a story beat to keep; a single word (a name, a place) is only a warning.
const hardPhrase = (h) => h.phrase.includes(' ') && h.phrase.length >= 8;
const tokensOf = (s) => (s.match(/\{[a-z_]+\}/g) || []).sort().join('');
const placeholdersOf = (s) => (s.match(/%[sd]/g) || []).join('');
const tagOf = (s) => (s.match(/^\[[a-z_]+\]/) || [''])[0];

function problemsOf(id, old, text, prot, banned) {
	const p = [];
	if (!text.trim()) p.push('empty');
	if (/[\r\n\t]/.test(text)) p.push('line break or tab');
	const odd = [...text].filter((c) => (c < ' ' || c > '~') && !old.includes(c));
	if (odd.length) p.push(`odd characters ${JSON.stringify([...new Set(odd)].join(''))}`);
	// Like tools/apply_dialogue_pass.js: no token may be lost; a token may only be added in place of the literal name it fills to (a story
	// line that spelled "Crosspath" may say {town}), and not in a file the game shows literally.
	const lost = (old.match(/\{[a-z_]+\}/g) || []).filter((t) => !text.includes(t));
	const added = (text.match(/\{[a-z_]+\}/g) || []).filter((t) => !old.includes(t));
	const swapOk = (t) => !noTokenFile(id) && FILLS[t] && old.includes(FILLS[t]) && !(FILLS[t][0] !== FILLS[t][0].toUpperCase() && text.startsWith(t));
	if (lost.length || !added.every(swapOk) || (!added.length && tokensOf(old) !== tokensOf(text))) p.push(`tokens ${tokensOf(old) || '(none)'} -> ${tokensOf(text) || '(none)'}`);
	const unknown = (text.match(/\{[a-z_]+\}/g) || []).filter((t) => !TOKENS.includes(t));
	if (unknown.length) p.push(`unknown token ${unknown.join('')}`);
	if (placeholdersOf(old) !== placeholdersOf(text)) p.push('%s/%d changed');
	if (tagOf(old) !== tagOf(text)) p.push(`expression tag ${tagOf(old) || '(none)'} -> ${tagOf(text) || '(none)'}`);
	for (const name of banned) if (text.includes(name) && !old.includes(name)) p.push(`banned name "${name}"`);
	if (!noTokenFile(id)) for (const name of TOKEN_NAMES) if (text.includes(name) && !old.includes(name)) p.push(`literal "${name}" (use the token)`);
	for (const h of (prot || []).filter(hardPhrase)) {
		const re = new RegExp(`(^|[^A-Za-z])${h.phrase.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}($|[^A-Za-z])`, h.phrase.includes(' ') ? 'i' : '');
		if (!re.test(text)) p.push(`lost tested phrase "${h.phrase}" (${h.tests[0]})`);
	}
	const bark = id.split('::')[0].endsWith('npcs.json');
	const cap = bark ? MAX_BARK - 1 : offBox(id) ? Math.max(MAX_BOX, Math.ceil(old.length * 1.25)) : Math.max(MAX_BOX, old.length);
	if (text.length > cap) p.push(`${text.length} characters (max ${cap})`);
	return p;
}

function check(file) {
	if (!fs.existsSync(PROTECTED)) protect();
	const prot = JSON.parse(fs.readFileSync(PROTECTED, 'utf8'));
	const banned = bannedNames();
	const byId = new Map(editRows().map((r) => [r.ID, r]));
	const rows = parseCsv(fs.readFileSync(path.resolve(root, file), 'utf8'));
	const failed = [];
	const seen = new Set();
	for (const r of rows) {
		const id = r.ID;
		const p = [];
		const src = byId.get(id);
		if (!src) p.push('no such id in the edit CSV');
		if (seen.has(id)) p.push('duplicate id');
		seen.add(id);
		const old = src ? effective(src) : r['Effective line'] || '';
		if (src && (r['Effective line'] || '').trim() !== old.trim()) p.push('Effective line differs from the edit CSV');
		if (src && (r['Suggested line'] || '').trim() === old.trim()) p.push('suggestion equals the line');
		p.push(...problemsOf(id || '', old, r['Suggested line'] || '', prot[id], banned));
		if (p.length) failed.push({ id, problems: p, text: r['Suggested line'] });
	}
	let out = `# Critic suggestions: check (${new Date().toISOString().slice(0, 10)})\n\n\`node tools/dialogue_critic_check.js --check=${file}\`\n\n` +
		`- Rows: ${rows.length}\n- Pass: ${rows.length - failed.length}\n- Fail: ${failed.length}\n\n`;
	if (failed.length) out += '| id | Problems | Suggested line |\n|---|---|---|\n' + failed.map((f) => `| \`${f.id}\` | ${f.problems.join('; ')} | ${String(f.text).replace(/\|/g, '\\|')} |`).join('\n') + '\n';
	if (args.out) fs.writeFileSync(path.resolve(root, args.out), out);
	for (const f of failed) console.log(`FAIL ${f.id}: ${f.problems.join('; ')}`);
	console.log(`critic check: ${rows.length - failed.length} of ${rows.length} pass`);
	process.exitCode = failed.length ? 1 : 0;
}

module.exports = { problemsOf, bannedNames, csvq };
if (require.main === module) {
	if (args.protect) protect();
	else if (args.check) check(args.check);
	else console.log('usage: --protect | --check=<suggestions.csv>');
}
