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
	var label_height: float = 2.5
	var plate: Label3D
	## False: no name plate and no map icon (hidden chests and levers, and vendors whose stock is not open yet).
	var named: bool = true


## High-angle diorama framing (docs/art/style_guide.md, section 7).
const CAMERA_OFFSET: Vector3 = Vector3(0.0, 11.0, 8.2)
## Screenshots can override it (`--cam=x,y,z`).
var camera_offset: Vector3 = CAMERA_OFFSET
## New brief, Part E: corrupted-NPC dialogue lines live here, not hardcoded in this script.
const STORY_PATH: String = "res://data/story/intro_story.tres"
## Three placeholder secrets proving the Condition system (docs/design/open_questions.md D38):
## a hidden chest, a locked vault that opens once its lever is pulled, and a hidden vendor who
## only appears once the chest has been found.
const HIDDEN_CHEST_SECRET: String = "harbor_chest"
const VAULT_LEVER_FLAG: StringName = &"vault_lever_pulled"
const HIDDEN_VENDOR_SECRET: String = "harbor_chest"
## True for spots that are people to talk to, as opposed to objects/gates.
const NPC_SPOT_IDS: Array[String] = [
	"elder", "guard", "vendor", "hidden_vendor", "item_vendor", "equipment_vendor", "pack_vendor", "tailor",
	"npc_beefcake", "npc_gourmand", "npc_refusemancer", "npc_necrocrat",
]
## The NPC ID (data/npcs, `NpcRegistry`) of each talkable town spot; spots without one (the secret dealer, the rift technician) show no portrait.
const NPC_IDS: Dictionary = {
	"elder": "NPC-ELDER", "guard": "NPC-GATEKEEPER", "vendor": "V-SABLE", "item_vendor": "V-TONIC", "equipment_vendor": "V-BEETSWORTH",
	"pack_vendor": "V-FENWICK", "tailor": "V-THREADWELL", "alchemist": "V-ALEMBIC", "arena": "NPC-BELLOWS",
	"npc_beefcake": "NPC-BRONSON", "npc_gourmand": "NPC-GRAVOIS", "npc_refusemancer": "NPC-MULLIGAN", "npc_necrocrat": "NPC-PALLOR",
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
var hud: TownHud
var dialogue: DialogueBox
var _camera: Camera3D
var style_rig: StyleRig
var square: TownSquare
var _portal_toast_cooldown: float = 0.0
var cloud_fader: CloudFader
var npc_hp: NpcHp
var _overlay_layer: Control
var _overlay: Control
var _near: Spot
var _time: float = 0.0
var _npcs: Dictionary = {}
var _well_light: OmniLight3D
var _well_particles: CPUParticles3D
var _screenshot_args: Dictionary = {}
var _locked: bool = false
var _station: FastTravelStation
var _arrived_by_rift: bool = false
var _hidden_chest_near: String = ""


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


func _ready() -> void:
	SceneManager.pause_allowed = true
	Audio.play_music(&"town")
	if not _screenshot_args.is_empty():
		if str(_screenshot_args.get("fresh", "false")) == "true":
			Session.new_game()
		else:
			Session.ensure_game()
		for found_id: String in str(_screenshot_args.get("found", "")).split(",", false):
			Session.discover_secret(found_id)
		var zone_count: int = int(_screenshot_args.get("zones", 0))
		for zone_id: String in ZoneDefs.ids().slice(0, zone_count):
			Session.complete_zone(zone_id)
		if _screenshot_args.has("essence"):
			for path: Affinity.Type in Affinity.colored_types():
				Session.profile.set_essence(path, 14 if path == Affinity.Type.BEEFCAKE or path == Affinity.Type.NECROCRAT else 3)
	if Session.deck == null:
		Session.new_game()
	Session.arrive_in_town()
	_ensure_input_actions()
	add_child(WorldLook.environment(&"day"))
	add_child(WorldLook.sun(&"day"))
	town.build(self)
	square = TownSquare.build(self, town, Settings.graphics_quality)
	AmbientBirds.spawn(self, square.center, 4, Color("f4ecd8"))
	_build_actors()
	_build_spots()
	_build_rift_station()
	ChestKit.apply_saved(town.hidden_chest_nodes, TownScene._hidden_chest_secret)
	GiantChestEvent.apply_look(town.harbor_chest_node, NinjaBoss.ORIGINAL_CHEST)
	_build_portal_barriers()
	TownDressing.alchemist(self, town.anchors, Session.alchemist_unlocked(), StoryText.shared())
	TownDressing.arena_gate(self, town.anchors, Session.arena_unlocked(), StoryText.shared())
	_announce_new_unlocks.call_deferred()
	_show_pending_arena_result.call_deferred()
	if _screenshot_args.has("cam"):
		var cam: PackedStringArray = str(_screenshot_args["cam"]).split(",")
		camera_offset = Vector3(float(cam[0]), float(cam[1]), float(cam[2]))
	_build_camera()
	style_rig = StyleRig.install(self, StylePresets.TOWN, _camera, player, 0.0 if _screenshot_args.has("nocull") else 70.0)
	if style_rig != null and style_rig.ambience != null:
		style_rig.ambience.focus(0.5, 1.2)
	cloud_fader = CloudFader.new()
	cloud_fader.camera = _camera
	cloud_fader.target = player
	add_child(cloud_fader)
	for cloud: Node3D in town.clouds:
		cloud_fader.adopt(cloud, 3.0)
	if style_rig != null:
		style_rig.register_lights(square.lights)
	var avoid: Array[Vector3] = [Vector3(square.center.x, square.center.z, square.meadow_radius)]
	if style_rig != null:
		ZoneDressing.build(self, town, StylePresets.TOWN, Settings.graphics_quality, avoid)
	_build_ui()
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
		_camera.position = player.position + camera_offset * Settings.camera_zoom
	if _screenshot_args.has("at"):
		_teleport(str(_screenshot_args["at"]))
	if _screenshot_args.has("open"):
		_screenshot_open.call_deferred(str(_screenshot_args["open"]))
	if Session.town_notice != "":
		hud.toast(Session.town_notice, UIStyle.GOLD)
		Session.town_notice = ""
	_show_npc_result.call_deferred()
	_show_graveyard_result.call_deferred()
	_show_ninja_result.call_deferred()
	if _screenshot_args.has("ninja"):
		GiantChestEvent.screenshot_run(self, str(_screenshot_args["ninja"]), town.harbor_chest_node, _screenshot_args)
	Session.save_game()


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
	player = TownPlayer.new()
	add_child(player)
	player.setup(town, "Hero", spawn)
	player.speed_multiplier = 1.35  # the town is spread out: a brisker walk
	npc_hp = NpcHp.new()
	npc_hp.target = player
	add_child(npc_hp)
	_add_npc("vendor", "Rogue_Hooded", town.anchors["npc_market"] as Vector3, 200.0)
	_add_npc("elder", "Mage", town.anchors["npc_well"] as Vector3, 250.0)
	_add_npc("guard", "Barbarian", town.anchors["npc_gate"] as Vector3, 160.0)
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
	if Session.arena_unlocked():
		_add_npc("arena", "Barbarian", town.anchors["npc_arena"] as Vector3, 200.0, Color(1.0, 0.8, 0.6))
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
	var npc: Node3D = HeroModel.build(HeroModel.npc_look(model_name.substr(5))) if model_name.begins_with("hero:") else ModelKit.character(model_name)
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
	_add_spot("well", "Wellspring", town.anchors["well"] as Vector3, 1.7)
	_add_spot("well_door", "The Iron Hatch", (town.anchors["well"] as Vector3) + Vector3(-2.2, 0.0, 0.6), 1.3)
	_build_vault_hatch()
	_add_spot("vendor", "Card Vendor", town.anchors["npc_market"] as Vector3, 1.5)
	_add_spot("deck", "Deck Station", town.anchors["deck"] as Vector3, 1.6)
	_add_spot("gate", "Trial of the Hollow", town.anchors["gate"] as Vector3, 1.7)
	_add_spot("elder", "Elder Maren", town.anchors["npc_well"] as Vector3, 1.4)
	_add_spot("guard", "Gatekeeper Brannoch", town.anchors["npc_gate"] as Vector3, 1.4)
	_add_spot("codex", "Hall of Records", town.anchors["codex"] as Vector3, 1.6)
	_add_spot("chest", "A Hidden Chest", town.anchors["chest"] as Vector3, 1.3)
	_add_spot("lever", "An Old Lever", town.anchors["lever"] as Vector3, 1.2)
	_add_spot("vault", "The Sealed Vault", town.anchors["vault"] as Vector3, 1.8)
	# Fourth brief, Part F: The Restless Cairn - the Graveyard's scripted-battle trigger. Unlike
	# the hidden chests, this one DOES get the normal marker/name-plate treatment (a Spot) - it's
	# meant to be found, not stumbled on; the challenge is the fight, not finding it.
	_add_spot("graveyard_cairn", "The Restless Cairn", town.anchors["graveyard_cairn"] as Vector3, 1.6)
	if _secret_dealer_open():
		_add_spot("hidden_vendor", "A Secret Dealer", town.anchors["hidden_vendor"] as Vector3, 1.5)
	# New brief, Part F: the item vendor.
	_add_spot("item_vendor", "Wick's Supplies", town.anchors["npc_item_vendor"] as Vector3, 1.5)
	# Fourth brief, Part C: the equipment vendor.
	_add_spot("equipment_vendor", "Assistant to the Regional Merchant", town.anchors["npc_equipment_vendor"] as Vector3, 1.5)
	_add_spot("pack_vendor", StoryText.shared().text("town.pack_vendor.name"), town.anchors["npc_pack_vendor"] as Vector3, 1.5)
	_add_spot("tailor", StoryText.shared().text("town.tailor.name"), town.anchors["npc_tailor"] as Vector3, 1.5)
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
	var marker: Node3D = Node3D.new()
	marker.position = position + Vector3(0, 1.9 if id in NPC_SPOT_IDS else 2.5, 0)
	add_child(marker)
	spot.marker = marker
	var plate: Label3D = Label3D.new()
	plate.text = title if spot.named else ""
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


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.fov = 38.0
	add_child(_camera)
	_camera.current = true
	_camera.position = player.position + camera_offset * Settings.camera_zoom
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
	minimap = MinimapHud.new()
	host.add_child(minimap)
	minimap.setup("town", town, player, _collect_pois)
	minimap.full_map_requested.connect(_open_full_map)
	var overlay_canvas: CanvasLayer = CanvasLayer.new()
	overlay_canvas.layer = 8
	add_child(overlay_canvas)
	_overlay_layer = UIKit.layer_host(overlay_canvas)


# ---- Frame update -----------------------------------------------------------------------


func _process(delta: float) -> void:
	_time += delta
	var target: Vector3 = player.position + camera_offset * Settings.camera_zoom
	_camera.position = _camera.position.lerp(target, 1.0 - exp(-5.0 * delta))
	_camera.basis = Basis.looking_at(-camera_offset, Vector3.UP)
	for spot: Spot in spots:
		var base_y: float = 1.9 if spot.id in NPC_SPOT_IDS else 2.5
		spot.marker.position.y = base_y + sin(_time * 2.4 + spot.position.x) * 0.08
		spot.marker.rotation_degrees.y += 60.0 * delta
		var distance: float = Vector2(player.position.x - spot.position.x, player.position.z - spot.position.z).length()
		var fade_start: float = 7.0 if spot.id.begins_with("portal_") else 2.6
		spot.plate.modulate.a = clampf(1.0 - (distance - fade_start) / 1.6, 0.0, 1.0)
		spot.plate.outline_modulate.a = spot.plate.modulate.a
		spot.plate.visible = spot.plate.modulate.a > 0.02
	_well_light.light_energy = 1.4 + sin(_time * 1.7) * 0.35
	_update_nearest()
	_update_hidden_chest_prompt()
	_check_portal_walk(delta)
	player.input_enabled = not _locked and not dialogue.active
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
		if distance <= spot.radius and distance < best_distance:
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
			return "Touch the Wellspring"
		"deck":
			return "Open the Deck Station"
		"gate":
			return "Enter the Trial of the Hollow"
		"codex":
			return "Browse the Codex"
		"chest":
			return "Open the chest"
		"lever":
			return "Pull the lever"
		"dev_shrine":
			return "Pray at the Dev Shrine (+1 level)"
		"vault":
			return "Open the vault" if Session.flag(VAULT_LEVER_FLAG) else "Try the sealed door"
		"graveyard_cairn":
			return "Disturb the cairn"
		"rift_station":
			return StoryText.shared().text("travel.prompt")
		"alchemist":
			return "Browse Crucible & Co." if Session.alchemist_unlocked() else "Knock (the shop is closed)"
		"arena":
			return "Enter the Grand Clashatorium" if Session.arena_unlocked() else "The gates are chained shut"
	if spot.id.begins_with("portal_"):
		var zone_id: String = spot.id.trim_prefix("portal_")
		return "Sealed - the corrupted guardian must fall first" if _portal_is_locked(zone_id) else "Enter"
	return spot.title


func _unhandled_input(event: InputEvent) -> void:
	# The character screen (Part E) and the deck builder (new brief, Part B) are global
	# shortcuts, not tied to a nearby spot - usable anywhere in town, not just at the station.
	if not _locked and not dialogue.active and event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		if (event as InputEventKey).keycode == KEY_C:
			get_viewport().set_input_as_handled()
			_open_character_screen()
			return
		if (event as InputEventKey).keycode == KEY_B:
			get_viewport().set_input_as_handled()
			_open_deck_builder_anywhere()
			return
		if (event as InputEventKey).keycode == KEY_P:
			get_viewport().set_input_as_handled()
			_open_packs()
			return
		if (event as InputEventKey).keycode == KEY_T:
			get_viewport().set_input_as_handled()
			_open_wardrobe()
			return
		if (event as InputEventKey).keycode == KEY_J:
			get_viewport().set_input_as_handled()
			_open_quest_log()
			return
		if (event as InputEventKey).keycode == KEY_M:
			get_viewport().set_input_as_handled()
			_open_full_map()
			return
	if not _locked and not dialogue.active and _hidden_chest_near != "":
		if event.is_action_pressed(&"interact") or (event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_SPACE):
			get_viewport().set_input_as_handled()
			_open_hidden_chest(_hidden_chest_near)
			return
	if _locked or dialogue.active or _near == null:
		return
	if event.is_action_pressed(&"interact"):
		get_viewport().set_input_as_handled()
		_interact(_near)
		return
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		if (event as InputEventKey).keycode == KEY_SPACE:
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
		"elder":
			_talk_elder()
		"guard":
			_talk_npc("guard", "Gatekeeper Brannoch", _guard_lines())
		"codex":
			_open_codex()
		"chest":
			_open_chest()
		"lever":
			_pull_lever()
		"dev_shrine":
			_use_dev_shrine()
		"vault":
			_open_vault()
		"hidden_vendor":
			_talk_hidden_vendor()
		"item_vendor":
			_talk_item_vendor()
		"equipment_vendor":
			_talk_equipment_vendor()
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
	var npc: Node3D = _npcs.get(id) as Node3D
	if npc != null:
		var offset: Vector3 = player.position - npc.position
		npc.rotation.y = atan2(offset.x, offset.z)
	player.face((npc.position if npc != null else player.position))


## Elder Maren: her greeting, and the quest that opens the Forgotten Vault under the old well (hand-in first, then the offer, then a reminder).
func _talk_elder() -> void:
	var elder: String = "Elder Maren"
	var ready: Array[QuestData] = Session.quests_ready_for(elder)
	if not ready.is_empty():
		var finished_quest: QuestData = ready[0]
		_talk_npc("elder", elder, DungeonCatalog.text_lines("quest.%s.ready" % finished_quest.id) as Array[String])
		dialogue.finished.connect(func() -> void: Session.turn_in_quest(finished_quest.id), CONNECT_ONE_SHOT)
		return
	var offered: Array[QuestData] = Session.quests_offered_by(elder) if Session.flag(&"elder_greeted") else ([] as Array[QuestData])
	if not offered.is_empty():
		var offer: QuestData = offered[0]
		var lines: Array[String] = _elder_lines()
		lines.append_array(DungeonCatalog.text_lines("quest.%s.offer" % offer.id))
		_talk_npc("elder", elder, lines)
		dialogue.finished.connect(func() -> void: Session.start_quest(offer.id), CONNECT_ONE_SHOT)
		return
	for quest_id: String in Session.quest_log.active:
		var active_quest: QuestData = QuestCatalog.find(quest_id)
		if active_quest != null and active_quest.giver_npc == elder:
			_talk_npc("elder", elder, DungeonCatalog.text_lines("quest.%s.active" % quest_id) as Array[String])
			return
	_talk_npc("elder", elder, _elder_lines())


func _talk_npc(id: String, speaker: String, lines: Array[String]) -> void:
	_face_npc(id)
	dialogue.start(speaker, lines)
	EventBus.tutorial_event.emit(StringName("talked_" + id))


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
	_face_npc("npc_%s" % id)
	dialogue.start(CorruptedNpcs.display_name(id), lines)
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
			if not levels_gained.is_empty():
				_show_level_up(levels_gained), CONNECT_ONE_SHOT)


