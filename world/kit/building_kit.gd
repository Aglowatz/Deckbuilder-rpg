class_name BuildingKit
extends RefCounted
## The modular building kit (vertical slice, Part A): assembles a cosy storybook building from parts, entirely in code, as one mesh with a material slot per kit asset
## (wall, upper wall, foundation band, timber beams / posts / eave trim, roof, awning, door, shutters, lit glass ...). Parameters come from a spec dictionary
## (data/art/building_presets.json; see `BuildingPresets`):
##
##   width, depth (m), floors, floor_height (ground floor may differ: ground_height), foundation (band height)
##   wall / wall_upper / foundation_wall / beam / eave : kit ids      timber: "none" | "upper" | "all"
##   roof: {style gable|hip|thatch|spire, pitch (deg), overhang (m), material id, gable_front (bool: front face is the gable)}
##   chimney: {x, z, w, height} (optional)      dormers: [{u, w}] (optional, on the front slope)
##   faces: {front|back|left|right: [socket, ...]} where a socket is {type door|window|awning|sign|lantern|ivy|stain|flowerbox|bench..., id: kit id, u: metres along the
##          face from its centre (right when looking at it), floor: 0.., y: explicit height}
##
## The front face is +z (yaw 0 faces south, like the rest of the town). All sizes follow the scale rule: the hero (1.25 m) reaches about a third of the way up a door (DOOR_H).
## Windows are lit with a warm emissive glass (bloom picks it up) and a few registered `lights` carry real OmniLights, budgeted by the caller.

const DOOR_H: float = 3.4
const DOOR_W: float = 1.7
const GLASS_COLOR: Color = Color("ffa447")
const LANTERN_COLOR: Color = Color("ffb45a")
const FLOWERS: Array[Color] = [Color("e0483a"), Color("f0c03a"), Color("e87aa8"), Color("f4efe0"), Color("9a6ad8")]

const FACES: Dictionary = {
	"front": {"n": Vector3(0, 0, 1), "u": Vector3(1, 0, 0)},
	"back": {"n": Vector3(0, 0, -1), "u": Vector3(-1, 0, 0)},
	"right": {"n": Vector3(1, 0, 0), "u": Vector3(0, 0, -1)},
	"left": {"n": Vector3(-1, 0, 0), "u": Vector3(0, 0, 1)},
}

var spec: Dictionary = {}
var mesh: KitMesh = KitMesh.new()
var hw: float = 3.0
var hd: float = 2.5
var floors: int = 1
var ground_h: float = 4.0
var floor_h: float = 3.2
var foundation: float = 0.55
var wall_top: float = 4.0
var ridge_y: float = 6.0
var lights: Array[Dictionary] = []
var anchors: Dictionary = {}
var smoke_points: Array[Vector3] = []
## Ground points in front of the ground-floor windows: a soft warm light pool is laid there (the lit glass itself only glows through the bloom).
var glows: Array[Vector3] = []
var _flower_index: int = 0
var _tint: Color = Color.WHITE


## Builds the building described by `spec_value` and returns its root Node3D (a "Body" MeshInstance3D, anchors in meta).
static func build(spec_value: Dictionary, tint: Color = Color.WHITE) -> Node3D:
	var job: BuildingKit = BuildingKit.new()
	job.spec = spec_value
	job._tint = tint
	return job._assemble()


static func floor_top(spec_value: Dictionary, index: int) -> float:
	var ground: float = float(spec_value.get("ground_height", spec_value.get("floor_height", 3.2)))
	var upper: float = float(spec_value.get("floor_height", 3.2))
	return float(spec_value.get("foundation", 0.55)) + ground + upper * float(maxi(index, 0))


## Circles (x offset, z offset, radius) in the building local frame that cover the footprint along its long axis (the town's obstacles are circles).
static func obstacle_circles(spec_value: Dictionary, inflate: float = 0.0) -> Array[Vector3]:
	var w: float = float(spec_value.get("width", 6.0))
	var d: float = float(spec_value.get("depth", 5.0))
	var radius: float = minf(w, d) * 0.5 + inflate
	var long_axis_is_x: bool = w >= d
	var length: float = maxf(w, d)
	var count: int = maxi(1, int(ceil((length - radius * 2.0) / (radius * 1.2))) + 1)
	var result: Array[Vector3] = []
	for index: int in range(count):
		var t: float = 0.5 if count == 1 else float(index) / float(count - 1)
		var offset: float = lerpf(-(length * 0.5 - radius), length * 0.5 - radius, t)
		result.append(Vector3(offset, 0.0, radius) if long_axis_is_x else Vector3(0.0, offset, radius))
	return result


