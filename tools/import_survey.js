// Surveys texture import settings: packed size and file count per folder x (mode, mipmaps, high quality, size limit).
// Usage: node tools/import_survey.js
const fs = require("fs"), path = require("path");
const SKIP = new Set([".godot", ".git", "builds", "_asset_library", "docs", "tests", "tools", "marketing", "_screenshots", "_logs", "_reference", "_art_source"]);
const out = {};
function walk(d) {
	for (const e of fs.readdirSync(d, { withFileTypes: true })) {
		const p = path.join(d, e.name);
		if (e.isDirectory()) { if (!SKIP.has(e.name)) walk(p); continue; }
		if (!e.name.endsWith(".import")) continue;
		const t = fs.readFileSync(p, "utf8");
		if ((t.match(/^importer="(\w+)"/m) || [])[1] !== "texture") continue;
		const g = (re) => (t.match(re) || [])[1];
		const dir = path.relative(".", d).split(path.sep).slice(0, 3).join("/");
		const k = `${dir} | mode${g(/compress\/mode=(\d)/)} mip=${g(/mipmaps\/generate=(\w+)/)} hq=${g(/high_quality=(\w+)/)} lim=${g(/size_limit=(\d+)/)}`;
		let s = 0;
		for (const m of new Set([...t.matchAll(/^path[.\w]*="res:\/\/([^"]+)"/gm)].map(x => x[1]))) { try { s += fs.statSync(m).size; } catch { } }
		out[k] = out[k] || [0, 0];
		out[k][0]++; out[k][1] += s;
	}
}
walk(".");
for (const [k, v] of Object.entries(out).sort((a, b) => b[1][1] - a[1][1]))
	console.log((v[1] / 1048576).toFixed(1).padStart(7), String(v[0]).padStart(4), k);
