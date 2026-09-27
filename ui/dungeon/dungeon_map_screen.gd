class_name DungeonMapScreen
extends Control
## The dungeon node map: nodes joined by paths over a 3D diorama, the party marker, the run's
## life bar, and the entry points for battles, the challenge and the shrine.

const MAP_ORIGIN: Vector2 = Vector2(120.0, 150.0)
const MAP_EXTENT: Vector2 = Vector2(1680.0, 880.0)

var map: DungeonMap
var run: DungeonRun
var _buttons: Dictionary = {}
var _paths: MapPaths
var _marker: Control
var _info_title: Label
var _info_body: RichTextLabel
var _life_label: Label
var _life_bar: ProgressBar
var _modal: Control
var _busy: bool = false
var _screenshot_args: Dictionary = {}


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


func _ready() -> void:
	SceneManager.pause_allowed = true
	Audio.play_music(&"map")
	if not Session.in_dungeon():
		Session.ensure_game()
		Session.dungeon_map = TrialOfTheHollow.build_map()
		Session.run = DungeonRun.enter(Session.profile, Session.deck, [TrialOfTheHollow.blessing()] as Array[ModifierSource])
		var progress: int = int(_screenshot_args.get("progress", 0))
		for step: int in range(progress):
			Session.dungeon_map.complete(Session.dungeon_map.available()[0].id)
			if _screenshot_args.has("damage"):
				Session.run.lose_life(int(_screenshot_args["damage"]))
	map = Session.dungeon_map
	run = Session.run
	add_child(ArenaBackdrop.new())
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.07, 0.25)
	UIKit.full_rect(dim)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	add_child(UIKit.vignette(0.85))
	_build_board()
	_build_hud()
	_build_nodes()
	_refresh_life()
	if _screenshot_args.has("open"):
		_open_from_screenshot.call_deferred(str(_screenshot_args["open"]))
	EventBus.tutorial_event.emit(&"map_entered")
	if _screenshot_args.is_empty() or _screenshot_args.has("tip"):
		TipPanel.show_once(self, &"tip_map", "The dungeon map", "Glowing nodes are your next steps. [b]Life carries from fight to fight[/b], so save the shrine for when you need it. Lose a duel and you are carried back to town with your collection intact.", Vector2(560, 140))


func _build_board() -> void:
	var board: Panel = Panel.new()
	board.position = MAP_ORIGIN - Vector2(30, 20)
	board.size = MAP_EXTENT + Vector2(60, 40)
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.add_theme_stylebox_override("panel", UIStyle.box(Color(0.06, 0.04, 0.1, 0.5), Color(UIStyle.GOLD_DIM, 0.6), 3, 26, 20))
	add_child(board)
	_paths = MapPaths.new()
	_paths.position = Vector2.ZERO
	_paths.size = Vector2(1920, 1080)
	_paths.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_paths)


func _node_position(node: DungeonMap.MapNode) -> Vector2:
	return MAP_ORIGIN + Vector2(node.position.x * MAP_EXTENT.x, node.position.y * MAP_EXTENT.y - 60.0)


func _build_nodes() -> void:
	var available_ids: Array[int] = []
	for node: DungeonMap.MapNode in map.available():
		available_ids.append(node.id)
	for node: DungeonMap.MapNode in map.nodes:
		var button: MapNodeButton = MapNodeButton.new()
		button.setup(node, available_ids.has(node.id), map.is_cleared(node.id))
		add_child(button)
		button.position = _node_position(node) - Vector2(MapNodeButton.DIAMETER, MapNodeButton.DIAMETER) * 0.5
		button.hovered.connect(_on_node_hovered)
		button.unhovered.connect(func(_id: int) -> void: _show_default_info())
		button.chosen.connect(_on_node_chosen)
		_buttons[node.id] = button
	_paths.setup(map, func(id: int) -> Vector2: return (_buttons[id] as MapNodeButton).center_point())
	_marker = _make_marker()
	add_child(_marker)
	var from_id: int = int(Session.flags.get("map_marker", 0)) if Session.in_dungeon() else 0
	if from_id >= map.nodes.size() or not _screenshot_args.is_empty():
		from_id = map.current
	_marker.position = (_buttons[from_id] as MapNodeButton).center_point() - _marker.size * 0.5 - Vector2(0, 62)
	Session.flags["map_marker"] = map.current
	if from_id != map.current:
		var target: Vector2 = (_buttons[map.current] as MapNodeButton).center_point() - _marker.size * 0.5 - Vector2(0, 62)
		var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tween.tween_interval(0.4)
		tween.tween_property(_marker, "position", target, 0.9)
		tween.tween_callback(func() -> void: Audio.sfx(&"footstep"))
	_bob_marker()
	_show_default_info()