func _assemble() -> Node3D:
	hw = float(spec.get("width", 6.0)) * 0.5
	hd = float(spec.get("depth", 5.0)) * 0.5
	floors = maxi(int(spec.get("floors", 1)), 1)
	floor_h = float(spec.get("floor_height", 3.2))
	ground_h = float(spec.get("ground_height", floor_h))
	foundation = float(spec.get("foundation", 0.55))
	wall_top = foundation + ground_h + floor_h * float(floors - 1)
	var root: Node3D = Node3D.new()
	root.name = str(spec.get("name", "Building"))
	_set_materials()
	_foundation_and_walls()
	_timber()
	var roof_data: Dictionary = spec.get("roof", {}) as Dictionary
	_roof(roof_data)
	_chimney(spec.get("chimney", {}) as Dictionary)
	_dormers(spec.get("dormers", []) as Array, roof_data)
	var faces_data: Dictionary = spec.get("faces", {}) as Dictionary
	for face: String in faces_data.keys():
		for socket: Variant in faces_data[face] as Array:
			_socket(face, socket as Dictionary)
	# Shadows: the detailed body (a dozen surfaces) casts none; a plain proxy (the wall box and the roof, three surfaces) casts them instead, so a building costs the shadow pass
	# a fraction of its draws. The proxy never dissolves with the body (shadows stay).
	var saved_mesh: KitMesh = mesh
	var triangles: int = mesh.triangle_count()
	mesh = KitMesh.new()
	var shadow_material: StandardMaterial3D = StandardMaterial3D.new()
	shadow_material.set_meta(StyleToon.META_NO_TOON, true)
	for slot: String in ["wall", "wall_upper", "roof", "eave"]:
		mesh.set_material(slot, shadow_material)
	mesh.box("wall", Vector3(0, wall_top * 0.5, 0), Vector3(hw * 2.0, wall_top, hd * 2.0))
	_roof(roof_data)
	var proxy: MeshInstance3D = mesh.instance("ShadowProxy")
	mesh = saved_mesh
	proxy.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	proxy.set_meta(StyleToon.META_NO_TOON, true)
	proxy.set_meta("no_occlusion_fade", true)
	var body: MeshInstance3D = mesh.instance("Body")
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# A big building next to the camera is part of the picture (the paint-over has one at its right edge): it only dissolves as clutter when the lens is almost touching it.
	body.set_meta("occlusion_near", 2.0)
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	root.add_child(body)
	root.add_child(proxy)
	root.set_meta("height", ridge_y)
	root.set_meta("footprint", Vector2(hw * 2.0, hd * 2.0))
	root.set_meta("anchors", anchors)
	root.set_meta("lights", lights)
	root.set_meta("smoke", smoke_points)
	root.set_meta("glows", glows)
	root.set_meta("triangles", triangles)
	return root


# ---- materials ----------------------------------------------------------------------------------------------------------------------


func _id(key: String, fallback: String) -> String:
	return str(spec.get(key, fallback))


func _set_materials() -> void:
	var wall_id: String = _id("wall", "ENV-WALL-TIMBER")
	var roof_data: Dictionary = spec.get("roof", {}) as Dictionary
	mesh.set_material("wall", EnvKit.material(wall_id, false, _tint))
	mesh.set_material("wall_upper", EnvKit.material(_id("wall_upper", wall_id), false, _tint))
	mesh.set_material("foundation", EnvKit.material(_id("foundation_wall", "ENV-WALL-FOUNDATION")))
	mesh.set_material("beam", EnvKit.material(_id("beam", "ENV-BEAM")))
	mesh.set_material("eave", EnvKit.material(_id("eave", "ENV-ROOF-EAVE")))
	mesh.set_material("roof", EnvKit.material(str(roof_data.get("material", "ENV-ROOF-TILE-RED")), false, _tint if bool(roof_data.get("tinted", false)) else Color.WHITE))
	mesh.set_material("plank", EnvKit.material("ENV-WALL-PLANK"))
	mesh.set_material("glass", EnvKit.glow(GLASS_COLOR, 1.45))
	mesh.set_material("lantern", EnvKit.glow(LANTERN_COLOR, 2.0))
	mesh.set_material("pot", EnvKit.material("ENV-PROP-FLOWERPOTS"))
	mesh.set_material("awning_a", EnvKit.material("ENV-AWNING-01"))
	mesh.set_material("awning_b", EnvKit.material("ENV-AWNING-02"))
	for door: String in ["ENV-DOOR-01", "ENV-DOOR-02", "ENV-DOOR-03"]:
		mesh.set_material(door, EnvKit.material(door, EnvKit.has_art(door)))
	# Flat-coloured details share ONE white surface and are coloured per vertex: iron, shutters, soil, leaves and blooms are a single draw call (not five or six).
	mesh.set_material("flat", EnvKit.flat(Color.WHITE, "flat"))
	mesh.alias("iron", "flat", Color("3a3430"))
	mesh.alias("shutter", "flat", Color.html(str(spec.get("shutter", "#5a8a6a"))))
	mesh.alias("shutter_dark", "flat", Color("3f6a52"))
	mesh.alias("plant", "flat", Color.WHITE)
	mesh.alias("cutout", "flat", Color.WHITE)
	if _id("wall_upper", wall_id) == wall_id:
		mesh.alias("wall_upper", "wall", Color.WHITE)


# ---- frame of the face: where things attach -------------------------------------------------------------------------------------------


func _face_half(face: String) -> float:
	return hw if face == "front" or face == "back" else hd


func _face_point(face: String, u_off: float, y: float, off: float = 0.0) -> Vector3:
	var data: Dictionary = FACES[face] as Dictionary
	var n: Vector3 = data["n"] as Vector3
	var u: Vector3 = data["u"] as Vector3
	var depth: float = hd if face == "front" or face == "back" else hw
	return n * (depth + off) + u * u_off + Vector3(0, y, 0)


func _face_basis(face: String) -> Basis:
	var data: Dictionary = FACES[face] as Dictionary
	return Basis(data["u"] as Vector3, Vector3.UP, data["n"] as Vector3)


## A box attached to a face: `size` = (along the face, up, out of the face); the centre sits `off` out from the wall plane.
func _attach(slot: String, face: String, u_off: float, y: float, off: float, size: Vector3, bevel: float = 0.02, ao: float = 1.0) -> void:
	mesh.box(slot, _face_point(face, u_off, y, off), size, _face_basis(face), bevel, ao)


