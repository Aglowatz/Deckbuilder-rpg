// Size pass Nov 3, Part 3: sums up _logs/texfit/*.txt (tools/texfit_run.sh) - the largest on-screen size of every texture across the
// screens, then per asset folder: the native sizes, the largest drawn size, the ratio, and a suggested size_limit (1.25 x the largest
// drawn max side at 1440p = 1.25 x 1.333 x the 1080p size, rounded up to the next 64, never above the native size).
// Usage: node tools/texfit_report.js [--md docs/art/size_pass/texfit.md] [--folder assets/art/portraits]
const fs = require("fs"), path = require("path");
const root = path.resolve(__dirname, "..");
const args = process.argv.slice(2);
const mdOut = args.includes("--md") ? args[args.indexOf("--md") + 1] : null;
const onlyFolder = args.includes("--folder") ? args[args.indexOf("--folder") + 1] : null;
const dir = path.join(root, "_logs", "texfit");
const best = {}; // path -> {native, drawn, ratio, screens:Set, node}
for (const f of fs.readdirSync(dir).filter((n) => n.endsWith(".txt"))) {
	for (const line of fs.readFileSync(path.join(dir, f), "utf8").split(/\r?\n/)) {
		const m = line.match(/^texfit: (\S+) native=(\d+)x(\d+) drawn=(\d+)x(\d+) ratio=([\d.]+) node=(\S+) screen=(\S+)/);
		if (!m) continue;
		const [, p, nw, nh, dw, dh, ratio, node, screen] = m;
		const cur = best[p] || { native: [+nw, +nh], drawn: [0, 0], ratio: 0, screens: new Set(), node: "" };
		if (+ratio > cur.ratio) { cur.ratio = +ratio; cur.drawn = [+dw, +dh]; cur.node = node; }
		cur.screens.add(screen);
		best[p] = cur;
	}
}
const folderOf = (p) => p.startsWith("res://") ? p.slice(6).split("/").slice(0, -1).join("/") : "(runtime)";
const byFolder = {};
for (const [p, v] of Object.entries(best)) {
	const folder = folderOf(p);
	if (onlyFolder && !folder.startsWith(onlyFolder)) continue;
	(byFolder[folder] = byFolder[folder] || []).push({ p, ...v });
}
const ceil64 = (x) => Math.ceil(x / 64) * 64;
let md = "# On-screen texture sizes (tools/texfit_run.sh, design pixels at 1080p)\n\n";
md += "| Folder | Textures seen | Native max side | Largest drawn (1080p) | 1440p | Max ratio | Suggested size_limit | Largest case |\n|---|---:|---:|---:|---:|---:|---:|---|\n";
for (const [folder, items] of Object.entries(byFolder).sort()) {
	const nativeMax = Math.max(...items.map((i) => Math.max(...i.native)));
	const top = items.slice().sort((a, b) => Math.max(...b.drawn) - Math.max(...a.drawn))[0];
	const drawnMax = Math.max(...top.drawn);
	const at1440 = Math.round(drawnMax * 4 / 3);
	const suggested = Math.min(nativeMax, ceil64(at1440 * 1.25));
	const maxRatio = Math.max(...items.map((i) => i.ratio));
	md += `| ${folder} | ${items.length} | ${nativeMax} | ${top.drawn[0]}x${top.drawn[1]} | ${at1440} | ${maxRatio.toFixed(2)} | ${suggested} | ${path.basename(top.p)} on ${[...top.screens][0]} (${top.node}) |\n`;
}
md += "\n## Every texture (largest drawn size)\n\n| Texture | Native | Drawn | Ratio | Screens |\n|---|---:|---:|---:|---|\n";
for (const [folder, items] of Object.entries(byFolder).sort())
	for (const i of items.sort((a, b) => b.ratio - a.ratio))
		md += `| ${i.p.replace("res://", "")} | ${i.native.join("x")} | ${i.drawn.join("x")} | ${i.ratio.toFixed(2)} | ${[...i.screens].join(" ")} |\n`;
if (mdOut) { fs.mkdirSync(path.dirname(path.join(root, mdOut)), { recursive: true }); fs.writeFileSync(path.join(root, mdOut), md); console.log("written: " + mdOut); }
else console.log(md.split("\n## Every texture")[0]);