func _make_marker() -> Control:
	var marker: Control = Control.new()
	marker.size = Vector2(56, 56)
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.z_index = 10
	var disc: Panel = Panel.new()
	disc.size = Vector2(56, 56)
	disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	disc.add_theme_stylebox_override("panel", UIStyle.box(UIStyle.GOLD.darkened(0.6), UIStyle.GOLD, 4, 28, 10))
	marker.add_child(disc)
	marker.add_child(_glyph_at(CardIcons.ui("magic"), Vector2(8, 8), Vector2(40, 40)))
	return marker


func _glyph_at(texture: Texture2D, pos: Vector2, glyph_size: Vector2) -> TextureRect:
	var glyph: TextureRect = CardIcons.glyph(texture, UIStyle.GOLD, glyph_size)
	glyph.position = pos
	glyph.size = glyph_size
	return glyph


func _bob_marker() -> void:
	var glow: Tween = create_tween().set_loops()
	glow.tween_property(_marker, "scale", Vector2(1.08, 1.08), 0.8).set_trans(Tween.TRANS_SINE)
	glow.tween_property(_marker, "scale", Vector2.ONE, 0.8).set_trans(Tween.TRANS_SINE)


func _build_hud() -> void:
	var title: Label = UIKit.label(map.dungeon_name, &"TitleLabel", 58, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(360, 26)
	title.size = Vector2(1200, 80)
	add_child(title)
	var life_panel: PanelContainer = UIKit.panel(&"DarkPanel")
	life_panel.position = Vector2(34, 28)
	life_panel.custom_minimum_size = Vector2(320, 0)
	add_child(life_panel)
	var life_column: VBoxContainer = UIKit.vbox(6)
	life_panel.add_child(life_column)
	var top: HBoxContainer = UIKit.hbox(8)
	var heart: BattleHud.HeartIcon = BattleHud.HeartIcon.new()
	heart.custom_minimum_size = Vector2(34, 34)
	top.add_child(heart)
	_life_label = UIKit.label("", &"", 30, UIStyle.PARCHMENT)
	_life_label.add_theme_font_override("font", UIStyle.font_title())
	top.add_child(_life_label)
	life_column.add_child(top)
	_life_bar = ProgressBar.new()
	_life_bar.custom_minimum_size = Vector2(0, 16)
	_life_bar.show_percentage = false
	life_column.add_child(_life_bar)
	life_column.add_child(UIKit.label("Life carries from fight to fight.", &"MutedLabel", 18))
	var gold_panel: PanelContainer = UIKit.panel(&"DarkPanel")
	gold_panel.position = Vector2(1650, 28)
	add_child(gold_panel)
	var gold_row: HBoxContainer = UIKit.hbox(10)
	gold_panel.add_child(gold_row)
	gold_row.add_child(CardIcons.glyph(CardIcons.ui("coins"), UIStyle.GOLD, Vector2(34, 34)))
	var gold: Label = UIKit.label(str(Session.gold), &"", 30, UIStyle.GOLD)
	gold.add_theme_font_override("font", UIStyle.font_title())
	gold_row.add_child(gold)
	var info: PanelContainer = UIKit.panel()
	info.position = Vector2(400, 900)
	info.custom_minimum_size = Vector2(1120, 150)
	add_child(info)
	var info_column: VBoxContainer = UIKit.vbox(4)
	info.add_child(info_column)
	_info_title = UIKit.label("", &"HeadingLabel", 30)
	info_column.add_child(_info_title)
	_info_body = UIKit.rich("", 23)
	_info_body.custom_minimum_size = Vector2(1080, 0)
	info_column.add_child(_info_body)
	var retreat: FancyButton = FancyButton.make("Retreat", &"DangerButton", Vector2(220, 56))
	retreat.position = Vector2(60, 960)
	retreat.pressed.connect(_ask_retreat)
	add_child(retreat)


func _refresh_life() -> void:
	_life_label.text = "Life  %d / %d" % [run.life, run.max_life()]
	_life_bar.max_value = run.max_life()
	_life_bar.value = run.life
	var ratio: float = float(run.life) / float(maxi(run.max_life(), 1))
	_life_bar.add_theme_stylebox_override("fill", UIStyle.box(UIStyle.GOOD if ratio > 0.6 else (Color("e0b03a") if ratio > 0.3 else UIStyle.LIFE_RED), Color(0, 0, 0, 0), 0, 8))


# ---- Info panel -------------------------------------------------------------------------


func _show_default_info() -> void:
	if map.is_complete():
		_info_title.text = "The Hollow is quiet"
		_info_body.text = "Every chamber is cleared."
		return
	_info_title.text = "Choose your path"
	_info_body.text = "Glowing nodes are next. [color=#a89bb5]Hover a node to see what waits there.[/color]"


func _on_node_hovered(id: int) -> void:
	var node: DungeonMap.MapNode = map.node(id)
	_info_title.text = node.title
	var text: String = node.blurb
	match node.kind:
		DungeonMap.Kind.BATTLE, DungeonMap.Kind.BOSS:
			text += "\n[b]%s[/b], %d life.  Reward: %d gold and a choice of card." % [node.enemy_name, node.enemy_life, node.gold_reward]
		DungeonMap.Kind.CHALLENGE:
			text += "\nA deck challenge: the outcome depends on the cards you draw."
		DungeonMap.Kind.SHRINE:
			text += "\nRestore [b]%d[/b] life." % node.heal_amount
	if map.is_cleared(id):
		text += "  [color=#6fbf73](cleared)[/color]"
	_info_body.text = text


# ---- Entering nodes ---------------------------------------------------------------------


func _on_node_chosen(id: int) -> void:
	if _busy or _modal != null:
		return
	var node: DungeonMap.MapNode = map.node(id)
	Audio.sfx(&"ui_select")
	match node.kind:
		DungeonMap.Kind.BATTLE, DungeonMap.Kind.BOSS:
			_busy = true
			Audio.sfx(&"door")
			Session.start_battle(Session.make_dungeon_battle(node))
		DungeonMap.Kind.CHALLENGE:
			_open_modal(ChallengeScreen.new(), id)
		DungeonMap.Kind.SHRINE:
			_open_modal(ShrineScreen.new(), id)


func _open_modal(screen: Control, node_id: int) -> void:
	_modal = screen
	screen.z_index = 100
	screen.set_meta("node_id", node_id)
	add_child(screen)
	screen.tree_exited.connect(func() -> void: _modal = null)
	screen.connect("finished", _on_modal_finished.bind(node_id))


func _on_modal_finished(node_id: int) -> void:
	if _modal != null:
		_modal.queue_free()
		_modal = null
	map.complete(node_id)
	Session.save_game()
	if run.failed:
		Session.abandon_run("You were carried out of the Hollow. Your collection is safe.")
		return
	SceneManager.change_scene("res://scenes/dungeon_map.tscn", 0.25)


func _ask_retreat() -> void:
	if _busy or _modal != null:
		return
	var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Retreat from the Hollow?", "You leave the dungeon and lose this run's progress. Cards you already took are kept.", "Retreat", "Stay", true)
	dialog.confirmed.connect(func() -> void: Session.abandon_run("You retreated from the Hollow."))


func _open_from_screenshot(what: String) -> void:
	match what:
		"challenge":
			_open_modal(ChallengeScreen.new(), 2)
		"shrine":
			_open_modal(ShrineScreen.new(), 4)
