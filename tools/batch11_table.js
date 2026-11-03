// Batch 11 art import (Nov 2), Part 1: the delivery table for docs/art/import_nov2_batch11.md from _art_inbox/batch11/delivery.json
// (tools/batch11_delivery.js) and pixels.json (tools/batch11_pixels.gd). Prints markdown. Run: node tools/batch11_table.js
const path = require("path");
const stage = path.join(__dirname, "..", "_art_inbox", "batch11");
const delivery = require(path.join(stage, "delivery.json"));
const pixels = require(path.join(stage, "pixels.json"));

// What the lock asks for, by the row's Size/format text.
function verdict(e, m) {
	if (e.missing) return "MISSING";
	const notes = [];
	const want = e.size.match(/(\d{3,4})x(\d{3,4})/);
	if (want && !e.sheet && (Number(want[1]) !== e.w || Number(want[2]) !== e.h)) notes.push(`size ${e.w}x${e.h}, asked ${want[0]}`);
	const cutOut = /transparent/.test(e.size);
	if (cutOut && m.corners.some((a) => a > 10) && !/sky transparent/.test(e.size)) notes.push("corners not clear");
	if (/opaque/.test(e.size) || /^STORY-/.test(e.name) || /^16:9/.test(e.size)) {
		if (m.min_alpha < 250) notes.push(`1-px border at alpha ${m.min_alpha} (frame edge only)`);
	}
	if (/SHEET/.test(e.name) && /3x2/.test(e.size) && (m.col_runs.length !== 3 || m.row_runs.length !== 2)) notes.push("not a clean 3x2 grid");
	if (/HAT-.*SHEET/.test(e.name) && m.col_runs.length !== 5) notes.push(`${m.col_runs.length} views, asked 5`);
	return notes.length ? "OK - " + notes.join("; ") : "OK";
}

function detail(e, m) {
	if (e.missing || !m) return "";
	if (/^SPR-/.test(e.name)) return `drawn ${m.box[1]}-${m.box[3]} (h ${m.drawn_h}, ground ${m.box[3]})`;
	if (/SHEET/.test(e.name)) return `${m.col_runs.length} cols x ${m.row_runs.length} rows, clear gutters`;
	if (/^CAP-BD/.test(e.name)) return `sky clear above y ${m.row_runs[0][0]}`;
	return m.min_alpha === 255 ? "opaque" : m.corners.every((a) => a === 0) ? "cut-out" : "";
}

console.log("| # | File | Folder | KB | Dims | Alpha / layout | Result |");
console.log("|---|---|---|---|---|---|---|");
let n = 0;
for (const e of delivery) {
	const m = pixels[e.name];
	n += 1;
	console.log(`| ${n} | ${e.name} | ${e.folder} | ${e.bytes ? Math.round(e.bytes / 1024) : "-"} | ${e.w ? e.w + "x" + e.h : "-"} | ${detail(e, m)} | ${verdict(e, m)} |`);
}
