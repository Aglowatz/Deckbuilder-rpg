class_name UiArtWarmup
extends Node
## Overnight Oct 17 (Phase 2 cycle 5, performance): the first open of a big screen loaded its full-screen painting (and a vendor's stage
## picture) on the main thread, a 100-200 ms hitch the first time each menu opened. A moment after an area loads, this asks for those pictures on a
## loader thread and puts them in the same caches `UiArt.texture` / `KeyArt.texture` read, so the screens find them ready.
## Opening a screen before a picture has arrived still works: `load()` waits for the thread's copy.

## The full-screen backgrounds of the screens opened from anywhere (Character, Deck Station and Collection Book, Quest Log, map, packs).
const UI_BACKGROUNDS: Array[String] = ["UI-BG-CHARACTER", "UI-BG-DECKBUILDER", "UI-BG-QUESTLOG", "UI-BG-WORLDMAP", "UI-BG-PACKOPEN"]
## Seconds after the area appears (its own loading comes first).
const START_DELAY: float = 2.0

## Vendor stage pictures (KeyArt ids such as "VS-SABLE") of the vendors in this area.
var vendor_screens: Array[String] = []
var _delay: float = START_DELAY
## path -> the cache it goes into once loaded.
var _pending: Dictionary = {}


static func make(vendors: Array[String] = []) -> UiArtWarmup:
	var warmup: UiArtWarmup = UiArtWarmup.new()
	warmup.name = "UiArtWarmup"
	warmup.vendor_screens = vendors
	return warmup


func _process(delta: float) -> void:
	if _delay > 0.0:
		_delay -= delta
		if _delay <= 0.0:
			_start()
		return
	if _pending.is_empty():
		set_process(false)
		return
	for path: Variant in _pending.keys():
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(str(path))
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			(_pending[path] as Callable).call(ResourceLoader.load_threaded_get(str(path)) as Texture2D)
			_pending.erase(path)
		elif status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_pending.erase(path)


## How many pictures are still on their way (tests).
func pending() -> int:
	return _pending.size() if _delay <= 0.0 else -1


func _start() -> void:
	for id: String in UI_BACKGROUNDS:
		if not UiArt._textures.has(id) and UiArt.has(id):
			_request(UiArt.path_for(id), func(texture: Texture2D) -> void:
				if not UiArt._textures.has(id):
					UiArt._textures[id] = texture)
	for id: String in vendor_screens:
		if not KeyArt._textures.has(id) and KeyArt.has(id):
			_request(KeyArt.path_for(id), func(texture: Texture2D) -> void:
				if not KeyArt._textures.has(id):
					KeyArt._textures[id] = texture)


func _request(path: String, store: Callable) -> void:
	if ResourceLoader.load_threaded_request(path, "Texture2D") == OK:
		_pending[path] = store
