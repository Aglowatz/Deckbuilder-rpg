class_name RuleIconRow
extends Control
## Playtest v0.4.0, Part F: a row of small round icons, one per rule badge (`RuleBadges.Badge`): hover for the full text, click any icon
## (or the row's caption) to open a panel listing every rule in full. The same row sits on the node map, in the dungeon brief and in the
## battle HUD, so the rules of a fight always look the same. Enemy-side rules are red, player-side green, shared rules gold.

signal toggled(open: bool)

const ICON_PX: float = 34.0
const GAP: float = 6.0

var badges: Array[RuleBadges.Badge] = []
var caption_text: String = ""
var _panel: PanelContainer
var _row: BoxContainer
## Overnight Nov 19 (Part 1.4): one readable line per rule (icon + name + text) instead of a row of icons - the battle HUD's list.
var lines_mode: bool = false
const LINE_WIDTH: float = 300.0
const LINE_CHARS: int = 120
var _caption: Label
## Fable Nov 21 castle (Part 5.1), the battle's rules panel: `max_height` > 0 caps the list - the fight's own rules then scroll inside
## the panel (its own scroll bar), so the list never grows over the items or the player's plate. `fold_run` folds what the RUN brought
## (boons, curses, the leaders' help: `RUN_KINDS`) into one line under the list, "Run effects: 3 allies, 4 boons, 1 curse"; hovering,
## clicking or focusing that line (or the Rules key / button) opens the full list beside the panel.
var max_height: float = 0.0
var fold_run: bool = false
const RUN_KINDS: Array[String] = ["ally", "boon", "curse"]
const RUN_LINE_HEIGHT: float = 34.0
const RUN_PANEL_MAX_HEIGHT: float = 430.0
var _run_badges: Array[RuleBadges.Badge] = []
var _run_button: Button
var _run_panel: PanelContainer
var _run_pinned: bool = false


## The battle HUD's panel: one line per rule of the fight in a list `height_limit` tall at most, the run's effects in one line.
static func make_battle(rule_badges: Array[RuleBadges.Badge], height_limit: float, caption: String = "Rules of this fight") -> RuleIconRow:
	return make(rule_badges, caption, false, true, height_limit, true)


## "Run effects: 3 allies, 4 boons, 1 curse" ("" when the run brought nothing).
static func run_summary(rule_badges: Array[RuleBadges.Badge]) -> String:
	var counts: Dictionary = {"ally": 0, "boon": 0, "curse": 0}
	for badge: RuleBadges.Badge in rule_badges:
		if counts.has(badge.kind):
			counts[badge.kind] = int(counts[badge.kind]) + 1
	var parts: PackedStringArray = []
	for pair: Array in [["ally", "ally", "allies"], ["boon", "boon", "boons"], ["curse", "curse", "curses"]]:
		var count: int = int(counts[pair[0]])
		if count > 0:
			parts.append("%d %s" % [count, pair[1] if count == 1 else pair[2]])
	return "" if parts.is_empty() else "Run effects: %s" % ", ".join(parts)


static func make(rule_badges: Array[RuleBadges.Badge], caption: String = "Rules", compact: bool = false, as_lines: bool = false, height_limit: float = 0.0, fold: bool = false) -> RuleIconRow:
	var row: RuleIconRow = RuleIconRow.new()
	row.name = "RuleIconRow"
	row.badges = rule_badges
	row.caption_text = caption
	row.lines_mode = as_lines
	row.max_height = height_limit
	row.fold_run = fold
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row._build(compact)
	return row


## The height of the list in lines mode (for stacking panels under it).
func lines_height() -> float:
	if _row == null:
		return 0.0
	return _row.get_parent().get_combined_minimum_size().y if _row.get_parent() is Control else ICON_PX