## New brief, Part E: talking to a corrupted NPC always plays a short line (corrupted/hinting at
## their zone before they're freed, calmer/still hinting after) and then starts the fight - win or
## lose, they can always be challenged again (D68); only a first win pays out.
func _talk_corrupted_npc(id: String) -> void:
	_face_npc("npc_%s" % id)
	var story: StoryText = load(STORY_PATH) as StoryText
	var defeated: bool = Session.flag(CorruptedNpcs.unlock_flag(id))
	var lines: Array[String] = [] as Array[String]
	if story != null:
		lines = story.npc_victory_lines(id) if defeated else story.npc_intro_lines(id)
	dialogue.start(CorruptedNpcs.display_name(id), lines)
	dialogue.finished.connect(func() -> void: Session.challenge_corrupted_npc(id), CONNECT_ONE_SHOT)


## Fourth brief, Part F: The Restless Cairn - talking to it always plays a short line ("placeholder
## dialogue before"), then starts the scripted battle. Win or lose, it can always be challenged
## again (same repeatable-but-unrewarded-past-the-first-win choice as the corrupted NPCs, D68);
## only a first win pays out.
func _talk_graveyard() -> void:
	var story: StoryText = load(STORY_PATH) as StoryText
	var lines: Array[String] = story.graveyard_intro_lines if story != null else [] as Array[String]
	dialogue.start("The Restless Cairn", lines)
	dialogue.finished.connect(func() -> void: Session.challenge_graveyard_boss(), CONNECT_ONE_SHOT)


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
		lines = story.graveyard_victory_lines if won else story.graveyard_defeat_lines
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
			if not levels_gained.is_empty():
				_show_level_up(levels_gained), CONNECT_ONE_SHOT)


