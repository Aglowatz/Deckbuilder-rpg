extends GutTest
## Overnight Oct 19-20, Part 7: the pure parts of the drop-in music pipeline (core/audio/music_drop_in.gd): ID parsing, the loudnorm JSON and
## second-pass filter, the loop-point maths, and the local levels that keep the registry base volume right for repaired files.

const LOUDNORM_OUTPUT: String = """[Parsed_loudnorm_0 @ 000001a127056f00]
{
	"input_i" : "-20.96",
	"input_tp" : "-9.03",
	"input_lra" : "10.90",
	"input_thresh" : "-31.62",
	"output_i" : "-20.38",
	"output_tp" : "-7.99",
	"output_lra" : "10.60",
	"output_thresh" : "-31.01",
	"normalization_type" : "dynamic",
	"target_offset" : "0.38"
}
[out#0/null @ 000001a12516e680] video:0KiB audio:113333KiB"""


func _noise(count: int, seed_value: int) -> PackedFloat32Array:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var result: PackedFloat32Array = PackedFloat32Array()
	result.resize(count)
	for i: int in count:
		result[i] = rng.randf_range(-0.5, 0.5)
	return result


func test_file_names_parse_to_ids() -> void:
	assert_eq(MusicDropIn.parse_file_id("MUS-TOWN.ogg"), {"id": "MUS-TOWN", "version": -1, "ext": "ogg"})
	assert_eq(MusicDropIn.parse_file_id("mus-town-freed_v03.WAV"), {"id": "MUS-TOWN-FREED", "version": 3, "ext": "wav"})
	assert_eq(MusicDropIn.parse_file_id("STG-PACK-RARE_V12.wav"), {"id": "STG-PACK-RARE", "version": 12, "ext": "wav"})
	assert_eq(MusicDropIn.parse_file_id("registry.json"), {})
	assert_eq(MusicDropIn.parse_file_id("MUS-TOWN.mp3"), {}, "only OGG and WAV are delivery formats")
	assert_eq(MusicDropIn.parse_file_id("Crosspath theme.ogg"), {})
	assert_eq(MusicDropIn.parse_file_id("MUS-.ogg"), {})


func test_a_versioned_take_replaces_the_plain_file() -> void:
	var files: Array[String] = ["MUS-TOWN.ogg", "MUS-TOWN-FREED.ogg", "MUS-TOWN_v02.ogg", "MUS-TOWN_v03.wav", "STG-LEVEL.wav"]
	assert_eq(AudioRegistry.pick_source("MUS-TOWN", files, true), "MUS-TOWN_v03.wav", "the highest version wins, either format")
	assert_eq(AudioRegistry.pick_source("MUS-TOWN-FREED", files, true), "MUS-TOWN-FREED.ogg", "MUS-TOWN_vNN never matches another ID")
	assert_eq(AudioRegistry.pick_source("STG-LEVEL", files, false), "STG-LEVEL.wav")
	assert_eq(AudioRegistry.pick_source("MUS-DECK", files, true), "")


func test_loudnorm_json_is_read_from_ffmpeg_output() -> void:
	var measured: Dictionary = MusicDropIn.parse_loudnorm_json(LOUDNORM_OUTPUT)
	assert_almost_eq(float(measured["input_i"]), -20.96, 0.001)
	assert_almost_eq(float(measured["input_tp"]), -9.03, 0.001)
	assert_almost_eq(float(measured["input_lra"]), 10.9, 0.001)
	assert_almost_eq(float(measured["input_thresh"]), -31.62, 0.001)
	assert_almost_eq(float(measured["target_offset"]), 0.38, 0.001)
	assert_eq(MusicDropIn.parse_loudnorm_json("no json here"), {})
	assert_eq(MusicDropIn.parse_loudnorm_json("{\"input_i\" : \"-inf\"}"), {}, "a silent file has no usable measurement")


func test_second_pass_stays_linear_or_falls_back_to_a_plain_gain() -> void:
	var measured: Dictionary = MusicDropIn.parse_loudnorm_json(LOUDNORM_OUTPUT)
	var filter: String = MusicDropIn.second_pass_filter(measured, -20.0, -2.0)
	assert_true(filter.begins_with("loudnorm=I=-20"), filter)
	assert_true(filter.contains("measured_I=-20.96") and filter.contains("linear=true"), filter)
	assert_almost_eq(MusicDropIn.linear_gain_db(measured, -20.0, -2.0), 0.96, 0.001)
	# A peaky file: +6 dB would push the peak past -2 dBTP, so it gets the most gain the peak allows and lands under the target.
	var peaky: Dictionary = {"input_i": -26.0, "input_tp": -3.0, "input_lra": 8.0, "input_thresh": -36.0, "target_offset": 0.0}
	assert_almost_eq(MusicDropIn.linear_gain_db(peaky, -20.0, -2.0), 1.0, 0.001)
	assert_eq(MusicDropIn.second_pass_filter(peaky, -20.0, -2.0), "volume=1.00dB")
	assert_eq(MusicDropIn.second_pass_filter({}, -20.0, -2.0), "anull")


func test_wrap_jump_measures_the_first_against_the_last_second() -> void:
	var x: PackedFloat32Array = PackedFloat32Array()
	x.resize(300)
	for i: int in 300:
		x[i] = (1.0 if i < 100 else 0.1) * (1.0 if i % 2 == 0 else -1.0)
	assert_almost_eq(MusicDropIn.wrap_jump_db(x, 100), 20.0, 0.01)


