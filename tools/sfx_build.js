#!/usr/bin/env node
// Sound-effects build (docs/audio/sound_direction.md, docs/audio/sfx_sources.md).
//   node tools/sfx_build.js [--force] [--only=<set prefix>]   process data/source/sfx_sources.csv into assets/audio/sfx/, then write the bank
//   node tools/sfx_build.js bank                               only rebuild data/audio/sfx_bank.json + docs/audio/sfx_sources.md
//   node tools/sfx_build.js onsets <file> [thresholdDb] [minSilence]   prints the sound events in a file (to pick start/end of variants)
//   node tools/sfx_build.js stats <file>                        loudness of a file
//   node tools/sfx_build.js report                              sizes per group, totals, cache size
//
// Each row of sfx_sources.csv is one shipped file: set (group/name), out (variant label), source, start, end, filters, category, channels,
// format, loop, notes. Sources: kenney:<pack>/<file> (the local CC0 packs in _asset_library/), fs:<id> (a freesound CC0 preview fetched with
// tools/freesound.js into _audio_source/), synth:<ffmpeg lavfi graph> (generated, original), file:<path> (a committed source).
// Processing: trim, extra filters, mono/stereo at 44.1 kHz, silence trimmed from both ends (one-shots), a seamless crossfaded loop (loop column = seconds),
// loudness normalised to the category target (RMS of the loudest 50 ms for one-shots, integrated LUFS for beds) with the peak capped at -1 dBFS,
// 3 ms / 12 ms fades, then OGG (q4) or 16-bit WAV. A freesound raw file is deleted as soon as every row that uses it is built (the cache stays small).
const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const ROOT = path.resolve(__dirname, "..");
const SOURCES = path.join(ROOT, "data", "source", "sfx_sources.csv");
const EVENTS = path.join(ROOT, "data", "source", "sfx_events.csv");
const META = path.join(ROOT, "data", "source", "sfx_meta.json");
const OUT_DIR = path.join(ROOT, "assets", "audio", "sfx");
const BANK = path.join(ROOT, "data", "audio", "sfx_bank.json");
const DOC = path.join(ROOT, "docs", "audio", "sfx_sources.md");
const CACHE = path.join(ROOT, "_audio_source");
const LIB = path.join(ROOT, "_asset_library");
const TMP = path.join(CACHE, "_tmp");

// Loudness targets. Short sounds: RMS of the loudest 50 ms window in dBFS. Long sounds (*_lufs): integrated loudness.
const TARGETS = {
	ui_hover: -31, ui: -25, ui_big: -19, voice: -29,
	card_light: -25, card: -21, card_heavy: -17,
	hit_light: -18, hit_medium: -15, hit_heavy: -12,
	accent: -20, accent_soft: -24, big: -14,
	step: -24, world: -20, world_big: -15, amb_oneshot: -24,
	amb_bed_lufs: -30, amb_layer_lufs: -33, amb_spot_lufs: -26,
};

function ffmpegPath(name) {
	const local = process.env.LOCALAPPDATA || "";
	const base = path.join(local, "Microsoft", "WinGet", "Packages");
	if (fs.existsSync(base)) {
		for (const dir of fs.readdirSync(base)) {
			if (!dir.startsWith("Gyan.FFmpeg")) continue;
			for (const sub of fs.readdirSync(path.join(base, dir))) {
				const exe = path.join(base, dir, sub, "bin", name + ".exe");
				if (fs.existsSync(exe)) return exe;
			}
		}
	}
	return name;
}
const FFMPEG = process.env.FFMPEG || ffmpegPath("ffmpeg");

function run(args, allowFail) {
	const result = spawnSync(FFMPEG, ["-hide_banner", "-nostdin", ...args], { encoding: "utf8", maxBuffer: 64 * 1024 * 1024 });
	if (result.status !== 0 && !allowFail) {
		throw new Error(`ffmpeg failed: ${args.join(" ")}\n${(result.stderr || "").split("\n").slice(-12).join("\n")}`);
	}
	return result.stderr || "";
}

