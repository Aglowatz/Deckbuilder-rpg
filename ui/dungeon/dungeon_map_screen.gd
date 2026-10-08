class_name DungeonMapScreen
extends Control
## The dungeon node map: nodes joined by paths over a 3D diorama, the party marker, the run's
## HP bar, and the entry points for battles, the challenge and the shrine.

const MAP_ORIGIN: Vector2 = Vector2(120.0, 150.0)
const MAP_EXTENT: Vector2 = Vector2(1680.0, 880.0)
## Big maps (Primm's Castle, 30 nodes) draw their nodes smaller so the rows and columns do not overlap.
const DENSE_NODE_COUNT: int = 18
const DENSE_NODE_SCALE: float = 0.78

var map: DungeonMap
var run: DungeonRun
var _buttons: Dictionary = {}
var _paths: MapPaths
var _marker: Control
var _info_title: Label
var _info_body: RichTextLabel
var _hp_label: Label
var _hp_bar: ProgressBar
var _modal: Control
var _busy: bool = false
var _screenshot_args: Dictionary = {}
var _dialogue: DialogueBox
## Set while inside a zone's final dungeon (Part E): its data (foes, events, backdrop).
var _main_def: MainDungeonDef
## The dungeon list entry of this map and its painted map (null when the dungeon has no image yet: the placeholder diorama is used then).
var _plan: DungeonCatalog.Blueprint
var _art: Texture2D
## Where the painted map sits on the 1920x1080 screen: as large as fits, never cropped (3:2 art leaves a band at each side).
var _art_rect: Rect2 = Rect2(0.0, 0.0, 1920.0, 1080.0)
var _info_panel: PanelContainer
var _rules_panel: PanelContainer


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


func _ready() -> void:
	SceneManager.pause_allowed = true
	Audio.play_music(&"map")
	if not Session.in_dungeon() and _screenshot_args.has("dungeon"):
		_prepare_dungeon_for_screenshot()
	elif not Session.in_dungeon() and _screenshot_args.has("main"):
		_prepare_main_dungeon_for_screenshot()
	elif not Session.in_dungeon() and _screenshot_args.has("mini"):
		_prepare_mini_dungeon_for_screenshot()
	elif not Session.in_dungeon():
		Session.ensure_game()
		Session.dungeon_map = TrialOfTheHollow.build_map()
		Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
		var progress: int = int(_screenshot_args.get("progress", 0))
		for step: int in range(progress):
			Session.dungeon_map.complete(Session.dungeon_map.available()[0].id)
			if _screenshot_args.has("damage"):
				Session.run.lose_hp(int(_screenshot_args["damage"]))
	map = Session.dungeon_map
	run = Session.run
	if Session.main_dungeon_active or Session.mini_active:
		_main_def = MainDungeons.def(Session.dungeon_key)
	_plan = _find_plan()
	_art = MapArt.texture_for(_plan.map_id) if _plan != null else null
	if _art != null:
		_build_art()
	else:
		# No painted map for this dungeon yet: the placeholder diorama backdrop.
		if Session.main_dungeon_active:
			add_child(DungeonBackdrop.make(_main_def.backdrop))
		else:
			var backdrop: ArenaBackdrop = ArenaBackdrop.new()
			backdrop.zone_id = Session.zone_run.zone_id if (Session.mini_active and Session.zone_run != null) else "hollow"
			add_child(backdrop)
		var dim: ColorRect = ColorRect.new()
		dim.color = Color(0.03, 0.02, 0.07, 0.25)
		UIKit.full_rect(dim)
		dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(dim)
		add_child(UIKit.vignette(0.85))
	_build_board()
	_build_hud()
	_build_nodes()
	_refresh_hp()
	_build_dungeon_extras()
	_dialogue = DialogueBox.new()
	_dialogue.z_index = 150
	add_child(_dialogue)
	if _screenshot_args.has("open"):
		_open_from_screenshot.call_deferred(str(_screenshot_args["open"]))
	EventBus.tutorial_event.emit(&"map_entered")
	if _screenshot_args.is_empty() or _screenshot_args.has("tip"):
		TipPanel.show_once(self, &"tip_map", "The dungeon map", ("Glowing nodes are your next steps, and some of them are real choices between routes. [b]HP carries from fight to fight[/b] and nothing heals except at shrines - this is the zone's HP. Lose a duel and you wake at the hub (for a paperwork fee)." if (Session.mini_active or Session.main_dungeon_active) else "Glowing nodes are your next steps. [b]HP carries from fight to fight[/b], so save the shrine for when you need it. Lose a duel and you are carried back to town with your collection intact."), Vector2(560, 140))
	_play_pending_after_story.call_deferred()
	if Session.boss_phase_pending and Session.main_dungeon_active:
		_begin_boss_phase.call_deferred()


