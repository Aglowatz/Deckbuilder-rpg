class_name TownScene
extends Node3D
## The walkable starter town: a follow camera, the hero, two NPCs and the interactable spots
## (Wellspring, card vendor, deck station, dungeon gate). Only reached after the player has
## chosen their element and cleared the tutorial dungeon (`StartingAreaScene`,
## `ElementChoiceScreen`) - `Session.profile`/`Session.deck` are always set by then.

class Spot:
	extends RefCounted
	var id: String = ""
	var title: String = ""
	var position: Vector3 = Vector3.ZERO
	var radius: float = 1.6
	var marker: Node3D
	## Metres above the ground the marker / plate hover at (a painted NPC's height); 0 = the default for the kind of spot.
	var label_height: float = 0.0
	var plate: Label3D
	## False: no name plate and no map icon (hidden chests and levers, and vendors whose stock is not open yet).
	var named: bool = true


## The low cinematic framing of the world look (WorldLookRig: pitch 20, distance 6.2 before the zoom). Screenshots can override it (`--cam=x,y,z`).
var camera_offset: Vector3 = WorldLookRig.base_offset()
## The world look (post pass, sky, scenery, foliage); null with NO_STYLE.
var look_rig: WorldLookRig
## New brief, Part E: corrupted-NPC dialogue lines live here, not hardcoded in this script.
const STORY_PATH: String = "res://data/story/intro_story.tres"
## Three placeholder secrets proving the Condition system (docs/design/open_questions.md D38):
## a hidden chest, a locked vault that opens once its lever is pulled, and a hidden vendor who
## only appears once the chest has been found.
const HIDDEN_CHEST_SECRET: String = "harbor_chest"
const VAULT_LEVER_FLAG: StringName = &"vault_lever_pulled"
const HIDDEN_VENDOR_SECRET: String = "harbor_chest"
## The town NPCs that are painted sprites (docs/art/world_rollout.md, Part D): spot id -> sprite set. Everyone else is still a 3D model.
const NPC_SPRITES: Dictionary = {"elder": "ELDER", "guard": "GATEKEEPER", "vendor": "SABLE", "item_vendor": "TONIC", "pack_vendor": "FENWICK", "rescuer": "ELOWEN", "hob": "HOB", "isla": "ISLA"}
## True for spots that are people to talk to, as opposed to objects/gates.
const NPC_SPOT_IDS: Array[String] = [
	"elder", "guard", "vendor", "hidden_vendor", "item_vendor", "equipment_vendor", "pack_vendor", "tailor", "baker", "rescuer", "hob", "isla",
	"npc_beefcake", "npc_gourmand", "npc_refusemancer", "npc_necrocrat",
]
## The NPC ID (data/npcs, `NpcRegistry`) of each talkable town spot; spots without one (the secret dealer, the rift technician) show no portrait.
const NPC_IDS: Dictionary = {
	"elder": "NPC-ELDER", "guard": "NPC-GATEKEEPER", "vendor": "V-SABLE", "item_vendor": "V-TONIC", "equipment_vendor": "V-BEETSWORTH",
	"pack_vendor": "V-FENWICK", "tailor": "V-THREADWELL", "alchemist": "V-ALEMBIC", "arena": "NPC-BELLOWS",
	"npc_beefcake": "NPC-BRONSON", "npc_gourmand": "NPC-GRAVOIS", "npc_refusemancer": "NPC-MULLIGAN", "npc_necrocrat": "NPC-PALLOR",
	"hob": "NPC-HOB", "isla": "NPC-ISLA",
}
## How close (in screen pixels) a click has to land to a spot's marker to count as
## "clicking the NPC", since the fixed camera has no 3D picking set up.
const CLICK_PICK_RADIUS: float = 90.0

## New brief, Part D: 5 hidden chests (see TownBuilder.HIDDEN_CHEST_CELLS for where) - unlike
## the regular Spot system above, these have no marker/plate/click-picking at all, and a much
## tighter radius, so they cannot be found except by actually walking up close. See
## docs/design/secrets.md for the spoiler (locations + contents) - keep both in sync.
const HIDDEN_CHEST_RADIUS: float = 1.5
## id -> {gold, item, card, equipment}; "" / 0 means that reward type is not part of this chest.
## Fourth brief, Part E: added "equipment" (an equipment id) - the 2 new chests each hold one
## basic piece.
const HIDDEN_CHEST_REWARDS: Dictionary = {
	"west_woods": {"gold": 45, "item": "", "card": ""},
	"harbor_dock": {"gold": 30, "item": "healing_draught", "card": ""},
	"grave_hollow": {"gold": 0, "item": "reckless_tonic", "card": "N-06"},
	"uplands": {"gold": 50, "item": "", "card": "C-05"},
	"beefcake_flats": {"gold": 0, "item": "vitality_charm", "card": ""},
	"uplands_ridge": {"gold": 0, "item": "", "card": "", "equipment": "travelers_boots"},
	"harbor_dock_back": {"gold": 0, "item": "", "card": "", "equipment": "solid_plate"},
	# Polish round: the shores and ridges, paid by how far they are from the spawn (see docs/design/secrets.md).
	"clashatorium_west": {"gold": 60, "item": "healing_draught", "card": ""},
	"harbor_pier": {"gold": 50, "item": "", "card": "C-22"},
	"northeast_ridge": {"gold": 60, "item": "", "card": "C-29"},
	"southeast_shore": {"gold": 80, "item": "", "card": "", "pack": "gilded_gourmand"},
}

var town: TownBuilder = TownBuilder.new()
var player: TownPlayer
var spots: Array[Spot] = []
var minimap: MinimapHud
## Overnight Oct 16: "!" / "?" over quest givers and the tracked quest's objective marker (with its edge-of-screen pointer).
var quest_markers: QuestMarkerLayer
## Emitted when a gatekeeper is beaten for the first time (the hub plays the obstacle clearing).
signal gate_cleared(zone_id: String)
## Overnight Oct 16: the obstacles on the four zone roads (and their clearing animations).
var hub_obstacles: HubObstacles
var hud: TownHud
var dialogue: DialogueBox
var _camera: Camera3D
var style_rig: StyleRig
var square: TownSquare
## The painted texture look (data/art/texture_presets.json); Shift+T toggles it in debug builds.
var painted_world: PaintedWorld
var _portal_toast_cooldown: float = 0.0
var cloud_fader: CloudFader
var npc_hp: NpcHp
var _overlay_layer: Control
var _overlay: Control
var _near: Spot
var _time: float = 0.0
## The Graveyard's music override (`Audio.push_music` token, 0 = not in the Graveyard) and its check timer.
var _graveyard_music: int = 0
var _music_timer: float = 0.0
const GRAVEYARD_MUSIC_RADIUS: float = 6.0
var _npcs: Dictionary = {}
## The NPC the hero is talking to (the sprite NPCs show their TALK pose while the dialogue is open).
var _talking_id: String = ""
## The wandering badger baker (a painted sprite that walks round the plaza; talk to him with E).
var _baker: SpriteWanderer
var _well_light: OmniLight3D
var _well_particles: CPUParticles3D
var _screenshot_args: Dictionary = {}
## Overnight Oct 20: every change of the hero lock goes to the game log (GameLog), so a tester's log shows a lock that never let go.
var _locked: bool = false:
	set(value):
		if value != _locked:
			GameLog.info("lock", "%s: hero %s" % [name, "locked" if value else "free"])
		_locked = value
## v0.4.2 hotfix: the lock watchdog - seconds the hero has been locked with no modal UI open (see `_watch_lock`).
var _lock_idle: float = 0.0
const LOCK_WATCHDOG_SECONDS: float = 4.0
## Times the watchdog had to free the hero (tests, the game log).
var lock_watchdog_trips: int = 0
## A scripted scene (the Shiro Swindle chests) holds the lock with no UI on screen: the watchdog leaves it alone.
var _scripted_lock: bool = false
var _station: FastTravelStation
var _arrived_by_rift: bool = false
var _hidden_chest_near: String = ""
## Brief 16, Group G: the Four-Seal Vault (door, four seals) built from the save's lever flags.
var four_seal_vault: Node3D
## Brief 16, Group D: the camera pulls back as the hero nears a zone passageway, to show the bridge and the land it leads to (1.0 = normal).
var _passage_boost: float = 1.0
## Overnight Oct 23 (boss entrances): the camera pushes in on the hero and the foe before a boss or gatekeeper fight (1 = normal).
var _battle_push: float = 1.0
var _passage_dir: Vector3 = Vector3.ZERO
var _passage_dir_target: Vector3 = Vector3.ZERO
## The destination name shown over the screen while the hero nears a passageway (only the name, like "The Capital").
var _passage_label: Label
const PASSAGE_ZOOM_NEAR: float = 5.0
const PASSAGE_ZOOM_FAR: float = 13.0
## Oct 16: only a slight pull-back (12 percent) near a road's end, not the old 2.2x zoom-out.
const PASSAGE_ZOOM_MAX: float = 0.12


## Crosspath pass, Part E: the kit vignettes round the outskirts (and what was refused, for tuning).
var outskirt_dressing: OutskirtDressing


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


## v0.4.2 hotfix: arriving through SceneManager the town is built in stages, one per frame (`_stage`), behind the loading screen, which keeps
## turning while the window keeps answering (the cave exit used to block one frame for 15-25 s with the screen black). SceneManager waits for
## `is_load_finished()` (built, and the first screens warmed by UiArtWarmup) before it fades in. A town added directly (tests, tools) is
## built in one go inside `_ready`, as before.
var _staged_build: bool = false
## Overnight Oct 23 (memory probe): `WAYWARD_PROBE_SKIP=birds,outskirts,look,clouds,dressing,painted` leaves those optional pieces out
## of the town build, to bisect the video memory that stays behind per Crosspath visit. Debug only; empty in normal play.
var _probe_skip: PackedStringArray = OS.get_environment("WAYWARD_PROBE_SKIP").split(",", false)
var _built: bool = false
var _build_steps_done: int = 0
const BUILD_STEPS: int = 16
var _warmup: UiArtWarmup
var _files_warmup: SceneWarmup
## The town's sound events warmed behind the loading screen (footsteps on every surface, the dialogue voices, the UI ticks).
const WARM_SOUNDS: Array[String] = ["step_grass", "step_dirt", "step_cobble", "step_stone", "step_wood", "step_gravel", "dialogue", "dialogue_airy",
	"ui_tick", "ui_open", "ui_close", "ui_confirm", "ui_click", "ui_hover", "ui_back", "ui_tab", "book", "sign_read", "zone_transition"]


func is_load_finished() -> bool:
	if not _built:
		return false
	if _files_warmup != null and is_instance_valid(_files_warmup) and not _files_warmup.is_done():
		return false
	if _warming_popups:
		return false
	return _warmup == null or not is_instance_valid(_warmup) or (_warmup.screens_done() and (not _staged_build or _warmup.settled()))


## v0.4.2 hotfix: a level-up screen or a reward box opening at the fade-in cost a 0.5-2.6 s first frame (its live blurred backdrop, rays,
## big outlined numbers). When the cave arrival starts with one of those, it is opened behind the loading screen, which stays up a few more
## frames (and SceneManager's settle) until it draws quickly. Maren's welcome itself still opens at the fade-in.
var _warming_popups: bool = false
const COVER_FRAMES: int = 3


func _open_arrival_under_cover() -> void:
	if not arrival_pending or (Session.pending_level_ups.is_empty() and Session.pending_popups.is_empty()):
		return
	_warming_popups = true
	_begin_cave_arrival(true)
	await get_tree().process_frame
	if _overlay is LevelUpScreen:
		(_overlay as LevelUpScreen).reveal_all()  # its rows' first draws (new glyph sizes, icons) happen under the cover too
	for _frame: int in range(COVER_FRAMES):
		await get_tree().process_frame
	_warming_popups = false


## v0.4.2 hotfix: what the first seconds in town load on the main thread, asked for on loader threads behind the loading screen.
func _start_files_warmup() -> void:
	_files_warmup = SceneWarmup.new()
	_files_warmup.name = "SceneWarmup"
	add_child(_files_warmup)
	var characters: Array[String] = SceneWarmup.sprite_characters_under(self)
	if not characters.has("PLAYER"):
		characters.append("PLAYER")
	_files_warmup.add_sprite_characters(characters)
	_files_warmup.add_sound_events(WARM_SOUNDS)
	_files_warmup.add_ambience(["town"] as Array[String])
	var banner: String = Areas.banner_id(Areas.TOWN)
	if KeyArt.has(banner):
		_files_warmup.add_path(KeyArt.path_for(banner))  # the zone title card shown at the fade-in
	if arrival_pending:
		var story: StoryText = StoryText.shared()
		var lines: Array[String] = []
		for key: String in ["cave_mouth.maren", "cave_mouth.wanderer", "cave_mouth.maren_end"]:
			lines.append_array(story.get_lines(key))
		_files_warmup.add_portraits(["NPC-ELDER", NpcRegistry.PLAYER_ID] as Array[String], lines)
	LoadTiming.mark("town: %d files asked for on loader threads" % _files_warmup.requested())


## Overnight Oct 20: SceneManager gave up waiting for the build (BUILD_TIMEOUT, or its watchdog): whatever is left switches on so the town
## answers - processing and input back, counted as built - and the arrival (if any) starts from `_process` once the cover is gone.
func recover_after_timeout() -> void:
	GameLog.warn("town", "recovering after a load timeout (built=%s, %d of %d steps, warmup screens done=%s)" % [str(_built), _build_steps_done, BUILD_STEPS,
		str(_warmup == null or not is_instance_valid(_warmup) or _warmup.screens_done())])
	_built = true
	_warming_popups = false
	set_process(true)
	set_process_unhandled_input(true)
	if get_viewport() != null:
		get_viewport().gui_disable_input = false


func load_progress() -> float:
	return clampf(float(_build_steps_done) / float(BUILD_STEPS), 0.0, 1.0)


func _stage(label: String) -> void:
	LoadTiming.mark(label)
	_build_steps_done += 1
	if _staged_build and is_inside_tree():
		await get_tree().process_frame


