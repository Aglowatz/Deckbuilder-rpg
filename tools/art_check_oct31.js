// Art import Oct 31 (batch 10): checks that each of the 17 delivered files is in the game - the files the importers make from it exist and the
// game's lookups name them. Prints one line per delivered file and exits 1 when anything is missing. Run: node tools/art_check_oct31.js
const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const DIRS = ["FRONT", "FRONTSIDE", "SIDE", "BACKSIDE", "BACK"];
const has = (rel) => fs.existsSync(path.join(root, rel));
const read = (rel) => fs.readFileSync(path.join(root, rel), "utf8");

const manifest = JSON.parse(read("assets/art/world_test/sprites/manifest.json"));
const fitAuto = JSON.parse(read("assets/art/cosmetics/hats/fit_auto.json"));
const spotless = "assets/art/world_test/sprites/FOE_CAPTAIN_SPOTLESS/";

const checks = [
	["STORY-WAKE-NIGHT.png", ["assets/art/keyart/STORY-WAKE-NIGHT.webp"], () => read("core/data/story_stills.gd").includes('"STORY-WAKE-NIGHT"')],
	["ICON-UI-GLOSSARY.png", ["assets/art/icons/ICON-UI-GLOSSARY.webp"], () => read("ui/screens/pause_menu.gd").includes('"ICON-UI-GLOSSARY"')],
	["ICON-UI-FEATS.png", ["assets/art/icons/ICON-UI-FEATS.webp"], () => read("ui/screens/pause_menu.gd").includes('"ICON-UI-FEATS"')],
];
for (const hat of ["CHEF", "WIZARD", "LEAFCROWN"]) {
	checks.push([`COS-HAT-${hat}-SHEET.png`, DIRS.map((d) => `assets/art/cosmetics/hats/${hat}/${d}.png`), () => hat in fitAuto]);
}
for (const d of DIRS) {
	checks.push([`SPR-FOE-CAPTAIN-SPOTLESS-${d}_IDLE.png`, [`${spotless}${d}_IDLE.png`], () => (manifest.FOE_CAPTAIN_SPOTLESS?.dirs || []).includes(d)]);
	checks.push([`SPR-FOE-CAPTAIN-SPOTLESS-${d}_WALK.png`, [1, 2, 3, 4].map((n) => `${spotless}${d}_WALK${n}.png`),
		() => (manifest.FOE_CAPTAIN_SPOTLESS?.walk_dirs || []).includes(d)]);
}
checks.push(["SPR-FOE-CAPTAIN-SPOTLESS-FRONT_TALK.png", [`${spotless}FRONT_TALK.png`], () => manifest.FOE_CAPTAIN_SPOTLESS?.has_talk === true]);

let missing = 0;
for (const [source, outputs, wired] of checks) {
	const absent = outputs.filter((rel) => !has(rel));
	const ok = absent.length === 0 && wired();
	if (!ok) missing += 1;
	console.log(`${ok ? "IN GAME" : "MISSING"}  ${source}  (${outputs.length} file${outputs.length === 1 ? "" : "s"})${absent.length ? "  absent: " + absent.join(", ") : ""}${absent.length === 0 && !ok ? "  not wired" : ""}`);
}
console.log(`${checks.length - missing} of ${checks.length} delivered files in game`);
process.exit(missing === 0 ? 0 : 1);
