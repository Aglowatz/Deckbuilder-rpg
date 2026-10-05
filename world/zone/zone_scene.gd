class_name ZoneScene
extends Node3D
## The shared zone framework: everything a zone scene does that is not specific to one zone. A zone
## (the D.N.A., the Gainlands, future ones) is a `ZoneDef` (data) + a `ZoneMap` (layout) + a story file,
## plus a thin subclass for its own look and its own interactables. This base provides the hub (heal
## spot, vendor, quest NPCs), the zone life rules and 0-life respawn (`ZoneRun`), roaming enemies,
## hidden chests, the quiz master / minigame / puzzle launchers, the mini dungeon entrance, the
## main-dungeon placeholder, the HUD, overlays, dialogue and the minimap.
##
## Subclasses override the `_zone_*` / `_make_*` hooks below.

const CAMERA_OFFSET: Vector3 = Vector3(0.0, 10.5, 8.4)
const CLICK_PICK_RADIUS: float = 90.0
const HIDDEN_CHEST_RADIUS: float = 1.5
const SPAWN_GRACE: float = 2.0

var def: ZoneDef
var builder: ZoneMap
var player: TownPlayer
var hud: TownHud
var life_bar: ZoneLifeBar
var dialogue: DialogueBox
var minimap: MinimapHud
var spots: Array[ZoneSpot] = []
var enemies: Array[ZoneEnemy] = []
var story: ZoneStoryText
var camera_offset: Vector3 = CAMERA_OFFSET
var _camera: Camera3D
var style_rig: StyleRig
var _overlay_layer: Control
var _overlay: Control
var _flash: ColorRect
var _banner: Label
var _banner_tween: Tween
var _near: ZoneSpot
var _npcs: Dictionary = {}
var _time: float = 0.0
var _locked: bool = false
var _invulnerable: float = 0.0
var _spawn_grace: float = SPAWN_GRACE
var _chest_near: String = ""
var _area_id: String = ""
var _screenshot_args: Dictionary = {}
var _fainting: bool = false
var _last_fee: int = 0
var _station: FastTravelStation
var _arrived_by_rift: bool = false


# ---- Hooks for subclasses --------------------------------------------------------------------


## Which zone this scene is (a `ZoneDefs` id).
func _zone_id() -> String:
	return DnaZone.ID


func _make_map() -> ZoneMap:
	return ZoneMap.new()


## Adds the environment/sun/etc. (called before the map is built).
func _build_environment() -> void:
	pass


## Called after the map, player, NPCs, spots and enemies exist (lights, ambience, extra props).
func _build_zone_extras() -> void:
	pass


## Per-frame zone-specific work (flicker, wind, falling checks).
func _zone_process(_delta: float) -> void:
	pass


## Handles a spot whose kind is "zone" (interactables, travel points...).
func _interact_zone(_spot: ZoneSpot) -> void:
	pass


## The puzzle screen of this zone (must have `closed` and `solved` signals).
func _make_puzzle_screen() -> OverlayScreen:
	return null


## The minigame screen of this zone.
func _make_minigame_screen() -> OverlayScreen:
	return null


## Extra minimap points of interest (travel points, interactables...). Never chests or secrets.
func _extra_pois() -> Array[MapPoi]:
	return []


## Extra grading applied to a roaming enemy model (the zone's look).
func _grade_enemy(_model: Node3D) -> void:
	pass


# ---- Completion state (Part D) ----------------------------------------------------------------


## The zone as it should look right now: oppressed (the ruler's statue and banners, dim tinted light)
## or freed (a toppled statue, bunting, the freed leader at the hub, brighter light).
func _build_completion_state() -> void:
	var freed: bool = Session.is_zone_completed(def.id)
	ZoneCompletionLook.apply(self, def, freed)
	var hub: Vector3 = builder.anchor(def.hub_anchor)
	hub.y = builder.height_at(hub)
	RulerPresence.build(self, builder, def, story, hub, freed)
	if freed:
		_build_freed_npcs(hub)


