// Fable pass Nov 1 (Part 8): refreshes the designer's dialogue sheet CSV from a fresh export WITHOUT reordering it.
//   node tools/export_dialogue.js --out=_logs/export_nov1/export.csv
//   node tools/merge_dialogue_export.js --fresh=_logs/export_nov1/export.csv [--sheet=docs/dialogue/edit_oct27.csv] [--new_rows=docs/dialogue/new_rows_nov1.csv]
// Existing rows keep their IDs, order and every extra column (New line, Suggested, Critic...); only "Current line" is refreshed from
// the game text. IDs the export no longer has are kept (listed). New IDs are appended at the end in the export's own order and also
// listed in --new_rows (ID, Zone/Area, Speaker, When it's heard, Line) unless already there. The export's snapshot JSON is copied beside
// the sheet (the importer reads it).
const fs = require("fs");
const path = require("path");
const args = Object.fromEntries(process.argv.slice(2).map(a => { const m = a.match(/^--([^=]+)=(.*)$/); return m ? [m[1], m[2]] : [a, true]; }));
const sheetPath = args.sheet || "docs/dialogue/edit_oct27.csv";
const freshPath = args.fresh;
const newRowsPath = args.new_rows || "docs/dialogue/new_rows_nov1.csv";
if (!freshPath) { console.error("--fresh=<export csv> is required"); process.exit(1); }

function parse(data) {
  const rows = []; let row = []; let cell = ""; let q = false;
  for (let i = 0; i < data.length; i++) {
    const c = data[i];
    if (q) { if (c === '"') { if (data[i + 1] === '"') { cell += '"'; i++; } else q = false; } else cell += c; }
    else if (c === '"') q = true;
    else if (c === ",") { row.push(cell); cell = ""; }
    else if (c === "\n") { row.push(cell); rows.push(row); row = []; cell = ""; }
    else if (c !== "\r") cell += c;
  }
  if (cell.length || row.length) { row.push(cell); rows.push(row); }
  return rows;
}
function q(s) { return '"' + String(s ?? "").replace(/"/g, '""') + '"'; }
const sheetRaw = fs.readFileSync(sheetPath, "utf8");
const bom = sheetRaw.startsWith("﻿") ? "﻿" : "";
const sheet = parse(sheetRaw.replace(/^﻿/, ""));
const fresh = parse(fs.readFileSync(freshPath, "utf8").replace(/^﻿/, ""));
const header = sheet[0];
const width = header.length;
const col = name => header.indexOf(name);
const ID = col("ID"), CUR = col("Current line");
const fHeader = fresh[0];
const fcol = name => fHeader.indexOf(name);
const freshById = new Map(fresh.slice(1).map(r => [r[fcol("ID")], r]));
const seen = new Set();
let refreshed = 0, kept = 0;
const out = [header];
for (const row of sheet.slice(1)) {
  const id = row[ID];
  seen.add(id);
  const f = freshById.get(id);
  const copy = row.slice();
  while (copy.length < width) copy.push("");
  if (f) { if (f[fcol("Current line")] !== row[CUR]) { copy[CUR] = f[fcol("Current line")]; refreshed++; } }
  else kept++;
  out.push(copy);
}
const added = [];
for (const f of fresh.slice(1)) {
  const id = f[fcol("ID")];
  if (seen.has(id)) continue;
  const row = new Array(width).fill("");
  for (const name of ["ID", "Zone/Area", "Speaker", "When it's heard", "Current line", "New line"]) if (col(name) >= 0 && fcol(name) >= 0) row[col(name)] = f[fcol(name)];
  out.push(row);
  added.push(f);
}
fs.writeFileSync(sheetPath, bom + out.map(r => r.map(q).join(",")).join("\n") + "\n");
// the new rows list for the designer
let newRows = fs.existsSync(newRowsPath) ? fs.readFileSync(newRowsPath, "utf8") : "ID,Zone/Area,Speaker,When it's heard,Line\n";
const listed = new Set(parse(newRows).slice(1).map(r => r[0]));
let listedNow = 0;
for (const f of added) {
  const id = f[fcol("ID")];
  if (listed.has(id)) continue;
  newRows += [id, f[fcol("Zone/Area")], f[fcol("Speaker")], f[fcol("When it's heard")], f[fcol("Current line")]].map(q).join(",") + "\n";
  listedNow++;
}
fs.writeFileSync(newRowsPath, newRows);
// the exporter keeps its snapshot in <csv without .csv>/export_snapshot.json; the importer reads the sheet folder of the same name
const snapshot = path.join(freshPath.replace(/.csv$/, ""), "export_snapshot.json");
const target = path.join(sheetPath.replace(/.csv$/, ""), "export_snapshot.json");
if (fs.existsSync(snapshot)) { fs.mkdirSync(path.dirname(target), { recursive: true }); fs.copyFileSync(snapshot, target); }
console.log(`sheet ${sheetPath}: ${sheet.length - 1} rows kept in order (${refreshed} current lines refreshed, ${kept} ids the export no longer has), ${added.length} new rows appended, ${listedNow} listed in ${newRowsPath}`);
