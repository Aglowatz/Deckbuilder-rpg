// Oct 21: applies an outside dialogue pass (the ChatGPT pass in docs/dialogue/chatgpt_pass_oct21/) to the game's text files.
// Each batch_*_done.csv row is one dialogue box: id (<file>::<key>::<line index>), speaker, key, flags, chars, current_text, new_text,
// writer_note. A blank new_text keeps the line. A row is applied only when the game's line still equals current_text (a line moved inside
// its own key, or a loading tip moved to another line, still counts); otherwise it is a conflict and is left alone. Every applied line is
// validated: tokens, %s/%d and the [expression] tag unchanged, one plain line, no banned old name, at most 240 characters and fits the
// dialogue box (measured by Godot: tools/dialogue_fit_check.gd, the same measure as tests/test_dialogue_fit.gd).
//   node tools/apply_dialogue_pass.js                  dry run: report only (apply_report_dry_run.md); rows already applied count as skipped
//   node tools/apply_dialogue_pass.js --apply          writes the game files, apply_report.md and applied_ledger.json
//   node tools/apply_dialogue_pass.js --revert=ids.txt puts the listed ids (one per line, # comments) back to their pre-pass text
//   node tools/apply_dialogue_pass.js --merge=merges.csv --apply   applies hand merges (id,new_text) for conflicts, same validation;
//                                                                  their pre-merge text joins the ledger so --revert covers them
// Options: --dir=<pass folder> (default docs/dialogue/chatgpt_pass_oct21), --no-fit (skip the Godot measure; never with --apply).
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const root = path.resolve(__dirname, '..');
const GODOT = 'C:/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe';
const args = Object.fromEntries(process.argv.slice(2).map((a) => { const m = a.match(/^--([a-z-]+)(?:=(.*))?$/); return m ? [m[1], m[2] ?? true] : [a, true]; }));
const dir = path.resolve(root, args.dir || 'docs/dialogue/chatgpt_pass_oct21');
const LEDGER = path.join(dir, 'applied_ledger.json');

const TOKENS = ['{villain}', '{villain_title}', '{prince}', '{prince_full}', '{royal_house}', '{king}', '{queen}', '{rescuer}', '{kingdom}', '{town}',
	'{capital}', '{pathordia}', '{showcase}', '{wanderer}'];
// Names the brief says story lines must write as tokens (barks and tips have no tokens and may name them plainly).
const TOKEN_NAMES = ['Primm', 'His Perfection', 'Tessar', 'Wayweaver', 'Crosspath', 'Pathordia', 'Showcase Quarter'];
// The black market vendors (Fig Sly, the Secret Dealer) are never changed (docs/design/canon.md).
const LOCKED = [/::npc\.fig\./, /::pack\.black_market/, /::pack\.hint\.gilded/, /::town\.hidden_vendor/, /V-FIGSLY\./];
// Keys tests/test_dialogue_fit.gd does not measure (labels, titles, prompts...): only the 240-character cap applies.
const SKIP_FIT = ['.name', '.title', '.prompt', '.button', '.label', '.hint', '.blurb', '.machines', '.wheel_names', '.pairs', '.shouts'];
const MAX_CHARS = 240;
const MAX_BARK = 90;
// Rows not applied on purpose ("id  # reason"): rewrites that lost a story beat a GUT test guards.
const HOLD = path.join(dir, 'held_ids.txt');

// ---------- CSV ----------
function parseCsv(t) {
	t = t.replace(/^\uFEFF/, '');
	const rows = []; let row = [], f = '', q = false;
	for (let i = 0; i < t.length; i++) {
		const ch = t[i];
		if (q) { if (ch === '"') { if (t[i + 1] === '"') { f += '"'; i++; } else q = false; } else f += ch; }
		else if (ch === '"') q = true;
		else if (ch === ',') { row.push(f); f = ''; }
		else if (ch === '\n' || ch === '\r') { if (ch === '\r' && t[i + 1] === '\n') i++; row.push(f); rows.push(row); row = []; f = ''; }
		else f += ch;
	}
	if (f || row.length) { row.push(f); rows.push(row); }
	const h = rows.shift();
	return rows.filter((r) => r.length > 1).map((r) => Object.fromEntries(h.map((k, i) => [k, r[i] ?? ''])));
}