func _ready() -> void:
	_staged_build = SceneManager.busy
	if _staged_build:
		set_process(false)
		set_process_unhandled_input(false)
	await _stage("town: scene loaded")
	SceneManager.pause_allowed = true
	Audio.play_music(MusicDirector.town(Session.flags))
	Audio.set_ambience("town")
	# The plaza fountain is heard from round the square (sound pass, Part C).
	add_child(AmbientEmitter.make("spot/fountain", TownLayout.PLAZA + Vector3(0.0, 1.0, 0.0), 16.0, -2.0))
	ZoneStyles.use_preset(StylePresets.TOWN)
	if not _screenshot_args.is_empty():
		if str(_screenshot_args.get("fresh", "false")) == "true":
			Session.new_game()
		else:
			Session.ensure_game()
		# Oct 16: `--gates=open` shows every road cleared (the four gatekeepers beaten), `--gates=beefcake,gourmand` some of them.
		if _screenshot_args.has("gates"):
			for gate_id: String in Gatekeepers.IDS:
				if str(_screenshot_args["gates"]) == "open" or str(_screenshot_args["gates"]).contains(gate_id):
					Session.set_flag(CorruptedNpcs.unlock_flag(gate_id))
		for found_id: String in str(_screenshot_args.get("found", "")).split(",", false):
			Session.discover_secret(found_id)
		var zone_count: int = int(_screenshot_args.get("zones", 0))
		for zone_id: String in ZoneDefs.ids().slice(0, zone_count):
			Session.complete_zone(zone_id)
		for lever_zone: String in str(_screenshot_args.get("levers", "")).split(",", false):
			Session.pull_vault_lever(lever_zone)
		if _screenshot_args.has("decks"):
			Session.new_saved_deck("Quick Aggro", ["BAS-B", "BAS-B", "BAS-B", "B-01", "B-01"] as Array[String])
			Session.new_saved_deck("Old Necro Deck", ["BAS-N", "N-28", "N-28", "N-17"] as Array[String])
			if str(_screenshot_args["decks"]) == "2":
				Session.use_deck(2)
		# Apparel Part 3: --wear=cloak_royal,hat_wizard owns and wears those pieces (wardrobe and tailor shots).
		for wear_id: String in str(_screenshot_args.get("wear", "")).split(",", false):
			var wear: CosmeticData = CosmeticCatalog.find(wear_id)
			if wear != null:
				Session.cosmetics.grant(wear_id)
				Session.cosmetics.equip(wear.slot, wear_id)
		if _screenshot_args.has("levelup"):
			Session.add_xp(ProgressionTable.xp_to_reach(int(_screenshot_args["levelup"]) - 1))
			Session.pending_level_ups.append_array(Session.add_xp(ProgressionTable.xp_to_reach(int(_screenshot_args["levelup"]))))
		if _screenshot_args.has("essence"):
			for path: Affinity.Type in Affinity.colored_types():
				Session.profile.set_essence(path, 14 if path == Affinity.Type.BEEFCAKE or path == Affinity.Type.NECROCRAT else 3)
	if Session.deck == null:
		Session.new_game()
	Session.arrive_in_town()
	_ensure_input_actions()
	add_child(WorldLook.environment(&"day"))
	add_child(WorldLook.sun(&"day"))
	await _stage("town: session + music")
	town.build(self)
	await _stage("town: TownBuilder.build")
	square = TownSquare.build(self, town, Settings.graphics_quality)
	await _stage("town: TownSquare")
	if town.hub_land and not _probe_skip.has("outskirts"):
		# Crosspath pass, Part E: the outskirts dressed with the town kit (walls, corners, field edges)
		outskirt_dressing = OutskirtDressing.build(self, town)
	await _stage("town: outskirt dressing")
	if not _probe_skip.has("birds"):
		AmbientBirds.spawn(self, square.center, 4, Color("f4ecd8"))
	_build_actors()
	if _staged_build:
		player.input_enabled = false  # `_process` hands input back once the town is built
	await _stage("town: actors")
	_build_barks()
	_build_spots()
	_build_enemies()
	_build_rift_station()
	ChestKit.apply_saved(town.hidden_chest_nodes, TownScene._hidden_chest_secret)
	GiantChestEvent.apply_look(town.harbor_chest_node, NinjaBoss.ORIGINAL_CHEST)
	_build_portal_barriers()
	if town.hub_land:
		hub_obstacles = HubObstacles.build(self, town, Session.flags)
		gate_cleared.connect(func(zone_id: String) -> void: hub_obstacles.play_cleared(zone_id))
	TownDressing.alchemist(self, town.anchors, Session.alchemist_unlocked(), StoryText.shared())
	if not town.hub_land:
		TownDressing.arena_gate(self, town.anchors, Session.arena_unlocked(), StoryText.shared())
	if _screenshot_args.has("cam"):
		var cam: PackedStringArray = str(_screenshot_args["cam"]).split(",")
		camera_offset = Vector3(float(cam[0]), float(cam[1]), float(cam[2]))
	await _stage("town: spots, enemies, obstacles")
	_build_camera()
	style_rig = StyleRig.install(self, StylePresets.TOWN, _camera, player, 0.0 if _screenshot_args.has("nocull") else 70.0)
	await _stage("town: StyleRig")
	look_rig = _install_look() if not _probe_skip.has("look") else null
	if _staged_build and look_rig != null:
		await look_rig.build_pieces_staged(_stage)
	await _stage("town: look rig")
	if _screenshot_args.has("nofog"):
		_strip_fog()
	if style_rig != null and style_rig.ambience != null:
		style_rig.ambience.focus(0.5, 1.2)
	cloud_fader = CloudFader.new()
	cloud_fader.camera = _camera
	cloud_fader.target = player
	add_child(cloud_fader)
	for cloud: Node3D in town.clouds:
		if not _probe_skip.has("clouds"):
			cloud_fader.adopt(cloud, 3.0)
	if style_rig != null:
		style_rig.register_lights(square.lights)
	var avoid: Array[Vector3] = [Vector3(square.center.x, square.center.z, square.meadow_radius)]
	if style_rig != null and not _probe_skip.has("dressing"):
		# Crosspath pass, Part B: in the hub the dressing clumps along paths, walls and field edges with open grass between (TownClutter), at about half the old count.
		if town.hub_land:
			ZoneDressing.build(self, town, StylePresets.TOWN, Settings.graphics_quality, avoid, TownClutter.region(town), 0.5)
		else:
			ZoneDressing.build(self, town, StylePresets.TOWN, Settings.graphics_quality, avoid)
		await _stage("town: ZoneDressing")
	if style_rig != null and not _probe_skip.has("painted"):
		var painted_context: Dictionary = PaintedContexts.town(self)
		LoadTiming.mark("painted: context")
		painted_world = PaintedWorld.apply(self, town, StylePresets.TOWN, painted_context)
		await _stage("town: PaintedWorld")
	_build_ui()
	_announce_new_unlocks.call_deferred()
	_show_pending_arena_result.call_deferred()
	await _stage("town: UI")
	if str(_screenshot_args.get("nohud", "false")) == "true":
		for child: Node in get_children():
			if child is CanvasLayer:
				(child as CanvasLayer).visible = false
	if _arrived_by_rift:
		_show_rift_arrival.call_deferred()
	_refresh_objective()
	EventBus.tutorial_event.emit(&"town_entered")
	# Part B: the two starter quests are given the first time the player is in town.
	Session.offer_auto_quests()
	if _screenshot_args.has("pos"):
		var pos: PackedStringArray = str(_screenshot_args["pos"]).split(",")
		player.position = Vector3(float(pos[0]), 0.0, float(pos[1]))
		_camera.position = player.position + CameraRig.shape(camera_offset)
	if _screenshot_args.has("at"):
		_teleport(str(_screenshot_args["at"]))
	if _screenshot_args.has("open"):
		_screenshot_open.call_deferred(str(_screenshot_args["open"]))
	if _screenshot_args.has("top"):
		PlanView.install(self, town, town.obstacles, town.anchors, str(_screenshot_args["top"]), str(_screenshot_args.get("plan", "false")) == "true")
	if _screenshot_args.has("windlog"):
		for line: String in PlanView.swaying(self):
			print("SWAY ", line)
	if Session.town_notice != "":
		hud.toast(Session.town_notice, UIStyle.GOLD)
		Session.town_notice = ""
	_warn_path_limit.call_deferred()
	if Session.cave_exit_pending and not _screenshot_args.has("quiet"):
		Session.cave_exit_pending = false
		# v0.4.2 hotfix: the hero is held from the first frame, so nothing (a hotkey, a popup) opens before the arrival queue runs. The queue
		# starts once the town is revealed; `_process` starts it too if `revealed` was missed.
		arrival_pending = true
		_locked = true
		if SceneManager.busy:
			SceneManager.revealed.connect(_begin_cave_arrival, CONNECT_ONE_SHOT)
		else:
			_begin_cave_arrival.call_deferred()
	if not arrival_pending:
		_results_pending = true
		# the cave arrival shows them after its own queue. Phase 2 (stability): behind a loading screen they wait for the reveal (the store
		# room ghosts' lines were typing out unseen under the cover while the town built).
		if _staged_build and SceneManager.busy:
			SceneManager.revealed.connect(_show_pending_results, CONNECT_ONE_SHOT)
		else:
			_show_pending_results.call_deferred()
	_apply_well_stir()
	if _screenshot_args.has("slots"):
		_screenshot_slots.call_deferred(str(_screenshot_args["slots"]))
	if _screenshot_args.has("ninja"):
		GiantChestEvent.screenshot_run(self, str(_screenshot_args["ninja"]), town.harbor_chest_node, _screenshot_args)
	if _staged_build and SceneManager.busy:
		SceneManager.revealed.connect(ZoneTitleCard.show_in.bind(self, Areas.TOWN, _screenshot_args.is_empty() or _screenshot_args.has("card")), CONNECT_ONE_SHOT)
	else:
		ZoneTitleCard.show_in(self, Areas.TOWN, _screenshot_args.is_empty() or _screenshot_args.has("card"))
	Session.save_game()
	# Menu paintings and the town vendors' stage pictures load on a thread a moment after arriving (Phase 2 cycle 5, performance).
	# Daytime Oct 19: the screens opened first (Sable, Tilly Tonic's item stall, the Deck Station) are built once too, after the character screen.
	# v0.4.2: added once the town is built, so those builds also happen behind the loading screen (SceneManager waits for them).
	_warmup = UiArtWarmup.make(["VS-SABLE", "VS-TONIC", "VS-BEETSWORTH", "VS-THREADWELL", "VS-FENWICK", "VS-ALEMBIC"],
		[_new_card_vendor_screen, func() -> OverlayScreen: return ItemVendorScreen.new(), func() -> OverlayScreen: return DeckbuilderScreen.new()] as Array[Callable])
	if _staged_build:
		_warmup.start_now()  # behind the loading screen, not 2 s after it lifts
	add_child(_warmup)
	if _staged_build:
		_start_files_warmup()
	LoadTiming.mark("town: _ready end")
	_built = true
	if _staged_build and is_inside_tree():
		set_process(true)
		set_process_unhandled_input(true)
		_open_arrival_under_cover()


## Story v2: an old save may hold decks that walk more Paths than the Wanderer can carry yet. They are kept (and marked not legal in the deck picker), and the player is told to fix them.
func _warn_path_limit() -> void:
	if arrival_pending or arrival_active:
		return  # the cave arrival shows it in its own turn
	var warning: String = _path_limit_warning()
	if not warning.is_empty():
		hud.toast(warning, Color("ffcf70"))


func _path_limit_warning() -> String:
	if Session.profile == null or Session.deck_box == null:
		return ""
	var limit: int = DeckValidator.max_colors(Session.profile)
	for index: int in range(Session.deck_box.size()):
		var candidate: Deck = Session.deck_box.build(index, Session.deck_lookup())
		if candidate.colors().size() > limit:
			return "A saved deck walks more Paths than you can carry yet. Fix it at the Deck Station."
	return ""

func _ensure_input_actions() -> void:
	if not InputMap.has_action(&"interact"):
		InputMap.add_action(&"interact")
		var key: InputEventKey = InputEventKey.new()
		key.physical_keycode = KEY_E
		InputMap.action_add_event(&"interact", key)


# ---- Construction -----------------------------------------------------------------------


func _build_actors() -> void:
	# New brief, Part C: coming back from a zone entrance returns the player to that same
	# entrance, not the default spawn point (see docs/design/open_questions.md D65).
	var spawn: Vector3 = town.anchors["spawn"] as Vector3 + Vector3(0, 0, -0.4)
	if not Session.pending_zone_id.is_empty():
		var portal_key: String = "portal_%s" % Session.pending_zone_id
		if town.anchors.has(portal_key):
			# The anchor already sits on the walkable, map-facing side of the gate
			# (see TownBuilder._portal_approach_offset) - safe to spawn on directly.
			spawn = town.anchors[portal_key] as Vector3
		Session.pending_zone_id = ""
	if Session.arrive_at_station:
		Session.arrive_at_station = false
		spawn = (town.anchors["rift_station"] as Vector3) + Vector3(0.0, 0.0, 1.6)
		_arrived_by_rift = true
	if Session.has_town_return_position:
		spawn = Session.town_return_position
		Session.has_town_return_position = false
	if Session.cave_exit_pending and town.anchors.has("npc_elder"):
		# Playtest v0.4.0 Part C: out of the Forgotten Cave the Wanderer stands at the north end of town, right beside Elder Maren's door.
		spawn = (town.anchors["npc_elder"] as Vector3) + Vector3(1.3, 0.0, 1.1)
	player = TownPlayer.new()
	add_child(player)
	player.setup(town, "Hero", spawn)
	player.speed_multiplier = 1.35  # the town is spread out: a brisker walk
	npc_hp = NpcHp.new()
	npc_hp.target = player
	add_child(npc_hp)
	_add_npc("vendor", "Rogue_Hooded", town.anchors["npc_market"] as Vector3, 200.0)
	_add_npc("elder", "Mage", town.anchors["npc_elder"] as Vector3, -90.0)
	if not (_npcs["elder"] is SpriteActor):
		TortoiseKit.add_shell(_npcs["elder"] as Node3D)
	_add_npc("guard", "Barbarian", town.anchors["npc_gate"] as Vector3, 160.0)
	# Oct 21: Old Hob among the graves; Isla beside her father once she is home.
	if town.anchors.has("graveyard_cairn"):
		_add_npc("hob", "Rogue", _hob_spot(), 150.0)
	if Session.flag(&"isla_home"):
		_add_npc("isla", "Rogue", _isla_spot(), 200.0)
	# Oct 21: the Rescuer waits at the cave mouth after each freed zone (StoryBeats.cave_mouth_scene), until she is taken at the castle gate.
	if not StoryBeats.cave_mouth_scene(Session.flags, Session.completed_zone_count()).is_empty() and town.anchors.has("gate"):
		_add_npc("rescuer", "Rogue_Hooded", _cave_mouth_spot(), 200.0, Color(0.62, 0.58, 0.7))
	if _secret_dealer_open():
		_add_npc("hidden_vendor", "Rogue_Hooded", town.anchors["hidden_vendor"] as Vector3, 100.0)
	# New brief, Part F: the item vendor.
	_add_npc("item_vendor", "Mage", town.anchors["npc_item_vendor"] as Vector3, -110.0)
	_add_npc("equipment_vendor", "Knight", town.anchors["npc_equipment_vendor"] as Vector3, -70.0)
	# Brief 11: Foil Fenwick, the Pack Vendor.
	_add_npc("pack_vendor", "Rogue", town.anchors["npc_pack_vendor"] as Vector3, 25.0, Color(1.0, 0.9, 0.6))
	# Brief 12, Part F: Pip Threadwell, the tailor (hero-shaped, in her own top hat and scarf-cape), and a window mannequin.
	_add_npc("tailor", "hero:tailor", town.anchors["npc_tailor"] as Vector3, -20.0)
	_add_npc("mannequin", "hero:mannequin", town.anchors["tailor_mannequin"] as Vector3, 40.0)
	if Session.alchemist_unlocked():
		_add_npc("alchemist", "Mage", town.anchors["npc_alchemist"] as Vector3, -80.0, Color(0.7, 1.0, 0.7))
	if Session.arena_unlocked() and not town.hub_land:  # Oct 16: Grand Bellows runs the ring underground now (The Undercroft)
		_add_npc("arena", "Barbarian", town.anchors["npc_arena"] as Vector3, 200.0, Color(1.0, 0.8, 0.6))
	_build_baker()
	_build_strollers()
	# New brief, Part E: the 4 corrupted NPCs stay in town, and stay challengeable, even after
	# being freed (D68) - only their dialogue changes on later visits, not their presence/look.
	for npc_id: String in CorruptedNpcs.IDS:
		_add_corrupted_npc(npc_id)
	# The Wellspring glows: a light and rising motes.
	var well: Vector3 = (town.anchors["well"] as Vector3) + Vector3(0, 0, -0.9)
	_well_light = OmniLight3D.new()
	_well_light.position = well + Vector3(0, 1.4, 0)
	_well_light.light_color = Color("7fe0ff")
	_well_light.light_energy = 1.4
	_well_light.omni_range = 4.0
	add_child(_well_light)
	_well_particles = CPUParticles3D.new()
	_well_particles.position = well + Vector3(0, 0.6, 0)
	_well_particles.amount = 26
	_well_particles.lifetime = 2.6
	_well_particles.direction = Vector3.UP
	_well_particles.spread = 25.0
	_well_particles.initial_velocity_min = 0.35
	_well_particles.initial_velocity_max = 0.8
	_well_particles.gravity = Vector3.ZERO
	_well_particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	_well_particles.emission_sphere_radius = 0.35
	var mote: SphereMesh = SphereMesh.new()
	mote.radius = 0.035
	mote.height = 0.07
	var mote_material: StandardMaterial3D = StandardMaterial3D.new()
	mote_material.albedo_color = Color("aef0ff")
	mote_material.emission_enabled = true
	mote_material.emission = Color("7fe0ff")
	mote_material.emission_energy_multiplier = 3.0
	mote_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mote.material = mote_material
	_well_particles.mesh = mote
	add_child(_well_particles)
	_build_graveyard_mist()


func _add_npc(id: String, model_name: String, position: Vector3, yaw: float, tint: Color = Color.WHITE) -> void:
	var npc: Node3D
	var sprite_id: String = str(NPC_SPRITES.get(id, ""))
	if id == "rescuer":
		sprite_id = NpcSprites.rescuer_key()  # Apparel Part 4: the disguise until she is named
	if sprite_id == "":
		sprite_id = NpcSprites.character_for(str(NPC_IDS.get(id, "")))
	if sprite_id != "" and SpriteLibrary.has_character(sprite_id):
		var actor: SpriteActor = SpriteActor.new()
		actor.character = sprite_id
		actor.follow_cosmetics = false
		actor.natural_scale = TownPlayer.MODEL_SCALE
		actor.turn_rate_degrees = 420.0
		actor.name = "Sprite_%s" % id
		npc = actor
	else:
		npc = HeroModel.build(HeroModel.npc_look(model_name.substr(5))) if model_name.begins_with("hero:") else ModelKit.character(model_name)
		if tint != Color.WHITE:
			ModelKit.tint(npc, tint)
	ModelKit.place(self, npc, position, yaw, TownPlayer.MODEL_SCALE)
	var animation: AnimationPlayer = ModelKit.animation_player(npc)
	if animation != null and animation.has_animation("Idle"):
		animation.play("Idle")
		animation.seek(randf() * 1.5)
	_npcs[id] = npc
	if npc_hp != null and id != "mannequin":
		npc_hp.register(npc, yaw)
	town.obstacles.append(Vector3(position.x, position.z, 0.3))


## Playtest v0.4.0 Part A: floating name labels as screen UI - vendors ("Sable - Cards") and quest givers always, everyone else when the hero
## is close - and a glow at the feet of vendors (gold) and quest givers (green). The black-market dealer keeps no label and no glow.
var npc_labels: NpcLabels
const QUEST_SPOT_IDS: Array[String] = ["elder", "guard", "npc_beefcake", "npc_gourmand", "npc_refusemancer", "npc_necrocrat", "rescuer"]


func _labels() -> NpcLabels:
	if npc_labels == null:
		npc_labels = NpcLabels.install(self, player, _camera, func() -> bool: return _locked or (dialogue != null and dialogue.active))
		npc_labels.boost = func(key: String) -> bool: return quest_markers != null and quest_markers.is_marked(key)
	return npc_labels


func _label_spot(id: String, title: String, marker: Node3D) -> void:
	if id == "hidden_vendor" or not is_instance_valid(marker):
		return
	var npc_id: String = str(NPC_IDS.get(id, ""))
	var kind: String = NpcLabels.kind_for(npc_id) if not npc_id.is_empty() else "npc"
	if id in QUEST_SPOT_IDS:
		kind = "quest"
	elif id in ["vendor", "item_vendor", "equipment_vendor", "pack_vendor", "tailor", "alchemist"]:
		kind = "vendor"
	if kind.is_empty():
		return
	var text: String = NpcLabels.text_for(npc_id, title) if not npc_id.is_empty() else title
	if kind == "vendor" and not text.contains(" - "):
		text = "%s - %s" % [title, {"vendor": "Cards", "item_vendor": "Items", "equipment_vendor": "Gear", "pack_vendor": "Packs", "tailor": "Clothes", "alchemist": "Alchemy"}.get(id, "Shop")]
	_labels().register(marker, text, kind, kind != "npc", 0.3, id)
	if kind != "npc" and _npcs.has(id):
		NpcGlow.attach(_npcs[id] as Node3D, NpcGlow.VENDOR if kind == "vendor" else NpcGlow.QUEST)


## The badger baker: a townsperson who wanders the plaza (the World Look Test bench builds its own and overrides this).
## Overnight Oct 17, Part 11: the town's NPCs say a line when the hero walks past (`NpcBarks`, lines from data/npcs/npcs.json).
var npc_barks: NpcBarks


func _build_barks() -> void:
	npc_barks = NpcBarks.new()
	add_child(npc_barks)
	npc_barks.target = player
	npc_barks.blocked = func() -> bool: return _locked or (dialogue != null and dialogue.active)
	for key: Variant in _npcs.keys():
		if NPC_IDS.has(key):
			npc_barks.register(_npcs[key] as Node3D, str(NPC_IDS[key]))
	if _baker != null and _baker.sprite != null:
		npc_barks.register(_baker.sprite, "NPC-VILLAGER")
		_labels().register(_baker.sprite, NpcRegistry.find("NPC-VILLAGER").short_name() if NpcRegistry.has("NPC-VILLAGER") else "Baker", "npc", false, _baker.sprite.head_height() + 0.3)
	for stroller: SpriteWanderer in _strollers:
		npc_barks.register(stroller.sprite, "NPC-TOWNSFOLK")
		_labels().register(stroller.sprite, "Townsfolk", "npc", false, stroller.sprite.head_height() + 0.3)
	# Overnight Oct 17, Part 14: dandelion fluff drifting over the town, and footstep puffs.
	AmbientFx.add(self, "town", player)


## Overnight Oct 17 (Phase 2, NPC life): townsfolk stroll their own small loops away from the busy square - round the Old Well's yard
## and up by Elder Maren's lane - in the shared townsfolk sprite set with their own tints, and say a line to a passing hero.
const STROLLERS: Array[Dictionary] = [
	{"anchor": "well", "radius": 3.4, "seed": 23, "tint": 2},
	{"anchor": "npc_elder", "radius": 3.8, "seed": 41, "tint": 4},
	# Phase 2 cycle 23: one more by the Arena gate (the rift station's loop crossed an unwalkable edge, so it has none)
	{"anchor": "arena_gate", "radius": 3.6, "seed": 57, "tint": 1},
]
var _strollers: Array[SpriteWanderer] = []


func _build_strollers() -> void:
	# Playtest v0.4.0 Part B: the blonde white-suit CITIZEN is Primm's perfect citizen and only walks the Capital; Crosspath's
	# strollers are plain villagers in different coats.
	for spec: Dictionary in STROLLERS:
		if not town.anchors.has(str(spec["anchor"])) or not SpriteLibrary.has_character("VILLAGER"):
			continue
		var stroller: SpriteWanderer = SpriteWanderer.new()
		stroller.character = "VILLAGER"
		stroller.name = "Stroller%d" % (_strollers.size() + 1)
		stroller.seed_value = int(spec["seed"])
		stroller.ring_radius = float(spec["radius"])
		stroller.tint = NpcSprites.CITIZEN_TINTS[int(spec["tint"]) % NpcSprites.CITIZEN_TINTS.size()]
		add_child(stroller)
		stroller.setup(town, town.anchors[str(spec["anchor"])] as Vector3, null, Vector3.ZERO)
		if stroller.sprite == null:
			stroller.queue_free()
			continue
		_strollers.append(stroller)


