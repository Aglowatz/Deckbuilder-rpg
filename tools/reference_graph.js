// Size pass Nov 3, Part 1: which exported files does the game actually reach?
// Usage: node tools/reference_graph.js [--list] [--min-kb N] [--write]
//   prints the unreferenced exported files by folder (packed size, like build_audit.js); --list prints every file;
//   --write saves the list to tools/export_unused.json, which update_export_excludes.js adds to the export's exclude filter.
//
// How a file counts as referenced (conservative: anything a loader could build by name is kept):
//   1. live code + data (P): project.godot, export_presets.cfg, everything under app/ core/ ui/ world/ scenes/ data/ MINUS dead scripts
//      (a .gd whose class_name / path / file name no other live text mentions and that is no autoload or main scene) - their asset
//      mentions no longer keep an asset alive. Dead scripts are listed too (they are small; excluding them is a separate decision).
//   2. shipped asset text (S): assets/**/*.tscn|tres|gltf|json|csv|cfg|material (kit scenes name their textures; manifests name their frames).
//   3. a file is referenced when P or S contains its res:// path, its file name or its stem (>= 4 chars); or when its "family" stem
//      (trailing _01 / -01 / _n / _nr / _albedo / _normal / _roughness / _a / _b stripped) does; or - for a character sprite set
//      (assets/art/world_test/sprites/<SET>/<DIR>_<STATE>.webp) - when the set folder's name is a quoted string in P (SpriteLibrary
//      loads a set by name); or - for an id built from another id (CUT-<NPC key> entrance cut-outs) - when the base id is in P.
//   4. anything the build cache manifest names.
// Files the export already excludes (export_presets.cfg exclude_filter, .gdignore folders) are skipped.
const fs = require("fs"), path = require("path");
const root = path.resolve(__dirname, "..");
const args = process.argv.slice(2);
const minKb = args.includes("--min-kb") ? Number(args[args.indexOf("--min-kb") + 1]) : 0;

const TEXT_EXT = /\.(gd|tscn|tres|json|cfg|csv|gdshader|gdshaderinc|txt|godot|res|material|gltf)$/;
function readCfgExcludes() {
	const cfg = fs.readFileSync(path.join(root, "export_presets.cfg"), "utf8");
	const m = cfg.match(/^exclude_filter="([^"]*)"/m);
	return (m ? m[1].split(",").map((s) => s.trim()).filter(Boolean) : []).map((g) => new RegExp("^" + g.replace(/[.+^${}()|[\]\\]/g, "\\$&").replace(/\*/g, ".*").replace(/\?/g, ".") + "$"));
}
const fixedExcludes = readCfgExcludes().filter((re) => !/export_unused/.test(re.source));
const excluded = (rel) => fixedExcludes.some((re) => re.test(rel));

function walk(dir, acc) {
	for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
		const full = path.join(dir, e.name);
		if (e.isDirectory()) {
			if (e.name.startsWith(".") || fs.existsSync(path.join(full, ".gdignore"))) continue;
			if (dir === root && ["builds", "tests", "tools", "docs", "marketing", "addons", "_reference", "_logs", "_screenshots", "_art_inbox", "_art_source", "_asset_library", "_tmp_tools"].includes(e.name)) continue;
			walk(full, acc);
		} else acc.push(path.relative(root, full).replace(/\\/g, "/"));
	}
	return acc;
}
const all = walk(root, []);