func _build_freed_npcs(hub: Vector3) -> void:
	for entry: Dictionary in def.freed_npcs:
		var pos: Vector3 = hub + (entry["offset"] as Vector3)
		pos.y = builder.height_at(pos)
		var npc: Node3D = ModelKit.character(str(entry["model"]))
		ModelKit.tint(npc, entry["tint"] as Color)
		ModelKit.place(self, npc, pos, float(entry["yaw"]), TownPlayer.MODEL_SCALE * float(entry.get("scale", 1.0)))
		var animation: AnimationPlayer = ModelKit.animation_player(npc)
		if animation != null and animation.has_animation("Idle"):
			animation.get_animation("Idle").loop_mode = Animation.LOOP_LINEAR
			animation.play("Idle")
		_npcs[str(entry["id"])] = npc
		builder.add_blocker(pos, 0.4)
		_add_spot("freed_%s" % str(entry["id"]), str(entry["name"]), pos, 1.9, "Talk", true, "freed_npc", {"npc": str(entry["id"]), "speaker": str(entry["speaker"])})

# ---- Setup -----------------------------------------------------------------------------------


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


func _ready() -> void:
	def = ZoneDefs.get_def(_zone_id())
	SceneManager.pause_allowed = true
	Audio.play_music(def.music)
	story = ZoneStoryText.for_zone(def.id)
	if not _screenshot_args.is_empty():
		Session.ensure_game()
		if Session.zone_run == null:
			Session.begin_zone_visit(def.id)
		if _screenshot_args.has("damage"):
			Session.zone_run.damage(int(_screenshot_args["damage"]))
		if _screenshot_args.has("freed"):
			Session.complete_zone(def.id)
		if _screenshot_args.has("announce"):
			Session.pending_zone_result = {"kind": "zone_freed", "arena_opened": true, "alchemist_opened": Session.completed_zone_count() >= 2}
	if Session.zone_run == null:
		# Reached some other way (a dev launch): start a fresh visit.
		Session.ensure_game()
		Session.begin_zone_visit(def.id)
	_ensure_input_actions()
	builder = _make_map()
	_build_environment()
	builder.build(self)
	_build_player()
	_build_npcs()
	_build_spots()
	_build_fast_travel()
	_build_enemies()
	_build_zone_extras()
	_build_completion_state()
	_build_camera()
	_build_ui()
	hud.set_objective(story.text("hud.objective"))
	hud.show_zone_effects(ZoneEffects.for_zone(def.id), def.display_name)
	EventBus.zone_life_changed.emit(Session.zone_run.life, Session.zone_run.max_life())
	_apply_pending_result.call_deferred()
	if _arrived_by_rift:
		_show_rift_arrival.call_deferred()
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


func _build_player() -> void:
	var run: ZoneRun = Session.zone_run
	var spawn: Vector3 = builder.anchor("spawn")
	if run.has_return_position:
		spawn = run.return_position
		run.has_return_position = false
	if Session.arrive_at_station:
		Session.arrive_at_station = false
		if builder.has_anchor(FastTravel.ANCHOR):
			var landing: Vector3 = builder.anchor(FastTravel.ANCHOR) + Vector3(0.0, 0.0, 2.4)
			if builder.is_walkable(landing):
				spawn = landing
				_arrived_by_rift = true
	player = TownPlayer.new()
	add_child(player)
	player.setup(builder, "Knight", spawn)
	player.position.y = builder.height_at(spawn)


func _build_npcs() -> void:
	for entry: Dictionary in def.npcs:
		var pos: Vector3 = builder.anchor(str(entry["anchor"]))
		var npc: Node3D = ModelKit.character(str(entry["model"]))
		ModelKit.tint(npc, entry["tint"] as Color)
		pos.y = builder.height_at(pos)
		ModelKit.place(self, npc, pos, float(entry["yaw"]), TownPlayer.MODEL_SCALE * float(entry.get("scale", 1.0)))
		var animation: AnimationPlayer = ModelKit.animation_player(npc)
		var anim_name: String = str(entry.get("anim", "Idle"))
		if animation != null and animation.has_animation(anim_name):
			animation.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
			animation.play(anim_name)
			animation.seek(randf() * 1.5)
		_npcs[str(entry["id"])] = npc
		builder.add_blocker(pos, 0.3)


func _add_spot(id: String, title: String, pos: Vector3, radius: float, prompt: String, npc: bool = false, kind: String = "zone", data: Dictionary = {}) -> ZoneSpot:
	var spot: ZoneSpot = ZoneSpot.new()
	spot.id = id
	spot.title = title
	spot.position = pos
	spot.radius = radius
	spot.prompt = prompt
	spot.is_npc = npc
	spot.kind = kind
	spot.data = data
	var ground: float = builder.height_at(pos)
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
	marker.position = pos + Vector3(0, ground + (1.45 if npc else 1.7), 0)
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
	if bool(data.get("hidden", false)):
		marker.visible = false
		plate.visible = false
	spots.append(spot)
	return spot


