class_name MusicDropIn
extends RefCounted
## Overnight Oct 19-20, Part 7: the drop-in music pipeline used by "import audio" (tools/import_audio.gd, docs/audio/music_integration.md
## "Drop-in pipeline"). A new or changed loop placed in the Drive folder Approved_Audio, named by its ID from data/source/music_list.csv
## (MUS-TOWN.ogg, MUS-TOWN_v03.wav), is measured, given loop points, loudness-normalised and encoded to OGG Vorbis before it lands in
## assets/audio/music. The maths here is pure (tests/audio/test_music_drop_in.gd); `process_loop` runs ffmpeg.
##
## Loop points (Godot plays an OGG from `loop_offset` to the end of the file):
## 1. Explicit metadata wins: the Drive registry.json `loop_start_frame` / `loop_end_exclusive_frame`, when it says something (a start after
##    frame 0 or an end more than END_TOLERANCE before the end of the file; "loop end = file length" is treated as no metadata).
## 2. Otherwise the whole file loops, minus digital silence at either end (a silent wrap is an audible hole).
## 3. When the wrap still jumps (the last second is >= RESEAT_JUMP_DB away from the first), the end is re-seated at the point in the last
##    SEARCH_FRACTION of the file whose next second best matches the first second (normalised cross-correlation at 4 kHz, then moved to the
##    48 kHz frame whose sample and slope best match frame 0). Only a true repeat counts (ncc >= MIN_NCC, levels within MAX_LEVEL_DB);
##    a loop is never faded.
## Loudness: two-pass ffmpeg loudnorm to the loop target (AudioRegistry.TARGET_LOOP_LUFS, -20 LUFS) with the true peak at ENCODE_TP, in
## linear mode (one static gain, the composed dynamics stay). When the peak would stop the gain, a plain volume gain lands it a little under
## the target and the registry base volume does the rest.

const SEAM_RATE: int = 4000
const OUT_RATE: int = 48000
const VORBIS_QUALITY: int = 5
## 0.5 dB under AudioRegistry.PEAK_CEILING_DB: the Vorbis encode adds a few tenths.
const ENCODE_TP: float = -2.0
const MIN_NCC: float = 0.6
const MAX_LEVEL_DB: float = 1.5
const RESEAT_JUMP_DB: float = 6.0
const SEARCH_FRACTION: float = 0.12
const MIN_KEEP_FRACTION: float = 0.85
const SILENCE: float = 0.001
## A metadata loop end within this many frames of the file end means "the whole file" (decoder padding differs by a few hundred frames).
const END_TOLERANCE: int = 2048


# ---- Pure -------------------------------------------------------------------------------------


## "MUS-TOWN.ogg" -> {id: "MUS-TOWN", version: -1, ext: "ogg"}; "mus-town_v03.WAV" -> {id: "MUS-TOWN", version: 3, ext: "wav"}. {} for a name that is
## not an audio ID file.
static func parse_file_id(file_name: String) -> Dictionary:
	var matcher: RegEx = RegEx.new()
	matcher.compile("^((?:MUS|STG)-[A-Z0-9]+(?:-[A-Z0-9]+)*)(?:_[vV](\\d+))?\\.(ogg|wav)$")
	var name: String = file_name.strip_edges()
	var dot: int = name.rfind(".")
	if dot <= 0:
		return {}
	var found: RegExMatch = matcher.search(name.substr(0, dot).to_upper() + name.substr(dot).to_lower())
	if found == null:
		return {}
	var version: int = found.get_string(2).to_int() if not found.get_string(2).is_empty() else -1
	return {"id": found.get_string(1), "version": version, "ext": found.get_string(3)}


## The JSON block ffmpeg's loudnorm prints (print_format=json) as floats: input_i, input_tp, input_lra, input_thresh, target_offset. {} when absent.
static func parse_loudnorm_json(text: String) -> Dictionary:
	var start: int = text.rfind("{")
	var end: int = text.rfind("}")
	if start < 0 or end < start:
		return {}
	var parsed: Variant = JSON.parse_string(text.substr(start, end - start + 1))
	if not (parsed is Dictionary):
		return {}
	var raw: Dictionary = parsed as Dictionary
	if not raw.has("input_i") or not _finite_number(str(raw["input_i"])):
		return {}
	var result: Dictionary = {}
	for key: String in ["input_i", "input_tp", "input_lra", "input_thresh", "target_offset"]:
		var value: String = str(raw.get(key, "0"))
		result[key] = value.to_float() if _finite_number(value) else 0.0
	return result