## Brief 10: between the final boss's phases the map plays the scene (`primm_p1` / `primm_p2`) and then starts the next duel.
func _begin_boss_phase() -> void:
	var boss: DungeonMap.MapNode = map.boss()
	if boss == null:
		return
	_busy = true
	var scene_id: String = "primm_p%d" % Session.boss_phase
	Session.boss_phase_pending = false
	var start: Callable = func() -> void:
		Audio.sfx(&"door")
		Session.start_battle(Session.make_dungeon_battle(boss))
	if CutsceneDefs.has_scene(scene_id):
		_show_cutscene(start, scene_id)
	else:
		start.call()


## Screenshot/dev only: enter any dungeon of the dungeon list by ID (`--dungeon=D-HOG`, `S-TOWN`... plus `--progress=N`); D-TUT is the Forgotten Cave.
func _prepare_dungeon_for_screenshot() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(str(_screenshot_args["dungeon"]))
	if plan == null:
		return
	Session.ensure_game()
	if plan.type == DungeonCatalog.TYPE_TUTORIAL:
		Session.dungeon_map = TrialOfTheHollow.build_map()
		Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
		for step: int in range(int(_screenshot_args.get("progress", 0))):
			Session.dungeon_map.complete(Session.dungeon_map.available()[0].id)
		return
	if not plan.is_side():
		_screenshot_args["main"] = plan.zone_id
		_prepare_main_dungeon_for_screenshot()
	elif ZoneDefs.has_def(plan.zone_id):
		_screenshot_args["mini"] = plan.zone_id
		_prepare_mini_dungeon_for_screenshot()
	else:
		Session.dungeon_key = plan.id
		Session.dungeon_map = MainDungeons.build_map(plan.id)
		Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
		Session.mini_active = true
		Session.town_side_active = true
		for step: int in range(int(_screenshot_args.get("progress", 0))):
			var choices: Array[DungeonMap.MapNode] = Session.dungeon_map.available()
			if choices.is_empty():
				break
			Session.dungeon_map.complete(choices[0].id)


## Screenshot/dev only: enter a zone's mini dungeon directly (`--mini=<zone id> --progress=N`).
func _prepare_mini_dungeon_for_screenshot() -> void:
	Session.ensure_game()
	var zone_id: String = str(_screenshot_args.get("mini", "necrocrat"))
	Session.zone_run = ZoneRun.enter(zone_id, Session.profile, Session.deck)
	Session.dungeon_key = DungeonCatalog.side_for_zone(zone_id).id
	Session.dungeon_map = MiniDungeon.build_map(zone_id)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.mini_active = true
	for step: int in range(int(_screenshot_args.get("progress", 0))):
		var choices: Array[DungeonMap.MapNode] = Session.dungeon_map.available()
		if choices.is_empty():
			break
		Session.dungeon_map.complete(choices[0].id)


