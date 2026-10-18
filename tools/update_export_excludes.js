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
const models = [];
for (const line of out.split("\n")) {
	const m = line.match(/^\s*\d+ KB (assets\/.+\.(glb|gltf))$/);
	if (m) models.push(m[1]);
}
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
