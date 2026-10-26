class_name QuestTracker
extends PanelContainer
## HUD widget (Oct 16 overhaul): ONE quest at a time - its category tag, its name and its objectives as a checklist (done ones ticked, the
## current one highlighted, later ones dimmed). The player toggles through the active quests with two rebindable keys (`quest_prev` /
## `quest_next`, shown on the tracker) or the controller bumpers; it follows the most recently updated quest by default (`Session.refresh_quests`).
## Click the name to fold it to a single line. Redraws on `EventBus.quest_changed`.

static var collapsed: bool = false
## The scene's tracker (the quest update banner sits beside it).
const GROUP: StringName = &"quest_tracker"

## Longest checklist shown at once (a longer one shows a window round the current step).
const MAX_ROWS: int = 5
const WIDTH: float = 340.0
const MAIN_COLOR: Color = Color("e9b949")
const SIDE_COLOR: Color = Color("8fb8d8")

var _tag: Label
var _tag_panel: PanelContainer
var _header: Button
var _switcher: HBoxContainer
var _count: Label
var _body: VBoxContainer


func _ready() -> void:
	name = "QuestTracker"
	theme_type_variation = &"DarkPanel"
	custom_minimum_size = Vector2(WIDTH, 0)
	mouse_filter = Control.MOUSE_FILTER_PASS
	var column: VBoxContainer = UIKit.vbox(4)
	column.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(column)
	var top: HBoxContainer = UIKit.hbox(8)
	top.mouse_filter = Control.MOUSE_FILTER_PASS
	column.add_child(top)
	_tag_panel = PanelContainer.new()
	_tag_panel.name = "CategoryTag"
	_tag_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tag_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(_tag_panel)
	_tag = UIKit.label("MAIN", &"", 13, Color("1d1408"))
	_tag.add_theme_font_override("font", UIStyle.font_bold())
	_tag_panel.add_child(_tag)
	_header = Button.new()
	_header.name = "TrackerHeader"
	_header.flat = true
	_header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_header.clip_text = true
	_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for state: String in ["normal", "hover", "pressed", "focus"]:
		_header.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	_header.focus_mode = Control.FOCUS_NONE
	_header.add_theme_font_size_override("font_size", 20)
	_header.add_theme_color_override("font_color", UIStyle.GOLD)
	_header.tooltip_text = "Click to fold. Choose any quest in the Quest Log (%s)." % Keybinds.first_key(&"open_quests")
	_header.pressed.connect(toggle)
	top.add_child(_header)
	_body = UIKit.vbox(2)
	_body.mouse_filter = Control.MOUSE_FILTER_PASS
	column.add_child(_body)
	_switcher = UIKit.hbox(6)
	_switcher.name = "QuestSwitcher"
	_switcher.mouse_filter = Control.MOUSE_FILTER_PASS
	column.add_child(_switcher)
	_switcher.add_child(_arrow("◂", -1, &"quest_prev"))
	_count = UIKit.label("", &"MutedLabel", 14)
	_count.name = "QuestCount"
	_count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_switcher.add_child(_count)
	_switcher.add_child(_arrow("▸", 1, &"quest_next"))
	EventBus.quest_changed.connect(refresh)
	add_to_group(GROUP)
	refresh()


## Fixes Oct 25, Part 7: a brief glow when the quest update banner beside it appears.
func flash(color: Color = UIStyle.GOLD) -> void:
	var tween: Tween = create_tween()
	self_modulate = Color(1.0 + color.r * 0.6, 1.0 + color.g * 0.6, 1.0 + color.b * 0.6)
	tween.tween_property(self, "self_modulate", Color.WHITE, 0.9).set_trans(Tween.TRANS_SINE)


func _arrow(glyph: String, step: int, action: StringName) -> Button:
	var button: Button = Button.new()
	button.name = "QuestPrev" if step < 0 else "QuestNext"
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", UIStyle.PARCHMENT)
	button.custom_minimum_size = Vector2(64, 24)
	var word: String = "Previous" if step < 0 else "Next"
	PromptText.bind(button, "%s quest ({%s} / %s)" % [word, action, "LB" if step < 0 else "RB"], &"tooltip_text", "%s quest ({%s})" % [word, action])
	button.pressed.connect(func() -> void: cycle(step))
	button.set_meta(&"glyph", glyph)
	button.set_meta(&"action", action)
	return button


func toggle() -> void:
	collapsed = not collapsed
	refresh()


## Tracks the next / previous active quest.
func cycle(step: int) -> void:
	if Session.quest_log.cycle(QuestCatalog.all(), step) != "":
		Audio.sfx(&"ui_tick")
		EventBus.quest_changed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree() or get_tree().paused:
		return
	if event.is_action_pressed(&"quest_next"):
		get_viewport().set_input_as_handled()
		cycle(1)
	elif event.is_action_pressed(&"quest_prev"):
		get_viewport().set_input_as_handled()
		cycle(-1)


## The first objective that is not done yet (or the last one when all are), with its progress.
static func current_objective(quest: QuestData, qlog: QuestLog, state: UnlockState) -> Dictionary:
	var index: int = mini(qlog.current_index(quest, state), quest.objectives.size() - 1)
	var progress_now: Vector2i = qlog.objective_progress(quest, index, state)
	return {"text": quest.objectives[index].text, "done": progress_now.x >= progress_now.y, "have": progress_now.x, "need": progress_now.y, "index": index}