func _build(compact: bool) -> void:
	var column: VBoxContainer = UIKit.vbox(2)
	column.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(column)
	if not compact and not caption_text.is_empty():
		_caption = UIKit.label(caption_text, &"", 15, UIStyle.MUTED)
		_caption.mouse_filter = Control.MOUSE_FILTER_STOP
		_caption.tooltip_text = "Click for the full rules."
		_caption.gui_input.connect(_on_caption_input)
		column.add_child(_caption)
	if lines_mode:
		_row = VBoxContainer.new()
		_row.add_theme_constant_override("separation", 4)
		_row.mouse_filter = Control.MOUSE_FILTER_PASS
		var listed: Array[RuleBadges.Badge] = []
		_run_badges = []
		for badge: RuleBadges.Badge in badges:
			if fold_run and RUN_KINDS.has(badge.kind):
				_run_badges.append(badge)
			else:
				listed.append(badge)
		for badge: RuleBadges.Badge in listed:
			_row.add_child(_line(badge))
		var head: float = 0.0 if compact or caption_text.is_empty() else 20.0
		var list_tall: float = 0.0
		for badge: RuleBadges.Badge in listed:
			var chars: int = mini(badge.text.length(), LINE_CHARS) + badge.name.length() + 2
			list_tall += maxf(ICON_PX + 8.0, ceilf(float(chars) * 7.4 / LINE_WIDTH) * 19.0) + 4.0
		var foot: float = RUN_LINE_HEIGHT + 4.0 if not _run_badges.is_empty() else 0.0
		var width: float = LINE_WIDTH + ICON_PX + 16.0
		var room: float = max_height - head - foot
		if max_height > 0.0 and list_tall > room:
			# The list is longer than its room: it scrolls inside the panel (its own bar), the panel keeps its height.
			var scroll: ScrollContainer = ScrollContainer.new()
			scroll.name = "RuleScroll"
			scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
			scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
			scroll.custom_minimum_size = Vector2(width + 14.0, maxf(room, ICON_PX + 12.0))
			scroll.mouse_filter = Control.MOUSE_FILTER_PASS
			scroll.add_child(_row)
			column.add_child(scroll)
			list_tall = maxf(room, ICON_PX + 12.0)
			width += 14.0
		else:
			column.add_child(_row)
		if not _run_badges.is_empty():
			column.add_child(_run_line())
		custom_minimum_size = Vector2(width, head + list_tall + foot)
		return
	_row = HBoxContainer.new()
	_row.add_theme_constant_override("separation", int(GAP))
	_row.mouse_filter = Control.MOUSE_FILTER_PASS
	column.add_child(_row)
	for badge: RuleBadges.Badge in badges:
		_row.add_child(_icon(badge))
	custom_minimum_size = Vector2(float(badges.size()) * (ICON_PX + GAP), ICON_PX + (0.0 if compact else 20.0))


## One rule as a line: its icon (hover for the full text, click for the list) and "Name: text" beside it, wrapped.
func _line(badge: RuleBadges.Badge) -> HBoxContainer:
	var line: HBoxContainer = HBoxContainer.new()
	line.name = "Line_%s" % badge.name.replace(" ", "_")
	line.add_theme_constant_override("separation", 6)
	line.mouse_filter = Control.MOUSE_FILTER_PASS
	var button: Control = _icon(badge)
	button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	line.add_child(button)
	var words: String = badge.text
	if words.length() > LINE_CHARS:
		words = words.substr(0, LINE_CHARS - 3).strip_edges() + "..."
	var text: RichTextLabel = UIKit.rich("[color=#%s][b]%s[/b][/color]  %s" % [badge.color().lightened(0.2).to_html(false), badge.name, words], 15)
	text.name = "Text"
	text.custom_minimum_size = Vector2(LINE_WIDTH, 0)
	text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text.add_theme_color_override("default_color", UIStyle.PARCHMENT)
	text.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.92))
	text.add_theme_constant_override("outline_size", 5)
	line.add_child(text)
	return line


## The one line the run's effects fold into: a button (mouse and controller focus) that opens the full list beside the panel.
func _run_line() -> Button:
	_run_button = Button.new()
	_run_button.name = "RunEffects"
	_run_button.text = run_summary(_run_badges)
	_run_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_run_button.custom_minimum_size = Vector2(LINE_WIDTH + ICON_PX + 16.0, RUN_LINE_HEIGHT)
	_run_button.focus_mode = Control.FOCUS_ALL
	_run_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_run_button.add_theme_font_size_override("font_size", 16)
	_run_button.add_theme_color_override("font_color", Color("ffe08a"))
	_run_button.add_theme_stylebox_override("normal", UIStyle.box(Color(0.05, 0.03, 0.09, 0.78), Color(UIStyle.GOLD, 0.55), 1, 8))
	_run_button.add_theme_stylebox_override("hover", UIStyle.box(Color(0.12, 0.08, 0.18, 0.92), UIStyle.GOLD, 2, 8))
	_run_button.add_theme_stylebox_override("pressed", UIStyle.box(Color(0.12, 0.08, 0.18, 0.92), UIStyle.GOLD, 2, 8))
	_run_button.add_theme_stylebox_override("focus", UIStyle.box(Color(0.12, 0.08, 0.18, 0.92), UIStyle.GOLD, 3, 8))
	_run_button.mouse_entered.connect(func() -> void: _show_run_panel(true))
	_run_button.mouse_exited.connect(func() -> void: _show_run_panel(_run_pinned))
	_run_button.focus_entered.connect(func() -> void: _show_run_panel(true))
	_run_button.focus_exited.connect(func() -> void: _show_run_panel(_run_pinned))
	_run_button.pressed.connect(toggle_run_effects)
	PromptText.bind(_run_button, run_summary(_run_badges) + "  ({dungeon_rules})")
	return _run_button