func _build_spots() -> void:
	for entry: Dictionary in def.spots:
		var pos: Vector3 = builder.anchor(str(entry["anchor"])) + (entry["offset"] as Vector3)
		_add_spot(str(entry["id"]), str(entry["title"]), pos, float(entry["radius"]), str(entry["prompt"]), entry.has("npc"), str(entry["kind"]), entry)


# ---- The Beefcake Rift Express (brief 10b) -----------------------------------------------------------------------


## The zone's Rift Station beside its hub: a squat-rack frame with a torn-open rift, a Beefcake operator, and a spot to use it.
func _build_fast_travel() -> void:
	if not builder.has_anchor(FastTravel.ANCHOR):
		return
	var travel: StoryText = StoryText.shared()
	var pos: Vector3 = builder.anchor(FastTravel.ANCHOR)
	pos.y = builder.height_at(pos)
	_station = FastTravelStation.new()
	add_child(_station)
	_station.position = pos
	_station.build(travel.get_lines("travel.sign.zone"), Session.fast_travel_unlocked(def.id))
	if _station_layer() != 1:
		_station.set_render_layer(_station_layer())
	builder.add_blocker(pos, 1.3)
	var operator: Node3D = ModelKit.character("Barbarian")
	ModelKit.tint(operator, Color(1.0, 0.8, 0.65))
	var operator_pos: Vector3 = pos + Vector3(-2.4, 0.0, 0.8)
	ModelKit.place(self, operator, operator_pos, 50.0, TownPlayer.MODEL_SCALE * 1.3)
	var animation: AnimationPlayer = ModelKit.animation_player(operator)
	if animation != null and animation.has_animation("Idle"):
		animation.play("Idle")
		animation.seek(randf() * 1.5)
	_npcs["rift_operator"] = operator
	builder.add_blocker(operator_pos, 0.35)
	_add_spot("rift_station", travel.text("travel.title"), pos + Vector3(0.0, 0.0, 1.6), 2.0, travel.text("travel.prompt"), false, "rift_station")


## The visual layer of the station (the Capital puts its underground hideout on layer 2).
func _station_layer() -> int:
	return 1


func _rift_operator() -> String:
	return StoryText.shared().text("travel.operator.%s" % def.id)


## Reaching the zone's town (walking up to its station) unlocks the station for good.
func _update_station() -> void:
	if _station == null or Session.fast_travel_unlocked(def.id) or _locked or dialogue.active or _fainting:
		return
	var offset: Vector3 = player.position - _station.position
	if Vector2(offset.x, offset.z).length() > FastTravel.UNLOCK_RADIUS:
		return
	if Session.unlock_fast_travel(def.id):
		_station.set_active(true)
		Audio.sfx(&"level_up")
		_say(_rift_operator(), StoryText.shared().get_lines("travel.unlock.%s" % def.id))


func _show_rift_arrival() -> void:
	if not dialogue.active:
		_say(_rift_operator(), StoryText.shared().get_lines("travel.arrive.%s" % def.id))


func _use_rift_station() -> void:
	var travel: StoryText = StoryText.shared()
	_face_npc("rift_operator")
	if Session.unlock_fast_travel(def.id):
		_station.set_active(true)
	var met: StringName = StringName("rift_met_%s" % def.id)
	var lines: Array[String] = travel.get_lines("travel.return.zone")
	if not Session.flag(met):
		Session.set_flag(met)
		lines = travel.get_lines("travel.intro.final" if def.id == CapitalZone.ID else "travel.intro.zone")
	_say(_rift_operator(), lines, _open_rift_screen)


func _open_rift_screen() -> void:
	var screen: FastTravelScreen = FastTravelScreen.new()
	screen.here = def.id
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)
	screen.destination_chosen.connect(func(station_id: String) -> void:
		_close_overlay()
		_locked = true
		RiftTrip.run(self, _overlay_layer, dialogue, _station, _rift_operator(), station_id))