## A plain finite number ("-20.96"); ffmpeg prints "-inf" / "nan" for a silent file.
static func _finite_number(text: String) -> bool:
	var lower: String = text.strip_edges().to_lower()
	return lower.is_valid_float() and not lower.contains("inf") and not lower.contains("nan")


## Static gain (dB) that reaches `target_i` without pushing the true peak past `target_tp`.
static func linear_gain_db(measured: Dictionary, target_i: float, target_tp: float) -> float:
	return minf(target_i - float(measured["input_i"]), target_tp - float(measured["input_tp"]))


## The second-pass audio filter: loudnorm in linear mode with the first pass's numbers, or a plain gain when the peak limits it.
static func second_pass_filter(measured: Dictionary, target_i: float, target_tp: float) -> String:
	if measured.is_empty():
		return "anull"
	if target_i - float(measured["input_i"]) > target_tp - float(measured["input_tp"]):
		return "volume=%.2fdB" % linear_gain_db(measured, target_i, target_tp)
	return "loudnorm=I=%s:TP=%s:LRA=20:measured_I=%s:measured_TP=%s:measured_LRA=%s:measured_thresh=%s:offset=%s:linear=true" % [
		target_i, target_tp, measured["input_i"], measured["input_tp"], measured["input_lra"], measured["input_thresh"], measured["target_offset"]]


static func _rms(x: PackedFloat32Array, from: int, to: int) -> float:
	var sum: float = 0.0
	for i: int in range(from, to):
		sum += x[i] * x[i]
	return sqrt(sum / maxf(1.0, float(to - from)))


static func _db(value: float) -> float:
	return 20.0 * log(maxf(value, 1e-9)) / log(10.0)


## How well the `window` samples after `end` continue like the file's first `window` samples: {ncc, level_db, score} (score 1 = identical).
static func seam_score(x: PackedFloat32Array, end: int, window: int) -> Dictionary:
	var ab: float = 0.0
	var aa: float = 0.0
	var bb: float = 0.0
	for i: int in window:
		var p: float = x[i]
		var q: float = x[end + i]
		ab += p * q
		aa += p * p
		bb += q * q
	var ncc: float = ab / sqrt(maxf(aa * bb, 1e-12))
	var level: float = absf(_db(_rms(x, 0, window)) - _db(_rms(x, end, end + window)))
	return {"ncc": ncc, "level_db": level, "score": ncc - 0.1 * level}


## Level of the first second minus the last second (dB) of mono `x` at `rate`: the wrap jump.
static func wrap_jump_db(x: PackedFloat32Array, rate: int) -> float:
	var n: int = x.size()
	var window: int = mini(rate, n / 2)
	if window <= 0:
		return 0.0
	return _db(_rms(x, 0, window)) - _db(_rms(x, n - window, n))


## The best loop end (index into mono `x` at `rate`) in the last `search_fraction` of the file, never keeping less than `min_keep`.
## {end, ncc, level_db, improves}; `improves` only for a true repeat.
static func best_loop_end(x: PackedFloat32Array, rate: int, window_seconds: float = 1.0, search_fraction: float = SEARCH_FRACTION, min_keep: float = MIN_KEEP_FRACTION) -> Dictionary:
	var n: int = x.size()
	var window: int = int(round(window_seconds * rate))
	var lo: int = maxi(maxi(int(round(n * min_keep)), int(round(n * (1.0 - search_fraction)))), window)
	var hi: int = n - window
	if hi <= lo:
		return {"end": n, "ncc": 0.0, "level_db": 0.0, "improves": false}
	var coarse: int = maxi(1, rate / 100)
	var best: int = lo
	var best_score: float = -INF
	var e: int = lo
	while e <= hi:
		var score: float = float(seam_score(x, e, window)["score"])
		if score > best_score:
			best_score = score
			best = e
		e += coarse
	for fine: int in range(maxi(lo, best - coarse), mini(hi, best + coarse) + 1):
		var score: float = float(seam_score(x, fine, window)["score"])
		if score > best_score:
			best_score = score
			best = fine
	var result: Dictionary = seam_score(x, best, window)
	var ncc: float = float(result["ncc"])
	var level: float = float(result["level_db"])
	return {"end": best, "ncc": ncc, "level_db": level, "improves": ncc >= MIN_NCC and level <= MAX_LEVEL_DB}


