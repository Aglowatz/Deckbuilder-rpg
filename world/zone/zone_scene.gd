class_name ZoneScene
extends Node3D
## The shared zone framework: everything a zone scene does that is not specific to one zone. A zone
## (the D.N.A., the Gainlands, future ones) is a `ZoneDef` (data) + a `ZoneMap` (layout) + a story file,
## plus a thin subclass for its own look and its own interactables. This base provides the hub (heal
## spot, vendor, quest NPCs), the zone HP rules and 0-HP respawn (`ZoneRun`), roaming enemies,
## hidden chests, the quiz master / minigame / puzzle launchers, the mini dungeon entrance, the
## main-dungeon placeholder, the HUD, overlays, dialogue and the minimap.
##
## Subclasses override the `_zone_*` / `_make_*` hooks below.

## The approved world-look framing (WorldLookRig.base_offset() for the F5 values: pitch 20, distance 6.2); scenes read the live value.
const CAMERA_OFFSET: Vector3 = Vector3(0.0, 2.12, 5.83)
const CLICK_PICK_RADIUS: float = 90.0
const HIDDEN_CHEST_RADIUS: float = 1.5
const SPAWN_GRACE: float = 2.0
## Meshes farther than this from the (low) camera are not drawn: the low camera sees the whole map to the horizon, which the old high camera never did (docs/art/world_rollout.md).
const CULL_DISTANCE: float = 48.0

var def: ZoneDef
var builder: ZoneMap
var player: TownPlayer
var hud: TownHud
var hp_bar: ZoneHpBar
var dialogue: DialogueBox
var minimap: MinimapHud
## Overnight Oct 16: "!" / "?" over quest givers and the tracked quest's objective marker (with its edge-of-screen pointer).
var quest_markers: QuestMarkerLayer
var spots: Array[ZoneSpot] = []
var enemies: Array[ZoneEnemy] = []
var story: ZoneStoryText
var camera_offset: Vector3 = WorldLookRig.base_offset()
## The world look (post pass, sky, scenery, foliage); null with NO_STYLE.
var look_rig: WorldLookRig
var _camera: Camera3D
var style_rig: StyleRig
var _overlay_layer: Control
var _overlay: Control
var _flash: ColorRect
var _banner: Label
var _banner_tween: Tween
var _near: ZoneSpot
var _npcs: Dictionary = {}
var _strollers: Array[SpriteStroller] = []
var _talking_id: String = ""
## Life for the painted NPCs (a gentle turn toward the hero when close).
var npc_hp: NpcHp
var _time: float = 0.0
## Overnight Oct 20: every change of the hero lock goes to the game log (GameLog), so a tester's log shows a lock that never let go.
var _locked: bool = false:
	set(value):
		if value != _locked:
			GameLog.info("lock", "%s: hero %s" % [name, "locked" if value else "free"])
		_locked = value
var _invulnerable: float = 0.0
## Oct 21: a short pause before a story scene that waits for the hero (the lieutenant has fled, the regulation lawn...), so it never
## starts on the first frame of an arrival.
var _scene_cooldown: float = 1.0
var _spawn_grace: float = SPAWN_GRACE
var _chest_near: String = ""
var _area_id: String = ""
var _screenshot_args: Dictionary = {}
var _fainting: bool = false
var _last_fee: int = 0
var _station: FastTravelStation
var _arrived_by_rift: bool = false
## Brief 16: this zone's giant chest (Shiro Swindle's trap), null in a zone without one.
var giant_chest_node: Node3D
## Brief 16, Group G: this zone's hidden vault lever (null in a zone without one) and the camera shake the lever and other big events use.
var vault_lever_node: Node3D
var _cam_shake_power: float = 0.0
var _cam_shake_time: float = 0.0


# ---- Hooks for subclasses --------------------------------------------------------------------


## Which zone this scene is (a `ZoneDefs` id).
func _zone_id() -> String:
	return DnaZone.ID


func _make_map() -> ZoneMap:
	return ZoneMap.new()


## Adds the environment/sun/etc. (called before the map is built).
func _build_environment() -> void:
	pass


## G-03: hub signs carry a pictogram only. Each sign in the builder's layout (`layout.signs`: key + pos) gets a hidden spot; using it reads the old words.
func _build_sign_spots() -> void:
	var layout: Object = builder.get("layout") as Object
	if layout == null or not layout.get("signs") is Array:
		return
	var index: int = 0
	for sign: Object in layout.get("signs") as Array:
		var pos: Vector3 = sign.get("pos") as Vector3
		_add_spot("sign_%d" % index, "Sign", Vector3(pos.x, 0.0, pos.z), 1.4, "Read the sign", false, "sign", {"hidden": true, "key": str(sign.get("key"))})
		index += 1


## Called after the map, player, NPCs, spots and enemies exist (lights, ambience, extra props).
func _build_zone_extras() -> void:
	pass


var _soundscape_timer: float = 0.0


## Sound pass, Part C: the Verdant Dump grows eerier toward the Rotheart (a low drone and a heartbeat-like pulse rise with the corruption parameter).
func _update_soundscape(delta: float) -> void:
	_soundscape_timer -= delta
	if _soundscape_timer > 0.0 or def == null or def.id != "refusemancer" or player == null:
		return
	_soundscape_timer = 0.5
	Audio.ambience.set_param("corruption", ZoneSoundscape.heap_corruption(player.position))


## Per-frame zone-specific work (flicker, wind, falling checks).
func _zone_process(_delta: float) -> void:
	pass


## Handles a spot whose kind is "zone" (interactables, travel points...).
func _interact_zone(_spot: ZoneSpot) -> void:
	pass


## A shrine (SR-7): one offering per campaign, a card (or a little gold) from the zone's own chest table (`ZoneShrine`); afterwards it only speaks
## (story key "shrine.used"). The same flow as a hidden chest: the reward popup, then the hero is given back.
func _use_shrine(spot: ZoneSpot) -> void:
	player.face(spot.position)
	var used: StringName = ZoneShrine.flag(def.id, spot.id)
	if Session.flag(used):
		_say("", story.get_lines("shrine.used"))
		return
	Session.set_flag(used)
	var reward: Dictionary = ZoneShrine.reward(def.chest_rewards, "%s:%s" % [def.id, spot.id])
	var summary: RewardSummary = Session.grant_chest_reward(reward, spot.title)
	hud.set_gold(Session.gold)
	Session.save_game()
	_locked = true
	player.input_enabled = false
	Audio.sfx(&"chest_open")
	await get_tree().create_timer(0.5).timeout
	var popup: RewardPopup = RewardPopup.make(summary)
	_open_overlay(popup)
	popup.finished.connect(_close_overlay)


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
	# The plaque has no lettering any more (G-03): using the statue reads it out.
	var plinth: Vector3 = RulerPresence.statue_position(def, hub) + Vector3(0.0, 0.0, 1.2)
	_add_spot("ruler_statue", "Statue", plinth, 1.8, "Read the plaque", false, "plaque", {"hidden": true, "key": "ruler.statue.freed" if freed else "ruler.statue"})
	if freed:
		_build_freed_npcs(hub)
	_build_hob()