func test_best_loop_end_finds_a_true_repeat() -> void:
	var rate: int = 200
	var x: PackedFloat32Array = _noise(rate * 20, 7)
	# The opening second comes back at 18 s: cutting the file there makes the wrap play what the music would have played anyway.
	for i: int in rate:
		x[18 * rate + i] = x[i]
	var found: Dictionary = MusicDropIn.best_loop_end(x, rate)
	assert_eq(int(found["end"]), 18 * rate)
	assert_true(bool(found["improves"]))
	assert_almost_eq(float(found["ncc"]), 1.0, 0.001)


func test_best_loop_end_never_cuts_without_a_repeat() -> void:
	var rate: int = 200
	var found: Dictionary = MusicDropIn.best_loop_end(_noise(rate * 20, 11), rate)
	assert_false(bool(found["improves"]), "unrelated material is not a seam")
	var short: Dictionary = MusicDropIn.best_loop_end(_noise(rate, 3), rate)
	assert_eq(int(short["end"]), rate, "a file too short to search keeps its length")
	assert_false(bool(short["improves"]))


func test_seam_frame_continues_frame_zero() -> void:
	var x: PackedFloat32Array = PackedFloat32Array()
	x.resize(40)
	for i: int in 40:
		x[i] = 0.9 if i % 2 == 0 else -0.9
	# Frames 0 and 1 (left, right): (0.5, -0.2) then (0.6, -0.1). Frame 12 holds (0.5, -0.2) after (0.4, -0.3): same value and slope.
	x[0] = 0.5
	x[1] = -0.2
	x[2] = 0.6
	x[3] = -0.1
	x[22] = 0.4
	x[23] = -0.3
	x[24] = 0.5
	x[25] = -0.2
	assert_eq(MusicDropIn.refine_seam_frame(x, 10, 5), 12)


func test_silence_runs_count_both_ends() -> void:
	var x: PackedFloat32Array = PackedFloat32Array([0.0, 0.0, 0.0005, 0.3, -0.2, 0.0, 0.0])
	assert_eq(MusicDropIn.silence_runs(x), [3, 2] as Array[int])
	assert_eq(MusicDropIn.silence_runs(PackedFloat32Array([0.0, 0.0])), [2, 0] as Array[int], "an all-silent file counts once")


func test_loop_choice() -> void:
	# Metadata inside the file wins (intro kept, loop restarts at the start frame).
	var explicit: Dictionary = MusicDropIn.choose_loop(480000, 96000, 432000, 0, 0, 0.0, {})
	assert_eq(explicit["trim_end"], 432000)
	assert_eq(explicit["loop_offset_frames"], 96000)
	assert_eq(explicit["reason"], "explicit loop points")
	# "Loop end = file length" (every Drive registry row) is no metadata: the silence is still trimmed.
	var whole: Dictionary = MusicDropIn.choose_loop(480000, 0, 480000, 1200, 1920, 0.0, {})
	assert_eq(whole["trim_start"], 1200)
	assert_eq(whole["trim_end"], 480000 - 1920)
	assert_eq(whole["loop_offset_frames"], 0)
	assert_true(str(whole["reason"]).contains("silence trimmed"))
	# A jumping wrap with a true repeat is re-seated; without one it is left alone and flagged for a listen (never faded).
	var reseated: Dictionary = MusicDropIn.choose_loop(480000, -1, -1, 0, 0, 8.0, {"end": 430000, "ncc": 0.8, "improves": true})
	assert_eq(reseated["trim_end"], 430000)
	assert_true(str(reseated["reason"]).contains("re-seated"))
	var kept: Dictionary = MusicDropIn.choose_loop(480000, -1, -1, 0, 0, -7.0, {"end": 430000, "ncc": 0.3, "improves": false})
	assert_eq(kept["trim_end"], 480000)
	assert_true(str(kept["reason"]).contains("listen"))
	var small_jump: Dictionary = MusicDropIn.choose_loop(480000, -1, -1, 0, 0, 3.0, {"end": 430000, "ncc": 0.9, "improves": true})
	assert_eq(small_jump["trim_end"], 480000, "a wrap that does not jump keeps the whole file")


func test_repaired_files_keep_their_measured_levels() -> void:
	# tools/music_fix.js (Oct 19) rebuilt these loops at -20 LUFS; the local levels apply while the file's MD5 matches.
	var local: Dictionary = AudioRegistry._local_levels()
	for id: String in ["MUS-BEEF-EXP", "MUS-BEEF-DUN-EXP", "MUS-BEEF-DUN-BATTLE", "MUS-BEEF-BOSS", "MUS-SHOP-MIREPOIX"]:
		assert_true(local.has(id), id)
		if local.has(id):
			assert_almost_eq(float((local[id] as Dictionary)["lufs"]), -20.0, 0.25, id)
			assert_lt(float((local[id] as Dictionary)["peak"]), AudioRegistry.PEAK_CEILING_DB, id)
		assert_almost_eq(AudioRegistry.entry(id).volume_db, 0.0, 0.15, "%s: no double gain on a normalised file" % id)
	assert_eq(AudioRegistry.entry("MUS-TOWN").loop_offset, 0.0, "full-file loops restart at 0")
