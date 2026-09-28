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


const CAMERA_OFFSET: Vector3 = Vector3(0.0, 8.4, 7.0)
## Three placeholder secrets proving the Condition system (docs/design/open_questions.md D38):
## a hidden chest, a locked vault that opens once its lever is pulled, and a hidden vendor who
## only appears once the chest has been found.
const HIDDEN_CHEST_SECRET: String = "harbor_chest"
const VAULT_LEVER_FLAG: StringName = &"vault_lever_pulled"
const HIDDEN_VENDOR_SECRET: String = "harbor_chest"
## True for spots that are people to talk to, as opposed to objects/gates.
const NPC_SPOT_IDS: Array[String] = ["elder", "guard", "vendor", "hidden_vendor"]
## How close (in screen pixels) a click has to land to a spot's marker to count as
## "clicking the NPC", since the fixed camera has no 3D picking set up.
const CLICK_PICK_RADIUS: float = 90.0

var town: TownBuilder = TownBuilder.new()
var player: TownPlayer
var spots: Array[Spot] = []
var hud: TownHud
var dialogue: DialogueBox
var _camera: Camera3D
var _overlay_layer: Control
var _overlay: Control
var _near: Spot
var _time: float = 0.0
var _npcs: Dictionary = {}
var _well_light: OmniLight3D
var _well_particles: CPUParticles3D
var _screenshot_args: Dictionary = {}
var _locked: bool = false


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
	if Session.deck == null:
		Session.new_game()
	_ensure_input_actions()
	add_child(WorldLook.environment(&"day"))
	add_child(WorldLook.sun(&"day"))
	town.build(self)
	_build_actors()
	_build_spots()
	_build_portal_barriers()
	_build_camera()
	_build_ui()
	_refresh_objective()
	EventBus.tutorial_event.emit(&"town_entered")
	if _screenshot_args.has("at"):
		_teleport(str(_screenshot_args["at"]))
	if _screenshot_args.has("open"):
		_screenshot_open.call_deferred(str(_screenshot_args["open"]))
	if Session.town_notice != "":
		hud.toast(Session.town_notice, UIStyle.GOLD)
		Session.town_notice = ""
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
	player = TownPlayer.new()
	add_child(player)
	player.setup(town, "Knight", spawn)
	_add_npc("vendor", "Rogue_Hooded", town.anchors["npc_market"] as Vector3, 200.0)
	_add_npc("elder", "Mage", town.anchors["npc_well"] as Vector3, 250.0)
	_add_npc("guard", "Barbarian", town.anchors["npc_gate"] as Vector3, 160.0)
	if Session.found_secret(HIDDEN_VENDOR_SECRET):
		_add_npc("hidden_vendor", "Rogue_Hooded", town.anchors["hidden_vendor"] as Vector3, 100.0)
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


func _add_npc(id: String, model_name: String, position: Vector3, yaw: float) -> void:
	var npc: Node3D = ModelKit.character(model_name)
	ModelKit.place(self, npc, position, yaw, TownPlayer.MODEL_SCALE)
	var animation: AnimationPlayer = ModelKit.animation_player(npc)
	if animation != null and animation.has_animation("Idle"):
		animation.play("Idle")
		animation.seek(randf() * 1.5)
	_npcs[id] = npc
	town.obstacles.append(Vector3(position.x, position.z, 0.3))