// --- live code (P) ---
const codeFiles = all.filter((f) => /^(app|core|ui|world|scenes|data)\//.test(f) && TEXT_EXT.test(f) && !/\.import$/.test(f));
const text = {};
for (const f of codeFiles) text[f] = fs.readFileSync(path.join(root, f), "utf8");
const project = fs.readFileSync(path.join(root, "project.godot"), "utf8");
const autoloads = new Set((project.match(/^[A-Za-z_]+="\*?res:\/\/([^"]+)"/gm) || []).map((l) => l.replace(/^.*res:\/\//, "").replace(/"$/, "")));
const scripts = codeFiles.filter((f) => f.endsWith(".gd"));
const classOf = {};
for (const f of scripts) { const m = text[f].match(/^class_name\s+([A-Za-z_][A-Za-z0-9_]*)/m); if (m) classOf[f] = m[1]; }
let dead = new Set();
for (let pass = 0; pass < 4; pass++) {
	const live = Object.entries(text).filter(([f]) => !dead.has(f)).map(([, t]) => t).join("\n") + "\n" + project;
	const next = new Set();
	for (const f of scripts) {
		if (autoloads.has(f) || project.includes(f)) continue;
		const self = text[f];
		const others = live.replace(self, "");
		const base = path.basename(f);
		const stem = base.replace(/\.gd$/, "");
		const cls = classOf[f];
		const mentioned = others.includes("res://" + f) || others.includes(base) || (cls && new RegExp("\\b" + cls + "\\b").test(others)) || new RegExp("\\b" + stem + "\\b").test(others);
		if (!mentioned) next.add(f);
	}
	if (next.size === dead.size && [...next].every((f) => dead.has(f))) break;
	dead = next;
}
const P = Object.entries(text).filter(([f]) => !dead.has(f)).map(([, t]) => t).join("\n") + "\n" + project + "\n" + fs.readFileSync(path.join(root, "export_presets.cfg"), "utf8");
const quotedP = new Set((P.match(/"[A-Za-z0-9_\-\.\/]+"/g) || []).map((q) => q.slice(1, -1)));
const quotedP2 = new Set((P.match(/'[A-Za-z0-9_\-\.\/]+'/g) || []).map((q) => q.slice(1, -1)));
for (const q of quotedP2) quotedP.add(q);
// Ids built from parts: "X-" + id, "%s" % id, StringName(&"X-" + ...). A quoted string ending in "-" or "_" is a prefix a loader completes.
const prefixes = [...quotedP].filter((q) => /[-_]$/.test(q) && q.length >= 3);

