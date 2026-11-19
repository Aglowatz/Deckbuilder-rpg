class_name FadeScan
extends RefCounted
## Fable Nov 19 (Part 1): walks the hero over every walkable cell of the current place (in maths only, no frames) and asks the occlusion
## fader what it would hide there, at the default and the Low camera. Used by the play-script command `fadescan` to take stock, to pick
## the worst spots for before / after shots, and by the fade probe test.
##
## Works with the old fader (private `_run_tests`) and the new one (`OcclusionFader.verdict_at`).

const STEP: float = 2.0
const SPOT_GAP: float = 9.0


## One row per thing that fades somewhere: {name, size (Vector3), kind, count (cells), cams}. `spots` gets the worst cells:
## {pos, cam, score, names}.
static func scan(scene: Node, map: Object, spots: Array[Dictionary], top: int = 6, cams: Array[int] = [0, 3]) -> Array[Dictionary]:
	var fader: Node = find_fader(scene)
	var rows: Dictionary = {}
	if fader == null or map == null or not ("player" in scene):
		return []
	var player: Node3D = scene.get("player") as Node3D
	var camera: Camera3D = scene.get("_camera") as Camera3D
	var offset: Vector3 = (scene.get("camera_offset") if "camera_offset" in scene else scene.get("_camera_offset")) as Vector3
	var keep_pos: Vector3 = player.position
	var keep_cam: Vector3 = camera.position
	var keep_angle: int = Settings.camera_angle
	var scored: Array[Dictionary] = []
	for cam: int in cams:
		Settings.camera_angle = cam
		var arm: Vector3 = CameraRig.shape(offset)
		var xi: float = -60.0
		while xi < 261.0:
			var zi: float = -60.0
			while zi < 261.0:
				var at: Vector3 = Vector3(xi + 0.5, 0.0, zi + 0.5)
				zi += STEP
				if not bool(map.call("is_walkable", at)):
					continue
				if map.has_method("height_at"):
					at.y = float(map.call("height_at", at))
				else:
					at.y = keep_pos.y
				player.position = at
				camera.position = at + arm
				var found: Array[Dictionary] = faded_now(fader, true)
				if found.is_empty():
					continue
				var score: float = 0.0
				var names: PackedStringArray = PackedStringArray()
				for entry: Dictionary in found:
					var key: String = str(entry["name"])
					if not rows.has(key):
						rows[key] = {"name": key, "size": entry["size"], "kind": entry["kind"], "count": 0, "cams": {}}
					(rows[key] as Dictionary)["count"] = int((rows[key] as Dictionary)["count"]) + 1
					((rows[key] as Dictionary)["cams"] as Dictionary)[cam] = true
					score += 1.0 if str(entry["kind"]) in ["tall", "tall_occluder", "small_prop"] else 3.0
					names.append("%s[%s]" % [key, str(entry["kind"])])
				scored.append({"pos": at, "cam": cam, "score": score, "names": names})
			xi += STEP
	Settings.camera_angle = keep_angle
	player.position = keep_pos
	camera.position = keep_cam
	faded_now(fader, true)
	scored.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["score"]) > float(b["score"]))
	for entry: Dictionary in scored:
		if spots.size() >= top:
			break
		var far_enough: bool = true
		for kept: Dictionary in spots:
			if (kept["pos"] as Vector3).distance_to(entry["pos"] as Vector3) < SPOT_GAP:
				far_enough = false
				break
		if far_enough:
			spots.append(entry)
	var result: Array[Dictionary] = []
	for key: Variant in rows.keys():
		result.append(rows[key] as Dictionary)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["count"]) > int(b["count"]))
	return result


static func find_fader(scene: Node) -> Node:
	for node: Node in scene.find_children("OcclusionFader", "", true, false):
		return node
	return null


## What the fader hides for the hero and camera as they stand now: [{name, size, kind}] (kind by the size alone: low under 1.5 m,
## small under 1.3 m across, else tall). `recompute` runs the fader's test first.
static func faded_now(fader: Node, recompute: bool = false) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if fader.has_method("verdict_now"):
		return fader.call("verdict_now", recompute) as Array[Dictionary]
	if recompute:
		fader.call("_run_tests")
	var keys: Dictionary = {}
	for key: Variant in (fader.get("_blocking") as Dictionary).keys():
		keys[key] = "blocks"
	for key: Variant in (fader.get("_cut") as Dictionary).keys():
		keys[key] = "cut"
	if keys.is_empty():
		return result
	var boxes: Array[AABB] = fader.get("_boxes") as Array[AABB]
	var box_keys: Array[int] = fader.get("_box_keys") as Array[int]
	var unions: Dictionary = {}
	for index: int in range(boxes.size()):
		var key: int = box_keys[index]
		if keys.has(key):
			unions[key] = (unions[key] as AABB).merge(boxes[index]) if unions.has(key) else boxes[index]
	var members: Dictionary = fader.get("_members") as Dictionary
	for key: Variant in keys.keys():
		var list: Array = members.get(key, []) as Array
		var label: String = "?"
		if not list.is_empty() and is_instance_valid(list[0]):
			var piece: Node = list[0] as Node
			label = "%s/%s" % [str(piece.get_parent().name), str(piece.name)] if list.size() == 1 else "%s (%d)" % [str(piece.get_parent().name), list.size()]
		var box: AABB = unions.get(key, AABB()) as AABB
		result.append({"name": label, "size": box.size, "kind": kind_of(box.size), "why": str(keys[key])})
	return result


static func kind_of(size: Vector3) -> String:
	if size.y < 1.5:
		return "low"
	if maxf(size.x, size.z) < 1.3:
		return "small"
	return "tall"
