// Overnight Oct 19-20, Part 7: measure and repair the in-game music files (docs/audio/music_audit.md "Oct 19 fixes").
//   node tools/music_fix.js --analyze [ID ...]          measure assets/audio/music/<ID>.ogg (all loops when no ID) -> JSON lines on stdout
//   node tools/music_fix.js --fix ID [ID ...] [--dry]    back up the in-game file once to _art_source/audio_backup_oct19/, then rebuild it:
//        trim digital silence at both ends, gentle EQ when the band check flags harshness or mud (2 dB shelf / bell, never more),
//        two-pass loudnorm to the game's loop target (-20 LUFS integrated, true peak <= -1.5 dBTP; core/data/audio_registry.gd), and for a loop
//        whose wrap still steps, a re-seated seam (the best-matching earlier point, tools/music_seam.js maths) instead of a fade.
//        Encodes OGG Vorbis q5 (~160 kbps) and records the new levels in data/source/audio_levels_local.csv (the importer prefers them while the
//        in-game file's MD5 matches, so the registry base volume stays right).
//   node tools/music_fix.js --restore ID [ID ...]        put the backed-up original back.
// Measurements: integrated loudness / LRA / true peak (ffmpeg ebur128), silence at the start and end (< -60 dBFS), the first and last 50 ms RMS
// (the loop seam: last 50 ms -> first 50 ms), the 1 s jump (as tools/audio_analyze.js), the sample step at the wrap, and band energy shares
// from a 4096-point FFT every 0.5 s: mud = 150-500 Hz, harsh = 2.5-8 kHz, both against the 500-2500 Hz mid band in dB.
const fs = require('fs'), path = require('path'), cp = require('child_process');
const seamMath = require('./music_seam.js');
const root = path.join(__dirname, '..');
const ffdir = process.env.FFMPEG_DIR || 'C:/Users/asche/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-9.0.2-full_build/bin';
const ffmpeg = path.join(ffdir, 'ffmpeg');
const musicDir = path.join(root, 'assets/audio/music');
const backupDir = path.join(root, '_art_source/audio_backup_oct19');
const localLevels = path.join(root, 'data/source/audio_levels_local.csv');
const TARGET_LUFS = -20.0, TARGET_TP = -1.5, SR = 48000, HARSH_LIMIT = -6.5, MUD_LIMIT = 12.0;

function pcm(file, rate = SR) {
	const raw = cp.spawnSync(ffmpeg, ['-v', 'error', '-i', file, '-f', 'f32le', '-ac', '2', '-ar', String(rate), '-'], { maxBuffer: 1 << 30 }).stdout;
	return new Float32Array(raw.buffer.slice(raw.byteOffset, raw.byteOffset + Math.floor(raw.length / 4) * 4));
}
function ebur(file) {
	const err = cp.spawnSync(ffmpeg, ['-nostats', '-i', file, '-af', 'ebur128=peak=true', '-f', 'null', '-'], { encoding: 'utf8', maxBuffer: 1 << 28 }).stderr;
	const tail = err.split('\n').slice(-16).join('\n');
	const num = (re) => { const m = tail.match(re); return m ? parseFloat(m[1]) : NaN; };
	return { lufs: num(/I:\s+(-?[\d.]+) LUFS/), lra: num(/LRA:\s+(-?[\d.]+) LU/), tp: num(/Peak:\s+(-?[\d.]+) dBFS/) };
}
const db = (v) => 20 * Math.log10(Math.max(v, 1e-9));
function fft(re, im) {
	const n = re.length;
	for (let i = 1, j = 0; i < n; i++) { let bit = n >> 1; for (; j & bit; bit >>= 1) j ^= bit; j ^= bit; if (i < j) { [re[i], re[j]] = [re[j], re[i]]; [im[i], im[j]] = [im[j], im[i]]; } }
	for (let len = 2; len <= n; len <<= 1) {
		const ang = -2 * Math.PI / len, wr = Math.cos(ang), wi = Math.sin(ang);
		for (let i = 0; i < n; i += len) {
			let cr = 1, ci = 0;
			for (let k = 0; k < len / 2; k++) {
				const a = i + k, b = a + len / 2;
				const tr = re[b] * cr - im[b] * ci, ti = re[b] * ci + im[b] * cr;
				re[b] = re[a] - tr; im[b] = im[a] - ti; re[a] += tr; im[a] += ti;
				const nr = cr * wr - ci * wi; ci = cr * wi + ci * wr; cr = nr;
			}
		}
	}
}
function bands(x, n) {
	const N = 4096, hop = SR / 2, e = { low: 0, mud: 0, mid: 0, harsh: 0, air: 0 };
	const re = new Float64Array(N), im = new Float64Array(N);
	for (let s = 0; s + N < n; s += hop) {
		for (let i = 0; i < N; i++) { const w = 0.5 - 0.5 * Math.cos(2 * Math.PI * i / N); re[i] = (x[2 * (s + i)] + x[2 * (s + i) + 1]) * 0.5 * w; im[i] = 0; }
		fft(re, im);
		for (let k = 1; k < N / 2; k++) {
			const f = k * SR / N, p = re[k] * re[k] + im[k] * im[k];
			if (f < 150) e.low += p; else if (f < 500) e.mud += p; else if (f < 2500) e.mid += p; else if (f < 8000) e.harsh += p; else e.air += p;
		}
	}
	const r = (a) => 10 * Math.log10(Math.max(a, 1e-12) / Math.max(e.mid, 1e-12));
	return { low_db: +r(e.low).toFixed(1), mud_db: +r(e.mud).toFixed(1), harsh_db: +r(e.harsh).toFixed(1), air_db: +r(e.air).toFixed(1) };
}
function analyze(file) {
	const x = pcm(file); const n = Math.floor(x.length / 2);
	const rms = (a, b) => { let s = 0; for (let i = a; i < b; i++) s += x[2 * i] * x[2 * i] + x[2 * i + 1] * x[2 * i + 1]; return Math.sqrt(s / (2 * Math.max(1, b - a))); };
	const quiet = (i) => Math.abs(x[2 * i]) < 1e-3 && Math.abs(x[2 * i + 1]) < 1e-3;
	let lead = 0; while (lead < n && quiet(lead)) lead++;
	let trail = 0; while (trail < n && quiet(n - 1 - trail)) trail++;
	const w50 = SR / 20;
	const first50 = db(rms(0, w50)), last50 = db(rms(n - w50, n));
	const step = Math.abs(x[0] - x[2 * (n - 1)]) + Math.abs(x[1] - x[2 * (n - 1) + 1]);
	const loud = ebur(file);
	return Object.assign({ seconds: +(n / SR).toFixed(2), lead_s: +(lead / SR).toFixed(2), trail_s: +(trail / SR).toFixed(2), first50_db: +first50.toFixed(1), last50_db: +last50.toFixed(1),
		seam50_db: +(first50 - last50).toFixed(1), jump1s_db: +(db(rms(0, SR)) - db(rms(n - SR, n))).toFixed(1), step: +step.toFixed(3) }, loud, bands(x, n));
}

