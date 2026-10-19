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
## Daytime Oct 19: the screens opened first after arriving (the character screen everywhere; the area adds its shops). Each is built once,
## nearly invisible, for a couple of frames before the glyph warmup starts, so the first real open finds its glyphs, shaders and textures
## ready (the full tour saw first opens of 245-345 ms while the glyph warmup was still running). Callables returning an OverlayScreen.
var first_screens: Array[Callable] = []
const SCREEN_FRAMES: int = 2
## The screens are built while the loading screen (or the arrival fade) still covers the new area, so their one heavy frame is never seen.
const SCREEN_DELAY: float = 0.1
## Once per session: the glyphs, shaders and pictures stay cached, so a later area does not build the same screen again.
static var _warmed: Dictionary = {}
var _screen_delay: float = SCREEN_DELAY
var _screens_done: bool = false
var _delay: float = START_DELAY
## path -> the cache it goes into once loaded.
var _pending: Dictionary = {}


static func make(vendors: Array[String] = [], screens: Array[Callable] = []) -> UiArtWarmup:
	var warmup: UiArtWarmup = UiArtWarmup.new()
	warmup.name = "UiArtWarmup"
	warmup.vendor_screens = vendors
	warmup.first_screens = [func() -> OverlayScreen: return CharacterScreen.new()] as Array[Callable]
	warmup.first_screens.append_array(screens)
	return warmup


func _process(delta: float) -> void:
	if _screen_delay > 0.0:
		_screen_delay -= delta
		if _screen_delay <= 0.0:
			_warm_screens()
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
	_glyphs_after_screens()
	for card_id: String in _first_thumbs():
		var thumb_path: String = "%s%s.%s" % [CardArt.THUMB_DIR, card_id, CardArt.EXTENSION]
		if not CardArt._thumbs.has(card_id) and ResourceLoader.exists(thumb_path):
			_request(thumb_path, func(texture: Texture2D) -> void:
				if not CardArt._thumbs.has(card_id):
					CardArt._thumbs[card_id] = texture)


## The first screens one after another (each built in its own frame, drawn SCREEN_FRAMES frames, freed). GUI input is off while a screen
## is up, so nothing invisible can be clicked or hovered.
func _warm_screens() -> void:
	if Session.profile != null and not first_screens.is_empty():
		var layer: CanvasLayer = CanvasLayer.new()
		layer.layer = -10
		add_child(layer)
		for maker: Callable in first_screens:
			if not is_inside_tree():
				return
			var screen: OverlayScreen = maker.call() as OverlayScreen
			if screen == null:
				continue
			var key: String = "%s/%s" % [(screen.get_script() as Script).get_global_name(), screen.vendor_screen_id]
			if _warmed.has(key):
				screen.free()
				continue
			_warmed[key] = true
			screen.warming = true
			get_viewport().gui_disable_input = true
			layer.add_child(screen)
			for _frame: int in range(SCREEN_FRAMES):
				await get_tree().process_frame
			if not is_inside_tree():
				return
			get_viewport().gui_disable_input = false
			screen.queue_free()
			await get_tree().process_frame
		layer.queue_free()
	_screens_done = true


## The glyph warmup starts once the screens are done (they rasterize most of the glyphs their sizes need anyway).
func _glyphs_after_screens() -> void:
	while not _screens_done and is_inside_tree():
		await get_tree().process_frame
	if is_inside_tree():
		_prewarm_glyphs()


func _exit_tree() -> void:
	# A scene change in the middle of a warm screen must not leave the GUI deaf.
	if get_viewport() != null:
		get_viewport().gui_disable_input = false


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


## Overnight Oct 18, Phase 2 cycle 3: the UI fonts are rasterized per size and outline (no MSDF), so the first screen that shows a new size
## drew dozens of glyphs on its first frame. A label clipped to a 3-pixel corner, nearly invisible, cycles through the menus' common sizes, one
## per frame (about 1.5 s), through the real draw path so the UI scale's oversampling is right too.
const GLYPH_SIZES: Array[int] = [15, 16, 17, 18, 19, 20, 21, 22, 24, 26, 28, 30, 32, 34, 38, 44, 54, 64]
const GLYPH_TEXT: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz 0123456789 .,:;!?'\"()-+/%&"
const GLYPH_CHUNK: int = 12


## (font, size, outline) combinations the warmup draws: body and bold plain, the title font plain and with the two outlines menus use.
static func glyph_combos() -> Array[Array]:
	var combos: Array[Array] = []
	for size: int in GLYPH_SIZES:
		combos.append([UIStyle.font_body(), size, 0])
		combos.append([UIStyle.font_bold(), size, 0])
		for outline: int in [0, 6, 8]:
			combos.append([UIStyle.font_title(), size, outline])
	return combos


func _prewarm_glyphs() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = -10
	add_child(layer)
	var clip: Control = Control.new()
	clip.clip_contents = true
	clip.position = Vector2(1.0, 1.0)
	clip.size = Vector2(3.0, 3.0)
	clip.modulate.a = 0.02
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(clip)
	var label: Label = Label.new()
	label.name = "GlyphWarmup"
	label.text = GLYPH_TEXT
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.add_child(label)
	# Phase 2 cycle 20: a whole alphabet at a large size with an outline cost 25-30 ms in one frame (a 0.6 s run of 40-50 ms frames soon
	# after arriving), so each combination is drawn GLYPH_CHUNK characters per frame (~9 s in all, no frame over budget).
	for combo: Array in glyph_combos():
		label.add_theme_font_override("font", combo[0] as Font)
		label.add_theme_font_size_override("font_size", int(combo[1]))
		label.add_theme_constant_override("outline_size", int(combo[2]))
		for start: int in range(0, GLYPH_TEXT.length(), GLYPH_CHUNK):
			if not is_instance_valid(label) or not is_inside_tree():
				return
			label.text = GLYPH_TEXT.substr(start, GLYPH_CHUNK)
			await get_tree().process_frame
	layer.queue_free()


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