func _face_quad(slot: String, face: String, u0: float, u1: float, y0: float, y1: float, off: float, colors: Array[Color] = [], uvs: Array[Vector2] = []) -> void:
	var n: Vector3 = (FACES[face] as Dictionary)["n"] as Vector3
	mesh.quad(slot, [_face_point(face, u0, y0, off), _face_point(face, u1, y0, off), _face_point(face, u1, y1, off), _face_point(face, u0, y1, off)], n, colors, uvs)


# ---- foundation, walls, posts, beams -----------------------------------------------------------------------------------------------


func _foundation_and_walls() -> void:
	var fw: float = hw * 2.0 + 0.14
	var fd: float = hd * 2.0 + 0.14
	mesh.box("foundation", Vector3(0, foundation * 0.5, 0), Vector3(fw, foundation, fd), Basis.IDENTITY, 0.05, 0.72)
	var dark: Color = Color(0.74, 0.74, 0.74)
	for face: String in FACES.keys():
		var half: float = _face_half(face)
		var y0: float = foundation
		for floor_index: int in range(floors):
			var y1: float = floor_top(spec, floor_index)
			var slot: String = "wall" if floor_index == 0 else "wall_upper"
			var bottom: Color = dark if floor_index == 0 else Color(0.9, 0.9, 0.9)
			var top: Color = Color(0.8, 0.8, 0.8) if floor_index == floors - 1 else Color.WHITE
			_face_quad(slot, face, -half, half, y0, y1, 0.0, [bottom, bottom, top, top])
			y0 = y1


func _timber() -> void:
	var mode: String = str(spec.get("timber", "upper"))
	var post: float = 0.3
	# corner posts, floor beams and the plate
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			mesh.box("beam", Vector3(sx * hw, (foundation + wall_top) * 0.5, sz * hd), Vector3(post, wall_top - foundation, post), Basis.IDENTITY, 0.03, 0.85)
	for index: int in range(floors):
		var y: float = floor_top(spec, index)
		var thickness: float = 0.26
		for face: String in FACES.keys():
			var half: float = _face_half(face)
			_attach("beam", face, 0.0, y - (0.0 if index < floors - 1 else 0.12), 0.07, Vector3(half * 2.0 + 0.2, thickness, 0.14), 0.03)
	_attach("beam", "front", 0.0, foundation + 0.08, 0.06, Vector3(hw * 2.0, 0.18, 0.12), 0.03)
	if mode == "none":
		return
	for face: String in FACES.keys():
		var half: float = _face_half(face)
		var bays: int = maxi(2, int(round(half * 2.0 / 1.9)))
		var bay_w: float = half * 2.0 / float(bays)
		var y0: float = foundation
		for floor_index: int in range(floors):
			var y1: float = floor_top(spec, floor_index)
			if mode == "all" or floor_index > 0 or floors == 1:
				for bay: int in range(bays + 1):
					var u: float = -half + bay_w * float(bay)
					if bay > 0 and bay < bays:
						_attach("beam", face, u, (y0 + y1) * 0.5, 0.05, Vector3(0.16, y1 - y0 - 0.3, 0.1), 0.02)
				for bay: int in range(bays):
					var u_mid: float = -half + bay_w * (float(bay) + 0.5)
					if (bay + int(floor_index)) % 2 == 0:
						var rise: float = (y1 - y0) * 0.38
						var angle: float = atan2(rise, bay_w * 0.42)
						var length: float = sqrt(rise * rise + bay_w * 0.42 * bay_w * 0.42)
						var basis: Basis = _face_basis(face) * Basis(Vector3(0, 0, 1), angle * (1.0 if bay % 2 == 0 else -1.0))
						var center: Vector3 = _face_point(face, u_mid, y0 + rise * 0.5 + 0.2, 0.05)
						mesh.box("beam", center, Vector3(length, 0.14, 0.1), basis, 0.02)
			y0 = y1


# ---- roof ------------------------------------------------------------------------------------------------------------------------------


