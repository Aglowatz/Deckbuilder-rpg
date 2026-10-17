#!/usr/bin/env node
// The mix report (docs/audio/sound_direction.md, "Mix"; Part E): renders every bank event offline the way the game plays it (each layer's first
// variant, its delay, the layer gain plus the event level, the layer pitch) and measures the loudest 50 ms (RMS) and the peak, against a target per
// role. Prints the outliers and, with --apply, moves each event's volume_db in data/source/sfx_events.csv toward its target (at most 6 dB per run).
//   node tools/sfx_mix_report.js [--apply] [--all]
const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const ROOT = path.resolve(__dirname, "..");
const BANK = JSON.parse(fs.readFileSync(path.join(ROOT, "data", "audio", "sfx_bank.json"), "utf8"));
const EVENTS_CSV = path.join(ROOT, "data", "source", "sfx_events.csv");
const TMP = path.join(ROOT, "_audio_source", "_mix");

// Target loudness (RMS of the loudest 50 ms, dBFS, before the bus sliders) by event name pattern; the first match wins.
const ROLES = [
	[/^ui_hover$|^card_hover$/, -36, "hover"],
	[/^dialogue/, -33, "dialogue blip"],
	[/^ui_slider$|^preview_tick$|^energy_tick$/, -32, "tick"],
	[/^ui_(click|select|tick|toggle|back|tab)$/, -29, "ui tap"],
	[/^ui_(confirm|open|close|error)$|^book$|^notify$|^refuse_open$/, -27, "ui"],
	[/^(deck_|game_save|game_load)/, -26, "ui action"],
	[/^(quest_|shop_buy|coins$|pack_tear|pack_whoosh|pack_flip)/, -23, "ui reward"],
	[/^pack_reveal|^level_up_layer$|_layer$/, -22, "under a sting"],
	[/^step_|^footstep$/, -27, "footstep"],
	[/^card_(draw|discard|return|pickup|shuffle|shred)$|^deck_sort$/, -26, "card handling"],
	[/^card_play_cheap$|^token_create$|^land_play$/, -24, "light card"],
	[/^card_play$|^spell_cast$|^summon_|^tool_attach$|^trap_set$|^attack_/, -22, "card"],
	[/^card_play_heavy$|^spell_cast_big$|^death_|^block$|^hit_metal$/, -19, "heavy card"],
	[/^(buff|debuff|heal|keyword_gain|energy_gain|coin_flip)$/, -26, "battle accent"],
	[/_gain$/, -24, "resource gained"],
	[/_spend$/, -27, "resource spent"],
	[/^hit_light$/, -20, "light hit"],
	[/^hit_medium$|^hit_player$/, -17, "medium hit"],
	[/^hit_heavy$|^trap_spring$|^wonder_play$/, -15, "big moment"],
	[/^turn_|^preview_lethal$|^low_hp$|^battle_start$/, -25, "turn and warning"],
	[/^(gate_big|vault_grind|chest_giant|thrower_land|thrower_launch|rift_seal)$/, -18, "big world"],
	[/^zone_transition$|^sign_read$/, -28, "world soft"],
	[/.*/, -22, "world"],
];

function ffmpeg(args) {
	const local = process.env.LOCALAPPDATA || "";
	let exe = "ffmpeg";
	const base = path.join(local, "Microsoft", "WinGet", "Packages");
	if (fs.existsSync(base)) {
		for (const dir of fs.readdirSync(base).filter((d) => d.startsWith("Gyan.FFmpeg"))) {
			for (const sub of fs.readdirSync(path.join(base, dir))) {
				const candidate = path.join(base, dir, sub, "bin", "ffmpeg.exe");
				if (fs.existsSync(candidate)) exe = candidate;
			}
		}
	}
	return spawnSync(exe, ["-hide_banner", "-nostdin", ...args], { encoding: "utf8", maxBuffer: 32 * 1024 * 1024 }).stderr || "";
}

const PEAKS = {};

function loudest(files) {
	let best = null;
	let bestPeak = -999;
	for (const res of files) {
		const file = path.join(ROOT, res.replace("res://", ""));
		if (PEAKS[file] === undefined) {
			const text = ffmpeg(["-i", file, "-af", "astats=measure_perchannel=none", "-f", "null", "-"]).split("Overall").pop();
			PEAKS[file] = Number((text.match(/Peak level dB:\s*(-?[0-9.]+)/) || [])[1] || -90);
		}
		if (PEAKS[file] > bestPeak) {
			bestPeak = PEAKS[file];
			best = file;
		}
	}
	return best;
}