func _build_spots() -> void:
	_add_spot("well", "Wellspring", town.anchors["well"] as Vector3, 1.7)
	_add_spot("vendor", "Card Vendor", town.anchors["npc_market"] as Vector3, 1.5)
	_add_spot("deck", "Deck Station", town.anchors["deck"] as Vector3, 1.6)
	_add_spot("gate", "Trial of the Hollow", town.anchors["gate"] as Vector3, 1.7)
	_add_spot("elder", "Elder Maren", town.anchors["npc_well"] as Vector3, 1.4)
	_add_spot("guard", "Gatekeeper Brannoch", town.anchors["npc_gate"] as Vector3, 1.4)
	_add_spot("codex", "Hall of Records", town.anchors["codex"] as Vector3, 1.6)
	_add_spot("chest", "A Hidden Chest", town.anchors["chest"] as Vector3, 1.3)
	_add_spot("lever", "An Old Lever", town.anchors["lever"] as Vector3, 1.2)
	_add_spot("vault", "The Sealed Vault", town.anchors["vault"] as Vector3, 1.8)
	if Session.found_secret(HIDDEN_VENDOR_SECRET):
		_add_spot("hidden_vendor", "A Secret Dealer", town.anchors["hidden_vendor"] as Vector3, 1.5)
	# Part G: 5 placeholder zone portals (one per element, one for the final area), now at the
	# edges of the (bigger) map - see ZonePortals/ZonePlaceholderScene. Real zones are not built
	# this pass. New brief, Part C/E: the 4 element entrances start locked (see
	# _portal_is_locked); the final entrance is always open.
	for info: ZonePortals.Info in ZonePortals.all():
		_add_spot("portal_%s" % info.id, "%s (coming soon)" % info.display_name, town.anchors["portal_%s" % info.id] as Vector3, 1.6)


## New brief, Part E sets this flag on defeating the matching corrupted NPC; the final entrance
## has no NPC and is never locked.
static func _portal_unlock_flag(zone_id: String) -> StringName:
	return StringName("%s_zone_unlocked" % zone_id)


func _portal_is_locked(zone_id: String) -> bool:
	return zone_id != ZonePortals.FINAL_ID and not Session.flag(_portal_unlock_flag(zone_id))


## A translucent, element-tinted barrier in front of each still-locked entrance - built once from
## a flag snapshot at scene load (unlocking always happens in a different scene, via a battle, so
## it never needs to change live mid-visit).
func _build_portal_barriers() -> void:
	for info: ZonePortals.Info in ZonePortals.all():
		if not _portal_is_locked(info.id):
			continue
		var anchor: Vector3 = town.anchors.get("portal_%s" % info.id, Vector3.ZERO) as Vector3
		var barrier: MeshInstance3D = MeshInstance3D.new()
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = Vector3(1.7, 1.9, 0.1)
		barrier.mesh = mesh
		barrier.position = anchor + Vector3(0, 0.95, 0)
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color(info.tint.r, info.tint.g, info.tint.b, 0.32)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.emission_enabled = true
		material.emission = info.tint
		material.emission_energy_multiplier = 0.9
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		barrier.material_override = material
		add_child(barrier)


func _add_spot(id: String, title: String, position: Vector3, radius: float) -> void:
	var spot: Spot = Spot.new()
	spot.id = id
	spot.title = title
	spot.position = position
	spot.radius = radius
	# A bobbing gem marks each spot; a floating name plate tells what it is.
	var marker: MeshInstance3D = MeshInstance3D.new()
	var mesh: PrismMesh = PrismMesh.new()
	mesh.size = Vector3(0.22, 0.32, 0.22)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = UIStyle.GOLD
	material.emission_enabled = true
	material.emission = UIStyle.GOLD
	material.emission_energy_multiplier = 1.6
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = material
	marker.mesh = mesh
	marker.rotation_degrees.x = 180.0
	marker.position = position + Vector3(0, 1.9 if id in NPC_SPOT_IDS else 2.5, 0)
	add_child(marker)
	spot.marker = marker
	var plate: Label3D = Label3D.new()
	plate.text = title
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
	_camera.position = player.position + CAMERA_OFFSET
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
	dialogue = DialogueBox.new()
	host.add_child(dialogue)
	var overlay_canvas: CanvasLayer = CanvasLayer.new()
	overlay_canvas.layer = 8
	add_child(overlay_canvas)
	_overlay_layer = UIKit.layer_host(overlay_canvas)


