// Batch 14 art import (Nov 8): file every image of "Pending Review/Batch 14" into its Approved_* folder.
// Looks up each destination by exact name (no folder scans: Approved_Sprites is too big to list over Drive).
// An existing file of the same name is moved to Superseded first (" (n)" suffix when Superseded already has one).
// Every source file is first copied to _art_inbox/batch14/ (local backup + PNG info), and every replaced file to
// _art_source/superseded_batch14/.
// Run: node tools/batch14_move.js            (dry run: prints the plan)
//      node tools/batch14_move.js --apply    (moves)
const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const DRIVE = "G:/My Drive/Card Game Art";
const SRC = path.join(DRIVE, "Pending Review", "Batch 14");
const STAGE = path.join(root, "_art_inbox", "batch14");
const BACKUP = path.join(root, "_art_source", "superseded_batch14");
const apply = process.argv.includes("--apply");

const RULES = [
	[/^V-THREADWELL_DELIGHTED-ALT\.png$/, "Superseded"],  // the less on-model of the two Pip tries (the hat tilt, ears and sash differ from V-THREADWELL)
	[/^(NPC|V)-/, "Approved_Characters"],
	[/^SPR-/, "Approved_Sprites"],
	[/^STORY-/, "Approved_KeyArt"],
	[/^BST-/, "Approved_Bestiary"],
	[/^ICON-/, "Approved_Icons"],
	[/^(RES|BAS|[BNGR])-/, "Approved"],
];
// Sable's old world sprites were imported from Approved_WorldTest (the World Look Test); the sprite importer reads Approved_Sprites, so the
// old set is moved to Superseded as well (its names would otherwise stay the current ones in that folder).
const ALSO_SUPERSEDE = ["Approved_WorldTest/SPR-SABLE-REF.png", "Approved_WorldTest/SPR-SABLE-FRONT_IDLE.png", "Approved_WorldTest/SPR-SABLE-SIDE_IDLE.png",
	"Approved_WorldTest/SPR-SABLE-BACK_IDLE.png", "Approved_WorldTest/SPR-SABLE-FRONT_TALK.png"];

function pngInfo(file) {
	const fd = fs.openSync(file, "r");
	const buf = Buffer.alloc(33);
	fs.readSync(fd, buf, 0, 33, 0);
	fs.closeSync(fd);
	if (buf.readUInt32BE(0) !== 0x89504e47) return { format: "not PNG" };
	const colour = buf[25];
	return { format: "PNG", w: buf.readUInt32BE(16), h: buf.readUInt32BE(20), alpha: colour === 6 || colour === 4 };
}

function freeName(dir, name) {
	const ext = path.extname(name), base = path.basename(name, ext);
	if (!fs.existsSync(path.join(dir, name))) return name;
	for (let n = 1; ; n++) {
		const cand = `${base} (${n})${ext}`;
		if (!fs.existsSync(path.join(dir, cand))) return cand;
	}
}

function move(from, to) {
	try { fs.renameSync(from, to); }
	catch (e) { fs.copyFileSync(from, to); fs.unlinkSync(from); }
}

const names = fs.readdirSync(SRC).filter((n) => n.toLowerCase().endsWith(".png")).sort();
const out = [];
for (const name of names) {
	const rule = RULES.find(([re]) => re.test(name));
	if (!rule) { out.push({ name, error: "no folder rule" }); continue; }
	const folder = rule[1];
	const src = path.join(SRC, name);
	const dest = path.join(DRIVE, folder, folder === "Superseded" ? freeName(path.join(DRIVE, "Superseded"), name) : name);
	const entry = { name, folder, ...pngInfo(src), bytes: fs.statSync(src).size, replaces: folder !== "Superseded" && fs.existsSync(dest) };
	if (apply) {
		fs.mkdirSync(STAGE, { recursive: true });
		fs.copyFileSync(src, path.join(STAGE, name));
		if (entry.replaces) {
			fs.mkdirSync(BACKUP, { recursive: true });
			fs.copyFileSync(dest, path.join(BACKUP, name));
			const sup = freeName(path.join(DRIVE, "Superseded"), name);
			move(dest, path.join(DRIVE, "Superseded", sup));
			entry.superseded_as = sup;
		}
		move(src, dest);
		entry.moved = true;
	}
	out.push(entry);
	console.log([name, folder, `${entry.w}x${entry.h}`, entry.alpha ? "alpha" : "opaque",
		entry.replaces ? "REPLACES -> Superseded" + (entry.superseded_as ? "/" + entry.superseded_as : "") : "new"].join(" | "));
}
for (const rel of ALSO_SUPERSEDE) {
	const from = path.join(DRIVE, rel);
	if (!fs.existsSync(from)) { console.log(`${rel} | already gone`); continue; }
	const sup = freeName(path.join(DRIVE, "Superseded"), path.basename(rel));
	if (apply) {
		fs.mkdirSync(BACKUP, { recursive: true });
		fs.copyFileSync(from, path.join(BACKUP, path.basename(rel)));
		move(from, path.join(DRIVE, "Superseded", sup));
	}
	out.push({ name: path.basename(rel), folder: "Superseded", from: rel, superseded_as: sup, moved: apply });
	console.log(`${rel} | old set -> Superseded/${sup}${apply ? "" : " (dry run)"}`);
}
fs.mkdirSync(STAGE, { recursive: true });
fs.writeFileSync(path.join(STAGE, apply ? "moved.json" : "plan.json"), JSON.stringify(out, null, 1));
console.log(`${out.length} files, ${out.filter((e) => e.replaces).length} replace an existing file${apply ? " (moved)" : " (dry run)"}`);
