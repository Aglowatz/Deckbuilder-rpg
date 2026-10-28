// Oct 21: applies an outside dialogue pass (the ChatGPT pass in docs/dialogue/chatgpt_pass_oct21/) to the game's text files.
// Each batch_*_done.csv row is one dialogue box: id (<file>::<key>::<line index>, see tools/dialogue_ids.js), speaker, key, flags, chars,
// current_text, new_text, writer_note. A blank new_text keeps the line. A row is applied only when the game's line still equals current_text
// (a line moved inside its own key, or a loading tip moved to another line, still counts); otherwise it is a conflict and is left alone. Every
// applied line is validated: tokens, %s/%d and the [expression] tag unchanged, one plain line, no banned old name, at most 240 characters and
// fits the dialogue box (measured by Godot: tools/dialogue_fit_check.gd, the same measure as tests/test_dialogue_fit.gd).
//   node tools/apply_dialogue_pass.js                  dry run: report only (apply_report_dry_run.md); rows already applied count as skipped
//   node tools/apply_dialogue_pass.js --apply          writes the game files, apply_report.md and applied_ledger.json
//   node tools/apply_dialogue_pass.js --revert=ids.txt puts the listed ids (one per line, # comments) back to their pre-pass text
//   node tools/apply_dialogue_pass.js --merge=merges.csv --apply   applies hand merges (id,new_text) for conflicts, same validation;
//                                                                  their pre-merge text joins the ledger so --revert covers them
// Options: --dir=<pass folder> (default docs/dialogue/chatgpt_pass_oct21), --no-fit (skip the Godot measure; never with --apply).
//
// Oct 27, one-file edit CSVs (tools/export_dialogue.js): columns ID, Zone/Area, Speaker, When it's heard, Current line, New line.
//   node tools/apply_dialogue_pass.js --csv=docs/dialogue/edit_oct27.csv            dry run (report in docs/dialogue/edit_oct27/)
//   node tools/apply_dialogue_pass.js --csv=docs/dialogue/edit_oct27.csv --apply    applies the rows whose New line differs from the game
//   node tools/apply_dialogue_pass.js --csv=docs/dialogue/edit_oct27.csv --revert   puts every line this CSV changed back
//   node tools/apply_dialogue_pass.js --csv=docs/dialogue/edit_oct27.csv --revert=ids.txt   only the listed ids
// The CSV can be applied again after more edits: the ledger keeps each line's text from before its first change, and a row whose
// Current line a spreadsheet re-encoded still matches through the folder's export_snapshot.json.
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');
const { root, parseCsv, csvq, fileText, spansOf, setFileText, locate, namedSlot, encode, same } = require('./dialogue_ids');

const GODOT = 'C:/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe';
const args = Object.fromEntries(process.argv.slice(2).map((a) => { const m = a.match(/^--([a-z-]+)(?:=(.*))?$/); return m ? [m[1], m[2] ?? true] : [a, true]; }));
const CSV = args.csv ? path.resolve(root, args.csv) : null;
const dir = CSV ? CSV.replace(/\.csv$/i, '') : path.resolve(root, args.dir || 'docs/dialogue/chatgpt_pass_oct21');
fs.mkdirSync(dir, { recursive: true });
const LEDGER = path.join(dir, 'applied_ledger.json');
const SNAPSHOT = path.join(dir, 'export_snapshot.json');

const TOKENS = ['{villain}', '{villain_title}', '{prince}', '{prince_full}', '{royal_house}', '{king}', '{queen}', '{rescuer}', '{kingdom}', '{town}',
	'{capital}', '{pathordia}', '{showcase}', '{wanderer}'];
// Names the brief says story lines must write as tokens (barks and tips have no tokens and may name them plainly).
const TOKEN_NAMES = ['Primm', 'His Perfection', 'Tessar', 'Wayweaver', 'Crosspath', 'Pathordia', 'Showcase Quarter'];
// The black market vendors (Fig Sly, the Secret Dealer) are never changed (docs/design/canon.md).
const LOCKED = [/::npc\.fig\./, /::pack\.black_market/, /::pack\.hint\.gilded/, /::town\.hidden_vendor/, /V-FIGSLY\./];
// Keys tests/test_dialogue_fit.gd does not measure (labels, titles, prompts...): only the 240-character cap applies.
const SKIP_FIT = ['name', 'title', 'prompt', 'button', 'label', 'hint', 'blurb', 'machines', 'wheel_names', 'pairs', 'shouts', 'banner', 'warn'];
const MAX_CHARS = 240;
const MAX_BARK = 90;
// Rows not applied on purpose ("id  # reason"): rewrites that lost a story beat a GUT test guards.
const HOLD = path.join(dir, 'held_ids.txt');