// ---------- locating a line in a file ----------
// String literals of the array starting at text[open] ('['): [{start, end, value}] (start/end include the quotes).
function arrayStrings(text, open) {
	const out = [];
	let i = open + 1;
	while (i < text.length) {
		const ch = text[i];
		if (ch === ']') return out;
		if (ch === '"') {
			let j = i + 1;
			while (text[j] !== '"') j += text[j] === '\\' ? 2 : 1;
			out.push({ start: i, end: j + 1, value: JSON.parse(text.slice(i, j + 1)) });
			i = j + 1;
		} else i++;
	}
	throw new Error('unterminated array');
}

// Position-tracking JSON parse: every string value with its path and span.
function jsonSpans(text) {
	const spans = [];
	let i = 0;
	const ws = () => { while (/\s/.test(text[i])) i++; };
	const str = () => { const s = i; i++; while (text[i] !== '"') i += text[i] === '\\' ? 2 : 1; i++; return { start: s, end: i, value: JSON.parse(text.slice(s, i)) }; };
	function value(p) {
		ws();
		const ch = text[i];
		if (ch === '{') {
			i++; ws();
			if (text[i] === '}') { i++; return; }
			for (;;) { ws(); const k = str().value; ws(); i++; value(p.concat([k])); ws(); if (text[i] === ',') { i++; continue; } i++; return; }
		}
		if (ch === '[') {
			i++; ws();
			if (text[i] === ']') { i++; return; }
			for (let n = 0; ; n++) { value(p.concat([n])); ws(); if (text[i] === ',') { i++; continue; } i++; return; }
		}
		if (ch === '"') { const s = str(); spans.push({ path: p, ...s }); return; }
		while (i < text.length && !/[,\]}\s]/.test(text[i])) i++;
	}
	value([]);
	return spans;
}

const fileCache = new Map();
function fileText(file) {
	if (!fileCache.has(file)) fileCache.set(file, fs.readFileSync(path.join(root, file), 'utf8'));
	return fileCache.get(file);
}
const spanCache = new Map();
function spansOf(file) {
	if (!spanCache.has(file)) spanCache.set(file, jsonSpans(fileText(file)));
	return spanCache.get(file);
}
const same = (a, b) => a.length === b.length && a.every((x, k) => x === b[k]);

