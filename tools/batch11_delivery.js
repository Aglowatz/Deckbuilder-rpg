// Batch 11 art import (Nov 2): Part 1 delivery check. Reads docs/art/art_needed_nov2.csv, looks up every expected file in its Drive folder by exact
// name (no folder scans - Approved_Sprites is too big to list over Drive), copies what it finds to _art_inbox/batch11/<folder>/ and prints one row
// per file: size, PNG dims, colour type (alpha or not). Writes _art_inbox/batch11/delivery.json for the report.
// Run: node tools/batch11_delivery.js [--no-copy]
const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const DRIVE = "G:/My Drive/Card Game Art";
const STAGE = path.join(root, "_art_inbox", "batch11");
const copy = !process.argv.includes("--no-copy");

// Where the sheet said "Save to" -> where the files actually landed (brief folder notes).
const FOLDERS = {
	"Approved_Stills": "Approved_KeyArt",
	"Approved_ZoneKits/final": "Approved_ZoneKits/Capital",
	"Approved_ZoneKits/dna": "Approved_ZoneKits/DNA",
	"Approved_ZoneKits/gourmand": "Approved_ZoneKits/Buffet",
	"Approved_Cards": "Approved",
};

function parseCsv(text) {
	const rows = [];
	let row = [], cell = "", quoted = false;
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

function pngInfo(file) {
	const fd = fs.openSync(file, "r");
	const buf = Buffer.alloc(33);
	fs.readSync(fd, buf, 0, 33, 0);
	fs.closeSync(fd);
	if (buf.readUInt32BE(0) !== 0x89504e47) return { format: "not PNG" };
	const colour = buf[25];
	return { format: "PNG", w: buf.readUInt32BE(16), h: buf.readUInt32BE(20), alpha: colour === 6 || colour === 4 };
}

const rows = parseCsv(fs.readFileSync(path.join(root, "docs/art/art_needed_nov2.csv"), "utf8"));
const head = rows.shift();
const col = (name) => head.indexOf(name);
const out = [];
for (const r of rows) {
	// The Zone cell of a few rows holds unquoted commas: fold the extra cells back into it.
	while (r.length > head.length) r.splice(2, 2, r[2] + "," + r[3]);
	const id = r[col("Art ID")];
	if (id === "NPC-EXPRESSIONS-SKIPPED") continue; // a pointer row to the Oct 28 batch, not a file list
	const folder = FOLDERS[r[col("Save to")]] || r[col("Save to")];
	let names = r[col("File name(s)")].split(",").map((s) => s.trim()).filter(Boolean);
	const isSet = r[col("Category")].startsWith("Sprite set");
	for (const name of names) {
		const file = path.join(DRIVE, folder, name);
		const entry = { id, folder, name, size: r[col("Size/format")] };
		if (fs.existsSync(file)) {
			entry.bytes = fs.statSync(file).size;
			Object.assign(entry, pngInfo(file));
			if (copy) {
				fs.mkdirSync(path.join(STAGE, folder), { recursive: true });
				fs.copyFileSync(file, path.join(STAGE, folder, name));
			}
		} else entry.missing = true;
		out.push(entry);
	}
	if (isSet) {
		// A set may come as one sheet SPR-<KEY>.png instead of four poses.
		const sheet = names[0].replace(/-FRONT_IDLE\.png$/, ".png");
		const file = path.join(DRIVE, folder, sheet);
		if (fs.existsSync(file)) {
			const entry = { id, folder, name: sheet, sheet: true, bytes: fs.statSync(file).size, ...pngInfo(file) };
			if (copy) fs.copyFileSync(file, path.join(STAGE, folder, sheet));
			out.push(entry);
		}
	}
}
fs.mkdirSync(STAGE, { recursive: true });
fs.writeFileSync(path.join(STAGE, "delivery.json"), JSON.stringify(out, null, 1));
for (const e of out) {
	console.log(e.missing ? `MISSING  ${e.folder}/${e.name}` :
		`found    ${e.folder}/${e.name}  ${(e.bytes / 1024).toFixed(0)} KB  ${e.w}x${e.h}  ${e.alpha ? "alpha" : "opaque"}${e.sheet ? "  (sheet)" : ""}`);
}
console.log(`${out.filter((e) => !e.missing).length} found, ${out.filter((e) => e.missing).length} missing`);
