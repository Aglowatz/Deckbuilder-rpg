// Audio analysis for the music integration (docs/audio/music_integration.md): loudness (ffmpeg ebur128) and loop-seam checks
// on the delivered Drive files. Usage: node tools/audio_analyze.js <audio dir> <ffmpeg dir> <out csv>
// Seam checks (loops only; OGG files are full-file loops): `click` = how many times larger the first-sample prediction error at the
// wrap is than the 99.9th percentile of the file's own prediction error; `gap_s` = digital silence at the end + start of the file (an audible
// hole when the loop wraps); `jump_db` = RMS(first 1 s) - RMS(last 1 s) (a big step means the loop ends in a decay or fade that the start
// does not continue from). Flags: seam-click (click > 1), silent-gap (> 0.15 s of digital silence at the wrap), level-jump (>= 12 dB: needs a fix),
// level-step (6-12 dB: listen to it; often just musical dynamics).
const fs = require('fs'), path = require('path'), cp = require('child_process');
const [dir, ff, outCsv] = process.argv.slice(2);
const registry = JSON.parse(fs.readFileSync(path.join(dir, 'registry.json'), 'utf8').replace(/^\uFEFF/, ''));
const byFile = {};
for (const r of registry.records) byFile[r.file] = r;
const db = (x) => 20 * Math.log10(Math.max(x, 1e-9));
const rows = [['id', 'file', 'loop', 'frames', 'registry_loop_end', 'lufs', 'true_peak_db', 'lra', 'click', 'gap_s', 'jump_db', 'end_db', 'start_db', 'flags']];
const files = fs.readdirSync(dir).filter((f) => /\.(ogg|wav)$/.test(f)).sort();
for (const f of files) {
  const p = path.join(dir, f);
  const ebu = cp.spawnSync(path.join(ff, 'ffmpeg'), ['-nostats', '-i', p, '-af', 'ebur128=peak=true', '-f', 'null', '-'], { encoding: 'utf8' }).stderr.split('\n').slice(-16).join('\n');
  const num = (re) => { const m = ebu.match(re); return m ? parseFloat(m[1]) : NaN; };
  const lufs = num(/I:\s+(-?[\d.]+) LUFS/), lra = num(/LRA:\s+(-?[\d.]+) LU/), peak = num(/Peak:\s+(-?[\d.]+) dBFS/);
  const raw = cp.spawnSync(path.join(ff, 'ffmpeg'), ['-v', 'error', '-i', p, '-f', 'f32le', '-ac', '2', '-ar', '48000', '-'], { maxBuffer: 1 << 30 }).stdout;
  const x = new Float32Array(raw.buffer, raw.byteOffset, Math.floor(raw.length / 4));
  const n = Math.floor(x.length / 2);
  const rec = byFile[f] || {};
  const isLoop = rec.playback === 'Loop' || f.endsWith('.ogg');
  let click = 0, jump = 0, tail = 0, start = 0, gap = 0;
  const flags = [];
  if (isLoop && n > 96000) {
    // Prediction error at the wrap vs the file's own distribution.
    let worst = 0;
    for (let c = 0; c < 2; c++) {
      const errs = new Float32Array(n - 2);
      for (let i = 2; i < n; i++) errs[i - 2] = Math.abs(x[2 * i + c] - (2 * x[2 * (i - 1) + c] - x[2 * (i - 2) + c]));
      const sorted = Float32Array.from(errs).sort();
      const p999 = sorted[Math.floor(sorted.length * 0.999)] + 1e-5;
      const wrap = Math.abs(x[c] - (2 * x[2 * (n - 1) + c] - x[2 * (n - 2) + c]));
      worst = Math.max(worst, wrap / p999);
    }
    click = worst;
    const rms = (a, b) => { let s = 0; for (let i = a; i < b; i++) s += x[2 * i] * x[2 * i] + x[2 * i + 1] * x[2 * i + 1]; return Math.sqrt(s / (2 * (b - a))); };
    const w = 48000, endR = rms(n - w, n), startR = rms(0, w);
    let lead = 0; while (lead < n && Math.abs(x[2 * lead]) < 1e-3 && Math.abs(x[2 * lead + 1]) < 1e-3) lead++;
    let trail = 0; while (trail < n && Math.abs(x[2 * (n - 1 - trail)]) < 1e-3 && Math.abs(x[2 * (n - 1 - trail) + 1]) < 1e-3) trail++;
    gap = (lead + trail) / 48000;
    jump = db(startR) - db(endR); tail = db(endR); start = db(startR);
    if (click > 1.0) flags.push('seam-click');
    if (gap > 0.15) flags.push('silent-gap');
    if (Math.abs(jump) >= 12) flags.push('level-jump');
    else if (Math.abs(jump) >= 6) flags.push('level-step');
    if (rec.loop_end_exclusive_frame && Math.abs(rec.loop_end_exclusive_frame - n) > 2048) flags.push('length-mismatch');
  }
  rows.push([rec.id || f.replace(/\.\w+$/, ''), f, isLoop ? 1 : 0, n, rec.loop_end_exclusive_frame || '', lufs, peak, lra, click.toFixed(2), gap.toFixed(2), jump.toFixed(1), tail.toFixed(1), start.toFixed(1), flags.join(' ')]);
  process.stderr.write(f + ' ' + flags.join(' ') + '\n');
}
fs.writeFileSync(outCsv, rows.map((r) => r.join(',')).join('\n') + '\n');
