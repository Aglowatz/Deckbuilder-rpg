class_name UiArtWarmup
extends Node
## Overnight Oct 17 (Phase 2 cycle 5, performance): the first open of a big screen loaded its full-screen painting (and a vendor's stage
## picture) on the main thread, a 100-200 ms hitch the first time each menu opened. A moment after an area loads, this asks for those pictures on a
## loader thread and puts them in the same caches `UiArt.texture` / `KeyArt.texture` read, so the screens find them ready.
## Opening a screen before a picture has arrived still works: `load()` waits for the thread's copy.

## The full-screen backgrounds of the screens opened from anywhere (Character, Deck Station and Collection Book, Quest Log, map, packs).
const UI_BACKGROUNDS: Array[String] = ["UI-BG-CHARACTER", "UI-BG-DECKBUILDER", "UI-BG-QUESTLOG", "UI-BG-WORLDMAP", "UI-BG-PACKOPEN"]
## Card thumbnails warmed: the owned cards the Deck Station and the Collection Book show first (Phase 2 cycle 20).
const THUMBS: int = 32
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
	_prewarm_card_drawing()
	for card_id: String in _first_thumbs():
		var thumb_path: String = "%s%s.%s" % [CardArt.THUMB_DIR, card_id, CardArt.EXTENSION]
		if not CardArt._thumbs.has(card_id) and ResourceLoader.exists(thumb_path):
			_request(thumb_path, func(texture: Texture2D) -> void:
				if not CardArt._thumbs.has(card_id):
					CardArt._thumbs[card_id] = texture)


## A card view drawn for a few frames in a corner, nearly invisible, so the card shaders and the card text sizes are ready before a grid of
## cards first opens (that first draw cost ~150 ms more than later opens). A rare owned card, so the foil is drawn too.
func _prewarm_card_drawing() -> void:
	if Session.profile == null or Session.profile.owned_cards.is_empty():
		return
	var pick: CardData = Session.profile.owned_cards[0]
	for card: CardData in Session.profile.owned_cards:
		if card != null and int(card.rarity) >= 2:
			pick = card
			break
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = -10
	add_child(layer)
	for card_mode: CardView.Mode in [CardView.Mode.FULL]:
		var view: CardView = CardView.create(pick, card_mode, true)
		view.modulate.a = 0.02
		view.scale = Vector2.ONE * 0.2
		view.position = Vector2(2.0, 2.0)
		view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(view)
	get_tree().create_timer(0.5).timeout.connect(layer.queue_free)


## The first THUMBS distinct owned cards (the top of the Deck Station's collection grid).
func _first_thumbs() -> Array[String]:
	var ids: Array[String] = []
	if Session.profile == null:
		return ids
	for card: CardData in Session.profile.owned_cards:
		if card != null and not ids.has(card.id):
			ids.append(card.id)
			if ids.size() >= THUMBS:
				break
	return ids


func _request(path: String, store: Callable) -> void:
	if ResourceLoader.load_threaded_request(path, "Texture2D") == OK:
		_pending[path] = store
