// Oct 31: rebuilds docs/dialogue/edit_oct27.csv from the sheet's Dialogue Edit tab (a get_values dump of A1:H, saved as JSON), so the
// local file is what the designer sees: their rewrites typed over Current line, the earlier review columns G/H. On top:
//   - Speaker and When it's heard from a fresh `node tools/export_dialogue.js --out=<tmp>` (the Oct 31 label fixes);
//   - Current line = the game's text for the rows changed on Oct 31 (fixes.js merges and the {rescuer} hand edits);
//   - the leading ' that Google Sheets swallows is put back (it is part of the line, not an edit).
//   node docs/dialogue/fixes_oct31/sync_from_sheet.js <sheet.json> <fresh-export.csv> <fixed_ids.json>
const fs = require('fs');
const path = require('path');
const { root, parseCsv, csvq } = require('../../../tools/dialogue_ids');
const { sameLine } = require('../../../tools/dialogue_edit_rows');

const [sheetFile, exportFile, fixedFile] = process.argv.slice(2);
const sheet = JSON.parse(fs.readFileSync(sheetFile, 'utf8')).values;
const fresh = new Map(parseCsv(fs.readFileSync(exportFile, 'utf8')).map((r) => [r.ID, r]));
const fixed = new Set(JSON.parse(fs.readFileSync(fixedFile, 'utf8')));
const snapshot = JSON.parse(fs.readFileSync(path.join(root, 'docs/dialogue/edit_oct27/export_snapshot.json'), 'utf8'));
const header = sheet[0];
const out = [header.map(csvq).join(',')];
let typedOver = 0, quoteFix = 0, fixedRows = 0;
for (const row of sheet.slice(1)) {
	const cells = header.map((_, i) => row[i] ?? '');
	const id = cells[0];
	const now = fresh.get(id);
	if (!now) throw new Error(`no such id in the fresh export: ${id}`);
	cells[2] = now.Speaker;
	cells[3] = now["When it's heard"];
	const snap = snapshot[id] ?? '';
	if (fixed.has(id)) { cells[4] = now['Current line']; fixedRows++; }
	else if (sameLine(cells[4], snap)) { if (cells[4] !== snap && snap.startsWith("'")) quoteFix++; cells[4] = snap; }
	else typedOver++;
	out.push(cells.map(csvq).join(','));
}
fs.writeFileSync(path.join(root, 'docs/dialogue/edit_oct27.csv'), '﻿' + out.join('\n') + '\n');
console.log(`edit_oct27.csv: ${sheet.length - 1} rows; ${typedOver} designer rewrites typed over Current line, ${fixedRows} rows fixed on Oct 31, ${quoteFix} swallowed quotes restored`);