// The lines of an id's key, in order, plus which one the id names: {file, kind, slots: [{start, end, value, prefix?}], index}.
function locate(id) {
	const parts = id.split('::');
	const file = parts[0], key = parts[1], index = Number(parts[2]);
	const text = fileText(file);
	if (file.endsWith('.tres')) {
		const lines = text.split('\n');
		let offset = 0;
		for (const line of lines) {
			if (line.startsWith(`"${key}":`) || line.startsWith(`${key} = Array[String](`)) {
				const at = line.startsWith('"') ? line.slice(key.length + 3).search(/\S/) + key.length + 3 : line.indexOf('([') + 1;
				if (line[at] === '"') {
					const lit = arrayStrings('[' + line.slice(at) + ']', 0)[0];
					return { file, kind: 'tres', slots: [{ start: offset + at, end: offset + at + lit.end - 1, value: lit.value }], index: 0 };
				}
				return { file, kind: 'tres', slots: arrayStrings(text, offset + at), index };
			}
			offset += line.length + 1;
		}
		return null;
	}
	if (file.endsWith('.txt')) {
		// Loading tips: lineN is the file's line N (1-based); the slots are every tip line (kind | text).
		const slots = [];
		let offset = 0, n = 0, wanted = -1;
		for (const line of text.split('\n')) {
			n++;
			const m = line.match(/^(\s*(?:@\S+\s+)?[a-z]+\s*\|\s*)(.*?)(\r?)$/);
			if (m && !line.trim().startsWith('#')) {
				if (n === Number(key.replace('line', ''))) wanted = slots.length;
				slots.push({ start: offset + m[1].length, end: offset + m[1].length + m[2].length, value: m[2] });
			}
			offset += line.length + 1;
		}
		return wanted < 0 ? { file, kind: 'txt', slots, index: -1 } : { file, kind: 'txt', slots, index: wanted };
	}
	const spans = spansOf(file);
	let prefix = null;
	if (file.endsWith('npcs.json')) {
		const m = key.match(/^(.*)\.(barks)$/);
		const n = spans.find((s) => s.path.length === 2 && s.path[1] === 'id' && s.value === m[1]);
		if (!n) return null;
		prefix = [n.path[0], 'barks'];
	} else if (file.endsWith('old_well_story.json')) {
		let m = key.match(/^beats\.(.*)\.(\d+)$/);
		if (m) prefix = ['beats', m[1], Number(m[2]), 'lines'];
		else if ((m = key.match(/^text\.(.*)$/))) prefix = ['text', m[1]];
	} else {
		prefix = ['text', key];
	}
	if (!prefix) return null;
	const slots = spans.filter((s) => s.path.length >= prefix.length && same(s.path.slice(0, prefix.length), prefix) && s.path.length <= prefix.length + 1);
	if (slots.length === 0) return null;
	return { file, kind: 'json', slots, index: slots.length === 1 && slots[0].path.length === prefix.length ? 0 : index };
}

// The slot holding `want` for an id: the named one when it still says `want`, else the only slot of the key that does (relocated).
function findSlot(loc, want) {
	if (!loc) return { slot: null, why: 'key not found' };
	const named = loc.slots[loc.index];
	if (named && named.value === want) return { slot: named, moved: false };
	const hits = loc.slots.filter((s) => s.value === want);
	if (hits.length === 1) return { slot: hits[0], moved: true };
	return { slot: null, current: named ? named.value : '(no such line)', why: hits.length > 1 ? 'ambiguous' : 'changed' };
}

function encode(kind, text) {
	if (kind === 'txt') return text;
	return JSON.stringify(text); // also Godot's .tres string escaping for one plain line
}

// ---------- validation ----------
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
	return out.concat(['Elowen']);
}
const BANNED = bannedNames();

// What the plain tokens fill to (data/story/royal_family.tres, villain.tres), for literal-name -> token swaps.
function fills() {
	const read = (f) => Object.fromEntries([...fs.readFileSync(path.join(root, f), 'utf8').matchAll(/^(\w+) = "(.*)"$/gm)].map((m) => [m[1], m[2]]));
	const r = read('data/story/royal_family.tres'), v = read('data/story/villain.tres');
	return { '{villain}': v.villain_name, '{villain_title}': v.villain_title, '{town}': r.town, '{kingdom}': r.kingdom, '{showcase}': r.showcase,
		'{pathordia}': r.capital_liberated, '{royal_house}': r.royal_house, '{king}': r.king_name, '{queen}': r.queen_name };
}
const FILLS = fills();

function normalize(s) {
	return s.replace(/[\u2018\u2019\u201B]/g, "'").replace(/[\u201C\u201D\u201F]/g, '"').replace(/\u2026/g, '...').replace(/\s*[\u2014\u2013]\s*/g, ' - ')
		.replace(/\u00A0/g, ' ').replace(/ {2,}/g, ' ').trim();
}
const tokensOf = (s) => (s.match(/\{[a-z_]+\}/g) || []).sort();
const placeholdersOf = (s) => s.match(/%[sd]/g) || [];
const tagOf = (s) => (s.match(/^\[[a-z_]+\]/) || [''])[0];