func _build_enemies() -> void:
	var run: ZoneRun = Session.zone_run
	var index: int = 0
	for spawn: Dictionary in builder.enemy_spawns():
		var instance_id: String = str(spawn.get("id", "%s_%d" % [str(spawn["type"]), index]))
		index += 1
		if run.is_defeated(instance_id):
			continue
		var enemy: ZoneEnemy = ZoneEnemy.new()
		add_child(enemy)
		enemy.setup(ZoneEnemies.info(def.id, str(spawn["type"])), instance_id, spawn["home"] as Vector3, float(spawn["patrol"]), builder, player, _grade_enemy)
		enemy.touched.connect(_on_enemy_touched)
		enemies.append(enemy)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.fov = 38.0
	add_child(_camera)
	_camera.current = true
	_camera.position = player.position + camera_offset
	_camera.look_at(player.position + Vector3(0, 0.4, 0), Vector3.UP)
	style_rig = StyleRig.install(self, _style_preset(), _camera, player)


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
	_flash.name = "Flash"
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
	minimap = MinimapHud.new()
	host.add_child(minimap)
	minimap.setup(def.id, builder, player, _collect_pois)
	minimap.full_map_requested.connect(_open_full_map)
	var overlay_canvas: CanvasLayer = CanvasLayer.new()
	overlay_canvas.layer = 8
	add_child(overlay_canvas)
	_overlay_layer = UIKit.layer_host(overlay_canvas)


# ---- Frame update ----------------------------------------------------------------------------


func _process(delta: float) -> void:
	_time += delta
	_invulnerable = maxf(0.0, _invulnerable - delta)
	_spawn_grace = maxf(0.0, _spawn_grace - delta)
	_update_camera(delta)
	builder.update_visibility(player.position)
	_zone_process(delta)
	var world_active: bool = _world_active()
	if world_active and not Session.pending_level_ups.is_empty():
		var gained: Array[LevelData] = Session.pending_level_ups.duplicate()
		Session.pending_level_ups.clear()
		var screen: LevelUpScreen = LevelUpScreen.new()
		screen.setup(gained)
		_open_overlay(screen)
		screen.finished.connect(_close_overlay)
		world_active = false
	player.input_enabled = world_active and not player.airborne
	player.model.visible = _invulnerable <= 0.0 or int(_time * 14.0) % 2 == 0
	for enemy: ZoneEnemy in enemies:
		enemy.active = world_active
		if _spawn_grace > 0.0 and enemy.cooldown < _spawn_grace:
			enemy.cooldown = _spawn_grace
	for spot: ZoneSpot in spots:
		if bool(spot.data.get("hidden", false)):
			continue
		var base_y: float = builder.height_at(spot.position) + (1.45 if spot.is_npc else 1.7)
		spot.marker.position.y = base_y + sin(_time * 2.4 + spot.position.x) * 0.07
		spot.marker.rotation_degrees.y += 60.0 * delta
		var distance: float = Vector2(player.position.x - spot.position.x, player.position.z - spot.position.z).length()
		spot.plate.modulate.a = clampf(1.0 - (distance - 2.4) / 1.6, 0.0, 1.0)
		spot.plate.outline_modulate.a = spot.plate.modulate.a
		spot.plate.visible = spot.plate.modulate.a > 0.02
	_update_nearest()
	_update_chest_prompt()
	_update_area_banner()
	_update_station()


func _world_active() -> bool:
	return not _locked and not dialogue.active and not _fainting


func _update_camera(delta: float) -> void:
	var target: Vector3 = player.position + camera_offset
	_camera.position = _camera.position.lerp(target, 1.0 - exp(-5.0 * delta))
	_camera.rotation_degrees = Vector3(-atan2(camera_offset.y, camera_offset.z) * 180.0 / PI, 0.0, 0.0)


func _update_nearest() -> void:
	if _locked or dialogue.active or _fainting or player.airborne:
		hud.hide_prompt()
		_near = null
		return
	var best: ZoneSpot = null
	var best_distance: float = 1e9
	for spot: ZoneSpot in spots:
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


func _prompt_for(spot: ZoneSpot) -> String:
	return spot.prompt


## Hidden stashes: no marker, no plate - the prompt is the only tell, and only up close.
func _update_chest_prompt() -> void:
	if _locked or dialogue.active or _fainting or player.airborne:
		_chest_near = ""
		return
	var found: String = ""
	var chests: Dictionary = builder.chest_positions()
	for id: String in chests.keys():
		if Session.found_secret(_chest_secret(id)):
			continue
		var pos: Vector3 = chests[id] as Vector3
		if Vector2(player.position.x - pos.x, player.position.z - pos.z).length() <= HIDDEN_CHEST_RADIUS:
			found = id
			break
	if found != _chest_near:
		_chest_near = found
		if not found.is_empty():
			Audio.sfx(&"ui_tick", -10.0)
	if not found.is_empty():
		hud.show_prompt("[E]  Open the chest")