# ---- Frame update -----------------------------------------------------------------------


func _process(delta: float) -> void:
	_time += delta
	var target: Vector3 = player.position + CAMERA_OFFSET
	_camera.position = _camera.position.lerp(target, 1.0 - exp(-5.0 * delta))
	_camera.rotation_degrees = Vector3(-atan2(CAMERA_OFFSET.y, CAMERA_OFFSET.z) * 180.0 / PI, 0.0, 0.0)
	for spot: Spot in spots:
		var base_y: float = 1.9 if spot.id in NPC_SPOT_IDS else 2.5
		spot.marker.position.y = base_y + sin(_time * 2.4 + spot.position.x) * 0.08
		spot.marker.rotation_degrees.y += 60.0 * delta
		var distance: float = Vector2(player.position.x - spot.position.x, player.position.z - spot.position.z).length()
		spot.plate.modulate.a = clampf(1.0 - (distance - 2.6) / 1.6, 0.0, 1.0)
		spot.plate.outline_modulate.a = spot.plate.modulate.a
		spot.plate.visible = spot.plate.modulate.a > 0.02
	_well_light.light_energy = 1.4 + sin(_time * 1.7) * 0.35
	_update_nearest()
	player.input_enabled = not _locked and not dialogue.active


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



func _prompt_text(spot: Spot) -> String:
	if spot.id in NPC_SPOT_IDS:
		return "Talk"
	match spot.id:
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
		"vault":
			return "Open the vault" if Session.flag(VAULT_LEVER_FLAG) else "Try the sealed door"
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
		"vendor":
			_talk_vendor()
		"deck":
			_open_deck_station()
		"gate":
			_use_gate()
		"elder":
			_talk_npc("elder", "Elder Maren", _elder_lines())
		"guard":
			_talk_npc("guard", "Gatekeeper Brannoch", _guard_lines())
		"codex":
			_open_codex()
		"chest":
			_open_chest()
		"lever":
			_pull_lever()
		"vault":
			_open_vault()
		"hidden_vendor":
			_talk_hidden_vendor()
		_:
			if spot.id.begins_with("portal_"):
				_use_zone_portal(spot.id.trim_prefix("portal_"))


func _face_npc(id: String) -> void:
	var npc: Node3D = _npcs.get(id) as Node3D
	if npc != null:
		var offset: Vector3 = player.position - npc.position
		npc.rotation.y = atan2(offset.x, offset.z)
	player.face((npc.position if npc != null else player.position))


func _talk_npc(id: String, speaker: String, lines: Array[String]) -> void:
	_face_npc(id)
	dialogue.start(speaker, lines)
	EventBus.tutorial_event.emit(StringName("talked_" + id))


func _elder_lines() -> Array[String]:
	if not Session.flag(&"elder_greeted"):
		Session.set_flag(&"elder_greeted")
		return [
			"You made it out of the Hollow, and with a deck to your name. Not everyone does.",
			"This town is yours to explore now. The spring in the square still hums, if you ever want to listen to it.",
			"Buy cards from Sable, refine your deck at the station by the tavern, and the gate stays open if you want to test yourself again.",
		] as Array[String]
	return [
		"The spring recognizes you now. There are other springs and other Wanderers, but that is a story for another day.",
		"Buy cards, build a better deck, and try the Trial again if you miss the gold.",
	] as Array[String]


func _guard_lines() -> Array[String]:
	return [
		"You came back from the Hollow. Not many do on the first try.",
		"The gate stays open. The scavengers restock, and they pay well.",
	] as Array[String]