func _build_baker() -> void:
	_baker = SpriteWanderer.new()
	_baker.character = "VILLAGER"
	_baker.name = "Baker"
	add_child(_baker)
	_baker.setup(town, square.center, null, Vector3.ZERO)


## New brief, Part E: the 4 corrupted NPCs - a dark, element-tinted character plus a slow,
## element-colored particle drift (corruption made visible), distinct from the Wellspring's
## bright rising motes.
const CORRUPTED_NPC_MODELS: Dictionary = {
	"beefcake": "Barbarian", "gourmand": "Mage", "refusemancer": "Rogue", "necrocrat": "Rogue_Hooded",
}


func _add_corrupted_npc(id: String) -> void:
	var position: Vector3 = town.anchors["npc_%s" % id] as Vector3
	# A plain multiply-tint reads as "muddy" over these characters' own brown/tan textures at
	# normal brightness, so this leans bright+saturated rather than dark - it needs to win against
	# the base texture, not just shade it (confirmed by eye, not guessed - see D69).
	var tint: Color = UIStyle.affinity_color(CorruptedNpcs.element(id)).lightened(0.25) * 1.4
	_add_npc("npc_%s" % id, str(CORRUPTED_NPC_MODELS.get(id, "Rogue")), position, randf() * 360.0, tint)
	var particles: CPUParticles3D = CPUParticles3D.new()
	particles.position = position + Vector3(0, 0.9, 0)
	particles.amount = 14
	particles.lifetime = 2.2
	particles.direction = Vector3.UP
	particles.spread = 40.0
	particles.initial_velocity_min = 0.2
	particles.initial_velocity_max = 0.5
	particles.gravity = Vector3(0, 0.15, 0)
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.4
	var mote: SphereMesh = SphereMesh.new()
	mote.radius = 0.03
	mote.height = 0.06
	var material: StandardMaterial3D = StandardMaterial3D.new()
	var glow: Color = UIStyle.affinity_color(CorruptedNpcs.element(id))
	material.albedo_color = glow
	material.emission_enabled = true
	material.emission = glow
	material.emission_energy_multiplier = 2.2
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mote.material = material
	particles.mesh = mote
	add_child(particles)


## Fourth brief, Part F: ground-hugging grey mist over the Graveyard - the same slow-particle-
## drift technique as the corrupted NPCs' visible corruption (D69), just low, wide, grey and
## horizontal instead of rising and element-colored. As close as this scene's single
## WorldEnvironment can get to "darker lighting" confined to one small area without a full
## per-zone environment switch (out of scope here) - see docs/design/open_questions.md.
func _build_graveyard_mist() -> void:
	var center: Vector3 = (town.anchors.get("graveyard_cairn", Vector3.ZERO) as Vector3) + Vector3(0, -0.65, 0)
	var particles: CPUParticles3D = CPUParticles3D.new()
	particles.position = center
	particles.amount = 22
	particles.lifetime = 4.5
	particles.direction = Vector3(1, 0, 0)
	particles.spread = 180.0
	particles.initial_velocity_min = 0.08
	particles.initial_velocity_max = 0.22
	particles.gravity = Vector3.ZERO
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(1.6, 0.15, 1.6)
	var wisp: SphereMesh = SphereMesh.new()
	wisp.radius = 0.35
	wisp.height = 0.15
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.72, 0.74, 0.78, 0.22)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	wisp.material = material
	particles.mesh = wisp
	add_child(particles)


func _build_spots() -> void:
	_add_spot("well", "The Old Well", town.anchors["well"] as Vector3, 1.7)
	_add_spot("well_door", "The Iron Hatch", (town.anchors["well"] as Vector3) + Vector3(-2.2, 0.0, 0.6), 1.3)
	_build_vault_hatch()
	_add_spot("vendor", "Card Vendor", town.anchors["npc_market"] as Vector3, 1.5)
	_add_spot("deck", "Deck Station", town.anchors["deck"] as Vector3, 1.6)
	_add_spot("gate", "The Forgotten Cave", town.anchors["gate"] as Vector3, 1.7)
	if _npcs.has("hob"):
		_add_spot("hob", "Old Hob", _hob_spot(), 1.4)
	if _npcs.has("isla"):
		_add_spot("isla", "Isla Brannoch", _isla_spot(), 1.4)
	if _npcs.has("rescuer"):
		_add_spot("rescuer", RoyalFamily.fill("{rescuer}"), _cave_mouth_spot(), 1.5)
	_add_spot("elder", "Elder Maren", town.anchors["npc_elder"] as Vector3, 1.4)
	_add_spot("notice_board", "Notice Board", town.anchors["notice_board"] as Vector3, 1.7)
	for sign_index: int in range(square.streets.signpost_positions.size()):
		_add_spot("signpost_%d" % sign_index, "Signpost", town.anchors["signpost_%d" % sign_index] as Vector3, 1.5)
	_add_spot("guard", "Gatekeeper Brannoch", town.anchors["npc_gate"] as Vector3, 1.4)
	_add_spot("codex", "Hall of Records", town.anchors["codex"] as Vector3, 1.6)
	_add_spot("chest", "A Hidden Chest", town.anchors["chest"] as Vector3, 1.3)
	_add_spot("lever", "An Old Lever", town.anchors["lever"] as Vector3, 1.2)
	_add_spot("vault", "The Sealed Vault", town.anchors["vault"] as Vector3, 1.8)
	_add_spot("vault4", "The Four-Seal Vault", town.anchors["vault4"] as Vector3, 2.2)
	four_seal_vault = FourSealVault.build(self, town.anchors["vault4_mouth"] as Vector3)
	# Fourth brief, Part F: The Restless Cairn - the Graveyard's scripted-battle trigger. Unlike
	# the hidden chests, this one DOES get the normal marker/name-plate treatment (a Spot) - it's
	# meant to be found, not stumbled on; the challenge is the fight, not finding it.
	_add_spot("graveyard_cairn", "The Restless Cairn", town.anchors["graveyard_cairn"] as Vector3, 1.6)
	if _secret_dealer_open():
		_add_spot("hidden_vendor", "A Secret Dealer", town.anchors["hidden_vendor"] as Vector3, 1.5)
	# New brief, Part F: the item vendor.
	_add_spot("item_vendor", "Tilly Tonic's Supplies", town.anchors["npc_item_vendor"] as Vector3, 1.5)
	# Oct 20, Part 4: the haunted store room's door, the corner house beside Tilly's shop (Maren's ghost errand starts its fight here).
	_add_spot(StoreroomGhosts.SPOT_ID, "Tilly's Store Room", town.anchors[StoreroomGhosts.SPOT_ID] as Vector3, 1.5)
	# Fourth brief, Part C: the equipment vendor.
	_add_spot("equipment_vendor", "Assistant to the Regional Merchant", town.anchors["npc_equipment_vendor"] as Vector3, 1.5)
	_add_spot("pack_vendor", StoryText.shared().text("town.pack_vendor.name"), town.anchors["npc_pack_vendor"] as Vector3, 1.5)
	_add_spot("tailor", StoryText.shared().text("town.tailor.name"), town.anchors["npc_tailor"] as Vector3, 1.5)
	if _baker != null:
		_add_spot("baker", "Brindle the Baker", _baker.world_position(), 1.4)
	# Brief 9, Part F: the Alchemist (locked until two zones are free; visible and closed before that).
	_add_spot("alchemist", StoryText.shared().text("town.alchemist.name"), town.anchors["alchemist"] as Vector3, 1.7)
	# Brief 9, Part G: the Grand Clashatorium (chained until the first zone is free).
	_add_spot("arena", StoryText.shared().text("town.arena.name"), town.anchors["arena"] as Vector3, 1.9)
	# New brief (third), Part E: the debug-only Dev Shrine - only constructed at all (so only ever
	# present as an anchor here) when DevTools.shrine_enabled() said yes at builder time.
	if town.anchors.has("dev_shrine"):
		_add_spot("dev_shrine", "Dev Shrine", town.anchors["dev_shrine"] as Vector3, 1.6)
	# New brief, Part E: the 4 corrupted NPCs.
	for npc_id: String in CorruptedNpcs.IDS:
		_add_spot("npc_%s" % npc_id, CorruptedNpcs.display_name(npc_id), town.anchors["npc_%s" % npc_id] as Vector3, 1.5)
	# Part G: 5 placeholder zone portals (one per element, one for the final area), now at the
	# edges of the (bigger) map - see ZonePortals/ZonePlaceholderScene. Real zones are not built
	# this pass. New brief, Part C/E: the 4 element entrances start locked (see
	# _portal_is_locked); the final entrance is always open.
	for info: ZonePortals.Info in ZonePortals.all():
		_add_spot("portal_%s" % info.id, info.display_name if ZoneDefs.has_def(info.id) else "%s (coming soon)" % info.display_name, town.anchors["portal_%s" % info.id] as Vector3, 3.4)


## New brief, Part E sets this flag (via CorruptedNpcs.unlock_flag, the single source of truth)
## on defeating the matching corrupted NPC; the final entrance has no NPC and is never locked.
static func _portal_unlock_flag(zone_id: String) -> StringName:
	return CorruptedNpcs.unlock_flag(zone_id)


func _portal_is_locked(zone_id: String) -> bool:
	return zone_id != ZonePortals.FINAL_ID and not Session.flag(_portal_unlock_flag(zone_id))


## A translucent, element-tinted barrier in front of each still-locked entrance - built once from
## a flag snapshot at scene load (unlocking always happens in a different scene, via a battle, so
## it never needs to change live mid-visit).
func _build_portal_barriers() -> void:
	for info: ZonePortals.Info in ZonePortals.all():
		var passage: Node3D = town.passage_nodes.get(info.id) as Node3D
		if not _portal_is_locked(info.id):
			continue
		var mouth: Vector3 = town.anchors.get("portal_%s_mouth" % info.id, Vector3.ZERO) as Vector3
		var out: Vector3 = TownBuilder.PORTAL_OUT.get(info.id, Vector3(0, 0, -1)) as Vector3
		if town.hub_land and Gatekeepers.has(info.id):
			# Oct 16: the road is blocked by its own obstacle (HubObstacles: the bridge, the barrier, the pantry door, the thorns), not a glowing pane.
			town.obstacles.append(Vector3(mouth.x, mouth.z, 1.55))
			continue
		var barrier: MeshInstance3D = MeshInstance3D.new()
		barrier.name = "Barrier_%s" % info.id
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = Vector3(TownPassages.OPENING * 2.0 + 0.3, 2.6, 0.12)
		barrier.mesh = mesh
		barrier.position = mouth - out * 1.7 + Vector3(0, 1.3, 0)
		barrier.rotation_degrees.y = TownPassages.yaw_for(out)
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color(info.tint.r, info.tint.g, info.tint.b, 0.32)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.emission_enabled = true
		material.emission = info.tint
		material.emission_energy_multiplier = 0.9
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		barrier.material_override = material
		barrier.set_meta(StyleToon.META_NO_TOON, true)
		add_child(barrier)
		# solid: the hero cannot walk through a sealed passage
		town.obstacles.append(Vector3(mouth.x, mouth.z, 1.55))
		var glow: Node = passage.find_child("FarGlow", true, false) if passage != null else null
		if glow != null:
			((glow as MeshInstance3D).material_override as StandardMaterial3D).albedo_color.a = 0.1


## Shows the name of the nearest passageway's destination (and nothing else) once the hero is within a dozen metres of its mouth.
func _update_passage_label() -> void:
	var nearest: float = 1e9
	var title: String = ""
	for info: ZonePortals.Info in ZonePortals.all():
		var mouth: Vector3 = town.anchors.get("portal_%s_mouth" % info.id, Vector3.ZERO) as Vector3
		var distance: float = Vector2(player.position.x - mouth.x, player.position.z - mouth.z).length()
		if distance < nearest:
			nearest = distance
			title = info.display_name
	var wanted: float = 0.0 if (_locked or dialogue.active) else clampf((13.0 - nearest) / 3.0, 0.0, 1.0)
	if wanted > 0.0 and _passage_label.text != title:
		_passage_label.text = title
	_passage_label.modulate.a = lerpf(_passage_label.modulate.a, wanted, 0.2)


## 1.0 normally; up to 1.12 within a few metres of a road's end (Oct 16: a slight, brief pull-back instead of the old far zoom-out).
func _passage_boost_target() -> float:
	if _locked or dialogue.active or player.airborne:
		return 1.0
	var nearest: float = 1e9
	_passage_dir_target = Vector3.ZERO
	for info: ZonePortals.Info in ZonePortals.all():
		var mouth: Vector3 = town.anchors.get("portal_%s_mouth" % info.id, Vector3.ZERO) as Vector3
		var distance: float = Vector2(player.position.x - mouth.x, player.position.z - mouth.z).length()
		if distance < nearest:
			nearest = distance
			_passage_dir_target = TownBuilder.PORTAL_OUT.get(info.id, Vector3.ZERO) as Vector3
	var t: float = clampf((PASSAGE_ZOOM_FAR - nearest) / (PASSAGE_ZOOM_FAR - PASSAGE_ZOOM_NEAR), 0.0, 1.0)
	return 1.0 + PASSAGE_ZOOM_MAX * smoothstep(0.0, 1.0, t)


## Walking down a passageway takes it: an open one changes scene (the same call the E prompt makes), a sealed one stops the hero and says why.
func _check_portal_walk(delta: float) -> void:
	_portal_toast_cooldown = maxf(0.0, _portal_toast_cooldown - delta)
	if _locked or dialogue.active or player.airborne:
		return
	for info: ZonePortals.Info in ZonePortals.all():
		var mouth: Vector3 = town.anchors.get("portal_%s_mouth" % info.id, Vector3.ZERO) as Vector3
		var distance: float = Vector2(player.position.x - mouth.x, player.position.z - mouth.z).length()
		if _portal_is_locked(info.id):
			if distance < 2.3 and _portal_toast_cooldown <= 0.0:
				_portal_toast_cooldown = 3.5
				_use_zone_portal(info.id)
		elif distance < TownBuilder.PORTAL_TRIGGER:
			_use_zone_portal(info.id)
			return


func _add_spot(id: String, title: String, position: Vector3, radius: float) -> void:
	var spot: Spot = Spot.new()
	spot.id = id
	spot.title = title
	spot.position = position
	spot.radius = radius
	# The golden floating gems were removed (they read as clutter): a plain anchor holds the name plate; unnamed spots get an empty plate.
	spot.named = _spot_is_named(id)
	var sprite_label: float = NpcSprites.label_height(_npcs.get(id) as Node, 0.0)
	spot.label_height = sprite_label
	var marker: Node3D = Node3D.new()
	marker.position = position + Vector3(0, sprite_label if sprite_label > 0.0 else (1.9 if id in NPC_SPOT_IDS else 2.5), 0)
	add_child(marker)
	spot.marker = marker
	var plate: Label3D = Label3D.new()
	# Playtest v0.4.0 Part A: names are screen UI now (`NpcLabels`), never lettering in the world; the plate stays as an empty anchor.
	plate.text = ""
	plate.visible = false
	if _spot_has_plate(id):
		_label_spot.call_deferred(id, title, marker)
	plate.font = UIStyle.font_title()
	plate.font_size = 46
	plate.pixel_size = 0.0055
	plate.outline_size = 14
	plate.outline_modulate = Color(0.08, 0.05, 0.12, 0.95)
	plate.modulate = UIStyle.PARCHMENT
	plate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	plate.no_depth_test = true
	plate.position = marker.position + Vector3(0, 0.42, 0)
	add_child(plate)
	spot.plate = plate
	spots.append(spot)


## The world look of this scene (the World Look Test builds its own copy of the pieces and returns null here).
func _install_look() -> WorldLookRig:
	if style_rig == null:
		return null
	return WorldLookRig.install(self, _camera, player, style_rig, town, not _staged_build)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.fov = 38.0
	add_child(_camera)
	_camera.current = true
	_camera.position = player.position + CameraRig.shape(camera_offset)
	_camera.look_at(player.position + Vector3(0, 0.4, 0), Vector3.UP)


func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var host: Control = UIKit.layer_host(layer)
	var vignette: ColorRect = UIKit.vignette(0.55)
	host.add_child(vignette)
	hud = TownHud.new()
	host.add_child(hud)
	hud.character_pressed.connect(_open_character_screen)
	hud.deck_pressed.connect(_open_deck_builder_anywhere)
	hud.quests_pressed.connect(_open_quest_log)
	hud.wardrobe_pressed.connect(_open_wardrobe)
	hud.packs_pressed.connect(_open_packs)
	EventBus.quest_notice.connect(_on_quest_notice)
	dialogue = DialogueBox.new()
	host.add_child(dialogue)
	dialogue.stand_behind(hud)
	_passage_label = UIKit.label("", &"TitleLabel", 54, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_passage_label.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.1, 0.95))
	_passage_label.add_theme_constant_override("outline_size", 12)
	_passage_label.position = Vector2(360, 96)
	_passage_label.size = Vector2(1200, 80)
	_passage_label.modulate.a = 0.0
	_passage_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(_passage_label)
	minimap = MinimapHud.new()
	host.add_child(minimap)
	minimap.setup("town", town, player, _collect_pois)
	minimap.full_map_requested.connect(_open_full_map)
	quest_markers = QuestMarkerLayer.install(self, "town", _camera, _resolve_quest_spot, host)
	var overlay_canvas: CanvasLayer = CanvasLayer.new()
	overlay_canvas.layer = 8
	add_child(overlay_canvas)
	_overlay_layer = UIKit.layer_host(overlay_canvas)


# ---- Frame update -----------------------------------------------------------------------


## The Graveyard has its own theme: walking into its corner of town lays it over the town music, walking out hands back (with a margin so the edge does not flutter).
func _update_music(delta: float) -> void:
	_music_timer -= delta
	if _music_timer > 0.0 or player == null or town == null:
		return
	_music_timer = 0.4
	var cairn: Vector3 = town.anchors.get("graveyard_cairn", Vector3.ZERO) as Vector3
	var distance: float = Vector2(player.position.x - cairn.x, player.position.z - cairn.z).length()
	if _graveyard_music == 0 and distance < GRAVEYARD_MUSIC_RADIUS:
		_graveyard_music = Audio.push_music(StringName(MusicDirector.graveyard()), 1.2, false)
	elif _graveyard_music != 0 and distance > GRAVEYARD_MUSIC_RADIUS + 3.0:
		Audio.pop_music(_graveyard_music, 1.2)
		_graveyard_music = 0


func _exit_tree() -> void:
	if arrival_active:
		print("arrival: interrupted by a scene change at step %d of %d" % [_arrival_index, _arrival_steps.size()])
		arrival_active = false
	if _graveyard_music != 0:
		Audio.pop_music(_graveyard_music, 0.8)
		_graveyard_music = 0


