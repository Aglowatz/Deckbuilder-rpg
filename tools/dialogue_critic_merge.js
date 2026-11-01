// Oct 31, the dialogue critic pass, Part 4: merges the chunk agents' suggestions and prepares the sheet columns. No game file is changed.
//   node tools/dialogue_critic_merge.js
// - reads docs/dialogue/critic_oct31/suggestions_NN.csv, sorts the rows into the edit CSV's story order and writes
//   docs/dialogue/critic_suggestions_oct31.csv (rows that fail tools/dialogue_critic_check.js are left out and listed in
//   docs/dialogue/critic_oct31/dropped.md);
// - writes docs/dialogue/critic_oct31/sheet_columns.csv: one row per edit-CSV row, in the sheet's order, with the columns to paste beside
//   the Dialogue Edit tab (Critic suggestion, Accept (Y), Why, Category, Priority);
// - writes <out>/edit_all_accepted.csv: the edit CSV with every suggestion accepted (for a dry run of tools/apply_dialogue_pass.js).
//   --out=<folder> (default docs/dialogue/critic_oct31/dry_run).
const fs = require('fs');
const path = require('path');
const { root, parseCsv, csvq, locate, namedSlot } = require('./dialogue_ids');
const { typedOver, sameLine } = require('./dialogue_edit_rows');
const { problemsOf, bannedNames } = require('./dialogue_critic_check');

const args = Object.fromEntries(process.argv.slice(2).map((a) => { const m = a.match(/^--([a-z-]+)(?:=(.*))?$/); return m ? [m[1], m[2] ?? true] : [a, true]; }));
const DIR = path.join(root, 'docs/dialogue/critic_oct31');
const OUT = path.resolve(root, args.out || 'docs/dialogue/critic_oct31/dry_run');
const EDIT = path.join(root, 'docs/dialogue/edit_oct27.csv');
const COLS = ['ID', 'Zone/Area', 'Speaker', 'Effective line', 'Suggested line', 'Why', 'Category', 'Priority', 'Designer line'];
const CATEGORIES = ['Humor', 'Worldbuilding', 'Story', 'Clarity', 'Voice', 'Natural', 'Fix'];
const PRIORITIES = ['High', 'Medium', 'Low'];

const edit = parseCsv(fs.readFileSync(EDIT, 'utf8'));
const order = new Map(edit.map((r, i) => [r.ID, i]));
const byId = new Map(edit.map((r) => [r.ID, r]));
const effective = (r) => ((r['New line'] || '').trim() ? r['New line'] : r['Current line']) || '';
// The designer's line: a New line, or a rewrite typed over Current line that the game does not say yet (a row changed in the game since
// the export, and synced into the sheet, is not theirs).
const snapshot = JSON.parse(fs.readFileSync(path.join(root, 'docs/dialogue/edit_oct27/export_snapshot.json'), 'utf8'));
function designerLine(r) {
	if ((r['New line'] || '').trim()) return true;
	if (!typedOver(r, snapshot)) return false;
	const slot = namedSlot(locate(r.ID));
	return !slot || !sameLine(slot.value, r['Current line']);
}
const prot = JSON.parse(fs.readFileSync(path.join(DIR, 'protected_phrases.json'), 'utf8'));
const banned = bannedNames();

const kept = [], dropped = [];
const seen = new Map();
for (const file of fs.readdirSync(DIR).filter((f) => /^suggestions_\d+\.csv$/.test(f)).sort()) {
	for (const r of parseCsv(fs.readFileSync(path.join(DIR, file), 'utf8'))) {
		const src = byId.get(r.ID);
		const p = [];
		if (!src) p.push('no such id');
		else {
			if ((r['Effective line'] || '').trim() !== effective(src).trim()) p.push('Effective line differs from the edit CSV');
			if ((r['Suggested line'] || '').trim() === effective(src).trim()) p.push('suggestion equals the line');
			p.push(...problemsOf(r.ID, effective(src), r['Suggested line'] || '', prot[r.ID], banned));
		}
		if (seen.has(r.ID)) p.push(`duplicate of a row in ${seen.get(r.ID)}`);
		if (!CATEGORIES.includes(r.Category)) p.push(`category "${r.Category}"`);
		if (!PRIORITIES.includes(r.Priority)) p.push(`priority "${r.Priority}"`);
		const row = { ...r, Speaker: src ? src.Speaker : r.Speaker, 'Zone/Area': src ? src['Zone/Area'] : r['Zone/Area'], 'Effective line': src ? effective(src) : r['Effective line'], 'Designer line': src && designerLine(src) ? 'Y' : 'N', file };
		if (p.length) { dropped.push({ ...row, problems: p }); continue; }
		seen.set(r.ID, file);
		kept.push(row);
	}
}
kept.sort((a, b) => order.get(a.ID) - order.get(b.ID));