// Text the game never fills tokens into (barks, tips, battle intros and events, dungeon event screens).
const noTokenFile = (id) => /npcs\.json::|\.txt::|boss_intros\.json::|encounter_scripts\.json::|dungeon_content\.json::dungeons\//.test(id);
// Lines shown outside the dialogue box (Quest Log, dungeon event screens): no box measure, and a long one may grow by a quarter.
const offBox = (id) => /\.gd::|dungeon_content\.json::dungeons\/|encounter_scripts\.json::/.test(id);
const lastSegment = (key) => key.split(/[./]/).pop();
const skipFit = (id) => offBox(id) || SKIP_FIT.includes(lastSegment(id.split('::')[1])) || SKIP_FIT.some((s) => id.split('::')[1].endsWith('.' + s));

// The slot holding one of `wants` for an id: the named one when it says it, else the only slot of the key that does (relocated).
function findSlot(loc, wants) {
	if (!loc) return { slot: null, why: 'key not found' };
	wants = [].concat(wants).filter((w) => typeof w === 'string');
	const named = namedSlot(loc);
	for (const want of wants) if (named && named.value === want) return { slot: named, moved: false, want };
	for (const want of wants) {
		const hits = loc.slots.filter((s) => s.value === want);
		if (hits.length === 1) return { slot: hits[0], moved: true, want };
		if (hits.length > 1) return { slot: null, current: named ? named.value : '(no such line)', why: 'ambiguous' };
	}
	return { slot: null, current: named ? named.value : '(no such line)', why: 'changed' };
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
	const noTokens = noTokenFile(row.id);
	if (/[\r\n\t]/.test(text) && !/[\r\n\t]/.test(old)) problems.push('line break or tab');
	const odd = [...text].filter((c) => (c < ' ' || c > '~') && c !== '\n' && !old.includes(c));
	if (odd.length) problems.push(`odd characters ${JSON.stringify([...new Set(odd)].join(''))}`);
	// A token may replace the literal name it fills to (canon: story lines use tokens), only when it renders the same (same case, not
	// sentence-initial for "the ..." fills); every other token change fails.
	const lost = tokensOf(old).filter((t) => !text.includes(t));
	const added = tokensOf(text).filter((t) => !old.includes(t));
	const swapOk = (t) => FILLS[t] && old.includes(FILLS[t]) && !(FILLS[t][0] !== FILLS[t][0].toUpperCase() && text.startsWith(t));
	if (lost.length || !added.every(swapOk)) problems.push(`tokens ${tokensOf(old).join('') || '(none)'} -> ${tokensOf(text).join('') || '(none)'}`);
	const unknown = tokensOf(text).filter((t) => !TOKENS.includes(t));
	if (unknown.length) problems.push(`unknown token ${unknown.join('')}`);
	if (noTokens && tokensOf(text).length > tokensOf(old).length) problems.push('token where the game shows it literally');
	if (!same(placeholdersOf(old), placeholdersOf(text))) problems.push('%s/%d changed');
	if (tagOf(old) !== tagOf(text)) problems.push(`expression tag ${tagOf(old) || '(none)'} -> ${tagOf(text) || '(none)'}`);
	for (const name of BANNED) if (text.includes(name) && !old.includes(name)) problems.push(`banned name "${name}"`);
	if (!noTokens) for (const name of TOKEN_NAMES) if (text.includes(name) && !old.includes(name)) problems.push(`literal "${name}" (use the token)`);
	const cap = offBox(row.id) ? Math.max(MAX_CHARS, Math.ceil(old.length * 1.25)) : MAX_CHARS;
	if (text.length > cap) problems.push(`${text.length} characters (max ${cap})`);
	if (file.endsWith('npcs.json') && text.length >= MAX_BARK) problems.push(`${text.length} characters (barks under ${MAX_BARK}, tests/core/data/test_npc_truth.gd)`);
	if (text.length === 0) problems.push('empty');
	return problems;
}

