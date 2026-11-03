// Size pass Nov 3, Part 4: sets the import params of the texture-format test copies in assets/art/_fmt_test/ by their name suffix
// (<name>__bc7 / __bc1 / __basis1 / __basis3), after a first headless import has created their .import files.
// Usage: node tools/texfmt_patch.js && Godot --headless --import, then node tools/texfmt_patch.js --sizes
const fs = require("fs"), path = require("path");
const root = path.resolve(__dirname, "..");
const dir = path.join(root, "assets", "art", "_fmt_test");
const VARIANTS = {
	bc7: { "compress/mode": "2", "compress/high_quality": "true", "compress/uastc_level": "0", "compress/rdo_quality_loss": "0.0" },
	bc1: { "compress/mode": "2", "compress/high_quality": "false", "compress/uastc_level": "0", "compress/rdo_quality_loss": "0.0" },
	basis1: { "compress/mode": "3", "compress/high_quality": "true", "compress/uastc_level": "2", "compress/rdo_quality_loss": "1.0" },
	basis3: { "compress/mode": "3", "compress/high_quality": "true", "compress/uastc_level": "2", "compress/rdo_quality_loss": "3.0" },
};
const COMMON = { "mipmaps/generate": "true", "process/size_limit": "1024", "detect_3d/compress_to": "0" };
if (process.argv.includes("--sizes")) {
	const zlib = require("zlib");
	console.log("| File | Variant | ctex KB | deflated KB |\n|---|---|---:|---:|");
	for (const f of fs.readdirSync(dir).filter((n) => n.endsWith(".import")).sort()) {
		const txt = fs.readFileSync(path.join(dir, f), "utf8");
		const paths = [...txt.matchAll(/^path(?:\.[a-z0-9_]+)?="res:\/\/([^"]+)"/gm)].map((m) => m[1]);
		let bytes = 0, deflated = 0;
		for (const p of new Set(paths)) {
			try { const data = fs.readFileSync(path.join(root, p)); bytes += data.length; deflated += zlib.deflateSync(data, { level: 6 }).length; } catch {}
		}
		const m = f.match(/^(.*)__(bc7|bc1|basis1|basis3)\.webp\.import$/);
		if (m) console.log(`| ${m[1]} | ${m[2]} | ${(bytes / 1024).toFixed(0)} | ${(deflated / 1024).toFixed(0)} |`);
	}
	process.exit(0);
}
let n = 0;
for (const f of fs.readdirSync(dir).filter((name) => name.endsWith(".import"))) {
	const m = f.match(/__(bc7|bc1|basis1|basis3)\.webp\.import$/);
	if (!m) continue;
	const params = { ...COMMON, ...VARIANTS[m[1]] };
	let txt = fs.readFileSync(path.join(dir, f), "utf8");
	for (const [k, v] of Object.entries(params)) {
		const re = new RegExp("^" + k.replace(/[/]/g, "\\/") + "=.*$", "m");
		txt = re.test(txt) ? txt.replace(re, `${k}=${v}`) : txt.replace(/\[params\]\n/, `[params]\n${k}=${v}\n`);
	}
	fs.writeFileSync(path.join(dir, f), txt);
	n++;
}
console.log("patched " + n + " import files; now run the headless import, then --sizes");