function loudnormMeasure(file, pre) {
	const af = (pre ? pre + ',' : '') + `loudnorm=I=${TARGET_LUFS}:TP=${TARGET_TP - 0.5}:LRA=20:print_format=json`;
	const err = cp.spawnSync(ffmpeg, ['-nostats', '-i', file, '-af', af, '-f', 'null', '-'], { encoding: 'utf8', maxBuffer: 1 << 28 }).stderr;
	return seamMath.parseLoudnormJson(err);
}

function fix(id, dry) {
	const file = path.join(musicDir, id + '.ogg');
	const backup = path.join(backupDir, id + '.ogg');
	fs.mkdirSync(backupDir, { recursive: true });
	if (!fs.existsSync(backup)) fs.copyFileSync(file, backup);
	// Start from the delivered take when tools/loop_fix.js baked a crossfade into the in-game file (its original is in _art_source/audio_original/).
	const original = path.join(root, '_art_source/audio_original', id + '.ogg');
	const source = fs.existsSync(original) ? original : backup;
	const before = analyze(backup);
	const delivered = source === backup ? before : analyze(source);
	const filters = [];
	// Silence: drop digital silence at both ends (a loop wraps straight into the music).
	filters.push('silenceremove=start_periods=1:start_threshold=-60dB,areverse,silenceremove=start_periods=1:start_threshold=-60dB,areverse');
	// Gentle EQ only for an outlier (thresholds from the catalogue spread, see music_audit.md "Oct 19 fixes").
	const eq = [];
	// Catalogue spread (123 files, Oct 19): harsh (2.5-8 kHz vs mid) median -24.8 dB, 90th percentile -8.2; mud (150-500 Hz) median 2.9, p90 9.9.
	if (delivered.harsh_db > HARSH_LIMIT) eq.push('highshelf=f=5000:g=-2:t=q:w=0.7');
	if (delivered.mud_db > MUD_LIMIT) eq.push('equalizer=f=300:t=q:w=1.0:g=-2');
	filters.push(...eq);
	const tmp = path.join(backupDir, id + '.stage.wav');
	cp.spawnSync(ffmpeg, ['-v', 'error', '-y', '-i', source, '-af', filters.join(','), '-c:a', 'pcm_f32le', tmp]);
	// Seam: a loop that still steps (> 3 dB between the last and first 50 ms, or a 1 s jump > 6 dB) is re-seated at the best-matching point.
	let seam = null;
	const staged = analyze(tmp);
	if (Math.abs(staged.jump1s_db) > 6 || source !== backup) {
		const mono = pcm(tmp, 4000); const m = new Float32Array(mono.length / 2);
		for (let i = 0; i < m.length; i++) m[i] = (mono[2 * i] + mono[2 * i + 1]) * 0.5;
		seam = seamMath.bestLoopEnd(m, 4000, { windowSeconds: 1.0, searchFraction: 0.12, minKeepFraction: 0.85 });
	}
	const stage2 = path.join(backupDir, id + '.stage2.wav');
	if (seam && seam.improves) {
		const endFrame = seamMath.refineToZeroCrossing(pcm(tmp), Math.round(seam.end_seconds * SR), 480);
		cp.spawnSync(ffmpeg, ['-v', 'error', '-y', '-i', tmp, '-af', `atrim=end_sample=${endFrame}`, '-c:a', 'pcm_f32le', stage2]);
		seam.end_frame = endFrame;
	} else if (source !== backup) {
		// No real repeat to re-seat on: keep the crossfaded in-game take (re-run the trim and EQ on it).
		cp.spawnSync(ffmpeg, ['-v', 'error', '-y', '-i', backup, '-af', filters.join(','), '-c:a', 'pcm_f32le', stage2]);
		if (seam) seam.kept_crossfade = true;
	} else fs.copyFileSync(tmp, stage2);
	const trimmed = delivered.lead_s + delivered.trail_s >= 0.01 && !(seam && seam.kept_crossfade && before.lead_s + before.trail_s < 0.01);
	if (!trimmed && eq.length === 0 && !(seam && seam.improves)) {
		// Nothing to repair: a gain change alone is left to the registry base volume (lossless), never a second lossy encode.
		fs.unlinkSync(tmp); fs.unlinkSync(stage2);
		return { id, changed: false, before, seam };
	}
	// Two-pass loudnorm (linear: a static gain, the dynamics stay as composed).
	const m1 = loudnormMeasure(stage2, '');
	const ln = seamMath.loudnormSecondPass(m1, TARGET_LUFS, TARGET_TP - 0.5);
	const out = dry ? path.join(backupDir, id + '.fixed.ogg') : file;
	const run = cp.spawnSync(ffmpeg, ['-v', 'error', '-y', '-i', stage2, '-af', ln + ',aresample=48000', '-ar', '48000', '-c:a', 'libvorbis', '-q:a', '5', out], { encoding: 'utf8' });
	fs.unlinkSync(tmp); fs.unlinkSync(stage2);
	if (run.status !== 0) { console.error('music_fix: FAILED', id, run.stderr); return null; }
	const after = analyze(out);
	if (!dry) writeLocalLevel(id, out, after);
	return { id, changed: true, eq, seam, gain: ln, before, after };
}

