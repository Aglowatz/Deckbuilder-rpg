// Overnight Oct 17 (Phase 2, performance): small copies of the card art for grids.
//   node tools/card_thumbs.js [--force]
// Writes assets/art/cards_thumb/<CardID>.webp at 256x384 (a third of the 768x1152 art) for every assets/art/cards/*.webp, so screens that
// show many small cards (the Collection Book, the Deck Station, vendors) decode a ninth of the pixels when they open. CardView uses them
// below THUMB_SCALE (`CardArt.thumb`). Re-run after "import card art" (tools/import_art.sh); --force rebuilds every thumbnail.
const fs = require('fs'), path = require('path'), cp = require('child_process');
const root = path.join(__dirname, '..');
const ffdir = process.env.FFMPEG_DIR || 'C:/Users/asche/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-9.0.2-full_build/bin';
const ffmpeg = path.join(ffdir, 'ffmpeg');
const src = path.join(root, 'assets/art/cards');
const out = path.join(root, 'assets/art/cards_thumb');
fs.mkdirSync(out, { recursive: true });
const force = process.argv.includes('--force');
let made = 0, kept = 0, failed = 0;
for (const file of fs.readdirSync(src).filter((f) => f.endsWith('.webp'))) {
	const target = path.join(out, file);
	if (!force && fs.existsSync(target) && fs.statSync(target).mtimeMs >= fs.statSync(path.join(src, file)).mtimeMs) { kept++; continue; }
	const run = cp.spawnSync(ffmpeg, ['-v', 'error', '-y', '-i', path.join(src, file), '-vf', 'scale=256:384:flags=lanczos', '-c:v', 'libwebp', '-quality', '82', target], { encoding: 'utf8' });
	if (run.status === 0) made++; else { failed++; console.log('card_thumbs: FAILED', file, run.stderr.trim()); }
}
let bytes = 0;
for (const f of fs.readdirSync(out).filter((f) => f.endsWith('.webp'))) bytes += fs.statSync(path.join(out, f)).size;
console.log(`card_thumbs: ${made} made, ${kept} up to date, ${failed} failed; ${(bytes / 1048576).toFixed(1)} MB in assets/art/cards_thumb`);
