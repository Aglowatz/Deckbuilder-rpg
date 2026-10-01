class_name DnaScene
extends Node3D
## The playable D.N.A. (Department of Necrotic Affairs): the Necrocrat zone. Builds the office
## complex (`DnaBuilder`), the hero, hub NPCs, roaming enemies, interactables, lighting and HUD, and
## runs the zone life rules (`ZoneRun`): life persists between battles and hits, heal only at the
## hub / with items and cards / by returning to town, and 0 life wakes you at the hub for a fee.

class Spot:
	extends RefCounted
	var id: String = ""
	var title: String = ""
	var position: Vector3 = Vector3.ZERO
	var radius: float = 1.5
	var prompt: String = ""
	var is_npc: bool = false
	var marker: Node3D
	var plate: Label3D


const CAMERA_OFFSET: Vector3 = Vector3(0.0, 10.5, 8.4)
const CLICK_PICK_RADIUS: float = 90.0
const HIDDEN_CHEST_RADIUS: float = 1.5
const LIGHT_POOL: int = 8
const SPAWN_GRACE: float = 2.0
## Rewards of the hidden stashes: id -> {gold, item, card, equipment}. Documented in
## docs/design/secrets.md - keep both in sync.
const CHEST_REWARDS: Dictionary = {
	"chest_farm_a": {"gold": 35, "item": "", "card": ""},
	"chest_farm_b": {"gold": 0, "item": "healing_salve", "card": ""},
	"chest_maze_0": {"gold": 50, "item": "", "card": ""},
	"chest_maze_1": {"gold": 0, "item": "scroll_of_insight", "card": "overdue_intern"},
	"chest_maze_2": {"gold": 25, "item": "firebrand_charm", "card": ""},
	"chest_records_0": {"gold": 60, "item": "", "card": ""},
	"chest_records_1": {"gold": 0, "item": "vitality_charm", "card": "cubicle_zombie"},
	"chest_exec": {"gold": 80, "item": "healing_draught", "card": ""},
}

var builder: DnaBuilder = DnaBuilder.new()
var player: TownPlayer
var hud: TownHud
var life_bar: ZoneLifeBar
var dialogue: DialogueBox
var spots: Array[Spot] = []
var enemies: Array[ZoneEnemy] = []
var story: ZoneStoryText
var _camera: Camera3D
var _overlay_layer: Control
var _overlay: Control
var _flash: ColorRect
var _banner: Label
var _banner_tween: Tween
var _near: Spot
var _npcs: Dictionary = {}
var _light_pool: Array[OmniLight3D] = []
var _light_groups: Array[int] = []
var _light_timer: float = 0.0
var _time: float = 0.0
var _locked: bool = false
var _invulnerable: float = 0.0
var _spawn_grace: float = SPAWN_GRACE
var _chest_near: String = ""
var _room_id: String = ""
var _screenshot_args: Dictionary = {}
var _fainting: bool = false


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


func _ready() -> void:
	SceneManager.pause_allowed = true
	Audio.play_music(&"dna")
	story = ZoneStoryText.shared()
	if not _screenshot_args.is_empty():
		Session.ensure_game()
		if Session.zone_run == null:
			Session.zone_run = ZoneRun.enter(DnaZone.ID, Session.profile, Session.deck)
		if _screenshot_args.has("damage"):
			Session.zone_run.damage(int(_screenshot_args["damage"]))
	if Session.zone_run == null:
		# Reached some other way (a dev launch): start a fresh visit.
		Session.ensure_game()
		Session.zone_run = ZoneRun.enter(DnaZone.ID, Session.profile, Session.deck)
	_ensure_input_actions()
	add_child(DnaLook.environment())
	add_child(DnaLook.moonlight())
	builder.build(self)
	_build_player()
	_build_npcs()
	_build_spots()
	_build_enemies()
	_build_lights()
	_build_camera()
	_build_ui()
	hud.set_objective(story.text("hud.objective"))
	EventBus.zone_life_changed.emit(Session.zone_run.life, Session.zone_run.max_life())
	_apply_pending_result.call_deferred()
	if _screenshot_args.has("at"):
		_teleport(str(_screenshot_args["at"]))
	if _screenshot_args.has("open"):
		_screenshot_open.call_deferred(str(_screenshot_args["open"]))
	Session.save_game()