func _roof(roof_data: Dictionary) -> void:
	var style: String = str(roof_data.get("style", "gable"))
	var pitch: float = deg_to_rad(float(roof_data.get("pitch", 40.0 if style != "spire" else 58.0)))
	var over: float = float(roof_data.get("overhang", 0.75))
	var gable_front: bool = bool(roof_data.get("gable_front", false))
	var thick: float = 0.16 if style != "thatch" else 0.42
	# Frame: the ridge runs along the frame's x. `gable_front` rotates the frame by 90 degrees (the front face becomes the gable end).
	var frame_hx: float = (hd if gable_front else hw) + over
	var frame_hz: float = (hw if gable_front else hd) + over
	var rise_at_wall: float = tan(pitch) * (frame_hz - over)
	var y_wall: float = wall_top + 0.1
	var y_e: float = y_wall - over * tan(pitch)
	var y_r: float = y_wall + rise_at_wall
	ridge_y = y_r + 0.12
	var map: Callable = func(p: Vector3) -> Vector3:
		return Vector3(p.z, p.y, p.x) if gable_front else p
	var corner_dark: Color = Color(0.72, 0.72, 0.72)
	var top_slot: String = "roof"
	var ridge_half: float = frame_hx
	if style == "hip" or style == "spire":
		ridge_half = maxf(frame_hx - frame_hz, 0.0)
		if style == "spire":
			ridge_half = 0.0
			y_r = y_e + tan(pitch) * maxf(frame_hx, frame_hz)
			frame_hz = maxf(frame_hx, frame_hz)
			frame_hx = frame_hz
			ridge_y = y_r + 0.2
		else:
			y_r = y_e + tan(pitch) * frame_hz
			ridge_y = y_r + 0.12
	# sloped top faces (front and back of the frame)
	for side: float in [-1.0, 1.0]:
		var n: Vector3 = Vector3(0, cos(pitch), sin(pitch) * side)
		var eave_a: Vector3 = Vector3(-frame_hx, y_e, side * frame_hz)
		var eave_b: Vector3 = Vector3(frame_hx, y_e, side * frame_hz)
		var rid_a: Vector3 = Vector3(-ridge_half, y_r, 0.0)
		var rid_b: Vector3 = Vector3(ridge_half, y_r, 0.0)
		var slope_len: float = Vector2(frame_hz, y_r - y_e).length()
		var uv_a: Vector2 = Vector2(-frame_hx, 0.0)
		var uv_b: Vector2 = Vector2(frame_hx, 0.0)
		var uv_c: Vector2 = Vector2(ridge_half, slope_len)
		var uv_d: Vector2 = Vector2(-ridge_half, slope_len)
		var cols: Array[Color] = [corner_dark, corner_dark, Color.WHITE, Color.WHITE]
		mesh.quad(top_slot, [map.call(eave_a) as Vector3, map.call(eave_b) as Vector3, map.call(rid_b) as Vector3, map.call(rid_a) as Vector3], map.call(n) as Vector3, cols, [uv_a, uv_b, uv_c, uv_d])
		# underside and fascia at the eave
		mesh.quad("eave", [map.call(eave_a) as Vector3, map.call(eave_b) as Vector3, map.call(eave_b + Vector3(0, -thick, 0)) as Vector3, map.call(eave_a + Vector3(0, -thick, 0)) as Vector3], map.call(Vector3(0, 0, side)) as Vector3, [Color.WHITE, Color.WHITE, Color(0.7, 0.7, 0.7), Color(0.7, 0.7, 0.7)])
		var inner_a: Vector3 = Vector3(-frame_hx, y_wall - 0.2 - thick * 0.0, side * (frame_hz - over))
		var inner_b: Vector3 = Vector3(frame_hx, y_wall - 0.2, side * (frame_hz - over))
		mesh.quad("eave", [map.call(eave_a + Vector3(0, -thick, 0)) as Vector3, map.call(eave_b + Vector3(0, -thick, 0)) as Vector3, map.call(inner_b) as Vector3, map.call(inner_a) as Vector3], map.call(Vector3.DOWN) as Vector3, [Color(0.62, 0.62, 0.62), Color(0.62, 0.62, 0.62), Color(0.5, 0.5, 0.5), Color(0.5, 0.5, 0.5)])
	# the two ends: gable (a vertical triangle of wall plus a barge board) or hip (two sloped triangles)
	for end: float in [-1.0, 1.0]:
		if style == "gable" or style == "thatch":
			var n_end: Vector3 = Vector3(end, 0, 0)
			var wall_x: float = end * (frame_hx - over)
			var apex: Vector3 = Vector3(wall_x, y_r - 0.05, 0)
			var left: Vector3 = Vector3(wall_x, wall_top, -frame_hz + over)
			var right: Vector3 = Vector3(wall_x, wall_top, frame_hz - over)
			var slot: String = "wall_upper" if floors > 1 else "wall"
			mesh.tri(slot, [map.call(left) as Vector3, map.call(right) as Vector3, map.call(apex) as Vector3], map.call(n_end) as Vector3, [Color(0.8, 0.8, 0.8), Color(0.8, 0.8, 0.8), Color.WHITE])
			# barge boards along both rake edges (a box rotated to the slope), proud of the roof edge
			for side: float in [-1.0, 1.0]:
				var a: Vector3 = Vector3(end * frame_hx, y_e, side * frame_hz)
				var b: Vector3 = Vector3(end * frame_hx, y_r, 0.0)
				var along: Vector3 = (b - a)
				var length: float = along.length()
				var center: Vector3 = (a + b) * 0.5 + Vector3(0, -thick * 0.4, 0)
				var x_axis: Vector3 = along.normalized()
				var y_axis: Vector3 = Vector3(end, 0, 0).cross(x_axis).normalized()
				if y_axis.y < 0.0:
					y_axis = -y_axis
				var z_axis: Vector3 = x_axis.cross(y_axis).normalized()
				var rot: Basis = Basis(x_axis, y_axis, z_axis)
				mesh.box("eave", map.call(center) as Vector3, Vector3(length + 0.1, 0.22 + (thick - 0.16), 0.2), _map_basis(rot, gable_front), 0.03)
		else:
			var tip: Vector3 = Vector3(end * ridge_half, y_r, 0.0)
			var c1: Vector3 = Vector3(end * frame_hx, y_e, frame_hz)
			var c2: Vector3 = Vector3(end * frame_hx, y_e, -frame_hz)
			var n_hip: Vector3 = Vector3(sin(pitch) * end, cos(pitch), 0)
			mesh.tri(top_slot, [map.call(c1) as Vector3, map.call(c2) as Vector3, map.call(tip) as Vector3], map.call(n_hip) as Vector3, [corner_dark, corner_dark, Color.WHITE])
			mesh.quad("eave", [map.call(c1) as Vector3, map.call(c2) as Vector3, map.call(c2 + Vector3(0, -thick, 0)) as Vector3, map.call(c1 + Vector3(0, -thick, 0)) as Vector3], map.call(Vector3(end, 0, 0)) as Vector3)
	# ridge cap
	if ridge_half > 0.01:
		var cap_basis: Basis = Basis.IDENTITY
		mesh.box("eave", map.call(Vector3(0, y_r + 0.02, 0)) as Vector3, map.call(Vector3(ridge_half * 2.0 + 0.3, 0.24, 0.3)).abs() as Vector3, cap_basis, 0.05)
	else:
		mesh.box("eave", Vector3(0, y_r + 0.1, 0), Vector3(0.34, 0.5, 0.34), Basis.IDENTITY, 0.07)
	anchors["roof_ridge"] = Vector3(0, ridge_y, 0)