## The run's effects as the list shows them (for tests).
func run_badges() -> Array[RuleBadges.Badge]:
	return _run_badges


func run_effects_open() -> bool:
	return _run_panel != null and is_instance_valid(_run_panel) and _run_panel.visible


## Click, the Rules key or the controller's Rules button: the full list stays open until toggled again.
func toggle_run_effects() -> void:
	if _run_badges.is_empty():
		return
	_run_pinned = not _run_pinned
	_show_run_panel(_run_pinned)


func _show_run_panel(shown: bool) -> void:
	if not shown:
		if _run_panel != null and is_instance_valid(_run_panel):
			_run_panel.visible = false
		return
	if _run_panel == null or not is_instance_valid(_run_panel):
		_run_panel = PanelContainer.new()
		_run_panel.name = "RunEffectsPanel"
		_run_panel.theme_type_variation = &"DarkPanel"
		_run_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_run_panel.z_index = 400
		var column: VBoxContainer = UIKit.vbox(6)
		_run_panel.add_child(column)
		column.add_child(UIKit.label("Run effects", &"HeadingLabel", 21))
		var list: VBoxContainer = UIKit.vbox(6)
		var tall: float = 0.0
		for badge: RuleBadges.Badge in _run_badges:
			list.add_child(_full_row(badge))
			tall += 30.0 + ceilf(float(badge.text.length() + 12) * 7.2 / 290.0) * 19.0
		if tall > RUN_PANEL_MAX_HEIGHT:
			var scroll: ScrollContainer = ScrollContainer.new()
			scroll.name = "RunScroll"
			scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
			scroll.custom_minimum_size = Vector2(346, RUN_PANEL_MAX_HEIGHT)
			scroll.add_child(list)
			column.add_child(scroll)
		else:
			column.add_child(list)
		add_child(_run_panel)
		# beside the panel, its foot level with the line, never above the top of the screen
		_run_panel.reset_size()
		var panel_tall: float = _run_panel.get_combined_minimum_size().y
		var top: float = minf(0.0, custom_minimum_size.y - panel_tall)
		_run_panel.position = Vector2(custom_minimum_size.x + 12.0, maxf(top, 12.0 - global_position.y))
	_run_panel.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if fold_run and not _run_badges.is_empty() and is_visible_in_tree() and event.is_action_pressed(&"dungeon_rules"):
		toggle_run_effects()
		get_viewport().set_input_as_handled()


func _find_badge(badge_name: String) -> Node:
	return _row.find_child("Badge_%s" % badge_name.replace(" ", "_"), true, false) if _row != null else null


## Overnight Nov 10-11 (Part 1.5): a few words right after one badge's icon, inside the row ("Setting Up - attacks start Turn 3"); "" removes
## them. The icon keeps its tooltip and click.
func set_note(badge_name: String, text: String) -> void:
	if _row == null:
		return
	var node_name: String = "Note_%s" % badge_name.replace(" ", "_")
	var note: Label = _row.find_child(node_name, true, false) as Label
	if text.is_empty():
		if note != null:
			note.queue_free()
		return
	if note == null:
		var button: Node = _find_badge(badge_name)
		if button == null:
			return
		note = UIKit.label(text, &"", 15, Color("ffe08a"))
		note.name = node_name
		note.mouse_filter = Control.MOUSE_FILTER_IGNORE
		note.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		note.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		note.add_theme_constant_override("outline_size", 5)
		if lines_mode:
			# In the list the words go under the rule's own text.
			var text_box: Node = button.get_parent().get_node_or_null("Text")
			note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			note.custom_minimum_size = Vector2(LINE_WIDTH, 0)
			var holder: VBoxContainer = VBoxContainer.new()
			holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if text_box != null:
				var parent: Node = text_box.get_parent()
				var at: int = text_box.get_index()
				parent.remove_child(text_box)
				holder.add_child(text_box)
				parent.add_child(holder)
				parent.move_child(holder, at)
			else:
				button.get_parent().add_child(holder)
			holder.add_child(note)
		else:
			_row.add_child(note)
			_row.move_child(note, button.get_index() + 1)
	note.text = text