# ---- Old Hob, just measuring (Oct 21) ---------------------------------------------------------------------------------------------

## Old Hob (secretly Death) turns up near every zone's hub with his shovel and his appointment book (OldHob.cameo_scene).
func _build_hob() -> void:
	if OldHob.cameo_scene(def.id, Session.flags).is_empty() or not SpriteLibrary.has_character(OldHob.SPRITE):
		return
	var pos: Vector3 = _hob_position()
	if pos == Vector3.INF:
		return
	pos.y = builder.height_at(pos)
	var entry: Dictionary = {"id": "hob", "npc_id": OldHob.NPC_ID, "model": "Rogue", "anchor": "", "yaw": 200.0, "tint": Color.WHITE}
	_npcs["hob"] = _make_npc(entry, pos, "Idle")
	builder.add_blocker(pos, 0.4)
	_add_spot("hob", "Old Hob", pos, 1.7, "Talk", true, "hob", {"npc": "hob", "npc_id": OldHob.NPC_ID, "speaker": "Old Hob"})


## Where Hob stands: the first open ground a few steps off the hub (Vector3.INF when there is none). The Capital puts him in Grave Row.
func _hob_position() -> Vector3:
	var hub: Vector3 = builder.anchor(def.hub_anchor)
	for offset: Vector3 in [Vector3(4.5, 0, 3.5), Vector3(-4.5, 0, 3.5), Vector3(4.5, 0, -3.5), Vector3(-4.5, 0, -3.5), Vector3(6.0, 0, 0), Vector3(-6.0, 0, 0), Vector3(0, 0, 6.0)]:
		var at: Vector3 = hub + offset
		if builder.is_walkable(at, 0.6) and _clear_of_spots(at, 2.2):
			return at
	return Vector3.INF


func _clear_of_spots(at: Vector3, distance: float) -> bool:
	for spot: ZoneSpot in spots:
		if Vector2(spot.position.x - at.x, spot.position.z - at.z).length() < distance:
			return false
	return true


func _talk_hob() -> void:
	_face_npc("hob")
	StoryScenePlayer.play(dialogue, OldHob.cameo_scene(def.id, Session.flags))


func _build_freed_npcs(hub: Vector3) -> void:
	for entry: Dictionary in def.freed_npcs:
		var pos: Vector3 = hub + (entry["offset"] as Vector3)
		pos.y = builder.height_at(pos)
		var npc: Node3D = _make_npc(entry, pos, "Idle")
		_npcs[str(entry["id"])] = npc
		builder.add_blocker(pos, 0.4)
		# Phase 2 cycle 16: the freed leaders say a passing line too, like everyone else
		if npc_barks != null and not str(entry.get("npc_id", "")).is_empty():
			npc_barks.register(npc, str(entry["npc_id"]))
		_add_spot("freed_%s" % str(entry["id"]), str(entry["name"]), pos, 1.9, "Talk", true, "freed_npc", {"npc": str(entry["id"]), "speaker": str(entry["speaker"]), "npc_id": str(entry.get("npc_id", ""))})

# ---- Setup -----------------------------------------------------------------------------------


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


## The blocking circles (x, z, radius) and anchors the top-down plan view draws (`--top --plan`); a zone with them overrides these.
func _plan_obstacles() -> Array[Vector3]:
	return [] as Array[Vector3]


func _plan_anchors() -> Dictionary:
	return {}


func _ready() -> void:
	def = ZoneDefs.get_def(_zone_id())
	SceneManager.pause_allowed = true
	# Overnight Oct 18, Phase 2 cycle 29: the zone shop's stage art is warmed like Crosspath's (its first open loaded it on the spot, ~45 ms). The
	# Capital's shop is the black market and is left as it is.
	var stages: Array[String] = []
	if not def.vendor_screen_id.is_empty() and def.id != CapitalZone.ID:
		stages.append(def.vendor_screen_id)
	add_child(UiArtWarmup.make(stages))
	ZoneStyles.use_preset(StylePresets.for_zone(def.id))
	if def.id != CapitalZone.ID:
		# A Path's zone: exploration, or the freed arrangement once its own completion flag is set (the Capital picks by district, `CapitalScene`).
		Audio.play_music(MusicDirector.zone_area(def.id, Session.flags))
		Audio.set_ambience(ZoneSoundscape.zone_profile(def.id))
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
	# Phase 2 (stability): a mark per build step - the game log shows where a zone load spends its time, and each mark lets the window
	# answer Windows during the long build frame (KeepAlive).
	builder = _make_map()
	LoadTiming.mark("zone: map")
	_build_environment()
	LoadTiming.mark("zone: environment")
	builder.build(self)
	LoadTiming.mark("zone: builder")
	_build_player()
	_build_npcs()
	_build_spots()
	_build_giant_chest()
	_build_vault_lever()
	_build_fast_travel()
	ChestKit.apply_saved(builder.chest_nodes, _chest_secret)
	LoadTiming.mark("zone: player, NPCs, spots")
	_build_enemies()
	LoadTiming.mark("zone: enemies")
	_build_sign_spots()
	_build_zone_extras()
	LoadTiming.mark("zone: extras")
	ZoneSoundscape.add_emitters(self, def.id)
	_build_completion_state()
	_build_camera()
	_build_ui()
	LoadTiming.mark("zone: camera, UI")
	hud.set_objective(story.text("hud.objective"))
	hud.show_zone_effects(ZoneEffects.for_zone(def.id), def.display_name)
	if _screenshot_args.is_empty():
		_warn_rival_path()
	EventBus.zone_hp_changed.emit(Session.zone_run.hp, Session.zone_run.max_hp())
	_apply_pending_result.call_deferred()
	if _arrived_by_rift:
		_show_rift_arrival.call_deferred()
	if _screenshot_args.has("at"):
		_teleport(str(_screenshot_args["at"]))
	_apply_colour_keep()
	if _screenshot_args.has("cam"):
		var cam: PackedStringArray = str(_screenshot_args["cam"]).split(",")
		camera_offset = Vector3(float(cam[0]), float(cam[1]), float(cam[2]))
	if _screenshot_args.has("pos"):
		var pos: PackedStringArray = str(_screenshot_args["pos"]).split(",")
		player.position = Vector3(float(pos[0]), 0.0, float(pos[1]))
		_camera.position = player.position + CameraRig.shape(camera_offset)
	if str(_screenshot_args.get("nohud", "false")) == "true":
		for child: Node in get_children():
			if child is CanvasLayer:
				(child as CanvasLayer).visible = false
	if _screenshot_args.has("open"):
		_screenshot_open.call_deferred(str(_screenshot_args["open"]))
	if _screenshot_args.has("ninja") and giant_chest_node != null:
		GiantChestEvent.screenshot_run(self, def.id, giant_chest_node, _screenshot_args)
	if _screenshot_args.has("lever") and vault_lever_node != null:
		VaultLeverEvent.screenshot_run(self, def.id, vault_lever_node)
	# Capital pass: the top-down audit view (`--top=x,z,size [--plan=true]`, PlanView) and the sway log (`--windlog=true`), as in town
	if _screenshot_args.has("top"):
		if _screenshot_args.has("nofog"):
			for node: Node in find_children("*", "WorldEnvironment", true, false):
				var env: Environment = (node as WorldEnvironment).environment
				if env != null:
					env.fog_enabled = false
					env.volumetric_fog_enabled = false
					env.glow_enabled = false
		PlanView.install(self, builder, _plan_obstacles(), _plan_anchors(), str(_screenshot_args["top"]), str(_screenshot_args.get("plan", "false")) == "true")
	if _screenshot_args.has("windlog"):
		# after the style rig has turned the materials into its toon and card shaders
		get_tree().create_timer(1.5).timeout.connect(func() -> void:
			var lines: PackedStringArray = PlanView.swaying(self)
			print("SWAY-COUNT ", lines.size())
			for line: String in lines:
				print("SWAY ", line))
	ZoneTitleCard.show_in(self, Areas.key_for_zone(def.id), _screenshot_args.is_empty() or _screenshot_args.has("card"))
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
	player.setup(builder, "Hero", spawn)
	player.position.y = builder.height_at(spawn)


