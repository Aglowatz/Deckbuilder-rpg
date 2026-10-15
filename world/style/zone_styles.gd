class_name ZoneStyles
extends RefCounted
## The per-area style data of the Art Bible (docs/art/art_bible.md, docs/art/zone_styles.md): `data/zone_styles/<area>.json`.
## One file per area holds the time-of-day light (key + ambient), fog, colour grade, bloom, the palette, the material swap map (which kit
## surface a zone uses) and the tint values that recolour neutral kit textures (Layer 2 of G-08). Everything is optional: a missing key keeps
## the value of `StylePresets` / `data/art/zone_looks.json`.
##
## Hot reload (debug builds): `ZoneStyleWatcher` re-reads a changed file and re-applies light, fog, grade and tints to the running scene.
## Material swaps are read when buildings are built, so they apply at the next scene load.

const DIR: String = "res://data/zone_styles/"

## Style preset id (`StylePresets`) -> area id (file name). Variants of the Capital (dark, freed) are not listed: they keep their own look.
const PRESET_AREAS: Dictionary = {
	"town": "main_town",
	"start": "starting_forest",
	"gainlands": "gainlands",
	"dna": "dna",
	"buffet": "buffet",
	"heap": "heap",
	"capital_outskirts": "capital_outside",
	"capital_inside": "capital_inside",
	"capital_facade": "capital_inside",
	"lab": "pathology_lab",
	# Variants: kit swaps and tints follow the base area; their own light and fog stay as built.
	"capital_dark": "capital_outside",
	"capital_inside_dark": "capital_inside",
	"capital_freed": "capital_inside",
}

const VARIANTS: Array[String] = ["capital_dark", "capital_inside_dark", "capital_freed"]

const AREAS: Array[String] = [
	"main_town", "starting_forest", "gainlands", "dna", "buffet", "heap", "capital_outside", "capital_inside", "pathology_lab",
]

static var _cache: Dictionary = {}
## The area whose swaps and tints new kit materials take (set by a scene when it starts building).
static var current: String = ""
## Bumped on every reload so cached kit materials know to re-tint.
static var revision: int = 0


static func path_for(area: String) -> String:
	return "%s%s.json" % [DIR, area]


## The parsed style of `area` ({} when there is no file).
static func style(area: String) -> Dictionary:
	if area == "":
		return {}
	if _cache.has(area):
		return _cache[area] as Dictionary
	var result: Dictionary = {}
	var path: String = path_for(area)
	if FileAccess.file_exists(path):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Dictionary:
			result = parsed as Dictionary
	_cache[area] = result
	return result


static func reload() -> void:
	_cache.clear()
	revision += 1


static func area_for_preset(preset_id: StringName) -> String:
	return str(PRESET_AREAS.get(str(preset_id), ""))


## Makes `area` the one kit materials are swapped and tinted for. Returns true when it changed.
static func use_area(area: String) -> bool:
	if area == current:
		return false
	current = area
	revision += 1
	return true


static func use_preset(preset_id: StringName) -> void:
	use_area(area_for_preset(preset_id))


# ---- Palette, swaps and tints -------------------------------------------------------------------------------------------------------


static func palette(area: String = "") -> Array[Color]:
	var result: Array[Color] = []
	for entry: Variant in style(area if area != "" else current).get("palette", []) as Array:
		result.append(Color.html(str(entry)))
	return result


## The kit id a zone uses instead of `id` ("ENV-WALL-TIMBER" -> "ENV-WALL-PLANK"), or `id` itself.
static func swap(id: String) -> String:
	var swaps: Dictionary = style(current).get("material_swaps", {}) as Dictionary
	return str(swaps.get(id, id))


## The tint multiplied onto kit materials of `group` ("wall", "roof", "ground", "trim", "door", "window", "sign", "prop", "tree", "decal", "concept").
## A value is a colour string; `tint_strength` (default 1) blends it toward white so a zone can push its palette gently.
static func tint(group: String) -> Color:
	var data: Dictionary = style(current)
	var tints: Dictionary = data.get("tints", {}) as Dictionary
	if not tints.has(group):
		return Color.WHITE
	var strength: float = clampf(float(data.get("tint_strength", 1.0)), 0.0, 1.0)
	var color: Color = Color.html(str(tints[group]))
	return Color.WHITE.lerp(color, strength)


# ---- Preset overrides -----------------------------------------------------------------------------------------------------------------


## Applies the style file's light, fog and grade to a preset (a no-op for a preset without a file).
static func apply_to_preset(p: ZonePreset, preset_id: StringName) -> void:
	if str(preset_id) in VARIANTS:
		return
	var data: Dictionary = style(area_for_preset(preset_id))
	if data.is_empty():
		return
	var light: Dictionary = data.get("light", {}) as Dictionary
	if light.has("key_color"):
		p.sun_color = Color.html(str(light["key_color"]))
	if light.has("key_energy"):
		p.sun_energy = float(light["key_energy"])
	if light.has("key_pitch"):
		p.sun_pitch = float(light["key_pitch"])
	if light.has("key_yaw"):
		p.sun_yaw = float(light["key_yaw"])
	if light.has("ambient_color"):
		p.ambient_color = Color.html(str(light["ambient_color"]))
	if light.has("ambient_energy"):
		p.ambient_energy = float(light["ambient_energy"])
	var fog: Dictionary = data.get("fog", {}) as Dictionary
	if fog.has("color"):
		p.fog_color = Color.html(str(fog["color"]))
	if fog.has("density"):
		p.fog_density = float(fog["density"])
	var grade: Dictionary = data.get("grade", {}) as Dictionary
	if grade.has("saturation"):
		p.saturation = float(grade["saturation"])
	if grade.has("contrast"):
		p.contrast = float(grade["contrast"])


## The `look` block of the world look rig for this preset (warmth, saturation, vignette, bloom, fog), merged over the zone_looks mood.
static func look_overrides(preset_id: StringName) -> Dictionary:
	if str(preset_id) in VARIANTS:
		return {}
	var data: Dictionary = style(area_for_preset(preset_id))
	var result: Dictionary = {}
	if data.is_empty():
		return result
	var grade: Dictionary = data.get("grade", {}) as Dictionary
	if grade.has("warmth"):
		result["warmth"] = float(grade["warmth"])
	if grade.has("post_saturation"):
		result["saturation"] = float(grade["post_saturation"])
	var fog: Dictionary = data.get("fog", {}) as Dictionary
	if fog.has("color"):
		result["fog_color"] = str(fog["color"]).trim_prefix("#")
	if fog.has("density"):
		result["fog_density"] = float(fog["density"])
	var bloom: Dictionary = data.get("bloom", {}) as Dictionary
	if bloom.has("intensity"):
		result["bloom"] = float(bloom["intensity"])
	if bloom.has("threshold"):
		result["bloom_threshold"] = float(bloom["threshold"])
	if data.has("vignette"):
		result["vignette"] = float(data["vignette"])
	return result
