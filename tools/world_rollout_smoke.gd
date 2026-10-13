class_name WorldRolloutSmoke
extends Node
## World rollout final e2e (docs/art/world_rollout.md, Part F) with human-style input (real injected keys and clicks): a NEW game (no character-design screen, the default look,
## the hero is a painted sprite), a walk through the starting area, the town (talk to painted NPCs of each kind with their portrait, open the clothing vendor and see the items arriving soon),
## every zone and both sides of the Capital; a screenshot of every area and the frame rate over a few seconds of walking in each. Deliberate shortcuts: the tutorial dungeon is
## not replayed (`Session.ensure_game()` after the starting area), zone scenes are opened directly instead of walking the bridges.
## Screenshots: _screenshots/rollout_smoke/.   Godot --path . res://tools/world_rollout_launcher.tscn

const SHOT_DIR: String = "res://_screenshots/rollout_smoke/"
const TAG: String = "rollout_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held: Dictionary = {}
var _shots: int = 0
var _fps_rows: PackedStringArray = []


func run() -> void:
	Session.save_enabled = false
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var only: String = OS.get_environment("SMOKE_ONLY")
	if only == "":
		var start: StartingAreaScene = await _wait_for(StartingAreaScene) as StartingAreaScene
		if start == null:
			_finish(false, "the starting area never loaded")
			return
		await _flow_new_game(start)
	if only != "zones":
		var town: TownScene = await _go("res://scenes/town.tscn", TownScene) as TownScene
		if town == null:
			_finish(false, "town never loaded")
			return
		if only == "" or only == "town":
			await _flow_town(town)
		if only == "town":
			_finish(_failures.is_empty(), "town only")
			return
	await _flow_zone("res://scenes/gainlands_zone.tscn", GainlandsScene, "gainlands", "brenda", "MOUNTAIN", "NPC-MOUNTAIN")
	await _flow_zone("res://scenes/dna_zone.tscn", DnaScene, "dna", "barnaby", "GERALD", "NPC-GERALD")
	await _flow_zone("res://scenes/buffet_zone.tscn", BuffetScene, "buffet", "odalys", "BASIL", "NPC-BASIL")
	await _flow_zone("res://scenes/heap_zone.tscn", HeapScene, "heap", "marigold", "BRAMBLE", "NPC-BRAMBLE")
	await _flow_capital()
	print("%s: fps (Medium, window 1600x900, walking):" % TAG)
	for row: String in _fps_rows:
		print("%s:   %s" % [TAG, row])
	_finish(_failures.is_empty(), "new game without a look choice, starting area, town with sprite and 3D NPCs and the clothing vendor, four zones, the Capital outside and inside (%d screenshots)" % _shots)


# ---- 1: a new game ---------------------------------------------------------------------------------------------------------------


func _flow_new_game(start: StartingAreaScene) -> void:
	await driver.seconds(1.5)
	# The wake-up story still comes first, then the first words; nothing asks for a hat or a cloak.
	var saw_wardrobe: bool = false
	for step: int in range(14):
		if _find(start, WardrobeScreen) != null:
			saw_wardrobe = true
		if start.dialogue != null and start.dialogue.active:
			break
		await driver.tap_key(KEY_E)
		await driver.seconds(0.6)
	_check(not saw_wardrobe, "no character-design screen at the start of a new game")
	_check(start.player.model is SpriteActor, "the hero is the painted sprite")
	_check(Session.cosmetics.hat_id == "" and Session.cosmetics.cloak_id == "" and Session.cosmetics.cloak_dye == Dye.NATURAL, "the default look: the dark teal hooded cloak, no hat")
	await _dismiss(start.dialogue)
	await driver.seconds(0.6)
	# Take control: the Rescuer scene is a long conversation, the walk starts from the clearing.
	Session.ensure_game()
	start._locked = false
	start.dialogue.visible = false
	await _walk_for(start, [KEY_A, KEY_W], 1.0)
	await _shot("a1_starting_area")
	_fps_row("starting area", await _measure_fps_walking(start, KEY_D, 4.0))