func _ensure_input_actions() -> void:
	if not InputMap.has_action(&"interact"):
		InputMap.add_action(&"interact")
		var key: InputEventKey = InputEventKey.new()
		key.physical_keycode = KEY_E
		InputMap.action_add_event(&"interact", key)


# ---- Construction ----------------------------------------------------------------------------


func _build_player() -> void:
	var run: ZoneRun = Session.zone_run
	var spawn: Vector3 = builder.anchor("spawn")
	if run.has_return_position:
		spawn = run.return_position
		run.has_return_position = false
	player = TownPlayer.new()
	add_child(player)
	player.setup(builder, "Knight", spawn)


func _npc(id: String, model: String, anchor_name: String, yaw: float, tint: Color) -> void:
	var pos: Vector3 = builder.anchor(anchor_name)
	var npc: Node3D = ModelKit.character(model)
	ModelKit.tint(npc, tint)
	ModelKit.place(self, npc, pos, yaw, TownPlayer.MODEL_SCALE)
	var animation: AnimationPlayer = ModelKit.animation_player(npc)
	if animation != null and animation.has_animation("Idle"):
		animation.play("Idle")
		animation.seek(randf() * 1.5)
	_npcs[id] = npc
	builder.add_blocker(pos, 0.3)


func _build_npcs() -> void:
	_npc("dolores", "Mage", "dolores", 0.0, Color(0.85, 1.0, 0.95))
	_npc("barnaby", "Rogue_Hooded", "barnaby", 90.0, Color(0.9, 1.0, 0.85))
	_npc("pip", "Rogue", "pip", 180.0, Color(0.9, 0.95, 1.0))
	_npc("quiz", "Mage", "quiz", 90.0, Color(0.75, 0.85, 1.0))
	_npc("matching", "Barbarian", "matching", 135.0, Color(1.0, 0.85, 1.0))


func _add_spot(id: String, title: String, pos: Vector3, radius: float, prompt: String, npc: bool = false) -> void:
	var spot: Spot = Spot.new()
	spot.id = id
	spot.title = title
	spot.position = pos
	spot.radius = radius
	spot.prompt = prompt
	spot.is_npc = npc
	var marker: MeshInstance3D = MeshInstance3D.new()
	var mesh: PrismMesh = PrismMesh.new()
	mesh.size = Vector3(0.2, 0.3, 0.2)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = UIStyle.GOLD
	material.emission_enabled = true
	material.emission = UIStyle.GOLD
	material.emission_energy_multiplier = 1.6
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = material
	marker.mesh = mesh
	marker.rotation_degrees.x = 180.0
	marker.position = pos + Vector3(0, 1.45 if npc else 1.7, 0)
	add_child(marker)
	spot.marker = marker
	var plate: Label3D = Label3D.new()
	plate.text = title
	plate.font = UIStyle.font_title()
	plate.font_size = 46
	plate.pixel_size = 0.0045
	plate.outline_size = 14
	plate.outline_modulate = Color(0.04, 0.07, 0.07, 0.95)
	plate.modulate = UIStyle.PARCHMENT
	plate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	plate.no_depth_test = true
	plate.position = marker.position + Vector3(0, 0.34, 0)
	add_child(plate)
	spot.plate = plate
	spots.append(spot)


func _build_spots() -> void:
	_add_spot("dolores", "Dolores, Front Desk", builder.anchor("dolores") + Vector3(0, 0, 1.0), 1.7, "Talk", true)
	_add_spot("barnaby", "Barnaby, Barista", builder.anchor("barnaby") + Vector3(0, 0, 0.6), 1.5, "Talk", true)
	_add_spot("pip", "Pip, Requisitions", builder.anchor("pip") + Vector3(0, 0, -0.6), 1.5, "Talk", true)
	_add_spot("heal", "Breakroom Couch", builder.anchor("heal"), 1.5, "Rest on the couch (full heal)")
	_add_spot("coffee", "Coffee Machine", builder.anchor("coffee"), 1.3, "Pour a cup")
	_add_spot("time_clock", "Time Clock", builder.anchor("time_clock"), 1.3, "Punch in")
	_add_spot("exit", "Elevator to Town", builder.anchor("exit"), 1.6, "Ride up to town (full heal)")
	_add_spot("printer", "Haunted Printer", builder.anchor("printer") + Vector3(0.9, 0, 0), 1.4, "Print a card (%d gold)" % DnaInteractables.PRINTER_COST)
	_add_spot("suggestion", "Suggestion Box", builder.anchor("suggestion"), 1.3, "Drop in a suggestion")
	_add_spot("mini_dungeon", "Sub-Basement 3", builder.anchor("mini_dungeon"), 1.5, "Take the elevator to Quarterly Reviews")
	_add_spot("main_dungeon", "Under Renovation", builder.anchor("main_dungeon"), 1.7, "Try the door")


