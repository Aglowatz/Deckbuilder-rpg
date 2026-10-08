class_name AlchemistScreen
extends OverlayScreen
## Auntie Alembic's (Part F): the Alchemist's crafting UI. Left: the player's Path essence (click up to two Paths
## that have enough to take part). Right: what the trade costs (ALL essence of both Paths plus gold), the four
## dual-Path cards it can produce with their odds, and the Craft button, which plays a short brewing animation
## (a bubbling cauldron, swirling motes in both Path colors) before the card is revealed. Rules: `Alchemy`.

signal crafted(card: CardData)

var _selected: Array[Affinity.Type] = []
var _essence_rows: Dictionary = {}
var _preview_box: VBoxContainer
var _cost_label: Label
var _hint_label: Label
var _craft_button: FancyButton
var _stage: Control
var _cauldron: TextureRect
var _result_holder: Control
var _brewing: bool = false
var _gold_label: Label


func _ready() -> void:
	screen_title = StoryText.shared().text("town.alchemist.name")
	super._ready()


func _build() -> void:
	_gold_label = UIKit.label("", &"", 28, UIStyle.GOLD)
	header_extra.add_child(_gold_label)
	var columns: HBoxContainer = UIKit.hbox(26)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(columns)
	columns.add_child(_build_essence_column())
	columns.add_child(_build_brew_column())
	_refresh()


func _build_essence_column() -> Control:
	var panel: PanelContainer = UIKit.panel(&"DarkPanel")
	panel.custom_minimum_size = Vector2(620, 0)
	var column: VBoxContainer = UIKit.vbox(12)
	panel.add_child(column)
	column.add_child(UIKit.label("Your Path essence", &"HeadingLabel", 32))
	var blurb: Label = UIKit.label("Every copy of a card beyond the fourth turns into essence of its Path (more for rarer cards). Pick two Paths with at least %d essence each." % Alchemy.MIN_ESSENCE_PER_PATH, &"MutedLabel", 20)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.custom_minimum_size = Vector2(580, 0)
	column.add_child(blurb)
	for path: Affinity.Type in Affinity.colored_types():
		var row: Button = Button.new()
		row.name = "EssenceRow%d" % int(path)
		row.toggle_mode = true
		row.custom_minimum_size = Vector2(580, 82)
		row.focus_mode = Control.FOCUS_NONE
		row.add_theme_stylebox_override("normal", UIStyle.box(Color(1, 1, 1, 0.05), UIStyle.affinity_color(path).darkened(0.3), 2, 12))
		row.add_theme_stylebox_override("hover", UIStyle.box(Color(1, 1, 1, 0.09), UIStyle.affinity_color(path), 3, 12))
		row.add_theme_stylebox_override("pressed", UIStyle.box(UIStyle.affinity_color(path).darkened(0.55), UIStyle.GOLD, 4, 12))
		row.add_theme_stylebox_override("disabled", UIStyle.box(Color(1, 1, 1, 0.02), Color(1, 1, 1, 0.08), 2, 12))
		row.pressed.connect(_toggle_path.bind(path))
		var inner: HBoxContainer = UIKit.hbox(14)
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		inner.offset_left = 14
		inner.offset_right = -14
		row.add_child(inner)
		var orb: TextureRect = CardIcons.glyph(CardIcons.ui("gems"), UIStyle.affinity_color(path), Vector2(48, 48))
		orb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_child(orb)
		var name_label: Label = UIKit.label("%s essence" % Affinity.display_name(path), &"", 26, UIStyle.PARCHMENT)
		name_label.custom_minimum_size = Vector2(250, 0)
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_child(name_label)
		var bar: ProgressBar = ProgressBar.new()
		bar.custom_minimum_size = Vector2(140, 18)
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bar.show_percentage = false
		bar.max_value = Alchemy.MIN_ESSENCE_PER_PATH
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.add_theme_stylebox_override("fill", UIStyle.box(UIStyle.affinity_color(path), Color(0, 0, 0, 0), 0, 6))
		inner.add_child(bar)
		var amount: Label = UIKit.label("0", &"", 34, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_RIGHT)
		amount.name = "Amount"
		amount.custom_minimum_size = Vector2(70, 0)
		amount.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_child(amount)
		column.add_child(row)
		_essence_rows[path] = {"button": row, "bar": bar, "amount": amount}
	column.add_child(UIKit.spacer(6))
	if Alchemy.tri_path_unlocked(Session.profile):
		var tri: Label = UIKit.label("TRI-PATH CRAFTING UNLOCKED: with Primm gone the Paths may mix freely, and the cauldron will take three. (No tri-Path recipes exist yet; the hook is ready.)", &"MutedLabel", 20)
		tri.name = "TriPathHint"
		tri.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tri.custom_minimum_size = Vector2(580, 0)
		column.add_child(tri)
	return panel