## The words beside a badge ("" when none) - for tests.
func note_text(badge_name: String) -> String:
	var note: Label = _row.find_child("Note_%s" % badge_name.replace(" ", "_"), true, false) as Label if _row != null else null
	return note.text if note != null and not note.is_queued_for_deletion() else ""


func _icon(badge: RuleBadges.Badge) -> Control:
	var button: Button = Button.new()
	button.name = "Badge_%s" % badge.name.replace(" ", "_")
	button.custom_minimum_size = Vector2(ICON_PX + 8.0, ICON_PX + 8.0)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	var color: Color = badge.color()
	button.add_theme_stylebox_override("normal", UIStyle.box(Color(0.05, 0.03, 0.09, 0.78), Color(color, 0.8), 2, int(ICON_PX * 0.5) + 4))
	button.add_theme_stylebox_override("hover", UIStyle.box(Color(0.12, 0.08, 0.18, 0.92), color, 2, int(ICON_PX * 0.5) + 4))
	button.add_theme_stylebox_override("pressed", UIStyle.box(Color(0.12, 0.08, 0.18, 0.92), color, 3, int(ICON_PX * 0.5) + 4))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	var glyph: TextureRect = IconArt.glyph_or(badge.icon, CardIcons.named(badge.icon) if not badge.icon.begins_with("ICON-") else CardIcons.named(RuleBadges.DEFAULT_ICON), color, ICON_PX - 8.0)
	if glyph != null:
		glyph.position = Vector2(8.0, 8.0)
		glyph.size = Vector2(ICON_PX - 8.0, ICON_PX - 8.0)
		glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(glyph)
	HoverTip.attach_dynamic(button, badge.name, func() -> String:
		return badge.tooltip() + ("\n\nHappened on turn %d." % int(button.get_meta("fired_turn")) if button.has_meta("fired_turn") else ""), color)
	button.pressed.connect(toggle_panel)
	return button


## Overnight Oct 23: a scripted event has happened - its icon dims and gets a tick; the tooltip says when.
func mark_fired(badge_name: String, turn: int) -> void:
	if _row == null:
		return
	for child: Node in _row.find_children("Badge_*", "", true, false):
		if child.name != "Badge_%s" % badge_name.replace(" ", "_") or child.has_meta("fired_turn"):
			continue
		child.set_meta("fired_turn", turn)
		(child as Control).modulate = Color(1, 1, 1, 0.55)
		var tick: Label = UIKit.label("done", &"", 12, Color("ffe08a"))
		tick.position = Vector2(2.0, ICON_PX - 8.0)
		tick.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		tick.add_theme_constant_override("outline_size", 4)
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		child.add_child(tick)


func _on_caption_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		toggle_panel()


func is_open() -> bool:
	return _panel != null and is_instance_valid(_panel) and _panel.visible


## The full list of rules, under the row; click again (or press the row) to close it.
func toggle_panel() -> void:
	if is_open():
		_panel.visible = false
		toggled.emit(false)
		return
	if _panel == null or not is_instance_valid(_panel):
		_panel = PanelContainer.new()
		_panel.name = "RulesPanel"
		_panel.theme_type_variation = &"DarkPanel"
		_panel.custom_minimum_size = Vector2(340, 0)
		_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		_panel.z_index = 40
		var column: VBoxContainer = UIKit.vbox(6)
		_panel.add_child(column)
		column.add_child(UIKit.label(caption_text if not caption_text.is_empty() else "Rules", &"HeadingLabel", 21))
		for badge: RuleBadges.Badge in badges:
			column.add_child(_full_row(badge))
		add_child(_panel)
		_panel.position = Vector2(0.0, size.y + 6.0 if size.y > 0.0 else ICON_PX + 28.0)
	_panel.visible = true
	toggled.emit(true)


func _full_row(badge: RuleBadges.Badge) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	var color: Color = badge.color()
	var glyph: TextureRect = IconArt.glyph_or(badge.icon, CardIcons.named(badge.icon) if not badge.icon.begins_with("ICON-") else CardIcons.named(RuleBadges.DEFAULT_ICON), color, 24.0)
	if glyph != null:
		glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(glyph)
	var box: VBoxContainer = UIKit.vbox(0)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	var head: Label = UIKit.label(badge.name, &"", 18, color)
	head.add_theme_font_override("font", UIStyle.font_bold())
	box.add_child(head)
	var body: Label = UIKit.label("%s  (%s)" % [badge.text, badge.side_text().trim_suffix(".")], &"MutedLabel", 15)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(290, 0)
	box.add_child(body)
	row.add_child(box)
	return row
