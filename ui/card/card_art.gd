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


static func has_art(card_id: String) -> bool:
	return ResourceLoader.exists(path_for(card_id))


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