func _build_enemies() -> void:
	var run: ZoneRun = Session.zone_run
	var index: int = 0
	for spawn: Dictionary in builder.layout.enemy_spawns:
		var instance_id: String = "%s_%d" % [str(spawn["type"]), index]
		index += 1
		if run.is_defeated(instance_id):
			continue
		var enemy: ZoneEnemy = ZoneEnemy.new()
		add_child(enemy)
		enemy.setup(DnaEnemies.info(str(spawn["type"])), instance_id, spawn["home"] as Vector3, float(spawn["patrol"]), builder, player)
		enemy.touched.connect(_on_enemy_touched)
		enemies.append(enemy)


func _build_lights() -> void:
	for i: int in range(LIGHT_POOL):
		var light: OmniLight3D = OmniLight3D.new()
		light.omni_range = 7.5
		light.light_energy = 0.0
		light.light_color = Color(0.7, 1.0, 0.82)
		light.shadow_enabled = false
		light.omni_attenuation = 1.3
		add_child(light)
		_light_pool.append(light)
		_light_groups.append(0)
	_assign_lights()


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.fov = 38.0
	add_child(_camera)
	_camera.current = true
	_camera.position = player.position + CAMERA_OFFSET
	_camera.look_at(player.position + Vector3(0, 0.4, 0), Vector3.UP)


