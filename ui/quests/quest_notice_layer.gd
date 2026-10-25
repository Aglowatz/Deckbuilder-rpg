class_name QuestNoticeLayer
extends CanvasLayer
## Fixes Oct 25, Part 7: a short banner whenever a quest starts, a step is done or a quest is finished - "New quest" / "Quest updated" /
## "Quest complete", the quest's name and its NEW objective (or the reward). It sits beside the HUD's quest tracker (top left; top centre
## where a scene has no tracker), far from the dialogue box at the bottom, never takes the mouse and never pauses anything. Notices queue
## and play one after another; while a battle, a scene change or a paused menu is up they wait and show once the world is back. Each one
## plays a sound and briefly lights the tracker. Installed once at the tree root by SceneManager (release builds too).
## Source: `EventBus.quest_update(kind, quest_id, detail)` from Session (start_quest, refresh_quests, complete_quest).

const SHOW_SECONDS: float = 3.4
const SLIDE_SECONDS: float = 0.22
const FADE_SECONDS: float = 0.3
const WIDTH: float = 440.0
const GAP: float = 14.0
## Notices kept waiting at most (a burst of quests keeps the newest few).
const MAX_QUEUE: int = 4
const COLORS: Dictionary = {"start": Color("ffd25a"), "step": Color("8fd0ff"), "complete": Color("9be08a")}
const HEADERS: Dictionary = {"start": "New quest", "step": "Quest updated", "complete": "Quest complete"}

var _queue: Array[Dictionary] = []
var _panel: PanelContainer
var _header: Label
var _title: Label
var _line: Label
var _showing: bool = false
## The notice on screen ({} when none) - for tests and screenshots.
var current: Dictionary = {}
## Tools/screenshots: a notice stays up until cleared.
var hold: bool = false


static func install(tree: SceneTree) -> QuestNoticeLayer:
	var layer: QuestNoticeLayer = QuestNoticeLayer.new()
	layer.name = "QuestNotices"
	tree.root.add_child.call_deferred(layer)
	return layer


func _ready() -> void:
	layer = 85  # over every HUD, under the pause menu (90) and the scene fade (100)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel = UIKit.panel(&"DarkPanel")
	_panel.name = "QuestNotice"
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.custom_minimum_size = Vector2(WIDTH, 0)
	_panel.visible = false
	add_child(_panel)
	var column: VBoxContainer = UIKit.vbox(2)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(column)
	_header = UIKit.label("", &"", 16, UIStyle.GOLD)
	_header.add_theme_font_override("font", UIStyle.font_bold())
	column.add_child(_header)
	_title = UIKit.label("", &"", 24, UIStyle.PARCHMENT)
	_title.add_theme_font_override("font", UIStyle.font_title())
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_title)
	_line = UIKit.label("", &"", 19, UIStyle.PARCHMENT)
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_line)
	for label: Label in [_header, _title, _line]:
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.custom_minimum_size = Vector2(WIDTH - 30.0, 0)
	EventBus.quest_update.connect(push)


## Queues one notice (Session emits these; tests and tools may call it directly).
func push(kind: String, quest_id: String, detail: String = "") -> void:
	var notice: Dictionary = notice_for(kind, quest_id, detail)
	if notice.is_empty():
		return
	# a later notice about the same quest replaces a waiting one (two steps done at once read as the newest)
	for index: int in range(_queue.size() - 1, -1, -1):
		if str(_queue[index]["quest"]) == quest_id and kind != "complete" and str(_queue[index]["kind"]) != "complete":
			_queue.remove_at(index)
	_queue.append(notice)
	while _queue.size() > MAX_QUEUE:
		_queue.pop_front()


func queued() -> int:
	return _queue.size()


## The words of a notice: {"kind", "quest", "header", "title", "line"}; {} for an unknown quest.
static func notice_for(kind: String, quest_id: String, detail: String = "") -> Dictionary:
	var quest: QuestData = QuestCatalog.find(quest_id)
	if quest == null or not HEADERS.has(kind):
		return {}
	var line: String = detail
	if kind != "complete":
		line = objective_line(quest)
		if not detail.is_empty():
			line += "\n" + detail
	return {"kind": kind, "quest": quest_id, "header": str(HEADERS[kind]), "title": Villain.fill(quest.title), "line": line}


## The quest's NEW objective as the tracker shows it: the current (revealed) step with its progress, or "Hand in to ..." when all are done.
static func objective_line(quest: QuestData) -> String:
	var qlog: QuestLog = Session.quest_log
	var state: UnlockState = Session.unlock_state()
	if not qlog.is_active(quest.id):
		return ""
	if qlog.is_ready_to_turn_in(quest, state):
		return "» Hand in to %s" % quest.turn_in_npc
	var index: int = qlog.current_index(quest, state)
	if index >= quest.objectives.size():
		return ""
	var text: String = Villain.fill(quest.objectives[index].text)
	var progress: Vector2i = qlog.objective_progress(quest, index, state)
	if progress.y > 1:
		text += "  %d/%d" % [progress.x, progress.y]
	return "» " + text


func _process(_delta: float) -> void:
	if _showing or _queue.is_empty() or _must_wait():
		return
	_show(_queue.pop_front())


## Notices wait through battles, scene changes and paused menus (they would be missed or cover the board).
func _must_wait() -> bool:
	if SceneManager.busy or get_tree().paused:
		return true
	return get_tree().current_scene is BattleScreen


func _show(notice: Dictionary) -> void:
	_showing = true
	current = notice
	var color: Color = COLORS.get(str(notice["kind"]), UIStyle.GOLD) as Color
	_header.text = str(notice["header"]).to_upper()
	_header.add_theme_color_override("font_color", color)
	_title.text = str(notice["title"])
	_line.text = str(notice["line"])
	_line.visible = not _line.text.is_empty()
	_panel.reset_size()
	var tracker: QuestTracker = get_tree().get_first_node_in_group(QuestTracker.GROUP) as QuestTracker
	var at: Vector2 = Vector2((1920.0 - WIDTH) * 0.5, 24.0)
	if tracker != null and tracker.is_visible_in_tree():
		var corner: Vector2 = tracker.get_global_transform_with_canvas() * Vector2(tracker.size.x, 0.0)
		at = Vector2(corner.x + GAP, corner.y)
		tracker.flash(color)
	_panel.position = at - Vector2(24.0, 0.0)
	_panel.modulate = Color(1, 1, 1, 0)
	_panel.visible = true
	Audio.sfx(&"quest_complete" if str(notice["kind"]) == "complete" else &"quest_accept")
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_panel, "modulate:a", 1.0, SLIDE_SECONDS)
	tween.tween_property(_panel, "position", at, SLIDE_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if hold:
		return
	tween.chain().tween_interval(SHOW_SECONDS)
	tween.chain().tween_property(_panel, "modulate:a", 0.0, FADE_SECONDS)
	tween.chain().tween_callback(_done)


func _done() -> void:
	_panel.visible = false
	_showing = false
	current = {}
