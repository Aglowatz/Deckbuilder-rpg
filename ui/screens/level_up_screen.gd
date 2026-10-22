class_name LevelUpScreen
extends Control
## Shown after anything grants enough XP to level up (battles, quests, the dev shrine): one moment PER level gained, in sequence.
## Overnight Oct 17, Part 7: a full-screen moment. The new level number punches in over slow golden rays with a burst and the level-up
## sound, the level's headline appears, then every reward is revealed one by one (a soft tick each); new unlocks (the armory, deck
## slots, cap raises, item slots, shop unlocks, cosmetics) sit in a gold box with a NEW chip and their own spark. Skippable: the first
## click / Enter / Space / E reveals everything at once, the next one moves on; Esc skips the remaining levels. Rewards come from the
## reward track (`ProgressionTable.reward_lines`). Callers call `setup()` then add this as a child, and wait for `finished`.

signal finished

const REVEAL_STEP: float = 0.16
const GUARD_TIME: float = 0.45
const NUMBER_SIZE: int = 200

var levels_gained: Array[LevelData] = []
var _index: int = 0
var _root: Control
var _rows: VBoxContainer
var _pending: Array[Control] = []
var _reveal_tween: Tween
var _revealing: bool = false
var _age: float = 0.0
var _continue: FancyButton


func setup(gained: Array[LevelData]) -> void:
	levels_gained = gained


func _ready() -> void:
	UIKit.full_rect(self)
	UiScale.fit(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Oct 19: the place behind stays visible, blurred (it was a near-black shade).
	add_child(PostBattleBackdrop.live())
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.015, 0.05, 0.3)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIKit.full_rect(shade)
	add_child(shade)
	_index = 0
	if levels_gained.is_empty():
		finished.emit.call_deferred()
		return
	_show_level()


func _process(delta: float) -> void:
	_age += delta


