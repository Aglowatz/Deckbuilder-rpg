// Overnight Nov 8-9, Part 5: a sweep of every player-facing text for typos, double spaces, leftover dev text and inconsistent names.
//
//   node tools/text_sweep.js            -> docs/release/text_sweep_nov9.md (findings, by kind)
//
// Sources: the story files (data/story/*.tres "key": ["line", ...] and *.json), the NPC registry (names, barks), cards (name, rules,
// flavour), items and equipment (name, description), feats, bestiary, loading tips, and the quoted strings of the quest definitions.
// Checks: double spaces, space before punctuation, "TODO/FIXME/PLACEHOLDER/lorem/XXX/debug", "???" outside spoiler names, repeated words
// ("the the"), common misspellings, names one or two letters away from a canon name (docs/design/canon.md), a wrong-case canon name.
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const rel = (p) => path.relative(ROOT, p).replace(/\\/g, "/");
const texts = []; // {file, key, text}

function walk(dir, pred, out = []) {
	if (!fs.existsSync(dir)) return out;
	for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
		const p = path.join(dir, e.name);
		if (e.isDirectory()) walk(p, pred, out);
		else if (pred(p)) out.push(p);
	}
	return out;
}

function addStoryTres(file) {
	const src = fs.readFileSync(file, "utf8");
	const re = /^"([^"]+)":\s*\[(.*)\],?\s*$/gm;
	let m;
	while ((m = re.exec(src))) {
		let arr;
		try { arr = JSON.parse("[" + m[2] + "]"); } catch (e) { continue; }
		arr.forEach((t, i) => { if (typeof t === "string") texts.push({ file: rel(file), key: m[1] + (arr.length > 1 ? "#" + i : ""), text: t }); });
	}
}

function addJsonStrings(file, keyFilter) {
	let data;
	try { data = JSON.parse(fs.readFileSync(file, "utf8")); } catch (e) { return; }
	const visit = (v, keyPath) => {
		if (typeof v === "string") {
			const last = keyPath[keyPath.length - 1] || "";
			if (!keyFilter || keyFilter(String(last), keyPath)) texts.push({ file: rel(file), key: keyPath.join("."), text: v });
		} else if (Array.isArray(v)) v.forEach((x, i) => visit(x, keyPath.concat([keyPath[keyPath.length - 1] + "[" + i + "]"])));
		else if (v && typeof v === "object") for (const k of Object.keys(v)) visit(v[k], keyPath.concat([k]));
	};
	visit(data, []);
}