## True when the hidden chest in reach is closer to the player than `spot` (so E opens the chest).
func _chest_closer_than(spot: ZoneSpot) -> bool:
	var chest: Vector3 = builder.chest_positions().get(_chest_near, Vector3.ZERO) as Vector3
	var to_chest: float = Vector2(player.position.x - chest.x, player.position.z - chest.z).length()
	var to_spot: float = Vector2(player.position.x - spot.position.x, player.position.z - spot.position.z).length()
	return to_chest <= to_spot


func _chest_secret(id: String) -> String:
	return "%s%s" % [def.secret_prefix, id]


func _update_area_banner() -> void:
	var area: Array[String] = builder.area_at(player.position)
	if area.is_empty() or area[0] == _area_id:
		return
	_area_id = area[0]
	show_banner(area[1])


func show_banner(text: String) -> void:
	_banner.text = text
	if _banner_tween != null and _banner_tween.is_valid():
		_banner_tween.kill()
	_banner.modulate.a = 0.0
	_banner_tween = create_tween()
	_banner_tween.tween_property(_banner, "modulate:a", 1.0, 0.4)
	_banner_tween.tween_interval(1.6)
	_banner_tween.tween_property(_banner, "modulate:a", 0.0, 0.8)


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
		if code == KEY_M:
			get_viewport().set_input_as_handled()
			_open_full_map()
			return
	if _locked or dialogue.active:
		return
	var interact: bool = event.is_action_pressed(&"interact") or (event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_SPACE)
	if interact:
		if not _chest_near.is_empty() and (_near == null or _chest_closer_than(_near)):
			get_viewport().set_input_as_handled()
			_open_chest(_chest_near)
			return
		if _near != null:
			get_viewport().set_input_as_handled()
			_interact(_near)
			return
	if event is InputEventMouseButton and _near != null:
		var click: InputEventMouseButton = event as InputEventMouseButton
		if click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
			if _camera.unproject_position(_near.marker.position).distance_to(click.position) <= CLICK_PICK_RADIUS:
				get_viewport().set_input_as_handled()
				_interact(_near)


# ---- Interactions ----------------------------------------------------------------------------


func _interact(spot: ZoneSpot) -> void:
	Audio.sfx(&"ui_select")
	match spot.kind:
		"quest_npc":
			_talk_quest_npc(str(spot.data["npc"]), str(spot.data["npc_name"]), str(spot.data["speaker"]))
		"vendor_npc":
			_talk_quest_npc(str(spot.data["npc"]), str(spot.data["npc_name"]), str(spot.data["speaker"]), _open_vendor)
		"heal":
			_use_heal_spot(spot)
		"rift_station":
			_use_rift_station()
		"exit":
			_ask_exit()
		"main_dungeon":
			_use_main_dungeon(spot)
		"mini_dungeon":
			_ask_mini_dungeon(spot)
		"puzzle":
			_open_puzzle(spot)
		"freed_npc":
			_face_npc(str(spot.data["npc"]))
			_say(str(spot.data["speaker"]), story.get_lines("freed_npc.%s" % str(spot.data["npc"])))
		"quiz":
			_face_npc(str(spot.data["npc"]))
			_say(str(spot.data["speaker"]), story.get_lines("npc.quiz.return" if Session.flag(def.flag_met("quiz")) else "npc.quiz.intro"), _open_quiz)
			Session.set_flag(def.flag_met("quiz"))
		"minigame":
			_face_npc(str(spot.data["npc"]))
			_say(str(spot.data["speaker"]), _greeting(str(spot.data["npc"])), _open_minigame)
		_:
			_interact_zone(spot)


func _open_puzzle(spot: ZoneSpot) -> void:
	player.face(spot.position)
	var screen: OverlayScreen = _make_puzzle_screen()
	if screen == null:
		return
	_open_overlay(screen)
	screen.connect("closed", _close_overlay)
	screen.connect("solved", func() -> void:
		Session.set_flag(def.flag_puzzle_solved)
		var piece: EquipmentData = Session.content.equipment_piece(def.puzzle_equipment_id)
		if piece != null and Session.grant_equipment(piece):
			hud.toast("Puzzle solved! %s joins your gear." % piece.source_name, UIStyle.GOLD)
		Session.refresh_quests()
		Session.save_game())