## Overnight Oct 17, Part 11: the zone's NPCs say a line when the hero walks past (`NpcBarks`, lines from data/npcs/npcs.json).
var npc_barks: NpcBarks
var ambient_fx: AmbientFx
## Zone id -> its `AmbientFx` preset.
const AMBIENT_KEYS: Dictionary = {"beefcake": "gainlands", "necrocrat": "dna", "gourmand": "buffet", "refusemancer": "heap", "final": "capital"}


## Playtest v0.4.0 Part A: floating name labels as screen UI (vendors with what they sell and quest givers always, others when close) and a
## glow at the feet of vendors and quest givers. Fig Sly (the black market) keeps no label and no glow.
var npc_labels: NpcLabels


func _labels() -> NpcLabels:
	if npc_labels == null:
		npc_labels = NpcLabels.install(self, player, _camera, func() -> bool: return _locked or (dialogue != null and dialogue.active))
		npc_labels.boost = func(key: String) -> bool: return quest_markers != null and quest_markers.is_marked(key)
	return npc_labels


func _label_spot(spot: ZoneSpot, marker: Node3D) -> void:
	if not is_instance_valid(marker):
		return
	var npc_id: String = str(spot.data.get("npc_id", ""))
	var kind: String = NpcLabels.kind_for(npc_id) if not npc_id.is_empty() else ("vendor" if spot.kind == "vendor" else "npc")
	if kind.is_empty() or spot.title.to_lower().contains("fig sly"):
		return
	if spot.kind.begins_with("vendor") and kind == "npc":
		kind = "vendor"
	elif (spot.kind.contains("quest") or bool(spot.data.get("quest", false))) and kind == "npc":
		kind = "quest"
	var text: String = NpcLabels.text_for(npc_id, spot.title) if not npc_id.is_empty() else spot.title
	if kind == "vendor" and not text.contains(" - "):
		text = "%s - Shop" % spot.title
	_labels().register(marker, text, kind, kind != "npc", 0.3, spot.id)
	if kind != "npc":
		var npc_key: String = str(spot.data.get("npc", spot.id))
		if _npcs.has(npc_key):
			NpcGlow.attach(_npcs[npc_key] as Node3D, NpcGlow.VENDOR if kind == "vendor" else NpcGlow.QUEST)


func _build_npcs() -> void:
	npc_barks = NpcBarks.new()
	add_child(npc_barks)
	npc_barks.target = player
	npc_barks.blocked = func() -> bool: return _locked or (dialogue != null and dialogue.active)
	# Overnight Oct 17, Part 14: the zone's light atmosphere (dust, steam, ghost motes, gnats, ash) and footstep puffs.
	ambient_fx = AmbientFx.add(self, str(AMBIENT_KEYS.get(def.id, "")), player)
	for entry: Dictionary in def.npcs:
		var pos: Vector3 = builder.anchor(str(entry["anchor"]))
		pos.y = builder.height_at(pos)
		var npc: Node3D = _make_npc(entry, pos, str(entry.get("anim", "Idle")))
		_npcs[str(entry["id"])] = npc
		if not str(entry.get("npc_id", "")).is_empty():
			npc_barks.register(npc, str(entry["npc_id"]))
		if not (npc is SpriteStroller):
			builder.add_blocker(pos, 0.3)


## One NPC of a zone entry: a painted sprite when its list NPC has a sprite set (`NpcSprites`; `wander` entries with a walking set stroll about their anchor), else the tinted
## 3D model. Sprites take their size from the art's relative height, so the entry's model `scale` does not apply to them.
func _make_npc(entry: Dictionary, pos: Vector3, anim_name: String) -> Node3D:
	var character: String = NpcSprites.character_for_entry(entry)
	if character != "":
		var walk_dirs: Array = SpriteLibrary.info(character).get("walk_dirs", []) as Array
		if bool(entry.get("wander", false)) and not walk_dirs.is_empty():
			var stroller: SpriteStroller = SpriteStroller.new()
			stroller.character = character
			stroller.tint = entry.get("sprite_tint", Color.WHITE) as Color
			stroller.name = "Stroller_%s" % str(entry["id"])
			add_child(stroller)
			stroller.setup(pos, func(p: Vector3) -> bool: return builder.is_walkable(p, 0.25), hash(str(entry["id"])))
			_strollers.append(stroller)
			return stroller
		var actor: SpriteActor = NpcSprites.make_actor(character, entry.get("sprite_tint", Color.WHITE) as Color)
		ModelKit.place(self, actor, pos, float(entry["yaw"]), TownPlayer.MODEL_SCALE)
		if npc_hp == null:
			npc_hp = NpcHp.new()
			npc_hp.target = player
			add_child(npc_hp)
		npc_hp.register(actor, float(entry["yaw"]))
		return actor
	var npc: Node3D = ModelKit.character(str(entry["model"]))
	ModelKit.tint(npc, entry["tint"] as Color)
	ModelKit.place(self, npc, pos, float(entry["yaw"]), TownPlayer.MODEL_SCALE * float(entry.get("scale", 1.0)))
	var animation: AnimationPlayer = ModelKit.animation_player(npc)
	if animation != null and animation.has_animation(anim_name):
		animation.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
		animation.play(anim_name)
		animation.seek(randf() * 1.5)
	return npc


