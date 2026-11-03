// Overnight Nov 2-3, Part 1: builds the one edit CSV that applies the whole critic pass to the CURRENT game text (the dialogue freeze ends).
//   node tools/dialogue_build_nov3.js
// Reads docs/dialogue/applied_nov3/export_before.csv (tools/export_dialogue.js of the game as it is) and fills "New line" from, in order:
//   1. docs/dialogue/critic_suggestions_oct31.csv - every suggestion accepted (incl. the 12 designer-line fixes) when the line is still the one the
//      critic saw ("Effective line" == current); a line changed since (the designer's own rewrites) keeps the designer's text (logged as skipped);
//   2. docs/dialogue/typo_fixes_nov1.csv - the typo fixes, applied on top of whatever the line becomes (double spaces, " .", color -> colour);
//   3. docs/dialogue/new_lines_proposed_oct31.csv - the Primm phase-1 rule rewrite.
// Writes docs/dialogue/applied_nov3/edit_apply.csv (the importer's columns) and build_log.md.
const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const dir = path.join(root, "docs/dialogue/applied_nov3");

function parseCsv(text) {
	const rows = [];
	let row = [], cell = "", quoted = false;
	text = text.replace(/^﻿/, "");
	for (let i = 0; i < text.length; i++) {
		const c = text[i];
		if (quoted) {
			if (c === '"' && text[i + 1] === '"') { cell += '"'; i++; }
			else if (c === '"') quoted = false;
			else cell += c;
		} else if (c === '"') quoted = true;
		else if (c === ",") { row.push(cell); cell = ""; }
		else if (c === "\n" || c === "\r") {
			if (c === "\r" && text[i + 1] === "\n") i++;
			row.push(cell); cell = "";
			if (row.some((v) => v !== "")) rows.push(row);
			row = [];
		} else cell += c;
	}
	if (cell !== "" || row.length) { row.push(cell); rows.push(row); }
	return rows;
}
const table = (file) => {
	const rows = parseCsv(fs.readFileSync(path.join(root, file), "utf8"));
	const head = rows.shift();
	return rows.map((r) => Object.fromEntries(head.map((h, i) => [h, r[i] ?? ""])));
};
const q = (s) => `"${String(s).replace(/"/g, '""')}"`;

const exportRows = table("docs/dialogue/applied_nov3/export_before.csv");
const byId = new Map(exportRows.map((r) => [r["ID"], r]));
const log = [];
let accepted = 0, skippedChanged = 0, missing = 0, typos = 0, proposed = 0;

for (const s of table("docs/dialogue/critic_suggestions_oct31.csv")) {
	const row = byId.get(s["ID"]);
	if (!row) { missing += 1; log.push(`- MISSING id ${s["ID"]}`); continue; }
	// the line changed since only by the Nov 1 typo fixes (spacing, its / shes / aquainted): the suggestion carries those fixes too, so it is
	// accepted when it still changes the line; one that now equals the line is a no-op
	const typoOnly = (a) => a.replace(/ {2,}/g, " ").trim().replace(/\bits\b/g, "it's").replace(/\bshes\b/g, "she's").replace(/aquainted/g, "acquainted").replace(/their shouting/g, "they're shouting").replace(/Primm's/g, "{villain}'s");
	if (row["Current line"] !== s["Effective line"] && typoOnly(row["Current line"]) === typoOnly(s["Effective line"]) && s["Suggested line"] !== row["Current line"]) {
		row["New line"] = s["Suggested line"];
		row._source = "critic (over the Nov 1 typo fix)";
		accepted += 1;
		log.push(`- accepted over a typo-level change: ${s["ID"]}`);
		continue;
	}
	if (row["Current line"] !== s["Effective line"]) {
		skippedChanged += 1;
		log.push(`- KEPT designer text (line changed since the critic saw it): ${s["ID"]}\n  - critic saw: ${s["Effective line"]}\n  - now: ${row["Current line"]}\n  - suggestion (not applied): ${s["Suggested line"]}`);
		continue;
	}
	row["New line"] = s["Suggested line"];
	row._source = s["Designer line"] === "Y" ? "critic (designer-line fix)" : "critic";
	accepted += 1;
}

for (const t of table("docs/dialogue/typo_fixes_nov1.csv")) {
	const row = byId.get(t["ID"]);
	if (!row) { missing += 1; log.push(`- MISSING typo id ${t["ID"]}`); continue; }
	const base = row["New line"] || row["Current line"];
	let fixed = base.replace(/ {2,}/g, " ").replace(/ +([.,!?;:])/g, "$1");
	if (t["Fix"] === "colour") fixed = fixed.replace(/\bcolor\b/g, "colour");
	if (fixed === base) { log.push(`- typo already fixed: ${t["ID"]}`); continue; }
	row["New line"] = fixed;
	row._source = (row._source ? row._source + " + " : "") + "typo";
	typos += 1;
}

for (const p of table("docs/dialogue/new_lines_proposed_oct31.csv")) {
	const id = p["ID (proposed)"].replace(/ \(rewrite\)$/, "");
	const row = byId.get(id);
	if (!row) { missing += 1; log.push(`- MISSING proposed id ${id}`); continue; }
	row["New line"] = p["Proposed line"];
	row._source = "proposed (Primm rule)";
	proposed += 1;
}

const head = ["ID", "Zone/Area", "Speaker", "When it's heard", "Current line", "New line"];
const out = [head.map(q).join(",")];
for (const r of exportRows) out.push(head.map((h) => q(r[h])).join(","));
fs.writeFileSync(path.join(dir, "edit_apply.csv"), "﻿" + out.join("\r\n") + "\r\n");
const changed = exportRows.filter((r) => r["New line"] !== "");
fs.writeFileSync(path.join(dir, "sources.json"), JSON.stringify(Object.fromEntries(changed.map((r) => [r["ID"], r._source])), null, 1));
fs.writeFileSync(path.join(dir, "build_log.md"), `# Dialogue apply Nov 3 - build log\n\nCritic suggestions accepted: ${accepted}; kept the designer's newer text: ${skippedChanged}; ids missing: ${missing}; typo fixes: ${typos}; proposed lines: ${proposed}. Rows with a New line: ${changed.length}.\n\n${log.join("\n")}\n`);
console.log(`accepted ${accepted}, designer text kept ${skippedChanged}, missing ${missing}, typos ${typos}, proposed ${proposed}; ${changed.length} rows to apply`);
