// Build size audit: estimates what Godot packs into the .pck, grouped by category.
// Usage: node tools/build_audit.js [--md docs/build_size.md] [--quiet]
// Imported resources count as their .godot/imported output; other files count raw.
// Honors export_filter exclude patterns from export_presets.cfg (preset.0) and the
// path-prefix excludes below.
const fs = require("fs");
const path = require("path");
const root = path.resolve(__dirname, "..");
const args = process.argv.slice(2);
const mdOut = args.includes("--md") ? args[args.indexOf("--md") + 1] : null;
const quiet = args.includes("--quiet");

function readExcludes() {
  const cfg = fs.readFileSync(path.join(root, "export_presets.cfg"), "utf8");
  const m = cfg.match(/^exclude_filter="([^"]*)"/m);
  return m ? m[1].split(",").map(s => s.trim()).filter(Boolean) : [];
}
function globToRe(g) {
  const esc = g.replace(/[.+^${}()|[\]\\]/g, "\\$&").replace(/\*/g, ".*").replace(/\?/g, ".");
  return new RegExp("^" + esc + "$");
}
const excludeRes = readExcludes().map(globToRe);
const SKIP_DIRS = new Set([".godot", ".git", "builds"]);

const files = [];
function walk(dir) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const rel = path.relative(root, path.join(dir, e.name)).replace(/\\/g, "/");
    if (e.isDirectory()) {
      if (SKIP_DIRS.has(e.name) && dir === root) continue;
      if (e.name.startsWith(".") || fs.existsSync(path.join(dir, e.name, ".gdignore"))) continue;
      walk(path.join(dir, e.name));
    } else files.push(rel);
  }
}
walk(root);

function excluded(rel) { return excludeRes.some(r => r.test(rel)); }

function sizeOf(rel) { try { return fs.statSync(path.join(root, rel)).size; } catch { return 0; } }

function category(rel) {
  const p = rel.toLowerCase();
  if (/^(_art_inbox|_art_source)\//.test(p)) return "working art (_art_inbox), not game assets";
  if (/^(docs|tests|tools|marketing)\//.test(p)) return "docs/tests/tools";
  if (/^assets\/art\/world_test\//.test(p)) return "world test art (assets/art/world_test)";
  if (/\.(ogg|wav|mp3)$/.test(p)) return /assets\/audio\/music|ambien/.test(p) ? "audio: music/ambience" : "audio: sfx";
  if (/\.(ttf|otf|woff2?)$/.test(p)) return "fonts";
  if (/\.(glb|gltf|obj|fbx|scn)$/.test(p)) return "3D models";
  if (/(_normal|_roughness|_rough|_nrm|_nr|_orm|_ao|_height)\.(png|webp|jpg)$/.test(p) || /\/(normal|roughness)\//.test(p)) return "world: normal/roughness maps";
  if (/assets\/art\/(textures|decals|env_kit)/.test(p) || /\/(tex|env|dec)-/.test(p)) return "world textures (TEX/ENV/DEC, kit)";
  if (/\/portraits\//.test(p)) return "portraits";
  if (/\/cards\//.test(p)) return "card art";
  if (/\/battleboards\//.test(p)) return "battleboards";
  if (/\/maps\//.test(p)) return "maps";
  if (/\/vendors\//.test(p)) return "vendor screens";
  if (/\/keyart\//.test(p)) return "backgrounds/key art";
  if (/\/ui\/|\/icons\/|\/icon\//.test(p)) return "UI and icons";
  if (/\/characters\/|\/cosmetics\//.test(p)) return "sprites (characters/cosmetics)";
  if (/\/world_test\//.test(p)) return "world test art";
  if (/\.(png|jpg|jpeg|webp|svg)$/.test(p)) return "other images";
  return "other (scripts, scenes, data)";
}

const items = []; // {src, bytes, cat}
const counted = new Set();
for (const rel of files) {
  if (rel.endsWith(".import") || rel.endsWith(".uid")) continue;
  if (excluded(rel)) continue;
  const imp = rel + ".import";
  let bytes = 0;
  if (fs.existsSync(path.join(root, imp))) {
    const txt = fs.readFileSync(path.join(root, imp), "utf8");
    if (/^valid=false/m.test(txt)) continue;
    const paths = [...txt.matchAll(/^(?:path|path\.[a-z0-9_]+)="res:\/\/([^"]+)"/gm)].map(m => m[1]);
    for (const p of new Set(paths)) {
      if (counted.has(p)) continue;
      counted.add(p);
      bytes += sizeOf(p);
      // glb/scn imports often also have a .md5 sidecar; negligible
    }
    if (/importer="keep"|importer="skip"/.test(txt)) bytes = sizeOf(rel);
  } else {
    bytes = sizeOf(rel);
  }
  items.push({ src: rel, bytes, cat: category(rel) });
}

const byCat = {};
let total = 0;
for (const it of items) { byCat[it.cat] = (byCat[it.cat] || { n: 0, b: 0 }); byCat[it.cat].n++; byCat[it.cat].b += it.bytes; total += it.bytes; }
const mb = b => (b / 1048576).toFixed(1);
const cats = Object.entries(byCat).sort((a, b) => b[1].b - a[1].b);
const top = items.slice().sort((a, b) => b.bytes - a.bytes).slice(0, 30);

let md = "";
md += `Estimated export payload: **${mb(total)} MB** (${items.length} source files)\n\n`;
md += "| Category | Files | MB |\n|---|---:|---:|\n";
for (const [c, v] of cats) md += `| ${c} | ${v.n} | ${mb(v.b)} |\n`;
md += `| **Total** | ${items.length} | **${mb(total)}** |\n\n`;
md += "### 30 largest files (packed size)\n\n| MB | File |\n|---:|---|\n";
for (const t of top) md += `| ${mb(t.bytes)} | \`${t.src}\` |\n`;

if (mdOut) {
  const header = fs.existsSync(path.join(root, mdOut + ".header")) ? fs.readFileSync(path.join(root, mdOut + ".header"), "utf8") : "";
  fs.writeFileSync(path.join(root, mdOut), header + md);
}
if (!quiet) console.log(md);
else console.log(`Export payload ~${mb(total)} MB`);
if (total > 800 * 1048576) console.log(`WARNING: export payload ${mb(total)} MB exceeds the 800 MB budget`);
