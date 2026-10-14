// Applies tools/art_import_rules.json to the .import files of the project's textures.
// Usage: node tools/apply_import_rules.js [--dry] [--verbose]
// Only touches [params] keys the matching rule sets. Run it after new art is imported
// (the import_*.sh scripts do), then re-import (Godot re-imports on the changed .import).
const fs = require("fs"), path = require("path");
const dims = require("./lib_imgdims.js");
const root = path.resolve(__dirname, "..");
const dry = process.argv.includes("--dry");
const verbose = process.argv.includes("--verbose");
const rules = JSON.parse(fs.readFileSync(path.join(__dirname, "art_import_rules.json"), "utf8")).rules;
const SPECIAL = /[.+^${}()|[\]\\]/g;
const compiled = rules.map(r => ({ r, re: new RegExp("^" + r.match.replace(SPECIAL, "\\$&").replace(/\*/g, ".*") + "$") }));

function setKey(text, key, value) {
	const re = new RegExp("^" + key.replace(SPECIAL, "\\$&") + "=.*$", "m");
	return re.test(text) ? text.replace(re, key + "=" + value) : text.replace(/\[params\]\r?\n/, "[params]\n\n" + key + "=" + value + "\n");
}

const SKIP = new Set(["_art_inbox", "_art_source", "docs", "tests", "tools", "builds", "addons", "_asset_library", "marketing"]);
let changed = 0, matched = 0;
function walk(d) {
	for (const e of fs.readdirSync(d, { withFileTypes: true })) {
		const p = path.join(d, e.name);
		if (e.isDirectory()) {
			if (e.name.startsWith(".") || SKIP.has(e.name)) continue;
			walk(p);
			continue;
		}
		if (!e.name.endsWith(".import")) continue;
		const src = path.relative(root, p).split(path.sep).join("/").replace(/\.import$/, "");
		const hit = compiled.find(x => x.re.test(src));
		if (!hit) continue;
		let text = fs.readFileSync(p, "utf8");
		if (!/^importer="texture"/m.test(text)) continue;
		matched++;
		const r = hit.r;
		const before = text;
		let mode = r.mode;
		if (r.lossy_over_px != null) {
			let dm = null;
			try { dm = dims(path.join(root, src)); } catch (err) { dm = null; }
			if (!dm || Math.max(dm[0], dm[1]) <= r.lossy_over_px) mode = 0;
		}
		text = setKey(text, "compress/mode", mode);
		text = setKey(text, "compress/high_quality", mode === 2 && r.hq ? "true" : "false");
		if (mode === 1) text = setKey(text, "compress/lossy_quality", r.quality != null ? r.quality : 0.88);
		if (r.mipmaps != null) text = setKey(text, "mipmaps/generate", r.mipmaps ? "true" : "false");
		if (r.normal_map != null) text = setKey(text, "compress/normal_map", r.normal_map);
		text = setKey(text, "process/size_limit", r.size_limit != null ? r.size_limit : 0);
		if (text !== before) {
			changed++;
			if (verbose) console.log("update", src);
			if (!dry) fs.writeFileSync(p, text);
		}
	}
}
walk(root);
console.log("import rules: " + matched + " textures matched, " + changed + " .import files " + (dry ? "would change" : "updated"));