const line = (cells) => cells.map((c) => csvq(String(c ?? ''))).join(',');
fs.writeFileSync(path.join(root, 'docs/dialogue/critic_suggestions_oct31.csv'), '﻿' + [line(COLS), ...kept.map((r) => line(COLS.map((c) => r[c])))].join('\n') + '\n');

const sug = new Map(kept.map((r) => [r.ID, r]));
const sheetCols = ['ID', 'Critic suggestion', 'Accept (Y)', 'Why', 'Category', 'Priority'];
fs.writeFileSync(path.join(DIR, 'sheet_columns.csv'), '﻿' + [line(sheetCols), ...edit.map((r) => {
	const s = sug.get(r.ID);
	return line([r.ID, s ? s['Suggested line'] : '', '', s ? s.Why : '', s ? s.Category : '', s ? s.Priority : '']);
})].join('\n') + '\n');

fs.mkdirSync(OUT, { recursive: true });
const editCols = ['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line', 'Critic suggestion', 'Accept (Y)'];
fs.writeFileSync(path.join(OUT, 'edit_all_accepted.csv'), [line(editCols), ...edit.map((r) => {
	const s = sug.get(r.ID);
	return line([r.ID, r['Zone/Area'], r.Speaker, r["When it's heard"], r['Current line'], r['New line'] || '', s ? s['Suggested line'] : '', s ? 'Y' : '']);
})].join('\n') + '\n');
// The dry run reads export_snapshot.json from the CSV's own folder (re-encoded cells); give the temp copy the same snapshot.
fs.mkdirSync(path.join(OUT, 'edit_all_accepted'), { recursive: true });
fs.copyFileSync(path.join(root, 'docs/dialogue/edit_oct27/export_snapshot.json'), path.join(OUT, 'edit_all_accepted', 'export_snapshot.json'));

let md = `# Critic suggestions dropped by the checks (${new Date().toISOString().slice(0, 10)})\n\n` +
	'Rows the chunk agents wrote that failed `tools/dialogue_critic_check.js` (or were duplicates); not in `critic_suggestions_oct31.csv`.\n\n';
md += dropped.length ? '| id | file | Problems | Suggested line |\n|---|---|---|---|\n' + dropped.map((d) => `| \`${d.ID}\` | ${d.file} | ${d.problems.join('; ')} | ${String(d['Suggested line']).replace(/\|/g, '\\|')} |`).join('\n') + '\n' : 'None.\n';
fs.writeFileSync(path.join(DIR, 'dropped.md'), md);

const tally = (key) => Object.entries(kept.reduce((m, r) => ((m[r[key]] = (m[r[key]] || 0) + 1), m), {})).map((e) => e.join(' ')).join(', ');
console.log(`critic merge: ${kept.length} suggestions kept, ${dropped.length} dropped`);
console.log(`  by priority: ${tally('Priority')}`);
console.log(`  by category: ${tally('Category')}`);
console.log(`  by area: ${Object.entries(kept.reduce((m, r) => ((m[r['Zone/Area'].split(' / ')[0]] = (m[r['Zone/Area'].split(' / ')[0]] || 0) + 1), m), {})).map((e) => e.join(' ')).join(', ')}`);
for (const d of dropped) console.log(`  DROPPED ${d.ID}: ${d.problems.join('; ')}`);
