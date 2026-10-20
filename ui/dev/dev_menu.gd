class_name DevMenu
extends CanvasLayer
## Oct 20, Part 1: the Dev Menu. F10 opens and closes it anywhere (title, overworld, menus, battles). Six tabs - Travel, Player, Progress,
## Battle, View, Saves - whose buttons call `DevActions` (the real systems) and toast what happened. Debug builds only: `SceneManager`
## installs it when `DevTools.menu_enabled()`, so a release export never has one. The world pauses while it is open; the view tools
## (fps overlay, time scale, hidden HUD, free camera, walkable overlay) keep running after it closes. Docs: docs/dev_menu.md.

const TABS: Array[String] = ["Travel", "Player", "Progress", "Battle", "View", "Saves"]
const PAGE_SIZE: Vector2 = Vector2(1080, 520)
const LABEL_WIDTH: float = 190.0
const RESOURCE_KINDS: Array[ResourceKind.Kind] = [ResourceKind.Kind.IRON, ResourceKind.Kind.RED_TAPE, ResourceKind.Kind.CONTRACT, ResourceKind.Kind.INGREDIENT, ResourceKind.Kind.GARBAGE]
const TIME_SCALES: Array[float] = [0.5, 1.0, 2.0, 4.0]

var _root: Control
var _tabs: Array[Button] = []
var _body: VBoxContainer
var _page: int = 0
var _was_paused: bool = false

## View tools (they outlive the panel).
var show_fps: bool = false
var time_scale: float = 1.0
var hud_hidden: bool = false
var _fps_label: Label
var _fps_time: float = 0.0
var _fps_frames: int = 0
var _hidden_layers: Array[CanvasLayer] = []
var _free_cam: DevFreeCamera
var _walk_overlay: DevWalkOverlay

## Picker state kept across page rebuilds.
var _dungeon_ids: Array[String] = []
var _dungeon_pick: int = 0
var _quest_ids: Array[String] = []
var _quest_pick: int = 0
var _card_query: String = ""
var _ignore_caps: bool = false
var _encounter_query: String = ""
var _deck_pick: int = 0


## Adds the menu to the tree root in debug builds; returns null (and adds nothing) in a release build.
static func install(tree: SceneTree, force_debug: bool = OS.is_debug_build()) -> DevMenu:
	if not DevTools.menu_enabled(force_debug):
		return null
	var menu: DevMenu = DevMenu.new()
	menu.name = "DevMenu"
	tree.root.add_child.call_deferred(menu)
	return menu


