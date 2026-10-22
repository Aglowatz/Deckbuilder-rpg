class_name CardArt
extends RefCounted
## Card and token art, loaded by convention: `assets/art/cards/<CardID>.webp` (tokens `<TokenID>.webp`). A card without an image
## uses the placeholder (see `CardView`). Art is 2:3 (768x1152 after `tools/import_art`); `square()` is the centre-upper square crop
## used by the deck builder and the pack reveal. Docs: docs/art/art_pipeline.md.

const DIR: String = "res://assets/art/cards/"
const EXTENSION: String = "webp"
const ASPECT: float = 2.0 / 3.0

static var _cache: Dictionary = {}
## Overnight Oct 17 (Phase 2, performance): 256x384 copies for screens that show many small cards (tools/card_thumbs.js).
const THUMB_DIR: String = "res://assets/art/cards_thumb/"
static var _thumbs: Dictionary = {}


## The small copy of a card's art (a ninth of the pixels), or the full art when there is no thumbnail.
static func thumb(card_id: String) -> Texture2D:
	if _thumbs.has(card_id):
		return _thumbs[card_id] as Texture2D
	var path: String = "%s%s.%s" % [THUMB_DIR, card_id, EXTENSION]
	var loaded: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else texture(card_id)
	_thumbs[card_id] = loaded
	return loaded


static func path_for(card_id: String) -> String:
	return "%s%s.%s" % [DIR, card_id, EXTENSION]


static var _has_art_cache: Dictionary = {}


## Remembered per card (a file check each time was a measurable part of building every card view).
static func has_art(card_id: String) -> bool:
	var known: Variant = _has_art_cache.get(card_id)
	if known == null:
		known = ResourceLoader.exists(path_for(card_id))
		_has_art_cache[card_id] = known
	return bool(known)


## The full 2:3 art, or null when this card has no art yet (use the placeholder).
static func texture(card_id: String) -> Texture2D:
	if _cache.has(card_id):
		return _cache[card_id] as Texture2D
	var loaded: Texture2D = null
	if has_art(card_id):
		loaded = load(path_for(card_id)) as Texture2D
	_cache[card_id] = loaded
	return loaded


## A square crop (full width, from 8% down) of the art for small thumbnails, or null.
static func square(card_id: String) -> Texture2D:
	var full: Texture2D = texture(card_id)
	if full == null:
		return null
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = full
	var width: float = full.get_width()
	atlas.region = Rect2(0.0, full.get_height() * 0.08, width, minf(width, full.get_height() * 0.92))
	return atlas


## The art cropped to its upper-middle (the compact battlefield look), or null: the middle 80% of the width from 4% down.
static func compact(card_id: String) -> Texture2D:
	var full: Texture2D = texture(card_id)
	if full == null:
		return null
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = full
	var width: float = full.get_width()
	var height: float = full.get_height()
	atlas.region = Rect2(width * 0.1, height * 0.04, width * 0.8, height * 0.8)
	return atlas


static func clear_cache() -> void:
	_cache.clear()


# ---- Art crop (UI + economy fixes Oct 22, Part 3) -------------------------------------------------------------------------------
## The card art style keeps the subject's head and key details in the upper 60% of the painting with the top 10% clear, so a window
## that is not the whole 2:3 painting is cut around a focus point near the top, not around the centre (heads used to be cut).
## `data/art/card_focus.json` overrides it per card: card id -> {"focus": 0-1 (the painting's height to keep in view, 0 = top),
## "zoom": >= 1 (extra zoom on top of the display's own)}. Contact sheets: tools/card_crop_sheet.gd.

const FOCUS_PATH: String = "res://data/art/card_focus.json"
## The default focus: just above the middle of the upper 60% (the head and the face of a portrait).
const DEFAULT_FOCUS: float = 0.3
static var _focus: Dictionary = {}
static var _focus_loaded: bool = false


## {"focus": float, "zoom": float} for `card_id` (the default when the card has no override).
static func focus_for(card_id: String) -> Dictionary:
	if not _focus_loaded:
		_focus_loaded = true
		var text: String = FileAccess.get_file_as_string(FOCUS_PATH) if FileAccess.file_exists(FOCUS_PATH) else ""
		var parsed: Variant = JSON.parse_string(text) if not text.is_empty() else null
		if parsed is Dictionary:
			for key: Variant in (parsed as Dictionary).keys():
				if str(key).begins_with("_"):
					continue
				var entry: Variant = (parsed as Dictionary)[key]
				if entry is Dictionary:
					_focus[str(key)] = entry
	var override: Dictionary = _focus.get(card_id, {}) as Dictionary
	return {"focus": clampf(float(override.get("focus", DEFAULT_FOCUS)), 0.0, 1.0), "zoom": maxf(1.0, float(override.get("zoom", 1.0)))}


## The part of a `texture_size` picture shown in a window of `window` aspect: as large as fits (times 1/`zoom`), centred
## horizontally, and placed vertically so the painting's `focus` height sits in the middle of the window when it can (clamped
## to the picture: a low focus keeps the top edge).
static func crop_region(texture_size: Vector2, window: Vector2, focus: float, zoom: float = 1.0) -> Rect2:
	if texture_size.x <= 0.0 or texture_size.y <= 0.0 or window.x <= 0.0 or window.y <= 0.0:
		return Rect2(Vector2.ZERO, texture_size)
	var aspect: float = window.x / window.y
	var width: float = texture_size.x
	var height: float = width / aspect
	if height > texture_size.y:
		height = texture_size.y
		width = height * aspect
	width /= maxf(zoom, 1.0)
	height /= maxf(zoom, 1.0)
	var x: float = (texture_size.x - width) * 0.5
	var y: float = clampf(focus * texture_size.y - height * 0.5, 0.0, texture_size.y - height)
	return Rect2(x, y, width, height)


## `card_id`'s art cut for a window of `window` pixels (the thumbnail copy when `small`), with the card's focus and `zoom` times
## its own zoom; null when the card has no art.
static func cropped(card_id: String, window: Vector2, zoom: float = 1.0, small: bool = false) -> Texture2D:
	var full: Texture2D = thumb(card_id) if small else texture(card_id)
	if full == null:
		return null
	var focus: Dictionary = focus_for(card_id)
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = full
	atlas.region = crop_region(Vector2(full.get_width(), full.get_height()), window, float(focus["focus"]), zoom * float(focus["zoom"]))
	return atlas