## Screenshot/dev only: enter a zone's final dungeon directly (`--main=<zone id> --progress=N`).
func _prepare_main_dungeon_for_screenshot() -> void:
	Session.ensure_game()
	var zone_id: String = str(_screenshot_args.get("main", "beefcake"))
	Session.zone_run = ZoneRun.enter(zone_id, Session.profile, Session.deck)
	Session.dungeon_key = zone_id
	Session.dungeon_map = MainDungeons.build_map(zone_id)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.main_dungeon_active = true
	for step: int in range(int(_screenshot_args.get("progress", 0))):
		var choices: Array[DungeonMap.MapNode] = Session.dungeon_map.available()
		if choices.is_empty():
			break
		Session.dungeon_map.complete(choices[int(_screenshot_args.get("branch", 0)) % choices.size()].id)
	if _screenshot_args.has("damage"):
		Session.run.lose_hp(int(_screenshot_args["damage"]))
	if _screenshot_args.has("boon") and MainDungeons.def(zone_id).boon != null:
		Session.run.add_dungeon_source(MainDungeons.def(zone_id).boon)


func _build_board() -> void:
	if _art == null:
		_build_placeholder_board()
	_paths = MapPaths.new()
	_paths.position = Vector2.ZERO
	_paths.size = Vector2(1920, 1080)
	_paths.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_paths.style = DungeonCatalog.path_style(_plan.id) if _plan != null else "full"
	add_child(_paths)


func _build_placeholder_board() -> void:
	var board: Panel = Panel.new()
	board.position = MAP_ORIGIN - Vector2(30, 20)
	board.size = MAP_EXTENT + Vector2(60, 40)
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.add_theme_stylebox_override("panel", UIStyle.box(Color(0.06, 0.04, 0.1, 0.5), Color(UIStyle.GOLD_DIM, 0.6), 3, 26, 20))
	add_child(board)