// --- shipped asset text (S) ---
const S = all.filter((f) => /^assets\//.test(f) && /\.(tscn|tres|gltf|json|csv|cfg|material|txt)$/.test(f)).map((f) => fs.readFileSync(path.join(root, f), "utf8")).join("\n");
let cacheManifest = "";
try { cacheManifest = fs.readFileSync(path.join(root, "build_cache/manifest.json"), "utf8"); } catch {}
const corpus = P + "\n" + S + "\n" + cacheManifest;

function packedBytes(rel) {
	const imp = path.join(root, rel + ".import");
	let bytes = 0;
	if (fs.existsSync(imp)) {
		const txt = fs.readFileSync(imp, "utf8");
		if (/^valid=false/m.test(txt)) return 0;
		const paths = [...txt.matchAll(/^(?:path|path\.[a-z0-9_]+)="res:\/\/([^"]+)"/gm)].map((m) => m[1]);
		for (const p of new Set(paths)) { try { bytes += fs.statSync(path.join(root, p)).size; } catch {} }
		if (/importer="keep"|importer="skip"/.test(txt)) bytes = fs.statSync(path.join(root, rel)).size;
		return bytes;
	}
	try { return fs.statSync(path.join(root, rel)).size; } catch { return 0; }
}

const SPRITE_SET = /^assets\/art\/world_test\/sprites\/([A-Z0-9_]+)\/[A-Z]+_(IDLE|TALK|WALK\d|[A-Z]+\d*)\.(png|webp)$/;
const DERIVED = { "CUT-": ["NPC-", ""], "BST-": ["NPC-", ""] };
// Ids the loaders derive from other ids, compared with punctuation and case removed: BST-<enemy name slug> (Bestiary), ICON-GEAR-<gear id> /
// ICON-ITEM-<item id> (IconArt), NPC-<key>_<EXPRESSION> / V-<vendor>_<MOOD> (Portraits: the tag comes from the dialogue text).
const norm = (s) => s.toLowerCase().replace(/[^a-z0-9]/g, "");
const normP = new Set([...quotedP].map(norm).filter((s) => s.length >= 4));
const normCorpus = norm(P); // unquoted CSV cells (enemy names, vendor keys) with punctuation and case removed
const derivedIn = (s) => normP.has(s) || (s.length >= 6 && normCorpus.includes(s));
const referencedGlb = new Set();
function familyStem(stem) {
	// _n / _r / _nr: EnvKit.map_texture(id, "n" | "r") and PaintedLibrary "%s_nr.webp" build these from the base id
	return stem.replace(/[-_](albedo|nr|normal|roughness|rough|orm|ao|height|n|r|a|b|c)$/i, "").replace(/[-_]?\d{1,3}$/, "");
}
function referenced(rel) {
	const base = path.basename(rel);
	const stem = base.replace(/\.[^.]+$/, "");
	if (corpus.includes("res://" + rel) || corpus.includes(rel) || corpus.includes(base)) return "path";
	if (stem.length >= 4 && corpus.includes(stem)) return "stem";
	if (stem.length < 4 && quotedP.has(stem)) return "short id";
	const fam = familyStem(stem);
	if (fam !== stem && fam.length >= 4 && corpus.includes(fam)) return "family";
	const sprite = rel.match(SPRITE_SET);
	if (sprite && quotedP.has(sprite[1])) return "sprite set";
	for (const [pre, bases] of Object.entries(DERIVED)) {
		if (stem.startsWith(pre)) {
			const rest = stem.slice(pre.length);
			for (const b of bases) if (quotedP.has(b + rest) || (b && corpus.includes(b + rest))) return "derived id";
		}
	}
	for (const pre of prefixes) if (stem.startsWith(pre) && quotedP.has(stem.slice(pre.length))) return "prefix + id";
	if (/^build_cache\//.test(rel)) return "build cache (BuildCache.fetch by name)";
	const tagless = stem.replace(/_[A-Z]+$/, "");
	for (const pre of ["BST-", "ICON-GEAR-", "ICON-ITEM-", "ICON-", "NPC-", "V-", "CUT-"]) {
		if (!stem.startsWith(pre)) continue;
		if (derivedIn(norm(stem.slice(pre.length))) || derivedIn(norm(tagless.slice(pre.length))) || derivedIn(norm(fam.slice(pre.length)))) return "derived id (" + pre + ")";
	}
	if (/\.(png|jpg|webp)$/i.test(rel)) { // a texture next to a referenced model, named by the model's own file (glb imports load it)
		const dir = rel.slice(0, rel.lastIndexOf("/") + 1);
		for (const g of referencedGlb) if (g.startsWith(dir) && stem.toLowerCase().startsWith(path.basename(g).replace(/\.(glb|gltf)$/i, "").toLowerCase())) return "model texture";
	}
	return "";
}
for (const rel of all) if (/\.(glb|gltf)$/i.test(rel) && !excluded(rel) && referenced(rel)) referencedGlb.add(rel);

const EXPORTED = (rel) => !excluded(rel) && !/\.(import|uid|md|license|url|gdignore)$/i.test(rel) && !/\/\.|^\./.test(rel) && !/(^|\/)(README|LICENSE|CHANGELOG)[^/]*$/i.test(rel);
const unused = [];
let totalBytes = 0, unusedBytes = 0;
for (const rel of all) {
	if (!EXPORTED(rel)) continue;
	if (/^(app|core|ui|world|scenes|data)\//.test(rel) && TEXT_EXT.test(rel)) continue; // code and data: reported by the dead-script pass only
	const bytes = packedBytes(rel);
	totalBytes += bytes;
	const why = referenced(rel);
	if (!why) { unused.push({ rel, bytes }); unusedBytes += bytes; }
}
unused.sort((a, b) => b.bytes - a.bytes);
const byDir = {};
for (const u of unused) { const k = u.rel.split("/").slice(0, 4).join("/"); byDir[k] = byDir[k] || { n: 0, b: 0 }; byDir[k].n++; byDir[k].b += u.bytes; }
const mb = (b) => (b / 1048576).toFixed(1);
console.log(`exported files checked: ${all.filter(EXPORTED).length}, packed ${mb(totalBytes)} MB; unreferenced: ${unused.length} files, ${mb(unusedBytes)} MB packed`);
console.log(`dead scripts (no live text mentions them; not excluded by this tool): ${dead.size}`);
for (const f of [...dead].sort()) console.log("   " + f + (classOf[f] ? "  (class_name " + classOf[f] + ")" : ""));
console.log("\n| Folder | Files | packed MB |\n|---|---:|---:|");
for (const [k, v] of Object.entries(byDir).sort((a, b) => b[1].b - a[1].b)) console.log(`| ${k} | ${v.n} | ${mb(v.b)} |`);
if (args.includes("--list")) { console.log(""); for (const u of unused) if (u.bytes / 1024 >= minKb) console.log((u.bytes / 1024).toFixed(0).padStart(7) + " KB " + u.rel); }
if (args.includes("--write")) {
	const out = path.join(__dirname, "export_unused.json");
	fs.writeFileSync(out, JSON.stringify({ _about: "GENERATED by tools/reference_graph.js --write (Size pass Nov 3): exported files nothing in the game references, added to the export's exclude filter by tools/update_export_excludes.js. Sources stay in the repo; re-run the tool when something gains a reference.", files: unused.map((u) => u.rel) }, null, "\t") + "\n");
	console.log("\nwritten: tools/export_unused.json (" + unused.length + " files)");
}