func _build_brew_column() -> Control:
	var panel: PanelContainer = UIKit.panel()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var column: VBoxContainer = UIKit.vbox(12)
	panel.add_child(column)
	column.add_child(UIKit.label("The brew", &"HeadingLabel", 32))
	_cost_label = UIKit.label("", &"", 24, UIStyle.PARCHMENT)
	_cost_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_cost_label.custom_minimum_size = Vector2(700, 0)
	column.add_child(_cost_label)
	_stage = Control.new()
	_stage.custom_minimum_size = Vector2(700, 330)
	_stage.clip_contents = false
	column.add_child(_stage)
	_cauldron = CardIcons.glyph(CardIcons.named("lorc/cauldron"), Color("8fd36a"), Vector2(200, 200))
	_cauldron.name = "Cauldron"
	_cauldron.size = Vector2(200, 200)
	_cauldron.pivot_offset = Vector2(100, 100)
	_cauldron.position = Vector2(250, 110)
	_stage.add_child(_cauldron)
	_preview_box = UIKit.vbox(6)
	_preview_box.name = "PossibleCards"
	_preview_box.position = Vector2(0, 0)
	column.add_child(_preview_box)
	_hint_label = UIKit.label("", &"MutedLabel", 22)
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.custom_minimum_size = Vector2(700, 0)
	column.add_child(_hint_label)
	_craft_button = FancyButton.make("Craft", &"PrimaryButton", Vector2(340, 66))
	_craft_button.name = "CraftButton"
	_craft_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_craft_button.pressed.connect(_craft)
	column.add_child(_craft_button)
	return panel


func _toggle_path(path: Affinity.Type) -> void:
	if _brewing:
		return
	if _selected.has(path):
		_selected.erase(path)
	else:
		if Session.profile.essence_of(path) < Alchemy.MIN_ESSENCE_PER_PATH:
			Audio.sfx(&"ui_error")
			_refresh()
			return
		if _selected.size() >= Alchemy.max_craft_paths(Session.profile) or _selected.size() >= 2:
			_selected.remove_at(0)
		_selected.append(path)
	Audio.sfx(&"ui_tick")
	_clear_result()
	_refresh()


func _refresh() -> void:
	_gold_label.text = "%d gold" % Session.gold
	for path: Variant in _essence_rows.keys():
		var entry: Dictionary = _essence_rows[path]
		var amount: int = Session.profile.essence_of(path as Affinity.Type)
		(entry["amount"] as Label).text = str(amount)
		(entry["bar"] as ProgressBar).value = float(mini(amount, Alchemy.MIN_ESSENCE_PER_PATH))
		var button: Button = entry["button"] as Button
		button.button_pressed = _selected.has(path as Affinity.Type)
		button.tooltip_text = "%d / %d essence needed to craft." % [amount, Alchemy.MIN_ESSENCE_PER_PATH] if amount < Alchemy.MIN_ESSENCE_PER_PATH else "Click to use this Path in the brew."
	_rebuild_preview()
	var pair_ready: bool = _selected.size() == 2
	_craft_button.disabled = _brewing or not pair_ready or not Alchemy.can_craft(Session.profile, Session.gold, _selected[0], _selected[1])
	if _selected.size() < 2:
		_cost_label.text = "Choose two Paths. The brew takes ALL of your essence of both, plus %d gold, and gives you ONE random dual-Path card of those Paths." % Alchemy.GOLD_COST
		_hint_label.text = StoryText.shared().text("town.alchemist.need_more") if not Alchemy.can_craft_something(Session.profile) else ""
	else:
		var first: int = Session.profile.essence_of(_selected[0])
		var second: int = Session.profile.essence_of(_selected[1])
		_cost_label.text = "Trade %d %s + %d %s essence and %d gold for a random %s / %s card." % [first, Affinity.display_name(_selected[0]), second, Affinity.display_name(_selected[1]), Alchemy.GOLD_COST, Affinity.display_name(_selected[0]), Affinity.display_name(_selected[1])]
		_hint_label.text = Alchemy.problem(Session.profile, Session.gold, _selected[0], _selected[1])


