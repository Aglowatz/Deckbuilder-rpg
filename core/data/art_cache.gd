class_name ArtCache
extends RefCounted
## Size pass Nov 3 (Part 5): one bounded, least-recently-used cache behind the big 2D art loaders (UiArt, KeyArt, Portraits, CardArt,
## Battleboards, MapArt, Bestiary pictures). Before it, each loader kept every picture it had ever loaded for the whole session: a long
## session held hundreds of card paintings (3.5 MB each decoded) and every portrait, still and vendor stage it had shown.
##
## `fetch(group, key, loader)` returns the cached texture or calls `loader` (a Callable returning Texture2D or null), remembers the
## result and evicts the least recently used entries when the budget is passed. Missing art (null) is remembered too, without cost, so a
## screen never re-checks the disk for a picture that does not exist. Evicting drops only this cache's reference: a texture a live
## screen still shows stays alive until that screen closes (Godot frees it with its last reference), and a later fetch loads it again.
##
## The budget follows the quality preset (`Settings` sets `budget_mb` at start and when the preset changes); tests and tools may set it.
## `forget_group` is what AreaCaches calls for the per-area groups (zone banners, boards, maps, loading paintings, vendor stages).

## Budget per quality preset (MB of decoded texture memory held by this cache), indexed by GraphicsQuality.Level: Low, Medium, High
## (the Low-end preset of Part 6 is a Low with `GraphicsQuality.low_end` set and takes LOW_END_MB).
const BUDGET_MB: Array[int] = [160, 256, 512]
const LOW_END_MB: int = 96
const DEFAULT_BUDGET_MB: int = 256

static var budget_mb: int = DEFAULT_BUDGET_MB

class Entry extends RefCounted:
	var texture: Texture2D
	var bytes: int = 0
	var group: StringName
	var tick: int = 0

## full key ("group/key") -> Entry
static var _entries: Dictionary = {}
## full keys of art that does not exist (no texture, no cost), per group
static var _missing: Dictionary = {}
static var _bytes: int = 0
static var _tick: int = 0
## counters for the memory probe and tests
static var loads: int = 0
static var evictions: int = 0


static func budget_for_level(level: int, low_end: bool = false) -> int:
	if low_end:
		return LOW_END_MB
	return BUDGET_MB[clampi(level, 0, BUDGET_MB.size() - 1)]


static func fetch(group: StringName, key: String, loader: Callable) -> Texture2D:
	var full: String = "%s/%s" % [group, key]
	var entry: Entry = _entries.get(full) as Entry
	if entry != null:
		_tick += 1
		entry.tick = _tick
		return entry.texture
	if _missing.has(full):
		return null
	var texture: Texture2D = loader.call() as Texture2D
	put(group, key, texture)
	return texture


## Remembers a texture loaded elsewhere (the warmup's loader threads); a null marks the art as missing.
static func put(group: StringName, key: String, texture: Texture2D) -> void:
	var full: String = "%s/%s" % [group, key]
	if texture == null:
		_missing[full] = true
		return
	loads += 1
	var old: Entry = _entries.get(full) as Entry
	if old != null:
		_bytes -= old.bytes
	var entry: Entry = Entry.new()
	entry.texture = texture
	entry.bytes = bytes_of(texture)
	entry.group = group
	_tick += 1
	entry.tick = _tick
	_entries[full] = entry
	_bytes += entry.bytes
	_evict(full)


static func has(group: StringName, key: String) -> bool:
	return _entries.has("%s/%s" % [group, key])


## True when the key was looked up before (a texture is held, or the art is known to be missing).
static func known(group: StringName, key: String) -> bool:
	var full: String = "%s/%s" % [group, key]
	return _entries.has(full) or _missing.has(full)


## Drops every entry of a group (an area's own pictures when the player leaves it; a re-import in the art tools). Returns how many.
static func forget_group(group: StringName) -> int:
	var dropped: int = 0
	for full: String in _entries.keys():
		var entry: Entry = _entries[full] as Entry
		if entry.group == group:
			_bytes -= entry.bytes
			_entries.erase(full)
			dropped += 1
	for full: String in _missing.keys():
		if full.begins_with("%s/" % group):
			_missing.erase(full)
	return dropped


static func reset() -> void:
	_entries = {}
	_missing = {}
	_bytes = 0
	loads = 0
	evictions = 0


static func bytes_held() -> int:
	return _bytes


static func count() -> int:
	return _entries.size()


## Decoded size of a texture as the GPU holds it (compressed formats a byte or half a byte a pixel, plus a third for mipmaps; everything
## else four bytes a pixel). An estimate for the budget, not an accounting.
static func bytes_of(texture: Texture2D) -> int:
	if texture == null:
		return 0
	if texture is AtlasTexture:
		return 0  # a window onto another texture that is counted on its own
	var size: Vector2 = texture.get_size()
	var pixels: float = maxf(size.x, 1.0) * maxf(size.y, 1.0)
	var per_pixel: float = 4.0
	var mips: float = 1.0
	if texture.has_method("get_format"):
		var format: int = int(texture.call("get_format"))
		match format:
			Image.FORMAT_L8, Image.FORMAT_R8: per_pixel = 1.0
			Image.FORMAT_LA8, Image.FORMAT_RG8, Image.FORMAT_RGBA4444, Image.FORMAT_RGB565: per_pixel = 2.0
			Image.FORMAT_RGB8: per_pixel = 3.0
			Image.FORMAT_DXT1, Image.FORMAT_ETC2_RGB8, Image.FORMAT_ETC: per_pixel = 0.5; mips = 1.34
			Image.FORMAT_DXT3, Image.FORMAT_DXT5, Image.FORMAT_BPTC_RGBA, Image.FORMAT_BPTC_RGBF, Image.FORMAT_BPTC_RGBFU, Image.FORMAT_ETC2_RGBA8, Image.FORMAT_ETC2_RA_AS_RG, Image.FORMAT_ASTC_4x4, Image.FORMAT_ASTC_4x4_HDR: per_pixel = 1.0; mips = 1.34
			Image.FORMAT_RGBAH: per_pixel = 8.0
			Image.FORMAT_RGBAF: per_pixel = 16.0
			Image.FORMAT_RGBH: per_pixel = 6.0
			Image.FORMAT_RGBF: per_pixel = 12.0
	return int(pixels * per_pixel * mips)


## The groups and bytes held, for the memory probe: {group: {count, mb}}.
static func stats() -> Dictionary:
	var out: Dictionary = {}
	for entry: Entry in _entries.values():
		var row: Dictionary = out.get(entry.group, {"count": 0, "bytes": 0})
		row["count"] = int(row["count"]) + 1
		row["bytes"] = int(row["bytes"]) + entry.bytes
		out[entry.group] = row
	out["_total"] = {"count": _entries.size(), "bytes": _bytes, "budget_mb": budget_mb, "loads": loads, "evictions": evictions}
	return out


static func _evict(keep: String) -> void:
	var limit: int = budget_mb * 1048576
	if _bytes <= limit:
		return
	# oldest first; the entry just put in is never the one evicted
	var order: Array = _entries.keys()
	order.sort_custom(func(a: String, b: String) -> bool: return (_entries[a] as Entry).tick < (_entries[b] as Entry).tick)
	for full: String in order:
		if _bytes <= limit:
			break
		if full == keep:
			continue
		var entry: Entry = _entries[full] as Entry
		_bytes -= entry.bytes
		_entries.erase(full)
		evictions += 1
