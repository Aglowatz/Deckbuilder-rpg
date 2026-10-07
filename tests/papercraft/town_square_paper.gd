extends TownScene
## Papercraft character test (docs/art/papercraft_test.md). The real town (it is built in code, so this scene extends it instead of copying 1800 lines) with the player, Elder Maren,
## Foil Fenwick and a new Big Hurl drawn as paper cut-outs; P swaps them with the current 3D models. Nothing else changes, the real scenes are untouched, and the real save is never written.
## Open tests/papercraft/town_square_paper.tscn in the editor and press F6, or: godot --path . res://tests/papercraft/town_square_paper.tscn
## Screenshot args (tools/shot.sh): --paper=1|0 (default 1), --still=1 (no wandering), plus the town's own --cam, --pos, --nohud.

const PaperCharacter: GDScript = preload("res://tests/papercraft/paper_character.gd")
const WANDER_SPEED: float = 0.55
const WANDER_RADIUS: float = 1.1
const HURL_SPOT: String = "hurl"
## [town npc id, PAPER art id].
const CAST: Array = [["elder", "NPC-ELDER"], ["pack_vendor", "V-FENWICK"], [HURL_SPOT, "NPC-HURL"]]

var paper_mode: bool = true
var _papers: Dictionary = {}
var _wanderers: Array[Dictionary] = []


func _init() -> void:
	# This test scene must never overwrite the player's real save.
	Session.save_enabled = false


func _ready() -> void:
	super._ready()
	paper_mode = str(_screenshot_args.get("paper", "1")) != "0"
	_add_hurl()
	var hero_height: float = _height_of(player.model)
	var hero: Node3D = PaperCharacter.create("NPC-PLAYER", hero_height, player) as Node3D
	add_child(hero)
	_papers["player"] = hero
	for entry: Array in CAST:
		var id: String = str(entry[0])
		var npc: Node3D = _npcs[id] as Node3D
		var paper: Node3D = PaperCharacter.create(str(entry[1]), _height_of(npc), npc) as Node3D
		add_child(paper)
		_papers[id] = paper
		_wanderers.append({"id": id, "node": npc, "home": npc.position, "target": npc.position, "wait": randf_range(1.0, 4.0), "walking": false})
	_apply_mode()


## Big Hurl has no 3D town model of his own: a scaled-up Barbarian stands in, next to Elder Maren, and is talkable like the others.
func _add_hurl() -> void:
	var base: Vector3 = town.anchors["npc_well"] as Vector3
	var spot_position: Vector3 = base + Vector3(2.4, 0.0, 1.3)
	for offset: Vector3 in [Vector3(2.4, 0, 1.3), Vector3(-2.0, 0, 2.2), Vector3(0.6, 0, 2.6), Vector3(-1.0, 0, -2.0)]:
		if town.is_walkable(base + offset, 0.6):
			spot_position = base + offset
			break
	town.anchors["npc_hurl"] = spot_position
	_add_npc(HURL_SPOT, "Barbarian", spot_position, 200.0)
	var hurl: Node3D = _npcs[HURL_SPOT] as Node3D
	hurl.scale *= 1.3
	_add_spot(HURL_SPOT, "Big Hurl", spot_position, 1.5)


## World height of a model's meshes (so the cut-out stands as tall as the 3D character it replaces).
func _height_of(model: Node3D) -> float:
	var top: float = -INF
	var bottom: float = INF
	for node: Node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.name == ContactShadow.NAME or mesh_instance.mesh == null or not mesh_instance.is_visible_in_tree():
			continue
		var box: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
		top = maxf(top, box.end.y)
		bottom = minf(bottom, box.position.y)
	return maxf(top - bottom, 0.5)


func _apply_mode() -> void:
	player.model.visible = not paper_mode
	for id: String in _papers:
		(_papers[id] as Node3D).visible = paper_mode
	for id: String in _npcs:
		if _papers.has(id):
			(_npcs[id] as Node3D).visible = not paper_mode


func toggle_paper() -> void:
	paper_mode = not paper_mode
	_apply_mode()
	if hud != null:
		hud.toast("Paper characters" if paper_mode else "3D models", UIStyle.GOLD)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_P and not _locked:
		get_viewport().set_input_as_handled()
		toggle_paper()
		return
	super._unhandled_input(event)


func _process(delta: float) -> void:
	super._process(delta)
	for spot: Spot in spots:
		if spot.id == HURL_SPOT:
			spot.marker.position.y = spot.position.y + 2.3 + sin(_time * 2.4 + spot.position.x) * 0.08
	if not dialogue.active and not _locked and not _screenshot_args.has("still"):
		for wanderer: Dictionary in _wanderers:
			_wander(wanderer, delta)


## Occasional small wander around the NPC's home spot; the 3D model walks with its Walking_A clip so both modes show the same behaviour.
func _wander(wanderer: Dictionary, delta: float) -> void:
	var npc: Node3D = wanderer["node"] as Node3D
	var animation: AnimationPlayer = ModelKit.animation_player(npc)
	if not bool(wanderer["walking"]):
		wanderer["wait"] = float(wanderer["wait"]) - delta
		if float(wanderer["wait"]) > 0.0:
			return
		var home: Vector3 = wanderer["home"] as Vector3
		var angle: float = randf() * TAU
		var candidate: Vector3 = home + Vector3(cos(angle), 0.0, sin(angle)) * randf_range(0.5, WANDER_RADIUS)
		if town.is_walkable(candidate) and town.is_walkable(npc.position.lerp(candidate, 0.5)):
			wanderer["target"] = candidate
			wanderer["walking"] = true
			if animation != null and animation.has_animation("Walking_A"):
				animation.play("Walking_A", 0.2)
		else:
			wanderer["wait"] = 1.0
		return
	var target: Vector3 = wanderer["target"] as Vector3
	var to_target: Vector3 = target - npc.position
	to_target.y = 0.0
	if to_target.length() < 0.06:
		wanderer["walking"] = false
		wanderer["wait"] = randf_range(3.0, 8.0)
		if animation != null and animation.has_animation("Idle"):
			animation.play("Idle", 0.2)
		return
	npc.rotation.y = lerp_angle(npc.rotation.y, atan2(to_target.x, to_target.z), 1.0 - exp(-10.0 * delta))
	npc.position += to_target.normalized() * minf(WANDER_SPEED * delta, to_target.length())


func _face_npc(id: String) -> void:
	super._face_npc(id)
	var npc: Node3D = _npcs.get(id) as Node3D
	if npc == null:
		return
	if _papers.has(id):
		(_papers[id] as Node3D).call("face_toward", player.position)
	(_papers["player"] as Node3D).call("face_toward", npc.position)


func _interact(spot: Spot) -> void:
	if spot.id == HURL_SPOT:
		Audio.sfx(&"ui_select")
		_face_npc(HURL_SPOT)
		var lines: Array[String] = ["[happy] Well met, little one! Big Hurl is the name, and carrying heavy things is the game.", "Mind the paper folks, they flip over quick when you wave at them."]
		dialogue.start("Big Hurl", lines, "NPC-HURL")
		return
	super._interact(spot)
