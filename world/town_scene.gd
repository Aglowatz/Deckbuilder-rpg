class_name TownScene
extends Node3D
## The walkable starter town: a follow camera, the hero, two NPCs and the interactable spots
## (Wellspring, card vendor, deck station, dungeon gate).

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
	var spawn: Vector3 = town.anchors["spawn"] as Vector3 + Vector3(0, 0, -0.4)
	player = TownPlayer.new()
	add_child(player)
	player.setup(town, "Knight", spawn)
	_add_npc("vendor", "Rogue_Hooded", town.anchors["npc_market"] as Vector3, 200.0)
	_add_npc("elder", "Mage", town.anchors["npc_well"] as Vector3, 250.0)
	_add_npc("guard", "Barbarian", town.anchors["npc_gate"] as Vector3, 160.0)
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
	marker.position = position + Vector3(0, 1.9 if id in ["elder", "guard", "vendor"] else 2.5, 0)
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
		var base_y: float = 1.9 if spot.id in ["elder", "guard", "vendor"] else 2.5
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
	match spot.id:
		"well":
			return "Approach the Wellspring" if not Session.flag(&"wellspring_chosen") else "Touch the Wellspring"
		"vendor":
			return "Trade with the Card Vendor"
		"deck":
			return "Open the Deck Station"
		"gate":
			return "Enter the Trial of the Hollow"
		"elder":
			return "Talk to Elder Maren"
		"guard":
			return "Talk to Gatekeeper Brannoch"
	return spot.title


func _unhandled_input(event: InputEvent) -> void:
	if _locked or dialogue.active or _near == null:
		return
	if event.is_action_pressed(&"interact"):
		get_viewport().set_input_as_handled()
		_interact(_near)


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
	if not Session.flag(&"wellspring_chosen"):
		return [
			"Ah, a Wanderer. You have the look of someone who hears it too.",
			"Four Wellsprings hum beneath the world. One of them has been calling to you since the road.",
			"Kneel at the well in the middle of town and answer. Then take the north road to the Trial of the Hollow.",
		] as Array[String]
	if not Session.profile.intro_dungeon_cleared:
		return [
			"The spring has taken to you. I can feel it from here.",
			"Go north, through the gate. The Hollow is only a shallow cave, but it will test the deck you carry.",
			"If it goes badly, come back and rebuild. The Deck Station is by the tavern.",
		] as Array[String]
	return [
		"The spring recognizes you now. Five techniques, given freely.",
		"There are other springs and other Wanderers. But that is a story for another day.",
		"Until then: buy cards, build a better deck, and try the Trial again if you miss the gold.",
	] as Array[String]


func _guard_lines() -> Array[String]:
	if not Session.flag(&"wellspring_chosen"):
		return [
			"Halt. The Hollow is no place for someone the springs have not marked.",
			"Talk to Elder Maren by the well. Then come back and I will open the gate.",
		] as Array[String]
	if not Session.profile.intro_dungeon_cleared:
		return [
			"Two guardians, a well that asks questions, a shrine to rest at, and something big at the bottom.",
			"Life carries from fight to fight, so use the shrine wisely. Your deck needs at least 45 cards, at most two colors.",
			"Good luck, Wanderer. The gate is open.",
		] as Array[String]
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


func _use_well() -> void:
	if not Session.flag(&"wellspring_chosen"):
		var choice: WellspringChoice = WellspringChoice.new()
		_open_overlay(choice)
		choice.chosen.connect(_on_wellspring_chosen.bind(choice))
		choice.closed.connect(_close_overlay)
		return
	var color: Affinity.Type = Session.profile.primary_affinity
	hud.toast("The %s spring hums. It knows you." % UIStyle.affinity_name(color), UIStyle.affinity_color(color).lightened(0.3))
	_well_burst(color)


func _on_wellspring_chosen(color: Affinity.Type, _choice: WellspringChoice) -> void:
	Session.choose_affinity(color)
	_close_overlay()
	Audio.sfx(&"heal")
	Audio.sfx(&"ui_confirm")
	_well_burst(color)
	hud.toast("You answered the %s spring. Your starter deck is ready." % UIStyle.affinity_name(color), UIStyle.affinity_color(color).lightened(0.3))
	_refresh_objective()
	EventBus.tutorial_event.emit(&"wellspring_chosen")


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
	if not Session.has_profile():
		dialogue.start("Deck Station", ["Your deck is empty. Visit the Wellspring first to receive a starter deck."] as Array[String])
		return
	Session.set_flag(&"deck_station_seen")
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)
	EventBus.tutorial_event.emit(&"deck_station_opened")


func _open_vendor() -> void:
	if not Session.has_profile():
		return
	var screen: VendorScreen = VendorScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)
	EventBus.tutorial_event.emit(&"vendor_opened")


func _use_gate() -> void:
	_face_npc("guard")
	if not Session.has_profile():
		dialogue.start("Sealed Gate", ["The gate will not open. Something in the town's Wellspring calls to you first."] as Array[String])
		return
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
	if not Session.flag(&"wellspring_chosen"):
		hud.set_objective("Walk to the [b]Wellspring[/b] in the middle of town and answer its call.")
	elif not Session.profile.intro_dungeon_cleared:
		hud.set_objective("Enter the [b]Trial of the Hollow[/b] through the gate in the north.\n[color=#a89bb5]Tip: check your deck at the Deck Station first.[/color]")
	else:
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
