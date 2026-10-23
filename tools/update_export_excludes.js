// Rewrites exclude_filter of the Windows preset in export_presets.cfg: the fixed list below plus every
// 3D model (.glb/.gltf) under assets/ that nothing in the game references (see tools/unused_assets.js).
// Usage: node tools/update_export_excludes.js [--check]
// Run by tools/export_windows.sh before every export, so a model that gains a reference is exported again.
const fs = require("fs"), path = require("path"), cp = require("child_process");
const root = path.resolve(__dirname, "..");
const cfgPath = path.join(root, "export_presets.cfg");

const FIXED = [
	"tests/*", "tools/*", "docs/*", "marketing/*", "addons/gut/*", "scenes/dev/*",
	"_reference/*", "_logs/*", "_screenshots/*", "_art_inbox/*", "_art_source/*", "_asset_library/*", "builds/*", "_tmp_tools/*",
	// Playtest v0.4.0 Part H: dev-only data and reports (sim reports live under docs/; the sheet CSVs the importers read are source, not shipped).
	"data/source/*.csv.csv", "*.psd", "*.blend", "*.xcf", "*.kra",
];

const out = cp.execFileSync(process.execPath, [path.join(__dirname, "unused_assets.js"), "--dir", "assets", "--list"], { cwd: root, encoding: "utf8", maxBuffer: 64 * 1024 * 1024 });
// Overnight Oct 22 (Part 5): loaders such as BuffetModels.food("cup") / HeapModels.survival("box") build the path from a folder constant
// and a bare name, which unused_assets.js cannot see - the exported Buffet and Dump were missing five props. A model whose folder is
// named in a script ("res://assets/<kit>/models/") and whose file name is a quoted string in any script is kept.
function scripts(dir, acc) {
	for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
		const full = path.join(dir, entry.name);
		if (entry.isDirectory()) scripts(full, acc);
		else if (entry.name.endsWith(".gd")) acc.push(fs.readFileSync(full, "utf8"));
	}
	return acc;
}
const code = ["app", "core", "ui", "world"].filter((d) => fs.existsSync(path.join(root, d))).flatMap((d) => scripts(path.join(root, d), [])).join("\n");
const folders = new Set((code.match(/res:\/\/assets\/[^"]+\//g) || []).map((p) => p.slice("res://".length)));
const quoted = new Set((code.match(/"[A-Za-z0-9_\-]+"/g) || []).map((q) => q.slice(1, -1)));
const models = [];
const kept = [];
for (const line of out.split("\n")) {
	const m = line.match(/^\s*\d+ KB (assets\/.+\.(glb|gltf))$/);
	if (!m) continue;
	const dir = m[1].slice(0, m[1].lastIndexOf("/") + 1);
	const base = path.basename(m[1]).replace(/\.(glb|gltf)$/, "");
	if (folders.has(dir) && quoted.has(base)) kept.push(m[1]);
	else models.push(m[1]);
}
if (kept.length) console.log("export excludes: kept " + kept.length + " models loaded by name: " + kept.join(", "));
const filter = FIXED.concat(models.sort()).join(", ");

let cfg = fs.readFileSync(cfgPath, "utf8");
const next = cfg.replace(/^exclude_filter=".*"$/m, (line, offset) => {
	// only the first preset (Windows Desktop) is rewritten
	return offset === cfg.search(/^exclude_filter=/m) ? 'exclude_filter="' + filter + '"' : line;
});
if (process.argv.includes("--check")) {
	console.log(models.length + " unreferenced models would be excluded; preset " + (next === cfg ? "is up to date" : "needs an update"));
} else {
	fs.writeFileSync(cfgPath, next);
	console.log("export excludes: " + FIXED.length + " fixed patterns + " + models.length + " unreferenced models");
}