func _map_basis(rot: Basis, gable_front: bool) -> Basis:
	if not gable_front:
		return rot
	# the frame swaps x and z: reflect the basis through the plane x = z
	var swap: Basis = Basis(Vector3(0, 0, 1), Vector3(0, 1, 0), Vector3(1, 0, 0))
	return swap * rot * swap


func _chimney(data: Dictionary) -> void:
	if data.is_empty():
		return
	var cx: float = float(data.get("x", hw * 0.5))
	var cz: float = float(data.get("z", -hd * 0.3))
	var w: float = float(data.get("w", 1.0))
	var h: float = float(data.get("height", 1.8))
	var base: float = wall_top - 0.5
	var top: float = ridge_y + h * 0.5
	mesh.box("foundation", Vector3(cx, (base + top) * 0.5, cz), Vector3(w, top - base, w), Basis.IDENTITY, 0.05, 0.9)
	mesh.box("foundation", Vector3(cx, top + 0.12, cz), Vector3(w + 0.24, 0.24, w + 0.24), Basis.IDENTITY, 0.05)
	mesh.box("iron", Vector3(cx, top + 0.26, cz), Vector3(w * 0.5, 0.06, w * 0.5), Basis.IDENTITY, 0.0)
	smoke_points.append(Vector3(cx, top + 0.4, cz))


func _dormers(list: Array, roof_data: Dictionary) -> void:
	if list.is_empty():
		return
	var pitch: float = deg_to_rad(float(roof_data.get("pitch", 40.0)))
	var gable_front: bool = bool(roof_data.get("gable_front", false))
	if gable_front:
		return
	for item: Variant in list:
		var data: Dictionary = item as Dictionary
		var u: float = float(data.get("u", 0.0))
		var w: float = float(data.get("w", 1.5))
		# the front slope passes through (z = hd, y = wall_top + 0.1) and climbs tan(pitch) per metre towards the ridge
		var z_front: float = hd - 0.55
		var y_base: float = wall_top + 0.1 + (hd - z_front) * tan(pitch)
		var wall_h: float = 1.5
		mesh.quad("wall_upper", [Vector3(u - w * 0.5, y_base - 0.2, z_front), Vector3(u + w * 0.5, y_base - 0.2, z_front), Vector3(u + w * 0.5, y_base + wall_h, z_front), Vector3(u - w * 0.5, y_base + wall_h, z_front)], Vector3(0, 0, 1))
		for side: float in [-1.0, 1.0]:
			var x: float = u + side * w * 0.5
			mesh.tri("wall_upper", [Vector3(x, y_base - 0.2, z_front), Vector3(x, y_base - 0.2, z_front - 1.3), Vector3(x, y_base + wall_h, z_front)], Vector3(side, 0, 0))
		var top_y: float = y_base + wall_h + 0.7
		for side: float in [-1.0, 1.0]:
			var eave_x: float = u + side * (w * 0.5 + 0.3)
			mesh.quad("roof", [Vector3(eave_x, y_base + wall_h, z_front + 0.3), Vector3(u, top_y, z_front + 0.3), Vector3(u, top_y, z_front - 1.4), Vector3(eave_x, y_base + wall_h, z_front - 1.4)], Vector3(side * 0.6, 0.8, 0))
		mesh.tri("wall_upper", [Vector3(u - w * 0.5, y_base + wall_h, z_front + 0.01), Vector3(u + w * 0.5, y_base + wall_h, z_front + 0.01), Vector3(u, top_y - 0.08, z_front + 0.01)], Vector3(0, 0, 1))
		_window_style("front", u, y_base + 0.55, "cross", -(hd - z_front) + 0.02, false, false, 0.72)


# ---- sockets: doors, windows, awnings, signs, lanterns, ivy -------------------------------------------------------------------------------


func _socket(face: String, data: Dictionary) -> void:
	var type: String = str(data.get("type", "window"))
	var u: float = float(data.get("u", 0.0))
	var floor_index: int = int(data.get("floor", 0))
	match type:
		"door":
			_door(face, u, str(data.get("id", "ENV-DOOR-01")), data)
		"window":
			var id: String = str(data.get("id", "ENV-WINDOW-01"))
			var y: float = foundation + 2.3
			if floor_index > 0:
				y = floor_top(spec, floor_index - 1) + floor_h * 0.5 + 0.1
			y = float(data.get("y", y))
			_window(face, u, y, id, data)
		"awning":
			_awning(face, u, float(data.get("y", DOOR_H + 0.45)), float(data.get("w", DOOR_W + 1.4)), str(data.get("id", "ENV-AWNING-01")))
		"sign":
			_sign(face, u, float(data.get("y", DOOR_H + 1.2)), str(data.get("id", "ENV-SIGN-CARDS")), float(data.get("size", 1.1)))
		"lantern":
			_wall_lantern(face, u, float(data.get("y", 2.6)), bool(data.get("light", true)))
		"ivy":
			_ivy(face, u, float(data.get("h", 2.8)), float(data.get("w", 1.3)))
		"stain":
			_stain(face, u, float(data.get("y", 2.0)))
		"flowerbox":
			_flowerbox(face, u, float(data.get("y", 1.5)), float(data.get("w", 1.7)))
		"shutters":
			pass