# ---- 2: the town ------------------------------------------------------------------------------------------------------------------


func _flow_town(town: TownScene) -> void:
	await driver.seconds(1.0)
	await _shot("b1_town_square")
	_fps_row("town square", await _measure_fps_walking(town, KEY_D, 4.0))
	# A painted NPC: Elder Maren.
	var elder: SpriteActor = town._npcs["elder"] as SpriteActor
	_check(elder != null, "Elder Maren is a painted sprite")
	await _walk_to(town, elder.position + Vector3(0.0, 0.0, 0.95), 0.9)
	await driver.seconds(0.5)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.9)
	_check(town.dialogue.active, "Elder Maren talks")
	if elder != null:
		_check(elder.sprite.current_key == "FRONT_TALK", "her TALK pose shows during the dialogue")
	await _shot("b2_talk_sprite_npc")
	await _dismiss(town.dialogue)
	await driver.seconds(0.6)
	# Bertram Beetsworth (equipment vendor, a human) and a corrupted NPC (Brick Bronson): painted sprites whose portrait matches.
	await _talk_town(town, "equipment_vendor", "BEETSWORTH", "V-BEETSWORTH", "b3_talk_human_vendor")
	await _talk_town(town, "npc_beefcake", "BRONSON", "NPC-BRONSON", "b3b_talk_corrupted")
	# The clothing vendor.
	await _walk_to(town, (town.town.anchors["npc_tailor"] as Vector3) + Vector3(0.0, 0.0, 0.95), 0.9)
	await driver.seconds(0.4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.6)
	await _dismiss(town.dialogue)
	await driver.seconds(0.8)
	var shop: TailorScreen = _find(town, TailorScreen) as TailorScreen
	_check(shop != null, "the clothing vendor's shop opens")
	if shop != null:
		var ready_items: int = 0
		for item: CosmeticData in CosmeticCatalog.all():
			if SpriteCosmetics.art_ready(item):
				ready_items += 1
		var buy: Button = shop.find_child("Buy_hat_chef", true, false) as Button
		_check(buy != null, "the Chef's Toque is listed")
		if buy != null and ready_items == 0:
			_check(buy.disabled and buy.text == "Soon", "items without art are 'arriving soon' and cannot be bought")
		await _shot("b4_clothing_vendor")
		await driver.tap_key(KEY_ESCAPE)
		await driver.seconds(0.5)
	await _walk_to(town, Vector3(26.0, 0.0, 14.0), 1.5)
	# The baker walks his round.
	_check(town._npcs["mannequin"] is Node3D and not (town._npcs["mannequin"] is SpriteActor), "the shop-window mannequin (no list NPC) is the only 3D figure left in the town")
	_check(town._baker != null, "the badger baker wanders the plaza")
	await _shot("b5_baker_and_plaza")


# ---- 3: zones ---------------------------------------------------------------------------------------------------------------------


func _flow_zone(path: String, kind: Variant, label: String, talk_spot: String = "", character: String = "", portrait: String = "") -> void:
	var zone: ZoneScene = await _go(path, kind) as ZoneScene
	if zone == null:
		_check(false, "%s loaded" % label)
		return
	await driver.seconds(1.5)
	_check(zone.player.model is SpriteActor, "%s: the hero is the painted sprite" % label)
	_check(zone.look_rig != null, "%s: the world look is installed" % label)
	await _shot("c_%s_arrival" % label)
	_fps_row(label, await _measure_fps_walking(zone, KEY_D, 4.0))
	await _shot("c_%s_walk" % label)
	if talk_spot != "":
		await _talk_zone(zone, talk_spot, character, portrait, "c_%s_talk" % label)