func _open_quiz() -> void:
	var screen: QuizScreen = QuizScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


func _open_minigame() -> void:
	var screen: OverlayScreen = _make_minigame_screen()
	if screen == null:
		return
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


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
	var flag_name: StringName = def.flag_met(npc_id)
	if not Session.flag(flag_name):
		Session.set_flag(flag_name)
		return story.get_lines("npc.%s.intro" % npc_id)
	return story.get_lines("npc.%s.return" % npc_id)


func _use_heal_spot(spot: ZoneSpot) -> void:
	player.face(spot.position)
	var healed: int = Session.zone_run.fully_heal()
	EventBus.zone_life_changed.emit(Session.zone_run.life, Session.zone_run.max_life())
	Audio.sfx(&"heal")
	hud.toast(story.text("fx.heal_couch") if healed > 0 else story.text("fx.heal_already"), UIStyle.GOOD)


func _ask_mini_dungeon(spot: ZoneSpot) -> void:
	player.face(spot.position)
	_locked = true
	var cleared: bool = Session.flag(def.flag_mini_cleared)
	var body: String = story.text("ui.mini.body_cleared" if cleared else "ui.mini.body")
	var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, def.mini.dungeon_name, body, story.text("ui.mini.button"), "Not yet")
	dialog.confirmed.connect(func() -> void:
		var run: ZoneRun = Session.zone_run
		run.return_position = spot.position + Vector3(0, 0, 1.0)
		run.has_return_position = true
		Audio.sfx(&"door")
		Session.enter_mini_dungeon())
	dialog.cancelled.connect(func() -> void: _locked = false)


## The zone's final dungeon (Part E): its entrance shows what waits inside, then enters it (life carries in
## from the zone, like the mini dungeon).
func _use_main_dungeon(spot: ZoneSpot) -> void:
	player.face(spot.position)
	hud.toast(story.text("fx.main_dungeon"), Color("ffcf70"))
	if not MainDungeons.has_def(def.id):
		return
	_locked = true
	var cleared: bool = Session.is_zone_completed(def.id)
	var body: String = story.text("ui.main.body_cleared" if cleared else "ui.main.body")
	var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, story.text("ui.main.title"), body, story.text("ui.main.button"), "Not yet")
	dialog.confirmed.connect(func() -> void:
		var run: ZoneRun = Session.zone_run
		run.return_position = spot.position + Vector3(0, 0, 1.4)
		run.has_return_position = true
		Audio.sfx(&"door")
		Session.enter_main_dungeon())
	dialog.cancelled.connect(func() -> void: _locked = false)


func _ask_exit() -> void:
	_locked = true
	var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, story.text("ui.exit.title"), story.text("ui.exit.body"), "Leave", "Stay")
	dialog.confirmed.connect(func() -> void:
		Audio.sfx(&"door")
		Session.leave_zone())
	dialog.cancelled.connect(func() -> void: _locked = false)


func _open_vendor() -> void:
	var data: VendorData = VendorData.new()
	data.vendor_name = def.vendor_name
	for id: String in def.vendor_ids:
		data.add(id)
	var screen: VendorScreen = VendorScreen.new()
	screen.stock = data
	screen.screen_title = def.vendor_title
	if def.id == CapitalZone.ID:
		screen.pack_vendor_id = PackData.VENDOR_BLACK_MARKET
		screen.pack_story_prefix = "pack.black_market"
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


func _open_chest(id: String) -> void:
	var pos: Vector3 = builder.chest_positions().get(id, Vector3.ZERO) as Vector3
	player.face(pos)
	if Session.found_secret(_chest_secret(id)):
		return
	Session.discover_secret(_chest_secret(id))
	var reward: Dictionary = def.chest_rewards.get(id, {}) as Dictionary
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
	Session.bump_counter(def.counter_chests)
	_animate_chest(id)
	hud.set_gold(Session.gold)
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
	if _locked or dialogue.active or _fainting or _spawn_grace > 0.0 or player.airborne:
		return
	if enemy.info.kind == ZoneEnemyInfo.Kind.DAMAGE:
		if _invulnerable > 0.0:
			return
		hit_player(enemy.info.damage, enemy.position, "knocked flat by a %s" % enemy.info.display_name)
		enemy.retreat_from(player.position, ZoneEnemies.RETREAT_TIME)
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
func hit_player(amount: int, from: Vector3, cause: String = "knocked flat") -> void:
	var run: ZoneRun = Session.zone_run
	run.damage(amount)
	_invulnerable = ZoneEnemies.HIT_COOLDOWN
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
		var candidate: Vector3 = player.position + away * (ZoneEnemies.KNOCKBACK_DISTANCE * float(8 - step) / 8.0)
		if builder.is_walkable(candidate):
			target = candidate
			break
	var shove: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	shove.tween_property(player, "position", target, 0.22)
	if run.is_down():
		_faint(cause)


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


