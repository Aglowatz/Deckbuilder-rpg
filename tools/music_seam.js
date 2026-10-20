// Overnight Oct 19-20, Part 7: pure loop-seam and loudnorm maths for tools/music_fix.js (mirrored in core/audio/music_drop_in.gd, which the
// importer uses and tests/audio/test_music_drop_in.gd covers). No I/O here.
//
// Loop model: Godot loops an OGG from loop_offset to the end of the file. A seamless loop needs the audio just after the loop end to sound
// like the start of the file. So the loop end E is the point in the last part of the track whose next `windowSeconds` best match the first
// `windowSeconds` (normalised cross-correlation, weighted by how close the two RMS levels are). Cutting the file at E then makes the wrap
// play what the music would have played anyway.

function rms(x, a, b) { let s = 0; for (let i = a; i < b; i++) s += x[i] * x[i]; return Math.sqrt(s / Math.max(1, b - a)); }
function ncc(x, a, b, w) {
	let sab = 0, saa = 0, sbb = 0;
	for (let i = 0; i < w; i++) { const p = x[a + i], q = x[b + i]; sab += p * q; saa += p * p; sbb += q * q; }
	return sab / Math.sqrt(Math.max(saa * sbb, 1e-12));
}
// Score of a candidate end (1 = identical continuation). Level mismatch costs 0.1 per dB.
function seamScore(x, rate, end, w) {
	const c = ncc(x, 0, end, w);
	const levelDb = Math.abs(20 * Math.log10(Math.max(rms(x, 0, w), 1e-9) / Math.max(rms(x, end, end + w), 1e-9)));
	return { score: c - 0.1 * levelDb, ncc: c, level_db: levelDb };
}
// x: mono samples at `rate`. Returns { end_seconds, score, ncc, level_db, improves }. `improves` only when the match is a real repeat
// (ncc >= 0.6 and the levels within 1.5 dB): otherwise the file is left as it is (no fade is ever put on a loop).
function bestLoopEnd(x, rate, opts = {}) {
	const w = Math.round((opts.windowSeconds || 1.0) * rate);
	const n = x.length;
	const lo = Math.max(Math.round(n * (opts.minKeepFraction || 0.85)), Math.round(n * (1 - (opts.searchFraction || 0.12))), w);
	const hi = n - w;
	if (hi <= lo) return { end_seconds: n / rate, score: 0, ncc: 0, level_db: 0, improves: false };
	const coarse = Math.max(1, Math.round(rate / 100));
	let best = lo, bestScore = -Infinity;
	for (let e = lo; e <= hi; e += coarse) { const s = seamScore(x, rate, e, w).score; if (s > bestScore) { bestScore = s; best = e; } }
	for (let e = Math.max(lo, best - coarse); e <= Math.min(hi, best + coarse); e++) { const s = seamScore(x, rate, e, w).score; if (s > bestScore) { bestScore = s; best = e; } }
	const r = seamScore(x, rate, best, w);
	return { end_seconds: best / rate, score: +r.score.toFixed(3), ncc: +r.ncc.toFixed(3), level_db: +r.level_db.toFixed(2), improves: r.ncc >= 0.6 && r.level_db <= 1.5 };
}
// Interleaved stereo `x`; moves `frame` within +-radius to where the samples and slopes best match frame 0 (no click at the wrap).
function refineToZeroCrossing(x, frame, radius) {
	const n = Math.floor(x.length / 2);
	let best = frame, bestCost = Infinity;
	for (let f = Math.max(2, frame - radius); f <= Math.min(n - 1, frame + radius); f++) {
		let cost = 0;
		for (let c = 0; c < 2; c++) {
			cost += Math.abs(x[2 * f + c] - x[c]);
			cost += 0.5 * Math.abs((x[2 * f + c] - x[2 * (f - 1) + c]) - (x[2 + c] - x[c]));
		}
		if (cost < bestCost) { bestCost = cost; best = f; }
	}
	return best;
}
// The JSON block ffmpeg's loudnorm prints (print_format=json) -> numbers. null when absent.
function parseLoudnormJson(text) {
	const start = text.lastIndexOf('{'), end = text.lastIndexOf('}');
	if (start < 0 || end < start) return null;
	let obj;
	try { obj = JSON.parse(text.slice(start, end + 1)); } catch (e) { return null; }
	const num = (k) => parseFloat(obj[k]);
	if (isNaN(num('input_i'))) return null;
	return { input_i: num('input_i'), input_tp: num('input_tp'), input_lra: num('input_lra'), input_thresh: num('input_thresh'), target_offset: num('target_offset') || 0 };
}
// Static gain (dB) to reach `targetI` without pushing the true peak past `targetTp`.
function linearGain(m, targetI, targetTp) { return Math.min(targetI - m.input_i, targetTp - m.input_tp); }
// Second-pass filter. When the peak ceiling would stop loudnorm staying linear, a plain volume gain is used instead (never dynamic
// compression: the composed dynamics are kept, the track just lands a little under the target and the registry base volume does the rest).
function loudnormSecondPass(m, targetI, targetTp) {
	if (!m) return 'anull';
	if (targetI - m.input_i > targetTp - m.input_tp) return `volume=${linearGain(m, targetI, targetTp).toFixed(2)}dB`;
	return `loudnorm=I=${targetI}:TP=${targetTp}:LRA=20:measured_I=${m.input_i}:measured_TP=${m.input_tp}:measured_LRA=${m.input_lra}:measured_thresh=${m.input_thresh}:offset=${m.target_offset}:linear=true`;
}
module.exports = { bestLoopEnd, refineToZeroCrossing, parseLoudnormJson, linearGain, loudnormSecondPass, seamScore };
