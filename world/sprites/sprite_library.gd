class_name SpriteLibrary
extends RefCounted
## The painted character frames made by tools/world_test_import.gd: assets/art/world_test/sprites/<CHAR>/<DIR>_<IDLE|TALK|WALK1..4>.png plus manifest.json
## (canvas size, figure height, relative height, directions, frames). Textures are loaded once and shared by every sprite of a character.

const FOLDER: String = "res://assets/art/world_test/sprites/"

static var _manifest: Dictionary = {}
static var _textures: Dictionary = {}


static func manifest() -> Dictionary:
	if _manifest.is_empty():
		var file: FileAccess = FileAccess.open(FOLDER + "manifest.json", FileAccess.READ)
		if file != null:
			_manifest = JSON.parse_string(file.get_as_text()) as Dictionary
	return _manifest


static func has_character(character: String) -> bool:
	return manifest().has(character)


static func info(character: String) -> Dictionary:
	return manifest().get(character, {}) as Dictionary


## Frame key ("FRONT_IDLE", "SIDE_WALK3", "FRONT_TALK") -> texture, loaded on first use.
static func frame(character: String, key: String) -> Texture2D:
	var path: String = "%s%s/%s.png" % [FOLDER, character, key]
	if not _textures.has(path):
		_textures[path] = load(path) as Texture2D
	return _textures[path] as Texture2D