func _elder_lines() -> Array[String]:
	var story: StoryText = StoryText.shared()
	if not Session.flag(&"elder_greeted"):
		Session.set_flag(&"elder_greeted")
		return story.get_lines("town.elder.first")
	if Session.flag(&"primm_defeated"):
		return story.get_lines("town.elder.postgame")
	var freed: int = Session.completed_zone_count()
	if freed > 0:
		var lines: Array[String] = story.get_lines("town.elder.progress.%d" % mini(freed, 4))
		lines.append_array(story.get_lines("town.elder.return"))
		return lines
	return story.get_lines("town.elder.return")


func _guard_lines() -> Array[String]:
	return StoryText.shared().get_lines("town.guard")


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
	if not Session.deck_is_valid():
		hud.toast("Your deck is not ready for the vault.", Color("ff8a85"))
		Audio.sfx(&"ui_error")
		return
	_locked = true
	var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, plan.dungeon_name, "%s

You are fully healed on entry. Lose a duel and you are carried back to town." % plan.story, "Descend", "Not yet")
	dialog.confirmed.connect(func() -> void:
		Audio.sfx(&"door")
		Session.enter_town_side_dungeon())
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
func _use_well() -> void:
	var color: Affinity.Type = Session.profile.primary_affinity
	hud.toast("The %s spring hums. It knows you." % UIStyle.affinity_name(color), UIStyle.affinity_color(color).lightened(0.3))
	Audio.sfx(&"ui_confirm")
	_well_burst(color)


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
	# A finished quest gets its own "Quest Complete" box (Session.pending_popups), so only new quests toast.
	if is_new:
		hud.queue_toast(text, UIStyle.GOLD)


