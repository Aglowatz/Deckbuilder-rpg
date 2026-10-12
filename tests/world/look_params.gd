class_name LookParams
extends RefCounted
## The live look settings of the World Look Test (docs/art/world_look_test.md): camera, tilt-shift, bloom, fog, grade and cloud speed, with the F1-F5 presets,
## the slider table of the tuning panel, and the "My Preset" data file (F6 loads it, the panel's Save button writes it).

const MY_PRESET_PATH: String = "res://data/art/world_look_my_preset.json"
const RECOMMENDED_PATH: String = "res://data/art/world_look_recommended.json"

## key, label, min, max, step, decimals.
const SLIDERS: Array[Dictionary] = [
	{"key": "pitch", "label": "Pitch (deg)", "min": 8.0, "max": 60.0, "step": 0.5},
	{"key": "distance", "label": "Distance (x zoom)", "min": 4.0, "max": 22.0, "step": 0.1},
	{"key": "fov", "label": "Field of view", "min": 18.0, "max": 70.0, "step": 0.5},
	{"key": "height", "label": "Camera height offset", "min": -2.0, "max": 10.0, "step": 0.1},
	{"key": "focus", "label": "Tilt-shift focus (0 top - 1 bottom)", "min": 0.15, "max": 0.9, "step": 0.01},
	{"key": "band", "label": "Focus band width", "min": 0.0, "max": 0.45, "step": 0.01},
	{"key": "blur_far", "label": "Blur far (top, px)", "min": 0.0, "max": 24.0, "step": 0.5},
	{"key": "blur_near", "label": "Blur near (bottom, px)", "min": 0.0, "max": 24.0, "step": 0.5},
	{"key": "bloom", "label": "Bloom intensity", "min": 0.0, "max": 2.0, "step": 0.01},
	{"key": "bloom_threshold", "label": "Bloom threshold", "min": 0.3, "max": 2.5, "step": 0.01},
	{"key": "glow_spread", "label": "Glow spread", "min": 0.0, "max": 1.0, "step": 0.01},
	{"key": "fog_density", "label": "Fog density", "min": 0.0, "max": 0.02, "step": 0.0005},
	{"key": "warmth", "label": "Colour warmth", "min": -1.0, "max": 1.5, "step": 0.01},
	{"key": "saturation", "label": "Saturation", "min": 0.4, "max": 1.7, "step": 0.01},
	{"key": "vignette", "label": "Vignette", "min": 0.0, "max": 0.9, "step": 0.01},
	{"key": "cloud_speed", "label": "Cloud speed", "min": 0.0, "max": 8.0, "step": 0.1},
]

## F5 "Recommended". The final tuned numbers are logged in docs/art/world_look_test.md.
const RECOMMENDED: Dictionary = {
	"name": "F5 Recommended", "pitch": 20.0, "distance": 7.5, "fov": 42.0, "height": 1.0,
	"focus": 0.6, "band": 0.12, "blur_far": 7.0, "blur_near": 6.0,
	"bloom": 0.55, "bloom_threshold": 1.05, "glow_spread": 0.5,
	"fog_density": 0.0035, "fog_color": "f2cfa4", "warmth": 0.35, "saturation": 1.1, "vignette": 0.28, "cloud_speed": 1.0,
}

## F1 - F4: the old character-test cameras, expressed in the same parameters (look-up converted to a height offset).
const OLD_PRESETS: Array[Dictionary] = [
	{"name": "F1 Current", "pitch": 53.27, "distance": 13.72, "fov": 38.0, "height": 0.0, "blur_far": 0.0, "blur_near": 0.0, "bloom": 0.0, "vignette": 0.0, "warmth": 0.0, "saturation": 1.0},
	{"name": "F2 Classic RPG", "pitch": 45.0, "distance": 10.0, "fov": 38.0, "height": 0.0, "blur_far": 0.0, "blur_near": 0.0, "bloom": 0.0, "vignette": 0.0, "warmth": 0.0, "saturation": 1.0},
	{"name": "F3 HD-2D", "pitch": 30.0, "distance": 7.4, "fov": 30.0, "height": 0.4, "blur_far": 9.0, "blur_near": 9.0, "band": 0.13, "focus": 0.55, "bloom": 0.9, "bloom_threshold": 0.75, "vignette": 0.0, "warmth": 0.0, "saturation": 1.0},
	{"name": "F4 Low and cinematic", "pitch": 20.0, "distance": 7.0, "fov": 44.0, "height": 0.85, "blur_far": 0.0, "blur_near": 0.0, "bloom": 0.0, "vignette": 0.0, "warmth": 0.0, "saturation": 1.0},
]


## A full parameter set: the Recommended values with `overrides` on top.
static func make(overrides: Dictionary = {}) -> Dictionary:
	var result: Dictionary = RECOMMENDED.duplicate()
	for key: Variant in overrides.keys():
		result[key] = overrides[key]
	return result


## Old presets keep the Recommended fog / sky; only camera and post differ, with the extras of the old preset off.
static func old_preset(index: int) -> Dictionary:
	var base: Dictionary = RECOMMENDED.duplicate()
	base["blur_far"] = 0.0
	base["blur_near"] = 0.0
	base["bloom"] = 0.0
	base["vignette"] = 0.0
	base["warmth"] = 0.0
	base["saturation"] = 1.0
	base["bloom_threshold"] = 1.0
	return make_from(base, OLD_PRESETS[index])


static func make_from(base: Dictionary, overrides: Dictionary) -> Dictionary:
	var result: Dictionary = base.duplicate()
	for key: Variant in overrides.keys():
		result[key] = overrides[key]
	return result


static func recommended() -> Dictionary:
	var file: FileAccess = FileAccess.open(RECOMMENDED_PATH, FileAccess.READ)
	if file != null:
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			return make_from(RECOMMENDED, parsed as Dictionary)
	return RECOMMENDED.duplicate()


static func load_my_preset() -> Dictionary:
	var file: FileAccess = FileAccess.open(MY_PRESET_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		var result: Dictionary = parsed as Dictionary
		result["name"] = "F6 My Preset"
		return make_from(recommended(), result)
	return {}


static func save_my_preset(values: Dictionary) -> Error:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(MY_PRESET_PATH.get_base_dir()))
	var file: FileAccess = FileAccess.open(MY_PRESET_PATH, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var clean: Dictionary = values.duplicate()
	clean.erase("name")
	file.store_string(JSON.stringify(clean, "\t"))
	return OK


## One line per value, the way the doc and the on-screen readout list them.
static func describe(values: Dictionary) -> String:
	var parts: PackedStringArray = []
	for slider: Dictionary in SLIDERS:
		var key: String = str(slider["key"])
		parts.append("%s %s" % [key, _fmt(float(values.get(key, 0.0)), float(slider["step"]))])
	parts.append("fog_color %s" % str(values.get("fog_color", "")))
	return ", ".join(parts)


static func _fmt(value: float, step: float) -> String:
	if step >= 0.5:
		return "%.1f" % value
	if step >= 0.05:
		return "%.2f" % value
	return "%.4f" % value
