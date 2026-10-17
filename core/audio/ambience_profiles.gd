class_name AmbienceProfiles
extends RefCounted
## What every place sounds like when nothing happens (docs/audio/sound_direction.md, "Ambience"): looping beds plus randomised one-shots placed in the
## world around the listener, and the place's acoustics. `AmbienceManager` plays them; scenes only name the profile (`Audio.set_ambience`).
##
## A profile: `beds` (each `set`, `db`, optional `param`: its level follows `AmbienceManager.set_param`), `oneshots` (each `set`, `every` [min, max]
## seconds, `db`, `dist` [min, max] metres from the listener, `up` [min, max] metres above it, optional `param`: fires only that often), `acoustic`
## (an `AcousticProfiles` name). A bed shared by two profiles keeps playing across the change; the others crossfade.

const PROFILES: Dictionary = {
	"forest": {
		"acoustic": "forest",
		"beds": [{"set": "amb/forest_bed", "db": 0.0}],
		"oneshots": [
			{"set": "amb/bird_song", "every": [4.0, 11.0], "db": -6.0, "dist": [8.0, 22.0], "up": [3.0, 9.0]},
			{"set": "amb/leaves_gust", "every": [10.0, 22.0], "db": -8.0, "dist": [5.0, 14.0], "up": [2.0, 6.0]},
			{"set": "amb/woodpecker", "every": [25.0, 60.0], "db": -12.0, "dist": [18.0, 30.0], "up": [4.0, 10.0]},
		],
	},
	"town": {
		"acoustic": "stone_plaza",
		"beds": [{"set": "amb/town_bed", "db": 0.0}],
		"oneshots": [
			{"set": "amb/bird_song", "every": [5.0, 12.0], "db": -8.0, "dist": [10.0, 24.0], "up": [3.0, 9.0]},
			{"set": "amb/chatter", "every": [7.0, 16.0], "db": -10.0, "dist": [10.0, 20.0], "up": [0.5, 1.5]},
			{"set": "amb/wind_chime", "every": [12.0, 28.0], "db": -12.0, "dist": [6.0, 14.0], "up": [2.0, 4.0]},
			{"set": "amb/town_bell", "every": [70.0, 140.0], "db": -16.0, "dist": [28.0, 40.0], "up": [10.0, 16.0]},
		],
	},
	"gainlands": {
		"acoustic": "open_meadow",
		"beds": [{"set": "amb/meadow_wind", "db": 0.0}],
		"oneshots": [
			{"set": "amb/grunt", "every": [5.0, 12.0], "db": -10.0, "dist": [14.0, 26.0], "up": [0.5, 1.5]},
			{"set": "amb/cheer", "every": [16.0, 34.0], "db": -14.0, "dist": [20.0, 32.0], "up": [0.5, 2.0]},
			{"set": "amb/weights_clank", "every": [6.0, 14.0], "db": -14.0, "dist": [12.0, 24.0], "up": [0.5, 1.5]},
			{"set": "amb/bird_song", "every": [9.0, 20.0], "db": -12.0, "dist": [12.0, 26.0], "up": [4.0, 10.0]},
		],
	},
	"dna": {
		"acoustic": "office_halls",
		"beds": [{"set": "amb/office_hum", "db": 0.0}, {"set": "amb/clock_tick", "db": -12.0}],
		"oneshots": [
			{"set": "amb/typewriter", "every": [6.0, 14.0], "db": -12.0, "dist": [10.0, 22.0], "up": [0.5, 2.0]},
			{"set": "amb/stamp_far", "every": [5.0, 12.0], "db": -12.0, "dist": [10.0, 22.0], "up": [0.5, 2.0]},
			{"set": "amb/whisper", "every": [14.0, 30.0], "db": -14.0, "dist": [6.0, 14.0], "up": [1.0, 3.0]},
			{"set": "amb/paper_shuffle", "every": [9.0, 20.0], "db": -14.0, "dist": [8.0, 16.0], "up": [0.5, 1.5]},
		],
	},
	"buffet": {
		"acoustic": "kitchen",
		"beds": [{"set": "amb/kitchen_bed", "db": 0.0}, {"set": "amb/sizzle_bed", "db": -8.0}],
		"oneshots": [
			{"set": "amb/pot_clink", "every": [3.0, 8.0], "db": -10.0, "dist": [8.0, 20.0], "up": [0.5, 2.0]},
			{"set": "amb/gravy_bubble", "every": [5.0, 11.0], "db": -10.0, "dist": [6.0, 16.0], "up": [0.0, 1.0]},
			{"set": "amb/kitchen_bell", "every": [30.0, 70.0], "db": -14.0, "dist": [16.0, 28.0], "up": [1.0, 3.0]},
		],
	},
	"heap": {
		"acoustic": "wetlands",
		"beds": [
			{"set": "amb/crickets_bed", "db": 0.0},
			{"set": "amb/eerie_drone", "db": -2.0, "param": "corruption"},
		],
		"oneshots": [
			{"set": "amb/goat", "every": [16.0, 40.0], "db": -12.0, "dist": [14.0, 28.0], "up": [0.5, 3.0]},
			{"set": "amb/windmill_creak", "every": [9.0, 20.0], "db": -12.0, "dist": [14.0, 26.0], "up": [4.0, 10.0]},
			{"set": "amb/junk_rustle", "every": [6.0, 14.0], "db": -12.0, "dist": [5.0, 12.0], "up": [0.0, 1.0]},
			{"set": "amb/frog", "every": [10.0, 24.0], "db": -14.0, "dist": [10.0, 22.0], "up": [0.0, 0.5]},
			{"set": "amb/rot_pulse", "every": [5.0, 9.0], "db": -6.0, "dist": [10.0, 18.0], "up": [0.0, 2.0], "param": "corruption"},
		],
	},
	"capital_out": {
		"acoustic": "wasteland",
		"beds": [{"set": "amb/waste_wind", "db": 0.0}, {"set": "amb/ash_hiss", "db": -10.0}],
		"oneshots": [
			{"set": "amb/rift_crackle", "every": [6.0, 14.0], "db": -12.0, "dist": [14.0, 30.0], "up": [1.0, 5.0]},
			{"set": "amb/debris_creak", "every": [12.0, 28.0], "db": -14.0, "dist": [10.0, 22.0], "up": [0.5, 3.0]},
			{"set": "amb/crow", "every": [24.0, 60.0], "db": -16.0, "dist": [20.0, 34.0], "up": [6.0, 14.0]},
		],
	},
	"capital_in": {
		"acoustic": "perfect_plaza",
		"beds": [{"set": "amb/perfect_quiet", "db": 0.0}],
		"oneshots": [
			{"set": "amb/fountain_splash", "every": [4.0, 7.0], "db": -14.0, "dist": [12.0, 24.0], "up": [0.5, 1.5]},
			{"set": "amb/loudspeaker", "every": [45.0, 90.0], "db": -12.0, "dist": [24.0, 36.0], "up": [8.0, 14.0]},
			{"set": "amb/perfect_bird", "every": [12.0, 12.5], "db": -16.0, "dist": [14.0, 20.0], "up": [4.0, 8.0]},
		],
	},
	# The four Capital districts layer their state over the inside: broken (failed service) or restored (the Path's life back).
	"capital_transit_broken": {"base": "capital_in", "beds": [{"set": "amb/dead_machine", "db": -6.0}], "oneshots": [{"set": "amb/metal_groan", "every": [8.0, 18.0], "db": -12.0, "dist": [8.0, 18.0], "up": [1.0, 4.0]}]},
	"capital_transit_restored": {"base": "capital_in", "beds": [{"set": "amb/machine_hum", "db": -6.0}], "oneshots": [{"set": "amb/weights_clank", "every": [5.0, 12.0], "db": -12.0, "dist": [10.0, 20.0], "up": [0.5, 1.5]}, {"set": "amb/cheer", "every": [20.0, 40.0], "db": -16.0, "dist": [16.0, 26.0], "up": [0.5, 2.0]}]},
	"capital_hungry_broken": {"base": "capital_in", "beds": [], "oneshots": [{"set": "amb/paste_squelch", "every": [9.0, 20.0], "db": -12.0, "dist": [8.0, 16.0], "up": [0.5, 1.5]}, {"set": "amb/stomach", "every": [18.0, 36.0], "db": -16.0, "dist": [6.0, 12.0], "up": [0.5, 1.5]}]},
	"capital_hungry_restored": {"base": "capital_in", "beds": [{"set": "amb/sizzle_bed", "db": -10.0}], "oneshots": [{"set": "amb/pot_clink", "every": [4.0, 10.0], "db": -12.0, "dist": [8.0, 18.0], "up": [0.5, 2.0]}, {"set": "amb/chatter", "every": [8.0, 16.0], "db": -12.0, "dist": [10.0, 20.0], "up": [0.5, 1.5]}]},
	"capital_grave_broken": {"base": "capital_in", "beds": [], "oneshots": [{"set": "amb/whisper", "every": [8.0, 18.0], "db": -12.0, "dist": [6.0, 14.0], "up": [1.0, 3.0]}, {"set": "amb/paper_flutter", "every": [9.0, 20.0], "db": -14.0, "dist": [5.0, 12.0], "up": [1.0, 3.0]}]},
	"capital_grave_restored": {"base": "capital_in", "beds": [], "oneshots": [{"set": "amb/bird_song", "every": [8.0, 18.0], "db": -12.0, "dist": [10.0, 22.0], "up": [3.0, 8.0]}, {"set": "amb/wind_chime", "every": [12.0, 26.0], "db": -14.0, "dist": [6.0, 14.0], "up": [2.0, 4.0]}]},
	"capital_reek_broken": {"base": "capital_in", "beds": [{"set": "amb/flies", "db": -12.0}], "oneshots": [{"set": "amb/junk_rustle", "every": [6.0, 14.0], "db": -12.0, "dist": [5.0, 12.0], "up": [0.0, 1.0]}]},
	"capital_reek_restored": {"base": "capital_in", "beds": [{"set": "amb/crickets_bed", "db": -10.0}], "oneshots": [{"set": "amb/bird_song", "every": [8.0, 18.0], "db": -12.0, "dist": [10.0, 22.0], "up": [3.0, 8.0]}, {"set": "amb/frog", "every": [12.0, 26.0], "db": -14.0, "dist": [8.0, 18.0], "up": [0.0, 0.5]}]},
	# The whole city once Primm has fallen: the perfect quiet breaks into a living town.
	"capital_restored": {
		"acoustic": "stone_plaza",
		"beds": [{"set": "amb/town_bed", "db": -3.0}],
		"oneshots": [
			{"set": "amb/bird_song", "every": [6.0, 14.0], "db": -10.0, "dist": [10.0, 24.0], "up": [3.0, 9.0]},
			{"set": "amb/chatter", "every": [7.0, 15.0], "db": -10.0, "dist": [10.0, 20.0], "up": [0.5, 1.5]},
			{"set": "amb/fountain_splash", "every": [5.0, 11.0], "db": -14.0, "dist": [10.0, 20.0], "up": [0.5, 1.5]},
		],
	},
	# Dungeon node maps and menus: no bed.
	"none": {"acoustic": "dry", "beds": [], "oneshots": []},
}