## Part E: level, XP, stats, item and equipment slots. Hotkey C (global, see _unhandled_input) or
## the HUD button; also reachable from the rewards screen right after leveling up.
func _open_character_screen() -> void:
	var screen: CharacterScreen = CharacterScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


## New brief, Part A: the same level-up popup used after a dungeon battle, reused here for
## level-ups from any other source (a corrupted NPC's first win, the dev shrine).
func _show_level_up(gained: Array[LevelData]) -> void:
	var screen: LevelUpScreen = LevelUpScreen.new()
	screen.setup(gained)
	_open_overlay(screen)
	screen.finished.connect(_close_overlay)


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
		Session.challenge_ninja(), CONNECT_ONE_SHOT)


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


func _show_reward_box(summary: RewardSummary) -> void:
	var popup: RewardPopup = RewardPopup.make(summary)
	_open_overlay(popup)
	popup.finished.connect(_close_overlay)


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
	Audio.sfx(&"door")
	hud.toast("Something deep in the vault unlocks.", UIStyle.GOLD)
	Session.save_game()


func _open_vault() -> void:
	player.face(town.anchors["vault"] as Vector3)
	if not Condition.met(_vault_condition(), Session.unlock_state()):
		hud.toast("Sealed. Somewhere nearby, an old lever might help.", Color("ffcf70"))
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


