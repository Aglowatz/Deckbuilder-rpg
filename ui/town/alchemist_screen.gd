class_name AlchemistScreen
extends OverlayScreen
## Auntie Alembic's (Part F): the Alchemist's crafting UI. Left: the player's Path essence (click up to two Paths
## that have enough to take part; three once the postgame opens tri-Path crafting). Right: what the trade costs (ALL essence
## of the chosen Paths plus gold), the cards it can produce with their odds, and the Craft button, which plays a short brewing
## animation (a bubbling cauldron, swirling motes in the Path colors) before the card is revealed. Rules: `Alchemy`.

signal crafted(card: CardData)

var _selected: Array[Affinity.Type] = []
var _essence_rows: Dictionary = {}
var _preview_box: VBoxContainer
var _cost_label: Label
var _hint_label: Label
var _craft_button: FancyButton
## Fable Nov 20: the brewed card's size in "The brew" panel (of CardView.SIZE).
const RESULT_CARD_SCALE: float = 1.1
var _stage: Control
var _cauldron: TextureRect
## Import Nov 8: the painted cauldron (Batch 13); the vector glyph stands in without it.
const CAULDRON_ART: String = "UI-CAULDRON"
## Batch 19 (Fable Nov 22 night): Auntie Alembic stirring the big cauldron under four glass pipes, the centre of "The brew" panel (it
## replaces the small cauldron; the bubbles and the flash of a brew start at the pot's mouth, `_pot_mouth`).
const BREW_ART: String = "UI-ALEMBIC-BREW"
const BREW_STAGE_HEIGHT: float = 320.0
var _pot_mouth: Vector2 = Vector2(350, 110)
var _brew_swing: float = 6.0
var _result_holder: Control
var _brewing: bool = false
var _gold_label: Label
## Fable Nov 21 castle (Part 8): one jar's cell on the shelf, the "pick two Paths, then brew" strip and its two slots.
const JAR_CELL: Vector2 = Vector2(270, 262)
var _steps: HBoxContainer
var _slots: Array[PanelContainer] = []
var _pool_title: Label


func _ready() -> void:
	screen_title = StoryText.shared().text("town.alchemist.name")
	title_icon_id = "ICON-UI-CRAFT"
	vendor_screen_id = "VS-ALEMBIC"
	vendor_inset = 500.0
	super._ready()


## Overnight Nov 19 (Part 3.7): the instructions at the top of the essence column.
static func instructions() -> String:
	return "Every copy of a card beyond your third turns into essence of its Path (more for rarer cards). A brew takes %d essence of each of two Paths, plus %d gold. Each Path holds at most %d essence: once a Path is full, extra copies of its cards add no more." % [Alchemy.MIN_ESSENCE_PER_PATH, Alchemy.GOLD_COST, Alchemy.ESSENCE_CAP_PER_PATH]


## The copy caps at the hero's level, as on the Character screen (Part 1 replaced the old four-copy rule).
func _caps_text() -> String:
	var level: int = Session.profile.level if Session.profile != null else 1
	return "%d Common, %d Uncommon, %d Epic, %d Legendary" % [CopyCaps.cap_for(CardEnums.Rarity.COMMON, level), CopyCaps.cap_for(CardEnums.Rarity.UNCOMMON, level), CopyCaps.cap_for(CardEnums.Rarity.EPIC, level), CopyCaps.cap_for(CardEnums.Rarity.LEGENDARY, level)]


func _build() -> void:
	# The same coin and number as every vendor's header (Overnight Oct 17, Phase 2, UI consistency).
	header_extra.add_child(IconArt.glyph_or("ICON-GOLD", CardIcons.ui("coins"), UIStyle.GOLD, 38.0))
	_gold_label = UIKit.label("", &"", 34, UIStyle.GOLD)
	_gold_label.add_theme_font_override("font", UIStyle.font_title())
	header_extra.add_child(_gold_label)
	var columns: HBoxContainer = UIKit.hbox(26)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(columns)
	columns.add_child(_build_essence_column())
	columns.add_child(_build_brew_column())
	_refresh()