func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var host: Control = UIKit.layer_host(layer)
	host.add_child(UIKit.vignette(0.7))
	_flash = ColorRect.new()
	_flash.color = Color(0.9, 0.05, 0.05, 0.0)
	UIKit.full_rect(_flash)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(_flash)
	hud = TownHud.new()
	host.add_child(hud)
	hud.character_pressed.connect(_open_character_screen)
	hud.deck_pressed.connect(_open_deck_builder)
	hud.quests_pressed.connect(_open_quest_log)
	EventBus.quest_notice.connect(_on_quest_notice)
	life_bar = ZoneLifeBar.new()
	life_bar.position = Vector2(790, 24)
	host.add_child(life_bar)
	_banner = UIKit.label("", &"TitleLabel", 54, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	_banner.position = Vector2(360, 190)
	_banner.size = Vector2(1200, 80)
	_banner.modulate.a = 0.0
	host.add_child(_banner)
	dialogue = DialogueBox.new()
	host.add_child(dialogue)
	var overlay_canvas: CanvasLayer = CanvasLayer.new()
	overlay_canvas.layer = 8
	add_child(overlay_canvas)
	_overlay_layer = UIKit.layer_host(overlay_canvas)


# ---- Frame update ----------------------------------------------------------------------------


func _process(delta: float) -> void:
	_time += delta
	_invulnerable = maxf(0.0, _invulnerable - delta)
	_spawn_grace = maxf(0.0, _spawn_grace - delta)
	var target: Vector3 = player.position + CAMERA_OFFSET
	_camera.position = _camera.position.lerp(target, 1.0 - exp(-5.0 * delta))
	_camera.rotation_degrees = Vector3(-atan2(CAMERA_OFFSET.y, CAMERA_OFFSET.z) * 180.0 / PI, 0.0, 0.0)
	builder.update_visibility(player.position)
	_update_flicker()
	_light_timer -= delta
	if _light_timer <= 0.0:
		_light_timer = 0.25
		_assign_lights()
	var world_active: bool = not _locked and not dialogue.active and not _fainting
	player.input_enabled = world_active
	player.model.visible = _invulnerable <= 0.0 or int(_time * 14.0) % 2 == 0
	for enemy: ZoneEnemy in enemies:
		enemy.active = world_active
		if _spawn_grace > 0.0 and enemy.cooldown < _spawn_grace:
			enemy.cooldown = _spawn_grace
	for spot: Spot in spots:
		var base_y: float = 1.45 if spot.is_npc else 1.7
		spot.marker.position.y = base_y + sin(_time * 2.4 + spot.position.x) * 0.07
		spot.marker.rotation_degrees.y += 60.0 * delta
		var distance: float = Vector2(player.position.x - spot.position.x, player.position.z - spot.position.z).length()
		spot.plate.modulate.a = clampf(1.0 - (distance - 2.4) / 1.6, 0.0, 1.0)
		spot.plate.outline_modulate.a = spot.plate.modulate.a
		spot.plate.visible = spot.plate.modulate.a > 0.02
	_update_nearest()
	_update_chest_prompt()
	_update_room_banner()


func _update_nearest() -> void:
	if _locked or dialogue.active or _fainting:
		hud.hide_prompt()
		_near = null
		return
	var best: Spot = null
	var best_distance: float = 1e9
	for spot: Spot in spots:
		var distance: float = Vector2(player.position.x - spot.position.x, player.position.z - spot.position.z).length()
		if distance <= spot.radius and distance < best_distance:
			best = spot
			best_distance = distance
	if best != _near:
		_near = best
		if best != null:
			Audio.sfx(&"ui_tick", -10.0)
	if _near == null:
		if _chest_near.is_empty():
			hud.hide_prompt()
	else:
		hud.show_prompt("[E]  %s" % _prompt_for(_near))


func _prompt_for(spot: Spot) -> String:
	return spot.prompt


## Hidden stashes: no marker, no plate - the prompt is the only tell, and only up close.
func _update_chest_prompt() -> void:
	if _locked or dialogue.active or _fainting:
		_chest_near = ""
		return
	var found: String = ""
	for id: String in builder.layout.chests.keys():
		if Session.found_secret(_chest_secret(id)):
			continue
		var pos: Vector3 = builder.layout.chests[id] as Vector3
		if Vector2(player.position.x - pos.x, player.position.z - pos.z).length() <= HIDDEN_CHEST_RADIUS:
			found = id
			break
	if found != _chest_near:
		_chest_near = found
		if not found.is_empty():
			Audio.sfx(&"ui_tick", -10.0)
	if not found.is_empty():
		hud.show_prompt("[E]  Open the chest")


static func _chest_secret(id: String) -> String:
	return "dna_%s" % id


func _update_room_banner() -> void:
	var room: DnaLayout.Room = builder.layout.room_at(player.position)
	var id: String = room.id if room != null else _room_id
	if id == _room_id or room == null:
		return
	_room_id = id
	_banner.text = room.title
	if _banner_tween != null and _banner_tween.is_valid():
		_banner_tween.kill()
	_banner.modulate.a = 0.0
	_banner_tween = create_tween()
	_banner_tween.tween_property(_banner, "modulate:a", 1.0, 0.4)
	_banner_tween.tween_interval(1.6)
	_banner_tween.tween_property(_banner, "modulate:a", 0.0, 0.8)


# ---- Lighting: flicker and the pooled lights --------------------------------------------------


func _flicker(group: int) -> float:
	match group:
		1:
			var slot: float = floorf(_time * 11.0)
			var r: float = fposmod(sin(slot * 12.9898 + 4.1) * 43758.5453, 1.0)
			return 0.1 if r > 0.94 else (0.55 if r > 0.9 else 1.0)
		2:
			var cut: float = fposmod(_time * 0.21 + 0.37, 1.0)
			return 0.0 if cut < 0.025 else 0.9 + 0.1 * sin(_time * 53.0)
		3:
			var slot3: float = floorf(_time * 6.0)
			var r3: float = fposmod(sin(slot3 * 78.233 + 1.7) * 12345.6789, 1.0)
			return 0.35 if r3 > 0.86 else 0.92 + 0.08 * sin(_time * 31.0)
	return 1.0


func _update_flicker() -> void:
	for entry: Variant in DnaMaterials.glow_materials():
		var glow: ShaderMaterial = entry as ShaderMaterial
		glow.set_shader_parameter("energy", _flicker(int(glow.get_meta("group", 0))))
	for i: int in range(_light_pool.size()):
		var light: OmniLight3D = _light_pool[i]
		light.light_energy = lerpf(light.light_energy, 1.7 * _flicker(_light_groups[i]) * float(int(light.get_meta("on", 0))), 0.5)


## Moves the pooled lights onto the nearest tube fixtures around the player.
func _assign_lights() -> void:
	var fixtures: Array[DnaLayout.LightSpot] = builder.layout.lights.duplicate()
	var here: Vector3 = player.position
	fixtures.sort_custom(func(a: DnaLayout.LightSpot, b: DnaLayout.LightSpot) -> bool:
		return a.pos.distance_squared_to(here) < b.pos.distance_squared_to(here))
	for i: int in range(_light_pool.size()):
		var light: OmniLight3D = _light_pool[i]
		if i < fixtures.size() and fixtures[i].pos.distance_to(here) < 16.0:
			var fixture: DnaLayout.LightSpot = fixtures[i]
			light.position = fixture.pos - Vector3(0, 0.3, 0)
			light.light_color = fixture.color
			_light_groups[i] = fixture.group
			light.set_meta("on", 1)
		else:
			light.set_meta("on", 0)


# ---- Input -----------------------------------------------------------------------------------


func _unhandled_input(event: InputEvent) -> void:
	if _fainting:
		return
	if not _locked and not dialogue.active and event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var code: Key = (event as InputEventKey).keycode
		if code == KEY_C:
			get_viewport().set_input_as_handled()
			_open_character_screen()
			return
		if code == KEY_B:
			get_viewport().set_input_as_handled()
			_open_deck_builder()
			return
		if code == KEY_J:
			get_viewport().set_input_as_handled()
			_open_quest_log()
			return
	if _locked or dialogue.active:
		return
	var interact: bool = event.is_action_pressed(&"interact") or (event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_SPACE)
	if interact:
		if _near != null:
			get_viewport().set_input_as_handled()
			_interact(_near)
			return
		if not _chest_near.is_empty():
			get_viewport().set_input_as_handled()
			_open_chest(_chest_near)
			return
	if event is InputEventMouseButton and _near != null:
		var click: InputEventMouseButton = event as InputEventMouseButton
		if click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
			if _camera.unproject_position(_near.marker.position).distance_to(click.position) <= CLICK_PICK_RADIUS:
				get_viewport().set_input_as_handled()
				_interact(_near)


# ---- Interactions ----------------------------------------------------------------------------


func _interact(spot: Spot) -> void:
	Audio.sfx(&"ui_select")
	match spot.id:
		"dolores":
			_talk_quest_npc("dolores", DnaZone.NPC_DOLORES, "Dolores")
		"barnaby":
			_talk_quest_npc("barnaby", DnaZone.NPC_BARNABY, "Barnaby")
		"pip":
			_talk_quest_npc("pip", DnaZone.NPC_PIP, "Pip", _open_vendor)
		"heal":
			_use_couch()
		"coffee":
			_use_coffee()
		"time_clock":
			_use_time_clock()
		"exit":
			_ask_exit()
		"main_dungeon":
			_use_main_dungeon()
		"mini_dungeon":
			_ask_mini_dungeon()
		"printer":
			DnaInteractables.printer(self)
		"suggestion":
			DnaInteractables.suggestion_box(self)
		_:
			_interact_extra(spot)


## Hook for spots added by later parts (mini dungeon, puzzle, quiz, matching, printer...).
func _interact_extra(_spot: Spot) -> void:
	pass


func _face_npc(id: String) -> void:
	var npc: Node3D = _npcs.get(id) as Node3D
	if npc != null:
		var offset: Vector3 = player.position - npc.position
		npc.rotation.y = atan2(offset.x, offset.z)
		player.face(npc.position)


func _say(speaker: String, lines: Array[String], then: Callable = Callable()) -> void:
	dialogue.start(speaker, lines)
	if then.is_valid():
		dialogue.finished.connect(then, CONNECT_ONE_SHOT)


## An NPC who gives and takes quests: hand-in first, then a new offer, then a reminder, then the
## plain greeting (intro the first time, "return" lines afterwards). `after` runs when the
## conversation ends (the vendor opens his shop).
func _talk_quest_npc(npc_id: String, npc_name: String, speaker: String, after: Callable = Callable()) -> void:
	_face_npc(npc_id)
	var ready: Array[QuestData] = Session.quests_ready_for(npc_name)
	if not ready.is_empty():
		var quest: QuestData = ready[0]
		_say(speaker, story.get_lines("quest.%s.ready" % quest.id), func() -> void:
			Session.turn_in_quest(quest.id)
			if after.is_valid():
				after.call())
		return
	var offered: Array[QuestData] = Session.quests_offered_by(npc_name)
	if not offered.is_empty():
		var quest: QuestData = offered[0]
		_say(speaker, _greeting(npc_id) + story.get_lines("quest.%s.offer" % quest.id), func() -> void:
			Session.start_quest(quest.id)
			if after.is_valid():
				after.call())
		return
	for quest_id: String in Session.quest_log.active:
		var active_quest: QuestData = QuestCatalog.find(quest_id)
		if active_quest != null and active_quest.giver_npc == npc_name:
			_say(speaker, story.get_lines("quest.%s.active" % quest_id), after)
			return
	_say(speaker, _greeting(npc_id), after)


func _greeting(npc_id: String) -> Array[String]:
	var flag_name: StringName = StringName("dna_met_%s" % npc_id)
	if not Session.flag(flag_name):
		Session.set_flag(flag_name)
		return story.get_lines("npc.%s.intro" % npc_id)
	return story.get_lines("npc.%s.return" % npc_id)


func _use_couch() -> void:
	player.face(builder.anchor("heal"))
	var healed: int = Session.zone_run.fully_heal()
	EventBus.zone_life_changed.emit(Session.zone_run.life, Session.zone_run.max_life())
	Audio.sfx(&"heal")
	hud.toast(story.text("fx.heal_couch") if healed > 0 else "You are already as rested as the dead get.", UIStyle.GOOD)


func _use_coffee() -> void:
	DnaInteractables.coffee(self)


func _use_time_clock() -> void:
	DnaInteractables.time_clock(self)


func _ask_mini_dungeon() -> void:
	player.face(builder.anchor("mini_dungeon"))
	_locked = true
	var cleared: bool = Session.flag(DnaZone.FLAG_MINI_DUNGEON_CLEARED)
	var body: String = "Three meetings in a row. Your life carries from one to the next and nothing heals in between. Win all three for a unique Necrocrat card." if not cleared else "You have already earned the unique card here. You can still sit through the meetings for gold and XP. Life carries over; nothing heals in between."
	var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, "Sub-Basement 3: Quarterly Reviews", body, "Go down", "Not yet")
	dialog.confirmed.connect(func() -> void:
		var run: ZoneRun = Session.zone_run
		run.return_position = builder.anchor("mini_dungeon") + Vector3(0, 0, 1.0)
		run.has_return_position = true
		Audio.sfx(&"door")
		Session.enter_mini_dungeon())
	dialog.cancelled.connect(func() -> void: _locked = false)