func _door(face: String, u: float, id: String, data: Dictionary) -> void:
	var y_mid: float = foundation + DOOR_H * 0.5 - 0.1
	var bottom: float = 0.0
	var h: float = DOOR_H
	var w: float = DOOR_W
	var arched: bool = id == "ENV-DOOR-03"
	var jamb: float = 0.2
	# step
	_attach("foundation", face, u, 0.14, 0.38, Vector3(w + 0.9, 0.28, 0.76), 0.05)
	# the opening's dark reveal (slight inset): a dark quad behind the leaf so the frame reads as a recess
	_face_quad("iron", face, u - w * 0.5, u + w * 0.5, bottom + 0.28, h - (w * 0.5 if arched else 0.0), 0.012)
	# frame
	_attach("beam", face, u - w * 0.5 - jamb * 0.5, bottom + h * 0.5 + 0.14, 0.09, Vector3(jamb, h, 0.18), 0.03)
	_attach("beam", face, u + w * 0.5 + jamb * 0.5, bottom + h * 0.5 + 0.14, 0.09, Vector3(jamb, h, 0.18), 0.03)
	if arched:
		var segments: int = 10
		var radius: float = w * 0.5
		var center_y: float = h - radius
		for step: int in range(segments):
			var a0: float = PI * float(step) / float(segments)
			var a1: float = PI * float(step + 1) / float(segments)
			var p0: Vector3 = _face_point(face, u + cos(a0) * radius, center_y + sin(a0) * radius, 0.02)
			var p1: Vector3 = _face_point(face, u + cos(a1) * radius, center_y + sin(a1) * radius, 0.02)
			var c: Vector3 = _face_point(face, u, center_y, 0.02)
			var n: Vector3 = (FACES[face] as Dictionary)["n"] as Vector3
			mesh.tri(id, [c, p0, p1], n)
			var q0: Vector3 = _face_point(face, u + cos(a0) * (radius + jamb), center_y + sin(a0) * (radius + jamb), 0.09)
			var q1: Vector3 = _face_point(face, u + cos(a1) * (radius + jamb), center_y + sin(a1) * (radius + jamb), 0.09)
			var r0: Vector3 = _face_point(face, u + cos(a0) * radius, center_y + sin(a0) * radius, 0.09)
			var r1: Vector3 = _face_point(face, u + cos(a1) * radius, center_y + sin(a1) * radius, 0.09)
			mesh.quad("foundation", [r0, r1, q1, q0], n)
		_face_quad(id, face, u - radius, u + radius, bottom + 0.28, center_y, 0.02)
	else:
		_attach("beam", face, u, bottom + h + 0.14, 0.09, Vector3(w + jamb * 2.0, 0.26, 0.18), 0.03)
		_face_quad(id, face, u - w * 0.5, u + w * 0.5, bottom + 0.28, h, 0.03)
	# door furniture
	if id == "ENV-DOOR-02":
		_attach("beam", face, u, h * 0.5, 0.06, Vector3(0.08, h - 0.4, 0.06), 0.01)
		_attach("glass", face, u, h * 0.72, 0.045, Vector3(w - 0.4, 0.7, 0.03), 0.0)
		_attach("beam", face, u, h * 0.72, 0.07, Vector3(w - 0.3, 0.06, 0.05), 0.0)
	else:
		for strap: float in [0.9, 2.4]:
			_attach("iron", face, u, strap, 0.05, Vector3(w - 0.1, 0.12, 0.04), 0.01)
	_attach("iron", face, u + w * 0.32, 1.7, 0.1, Vector3(0.12, 0.12, 0.1), 0.02)
	anchors["door_%s_%s" % [face, str(u)]] = _face_point(face, u, 0.0, 0.9)
	if bool(data.get("awning", false)):
		_awning(face, u, h + 0.5, w + 1.4, str(data.get("awning_id", "ENV-AWNING-01")))
	if bool(data.get("lantern", false)):
		_wall_lantern(face, u + w * 0.5 + 0.9, 2.9, true)
	if bool(data.get("pots", false)):
		_pots(face, u - w * 0.5 - 0.8, 0.55)
		_pots(face, u + w * 0.5 + 0.8, 0.4)


## Window styles of the kit (the geometry stand-ins of ENV-WINDOW-01..05): width, height.
const WINDOW_SIZES: Dictionary = {
	"cross": Vector2(1.25, 1.6), "wide": Vector2(2.0, 1.4), "round": Vector2(1.1, 1.1), "arch": Vector2(1.2, 2.5), "shop": Vector2(3.0, 1.7),
}


func _window(face: String, u: float, y: float, id: String, data: Dictionary) -> void:
	if EnvKit.has_art(id):
		var size: float = float(data.get("w", 1.3))
		var material_slot: String = "art_%s" % id
		mesh.set_material(material_slot, EnvKit.material(id, true))
		_face_quad(material_slot, face, u - size * 0.5, u + size * 0.5, y - size * 0.7, y + size * 0.7, 0.05, [], [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)])
		return
	var generator: String = EnvKit.generator(id)
	var style: String = generator.trim_prefix("window_") if generator != "" else "cross"
	if not WINDOW_SIZES.has(style):
		style = "cross"
	_window_style(face, u, y, style, 0.0, bool(data.get("shutters", style == "cross")), bool(data.get("box", style == "wide")))


