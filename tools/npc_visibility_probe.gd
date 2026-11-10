class_name NpcVisibilityProbe
extends Node
## Fable pass Nov 10 (Part 1.3): nobody hidden behind props. For every NPC with a talk prompt in Crosspath, the four Path zones and the
## Capital, the hero is put on the NPC's talk point (where a player stands to press E), the camera settles at the DEFAULT angle and at the
## LOW angle (Settings > Display > Camera angle; the Capital's own Low city camera too), and sight lines from the lens to the NPC's feet,
## chest, head and name-plate point are tested against every mesh of the scene, triangle by triangle (a painted card counts only where its
## picture is opaque). Meshes that stand between the lens and the HERO are left out: the occlusion fader dissolves those. An NPC whose body
## (two or more of the three body points) or talk point is hidden is a FAIL, with a screenshot. Windowed:
##   bash tools/run_npc_visibility_probe.sh      (NPC_AREAS=gourmand,town to limit it)     Report: _screenshots/npc_visibility/report.md

const OUT_DIR: String = "res://_screenshots/npc_visibility/"
const TAG: String = "npc_visibility_probe"
const AREAS: Array[String] = ["town", "beefcake", "necrocrat", "gourmand", "refusemancer", "final"]
## Camera set-ups: the Settings camera angle index (CameraRig.ANGLE_NAMES) and, in the Capital, the city camera mode.
const CAMERAS: Array[Dictionary] = [{"name": "default", "angle": 0, "city": 1}, {"name": "low", "angle": 3, "city": 2}]
## Meshes wider than this are ground, water or sky (never an occluder); flatter than this are decals and rugs.
const MAX_EXTENT: float = 80.0
const MIN_HEIGHT: float = 0.25
## A mesh with more faces than this is tested by its box only (a merged chunk).
const MAX_FACES: int = 400000
## How far in front of the NPC the hero stands (a share of the talk reach), and the directions tried (toward the camera first).
const STAND_SHARE: float = 0.75
const APPROACHES: Array[Vector3] = [Vector3(0, 0, 1), Vector3(0.7, 0, 0.7), Vector3(-0.7, 0, 0.7), Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, -1)]
const SETTLE_SECONDS: float = 2.2

var driver: UiDriver
var _rows: PackedStringArray = []
var _failures: PackedStringArray = []
var _alpha_cache: Dictionary = {}
var _settings_before: Dictionary = {}


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.flags[QuestDefinitions.LEGACY_FLAG] = true
	for zone_id: String in Gatekeepers.IDS:
		Session.set_flag(CorruptedNpcs.unlock_flag(zone_id))
	Session.set_flag(CapitalZone.FLAG_GATE_OPEN)
	Session.set_flag(CapitalZone.FLAG_INSIDE)
	Session.set_flag(CapitalZone.FLAG_HUB_KNOWN)
	_settings_before = {"angle": Settings.camera_angle, "city": Settings.city_camera}
	driver = UiDriver.new(get_tree())
	await driver.frames(5)
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var wanted: String = OS.get_environment("NPC_AREAS")
	for area: String in AREAS:
		if wanted != "" and not wanted.split(",").has(area):
			continue
		await _area(area)
	Settings.camera_angle = int(_settings_before["angle"])
	Settings.city_camera = int(_settings_before["city"])
	var report: FileAccess = FileAccess.open(OUT_DIR + "report.md", FileAccess.WRITE)
	if report != null:
		report.store_string("# NPC visibility probe\n\nThe hero on each NPC's talk point; sight lines from the lens to the NPC's feet, chest, head and plate. A mesh between the lens and the hero is ignored (it fades).\n\n| Area | NPC | Camera | Feet | Chest | Head | Plate | Hidden by | Result |\n|---|---|---|---|---|---|---|---|---|\n" + "\n".join(_rows) + "\n")
		report.close()
	_finish(_failures.is_empty(), "%d checks, %d failed" % [_rows.size(), _failures.size()])