## Strollers walk and their talk spots follow them; a painted NPC shows its TALK pose while the hero talks to them.
func _update_sprite_npcs(delta: float) -> void:
	if npc_hp != null and npc_hp.target == null:
		npc_hp.target = player
	var talking: bool = dialogue != null and dialogue.active
	if not talking:
		_talking_id = ""
	for id: Variant in _npcs.keys():
		var actor: SpriteActor = _npcs[id] as SpriteActor
		if actor != null:
			actor.talking = talking and str(id) == _talking_id
	for stroller: SpriteStroller in _strollers:
		stroller.frozen = talking and _npcs.get(_talking_id) == stroller
		stroller.tick(delta, player.position)
	for spot: ZoneSpot in spots:
		var moving: SpriteStroller = _npcs.get(str(spot.data.get("npc", ""))) as SpriteStroller
		if moving != null:
			spot.position = moving.world_position()
			spot.marker.position.x = spot.position.x
			spot.marker.position.z = spot.position.z
			spot.plate.position = spot.marker.position + Vector3(0.0, 0.34, 0.0)


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
	if not bool(data.get("hidden", false)):
		match kind:
			"mini_dungeon", "main_dungeon":
				StyleBeacon.build(self, Vector3(pos.x, ground, pos.z), Color(1.0, 0.78, 0.4), 5.0, 0.12)
			"exit":
				StyleBeacon.build(self, Vector3(pos.x, ground, pos.z), Color(0.8, 0.9, 1.0), 4.0, 0.08)
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
	spot.label_height = NpcSprites.label_height(_npcs.get(str(data.get("npc", ""))) as Node, 0.0) if npc else 0.0
	marker.position = pos + Vector3(0, ground + (spot.label_height if spot.label_height > 0.0 else (1.45 if npc else 1.7)), 0)
	add_child(marker)
	spot.marker = marker
	var plate: Label3D = Label3D.new()
	# Playtest v0.4.0 Part A: names are screen UI now (`NpcLabels`); the plate stays as an empty anchor so the old fade code is harmless.
	plate.text = ""
	plate.visible = false
	if npc and not bool(data.get("hidden", false)) and not bool(data.get("no_plate", false)):
		_label_spot.call_deferred(spot, marker)
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
	if bool(data.get("no_plate", false)):
		# a spot whose place carries its own pictogram (the House of Gains gate): the marker stays, the lettered plate never shows (the HUD prompt names it)
		plate.visible = false
		plate.modulate.a = 0.0
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
	if _station_layer() == 1:
		StyleBeacon.build(self, pos, _station_beacon_color(), 6.0, 0.18)
	builder.add_blocker(pos, 1.3)
	var rip: Dictionary = NpcSprites.rift_operator()
	var operator: Node3D = rip["node"] as Node3D
	var operator_pos: Vector3 = pos + Vector3(-2.4, 0.0, 0.8)
	ModelKit.place(self, operator, operator_pos, 50.0, TownPlayer.MODEL_SCALE * float(rip["scale"]))
	var animation: AnimationPlayer = ModelKit.animation_player(operator)
	if animation != null and animation.has_animation("Idle"):
		animation.play("Idle")
		animation.seek(randf() * 1.5)
	_npcs["rift_operator"] = operator
	builder.add_blocker(operator_pos, 0.35)
	_add_spot("rift_station", travel.text("travel.title"), pos + Vector3(0.0, 0.0, 1.6), 2.0, travel.text("travel.prompt"), false, "rift_station")


## The light pillar colour over the Rift Express (a zone with its own accent colour overrides it).
func _station_beacon_color() -> Color:
	return Color(0.55, 0.95, 1.0)


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
		if float(spawn.get("guard", 0.0)) > 0.0:
			enemy.make_guard(float(spawn["guard"]), int(spawn.get("escorts", 0)))  # a road guard (the Gainlands' middle road, v2 Part G)
		enemy.touched.connect(_on_enemy_touched)
		enemies.append(enemy)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.fov = 38.0
	add_child(_camera)
	_camera.current = true
	_camera.position = player.position + CameraRig.shape(camera_offset)
	_camera.look_at(player.position + Vector3(0, 0.4, 0), Vector3.UP)
	style_rig = StyleRig.install(self, _style_preset(), _camera, player, CULL_DISTANCE)
	if style_rig != null:
		look_rig = WorldLookRig.install(self, _camera, player, style_rig, builder)
	if style_rig != null and style_rig.ambience != null:
		style_rig.ambience.focus(0.5, 1.6)
	if style_rig != null:
		_dress_zone()
		_paint_zone()


