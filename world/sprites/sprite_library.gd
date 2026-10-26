class_name SpriteLibrary
extends RefCounted
## The painted character frames made by tools/world_test_import.gd: assets/art/world_test/sprites/<CHAR>/<DIR>_<IDLE|TALK|WALK1..4>.png plus manifest.json
## (canvas size, figure height, relative height, directions, frames, and from tools/sprite_anchors.gd the head anchor of every frame and the cloak hue).
## Textures are loaded once and shared by every sprite of a character.
##
## Cosmetics (tools/import_cosmetics.sh): a cloak is a whole alternate sprite set, the character `PLAYER_CLOAK_<NAME>` (listed in cosmetics_manifest.json, same folder layout);
## a hat is five images, assets/art/cosmetics/hats/<NAME>/<FRONT|FRONTSIDE|SIDE|BACKSIDE|BACK>.png, with its fit in assets/art/cosmetics/hats/fit.json.

const FOLDER: String = "res://assets/art/world_test/sprites/"
const COSMETICS_MANIFEST: String = "res://assets/art/world_test/sprites/cosmetics_manifest.json"
const DEFAULT_HAT_FOLDER: String = "res://assets/art/cosmetics/hats/"
const CLOAK_PREFIX: String = "PLAYER_CLOAK_"
const ICON_FOLDER: String = "res://assets/art/cosmetics/icons/"
const HAT_DIRS: Array[String] = ["FRONT", "FRONTSIDE", "SIDE", "BACKSIDE", "BACK"]

static var _manifest: Dictionary = {}
static var _textures: Dictionary = {}
static var _hat_fit: Dictionary = {}
static var _hat_fit_loaded: bool = false
static var _hat_fit_auto: Dictionary = {}
## Where the hat images live (tests point it at a temporary folder).
static var hat_folder: String = _default_hat_folder()


static func manifest() -> Dictionary:
	if _manifest.is_empty():
		_manifest = _read_json(FOLDER + "manifest.json")
		var extra: Dictionary = _read_json(COSMETICS_MANIFEST)
		for key: Variant in extra.keys():
			_manifest[key] = extra[key]
	return _manifest


## Forgets everything read so far (tests and the importers write new files).
static func reset() -> void:
	_manifest = {}
	_textures = {}
	_hat_fit = {}
	_hat_fit_auto = {}
	_hat_fit_loaded = false
	hat_folder = _default_hat_folder()


## `SPRITE_HAT_FOLDER` (a dev tool: tools/fake_hats.gd draws stand-in hats to check the placement) points the hats somewhere else.
static func _default_hat_folder() -> String:
	var override: String = OS.get_environment("SPRITE_HAT_FOLDER")
	return override if override != "" else DEFAULT_HAT_FOLDER


## Performance pass Oct 25, Part 4: moving to another area drops every cached frame but the hero's (the PLAYER sets and the cloaks, seen
## everywhere): the NPC frames of each area visited stayed for the session (64 -> 256 textures, about 80 MB of video memory after a tour).
## A frame still drawn by a live sprite stays in memory through its material; the next area loads its own on demand. Returns how many went.
static func release_area_frames() -> int:
	var dropped: int = 0
	for path: Variant in _textures.keys():
		if not str(path).contains("/PLAYER"):
			_textures.erase(path)
			dropped += 1
	return dropped


## A texture from an imported resource, or (not imported yet, a test folder, a fresh importer run) straight from the PNG file. Null when neither exists.
static func _texture(path: String) -> Texture2D:
	if _textures.has(path):
		return _textures[path] as Texture2D
	var texture: Texture2D = null
	if ResourceLoader.exists(path):
		texture = load(path) as Texture2D
	elif FileAccess.file_exists(path):
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path) if path.begins_with("res://") else path)
		if image != null:
			image.generate_mipmaps()
			texture = ImageTexture.create_from_image(image)
	_textures[path] = texture
	return texture