func _flow_capital() -> void:
	var outside: ZoneScene = await _go("res://scenes/capital_zone.tscn", CapitalScene) as ZoneScene
	if outside == null:
		_check(false, "the Capital loaded")
		return
	await driver.seconds(1.5)
	await _shot("d_capital_outside")
	_fps_row("capital outside", await _measure_fps_walking(outside, KEY_D, 4.0))
	# Walk through the gate: the mood changes to the idyll.
	var capital: CapitalScene = outside as CapitalScene
	capital.player.position = Vector3(60.0, 0.0, 70.0)
	await driver.seconds(0.5)
	Session.set_flag(CapitalZone.FLAG_GATE_OPEN)
	await _walk_for(capital, [KEY_W], 5.0)
	capital.player.position = Vector3(60.0, 0.0, 52.0)
	await driver.seconds(1.8)
	_check(capital._inside, "the hero is inside the walls")
	_check(capital.look_rig != null and capital.look_rig.mood_id in [StylePresets.CAPITAL_INSIDE, StylePresets.CAPITAL_INSIDE_DARK, StylePresets.CAPITAL_FREED], "the look changed to the inside mood")
	await _shot("d_capital_inside")
	var citizen: SpriteStroller = capital._npcs.get("citizen_1") as SpriteStroller
	_check(citizen != null and citizen.character == "CITIZEN", "the Capital's citizens are painted wanderers")
	if citizen != null:
		var before: Vector3 = citizen.world_position()
		await driver.seconds(8.0)
		_check(before.distance_to(citizen.world_position()) > 0.2 or citizen.sprite.walking, "a citizen strolled in eight seconds")
		await _talk_zone(capital, "citizen_1", "CITIZEN", "NPC-CITIZEN", "d_capital_citizen_talk")
	_fps_row("capital inside", await _measure_fps_walking(capital, KEY_D, 4.0))


# ---- helpers ---------------------------------------------------------------------------------------------------------------------


## Walk to a town NPC, talk, check the painted sprite, its TALK pose and that the portrait is the list NPC's.
func _talk_town(town: TownScene, id: String, character: String, portrait: String, shot_name: String) -> void:
	var npc: Node3D = town._npcs.get(id) as Node3D
	_check(npc is SpriteActor and (npc as SpriteActor).character == character, "%s is the painted %s" % [id, character])
	if npc == null:
		return
	await _walk_to(town, npc.position + Vector3(0.0, 0.0, 0.95), 0.9)
	await driver.seconds(0.4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.9)
	_check(town.dialogue.active, "%s talks" % id)
	_check(town.dialogue.npc_id == portrait, "%s shows portrait %s (is '%s')" % [id, portrait, town.dialogue.npc_id])
	var actor: SpriteActor = npc as SpriteActor
	if actor != null:
		_check(actor.sprite.current_key == "FRONT_TALK", "%s shows the TALK pose" % id)
	await _shot(shot_name)
	await _dismiss(town.dialogue)
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.5)


## The same in a zone: stand next to the NPC's talk spot, press E, check sprite, TALK pose and portrait.
func _talk_zone(zone: ZoneScene, spot_id: String, character: String, portrait: String, shot_name: String) -> void:
	var spot: ZoneSpot = null
	for candidate: ZoneSpot in zone.spots:
		if candidate.id == spot_id:
			spot = candidate
	if spot == null:
		_check(false, "%s has a talk spot" % spot_id)
		return
	var npc: Node3D = zone._npcs.get(str(spot.data.get("npc", ""))) as Node3D
	_check((npc is SpriteActor and (npc as SpriteActor).character == character) or (npc is SpriteStroller and (npc as SpriteStroller).character == character), "%s is the painted %s" % [spot_id, character])
	await _dismiss(zone.dialogue)
	zone.player.position = spot.position + Vector3(0.0, 0.0, 0.5)
	await driver.seconds(0.7)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.9)
	_check(zone.dialogue.active, "%s talks" % spot_id)
	_check(zone.dialogue.npc_id == portrait, "%s shows portrait %s (is '%s')" % [spot_id, portrait, zone.dialogue.npc_id])
	var actor: SpriteActor = npc as SpriteActor
	if actor != null:
		_check(actor.sprite.current_key == "FRONT_TALK", "%s shows the TALK pose" % spot_id)
	await _shot(shot_name)
	await _dismiss(zone.dialogue)
	await driver.seconds(0.4)
	if _find(zone, OverlayScreen) != null:
		await driver.tap_key(KEY_ESCAPE)
		await driver.seconds(0.5)