## Overnight Oct 18, Phase 2 cycle 5: the first time a hero walks into a zone whose debuff hits their own Path, a longer toast says so and
## names the zone that favours their Path (shown after the arrival card; once per hero per zone).
func _warn_rival_path() -> void:
	if Session.profile == null:
		return
	var key: StringName = StringName("rival_warned_" + def.id)
	var text: String = ZoneEffects.rival_warning(def.id, Session.profile.primary_affinity)
	if text.is_empty() or Session.flag(key):
		return
	Session.set_flag(key)
	while SceneManager.busy:
		await get_tree().process_frame
	await get_tree().create_timer(4.6).timeout
	if is_inside_tree() and hud != null:
		Audio.sfx(&"enemy_alert", -10.0)
		hud.toast(text, UIStyle.GOLD, 6.0)


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
	hud.wardrobe_pressed.connect(_open_wardrobe)
	hud.packs_pressed.connect(_open_packs)
	EventBus.quest_notice.connect(_on_quest_notice)
	hp_bar = ZoneHpBar.new()
	hp_bar.position = Vector2(790, 24)
	host.add_child(hp_bar)
	_banner = UIKit.label("", &"TitleLabel", 54, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	_banner.position = Vector2(360, 190)
	_banner.size = Vector2(1200, 80)
	_banner.modulate.a = 0.0
	host.add_child(_banner)
	dialogue = DialogueBox.new()
	host.add_child(dialogue)
	dialogue.stand_behind(hud)
	minimap = MinimapHud.new()
	host.add_child(minimap)
	minimap.setup(def.id, builder, player, _collect_pois)
	minimap.full_map_requested.connect(_open_full_map)
	quest_markers = QuestMarkerLayer.install(self, def.id, _camera, func(spot_id: String) -> Dictionary: return QuestMarkerLayer.resolve_in(spots, spot_id), host)
	var overlay_canvas: CanvasLayer = CanvasLayer.new()
	overlay_canvas.layer = 8
	add_child(overlay_canvas)
	_overlay_layer = UIKit.layer_host(overlay_canvas)


# ---- Frame update ----------------------------------------------------------------------------


func _process(delta: float) -> void:
	_time += delta
	_invulnerable = maxf(0.0, _invulnerable - delta)
	_spawn_grace = maxf(0.0, _spawn_grace - delta)
	if _world_active():
		_scene_cooldown = maxf(0.0, _scene_cooldown - delta)
	Hitch.start("zone.camera")
	_update_camera(delta)
	Hitch.stop("zone.camera")
	Hitch.start("zone.visibility")
	builder.update_visibility(player.position)
	Hitch.stop("zone.visibility")
	Hitch.start("zone.process")
	_zone_process(delta)
	Hitch.stop("zone.process")
	Hitch.start("zone.soundscape")
	_update_soundscape(delta)
	Hitch.stop("zone.soundscape")
	var world_active: bool = _world_active()
	if world_active and not Session.pending_popups.is_empty():
		var popup: RewardPopup = RewardPopup.make(Session.pending_popups.pop_front() as RewardSummary)
		_open_overlay(popup)
		popup.finished.connect(_close_overlay)
		world_active = false
	elif world_active and _scene_cooldown <= 0.0 and _play_pending_story_scene():
		world_active = false
	elif world_active and not Session.pending_level_ups.is_empty():
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
		var base_y: float = builder.height_at(spot.position) + (spot.label_height if spot.label_height > 0.0 else (1.45 if spot.is_npc else 1.7))
		spot.marker.position.y = base_y + sin(_time * 2.4 + spot.position.x) * 0.07
		spot.marker.rotation_degrees.y += 60.0 * delta
		if bool(spot.data.get("no_plate", false)):
			continue
		var distance: float = Vector2(player.position.x - spot.position.x, player.position.z - spot.position.z).length()
		spot.plate.modulate.a = clampf(1.0 - (distance - 2.4) / 1.6, 0.0, 1.0)
		spot.plate.outline_modulate.a = spot.plate.modulate.a
		spot.plate.visible = spot.plate.modulate.a > 0.02
	_update_sprite_npcs(delta)
	_update_nearest()
	_update_chest_prompt()
	_update_area_banner()
	_update_station()


## Oct 21: a story scene waiting in this zone (pending_story_scene), played as soon as the hero is free. True when one started.
func _play_pending_story_scene() -> bool:
	var scene: String = pending_story_scene()
	if scene.is_empty():
		return false
	_scene_cooldown = 1.0
	StoryScenePlayer.play(dialogue, scene)
	return true


## The story scene waiting for the hero here: the lieutenant who fled this freed zone (Lieutenants.fled_scene). The Capital adds its own.
func pending_story_scene() -> String:
	return Lieutenants.fled_scene(def.id, Session.flags)


func _world_active() -> bool:
	return not _locked and not dialogue.active and not _fainting


func _update_camera(delta: float) -> void:
	var target: Vector3 = player.position + CameraRig.shape(camera_offset)
	_camera.position = _camera.position.lerp(target, 1.0 - exp(-5.0 * delta))
	_camera.rotation_degrees = Vector3(-atan2(camera_offset.y, camera_offset.z) * 180.0 / PI, 0.0, 0.0)
	if _cam_shake_time > 0.0:
		_cam_shake_time = maxf(0.0, _cam_shake_time - delta)
		_camera.position += Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * _cam_shake_power * 0.14 * minf(1.0, _cam_shake_time * 3.0)


## Signs (G-03 read spots) count as this much farther away, so any other spot in range wins the E.
const SIGN_YIELD: float = 3.0


## The spot E would use from `pos`: the closest one in reach; a sign counts as SIGN_YIELD farther, so it never steals the E from a spot beside it.
func _nearest_spot(pos: Vector3) -> ZoneSpot:
	var best: ZoneSpot = null
	var best_distance: float = 1e9
	for spot: ZoneSpot in spots:
		var distance: float = Vector2(pos.x - spot.position.x, pos.z - spot.position.z).length()
		var reach: float = spot.radius * StorybookScale.INTERACT_FACTOR
		if spot.kind == "sign":
			distance += SIGN_YIELD
			reach += SIGN_YIELD
		if distance <= reach and distance < best_distance:
			best = spot
			best_distance = distance
	return best


func _update_nearest() -> void:
	if _locked or dialogue.active or _fainting or player.airborne:
		hud.hide_prompt()
		_near = null
		return
	var best: ZoneSpot = _nearest_spot(player.position)
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
		if event.is_action_pressed(&"open_character"):
			get_viewport().set_input_as_handled()
			_open_character_screen()
			return
		if event.is_action_pressed(&"open_deck"):
			get_viewport().set_input_as_handled()
			_open_deck_builder()
			return
		if event.is_action_pressed(&"open_packs"):
			get_viewport().set_input_as_handled()
			_open_packs()
			return
		if event.is_action_pressed(&"open_wardrobe"):
			get_viewport().set_input_as_handled()
			_open_wardrobe()
			return
		if event.is_action_pressed(&"open_quests"):
			get_viewport().set_input_as_handled()
			_open_quest_log()
			return
		if event.is_action_pressed(&"open_map"):
			get_viewport().set_input_as_handled()
			_open_full_map()
			return
	if _locked or dialogue.active:
		return
	var interact: bool = event.is_action_pressed(&"interact")
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
			_talk_quest_npc(str(spot.data["npc"]), str(spot.data["npc_name"]), str(spot.data["speaker"]), Callable(), str(spot.data.get("npc_id", "")))
		"vendor_npc":
			_talk_quest_npc(str(spot.data["npc"]), str(spot.data["npc_name"]), str(spot.data["speaker"]), _open_vendor, str(spot.data.get("npc_id", "")))
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
		"shrine":
			_use_shrine(spot)
		"freed_npc":
			_face_npc(str(spot.data["npc"]))
			_say(str(spot.data["speaker"]), story.get_lines("freed_npc.%s" % str(spot.data["npc"])), Callable(), str(spot.data.get("npc_id", "")))
		"plaque", "sign":
			Audio.sfx_at(&"sign_read", spot.position)
			_say("", story.get_lines(str(spot.data["key"])))
		"hob":
			_talk_hob()
		"vault_lever":
			_pull_vault_lever()
		"giant_chest":
			_open_giant_chest()
		"quiz":
			_face_npc(str(spot.data["npc"]))
			_say(str(spot.data["speaker"]), story.get_lines("npc.quiz.return" if Session.flag(def.flag_met("quiz")) else "npc.quiz.intro"), _open_quiz, str(spot.data.get("npc_id", "")))
			Session.set_flag(def.flag_met("quiz"))
		"minigame":
			_face_npc(str(spot.data["npc"]))
			_say(str(spot.data["speaker"]), _greeting(str(spot.data["npc"])), _open_minigame, str(spot.data.get("npc_id", "")))
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
	_talking_id = id
	if npc is SpriteStroller:
		(npc as SpriteStroller).face(player.position)
		player.face((npc as SpriteStroller).world_position())
	elif npc != null:
		var offset: Vector3 = player.position - npc.position
		npc.rotation.y = atan2(offset.x, offset.z)
		player.face(npc.position)


## `speaker_npc_id`: the list NPC (`NpcRegistry`) whose portrait shows; empty looks the speaker label up by name.
func _say(speaker: String, lines: Array[String], then: Callable = Callable(), speaker_npc_id: String = "") -> void:
	dialogue.start(speaker, lines, speaker_npc_id)
	if then.is_valid():
		dialogue.finished.connect(then, CONNECT_ONE_SHOT)


## An NPC who gives and takes quests: hand-in first, then a new offer, then a reminder, then the
## plain greeting (intro the first time, "return" lines afterwards). `after` runs when the
## conversation ends (the vendor opens his shop).
func _talk_quest_npc(npc_id: String, npc_name: String, speaker: String, after: Callable = Callable(), portrait_npc: String = "") -> void:
	_face_npc(npc_id)
	var ready: Array[QuestData] = Session.quests_ready_for(npc_name)
	if not ready.is_empty():
		var quest: QuestData = ready[0]
		# A Capital Path NPC's major quest conclusion has its own cue (Pell, Rollo, Marlo, Fern) under the hand-in dialogue.
		var cue: String = MusicDirector.quest_conclusion(npc_id) if def.id == CapitalZone.ID else ""
		var cue_token: int = Audio.push_music(StringName(cue), 1.2, false) if not cue.is_empty() else 0
		_say(speaker, story.get_lines("quest.%s.ready" % quest.id), func() -> void:
			if cue_token != 0:
				Audio.pop_music(cue_token, 2.0)
			Session.turn_in_quest(quest.id)
			if after.is_valid():
				after.call(), portrait_npc)
		return
	var offered: Array[QuestData] = Session.quests_offered_by(npc_name)
	if not offered.is_empty():
		var quest: QuestData = offered[0]
		_say(speaker, _greeting(npc_id) + story.get_lines("quest.%s.offer" % quest.id), func() -> void:
			Session.start_quest(quest.id)
			if after.is_valid():
				after.call(), portrait_npc)
		return
	for quest_id: String in Session.quest_log.active:
		var active_quest: QuestData = QuestCatalog.find(quest_id)
		if active_quest != null and active_quest.giver_npc == npc_name:
			_say(speaker, story.get_lines("quest.%s.active" % quest_id), after, portrait_npc)
			return
	_say(speaker, _greeting(npc_id), after, portrait_npc)


func _greeting(npc_id: String) -> Array[String]:
	var flag_name: StringName = def.flag_met(npc_id)
	if not Session.flag(flag_name):
		Session.set_flag(flag_name)
		return story.get_lines("npc.%s.intro" % npc_id)
	var lines: Array[String] = story.get_lines("npc.%s.return" % npc_id)
	lines.append_array(_hook_lines(npc_id))
	return lines


## The quest hooks of the dungeon list that this NPC speaks (a main dungeon that is not cleared yet), as dialogue lines.
func _hook_lines(npc_id: String) -> Array[String]:
	var lines: Array[String] = []
	var list_id: String = str(def.spot_def(npc_id).get("npc_id", ""))
	if list_id.is_empty():
		return lines
	for hook: Dictionary in DungeonCatalog.hooks_for_npc(list_id):
		var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(str(hook["dungeon"]))
		if plan != null and not Session.is_zone_completed(plan.zone_id):
			lines.append(str(hook["text"]))
	return lines


func _use_heal_spot(spot: ZoneSpot) -> void:
	player.face(spot.position)
	var healed: int = Session.zone_run.fully_heal()
	EventBus.zone_hp_changed.emit(Session.zone_run.hp, Session.zone_run.max_hp())
	Audio.sfx(&"heal")
	hud.toast(story.text("fx.heal_couch") if healed > 0 else story.text("fx.heal_already"), UIStyle.GOOD)


func _ask_mini_dungeon(spot: ZoneSpot) -> void:
	player.face(spot.position)
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.side_for_zone(def.id)
	if plan == null:
		return
	# A side dungeon opens once its quest is done (`ZoneQuestDefinitions.SIDE_QUESTS`); until then the entrance only drops the hook.
	if not Session.side_unlocked(plan.id):
		hud.toast("%s is sealed. %s" % [plan.dungeon_name, plan.hook], Color("ffcf70"))
		Audio.sfx(&"ui_error")
		return
	_locked = true
	var cleared: bool = Session.flag(def.flag_mini_cleared)
	var body: String = "%s

%s" % [plan.story, "You have been here before: a repeat clear pays gold and a pack." if cleared else "First clear: a unique card."]
	var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, def.mini.dungeon_name, body, "Enter", "Not yet")
	dialog.confirmed.connect(func() -> void:
		DeckPicker.guard(_overlay_layer, func() -> void:
			var run: ZoneRun = Session.zone_run
			run.return_position = spot.position + Vector3(0, 0, 1.0)
			run.has_return_position = true
			Audio.sfx(&"dungeon_enter")
			Session.enter_mini_dungeon(), func() -> void: _locked = false))
	dialog.cancelled.connect(func() -> void: _locked = false)