function validate(row, text) {
	const problems = [];
	const old = row.current_text;
	const file = row.id.split('::')[0];
	const noTokens = file.endsWith('npcs.json') || file.endsWith('.txt');
	if (/[\r\n\t]/.test(text)) problems.push('line break or tab');
	const odd = [...text].filter((c) => (c < ' ' || c > '~') && !old.includes(c));
	if (odd.length) problems.push(`odd characters ${JSON.stringify([...new Set(odd)].join(''))}`);
	// A token may replace the literal name it fills to (canon: story lines use tokens), only when it renders the same (same case, not
	// sentence-initial for "the ..." fills); every other token change fails.
	const lost = tokensOf(old).filter((t) => !text.includes(t));
	const added = tokensOf(text).filter((t) => !old.includes(t));
	const swapOk = (t) => FILLS[t] && old.includes(FILLS[t]) && !(FILLS[t][0] !== FILLS[t][0].toUpperCase() && text.startsWith(t));
	if (lost.length || !added.every(swapOk)) problems.push(`tokens ${tokensOf(old).join('') || '(none)'} -> ${tokensOf(text).join('') || '(none)'}`);
	const unknown = tokensOf(text).filter((t) => !TOKENS.includes(t));
	if (unknown.length) problems.push(`unknown token ${unknown.join('')}`);
	if (noTokens && tokensOf(text).length) problems.push('token in a bark or tip');
	if (!same(placeholdersOf(old), placeholdersOf(text))) problems.push('%s/%d changed');
	if (tagOf(old) !== tagOf(text)) problems.push(`expression tag ${tagOf(old) || '(none)'} -> ${tagOf(text) || '(none)'}`);
	for (const name of BANNED) if (text.includes(name) && !old.includes(name)) problems.push(`banned name "${name}"`);
	if (!noTokens) for (const name of TOKEN_NAMES) if (text.includes(name) && !old.includes(name)) problems.push(`literal "${name}" (use the token)`);
	if (text.length > MAX_CHARS) problems.push(`${text.length} characters (max ${MAX_CHARS})`);
	if (file.endsWith('npcs.json') && text.length >= MAX_BARK) problems.push(`${text.length} characters (barks under ${MAX_BARK}, tests/core/data/test_npc_truth.gd)`);
	if (text.length === 0) problems.push('empty');
	return problems;
}

function measure(rows) {
	const logs = path.join(root, '_logs');
	fs.mkdirSync(logs, { recursive: true });
	fs.writeFileSync(path.join(logs, 'dialogue_fit_in.json'), JSON.stringify(rows.map((r) => ({ id: r.id, text: r.text }))));
	try { fs.unlinkSync(path.join(logs, 'dialogue_fit_out.json')); } catch (e) { /* first run */ }
	execFileSync(GODOT, ['--headless', '--path', root, '-s', 'res://tools/dialogue_fit_check.gd'], { stdio: ['ignore', 'ignore', 'ignore'], timeout: 120000 });
	return JSON.parse(fs.readFileSync(path.join(logs, 'dialogue_fit_out.json'), 'utf8'));
}

// ---------- writing ----------
// edits: [{file, kind, slot, text}] -> files rewritten (each edit replaces one slot's literal).
function writeEdits(edits) {
	const byFile = new Map();
	for (const e of edits) { if (!byFile.has(e.file)) byFile.set(e.file, []); byFile.get(e.file).push(e); }
	for (const [file, list] of byFile) {
		let text = fileText(file);
		list.sort((a, b) => b.slot.start - a.slot.start);
		for (const e of list) text = text.slice(0, e.slot.start) + encode(e.kind, e.text) + text.slice(e.slot.end);
		fs.writeFileSync(path.join(root, file), text);
		fileCache.set(file, text);
		spanCache.delete(file);
	}
}

const area = (batch) => batch.replace(/^batch_\d+_/, '').replace(/_done\.csv$/, '').replace(/_[a-f]$/, '');
const md = (s) => String(s).replace(/\|/g, '\\|');