## Rows to show: every objective of a short quest, otherwise a window of MAX_ROWS round the current one. [first, last) indices.
static func row_window(count: int, current: int) -> Vector2i:
	if count <= MAX_ROWS:
		return Vector2i(0, count)
	var first: int = clampi(current - 1, 0, count - MAX_ROWS)
	return Vector2i(first, first + MAX_ROWS)


func refresh() -> void:
	if _body == null:
		return
	for child: Node in _body.get_children():
		child.queue_free()
	var qlog: QuestLog = Session.quest_log
	var quest: QuestData = QuestCatalog.find(qlog.tracked_id())
	visible = quest != null
	if quest == null:
		return
	var state: UnlockState = Session.unlock_state()
	var main: bool = quest.is_main()
	_tag.text = quest.category_tag()
	var tag_box: StyleBoxFlat = StyleBoxFlat.new()
	tag_box.bg_color = MAIN_COLOR if main else SIDE_COLOR
	tag_box.set_corner_radius_all(5)
	tag_box.content_margin_left = 6
	tag_box.content_margin_right = 6
	tag_box.content_margin_top = 1
	tag_box.content_margin_bottom = 1
	_tag_panel.add_theme_stylebox_override("panel", tag_box)
	_header.text = "%s %s" % ["▸" if collapsed else "▾", quest.title]
	var ids: Array[String] = qlog.cycle_order(QuestCatalog.all())
	_switcher.visible = ids.size() > 1
	_count.text = "%d of %d" % [ids.find(quest.id) + 1, ids.size()]
	for button: Node in _switcher.get_children():
		if button is Button:
			var action: StringName = button.get_meta(&"action") as StringName
			var glyph: String = str(button.get_meta(&"glyph"))
			PromptText.bind(button, ("%s {%s}" % [glyph, action]) if glyph == "◂" else ("{%s} %s" % [action, glyph]))
	_body.visible = not collapsed
	if collapsed:
		return
	if qlog.is_ready_to_turn_in(quest, state):
		_body.add_child(_row("✔", "All done", UIStyle.GOOD, false))
		_body.add_child(_row("?", "Hand in to %s" % quest.turn_in_npc, UIStyle.GOLD, true))
		var turn_in_hint: String = elsewhere_hint(quest.turn_in_area, SceneManager.current_area)
		if not turn_in_hint.is_empty():
			_body.add_child(_row("➜", turn_in_hint, Color(UIStyle.GOLD, 0.8), false))
		return
	var current: int = qlog.current_index(quest, state)
	# Oct 20, Part 5: the steps done and the current one only; what comes next stays "???" (`QuestLog.visible_steps`).
	var shown: int = qlog.visible_steps(quest, state).size()
	var window: Vector2i = row_window(shown, current)
	if window.x > 0:
		_body.add_child(_row("✔", "%d done" % window.x, Color(UIStyle.GOOD, 0.75), false))
	for index: int in range(window.x, window.y):
		var progress: Vector2i = qlog.objective_progress(quest, index, state)
		var done: bool = progress.x >= progress.y
		var text: String = quest.objectives[index].text
		if progress.y > 1 and not done:
			text += "  %d/%d" % [progress.x, progress.y]
		if done:
			_body.add_child(_row("✔", text, Color(UIStyle.GOOD, 0.8), false))
		elif index == current:
			_body.add_child(_row("»", text, UIStyle.GOLD, true))
		else:
			_body.add_child(_row("○", text, Color(UIStyle.PARCHMENT, 0.55), false))
	if qlog.hidden_steps(quest, state) > 0:
		_body.add_child(_row("…", QuestLog.HIDDEN_STEPS_TEXT, Color(UIStyle.PARCHMENT, 0.5), false))
	if current < quest.objectives.size() and quest.objectives[current].target_id != QuestDefinitions.OUTSKIRTS_SPOT:
		var elsewhere: String = elsewhere_hint(quest.objectives[current].target_area, SceneManager.current_area)
		if not elsewhere.is_empty():
			_body.add_child(_row("➜", elsewhere, Color(UIStyle.GOLD, 0.8), false))


## Overnight Oct 18, Part 6: "Go to the Gainlands" when the current step happens in another area (`target_area` is a zone id or "town";
## `here` is the `Areas` key of the scene the player is in); "" when it is here, or nowhere in particular.
static func elsewhere_hint(target_area: String, here: String) -> String:
	if target_area.is_empty() or here.is_empty():
		return ""  # "" = the area is not known (a scene opened directly by a tool): say nothing rather than send the hero where they stand
	var key: String = Areas.TOWN if target_area == "town" else Areas.key_for_zone(target_area)
	if key.is_empty() or key == here:
		return ""
	var place: String = Areas.banner_name(key)
	return "Go to %s" % (place.substr(0, 1).to_lower() + place.substr(1) if place.begins_with("The ") else place)


func _row(mark: String, text: String, color: Color, highlight: bool) -> HBoxContainer:
	var row: HBoxContainer = UIKit.hbox(6)
	row.name = "Objective"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.set_meta(&"current", highlight)
	var mark_label: Label = UIKit.label(mark, &"", 16, color)
	mark_label.custom_minimum_size = Vector2(18, 0)
	mark_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	row.add_child(mark_label)
	var line: Label = UIKit.label(text, &"", 17 if highlight else 16, color)
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.custom_minimum_size = Vector2(WIDTH - 50.0, 0)
	if highlight:
		line.add_theme_font_override("font", UIStyle.font_bold())
	row.add_child(line)
	return row
