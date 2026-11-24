class_name AlchemistScreen
extends OverlayScreen
## Auntie Alembic's: the Alchemist's crafting screen. Rules: `Alchemy`.
##
## Fable big pass Nov 23 (Part 8): rebuilt from the owner's mock-up B (UI-ALEMBIC-MOCK-B), with mock-up A's light card panel.
##   - Centre left: Auntie Alembic at her cauldron (the four-armed UI-ALEMBIC-BREW) inside a gold circle that carries the four Path
##     sockets (`AlembicRing`). Click a socket (or its jar) to choose that Path: the socket lights up and its essence pours into
##     the pot. The Brew button is under her.
##   - Bottom left: the four essence jars in a row, each filling to 18 with its number on the glass.
##   - Right: a light parchment panel - the Paths of the brew (two slots; the third and the fourth are locked until Primm is
##     beaten), what it costs, and the cards it can make (hover one to read it; a card never seen is face down).
##   - Brewing: motes fly from the chosen sockets into the pot, it boils, flashes in the Paths' colours and the card rises out of
##     it, large, over the cauldron.
## Mouse and controller: every socket, jar and the Brew button take focus. The node names the tests and the smokes use are kept
## (EssenceRow<path>, CraftButton, PossibleCards, Possible_<id>, CraftResult, CraftedCard, BrewSteps, Slot<n>, Cauldron).

signal crafted(card: CardData)

var _selected: Array[Affinity.Type] = []
var _essence_rows: Dictionary = {}
var _sockets: Dictionary = {}
var _preview_box: VBoxContainer
var _cost_label: Label
var _hint_label: Label
var _craft_button: FancyButton
## The brewed card's size over the cauldron (of CardView.SIZE).
const RESULT_CARD_SCALE: float = 1.0
var _stage: Control
var _cauldron: TextureRect
var _ring: AlembicRing
var _streams: AlembicRing
const CAULDRON_ART: String = "UI-CAULDRON"
## Auntie Alembic stirring the big cauldron (Batch 19; Batch 20 repainted her with four arms), the centre of the screen.
const BREW_ART: String = "UI-ALEMBIC-BREW"
const BREW_STAGE_HEIGHT: float = 500.0
var _pot_mouth: Vector2 = Vector2(505, 320)
var _brew_swing: float = 6.0
var _result_holder: Control
var _brewing: bool = false
var _gold_label: Label
var _steps: HBoxContainer
var _slots: Array[PanelContainer] = []
var _pool_title: Label
var _cost_pill: HBoxContainer
var _board: Control

## The board (everything under the header) and its two halves.
const BOARD: Vector2 = Vector2(1840, 890)
const LEFT_WIDTH: float = 1010.0
const PANEL_RECT: Rect2 = Rect2(1040, 0, 800, 890)
const RING_CENTRE: Vector2 = Vector2(505, 275)
const RING_RADII: Vector2 = Vector2(400, 255)
const SOCKET_SIZE: float = 124.0
## The four sockets on the circle, in `PathIcons.ORDER` (top left, top right, bottom left, bottom right, as in the mock-up).
const SOCKET_SPOTS: Array[Vector2] = [Vector2(190, 105), Vector2(820, 105), Vector2(150, 400), Vector2(860, 400)]
const JAR_CELL: Vector2 = Vector2(190, 240)
const JAR_ROW_Y: float = 646.0
const BREW_BUTTON_RECT: Rect2 = Rect2(275, 530, 460, 84)
## The cards a brew can make: seven to a row in the parchment panel.
const POOL_COLUMNS: int = 7
const POOL_CARD_SCALE: float = 0.33
## The parchment panel's colours (mock-up A): light paper, brown ink.
const PAPER: Color = Color("efe2bd")
const PAPER_EDGE: Color = Color("8a6a3a")
const PAPER_INK: Color = Color("3a2817")
const PAPER_MUTED: Color = Color("6b5536")
const SLOT_SIZE: Vector2 = Vector2(172, 100)


func _ready() -> void:
	screen_title = StoryText.shared().text("town.alchemist.name")
	title_icon_id = "ICON-UI-CRAFT"
	# she is the centre of the screen now (UI-ALEMBIC-BREW), so the vendor stage with her portrait on the left is not used
	vendor_screen_id = "" if UiArt.has(BREW_ART) else "VS-ALEMBIC"
	vendor_inset = 500.0
	super._ready()


## The instructions shown in the card panel while no brew is chosen.
static func instructions() -> String:
	return "Every copy of a card beyond your third turns into essence of its Path (more for rarer cards). A brew takes %d essence of each of two Paths, plus %d gold. Each Path holds at most %d essence: once a Path is full, extra copies of its cards add no more until you brew." % [Alchemy.MIN_ESSENCE_PER_PATH, Alchemy.GOLD_COST, Alchemy.ESSENCE_CAP_PER_PATH]