## Interleaved stereo `x` (index 0 = frame 0 of the loop); the frame within `radius` of `frame` whose samples and slopes best match frame 0.
static func refine_seam_frame(x: PackedFloat32Array, frame: int, radius: int) -> int:
	var frames: int = x.size() / 2
	var best: int = frame
	var best_cost: float = INF
	for f: int in range(maxi(1, frame - radius), mini(frames - 1, frame + radius) + 1):
		var cost: float = 0.0
		for c: int in 2:
			cost += absf(x[2 * f + c] - x[c])
			cost += 0.5 * absf((x[2 * f + c] - x[2 * (f - 1) + c]) - (x[2 + c] - x[c]))
		if cost < best_cost:
			best_cost = cost
			best = f
	return best


## Samples of digital silence (|x| < SILENCE) at the start and at the end of mono `x`: [lead, trail].
static func silence_runs(x: PackedFloat32Array) -> Array[int]:
	var n: int = x.size()
	var lead: int = 0
	while lead < n and absf(x[lead]) < SILENCE:
		lead += 1
	var trail: int = 0
	while trail < n - lead and absf(x[n - 1 - trail]) < SILENCE:
		trail += 1
	return [lead, trail]


## The loop decision, all in OUT_RATE frames. `frames` = file length; `explicit_start` / `explicit_end` from registry metadata (-1 = none);
## `lead` / `trail` = silence runs; `jump_db` = wrap jump after the trim; `seam` = best_loop_end converted to frames ({} = not searched).
## -> {trim_start, trim_end, loop_offset_frames, reason}. The file keeps [trim_start, trim_end); Godot loops from loop_offset_frames.
static func choose_loop(frames: int, explicit_start: int, explicit_end: int, lead: int, trail: int, jump_db: float, seam: Dictionary) -> Dictionary:
	# Metadata that just restates "the whole file" (the Drive registry lists loop end = decoded length for every delivered loop) is no loop point.
	var explicit_end_inside: bool = explicit_end > 0 and explicit_end < frames - END_TOLERANCE
	if explicit_end_inside or explicit_start > 0:
		var end: int = explicit_end if explicit_end_inside else frames
		var start: int = clampi(explicit_start, 0, end - 1)
		return {"trim_start": 0, "trim_end": end, "loop_offset_frames": start, "reason": "explicit loop points"}
	var trim_start: int = clampi(lead, 0, frames)
	var trim_end: int = clampi(frames - trail, trim_start, frames)
	var reasons: Array[String] = ["whole file"]
	if lead > 0 or trail > 0:
		reasons.append("silence trimmed")
	if absf(jump_db) >= RESEAT_JUMP_DB and not seam.is_empty() and bool(seam.get("improves", false)):
		trim_end = clampi(int(seam["end"]), trim_start + 1, trim_end)
		reasons.append("seam re-seated (ncc %.2f)" % float(seam.get("ncc", 0.0)))
	elif absf(jump_db) >= RESEAT_JUMP_DB:
		reasons.append("wrap jumps %.1f dB, no repeat found: listen" % jump_db)
	return {"trim_start": trim_start, "trim_end": trim_end, "loop_offset_frames": 0, "reason": ", ".join(reasons)}


# ---- ffmpeg -----------------------------------------------------------------------------------


static func _run(tool: String, args: PackedStringArray) -> Dictionary:
	var output: Array = []
	var code: int = OS.execute(tool, args, output, true)
	var text: String = ""
	for chunk: Variant in output:
		text += str(chunk)
	return {"code": code, "text": text}


static func measure_loudness(tool: String, path: String) -> Dictionary:
	var run: Dictionary = _run(tool, PackedStringArray(["-hide_banner", "-nostats", "-i", path, "-af",
		"loudnorm=I=%s:TP=%s:LRA=20:print_format=json" % [AudioRegistry.TARGET_LOOP_LUFS, ENCODE_TP], "-f", "null", "-"]))
	return parse_loudnorm_json(str(run["text"]))


static func _decode(tool: String, path: String, rate: int, channels: int, filter: String) -> PackedFloat32Array:
	var temp: String = ProjectSettings.globalize_path("user://music_drop_in.f32")
	var args: PackedStringArray = PackedStringArray(["-v", "error", "-y", "-i", path])
	if not filter.is_empty():
		args.append_array(["-af", filter])
	args.append_array(["-f", "f32le", "-ac", str(channels), "-ar", str(rate), temp])
	if int(_run(tool, args)["code"]) != 0:
		return PackedFloat32Array()
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(temp)
	DirAccess.remove_absolute(temp)
	return bytes.to_float32_array()