func _talk_vendor() -> void:
	_face_npc("vendor")
	var lines: Array[String] = ["Cards for coin, friend. Everything on the table is honest, mostly."] as Array[String]
	if not Session.flag(&"vendor_seen"):
		Session.set_flag(&"vendor_seen")
		lines = [
			"Well met, Wanderer! Sable the Trader, at your service.",
			"You start with common neutral cards, but the colors are where the power is. Have a look, then check the Deck Station to put your purchases to use.",
		] as Array[String]
	dialogue.start("Sable the Trader", lines)
	dialogue.finished.connect(_open_vendor, CONNECT_ONE_SHOT)


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


## Part E: level, XP, stats, item and equipment slots. Hotkey C (global, see _unhandled_input) or
## the HUD button; also reachable from the rewards screen right after leveling up.
func _open_character_screen() -> void:
	var screen: CharacterScreen = CharacterScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


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
	if Session.found_secret(HIDDEN_CHEST_SECRET):
		hud.toast("The chest is empty now.", UIStyle.MUTED)
		return
	Session.discover_secret(HIDDEN_CHEST_SECRET)
	Session.add_gold(60)
	Audio.sfx(&"coins")
	Audio.sfx(&"ui_confirm")
	hud.set_gold(Session.gold)
	hud.toast("A hidden chest! +60 gold.", UIStyle.GOLD)
	# Rebuilding the spots/actors would be needed to show the hidden vendor right now; simplest
	# and honest: it appears the next time the player enters town, once the secret is saved.
	Session.save_game()


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
	var reward: CardData = Session.content.card("thornback_colossus")
	if reward != null:
		Session.add_cards([reward] as Array[CardData])
	Audio.sfx(&"card_draw")
	Audio.sfx(&"ui_confirm")
	hud.toast("The vault opens. %s joins your collection." % (reward.display_name if reward != null else "A card"), UIStyle.GOLD)
	Session.save_game()


func _talk_hidden_vendor() -> void:
	_face_npc("hidden_vendor")
	var lines: Array[String] = ["You found the chest, so I suppose you've earned a look. Epic and Legendary goods, quiet prices."] as Array[String]
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
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)
	EventBus.tutorial_event.emit(&"vendor_opened")


## Part G: a placeholder zone portal. Loads the reusable "coming soon" template
## (ZonePlaceholderScene) - no real zone exists yet for any of the 5. New brief, Part C/E: a
## locked element entrance shows a barrier message instead of loading the zone.
func _use_zone_portal(zone_id: String) -> void:
	var info: ZonePortals.Info = ZonePortals.find(zone_id)
	if info == null:
		return
	player.face(town.anchors["portal_%s" % zone_id] as Vector3)
	if _portal_is_locked(zone_id):
		hud.toast("The %s entrance is sealed. Defeat their corrupted guardian to open it." % info.display_name, info.tint.lightened(0.35))
		Audio.sfx(&"ui_error")
		return
	Audio.sfx(&"door")
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
		"Enter the cave? You are fully healed on entry, and your life carries from fight to fight. Lose a duel and you are carried back to town.",
		"Enter", "Not yet",
	)
	_locked = true
	dialog.confirmed.connect(func() -> void:
		Audio.sfx(&"door")
		Session.begin_trial())
	dialog.cancelled.connect(func() -> void: _locked = false)


# ---- Overlays ---------------------------------------------------------------------------


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
	hud.set_objective("The Trial is cleared. Buy cards, refine your deck at the Deck Station, and replay the Trial for gold.")


# ---- Screenshot helpers -----------------------------------------------------------------


func _teleport(spot_id: String) -> void:
	for spot: Spot in spots:
		if spot.id == spot_id:
			player.position = spot.position + Vector3(0.0, 0.0, 0.5)
			_camera.position = player.position + CAMERA_OFFSET


func _screenshot_open(what: String) -> void:
	match what:
		"well":
			_use_well()
		"deck":
			_open_deck_station()
		"vendor":
			_open_vendor()
		"dialogue":
			_talk_npc("elder", "Elder Maren", _elder_lines())
		"gate":
			_use_gate()
		"codex":
			_open_codex()
		"character":
			_open_character_screen()