## The copy caps at the hero's level, as on the Character screen.
func _caps_text() -> String:
	var level: int = Session.profile.level if Session.profile != null else 1
	return "%d Common, %d Uncommon, %d Epic, %d Legendary" % [CopyCaps.cap_for(CardEnums.Rarity.COMMON, level), CopyCaps.cap_for(CardEnums.Rarity.UNCOMMON, level), CopyCaps.cap_for(CardEnums.Rarity.EPIC, level), CopyCaps.cap_for(CardEnums.Rarity.LEGENDARY, level)]


func _build() -> void:
	# The same coin and number as every vendor's header.
	header_extra.add_child(IconArt.glyph_or("ICON-GOLD", CardIcons.ui("coins"), UIStyle.GOLD, 38.0))
	_gold_label = UIKit.label("", &"", 34, UIStyle.GOLD)
	_gold_label.add_theme_font_override("font", UIStyle.font_title())
	header_extra.add_child(_gold_label)
	_board = Control.new()
	_board.name = "AlembicBoard"
	_board.custom_minimum_size = BOARD if stage == null else Vector2(BOARD.x - vendor_inset, BOARD.y)
	_board.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_board.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	body.add_child(_board)
	_build_stage()
	_build_sockets()
	_build_brew_button()
	_build_jars()
	_build_panel()
	_refresh()


# ---- the left half: Alembic, the circle, the sockets, Brew, the jars --------------------------------------------------------------


func _build_stage() -> void:
	_stage = Control.new()
	_stage.name = "BrewStage"
	_stage.position = Vector2.ZERO
	_stage.size = Vector2(LEFT_WIDTH, 620)
	_stage.clip_contents = false
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_board.add_child(_stage)
	_ring = AlembicRing.new()
	_ring.name = "Ring"
	_ring.centre = RING_CENTRE
	_ring.radii = RING_RADII
	_ring.size = _stage.size
	_ring.show_streams = false
	_stage.add_child(_ring)
	if UiArt.has(BREW_ART):
		var scene: Texture2D = UiArt.texture(BREW_ART)
		var wide: float = BREW_STAGE_HEIGHT * scene.get_size().x / maxf(1.0, scene.get_size().y)
		_cauldron = TextureRect.new()
		_cauldron.texture = scene
		_cauldron.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_cauldron.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_cauldron.size = Vector2(wide, BREW_STAGE_HEIGHT)
		_cauldron.pivot_offset = Vector2(wide * 0.5, BREW_STAGE_HEIGHT * 0.78)
		_cauldron.position = Vector2(RING_CENTRE.x - wide * 0.5, 22.0)
		_pot_mouth = Vector2(RING_CENTRE.x, 22.0 + BREW_STAGE_HEIGHT * 0.6)
		_brew_swing = 1.5  # she is in the picture: the whole scene only trembles
	elif UiArt.has(CAULDRON_ART):
		_cauldron = TextureRect.new()
		_cauldron.texture = UiArt.texture(CAULDRON_ART)
		_cauldron.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_cauldron.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_cauldron.size = Vector2(300, 300)
		_cauldron.pivot_offset = Vector2(150, 170)
		_cauldron.position = Vector2(RING_CENTRE.x - 150.0, 130.0)
		_pot_mouth = Vector2(RING_CENTRE.x, 230.0)
	else:
		_cauldron = CardIcons.glyph(CardIcons.named("lorc/cauldron"), Color("8fd36a"), Vector2(260, 260))
		_cauldron.size = Vector2(260, 260)
		_cauldron.pivot_offset = Vector2(130, 130)
		_cauldron.position = Vector2(RING_CENTRE.x - 130.0, 140.0)
		_pot_mouth = Vector2(RING_CENTRE.x, 240.0)
	_cauldron.name = "Cauldron"
	_cauldron.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_cauldron)
	_ring.pot_mouth = _pot_mouth
	# the streams of the chosen Paths pour over her picture, into the pot
	_streams = AlembicRing.new()
	_streams.name = "Streams"
	_streams.centre = RING_CENTRE
	_streams.radii = RING_RADII
	_streams.size = _stage.size
	_streams.show_ring = false
	_streams.pot_mouth = _pot_mouth
	_streams.sockets = _ring.sockets  # one table of socket spots for both layers
	_stage.add_child(_streams)


func _build_sockets() -> void:
	for index: int in range(PathIcons.ORDER.size()):
		var path: Affinity.Type = PathIcons.ORDER[index]
		var spot: Vector2 = SOCKET_SPOTS[index]
		_ring.sockets[path] = spot
		var socket: Button = Button.new()
		socket.name = "Socket%d" % int(path)
		socket.size = Vector2(SOCKET_SIZE, SOCKET_SIZE)
		socket.custom_minimum_size = socket.size
		socket.position = spot - socket.size * 0.5
		socket.focus_mode = Control.FOCUS_ALL
		socket.pressed.connect(_toggle_path.bind(path))
		var icon: TextureRect = IconArt.glyph_or(PathIcons.icon(path), CardIcons.ui("gems"), Color.WHITE, 72.0)
		icon.name = "Icon"
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.position = (socket.size - Vector2(72, 72)) * 0.5
		icon.size = Vector2(72, 72)
		socket.add_child(icon)
		_stage.add_child(socket)
		_sockets[path] = socket