func _process(delta: float) -> void:
	_time += delta
	# Overnight Oct 20: the arrival start and the lock watchdog come first, so an error further down can never stop them.
	if arrival_pending and not arrival_active and not SceneManager.busy:
		_begin_cave_arrival()
	_watch_lock(delta)
	if town.undercroft != null:
		town.undercroft.update(player.position, delta)
	_update_music(delta)
	_update_sprite_npcs(delta)
	_passage_boost = lerpf(_passage_boost, _passage_boost_target(), 1.0 - exp(-3.0 * delta))
	_update_passage_label()
	_passage_dir = _passage_dir.lerp(_passage_dir_target, 1.0 - exp(-1.8 * delta))
	var look_ahead: Vector3 = _passage_dir * 12.0 * (_passage_boost - 1.0)
	var target: Vector3 = player.position + look_ahead + CameraRig.shape(camera_offset) * _passage_boost * _battle_push
	_camera.position = _camera.position.lerp(target, 1.0 - exp(-5.0 * delta))
	_camera.basis = Basis.looking_at(-camera_offset, Vector3.UP)
	for spot: Spot in spots:
		var base_y: float = spot.label_height if spot.label_height > 0.0 else (1.9 if spot.id in NPC_SPOT_IDS else 2.5)
		spot.marker.position.y = base_y + sin(_time * 2.4 + spot.position.x) * 0.08
		spot.marker.rotation_degrees.y += 60.0 * delta
		var distance: float = Vector2(player.position.x - spot.position.x, player.position.z - spot.position.z).length()
		var fade_start: float = 14.0 if spot.id.begins_with("portal_") else 2.6
		spot.plate.modulate.a = clampf(1.0 - (distance - fade_start) / 1.6, 0.0, 1.0)
		if spot.id.begins_with("portal_"):
			spot.plate.pixel_size = 0.0075
		spot.plate.outline_modulate.a = spot.plate.modulate.a
		spot.plate.visible = spot.plate.modulate.a > 0.02
	_well_light.light_energy = (1.4 + sin(_time * 1.7) * 0.35) * _well_stir
	_update_nearest()
	_update_hidden_chest_prompt()
	_check_portal_walk(delta)
	player.input_enabled = not _locked and not dialogue.active
	var roamers_active: bool = not _locked and not dialogue.active and _overlay == null
	for enemy: ZoneEnemy in enemies:
		enemy.active = roamers_active
	if arrival_pending or arrival_active:
		return
	if _results_pending:
		# Fixes Oct 27, Part 1: the fight's own result (a gatekeeper's lines) comes first, then its card pick (a missed reveal starts them here).
		_results_wait += delta
		if _results_wait > 4.0 and not SceneManager.busy:
			_show_pending_results()
		return
	if not _locked and not dialogue.active and not Session.pending_popups.is_empty():
		_show_reward_box(Session.pending_popups.pop_front() as RewardSummary)
	elif not _locked and not dialogue.active and not Session.pending_level_ups.is_empty():
		var gained: Array[LevelData] = Session.pending_level_ups.duplicate()
		Session.pending_level_ups.clear()
		_show_level_up(gained)


func _update_nearest() -> void:
	if _locked or dialogue.active:
		hud.hide_prompt()
		_near = null
		return
	var best: Spot = null
	var best_distance: float = 1e9
	for spot: Spot in spots:
		var distance: float = Vector2(player.position.x - spot.position.x, player.position.z - spot.position.z).length()
		if distance <= spot.radius * StorybookScale.INTERACT_FACTOR and distance < best_distance:
			best = spot
			best_distance = distance
	if best != _near:
		_near = best
		if best != null:
			Audio.sfx(&"ui_tick", -10.0)
	if _near == null:
		hud.hide_prompt()
	else:
		hud.show_prompt("[E]  %s" % _prompt_text(_near))


## New brief, Part D: hidden chests have no marker to draw the player's eye from a distance - the
## interact prompt is the ONLY tell, and only within HIDDEN_CHEST_RADIUS (~1.5m).
func _update_hidden_chest_prompt() -> void:
	if _locked or dialogue.active:
		_hidden_chest_near = ""
		return
	var found: String = ""
	for id: String in TownBuilder.HIDDEN_CHEST_CELLS.keys():
		if Session.found_secret(_hidden_chest_secret(id)):
			continue
		var anchor: Vector3 = town.anchors.get("hidden_chest_%s" % id, Vector3.ZERO) as Vector3
		var distance: float = Vector2(player.position.x - anchor.x, player.position.z - anchor.z).length()
		if distance <= HIDDEN_CHEST_RADIUS:
			found = id
			break
	if found != _hidden_chest_near:
		_hidden_chest_near = found
		if found != "":
			Audio.sfx(&"ui_tick", -10.0)
	if found != "":
		hud.show_prompt("[E]  Open the chest")


static func _hidden_chest_secret(id: String) -> String:
	return "hidden_chest_%s" % id



func _prompt_text(spot: Spot) -> String:
	if spot.id in NPC_SPOT_IDS:
		return "Talk"
	match spot.id:
		"well_door":
			return "Open the iron hatch" if Session.side_unlocked("S-TOWN") else "Try the iron hatch"
		"well":
			return OldWellStory.shared().text("prompt.well.ready") if Session.old_well_stage() == OldWellQuest.Stage.READY else "Touch the Old Well"
		"deck":
			return "Open the Deck Station"
		"gate":
			return "Enter the Forgotten Cave"
		"codex":
			return "Browse the Codex"
		"notice_board":
			return "Read the notice board (quests)"
		"chest":
			return "Open the chest"
		"lever":
			return "Pull the lever"
		"dev_shrine":
			return "Pray at the Dev Shrine (+1 level)"
		"vault":
			return "Open the vault" if Session.flag(VAULT_LEVER_FLAG) else "Try the sealed door"
		"vault4":
			return "Open the Four-Seal Vault" if Session.vault_unlocked() and not Session.vault_defeated() else "Examine the vault door"
		"graveyard_cairn":
			return "Disturb the cairn"
		"rift_station":
			return StoryText.shared().text("travel.prompt")
		"alchemist":
			return "Browse Auntie Alembic's" if Session.alchemist_unlocked() else "Knock (the shop is closed)"
		"arena":
			if town.hub_land:
				return "Climb down the cellar hatch" if Session.arena_unlocked() else "The cellar hatch is chained shut"
			return "Enter the Undercroft" if Session.arena_unlocked() else "The gates are chained shut"
	if spot.id.begins_with("signpost_"):
		return "Read the signpost"
	if spot.id.begins_with("portal_"):
		var zone_id: String = spot.id.trim_prefix("portal_")
		return "Sealed - the corrupted guardian must fall first" if _portal_is_locked(zone_id) else "Enter"
	return spot.title


func _unhandled_input(event: InputEvent) -> void:
	# Controller support (Oct 26): a pad press meant for a focused menu control (the HUD menu) is not also a world action
	if UiInput.pad_focus_busy(event, self):
		return
	# The character screen (Part E) and the deck builder (new brief, Part B) are global
	# shortcuts, not tied to a nearby spot - usable anywhere in town, not just at the station.
	if not _locked and not dialogue.active and UiInput.is_fresh_press(event):
		# Controller support (Oct 26): D-pad Up opens the HUD menu with its first entry focused
		if event.is_action_pressed(&"open_menu"):
			get_viewport().set_input_as_handled()
			hud.open_menu_focused()
			return
		if event.is_action_pressed(&"open_character"):
			get_viewport().set_input_as_handled()
			_open_character_screen()
			return
		if event.is_action_pressed(&"open_deck"):
			get_viewport().set_input_as_handled()
			_open_deck_builder_anywhere()
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
	if not _locked and not dialogue.active and _hidden_chest_near != "":
		if event.is_action_pressed(&"interact"):
			get_viewport().set_input_as_handled()
			_open_hidden_chest(_hidden_chest_near)
			return
	if _locked or dialogue.active or _near == null:
		return
	if event.is_action_pressed(&"interact"):
		get_viewport().set_input_as_handled()
		_interact(_near)
		return
	if event is InputEventMouseButton:
		var click: InputEventMouseButton = event as InputEventMouseButton
		if click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
			if _screen_pos_of(_near).distance_to(click.position) <= CLICK_PICK_RADIUS:
				get_viewport().set_input_as_handled()
				_interact(_near)


## Where `spot`'s marker currently projects to on screen, for click picking.
func _screen_pos_of(spot: Spot) -> Vector2:
	return _camera.unproject_position(spot.marker.position)


# ---- Interactions -----------------------------------------------------------------------


func _interact(spot: Spot) -> void:
	Audio.sfx(&"ui_select")
	if spot.id.begins_with("signpost_"):
		_read_signpost(int(spot.id.trim_prefix("signpost_")))
		return
	match spot.id:
		"well":
			_use_well()
		"well_door":
			_use_well_door()
		"vendor":
			_talk_vendor()
		"deck":
			_open_deck_station()
		"gate":
			_use_gate()
		"rescuer":
			_talk_rescuer()
		"hob":
			_face_npc("hob")
			StoryScenePlayer.play(dialogue, OldHob.town_scene(Session.flags))
		"isla":
			_face_npc("isla")
			StoryScenePlayer.play(dialogue, "isla_talk")
		"elder":
			_talk_elder()
		"guard":
			_talk_guard()
		"codex":
			_open_codex()
		"notice_board":
			_open_quest_log()
		"chest":
			_open_chest()
		"lever":
			_pull_lever()
		"dev_shrine":
			_use_dev_shrine()
		"vault":
			_open_vault()
		"vault4":
			_open_four_seal_vault()
		"hidden_vendor":
			_talk_hidden_vendor()
		"item_vendor":
			_talk_item_vendor()
		"storeroom":  # StoreroomGhosts.SPOT_ID
			_use_storeroom()
		"equipment_vendor":
			_talk_equipment_vendor()
		"baker":
			_talk_baker()
		"tailor":
			_talk_tailor()
		"pack_vendor":
			_talk_pack_vendor()
		"graveyard_cairn":
			_talk_graveyard()
		"arena":
			_use_arena()
		"rift_station":
			_use_rift_station()
		"alchemist":
			_use_alchemist()
		_:
			if spot.id.begins_with("portal_"):
				_use_zone_portal(spot.id.trim_prefix("portal_"))
			elif spot.id.begins_with("npc_") and spot.id.trim_prefix("npc_") in CorruptedNpcs.IDS:
				_talk_corrupted_npc(spot.id.trim_prefix("npc_"))


func _face_npc(id: String) -> void:
	_talking_id = id
	var npc: Node3D = _npcs.get(id) as Node3D
	if npc != null:
		var offset: Vector3 = player.position - npc.position
		npc.rotation.y = atan2(offset.x, offset.z)
	player.face((npc.position if npc != null else player.position))


## Oct 21: Old Hob, leaning on his shovel a few steps from the Restless Cairn.
func _hob_spot() -> Vector3:
	return (town.anchors["graveyard_cairn"] as Vector3) + Vector3(-2.4, 0.0, 1.6)


## Oct 21: Isla stands at her father's open gate once she is home.
func _isla_spot() -> Vector3:
	return (town.anchors["npc_gate"] as Vector3) + Vector3(1.6, 0.0, 0.8)


func _isla_arrives() -> void:
	if _npcs.has("isla"):
		return
	_add_npc("isla", "Rogue", _isla_spot(), 200.0)
	_add_spot("isla", "Isla Brannoch", _isla_spot(), 1.4)


## Oct 21: where the Rescuer waits, a little to the side of the cave mouth so the cave's own prompt stays reachable.
func _cave_mouth_spot() -> Vector3:
	return (town.anchors["gate"] as Vector3) + Vector3(2.2, 0.0, 1.2)


## The Cave Mouth scene that is waiting (one per freed zone, warmer each time); afterwards she slips away into the cave.
func _talk_rescuer() -> void:
	var scene: String = StoryBeats.cave_mouth_scene(Session.flags, Session.completed_zone_count())
	_face_npc("rescuer")
	if scene.is_empty():
		_rescuer_leaves_town()
		return
	_locked = true
	StoryScenePlayer.play(dialogue, scene, func() -> void:
		_locked = false
		_rescuer_leaves_town())


func _rescuer_leaves_town() -> void:
	for spot: Spot in spots.duplicate():
		if spot.id == "rescuer":
			if is_instance_valid(spot.marker):
				_labels().unregister(spot.marker)
				spot.marker.queue_free()
			if is_instance_valid(spot.plate):
				spot.plate.queue_free()
			spots.erase(spot)
	var npc: Node3D = _npcs.get("rescuer") as Node3D
	_npcs.erase("rescuer")
	if not is_instance_valid(npc):
		return
	var fade: Tween = create_tween().set_parallel(true)
	fade.tween_property(npc, "position", npc.position + Vector3(-1.4, 0.0, -1.2), 1.4)
	for node: Node in npc.find_children("*", "GeometryInstance3D", true, false):
		fade.tween_property(node, "transparency", 1.0, 1.2)
	fade.finished.connect(npc.queue_free)


## Elder Maren: memory fragments first, then hand-ins (an errand of the early-game chain hands straight over to the next one in the same
## talk: `CHAIN_NEXT`), then the chain's next errand, then her other offers once she has greeted the hero, then a reminder of what she
## asked for, else her greeting and mood lines.
func _talk_elder() -> void:
	var elder: String = QuestDefinitions.MAREN
	# Oct 21: news of the capture at the castle gate comes first (the story note for saves already past it, too).
	var news: String = StoryBeats.maren_scene(Session.flags)
	if not news.is_empty() and Session.flag(&"elder_greeted"):
		_face_npc("elder")
		StoryScenePlayer.play(dialogue, news)
		return
	var pending_memory: int = Session.pending_memory()
	if pending_memory > 0 and Session.flag(&"elder_greeted"):
		_play_memory(pending_memory)
		return
	var ready: Array[QuestData] = Session.quests_ready_for(elder)
	if not ready.is_empty():
		var finished_quest: QuestData = ready[0]
		var lines: Array[String] = DungeonCatalog.text_lines("quest.%s.ready" % finished_quest.id)
		var next_id: String = str(CHAIN_NEXT.get(finished_quest.id, ""))
		if not next_id.is_empty() and not Session.quest_log.is_active(next_id) and not Session.quest_log.is_completed(next_id):
			lines.append_array(_chain_offer_lines(next_id))
		_talk_npc("elder", elder, lines)
		dialogue.finished.connect(func() -> void:
			Session.turn_in_quest(finished_quest.id)
			if not next_id.is_empty():
				Session.start_quest(next_id), CONNECT_ONE_SHOT)
		return
	# Fixes Oct 25, Part 8: the armory quest done, Maren sends the hero to their own Path's zone first (its vendor, its buff, the rival's
	# debuff) and that zone's line becomes the tracked quest.
	if Session.profile != null and PathDirection.due(Session.quest_log, Session.flags, Session.profile.primary_affinity):
		_talk_npc("elder", elder, PathDirection.lines(Session.profile.primary_affinity))
		dialogue.finished.connect(Session.take_path_direction, CONNECT_ONE_SHOT)
		return
	var offered: Array[QuestData] = Session.quests_offered_by(elder)
	var chain_offer: Array[QuestData] = []
	for quest: QuestData in offered:
		if CHAIN_NEXT.values().has(quest.id):
			chain_offer.append(quest)
	if chain_offer.is_empty() and not Session.flag(&"elder_greeted"):
		offered = [] as Array[QuestData]
	if not chain_offer.is_empty() or not offered.is_empty():
		var offer: QuestData = chain_offer[0] if not chain_offer.is_empty() else offered[0]
		var offer_lines: Array[String] = [] as Array[String] if not chain_offer.is_empty() else _elder_lines()
		offer_lines.append_array(_chain_offer_lines(offer.id))
		_talk_npc("elder", elder, offer_lines)
		dialogue.finished.connect(func() -> void: Session.start_quest(offer.id), CONNECT_ONE_SHOT)
		return
	for quest_id: String in Session.quest_log.active:
		var active_quest: QuestData = QuestCatalog.find(quest_id)
		if active_quest != null and active_quest.giver_npc == elder and not DungeonCatalog.text_lines("quest.%s.active" % quest_id).is_empty():
			var active_key: String = "quest.%s.active" % quest_id
			if quest_id == QuestDefinitions.FIRST_DECK_EDIT and Session.pack_step_open():
				active_key = "quest.first_deck_edit.active_pack"
			_talk_npc("elder", elder, DungeonCatalog.text_lines(active_key) as Array[String])
			return
	_talk_npc("elder", elder, _elder_lines())


## Maren's offer of a chain errand. Fixes Oct 25, Part 6: Make It Yours opens with a pack - with none in the bag she hands one over
## (`Session.grant_first_pack` gives it when the quest starts).
func _chain_offer_lines(quest_id: String) -> Array[String]:
	var lines: Array[String] = []
	lines.append_array(DungeonCatalog.text_lines("quest.%s.offer" % quest_id))
	if quest_id == QuestDefinitions.FIRST_DECK_EDIT and Session.profile != null and Session.profile.total_packs() == 0 and not Session.flag(StringName(QuestDefinitions.FIRST_PACK_FLAG)):
		lines.append_array(DungeonCatalog.text_lines("quest.first_deck_edit.offer_pack"))
	return lines


## Oct 20, Part 4: the early-game chain - handing one errand back to Maren gives the next in the same conversation.
const CHAIN_NEXT: Dictionary = {
	QuestDefinitions.MERCHANTS: QuestDefinitions.FIRST_DECK_EDIT,
	QuestDefinitions.FIRST_DECK_EDIT: QuestDefinitions.GHOSTS,
	QuestDefinitions.GHOSTS: QuestDefinitions.ARMORY,
}


# ---- The haunted store room (Oct 20, Part 4) ----------------------------------------------------------------------

## The store room door beside Tilly Tonic's shop: before Maren's errand it only rattles; during it, the ghosts have their say and the
## duel starts at the door (the room is never walked into); once cleared it is just shelves.
func _use_storeroom() -> void:
	var story: StoryText = StoryText.shared()
	player.face(town.anchors[StoreroomGhosts.SPOT_ID] as Vector3)
	if Session.flag(StoreroomGhosts.FLAG_CLEARED):
		dialogue.start("", story.get_lines("storeroom.cleared"), NpcRegistry.PLAYER_ID)
		return
	if not Session.quest_log.is_active(QuestDefinitions.GHOSTS):
		dialogue.start("", story.get_lines("storeroom.locked"), NpcRegistry.PLAYER_ID)
		return
	_locked = true
	Audio.sfx(&"enemy_alert")
	dialogue.start(StoreroomGhosts.ENEMY_NAME, story.get_lines("storeroom.before"))
	dialogue.finished.connect(func() -> void:
		dialogue.start("", story.get_lines("storeroom.wanderer"), NpcRegistry.PLAYER_ID)
		dialogue.finished.connect(func() -> void:
			dialogue.start(StoreroomGhosts.ENEMY_NAME, story.get_lines("storeroom.challenge"))
			dialogue.finished.connect(func() -> void:
				_locked = false
				Session.start_storeroom_battle(), CONNECT_ONE_SHOT), CONNECT_ONE_SHOT), CONNECT_ONE_SHOT)


## Back from the store room fight: the ghosts' parting words (a win) or their gloating (a loss), then the usual rewards toast.
func _show_storeroom_result() -> void:
	if Session.pending_storeroom_result.is_empty():
		return
	var result: Dictionary = Session.pending_storeroom_result
	Session.pending_storeroom_result = {}
	var won: bool = bool(result.get("won", false))
	dialogue.start(StoreroomGhosts.ENEMY_NAME, StoryText.shared().get_lines("storeroom.after_win" if won else "storeroom.after_loss"))
	if not won:
		return
	var levels_gained: Array[LevelData] = []
	for level_data: Variant in (result.get("levels_gained", []) as Array):
		levels_gained.append(level_data as LevelData)
	dialogue.finished.connect(func() -> void:
		hud.toast("The store room is clear. +%d gold, +%d XP." % [int(result.get("gold", 0)), int(result.get("xp", 0))], UIStyle.GOLD)
		Session.pending_level_ups.append_array(levels_gained), CONNECT_ONE_SHOT)