func _use_main_dungeon() -> void:
	player.face(builder.anchor("main_dungeon"))
	Audio.sfx(&"ui_error")
	hud.toast("UNDER RENOVATION. Please hold.", Color("ffcf70"))


func _ask_exit() -> void:
	_locked = true
	var dialog: ConfirmDialog = ConfirmDialog.ask(
		_overlay_layer, "Ride up to town?",
		"Leaving the D.N.A. ends this visit. Town heals you fully; defeated staff will be back next time.",
		"Leave", "Stay",
	)
	dialog.confirmed.connect(func() -> void:
		Audio.sfx(&"door")
		Session.leave_zone())
	dialog.cancelled.connect(func() -> void: _locked = false)


func _open_vendor() -> void:
	var data: VendorData = VendorData.new()
	data.vendor_name = "Requisitions"
	for id: String in ZoneCards.VENDOR_IDS:
		data.add(id)
	var screen: VendorScreen = VendorScreen.new()
	screen.stock = data
	screen.screen_title = "Requisitions - Necrocrat Issue"
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


func _open_chest(id: String) -> void:
	var pos: Vector3 = builder.layout.chests.get(id, Vector3.ZERO) as Vector3
	player.face(pos)
	if Session.found_secret(_chest_secret(id)):
		return
	Session.discover_secret(_chest_secret(id))
	var reward: Dictionary = CHEST_REWARDS.get(id, {}) as Dictionary
	var parts: PackedStringArray = []
	var gold: int = int(reward.get("gold", 0))
	if gold > 0:
		Session.add_gold(gold)
		parts.append("+%d gold" % gold)
	var item_id: String = str(reward.get("item", ""))
	if not item_id.is_empty() and Session.content.item(item_id) != null:
		Session.add_item(Session.content.item(item_id))
		parts.append(Session.content.item(item_id).display_name)
	var card_id: String = str(reward.get("card", ""))
	if not card_id.is_empty() and Session.card_by_id(card_id) != null:
		Session.add_cards([Session.card_by_id(card_id)] as Array[CardData])
		parts.append(Session.card_by_id(card_id).display_name)
	var equipment_id: String = str(reward.get("equipment", ""))
	if not equipment_id.is_empty():
		var piece: EquipmentData = Session.content.equipment_piece(equipment_id)
		if piece != null and Session.grant_equipment(piece):
			parts.append(piece.source_name)
	Session.bump_counter(DnaZone.COUNTER_CHESTS)
	_animate_chest(id)
	hud.toast("%s %s" % [story.text("fx.chest"), ", ".join(parts)], UIStyle.GOLD)
	Session.save_game()