## One level's moment: rays, the number, the headline, then the reward rows one by one.
func _show_level() -> void:
	if _root != null:
		_root.queue_free()
	_age = 0.0
	var row: LevelData = levels_gained[_index]
	var previous: LevelData = ProgressionTable.row(row.level - 1)
	_root = Control.new()
	_root.name = "LevelMoment"
	UIKit.full_rect(_root)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var rays: PackFx.Rays = PackFx.Rays.new()
	rays.color = Color(UIStyle.GOLD.r, UIStyle.GOLD.g, UIStyle.GOLD.b, 0.13 if row.big else 0.08)
	rays.position = Vector2(960, 270)
	rays.length = 1300.0
	_root.add_child(rays)
	# Graphics Tier 1, Part 3: the level-up moment lights its own stage (a gold pulse under the number).
	BattleLights.flash(_root, Vector2(960, 270), UIStyle.GOLD, 900.0, 0.9, 1.6)
	var column: VBoxContainer = UIKit.vbox(6)
	column.position = Vector2(360, 50)
	column.size = Vector2(1200, 980)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(column)
	var banner: Label = UIKit.label("LEVEL UP", &"", 46, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	banner.add_theme_font_override("font", UIStyle.font_title())
	banner.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	banner.add_theme_constant_override("outline_size", 8)
	column.add_child(banner)
	var number: Label = UIKit.label(str(row.level), &"", NUMBER_SIZE, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	number.name = "LevelNumber"
	number.add_theme_font_override("font", UIStyle.font_title())
	number.add_theme_color_override("font_outline_color", Color("4a2a08"))
	number.add_theme_constant_override("outline_size", 14)
	number.custom_minimum_size = Vector2(0, 230)
	column.add_child(number)
	var headline: Label = UIKit.label(row.headline if not row.headline.is_empty() else "You are now level %d." % row.level, &"", 36, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	headline.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	headline.add_theme_constant_override("outline_size", 6)
	column.add_child(headline)
	if levels_gained.size() > 1:
		column.add_child(UIKit.label("%d of %d levels gained" % [_index + 1, levels_gained.size()], &"MutedLabel", 20, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(UIKit.spacer(10))
	_rows = UIKit.vbox(8)
	_rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_rows)
	_pending.clear()
	var lines: Array[String] = []
	if previous != null:
		lines = ProgressionTable.reward_lines(row, previous, Session.profile.primary_affinity if Session.profile != null else Affinity.Type.NEUTRAL)
	for line: String in lines:
		var reward: Control = _reward_row(line, is_unlock(line))
		_rows.add_child(reward)
		_pending.append(reward)
	_add_xp_bar(row)
	column.add_child(UIKit.spacer(8))
	_continue = FancyButton.make("Continue" if _index + 1 >= levels_gained.size() else "Next level", &"PrimaryButton", Vector2(260, 60))
	_continue.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_continue.pressed.connect(advance)
	column.add_child(_continue)
	_continue.focus_mode = Control.FOCUS_ALL
	# Overnight Oct 17 (Phase 2 cycle 22): a zone clear can give several levels at once; one button shows every remaining reward on one page.
	var remaining: int = levels_gained.size() - _index
	if remaining > 1:
		var all_button: FancyButton = FancyButton.make("All %d levels on one page" % remaining, &"GhostButton", Vector2(320, 48))
		all_button.name = "AllLevelsButton"
		all_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		all_button.pressed.connect(show_summary)
		column.add_child(all_button)
		all_button.focus_mode = Control.FOCUS_ALL
	column.add_child(UIKit.label("Click or press Enter to continue  -  Esc skips", &"MutedLabel", 18, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	_animate_number(number, row)
	_start_reveal()


## Unlock lines (new things, not just numbers going up) get the gold box and the NEW chip.
static func is_unlock(line: String) -> bool:
	for word: String in ["armory", "Deck Station", "copies", "Wear up to", "item slot", "Unlocks", "(cosmetic)"]:
		if line.contains(word):
			return true
	return false


func _reward_row(text: String, unlock: bool) -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.custom_minimum_size = Vector2(820, 0)
	var fill: Color = Color(0.32, 0.22, 0.06, 0.82) if unlock else Color(0.08, 0.06, 0.12, 0.72)
	var border: Color = UIStyle.GOLD if unlock else Color(1, 1, 1, 0.12)
	panel.add_theme_stylebox_override("panel", UIStyle.box(fill, border, 2 if unlock else 1, 10))
	var line: HBoxContainer = UIKit.hbox(12)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(UIKit.margin(line, 10))
	if unlock:
		var chip: Label = UIKit.label("NEW", &"", 18, UIStyle.INK, HORIZONTAL_ALIGNMENT_CENTER)
		chip.add_theme_stylebox_override("normal", UIStyle.box(UIStyle.GOLD, Color(0, 0, 0, 0), 0, 8))
		chip.custom_minimum_size = Vector2(64, 30)
		chip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line.add_child(chip)
	var label: Label = UIKit.label(text, &"", 24 if unlock else 22, UIStyle.GOLD if unlock else UIStyle.PARCHMENT)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(label)
	panel.set_meta(&"unlock", unlock)
	panel.modulate.a = 0.0
	return panel


func _animate_number(number: Label, row: LevelData) -> void:
	number.pivot_offset = Vector2(600, 115)
	number.scale = Vector2(2.2, 2.2)
	number.modulate.a = 0.0
	var tween: Tween = number.create_tween().set_parallel(true)
	tween.tween_property(number, "modulate:a", 1.0, 0.18)
	tween.tween_property(number, "scale", Vector2.ONE, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Audio.sfx(&"level_up")
	PackFx.burst(_root, Vector2(960, 270), UIStyle.GOLD, 46 if row.big else 30, 460.0, 1.1, true)
	if row.big:
		PackFx.ring(_root, Vector2(960, 270), UIStyle.GOLD, 320.0, 0.8)


func _start_reveal() -> void:
	_revealing = true
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	_reveal_tween = create_tween()
	_reveal_tween.tween_interval(0.55)
	for reward: Control in _pending:
		_reveal_tween.tween_callback(_reveal_one.bind(reward))
		_reveal_tween.tween_interval(REVEAL_STEP * (2.0 if bool(reward.get_meta(&"unlock", false)) else 1.0))
	_reveal_tween.tween_callback(func() -> void: _revealing = false)


func _reveal_one(reward: Control) -> void:
	if not is_instance_valid(reward) or reward.modulate.a > 0.99:
		return
	reward.pivot_offset = reward.size * 0.5
	reward.scale = Vector2(0.92, 0.92)
	var tween: Tween = reward.create_tween().set_parallel(true)
	tween.tween_property(reward, "modulate:a", 1.0, 0.16)
	tween.tween_property(reward, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if bool(reward.get_meta(&"unlock", false)):
		Audio.sfx(&"ui_confirm", -6.0)
		PackFx.burst(_root, reward.get_global_rect().get_center() - global_position, UIStyle.GOLD, 14, 220.0, 0.6, true)
	else:
		Audio.sfx(&"ui_tick", -6.0)


## Everything at once (the first press while the rewards are still coming in).
func reveal_all() -> void:
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	for reward: Control in _pending:
		if is_instance_valid(reward):
			reward.modulate.a = 1.0
			reward.scale = Vector2.ONE
	_revealing = false


func is_revealing() -> bool:
	return _revealing


## The XP bar under the rewards: how far the hero is toward the level after this one.
func _add_xp_bar(row: LevelData) -> void:
	if row.level >= ProgressionTable.MAX_LEVEL or Session.profile == null:
		return
	var floor_xp: int = ProgressionTable.xp_to_reach(row.level)
	var ceil_xp: int = ProgressionTable.xp_to_reach(row.level + 1)
	var bar: ProgressBar = ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = maxf(1.0, float(ceil_xp - floor_xp))
	bar.value = clampf(float(Session.profile.xp - floor_xp), 0.0, bar.max_value)
	bar.custom_minimum_size = Vector2(640, 0)
	bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if UiArt.has("UI-BAR-XP"):
		UiSkin.skin_bar(bar, "xp", 44.0, UIStyle.GOLD)
	_rows.add_child(UIKit.spacer(6))
	_rows.add_child(bar)
	_rows.add_child(UIKit.label("XP toward level %d: %d / %d" % [row.level + 1, int(bar.value), int(bar.max_value)], &"MutedLabel", 18, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))


## Continue: finish the reveal first, then the next level, then done.
func advance() -> void:
	if _age < GUARD_TIME:
		return
	if _revealing:
		reveal_all()
		return
	Audio.sfx(&"ui_confirm")
	_index += 1
	if _index < levels_gained.size():
		_show_level()
	else:
		finished.emit()


## Every remaining level's rewards on one page (from the current level to the last), then Continue finishes.
func show_summary() -> void:
	if _index >= levels_gained.size():
		return
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	_revealing = false
	_pending.clear()
	if _root != null:
		_root.queue_free()
	_age = GUARD_TIME
	var first: LevelData = levels_gained[_index]
	var last: LevelData = levels_gained[levels_gained.size() - 1]
	_root = Control.new()
	_root.name = "LevelSummary"
	UIKit.full_rect(_root)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var column: VBoxContainer = UIKit.vbox(8)
	column.position = Vector2(360, 60)
	column.size = Vector2(1200, 960)
	_root.add_child(column)
	var banner: Label = UIKit.label("LEVEL UP", &"", 46, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	banner.add_theme_font_override("font", UIStyle.font_title())
	column.add_child(banner)
	var number: Label = UIKit.label(("%d" % last.level) if first.level == last.level else ("%d - %d" % [first.level, last.level]), &"", 120, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	number.name = "LevelNumber"
	number.add_theme_font_override("font", UIStyle.font_title())
	number.add_theme_color_override("font_outline_color", Color("4a2a08"))
	number.add_theme_constant_override("outline_size", 12)
	column.add_child(number)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(1200, 560)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	_rows = UIKit.vbox(8)
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_rows)
	for index: int in range(_index, levels_gained.size()):
		var row: LevelData = levels_gained[index]
		var previous: LevelData = ProgressionTable.row(row.level - 1)
		_rows.add_child(UIKit.label("Level %d%s" % [row.level, (" - " + row.headline) if not row.headline.is_empty() else ""], &"HeadingLabel", 26, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
		if previous == null:
			continue
		for line: String in ProgressionTable.reward_lines(row, previous, Session.profile.primary_affinity if Session.profile != null else Affinity.Type.NEUTRAL):
			var reward: Control = _reward_row(line, is_unlock(line))
			reward.modulate.a = 1.0
			_rows.add_child(reward)
	_index = levels_gained.size() - 1
	_continue = FancyButton.make("Continue", &"PrimaryButton", Vector2(260, 60))
	_continue.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_continue.pressed.connect(advance)
	column.add_child(_continue)
	_continue.focus_mode = Control.FOCUS_ALL
	_continue.call_deferred(&"grab_focus")
	Audio.sfx(&"ui_confirm")


## Skips every remaining level.
func skip_all() -> void:
	if _age < GUARD_TIME or _index >= levels_gained.size():
		return
	reveal_all()
	_index = levels_gained.size()
	finished.emit()


func _gui_input(event: InputEvent) -> void:
	var click: InputEventMouseButton = event as InputEventMouseButton
	if click != null and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		advance()
		accept_event()


func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed(&"ui_cancel"):
		skip_all()
		get_viewport().set_input_as_handled()
		return
	var key: InputEventKey = event as InputEventKey
	if event.is_action_pressed(&"ui_accept") or (key != null and key.pressed and not key.echo and key.keycode == KEY_E):
		advance()
		get_viewport().set_input_as_handled()