## The zone's final dungeon (Part E): its entrance shows what waits inside, then enters it (HP carries in
## from the zone, like the mini dungeon).
func _use_main_dungeon(spot: ZoneSpot) -> void:
	player.face(spot.position)
	hud.toast(story.text("fx.main_dungeon"), Color("ffcf70"))
	if not MainDungeons.has_def(def.id):
		return
	_locked = true
	var cleared: bool = Session.is_zone_completed(def.id)
	var body: String = story.text("ui.main.body_cleared" if cleared else "ui.main.body")
	if def.id == CapitalZone.ID and not CapitalDebuffs.active(Session.flags).is_empty() and not Session.flag(&"primm_defeated"):
		# Oct 16: the Capital is open from the start, but storming the castle with services still broken is a speedrunner's dare.
		body = "%s\n\n%s (%d of 4 services still broken.)" % [StoryText.shared().text("capital.castle.warning"), body, CapitalDebuffs.active(Session.flags).size()]
	var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, story.text("ui.main.title"), body, story.text("ui.main.button"), "Not yet")
	dialog.confirmed.connect(func() -> void:
		DeckPicker.guard(_overlay_layer, func() -> void:
			var run: ZoneRun = Session.zone_run
			run.return_position = spot.position + Vector3(0, 0, 1.4)
			run.has_return_position = true
			Audio.sfx(&"dungeon_enter")
			Session.enter_main_dungeon(), func() -> void: _locked = false))
	dialog.cancelled.connect(func() -> void: _locked = false)


func _ask_exit() -> void:
	_locked = true
	var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, story.text("ui.exit.title"), story.text("ui.exit.body"), "Leave", "Stay")
	dialog.confirmed.connect(func() -> void:
		Audio.sfx(&"door")
		Session.leave_zone())
	dialog.cancelled.connect(func() -> void: _locked = false)