func _animate_chest(id: String) -> void:
	Audio.sfx(&"chest_open")
	Audio.sfx(&"coins", 0.0, 0.05)
	var chest: Node3D = builder.chest_nodes.get(id) as Node3D
	if chest != null:
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(chest, "scale", chest.scale * 1.35, 0.18)
		tween.tween_property(chest, "scale", chest.scale, 0.22)


# ---- Zone life: enemies, damage, fainting ----------------------------------------------------


func _on_enemy_touched(enemy: ZoneEnemy) -> void:
	if _locked or dialogue.active or _fainting or _spawn_grace > 0.0:
		return
	if enemy.info.kind == DnaEnemies.Kind.DAMAGE:
		if _invulnerable > 0.0:
			return
		hit_player(DnaEnemies.COURIER_DAMAGE, enemy.position)
		enemy.retreat_from(player.position, DnaEnemies.COURIER_RETREAT_TIME)
		return
	_start_enemy_battle(enemy)


func _start_enemy_battle(enemy: ZoneEnemy) -> void:
	_locked = true
	var run: ZoneRun = Session.zone_run
	var back: Vector3 = player.position + (player.position - enemy.position).normalized() * 0.6
	run.return_position = back if builder.is_walkable(back) else player.position
	run.has_return_position = true
	hud.toast("%s wants a word..." % enemy.info.display_name, Color("ff8a85"))
	Audio.sfx(&"turn_start")
	await get_tree().create_timer(0.7).timeout
	Session.start_zone_battle(enemy.info.id, enemy.instance_id)