func _talk_npc(id: String, speaker: String, lines: Array[String]) -> void:
	_face_npc(id)
	dialogue.start(speaker, lines)
	EventBus.tutorial_event.emit(StringName("talked_" + id))


# ---- Crosspath outskirts roamers (Playtest v0.4.0, Part D) ------------------------------------------------------

## The three easy roaming enemies on the lanes round the edge of town (`TownEnemies`): touching one starts a duel; a beaten one is
## away for a while and comes back. They sleep while a dialogue, a menu or a cutscene is up.
var enemies: Array[ZoneEnemy] = []
var _enemy_map: TownEnemyMap


func _build_enemies() -> void:
	if _screenshot_args.has("noroamers") or not town.hub_land:
		return
	_enemy_map = TownEnemyMap.wrap(town)
	for spawn: Dictionary in _enemy_map.enemy_spawns():
		var instance_id: String = str(spawn["id"])
		if Session.town_roamer_is_down(instance_id):
			continue
		var home: Vector3 = spawn["home"] as Vector3
		if not _enemy_map.is_enemy_walkable(home, 0.25):
			home = _nearest_roamer_ground(home)
		var enemy: ZoneEnemy = ZoneEnemy.new()
		add_child(enemy)
		enemy.setup(TownEnemies.info(str(spawn["type"])), instance_id, home, float(spawn["patrol"]), _enemy_map, player)
		enemy.cooldown = 2.0
		enemy.touched.connect(_on_roamer_touched)
		enemies.append(enemy)


## The quest markers' spot lookup: the town's spots, plus `QuestDefinitions.OUTSKIRTS_SPOT` (Fixes Oct 25, Part 4).
func _resolve_quest_spot(spot_id: String) -> Dictionary:
	if spot_id == QuestDefinitions.OUTSKIRTS_SPOT:
		return _outskirts_spot()
	return QuestMarkerLayer.resolve_in(spots, spot_id)


## Where the armory quest's "win one fight" step points: the home of the outskirts roamer nearest Beetsworth's smithy (a fixed point on the
## lanes, so the marker does not chase a walking enemy). {} when the town has no roamers.
func _outskirts_spot() -> Dictionary:
	if _enemy_map == null:
		return {}
	var smithy: Dictionary = QuestMarkerLayer.resolve_in(spots, "equipment_vendor")
	var from: Vector3 = smithy["pos"] as Vector3 if not smithy.is_empty() else Vector3.ZERO
	var best: Vector3 = Vector3.INF
	for spawn: Dictionary in _enemy_map.enemy_spawns():
		var home: Vector3 = spawn["home"] as Vector3
		if best == Vector3.INF or home.distance_squared_to(from) < best.distance_squared_to(from):
			best = home
	if best == Vector3.INF:
		return {}
	return {"pos": best, "top": 1.6}


## The closest patch of outskirts ground to `home` (a spawn point that landed on a prop after a layout change).
func _nearest_roamer_ground(home: Vector3) -> Vector3:
	for ring: int in range(1, 12):
		for step: int in range(12):
			var angle: float = TAU * float(step) / 12.0
			var candidate: Vector3 = home + Vector3(cos(angle), 0.0, sin(angle)) * float(ring) * 0.6
			if _enemy_map.is_enemy_walkable(candidate, 0.25):
				return candidate
	return home


func _on_roamer_touched(enemy: ZoneEnemy) -> void:
	if _locked or dialogue.active or _overlay != null:
		return
	_locked = true
	for other: ZoneEnemy in enemies:
		other.active = false
	player.face(enemy.position)
	var rule_names: String = EncounterModifiers.names_line(EncounterModifiers.zone_key(TownEnemies.ZONE_KEY, enemy.info.id))
	hud.toast("%s wants a word...%s" % [enemy.info.display_name, ("  [%s]" % rule_names) if not rule_names.is_empty() else ""], Color("ff8a85"))
	Audio.sfx(&"enemy_alert")
	Session.start_town_battle(enemy.info.id, enemy.instance_id)


## After an outskirts duel: what it paid (and a level-up), or a shrug on a loss.
func _show_town_result() -> void:
	if Session.pending_town_result.is_empty():
		return
	var result: Dictionary = Session.pending_town_result
	Session.pending_town_result = {}
	if bool(result.get("won", false)):
		hud.toast("Won! +%d gold, +%d XP." % [int(result.get("gold", 0)), int(result.get("xp", 0))], UIStyle.GOLD)
		var levels_gained: Array[LevelData] = []
		for level_data: Variant in (result.get("levels_gained", []) as Array):
			levels_gained.append(level_data as LevelData)
		if not levels_gained.is_empty():
			Session.pending_level_ups.append_array(levels_gained)
	else:
		hud.toast("The %s got the better of you. Catch your breath; the town heals." % str(result.get("enemy", "roamer")), Color("ffcf70"))


# ---- Out of the Forgotten Cave (Playtest v0.4.0, Part C) ----------------------------------------------------------

## The first steps into Crosspath: the Wanderer stands beside Elder Maren at the north end of town with the town in view, and her
## welcome (the old cave-mouth conversation) opens at once. Sets `maren_met` so her door's own greeting follows when talked to.
## v0.4.2 hotfix: everything the arrival shows runs as ONE queue of steps (ARRIVAL_ORDER), each opening once the previous one has closed:
## reward boxes (a finished quest), level-ups, the Path warning, then Maren's welcome in three parts. The hero is held until the queue
## ends; a step whose UI never opens or never reports back is caught by the lock watchdog (`_watch_lock`), which ends the queue.
## Started on `SceneManager.revealed` (or by `_process` once the scene manager is idle, if that signal was missed); runs once.
## Overnight Oct 20: level-ups first, then reward boxes and quest notices, the Path warning, Maren's welcome (the stability brief's order).
const ARRIVAL_ORDER: Array[String] = ["level_ups", "rewards", "path_warning", "welcome_maren", "welcome_wanderer", "welcome_maren_end"]
var arrival_pending: bool = false
var arrival_active: bool = false
## The steps shown so far, in order (tests and the game log): "rewards", "level_ups", "path_warning", "welcome_maren"...
var arrival_log: Array[String] = []
var _arrival_steps: Array[String] = []
var _arrival_index: int = 0
## Each step's done callback carries the step's token, so a late or repeated report from an older step is ignored.
var _arrival_token: int = 0
var _arrival_started_msec: int = 0


func _begin_cave_arrival(under_cover: bool = false) -> void:
	if arrival_active or not arrival_pending or dialogue == null or not is_inside_tree() or not _built or (SceneManager.busy and not under_cover):
		return  # `revealed` or `_process` starts it once the town is built and shown
	arrival_pending = false
	arrival_active = true
	_locked = true
	_arrival_started_msec = Time.get_ticks_msec()
	_arrival_steps = ARRIVAL_ORDER.duplicate()
	_arrival_index = -1
	arrival_log.clear()
	_next_arrival_step()


func _next_arrival_step() -> void:
	if not arrival_active or not is_inside_tree():
		return
	_arrival_index += 1
	_arrival_token += 1
	if _arrival_index >= _arrival_steps.size():
		_finish_cave_arrival()
		return
	_locked = true
	var step: String = _arrival_steps[_arrival_index]
	if _run_arrival_step(step, _arrival_step_done.bind(_arrival_token)):
		arrival_log.append(step)
	else:
		_next_arrival_step()  # nothing to show for this step


## Opens what `step` shows and returns true, or returns false when there is nothing to show. `done` is called once it has closed.
func _run_arrival_step(step: String, done: Callable) -> bool:
	var story: StoryText = StoryText.shared()
	match step:
		"rewards":
			if Session.pending_popups.is_empty():
				return false
			var popup: RewardPopup = _show_reward_box(Session.pending_popups.pop_front() as RewardSummary)
			if not Session.pending_popups.is_empty():
				_arrival_steps.insert(_arrival_index + 1, "rewards")  # one box at a time
			popup.finished.connect(done, CONNECT_ONE_SHOT)
			return true
		"level_ups":
			if Session.pending_level_ups.is_empty():
				return false
			var gained: Array[LevelData] = Session.pending_level_ups.duplicate()
			Session.pending_level_ups.clear()
			var screen: LevelUpScreen = _show_level_up(gained)
			screen.finished.connect(done, CONNECT_ONE_SHOT)
			return true
		"path_warning":
			var warning: String = _path_limit_warning()
			if warning.is_empty():
				return false
			hud.toast(warning, Color("ffcf70"))  # a toast, not a modal: it stays up beside the welcome
			done.call_deferred()
			return true
		"welcome_maren":
			return _arrival_dialogue("Elder Maren", story.get_lines("cave_mouth.maren"), "NPC-ELDER", done)
		"welcome_wanderer":
			return _arrival_dialogue("", story.get_lines("cave_mouth.wanderer"), NpcRegistry.PLAYER_ID, done)
		"welcome_maren_end":
			return _arrival_dialogue("Elder Maren", story.get_lines("cave_mouth.maren_end"), "NPC-ELDER", done)
	return false


func _arrival_dialogue(speaker: String, lines: Array[String], npc_id: String, done: Callable) -> bool:
	if lines.is_empty():
		return false
	_face_npc("elder")
	dialogue.start(speaker, lines, npc_id)
	# Own lambdas: Godot sees `done` callables that differ only in their bound token as one and the same connection.
	dialogue.finished.connect(func() -> void: done.call(), CONNECT_ONE_SHOT)
	# Another conversation replacing this one (it never should during the arrival) still moves the queue on.
	dialogue.interrupted.connect(func() -> void: done.call(), CONNECT_ONE_SHOT)
	return true


func _arrival_step_done(token: int) -> void:
	if not arrival_active or token != _arrival_token:
		return
	_next_arrival_step.call_deferred()  # after the closing screen's own handlers (`_close_overlay`) have run


## Fixes Oct 27, Part 1: true from the town's first frame until the fight's result lines have started, so a reward box (a gatekeeper's card
## pick) never opens before them and ends up under their dialogue.
var _results_pending: bool = false
var _results_wait: float = 0.0
var _results_shown: bool = false


## What a fight left to say on the way back to town (each a no-op when there is nothing).
func _show_pending_results() -> void:
	if _results_shown:
		return  # once per visit (the watchdog in _process and a late reveal must not play them twice)
	_results_shown = true
	_results_pending = false
	_show_town_result()
	_show_storeroom_result()
	_show_npc_result()
	_show_graveyard_result()
	_show_ninja_result()
	_show_vault_result()
	_show_old_well_result()
	if _npcs.has("rescuer"):
		hud.toast("Someone is waiting at the mouth of the Forgotten Cave.", UIStyle.GOLD)
	elif Session.flag(&"primm_defeated") and StoryScenes.should_play("isla_homecoming", Session.flags):
		hud.toast("Someone is walking down the Capital road toward Brannoch's gate.", UIStyle.GOLD)


func _finish_cave_arrival() -> void:
	arrival_active = false
	arrival_pending = false
	_locked = false
	_lock_idle = 0.0
	Session.set_flag(&"maren_met")
	Session.save_game()
	_show_pending_results.call_deferred()
	print("arrival: Crosspath after the cave - %s (%.1f s)" % [" -> ".join(arrival_log), float(Time.get_ticks_msec() - _arrival_started_msec) / 1000.0])


## v0.4.2 hotfix: the hero must never stay locked with nothing on screen to close. After LOCK_WATCHDOG_SECONDS locked with no modal UI open
## (no dialogue, overlay, confirm box, rules card, scene change, pause or scripted scene), the hero is freed and a warning goes to the log.
func _watch_lock(delta: float) -> void:
	if not _locked or _modal_ui_open():
		_lock_idle = 0.0
		return
	_lock_idle += delta
	if _lock_idle < LOCK_WATCHDOG_SECONDS:
		return
	lock_watchdog_trips += 1
	GameLog.warn("lock", "TownScene: the hero was locked for %.0f s with no dialogue or screen open (arrival step %s); unlocking" % [_lock_idle, _arrival_steps[_arrival_index] if arrival_active and _arrival_index >= 0 and _arrival_index < _arrival_steps.size() else "-"])
	_lock_idle = 0.0
	if arrival_active:
		_finish_cave_arrival()
	_locked = false


## True while something on screen holds the hero for a reason the player can see (and close).
func _modal_ui_open() -> bool:
	if (dialogue != null and dialogue.active) or (_overlay != null and is_instance_valid(_overlay)) or _scripted_lock:
		return true
	if SceneManager.busy or get_tree().paused:
		return true
	if _overlay_layer != null and _overlay_layer.get_child_count() > 0:
		return true
	for child: Node in get_children():
		if child is CanvasLayer:
			for inner: Node in child.get_children():
				if (inner is RulesBrief or inner is ConfirmDialog or inner is OverlayScreen) and (inner as Control).visible:
					return true
	return false


## New brief, Part E: shown once, right after returning from a corrupted-NPC battle - the
## post-fight dialogue (freed/calmer on a win, short on a loss - see docs/design/open_questions.md
## D68) and, on a first win only, a reward toast. Session.pending_npc_result is {} otherwise (town
## reached any other way), so this is a no-op almost all the time.
func _show_npc_result() -> void:
	if Session.pending_npc_result.is_empty():
		return
	var result: Dictionary = Session.pending_npc_result
	Session.pending_npc_result = {}
	var id: String = str(result.get("id", ""))
	if not (id in CorruptedNpcs.IDS):
		return
	var won: bool = bool(result.get("won", false))
	var story: StoryText = load(STORY_PATH) as StoryText
	var lines: Array[String] = [] as Array[String]
	if story != null:
		lines = story.npc_victory_lines(id) if won else story.npc_defeat_lines(id)
	if bool(result.get("first_win", false)) and Gatekeepers.has(id):
		# Oct 16: the gatekeeper clears the obstacle on the road (the bridge lowers, the barrier rises, the door swings open, the thorns wither).
		lines.append_array(StoryText.shared().get_lines("gate.%s.cleared" % id))
		gate_cleared.emit(id)
	_face_npc("npc_%s" % id)
	dialogue.start(Gatekeepers.full_title(id), lines)
	if bool(result.get("first_win", false)):
		var reward_text: String = "+%d gold, +%d XP" % [CorruptedNpcs.reward_gold(), CorruptedNpcs.reward_xp()]
		var item_name: String = str(result.get("item_name", ""))
		if not item_name.is_empty():
			reward_text += ", %s" % item_name
		var levels_gained: Array[LevelData] = []
		for level_data: Variant in (result.get("levels_gained", []) as Array):
			levels_gained.append(level_data as LevelData)
		# New brief, Part A: same level-up popup regardless of source - a corrupted NPC's first
		# win can grant levels just like a dungeon battle can.
		dialogue.finished.connect(func() -> void:
			hud.toast(reward_text, UIStyle.GOLD)
			# Fixes Oct 27, Part 1: queued, not opened here - opening it closed the card pick box that was up (the pick was lost); the
			# frame update shows the pick first, then the level-up.
			Session.pending_level_ups.append_array(levels_gained), CONNECT_ONE_SHOT)


## New brief, Part E: talking to a corrupted NPC always plays a short line (corrupted/hinting at
## their zone before they're freed, calmer/still hinting after) and then starts the fight - win or
## lose, they can always be challenged again (D68); only a first win pays out.
## Overnight Oct 23, Part 3 (boss entrances): a short push-in on the hero facing the foe, then `action` (the fight starts; the battle
## board then plays the foe's entrance).
func camera_push_then(action: Callable) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "_battle_push", 0.55, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func() -> void:
		action.call()
		_battle_push = 1.0)


func _talk_corrupted_npc(id: String) -> void:
	_face_npc("npc_%s" % id)
	var story: StoryText = load(STORY_PATH) as StoryText
	var defeated: bool = Session.flag(CorruptedNpcs.unlock_flag(id))
	var lines: Array[String] = [] as Array[String]
	if story != null:
		lines = story.npc_victory_lines(id) if defeated else story.npc_intro_lines(id)
		if defeated and Session.is_zone_completed(id):
			lines = story.npc_freed_lines(id)  # overnight Oct 19: their zone is free, and they say so
	dialogue.start(Gatekeepers.full_title(id), lines)
	dialogue.finished.connect(func() -> void: camera_push_then(Session.challenge_corrupted_npc.bind(id)), CONNECT_ONE_SHOT)


## Fourth brief, Part F: The Restless Cairn - talking to it always plays a short line ("placeholder
## dialogue before"), then starts the scripted battle. Win or lose, it can always be challenged
## again (same repeatable-but-unrewarded-past-the-first-win choice as the corrupted NPCs, D68);
## only a first win pays out.
func _talk_graveyard() -> void:
	var story: StoryText = load(STORY_PATH) as StoryText
	var lines: Array[String] = StoryText._filled(story.graveyard_intro_lines) if story != null else [] as Array[String]  # tokens filled (the Cairn showed a raw {villain})
	dialogue.start("The Restless Cairn", lines)
	dialogue.finished.connect(func() -> void: camera_push_then(Session.challenge_graveyard_boss), CONNECT_ONE_SHOT)


## Shown once, right after returning from a Graveyard battle ("placeholder dialogue... after") -
## mirrors _show_npc_result exactly, including the reward toast/level-up popup on a first win.
func _show_graveyard_result() -> void:
	if Session.pending_graveyard_result.is_empty():
		return
	var result: Dictionary = Session.pending_graveyard_result
	Session.pending_graveyard_result = {}
	var won: bool = bool(result.get("won", false))
	var story: StoryText = load(STORY_PATH) as StoryText
	var lines: Array[String] = [] as Array[String]
	if story != null:
		lines = StoryText._filled(story.graveyard_victory_lines if won else story.graveyard_defeat_lines)
	dialogue.start("The Restless Cairn", lines)
	if bool(result.get("first_win", false)):
		var reward_text: String = "+%d gold, +%d XP" % [GraveyardBoss.REWARD_GOLD, GraveyardBoss.REWARD_XP]
		var equipment_name: String = str(result.get("equipment_name", ""))
		if not equipment_name.is_empty():
			reward_text += ", %s" % equipment_name
		var levels_gained: Array[LevelData] = []
		for level_data: Variant in (result.get("levels_gained", []) as Array):
			levels_gained.append(level_data as LevelData)
		dialogue.finished.connect(func() -> void:
			hud.toast(reward_text, UIStyle.GOLD)
			# Fixes Oct 27, Part 1: queued, not opened here - opening it closed the card pick box that was up (the pick was lost); the
			# frame update shows the pick first, then the level-up.
			Session.pending_level_ups.append_array(levels_gained), CONNECT_ONE_SHOT)