func _open_vendor() -> void:
	# UI + economy fixes Oct 22, Part 5: a Path zone's vendor sells that Path - Commons and two Uncommons first, the rest of the Uncommons
	# and the Epics once the zone is freed, a Legendary in the postgame (VendorStocks.zone_shelf). The Capital's Black Market keeps its list.
	var path: Affinity.Type = PackRules.path_for_zone(def.id)
	var data: VendorData = VendorStocks.zone_shelf(Session.content, path, def.id, def.vendor_ids, def.vendor_name) if path != Affinity.Type.NEUTRAL else VendorData.new()
	if path == Affinity.Type.NEUTRAL:
		data.vendor_name = def.vendor_name
		for id: String in def.vendor_ids:
			data.add(id)
	var screen: VendorScreen = VendorScreen.new()
	screen.stock = data
	screen.screen_title = def.vendor_title
	screen.vendor_screen_id = def.vendor_screen_id
	screen.gear_stock = ExpansionGear.zone_vendor_stock(def.id)
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
	reward = ChestLoot.with_roll(reward, def.id, Session.owned_equipment_ids(), Session.rng)  # Oct 16: chests can roll gear or a pack by tier
	var summary: RewardSummary = Session.grant_chest_reward(reward, "Hidden chest")
	Session.bump_counter(def.counter_chests)
	hud.set_gold(Session.gold)
	Session.save_game()
	_locked = true
	player.input_enabled = false
	_animate_chest(id)
	await get_tree().create_timer(0.7).timeout
	var popup: RewardPopup = RewardPopup.make(summary)
	_open_overlay(popup)
	popup.finished.connect(_close_overlay)


func _animate_chest(id: String) -> void:
	Audio.sfx(&"chest_open")
	Audio.sfx(&"coins", 0.0, 0.05)
	ChestKit.open_animated(builder.chest_nodes.get(id) as Node3D)



# ---- The hidden vault lever (brief 16, Group G) ------------------------------------------------------------------------


## Builds this zone's vault lever where the layout's `vault_lever` anchor says: tucked away, no marker, no plate - only the prompt close up.
func _build_vault_lever() -> void:
	if not builder.has_anchor("vault_lever") or not VaultGuardian.is_lever_zone(def.id):
		return
	var pos: Vector3 = builder.anchor("vault_lever")
	pos.y = builder.height_at(pos)
	vault_lever_node = LeverKit.build(VaultLeverEvent.seal_color(def.id))
	add_child(vault_lever_node)
	vault_lever_node.position = pos
	vault_lever_node.rotation_degrees.y = 180.0
	builder.add_blocker(pos, 0.45)
	LeverKit.set_pulled(vault_lever_node, Session.vault_lever_pulled(def.id))
	_add_spot("vault_lever", "", pos, LeverKit.PROMPT_RADIUS, "Pull the lever", false, "vault_lever", {"hidden": true})


func _pull_vault_lever() -> void:
	if vault_lever_node == null:
		return
	VaultLeverEvent.play(self, def.id, vault_lever_node)


## A short camera shake (`power` ~0.5-1.5, `seconds`).
func shake_camera(power: float, seconds: float) -> void:
	_cam_shake_power = power
	_cam_shake_time = seconds


# ---- Shiro Swindle's giant chest (brief 16, Group B) -----------------------------------------------------------------


## Builds this zone's giant chest where the layout's `giant_chest` anchor says: a big chest (no marker, no plate) that stays open once opened.
func _build_giant_chest() -> void:
	if not builder.has_anchor("giant_chest") or not NinjaBoss.is_chest_id(def.id):
		return
	var pos: Vector3 = builder.anchor("giant_chest")
	pos.y = builder.height_at(pos)
	giant_chest_node = GiantChestEvent.make_chest(self, pos, 180.0)
	builder.add_blocker(pos, 0.55)
	GiantChestEvent.apply_look(giant_chest_node, def.id)
	_add_spot("giant_chest", "", pos, GiantChestEvent.PROMPT_RADIUS, "Open the chest", false, "giant_chest", {"hidden": true})


func _open_giant_chest() -> void:
	if giant_chest_node == null:
		return
	player.face(giant_chest_node.position)
	GiantChestEvent.play(self, def.id, giant_chest_node)


## GiantChestEvent hooks: the scene is locked while the scene plays; only the town has an original chest to wake.
func set_world_locked(on: bool) -> void:
	_locked = on


func on_ninja_ready() -> void:
	pass


# ---- Zone HP: enemies, damage, fainting ----------------------------------------------------


func _on_enemy_touched(enemy: ZoneEnemy) -> void:
	if _locked or dialogue.active or _fainting or _spawn_grace > 0.0 or player.airborne:
		return
	if enemy.info.kind == ZoneEnemyInfo.Kind.DAMAGE:
		if _invulnerable > 0.0:
			return
		hit_player(enemy.info.damage, enemy.position, "knocked flat by a %s" % enemy.info.display_name)
		Session.bestiary_meet(enemy.info.display_name)  # Part 10: roamers that never fight are met by touch
		enemy.retreat_from(player.position, ZoneEnemies.RETREAT_TIME)
		return
	_start_enemy_battle(enemy)


func _start_enemy_battle(enemy: ZoneEnemy) -> void:
	_locked = true
	var run: ZoneRun = Session.zone_run
	var back: Vector3 = player.position + (player.position - enemy.position).normalized() * 0.6
	run.return_position = back if builder.is_walkable(back) else player.position
	run.has_return_position = true
	var rule_names: String = EncounterModifiers.names_line(EncounterModifiers.zone_key(Session.zone_run.zone_id if Session.zone_run != null else "", enemy.info.id))
	hud.toast("%s wants a word...%s" % [enemy.info.display_name, ("  [%s]" % rule_names) if not rule_names.is_empty() else ""], Color("ff8a85"))
	Audio.sfx(&"enemy_alert")
	await get_tree().create_timer(0.7).timeout
	Session.start_zone_battle(enemy.info.id, enemy.instance_id)


## Damage to the persistent zone HP: flash, shake, HUD update, knockback and a short
## invulnerability window. At 0 HP the player faints and wakes at the hub.
func hit_player(amount: int, from: Vector3, cause: String = "knocked flat") -> void:
	var run: ZoneRun = Session.zone_run
	run.damage(amount)
	_invulnerable = ZoneEnemies.HIT_COOLDOWN
	EventBus.zone_hp_changed.emit(run.hp, run.max_hp())
	Audio.sfx(&"hero_hurt")
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
	_camera.position = player.position + CameraRig.shape(camera_offset)
	_invulnerable = 2.0
	_spawn_grace = SPAWN_GRACE
	EventBus.zone_hp_changed.emit(Session.zone_run.hp, Session.zone_run.max_hp())


func _show_wake_dialogue(fee_override: int) -> void:
	var fee: int = _last_fee if fee_override == 0 else fee_override
	# Oct 21: Old Hob sends you back first ("Not on my list. Off you pop."); the fee is his handling fee.
	StoryScenePlayer.play(dialogue, OldHob.WAKE_SCENE, func() -> void: dialogue.start(def.wake_speaker, story.get_lines("fx.wake")))
	hud.toast("%s: -%d gold (logged)." % [def.fee_label, fee], Color("ffcf70"))