function render(name, event) {
	const inputs = [];
	const chains = [];
	event.layers.forEach((layer, index) => {
		const files = BANK.sets[layer.set] || [];
		if (!files.length) return;
		// The loudest variant of the layer (the one that decides the peak).
		inputs.push("-i", loudest(files));
		const n = inputs.length / 2 - 1;
		const gain = (event.volume || 0) + (layer.gain || 0);
		const pitch = layer.pitch || 1;
		const delayMs = Math.round((layer.delay || 0) * 1000);
		chains.push(`[${n}]aformat=sample_fmts=fltp:channel_layouts=stereo,asetrate=44100*${pitch},aresample=44100,volume=${gain}dB,adelay=${delayMs}|${delayMs}[l${n}]`);
	});
	if (!chains.length) return null;
	const labels = chains.map((_, i) => `[l${i}]`).join("");
	const graph = `${chains.join(";")};${labels}amix=inputs=${chains.length}:normalize=0:duration=longest,astats=length=0.05:measure_perchannel=none`;
	const text = ffmpeg([...inputs, "-filter_complex", graph, "-f", "null", "-"]);
	const overall = text.split("Overall").pop();
	const rms = Number((overall.match(/RMS peak dB:\s*(-?[0-9.]+|-inf)/) || [])[1]);
	const peak = Number((overall.match(/Peak level dB:\s*(-?[0-9.]+|-inf)/) || [])[1]);
	return { rms: isFinite(rms) ? rms : -90, peak: isFinite(peak) ? peak : -90 };
}

function main() {
	const apply = process.argv.includes("--apply");
	const all = process.argv.includes("--all");
	const results = [];
	for (const [name, event] of Object.entries(BANK.events)) {
		const role = ROLES.find(([pattern]) => pattern.test(name));
		const measured = render(name, event);
		if (!measured) continue;
		results.push({ name, bus: event.bus, role: role[2], target: role[1], ...measured, volume: event.volume || 0, jitter: event.vol_jitter || 2 });
	}
	results.sort((a, b) => (Math.abs(b.rms - b.target) - Math.abs(a.rms - a.target)));
	console.log("event\tbus\trole\trms\ttarget\toff\tpeak");
	for (const r of results) {
		const off = r.rms - r.target;
		if (all || Math.abs(off) > 2 || r.peak + r.jitter + 1.0 > -1.5) console.log(`${r.name}\t${r.bus}\t${r.role}\t${r.rms.toFixed(1)}\t${r.target}\t${off >= 0 ? "+" : ""}${off.toFixed(1)}\t${r.peak.toFixed(1)}`);
	}
	const within = results.filter((r) => Math.abs(r.rms - r.target) <= 2).length;
	console.log(`${within}/${results.length} events within 2 dB of their role's target; ${results.filter((r) => r.peak + r.jitter + 1.0 > -1.5).length} could peak above -1.5 dBFS with their drift and the room`);
	if (apply) {
		const lines = fs.readFileSync(EVENTS_CSV, "utf8").split(/\r?\n/);
		const byName = Object.fromEntries(results.map((r) => [r.name, r]));
		let changed = 0;
		const out = lines.map((line) => {
			if (!line || line.startsWith("#") || line.startsWith("event,")) return line;
			const cells = line.split(",");
			const r = byName[cells[0]];
			if (!r) return line;
			// The move toward the target, never letting the peak pass -1.5 dBFS.
			let move = Math.max(-6, Math.min(6, r.target - r.rms));
			// Headroom for the random volume drift and the bus reverb: the loudest playing still stays under -1.5 dBFS.
			move = Math.min(move, -1.5 - r.peak - r.jitter - 1.0);
			if (Math.abs(move) < 0.75) return line;
			cells[3] = String(Math.round((Number(cells[3] || 0) + move) * 2) / 2);
			changed++;
			return cells.join(",");
		});
		fs.writeFileSync(EVENTS_CSV, out.join("\n"));
		console.log(`moved ${changed} event levels; run node tools/sfx_build.js bank`);
	}
	if (fs.existsSync(TMP)) fs.rmSync(TMP, { recursive: true, force: true });
}

main();