## Elder Maren and a memory fragment: she asks what came back, the screen dims and the fragment plays, then she answers. Fragment 1 also announces the second Path;
## fragment 4 reveals who the Wanderer is (`Session.recover_memory`).
func _play_memory(number: int) -> void:
	# Maren's story theme underlies her lines; the fragment itself has its own cue (`MemoryScreen`, MUS-MEM-0N) on top of it.
	var maren_music: int = Audio.push_music(&"MUS-MAREN", 1.2, false)
	var story: StoryText = StoryText.shared()
	var known: bool = number == MemoryDefs.COUNT and Session.flag(MemoryDefs.FLAG_REVEALED)
	_face_npc("elder")
	_locked = true
	dialogue.start("Elder Maren", story.get_lines(MemoryDefs.key(number, "intro_known" if known else "intro")), "NPC-ELDER")
	dialogue.finished.connect(func() -> void:
		var screen: MemoryScreen = MemoryScreen.make(number, story.text(MemoryDefs.key(number, "title")), story.get_lines(MemoryDefs.key(number, "fragment")))
		_overlay_layer.add_child(screen)
		screen.finished.connect(func() -> void:
			Session.recover_memory(number)
			hud.toast("Fragment %d of %d recovered." % [number, MemoryDefs.COUNT], UIStyle.GOLD)
			dialogue.start("Elder Maren", story.get_lines(MemoryDefs.key(number, "after_known" if known else "after")), "NPC-ELDER")
			dialogue.finished.connect(func() -> void: _after_memory(number, known, maren_music), CONNECT_ONE_SHOT), CONNECT_ONE_SHOT), CONNECT_ONE_SHOT)


func _after_memory(number: int, known: bool, maren_music: int) -> void:
	var story: StoryText = StoryText.shared()
	if number == MemoryDefs.COUNT and not known:
		dialogue.start("", story.get_lines("memory.4.reply"), NpcRegistry.PLAYER_ID)
		dialogue.finished.connect(func() -> void:
			dialogue.start("Elder Maren", story.get_lines("memory.4.after2"), "NPC-ELDER")
			dialogue.finished.connect(func() -> void:
				_locked = false
				Audio.pop_music(maren_music, 1.5), CONNECT_ONE_SHOT), CONNECT_ONE_SHOT)
		return
	Audio.pop_music(maren_music, 1.5)
	if number == 1:
		var popup: AnnouncementScreen = AnnouncementScreen.make(story.text("memory.1.announce_title"), story.text("memory.1.announce_body"), story.get_lines("memory.1.announce_line"), UIStyle.GOLD)
		_overlay_layer.add_child(popup)
		popup.finished.connect(func() -> void:
			popup.queue_free()
			_locked = false)
		return
	_locked = false


const ELDER_STATE_COUNTER: String = "elder_heard_state"
const ELDER_IDLE_COUNTER: String = "elder_idle_line"


func _elder_lines() -> Array[String]:
	var story: StoryText = StoryText.shared()
	if not Session.flag(&"elder_greeted"):
		Session.set_flag(&"elder_greeted")
		return story.get_lines("town.elder.first")
	if Session.flag(&"primm_defeated"):
		return story.get_lines("town.elder.postgame")
	# Maren's mood follows the number of memory fragments recovered (guarded, warmer, resistance, her past, the prince).
	var recovered: int = Session.memories_recovered()
	if Session.flag(MemoryDefs.FLAG_REVEALED) and recovered < MemoryDefs.COUNT:
		return story.get_lines("town.elder.known_early")
	var freed: int = Session.completed_zone_count()
	# Overnight Oct 19: her whole speech (progress, mood, reminder) plays once per change of state (zones freed, memory stage); a return visit
	# with nothing new gets one short line from `town.elder.idle`, in turn.
	var state: int = 1 + freed * 10 + MemoryDefs.stage(recovered)
	if Session.counter(ELDER_STATE_COUNTER) == state and story.has_text("town.elder.idle"):
		# Overnight Oct 22, Part 2: the short greeting reacts to progress (`town.elder.idle.<zones freed>`), still one line in turn.
		var idle_key: String = "town.elder.idle.%d" % mini(freed, 4)
		var idle: Array[String] = story.get_lines(idle_key if freed > 0 and story.has_text(idle_key) else "town.elder.idle")
		var pick: int = Session.counter(ELDER_IDLE_COUNTER) % idle.size()
		Session.bump_counter(ELDER_IDLE_COUNTER)
		return [idle[pick]] as Array[String]
	Session.counters[ELDER_STATE_COUNTER] = state
	var lines: Array[String] = []
	if freed > 0:
		lines.append_array(story.get_lines("town.elder.progress.%d" % mini(freed, 4)))
	lines.append_array(story.get_lines("town.elder.stage.%d" % MemoryDefs.stage(recovered)))
	if freed == 0:
		lines.append_array(story.get_lines("town.elder.return"))
	return lines


func _guard_lines() -> Array[String]:
	return StoryText.shared().get_lines("town.guard")


## Overnight Oct 16: Gatekeeper Brannoch stands on the imperial road and gives the Capital's main quest, "Free the Four Zones": the four
## broken services, their debuffs, and that freeing each zone lifts one. Afterwards he reminds, then cheers once all four are free.
func _talk_guard() -> void:
	var speaker: String = QuestDefinitions.BRANNOCH
	var story: StoryText = StoryText.shared()
	# Oct 21: once the Capital is free, his daughter walks home through the open gate (once); afterwards he talks about her.
	if Session.flag(&"primm_defeated") and StoryScenes.should_play("isla_homecoming", Session.flags):
		_face_npc("guard")
		_locked = true
		StoryScenePlayer.play(dialogue, "isla_homecoming", func() -> void:
			_locked = false
			_isla_arrives())
		return
	if Session.flag(&"isla_home") and Session.quests_offered_by(speaker).is_empty() and not Session.quest_log.is_active(QuestDefinitions.FREE_ZONES):
		_face_npc("guard")
		StoryScenePlayer.play(dialogue, "brannoch_isla")
		return
	if not Session.quests_offered_by(speaker).is_empty():
		var offer: QuestData = Session.quests_offered_by(speaker)[0]
		_talk_npc("guard", speaker, story.get_lines("town.guard.capital_offer"))
		dialogue.finished.connect(func() -> void: Session.start_quest(offer.id), CONNECT_ONE_SHOT)
		return
	if Session.quest_log.is_active(QuestDefinitions.FREE_ZONES):
		var key: String = "town.guard.capital_done" if ZoneCompletion.count(Session.flags) >= ZoneCompletion.TOTAL_ZONES else "town.guard.capital_active"
		_talk_npc("guard", speaker, story.get_lines(key))
		return
	_talk_npc("guard", speaker, _guard_lines())


func _talk_vendor() -> void:
	_face_npc("vendor")
	var lines: Array[String] = StoryText.shared().get_lines("town.vendor.return")
	if not Session.flag(&"vendor_seen"):
		Session.set_flag(&"vendor_seen")
		lines = StoryText.shared().get_lines("town.vendor.first")
	dialogue.start("Sable", lines)
	dialogue.finished.connect(_open_vendor, CONNECT_ONE_SHOT)


## The iron hatch beside the old well: the way down to the Forgotten Vault (S-TOWN), once Elder Maren's quest has found the key.
func _use_well_door() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.side_for_zone("town")
	if plan == null:
		return
	if not Session.side_unlocked(plan.id):
		hud.toast("The hatch is locked tight. The Elder might know why.", Color("ffcf70"))
		Audio.sfx(&"ui_error")
		return
	if not Session.any_deck_valid():
		hud.toast("Your deck is not ready for the vault.", Color("ff8a85"))
		Audio.sfx(&"ui_error")
		return
	_locked = true
	var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, plan.dungeon_name, "%s

You are fully healed on entry. Lose a duel and you are carried back to town." % plan.story, "Descend", "Not yet")
	dialog.confirmed.connect(func() -> void:
		DeckPicker.guard(_overlay_layer, func() -> void:
			Audio.sfx(&"dungeon_enter")
			Session.enter_town_side_dungeon(), func() -> void: _locked = false))
	dialog.cancelled.connect(func() -> void: _locked = false)


## A low iron hatch with a gold rim next to the well (visual only; the spot above does the work).
func _build_vault_hatch() -> void:
	var center: Vector3 = (town.anchors["well"] as Vector3) + Vector3(-2.2, 0.04, 0.6)
	var plate: MeshInstance3D = MeshInstance3D.new()
	var disc: CylinderMesh = CylinderMesh.new()
	disc.top_radius = 0.75
	disc.bottom_radius = 0.75
	disc.height = 0.1
	plate.mesh = disc
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color("3b3a44")
	iron.roughness = 0.8
	plate.material_override = iron
	plate.position = center
	add_child(plate)
	var rim: MeshInstance3D = MeshInstance3D.new()
	var ring: TorusMesh = TorusMesh.new()
	ring.inner_radius = 0.72
	ring.outer_radius = 0.82
	rim.mesh = ring
	var gold: StandardMaterial3D = StandardMaterial3D.new()
	gold.albedo_color = Color("c9a227")
	gold.metallic = 0.4
	gold.roughness = 0.5
	rim.material_override = gold
	rim.position = center + Vector3(0.0, 0.03, 0.0)
	add_child(rim)


## The Wellspring choice used to happen here; the player now picks their element in the starting
## area instead (`ElementChoiceScreen`, Part C), so the well is a lore/flavor spot: it always
## recognizes the color the player already carries. See docs/design/open_questions.md D30.
## Overnight Oct 19-20, Part 6: it is also the Old Well secret quest (`OldWellQuest`): once a Path zone is free the first touch plays the vision
## and starts the hidden quest; while it runs the well whispers where the two hums are; with both found it opens the duel against the
## Wellspring's Echo; afterwards it only hums. The iron hatch beside it (the Forgotten Vault) is a separate spot and is unchanged.
func _use_well() -> void:
	var color: Affinity.Type = Session.profile.primary_affinity
	_well_burst(color)
	player.face(town.anchors["well"] as Vector3)
	var story: OldWellStory = OldWellStory.shared()
	match Session.old_well_stage():
		OldWellQuest.Stage.LISTENING:
			Audio.sfx(&"ui_confirm")
			var beats: Array[OldWellStory.Beat] = story.get_beats("touch.listening")
			if not Session.flag(OldWellQuest.FLAG_HEAP):
				beats.append_array(story.get_beats("touch.left.heap"))
			if not Session.flag(OldWellQuest.FLAG_BUFFET):
				beats.append_array(story.get_beats("touch.left.buffet"))
			OldWellSpot.play(dialogue, beats)
			return
		OldWellQuest.Stage.READY:
			_ask_old_well_echo()
			return
		OldWellQuest.Stage.DONE:
			hud.toast(story.text("touch.done"), Color("aef0ff"))
			Audio.sfx(&"ui_confirm")
			return
	if Session.old_well_can_begin():
		_begin_old_well_vision()
		return
	hud.toast("The %s spring hums. It knows you." % UIStyle.affinity_name(color), UIStyle.affinity_color(color).lightened(0.3))
	Audio.sfx(&"ui_confirm")


## The first touch once a zone is free: the vision, then the hidden quest starts (its "New quest" notice is the only announcement).
func _begin_old_well_vision() -> void:
	_locked = true
	Audio.sfx(&"ui_open", -4.0)
	var music: int = Audio.push_music(WELL_VISION_MUSIC)  # overnight Oct 19: the vault's own theme under the visions (the vault guards the spring)
	OldWellSpot.play(dialogue, OldWellStory.shared().get_beats("vision.start"), func() -> void:
		Audio.pop_music(music)
		Audio.sting(&"STG-SECRET")
		_locked = false
		Session.begin_old_well_quest()
		_apply_well_stir())


## Both hums found: the well fills with light; a confirm, the Echo's lines, the Before-the-fight card with its rule icon, then the duel.
func _ask_old_well_echo() -> void:
	var story: OldWellStory = OldWellStory.shared()
	if not Session.any_deck_valid():
		hud.toast("Your deck is not ready for what waits in the well.", Color("ff8a85"))
		Audio.sfx(&"ui_error")
		return
	_locked = true
	Audio.sfx(&"ui_open", -4.0)
	OldWellSpot.play(dialogue, story.get_beats("touch.ready"), func() -> void:
		var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, story.text("confirm.title"), story.text("confirm.body"), story.text("confirm.yes"), story.text("confirm.no"))
		dialog.confirmed.connect(func() -> void:
			DeckPicker.guard(_overlay_layer, func() -> void:
				OldWellSpot.play(dialogue, story.get_beats("echo.before"), func() -> void:
					Session.save_game()
					RulesBrief.open(self, RuleBadges.for_encounter(EncounterModifiers.rules(OldWellQuest.RULES_KEY)), "Before the fight: %s" % OldWellQuest.DISPLAY_NAME, camera_push_then.bind(Session.challenge_old_well))),
				func() -> void: _locked = false))
		dialog.cancelled.connect(func() -> void: _locked = false))


## Shown once after the Echo's duel: a loss gets its lines; the first win plays the final vision, then the quest's reward box (queued by the
## quest system) shows on its own.
func _show_old_well_result() -> void:
	if Session.pending_old_well_result.is_empty():
		return
	var result: Dictionary = Session.pending_old_well_result
	Session.pending_old_well_result = {}
	var story: OldWellStory = OldWellStory.shared()
	if bool(result.get("first_win", false)):
		Audio.sfx(&"victory", -6.0)
		var music: int = Audio.push_music(WELL_VISION_MUSIC)
		OldWellSpot.play(dialogue, story.get_beats("echo.reveal"), func() -> void: Audio.pop_music(music))
	elif not bool(result.get("won", false)):
		OldWellSpot.play(dialogue, story.get_beats("echo.lose"))


## The music under the well's visions (the start and the final reveal): the Forgotten Vault's exploration theme.
const WELL_VISION_MUSIC: StringName = &"MUS-VAULT-EXP"


## How much the well's light and motes stir: brighter while the quest waits for the Echo.
var _well_stir: float = 1.0


func _apply_well_stir() -> void:
	_well_stir = 1.6 if Session.old_well_stage() == OldWellQuest.Stage.READY else 1.0
	if _well_particles != null:
		_well_particles.amount = 48 if _well_stir > 1.0 else 26


func _well_burst(color: Affinity.Type) -> void:
	var tint: Color = UIStyle.affinity_color(color).lightened(0.35)
	_well_light.light_color = tint
	var burst: CPUParticles3D = CPUParticles3D.new()
	burst.position = _well_particles.position
	burst.amount = 60
	burst.one_shot = true
	burst.explosiveness = 0.9
	burst.lifetime = 1.6
	burst.direction = Vector3.UP
	burst.spread = 60.0
	burst.initial_velocity_min = 1.5
	burst.initial_velocity_max = 3.2
	burst.gravity = Vector3(0, -2.0, 0)
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.1
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = tint
	material.emission_enabled = true
	material.emission = tint
	material.emission_energy_multiplier = 3.0
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = material
	burst.mesh = mesh
	add_child(burst)
	burst.emitting = true
	get_tree().create_timer(2.5).timeout.connect(burst.queue_free)


func _open_deck_station() -> void:
	Session.set_flag(&"deck_station_seen")
	_open_deck_builder_anywhere()
	EventBus.tutorial_event.emit(&"deck_station_opened")


## New brief, Part B: the deck builder is reachable anywhere in town via a hotkey (B) or the HUD
## button, not only by walking to the deck station spot. It is the same `DeckbuilderScreen` with
## the same validation rules either way (D64) - the station now just gives a flavorful, in-world
## way to reach the exact same screen instead of being the only way in.
func _open_deck_builder_anywhere() -> void:
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
	# A finished quest gets its own "Quest Complete" box (Session.pending_popups), so only new quests toast. Fixes Oct 25, Part 7: the quest
	# update banner (`QuestNoticeLayer`) announces new quests now; the toast stays only where no banner layer exists (tools).
	if is_new and SceneManager.quest_notices == null:
		hud.queue_toast(text, UIStyle.GOLD)


## Part E: level, XP, stats, item and equipment slots. Hotkey C (global, see _unhandled_input) or
## the HUD button; also reachable from the rewards screen right after leveling up.
func _open_character_screen() -> void:
	var screen: CharacterScreen = CharacterScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


## New brief, Part A: the same level-up popup used after a dungeon battle, reused here for
## level-ups from any other source (a corrupted NPC's first win, the dev shrine).
func _show_level_up(gained: Array[LevelData]) -> LevelUpScreen:
	var screen: LevelUpScreen = LevelUpScreen.new()
	screen.setup(gained)
	_open_overlay(screen)
	screen.finished.connect(_close_overlay)
	return screen


## New brief (third), Part E: debug-only - each interaction grants exactly one level (up to
## ProgressionTable.MAX_LEVEL), through the same LevelUpScreen/rewards/equipment-choice flow a
## real battle's XP would trigger. Defensively re-checks DevTools.shrine_enabled() even though the
## spot only exists at all when the builder already made that same check, in case anything ever
## calls this directly.
func _use_dev_shrine() -> void:
	if not DevTools.shrine_enabled():
		return
	Session.grant_dev_packs(1)
	var gained: Array[LevelData] = Session.grant_dev_level()
	if gained.is_empty():
		hud.toast("Already at max level (%d)." % ProgressionTable.MAX_LEVEL, UIStyle.MUTED)
		return
	_show_level_up(gained)


func _open_codex() -> void:
	var screen: CodexScreen = CodexScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


## The vault's unlock condition - built with the reusable Condition system (core/data/
## condition.gd) like a vendor's stock or an NPC line would be, not a raw flag check.
func _vault_condition() -> Condition:
	return Condition.flag(VAULT_LEVER_FLAG)


func _open_chest() -> void:
	player.face(town.anchors["chest"] as Vector3)
	if Session.ninja_defeated():
		hud.toast("The chest is empty. Only a faint smell of smoke remains.", UIStyle.MUTED)
		return
	if Session.ninja_ready():
		_start_ninja_fight()
		return
	if Session.ninja_chest_opened(NinjaBoss.ORIGINAL_CHEST):
		hud.toast("The chest is empty now.", UIStyle.MUTED)
		return
	GiantChestEvent.play(self, NinjaBoss.ORIGINAL_CHEST, town.harbor_chest_node)


## The Secret Dealer appears once the original giant chest has been opened (the old "harbor_chest" secret still counts for older saves).
func _secret_dealer_open() -> bool:
	return Session.found_secret(HIDDEN_VENDOR_SECRET) or Session.ninja_chest_opened(NinjaBoss.ORIGINAL_CHEST)


## Shiro Swindle scene hooks (GiantChestEvent): the scene is locked while it plays, and the fifth chest wakes the original one.
func set_world_locked(on: bool) -> void:
	_locked = on
	_scripted_lock = on


func on_ninja_ready() -> void:
	GiantChestEvent.apply_look(town.harbor_chest_node, NinjaBoss.ORIGINAL_CHEST)


## The original chest, closed and glowing: his lines, then the duel on the town battleboard.
func _start_ninja_fight() -> void:
	_locked = true
	player.input_enabled = false
	Audio.sfx(&"chest_open", -4.0)
	dialogue.start(NinjaBoss.DISPLAY_NAME, NinjaBoss.FIGHT_BEFORE, NinjaBoss.NPC_ID)
	dialogue.finished.connect(func() -> void:
		Session.save_game()
		# Daytime Oct 19: his one-sided rules before the duel (the same icons stay in the battle HUD).
		RulesBrief.open(self, RuleBadges.for_encounter(EncounterModifiers.rules(NinjaBoss.RULES_KEY)), "Before the fight: %s" % NinjaBoss.DISPLAY_NAME, camera_push_then.bind(Session.challenge_ninja)), CONNECT_ONE_SHOT)