func _area(area: String) -> void:
	if area == "town":
		SceneManager.go_to_town()
	else:
		Session.enter_zone(area)
	var scene: Node = await _wait_for_world()
	if scene == null:
		_check(false, "%s: the scene loaded" % area)
		return
	await driver.seconds(3.0)
	await _dismiss(scene)
	_clear_roamers(scene)
	var player: TownPlayer = scene.get("player") as TownPlayer
	var camera: Camera3D = scene.get("_camera") as Camera3D
	for npc: Dictionary in _npcs(scene, area):
		for setup: Dictionary in CAMERAS:
			Settings.camera_angle = int(setup["angle"])
			if area == "final":
				Settings.city_camera = int(setup["city"])
			var stand: Vector3 = _stand_point(player, npc)
			if stand == Vector3.INF:
				_rows.append("| %s | %s | %s | - | - | - | - | no walkable talk point found | **FAIL** |" % [area, npc["name"], setup["name"]])
				_check(false, "%s: %s has a walkable talk point" % [area, npc["name"]])
				continue
			player.position = stand
			player.stop_walking()
			player.face(npc["body"] as Vector3)
			await driver.seconds(0.6)
			await _dismiss(scene)  # a Rift station's unlock talk or a tip popup the teleport set off would freeze the camera
			await driver.seconds(SETTLE_SECONDS)
			await _dismiss(scene)
			var result: Dictionary = _test(scene, camera, player, npc)
			var hidden_points: int = int(result["feet"]) + int(result["chest"]) + int(result["head"])
			var bad: bool = hidden_points >= 2 or bool(result["plate"])
			var blockers: PackedStringArray = result["blockers"] as PackedStringArray
			var body_at: Vector3 = npc["body"] as Vector3
			_rows.append("| %s | %s (%.1f, %.1f) | %s | %s | %s | %s | %s | %s | %s |" % [area, npc["name"], body_at.x, body_at.z, setup["name"], _mark(bool(result["feet"])), _mark(bool(result["chest"])), _mark(bool(result["head"])), _mark(bool(result["plate"])), ", ".join(blockers) if not blockers.is_empty() else "-", "**FAIL**" if bad else ("partly" if hidden_points > 0 else "ok")])
			_check(not bad, "%s: %s (%.1f, %.1f; lens %s) at the %s camera - feet %s, chest %s, head %s, plate %s%s" % [area, npc["name"], body_at.x, body_at.z, str(camera.global_position.snapped(Vector3(0.1, 0.1, 0.1))), setup["name"], _mark(bool(result["feet"])), _mark(bool(result["chest"])), _mark(bool(result["head"])), _mark(bool(result["plate"])), (" - hidden by " + ", ".join(blockers)) if not blockers.is_empty() else ""])
			if bad or OS.get_environment("NPC_SHOTS_ALL") != "":
				await _shot("%s_%s_%s" % [area, str(npc["id"]), setup["name"]])
	Settings.camera_angle = int(_settings_before["angle"])
	Settings.city_camera = int(_settings_before["city"])


static func _mark(hidden: bool) -> String:
	return "HIDDEN" if hidden else "ok"


