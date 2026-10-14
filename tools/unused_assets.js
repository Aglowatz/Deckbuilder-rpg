// Lists exported asset files that nothing in the game seems to reference (candidates for the export exclude list).
// Usage: node tools/unused_assets.js [--dir assets] [--min-kb 0]
// Heuristic: a file counts as used when its res:// path, its file name or its stem (without _albedo/_nr/_normal...)
// appears in any game text file (gd, tscn, tres, json, cfg, csv, gdshader, godot, txt under data/), or when a
// scene/resource that is itself used lists it. Dynamic paths built from ids are caught by the stem check.
const fs = require("fs"), path = require("path");
const root = path.resolve(__dirname, "..");
const args = process.argv.slice(2);
const dir = args.includes("--dir") ? args[args.indexOf("--dir") + 1] : "assets";
const minKb = args.includes("--min-kb") ? Number(args[args.indexOf("--min-kb") + 1]) : 0;

const TEXT_DIRS = ["app", "core", "ui", "world", "scenes", "data", "addons/gut_plugin_none"];
const TEXT_EXT = /\.(gd|tscn|tres|json|cfg|csv|gdshader|txt|godot|res)$/;
let corpus = fs.readFileSync(path.join(root, "project.godot"), "utf8");
function walkText(d) {
	for (const e of fs.readdirSync(d, { withFileTypes: true })) {
		const p = path.join(d, e.name);
		if (e.isDirectory()) { if (e.name === "source" && d.endsWith("data")) continue; walkText(p); continue; }
		if (TEXT_EXT.test(e.name) && fs.statSync(p).size < 8 * 1048576) corpus += "\n" + fs.readFileSync(p, "utf8");
	}
}
for (const d of TEXT_DIRS) { const p = path.join(root, d); if (fs.existsSync(p)) walkText(p); }
// assets directory text files (scenes/materials shipped with kits) also reference each other
function walkAssets(d) {
	for (const e of fs.readdirSync(d, { withFileTypes: true })) {
		const p = path.join(d, e.name);
		if (e.isDirectory()) { walkAssets(p); continue; }
		if (/\.(tscn|tres|gltf|import)$/.test(e.name) && !e.name.endsWith(".import")) corpus += "\n" + fs.readFileSync(p, "utf8");
	}
}
walkAssets(path.join(root, "assets"));

const IGNORE_EXT = /\.(import|uid|md|txt|license|url)$/i;
const unused = [];
let total = 0, totalUnused = 0;
function scan(d) {
	for (const e of fs.readdirSync(d, { withFileTypes: true })) {
		const p = path.join(d, e.name);
		if (e.isDirectory()) { scan(p); continue; }
		if (IGNORE_EXT.test(e.name) || !fs.existsSync(p + ".import")) continue;
		const rel = path.relative(root, p).split(path.sep).join("/");
		const size = fs.statSync(p).size;
		total += size;
		const base = e.name;
		const stem = base.replace(/\.[^.]+$/, "").replace(/_(albedo|nr|normal|roughness|n|a)$/i, "");
		const used = corpus.includes(rel) || corpus.includes(base) || (stem.length >= 4 && corpus.includes(stem));
		if (!used) { unused.push([size, rel]); totalUnused += size; }
	}
}
scan(path.join(root, dir));
const byDir = {};
for (const [s, r] of unused) { const k = r.split("/").slice(0, 4).join("/"); byDir[k] = byDir[k] || [0, 0]; byDir[k][0]++; byDir[k][1] += s; }
console.log("scanned " + (total / 1048576).toFixed(0) + " MB of source files; " + unused.length + " look unused (" + (totalUnused / 1048576).toFixed(1) + " MB source)");
for (const [k, v] of Object.entries(byDir).sort((a, b) => b[1][1] - a[1][1]).slice(0, 40))
	console.log((v[1] / 1048576).toFixed(1).padStart(7) + " MB " + String(v[0]).padStart(4) + " files  " + k);
if (args.includes("--list")) for (const [s, r] of unused.sort((a, b) => b[0] - a[0])) if (s / 1024 >= minKb) console.log((s / 1024).toFixed(0).padStart(6) + " KB " + r);