func _build_essence_column() -> Control:
	var panel: PanelContainer = UIKit.panel(&"DarkPanel")
	panel.custom_minimum_size = Vector2(620.0 - _narrow(), 0)
	var column: VBoxContainer = UIKit.vbox(12)
	panel.add_child(column)
	column.add_child(UIKit.label("Your essence jars", &"HeadingLabel", 30))
	# Overnight Nov 19 (Part 3.7): you own up to 3 copies of every card, so a copy beyond the third converts; a brew costs 6 + 6; 18 is the cap.
	var blurb: Label = UIKit.label(instructions(), &"MutedLabel", 18)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.custom_minimum_size = Vector2(580.0 - _narrow(), 0)
	column.add_child(blurb)
	# Fable Nov 21 castle (Part 8): four glass jars on a shelf (2 x 2) in place of the cramped list - each fills to 18 with its number
	# on the glass and lights up when it is chosen for the brew. The buttons keep their names (EssenceRow<path>).
	var shelf: GridContainer = GridContainer.new()
	shelf.name = "JarShelf"
	shelf.columns = 2
	shelf.add_theme_constant_override("h_separation", 14)
	shelf.add_theme_constant_override("v_separation", 12)
	shelf.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(shelf)
	for path: Affinity.Type in Affinity.colored_types():
		var row: Button = Button.new()
		row.name = "EssenceRow%d" % int(path)
		row.toggle_mode = false  # Fixes Nov 8 (C3 F5): the screen owns the selection; a toggle button flipped itself and the first click looked lost
		row.custom_minimum_size = Vector2(JAR_CELL.x - _narrow() * 0.5, JAR_CELL.y)
		row.focus_mode = Control.FOCUS_ALL
		row.add_theme_stylebox_override("normal", UIStyle.box(Color(1, 1, 1, 0.04), UIStyle.affinity_color(path).darkened(0.35), 2, 14))
		row.add_theme_stylebox_override("hover", UIStyle.box(Color(1, 1, 1, 0.09), UIStyle.affinity_color(path), 3, 14))
		row.add_theme_stylebox_override("pressed", UIStyle.box(UIStyle.affinity_color(path).darkened(0.45), UIStyle.GOLD, 4, 14, 10))
		row.add_theme_stylebox_override("hover_pressed", UIStyle.box(UIStyle.affinity_color(path).darkened(0.4), UIStyle.GOLD, 4, 14, 10))
		row.add_theme_stylebox_override("focus", UIStyle.box(Color(0, 0, 0, 0), UIStyle.GOLD, 3, 14))
		row.add_theme_stylebox_override("disabled", UIStyle.box(Color(1, 1, 1, 0.02), Color(1, 1, 1, 0.08), 2, 14))
		row.pressed.connect(_toggle_path.bind(path))
		var jar: EssenceJar = EssenceJar.make(path, Alchemy.ESSENCE_CAP_PER_PATH)
		jar.position = Vector2((row.custom_minimum_size.x - EssenceJar.SIZE.x) * 0.5, 8)
		row.add_child(jar)
		var name_row: HBoxContainer = UIKit.hbox(6)
		name_row.alignment = BoxContainer.ALIGNMENT_CENTER
		name_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_row.position = Vector2(0, EssenceJar.SIZE.y + 10.0)
		name_row.custom_minimum_size = Vector2(row.custom_minimum_size.x, 30)
		name_row.size = name_row.custom_minimum_size
		row.add_child(name_row)
		var orb: TextureRect = IconArt.glyph_or(IconArt.essence_id(path), CardIcons.ui("gems"), UIStyle.affinity_color(path), 26.0)
		orb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_row.add_child(orb)
		var name_label: Label = UIKit.label(Affinity.display_name(path), &"", 22, UIStyle.PARCHMENT)
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_row.add_child(name_label)
		# the number is on the glass; this label keeps the count for screen readers of the tree (tests, smokes)
		var amount: Label = UIKit.label("0", &"", 18, Color.WHITE)
		amount.name = "Amount"
		amount.visible = false
		row.add_child(amount)
		# Overnight Nov 4-5, Part 1: a chosen jar says so - a gold tick and "Selected" (and the jar lights up).
		var tick: Label = UIKit.label("✓ Selected", &"", 18, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
		tick.name = "Selected"
		tick.add_theme_font_override("font", UIStyle.font_title())
		tick.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		tick.add_theme_constant_override("outline_size", 6)
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tick.position = Vector2(0, EssenceJar.SIZE.y + 38.0)
		tick.custom_minimum_size = Vector2(row.custom_minimum_size.x, 22)
		tick.size = tick.custom_minimum_size
		tick.visible = false
		row.add_child(tick)
		shelf.add_child(row)
		_essence_rows[path] = {"button": row, "jar": jar, "amount": amount, "tick": tick}
	column.add_child(UIKit.spacer(6))
	if Alchemy.tri_path_unlocked(Session.profile):
		var tri: Label = UIKit.label("TRI-PATH CRAFTING: with Primm gone the Paths mix freely, and the cauldron takes three. Pick three Paths for a tri-Path card (%d gold)." % Alchemy.TRI_GOLD_COST, &"MutedLabel", 20)
		tri.name = "TriPathHint"
		tri.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tri.custom_minimum_size = Vector2(580.0 - _narrow(), 0)
		column.add_child(tri)
	return panel


func _build_brew_column() -> Control:
	var panel: PanelContainer = UIKit.panel(&"DarkPanel")  # Fable Nov 21 castle: the same panel as the jars and as the other vendors
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var column: VBoxContainer = UIKit.vbox(12)
	panel.add_child(column)
	column.add_child(UIKit.label("The brew", &"HeadingLabel", 32))
	column.add_child(_build_steps())
	_cost_label = UIKit.label("", &"", 21, UIStyle.PARCHMENT)
	_cost_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_cost_label.custom_minimum_size = Vector2(700, 0)
	column.add_child(_cost_label)
	_stage = Control.new()
	_stage.custom_minimum_size = Vector2(700, 230)
	_stage.clip_contents = false
	column.add_child(_stage)
	if UiArt.has(BREW_ART):
		var scene: Texture2D = UiArt.texture(BREW_ART)
		var wide: float = BREW_STAGE_HEIGHT * scene.get_size().x / maxf(1.0, scene.get_size().y)
		_stage.custom_minimum_size = Vector2(700, BREW_STAGE_HEIGHT)
		_cauldron = TextureRect.new()
		_cauldron.texture = scene
		_cauldron.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_cauldron.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_cauldron.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_cauldron.size = Vector2(wide, BREW_STAGE_HEIGHT)
		_cauldron.pivot_offset = Vector2(wide * 0.5, BREW_STAGE_HEIGHT * 0.78)
		_cauldron.position = Vector2((700.0 - wide) * 0.5, 0.0)
		_pot_mouth = Vector2(350.0, BREW_STAGE_HEIGHT * 0.58)
		_brew_swing = 1.5  # she is in the picture: the whole scene only trembles
	elif UiArt.has(CAULDRON_ART):
		# Import Nov 8 (Batch 13, C3 F13): the painted copper cauldron replaces the flat green vector glyph.
		_cauldron = TextureRect.new()
		_cauldron.texture = UiArt.texture(CAULDRON_ART)
		_cauldron.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_cauldron.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_cauldron.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_cauldron.size = Vector2(230, 230)
		_cauldron.pivot_offset = Vector2(115, 132)
		_cauldron.position = Vector2(235, 2)
	else:
		_cauldron = CardIcons.glyph(CardIcons.named("lorc/cauldron"), Color("8fd36a"), Vector2(200, 200))
		_cauldron.size = Vector2(200, 200)
		_cauldron.pivot_offset = Vector2(100, 100)
		_cauldron.position = Vector2(250, 50)
	_cauldron.name = "Cauldron"
	_stage.add_child(_cauldron)
	_pool_title = UIKit.label("", &"", 20, UIStyle.GOLD)
	_pool_title.name = "PoolTitle"
	column.add_child(_pool_title)
	_preview_box = UIKit.vbox(6)
	_preview_box.name = "PossibleCards"
	_preview_box.position = Vector2(0, 0)
	_preview_box.custom_minimum_size = Vector2(700, 290)  # Fixes Nov 8 (C3 F5): space kept for the odds grid, so nothing jumps under the cursor
	column.add_child(_preview_box)
	_hint_label = UIKit.label("", &"MutedLabel", 20)
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.custom_minimum_size = Vector2(700, 0)
	column.add_child(_hint_label)
	_craft_button = FancyButton.make("Brew", &"PrimaryButton", Vector2(520, 88))
	_craft_button.name = "CraftButton"
	_craft_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_craft_button.pressed.connect(_craft)
	column.add_child(_craft_button)
	return panel


## "1 Pick two Paths  >  [slot] + [slot]  >  2 Brew": the flow in one strip, the slots filling with the chosen Paths' colours.
func _build_steps() -> Control:
	_steps = UIKit.hbox(10)
	_steps.name = "BrewSteps"
	_steps.alignment = BoxContainer.ALIGNMENT_CENTER
	_steps.add_child(_step_chip("StepPick", "1  Pick two Paths"))
	_slots = []
	for index: int in range(2):
		if index == 1:
			_steps.add_child(UIKit.label("+", &"", 30, UIStyle.GOLD))
		var slot: PanelContainer = PanelContainer.new()
		slot.name = "Slot%d" % index
		slot.custom_minimum_size = Vector2(170, 46)
		var text: Label = UIKit.label("", &"", 20, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
		text.name = "Text"
		slot.add_child(text)
		_steps.add_child(slot)
		_slots.append(slot)
	_steps.add_child(UIKit.label(">", &"", 30, UIStyle.GOLD))
	_steps.add_child(_step_chip("StepBrew", "2  Brew"))
	return _steps


func _step_chip(chip_name: String, words: String) -> PanelContainer:
	var chip: PanelContainer = PanelContainer.new()
	chip.name = chip_name
	chip.custom_minimum_size = Vector2(0, 46)
	var text: Label = UIKit.label(words, &"", 20, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	text.name = "Text"
	text.add_theme_font_override("font", UIStyle.font_title())
	chip.add_child(UIKit.margin(text, 10))
	return chip


## The step in hand is lit gold: picking until two (or three) Paths are chosen, brewing after.
func _refresh_steps() -> void:
	if _steps == null:
		return
	for index: int in range(_slots.size()):
		var slot: PanelContainer = _slots[index]
		var filled: bool = index < _selected.size()
		var colour: Color = UIStyle.affinity_color(_selected[index]) if filled else Color(1, 1, 1, 0.18)
		slot.add_theme_stylebox_override("panel", UIStyle.box(Color(colour.darkened(0.55), 0.9) if filled else Color(1, 1, 1, 0.04), colour, 3 if filled else 2, 10))
		var words: String = Affinity.display_name(_selected[index]) if filled else "empty"
		if index == 1 and _selected.size() == 3:
			words = "%s + %s" % [Affinity.display_name(_selected[1]), Affinity.display_name(_selected[2])]
		(slot.get_node("Text") as Label).text = words
		(slot.get_node("Text") as Label).add_theme_color_override("font_color", UIStyle.PARCHMENT if filled else UIStyle.MUTED)
	var ready: bool = _selected.size() >= 2
	for pair: Array in [["StepPick", not ready], ["StepBrew", ready]]:
		var chip: PanelContainer = _steps.get_node(str(pair[0])) as PanelContainer
		chip.add_theme_stylebox_override("panel", UIStyle.box(Color(UIStyle.GOLD.darkened(0.6), 0.9), UIStyle.GOLD, 3, 10) if bool(pair[1]) else UIStyle.box(Color(1, 1, 1, 0.04), Color(1, 1, 1, 0.2), 2, 10))
	if _pool_title != null:
		_pool_title.text = "" if not ready else "What this brew can make (hover a card to read it; a card you have never seen is face down)"


func _toggle_path(path: Affinity.Type) -> void:
	if _brewing:
		return
	if _selected.has(path):
		_selected.erase(path)
	else:
		# A jar short of essence can still be picked: the Craft button then says how much more it needs.
		if Session.profile.essence_of(path) < Alchemy.MIN_ESSENCE_PER_PATH:
			Audio.sfx(&"ui_error")
		if _selected.size() >= Alchemy.max_craft_paths(Session.profile):
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
		# Overnight Nov 19 (Part 3.6): white below the cap, gold when the jar is full.
		(entry["amount"] as Label).add_theme_color_override("font_color", UIStyle.GOLD if amount >= Alchemy.ESSENCE_CAP_PER_PATH else Color.WHITE)
		var button: Button = entry["button"] as Button
		var chosen: bool = _selected.has(path as Affinity.Type)
		var colour: Color = UIStyle.affinity_color(path as Affinity.Type)
		(entry["jar"] as EssenceJar).set_state(amount, chosen)
		button.add_theme_stylebox_override("normal", UIStyle.box(colour.darkened(0.5), UIStyle.GOLD, 4, 14, 10) if chosen else UIStyle.box(Color(1, 1, 1, 0.04), colour.darkened(0.35), 2, 14))
		button.add_theme_stylebox_override("hover", UIStyle.box(colour.darkened(0.42), UIStyle.GOLD, 4, 14, 10) if chosen else UIStyle.box(Color(1, 1, 1, 0.09), colour, 3, 14))
		button.set_meta("chosen", chosen)
		(entry["tick"] as Label).visible = chosen
		button.tooltip_text = "%d / %d essence needed to craft." % [amount, Alchemy.MIN_ESSENCE_PER_PATH] if amount < Alchemy.MIN_ESSENCE_PER_PATH else "Click to use this Path in the brew."
		if amount >= Alchemy.ESSENCE_CAP_PER_PATH:
			button.tooltip_text += "\nFull (%d): extra copies of %s cards add no more essence until you brew." % [Alchemy.ESSENCE_CAP_PER_PATH, Affinity.display_name(path as Affinity.Type)]
	_rebuild_preview()
	_refresh_steps()
	if _selected.size() == 3:
		var essence: Array[String] = []
		for path: Affinity.Type in _selected:
			essence.append("%d %s" % [Session.profile.essence_of(path), Affinity.display_name(path)])
		var tri_problem: String = Alchemy.tri_problem(Session.profile, Session.gold, _selected)
		_craft_button.disabled = _brewing or not tri_problem.is_empty()
		_cost_label.text = "Trade %d essence of each (you have %s) and %d gold for a random tri-Path card of all three." % [Alchemy.MIN_ESSENCE_PER_PATH, " + ".join(essence), Alchemy.TRI_GOLD_COST]
		_hint_label.text = ""
		_set_craft_text(Alchemy.TRI_GOLD_COST, 3, tri_problem)
		return
	var pair_ready: bool = _selected.size() == 2
	var pair_problem: String = "Pick two Paths" if not pair_ready else Alchemy.problem(Session.profile, Session.gold, _selected[0], _selected[1])
	_craft_button.disabled = _brewing or not pair_problem.is_empty()
	_set_craft_text(Alchemy.GOLD_COST, 2, pair_problem)
	if _selected.size() < 2:
		_cost_label.text = "Choose two Paths. The brew takes %d essence of each, plus %d gold, and gives you ONE random dual-Path card of those Paths. The rest stays in your jars." % [Alchemy.MIN_ESSENCE_PER_PATH, Alchemy.GOLD_COST]
		if Alchemy.tri_path_unlocked(Session.profile):
			_cost_label.text += " Or choose three for a tri-Path card (%d gold)." % Alchemy.TRI_GOLD_COST
		_hint_label.text = StoryText.shared().text("town.alchemist.need_more") if not Alchemy.can_craft_something(Session.profile) else ""
	else:
		var first: int = Session.profile.essence_of(_selected[0])
		var second: int = Session.profile.essence_of(_selected[1])
		_cost_label.text = "Trade %d %s + %d %s essence (of your %d + %d) and %d gold for a random %s / %s card." % [Alchemy.MIN_ESSENCE_PER_PATH, Affinity.display_name(_selected[0]), Alchemy.MIN_ESSENCE_PER_PATH, Affinity.display_name(_selected[1]), first, second, Alchemy.GOLD_COST, Affinity.display_name(_selected[0]), Affinity.display_name(_selected[1])]
		_hint_label.text = ""


## Overnight Nov 4-5, Part 1: the Craft button always shows its price ("Craft - 100 gold, 6 + 6") and, when it cannot be
## pressed, the reason on a second line ("Pick two Paths", "Need 6 more Necrocrat essence", "Need 100 gold").
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
		child.queue_free()
	if _selected.size() < 2:
		return
	var pool: Array[CardData] = Alchemy.possible_cards(Session.content, _selected[0], _selected[1]) if _selected.size() == 2 else Alchemy.tri_path_pool(Session.content, _selected)
	# Overnight Nov 4-5, Part 1: a pair has 16 cards; in one row they pushed the screen past its right edge. Two rows of 8.
	var row: GridContainer = GridContainer.new()
	row.columns = 8
	row.add_theme_constant_override("h_separation", 10)
	row.add_theme_constant_override("v_separation", 4)
	row.name = "PossibleRow"
	_preview_box.add_child(row)
	# Overnight Nov 19 (Part 3.8-3.9): no odds - under each card how many you own out of 3; a card never seen (owned, met in a battle,
	# a shop or a pack) is a card back until it is; hovering magnifies either, like the reward cards.
	for card: CardData in pool:
		var holder: VBoxContainer = UIKit.vbox(2)
		holder.name = "Possible_%s" % card.id
		var seen: bool = Session.has_seen(card.id)
		var view: Control = CardView.wrapped(card, 0.34, CardView.Mode.FULL if seen else CardView.Mode.BACK)
		view.name = "Card"
		if not seen:
			view.set_meta("unseen", true)
		view.mouse_filter = Control.MOUSE_FILTER_PASS
		CardHoverZoom.attach(view)
		holder.add_child(view)
		var owned: Label = UIKit.label("%d/%d" % [Session.owned_count(card.id), CopyCaps.own_cap(card)] if seen else "?/%d" % CopyCaps.own_cap(card), &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
		owned.name = "Owned"
		holder.add_child(owned)
		row.add_child(holder)


func _craft() -> void:
	if _brewing or _selected.size() < 2:
		return
	var first: Affinity.Type = _selected[0]
	var second: Affinity.Type = _selected[1]
	var result: Alchemy.Result = Session.craft_dual_card(first, second) if _selected.size() == 2 else Session.craft_tri_card(_selected.duplicate())
	if not result.ok:
		Audio.sfx(&"ui_error")
		_hint_label.text = result.reason
		return
	_brewing = true
	_clear_result()
	_craft_button.disabled = true
	_play_brew(first, second, result)


## The brewing animation: the cauldron shakes and glows, motes of both Path colors spiral into it, a flash, then the card
## rises out of the pot, flipped face-up with a glow.
func _play_brew(first: Affinity.Type, second: Affinity.Type, result: Alchemy.Result) -> void:
	Audio.sfx(&"craft_brew")
	var color_a: Color = UIStyle.affinity_color(first)
	var color_b: Color = UIStyle.affinity_color(second)
	var shake: Tween = create_tween()
	for index: int in range(10):
		shake.tween_property(_cauldron, "rotation_degrees", _brew_swing if index % 2 == 0 else -_brew_swing, 0.12)
	shake.tween_property(_cauldron, "rotation_degrees", 0.0, 0.1)
	var glow: Tween = create_tween()
	glow.tween_property(_cauldron, "modulate", Color(1.6, 1.6, 1.6), 1.2)
	for index: int in range(18):
		var mote: Panel = Panel.new()
		mote.size = Vector2(16, 16)
		mote.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mote.add_theme_stylebox_override("panel", UIStyle.box(color_a if index % 2 == 0 else color_b, Color(1, 1, 1, 0.6), 2, 8, 6))
		var angle: float = TAU * float(index) / 18.0
		mote.position = _pot_mouth + Vector2(0, 100) + Vector2(cos(angle), sin(angle)) * 300.0
		_stage.add_child(mote)
		var spiral: Tween = mote.create_tween()
		spiral.tween_interval(0.05 * float(index % 6))
		spiral.tween_property(mote, "position", _pot_mouth + Vector2(-8, 10), 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		spiral.tween_callback(mote.queue_free)
	# Fable Nov 21 castle (Part 8): the pot boils - bubbles in both colours rise out of it and burst
	if not Settings.reduce_motion:
		for index: int in range(BREW_BUBBLES):
			var bubble: Panel = Panel.new()
			var wide: float = 10.0 + float(index % 4) * 5.0
			bubble.name = "Bubble%d" % index
			bubble.size = Vector2(wide, wide)
			bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bubble.add_theme_stylebox_override("panel", UIStyle.box(Color(color_a if index % 2 == 0 else color_b, 0.75), Color(1, 1, 1, 0.75), 2, int(wide * 0.5)))
			bubble.position = Vector2(_pot_mouth.x - 50.0 + float((index * 37) % 100), _pot_mouth.y)
			bubble.modulate.a = 0.0
			_stage.add_child(bubble)
			var up: Tween = bubble.create_tween()
			up.tween_interval(0.08 * float(index))
			up.tween_property(bubble, "modulate:a", 1.0, 0.1)
			up.parallel().tween_property(bubble, "position:y", _pot_mouth.y - 140.0 - float((index * 53) % 70), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			up.parallel().tween_property(bubble, "position:x", bubble.position.x + (30.0 if index % 2 == 0 else -30.0), 0.9)
			up.tween_property(bubble, "scale", Vector2(1.7, 1.7), 0.08)
			up.parallel().tween_property(bubble, "modulate:a", 0.0, 0.08)
			up.tween_callback(bubble.queue_free)
	_brew_colours = [color_a, color_b] as Array[Color]
	var timer: SceneTreeTimer = get_tree().create_timer(1.5, false)
	timer.timeout.connect(func() -> void: _reveal(result))


const BREW_BUBBLES: int = 14
var _brew_colours: Array[Color] = [Color.WHITE]


func _reveal(result: Alchemy.Result) -> void:
	# A three-Path (postgame) craft has its own sting.
	Audio.sting(&"STG-CRAFT-POST" if result.paths.size() >= 3 else &"STG-CRAFT")
	_cauldron.modulate = Color.WHITE
	# Fable Nov 21 castle (Part 8): the flash is in the two Paths' colours, one after the other, not plain white
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
	# Fable Nov 20 (Part 3.1): the new card large and centred in "The brew" panel, its line underneath (wrapped, never over the
	# card); hovering it magnifies it like a reward card. It takes the place of the cauldron and the possible-cards grid until the
	# next brew or the next jar click.
	var brew_column: Node = _stage.get_parent()
	var box: VBoxContainer = UIKit.vbox(14)
	box.name = "CraftResult"
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.custom_minimum_size = Vector2(700, _stage.custom_minimum_size.y + _preview_box.custom_minimum_size.y + 12.0)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_result_holder = box
	var holder: Control = CardView.wrapped(result.card, RESULT_CARD_SCALE)
	holder.name = "CraftedCard"
	holder.mouse_filter = Control.MOUSE_FILTER_PASS
	CardHoverZoom.attach(holder)
	# a plain frame keeps the card's place while it rises (a container would reset the card's scale)
	var frame: Control = Control.new()
	frame.name = "CraftedCardFrame"
	frame.custom_minimum_size = holder.custom_minimum_size
	frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(frame)
	frame.add_child(holder)
	holder.size = holder.custom_minimum_size
	holder.pivot_offset = holder.custom_minimum_size * 0.5
	holder.scale = Vector2(0.1, 0.1)
	holder.position = Vector2(0, 160)
	var rise: Tween = holder.create_tween().set_parallel(true)
	rise.tween_property(holder, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	rise.tween_property(holder, "position", Vector2(0, 0), 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var caption: Label = UIKit.label("%s joins your collection!" % result.card.display_name, &"HeadingLabel", 26, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	caption.name = "CraftCaption"
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.custom_minimum_size = Vector2(660, 0)
	caption.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(caption)
	brew_column.add_child(box)
	brew_column.move_child(box, _stage.get_index())
	_stage.visible = false
	_preview_box.visible = false
	if _pool_title != null:
		_pool_title.visible = false
	_brewing = false
	# Fable Nov 20 (Part 3.2): the two (or three) chosen essences stay chosen, so the next brew is one click away while there is
	# enough essence and gold (the Craft button says what is missing otherwise).
	vendor_react("buy")
	crafted.emit(result.card)
	_refresh()


func _clear_result() -> void:
	if _result_holder != null and is_instance_valid(_result_holder):
		_result_holder.queue_free()
		_result_holder = null
	if _cauldron != null:
		_cauldron.visible = true
	if _stage != null:
		_stage.visible = true
	if _preview_box != null:
		_preview_box.visible = true
	if _pool_title != null:
		_pool_title.visible = true


## The essence column is this much narrower next to Auntie Alembic (the vendor stage takes the left side).
func _narrow() -> float:
	return 0.0 if stage == null else 100.0
