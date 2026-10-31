#!/usr/bin/env node
// Overnight Oct 30-31, Part 8: loudness of every sound-effect event, analysed offline with ffmpeg's ebur128 filter, and normalised by category.
// Each event is measured as the game plays it at rest: its loudest layer's variants (each padded to 0.5 s so a short click still fills one
// 400 ms momentary window), the loudest momentary loudness (M, LUFS) averaged over the variants, plus the layer gain and the event level.
// Category = the event's bus, with footsteps, resources, previews and dialogue voices split out (they are heard many times a minute).
// The target of a category is its own median (the mix of the sound pass is kept); an event more than TOLERANCE LU away from it is moved toward
// it (to TOLERANCE - 1 of the median, at most MAX_STEP dB a run) in data/source/sfx_events.csv with --apply. Then: node tools/sfx_build.js bank.
//   node tools/sfx_loudness.js [--apply] [--out=docs/audio/loudness_oct31.md]
const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const ROOT = path.resolve(__dirname, "..");
const BANK = JSON.parse(fs.readFileSync(path.join(ROOT, "data", "audio", "sfx_bank.json"), "utf8"));
const EVENTS_CSV = path.join(ROOT, "data", "source", "sfx_events.csv");
const TOLERANCE = 5.0;
const MAX_STEP = 4.0;
// Deliberately far from their category (the sound pass's direction): the hover ticks are the quietest sounds in the game because they fire
// constantly. They are measured and listed, never moved.
const EXEMPT = new Set(["ui_hover", "card_hover", "sprint_start", "sign_read"]);  // sign_read: raising it peaks at -0.2 dBFS (sfx_check)  // sprint_start: a soft cue heard every time the hero breaks into a run
const args = process.argv.slice(2);
const APPLY = args.includes("--apply");
const OUT = (args.find((a) => a.startsWith("--out=")) || "--out=docs/audio/loudness_oct31.md").slice(6);

function ffmpegPath() {
  const probe = spawnSync("ffmpeg", ["-version"], { encoding: "utf8" });
  if (probe.status === 0) return "ffmpeg";
  const winget = path.join(process.env.LOCALAPPDATA || "", "Microsoft", "WinGet", "Packages");
  if (fs.existsSync(winget)) {
    for (const dir of fs.readdirSync(winget)) {
      if (!dir.startsWith("Gyan.FFmpeg")) continue;
      for (const sub of fs.readdirSync(path.join(winget, dir))) {
        const bin = path.join(winget, dir, sub, "bin", "ffmpeg.exe");
        if (fs.existsSync(bin)) return bin;
      }
    }
  }
  throw new Error("ffmpeg not found");
}
const FF = ffmpegPath();