## Every NPC with a talk prompt: {"id", "name", "body": Vector3 (feet), "height": float, "node": Node3D or null, "plate": Vector3, "reach": float}.
func _npcs(scene: Node, area: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if scene is TownScene:
		var town: TownScene = scene as TownScene
		for spot: TownScene.Spot in town.spots:
			if not (spot.id in TownScene.NPC_SPOT_IDS) or not spot.named:
				continue
			var node: Node3D = town._npcs.get(spot.id) as Node3D
			if node == null or not is_instance_valid(node) or not node.is_inside_tree() or not node.visible:
				continue
			var body: Vector3 = node.global_position
			result.append({"id": spot.id, "name": spot.title, "body": body, "height": _height_of(node), "node": node, "marker": spot.marker, "plate": spot.marker.global_position if spot.marker != null else body + Vector3(0, 2.0, 0), "reach": spot.radius * StorybookScale.INTERACT_FACTOR})
	elif scene is ZoneScene:
		var zone: ZoneScene = scene as ZoneScene
		for spot: ZoneSpot in zone.spots:
			if not spot.data.has("npc") or bool(spot.data.get("hidden", false)):
				continue
			var node: Node3D = zone._npcs.get(str(spot.data["npc"])) as Node3D
			if node == null or not is_instance_valid(node) or not node.is_inside_tree() or not node.visible:
				continue
			var body: Vector3 = zone.npc_body_position(spot)
			if body.x > 1.0e8:
				body = node.global_position
			result.append({"id": spot.id, "name": spot.title if spot.title != "" else spot.id, "body": body, "height": _height_of(node), "node": node, "marker": spot.marker, "plate": spot.marker.global_position if spot.marker != null else body + Vector3(0, 2.0, 0), "reach": spot.radius * StorybookScale.INTERACT_FACTOR})
	if result.is_empty():
		_check(false, "%s: has NPCs to check" % area)
	return result


## An NPC's height above its feet: a painted sprite's head height, else its meshes' box.
static func _height_of(node: Node3D) -> float:
	if node is SpriteActor:
		return maxf(1.2, (node as SpriteActor).head_height() * maxf(node.scale.y, 0.01))
	var top: float = 0.0
	for child: Node in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = child as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var box: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
		top = maxf(top, box.end.y - node.global_position.y)
	return maxf(1.2, top if top > 0.0 else 1.7)


## Where a player stands to talk: STAND_SHARE of the reach from the body, toward the camera first, on walkable ground. INF when nowhere fits.
func _stand_point(player: TownPlayer, npc: Dictionary) -> Vector3:
	var body: Vector3 = npc["body"] as Vector3
	var reach: float = float(npc["reach"])
	for share: float in [STAND_SHARE, 0.55, 0.95]:
		for approach: Vector3 in APPROACHES:
			var at: Vector3 = body + approach.normalized() * reach * share
			at.y = player.town.height_at(at) if player.town.has_method("height_at") else body.y
			if player.town.is_walkable(at):
				return at
	return Vector3.INF


## The sight-line tests from the lens to the NPC: {"feet", "chest", "head", "plate": bool hidden, "blockers": names}.
func _test(scene: Node, camera: Camera3D, player: TownPlayer, npc: Dictionary) -> Dictionary:
	var from: Vector3 = camera.global_position
	var body: Vector3 = npc["body"] as Vector3
	var height: float = float(npc["height"])
	var node: Node3D = npc["node"] as Node3D
	var points: Dictionary = {
		"feet": body + Vector3(0, 0.3, 0), "chest": body + Vector3(0, height * 0.55, 0), "head": body + Vector3(0, height * 0.95, 0), "plate": npc["plate"] as Vector3,
	}
	var hero_lines: Array[Vector3] = [player.global_position + Vector3(0, 0.9, 0), player.global_position + Vector3(0, 0.35, 0), player.global_position + Vector3(0, 1.7, 0)]
	var result: Dictionary = {"feet": false, "chest": false, "head": false, "plate": false, "blockers": PackedStringArray()}
	var blockers: PackedStringArray = []
	var marker: Node = npc.get("marker") as Node
	var names: Dictionary = {}
	for mesh_node: Node in scene.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = mesh_node as MeshInstance3D
		if mesh_instance.mesh == null or not mesh_instance.is_visible_in_tree() or mesh_instance.layers == 0:
			continue
		if (node != null and node.is_ancestor_of(mesh_instance)) or player.is_ancestor_of(mesh_instance) or camera.is_ancestor_of(mesh_instance):
			continue
		if marker != null and (marker == mesh_instance or marker.is_ancestor_of(mesh_instance)):
			continue  # the spot's own floating marker stands on the plate point
		if _is_overlay(mesh_instance) or _cuts_away(mesh_instance):
			continue
		var box: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
		if maxf(box.size.x, box.size.z) > MAX_EXTENT or box.size.y < MIN_HEIGHT:
			continue
		# anything the fader dissolves (between the lens and the hero) is see-through
		var fades: bool = false
		for hero_point: Vector3 in hero_lines:
			if _segment_hits(box.grow(0.15), from, hero_point):
				fades = true
				break
		if fades and (not mesh_instance.has_meta(&"no_occlusion_fade") or _hero_aware_card(mesh_instance)):
			continue
		# a tall piece the fader may touch dissolves for the person in reach too (OcclusionFader.talk_focus, Part 1.3): only pieces the fader
		# never touches (no_occlusion_fade: landmarks, batched buildings, painted cards outside the hero corridor) and short props stay blockers
		if not mesh_instance.has_meta(&"no_occlusion_fade") and box.size.y >= 1.0:
			continue
		var hit_any: bool = false
		for key: String in points.keys():
			var to: Vector3 = points[key] as Vector3
			if not _segment_hits(box.grow(0.05), from, to):
				continue
			if _mesh_blocks(mesh_instance, from, to):
				result[key] = true
				hit_any = true
		if hit_any:
			var label: String = "%s/%s [x %.0f..%.0f, z %.0f..%.0f, y %.1f..%.1f]" % [mesh_instance.get_parent().name if mesh_instance.get_parent() != null else "", mesh_instance.name, box.position.x, box.end.x, box.position.z, box.end.z, box.position.y, box.end.y]
			if not names.has(label):
				names[label] = true
				blockers.append(label)
	result["blockers"] = blockers
	return result


## The D.N.A.'s per-piece fade chunks (dna_fade.gdshader) cut away round the hero's room: see-through for this probe.
static func _cuts_away(mesh_instance: MeshInstance3D) -> bool:
	var material: Material = mesh_instance.material_override
	if material == null and mesh_instance.mesh != null and mesh_instance.mesh.get_surface_count() > 0:
		material = mesh_instance.get_active_material(0)
	if material is ShaderMaterial and (material as ShaderMaterial).shader != null:
		return (material as ShaderMaterial).shader.resource_path.contains("dna_fade")
	return false


## A painted card whose shader fades it in the camera -> hero corridor (kit_card.gdshader with a live hero_pos).
static func _hero_aware_card(mesh_instance: MeshInstance3D) -> bool:
	var material: Material = mesh_instance.material_override
	if material is ShaderMaterial and (material as ShaderMaterial).shader != null and (material as ShaderMaterial).shader.resource_path.contains("kit_card"):
		var hero: Variant = (material as ShaderMaterial).get_shader_parameter("hero_pos")
		return hero is Vector3 and (hero as Vector3).y > -999.0
	return false


## Markers, rings, chevrons, name plates and the like never count.
static func _is_overlay(mesh_instance: MeshInstance3D) -> bool:
	var walker: Node = mesh_instance
	while walker != null:
		var name: String = str(walker.name)
		if name == "QuestMarkers" or name.begins_with("ObjectiveMarker") or name.begins_with("SideObjectiveMarker") or name == "NpcLabels" or name == "NpcGlow" or name.begins_with("Glow"):
			return true
		walker = walker.get_parent()
	if mesh_instance.material_override is StandardMaterial3D and (mesh_instance.material_override as StandardMaterial3D).no_depth_test:
		return true
	return false


## True when the segment crosses one of the mesh's triangles (a painted card: an opaque texel of its picture).
func _mesh_blocks(mesh_instance: MeshInstance3D, from: Vector3, to: Vector3) -> bool:
	var faces: PackedVector3Array = mesh_instance.mesh.get_faces()
	if faces.is_empty() or faces.size() > MAX_FACES * 3:
		return true  # no geometry to read, or an enormous merged chunk: its box decides
	var transform: Transform3D = mesh_instance.global_transform
	var card: bool = mesh_instance.mesh is QuadMesh
	var index: int = 0
	while index + 2 < faces.size():
		var hit: Variant = Geometry3D.segment_intersects_triangle(from, to, transform * faces[index], transform * faces[index + 1], transform * faces[index + 2])
		index += 3
		if hit == null:
			continue
		if card and not _card_opaque_at(mesh_instance, transform.affine_inverse() * (hit as Vector3)):
			continue
		return true
	return false


## A painted card's picture at a local hit point (the quad is one unit, scaled): opaque when its alpha is at least 0.5 within a texel or two.
func _card_opaque_at(mesh_instance: MeshInstance3D, local: Vector3) -> bool:
	var texture: Texture2D = null
	var material: Material = mesh_instance.material_override
	if material is ShaderMaterial:
		texture = (material as ShaderMaterial).get_shader_parameter("card_tex") as Texture2D
	elif material is StandardMaterial3D:
		texture = (material as StandardMaterial3D).albedo_texture
	if texture == null:
		return true
	var key: int = texture.get_instance_id()
	if not _alpha_cache.has(key):
		var image: Image = texture.get_image()
		if image != null:
			if image.is_compressed():
				image.decompress()
		_alpha_cache[key] = image
	var picture: Image = _alpha_cache[key] as Image
	if picture == null:
		return true
	var size: Vector2 = (mesh_instance.mesh as QuadMesh).size
	var u: float = clampf(local.x / size.x + 0.5, 0.0, 1.0)
	var v: float = clampf(0.5 - local.y / size.y, 0.0, 1.0)
	var px: int = int(u * float(picture.get_width() - 1))
	var py: int = int(v * float(picture.get_height() - 1))
	for dy: int in range(-2, 3):
		for dx: int in range(-2, 3):
			var x: int = clampi(px + dx, 0, picture.get_width() - 1)
			var y: int = clampi(py + dy, 0, picture.get_height() - 1)
			if picture.get_pixel(x, y).a >= 0.5:
				return true
	return false


## True when the segment from -> to passes through `box` (slab test).
static func _segment_hits(box: AABB, from: Vector3, to: Vector3) -> bool:
	var direction: Vector3 = to - from
	var t_min: float = 0.0
	var t_max: float = 1.0
	for axis: int in range(3):
		var origin: float = from[axis]
		var delta_axis: float = direction[axis]
		var low: float = box.position[axis]
		var high: float = box.position[axis] + box.size[axis]
		if absf(delta_axis) < 0.00001:
			if origin < low or origin > high:
				return false
			continue
		var t1: float = (low - origin) / delta_axis
		var t2: float = (high - origin) / delta_axis
		if t1 > t2:
			var swap: float = t1
			t1 = t2
			t2 = swap
		t_min = maxf(t_min, t1)
		t_max = minf(t_max, t2)
		if t_min > t_max:
			return false
	return true


func _clear_roamers(scene: Node) -> void:
	var enemies: Variant = scene.get("enemies")
	if enemies is Array:
		for enemy: Variant in (enemies as Array).duplicate():
			if enemy is Node and is_instance_valid(enemy):
				(enemy as Node).queue_free()
		(enemies as Array).clear()


func _dismiss(scene: Node) -> void:
	var dialogue: DialogueBox = scene.get("dialogue") as DialogueBox
	var guard: int = 0
	while dialogue != null and dialogue.active and guard < 40:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)
	guard = 0
	while (driver.find_button("Continue") != null or driver.find_button("Got it") != null) and guard < 10:
		guard += 1
		if driver.find_button("Got it") != null:
			await driver.click_button("Got it")
		else:
			await driver.tap_key(KEY_ENTER)
		await driver.seconds(0.4)


func _wait_for_world() -> Node:
	var elapsed: float = 0.0
	while elapsed < 40.0:
		var scene: Node = get_tree().current_scene
		if scene != null and (scene is TownScene or scene is ZoneScene) and not SceneManager.busy and scene.get("player") != null:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _shot(shot_name: String) -> void:
	await driver.frames(2)
	var texture: Texture2D = get_tree().root.get_texture()
	if texture != null:
		texture.get_image().save_png(ProjectSettings.globalize_path("%s%s.png" % [OUT_DIR, shot_name]))


func _check(condition: bool, message: String) -> void:
	if condition:
		print("%s: ok    %s" % [TAG, message])
	else:
		_failures.append(message)
		print("%s: FAIL  %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