func _open_vendor() -> void:
	if not Session.has_profile():
		return
	var screen: VendorScreen = VendorScreen.new()
	screen.pack_vendor_id = PackData.VENDOR_CARD
	screen.pack_story_prefix = "pack.card_vendor"
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)
	EventBus.tutorial_event.emit(&"vendor_opened")


## Brief 9, Part F: Crucible & Co. Locked until 2 zones are free: visible and shuttered, with a hint from the note on the
## door. Open: Auntie Alembic greets you and the crafting screen opens.
func _use_alchemist() -> void:
	var story: StoryText = StoryText.shared()
	if not Session.alchemist_unlocked():
		_face_npc("alchemist")
		dialogue.start(story.text("town.alchemist.name"), story.get_lines("town.alchemist.locked"))
		hud.toast("%s (%d of %d zones free)" % ["Crucible & Co. is closed", Session.completed_zone_count(), ZoneCompletion.ALCHEMIST_UNLOCK_COUNT], Color("ffcf70"))
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
		Session.start_arena_battle(encounter_id))
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
	var lines: Array[String] = story.equipment_vendor_return_lines
	if not Session.flag(&"equipment_vendor_seen"):
		Session.set_flag(&"equipment_vendor_seen")
		lines = story.equipment_vendor_intro_lines
	dialogue.start("Bertram Beetsworth", lines)
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
		hud.toast("The way to %s is sealed. Defeat its corrupted guardian to open it." % info.display_name, info.tint.lightened(0.35))
		Audio.sfx(&"ui_error")
		return
	Audio.sfx(&"door")
	if ZoneDefs.has_def(zone_id):
		Session.enter_zone(zone_id)
		return
	Session.enter_zone_portal(zone_id)