function parseCsv(text) {
	const rows = [];
	let row = [];
	let field = "";
	let quoted = false;
	for (let i = 0; i < text.length; i++) {
		const c = text[i];
		if (quoted) {
			if (c === '"' && text[i + 1] === '"') { field += '"'; i++; }
			else if (c === '"') quoted = false;
			else field += c;
		} else if (c === '"') quoted = true;
		else if (c === ",") { row.push(field); field = ""; }
		else if (c === "\n" || c === "\r") {
			if (c === "\r" && text[i + 1] === "\n") i++;
			row.push(field); field = "";
			if (row.some((v) => v.trim() !== "")) rows.push(row);
			row = [];
		} else field += c;
	}
	row.push(field);
	if (row.some((v) => v.trim() !== "")) rows.push(row);
	const header = rows.shift().map((h) => h.trim());
	return rows.filter((r) => !r[0].trim().startsWith("#")).map((r) => Object.fromEntries(header.map((h, i) => [h, (r[i] || "").trim()])));
}

function loadMeta() {
	return fs.existsSync(META) ? JSON.parse(fs.readFileSync(META, "utf8")) : {};
}

function outPath(row) {
	const ext = row.format === "wav" ? "wav" : "ogg";
	const [group, name] = row.set.split("/");
	return path.join(OUT_DIR, group, `${name}_${row.out}.${ext}`);
}

function resPath(file) {
	return "res://" + path.relative(ROOT, file).split(path.sep).join("/");
}

function findKenney(spec) {
	const [pack, ...rest] = spec.split("/");
	const file = rest.join("/");
	const dir = path.join(LIB, pack.startsWith("kenney-") ? pack : "kenney-" + pack);
	const stack = [dir];
	while (stack.length) {
		const current = stack.pop();
		if (!fs.existsSync(current)) continue;
		for (const entry of fs.readdirSync(current, { withFileTypes: true })) {
			const full = path.join(current, entry.name);
			if (entry.isDirectory()) stack.push(full);
			else if (entry.name === file || full.split(path.sep).join("/").endsWith("/" + file)) return full;
		}
	}
	throw new Error(`Kenney file not found: ${spec}`);
}

function inputArgs(row) {
	const source = row.source;
	if (source.startsWith("kenney:")) return ["-i", findKenney(source.slice(7))];
	if (source.startsWith("fs:")) {
		const file = path.join(CACHE, `fs_${source.slice(3)}.ogg`);
		if (!fs.existsSync(file)) {
			const fetch = spawnSync(process.execPath, [path.join(__dirname, "freesound.js"), "fetch", source.slice(3)], { encoding: "utf8" });
			process.stdout.write(fetch.stdout || "");
			process.stderr.write(fetch.stderr || "");
			if (!fs.existsSync(file)) throw new Error(`freesound ${source} could not be fetched`);
		}
		return ["-i", file];
	}
	if (source.startsWith("synth:")) return ["-f", "lavfi", "-i", source.slice(6)];
	if (source.startsWith("file:")) return ["-i", path.join(ROOT, source.slice(5))];
	if (source.startsWith("built:")) {
		// Another shipped file (set/name_out.ext) as the input: a derived variant.
		return ["-i", path.join(OUT_DIR, source.slice(6))];
	}
	throw new Error(`unknown source ${source}`);
}

function measure(file, long) {
	if (long) {
		const text = run(["-i", file, "-af", "ebur128=peak=true", "-f", "null", "-"], true);
		const integrated = Number((text.match(/I:\s+(-?[0-9.]+) LUFS/g) || []).pop()?.match(/-?[0-9.]+/)[0]);
		const peak = Number((text.match(/Peak:\s+(-?[0-9.]+|-inf) dBFS/g) || []).pop()?.match(/-?[0-9.]+|-inf/)[0]);
		return { loud: integrated, peak: isFinite(peak) ? peak : -90 };
	}
	const text = run(["-i", file, "-af", "astats=length=0.05:measure_perchannel=none", "-f", "null", "-"], true);
	const overall = text.split("Overall").pop();
	const rmsPeak = Number((overall.match(/RMS peak dB:\s*(-?[0-9.]+|-inf)/) || [])[1]);
	const peak = Number((overall.match(/Peak level dB:\s*(-?[0-9.]+|-inf)/) || [])[1]);
	return { loud: isFinite(rmsPeak) ? rmsPeak : -90, peak: isFinite(peak) ? peak : -90 };
}