static func _read_json(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed as Dictionary if parsed is Dictionary else {}


static func has_character(character: String) -> bool:
	return manifest().has(character)


static func info(character: String) -> Dictionary:
	return manifest().get(character, {}) as Dictionary


## Frame key ("FRONT_IDLE", "SIDE_WALK3", "FRONT_TALK") -> texture, loaded on first use. Null when the file does not exist.
static func frame(character: String, key: String) -> Texture2D:
	return _texture("%s%s/%s.png" % [FOLDER, character, key])


## Graphics Tier 1: the frame's generated normal map (tools/sprite_normals.gd, <KEY>_n.png), or null when none was generated.
static func normal_frame(character: String, key: String) -> Texture2D:
	return _texture("%s%s/%s_n.png" % [FOLDER, character, key])


## The normal map of a hat image, or null.
static func hat_normal(art_name: String, dir_name: String) -> Texture2D:
	return _texture("%s%s/%s_n.png" % [hat_folder, art_name, dir_name])


## `frame`, falling back to the same frame of the default character (a cloak set that lacks a frame never shows a hole).
static func frame_or_default(character: String, key: String, default_character: String = "PLAYER") -> Texture2D:
	var texture: Texture2D = frame(character, key)
	if texture == null and character != default_character:
		texture = frame(default_character, key)
	return texture


## The head anchor of a frame: [x, y_top, head_width] in canvas pixels (see SpriteAnchors), or an empty array.
static func head_anchor(character: String, key: String) -> Array:
	var head: Dictionary = info(character).get("head", {}) as Dictionary
	return head.get(key, []) as Array


## Where a hat sits in this frame: the tracked head (`hat_anchor`, tools/sprite_anchors.gd: one head width per direction, the walk's bob and sway) or, for a
## set measured before Apparel Part 2, the per-frame head anchor.
static func hat_anchor(character: String, key: String) -> Array:
	var tracked: Dictionary = info(character).get("hat_anchor", {}) as Dictionary
	var anchor: Array = tracked.get(key, []) as Array
	return anchor if anchor.size() >= 3 else head_anchor(character, key)


## The cloak hue of a character: [hue 0..1, half width], or an empty array.
static func cloak_hue(character: String) -> Array:
	return info(character).get("cloak_hue", []) as Array


# ---- Cosmetics -------------------------------------------------------------------------------------------------------------------


## The sprite character a cloak id draws ("PLAYER" for the default cloak or an unknown/missing one).
static func cloak_character(art_name: String) -> String:
	if art_name == "":
		return "PLAYER"
	var id: String = CLOAK_PREFIX + art_name
	return id if has_cloak(art_name) else "PLAYER"


## True when the art of this cloak was imported with every direction (idle) and walk set the default hero has.
static func has_cloak(art_name: String) -> bool:
	var entry: Dictionary = info(CLOAK_PREFIX + art_name)
	if entry.is_empty():
		return false
	var base: Dictionary = info("PLAYER")
	for dir_name: Variant in base.get("dirs", []) as Array:
		if not (entry.get("dirs", []) as Array).has(dir_name):
			return false
	return true


## The shop / wardrobe icon of an item (tools/import_cosmetics.sh makes it from the hat's FRONT view or the cloak set's FRONT_IDLE), null before the art is imported.
static func item_icon(is_hat: bool, art_name: String) -> Texture2D:
	if art_name == "":
		return null
	return _texture("%s%s_%s.png" % [ICON_FOLDER, "HAT" if is_hat else "CLOAK", art_name])


static func has_hat(art_name: String) -> bool:
	for dir_name: String in HAT_DIRS:
		var path: String = "%s%s/%s.png" % [hat_folder, art_name, dir_name]
		if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
			return false
	return true


static func hat_texture(art_name: String, dir_name: String) -> Texture2D:
	return _texture("%s%s/%s.png" % [hat_folder, art_name, dir_name])


## How a hat sits: `width` (hat width as a multiple of the head width, default 1.5), `sink` (how far the hat's bottom edge dips below the top of the head, in head widths,
## default 0.3), `dx` / `dy` (extra nudge in head widths), `scale` (overall). Per hat from fit.json; missing entries take the defaults.
static func hat_fit(art_name: String, dir_name: String = "") -> Dictionary:
	if not _hat_fit_loaded:
		_hat_fit = _read_json(hat_folder + "fit.json")
		_hat_fit_auto = _read_json(hat_folder + "fit_auto.json")
		_hat_fit_loaded = true
	var result: Dictionary = {"width": 1.5, "sink": 0.3, "dx": 0.0, "dy": 0.0, "scale": 1.0}
	var defaults: Dictionary = _hat_fit.get("default", {}) as Dictionary
	for key: Variant in defaults.keys():
		result[key] = defaults[key]
	# Apparel Part 2: the importer's fit from the hat sheet (fit_auto.json, rewritten on every import) comes first; the hand-tuned fit.json wins over it.
	var auto: Dictionary = _hat_fit_auto.get(art_name, {}) as Dictionary
	for key: Variant in auto.keys():
		result[key] = auto[key]
	var own: Dictionary = _hat_fit.get(art_name, {}) as Dictionary
	for key: Variant in own.keys():
		result[key] = own[key]
	# A view drawn narrower or wider than the front on the same sheet keeps that proportion: width x ratio_<DIR> (unless width_<DIR> is set by hand, below).
	if dir_name != "" and result.has("ratio_" + dir_name):
		result["width"] = float(result["width"]) * float(result["ratio_" + dir_name])
	# Per-direction overrides: "width_SIDE": 1.3, "sink_BACK": 0.1, ... (any of width, sink, dx, dy, scale). The importer's (sink_<DIR>) count only while
	# fit.json sets neither that direction nor the whole value by hand.
	if dir_name != "":
		for part: String in ["width", "sink", "dx", "dy", "scale"]:
			var special: String = "%s_%s" % [part, dir_name]
			if own.has(special):
				result[part] = own[special]
			elif auto.has(special) and not own.has(part):
				result[part] = auto[special]
	return result