function md5(file) { return require('crypto').createHash('md5').update(fs.readFileSync(file)).digest('hex'); }
function writeLocalLevel(id, file, a) {
	const header = 'id,file,loop,frames,registry_loop_end,lufs,true_peak_db,lra,click,gap_s,jump_db,end_db,start_db,flags,md5,loop_offset_s';
	let lines = fs.existsSync(localLevels) ? fs.readFileSync(localLevels, 'utf8').trim().split('\n').slice(1) : [];
	lines = lines.filter((l) => !l.startsWith(id + ','));
	const frames = Math.round(a.seconds * SR);
	lines.push([id, id + '.ogg', 1, frames, frames, a.lufs, a.tp, a.lra, '0.00', (a.lead_s + a.trail_s).toFixed(2), a.jump1s_db, a.last50_db, a.first50_db, 'oct19-fixed', md5(file), 0].join(','));
	lines.sort();
	fs.writeFileSync(localLevels, [header, ...lines].join('\n') + '\n');
}

const args = process.argv.slice(2);
const ids = args.filter((a) => !a.startsWith('--'));
if (args.includes('--analyze')) {
	const list = ids.length ? ids : fs.readdirSync(musicDir).filter((f) => f.endsWith('.ogg')).map((f) => f.replace(/\.ogg$/, '')).sort();
	for (const id of list) {
		const file = fs.existsSync(path.join(musicDir, id + '.ogg')) ? path.join(musicDir, id + '.ogg') : id;
		console.log(JSON.stringify(Object.assign({ id }, analyze(file))));
	}
} else if (args.includes('--restore')) {
	for (const id of ids) { const b = path.join(backupDir, id + '.ogg'); if (fs.existsSync(b)) fs.copyFileSync(b, path.join(musicDir, id + '.ogg')); }
	if (fs.existsSync(localLevels)) {
		const lines = fs.readFileSync(localLevels, 'utf8').trim().split('\n');
		fs.writeFileSync(localLevels, lines.filter((l, i) => i === 0 || !ids.some((id) => l.startsWith(id + ','))).join('\n') + '\n');
	}
	console.log('music_fix: restored', ids.join(', '));
} else if (args.includes('--fix')) {
	for (const id of ids) console.log(JSON.stringify(fix(id, args.includes('--dry'))));
} else console.log('usage: node tools/music_fix.js --analyze [ID...] | --fix ID... [--dry] | --restore ID...');