## Damage to the persistent zone life: flash, shake, HUD update, knockback and a short
## invulnerability window. At 0 life the player faints and wakes at the hub.
func hit_player(amount: int, from: Vector3) -> void:
	var run: ZoneRun = Session.zone_run
	run.damage(amount)
	_invulnerable = DnaEnemies.HIT_COOLDOWN
	EventBus.zone_life_changed.emit(run.life, run.max_life())
	Audio.sfx(&"hit_heavy")
	hud.toast(story.text("fx.hit"), Color("ff8a85"))
	_flash.color.a = 0.38
	create_tween().tween_property(_flash, "color:a", 0.0, 0.45)
	_floating_text("-%d" % amount, Color("ff6a60"))
	var away: Vector3 = player.position - from
	away.y = 0.0
	if away.length() < 0.01:
		away = Vector3(0, 0, 1)
	away = away.normalized()
	var target: Vector3 = player.position
	for step: int in range(8):
		var candidate: Vector3 = player.position + away * (DnaEnemies.KNOCKBACK_DISTANCE * float(8 - step) / 8.0)
		if builder.is_walkable(candidate):
			target = candidate
			break
	var shove: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	shove.tween_property(player, "position", target, 0.22)
	if run.is_down():
		_faint("knocked flat by a Speedy Ghost Courier")


func _floating_text(text: String, color: Color) -> void:
	var label: Label3D = Label3D.new()
	label.text = text
	label.font = UIStyle.font_title()
	label.font_size = 72
	label.pixel_size = 0.01
	label.modulate = color
	label.outline_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.position = player.position + Vector3(0, 1.1, 0)
	add_child(label)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y + 0.9, 0.9)
	tween.tween_property(label, "modulate:a", 0.0, 0.9)
	tween.chain().tween_callback(label.queue_free)


func _faint(cause: String) -> void:
	if _fainting:
		return
	_fainting = true
	var fade: ColorRect = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	UIKit.full_rect(fade)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay_layer.add_child(fade)
	var out: Tween = create_tween()
	out.tween_property(fade, "color:a", 1.0, 0.7)
	await out.finished
	_wake_at_hub(cause)
	var back: Tween = create_tween()
	back.tween_property(fade, "color:a", 0.0, 0.7)
	await back.finished
	fade.queue_free()
	_fainting = false
	_show_wake_dialogue(0)