## Where the player stands after waking at the hub.
func _hub_spawn() -> Vector3:
	var heal_pos: Vector3 = builder.anchor("heal") + Vector3(0.0, 0.0, -0.9)
	heal_pos.y = builder.height_at(heal_pos)
	return heal_pos


func _wake_at_hub(cause: String) -> void:
	_last_fee = Session.zone_wake_at_hub(cause)
	hud.set_gold(Session.gold)
	player.position = _hub_spawn()
	_camera.position = player.position + camera_offset
	_invulnerable = 2.0
	_spawn_grace = SPAWN_GRACE
	EventBus.zone_life_changed.emit(Session.zone_run.life, Session.zone_run.max_life())


func _show_wake_dialogue(fee_override: int) -> void:
	var fee: int = _last_fee if fee_override == 0 else fee_override
	dialogue.start(def.wake_speaker, story.get_lines("fx.wake"))
	hud.toast("%s: -%d gold (logged)." % [def.fee_label, fee], Color("ffcf70"))


## After returning from a zone battle: show what happened (rewards / woke at hub).
func _apply_pending_result() -> void:
	var result: Dictionary = Session.pending_zone_result
	Session.pending_zone_result = {}
	if result.is_empty():
		return
	if bool(result.get("woke_at_hub", false)):
		player.position = _hub_spawn()
		_camera.position = player.position + camera_offset
		_last_fee = int(result.get("fee", 0))
		_show_wake_dialogue(maxi(_last_fee, 0) if _last_fee > 0 else 0)
		if _last_fee == 0:
			hud.toast("%s waived (you were broke)." % def.fee_label, Color("ffcf70"))
		return
	if str(result.get("kind", "")) == "zone_freed":
		_show_zone_freed(result)
		return
	if str(result.get("kind", "")) == "main":
		if bool(result.get("cleared", false)):
			var pack_lines: Array[String] = PackRewards.dungeon_lines(result, StoryText.shared())
			hud.toast("%s survived again. %s" % [ZoneDefs.get_def(def.id).full_name, pack_lines[0] if not pack_lines.is_empty() else "Life carries over."], UIStyle.GOOD)
		else:
			hud.toast("You leave the dungeon with %d life." % Session.zone_run.life, Color("ffcf70"))
		return
	if str(result.get("kind", "")) == "mini":
		if bool(result.get("first_clear", false)):
			hud.toast("%s cleared! Unique card: %s" % [def.mini.dungeon_name, str(result.get("card", ""))], UIStyle.GOLD)
		elif bool(result.get("cleared", false)):
			hud.toast("%s survived again. Life carries over." % def.mini.dungeon_name, UIStyle.GOOD)
		else:
			hud.toast("You leave %s with %d life." % [def.mini.dungeon_name, Session.zone_run.life], Color("ffcf70"))
		return
	if bool(result.get("won", false)):
		hud.toast("Won! +%d gold, +%d XP. Life stays as it is." % [int(result.get("gold", 0)), int(result.get("xp", 0))], UIStyle.GOLD)


## The announcement after the zone's final boss falls: the zone is free; what just unlocked.
func _show_zone_freed(result: Dictionary) -> void:
	var story_text: StoryText = StoryText.shared()
	var lines: Array[String] = []
	lines.append(ZoneCompletion.progress_text(Session.flags))
	if bool(result.get("arena_opened", false)):
		Session.set_flag(&"arena_announced")
	if bool(result.get("alchemist_opened", false)):
		Session.set_flag(&"alchemist_announced")
	if bool(result.get("arena_opened", false)):
		lines.append(story_text.text("town.arena.unlock_line"))
	if bool(result.get("alchemist_opened", false)):
		lines.append(story_text.text("town.alchemist.unlock_line"))
	lines.append_array(PackRewards.dungeon_lines(result, story_text))
	var screen: AnnouncementScreen = AnnouncementScreen.make(story_text.text("zone.complete.%s.title" % def.id), story_text.text("zone.complete.%s.body" % def.id), lines)
	_locked = true
	_overlay_layer.add_child(screen)
	screen.finished.connect(func() -> void: _locked = false)