func _rebuild_preview() -> void:
	for child: Node in _preview_box.get_children():
		child.queue_free()
	if _selected.size() != 2:
		return
	var pool: Array[CardData] = Alchemy.possible_cards(Session.content, _selected[0], _selected[1])
	var total: int = Session.profile.essence_of(_selected[0]) + Session.profile.essence_of(_selected[1])
	var weights: Array[int] = Alchemy.weights_for(total)
	var weight_sum: int = 0
	for card: CardData in pool:
		weight_sum += weights[int(card.rarity)]
	var row: HBoxContainer = UIKit.hbox(14)
	row.name = "PossibleRow"
	_preview_box.add_child(row)
	for card: CardData in pool:
		var holder: VBoxContainer = UIKit.vbox(2)
		holder.add_child(CardView.wrapped(card, 0.4))
		var odds: Label = UIKit.label("%d%%" % roundi(100.0 * float(weights[int(card.rarity)]) / float(maxi(1, weight_sum))), &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
		holder.add_child(odds)
		row.add_child(holder)


func _craft() -> void:
	if _brewing or _selected.size() != 2:
		return
	var first: Affinity.Type = _selected[0]
	var second: Affinity.Type = _selected[1]
	var result: Alchemy.Result = Session.craft_dual_card(first, second)
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
	Audio.sfx(&"spell")
	var color_a: Color = UIStyle.affinity_color(first)
	var color_b: Color = UIStyle.affinity_color(second)
	var shake: Tween = create_tween()
	for index: int in range(10):
		shake.tween_property(_cauldron, "rotation_degrees", 6.0 if index % 2 == 0 else -6.0, 0.12)
	shake.tween_property(_cauldron, "rotation_degrees", 0.0, 0.1)
	var glow: Tween = create_tween()
	glow.tween_property(_cauldron, "modulate", Color(1.6, 1.6, 1.6), 1.2)
	for index: int in range(18):
		var mote: Panel = Panel.new()
		mote.size = Vector2(16, 16)
		mote.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mote.add_theme_stylebox_override("panel", UIStyle.box(color_a if index % 2 == 0 else color_b, Color(1, 1, 1, 0.6), 2, 8, 6))
		var angle: float = TAU * float(index) / 18.0
		mote.position = Vector2(350, 210) + Vector2(cos(angle), sin(angle)) * 300.0
		_stage.add_child(mote)
		var spiral: Tween = mote.create_tween()
		spiral.tween_interval(0.05 * float(index % 6))
		spiral.tween_property(mote, "position", Vector2(342, 202), 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		spiral.tween_callback(mote.queue_free)
	var timer: SceneTreeTimer = get_tree().create_timer(1.5, false)
	timer.timeout.connect(func() -> void: _reveal(result))


func _reveal(result: Alchemy.Result) -> void:
	Audio.sfx(&"victory")
	_cauldron.modulate = Color.WHITE
	var flash: ColorRect = ColorRect.new()
	flash.color = Color(1, 1, 1, 0.0)
	UIKit.full_rect(flash)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	var flash_tween: Tween = flash.create_tween()
	flash_tween.tween_property(flash, "color:a", 0.7, 0.1)
	flash_tween.tween_property(flash, "color:a", 0.0, 0.5)
	flash_tween.tween_callback(flash.queue_free)
	_result_holder = Control.new()
	_result_holder.name = "CraftResult"
	_result_holder.position = Vector2(240, 10)
	_stage.add_child(_result_holder)
	var holder: Control = CardView.wrapped(result.card, 0.7)
	holder.pivot_offset = holder.custom_minimum_size * 0.5
	holder.scale = Vector2(0.1, 0.1)
	holder.position = Vector2(0, 160)
	_result_holder.add_child(holder)
	var rise: Tween = holder.create_tween().set_parallel(true)
	rise.tween_property(holder, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	rise.tween_property(holder, "position", Vector2(0, 0), 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var caption: Label = UIKit.label("%s joins your collection!" % result.card.display_name, &"HeadingLabel", 26, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	caption.name = "CraftCaption"
	caption.position = Vector2(-120, 300)
	caption.size = Vector2(500, 36)
	_result_holder.add_child(caption)
	_brewing = false
	_selected.clear()
	crafted.emit(result.card)
	_refresh()
	_cauldron.visible = false


func _clear_result() -> void:
	if _result_holder != null and is_instance_valid(_result_holder):
		_result_holder.queue_free()
		_result_holder = null
	if _cauldron != null:
		_cauldron.visible = true