func _node_position(node: DungeonMap.MapNode) -> Vector2:
	if _art != null:
		return _art_rect.position + node.position * _art_rect.size
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
		button.visible = not node.hidden
		if map.nodes.size() > DENSE_NODE_COUNT:
			button.scale = Vector2.ONE * DENSE_NODE_SCALE
		button.hovered.connect(_on_node_hovered)
		button.unhovered.connect(func(_id: int) -> void: _show_default_info())
		button.chosen.connect(_on_node_chosen)
		_buttons[node.id] = button
	if map.nodes.size() > DENSE_NODE_COUNT:
		_paths.trim_radius = 62.0 * DENSE_NODE_SCALE
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
	if _art != null:
		_build_art_hud()
		return
	var title: Label = UIKit.label(map.dungeon_name, &"TitleLabel", 58, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(360, 26)
	title.size = Vector2(1200, 80)
	add_child(title)
	var hp_panel: PanelContainer = UIKit.panel(&"DarkPanel")
	hp_panel.position = Vector2(34, 28)
	hp_panel.custom_minimum_size = Vector2(320, 0)
	add_child(hp_panel)
	var hp_column: VBoxContainer = UIKit.vbox(6)
	hp_panel.add_child(hp_column)
	var top: HBoxContainer = UIKit.hbox(8)
	var heart: BattleHud.HeartIcon = BattleHud.HeartIcon.new()
	heart.custom_minimum_size = Vector2(34, 34)
	top.add_child(heart)
	_hp_label = UIKit.label("", &"", 30, UIStyle.PARCHMENT)
	_hp_label.add_theme_font_override("font", UIStyle.font_title())
	top.add_child(_hp_label)
	hp_column.add_child(top)
	_hp_bar = ProgressBar.new()
	_hp_bar.custom_minimum_size = Vector2(0, 16)
	_hp_bar.show_percentage = false
	hp_column.add_child(_hp_bar)
	hp_column.add_child(UIKit.label("HP carries from fight to fight.", &"MutedLabel", 18))
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
	var deck_button: FancyButton = FancyButton.make("Deck (B)", &"", Vector2(160, 56))
	deck_button.position = Vector2(60, 894)
	deck_button.tooltip_text = "Edit your deck without leaving the dungeon (same rules as town)."
	deck_button.pressed.connect(_open_deck_builder)
	add_child(deck_button)


func _refresh_hp() -> void:
	_hp_label.text = ("%d / %d" if _art != null else "HP  %d / %d") % [run.hp, run.max_hp()]
	_hp_bar.max_value = run.max_hp()
	_hp_bar.value = run.hp
	var ratio: float = float(run.hp) / float(maxi(run.max_hp(), 1))
	_hp_bar.add_theme_stylebox_override("fill", UIStyle.box(UIStyle.GOOD if ratio > 0.6 else (Color("e0b03a") if ratio > 0.3 else UIStyle.HP_RED), Color(0, 0, 0, 0), 0, 8))


# ---- Info panel -------------------------------------------------------------------------


func _show_default_info() -> void:
	if _art != null:
		_info_panel.visible = false
		return
	if map.is_complete():
		_info_title.text = "%s is quiet" % map.dungeon_name
		_info_body.text = "Every room is cleared."
		return
	_info_title.text = "Choose your path"
	_info_body.text = "Glowing nodes are next. [color=#a89bb5]Hover a node to see what waits there.[/color]"


func _on_node_hovered(id: int) -> void:
	var node: DungeonMap.MapNode = map.node(id)
	_info_title.text = node.title
	var text: String = node.blurb
	if not node.section.is_empty():
		text = "[color=#a89bb5](%s)[/color]  %s" % [node.section, text]
	match node.kind:
		DungeonMap.Kind.BATTLE, DungeonMap.Kind.BOSS, DungeonMap.Kind.ELITE:
			var prize: String = "a choice of card" if node.card_choices > 0 else "no card choice"
			text += "\n[b]%s[/b], %d HP.  Reward: %d gold and XP, %s." % [node.enemy_name, node.enemy_hp, node.gold_reward, prize]
		DungeonMap.Kind.EVENT:
			text += "\nA story event: choose how to deal with it."
		DungeonMap.Kind.RESCUE:
			text += "\nA rescue: free the prisoner and they fight beside you."
		DungeonMap.Kind.TREASURE:
			text += "\nTreasure: gold, XP and an item."
		DungeonMap.Kind.CHALLENGE:
			text += "\nA deck challenge: the outcome depends on the cards you draw."
		DungeonMap.Kind.SHRINE:
			text += "\nRestore [b]%d[/b] HP." % node.heal_amount
	if map.is_cleared(id):
		text += "  [color=#6fbf73](cleared)[/color]"
	_info_body.text = text
	if _art != null:
		_place_info(node)


# ---- Entering nodes ---------------------------------------------------------------------


func _on_node_chosen(id: int) -> void:
	if _busy or _modal != null or (_dialogue != null and _dialogue.active):
		return
	var node: DungeonMap.MapNode = map.node(id)
	Audio.sfx(&"ui_select")
	_play_before(node, _run_node.bind(node))


## What entering a node does, after its story and scene have played.
func _run_node(node: DungeonMap.MapNode) -> void:
	match node.kind:
		DungeonMap.Kind.BATTLE, DungeonMap.Kind.BOSS, DungeonMap.Kind.ELITE:
			_busy = true
			Audio.sfx(&"door")
			Session.start_battle(Session.make_dungeon_battle(node))
		DungeonMap.Kind.CHALLENGE:
			_open_modal(ChallengeScreen.new(), node.id)
		DungeonMap.Kind.SHRINE:
			_open_modal(ShrineScreen.new(), node.id)
		DungeonMap.Kind.EVENT, DungeonMap.Kind.RESCUE:
			var event: DungeonEvent = _main_def.event(node.event_id) if _main_def != null else null
			if event != null:
				_open_modal(EventScreen.make(event, Session.dungeon_key), node.id)
		DungeonMap.Kind.TREASURE:
			_open_modal(TreasureScreen.make(node), node.id)


## The node's story lines (placeholder dialogue), then its cutscene if any, then `then`.
func _play_before(node: DungeonMap.MapNode, then: Callable) -> void:
	var steps: Array[Callable] = []
	if not node.story_before.is_empty() and _main_def != null:
		var before_key: String = HouseOfGainsDungeon.boss_story_key(node.story_before, Session.run)
		steps.append(_show_story.bind(ZoneStoryText.for_zone(_main_def.zone_id).get_lines(before_key), NpcRegistry.story_speaker(node.story_before)))
	# The Forgotten Cave's guardian grumbles that the Wanderer smells familiar (the tutorial has no zone story file).
	if _main_def == null and node.kind == DungeonMap.Kind.BOSS and map != null and map.dungeon_name == TrialOfTheHollow.DUNGEON_NAME:
		steps.append(_show_story.bind(StoryText.shared().get_lines("tutorial.warden.before"), "NPC-WARDEN"))
	# Grandmaster Flex only throws off his coat when he is actually there (the rescue happened).
	var skip_flex: bool = node.scene == "flex" and _main_def != null and not HouseOfGainsDungeon.rescued(Session.run)
	if not node.scene.is_empty() and CutsceneDefs.has_scene(node.scene) and not skip_flex:
		steps.append(_show_cutscene.bind(node.scene))
	if _main_def != null and node.kind == DungeonMap.Kind.BOSS and _main_def.zone_id == CapitalZone.ID:
		steps.append(_show_leaders)
	_run_steps(steps, then)


## The freed leaders join you before the final fight (each lends a boon: `PrimmBoss.leader_boon`).
func _show_leaders(done: Callable) -> void:
	var lines: Array[String] = Session.begin_primm_fight()
	_dialogue.start("The Freed Leaders", lines)
	_dialogue.finished.connect(done, CONNECT_ONE_SHOT)


func _run_steps(steps: Array[Callable], then: Callable) -> void:
	if steps.is_empty():
		then.call()
		return
	var first: Callable = steps[0]
	var rest: Array[Callable] = steps.slice(1)
	first.call(func() -> void: _run_steps(rest, then))


## `speaker_npc_id`: the NPC who speaks the beat (`NpcRegistry.story_speaker`); empty for narration.
func _show_story(done: Callable, lines: Array[String], speaker_npc_id: String = "") -> void:
	_dialogue.start("", lines, speaker_npc_id)
	_dialogue.finished.connect(done, CONNECT_ONE_SHOT)


func _show_cutscene(done: Callable, scene_id: String) -> void:
	var scene: CutsceneScreen = CutsceneScreen.make(scene_id)
	add_child(scene)
	scene.finished.connect(done, CONNECT_ONE_SHOT)


## After returning to the map: the story line of the node just cleared (once per run).
func _play_pending_after_story() -> void:
	if _main_def == null or map == null:
		return
	var node: DungeonMap.MapNode = map.node(map.last_cleared if map.last_cleared >= 0 else map.current)
	if node.story_after.is_empty() or Session.dungeon_story_seen.has(node.id) or not map.is_cleared(node.id):
		return
	Session.dungeon_story_seen.append(node.id)
	_show_story(func() -> void: pass, ZoneStoryText.for_zone(_main_def.zone_id).get_lines(node.story_after), NpcRegistry.story_speaker(node.story_after))


## Part E: the zone effects, the boons earned in this dungeon and the current section under the title.
func _build_dungeon_extras() -> void:
	if _art != null:
		_build_art_extras()
		return
	if _main_def == null and not Session.mini_active:
		return
	var zone_id: String = Session.zone_run.zone_id if Session.zone_run != null else ""
	var effect: ZoneEffects.Effect = ZoneEffects.for_zone(zone_id) if not zone_id.is_empty() else null
	if effect != null:
		var panel: ZoneEffectsPanel = ZoneEffectsPanel.make(effect, Session.zone_def().display_name, true)
		panel.position = Vector2(34, 150)
		add_child(panel)
	var boons: Array[ModifierSource] = []
	for source: ModifierSource in run.dungeon_sources:
		if source.source_kind == ModifierSource.SourceKind.BOON:
			boons.append(source)
	if boons.is_empty():
		return
	var boon_panel: PanelContainer = UIKit.panel(&"DarkPanel")
	boon_panel.name = "BoonPanel"
	boon_panel.position = Vector2(1560, 150)
	boon_panel.custom_minimum_size = Vector2(330, 0)
	add_child(boon_panel)
	var column: VBoxContainer = UIKit.vbox(4)
	boon_panel.add_child(column)
	column.add_child(UIKit.label("Boons", &"HeadingLabel", 22))
	for boon: ModifierSource in boons:
		var row: Label = UIKit.label(boon.source_name, &"", 18, Color("9cf5a0"))
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.custom_minimum_size = Vector2(300, 0)
		column.add_child(row)


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
		Session.abandon_run("You were carried out of %s. Your collection is safe." % map.dungeon_name)
		return
	SceneManager.change_scene("res://scenes/dungeon_map.tscn", 0.25)


## New brief, Part B: a B hotkey alongside the existing Deck button, matching town/zones.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_B:
		get_viewport().set_input_as_handled()
		_open_deck_builder()


## Part C: a deck builder reachable from inside the dungeon, same validation rules as town (see
## DungeonDeckbuilderScreen) - it edits the run's current deck, not a map node, so it does not
## flow through `_open_modal`/`_on_modal_finished` (no node to complete afterward).
func _open_deck_builder() -> void:
	if _busy or _modal != null:
		return
	Audio.sfx(&"ui_select")
	var screen: DungeonDeckbuilderScreen = DungeonDeckbuilderScreen.new()
	_modal = screen
	screen.z_index = 100
	add_child(screen)
	screen.tree_exited.connect(func() -> void: _modal = null)
	screen.closed.connect(screen.queue_free)


func _ask_retreat() -> void:
	if _busy or _modal != null:
		return
	var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Retreat from %s?" % map.dungeon_name, "You leave the dungeon and lose this run's progress. Cards you already took are kept.", "Retreat", "Stay", true)
	dialog.confirmed.connect(func() -> void: Session.abandon_run("You retreated from %s." % map.dungeon_name))


func _open_from_screenshot(what: String) -> void:
	match what:
		"challenge":
			_open_modal(ChallengeScreen.new(), 2)
		"shrine":
			_open_modal(ShrineScreen.new(), 4)
		"deck":
			_open_deck_builder()
		"event":
			var shown: DungeonEvent = _main_def.event(str(_screenshot_args.get("event_id", ""))) if _main_def != null else null
			if shown != null:
				_open_modal(EventScreen.make(shown, Session.dungeon_key), 1)
		"treasure":
			for candidate: DungeonMap.MapNode in map.nodes:
				if candidate.kind == DungeonMap.Kind.TREASURE:
					_open_modal(TreasureScreen.make(candidate), candidate.id)
					break
		"cutscene":
			var scene: CutsceneScreen = CutsceneScreen.make(str(_screenshot_args.get("scene_id", "flex")))
			add_child(scene)
			for beat: int in range(int(_screenshot_args.get("beat", 0))):
				scene.advance()
				scene.advance()


# ---- The painted map ----------------------------------------------------------------------------------


func _find_plan() -> DungeonCatalog.Blueprint:
	if Session.main_dungeon_active or Session.mini_active:
		return MainDungeons.blueprint(Session.dungeon_key)
	return DungeonCatalog.find(DungeonCatalog.TUTORIAL_ID)


## The largest centred rectangle of the screen with `size` aspect ratio: the map is shown whole, never cropped.
static func fit_rect(size: Vector2) -> Rect2:
	var scale: float = minf(1920.0 / size.x, 1080.0 / size.y)
	var fitted: Vector2 = size * scale
	return Rect2((Vector2(1920.0, 1080.0) - fitted) * 0.5, fitted)


func _build_art() -> void:
	var black: ColorRect = ColorRect.new()
	black.color = Color(0.02, 0.015, 0.03)
	UIKit.full_rect(black)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(black)
	_art_rect = fit_rect(_art.get_size())
	var picture: TextureRect = TextureRect.new()
	picture.name = "MapArt"
	picture.texture = _art
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_SCALE
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	picture.position = _art_rect.position
	picture.size = _art_rect.size
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(picture)


## HUD for a painted map: nothing covers the art. The title sits in a small plate on top, HP / gold / buttons in the side bands, and the node info
## floats next to the hovered node. Zone effects, dungeon rules and boons live behind the Rules button.
func _build_art_hud() -> void:
	var plate: PanelContainer = UIKit.panel(&"DarkPanel")
	plate.name = "TitlePlate"
	plate.set_anchors_preset(Control.PRESET_CENTER_TOP)
	plate.grow_horizontal = Control.GROW_DIRECTION_BOTH
	plate.position.y = 6.0
	plate.modulate.a = 0.88
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(plate)
	plate.add_child(UIKit.label(map.dungeon_name, &"HeadingLabel", 34, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var band: VBoxContainer = UIKit.vbox(8)
	band.position = Vector2(8.0, 8.0)
	band.custom_minimum_size = Vector2(134.0, 0.0)
	add_child(band)
	var hp_panel: PanelContainer = UIKit.panel(&"DarkPanel")
	band.add_child(hp_panel)
	var hp_column: VBoxContainer = UIKit.vbox(4)
	hp_panel.add_child(hp_column)
	var top: HBoxContainer = UIKit.hbox(6)
	var heart: BattleHud.HeartIcon = BattleHud.HeartIcon.new()
	heart.custom_minimum_size = Vector2(26, 26)
	top.add_child(heart)
	_hp_label = UIKit.label("", &"", 22, UIStyle.PARCHMENT)
	_hp_label.add_theme_font_override("font", UIStyle.font_title())
	top.add_child(_hp_label)
	hp_column.add_child(top)
	_hp_bar = ProgressBar.new()
	_hp_bar.custom_minimum_size = Vector2(0, 12)
	_hp_bar.show_percentage = false
	hp_column.add_child(_hp_bar)
	var gold_panel: PanelContainer = UIKit.panel(&"DarkPanel")
	band.add_child(gold_panel)
	var gold_row: HBoxContainer = UIKit.hbox(6)
	gold_panel.add_child(gold_row)
	gold_row.add_child(CardIcons.glyph(CardIcons.ui("coins"), UIStyle.GOLD, Vector2(26, 26)))
	var gold: Label = UIKit.label(str(Session.gold), &"", 24, UIStyle.GOLD)
	gold.add_theme_font_override("font", UIStyle.font_title())
	gold_row.add_child(gold)
	var buttons: VBoxContainer = UIKit.vbox(8)
	buttons.position = Vector2(8.0, 1080.0 - 3.0 * 60.0 - 8.0)
	add_child(buttons)
	var rules_button: FancyButton = FancyButton.make("Rules (R)", &"", Vector2(134, 52))
	rules_button.name = "RulesButton"
	rules_button.pressed.connect(_toggle_rules)
	buttons.add_child(rules_button)
	var deck_button: FancyButton = FancyButton.make("Deck (B)", &"", Vector2(134, 52))
	deck_button.tooltip_text = "Edit your deck without leaving the dungeon (same rules as town)."
	deck_button.pressed.connect(_open_deck_builder)
	buttons.add_child(deck_button)
	var retreat: FancyButton = FancyButton.make("Retreat", &"DangerButton", Vector2(134, 52))
	retreat.pressed.connect(_ask_retreat)
	buttons.add_child(retreat)
	_info_panel = UIKit.panel()
	_info_panel.name = "NodeInfo"
	_info_panel.custom_minimum_size = Vector2(540, 0)
	_info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_info_panel.visible = false
	_info_panel.z_index = 20
	add_child(_info_panel)
	var info_column: VBoxContainer = UIKit.vbox(4)
	_info_panel.add_child(info_column)
	_info_title = UIKit.label("", &"HeadingLabel", 28)
	info_column.add_child(_info_title)
	_info_body = UIKit.rich("", 21)
	_info_body.custom_minimum_size = Vector2(500, 0)
	info_column.add_child(_info_body)


## Puts the node info next to the hovered node, in the half of the map the node is not in, so it never covers the node itself.
func _place_info(node: DungeonMap.MapNode) -> void:
	_info_panel.visible = true
	_info_panel.reset_size()
	var anchor: Vector2 = _node_position(node)
	var x: float = clampf(anchor.x - _info_panel.size.x * 0.5, _art_rect.position.x + 8.0, _art_rect.end.x - _info_panel.size.x - 8.0)
	var y: float = 70.0 if node.position.y > 0.5 else 1080.0 - _info_panel.size.y - 12.0
	_info_panel.position = Vector2(x, y)


## The rules of this dungeon, shown on demand: the zone effects, the buffs and debuffs of the dungeon itself and the boons earned in this run.
func _build_art_extras() -> void:
	_rules_panel = UIKit.panel(&"DarkPanel")
	_rules_panel.name = "RulesPanel"
	_rules_panel.position = Vector2(160.0, 120.0)
	_rules_panel.custom_minimum_size = Vector2(620, 0)
	_rules_panel.z_index = 30
	_rules_panel.visible = false
	add_child(_rules_panel)
	var column: VBoxContainer = UIKit.vbox(6)
	_rules_panel.add_child(column)
	column.add_child(UIKit.label("Rules of %s" % map.dungeon_name, &"HeadingLabel", 26))
	var zone_id: String = Session.zone_run.zone_id if Session.zone_run != null else ""
	var effect: ZoneEffects.Effect = ZoneEffects.for_zone(zone_id) if not zone_id.is_empty() else null
	if effect != null:
		column.add_child(_rule_label("[+] %s" % effect.buff_line(), Color("9cf5a0")))
		column.add_child(_rule_label("[-] %s" % effect.debuff_line(), Color("ff9c8f")))
	for rule: Dictionary in DungeonRules.rules(Session.dungeon_key if (Session.main_dungeon_active or Session.mini_active) else ""):
		var active: bool = bool(rule["active"])
		column.add_child(_rule_label("%s %s: %s%s" % ["[*]" if active else "[ ]", rule["name"], rule["text"], "" if active else "  (not enforced yet)"], UIStyle.PARCHMENT if active else Color(UIStyle.PARCHMENT, 0.6)))
	var boons: Array[ModifierSource] = []
	for source: ModifierSource in run.dungeon_sources:
		if source.source_kind == ModifierSource.SourceKind.BOON:
			boons.append(source)
	if not boons.is_empty():
		column.add_child(UIKit.label("Boons", &"HeadingLabel", 22))
		for boon: ModifierSource in boons:
			column.add_child(_rule_label(boon.source_name, Color("9cf5a0")))


func _rule_label(text: String, color: Color) -> Label:
	var label: Label = UIKit.label(text, &"", 19, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(580, 0)
	return label


func _toggle_rules() -> void:
	if _rules_panel != null:
		_rules_panel.visible = not _rules_panel.visible
		Audio.sfx(&"ui_tick", -6.0)


func _unhandled_key_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_R and _rules_panel != null and _modal == null:
		_toggle_rules()
		get_viewport().set_input_as_handled()