function duration(file) {
	const text = run(["-i", file, "-f", "null", "-"], true);
	const all = text.match(/time=(\d+):(\d+):([0-9.]+)/g) || [];
	const last = all.pop();
	if (!last) return 0;
	const [, h, m, s] = last.match(/time=(\d+):(\d+):([0-9.]+)/);
	return Number(h) * 3600 + Number(m) * 60 + Number(s);
}

function buildRow(row) {
	fs.mkdirSync(TMP, { recursive: true });
	const target = outPath(row);
	fs.mkdirSync(path.dirname(target), { recursive: true });
	const channels = row.channels === "2" ? 2 : 1;
	const loop = Number(row.loop || 0);
	const category = row.category || "world";
	const long = category.endsWith("_lufs");
	const stage1 = path.join(TMP, "stage1.wav");
	const stage2 = path.join(TMP, "stage2.wav");
	const pre = [];
	if (row.filters) pre.push(row.filters);
	pre.push(`aresample=44100`, `aformat=sample_fmts=fltp:channel_layouts=${channels === 2 ? "stereo" : "mono"}`);
	const oneShot = !loop && !long;
	const trim = [];
	if (row.start) trim.push("-ss", row.start);
	if (oneShot) {
		// One-shots: the leading silence goes first, so `end` counts from the start of the sound (start + its length); then the trailing silence.
		pre.push("silenceremove=start_periods=1:start_threshold=-55dB:start_silence=0.002");
		if (row.end) pre.push(`atrim=end=${Number(row.end) - Number(row.start || 0)}`);
		pre.push("areverse", "silenceremove=start_periods=1:start_threshold=-60dB:start_silence=0.01", "areverse");
	} else if (row.end) {
		trim.push("-to", row.end);
	}
	const input = inputArgs(row);
	const synth = row.source.startsWith("synth:");
	run(["-y", ...(synth ? [] : trim), ...input, ...(synth ? trim : []), "-af", pre.join(","), "-c:a", "pcm_f32le", stage1]);
	let source = stage1;
	if (loop > 0) {
		const total = duration(stage1);
		const xf = Math.min(3.0, Math.max(0.3, loop * 0.08));
		if (total < loop + xf) throw new Error(`${row.set}_${row.out}: ${total.toFixed(1)}s is too short for a ${loop}s loop`);
		run(["-y", "-i", stage1, "-filter_complex",
			`[0]asplit[s1][s2];[s1]atrim=start=${xf}:end=${loop + xf},asetpts=PTS-STARTPTS[a];[s2]atrim=0:${xf},asetpts=PTS-STARTPTS[b];[a][b]acrossfade=d=${xf}:c1=qsin:c2=qsin`,
			"-c:a", "pcm_f32le", stage2]);
		source = stage2;
	}
	const level = measure(source, long);
	const goal = TARGETS[category];
	if (goal === undefined) throw new Error(`unknown category ${category}`);
	// The gain that reaches the target, capped so the peak stays at or under -1 dBFS (no limiter: a very peaky transient ends a little under its target).
	let gain = Math.min(goal - level.loud, -1.0 - level.peak);
	const len = duration(source);
	const codec = row.format === "wav" ? ["-c:a", "pcm_s16le"] : ["-c:a", "libvorbis", "-q:a", long || channels === 2 ? "3" : "4"];
	const encode = () => {
		const post = [`volume=${gain.toFixed(2)}dB`];
		if (!loop) {
			const fadeOut = Math.min(0.012, len * 0.2);
			// The trim starts where the sound rises past -55 dB, so a 0.3 ms fade-in is enough against a click and leaves the transient untouched.
			post.push(`afade=t=in:d=0.0003`, `afade=t=out:st=${Math.max(0, len - fadeOut).toFixed(4)}:d=${fadeOut.toFixed(4)}`);
		}
		run(["-y", "-i", source, "-af", post.join(","), ...codec, "-map_metadata", "-1", target]);
		return measure(target, long);
	};
	let final = encode();
	// One correction pass: the fades and the encoder can move a short sound off its target.
	const correction = Math.min(goal - final.loud, -1.0 - final.peak);
	if (Math.abs(correction) > 0.8) {
		gain += correction;
		final = encode();
	}
	return { file: target, duration: len, gain, loud: final.loud, peak: final.peak };
}

