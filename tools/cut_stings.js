// Overnight Oct 17, Part 12: boss-victory stings cut from the game's own boss tracks.
//   node tools/cut_stings.js
// For every MUS-*-BOSS loop it finds the loudest 3.6 s stretch (the climax, by RMS over 0.25 s steps), cuts it with a 30 ms fade-in
// and a 1.5 s fade-out into assets/audio/stings/STG-WIN-<track>.wav (44.1 kHz stereo WAV like the other stings), measures its
// loudness and writes data/audio/audio_extras.json: game-made registry entries (kept apart from the generated audio_registry.json so
// "import audio" never drops them). Winning a boss battle plays its boss track's sting (BattleScreen._show_result).
const fs = require('fs'), path = require('path'), cp = require('child_process');
const root = path.join(__dirname, '..');
const ffdir = process.env.FFMPEG_DIR || 'C:/Users/asche/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-9.0.2-full_build/bin';
const ffmpeg = path.join(ffdir, 'ffmpeg');
const LENGTH = 3.6, STEP = 0.25, SR = 22050, TARGET = -17, CEILING = -1.5;
const music = path.join(root, 'assets/audio/music');
const entries = {};
for (const file of fs.readdirSync(music).filter((f) => /^MUS-.*-BOSS\.ogg$/.test(f)).sort()) {
	const id = file.replace('.ogg', '');
	const raw = cp.spawnSync(ffmpeg, ['-v', 'error', '-i', path.join(music, file), '-f', 'f32le', '-ac', '1', '-ar', String(SR), '-'], { maxBuffer: 1 << 30 }).stdout;
	const x = new Float32Array(raw.buffer, raw.byteOffset, Math.floor(raw.length / 4));
	const win = Math.floor(LENGTH * SR), hop = Math.floor(STEP * SR);
	let best = 0, bestAt = 0;
	for (let at = 0; at + win < x.length; at += hop) {
		let s = 0;
		for (let i = at; i < at + win; i += 4) s += x[i] * x[i];
		if (s > best) { best = s; bestAt = at; }
	}
	const start = bestAt / SR;
	const out = path.join(root, 'assets/audio/stings', `STG-WIN-${id.slice(4)}.wav`);
	const run = cp.spawnSync(ffmpeg, ['-v', 'error', '-y', '-ss', start.toFixed(3), '-t', String(LENGTH), '-i', path.join(music, file), '-af', `afade=t=in:d=0.03,afade=t=out:st=${(LENGTH - 1.5).toFixed(2)}:d=1.5`, '-ar', '44100', '-ac', '2', '-c:a', 'pcm_s16le', out], { encoding: 'utf8' });
	if (run.status !== 0) { console.log('cut_stings: FAILED', id, run.stderr); continue; }
	const ebu = cp.spawnSync(ffmpeg, ['-nostats', '-i', out, '-af', 'ebur128=peak=true', '-f', 'null', '-'], { encoding: 'utf8' }).stderr.split('\n').slice(-16).join('\n');
	const lufs = parseFloat((ebu.match(/I:\s+(-?[\d.]+) LUFS/) || [0, -17])[1]);
	const peak = parseFloat((ebu.match(/Peak:\s+(-?[\d.]+) dBFS/) || [0, -3])[1]);
	const volume = Math.round(Math.max(-12, Math.min(9, Math.min(TARGET - lufs, CEILING - peak))) * 10) / 10;
	const stingId = `STG-WIN-${id.slice(4)}`;
	entries[stingId] = { name: `Boss down (${id})`, kind: 'sting', file: `res://assets/audio/stings/${stingId}.wav`, loop: false, bus: 'Music', volume_db: volume, zone: '', category: 'Sting', use: `Winning the battle that plays ${id}: its climax (${start.toFixed(1)} s in), cut by tools/cut_stings.js`, duration: LENGTH, gameplay: true };
	console.log(`cut_stings: ${stingId} from ${start.toFixed(1)} s, ${lufs} LUFS, peak ${peak}, volume ${volume} dB`);
}
fs.writeFileSync(path.join(root, 'data/audio/audio_extras.json'), JSON.stringify({ _about: 'Overnight Oct 17, Part 12: registry entries the game makes itself (tools/cut_stings.js), merged into AudioRegistry at load; not touched by "import audio".', entries }, null, '\t') + '\n');