func _window_style(face: String, u: float, y: float, style: String, off: float, shutters: bool, flower_box: bool, scale_value: float = 1.0) -> void:
	var size: Vector2 = (WINDOW_SIZES[style] as Vector2) * scale_value
	var w: float = size.x
	var h: float = size.y
	var frame: float = 0.14
	var n: Vector3 = (FACES[face] as Dictionary)["n"] as Vector3
	var u_dir: Vector3 = (FACES[face] as Dictionary)["u"] as Vector3
	if style == "round":
		var radius: float = w * 0.5
		var segs: int = 14
		var center: Vector3 = _face_point(face, u, y, off + 0.03)
		for step: int in range(segs):
			var a0: float = TAU * float(step) / float(segs)
			var a1: float = TAU * float(step + 1) / float(segs)
			var p0: Vector3 = center + u_dir * cos(a0) * radius + Vector3.UP * sin(a0) * radius
			var p1: Vector3 = center + u_dir * cos(a1) * radius + Vector3.UP * sin(a1) * radius
			mesh.tri("glass", [center, p0, p1], n)
			mesh.tube("beam", p0 + n * 0.04, p1 + n * 0.04, 0.09, 6, false)
		mesh.box("beam", center + n * 0.06, Vector3(radius * 2.0, 0.07, 0.06), _face_basis(face), 0.0)
		mesh.box("beam", center + n * 0.06, Vector3(0.07, radius * 2.0, 0.06), _face_basis(face), 0.0)
		return
	var half_w: float = w * 0.5
	var half_h: float = h * 0.5
	var arch: bool = style == "arch"
	var rect_top: float = y + half_h - (half_w if arch else 0.0)
	var side_h: float = h - (half_w if arch else 0.0) + frame
	var side_y: float = y - (half_w * 0.5 if arch else 0.0)
	_attach("beam", face, u - half_w - frame * 0.5, side_y, off + 0.08, Vector3(frame, side_h, 0.16), 0.02)
	_attach("beam", face, u + half_w + frame * 0.5, side_y, off + 0.08, Vector3(frame, side_h, 0.16), 0.02)
	_attach("beam", face, u, y - half_h - 0.06, off + 0.12, Vector3(w + frame * 2.0 + 0.3, 0.16, 0.26), 0.03)
	if not arch:
		_attach("beam", face, u, y + half_h + 0.07, off + 0.09, Vector3(w + frame * 2.0 + 0.1, 0.16, 0.18), 0.02)
	_face_quad("glass", face, u - half_w, u + half_w, y - half_h, rect_top, off + 0.03)
	if y < 4.0 and off == 0.0:
		glows.append(_face_point(face, u, 0.0, 1.7))
	if arch:
		var c_a: Vector3 = _face_point(face, u, rect_top, off + 0.03)
		for step: int in range(8):
			var a0: float = PI * float(step) / 8.0
			var a1: float = PI * float(step + 1) / 8.0
			var p0: Vector3 = c_a + u_dir * cos(a0) * half_w + Vector3.UP * sin(a0) * half_w
			var p1: Vector3 = c_a + u_dir * cos(a1) * half_w + Vector3.UP * sin(a1) * half_w
			mesh.tri("glass", [c_a, p0, p1], n)
			mesh.tube("foundation", p0 + n * 0.05, p1 + n * 0.05, 0.1, 6, false)
	_attach("beam", face, u, side_y, off + 0.06, Vector3(0.07, side_h - 0.1, 0.06), 0.0)
	var cols: int = 3 if style == "shop" else (2 if style == "wide" else 1)
	for index: int in range(1, cols):
		_attach("beam", face, u - half_w + w * float(index) / float(cols), side_y, off + 0.06, Vector3(0.06, side_h - 0.1, 0.06), 0.0)
	_attach("beam", face, u, y + 0.1, off + 0.06, Vector3(w, 0.07, 0.06), 0.0)
	if style == "shop":
		_attach("beam", face, u, y - half_h - 0.28, off + 0.22, Vector3(w + 0.5, 0.14, 0.5), 0.03)
	if shutters:
		for side: float in [-1.0, 1.0]:
			_attach("shutter", face, u + side * (half_w + frame + 0.34), y, off + 0.07, Vector3(0.62, h + 0.1, 0.07), 0.02)
			for slat: int in range(5):
				_attach("shutter_dark", face, u + side * (half_w + frame + 0.34), y - h * 0.4 + h * 0.2 * float(slat), off + 0.115, Vector3(0.5, 0.05, 0.03), 0.0)
	if flower_box:
		_flowerbox(face, u, y - half_h - 0.32, w + 0.3)


func _flowerbox(face: String, u: float, y: float, w: float) -> void:
	_attach("pot", face, u, y, 0.3, Vector3(w, 0.3, 0.38), 0.04)
	var count: int = maxi(3, int(w / 0.42))
	for index: int in range(count):
		var bloom: Color = FLOWERS[(index + _flower_index + int(hw * 3.0)) % FLOWERS.size()]
		var local_u: float = u - w * 0.5 + w * (float(index) + 0.5) / float(count)
		mesh.blob("plant", _face_point(face, local_u, y + 0.28, 0.32), Vector3(0.22, 0.2, 0.22), 4, 9, 1.0, bloom)
		mesh.blob("plant", _face_point(face, local_u + 0.1, y + 0.22, 0.34), Vector3(0.2, 0.14, 0.2), 4, 9, 1.0, Color("4f8f3c"))
	_flower_index += 1