function measure(rows) {
	const logs = path.join(root, '_logs');
	fs.mkdirSync(logs, { recursive: true });
	fs.writeFileSync(path.join(logs, 'dialogue_fit_in.json'), JSON.stringify(rows.map((r) => ({ id: r.id, text: r.text }))));
	try { fs.unlinkSync(path.join(logs, 'dialogue_fit_out.json')); } catch (e) { /* first run */ }
	if (!rows.length) return {};
	execFileSync(GODOT, ['--headless', '--path', root, '-s', 'res://tools/dialogue_fit_check.gd'], { stdio: ['ignore', 'ignore', 'ignore'], timeout: 120000 });
	return JSON.parse(fs.readFileSync(path.join(logs, 'dialogue_fit_out.json'), 'utf8'));
}
const tooLong = (id, f) => !skipFit(id) && f && (f[0] > 4 || f[1] > 6);

// ---------- writing ----------
// edits: [{file, kind, slot, text}] -> files rewritten (each edit replaces one slot's literal).
function writeEdits(edits) {
	const byFile = new Map();
	for (const e of edits) { if (!byFile.has(e.file)) byFile.set(e.file, []); byFile.get(e.file).push(e); }
	for (const [file, list] of byFile) {
		let text = fileText(file);
		list.sort((a, b) => b.slot.start - a.slot.start);
		for (const e of list) text = text.slice(0, e.slot.start) + encode(e.kind, e.text) + text.slice(e.slot.end);
		setFileText(file, text);
	}
}