## Measures `source`, decides the loop points, and (unless `dry_run`) encodes the normalised OGG to `target` (absolute paths).
## `explicit` = {"start": frame, "end": frame} from the Drive registry ({} = none). -> {ok, error, reason, loop_offset, frames, lufs, tp, gain_filter}.
static func process_loop(tool: String, source: String, target: String, explicit: Dictionary, dry_run: bool) -> Dictionary:
	var result: Dictionary = {"ok": false, "error": "", "reason": "", "loop_offset": 0.0, "frames": 0, "lufs": 0.0, "tp": 0.0, "gain_filter": ""}
	var measured: Dictionary = measure_loudness(tool, source)
	var mono: PackedFloat32Array = _decode(tool, source, SEAM_RATE, 1, "")
	if measured.is_empty() or mono.size() < SEAM_RATE * 4:
		result["error"] = "ffmpeg could not measure %s" % source.get_file()
		return result
	var ratio: int = OUT_RATE / SEAM_RATE
	var frames: int = mono.size() * ratio
	var runs: Array[int] = silence_runs(mono)
	var body: PackedFloat32Array = mono.slice(runs[0], mono.size() - runs[1])
	var jump: float = wrap_jump_db(body, SEAM_RATE)
	var seam: Dictionary = {}
	if absf(jump) >= RESEAT_JUMP_DB:
		seam = best_loop_end(body, SEAM_RATE)
		seam["end"] = (int(seam["end"]) + runs[0]) * ratio
	var plan: Dictionary = choose_loop(frames, int(explicit.get("start", -1)), int(explicit.get("end", -1)), runs[0] * ratio, runs[1] * ratio, jump, seam)
	var trim_start: int = int(plan["trim_start"])
	var trim_end: int = int(plan["trim_end"])
	if str(plan["reason"]).contains("re-seated"):
		# Sample-accurate end: the 48 kHz frame near the 4 kHz match whose sample and slope continue into the loop's first frame.
		var head: PackedFloat32Array = _decode(tool, source, OUT_RATE, 2, "atrim=start_sample=%d:end_sample=%d" % [trim_start, trim_start + 4])
		var near: PackedFloat32Array = _decode(tool, source, OUT_RATE, 2, "atrim=start_sample=%d:end_sample=%d" % [trim_end - 480, trim_end + 480])
		if head.size() >= 4 and near.size() >= 4:
			var joined: PackedFloat32Array = head.slice(0, 4)
			joined.append_array(near)
			trim_end = trim_end - 480 + refine_seam_frame(joined, 482, 480) - 2
	var gain: String = second_pass_filter(measured, AudioRegistry.TARGET_LOOP_LUFS, ENCODE_TP)
	result["reason"] = plan["reason"]
	result["gain_filter"] = gain
	result["frames"] = trim_end - trim_start
	result["loop_offset"] = float(int(plan["loop_offset_frames"])) / float(OUT_RATE)
	if dry_run:
		result["ok"] = true
		result["lufs"] = AudioRegistry.TARGET_LOOP_LUFS
		result["tp"] = float(measured["input_tp"]) + linear_gain_db(measured, AudioRegistry.TARGET_LOOP_LUFS, ENCODE_TP)
		return result
	var filter: String = "aresample=%d,atrim=start_sample=%d:end_sample=%d,asetpts=PTS-STARTPTS,%s,aresample=%d" % [OUT_RATE, trim_start, trim_end, gain, OUT_RATE]
	var run: Dictionary = _run(tool, PackedStringArray(["-v", "error", "-y", "-i", source, "-af", filter, "-ar", str(OUT_RATE), "-ac", "2",
		"-c:a", "libvorbis", "-q:a", str(VORBIS_QUALITY), target]))
	if int(run["code"]) != 0:
		result["error"] = "ffmpeg could not encode %s: %s" % [source.get_file(), str(run["text"]).strip_edges()]
		return result
	var after: Dictionary = measure_loudness(tool, target)
	result["lufs"] = float(after.get("input_i", AudioRegistry.TARGET_LOOP_LUFS))
	result["tp"] = float(after.get("input_tp", ENCODE_TP))
	result["ok"] = true
	return result