function walk(dir) {
	const files = [];
	if (!fs.existsSync(dir)) return files;
	for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
		const full = path.join(dir, entry.name);
		if (entry.isDirectory()) files.push(...walk(full));
		else files.push(full);
	}
	return files;
}

function dirSize(dir, filter) {
	return walk(dir).filter((f) => !filter || filter(f)).reduce((sum, f) => sum + fs.statSync(f).size, 0);
}

function sourceCredit(row, meta) {
	if (row.source.startsWith("kenney:")) {
		const pack = row.source.slice(7).split("/")[0].replace(/^kenney-/, "");
		return { origin: `Kenney ${pack.replace(/-/g, " ")} (${row.source.slice(7).split("/").pop()})`, author: "Kenney (kenney.nl)", license: "CC0 1.0", url: `https://kenney.nl/assets/${pack}` };
	}
	if (row.source.startsWith("fs:")) {
		const id = row.source.slice(3);
		const info = meta[id] || {};
		return { origin: `freesound ${id}: ${info.title || "?"}`, author: info.author || "?", license: info.license || "CC0 1.0", url: info.url || `https://freesound.org/s/${id}/` };
	}
	if (row.source.startsWith("built:")) return { origin: `derived from ${row.source.slice(6)}`, author: "(see that file)", license: "(as that file)", url: "" };
	return { origin: "generated with ffmpeg (original)", author: "The Wayward Path", license: "CC0 1.0 (original)", url: "" };
}