var _last_fee: int = 0


func _wake_at_hub(cause: String) -> void:
	_last_fee = Session.zone_wake_at_hub(cause)
	hud.set_gold(Session.gold)
	player.position = builder.anchor("heal") + Vector3(0.0, 0.0, -0.9)
	_camera.position = player.position + CAMERA_OFFSET
	_invulnerable = 2.0
	_spawn_grace = SPAWN_GRACE
	EventBus.zone_life_changed.emit(Session.zone_run.life, Session.zone_run.max_life())


func _show_wake_dialogue(fee_override: int) -> void:
	var fee: int = _last_fee if fee_override == 0 else fee_override
	dialogue.start("Dolores (over the intercom)", story.get_lines("fx.wake"))
	hud.toast("Paperwork fee: -%d gold (logged)." % fee, Color("ffcf70"))


## After returning from a zone battle: show what happened (rewards / woke at hub).
func _apply_pending_result() -> void:
	var result: Dictionary = Session.pending_zone_result
	Session.pending_zone_result = {}
	if result.is_empty():
		return
	if bool(result.get("woke_at_hub", false)):
		player.position = builder.anchor("heal") + Vector3(0.0, 0.0, -0.9)
		_camera.position = player.position + CAMERA_OFFSET
		_last_fee = int(result.get("fee", 0))
		_show_wake_dialogue(maxi(_last_fee, 0) if _last_fee > 0 else 0)
		if _last_fee == 0:
			hud.toast("Paperwork fee waived (you were broke).", Color("ffcf70"))
		return
	if str(result.get("kind", "")) == "mini":
		if bool(result.get("first_clear", false)):
			hud.toast("Quarterly Reviews cleared! Unique card: %s" % str(result.get("card", "")), UIStyle.GOLD)
		elif bool(result.get("cleared", false)):
			hud.toast("Quarterly Reviews survived again. Life carries over.", UIStyle.GOOD)
		else:
			hud.toast("You leave Sub-Basement 3 with %d life." % Session.zone_run.life, Color("ffcf70"))
		return
	if bool(result.get("won", false)):
		hud.toast("Won! +%d gold, +%d XP. Life stays as it is." % [int(result.get("gold", 0)), int(result.get("xp", 0))], UIStyle.GOLD)


# ---- Overlays and screens --------------------------------------------------------------------


func _open_overlay(screen: Control) -> void:
	_close_overlay()
	_locked = true
	_overlay = screen
	_overlay_layer.add_child(screen)
	Audio.sfx(&"ui_open")


func _close_overlay() -> void:
	if _overlay != null:
		_overlay.queue_free()
		_overlay = null
	_locked = false
	hud.set_gold(Session.gold)
	EventBus.zone_life_changed.emit(Session.zone_run.life, Session.zone_run.max_life())
	Session.save_game()
	Audio.sfx(&"ui_close", -4.0)


func _open_character_screen() -> void:
	if _locked or dialogue.active:
		return
	var screen: CharacterScreen = CharacterScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


func _open_deck_builder() -> void:
	if _locked or dialogue.active:
		return
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


func _open_quest_log() -> void:
	if _locked or dialogue.active:
		return
	var screen: QuestLogScreen = QuestLogScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


func _on_quest_notice(text: String, is_new: bool) -> void:
	hud.queue_toast(text, UIStyle.GOLD if is_new else UIStyle.GOOD)


# ---- Screenshot helpers ----------------------------------------------------------------------


func _teleport(anchor_name: String) -> void:
	var pos: Vector3 = Vector3.ZERO
	if builder.layout.anchors.has(anchor_name):
		pos = builder.anchor(anchor_name)
	elif builder.layout.chests.has(anchor_name):
		pos = builder.layout.chests[anchor_name] as Vector3
	else:
		return
	player.position = pos + Vector3(0.0, 0.0, 1.2)
	if not builder.is_walkable(player.position):
		player.position = pos
	_camera.position = player.position + CAMERA_OFFSET
	_spawn_grace = 12.0


func _screenshot_open(what: String) -> void:
	match what:
		"vendor":
			_open_vendor()
		"quests":
			_open_quest_log()
		"dialogue":
			_talk_quest_npc("dolores", DnaZone.NPC_DOLORES, "Dolores")
		_:
			pass


func screenshot_ready() -> bool:
	return true