func _ready() -> void:
	layer = 110
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root = UIKit.layer_host(self)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.visible = false
	UiScale.fit(_root)
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.01, 0.04, 0.6)
	UIKit.full_rect(dim)
	_root.add_child(dim)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	_root.add_child(center)
	var panel: PanelContainer = UIKit.panel()
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(10)
	panel.add_child(column)
	column.add_child(UIKit.label("Dev Menu  (F10)", &"HeadingLabel", 30, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var tab_row: HBoxContainer = UIKit.hbox(8)
	tab_row.alignment = BoxContainer.ALIGNMENT_CENTER
	for index: int in range(TABS.size()):
		var tab: Button = FancyButton.make(TABS[index], &"GhostButton", Vector2(160, 44))
		tab.name = "Tab%s" % TABS[index]
		tab.toggle_mode = true
		tab.pressed.connect(show_page.bind(index))
		tab_row.add_child(tab)
		_tabs.append(tab)
	column.add_child(tab_row)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = PAGE_SIZE
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	_body = UIKit.vbox(10)
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_body)
	var close: FancyButton = FancyButton.make("Close (F10)", &"PrimaryButton", Vector2(220, 48))
	close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close.pressed.connect(close_menu)
	column.add_child(close)
	_fps_label = UIKit.label("", &"", 20, UIStyle.GOLD)
	_fps_label.name = "DevFps"
	_fps_label.position = Vector2(12, 1040)
	_fps_label.visible = false
	add_child(_fps_label)
	SceneManager.revealed.connect(_on_scene_revealed)


func is_open() -> bool:
	return _root.visible


func _input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_F10:
		toggle()
		get_viewport().set_input_as_handled()
	elif is_open() and key != null and key.pressed and key.keycode == KEY_ESCAPE:
		close_menu()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	if is_open():
		close_menu()
	else:
		open_menu()


func open_menu() -> void:
	if is_open():
		return
	_was_paused = get_tree().paused
	get_tree().paused = true
	_root.visible = true
	show_page(_page)


func close_menu() -> void:
	if not is_open():
		return
	_root.visible = false
	get_tree().paused = _was_paused or _free_cam != null


## Runs an action and toasts its line. `travels` closes the menu first (a scene change must not start paused).
func _act(action: Callable, travels: bool = false) -> void:
	if travels:
		_was_paused = false
		_set_free_camera(false)
		close_menu()
	var line: String = str(action.call())
	toast(line)
	if not travels and is_open():
		show_page(_page)


func toast(line: String) -> void:
	if not line.is_empty():
		EventBus.toast_requested.emit("[Dev] " + line)


func _battle() -> BattleScreen:
	return get_tree().current_scene as BattleScreen


## Applies a teleport or a scene call the last travel action left for the scene that has just appeared.
func _on_scene_revealed() -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return
	if not DevActions.pending_teleport.is_empty() and scene.has_method("_teleport"):
		scene.call("_teleport", DevActions.pending_teleport)
	if not DevActions.pending_call.is_empty() and scene.has_method(DevActions.pending_call):
		scene.call(DevActions.pending_call)
	DevActions.pending_teleport = ""
	DevActions.pending_call = ""
	if hud_hidden:
		_set_hud_hidden(true)


# ---- Pages -----------------------------------------------------------------------------------------------------------------------


func show_page(index: int) -> void:
	_page = clampi(index, 0, TABS.size() - 1)
	for tab_index: int in range(_tabs.size()):
		_tabs[tab_index].button_pressed = tab_index == _page
	for child: Node in _body.get_children():
		_body.remove_child(child)
		child.queue_free()
	match _page:
		0:
			_build_travel()
		1:
			_build_player()
		2:
			_build_progress()
		3:
			_build_battle()
		4:
			_build_view()
		_:
			_build_saves()


func _row(text: String) -> HBoxContainer:
	var row: HBoxContainer = UIKit.hbox(8)
	var label: Label = UIKit.label(text, &"", 20, UIStyle.PARCHMENT)
	label.custom_minimum_size = Vector2(LABEL_WIDTH, 0)
	row.add_child(label)
	_body.add_child(row)
	return row


func _button(row: Control, text: String, action: Callable, travels: bool = false, enabled: bool = true) -> Button:
	var button: Button = FancyButton.make(text, &"GhostButton", Vector2(0, 40))
	button.disabled = not enabled
	button.pressed.connect(func() -> void: _act(action, travels))
	row.add_child(button)
	return button


func _options(row: Control, labels: Array[String], selected: int, on_pick: Callable, width: float = 420.0) -> OptionButton:
	var options: OptionButton = OptionButton.new()
	options.custom_minimum_size = Vector2(width, 40)
	for text: String in labels:
		options.add_item(text)
	options.selected = clampi(selected, 0, maxi(0, labels.size() - 1))
	options.item_selected.connect(on_pick)
	row.add_child(options)
	return options


func _spin(row: Control, low: float, high: float, value: float, step: float = 1.0) -> SpinBox:
	var spin: SpinBox = SpinBox.new()
	spin.min_value = low
	spin.max_value = high
	spin.step = step
	spin.value = value
	spin.custom_minimum_size = Vector2(120, 40)
	row.add_child(spin)
	return spin


func _check(row: Control, text: String, value: bool, on_toggle: Callable) -> CheckBox:
	var box: CheckBox = CheckBox.new()
	box.text = text
	box.button_pressed = value
	box.toggled.connect(on_toggle)
	row.add_child(box)
	return box


func _note(text: String) -> void:
	var label: Label = UIKit.label(text, &"", 17, UIStyle.MUTED)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_child(label)


# ---- Travel ----------------------------------------------------------------------------------------------------------------------


func _build_travel() -> void:
	var hub: HBoxContainer = _row("Crosspath")
	_button(hub, "Crosspath", DevActions.travel_town, true)
	_button(hub, "Starting forest", DevActions.travel_forest, true)
	_button(hub, "Undercroft arena", DevActions.travel_arena, true)
	var zones: HBoxContainer = _row("Path zones")
	for zone_id: String in ZoneDefs.ids():
		_button(zones, ZoneDefs.get_def(zone_id).display_name, DevActions.travel_zone.bind(zone_id), true)
	var capital: HBoxContainer = _row("The Capital")
	_button(capital, "Outside the gate", DevActions.travel_zone.bind(CapitalZone.ID), true)
	_button(capital, "Inside (the Crease)", DevActions.travel_capital_inside, true)
	_button(capital, "Primm's castle", DevActions.travel_dungeon.bind("D-PC"), true)
	var iron: HBoxContainer = _row("Gainlands")
	_button(iron, "The Iron Cave (S-IRON)", DevActions.travel_dungeon.bind("S-IRON"), true)
	_dungeon_ids.assign(DungeonCatalog.ids())
	var labels: Array[String] = []
	for id: String in _dungeon_ids:
		var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(id)
		labels.append("%s - %s (%s)" % [id, plan.dungeon_name, plan.type])
	var pick_row: HBoxContainer = _row("Dungeon")
	_options(pick_row, labels, _dungeon_pick, func(index: int) -> void:
		_dungeon_pick = index
		show_page(_page))
	var dungeon_id: String = _dungeon_ids[_dungeon_pick] if _dungeon_pick < _dungeon_ids.size() else ""
	var map: DungeonMap = DevActions.preview_map(dungeon_id)
	var node_row: HBoxContainer = _row("Start at")
	_button(node_row, "First node", DevActions.travel_dungeon.bind(dungeon_id, -1), true)
	_button(node_row, "The boss", DevActions.travel_dungeon.bind(dungeon_id, -2), true)
	if map != null:
		var node_labels: Array[String] = []
		var node_ids: Array[int] = []
		for map_node: DungeonMap.MapNode in map.nodes:
			if map_node.hidden or map_node.kind == DungeonMap.Kind.START:
				continue
			node_ids.append(map_node.id)
			node_labels.append("%d: %s %s" % [map_node.id, DungeonMap.Kind.keys()[map_node.kind], map_node.enemy_name if not map_node.enemy_name.is_empty() else map_node.title])
		var chosen: Array[int] = [0]
		_options(node_row, node_labels, 0, func(index: int) -> void: chosen[0] = index, 300.0)
		_button(node_row, "Go to node", func() -> String: return DevActions.travel_dungeon(dungeon_id, node_ids[chosen[0]]) if not node_ids.is_empty() else "No nodes", true)
	_note("Zones are entered as a fresh visit from town (gatekeeper locks ignored). \"Go to node\" clears the route up to the node so the party stands beside it.")


# ---- Player ----------------------------------------------------------------------------------------------------------------------


func _build_player() -> void:
	var has: bool = Session.has_profile()
	_note("Level %d, %d XP, %d gold, %d cards owned." % [Session.profile.level, Session.profile.xp, Session.gold, Session.profile.owned_cards.size()] if has else "No game yet: any action starts one (Beefcake).")
	var level_row: HBoxContainer = _row("Level")
	var level: SpinBox = _spin(level_row, 1, ProgressionTable.MAX_LEVEL, Session.profile.level if has else 1)
	var silent: CheckBox = _check(level_row, "Silent (no rewards)", false, func(_on: bool) -> void: pass)
	_button(level_row, "Set level", func() -> String: return DevActions.set_level(int(level.value), silent.button_pressed))
	var gold: HBoxContainer = _row("Gold")
	for amount: int in [100, 1000, 10000]:
		_button(gold, "+%d" % amount, DevActions.add_gold.bind(amount))
	var packs: Array[PackData] = PackCatalog.all()
	var pack_labels: Array[String] = ["One of every pack"]
	for pack: PackData in packs:
		pack_labels.append(pack.display_name)
	var pack_row: HBoxContainer = _row("Packs")
	var pack_pick: OptionButton = _options(pack_row, pack_labels, 0, func(_i: int) -> void: pass, 320.0)
	var pack_amount: SpinBox = _spin(pack_row, 1, 20, 1)
	_button(pack_row, "Add", func() -> String: return DevActions.add_packs("" if pack_pick.selected == 0 else packs[pack_pick.selected - 1].id, int(pack_amount.value)))
	var card_row: HBoxContainer = _row("Card")
	var search: LineEdit = LineEdit.new()
	search.placeholder_text = "search by name or id"
	search.text = _card_query
	search.custom_minimum_size = Vector2(320, 40)
	card_row.add_child(search)
	_check(card_row, "Ignore caps", _ignore_caps, func(on: bool) -> void: _ignore_caps = on)
	var results: HFlowContainer = HFlowContainer.new()
	_body.add_child(results)
	var fill: Callable = func(query: String) -> void:
		_card_query = query
		for child: Node in results.get_children():
			child.queue_free()
		if query.strip_edges().length() < 2:
			return
		for card: CardData in DevActions.find_cards(query, 14):
			_button(results, "%s (%s)" % [card.display_name, card.id], func() -> String: return DevActions.add_card(card.id, _ignore_caps))
	search.text_changed.connect(fill)
	fill.call(_card_query)
	var gear: Array[EquipmentData] = DevActions.equipment_choices()
	var gear_labels: Array[String] = []
	for piece: EquipmentData in gear:
		gear_labels.append("%s (%s)" % [piece.source_name, EquipmentData.Slot.keys()[piece.slot].capitalize()])
	var gear_row: HBoxContainer = _row("Equipment")
	var gear_pick: OptionButton = _options(gear_row, gear_labels, 0, func(_i: int) -> void: pass)
	_button(gear_row, "Add", func() -> String: return DevActions.add_equipment(gear[gear_pick.selected].id) if not gear.is_empty() else "")
	var item_ids: Array[String] = []
	var item_labels: Array[String] = []
	for item_id: Variant in Session.content.items.keys():
		item_ids.append(str(item_id))
		item_labels.append((Session.content.items[item_id] as ItemData).display_name)
	var item_row: HBoxContainer = _row("Item")
	var item_pick: OptionButton = _options(item_row, item_labels, 0, func(_i: int) -> void: pass)
	_button(item_row, "Add", func() -> String: return DevActions.add_item(item_ids[item_pick.selected]) if not item_ids.is_empty() else "")
	var misc: HBoxContainer = _row("Other")
	_button(misc, "Unlock all deck slots", DevActions.unlock_deck_slots)
	_button(misc, "Full heal", func() -> String: return DevActions.full_heal(_battle()))
	var hp: SpinBox = _spin(misc, 1, 200, 10)
	_button(misc, "Set HP", func() -> String: return DevActions.set_hp(int(hp.value), _battle()))


# ---- Progress --------------------------------------------------------------------------------------------------------------------


func _build_progress() -> void:
	if not Session.has_profile():
		_note("No game yet.")
		var start: HBoxContainer = _row("")
		_button(start, "Start a game (Beefcake)", func() -> String:
			Session.ensure_game()
			return "New game")
		return
	for zone_id: String in ZoneDefs.ids():
		var row: HBoxContainer = _row(ZoneDefs.get_def(zone_id).display_name)
		_check(row, "Gatekeeper beaten", Session.flag(CorruptedNpcs.unlock_flag(zone_id)), func(on: bool) -> void: toast(DevActions.set_gatekeeper(zone_id, on)))
		_check(row, "Freed (boss beaten)", Session.is_zone_completed(zone_id), func(on: bool) -> void: toast(DevActions.set_zone_freed(zone_id, on)))
	var primm: HBoxContainer = _row("Primm")
	_check(primm, "Defeated (postgame)", Session.flag(&"primm_defeated"), func(on: bool) -> void: toast(DevActions.set_primm_defeated(on)))
	_quest_ids.assign(QuestCatalog.all().map(func(quest: QuestData) -> String: return quest.id))
	var quest_labels: Array[String] = []
	for quest_id: String in _quest_ids:
		var quest: QuestData = QuestCatalog.find(quest_id)
		var state: String = "done" if Session.quest_log.is_completed(quest_id) else ("active" if Session.quest_log.is_active(quest_id) else "-")
		quest_labels.append("%s (%s) [%s]" % [quest.title, quest_id, state])
	var quest_row: HBoxContainer = _row("Quest")
	_options(quest_row, quest_labels, _quest_pick, func(index: int) -> void:
		_quest_pick = index
		show_page(_page), 640.0)
	var picked: QuestData = QuestCatalog.find(_quest_ids[_quest_pick]) if _quest_pick < _quest_ids.size() else null
	if picked != null:
		var step_labels: Array[String] = []
		for index: int in range(picked.objectives.size()):
			step_labels.append("Step %d: %s" % [index + 1, picked.objectives[index].text])
		step_labels.append("Every step done")
		var current: int = Session.quest_log.current_index(picked, Session.unlock_state()) if Session.quest_log.is_active(picked.id) else 0
		var step_row: HBoxContainer = _row("Set step")
		var step_pick: OptionButton = _options(step_row, step_labels, current, func(_i: int) -> void: pass, 640.0)
		_button(step_row, "Set", func() -> String: return DevActions.set_quest_step(picked.id, step_pick.selected))
	var area_row: HBoxContainer = _row("This area")
	var scene: Node = get_tree().current_scene
	_button(area_row, "Reveal the map", func() -> String: return DevActions.reveal_map(get_tree().current_scene))
	_button(area_row, "Open all chests", func() -> String: return DevActions.open_all_chests(get_tree().current_scene))
	_button(area_row, "Reset this area", func() -> String: return DevActions.reset_area(scene), true)
	_note("Set step: earlier steps are met (flags, counters), later ones are un-met; a quest line's step rewards are not paid. Reset: chests close, the map fogs over, enemies return.")


# ---- Battle ----------------------------------------------------------------------------------------------------------------------


func _build_battle() -> void:
	var battle: BattleScreen = _battle()
	var live: HBoxContainer = _row("This battle")
	_button(live, "Win now", func() -> String: return DevActions.end_battle(_battle(), true), true, battle != null)
	_button(live, "Lose now", func() -> String: return DevActions.end_battle(_battle(), false), true, battle != null)
	_button(live, "Draw 1", func() -> String: return DevActions.draw_cards(_battle(), 1), false, battle != null)
	_button(live, "Draw 3", func() -> String: return DevActions.draw_cards(_battle(), 3), false, battle != null)
	_button(live, "+1 energy", func() -> String: return DevActions.add_energy(_battle(), 1), false, battle != null)
	_button(live, "+3 energy", func() -> String: return DevActions.add_energy(_battle(), 3), false, battle != null)
	var resources: HBoxContainer = _row("Resources")
	for kind: ResourceKind.Kind in RESOURCE_KINDS:
		_button(resources, "+1 %s" % ResourceKind.Kind.keys()[kind].capitalize(), func() -> String: return DevActions.add_resource(_battle(), kind, 1), false, battle != null)
	var reveal: HBoxContainer = _row("")
	_button(reveal, "Show the enemy hand", func() -> String: return DevActions.reveal_enemy_hand(_battle()), false, battle != null)
	var deck_labels: Array[String] = ["My deck", "Beefcake starter", "Necrocrat starter", "Gourmand starter", "Refusemancer starter"]
	var deck_values: Array[int] = [DevActions.DECK_MINE, Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER]
	var start_row: HBoxContainer = _row("Start a fight")
	var search: LineEdit = LineEdit.new()
	search.placeholder_text = "encounter, enemy or group (boss, zone:beefcake...)"
	search.text = _encounter_query
	search.custom_minimum_size = Vector2(420, 40)
	start_row.add_child(search)
	_options(start_row, deck_labels, _deck_pick, func(index: int) -> void: _deck_pick = index, 240.0)
	var results: HFlowContainer = HFlowContainer.new()
	_body.add_child(results)
	var fill: Callable = func(query: String) -> void:
		_encounter_query = query
		for child: Node in results.get_children():
			child.queue_free()
		if query.strip_edges().length() < 2:
			return
		for spec: EncounterSpec in DevActions.find_encounters(query, 18):
			_button(results, "%s (%s)" % [spec.enemy_name, spec.group], func() -> String: return DevActions.start_encounter(spec.id, deck_values[_deck_pick]), true)
	search.text_changed.connect(fill)
	fill.call(_encounter_query)
	_note("Fights started here pay nothing and return to Crosspath. Energy added is floating energy for this turn.")


# ---- View ------------------------------------------------------------------------------------------------------------------------


func _build_view() -> void:
	var overlay: HBoxContainer = _row("Overlays")
	_check(overlay, "FPS / frame time", show_fps, func(on: bool) -> void:
		show_fps = on
		_fps_label.visible = on)
	_check(overlay, "Hide HUD", hud_hidden, func(on: bool) -> void: _set_hud_hidden(on))
	_check(overlay, "Walkable overlay", _walk_overlay != null, func(on: bool) -> void: _set_walk_overlay(on))
	var cam: HBoxContainer = _row("Camera")
	_check(cam, "Free camera (world paused; WASD, Q/E, Shift, right-drag)", _free_cam != null, func(on: bool) -> void: _set_free_camera(on))
	var speed: HBoxContainer = _row("Time scale")
	for scale: float in TIME_SCALES:
		var button: Button = _button(speed, "%sx" % str(scale), func() -> String:
			time_scale = scale
			Engine.time_scale = scale
			return "Time scale %sx" % str(scale))
		button.toggle_mode = true
		button.button_pressed = is_equal_approx(scale, time_scale)


func _set_hud_hidden(on: bool) -> void:
	hud_hidden = on
	for layer_node: CanvasLayer in _hidden_layers:
		if is_instance_valid(layer_node):
			layer_node.visible = true
	_hidden_layers.clear()
	var scene: Node = get_tree().current_scene
	if on and scene != null:
		for child: Node in scene.get_children():
			if child is CanvasLayer and (child as CanvasLayer).visible:
				(child as CanvasLayer).visible = false
				_hidden_layers.append(child as CanvasLayer)
	toast("HUD %s" % ("hidden" if on else "shown"))


func _set_walk_overlay(on: bool) -> void:
	if _walk_overlay != null:
		_walk_overlay.queue_free()
		_walk_overlay = null
	var scene: Node = get_tree().current_scene
	var player: TownPlayer = scene.get("player") as TownPlayer if scene != null and "player" in scene else null
	if on:
		if player == null or player.town == null:
			toast("No walkable ground here")
			return
		_walk_overlay = DevWalkOverlay.new()
		_walk_overlay.hero = player
		scene.add_child(_walk_overlay)
	toast("Walkable overlay %s" % ("on" if on else "off"))


func _set_free_camera(on: bool) -> void:
	if _free_cam != null:
		_free_cam.release()
		_free_cam = null
		if not is_open():
			get_tree().paused = false
	if not on:
		return
	var current: Camera3D = get_viewport().get_camera_3d()
	if current == null:
		toast("No 3D camera here")
		return
	_free_cam = DevFreeCamera.new()
	get_tree().current_scene.add_child(_free_cam)
	_free_cam.take_over(current)
	toast("Free camera on (world paused)")


# ---- Saves -----------------------------------------------------------------------------------------------------------------------


func _build_saves() -> void:
	var save_row: HBoxContainer = _row("Snapshot")
	var name_box: LineEdit = LineEdit.new()
	name_box.placeholder_text = "e.g. before Rotheart"
	name_box.custom_minimum_size = Vector2(380, 40)
	save_row.add_child(name_box)
	_button(save_row, "Save", func() -> String: return DevActions.save_snapshot(name_box.text if not name_box.text.strip_edges().is_empty() else "snapshot"), false, Session.has_profile())
	var names: Array[String] = DevActions.snapshots()
	if names.is_empty():
		_note("No snapshots yet (they live in %s, apart from the five save slots)." % DevActions.SNAPSHOT_DIR)
	for snapshot: String in names:
		var row: HBoxContainer = _row(snapshot)
		_button(row, "Load", DevActions.load_snapshot.bind(snapshot), true)
		_button(row, "Delete", DevActions.delete_snapshot.bind(snapshot))


# ---- Every frame -----------------------------------------------------------------------------------------------------------------


func _process(delta: float) -> void:
	# The final blow's slow motion puts the time scale back to 1 when it ends; a chosen dev speed comes back after it.
	if not is_equal_approx(time_scale, 1.0) and is_equal_approx(Engine.time_scale, 1.0):
		Engine.time_scale = time_scale
	if not show_fps:
		return
	_fps_time += delta / maxf(Engine.time_scale, 0.01)
	_fps_frames += 1
	if _fps_time >= 0.25:
		_fps_label.text = "%d fps   %.1f ms" % [roundi(_fps_frames / _fps_time), 1000.0 * _fps_time / float(_fps_frames)]
		_fps_label.position = Vector2(12.0, get_viewport().get_visible_rect().size.y - 40.0)
		_fps_time = 0.0
		_fps_frames = 0