function writeBank(rows) {
	const meta = loadMeta();
	const sets = {};
	for (const row of rows) {
		const file = outPath(row);
		if (!fs.existsSync(file)) continue;
		(sets[row.set] = sets[row.set] || []).push(resPath(file));
	}
	for (const key of Object.keys(sets)) sets[key].sort();
	const loops = [...new Set(rows.filter((r) => Number(r.loop || 0) > 0).map((r) => r.set))].sort();
	const events = {};
	if (fs.existsSync(EVENTS)) {
		for (const ev of parseCsv(fs.readFileSync(EVENTS, "utf8"))) {
			const layers = ev.layers.split("+").filter(Boolean).map((spec) => {
				// set, then @delay_ms, :gain_db and ~pitch in any order.
				const m = spec.trim().match(/^([a-z0-9_\/]+)((?:[@:~]-?[0-9.]+)*)$/);
				if (!m) throw new Error(`bad layer "${spec}" in ${ev.event}`);
				const part = (mark) => (m[2].match(new RegExp(`\\${mark}(-?[0-9.]+)`)) || [])[1];
				return { set: m[1], delay: Number(part("@") || 0) / 1000, gain: Number(part(":") || 0), ...(part("~") ? { pitch: Number(part("~")) } : {}) };
			});
			for (const layer of layers) {
				if (!sets[layer.set]) console.warn(`warning: event ${ev.event} uses set ${layer.set}, which has no files yet`);
			}
			events[ev.event] = {
				bus: ev.bus || "Battle",
				layers,
				volume: Number(ev.volume_db || 0),
				pitch: Number(ev.pitch || 4) / 100,
				vol_jitter: Number(ev.vol_jitter || 2),
				priority: Number(ev.priority || 50),
				max: Number(ev.max_voices || 3),
				cooldown: Number(ev.cooldown_ms || 40) / 1000,
				spatial: ev.spatial === "3d",
				range: Number(ev.range || 0),
				duck: Number(ev.duck_db || 0),
			};
		}
	}
	fs.mkdirSync(path.dirname(BANK), { recursive: true });
	fs.writeFileSync(BANK, JSON.stringify({ generated: "tools/sfx_build.js from data/source/sfx_sources.csv + sfx_events.csv", sets, loops, events }, null, "\t") + "\n");
	// The sources doc.
	const lines = [
		"# Sound effect sources",
		"",
		"Generated by `node tools/sfx_build.js bank` from `data/source/sfx_sources.csv` (one row per shipped file) and `data/source/sfx_meta.json` (freesound titles and authors).",
		"Every file is CC0 (Kenney's packs, freesound sounds filtered to Creative Commons 0 and checked on each sound's page, or generated here with ffmpeg); none needs attribution, but the authors are credited in `CREDITS.md` anyway.",
		"",
		"| File | Source | Author | Licence | Processing |",
		"|---|---|---|---|---|",
	];
	for (const row of rows) {
		const file = outPath(row);
		if (!fs.existsSync(file)) continue;
		const credit = sourceCredit(row, meta);
		const link = credit.url ? `[${credit.origin.replace(/\|/g, "/")}](${credit.url})` : credit.origin;
		const proc = [row.start || row.end ? `${row.start || 0}-${row.end || "end"} s` : "", row.filters ? "filtered" : "", row.loop ? `${row.loop} s loop` : "", row.category].filter(Boolean).join(", ");
		lines.push(`| \`${path.relative(OUT_DIR, file).split(path.sep).join("/")}\` | ${link} | ${credit.author} | ${credit.license} | ${proc} |`);
	}
	const authors = {};
	for (const row of rows.filter((r) => r.source.startsWith("fs:"))) {
		const info = meta[row.source.slice(3)] || {};
		if (info.author) (authors[info.author] = authors[info.author] || new Set()).add(row.source.slice(3));
	}
	lines.push("", "## Freesound authors", "", Object.keys(authors).sort((a, b) => a.localeCompare(b)).map((a) => `${a} (${[...authors[a]].sort().join(", ")})`).join("; ") || "(none yet)", "");
	fs.writeFileSync(DOC, lines.join("\n"));
	// The CREDITS.md block (between its markers).
	const credits = path.join(ROOT, "CREDITS.md");
	const packs = [...new Set(rows.filter((r) => r.source.startsWith("kenney:") && fs.existsSync(outPath(r))).map((r) => r.source.slice(7).split("/")[0].replace(/^kenney-/, "")))].sort();
	const synthCount = rows.filter((r) => r.source.startsWith("synth:") && fs.existsSync(outPath(r))).length;
	const block = [
		"<!-- sfx-credits:start (written by tools/sfx_build.js) -->",
		`**assets/audio/sfx/** - the sound-effects pass (2026-10-16): ${Object.values(sets).reduce((n, l) => n + l.length, 0)} files, every one CC0, processed (trimmed, filtered, levelled, looped) by \`tools/sfx_build.js\`; the per-file source, author and licence are in \`docs/audio/sfx_sources.md\`.`,
		"",
		`- Kenney (https://kenney.nl), CC0: ${packs.map((p) => `${p} (https://kenney.nl/assets/${p})`).join(", ")}.`,
		`- Freesound (https://freesound.org), sounds released under Creative Commons 0 (CC0 1.0), by: ${Object.keys(authors).sort((a, b) => a.localeCompare(b)).map((a) => `${a} (${[...authors[a]].sort().map((id) => `freesound.org/s/${id}`).join(", ")})`).join("; ") || "(none)"}.`,
		`- ${synthCount} sounds generated with ffmpeg for this game (original, CC0).`,
		"<!-- sfx-credits:end -->",
	].join("\n");
	if (fs.existsSync(credits)) {
		let text = fs.readFileSync(credits, "utf8");
		const start = text.indexOf("<!-- sfx-credits:start");
		const end = text.indexOf("<!-- sfx-credits:end -->");
		if (start >= 0 && end > start) text = text.slice(0, start) + block + text.slice(end + "<!-- sfx-credits:end -->".length);
		else text = text.replace("Town, battle and title music are generated in code", block + "\n\nTown, battle and title music are generated in code");
		fs.writeFileSync(credits, text);
	}
	return { sets: Object.keys(sets).length, files: Object.values(sets).reduce((n, list) => n + list.length, 0), events: Object.keys(events).length };
}

function cleanupCache(rows, built) {
	// A freesound download is deleted once every row that uses it has its output.
	for (const file of fs.existsSync(CACHE) ? fs.readdirSync(CACHE) : []) {
		const m = file.match(/^fs_(\d+)\.ogg$/);
		if (!m) continue;
		const users = rows.filter((r) => r.source === `fs:${m[1]}`);
		if (users.length && users.every((r) => fs.existsSync(outPath(r)))) fs.unlinkSync(path.join(CACHE, file));
	}
	if (fs.existsSync(TMP)) fs.rmSync(TMP, { recursive: true, force: true });
}

function main() {
	const args = process.argv.slice(2);
	if (args[0] === "onsets") {
		const threshold = args[2] || "-40";
		const minSilence = args[3] || "0.08";
		const text = run(["-i", args[1], "-af", `silencedetect=noise=${threshold}dB:d=${minSilence}`, "-f", "null", "-"], true);
		const starts = [...text.matchAll(/silence_start: (-?[0-9.]+)/g)].map((m) => Number(m[1]));
		const ends = [...text.matchAll(/silence_end: ([0-9.]+)/g)].map((m) => Number(m[1]));
		const total = duration(args[1]);
		const events = [];
		let cursor = 0;
		const firstSilentAtZero = starts.length && starts[0] <= 0.001;
		if (!firstSilentAtZero) events.push([0, starts[0] ?? total]);
		for (let i = 0; i < ends.length; i++) events.push([ends[i], starts[firstSilentAtZero ? i + 1 : i + 1] ?? total]);
		console.log(`duration ${total.toFixed(2)}s, ${events.length} events:`);
		for (const [a, b] of events) if (b > a) console.log(`${a.toFixed(3)}\t${b.toFixed(3)}\t(${(b - a).toFixed(3)}s)`);
		return;
	}
	if (args[0] === "stats") {
		const s = measure(args[1], false);
		const l = measure(args[1], true);
		console.log(`duration ${duration(args[1]).toFixed(2)}s  rms50ms ${s.loud.toFixed(1)} dB  peak ${s.peak.toFixed(1)} dB  ${l.loud} LUFS`);
		return;
	}
	const rows = parseCsv(fs.readFileSync(SOURCES, "utf8"));
	if (args[0] === "report") {
		const groups = {};
		for (const file of walk(OUT_DIR).filter((f) => /\.(ogg|wav)$/.test(f))) {
			const group = path.relative(OUT_DIR, file).split(path.sep)[0];
			groups[group] = (groups[group] || 0) + fs.statSync(file).size;
		}
		for (const [group, size] of Object.entries(groups).sort()) console.log(`${group.padEnd(12)} ${(size / 1048576).toFixed(2)} MB`);
		console.log(`total shipped sfx: ${(dirSize(OUT_DIR, (f) => /\.(ogg|wav)$/.test(f)) / 1048576).toFixed(2)} MB in ${walk(OUT_DIR).filter((f) => /\.(ogg|wav)$/.test(f)).length} files`);
		console.log(`download cache: ${(dirSize(CACHE) / 1048576).toFixed(2)} MB`);
		return;
	}
	if (args[0] !== "bank") {
		const force = args.includes("--force");
		const only = (args.find((a) => a.startsWith("--only=")) || "").slice(7);
		const seen = new Set();
		let built = 0;
		for (const row of rows) {
			const key = `${row.set}_${row.out}`;
			if (seen.has(key)) throw new Error(`duplicate row ${key}`);
			seen.add(key);
			if (only && !row.set.startsWith(only)) continue;
			if (!force && fs.existsSync(outPath(row))) continue;
			try {
				const info = buildRow(row);
				built++;
				console.log(`${key.padEnd(34)} ${info.duration.toFixed(2)}s gain ${info.gain >= 0 ? "+" : ""}${info.gain.toFixed(1)} -> ${info.loud.toFixed(1)} (peak ${info.peak.toFixed(1)})`);
			} catch (error) {
				console.error(`FAILED ${key}: ${error.message}`);
			}
			cleanupCache(rows);
		}
		console.log(`built ${built} files`);
	}
	const summary = writeBank(rows);
	console.log(`bank: ${summary.sets} sets, ${summary.files} files, ${summary.events} events`);
	cleanupCache(rows);
}

main();