func _use_gate() -> void:
	_face_npc("guard")
	if not Session.deck_is_valid():
		var problems: Array[DeckValidator.Issue] = Session.deck_issues()
		var message: String = problems[0].message if not problems.is_empty() else "Your deck is not legal."
		hud.toast("Your deck is not ready: %s" % message, Color("ff8a85"))
		Audio.sfx(&"ui_error")
		return
	var dialog: ConfirmDialog = ConfirmDialog.ask(
		_overlay_layer, "Trial of the Hollow",
		"Enter the cave? You are fully healed on entry, and your HP carries from fight to fight. Lose a duel and you are carried back to town.",
		"Enter", "Not yet",
	)
	_locked = true
	dialog.confirmed.connect(func() -> void:
		Audio.sfx(&"door")
		Session.begin_trial())
	dialog.cancelled.connect(func() -> void: _locked = false)


# ---- Overlays ---------------------------------------------------------------------------


## Minimap points of interest (brief 6, Part C): an explicit whitelist by spot id. The hidden chest,
## lever, vault, secret dealer and dev shrine are deliberately NOT listed - secrets never show.
const POI_KINDS: Dictionary = {
	"well": MapPoi.Kind.HEAL, "vendor": MapPoi.Kind.VENDOR, "item_vendor": MapPoi.Kind.VENDOR,
	"equipment_vendor": MapPoi.Kind.VENDOR, "pack_vendor": MapPoi.Kind.VENDOR, "tailor": MapPoi.Kind.VENDOR, "deck": MapPoi.Kind.INTERACTABLE, "codex": MapPoi.Kind.INTERACTABLE,
	"elder": MapPoi.Kind.INTERACTABLE, "guard": MapPoi.Kind.INTERACTABLE, "gate": MapPoi.Kind.DUNGEON,
	"graveyard_cairn": MapPoi.Kind.CHALLENGE,
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
	_station.build(travel.get_lines("travel.sign.town"), true)
	town.obstacles.append(Vector3(pos.x, pos.z, 1.3))
	var operator: Node3D = ModelKit.character("Barbarian")
	ModelKit.tint(operator, Color(1.0, 0.8, 0.65))
	ModelKit.place(self, operator, town.anchors["npc_rift_station"] as Vector3, 40.0, TownPlayer.MODEL_SCALE * 1.3)
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
			_camera.position = player.position + camera_offset * Settings.camera_zoom
			return
	# Hidden chests (Part D) have no Spot - a dev-only screenshot convenience, not a gameplay path.
	if town.anchors.has(spot_id):
		player.position = (town.anchors[spot_id] as Vector3) + Vector3(0.0, 0.0, 1.8)
		_camera.position = player.position + camera_offset * Settings.camera_zoom


func _screenshot_open(what: String) -> void:
	match what:
		"well":
			_use_well()
		"deck":
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
		"codex":
			_open_codex()
		"wardrobe":
			_open_wardrobe()
		"character":
			_open_character_screen()
		"alchemist":
			_open_alchemist()
		"arena":
			_open_arena()
		"quests":
			_open_quest_log()
		"map":
			_open_full_map()
		"chest_popup":
			_show_reward_box(Session.grant_chest_reward({"gold": 80, "item": "healing_draught", "card": "C-29", "equipment": "hover_boots", "pack": "gilded_gourmand"}, "Hidden chest"))
		"quest_popup":
			_show_reward_box(_sample_quest_summary())
		"level_popup":
			_show_level_up(Session.grant_dev_level())



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
		"chest", "lever":
			return false
		"alchemist":
			return Session.alchemist_unlocked()
		"arena":
			return Session.arena_unlocked()
		"pack_vendor":
			return Session.completed_zone_count() >= 1 or Session.flag(&"pack_vendor_seen")
	return true