func _go(path: String, kind: Variant) -> Node:
	await _release_all()
	get_tree().change_scene_to_file(path)
	await driver.frames(10)
	var scene: Node = await _wait_for(kind)
	await driver.seconds(0.8)
	return scene


func _measure_fps_walking(scene: Node, key: Key, seconds: float) -> String:
	await driver.seconds(1.0)
	await _hold(key, true)
	var frames: PackedFloat32Array = []
	var elapsed: float = 0.0
	while elapsed < seconds:
		await get_tree().process_frame
		var dt: float = get_process_delta_time()
		frames.append(dt)
		elapsed += dt
	await _hold(key, false)
	var sorted: Array = Array(frames)
	sorted.sort()
	var total: float = 0.0
	for value: float in frames:
		total += value
	var avg: float = total / float(maxi(frames.size(), 1))
	return "%.1f fps avg, p95 %.1f ms, worst %.1f ms" % [1.0 / avg, float(sorted[int(float(sorted.size()) * 0.95)]) * 1000.0, float(sorted[sorted.size() - 1]) * 1000.0]


func _fps_row(label: String, text: String) -> void:
	_fps_rows.append("%s: %s" % [label, text])
	print("%s: fps %s: %s" % [TAG, label, text])


func _walk_for(scene: Node, keys: Array, seconds: float) -> void:
	for key: Key in keys:
		await _hold(key, true)
	await driver.seconds(seconds)
	for key: Key in keys:
		await _hold(key, false)


func _release_all() -> void:
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)


func _find(root: Node, kind: Variant) -> Node:
	for node: Node in root.find_children("*", "Control", true, false):
		if is_instance_of(node, kind):
			return node
	return null


func _dismiss(dialogue: DialogueBox) -> void:
	if dialogue == null:
		return
	await driver.frames(5)
	var guard: int = 0
	while dialogue.active and guard < 40:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.2)


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < 40.0:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _walk_to(scene: Node, target: Vector3, radius: float) -> void:
	var player: Node3D = scene.player
	var elapsed: float = 0.0
	var last_pos: Vector3 = player.position
	var stuck_frames: int = 0
	while elapsed < 20.0:
		var offset: Vector3 = target - player.position
		offset.y = 0.0
		if offset.length() < radius * 0.55:
			break
		# Walls and props are in the way now and then: when the hero has not moved for a while, a few steps sideways round the obstacle.
		if player.position.distance_to(last_pos) < 0.02:
			stuck_frames += 2
		else:
			stuck_frames = 0
			last_pos = player.position
		if stuck_frames > 18:
			var side: Key = KEY_D if int(elapsed) % 2 == 0 else KEY_A
			await _release_all()
			await _hold(side, true)
			await driver.seconds(0.9)
			await _hold(side, false)
			stuck_frames = 0
			elapsed += 0.9
			continue
		await _hold(KEY_W, offset.z < -0.35)
		await _hold(KEY_S, offset.z > 0.35)
		await _hold(KEY_A, offset.x < -0.35)
		await _hold(KEY_D, offset.x > 0.35)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	await _release_all()
	if Vector2(player.position.x - target.x, player.position.z - target.z).length() >= radius:
		_note("walk fell back to a short teleport near %s" % str(target))
		player.position = target + Vector3(0.0, 0.0, 0.4)
		await driver.frames(3)


func _hold(key: Key, down: bool) -> void:
	if bool(_held.get(key, false)) == down:
		return
	_held[key] = down
	await driver.key(key, down)


func _shot(shot_name: String) -> void:
	_shots += 1
	await driver.frames(3)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var image: Image = get_tree().root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("%s%s.png" % [SHOT_DIR, shot_name]))
	print("%s: screenshot -> %s.png" % [TAG, shot_name])


func _check(condition: bool, message: String) -> void:
	if condition:
		print("%s: ok    %s" % [TAG, message])
		return
	print("%s: FAIL  %s" % [TAG, message])
	push_error("%s: %s" % [TAG, message])
	_failures.append(message)


func _note(message: String) -> void:
	print("%s: note  %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