// Copies of a line that must change with it: an NPC's first bark is also its sample_line, and tools/npc_truth_input.json holds the barks
// npcs.json is rebuilt from (tools/npc_truth.js). Only copies that still say `value` are returned.
function companions(id, value) {
	const [file, key, idx] = id.split('::');
	if (!file.endsWith('npcs.json')) return [];
	const npcId = key.replace(/\.barks$/, '');
	const out = [];
	const n = spansOf(file).find((x) => x.path.length === 2 && x.path[1] === 'id' && x.value === npcId);
	const sample = n && spansOf(file).find((x) => x.path.length === 2 && x.path[0] === n.path[0] && x.path[1] === 'sample_line');
	if (Number(idx) === 0 && sample && sample.value === value) out.push({ file, kind: 'json', slot: sample });
	const input = 'tools/npc_truth_input.json';
	const copy = spansOf(input).find((x) => x.path.length === 3 && x.path[0] === 'barks' && x.path[1] === npcId && x.path[2] === Number(idx));
	if (copy && copy.value === value) out.push({ file: input, kind: 'json', slot: copy });
	return out;
}

// "id  # reason" lines of a text file -> Map(id -> reason).
function idList(file) {
	const out = new Map();
	if (!fs.existsSync(file)) return out;
	for (const raw of fs.readFileSync(file, 'utf8').split(/\r?\n/)) {
		const id = raw.replace(/#.*/, '').trim();
		if (id) out.set(id, (raw.match(/#\s*(.*)$/) || ['', ''])[1].trim());
	}
	return out;
}

function readLedger() { return fs.existsSync(LEDGER) ? JSON.parse(fs.readFileSync(LEDGER, 'utf8')) : []; }

// ---------- revert ----------
if (args.revert) {
	const list = readLedger();
	const ledger = new Map(list.map((e) => [e.id, e]));
	const ids = [...idList(path.resolve(args.revert)).keys()];
	const edits = [], report = [];
	let done = 0;
	for (const id of ids) {
		const entry = ledger.get(id);
		if (!entry || entry.reverted) { report.push(`${entry ? 'already reverted' : 'not in the ledger'}: ${id}`); continue; }
		const found = findSlot(locate(id), entry.after);
		if (!found.slot) { report.push(`skipped (line changed since the pass): ${id}`); continue; }
		edits.push({ file: entry.file, kind: locate(id).kind, slot: found.slot, text: entry.before });
		for (const c of companions(id, entry.after)) edits.push({ ...c, text: entry.before });
		entry.reverted = true;
		done++;
		report.push(`reverted: ${id}`);
	}
	writeEdits(edits);
	fs.writeFileSync(LEDGER, JSON.stringify(list, null, '\t') + '\n');
	console.log(report.join('\n'));
	console.log(`revert: ${done} of ${ids.length} lines put back`);
	process.exit(0);
}

// ---------- merges (Part 3: conflicts merged by hand) ----------
if (args.merge) {
	const ledger = readLedger();
	const rows = parseCsv(fs.readFileSync(path.resolve(args.merge), 'utf8'));
	const ready = [];
	for (const r of rows) {
		const loc = locate(r.id);
		const slot = loc && loc.slots[loc.index];
		if (!slot) { console.log(`no such line: ${r.id}`); continue; }
		const text = normalize(r.new_text);
		const problems = validate({ id: r.id, current_text: slot.value }, text);
		ready.push({ id: r.id, file: loc.file, kind: loc.kind, slot, before: slot.value, text, problems });
	}
	const fit = measure(ready);
	for (const r of ready) {
		const f = fit[r.id];
		if (!SKIP_FIT.some((s) => r.id.split('::')[1].endsWith(s)) && f && (f[0] > 4 || f[1] > 6)) r.problems.push(`too long for the box (${f[0]} / ${f[1]} lines)`);
		console.log(`${r.problems.length ? 'FAILED ' + r.problems.join('; ') : 'ok'}: ${r.id}`);
	}
	const good = ready.filter((r) => !r.problems.length);
	if (args.apply) {
		writeEdits(good.concat(good.flatMap((r) => companions(r.id, r.before).map((c) => ({ ...c, text: r.text })))));
		for (const r of good) ledger.push({ id: r.id, file: r.file, before: r.before, after: r.text, merged: true });
		fs.writeFileSync(LEDGER, JSON.stringify(ledger, null, '\t') + '\n');
	}
	console.log(`merge: ${good.length} of ${ready.length} ${args.apply ? 'applied' : 'would apply'}`);
	process.exit(0);
}

// ---------- the pass ----------
const batches = fs.readdirSync(dir).filter((f) => /^batch_.*_done\.csv$/.test(f)).sort();
const counts = {};
const skippedBlank = [], conflicts = [], failed = [], locked = [], held = [], candidates = [];
const holds = idList(HOLD);
for (const batch of batches) {
	for (const row of parseCsv(fs.readFileSync(path.join(dir, batch), 'utf8'))) {
		const a = area(batch);
		counts[a] = counts[a] || { rows: 0, blank: 0, applied: 0, conflict: 0, failed: 0, held: 0, locked: 0 };
		counts[a].rows++;
		if (!row.new_text.trim()) { counts[a].blank++; skippedBlank.push(row.id); continue; }
		if (LOCKED.some((re) => re.test(row.id))) { counts[a].locked++; locked.push(row); continue; }
		if (holds.has(row.id)) { counts[a].held++; held.push({ ...row, reason: holds.get(row.id) }); continue; }
		const loc = locate(row.id);
		const found = findSlot(loc, row.current_text);
		if (!found.slot && findSlot(loc, normalize(row.new_text)).slot) { counts[a].blank++; skippedBlank.push(row.id); continue; } // applied before
		if (!found.slot) { counts[a].conflict++; conflicts.push({ ...row, game: found.current ?? '', why: found.why, area: a }); continue; }
		const text = normalize(row.new_text);
		if (text === row.current_text) { counts[a].blank++; skippedBlank.push(row.id); continue; }
		candidates.push({ ...row, area: a, file: loc.file, kind: loc.kind, slot: found.slot, moved: found.moved, text, problems: validate(row, text) });
	}
}

if (!args['no-fit']) {
	const fit = measure(candidates);
	for (const c of candidates) {
		const f = fit[c.id];
		if (!f) { c.problems.push('not measured'); continue; }
		c.fit = f;
		if (!SKIP_FIT.some((s) => c.key.endsWith(s)) && (f[0] > 4 || f[1] > 6)) c.problems.push(`too long for the box (${f[0]} / ${f[1]} lines)`);
	}
} else if (args.apply) {
	console.error('--apply needs the fit check'); process.exit(1);
}

const good = candidates.filter((c) => !c.problems.length);
for (const c of candidates) counts[c.area][c.problems.length ? 'failed' : 'applied']++;
for (const c of candidates) if (c.problems.length) failed.push(c);

if (args.apply) {
	writeEdits(good.concat(good.flatMap((c) => companions(c.id, c.current_text).map((x) => ({ ...x, text: c.text })))));
	const ledger = good.map((c) => ({ id: c.id, file: c.file, speaker: c.speaker, before: c.current_text, after: c.text, moved: c.moved || undefined }));
	fs.writeFileSync(LEDGER, JSON.stringify(ledger, null, '\t') + '\n');
}

// Conflicts as a CSV too (Part 3 works from it).
const csvq = (s) => `"${String(s).replace(/"/g, '""')}"`;
if (args.apply) fs.writeFileSync(path.join(dir, 'conflicts.csv'), 'id,speaker,game_text,chatgpt_current_text,new_text,why\n' +
	conflicts.map((c) => [c.id, c.speaker, c.game, c.current_text, c.new_text, c.why].map(csvq).join(',')).join('\n') + '\n');

let out = `# ChatGPT dialogue pass: apply report${args.apply ? '' : ' (DRY RUN - nothing written)'}\n\n` +
	`Generated by \`node tools/apply_dialogue_pass.js${args.apply ? ' --apply' : ''}\` on ${new Date().toISOString().slice(0, 10)} from the ${batches.length} batch files in this folder.\n` +
	`A row is applied only when the game's line still equals the CSV's \`current_text\`. Every applied line: tokens, %s/%d and [expression] tags unchanged, one plain line,\n` +
	`no banned old name, at most ${MAX_CHARS} characters and fits the dialogue box (4 lines at default text size, 6 at the largest; titles, prompts and labels only\n` +
	`the character cap). The black market vendors' lines (Fig Sly, the Secret Dealer) are never touched. Before/after of every applied line: \`applied_ledger.json\`.\n` +
	`Revert lines: list their ids in a text file (one per line) and run \`node tools/apply_dialogue_pass.js --revert=<file>\`.\n\n` +
	`An NPC's first bark also updates its \`sample_line\` and the copy in \`tools/npc_truth_input.json\`; barks stay under ${MAX_BARK} characters (the bubble).\n` +
	`Held rows (\`held_ids.txt\`) are rewrites that lost a story beat a GUT test guards; they are not applied.\n\n` +
	`## Totals\n\n- Rows: ${skippedBlank.length + locked.length + held.length + conflicts.length + candidates.length}\n- ${args.apply ? 'Applied' : 'Would apply'}: ${good.length}` +
	`${good.filter((c) => c.moved).length ? ` (${good.filter((c) => c.moved).length} found at a moved position in their key)` : ''}\n` +
	`- Skipped (blank new_text, or unchanged): ${skippedBlank.length}\n- Conflicts (game line changed since the export): ${conflicts.length}\n` +
	`- Failed validation: ${failed.length}\n- Held (lost a tested story beat): ${held.length}\n- Locked (black market, never applied): ${locked.length}\n\n` +
	`## Per area\n\n| Area | Rows | Applied | Blank | Conflicts | Failed | Held | Locked |\n|---|---:|---:|---:|---:|---:|---:|---:|\n`;
for (const [a, c] of Object.entries(counts)) out += `| ${a} | ${c.rows} | ${c.applied} | ${c.blank} | ${c.conflict} | ${c.failed} | ${c.held} | ${c.locked} |\n`;
out += `\n## Conflicts (${conflicts.length})\n\nNot applied. Also in \`conflicts.csv\`. Part 3 of the brief merges the obvious ones (see the Part 3 section below once it exists).\n\n` +
	`| id | Game text now | ChatGPT's current_text | ChatGPT's new_text |\n|---|---|---|---|\n`;
for (const c of conflicts) out += `| \`${c.id}\` | ${md(c.game)} | ${md(c.current_text)} | ${md(c.new_text)} |\n`;
out += `\n## Failed validation (${failed.length})\n\nNot applied.\n\n| id | Problem | new_text |\n|---|---|---|\n`;
for (const c of failed) out += `| \`${c.id}\` | ${md(c.problems.join('; '))} | ${md(c.text)} |\n`;
out += `\n## Held (${held.length})\n\nNot applied: the rewrite lost a story beat a GUT test checks.\n\n| id | Why | Kept line | ChatGPT's new_text |\n|---|---|---|---|\n`;
for (const c of held) out += `| \`${c.id}\` | ${md(c.reason)} | ${md(c.current_text)} | ${md(c.new_text)} |\n`;
if (locked.length) {
	out += `\n## Locked (${locked.length})\n\nBlack market lines with a new_text in the CSV; left unchanged.\n\n`;
	for (const c of locked) out += `- \`${c.id}\`\n`;
}
// A dry run never overwrites the report of the real apply.
fs.writeFileSync(path.join(dir, args.apply ? 'apply_report.md' : 'apply_report_dry_run.md'), out);
console.log(`apply_dialogue_pass${args.apply ? '' : ' (dry run)'}: ${good.length} ${args.apply ? 'applied' : 'would apply'}, ${skippedBlank.length} blank, ` +
	`${conflicts.length} conflicts, ${failed.length} failed validation, ${held.length} held, ${locked.length} locked`);
