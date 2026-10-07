class_name BattleHud
extends Control
## Everything around the card table: player portraits with HP and energy orbs, the turn and
## phase tracker, deck/graveyard counters, the prompt line, the action buttons, the card zoom
## preview with keyword tooltips, and the "your turn" banner.

signal primary_pressed
signal end_turn_pressed
signal attack_all_pressed

const PHASE_NAMES: Array[String] = ["Start", "Main", "Combat", "Main 2", "End"]

var game: GameState
var primary_button: FancyButton
var end_turn_button: FancyButton
var attack_all_button: FancyButton
var _portraits: Array[Portrait] = []
var _phase_pills: Array[Label] = []
var _turn_label: Label
var _turn_sub: Label
var _prompt: RichTextLabel
var _prompt_panel: PanelContainer
var _counts: Array[Label] = []
var _preview_root: Control
var _preview_card: CardView
var _tooltip: PanelContainer
var _tooltip_box: VBoxContainer
var _banner: Label
var _phase_index: int = 0


func setup(game_state: GameState, enemy_name: String, enemy_icon: String) -> void:
	game = game_state
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_portraits(enemy_name, enemy_icon)
	_build_side_panel()
	_build_buttons()
	_build_preview()
	_build_banner()
	refresh_all()


## Part G: a banner at the top of an Arena duel: the fight's name and its rules/goal (a puzzle's goal is the whole point).
func set_arena_banner(encounter_id: String) -> void:
	var encounter: ArenaEncounter = ArenaDefs.find(encounter_id)
	if encounter == null:
		return
	var story: StoryText = StoryText.shared()
	var panel: PanelContainer = UIKit.panel(&"DarkPanel")
	panel.name = "ArenaBanner"
	panel.position = Vector2(500, 8)
	panel.custom_minimum_size = Vector2(920, 0)
	add_child(panel)
	var column: VBoxContainer = UIKit.vbox(2)
	panel.add_child(column)
	var title: Label = UIKit.label("%s  -  %s" % [story.text("town.arena.name"), story.text(encounter.title_key())], &"HeadingLabel", 24, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(title)
	var rules: Label = UIKit.label(story.text(encounter.rules_key()), &"", 19, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	rules.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rules.custom_minimum_size = Vector2(880, 0)
	column.add_child(rules)

## Part C: the zone's buff and debuff, under the enemy portrait. Both apply to both players; the
## tooltips explain each (and the rivalry behind it).
func set_zone_effects(effect: ZoneEffects.Effect, zone_title: String) -> void:
	if effect == null:
		return
	var panel: ZoneEffectsPanel = ZoneEffectsPanel.make(effect, zone_title)
	panel.position = Vector2(24, 190)
	add_child(panel)



## Brief 10: in the Capital's duels the broken services (the debuffs that apply to this duel) and, in a boss phase, the phase's rule.
func set_capital_panels(flags: Dictionary, rules_text: String) -> void:
	var y: float = 190.0
	if not CapitalDebuffs.active(flags).is_empty():
		var services: ServiceDebuffsPanel = ServiceDebuffsPanel.make(flags)
		services.position = Vector2(24, y)
		add_child(services)
		y += 40.0 + 30.0 * float(CapitalDebuffs.all().size())
	if not rules_text.is_empty():
		var panel: PanelContainer = UIKit.panel(&"DarkPanel")
		panel.name = "PhaseRulePanel"
		panel.position = Vector2(24, y)
		panel.custom_minimum_size = Vector2(300, 0)
		var column: VBoxContainer = UIKit.vbox(4)
		panel.add_child(column)
		column.add_child(UIKit.label("Primm's rule", &"HeadingLabel", 21))
		var body: Label = UIKit.label(rules_text, &"", 18, Color("ffcf70"))
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.custom_minimum_size = Vector2(270, 0)
		column.add_child(body)
		add_child(panel)
# ---- Construction -----------------------------------------------------------------------


func _build_portraits(enemy_name: String, enemy_icon: String) -> void:
	var player_panel: Portrait = Portrait.new()
	player_panel.title = "You"
	player_panel.icon_key = "lorc/pointy-hat"
	player_panel.accent = UIStyle.GOLD
	player_panel.position = Vector2(24, 884)
	add_child(player_panel)
	var enemy_panel: Portrait = Portrait.new()
	enemy_panel.title = enemy_name
	enemy_panel.icon_key = enemy_icon
	enemy_panel.accent = Color("d9534f")
	enemy_panel.position = Vector2(24, 20)
	add_child(enemy_panel)
	_portraits = [player_panel, enemy_panel]
	for index: int in range(2):
		_portraits[index].max_hp = game.players[index].max_hp
		_portraits[index].hp = game.players[index].hp


func _build_side_panel() -> void:
	var panel: PanelContainer = UIKit.panel(&"DarkPanel")
	panel.position = Vector2(1640, 226)
	panel.size = Vector2(250, 406)
	add_child(panel)
	var column: VBoxContainer = UIKit.vbox(8)
	panel.add_child(column)
	_turn_label = UIKit.label("Turn 1", &"HeadingLabel", 30, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(_turn_label)
	_turn_sub = UIKit.label("", &"MutedLabel", 20, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(_turn_sub)
	for phase_name: String in PHASE_NAMES:
		var pill: Label = UIKit.label(phase_name, &"", 21, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
		pill.custom_minimum_size = Vector2(0, 30)
		pill.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		pill.add_theme_stylebox_override("normal", UIStyle.box(Color(1, 1, 1, 0.04), Color(0, 0, 0, 0), 0, 8))
		column.add_child(pill)
		_phase_pills.append(pill)
	column.add_child(UIKit.spacer(4))
	_prompt_panel = UIKit.panel()
	_prompt_panel.add_theme_stylebox_override("panel", UIStyle.box(Color(0.0, 0.0, 0.0, 0.35), Color(UIStyle.GOLD, 0.35), 1, 10))
	_prompt_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_prompt_panel)
	_prompt = UIKit.rich("", 20, false)
	_prompt.fit_content = false
	_prompt.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_prompt.custom_minimum_size = Vector2(0, 96)
	_prompt_panel.add_child(_prompt)
	# Deck / graveyard counters.
	for index: int in range(2):
		var counter: PanelContainer = UIKit.panel(&"DarkPanel")
		counter.size = Vector2(250, 60)
		counter.position = Vector2(1640, 20) if index == 1 else Vector2(1640, 826)
		add_child(counter)
		var row: HBoxContainer = UIKit.hbox(8)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		counter.add_child(row)
		var label: Label = UIKit.label("Deck 0", &"", 22, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
		row.add_child(label)
		_counts.append(label)


func _build_buttons() -> void:
	attack_all_button = FancyButton.make("Select All Attackers", &"GhostButton", Vector2(250, 50))
	attack_all_button.position = Vector2(1640, 768)
	attack_all_button.size = Vector2(250, 50)
	attack_all_button.visible = false
	attack_all_button.pressed.connect(func() -> void: attack_all_pressed.emit())
	add_child(attack_all_button)
	primary_button = FancyButton.make("Combat", &"PrimaryButton", Vector2(250, 66))
	primary_button.position = Vector2(1640, 904)
	primary_button.size = Vector2(250, 66)
	primary_button.pressed.connect(func() -> void: primary_pressed.emit())
	add_child(primary_button)
	end_turn_button = FancyButton.make("End Turn", &"", Vector2(250, 56))
	end_turn_button.position = Vector2(1640, 982)
	end_turn_button.size = Vector2(250, 56)
	end_turn_button.pressed.connect(func() -> void: end_turn_pressed.emit())
	add_child(end_turn_button)


func _build_preview() -> void:
	_preview_root = Control.new()
	_preview_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_root.visible = false
	add_child(_preview_root)
	_tooltip = UIKit.panel(&"DarkPanel")
	_tooltip.position = Vector2(22, 640)
	_tooltip.custom_minimum_size = Vector2(302, 0)
	_tooltip.size = Vector2(302, 10)
	_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_root.add_child(_tooltip)
	_tooltip_box = UIKit.vbox(6)
	_tooltip.add_child(_tooltip_box)


func _build_banner() -> void:
	_banner = UIKit.label("", &"TitleLabel", 92, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	_banner.set_anchors_preset(Control.PRESET_CENTER)
	_banner.custom_minimum_size = Vector2(1200, 120)
	_banner.position = Vector2(385, 440)
	_banner.size = Vector2(1200, 120)
	_banner.modulate.a = 0.0
	_banner.z_index = 400
	add_child(_banner)


# ---- Updates ----------------------------------------------------------------------------


func refresh_all() -> void:
	for index: int in range(2):
		var player: PlayerState = game.players[index]
		_portraits[index].set_hp(player.hp, false)
		_portraits[index].set_infrastructure(player.infrastructure)
		_counts[index].text = "Deck %d" % player.deck.size()
	_turn_label.text = "Turn %d" % maxi(game.turn, 1)
	_set_phase(int(game.phase) if game.stage == GameState.Stage.PLAYING else -1)
	_turn_sub.text = ""
	if game.stage == GameState.Stage.PLAYING:
		_turn_sub.text = "Your turn" if game.active == 0 else "Enemy turn"


func set_portrait_targets(player_ok: bool, enemy_ok: bool) -> void:
	_portraits[0].set_targetable(player_ok)
	_portraits[1].set_targetable(enemy_ok)


func portrait_rect(player_index: int) -> Rect2:
	return Rect2(_portraits[player_index].position, _portraits[player_index].size)


func refresh_infrastructure() -> void:
	for index: int in range(2):
		_portraits[index].set_infrastructure(game.players[index].infrastructure)


func portrait_center(player_index: int) -> Vector2:
	return _portraits[player_index].position + _portraits[player_index].size * 0.5


func on_event(event: GameEvent) -> void:
	match event.type:
		GameEvent.Type.HP_CHANGED:
			_portraits[event.player].set_hp(event.value, true)
		GameEvent.Type.TURN_STARTED:
			_turn_label.text = "Turn %d" % event.value
			_turn_sub.text = "Your turn" if event.player == 0 else "Enemy turn"
			show_banner("Your Turn" if event.player == 0 else "Enemy Turn", UIStyle.GOLD if event.player == 0 else Color("e06a5a"))
			Audio.sfx(&"turn_start", -10.0)
		GameEvent.Type.PHASE_CHANGED:
			_set_phase(event.value)
		GameEvent.Type.ENERGY_SPENT, GameEvent.Type.INFRASTRUCTURE_PLAYED:
			refresh_infrastructure()
		GameEvent.Type.CARD_DRAWN, GameEvent.Type.CARD_TOSSED, GameEvent.Type.UNIT_DIED, GameEvent.Type.CARD_BURIED:
			for index: int in range(2):
				var player: PlayerState = game.players[index]
				_counts[index].text = "Deck %d" % player.deck.size()


func _set_phase(index: int) -> void:
	_phase_index = index
	for i: int in range(_phase_pills.size()):
		var pill: Label = _phase_pills[i]
		var active: bool = i == index
		pill.add_theme_color_override("font_color", UIStyle.INK if active else UIStyle.MUTED)
		pill.add_theme_stylebox_override("normal", UIStyle.box(UIStyle.GOLD if active else Color(1, 1, 1, 0.04), Color(0, 0, 0, 0), 0, 8))


func set_prompt(text: String) -> void:
	_prompt.text = text


func show_banner(text: String, color: Color) -> void:
	_banner.text = text.to_upper()
	_banner.add_theme_color_override("font_color", color)
	_banner.pivot_offset = _banner.size * 0.5
	_banner.scale = Vector2(0.7, 0.7)
	var tween: Tween = create_tween()
	tween.tween_property(_banner, "modulate:a", 1.0, 0.15)
	tween.parallel().tween_property(_banner, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.5)
	tween.tween_property(_banner, "modulate:a", 0.0, 0.3)


func set_hp_display(player_index: int, hp: int, max_hp: int) -> void:
	_portraits[player_index].max_hp = max_hp
	_portraits[player_index].set_hp(hp, false)


# ---- Card preview -----------------------------------------------------------------------


func show_preview(view: CardView) -> void:
	if view == null or view.data == null or bool(view.get_meta("hidden", false)) or view.mode == CardView.Mode.BACK:
		hide_preview()
		return
	if _preview_card != null:
		_preview_card.queue_free()
	_preview_card = CardView.create(view.data, CardView.Mode.FULL)
	_preview_card.position = Vector2(22, 200)
	_preview_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_root.add_child(_preview_card)
	var card: CardInstance = game.find_card(view.instance_uid)
	if card != null:
		_preview_card.apply_instance(card, game)
	_preview_root.visible = true
	for child: Node in _tooltip_box.get_children():
		child.queue_free()
	var entries: Array[Array] = KeywordInfo.entries_for(view.data)
	if card != null and card.summoning_sick and card.data.is_unit() and game.players[card.owner].field.has(card):
		entries.append(["Summoning sickness", str(KeywordInfo.GLOSSARY["Summoning sickness"])])
	_tooltip.visible = not entries.is_empty()
	for entry: Array in entries:
		var title: Label = UIKit.label(str(entry[0]), &"", 22, UIStyle.GOLD)
		title.add_theme_font_override("font", UIStyle.font_bold())
		_tooltip_box.add_child(title)
		var body: Label = UIKit.label(str(entry[1]), &"", 19, UIStyle.PARCHMENT)
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.custom_minimum_size = Vector2(270, 0)
		_tooltip_box.add_child(body)
	_tooltip.size = Vector2(302, 10)
	_tooltip.position = Vector2(22, 632)


func hide_preview() -> void:
	_preview_root.visible = false


# ---- Portrait ---------------------------------------------------------------------------


class Portrait:
	extends PanelContainer
	var title: String = ""
	var icon_key: String = "lorc/imp"
	var accent: Color = UIStyle.GOLD
	var hp: int = 10
	var max_hp: int = 10
	var _hp_label: Label
	var _bar: ProgressBar
	var _orbs: OrbRow
	var _shown_hp: float = 10.0
	var _tween: Tween

	func _ready() -> void:
		custom_minimum_size = Vector2(300, 172)
		size = Vector2(300, 172)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_theme_stylebox_override("panel", _frame(accent.darkened(0.2), 3, 12))
		var row: HBoxContainer = UIKit.hbox(12)
		add_child(row)
		var avatar: PanelContainer = PanelContainer.new()
		avatar.custom_minimum_size = Vector2(84, 84)
		avatar.add_theme_stylebox_override("panel", UIStyle.box(accent.darkened(0.6), accent, 3, 42))
		avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var glyph: TextureRect = CardIcons.glyph(load(CardIcons.BASE + icon_key + ".svg") as Texture2D, Color("fdf3dc"), Vector2(60, 60))
		glyph.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		glyph.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		avatar.add_child(glyph)
		row.add_child(avatar)
		var column: VBoxContainer = UIKit.vbox(2)
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(column)
		column.add_child(UIKit.label(title, &"HeadingLabel", 22))
		var hp_row: HBoxContainer = UIKit.hbox(6)
		var heart: HeartIcon = HeartIcon.new()
		heart.custom_minimum_size = Vector2(34, 34)
		heart.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hp_row.add_child(heart)
		_hp_label = UIKit.label(str(hp), &"", 40, UIStyle.PARCHMENT)
		_hp_label.add_theme_font_override("font", UIStyle.font_title())
		hp_row.add_child(_hp_label)
		column.add_child(hp_row)
		_bar = ProgressBar.new()
		_bar.custom_minimum_size = Vector2(0, 14)
		_bar.show_percentage = false
		_bar.max_value = max_hp
		_bar.value = hp
		column.add_child(_bar)
		_orbs = OrbRow.new()
		_orbs.custom_minimum_size = Vector2(0, 26)
		column.add_child(_orbs)
		_shown_hp = float(hp)
		_apply_hp(_shown_hp)

	func _frame(border: Color, width: int, shadow: int) -> StyleBoxFlat:
		var style: StyleBoxFlat = UIStyle.box(Color(0.06, 0.04, 0.1, 0.9), border, width, 16, shadow)
		style.set_content_margin_all(14)
		return style

	func set_targetable(active: bool) -> void:
		var color: Color = Color("ff5a5a") if active else accent.darkened(0.2)
		add_theme_stylebox_override("panel", _frame(color, 5 if active else 3, 18 if active else 12))

	func set_hp(value: int, animate: bool) -> void:
		hp = value
		if _hp_label == null:
			return
		_bar.max_value = max_hp
		if not animate:
			_apply_hp(float(value))
			return
		if _tween != null and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		_tween.tween_method(_apply_hp, _shown_hp, float(value), 0.5)

	func _apply_hp(value: float) -> void:
		_shown_hp = value
		_hp_label.text = str(roundi(value))
		_bar.value = value
		var ratio: float = value / maxf(float(max_hp), 1.0)
		var fill: StyleBoxFlat = UIStyle.box(Color("6fbf73") if ratio > 0.6 else (Color("e0b03a") if ratio > 0.3 else UIStyle.HP_RED), Color(0, 0, 0, 0), 0, 8)
		_bar.add_theme_stylebox_override("fill", fill)

	func set_infrastructure(infrastructure: Array[CardInstance]) -> void:
		if _orbs != null:
			_orbs.infrastructure = infrastructure.duplicate()
			_orbs.queue_redraw()
			_orbs.mouse_filter = Control.MOUSE_FILTER_PASS
			_orbs.tooltip_text = _infrastructure_tooltip(infrastructure)


	## Which energy is ready right now, per Path (activating infrastructure pays for cards).
	func _infrastructure_tooltip(infrastructure: Array[CardInstance]) -> String:
		var ready_by_path: Dictionary = {}
		var ready_count: int = 0
		for infra: CardInstance in infrastructure:
			if not infra.exhausted:
				ready_count += 1
				ready_by_path[infra.data.color] = int(ready_by_path.get(infra.data.color, 0)) + 1
		var parts: PackedStringArray = []
		for path: Variant in ready_by_path.keys():
			parts.append("%d %s" % [int(ready_by_path[path]), UIStyle.affinity_name(path as Affinity.Type)])
		var available: String = ", ".join(parts) if not parts.is_empty() else "none"
		return "Infrastructure: %d of %d ready (filled orbs).
Activating an infrastructure gives 1 energy of its Path; playing a card activates the infrastructure that pays for it, and they all ready again next turn.
Energy available: %s." % [ready_count, infrastructure.size(), available]

class HeartIcon:
	extends Control

	func _draw() -> void:
		var points: PackedVector2Array = PackedVector2Array()
		for step: int in range(40):
			var a: float = TAU * float(step) / 40.0
			var x: float = 16.0 * pow(sin(a), 3.0)
			var y: float = -(13.0 * cos(a) - 5.0 * cos(2.0 * a) - 2.0 * cos(3.0 * a) - cos(4.0 * a))
			points.append(Vector2(17.0 + x, 16.0 + y) * 0.98)
		draw_colored_polygon(points, UIStyle.HP_RED.darkened(0.35))
		var inner: PackedVector2Array = PackedVector2Array()
		for point: Vector2 in points:
			inner.append((point - Vector2(17, 16)) * 0.82 + Vector2(17, 16))
		draw_colored_polygon(inner, UIStyle.HP_RED)
		draw_circle(Vector2(10.0, 9.0), 3.0, Color(1, 1, 1, 0.45))


class OrbRow:
	extends Control
	var infrastructure: Array[CardInstance] = []

	func _draw() -> void:
		var x: float = 11.0
		for infra: CardInstance in infrastructure:
			var color: Color = UIStyle.affinity_color(infra.data.color)
			if infra.exhausted:
				draw_arc(Vector2(x, 13.0), 8.0, 0.0, TAU, 20, color.darkened(0.3), 2.5, true)
			else:
				draw_circle(Vector2(x, 13.0), 10.0, color.darkened(0.5))
				draw_circle(Vector2(x, 13.0), 8.0, color)
				draw_circle(Vector2(x - 2.5, 10.0), 2.6, Color(1, 1, 1, 0.5))
			x += 22.0