## The Four-Seal Vault door: sealed until all four hidden levers (one per Path zone) are pulled, then the Warden's duel; empty once it is beaten.
func _open_four_seal_vault() -> void:
	player.face(town.anchors["vault4_mouth"] as Vector3)
	if Session.vault_defeated():
		hud.toast(VaultGuardian.EMPTY_LINES[0], UIStyle.MUTED)
		return
	if not Session.vault_unlocked():
		Audio.sfx(&"ui_error")
		var lines: Array[String] = VaultGuardian.SEALED_LINES.duplicate()
		lines.append("%d of 4 seals are broken." % Session.vault_levers_pulled())
		dialogue.start("", lines)
		return
	_locked = true
	player.input_enabled = false
	dialogue.start(VaultGuardian.DISPLAY_NAME, VaultGuardian.BEFORE_LINES, VaultGuardian.NPC_ID)
	dialogue.finished.connect(func() -> void:
		Session.save_game()
		Session.challenge_vault_guardian(), CONNECT_ONE_SHOT)


## Shown once after the duel: the Warden's lines, and on a first win the reward box (4 Gilded Packs, essence, the Four-Seal Signet, a cloak, XP).
func _show_vault_result() -> void:
	if Session.pending_vault_result.is_empty():
		return
	var result: Dictionary = Session.pending_vault_result
	Session.pending_vault_result = {}
	var won: bool = bool(result.get("won", false))
	dialogue.start(VaultGuardian.DISPLAY_NAME, VaultGuardian.WIN_LINES if won else VaultGuardian.LOSE_LINES, VaultGuardian.NPC_ID)
	if bool(result.get("first_win", false)):
		var summary: RewardSummary = result.get("summary") as RewardSummary
		dialogue.finished.connect(func() -> void:
			Audio.sfx(&"victory", -6.0)
			if summary != null:
				_show_reward_box(summary), CONNECT_ONE_SHOT)


## Shown once after the duel: his post-fight lines, and on a first win what he gave back (gold, three Gilded Packs).
func _show_ninja_result() -> void:
	if Session.pending_ninja_result.is_empty():
		return
	var result: Dictionary = Session.pending_ninja_result
	Session.pending_ninja_result = {}
	var won: bool = bool(result.get("won", false))
	dialogue.start(NinjaBoss.DISPLAY_NAME, NinjaBoss.FIGHT_WIN if won else NinjaBoss.FIGHT_LOSE, NinjaBoss.NPC_ID)
	if bool(result.get("first_win", false)):
		var packs: Array = result.get("packs", []) as Array
		var entries: Array[Dictionary] = []
		for pack_id: Variant in packs:
			entries.append(PackRewards.entry(str(pack_id)))
		var returned: int = int(result.get("gold_returned", 0))
		var text: String = "Shiro Swindle returns %d gold and 3 Gilded Packs: %s" % [returned, PackRewards.labels(entries)]
		dialogue.finished.connect(func() -> void:
			hud.set_gold(Session.gold)
			hud.toast(text, UIStyle.GOLD)
			Audio.sfx(&"victory", -6.0), CONNECT_ONE_SHOT)


## New brief, Part D (5 chests) / fourth brief, Part E (2 more, equipment this time): one of the
## 7 hidden chests. One-time (Session.found_secret, like the D38 chest above) - contents mix
## gold/item/card/equipment per HIDDEN_CHEST_REWARDS. Locations and contents are also written to
## docs/design/secrets.md; keep both in sync if either changes.
func _open_hidden_chest(id: String) -> void:
	var anchor: Vector3 = town.anchors.get("hidden_chest_%s" % id, Vector3.ZERO) as Vector3
	player.face(anchor)
	if Session.found_secret(_hidden_chest_secret(id)):
		return
	Session.discover_secret(_hidden_chest_secret(id))
	var reward: Dictionary = HIDDEN_CHEST_REWARDS.get(id, {}) as Dictionary
	reward = ChestLoot.with_roll(reward, "town", Session.owned_equipment_ids(), Session.rng)  # Oct 16: chests can roll gear or a pack by tier
	var summary: RewardSummary = Session.grant_chest_reward(reward, "Hidden chest")
	hud.set_gold(Session.gold)
	_animate_chest_open(id)
	_reveal_chest(null, summary)
	Session.save_game()


## Polish round: opens the chest lid (when `chest` is given), then the reward box once the lid has swung up. The hero stands still until it is dismissed.
func _reveal_chest(chest: Node3D, summary: RewardSummary) -> void:
	_locked = true
	player.input_enabled = false
	if chest != null:
		Audio.sfx(&"chest_open")
		Audio.sfx(&"coins", 0.0, 0.05)
		ChestKit.open_animated(chest)
	await get_tree().create_timer(0.7).timeout
	_show_reward_box(summary)


func _show_reward_box(summary: RewardSummary) -> RewardPopup:
	var popup: RewardPopup = RewardPopup.make(summary)
	_open_overlay(popup)
	popup.finished.connect(_close_overlay)
	return popup


## A small bounce + a golden burst (reusing the Wellspring's particle-burst pattern) and a latch-
## then-coins sound, since the chest model has no separate lid to hinge open.
func _animate_chest_open(id: String) -> void:
	Audio.sfx(&"chest_open")
	ChestKit.open_animated(town.hidden_chest_nodes.get(id) as Node3D)
	var anchor: Vector3 = town.anchors.get("hidden_chest_%s" % id, Vector3.ZERO) as Vector3
	var burst: CPUParticles3D = CPUParticles3D.new()
	burst.position = anchor + Vector3(0, 0.3, 0)
	burst.amount = 34
	burst.one_shot = true
	burst.explosiveness = 0.95
	burst.lifetime = 1.1
	burst.direction = Vector3.UP
	burst.spread = 50.0
	burst.initial_velocity_min = 1.2
	burst.initial_velocity_max = 2.6
	burst.gravity = Vector3(0, -2.4, 0)
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.045
	mesh.height = 0.09
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = UIStyle.GOLD
	material.emission_enabled = true
	material.emission = UIStyle.GOLD
	material.emission_energy_multiplier = 3.0
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = material
	burst.mesh = mesh
	add_child(burst)
	burst.emitting = true
	Audio.sfx(&"coins", 0.0, 0.05)
	get_tree().create_timer(2.0).timeout.connect(burst.queue_free)


func _pull_lever() -> void:
	if Session.flag(VAULT_LEVER_FLAG):
		hud.toast("The lever will not budge any further.", UIStyle.MUTED)
		return
	Session.set_flag(VAULT_LEVER_FLAG)
	Audio.sfx(&"lever_clunk")
	hud.toast("Something deep in the vault unlocks.", UIStyle.GOLD)
	Session.save_game()


func _open_vault() -> void:
	player.face(town.anchors["vault"] as Vector3)
	if not Condition.met(_vault_condition(), Session.unlock_state()):
		hud.toast("Sealed. Somewhere in the town, an old lever might help.", Color("ffcf70"))
		Audio.sfx(&"ui_error")
		return
	if Session.flag(&"vault_opened"):
		hud.toast("The vault stands open and empty.", UIStyle.MUTED)
		return
	Session.set_flag(&"vault_opened")
	var reward: CardData = Session.content.card("B-27")
	if reward != null:
		Session.add_cards([reward] as Array[CardData])
	Audio.sfx(&"card_draw")
	Audio.sfx(&"ui_confirm")
	hud.toast("The vault opens. %s joins your collection." % (reward.display_name if reward != null else "A card"), UIStyle.GOLD)
	Session.save_game()


func _talk_hidden_vendor() -> void:
	_face_npc("hidden_vendor")
	var lines: Array[String] = StoryText.shared().get_lines("town.hidden_vendor")
	dialogue.start("A Secret Dealer", lines)
	dialogue.finished.connect(_open_hidden_vendor, CONNECT_ONE_SHOT)


func _open_hidden_vendor() -> void:
	var screen: VendorScreen = VendorScreen.new()
	screen.stock = _hidden_vendor_stock()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


## A small, always-unlocked stock of rare/mythic cards - distinct from Sable's stall, and only
## reachable at all once the hidden vendor's spot exists (Session.found_secret gate in
## _build_spots/_build_actors).
func _hidden_vendor_stock() -> VendorData:
	var data: VendorData = VendorData.new()
	data.vendor_name = "Secret Dealer"
	for id: Variant in Session.content.cards.keys():
		var card: CardData = Session.content.card(str(id))
		if card.rarity == CardEnums.Rarity.EPIC or card.rarity == CardEnums.Rarity.LEGENDARY:
			data.add(card.id)
	return data


## Sable's stall as it opens (also built once by the UiArtWarmup a moment after arriving).
static func _new_card_vendor_screen() -> VendorScreen:
	var screen: VendorScreen = VendorScreen.new()
	screen.pack_vendor_id = PackData.VENDOR_CARD
	screen.pack_story_prefix = "pack.card_vendor"
	screen.vendor_screen_id = "VS-SABLE"
	return screen


func _open_vendor() -> void:
	if not Session.has_profile():
		return
	var screen: VendorScreen = _new_card_vendor_screen()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)
	EventBus.tutorial_event.emit(&"vendor_opened")


## Brief 9, Part F: Auntie Alembic's Locked until 2 zones are free: visible and shuttered, with a hint from the note on the
## door. Open: Auntie Alembic greets you and the crafting screen opens.
func _use_alchemist() -> void:
	var story: StoryText = StoryText.shared()
	if not Session.alchemist_unlocked():
		_face_npc("alchemist")
		dialogue.start(story.text("town.alchemist.name"), story.get_lines("town.alchemist.locked"))
		hud.toast("%s (%d of %d zones free)" % ["Auntie Alembic's is closed", Session.completed_zone_count(), ZoneCompletion.ALCHEMIST_UNLOCK_COUNT], Color("ffcf70"))
		return
	_face_npc("alchemist")
	var lines: Array[String] = story.get_lines("town.alchemist.return" if Session.flag(&"alchemist_met") else "town.alchemist.intro")
	Session.set_flag(&"alchemist_met")
	dialogue.start("Auntie Alembic", lines)
	dialogue.finished.connect(_open_alchemist, CONNECT_ONE_SHOT)


func _open_alchemist() -> void:
	if not Session.has_profile():
		return
	var screen: AlchemistScreen = AlchemistScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)

## Brief 9, Part G: the Grand Clashatorium. Chained until the first zone is free (a hint from the sign on the chains), then
## Announcer Grand Bellows greets you and the Arena screen opens.
func _use_arena() -> void:
	var story: StoryText = StoryText.shared()
	if not Session.arena_unlocked():
		dialogue.start(story.text("town.arena.name"), story.get_lines("town.arena.locked"))
		if not town.hub_land:
			hud.toast("The Arena is closed (%d of %d zones free)" % [Session.completed_zone_count(), ZoneCompletion.ARENA_UNLOCK_COUNT], Color("ffcf70"))
		return
	_face_npc("arena")
	var lines: Array[String] = story.get_lines("town.arena.return" if Session.flag(&"arena_met") else "town.arena.intro")
	Session.set_flag(&"arena_met")
	dialogue.start("Announcer Grand Bellows", lines)
	dialogue.finished.connect(_open_arena, CONNECT_ONE_SHOT)


func _open_arena(result: Dictionary = {}) -> void:
	if not Session.has_profile():
		return
	var screen: ArenaScreen = ArenaScreen.new()
	screen.result = result
	screen.fight_chosen.connect(func(encounter_id: String) -> void:
		_close_overlay()
		_locked = true
		var encounter: ArenaEncounter = ArenaDefs.find(encounter_id)
		var rules: Array[RuleBadges.Badge] = RuleBadges.for_encounter(EncounterModifiers.rules(ArenaScenario.rules_key(encounter)))
		DeckPicker.guard(_overlay_layer, func() -> void:
			RulesBrief.open(self, rules, "Before the fight: %s" % encounter.enemy_name, Session.start_arena_battle.bind(encounter_id)), func() -> void: _locked = false))
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)

## New brief, Part F: the item vendor.
func _talk_item_vendor() -> void:
	_face_npc("item_vendor")
	var lines: Array[String] = StoryText.shared().get_lines("town.item_vendor.return")
	if not Session.flag(&"item_vendor_seen"):
		Session.set_flag(&"item_vendor_seen")
		lines = StoryText.shared().get_lines("town.item_vendor.first")
	dialogue.start("Tilly Tonic", lines)
	dialogue.finished.connect(_open_item_vendor, CONNECT_ONE_SHOT)


func _open_item_vendor() -> void:
	if not Session.has_profile():
		return
	var screen: ItemVendorScreen = ItemVendorScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


## Fourth brief, Part C: the equipment vendor (Bertram Beetsworth, "Assistant to the Regional
## Merchant"). Dialogue lives in the story data file (StoryText), not hardcoded here, matching
## the brief's own instruction rather than this scene's older (inline) convention for Sable/Tilly Tonic.
func _talk_equipment_vendor() -> void:
	_face_npc("equipment_vendor")
	var story: StoryText = load(STORY_PATH) as StoryText
	# filled copies: `append_array` below must never grow the story resource's own arrays (overnight Oct 19: the "too early" lines piled up on the
	# cached resource, so a second new game in the same session heard them twice)
	var lines: Array[String] = StoryText._filled(story.equipment_vendor_return_lines)
	var first_visit: bool = not Session.flag(&"equipment_vendor_seen")
	if first_visit:
		Session.set_flag(&"equipment_vendor_seen")
		lines = StoryText._filled(story.equipment_vendor_intro_lines)
	# Overnight Oct 17, Part 5: no shop before level 5; at level 5 his short quest hands out the first piece of gear.
	var shared: StoryText = StoryText.shared()
	var stage: int = Session.armory_talk()
	var opens_shop: bool = stage == 4
	match stage:
		0:
			if not first_visit:
				lines = []
			lines.append_array(shared.get_lines("town.equipment_vendor.too_early"))
		1:
			lines = shared.get_lines("quest.armory.start")
		2:
			lines = shared.get_lines("quest.armory.waiting")
		3:
			lines = shared.get_lines("quest.armory.done")
	dialogue.start("Bertram Beetsworth", lines)
	if opens_shop:
		dialogue.finished.connect(_open_equipment_vendor, CONNECT_ONE_SHOT)


func _open_equipment_vendor() -> void:
	if not Session.has_profile():
		return
	var screen: EquipmentVendorScreen = EquipmentVendorScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


## Brief 11: Foil Fenwick, the Pack Vendor. Sells each Path's pack once that Path's dungeon was cleared (locked ones are teasers), and the
## Prismatic Pack from the back room after the postgame.
func _talk_pack_vendor() -> void:
	_face_npc("pack_vendor")
	var story: StoryText = StoryText.shared()
	var lines: Array[String] = story.get_lines("town.pack_vendor.return")
	if not Session.flag(&"pack_vendor_seen"):
		Session.set_flag(&"pack_vendor_seen")
		lines = story.get_lines("town.pack_vendor.first")
	if Session.profile != null and Session.profile.postgame_unlocked and not Session.flag(&"pack_vendor_prismatic_seen"):
		Session.set_flag(&"pack_vendor_prismatic_seen")
		lines.append_array(story.get_lines("town.pack_vendor.prismatic_reveal"))
	dialogue.start(story.text("town.pack_vendor.name"), lines)
	dialogue.finished.connect(_open_pack_vendor, CONNECT_ONE_SHOT)


func _open_pack_vendor() -> void:
	if not Session.has_profile():
		return
	var screen: PackShopScreen = PackShopScreen.make(PackData.VENDOR_PACK, "town.pack_vendor")
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


## Part G: a placeholder zone portal. Loads the reusable "coming soon" template
## (ZonePlaceholderScene) - no real zone exists yet for any of the 5. New brief, Part C/E: a
## locked element entrance shows a barrier message instead of loading the zone.
func _use_zone_portal(zone_id: String) -> void:
	var info: ZonePortals.Info = ZonePortals.find(zone_id)
	if info == null:
		return
	player.face(town.anchors["portal_%s_mouth" % zone_id] as Vector3)
	if _portal_is_locked(zone_id):
		var blocked: String = StoryText.shared().text("gate.%s.blocked" % zone_id) if Gatekeepers.has(zone_id) else "The way to %s is sealed." % info.display_name
		hud.toast("%s Beat %s to open it." % [blocked, Gatekeepers.display_name(zone_id)] if Gatekeepers.has(zone_id) else blocked, info.tint.lightened(0.35))
		Audio.sfx(&"ui_error")
		return
	Audio.sfx(&"portal_enter")
	if ZoneDefs.has_def(zone_id):
		Session.enter_zone(zone_id)
		return
	Session.enter_zone_portal(zone_id)


func _use_gate() -> void:
	_face_npc("guard")
	if not Session.any_deck_valid():
		var problems: Array[DeckValidator.Issue] = Session.deck_issues()
		var message: String = problems[0].message if not problems.is_empty() else "Your deck is not legal."
		hud.toast("Your deck is not ready: %s" % message, Color("ff8a85"))
		Audio.sfx(&"ui_error")
		return
	var dialog: ConfirmDialog = ConfirmDialog.ask(
		_overlay_layer, "The Forgotten Cave",
		"Enter the cave? You are fully healed on entry, and your HP carries from fight to fight. Lose a duel and you are carried back to town.",
		"Enter", "Not yet",
	)
	_locked = true
	dialog.confirmed.connect(func() -> void:
		DeckPicker.guard(_overlay_layer, func() -> void:
			Audio.sfx(&"dungeon_enter")
			Session.begin_trial(), func() -> void: _locked = false))
	dialog.cancelled.connect(func() -> void: _locked = false)


# ---- Overlays ---------------------------------------------------------------------------


## Minimap points of interest (brief 6, Part C): an explicit whitelist by spot id. The hidden chest,
## lever, vault, secret dealer and dev shrine are deliberately NOT listed - secrets never show.
const POI_KINDS: Dictionary = {
	"well": MapPoi.Kind.HEAL, "vendor": MapPoi.Kind.VENDOR, "item_vendor": MapPoi.Kind.VENDOR,
	"equipment_vendor": MapPoi.Kind.VENDOR, "pack_vendor": MapPoi.Kind.VENDOR, "tailor": MapPoi.Kind.VENDOR, "deck": MapPoi.Kind.INTERACTABLE, "codex": MapPoi.Kind.INTERACTABLE,
	"elder": MapPoi.Kind.INTERACTABLE, "guard": MapPoi.Kind.INTERACTABLE, "gate": MapPoi.Kind.DUNGEON, "notice_board": MapPoi.Kind.INTERACTABLE, "arena": MapPoi.Kind.ARENA,
	"graveyard_cairn": MapPoi.Kind.CHALLENGE, StoreroomGhosts.SPOT_ID: MapPoi.Kind.CHALLENGE,
}


func _collect_pois() -> Array[MapPoi]:
	var result: Array[MapPoi] = []
	for spot: Spot in spots:
		if not spot.named:
			continue
		if POI_KINDS.has(spot.id):
			result.append(MapPoi.make(POI_KINDS[spot.id] as MapPoi.Kind, spot.position, spot.title))
		elif spot.id.begins_with("npc_") and spot.id.trim_prefix("npc_") in CorruptedNpcs.IDS:
			result.append(MapPoi.make(MapPoi.Kind.CHALLENGE, spot.position, spot.title))
		elif spot.id.begins_with("portal_"):
			result.append(MapPoi.make(MapPoi.Kind.EXIT, spot.position, spot.title, false, _portal_is_locked(spot.id.trim_prefix("portal_"))))
	if quest_markers != null:
		quest_markers.add_map_pois(result)
	return result