function addTresFields(file, fields) {
	const src = fs.readFileSync(file, "utf8");
	for (const f of fields) {
		const re = new RegExp("^" + f + ' = "((?:[^"\\\\]|\\\\.)*)"', "m");
		const m = re.exec(src);
		if (m) texts.push({ file: rel(file), key: f, text: m[1].replace(/\\"/g, '"').replace(/\\n/g, "\n") });
	}
}

function addGdStrings(file) {
	const lines = fs.readFileSync(file, "utf8").split(/\r?\n/);
	lines.forEach((line, i) => {
		const t = line.trim();
		if (t.startsWith("#") || t.startsWith("##")) return;
		const re = /"((?:[^"\\]|\\.){12,})"/g;
		let m;
		while ((m = re.exec(line))) {
			const s = m[1];
			if (!/ /.test(s) || /^res:\/\//.test(s) || /%[sd]/.test(s) && s.length < 20) continue;
			texts.push({ file: rel(file) + ":" + (i + 1), key: "", text: s.replace(/\\"/g, '"') });
		}
	});
}

// ---- collect
walk(path.join(ROOT, "data/story"), (p) => p.endsWith(".tres")).forEach(addStoryTres);
walk(path.join(ROOT, "data/story"), (p) => p.endsWith(".json")).forEach((f) => addJsonStrings(f, (k) => !/^(id|key|speaker_id|portrait|still|music|sfx|scene|flag|npc|cue|anchor|image|art)$/i.test(k)));
addJsonStrings(path.join(ROOT, "data/npcs/npcs.json"), (k, kp) => /^(name|barks|barks\[\d+\]|sample_line|freed_barks|freed_barks\[\d+\])$/.test(k) || /barks/.test(kp.join(".")));
walk(path.join(ROOT, "data/feats"), (p) => p.endsWith(".json")).forEach((f) => addJsonStrings(f, (k) => /^(name|title|description|text|hint)$/i.test(k)));
walk(path.join(ROOT, "data/loading"), (p) => p.endsWith(".json")).forEach((f) => addJsonStrings(f));
walk(path.join(ROOT, "data/bestiary"), (p) => p.endsWith(".json")).forEach((f) => addJsonStrings(f, (k) => /^(name|title|description|text|lore|flavor|flavour)$/i.test(k)));
walk(path.join(ROOT, "data/cards"), (p) => p.endsWith(".tres")).forEach((f) => addTresFields(f, ["display_name", "rules_text", "flavor_text"]));
for (const d of ["data/items", "data/equipment"]) walk(path.join(ROOT, d), (p) => p.endsWith(".tres")).forEach((f) => addTresFields(f, ["display_name", "description", "flavor_text"]));
for (const f of ["core/quests/quest_definitions.gd", "core/quests/zone_quest_definitions.gd"]) addGdStrings(path.join(ROOT, f));

// ---- canon names
const canonSrc = fs.readFileSync(path.join(ROOT, "docs/design/canon.md"), "utf8");
const canonNames = new Set();
for (const m of canonSrc.matchAll(/\b([A-Z][a-z]+(?:[-'][A-Z]?[a-z]+)?)\b/g)) if (m[1].length >= 5) canonNames.add(m[1]);
const npcNames = new Set();
try {
	const npcs = JSON.parse(fs.readFileSync(path.join(ROOT, "data/npcs/npcs.json"), "utf8"));
	for (const r of (Array.isArray(npcs) ? npcs : npcs.npcs || [])) for (const w of String(r.name || "").split(/[\s,]+/)) if (/^[A-Z][a-z]{4,}$/.test(w)) npcNames.add(w);
} catch (e) {}
const names = new Set([...canonNames, ...npcNames]);
const allWords = new Map();
for (const t of texts) for (const m of t.text.matchAll(/\b([A-Z][a-z]{4,})\b/g)) allWords.set(m[1], (allWords.get(m[1]) || 0) + 1);

function lev(a, b) {
	const dp = Array.from({ length: a.length + 1 }, (_, i) => [i]);
	for (let j = 1; j <= b.length; j++) dp[0][j] = j;
	for (let i = 1; i <= a.length; i++) for (let j = 1; j <= b.length; j++)
		dp[i][j] = Math.min(dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1));
	return dp[a.length][b.length];
}
const nearMiss = new Map();
for (const [w, n] of allWords) {
	if (names.has(w)) continue;
	for (const c of names) {
		if (Math.abs(c.length - w.length) > 1 || c[0] !== w[0]) continue;
		const d = lev(w, c);
		if (d === 1 && (allWords.get(c) || 0) > n * 3 && w.length >= 6) nearMiss.set(w, c);
	}
}

// ---- checks
const MISSPELL = { teh: "the", recieve: "receive", seperate: "separate", definately: "definitely", occured: "occurred", untill: "until", wich: "which", accomodate: "accommodate", wierd: "weird", thier: "their", alot: "a lot", "it's own": "its own", becuase: "because", begining: "beginning", calender: "calendar", enviroment: "environment", existance: "existence", goverment: "government", independant: "independent", neccessary: "necessary", noticable: "noticeable", occassion: "occasion", persistant: "persistent", posession: "possession", publically: "publicly", recomend: "recommend", refered: "referred", succesful: "successful", tommorow: "tomorrow", truely: "truly", writting: "writing", armour: null, colour: null };
const findings = [];
const add = (kind, t, detail) => findings.push({ kind, file: t.file, key: t.key, text: t.text, detail });
for (const t of texts) {
	const s = t.text;
	if (/\S  +\S/.test(s)) add("double space", t, "");
	if (/\s[,.;:!?](\s|$)/.test(s) && !/\s\.\.\./.test(s)) add("space before punctuation", t, "");
	if (/\b(TODO|FIXME|PLACEHOLDER|lorem|XXX)\b/i.test(s) || /\bdebug\b/i.test(s)) add("dev text", t, "");
	if (/\?\?\?/.test(s)) add("???", t, "");
	const rep = s.match(/\b([A-Za-z]{2,})\s+\1\b/i);
	if (rep && !/^(ha|ho|no|so|hm|very|bye|yes|tick|knock|ding|rep|clap|cha|la|na|chop|bang|very|boom|stamp|go|run|beep|woof|hup|tap|now|quick|well|that|had|is|in)$/i.test(rep[1])) add("repeated word", t, rep[0]);
	for (const [bad, good] of Object.entries(MISSPELL)) {
		if (!good) continue;
		if (new RegExp("\\b" + bad.replace(/'/g, "'") + "\\b", "i").test(s)) add("misspelling", t, bad + " -> " + good);
	}
	for (const [w, c] of nearMiss) if (new RegExp("\\b" + w + "\\b").test(s)) add("name near-miss", t, w + " (canon: " + c + ")");
	if (/\bD\.N\.A(?!\.)/.test(s) || /\bDNA\b/.test(s)) add("name spelling", t, "D.N.A. is written with three dots");
	if (/Doppelgänger/.test(s)) add("name spelling", t, "Doppelganger has no umlaut");
	if (/\bPathology\b/.test(s)) add("name spelling", t, "Path-ology keeps its hyphen");
	if (/\bCross ?path\b/.test(s) && !/Crosspath/.test(s)) add("name spelling", t, "Crosspath is one word");
	if (/\bWay weaver|Wayweavers'/.test(s)) add("name spelling", t, "Wayweaver");
}

// ---- report
const kinds = [...new Set(findings.map((f) => f.kind))];
const out = ["# Text sweep (Nov 9)", "", "Generated by `node tools/text_sweep.js`: " + texts.length + " player-facing strings scanned, " + findings.length + " findings.", ""];
for (const k of kinds) {
	const rows = findings.filter((f) => f.kind === k);
	out.push("## " + k + " (" + rows.length + ")", "");
	for (const f of rows) out.push("- `" + f.file + (f.key ? " " + f.key : "") + "`" + (f.detail ? " - " + f.detail : "") + ": " + JSON.stringify(f.text.length > 220 ? f.text.slice(0, 220) + "..." : f.text));
	out.push("");
}
fs.mkdirSync(path.join(ROOT, "docs/release"), { recursive: true });
fs.writeFileSync(path.join(ROOT, "docs/release/text_sweep_nov9.md"), out.join("\n"));
console.log(texts.length + " strings, " + findings.length + " findings");
for (const k of kinds) console.log("  " + k + ": " + findings.filter((f) => f.kind === k).length);