static func has(profile_name: String) -> bool:
	return PROFILES.has(profile_name)


## A profile with its `base` merged in (the base's beds and one-shots first, then its own), and the acoustics of the base when it names none.
static func resolved(profile_name: String) -> Dictionary:
	var own: Dictionary = PROFILES.get(profile_name, PROFILES["none"]) as Dictionary
	if not own.has("base"):
		return own
	var base: Dictionary = resolved(str(own["base"]))
	var beds: Array = (base.get("beds", []) as Array).duplicate()
	beds.append_array(own.get("beds", []) as Array)
	var oneshots: Array = (base.get("oneshots", []) as Array).duplicate()
	oneshots.append_array(own.get("oneshots", []) as Array)
	return {"acoustic": str(own.get("acoustic", base.get("acoustic", "dry"))), "beds": beds, "oneshots": oneshots}


## Every set any profile uses (the verify pass checks each has files).
static func all_sets() -> Array[String]:
	var result: Array[String] = []
	for profile_name: Variant in PROFILES.keys():
		var profile: Dictionary = PROFILES[profile_name] as Dictionary
		for key: String in ["beds", "oneshots"]:
			for entry: Variant in profile.get(key, []) as Array:
				var set_name: String = str((entry as Dictionary).get("set", ""))
				if not result.has(set_name):
					result.append(set_name)
	result.sort()
	return result