const cache = {};
function maxMomentary(resPath) {
  if (cache[resPath] !== undefined) return cache[resPath];
  const file = path.join(ROOT, resPath.replace(/^res:\/\//, ""));
  if (!fs.existsSync(file)) return (cache[resPath] = null);
  const run = spawnSync(FF, ["-v", "verbose", "-nostats", "-hide_banner", "-i", file, "-af", "apad=whole_dur=0.5,ebur128=peak=true:framelog=verbose", "-f", "null", "-"], { encoding: "utf8", maxBuffer: 64 * 1024 * 1024 });
  let best = -Infinity;
  for (const line of run.stderr.split("\n")) {
    const m = line.match(/\sM:\s*(-?[\d.]+|-inf)/);
    if (m && m[1] !== "-inf") best = Math.max(best, parseFloat(m[1]));
  }
  return (cache[resPath] = Number.isFinite(best) ? best : null);
}

function category(name, event) {
  if (name.startsWith("step_") || name === "footstep") return "Footsteps";
  if (/_(gain|spend)$/.test(name) || name === "resource_gain") return "Resources";
  if (name.startsWith("preview_")) return "Previews";
  if (name.startsWith("dialogue")) return "Dialogue voice";
  return event.bus || "Master";
}

function measure(name, event) {
  let loudest = null;
  for (const layer of event.layers || []) {
    const variants = BANK.sets[layer.set] || [];
    const values = variants.map(maxMomentary).filter((v) => v !== null);
    if (!values.length) continue;
    const mean = values.reduce((a, b) => a + b, 0) / values.length + (layer.gain || 0);
    if (loudest === null || mean > loudest) loudest = mean;
  }
  return loudest === null ? null : loudest + (event.volume || 0);
}

const median = (xs) => { const s = [...xs].sort((a, b) => a - b); const m = Math.floor(s.length / 2); return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2; };
const pct = (xs, p) => { const s = [...xs].sort((a, b) => a - b); return s[Math.min(s.length - 1, Math.max(0, Math.round((s.length - 1) * p)))]; };
const f1 = (x) => (x === null || x === undefined ? "-" : x.toFixed(1));

const rows = [];
for (const [name, event] of Object.entries(BANK.events)) {
  const lufs = measure(name, event);
  if (lufs === null) continue;
  rows.push({ name, cat: category(name, event), lufs, volume: event.volume || 0 });
}
const byCat = {};
for (const r of rows) (byCat[r.cat] = byCat[r.cat] || []).push(r);
const moves = {};
const lines = ["# Sound-effect loudness by category (Overnight Oct 30-31, Part 8)", "",
  "Measured offline by `node tools/sfx_loudness.js` (ffmpeg ebur128): each event's loudest momentary loudness (M, LUFS, 400 ms window) as the game",
  "plays it at rest (its loudest layer, every variant averaged, plus the layer gain and the event level; before the bus sliders). The target of a",
  `category is its own median; events more than ${TOLERANCE} LU away from it are pulled toward it (at most ${MAX_STEP} dB per run).`, "",
  "| Category | Events | Median LUFS | p10 | p90 | Spread p10-p90 | Outliers moved |", "|---|---:|---:|---:|---:|---:|---|"];
for (const [cat, list] of Object.entries(byCat).sort()) {
  const values = list.map((r) => r.lufs);
  const target = median(values);
  const moved = [];
  for (const r of list) {
    const delta = r.lufs - target;
    if (Math.abs(delta) > TOLERANCE && !EXEMPT.has(r.name)) {
      const step = Math.sign(delta) * Math.min(MAX_STEP, Math.abs(delta) - (TOLERANCE - 1));
      const next = Math.round((r.volume - step) * 2) / 2;
      moves[r.name] = next;
      moved.push(`${r.name} ${f1(r.lufs)} -> ${f1(r.lufs - (r.volume - next))}`);
    }
  }
  lines.push(`| ${cat} | ${list.length} | ${f1(target)} | ${f1(pct(values, 0.1))} | ${f1(pct(values, 0.9))} | ${f1(pct(values, 0.9) - pct(values, 0.1))} | ${moved.join("; ") || "-"} |`);
}
lines.push("", "## Every event", "", "| Event | Category | LUFS (M max) | Level dB | New level |", "|---|---|---:|---:|---:|");
for (const r of rows.sort((a, b) => a.cat.localeCompare(b.cat) || b.lufs - a.lufs)) {
  lines.push(`| ${r.name} | ${r.cat} | ${f1(r.lufs)} | ${r.volume} | ${moves[r.name] !== undefined ? moves[r.name] : ""} |`);
}
fs.mkdirSync(path.dirname(path.join(ROOT, OUT)), { recursive: true });
fs.writeFileSync(path.join(ROOT, OUT), lines.join("\n") + "\n");
console.log(`loudness: ${rows.length} events in ${Object.keys(byCat).length} categories; ${Object.keys(moves).length} outliers${APPLY ? " moved" : " (dry run)"}; report ${OUT}`);

if (APPLY && Object.keys(moves).length) {
  const csv = fs.readFileSync(EVENTS_CSV, "utf8").split("\n");
  let changed = 0;
  for (let i = 0; i < csv.length; i++) {
    const line = csv[i];
    if (!line || line.startsWith("#") || line.startsWith("event,")) continue;
    const name = line.split(",")[0];
    if (moves[name] === undefined) continue;
    // event,bus,layers,volume_db,... - layers never contain a comma
    const parts = line.split(",");
    parts[3] = String(moves[name]);
    csv[i] = parts.join(",");
    changed++;
  }
  fs.writeFileSync(EVENTS_CSV, csv.join("\n"));
  console.log(`loudness: ${changed} rows of sfx_events.csv updated; now run: node tools/sfx_build.js bank`);
}