func _open_full_map() -> void:
	if _locked or dialogue.active:
		return
	var screen: FullMapScreen = FullMapScreen.new()
	screen.setup("town", town, player, _collect_pois(), "Town")
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


# ---- The Beefcake Rift Express (brief 10b) -----------------------------------------------------------------------


## The home station: a squat-rack frame with a torn-open rift, and the Beefcake who tears it.
func _build_rift_station() -> void:
	var travel: StoryText = StoryText.shared()
	var pos: Vector3 = town.anchors["rift_station"] as Vector3
	_station = FastTravelStation.new()
	add_child(_station)
	_station.position = pos
	_station.icon_sign = true
	_station.build(travel.get_lines("travel.sign.town"), true)
	town.obstacles.append(Vector3(pos.x, pos.z, 1.3))
	var rip: Dictionary = NpcSprites.rift_operator()
	var operator: Node3D = rip["node"] as Node3D
	ModelKit.place(self, operator, town.anchors["npc_rift_station"] as Vector3, 40.0, TownPlayer.MODEL_SCALE * float(rip["scale"]))
	var animation: AnimationPlayer = ModelKit.animation_player(operator)
	if animation != null and animation.has_animation("Idle"):
		animation.play("Idle")
		animation.seek(randf() * 1.5)
	_npcs["rift_operator"] = operator
	town.obstacles.append(Vector3((town.anchors["npc_rift_station"] as Vector3).x, (town.anchors["npc_rift_station"] as Vector3).z, 0.35))
	_add_spot("rift_station", travel.text("travel.title"), pos + Vector3(0.0, 0.0, 1.6), 2.0)


func _use_rift_station() -> void:
	var travel: StoryText = StoryText.shared()
	_face_npc("rift_operator")
	var lines: Array[String] = travel.get_lines("travel.return.town")
	if not Session.flag(&"rift_met_town"):
		Session.set_flag(&"rift_met_town")
		lines = travel.get_lines("travel.intro.town")
	# Story v2 Part H: after Primm falls, Rip tells the Wanderer about the forest and opens a station there.
	if Session.flag(&"primm_defeated") and not Session.flag(&"rip_forest_tip"):
		Session.set_flag(&"rip_forest_tip")
		Session.set_flag(PathologyLab.FLAG_FOREST_OPEN)
		Session.set_flag(PathologyLab.FLAG_REVEALED)
		lines = travel.get_lines("travel.forest_tip")
	dialogue.start(travel.text("travel.operator.town"), lines)
	dialogue.finished.connect(_open_rift_screen, CONNECT_ONE_SHOT)


func _open_rift_screen() -> void:
	var screen: FastTravelScreen = FastTravelScreen.new()
	screen.here = FastTravel.TOWN
	screen.destination_chosen.connect(func(station_id: String) -> void:
		_close_overlay()
		_locked = true
		RiftTrip.run(self, _overlay_layer, dialogue, _station, StoryText.shared().text("travel.operator.town"), station_id))
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


## Arriving by rift: the operator says the town's landing line.
func _show_rift_arrival() -> void:
	if not dialogue.active:
		dialogue.start(StoryText.shared().text("travel.operator.town"), StoryText.shared().get_lines("travel.arrive.town"))


func _open_overlay(screen: Control) -> void:
	RewardPopup.requeue_if_unanswered(_overlay)
	_close_overlay()
	_locked = true
	_overlay = screen
	_overlay_layer.add_child(screen)
	Audio.sfx(&"ui_open")


func _close_overlay() -> void:
	if _overlay != null:
		_overlay.queue_free()
		_overlay = null
	_locked = arrival_active  # an arrival step closing hands over to the next one; the hero stays put until the queue ends
	_refresh_objective()
	hud.set_gold(Session.gold)
	Session.save_game()
	Audio.sfx(&"ui_close", -4.0)


func _refresh_objective() -> void:
	var story: StoryText = StoryText.shared()
	hud.set_location(story.text("town.name"), ZoneCompletion.progress_text(Session.flags))
	hud.set_objective(story.text("town.objective.postgame" if Session.flag(&"primm_defeated") else ("town.objective.free" if Session.completed_zone_count() >= ZoneCompletion.TOTAL_ZONES else "town.objective")))


## Brief 9: the Arena / the Alchemist opened since the player was last in town and nothing has announced it yet (the zone's own
## "free" screen normally does): a short announcement, once.
func _announce_new_unlocks() -> void:
	var story: StoryText = StoryText.shared()
	var notices: Array[String] = []
	if Session.arena_unlocked() and not Session.flag(&"arena_announced"):
		Session.set_flag(&"arena_announced")
		notices.append(story.text("town.arena.announce"))
	if Session.alchemist_unlocked() and not Session.flag(&"alchemist_announced"):
		Session.set_flag(&"alchemist_announced")
		notices.append(story.text("town.alchemist.announce"))
	if PackShop.tier2_unlocked(Session.unlock_state()) and not Session.flag(&"general_tier2_announced"):
		Session.set_flag(&"general_tier2_announced")
		notices.append(story.text("pack.card_vendor.tier2"))
	for notice: String in notices:
		hud.toast(notice, Color("ffd98a"))


## After an arena fight the town reopens the Arena screen with what happened.
func _show_pending_arena_result() -> void:
	if Session.pending_arena_result.is_empty():
		return
	var result: Dictionary = Session.pending_arena_result
	Session.pending_arena_result = {}
	_open_arena(result)

# ---- Screenshot helpers -----------------------------------------------------------------


func _teleport(spot_id: String) -> void:
	for spot: Spot in spots:
		if spot.id == spot_id:
			player.position = spot.position + Vector3(0.0, 0.0, 1.8)
			_camera.position = player.position + CameraRig.shape(camera_offset)
			return
	# Hidden chests (Part D) have no Spot - a dev-only screenshot convenience, not a gameplay path.
	if town.anchors.has(spot_id):
		player.position = (town.anchors[spot_id] as Vector3) + Vector3(0.0, 0.0, 1.8)
		_camera.position = player.position + CameraRig.shape(camera_offset)


## Screenshot helper (`--slots=save|load`): fills a few demo save slots in a throw-away folder and opens the slot list.
func _screenshot_slots(mode_name: String) -> void:
	SaveSlots.dir = "user://shot_saves/"
	for slot: int in range(0, SaveSlots.SLOT_COUNT + 1):
		SaveSlots.delete(slot)
	await get_tree().create_timer(1.5).timeout
	var shot: Image = Session.capture_thumbnail()
	Session.playtime_seconds = 5025.0
	Session.last_location = "Crosspath"
	Session.save_to_slot(1, "Before the Dump", shot)
	Session.gold = 340
	Session.profile.level = 4
	Session.playtime_seconds = 12480.0
	Session.last_location = "The Endless Buffet"
	Session.save_to_slot(3, "Buffet hub", shot)
	SaveSlots.write(SaveSlots.AUTOSAVE, Session.to_dict(), shot)
	var screen: SaveSlotsScreen = SaveSlotsScreen.make(SaveSlotsScreen.Mode.SAVE if mode_name == "save" else SaveSlotsScreen.Mode.LOAD, shot)
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


func _screenshot_open(what: String) -> void:
	match what:
		"bestiary_boss":  # Oct 23: a met boss's Bestiary page with its signature moves (Chancellor Clench, met and beaten once)
			Session.bestiary_meet("Chancellor Clench, Iron Regent")
			Session.bump_counter("bestiary_won:%s" % "Chancellor Clench, Iron Regent")
			var codex: CodexScreen = CodexScreen.new()
			_open_overlay(codex)
			codex.show_tab("Bestiary")
			var entry: Bestiary.Entry = Bestiary.find("Chancellor Clench, Iron Regent")
			if entry != null:
				get_tree().create_timer(0.6).timeout.connect(codex.show_beast.bind(entry))
		"pick":  # Oct 23, Part 4: the card pick box after a gatekeeper (as if Brick Bronson had just been beaten)
			var context: BattleContext = BattleContext.new()
			context.game = Session.make_practice_battle("Cave Scavenger").game
			context.enemy_name = "Brick Bronson"
			context.town_npc_id = "beefcake"
			context.won = true
			Session.queue_world_pick(context)
			var popup: RewardPopup = _show_reward_box(Session.pending_popups.pop_front() as RewardSummary)
			if popup != null:
				popup.frame.finish_reveal()
				popup.select_pick(1)
		"well":
			_use_well()
		"deck":
			_open_deck_station()
		"deck_slots":  # Oct 22, Part 2: the slot racks with several saved decks (covers, names, Path icons, In use)
			Session.set_flag(&"tip_deck")
			Session.add_xp(ProgressionTable.xp_to_reach(7) - Session.profile.xp)
			Session.new_saved_deck("Iron Sprint", ["BAS-B", "B-12", "B-12", "B-10", "B-09"] as Array[String])
			Session.new_saved_deck("Paperwork Pile", ["BAS-N", "N-23", "N-02", "N-01"] as Array[String])
			Session.new_saved_deck("Golem Kitchen", ["BAS-G", "G-23", "G-08", "G-01"] as Array[String])
			Session.new_saved_deck("Trash Party", ["BAS-R", "R-22", "R-08", "R-06"] as Array[String])
			_open_deck_station()
		"vendor":
			_open_vendor()
		"item_vendor":
			_open_item_vendor()
		"equipment_vendor":
			_open_equipment_vendor()
		"tailor":
			_open_tailor()
		"pack_vendor":
			_open_pack_vendor()
		"dialogue":
			_talk_elder()
		"gate":
			_use_gate()
		"bestiary":
			for index: int in range(0, Bestiary.all().size(), 3):
				Session.bestiary_meet(Bestiary.all()[index].name)
				Session.bestiary_defeat(Bestiary.all()[index].name)
			_open_codex()
			(_overlay as CodexScreen).show_tab("Bestiary")
			(_overlay as CodexScreen).show_beast(Bestiary.all()[3])
		"codex":
			_open_codex()
		"codex_gear":  # Overnight Oct 19-20: the Collection Book's Gear tab, a few pieces owned (the character_gear set)
			_screenshot_gear()
			_open_codex()
			(_overlay as CodexScreen).show_tab("Gear")
		"wardrobe":
			_open_wardrobe()
		"character":
			_open_character_screen()
		"character_gear":
			_screenshot_gear()
			_open_character_screen()
		"alchemist":
			_open_alchemist()
		"arena":
			_open_arena()
		"quests":
			_open_quest_log()
		"memory1":
			_screenshot_memory(1)
		"memory4":
			_screenshot_memory(4)
		"map":
			_open_full_map()
		"reveal", "map_all":
			minimap.reveal_all_for_screenshot()
			if what == "map_all":
				_open_full_map()
		"pause":
			SceneManager.get("_pause_menu").call("toggle")
		"pause_settings":
			SceneManager.get("_pause_menu").call("toggle")
			SceneManager.get("_pause_menu").call("_show_settings")
		"settings_display", "settings_text", "settings_access", "settings_controls", "settings_audio":
			SceneManager.get("_pause_menu").call("toggle")
			SceneManager.get("_pause_menu").call("_show_settings")
			(SceneManager.get("_pause_menu").get("_settings") as SettingsPanel).show_page(["settings_display", "settings_text", "settings_access", "settings_controls", "settings_audio"].find(what))
		"pause_load":
			SceneManager.get("_pause_menu").call("toggle")
			SceneManager.get("_pause_menu").call("_show_slots", SaveSlotsScreen.Mode.LOAD)
		"chest_popup":
			_show_reward_box(Session.grant_chest_reward({"gold": 80, "item": "healing_draught", "card": "C-29", "equipment": "hover_boots", "pack": "gilded_gourmand"}, "Hidden chest"))
		"quest_popup":
			_show_reward_box(_sample_quest_summary())
		"level_popup":
			_show_level_up(Session.grant_dev_level())



## Screenshot only: unlocks every equipment slot, owns the ten named pieces and the zone ones, and wears the dagger, the plate and the boots (the character screen with gear).
func _screenshot_gear() -> void:
	for slot: EquipmentData.Slot in EquipmentData.Slot.values():
		Session.profile.unlock_equipment_slot(slot)
	for path: String in ["wicked_dagger", "solid_plate", "hover_boots", "xray_goggles", "extra_pocket"]:
		var piece: EquipmentData = load("res://data/equipment/%s.tres" % path) as EquipmentData
		Session.profile.owned_equipment.append(piece)
		if path in ["wicked_dagger", "solid_plate", "hover_boots"]:
			Session.profile.equip(piece)
	var belt: EquipmentData = load("res://data/equipment/zone/swole_belt.tres") as EquipmentData
	Session.profile.owned_equipment.append(belt)

## Screenshot only: a made-up finished quest for the Quest Complete box.
func _sample_quest_summary() -> RewardSummary:
	var summary: RewardSummary = RewardSummary.new()
	summary.kind = RewardSummary.Kind.QUEST
	summary.title = "Clear the Paths"
	summary.subtitle = "The four envoys no longer block the roads."
	summary.gold = 150
	summary.xp = 120
	summary.cards.append(Session.card_by_id("C-22"))
	summary.items.append(Session.content.item("healing_draught"))
	summary.add_pack("path_beefcake", "Beefcake Pack")
	summary.unlocks = ["The Gainlands entrance is now open", "New stock at the Equipment Vendor", "The Alchemist is now available"] as Array[String]
	return summary

## The wardrobe (hotkey T): hats, cloaks and dyes, purely cosmetic.
func _open_wardrobe() -> void:
	if _locked or dialogue.active:
		return
	var screen: WardrobeScreen = WardrobeScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


## Brief 12, Part F: Pip Threadwell's Hats & Hems. Try items on a rotating copy of the hero before buying; stock grows with zones freed and levels.
func _talk_tailor() -> void:
	_face_npc("tailor")
	var story: StoryText = StoryText.shared()
	var lines: Array[String] = story.get_lines("town.tailor.return")
	if not Session.flag(&"tailor_seen"):
		Session.set_flag(&"tailor_seen")
		lines = story.get_lines("town.tailor.first")
	elif Session.completed_zone_count() > int(Session.counters.get("tailor_zones_seen", 0)):
		Session.counters["tailor_zones_seen"] = Session.completed_zone_count()
		lines = story.get_lines("town.tailor.progress")
	if Session.completed_zone_count() >= 1 and not Session.flag(&"tailor_secrets_told"):
		Session.set_flag(&"tailor_secrets_told")
		lines.append_array(story.get_lines("town.tailor.secrets"))
	dialogue.start(story.text("town.tailor.name"), lines)
	dialogue.finished.connect(_open_tailor, CONNECT_ONE_SHOT)


func _open_tailor() -> void:
	if not Session.has_profile():
		return
	var screen: TailorScreen = TailorScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


## The Packs menu entry (hotkey P): unopened packs with Open buttons.
func _open_packs() -> void:
	if _locked or dialogue.active or not Session.has_profile():
		return
	var screen: PacksScreen = PacksScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


## Hidden things and vendors whose stock is not open yet carry no name plate and no map icon: a locked shop does not announce itself.
func _spot_is_named(id: String) -> bool:
	match id:
		"chest", "lever", "vault4":
			return false
		"alchemist":
			return Session.alchemist_unlocked()
		"arena":
			return Session.arena_unlocked()
		"pack_vendor":
			return Session.completed_zone_count() >= 1 or Session.flag(&"pack_vendor_seen")
	return true


## Crosspath pass, Part B: no lettering in the world (G-03). Places (the passages, the well, the hatch, the gate, the boards, the signposts, the vault...)
## carry no floating plate (the minimap still lists them, the HUD prompt and the dialogue name them); only people keep a name over their head (CP-3).
func _spot_has_plate(id: String) -> bool:
	if id == "hidden_vendor":
		return false  # the black-market alley stays a discovery
	return _spot_is_named(id) and id in NPC_SPOT_IDS


## Screenshot helper (`--nofog=1`): clears fog and haze so a top-down overview from a very high camera stays readable.
func _strip_fog() -> void:
	for node: Node in find_children("*", "WorldEnvironment", true, false):
		var env: Environment = (node as WorldEnvironment).environment
		if env == null:
			continue
		env.fog_enabled = false
		env.volumetric_fog_enabled = false
		env.glow_enabled = false


## Screenshot helper (`--open=memory1`): the fragment screen over the town.
func _screenshot_memory(number: int) -> void:
	var story: StoryText = StoryText.shared()
	var screen: MemoryScreen = MemoryScreen.make(number, story.text(MemoryDefs.key(number, "title")), story.get_lines(MemoryDefs.key(number, "fragment")))
	_overlay_layer.add_child(screen)


# ---- Sprite NPCs and the baker ---------------------------------------------------------------------------------------------------------


## The painted NPCs show their TALK pose while the hero talks to them; the baker walks his round and his talk spot follows him.
func _update_sprite_npcs(delta: float) -> void:
	var talking: bool = dialogue != null and dialogue.active
	if not talking:
		_talking_id = ""
	for id: Variant in _npcs.keys():
		var actor: SpriteActor = _npcs[id] as SpriteActor
		if actor != null:
			actor.talking = talking and str(id) == _talking_id
	if player != null:
		for stroller: SpriteWanderer in _strollers:
			stroller.tick(delta, player.position)
	if _baker == null or player == null:
		return
	_baker.frozen = talking and _talking_id == "baker"
	_baker.tick(delta, player.position)
	for spot: Spot in spots:
		if spot.id == "baker":
			spot.position = _baker.world_position()
			spot.marker.position = spot.position + Vector3(0.0, spot.label_height if spot.label_height > 0.0 else 1.9, 0.0)
			spot.plate.position = spot.marker.position + Vector3(0.0, 0.42, 0.0)


const BAKER_LINES: Array[Array] = [
	["Mind the flour! It gets everywhere. Into the bread, into the ledger, into my tea...", "Fresh loaves at dawn, sir, madam, traveller of unclear title."],
	["I make the bread and the Crosspath eats the bread. It is a system and I am very proud of it.", "Try the seeded one. It has seeds in it. That is the whole recipe."],
	["Heard the road to the Capital groans at night. I wouldn't know; I'm asleep by nine. Dough waits for no badger.", "Take a roll for the road. No charge. (A small charge. Kidding.)"],
]


func _talk_baker() -> void:
	var visits: int = int(Session.counters.get("baker_talks", 0))
	Session.counters["baker_talks"] = visits + 1
	var lines: Array[String] = []
	lines.assign(BAKER_LINES[visits % BAKER_LINES.size()] as Array)
	if _baker != null:
		_baker.face(player.position)
	_talk_npc("baker", "Brindle the Baker", lines)


## Vertical slice: the signposts carry the Path crest and arrows, no lettering. Using one opens this popup with what the old boards said.
func _read_signpost(index: int) -> void:
	if index < 0 or index >= square.streets.signpost_lines.size():
		return
	var lines: Array[String] = []
	for line: Variant in square.streets.signpost_lines[index]:
		lines.append(str(line))
	Audio.sfx(&"sign_read")
	dialogue.start("Signpost", lines)