## After returning from a zone battle: show what happened (rewards / woke at hub).
func _apply_pending_result() -> void:
	var result: Dictionary = Session.pending_zone_result
	Session.pending_zone_result = {}
	if result.is_empty():
		return
	if bool(result.get("woke_at_hub", false)):
		player.position = _hub_spawn()
		_camera.position = player.position + CameraRig.shape(camera_offset)
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
			hud.toast("%s survived again. %s" % [ZoneDefs.get_def(def.id).full_name, pack_lines[0] if not pack_lines.is_empty() else "HP carries over."], UIStyle.GOOD)
		else:
			hud.toast("You leave the dungeon with %d HP." % Session.zone_run.hp, Color("ffcf70"))
		return
	if str(result.get("kind", "")) == "mini":
		if bool(result.get("first_clear", false)):
			Audio.sting(&"STG-DUNGEON")
			var gear_text: String = (" New gear: %s." % str(result["equipment"])) if result.has("equipment") else ""
			hud.toast("%s cleared! Unique card: %s.%s" % [def.mini.dungeon_name, str(result.get("card", "")), gear_text], UIStyle.GOLD)
		elif bool(result.get("cleared", false)):
			Audio.sting(&"STG-DUNGEON")
			hud.toast("%s cleared again: +%d gold. HP carries over." % [def.mini.dungeon_name, int(result.get("gold", 0))], UIStyle.GOOD)
		else:
			hud.toast("You leave %s with %d HP." % [def.mini.dungeon_name, Session.zone_run.hp], Color("ffcf70"))
		return
	if bool(result.get("won", false)):
		hud.toast("Won! +%d gold, +%d XP. HP stays as it is." % [int(result.get("gold", 0)), int(result.get("xp", 0))], UIStyle.GOLD)


## The announcement after the zone's final boss falls: the zone is free; what just unlocked.
func _show_zone_freed(result: Dictionary) -> void:
	var story_text: StoryText = StoryText.shared()
	var lines: Array[String] = []
	lines.append(ZoneCompletion.progress_text(Session.flags))
	if result.has("equipment"):
		lines.append("New gear: %s" % str(result["equipment"]))
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
	screen.sting = MusicDirector.zone_freed_sting(def.id)
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
		var turn_in: bool = false
		if poi_kind == MapPoi.Kind.QUEST_GIVER:
			var npc_name: String = str(spot.data.get("npc_name", ""))
			marker = not Session.quests_ready_for(npc_name).is_empty() or not Session.quests_offered_by(npc_name).is_empty()
			turn_in = not Session.quests_ready_for(npc_name).is_empty()
		var label: String = spot.title
		var poi: MapPoi = MapPoi.make(poi_kind, spot.position, label, marker)
		poi.turn_in = turn_in
		result.append(poi)
	for spot: ZoneSpot in spots:
		if spot.id == "rift_station":
			result.append(MapPoi.make(MapPoi.Kind.TRAVEL_PORTAL, spot.position, spot.title))
	result.append_array(_extra_pois())
	if quest_markers != null:
		quest_markers.add_map_pois(result)
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
	EventBus.zone_hp_changed.emit(Session.zone_run.hp, Session.zone_run.max_hp())
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
	# A finished quest gets its own "Quest Complete" box (Session.pending_popups), so only new quests toast.
	if is_new:
		hud.queue_toast(text, UIStyle.GOLD)


# ---- Screenshot helpers ----------------------------------------------------------------------


func _teleport(anchor_name: String) -> void:
	var pos: Vector3 = Vector3.ZERO
	if anchor_name == "courier":
		for enemy: ZoneEnemy in enemies:
			if enemy.info.kind == ZoneEnemyInfo.Kind.DAMAGE:
				player.position = enemy.position + Vector3(3.0, 0, 0.0)
				_camera.position = player.position + CameraRig.shape(camera_offset)
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
				_camera.position = player.position + CameraRig.shape(camera_offset)
				_spawn_grace = 30.0
				return
		return
	if anchor_name == "rift_station_view" and builder.has_anchor(FastTravel.ANCHOR):
		anchor_name = FastTravel.ANCHOR
		pos = builder.anchor(anchor_name) + Vector3(0.0, 0.0, 1.0)
		player.position = pos
		player.position.y = builder.height_at(pos)
		_camera.position = player.position + CameraRig.shape(camera_offset)
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
	_camera.position = player.position + CameraRig.shape(camera_offset)
	_spawn_grace = 12.0


func _screenshot_open(what: String) -> void:
	match what:
		"vendor":
			_open_vendor()
		"supplies":
			if has_method("_open_supplies"):
				call("_open_supplies")
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
		"reveal", "map_all":
			minimap.reveal_all_for_screenshot()
			if what == "map_all":
				_open_full_map()
		"dialogue":
			for spot: ZoneSpot in spots:
				if spot.kind == "quest_npc":
					_talk_quest_npc(str(spot.data["npc"]), str(spot.data["npc_name"]), str(spot.data["speaker"]), Callable(), str(spot.data.get("npc_id", "")))
					return
		_:
			pass


func screenshot_ready() -> bool:
	return true


## The lighting/environment preset this zone uses (docs/art/style_guide.md, section 11). The Capital overrides it with its state.
func _style_preset() -> StringName:
	return StylePresets.for_zone(def.id)


## In the near-monochrome zones (the D.N.A.) colour is reserved for the hero, the people, the enemies and the key objects (docs/art/style_guide.md, section 11):
## they keep their colours, and enemies also get the zone's accent (red) rim.
func _apply_colour_keep() -> void:
	if style_rig == null or style_rig.preset.desaturate < 0.3:
		return
	StyleToon.keep_colour(player)
	for npc: Variant in _npcs.values():
		StyleToon.keep_colour(npc as Node)
	for enemy: ZoneEnemy in enemies:
		StyleToon.keep_colour(enemy, 1.0)
	if _station != null:
		StyleToon.keep_colour(_station)


## The wardrobe (hotkey T): hats, cloaks and dyes, purely cosmetic.
func _open_wardrobe() -> void:
	if _locked or dialogue.active:
		return
	var screen: WardrobeScreen = WardrobeScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


## The Packs menu entry (hotkey P): unopened packs with Open buttons.
func _open_packs() -> void:
	if _locked or dialogue.active or not Session.has_profile():
		return
	var screen: PacksScreen = PacksScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


## The painted texture look of the zone (data/art/texture_presets.json): ground, cliff and decals. Shift+T toggles it in debug builds.
var painted_world: PaintedWorld


func _paint_zone() -> void:
	painted_world = PaintedWorld.apply(self, builder, style_rig.preset_id, PaintedContexts.zone(self, style_rig.preset_id))


## Generic foliage/clutter dressing for the zone's preset; a zone with two moods (the Capital) overrides it.
func _dress_zone() -> void:
	ZoneDressing.build(self, builder, style_rig.preset_id, Settings.graphics_quality)