func _build_brew_button() -> void:
	_craft_button = FancyButton.make("Brew", &"PrimaryButton", BREW_BUTTON_RECT.size)
	_craft_button.name = "CraftButton"
	_craft_button.position = BREW_BUTTON_RECT.position
	_craft_button.size = BREW_BUTTON_RECT.size
	_craft_button.pressed.connect(_craft)
	_board.add_child(_craft_button)


func _build_jars() -> void:
	var plaque: Label = UIKit.label("Essence", &"", 24, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	plaque.name = "EssencePlaque"
	plaque.add_theme_font_override("font", UIStyle.font_title())
	plaque.position = Vector2(0, JAR_ROW_Y - 30.0)
	plaque.size = Vector2(LEFT_WIDTH, 28)
	plaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_board.add_child(plaque)
	var shelf: HBoxContainer = UIKit.hbox(14)
	shelf.name = "JarShelf"
	shelf.alignment = BoxContainer.ALIGNMENT_CENTER
	shelf.position = Vector2(0, JAR_ROW_Y)
	shelf.size = Vector2(LEFT_WIDTH, JAR_CELL.y)
	_board.add_child(shelf)
	for path: Affinity.Type in PathIcons.ORDER:
		var row: Button = Button.new()
		row.name = "EssenceRow%d" % int(path)
		row.toggle_mode = false  # the screen owns the selection
		row.custom_minimum_size = JAR_CELL
		row.focus_mode = Control.FOCUS_ALL
		row.add_theme_stylebox_override("pressed", UIStyle.box(UIStyle.affinity_color(path).darkened(0.45), UIStyle.GOLD, 4, 14, 10))
		row.add_theme_stylebox_override("hover_pressed", UIStyle.box(UIStyle.affinity_color(path).darkened(0.4), UIStyle.GOLD, 4, 14, 10))
		row.add_theme_stylebox_override("focus", UIStyle.box(Color(0, 0, 0, 0), UIStyle.GOLD, 3, 14))
		row.add_theme_stylebox_override("disabled", UIStyle.box(Color(1, 1, 1, 0.02), Color(1, 1, 1, 0.08), 2, 14))
		row.pressed.connect(_toggle_path.bind(path))
		var jar: EssenceJar = EssenceJar.make(path, Alchemy.ESSENCE_CAP_PER_PATH)
		jar.position = Vector2((JAR_CELL.x - EssenceJar.SIZE.x) * 0.5, 6)
		row.add_child(jar)
		var name_row: HBoxContainer = UIKit.hbox(6)
		name_row.alignment = BoxContainer.ALIGNMENT_CENTER
		name_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_row.position = Vector2(0, EssenceJar.SIZE.y + 8.0)
		name_row.custom_minimum_size = Vector2(JAR_CELL.x, 30)
		name_row.size = name_row.custom_minimum_size
		row.add_child(name_row)
		var orb: TextureRect = IconArt.glyph_or(IconArt.essence_id(path), CardIcons.ui("gems"), UIStyle.affinity_color(path), 26.0)
		orb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_row.add_child(orb)
		var name_label: Label = UIKit.label(Affinity.display_name(path), &"", 21, UIStyle.PARCHMENT)
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_row.add_child(name_label)
		# the number is on the glass; this label keeps the count for readers of the tree (tests, smokes)
		var amount: Label = UIKit.label("0", &"", 18, Color.WHITE)
		amount.name = "Amount"
		amount.visible = false
		row.add_child(amount)
		var tick: Label = UIKit.label("✓", &"", 30, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
		tick.name = "Selected"
		tick.add_theme_font_override("font", UIStyle.font_title())
		tick.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		tick.add_theme_constant_override("outline_size", 8)
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tick.position = Vector2(JAR_CELL.x - 44.0, 2.0)
		tick.size = Vector2(36, 36)
		tick.visible = false
		row.add_child(tick)
		shelf.add_child(row)
		_essence_rows[path] = {"button": row, "jar": jar, "amount": amount, "tick": tick}


# ---- the right half: the light card panel -----------------------------------------------------------------------------------------


func _ink(text: String, px: int, colour: Color = PAPER_INK, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label: Label = UIKit.label(text, &"", px, colour, align)
	label.add_theme_color_override("font_color", colour)
	return label


func _build_panel() -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "CardPanel"
	panel.position = PANEL_RECT.position if stage == null else Vector2(maxf(0.0, _board.custom_minimum_size.x - PANEL_RECT.size.x), 0.0)
	panel.size = PANEL_RECT.size
	panel.custom_minimum_size = PANEL_RECT.size
	var paper: StyleBoxFlat = UIStyle.box(PAPER, PAPER_EDGE, 5, 22, 14)
	paper.set_content_margin_all(22.0)
	panel.add_theme_stylebox_override("panel", paper)
	_board.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(10)
	panel.add_child(column)
	var title: Label = _ink("Paths", 30, PAPER_INK, HORIZONTAL_ALIGNMENT_CENTER)
	title.name = "PathsTitle"
	title.add_theme_font_override("font", UIStyle.font_title())
	column.add_child(title)
	column.add_child(_build_steps())
	_cost_pill = UIKit.hbox(18)
	_cost_pill.name = "CostPill"
	_cost_pill.alignment = BoxContainer.ALIGNMENT_CENTER
	var pill: PanelContainer = PanelContainer.new()
	pill.name = "CostPanel"
	var pill_box: StyleBoxFlat = UIStyle.box(Color("2a1d33"), UIStyle.GOLD_DIM, 3, 22)
	pill_box.set_content_margin_all(8.0)
	pill.add_theme_stylebox_override("panel", pill_box)
	pill.custom_minimum_size = Vector2(0, 52)
	pill.add_child(_cost_pill)
	column.add_child(pill)
	_cost_label = _ink("", 19)
	_cost_label.name = "CostLabel"
	_cost_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_cost_label.custom_minimum_size = Vector2(PANEL_RECT.size.x - 48.0, 50)
	column.add_child(_cost_label)
	_pool_title = _ink("", 18, PAPER_MUTED)
	_pool_title.name = "PoolTitle"
	_pool_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_pool_title.custom_minimum_size = Vector2(PANEL_RECT.size.x - 48.0, 0)
	column.add_child(_pool_title)
	_preview_box = UIKit.vbox(6)
	_preview_box.name = "PossibleCards"
	_preview_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_preview_box.custom_minimum_size = Vector2(PANEL_RECT.size.x - 48.0, 420)  # the space is kept, so nothing jumps under the cursor
	column.add_child(_preview_box)
	_hint_label = _ink("", 19, Color("8c2f1f"))
	_hint_label.name = "Hint"
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.custom_minimum_size = Vector2(PANEL_RECT.size.x - 48.0, 0)
	column.add_child(_hint_label)


## The Paths of the brew: one slot per Path a brew may take today, filled with the chosen Paths' colours and icons; the third and
## the fourth slot are locked until Primm is beaten.
func _build_steps() -> Control:
	_steps = UIKit.hbox(12)
	_steps.name = "BrewSteps"
	_steps.alignment = BoxContainer.ALIGNMENT_CENTER
	_slots = []
	for index: int in range(PathIcons.ORDER.size()):
		var slot: PanelContainer = PanelContainer.new()
		slot.name = "Slot%d" % index
		slot.custom_minimum_size = SLOT_SIZE
		var inside: VBoxContainer = UIKit.vbox(2)
		inside.alignment = BoxContainer.ALIGNMENT_CENTER
		inside.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(inside)
		var icon: TextureRect = TextureRect.new()
		icon.name = "Icon"
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(52, 52)
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inside.add_child(icon)
		var text: Label = UIKit.label("", &"", 18, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
		text.name = "Text"
		text.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inside.add_child(text)
		_steps.add_child(slot)
		_slots.append(slot)
	return _steps


## How many Paths a brew may take today (two; four once Primm is beaten).
func slot_count() -> int:
	return Alchemy.max_craft_paths(Session.profile)


func _refresh_steps() -> void:
	if _steps == null:
		return
	var open: int = slot_count()
	for index: int in range(_slots.size()):
		var slot: PanelContainer = _slots[index]
		var icon: TextureRect = slot.find_child("Icon", true, false) as TextureRect
		var text: Label = slot.find_child("Text", true, false) as Label
		var locked: bool = index >= open
		var filled: bool = index < _selected.size()
		slot.set_meta("locked", locked)
		if locked:
			slot.add_theme_stylebox_override("panel", UIStyle.box(Color("5a4a3c"), Color("3a2c20"), 3, 14))
			icon.texture = IconArt.texture("ICON-PADLOCK", 52.0) if IconArt.has("ICON-PADLOCK") else CardIcons.ui("lock")
			icon.modulate = Color(1.0, 0.86, 0.5)
			text.text = "After Primm"
			text.add_theme_color_override("font_color", Color(0.93, 0.87, 0.74))
			slot.tooltip_text = "A third and a fourth Path join the brew once Primm is beaten."
		elif filled:
			var colour: Color = UIStyle.affinity_color(_selected[index])
			slot.add_theme_stylebox_override("panel", UIStyle.box(colour.darkened(0.25), UIStyle.GOLD, 4, 14, 6))
			icon.texture = IconArt.texture(PathIcons.icon(_selected[index]), 52.0) if IconArt.has(PathIcons.icon(_selected[index])) else CardIcons.ui("gems")
			icon.modulate = Color.WHITE
			text.text = Affinity.display_name(_selected[index])
			text.add_theme_color_override("font_color", Color.WHITE)
			slot.tooltip_text = ""
		else:
			slot.add_theme_stylebox_override("panel", UIStyle.box(Color(0.23, 0.16, 0.09, 0.14), PAPER_EDGE, 3, 14))
			icon.texture = null
			text.text = "empty" if index < 2 else "optional"
			text.add_theme_color_override("font_color", PAPER_MUTED)
			slot.tooltip_text = "Click a Path's socket or its jar."
	var ready: bool = _selected.size() >= 2
	if _pool_title != null:
		_pool_title.text = "" if not ready else "What this brew can make (hover a card to read it; a card you have never seen is face down)"


## The price in the dark strip: the gold, then six essence of each chosen Path (two grey gems while nothing is chosen).
func _refresh_cost_pill() -> void:
	for child: Node in _cost_pill.get_children():
		_cost_pill.remove_child(child)
		child.queue_free()
	var count: int = maxi(2, _selected.size())
	_cost_pill.add_child(_price(IconArt.glyph_or("ICON-GOLD", CardIcons.ui("coins"), UIStyle.GOLD, 34.0), Alchemy.gold_cost(count), UIStyle.GOLD, Session.gold >= Alchemy.gold_cost(count)))
	for index: int in range(count):
		var chosen: bool = index < _selected.size()
		var colour: Color = UIStyle.affinity_color(_selected[index]) if chosen else Color(0.7, 0.68, 0.75)
		var gem: TextureRect = IconArt.glyph_or(IconArt.essence_id(_selected[index]) if chosen else "", CardIcons.ui("gems"), colour, 34.0)
		var enough: bool = not chosen or Session.profile.essence_of(_selected[index]) >= Alchemy.MIN_ESSENCE_PER_PATH
		_cost_pill.add_child(_price(gem, Alchemy.MIN_ESSENCE_PER_PATH, colour.lightened(0.35), enough))


func _price(icon: TextureRect, amount: int, colour: Color, enough: bool) -> HBoxContainer:
	var row: HBoxContainer = UIKit.hbox(6)
	row.name = "Price"
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)
	var number: Label = UIKit.label("×%d" % amount, &"", 26, colour if enough else Color("ff7a66"))
	number.name = "Number"
	number.add_theme_font_override("font", UIStyle.font_title())
	row.add_child(number)
	return row


# ---- choosing and the state of everything ------------------------------------------------------------------------------------------


func _toggle_path(path: Affinity.Type) -> void:
	if _brewing:
		return
	if _selected.has(path):
		_selected.erase(path)
	else:
		# A jar short of essence can still be picked: the Brew button then says how much more it needs.
		if Session.profile.essence_of(path) < Alchemy.MIN_ESSENCE_PER_PATH:
			Audio.sfx(&"ui_error")
		if _selected.size() >= slot_count():
			_selected.remove_at(0)
		_selected.append(path)
	Audio.sfx(&"ui_tick")
	_clear_result()
	_refresh()


func _refresh() -> void:
	_gold_label.text = str(Session.gold)
	for path: Variant in _essence_rows.keys():
		var entry: Dictionary = _essence_rows[path]
		var amount: int = Session.profile.essence_of(path as Affinity.Type)
		(entry["amount"] as Label).text = str(amount)
		(entry["amount"] as Label).add_theme_color_override("font_color", UIStyle.GOLD if amount >= Alchemy.ESSENCE_CAP_PER_PATH else Color.WHITE)
		var button: Button = entry["button"] as Button
		var chosen: bool = _selected.has(path as Affinity.Type)
		var colour: Color = UIStyle.affinity_color(path as Affinity.Type)
		(entry["jar"] as EssenceJar).set_state(amount, chosen)
		button.add_theme_stylebox_override("normal", UIStyle.box(colour.darkened(0.5), UIStyle.GOLD, 4, 14, 10) if chosen else UIStyle.box(Color(1, 1, 1, 0.04), colour.darkened(0.35), 2, 14))
		button.add_theme_stylebox_override("hover", UIStyle.box(colour.darkened(0.42), UIStyle.GOLD, 4, 14, 10) if chosen else UIStyle.box(Color(1, 1, 1, 0.09), colour, 3, 14))
		button.set_meta("chosen", chosen)
		(entry["tick"] as Label).visible = chosen
		button.tooltip_text = "%d / %d essence needed to brew." % [amount, Alchemy.MIN_ESSENCE_PER_PATH] if amount < Alchemy.MIN_ESSENCE_PER_PATH else "Click to use this Path in the brew."
		if amount >= Alchemy.ESSENCE_CAP_PER_PATH:
			button.tooltip_text += "\nFull (%d): extra copies of %s cards add no more essence until you brew." % [Alchemy.ESSENCE_CAP_PER_PATH, Affinity.display_name(path as Affinity.Type)]
		_style_socket(path as Affinity.Type, chosen, amount >= Alchemy.MIN_ESSENCE_PER_PATH)
	_ring.set_chosen(_selected)
	_streams.set_chosen(_selected)
	_rebuild_preview()
	_refresh_steps()
	_refresh_cost_pill()
	var count: int = _selected.size()
	var problem: String = Alchemy.problem_for(Session.profile, Session.gold, _selected)
	_craft_button.disabled = _brewing or not problem.is_empty()
	_set_craft_text(Alchemy.gold_cost(maxi(2, count)), maxi(2, count), problem)
	_hint_label.text = ""
	if count < 2:
		_cost_label.text = "Choose two Paths. The brew takes %d essence of each, plus %d gold, and gives you ONE random card of those two Paths. The rest stays in your jars." % [Alchemy.MIN_ESSENCE_PER_PATH, Alchemy.GOLD_COST]
		if Alchemy.tri_path_unlocked(Session.profile):
			_cost_label.text += " Or choose three (%d gold) or all four (%d gold)." % [Alchemy.TRI_GOLD_COST, Alchemy.QUAD_GOLD_COST]
		_hint_label.text = StoryText.shared().text("town.alchemist.need_more") if not Alchemy.can_craft_something(Session.profile) else ""
		return
	var names: Array[String] = []
	for path: Affinity.Type in _selected:
		names.append("%d %s" % [Alchemy.MIN_ESSENCE_PER_PATH, Affinity.display_name(path)])
	var kind: String = "dual-Path" if count == 2 else ("tri-Path" if count == 3 else "four-Path")
	_cost_label.text = "Trade %s essence and %d gold for a random %s card of %s." % [" + ".join(names), Alchemy.gold_cost(count), kind, "both" if count == 2 else ("all three" if count == 3 else "all four")]


## A socket on the circle: dark with a dim icon; lit in its Path's colour with a gold rim when chosen.
func _style_socket(path: Affinity.Type, chosen: bool, enough: bool) -> void:
	var socket: Button = _sockets.get(path) as Button
	if socket == null:
		return
	var colour: Color = UIStyle.affinity_color(path)
	var radius: int = int(SOCKET_SIZE * 0.5)
	var rest: StyleBoxFlat = UIStyle.box(colour.darkened(0.2) if chosen else colour.darkened(0.72), UIStyle.GOLD if chosen else colour.darkened(0.1), 6 if chosen else 4, radius, 16 if chosen else 4)
	if chosen:
		rest.shadow_color = Color(colour.lightened(0.2), 0.75)
		rest.shadow_offset = Vector2.ZERO
	socket.add_theme_stylebox_override("normal", rest)
	socket.add_theme_stylebox_override("pressed", rest)
	var hover: StyleBoxFlat = rest.duplicate() as StyleBoxFlat
	hover.bg_color = rest.bg_color.lightened(0.14)
	hover.border_color = UIStyle.GOLD
	socket.add_theme_stylebox_override("hover", hover)
	socket.add_theme_stylebox_override("focus", UIStyle.box(Color(0, 0, 0, 0), Color.WHITE, 4, radius))
	socket.set_meta("chosen", chosen)
	(socket.get_node("Icon") as TextureRect).modulate = Color.WHITE if chosen else Color(1, 1, 1, 0.62 if enough else 0.34)
	socket.tooltip_text = "%s: %d essence%s" % [Affinity.display_name(path), Session.profile.essence_of(path), "" if enough else " (a brew needs %d)" % Alchemy.MIN_ESSENCE_PER_PATH]


## The Brew button always shows its price ("Brew - 100 gold, 6 + 6") and, when it cannot be pressed, the reason on a second line
## ("Pick two Paths", "Need 6 more Necrocrat essence", "Need 100 gold").
func _set_craft_text(gold: int, paths: int, problem: String) -> void:
	var each: Array[String] = []
	for index: int in range(paths):
		each.append(str(Alchemy.MIN_ESSENCE_PER_PATH))
	var label: String = "Brew — %d gold, %s" % [gold, " + ".join(each)]
	if not problem.is_empty() and not _brewing:
		label += "\n" + problem.trim_suffix(".")
	_craft_button.text = label
	_craft_button.tooltip_text = problem


func _rebuild_preview() -> void:
	for child: Node in _preview_box.get_children():
		_preview_box.remove_child(child)
		child.queue_free()
	if _selected.size() < 2:
		# nothing chosen yet: how brewing works, where the cards will be
		var how: Label = _ink(instructions(), 19, PAPER_MUTED)
		how.name = "HowItWorks"
		how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		how.custom_minimum_size = Vector2(PANEL_RECT.size.x - 60.0, 0)
		_preview_box.add_child(how)
		return
	# reward-locked cards (every four-Path card is one) join the pool once earned: the brew makes more copies of them
	var earned: Dictionary = {}
	for owned_card: CardData in Session.profile.owned_cards:
		earned[owned_card.id] = true
	var pool: Array[CardData] = Alchemy.pool_for(Session.content, _selected, earned)
	var row: GridContainer = GridContainer.new()
	row.columns = POOL_COLUMNS
	row.add_theme_constant_override("h_separation", 8)
	row.add_theme_constant_override("v_separation", 2)
	row.name = "PossibleRow"
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_preview_box.add_child(row)
	# under each card how many you own; a card never seen (owned, met in a battle, a shop or a pack) is a card back until it is;
	# hovering magnifies either, like the reward cards.
	for card: CardData in pool:
		var holder: VBoxContainer = UIKit.vbox(0)
		holder.name = "Possible_%s" % card.id
		var seen: bool = Session.has_seen(card.id)
		var view: Control = CardView.wrapped(card, POOL_CARD_SCALE, CardView.Mode.FULL if seen else CardView.Mode.BACK)
		view.name = "Card"
		if not seen:
			view.set_meta("unseen", true)
		view.mouse_filter = Control.MOUSE_FILTER_PASS
		CardHoverZoom.attach(view)
		holder.add_child(view)
		var owned: Label = _ink("%d/%d" % [Session.owned_count(card.id), CopyCaps.own_cap(card)] if seen else "?/%d" % CopyCaps.own_cap(card), 17, PAPER_MUTED, HORIZONTAL_ALIGNMENT_CENTER)
		owned.name = "Owned"
		holder.add_child(owned)
		row.add_child(holder)
	if pool.is_empty():
		var none: Label = _ink("The cards of all four Paths are prizes (the Path-ology Lab, Primm's Castle, the Shuffled Halls). Earn one, and this brew makes more copies of it." if _selected.size() >= 4 else "These Paths have no card of their own yet.", 19, PAPER_MUTED)
		none.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		none.custom_minimum_size = Vector2(PANEL_RECT.size.x - 60.0, 0)
		none.name = "NoCards"
		_preview_box.add_child(none)


# ---- brewing ----------------------------------------------------------------------------------------------------------------------


func _craft() -> void:
	if _brewing or _selected.size() < 2:
		return
	var paths: Array[Affinity.Type] = _selected.duplicate()
	var result: Alchemy.Result = Session.craft_dual_card(paths[0], paths[1]) if paths.size() == 2 else Session.craft_tri_card(paths)
	if not result.ok:
		Audio.sfx(&"ui_error")
		_hint_label.text = result.reason
		return
	_brewing = true
	_clear_result()
	_craft_button.disabled = true
	_play_brew(paths, result)


## The brewing moment: the scene trembles and glows, motes of every chosen Path fly from the sockets into the pot, it boils over
## in their colours, a flash, then the card rises out of the pot.
func _play_brew(paths: Array[Affinity.Type], result: Alchemy.Result) -> void:
	Audio.sfx(&"craft_brew")
	var colours: Array[Color] = []
	for path: Affinity.Type in paths:
		colours.append(UIStyle.affinity_color(path))
	var shake: Tween = create_tween()
	for index: int in range(10):
		shake.tween_property(_cauldron, "rotation_degrees", _brew_swing if index % 2 == 0 else -_brew_swing, 0.12)
	shake.tween_property(_cauldron, "rotation_degrees", 0.0, 0.1)
	var glow: Tween = create_tween()
	glow.tween_property(_cauldron, "modulate", Color(1.5, 1.5, 1.5), 1.2)
	for index: int in range(20):
		var path: Affinity.Type = paths[index % paths.size()]
		var mote: Panel = Panel.new()
		mote.name = "Mote%d" % index
		mote.size = Vector2(16, 16)
		mote.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mote.add_theme_stylebox_override("panel", UIStyle.box(colours[index % colours.size()], Color(1, 1, 1, 0.6), 2, 8, 6))
		var angle: float = TAU * float(index) / 20.0
		mote.position = (_ring.sockets.get(path, _pot_mouth) as Vector2) + Vector2(cos(angle), sin(angle)) * 46.0
		_stage.add_child(mote)
		var fly: Tween = mote.create_tween()
		fly.tween_interval(0.05 * float(index % 7))
		fly.tween_property(mote, "position", _pot_mouth + Vector2(-8, 4), 1.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		fly.tween_callback(mote.queue_free)
	if not Settings.reduce_motion:
		for index: int in range(BREW_BUBBLES):
			var bubble: Panel = Panel.new()
			var wide: float = 10.0 + float(index % 4) * 5.0
			bubble.name = "Bubble%d" % index
			bubble.size = Vector2(wide, wide)
			bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bubble.add_theme_stylebox_override("panel", UIStyle.box(Color(colours[index % colours.size()], 0.75), Color(1, 1, 1, 0.75), 2, int(wide * 0.5)))
			bubble.position = Vector2(_pot_mouth.x - 70.0 + float((index * 37) % 140), _pot_mouth.y)
			bubble.modulate.a = 0.0
			_stage.add_child(bubble)
			var up: Tween = bubble.create_tween()
			up.tween_interval(0.08 * float(index))
			up.tween_property(bubble, "modulate:a", 1.0, 0.1)
			up.parallel().tween_property(bubble, "position:y", _pot_mouth.y - 150.0 - float((index * 53) % 80), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			up.parallel().tween_property(bubble, "position:x", bubble.position.x + (30.0 if index % 2 == 0 else -30.0), 0.9)
			up.tween_property(bubble, "scale", Vector2(1.7, 1.7), 0.08)
			up.parallel().tween_property(bubble, "modulate:a", 0.0, 0.08)
			up.tween_callback(bubble.queue_free)
	_brew_colours = colours
	var timer: SceneTreeTimer = get_tree().create_timer(1.5, false)
	timer.timeout.connect(func() -> void: _reveal(result))


const BREW_BUBBLES: int = 16
var _brew_colours: Array[Color] = [Color.WHITE]


func _reveal(result: Alchemy.Result) -> void:
	# A brew of three or four Paths (postgame) has its own sting.
	Audio.sting(&"STG-CRAFT-POST" if result.paths.size() >= 3 else &"STG-CRAFT")
	_cauldron.modulate = Color.WHITE
	# the flash is in the Paths' colours, one after the other
	for index: int in range(_brew_colours.size()):
		var flash: ColorRect = ColorRect.new()
		flash.name = "BrewFlash%d" % index
		flash.color = Color(_brew_colours[index].lightened(0.35), 0.0)
		UIKit.full_rect(flash)
		flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(flash)
		var flash_tween: Tween = flash.create_tween()
		flash_tween.tween_interval(0.14 * float(index))
		flash_tween.tween_property(flash, "color:a", 0.6 * Settings.flash_scale(), 0.1)
		flash_tween.tween_property(flash, "color:a", 0.0, 0.45)
		flash_tween.tween_callback(flash.queue_free)
	# the new card, large, rises out of the pot and stays over the cauldron, its line underneath; hovering magnifies it like a
	# reward card. It goes with the next brew or the next Path click.
	var card_size: Vector2 = CardView.SIZE * RESULT_CARD_SCALE
	var box: Control = Control.new()
	box.name = "CraftResult"
	box.position = Vector2.ZERO
	box.size = Vector2(LEFT_WIDTH, BREW_BUTTON_RECT.position.y)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_result_holder = box
	var holder: Control = CardView.wrapped(result.card, RESULT_CARD_SCALE)
	holder.name = "CraftedCard"
	holder.mouse_filter = Control.MOUSE_FILTER_PASS
	CardHoverZoom.attach(holder)
	var frame: Control = Control.new()
	frame.name = "CraftedCardFrame"
	frame.size = card_size
	frame.position = Vector2(RING_CENTRE.x - card_size.x * 0.5, 6.0)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(frame)
	frame.add_child(holder)
	holder.size = holder.custom_minimum_size
	holder.pivot_offset = holder.custom_minimum_size * 0.5
	holder.scale = Vector2(0.1, 0.1)
	holder.position = Vector2(0, _pot_mouth.y - card_size.y * 0.5)
	var rise: Tween = holder.create_tween().set_parallel(true)
	rise.tween_property(holder, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	rise.tween_property(holder, "position", Vector2(0, 0), 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var plate: PanelContainer = PanelContainer.new()
	plate.name = "CraftCaptionPlate"
	var plate_box: StyleBoxFlat = UIStyle.box(Color(0.08, 0.05, 0.12, 0.9), UIStyle.GOLD, 3, 16)
	plate_box.set_content_margin_all(8.0)
	plate.add_theme_stylebox_override("panel", plate_box)
	plate.position = Vector2(RING_CENTRE.x - 330.0, card_size.y + 12.0)
	plate.custom_minimum_size = Vector2(660, 0)
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caption: Label = UIKit.label("%s joins your collection!" % result.card.display_name, &"HeadingLabel", 24, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	caption.name = "CraftCaption"
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.custom_minimum_size = Vector2(640, 0)
	plate.add_child(caption)
	box.add_child(plate)
	_board.add_child(box)
	_cauldron.visible = false
	_streams.visible = false
	_brewing = false
	# the chosen essences stay chosen, so the next brew is one click away while there is enough essence and gold
	vendor_react("buy")
	crafted.emit(result.card)
	_refresh()


func _clear_result() -> void:
	if _result_holder != null and is_instance_valid(_result_holder):
		_result_holder.queue_free()
		_result_holder = null
	if _cauldron != null:
		_cauldron.visible = true
	if _streams != null:
		_streams.visible = true
	if _stage != null:
		_stage.visible = true
	if _preview_box != null:
		_preview_box.visible = true
	if _pool_title != null:
		_pool_title.visible = true


## Kept for the screens that asked how much narrower the essence column is beside the vendor stage (none is used now).
func _narrow() -> float:
	return 0.0 if stage == null else 100.0