const area = (batch) => batch.replace(/^batch_\d+_/, '').replace(/_done\.csv$/, '').replace(/_[a-f]$/, '');
const md = (s) => String(s).replace(/\|/g, '\\|').replace(/\n/g, ' ');

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
	// Bare --revert (only with --csv): every line the CSV changed.
	const ids = args.revert === true ? (CSV ? list.filter((e) => !e.reverted).map((e) => e.id) : []) : [...idList(path.resolve(args.revert)).keys()];
	if (args.revert === true && !CSV) { console.error('--revert needs a list of ids (--revert=ids.txt), or --csv=<file> to revert all of that CSV'); process.exit(1); }
	const edits = [], report = [];
	let done = 0;
	for (const id of ids) {
		const entry = ledger.get(id);
		if (!entry || entry.reverted) { report.push(`${entry ? 'already reverted' : 'not in the ledger'}: ${id}`); continue; }
		const loc = locate(id);
		const found = findSlot(loc, entry.after);
		if (!found.slot) { report.push(`skipped (line changed since the pass): ${id}`); continue; }
		edits.push({ file: entry.file, kind: loc.kind, slot: found.slot, text: entry.before });
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
		const slot = namedSlot(loc);
		if (!slot) { console.log(`no such line: ${r.id}`); continue; }
		const text = normalize(r.new_text);
		const problems = validate({ id: r.id, current_text: slot.value }, text);
		ready.push({ id: r.id, file: loc.file, kind: loc.kind, slot, before: slot.value, text, problems });
	}
	const fit = measure(ready);
	for (const r of ready) {
		const f = fit[r.id];
		if (tooLong(r.id, f)) r.problems.push(`too long for the box (${f[0]} / ${f[1]} lines)`);
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
// Rows: the batch files of a pass folder, or one edit CSV (its columns mapped onto the batch columns).
const sources = [];
if (CSV) {
	const snapshot = fs.existsSync(SNAPSHOT) ? JSON.parse(fs.readFileSync(SNAPSHOT, 'utf8')) : {};
	const rows = parseCsv(fs.readFileSync(CSV, 'utf8')).map((r) => ({ id: r.ID, speaker: r.Speaker, key: (r.ID || '').split('::')[1] || '', current_text: r['Current line'] ?? '',
		new_text: r['New line'] ?? '', snapshot: snapshot[r.ID], area: (r['Zone/Area'] || '').split(' / ')[0] }));
	sources.push({ name: path.basename(CSV), rows });
} else {
	for (const batch of fs.readdirSync(dir).filter((f) => /^batch_.*_done\.csv$/.test(f)).sort()) {
		sources.push({ name: batch, rows: parseCsv(fs.readFileSync(path.join(dir, batch), 'utf8')).map((r) => ({ ...r, area: area(batch) })) });
	}
}
const ledgerBefore = readLedger();
const ownAfter = new Map((CSV ? ledgerBefore : []).filter((e) => !e.reverted).map((e) => [e.id, e.after])); // lines this pass already changed
const counts = {};
const skippedBlank = [], conflicts = [], failed = [], locked = [], held = [], candidates = [];
const holds = idList(HOLD);
for (const source of sources) {
	for (const row of source.rows) {
		if (!row.id) continue;
		const a = row.area;
		counts[a] = counts[a] || { rows: 0, blank: 0, applied: 0, conflict: 0, failed: 0, held: 0, locked: 0 };
		counts[a].rows++;
		if (!row.new_text.trim()) { counts[a].blank++; skippedBlank.push(row.id); continue; }
		if (LOCKED.some((re) => re.test(row.id))) { counts[a].locked++; locked.push(row); continue; }
		if (holds.has(row.id)) { counts[a].held++; held.push({ ...row, reason: holds.get(row.id) }); continue; }
		const text = normalize(row.new_text);
		const loc = locate(row.id);
		if (loc && namedSlot(loc) && namedSlot(loc).value === text) { counts[a].blank++; skippedBlank.push(row.id); continue; } // applied before, or unchanged
		// The game line may still be the CSV's Current line, the export snapshot of it (a spreadsheet re-encoded the cell), or this pass's own
		// earlier change (the row was edited again after an apply).
		const found = findSlot(loc, [row.current_text, row.snapshot, ownAfter.get(row.id)]);
		if (!found.slot && findSlot(loc, text).slot) { counts[a].blank++; skippedBlank.push(row.id); continue; } // applied before (moved)
		if (!found.slot) { counts[a].conflict++; conflicts.push({ ...row, game: found.current ?? '', why: found.why, area: a }); continue; }
		const base = { ...row, current_text: found.slot.value };
		if (text === found.slot.value) { counts[a].blank++; skippedBlank.push(row.id); continue; }
		candidates.push({ ...base, area: a, file: loc.file, kind: loc.kind, slot: found.slot, moved: found.moved, text, problems: validate(base, text) });
	}
}

if (!args['no-fit']) {
	const fit = measure(candidates.filter((c) => !skipFit(c.id)));
	for (const c of candidates) {
		if (skipFit(c.id)) continue;
		const f = fit[c.id];
		if (!f) { c.problems.push('not measured'); continue; }
		c.fit = f;
		if (tooLong(c.id, f)) c.problems.push(`too long for the box (${f[0]} / ${f[1]} lines)`);
	}
} else if (args.apply) {
	console.error('--apply needs the fit check'); process.exit(1);
}

const good = candidates.filter((c) => !c.problems.length);
for (const c of candidates) counts[c.area][c.problems.length ? 'failed' : 'applied']++;
for (const c of candidates) if (c.problems.length) failed.push(c);

if (args.apply) {
	writeEdits(good.concat(good.flatMap((c) => companions(c.id, c.current_text).map((x) => ({ ...x, text: c.text })))));
	const fresh = good.map((c) => ({ id: c.id, file: c.file, speaker: c.speaker, before: c.current_text, after: c.text, moved: c.moved || undefined }));
	let ledger = fresh;
	if (CSV) {
		// One ledger across applies: a line changed again keeps the text from before its first change, so --revert restores the original.
		const byId = new Map(ledgerBefore.map((e) => [e.id, e]));
		for (const e of fresh) {
			const prev = byId.get(e.id);
			byId.set(e.id, prev && !prev.reverted ? { ...e, before: prev.before } : e);
		}
		ledger = [...byId.values()];
	}
	fs.writeFileSync(LEDGER, JSON.stringify(ledger, null, '\t') + '\n');
}

// Conflicts as a CSV too (Part 3 works from it).
if (args.apply) fs.writeFileSync(path.join(dir, 'conflicts.csv'), 'id,speaker,game_text,chatgpt_current_text,new_text,why\n' +
	conflicts.map((c) => [c.id, c.speaker, c.game, c.current_text, c.new_text, c.why].map(csvq).join(',')).join('\n') + '\n');

const fromWhat = CSV ? `\`${path.relative(root, CSV).replace(/\\/g, '/')}\`` : `the ${sources.length} batch files in this folder`;
const cmd = `node tools/apply_dialogue_pass.js${CSV ? ` --csv=${path.relative(root, CSV).replace(/\\/g, '/')}` : ''}`;
let out = `# Dialogue pass: apply report${args.apply ? '' : ' (DRY RUN - nothing written)'}\n\n` +
	`Generated by \`${cmd}${args.apply ? ' --apply' : ''}\` on ${new Date().toISOString().slice(0, 10)} from ${fromWhat}.\n` +
	`A row is applied only when the game's line still equals the CSV's current line. Every applied line: tokens, %s/%d and [expression] tags unchanged, one plain line,\n` +
	`no banned old name, at most ${MAX_CHARS} characters and fits the dialogue box (4 lines at default text size, 6 at the largest; titles, prompts and labels only\n` +
	`the character cap; Quest Log and dungeon event screen text may grow by a quarter). The black market vendors' lines (Fig Sly, the Secret Dealer) are never touched.\n` +
	`Before/after of every applied line: \`applied_ledger.json\`.\n` +
	`Revert lines: list their ids in a text file (one per line) and run \`${cmd} --revert=<file>\`${CSV ? ` (or \`${cmd} --revert\` for all of them)` : ''}.\n\n` +
	`An NPC's first bark also updates its \`sample_line\` and the copy in \`tools/npc_truth_input.json\`; barks stay under ${MAX_BARK} characters (the bubble).\n` +
	`Held rows (\`held_ids.txt\`) are rewrites that lost a story beat a GUT test guards; they are not applied.\n\n` +
	`## Totals\n\n- Rows: ${skippedBlank.length + locked.length + held.length + conflicts.length + candidates.length}\n- ${args.apply ? 'Applied' : 'Would apply'}: ${good.length}` +
	`${good.filter((c) => c.moved).length ? ` (${good.filter((c) => c.moved).length} found at a moved position in their key)` : ''}\n` +
	`- Skipped (blank new line, unchanged, or applied before): ${skippedBlank.length}\n- Conflicts (game line changed since the export): ${conflicts.length}\n` +
	`- Failed validation: ${failed.length}\n- Held (lost a tested story beat): ${held.length}\n- Locked (black market, never applied): ${locked.length}\n\n` +
	`## Per area\n\n| Area | Rows | Applied | Blank | Conflicts | Failed | Held | Locked |\n|---|---:|---:|---:|---:|---:|---:|---:|\n`;
for (const [a, c] of Object.entries(counts)) out += `| ${a} | ${c.rows} | ${c.applied} | ${c.blank} | ${c.conflict} | ${c.failed} | ${c.held} | ${c.locked} |\n`;
if (good.length) {
	out += `\n## ${args.apply ? 'Applied' : 'Would apply'} (${good.length})\n\n| id | Before | After |\n|---|---|---|\n`;
	for (const c of good) out += `| \`${c.id}\` | ${md(c.current_text)} | ${md(c.text)} |\n`;
}
out += `\n## Conflicts (${conflicts.length})\n\nNot applied. Also in \`conflicts.csv\`.\n\n` +
	`| id | Game text now | CSV's current line | CSV's new line |\n|---|---|---|---|\n`;
for (const c of conflicts) out += `| \`${c.id}\` | ${md(c.game)} | ${md(c.current_text)} | ${md(c.new_text)} |\n`;
out += `\n## Failed validation (${failed.length})\n\nNot applied.\n\n| id | Problem | new line |\n|---|---|---|\n`;
for (const c of failed) out += `| \`${c.id}\` | ${md(c.problems.join('; '))} | ${md(c.text)} |\n`;
out += `\n## Held (${held.length})\n\nNot applied: the rewrite lost a story beat a GUT test checks.\n\n| id | Why | Kept line | New line |\n|---|---|---|---|\n`;
for (const c of held) out += `| \`${c.id}\` | ${md(c.reason)} | ${md(c.current_text)} | ${md(c.new_text)} |\n`;
if (locked.length) {
	out += `\n## Locked (${locked.length})\n\nBlack market lines with a new line in the CSV; left unchanged.\n\n`;
	for (const c of locked) out += `- \`${c.id}\`\n`;
}
// A dry run never overwrites the report of the real apply.
fs.writeFileSync(path.join(dir, args.apply ? 'apply_report.md' : 'apply_report_dry_run.md'), out);
console.log(`apply_dialogue_pass${args.apply ? '' : ' (dry run)'}: ${good.length} ${args.apply ? 'applied' : 'would apply'}, ${skippedBlank.length} blank, ` +
	`${conflicts.length} conflicts, ${failed.length} failed validation, ${held.length} held, ${locked.length} locked`);
for (const c of failed) console.log(`  FAILED ${c.id}: ${c.problems.join('; ')}`);
for (const c of conflicts) console.log(`  CONFLICT ${c.id}: ${c.why}`);
