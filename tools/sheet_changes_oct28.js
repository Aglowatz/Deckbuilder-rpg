// Overnight Oct 28: writes docs/design/sheet_changes_oct28.csv - every changed or new card row of data/source/card_list.csv since the
// base commit, with the sheet's Card List columns (so the rows can be pasted into the Google Sheet), plus the availability column
// (Part 2) for every card, in a second file docs/design/sheet_availability_oct28.csv.
//   node tools/sheet_changes_oct28.js [base-commit]      (default a5807ea1 = pre-overnight-oct27)
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const repo = path.resolve(__dirname, '..');
const base = process.argv[2] || 'a5807ea1';

function parse(t) { const rows = []; let row = [], f = '', q = false; for (let i = 0; i < t.length; i++) { const c = t[i]; if (q) { if (c === '"') { if (t[i + 1] === '"') { f += '"'; i++; } else q = false; } else f += c; } else { if (c === '"') q = true; else if (c === ',') { row.push(f); f = ''; } else if (c === '\n') { row.push(f); rows.push(row); row = []; f = ''; } else if (c === '\r') { } else f += c; } } if (f.length || row.length) { row.push(f); rows.push(row); } return rows; }
function cell(v) { v = String(v == null ? '' : v); return /[",\n\r]/.test(v) ? '"' + v.replace(/"/g, '""') + '"' : v; }
function old(file) { return execSync(`git show ${base}:${file}`, { cwd: repo, encoding: 'utf8', maxBuffer: 1 << 26 }); }
function now(file) { return fs.readFileSync(path.join(repo, file), 'utf8'); }

const ID = 14;
const beforeRows = parse(old('data/source/card_list.csv'));
const afterRows = parse(now('data/source/card_list.csv'));
const header = afterRows[0];
const before = {};
for (const r of beforeRows.slice(1)) { const id = (r[ID] || '').trim(); if (id) before[id] = r; }
let section = '';
const changed = [];
for (const r of afterRows.slice(1)) {
  const id = (r[ID] || '').trim();
  if (!id) { const h = (r[0] || '').trim(); if (h.endsWith(':') && !(r[2] || '').trim()) section = h; continue; }
  const prev = before[id];
  let what = '';
  if (!prev) what = 'NEW ROW';
  else {
    const cols = [];
    for (let i = 0; i < r.length; i++) if ((prev[i] || '').trim() !== (r[i] || '').trim()) cols.push(header[i] || ('col ' + i));
    if (cols.length) what = 'changed: ' + cols.join('; ');
  }
  if (what) changed.push({ section, row: r, what });
}
const availability = {};
for (const r of parse(now('data/source/card_overrides.csv')).slice(1)) { const id = (r[0] || '').trim(); if (id) availability[id] = (r[2] || 'GENERAL').trim() || 'GENERAL'; }

const outRows = [[...header, 'Section (sheet)', 'Change', 'Availability']];
for (const c of changed) outRows.push([...c.row, c.section, c.what, availability[(c.row[ID] || '').trim()] || 'GENERAL']);
fs.writeFileSync(path.join(repo, 'docs/design/sheet_changes_oct28.csv'), outRows.map(r => r.map(cell).join(',')).join('\n') + '\n');

const avRows = [['Card ID', 'Name', 'Rarity', 'Availability']];
for (const r of afterRows.slice(1)) { const id = (r[ID] || '').trim(); if (id) avRows.push([id, r[2], r[1], availability[id] || 'GENERAL']); }
fs.writeFileSync(path.join(repo, 'docs/design/sheet_availability_oct28.csv'), avRows.map(r => r.map(cell).join(',')).join('\n') + '\n');
console.log(`${changed.length} changed/new card rows -> docs/design/sheet_changes_oct28.csv; ${avRows.length - 1} availability rows -> docs/design/sheet_availability_oct28.csv`);