# ---- Minimap ---------------------------------------------------------------------------------


## Every point of interest the map may show: the spots the def lists as POIs plus the zone's extras.
## Hidden chests are never here (`MapPoi.Kind` has no chest kind and chests are not spots).
func _collect_pois() -> Array[MapPoi]:
	var result: Array[MapPoi] = []
	for spot: ZoneSpot in spots:
		if not def.poi_kinds.has(spot.id):
			continue
		var poi_kind: MapPoi.Kind = def.poi_kinds[spot.id] as MapPoi.Kind
		var marker: bool = false
		if poi_kind == MapPoi.Kind.QUEST_GIVER:
			var npc_name: String = str(spot.data.get("npc_name", ""))
			marker = not Session.quests_ready_for(npc_name).is_empty() or not Session.quests_offered_by(npc_name).is_empty()
		var label: String = spot.title
		result.append(MapPoi.make(poi_kind, spot.position, label, marker))
	for spot: ZoneSpot in spots:
		if spot.id == "rift_station":
			result.append(MapPoi.make(MapPoi.Kind.TRAVEL_PORTAL, spot.position, spot.title))
	result.append_array(_extra_pois())
	return result


func _open_full_map() -> void:
	if _locked or dialogue.active:
		return
	var screen: FullMapScreen = FullMapScreen.new()
	screen.setup(def.id, builder, player, _collect_pois(), def.display_name)
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


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
	if anchor_name == "courier":
		for enemy: ZoneEnemy in enemies:
			if enemy.info.kind == ZoneEnemyInfo.Kind.DAMAGE:
				player.position = enemy.position + Vector3(3.0, 0, 0.0)
				_camera.position = player.position + camera_offset
				_spawn_grace = 0.3
				for other: ZoneEnemy in enemies.duplicate():
					if other != enemy:
						enemies.erase(other)
						other.queue_free()
				return
	if anchor_name.begins_with("enemy:"):
		for enemy: ZoneEnemy in enemies:
			if enemy.info.id == anchor_name.trim_prefix("enemy:"):
				player.position = enemy.position + Vector3(2.6, 0, 1.2)
				player.position.y = builder.height_at(player.position)
				_camera.position = player.position + camera_offset
				_spawn_grace = 30.0
				return
		return
	if anchor_name == "rift_station_view" and builder.has_anchor(FastTravel.ANCHOR):
		anchor_name = FastTravel.ANCHOR
		pos = builder.anchor(anchor_name) + Vector3(0.0, 0.0, 1.0)
		player.position = pos
		player.position.y = builder.height_at(pos)
		_camera.position = player.position + camera_offset
		_spawn_grace = 12.0
		return
	if builder.has_anchor(anchor_name):
		pos = builder.anchor(anchor_name)
	elif builder.chest_positions().has(anchor_name):
		pos = builder.chest_positions()[anchor_name] as Vector3
	else:
		return
	player.position = pos + Vector3(0.0, 0.0, 1.2)
	if not builder.is_walkable(player.position):
		player.position = pos
	player.position.y = builder.height_at(player.position)
	_camera.position = player.position + camera_offset
	_spawn_grace = 12.0


func _screenshot_open(what: String) -> void:
	match what:
		"vendor":
			_open_vendor()
		"quests":
			_open_quest_log()
		"puzzle":
			for spot: ZoneSpot in spots:
				if spot.kind == "puzzle":
					_open_puzzle(spot)
		"quiz":
			_open_quiz()
		"matching", "minigame":
			_open_minigame()
		"map":
			_open_full_map()
		"dialogue":
			for spot: ZoneSpot in spots:
				if spot.kind == "quest_npc":
					_talk_quest_npc(str(spot.data["npc"]), str(spot.data["npc_name"]), str(spot.data["speaker"]))
					return
		_:
			pass


func screenshot_ready() -> bool:
	return true


## The lighting/environment preset this zone uses (docs/art/style_guide.md, section 11). The Capital overrides it with its state.
func _style_preset() -> StringName:
	return StylePresets.for_zone(def.id)
