class_name TownHud
extends Control
## The town's overlay: objective, gold, "press E" prompt, toast messages and control hints.

signal character_pressed
signal deck_pressed
signal quests_pressed
signal wardrobe_pressed
signal packs_pressed

var _menu_button: FancyButton
var _menu_panel: PanelContainer
var _left_column: VBoxContainer
var _effects_panel: Control
var _gold: Label
var _prompt_panel: PanelContainer
var _prompt_label: Label
var _prompt_glyph: PadGlyph
var _prompt_template: String = ""
var _toast: Label
var _toast_tween: Tween
var _gold_panel: PanelContainer
## Fixes Oct 25, Part 6: the Menu button and its Packs entry glow while Make It Yours waits for a pack to be opened.
var _packs_item: FancyButton
var _packs_hint: bool = false
var _hint_badge: Label
var _item_badge: Label
var _hint_time: float = 0.0

## HUD panels take this much of the UI scale (the minimap above them takes the same), so the right column stays tidy at 150 percent.
const HUD_SCALE_STRENGTH: float = 0.55
## Where the right column sits at a scale of 100 percent: the minimap bottom (20 + 250), the gold panel, the Menu button and its list.
const RIGHT_COLUMN_Y: Array[float] = [282.0, 346.0, 408.0]


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var left_column: VBoxContainer = UIKit.vbox(10)
	left_column.position = Vector2(30, 28)
	left_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(left_column)
	_left_column = left_column
	# Oct 16: the quest tracker is the only headline (the "Crosspath - N of 4 zones free" box is gone); zone effects sit under it as a chip.
	left_column.add_child(QuestTracker.new())
	var gold_panel: PanelContainer = UIKit.panel(&"DarkPanel")
	gold_panel.position = Vector2(1650, 282)
	add_child(gold_panel)
	var gold_row: HBoxContainer = UIKit.hbox(10)
	gold_panel.add_child(gold_row)
	gold_row.add_child(IconArt.glyph_or("ICON-GOLD", CardIcons.ui("coins"), UIStyle.GOLD, 34.0))
	_gold = UIKit.label("0", &"", 30, UIStyle.GOLD)
	_gold.add_theme_font_override("font", UIStyle.font_title())
	gold_row.add_child(_gold)
	_menu_button = FancyButton.make("Menu", &"PrimaryButton", Vector2(180, 52))
	_menu_button.name = "MenuButton"
	_menu_button.position = Vector2(1650, 346)
	_menu_button.pressed.connect(toggle_menu)
	add_child(_menu_button)
	_menu_panel = UIKit.panel()
	_menu_panel.name = "MenuPanel"
	_menu_panel.position = Vector2(1650, 408)
	_menu_panel.visible = false
	add_child(_menu_panel)
	var menu_column: VBoxContainer = UIKit.vbox(6)
	_menu_panel.add_child(menu_column)
	for entry: Array in [["Character ({open_character})", character_pressed, "ICON-UI-CHARACTER"], ["Deck ({open_deck})", deck_pressed, "ICON-UI-DECK"], ["Quests ({open_quests})", quests_pressed, "ICON-UI-QUESTS"], ["Packs ({open_packs})", packs_pressed, "ICON-UI-PACKS"], ["Wardrobe ({open_wardrobe})", wardrobe_pressed, "ICON-UI-WARDROBE"]]:
		var item: FancyButton = FancyButton.make("", &"", Vector2(200, 48))
		PromptText.bind(item, str(entry[0]))
		item.name = "Menu_%s" % str(entry[0]).split(" ")[0]
		IconArt.button_icon(item, str(entry[2]), 30.0)
		var signal_ref: Signal = entry[1] as Signal
		item.pressed.connect(func() -> void:
			close_menu()
			signal_ref.emit())
		menu_column.add_child(item)
		if signal_ref == packs_pressed:
			_packs_item = item
	# Fresh eyes Oct 30: the pause menu's pages a new player never finds behind Esc - the Glossary (keywords, resources), the Feats and
	# Settings - listed here too. Each opens the pause menu on that page.
	for extra: Array in [["Glossary", SceneManager.show_glossary_page, ""], ["Feats", SceneManager.show_feats_page, ""], ["Settings", SceneManager.show_settings_page, "ICON-UI-SETTINGS"]]:
		var page: FancyButton = FancyButton.make(str(extra[0]), &"", Vector2(200, 48))
		page.name = "Menu_%s" % str(extra[0])
		if not str(extra[2]).is_empty():
			IconArt.button_icon(page, str(extra[2]), 30.0)
		var opener: Callable = extra[1] as Callable
		page.pressed.connect(func() -> void:
			close_menu()
			opener.call())
		menu_column.add_child(page)
	PadFocus.register(_menu_panel)
	_prompt_panel = UIKit.panel()
	_prompt_panel.position = Vector2(700, 900)
	_prompt_panel.visible = false
	add_child(_prompt_panel)
	# Controller support (Oct 26): a drawn A (or Cross) before the prompt while a pad is in use, instead of "[E]"
	var prompt_row: HBoxContainer = UIKit.hbox(12)
	_prompt_panel.add_child(prompt_row)
	_prompt_glyph = PadGlyph.make(&"interact", 38.0)
	_prompt_glyph.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_prompt_glyph.visible = false
	prompt_row.add_child(_prompt_glyph)
	_prompt_label = UIKit.label("", &"", 30, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	prompt_row.add_child(_prompt_label)
	EventBus.input_device_changed.connect(func(_pad: bool) -> void:
		if _prompt_panel.visible:
			show_prompt(_prompt_template))
	_toast = UIKit.label("", &"", 32, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_toast.add_theme_font_override("font", UIStyle.font_bold())
	_toast.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_toast.add_theme_constant_override("outline_size", 8)
	_toast.position = Vector2(460, 780)
	_toast.size = Vector2(1000, 44)
	# Overnight Oct 18: long toasts (the zone's Path warning) wrap and grow upward from the same bottom line.
	_toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_toast.modulate.a = 0.0
	add_child(_toast)
	# Phase 2 cycle 7: the line ran off the right edge; the Menu button names itself, so it is not listed here.
	var hints: Label = UIKit.label("", &"MutedLabel", 20, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_RIGHT)
	hints.name = "HintLine"
	bind_hints(hints, "%s: move      {hint:interact} / Click: interact      {open_map}: map      {pause}: menu" % _move_keys_text(), true)
	hints.position = Vector2(560, 1030)
	hints.size = Vector2(1340, 30)
	add_child(hints)
	EventBus.gold_changed.connect(set_gold)
	set_gold(Session.gold)
	UiScale.corner(self, [left_column, gold_panel, _menu_button, _menu_panel] as Array[Control], HUD_SCALE_STRENGTH)
	_gold_panel = gold_panel
	Settings.ui_scale_changed.connect(_stack_right_column)
	_stack_right_column()
	EventBus.quest_changed.connect(_sync_packs_hint)
	EventBus.packs_changed.connect(_sync_packs_hint)
	_sync_packs_hint()


func _sync_packs_hint() -> void:
	set_packs_hint(Session.pack_step_open())


## Fixes Oct 25, Part 6: lights the way to the packs (a pulsing Menu button with a "!", and the Packs entry once the menu is open).
func set_packs_hint(on: bool) -> void:
	if on == _packs_hint:
		return
	_packs_hint = on
	if on and _hint_badge == null:
		_hint_badge = _make_hint_badge("PacksHintBadge", Vector2(-34, -6))
		_menu_button.add_child(_hint_badge)
		if _packs_item != null:
			_item_badge = _make_hint_badge("PacksItemBadge", Vector2(-30, -4))
			_packs_item.add_child(_item_badge)
	for badge: Label in [_hint_badge, _item_badge]:
		if badge != null:
			badge.visible = on
	if not on:
		_menu_button.modulate = Color.WHITE
		if _packs_item != null:
			_packs_item.modulate = Color.WHITE


func _make_hint_badge(badge_name: String, at: Vector2) -> Label:
	var badge: Label = UIKit.label("!", &"", 44, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	badge.name = badge_name
	badge.add_theme_font_override("font", UIStyle.font_bold())
	badge.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	badge.add_theme_constant_override("outline_size", 10)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.position = at
	badge.pivot_offset = Vector2(12, 28)
	return badge


func packs_hint_shown() -> bool:
	return _packs_hint


func _pulse_packs_hint(delta: float) -> void:
	if not _packs_hint:
		return
	_hint_time += delta
	var glow: float = 0.5 + 0.5 * sin(_hint_time * 4.0)
	var lit: Color = Color(1.0 + 0.6 * glow, 1.0 + 0.45 * glow, 1.0 - 0.3 * glow)
	_menu_button.modulate = lit
	if _packs_item != null:
		_packs_item.modulate = lit
	for badge: Label in [_hint_badge, _item_badge]:
		if badge != null:
			badge.scale = Vector2.ONE * (1.0 + 0.2 * glow)


func set_gold(amount: int) -> void:
	_gold.text = str(amount)


## Part C: the active zone's buff and debuff, shown under the objective while in a zone. Playtest v0.4.0 Part F: an icon row (hover an
## icon for its text, click for the full list) in place of the old text pill - the same badges the node map and the battle HUD show.
func show_zone_effects(effect: ZoneEffects.Effect, zone_title: String) -> void:
	if _effects_panel != null:
		_effects_panel.queue_free()
		_effects_panel = null
	if effect == null:
		return
	var badges: Array[RuleBadges.Badge] = RuleBadges.for_zone(effect.zone_id)
	if badges.is_empty():
		return
	var row: RuleIconRow = RuleIconRow.make(badges, "%s: zone effects" % zone_title)
	row.name = "ZoneEffectsRow"
	_effects_panel = row
	_left_column.add_child(row)


## Any extra panel under the objective (the Capital's broken services).
func add_panel(panel: Control) -> void:
	_left_column.add_child(panel)


## Removed Oct 16 (the location and zone-progress header cluttered the HUD; the title card names the place). Kept so scenes can still call it.
func set_location(_town_name: String, _progress: String) -> void:
	pass


## The objective box was removed (the quest tracker replaces it); kept so scenes can still call it.
func set_objective(_bbcode: String) -> void:
	pass


## Controller support (Oct 26): the bottom-right hint line of a world scene, in keyboard words or controller words (`full` adds the HUD menu).
static func bind_hints(label: Label, keyboard_text: String, full: bool) -> void:
	var pad_text: String = "Left stick: move      {interact}: interact      {open_map}: map      {pause}: pause"
	if full:
		pad_text += "      {open_menu}: menu      {open_deck}: deck"
	PromptText.bind(label, keyboard_text, &"text", pad_text)


## Opens the HUD menu (D-pad Up) with its first entry focused, or closes it when open.
func open_menu_focused() -> void:
	if _menu_panel.visible:
		close_menu()
		Audio.sfx(&"ui_tick")
		return
	toggle_menu()
	PadFocus.focus_into(_menu_panel)


func is_menu_open() -> bool:
	return _menu_panel.visible


## The pad's B closes the HUD menu (Esc keeps opening the pause menu, as before).
func _unhandled_input(event: InputEvent) -> void:
	if _menu_panel.visible and event is InputEventJoypadButton and UiInput.is_back(event):
		get_viewport().set_input_as_handled()
		close_menu()
		Audio.sfx(&"ui_tick")


func show_prompt(text: String) -> void:
	_prompt_template = text
	var pad_glyph: bool = InputDevice.using_pad() and text.begins_with("[E]") and Keybinds.pad_of(&"interact") != Keybinds.PAD_NONE
	_prompt_glyph.visible = pad_glyph
	_prompt_label.text = text.trim_prefix("[E]").strip_edges() if pad_glyph else PromptText.render(text)
	_prompt_panel.visible = true
	_prompt_panel.reset_size()
	_prompt_panel.position.x = (1920.0 - _prompt_panel.size.x) * 0.5


func hide_prompt() -> void:
	_prompt_panel.visible = false


var _queue: Array = []
var _queue_timer: float = 0.0


## Toasts that must each be readable (several quest notices at once) - shown one after another.
func queue_toast(message: String, color: Color = UIStyle.PARCHMENT) -> void:
	_queue.append([message, color])


func _process(delta: float) -> void:
	_pulse_packs_hint(delta)
	_queue_timer -= delta
	if _queue_timer <= 0.0 and not _queue.is_empty():
		var entry: Array = _queue.pop_front()
		toast(str(entry[0]), entry[1] as Color)
		_queue_timer = 2.4


func toast(message: String, color: Color = UIStyle.PARCHMENT, hold: float = 2.0) -> void:
	_toast.text = message
	var lines: int = maxi(1, _toast.get_line_count())
	_toast.size = Vector2(1000, 44 * lines)
	_toast.position.y = 824.0 - 44.0 * lines
	_toast.add_theme_color_override("font_color", color)
	if _toast_tween != null and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast.modulate.a = 1.0
	_toast_tween = create_tween()
	_toast_tween.tween_interval(hold)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.5)


func toggle_menu() -> void:
	_menu_panel.visible = not _menu_panel.visible
	Audio.sfx(&"ui_tick")


func close_menu() -> void:
	_menu_panel.visible = false


## The movement keys for the hint line: the primary keys as "W A S D", plus "arrows" when the secondary ones are the arrow keys.
func _move_keys_text() -> String:
	var primary: PackedStringArray = []
	var secondary: PackedStringArray = []
	for action: StringName in [&"move_up", &"move_left", &"move_down", &"move_right"]:
		var keys: Array[int] = Keybinds.keys_of(action)
		primary.append(Keybinds.key_text(keys[0]))
		secondary.append(Keybinds.key_text(keys[1]))
	var text: String = " ".join(primary)
	if secondary != PackedStringArray(["Up", "Left", "Down", "Right"]):
		return text + (" / " + " ".join(secondary) if secondary != PackedStringArray(["-", "-", "-", "-"]) else "")
	return text + " / arrows"


## Moves the gold counter, the Menu button and its list down by what the (scaled) minimap and the panels above them gained, so nothing overlaps.
func _stack_right_column() -> void:
	if _gold_panel == null or _menu_button == null or _menu_panel == null:
		return
	var factor: float = 1.0 + (Settings.ui_scale - 1.0) * HUD_SCALE_STRENGTH
	var shift: float = 250.0 * (factor - 1.0)
	_gold_panel.position.y = RIGHT_COLUMN_Y[0] + shift
	_menu_button.position.y = RIGHT_COLUMN_Y[1] + shift + _gold_panel.size.y * (factor - 1.0)
	_menu_panel.position.y = RIGHT_COLUMN_Y[2] + shift + (_gold_panel.size.y + _menu_button.size.y) * (factor - 1.0)