func _pots(face: String, u: float, scale_value: float) -> void:
	var data: Dictionary = FACES[face] as Dictionary
	var n: Vector3 = data["n"] as Vector3
	var base: Vector3 = _face_point(face, u, 0.0, 0.45)
	var profile: Array[Vector2] = [Vector2(0.14, 0.0), Vector2(0.2, 0.04), Vector2(0.28, 0.3), Vector2(0.3, 0.42), Vector2(0.26, 0.42), Vector2(0.0, 0.4)]
	var scaled: Array[Vector2] = []
	for point: Vector2 in profile:
		scaled.append(point * Vector2(scale_value * 1.6, scale_value * 1.6))
	mesh.lathe("pot", base, scaled, 10, 0.85)
	var top: float = 0.4 * scale_value * 1.6
	mesh.blob("plant", base + Vector3(0, top + 0.2 * scale_value, 0), Vector3(0.36, 0.3, 0.36) * (scale_value * 1.8), 4, 9, 1.0, FLOWERS[(_flower_index + int(hw * 3.0)) % FLOWERS.size()])
	mesh.blob("plant", base + Vector3(0.1, top + 0.08, 0.05) + n * 0.0, Vector3(0.3, 0.18, 0.3) * (scale_value * 1.8), 4, 9, 1.0, Color("4f8f3c"))
	_flower_index += 1


func _awning(face: String, u: float, y: float, w: float, id: String) -> void:
	var slot: String = "awning_a" if id == "ENV-AWNING-01" else "awning_b"
	var out: float = 1.25
	var drop: float = 0.65
	var n: Vector3 = (FACES[face] as Dictionary)["n"] as Vector3
	var u0: float = u - w * 0.5
	var u1: float = u + w * 0.5
	var top: Array[Vector3] = [_face_point(face, u0, y + drop, 0.02), _face_point(face, u1, y + drop, 0.02), _face_point(face, u1, y, out), _face_point(face, u0, y, out)]
	mesh.quad(slot, top, n + Vector3.UP, [Color.WHITE, Color.WHITE, Color(0.85, 0.85, 0.85), Color(0.85, 0.85, 0.85)], [Vector2(u0, 0), Vector2(u1, 0), Vector2(u1, out), Vector2(u0, out)])
	mesh.quad(slot, [_face_point(face, u0, y, out), _face_point(face, u1, y, out), _face_point(face, u1, y - 0.34, out), _face_point(face, u0, y - 0.34, out)], n, [Color(0.9, 0.9, 0.9), Color(0.9, 0.9, 0.9), Color(0.7, 0.7, 0.7), Color(0.7, 0.7, 0.7)], [Vector2(u0, 0), Vector2(u1, 0), Vector2(u1, 0.34), Vector2(u0, 0.34)])
	for side: float in [-1.0, 1.0]:
		var uu: float = u + side * w * 0.5
		var left_n: Vector3 = (FACES[face] as Dictionary)["u"] as Vector3
		mesh.tri(slot, [_face_point(face, uu, y + drop, 0.02), _face_point(face, uu, y, out), _face_point(face, uu, y - 0.34, out)], left_n * side)
		mesh.tube("beam", _face_point(face, uu, y + drop - 0.2, 0.05), _face_point(face, uu, y - 0.3, out - 0.05), 0.045, 6, false)


func _sign(face: String, u: float, y: float, id: String, size: float) -> void:
	var n: Vector3 = (FACES[face] as Dictionary)["n"] as Vector3
	var slot: String = "sign_%s" % id
	mesh.set_material(slot, EnvKit.material(id, true))
	var arm_out: float = 0.9
	_attach("iron", face, u, y + size * 0.82 + 0.1, arm_out * 0.5, Vector3(0.1, 0.1, arm_out), 0.02)
	var u_dir: Vector3 = (FACES[face] as Dictionary)["u"] as Vector3
	var center: Vector3 = _face_point(face, u, y, arm_out)
	var half: float = size * 0.5
	var height: float = size * 1.25
	# a board facing the street, hung by two chains from the arm
	mesh.quad(slot, [center - u_dir * half + Vector3(0, height * 0.5, 0), center + u_dir * half + Vector3(0, height * 0.5, 0), center + u_dir * half - Vector3(0, height * 0.5, 0), center - u_dir * half - Vector3(0, height * 0.5, 0)], n, [], [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])
	for side: float in [-1.0, 1.0]:
		mesh.tube("iron", center + u_dir * half * 0.8 * side + Vector3(0, height * 0.5, 0), _face_point(face, u + half * 0.8 * side, y + size * 0.82 + 0.1, arm_out), 0.02, 4, false)


func _wall_lantern(face: String, u: float, y: float, with_light: bool) -> void:
	var n: Vector3 = (FACES[face] as Dictionary)["n"] as Vector3
	_attach("iron", face, u, y + 0.28, 0.3, Vector3(0.08, 0.08, 0.6), 0.01)
	_attach("iron", face, u, y, 0.62, Vector3(0.36, 0.08, 0.36), 0.02)
	_attach("lantern", face, u, y + 0.24, 0.62, Vector3(0.26, 0.4, 0.26), 0.04)
	_attach("iron", face, u, y + 0.48, 0.62, Vector3(0.38, 0.08, 0.38), 0.03)
	if with_light:
		lights.append({"pos": _face_point(face, u, y + 0.24, 0.9), "color": LANTERN_COLOR, "range": 6.5, "energy": 1.7, "kind": "lantern"})
	var _keep: Vector3 = n


func _ivy(face: String, u: float, h: float, w: float) -> void:
	var slot: String = "ivy"
	mesh.set_material(slot, EnvKit.material("DEC-IVY", true))
	_face_quad(slot, face, u - w * 0.5, u + w * 0.5, foundation - 0.1, foundation - 0.1 + h, 0.1, [], [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)])


func _stain(face: String, u: float, y: float) -> void:
	var slot: String = "stain"
	var stain_material: StandardMaterial3D = EnvKit.material("DEC-WALLSTAIN", true)
	mesh.set_material(slot, stain_material)
	_face_quad(slot, face, u - 0.9, u + 0.9, y - 1.4, y + 0.2, 0.025, [], [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)])
