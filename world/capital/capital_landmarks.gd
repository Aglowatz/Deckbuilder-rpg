class_name CapitalLandmarks
extends RefCounted
## The Capital's hero landmarks modelled after the approved concepts (docs/art/zone_kits/final/concepts/CAP-HERO-*.jpg) with the zone kit's painted
## surfaces (data/art/zone_kits/final.json, `CapitalKit`), in place of the layout pass's stand-ins and placed by `CapitalBuilder` from the layout's
## constants. `HeroLandmarks` dispatches "CAP-HERO-" ids here: Primm's Castle (`CapitalCastle`), the great wall's gate, the Primm statue fountain,
## the rifts (each copy varied in size and turn), the broken watchtower, the Old Service Tunnels' mouth and the resistance camp; the four district
## models and the Correction Ward live in `CapitalDistricts`. Each model is one `KitMesh` (a handful of surfaces) plus the odd moving or
## camera-facing child. Same contract as the other zones' heroes: origin on the ground, the front +z (south, toward the player), meta "circles",
## "height", "lights". Nothing carries readable text (Art Bible G-03).

const K = preload("res://world/capital/capital_kit.gd")

const IDS: Array[String] = [
	"CAP-HERO-PRIMMS-CASTLE", "CAP-HERO-GREAT-WALL-GATE", "CAP-HERO-PRIMM-FOUNTAIN", "CAP-HERO-RIFT", "CAP-HERO-WATCHTOWER", "CAP-HERO-SERVICE-TUNNEL",
	"CAP-HERO-RESISTANCE-CAMP", "CAP-HERO-TRAM-SHED", "CAP-HERO-IDENTICAL-ROW", "CAP-HERO-GRAVE-ROW", "CAP-HERO-THE-REEK", "CAP-HERO-CORRECTION-WARD",
]
## The essence icon of each Path (`IconArt`): the camp's scraps and the watchtower's old banner carry all four (Beefcake, Gourmand, Necrocrat,
## Refusemancer).
const PATH_ICONS: Array[String] = ["ICON-ESSENCE-B", "ICON-ESSENCE-G", "ICON-ESSENCE-N", "ICON-ESSENCE-R"]


static func has_model(id: String) -> bool:
	return id in IDS


## The model for `spec` ({id, size [w, h, d], final, state ("broken" / "restored"), seed, radius, big}).
static func build(spec: Dictionary) -> Node3D:
	var id: String = str(spec.get("id", ""))
	var final_state: bool = bool(spec.get("final", false))
	var node: Node3D = null
	match id:
		"CAP-HERO-PRIMMS-CASTLE":
			node = CapitalCastle.build(final_state)
		"CAP-HERO-GREAT-WALL-GATE":
			node = gate_arch(final_state)
		"CAP-HERO-PRIMM-FOUNTAIN":
			node = fountain(final_state)
		"CAP-HERO-RIFT":
			node = rift(int(spec.get("seed", 0)), float(spec.get("radius", 1.2)), bool(spec.get("big", false)))
		"CAP-HERO-WATCHTOWER":
			node = watchtower()
		"CAP-HERO-SERVICE-TUNNEL":
			node = tunnel_mouth()
		"CAP-HERO-RESISTANCE-CAMP":
			node = camp()
		_:
			node = CapitalDistricts.build(spec)
	if node != null:
		node.set_meta("kind", "hero")
		node.set_meta("hero_id", id)
	return node


## Marks every mesh under `node` as a far view: never range-culled, and (with `fade` false) never faded by the occlusion fader.
static func mark_view(node: Node, fade: bool = false) -> void:
	if node is GeometryInstance3D:
		node.set_meta(&"no_range_cull", true)
		if not fade:
			node.set_meta(&"no_occlusion_fade", true)
	for child: Node in node.get_children():
		mark_view(child, fade)


static func finish(root: Node3D, mesh: KitMesh, circles: Array[Vector3] = [], height: float = 0.0) -> Node3D:
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	root.add_child(body)
	root.move_child(body, 0)
	root.set_meta("circles", circles)
	root.set_meta("height", height)
	root.set_meta("triangles", mesh.triangle_count())
	root.set_meta(&"no_wind", true)
	return root


## An icon picture (a Path's essence, Primm's emblem) on a little quad, as a child: `IconSign` keeps it unlit and readable.
static func icon(root: Node3D, icon_id: String, pos: Vector3, size: float, yaw_deg: float = 0.0) -> void:
	var picture: MeshInstance3D = IconSign.picture(Vector2(size, size), icon_id, pos)
	picture.rotation_degrees.y = yaw_deg
	root.add_child(picture)


## A flat band (a line drawn as a quad) from `a` to `b`, `width` wide, facing `normal`.
static func band(mesh: KitMesh, slot: String, a: Vector3, b: Vector3, width: float, normal: Vector3) -> void:
	var across: Vector3 = (b - a).cross(normal).normalized() * width * 0.5
	mesh.quad(slot, [a - across, b - across, b + across, a + across], normal)


# ---- the great wall and its gate (CAP-HERO-GREAT-WALL-GATE) ---------------------------------------------------------------------------------


## A piece of the great wall (`w` x `h` x `d`, centred, the outside face +z): flawless white plaster in ashlar courses on a battered stone plinth, a
## cornice and crenellations with gold copings, deep pilasters every bay rising into gold-capped pinnacles over the parapet, Primm's white-and-gold
## banners in every other bay on both faces, and (`towers`, offsets along the piece) square towers standing out from the outer face, each with
## corner pinnacles, a gold spire and a tall dark sun banner (the concept and every outside paint-over). A few hairline cracks start on the outer
## face (`seed_value` places them). `batter` is how far the plinth steps out at the ground (outer face, inner face). Pristine against the ruin.
static func wall_piece(w: float, h: float, d: float, seed_value: int, towers: Array[float] = [], batter: Vector2 = Vector2(0.3, 0.3)) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh)
	var along_x: bool = w >= d
	var length: float = w if along_x else d
	var depth: float = d if along_x else w
	var basis: Basis = Basis.IDENTITY if along_x else Basis(Vector3.UP, PI * 0.5)
	var sized: Callable = func(x: float, y: float, z: float) -> Vector3: return Vector3(x, y, z) if along_x else Vector3(z, y, x)
	var plinth_h: float = 1.6
	mesh.box("plaster", Vector3(0, h * 0.5, 0), sized.call(length, h, depth), Basis.IDENTITY, 0.0, 0.8)
	for face: float in [-1.0, 1.0]:
		var normal: Vector3 = basis * Vector3(0, 0, face)
		var z: float = face * (depth * 0.5)
		var out: float = batter.x if face > 0.0 else batter.y
		# the battered plinth: a sloping stone skirt from the ground up to a moulded band
		var foot: float = z + face * out
		var skirt: Array[Vector3] = [basis * Vector3(-length * 0.5, 0.0, foot), basis * Vector3(length * 0.5, 0.0, foot), basis * Vector3(length * 0.5, plinth_h, z + face * 0.02), basis * Vector3(-length * 0.5, plinth_h, z + face * 0.02)]
		mesh.quad("marble_shade", skirt, normal + Vector3(0, out / plinth_h, 0), [Color(0.72, 0.72, 0.72), Color(0.72, 0.72, 0.72), Color.WHITE, Color.WHITE])
		mesh.box("marble_shade", basis * Vector3(0, plinth_h + 0.1, z + face * 0.08), sized.call(length, 0.2, 0.16), Basis.IDENTITY, 0.03)
		# ashlar courses: thin joints every course, the vertical joints staggered course to course
		var course: float = 1.25
		var y: float = plinth_h + course
		var row: int = 0
		while y < h - 1.2:
			mesh.quad("marble_shade", [basis * Vector3(-length * 0.5, y - 0.025, z + face * 0.012), basis * Vector3(length * 0.5, y - 0.025, z + face * 0.012), basis * Vector3(length * 0.5, y + 0.025, z + face * 0.012), basis * Vector3(-length * 0.5, y + 0.025, z + face * 0.012)], normal)
			var joint: float = -length * 0.5 + (1.3 if row % 2 == 0 else 0.0)
			while joint < length * 0.5:
				if joint > -length * 0.5 + 0.1:
					mesh.quad("marble_shade", [basis * Vector3(joint - 0.02, y - course + 0.03, z + face * 0.012), basis * Vector3(joint + 0.02, y - course + 0.03, z + face * 0.012), basis * Vector3(joint + 0.02, y - 0.03, z + face * 0.012), basis * Vector3(joint - 0.02, y - 0.03, z + face * 0.012)], normal)
				joint += 2.6
			y += course
			row += 1
		# the cornice under the parapet: a gold band over a projecting moulding
		mesh.box("plaster", basis * Vector3(0, h - 0.75, z + face * 0.14), sized.call(length, 0.3, 0.28), Basis.IDENTITY, 0.04)
		mesh.box("trim", basis * Vector3(0, h - 0.45, z + face * 0.05), sized.call(length, 0.36, 0.1))
		# pilasters every bay: a stone base, a deep white shaft, a gold capital, a pinnacle over the parapet
		var bays: int = maxi(1, int(round(length / 6.0)))
		for index: int in range(bays + 1):
			var x: float = clampf(-length * 0.5 + length * float(index) / float(bays), -length * 0.5 + 0.55, length * 0.5 - 0.55)
			mesh.box("marble_shade", basis * Vector3(x, plinth_h * 0.5, z + face * (out + 0.3) * 0.5), sized.call(1.25, plinth_h, out + 0.3), Basis.IDENTITY, 0.04, 0.8)
			mesh.box("plaster", basis * Vector3(x, h * 0.5, z + face * 0.28), sized.call(0.95, h, 0.56), Basis.IDENTITY, 0.05, 0.82)
			mesh.box("gold", basis * Vector3(x, h - 0.2, z + face * 0.32), sized.call(1.15, 0.32, 0.66), Basis.IDENTITY, 0.03)
			if face > 0.0:
				pinnacle(mesh, basis * Vector3(x, h + 0.6, 0.0), 0.8, 2.0)
			if index < bays and (index + seed_value) % 2 == 0:
				var mid: float = x + length / float(bays) * 0.5
				var banner: String = ["CAP-SHEET-BANNERS-01", "CAP-SHEET-BANNERS-04", "CAP-SHEET-BANNERS-03"][(index + seed_value) % 3]
				var near_tower: bool = false
				for offset: float in towers:
					near_tower = near_tower or (face > 0.0 and absf(offset - mid) < 3.2)
				if near_tower:
					continue
				if face > 0.0:
					# the outer face: the dark sun banners of the paint-overs, the white wall's contrast
					sun_banner(mesh, basis * Vector3(mid, h - 0.9, z + 0.02), 1.7, 4.6, normal)
				else:
					K.card(mesh, banner, basis * Vector3(mid, h - 1.1, z + face * 0.08), 3.6, normal)
	# the parapet: the breastwork and the crenellations, every merlon gold-capped
	mesh.box("plaster", Vector3(0, h + 0.3, 0), sized.call(length, 0.6, depth + 0.2), Basis.IDENTITY, 0.03)
	var count: int = maxi(2, int(length / 1.5))
	for index: int in range(count):
		if index % 2 == 1:
			continue
		var x: float = -length * 0.5 + (float(index) + 0.5) * length / float(count)
		mesh.box("plaster", basis * Vector3(x, h + 0.95, 0.0), sized.call(length / float(count) * 0.95, 0.7, depth + 0.2), Basis.IDENTITY, 0.04)
		mesh.box("gold", basis * Vector3(x, h + 1.33, 0.0), sized.call(length / float(count), 0.08, depth + 0.26))
	# the towers standing out from the outer face, each with its tall dark sun banner
	for offset: float in towers:
		_wall_tower(mesh, basis, sized, offset, h, depth, batter.x)
		sun_banner(mesh, basis * Vector3(offset, h + 1.4, depth * 0.5 + WALL_TOWER_OUT + 0.02), 2.4, 7.2, basis * Vector3(0, 0, 1))
	# a few hairline cracks starting on the outer face (dark, not glowing: the rift light lives in the castle)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7700 + seed_value
	for crack: int in range(maxi(1, int(length / 18.0))):
		var points: Array[Vector3] = [Vector3(rng.randf_range(-length * 0.4, length * 0.4), rng.randf_range(1.9, 2.6), depth * 0.5 + 0.03)]
		for step: int in range(4):
			points.append(points[points.size() - 1] + Vector3(rng.randf_range(-0.4, 0.4), rng.randf_range(0.5, 1.0), 0.0))
		for index: int in range(points.size() - 1):
			band(mesh, "stone_dark", basis * points[index], basis * points[index + 1], 0.06, basis * Vector3(0, 0, 1))
	return finish(root, mesh, [], h + 5.0)


## The great wall's dark sun banner (every outside paint-over: the contrast on the white wall): a long navy cloth with a swallow-tailed hem and a
## gold border, the radiant smiling sun in gold on it, hung from a gold rod with finials. `top` is the rod's middle, `normal` the face it hangs on.
static func sun_banner(mesh: KitMesh, top: Vector3, width: float, length: float, normal: Vector3) -> void:
	var right: Vector3 = Vector3.UP.cross(normal).normalized() * -1.0
	var out: Vector3 = normal * 0.05
	var half: float = width * 0.5
	var hem: float = length - width * 0.35
	var a: Vector3 = top - right * half + out
	var b: Vector3 = top + right * half + out
	var notch: Vector3 = top + out - Vector3(0, hem - width * 0.2, 0)
	mesh.quad("canvas_navy", [a - Vector3(0, hem, 0), b - Vector3(0, hem, 0), b, a], normal, [Color(0.72, 0.72, 0.8), Color(0.72, 0.72, 0.8), Color.WHITE, Color.WHITE])
	var tip_l: Vector3 = top + out - Vector3(0, length, 0) - right * half * 0.85
	var tip_r: Vector3 = top + out - Vector3(0, length, 0) + right * half * 0.85
	mesh.tri("canvas_navy", [a - Vector3(0, hem, 0), notch, tip_l], normal)
	mesh.tri("canvas_navy", [notch, b - Vector3(0, hem, 0), tip_r], normal)
	var edge: float = width * 0.05
	for side: float in [-1.0, 1.0]:
		band(mesh, "gold", top + right * side * (half - edge) + out * 1.2, top + right * side * (half - edge) + out * 1.2 - Vector3(0, hem, 0), edge, normal)
	K.sun_emblem(mesh, top + out * 1.6 - Vector3(0, length * 0.36, 0), width * 0.24, normal)
	var rod_a: Vector3 = top - right * (half + 0.25) + out * 2.0 + Vector3(0, 0.08, 0)
	var rod_b: Vector3 = top + right * (half + 0.25) + out * 2.0 + Vector3(0, 0.08, 0)
	mesh.tube("gold", rod_a, rod_b, 0.07, 6)
	for end: Vector3 in [rod_a, rod_b]:
		mesh.blob("gold", end, Vector3(0.12, 0.12, 0.12), 3, 6)


## How far a wall tower stands out from the wall's outer face (the layout keeps that strip solid, `CapitalLayout.WALL_TOWERS`).
const WALL_TOWER_OUT: float = 0.7
const WALL_TOWER_WIDTH: float = 4.0


## One square tower standing out from the wall's outer face at `offset` along it (the wall's own frame: `basis`, `sized`): a battered stone base,
## the shaft with gold bands, a cornice, a crenellated top with four corner pinnacles and a gold spire.
static func _wall_tower(mesh: KitMesh, basis: Basis, sized: Callable, offset: float, h: float, depth: float, batter: float) -> void:
	var width: float = WALL_TOWER_WIDTH
	var top: float = h + 2.4
	var back: float = -depth * 0.5 + 0.4
	var front: float = depth * 0.5 + WALL_TOWER_OUT
	var center_z: float = (back + front) * 0.5
	var span: float = front - back
	mesh.box("marble_shade", basis * Vector3(offset, 0.9, center_z + batter * 0.5), sized.call(width + batter * 2.0, 1.8, span + batter), Basis.IDENTITY, 0.06, 0.75)
	mesh.box("plaster", basis * Vector3(offset, top * 0.5, center_z), sized.call(width, top, span), Basis.IDENTITY, 0.06, 0.8)
	for corner: float in [-1.0, 1.0]:
		mesh.box("plaster", basis * Vector3(offset + corner * (width * 0.5 - 0.15), top * 0.5, front - 0.1), sized.call(0.5, top, 0.4), Basis.IDENTITY, 0.04, 0.85)
	for y: float in [2.0, h * 0.55, top - 0.6]:
		mesh.box("trim", basis * Vector3(offset, y, center_z), sized.call(width + 0.12, 0.32, span + 0.12))
	mesh.box("plaster", basis * Vector3(offset, top + 0.2, center_z), sized.call(width + 0.5, 0.4, span + 0.5), Basis.IDENTITY, 0.04)
	for cx: float in [-1.0, 1.0]:
		for cz: float in [-1.0, 1.0]:
			pinnacle(mesh, basis * Vector3(offset + cx * (width * 0.5 - 0.1), top + 0.4, center_z + cz * (span * 0.5 - 0.1)), 0.7, 1.9)
	mesh.lathe("gold", basis * Vector3(offset, top + 0.4, center_z), [Vector2(0.8, 0.0), Vector2(0.45, 1.3), Vector2(0.0, 3.2)], 8, 1.0, false, false)
	K.finial(mesh, basis * Vector3(offset, top + 3.0, center_z), 1.0)


## A gold-capped white pinnacle: a square shaft with a gold band and a gold pyramid with a finial, `width` square and `height` tall from `base`.
static func pinnacle(mesh: KitMesh, base: Vector3, width: float, height: float) -> void:
	mesh.box("plaster", base + Vector3(0, height * 0.32, 0), Vector3(width, height * 0.64, width), Basis.IDENTITY, 0.04)
	mesh.box("gold", base + Vector3(0, height * 0.64, 0), Vector3(width * 1.12, 0.12, width * 1.12))
	mesh.lathe("gold", base + Vector3(0, height * 0.7, 0), [Vector2(width * 0.62, 0.0), Vector2(0.0, height * 0.42)], 4, 1.0, false, false)
	K.finial(mesh, base + Vector3(0, height * 1.08, 0), width * 0.6)


## A corner tower where two runs of the great wall meet (the front wall and a side wall): a square white tower a little wider than the wall, its
## battered base, gold bands, crenellated top, corner pinnacles and a gold spire; a sun banner on its outer (south) face.
static func corner_tower(size: float, h: float) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh)
	var top: float = h + 3.0
	mesh.box("marble_shade", Vector3(0, 0.9, 0), Vector3(size + 0.5, 1.8, size + 0.5), Basis.IDENTITY, 0.06, 0.75)
	mesh.box("plaster", Vector3(0, top * 0.5, 0), Vector3(size, top, size), Basis.IDENTITY, 0.06, 0.8)
	for y: float in [2.0, h * 0.55, top - 0.6]:
		mesh.box("trim", Vector3(0, y, 0), Vector3(size + 0.12, 0.32, size + 0.12))
	mesh.box("plaster", Vector3(0, top + 0.2, 0), Vector3(size + 0.5, 0.4, size + 0.5), Basis.IDENTITY, 0.04)
	for cx: float in [-1.0, 1.0]:
		for cz: float in [-1.0, 1.0]:
			pinnacle(mesh, Vector3(cx * (size * 0.5 - 0.1), top + 0.4, cz * (size * 0.5 - 0.1)), 0.75, 2.0)
	mesh.lathe("gold", Vector3(0, top + 0.4, 0), [Vector2(0.9, 0.0), Vector2(0.5, 1.5), Vector2(0.0, 3.6)], 8, 1.0, false, false)
	K.finial(mesh, Vector3(0, top + 3.4, 0), 1.1)
	sun_banner(mesh, Vector3(0, h + 0.6, size * 0.5 + 0.02), 2.2, 6.4, Vector3(0, 0, 1))
	return finish(root, mesh, [], top + 4.0)


## A gate tower (`w` x `h` x `d`): a square white tower with gold bands and corner pilasters, a parapet, gold finials on its corners and a gold
## spire; a big sun-faced banner on its outer face and Primm's banner on the inner one (the wall concept).
static func gate_tower(w: float, h: float, d: float) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh)
	mesh.box("plaster", Vector3(0, h * 0.5, 0), Vector3(w, h, d), Basis.IDENTITY, 0.06, 0.8)
	mesh.box("marble_shade", Vector3(0, 0.9, 0), Vector3(w + 0.6, 1.8, d + 0.6), Basis.IDENTITY, 0.06, 0.75)
	for y: float in [0.6, h * 0.5, h - 0.6]:
		mesh.box("trim", Vector3(0, y, 0), Vector3(w + 0.12, 0.5, d + 0.12))
	for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		var c: Vector3 = Vector3(corner.x * (w * 0.5), 0, corner.y * (d * 0.5))
		mesh.box("plaster", c + Vector3(0, h * 0.5 + 0.6, 0), Vector3(1.0, h + 1.2, 1.0), Basis.IDENTITY, 0.04, 0.85)
		pinnacle(mesh, c + Vector3(0, h + 1.2, 0), 0.9, 2.6)
	for side: Vector3 in [Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(-1, 0, 0)]:
		var reach: float = (d if side.x == 0.0 else w) * 0.5
		var span: float = (w if side.x == 0.0 else d)
		mesh.box("plaster", side * reach + Vector3(0, h + 0.45, 0), Vector3(span + 0.3, 0.9, 0.4) if side.x == 0.0 else Vector3(0.4, 0.9, span + 0.3))
	mesh.lathe("gold", Vector3(0, h, 0), [Vector2(w * 0.32, 0.0), Vector2(w * 0.2, 2.5), Vector2(0.0, 6.0)], 4, 1.0, false, false)
	K.finial(mesh, Vector3(0, h + 5.6, 0), 1.4)
	sun_banner(mesh, Vector3(0, h - 0.8, d * 0.5 + 0.02), 3.0, 8.4, Vector3(0, 0, 1))
	K.card(mesh, "CAP-SHEET-BANNERS-03", Vector3(0, h - 1.4, -d * 0.5 - 0.06), 5.0, Vector3(0, 0, -1))
	return finish(root, mesh, [], h + 6.0)


## The great gate's crown between the two towers (CAP-HERO-GREAT-WALL-GATE): a white lintel over the 10 m opening at the wall's height, a gold
## pointed arch outlined down the towers' edges on both faces, and the radiant smiling sun-emblem over it (Primm's plain emblem inside). Nothing
## solid below 9 m, so the way through stays open; the barrier in the opening is the gate itself (`CapitalProps.gate_barrier`). Origin at the
## opening's centre on the ground.
static func gate_arch(final_state: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "GateArch"
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh, Color(0.62, 0.57, 0.5) if final_state else Color.WHITE)
	var span: float = 10.0
	var depth: float = 4.4
	mesh.box("plaster", Vector3(0, 10.3, 0), Vector3(span + 0.4, 2.6, depth), Basis.IDENTITY, 0.05, 0.85)
	for face: float in [-1.0, 1.0]:
		var normal: Vector3 = Vector3(0, 0, face)
		var z: float = face * (depth * 0.5 + 0.04)
		mesh.box("trim", Vector3(0, 9.25, z), Vector3(span + 0.4, 0.5, 0.08))
		mesh.box("trim", Vector3(0, 11.35, z), Vector3(span + 0.4, 0.5, 0.08))
		var steps: int = 9
		var previous: Vector3 = Vector3(-span * 0.5, 4.2, z)
		for index: int in range(1, steps + 1):
			var t: float = float(index) / float(steps)
			var point: Vector3 = Vector3(-span * 0.5 + span * 0.5 * (1.0 - cos(t * PI * 0.5)), 4.2 + 4.8 * sin(t * PI * 0.5), z)
			band(mesh, "gold", previous, point, 0.32, normal)
			band(mesh, "gold", Vector3(-previous.x, previous.y, z), Vector3(-point.x, point.y, z), 0.32, normal)
			previous = point
		band(mesh, "gold", Vector3(-span * 0.5, 0.2, z), Vector3(-span * 0.5, 4.2, z), 0.32, normal)
		band(mesh, "gold", Vector3(span * 0.5, 0.2, z), Vector3(span * 0.5, 4.2, z), 0.32, normal)
	# the crest over the lintel, the sun-emblem in it outside, the plain emblem inside
	var crest: Array[Vector3] = [Vector3(-3.2, 11.6, 0), Vector3(3.2, 11.6, 0), Vector3(0, 13.6, 0)]
	for face: float in [-1.0, 1.0]:
		var z: float = face * (depth * 0.5 - 0.6)
		mesh.tri("plaster", [crest[0] + Vector3(0, 0, z), crest[1] + Vector3(0, 0, z), crest[2] + Vector3(0, 0, z)], Vector3(0, 0, face))
	mesh.box("plaster", Vector3(0, 12.3, 0), Vector3(4.2, 1.4, depth - 1.2))
	K.finial(mesh, Vector3(0, 13.4, 0), 1.6)
	K.sun_emblem(mesh, Vector3(0, 11.0, depth * 0.5 + 0.1), 1.05, Vector3(0, 0, 1))
	K.emblem(mesh, Vector3(0, 11.0, -depth * 0.5 - 0.1), 0.95, Vector3(0, 0, -1), final_state, final_state)
	return finish(root, mesh, [], 15.0)


# ---- the Primm statue fountain (CAP-HERO-PRIMM-FOUNTAIN) ---------------------------------------------------------------------------------------


## The inside hub's centrepiece (7 m across, `CapitalLayout.FOUNTAIN_SIZE`): a pristine white marble basin with a gold rim and eight rose planters,
## a raised middle tier with Primm's face medallions and four gold spouts pouring into the basin, and on top the marble Primm smiling, arms spread,
## gold accents. Symmetric jets, a faint mist. When Primm has fallen the fountain runs dry and the statue lies toppled in the basin.
static func fountain(final_state: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "PrimmFountain"
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh, Color(0.62, 0.57, 0.5) if final_state else Color.WHITE)
	var outer: float = 3.3
	mesh.lathe("marble", Vector3.ZERO, [Vector2(outer, 0.0), Vector2(outer, 0.62), Vector2(outer - 0.35, 0.62), Vector2(outer - 0.35, 0.3)], 32, 0.8, false, false)
	mesh.lathe("gold", Vector3(0, 0.6, 0), [Vector2(outer + 0.03, 0.0), Vector2(outer + 0.03, 0.08), Vector2(outer - 0.38, 0.08)], 32, 1.0, false, false)
	mesh.lathe("marble_shade", Vector3(0, 0.05, 0), [Vector2(outer + 0.12, 0.0), Vector2(outer + 0.12, 0.18)], 32, 1.0, false, true)
	mesh.lathe("water" if not final_state else "dust", Vector3(0, 0.5 if not final_state else 0.32, 0), [Vector2(outer - 0.35, 0.0), Vector2(0.0, 0.0)], 32, 1.0, false, false)
	for index: int in range(8):
		var angle: float = TAU * float(index) / 8.0 + PI / 8.0
		var p: Vector3 = Vector3(cos(angle), 0, sin(angle)) * (outer - 0.1)
		K.post(mesh, p, Vector3(0.7, 0.85, 0.7), false)
		K.card(mesh, "CAP-PLANT-ROSE", p + Vector3(0, 0.95, 0), 0.75, Vector3(0, 0, 1))
	mesh.lathe("marble", Vector3.ZERO, [Vector2(1.7, 0.0), Vector2(1.7, 1.55), Vector2(1.85, 1.6), Vector2(1.85, 1.75), Vector2(1.5, 1.75)], 24, 0.85, false, false)
	mesh.lathe("gold", Vector3(0, 1.55, 0), [Vector2(1.88, 0.0), Vector2(1.88, 0.08)], 24, 1.0, false, false)
	if not final_state:
		mesh.lathe("water", Vector3(0, 1.66, 0), [Vector2(1.5, 0.0), Vector2(0.0, 0.0)], 24, 1.0, false, false)
	for index: int in range(4):
		var angle: float = TAU * float(index) / 4.0 + PI * 0.25
		var dir: Vector3 = Vector3(cos(angle), 0, sin(angle))
		K.emblem(mesh, dir * 1.72 + Vector3(0, 0.85, 0), 0.34, dir)
		var spout: Vector3 = Vector3(cos(angle + PI * 0.25), 0, sin(angle + PI * 0.25))
		mesh.blob("gold", spout * 1.82 + Vector3(0, 1.35, 0), Vector3(0.2, 0.18, 0.2), 4, 8)
		if not final_state:
			var points: Array[Vector3] = []
			for step: int in range(6):
				var t: float = float(step) / 5.0
				points.append(spout * lerpf(1.95, 2.75, t) + Vector3(0, 1.35 - 0.85 * t * t, 0))
			var across: Vector3 = Vector3(-spout.z, 0, spout.x) * 0.16
			for step: int in range(5):
				mesh.quad("water", [points[step] - across, points[step + 1] - across, points[step + 1] + across, points[step] + across], spout + Vector3.UP)
	mesh.lathe("marble", Vector3(0, 1.75, 0), [Vector2(0.8, 0.0), Vector2(0.7, 0.2), Vector2(0.6, 0.65), Vector2(0.75, 0.75)], 16, 0.9, false, true)
	mesh.lathe("gold", Vector3(0, 2.4, 0), [Vector2(0.78, 0.0), Vector2(0.78, 0.1)], 16, 1.0, false, true)
	if not final_state:
		K.primm_statue(mesh, Vector3(0, 2.5, 0), 3.6, Vector3(0, 0, 1))
	else:
		K.primm_statue(mesh, Vector3(0.4, 0.3, 0.6), 3.6, Vector3(0.7, 0, 0.7).normalized(), true)
	finish(root, mesh, [Vector3(0, 0, outer)], 6.5)
	if not final_state:
		var mist: CPUParticles3D = CPUParticles3D.new()
		mist.name = "Mist"
		mist.amount = 24
		mist.lifetime = 1.4
		mist.preprocess = 1.4
		mist.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
		mist.emission_ring_axis = Vector3.UP
		mist.emission_ring_radius = 2.6
		mist.emission_ring_inner_radius = 2.2
		mist.emission_ring_height = 0.1
		mist.direction = Vector3.UP
		mist.spread = 20.0
		mist.initial_velocity_min = 0.3
		mist.initial_velocity_max = 0.7
		mist.gravity = Vector3(0, -0.6, 0)
		var drop: SphereMesh = SphereMesh.new()
		drop.radius = 0.04
		drop.height = 0.08
		drop.radial_segments = 4
		drop.rings = 2
		mist.mesh = drop
		mist.material_override = K.water(0.55)
		mist.position = Vector3(0, 0.6, 0)
		root.add_child(mist)
	return root


# ---- the rifts (CAP-HERO-RIFT) -------------------------------------------------------------------------------------------------------------


## A magical rift (the concept): a jagged vertical tear in the air just above cracked, scorched ground, bright purple at its edges and dark inside,
## floating shards of stone and crystal turning slowly round it (the "Orbit" child), glowing crystals at its foot. Each copy is varied by
## `seed_value` (size, turn, lean, the shards); `radius` is the hazard's reach (the glowing "Rim" on the ground). The builder adds the light, the
## sparks and the warped-light lens and animates the "Tear", "Rim" and "Orbit" children.
static func rift(seed_value: int, radius: float, big: bool) -> Node3D:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 9100 + seed_value * 37
	var root: Node3D = Node3D.new()
	var size: float = (1.6 if big else 1.0) * rng.randf_range(0.85, 1.2)
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh)
	# the scorched ground: an irregular disc of rift-veined earth and broken flags
	var ground_r: float = radius * 1.55 + 0.6
	var steps: int = 18
	var ring: Array[Vector3] = []
	for index: int in range(steps):
		var angle: float = TAU * float(index) / float(steps)
		ring.append(Vector3(cos(angle), 0, sin(angle)) * ground_r * rng.randf_range(0.82, 1.08) + Vector3(0, 0.025, 0))
	for index: int in range(steps):
		mesh.tri("rift_ground", [Vector3(0, 0.03, 0), ring[index], ring[(index + 1) % steps]], Vector3.UP)
	for index: int in range(7):
		var angle: float = rng.randf() * TAU
		var dist: float = rng.randf_range(radius * 0.7, ground_r * 0.95)
		var slab: Vector3 = Vector3(rng.randf_range(0.5, 1.0), rng.randf_range(0.12, 0.3), rng.randf_range(0.4, 0.8))
		mesh.box("ash", Vector3(cos(angle) * dist, slab.y * 0.4, sin(angle) * dist), slab, Basis(Vector3.UP, rng.randf() * TAU) * Basis(Vector3.RIGHT, rng.randf_range(-0.3, 0.3)), 0.04, 0.7)
	for index: int in range(3 if big else 2):
		var angle: float = PI * 0.25 + PI * 0.5 * float(index) + rng.randf_range(-0.3, 0.3)
		K.card(mesh, "CAP-PLANT-CRYSTAL", Vector3(cos(angle), 0, sin(angle)) * radius * rng.randf_range(0.9, 1.3), rng.randf_range(1.0, 1.6) * size, Vector3(0, 0, 1), index % 2 == 1)
	finish(root, mesh, [], 3.5 * size)
	# the hazard's rim: a thin glowing ring at its reach
	var rim_mesh: KitMesh = KitMesh.new()
	rim_mesh.set_material("rim", K.own_glow(K.RIFT, 1.6, 0.85, true))
	for index: int in range(32):
		var d0: Vector3 = Vector3(cos(TAU * float(index) / 32.0), 0, sin(TAU * float(index) / 32.0))
		var d1: Vector3 = Vector3(cos(TAU * float(index + 1) / 32.0), 0, sin(TAU * float(index + 1) / 32.0))
		var lift: Vector3 = Vector3(0, 0.06, 0)
		rim_mesh.quad("rim", [d0 * (radius - 0.08) + lift, d1 * (radius - 0.08) + lift, d1 * (radius + 0.08) + lift, d0 * (radius + 0.08) + lift], Vector3.UP)
	root.add_child(rim_mesh.instance("Rim"))
	# the tear: a jagged lens bright violet at its edges and near-black inside (vertex colours on an unshaded glow), crossed by a thinner one
	var tear: Node3D = Node3D.new()
	tear.name = "Tear"
	tear.position = Vector3(0, 0.35 * size, 0)
	tear.rotation_degrees = Vector3(0, rng.randf_range(-25.0, 25.0), rng.randf_range(-8.0, 8.0))
	root.add_child(tear)
	var tear_mesh: KitMesh = KitMesh.new()
	var tear_material: StandardMaterial3D = K.own_glow(Color(1, 1, 1), 1.0, 1.0, true)
	tear_material.albedo_color = Color.WHITE  # the HDR lives only in the rim's vertex colour (a brighter tear bloomed over its own dark heart)
	tear_material.emission_enabled = false  # the vertex colours carry it: bright violet edges, a near-black heart
	tear_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	tear_mesh.set_material("tear", tear_material)
	_tear(tear_mesh, rng, 3.9 * size, 1.6 * size, 0.0)
	_tear(tear_mesh, rng, 3.1 * size, 0.7 * size, PI * 0.42)
	tear.add_child(tear_mesh.instance("TearMesh"))
	# the floating shards round it
	var orbit: Node3D = Node3D.new()
	orbit.name = "Orbit"
	root.add_child(orbit)
	var shard_mesh: KitMesh = KitMesh.new()
	K.materials(shard_mesh)
	shard_mesh.set_material("crystal", K.own_glow(K.RIFT, 1.2))
	var count: int = 12 if big else 8
	for index: int in range(count):
		var angle: float = TAU * float(index) / float(count) + rng.randf_range(-0.2, 0.2)
		var dist: float = rng.randf_range(1.1, 1.9) * size
		var center: Vector3 = Vector3(cos(angle) * dist, rng.randf_range(0.8, 3.6) * size, sin(angle) * dist * 0.7)
		var length: float = rng.randf_range(0.35, 0.8) * size
		var tilt: Basis = Basis(Vector3.UP, rng.randf() * TAU) * Basis(Vector3.RIGHT, rng.randf_range(-0.8, 0.8))
		_shard(shard_mesh, "ash" if index % 3 != 0 else "crystal", center, length, tilt)
		if index % 3 != 0:
			_shard(shard_mesh, "crystal", center + tilt * Vector3(0, -length * 0.55, 0), length * 0.45, tilt * Basis(Vector3.RIGHT, PI))
	orbit.add_child(shard_mesh.instance("Shards"))
	root.rotation_degrees.y = rng.randf_range(-20.0, 20.0)
	root.set_meta("size", size)
	return root


## One jagged tear: a dark heart (a fan out to 70 % of the way) inside a band that brightens to a jittered violet rim, `h` tall and `w` wide,
## turned by `yaw` about the vertical: dark inside, bright purple at its edges (the concept).
static func _tear(mesh: KitMesh, rng: RandomNumberGenerator, h: float, w: float, yaw: float) -> void:
	var basis: Basis = Basis(Vector3.UP, yaw)
	var normal: Vector3 = basis * Vector3(0, 0, 1)
	var core: Vector3 = Vector3(0, h * 0.5, 0)
	var rim: Array[Vector3] = []
	var steps: int = 22
	for index: int in range(steps):
		var t: float = TAU * float(index) / float(steps)
		var jag: float = rng.randf_range(0.72, 1.12)
		rim.append(basis * Vector3(sin(t) * w * 0.5 * jag * (0.55 + 0.45 * absf(cos(t * 0.5))), h * 0.5 + cos(t) * h * 0.5 * rng.randf_range(0.92, 1.04), 0.0))
	var bright: Color = Color(0.95, 0.5, 1.3)
	var deep: Color = Color(0.02, 0.0, 0.05)
	var inner: Color = Color(0.22, 0.05, 0.42)
	for index: int in range(steps):
		var a: Vector3 = rim[index]
		var b: Vector3 = rim[(index + 1) % steps]
		var ia: Vector3 = core.lerp(a, 0.7)
		var ib: Vector3 = core.lerp(b, 0.7)
		mesh.tri("tear", [core, ia, ib], normal, [deep, inner, inner])
		mesh.quad("tear", [ia, ib, b, a], normal, [inner, inner, bright, bright])


## A floating shard: a long double pyramid `length` tall about `center`, turned by `basis`.
static func _shard(mesh: KitMesh, slot: String, center: Vector3, length: float, basis: Basis) -> void:
	var top: Vector3 = center + basis * Vector3(0, length * 0.55, 0)
	var bottom: Vector3 = center + basis * Vector3(0, -length * 0.45, 0)
	var corners: Array[Vector3] = []
	for index: int in range(4):
		var angle: float = TAU * float(index) / 4.0
		corners.append(center + basis * Vector3(cos(angle) * length * 0.22, 0, sin(angle) * length * 0.16))
	for index: int in range(4):
		var a: Vector3 = corners[index]
		var b: Vector3 = corners[(index + 1) % 4]
		var out: Vector3 = ((a + b) * 0.5 - center).normalized()
		mesh.tri(slot, [a, b, top], out + basis * Vector3.UP * 0.3)
		mesh.tri(slot, [b, a, bottom], out - basis * Vector3.UP * 0.3)


# ---- the outside's landmarks ----------------------------------------------------------------------------------------------------------------


## The broken watchtower of the ruined outpost (CAP-HERO-WATCHTOWER): a square stone tower of the old kingdom, ash-blackened, about 13 m, its top
## half collapsed into a jagged crown with timbers sticking out, an arrow slit and a splintered door from the outpost sheet, the tattered old
## banner of the four Paths still clinging to it, rubble at its foot and its bitten-off crown lying beside it.
static func watchtower() -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Watchtower"
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh)
	mesh.box("ash", Vector3(0, 0.6, 0), Vector3(5.4, 1.2, 5.4), Basis.IDENTITY, 0.08, 0.6)
	mesh.box("ash", Vector3(0, 4.6, 0), Vector3(4.6, 7.0, 4.6), Basis(Vector3.FORWARD, deg_to_rad(1.5)), 0.06, 0.75)
	mesh.box("ash", Vector3(0.1, 9.4, 0), Vector3(4.3, 2.8, 4.3), Basis(Vector3.FORWARD, deg_to_rad(2.5)), 0.05)
	var crown: Array[Vector4] = [Vector4(-1.6, 1.6, 3.2, 1.2), Vector4(-0.4, 1.7, 2.2, 0.9), Vector4(1.5, 1.6, 1.4, 1.1), Vector4(-1.7, -1.5, 2.6, 1.0), Vector4(-1.7, 0.1, 1.8, 0.8), Vector4(0.2, -1.7, 1.2, 0.9)]
	for stone: Vector4 in crown:
		mesh.box("ash", Vector3(stone.x, 10.8 + stone.z * 0.5, stone.y), Vector3(stone.w, stone.z, stone.w), Basis(Vector3.UP, stone.x * 0.3), 0.05)
	for beam: Array in [[Vector3(-1.8, 11.4, 1.0), Vector3(2.6, 13.4, 1.4)], [Vector3(-1.2, 11.8, -1.4), Vector3(1.8, 14.0, -0.6)], [Vector3(1.0, 11.0, 1.9), Vector3(2.8, 12.2, 3.0)]]:
		mesh.tube("wood_dark", beam[0] as Vector3, beam[1] as Vector3, 0.14, 6)
	for window: Vector3 in [Vector3(-1.0, 7.2, 2.32), Vector3(1.1, 9.6, 2.17)]:
		mesh.quad("dark", [window + Vector3(-0.35, -0.6, 0), window + Vector3(0.35, -0.6, 0), window + Vector3(0.35, 0.6, 0), window + Vector3(-0.35, 0.6, 0)], Vector3(0, 0, 1))
	K.card(mesh, "CAP-SHEET-OUTPOST-06", Vector3(-1.2, 3.4, 2.33), 1.9, Vector3(0, 0, 1))
	K.card(mesh, "CAP-SHEET-OUTPOST-02", Vector3(0.4, 1.2, 2.33), 2.3, Vector3(0, 0, 1))
	# the tattered banner of the four Paths: a dark cloth with a ragged hem, four gold diamonds, each Path's essence in one
	var banner_x: float = 1.35
	var top: float = 10.2
	var drop: float = 5.6
	mesh.quad("canvas_navy", [Vector3(banner_x - 0.75, top - drop, 2.42), Vector3(banner_x + 0.75, top - drop, 2.42), Vector3(banner_x + 0.75, top, 2.42), Vector3(banner_x - 0.75, top, 2.42)], Vector3(0, 0, 1))
	for tooth: int in range(4):
		var x0: float = banner_x - 0.75 + 0.375 * float(tooth)
		mesh.tri("canvas_navy", [Vector3(x0, top - drop, 2.42), Vector3(x0 + 0.375, top - drop, 2.42), Vector3(x0 + 0.19, top - drop - 0.5 - 0.25 * float(tooth % 2), 2.42)], Vector3(0, 0, 1))
	mesh.box("wood_dark", Vector3(banner_x, top + 0.08, 2.45), Vector3(1.9, 0.12, 0.12))
	for index: int in range(4):
		var center: Vector3 = Vector3(banner_x, top - 0.8 - float(index) * 1.25, 2.44)
		for corner: int in range(4):
			var a: Vector3 = center + Vector3(cos(PI * 0.5 * float(corner)), sin(PI * 0.5 * float(corner)), 0) * 0.5
			var b: Vector3 = center + Vector3(cos(PI * 0.5 * float(corner + 1)), sin(PI * 0.5 * float(corner + 1)), 0) * 0.5
			band(mesh, "gold", a, b, 0.07, Vector3(0, 0, 1))
		icon(root, PATH_ICONS[index], center + Vector3(0, 0, 0.03), 0.55)
	K.card(mesh, "CAP-SHEET-RUBBLE-01", Vector3(-2.6, 0.0, 2.9), 1.5, Vector3(0, 0, 1))
	mesh.box("ash", Vector3(-4.2, 1.0, 2.6), Vector3(3.2, 2.0, 2.6), Basis.from_euler(Vector3(deg_to_rad(18), deg_to_rad(35), deg_to_rad(24))), 0.06, 0.7)
	mesh.box("ash", Vector3(-5.0, 0.4, 0.8), Vector3(1.2, 0.8, 1.0), Basis(Vector3.UP, 0.6), 0.05, 0.7)
	K.card(mesh, "CAP-TREE-DEAD", Vector3(2.9, 0.0, 2.6), 2.4, Vector3(0, 0, 1))
	return finish(root, mesh, [Vector3(0, 0, 3.4)], 14.0)


## A crumbling wall of the old kingdom's pale stone filling `rect` on the ground (the camp's shelter): stacked blocks under a ragged top, a broken
## pier standing taller at each end, fallen blocks at its foot (`masonry`).
static func _ruin_wall(mesh: KitMesh, rect: Rect2, seed_value: int) -> void:
	var along_x: bool = rect.size.x >= rect.size.y
	var thick: float = rect.size.y if along_x else rect.size.x
	var a: Vector3 = Vector3(rect.position.x, 0, rect.get_center().y) if along_x else Vector3(rect.get_center().x, 0, rect.position.y)
	var b: Vector3 = Vector3(rect.end.x, 0, rect.get_center().y) if along_x else Vector3(rect.get_center().x, 0, rect.end.y)
	masonry(mesh, PALE_STONE, a, b, thick, 3.4, seed_value, 0.6)
	for end: Vector3 in [a, b]:
		masonry(mesh, PALE_STONE, end + Vector3(-0.45, 0, 0), end + Vector3(0.45, 0, 0), thick + 0.35, 4.0, seed_value + int(end.z), 0.15, false)


## The stone the ruins are stacked from: the old kingdom's pale blocks (the camp, the outpost) and the wasteland's ash-blackened ones; each block
## takes one of its set (a painted surface and two plain tones), so a wall never reads as one cut box.
const PALE_STONE: Array[String] = ["ruin", "stone", "ash_flat", "stone"]
const ASH_STONE: Array[String] = ["ash", "ash_flat", "stone_dark", "ash"]


## A crumbling wall of stacked stone blocks from `a` to `b` on the ground, `thick` deep and up to `height` tall (the concepts' ruins): bevelled
## blocks in staggered courses, each column stopping at its own course under a ragged top (`ragged` 0..1, how much of the height the gaps bite),
## the top blocks a little askew, fallen blocks at its foot on both sides. `slots` are the stone's surfaces, one picked per block.
static func masonry(mesh: KitMesh, slots: Array[String], a: Vector3, b: Vector3, thick: float, height: float, seed_value: int, ragged: float = 0.55, fallen: bool = true) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var along: Vector3 = b - a
	along.y = 0.0
	var length: float = along.length()
	if length < 0.2:
		return
	var dir: Vector3 = along / length
	var side: Vector3 = Vector3(-dir.z, 0.0, dir.x)
	var basis: Basis = Basis(Vector3.UP, atan2(-dir.z, dir.x))
	var course: float = rng.randf_range(0.42, 0.52)
	var courses: int = maxi(1, int(height / course))
	# the top's outline: a slow wave biting into the middle, the ends standing longest
	var phase: float = rng.randf() * TAU
	var top_at: Callable = func(t: float) -> float:
		var u: float = t / length
		var wave: float = 0.5 + 0.5 * sin(u * 5.1 + phase) * cos(u * 2.3 + phase * 0.7)
		var ends: float = maxf(smoothstep(0.22, 0.0, u), smoothstep(0.78, 1.0, u))
		return height * clampf(1.0 - ragged * wave * (1.0 - ends * 0.8), 0.18, 1.0)
	for k: int in range(courses):
		var y: float = float(k) * course
		var t: float = -rng.randf_range(0.0, 0.5) if k % 2 == 1 else 0.0
		while t < length:
			var block: float = rng.randf_range(0.55, 0.95)
			var t0: float = maxf(t, 0.0)
			var t1: float = minf(t + block, length)
			t += block
			if t1 - t0 < 0.2:
				continue
			var mid: float = (t0 + t1) * 0.5
			if y + course * 0.5 > float(top_at.call(mid)):
				continue
			var tilt: Basis = Basis.IDENTITY
			var shift: Vector3 = Vector3.ZERO
			if y + course * 1.5 > float(top_at.call(mid)):
				tilt = Basis(Vector3.UP, rng.randf_range(-0.12, 0.12)) * Basis(Vector3.RIGHT, rng.randf_range(-0.08, 0.08))
				shift = side * rng.randf_range(-0.06, 0.06)
			var center: Vector3 = a + dir * mid + Vector3(0.0, y + course * 0.5, 0.0) + shift
			mesh.box(slots[rng.randi() % slots.size()], center, Vector3(t1 - t0 - 0.05, course - 0.04, thick * rng.randf_range(0.88, 1.0)), basis * tilt, 0.05, 0.78 if k == 0 else 0.92)
	if not fallen:
		return
	for index: int in range(maxi(2, int(length / 1.3))):
		var t: float = rng.randf_range(0.05, 0.95) * length
		var away: float = (thick * 0.5 + rng.randf_range(0.3, 1.1)) * (1.0 if index % 2 == 0 else -1.0)
		var size: Vector3 = Vector3(rng.randf_range(0.45, 0.8), rng.randf_range(0.3, 0.45), thick * rng.randf_range(0.6, 0.95))
		var spin: Basis = Basis(Vector3.UP, rng.randf() * TAU) * Basis(Vector3.RIGHT, rng.randf_range(-0.35, 0.35)) * Basis(Vector3.FORWARD, rng.randf_range(-0.25, 0.25))
		mesh.box(slots[rng.randi() % slots.size()], a + dir * t + side * away + Vector3(0.0, size.y * 0.42, 0.0), size, spin, 0.05, 0.8)


## A wooden crate of planks (the camp's, the yards'): a box with darker edge battens and a diagonal brace on its two long faces, turned by `yaw`.
static func crate(mesh: KitMesh, base: Vector3, size: Vector3, yaw: float) -> void:
	var basis: Basis = Basis(Vector3.UP, yaw)
	var center: Vector3 = base + Vector3(0, size.y * 0.5, 0)
	mesh.box("crate", center, size, basis, 0.03, 0.8)
	var t: float = 0.07
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			mesh.box("wood_dark", center + basis * Vector3(sx * (size.x * 0.5 - t * 0.3), 0, sz * (size.z * 0.5 - t * 0.3)), Vector3(t, size.y + 0.02, t), basis)
		for y: float in [-1.0, 1.0]:
			mesh.box("wood_dark", center + basis * Vector3(sx * (size.x * 0.5 - t * 0.3), y * (size.y * 0.5 - t * 0.3), 0), Vector3(t, t, size.z + 0.02), basis)
			mesh.box("wood_dark", center + basis * Vector3(0, y * (size.y * 0.5 - t * 0.3), sx * (size.z * 0.5 - t * 0.3)), Vector3(size.x + 0.02, t, t), basis)
	for face: float in [-1.0, 1.0]:
		var normal: Vector3 = basis * Vector3(0, 0, face)
		var z: float = face * (size.z * 0.5 + 0.012)
		band(mesh, "wood_dark", center + basis * Vector3(-size.x * 0.4, -size.y * 0.4, z), center + basis * Vector3(size.x * 0.4, size.y * 0.4, z), 0.08, normal)


## A barrel: bulging staves, two iron hoops, a lid.
static func barrel(mesh: KitMesh, base: Vector3, height: float = 0.95) -> void:
	var r: float = height * 0.36
	mesh.lathe("wood", base, [Vector2(r * 0.86, 0.0), Vector2(r, height * 0.25), Vector2(r * 1.06, height * 0.5), Vector2(r, height * 0.75), Vector2(r * 0.86, height)], 12, 0.8, false, true)
	for y: float in [0.16, 0.84]:
		mesh.lathe("iron_dark", base + Vector3(0, height * y - 0.04, 0), [Vector2(r * 0.97 + 0.03, 0.0), Vector2(r * 0.97 + 0.03, 0.08)], 12, 1.0, false, false)


## A tent of the camp (CAP-HERO-RESISTANCE-CAMP): patched canvas draped over a ridge pole on two poles, its open end toward `facing` (horizontal
## unit), the canvas sagging between the poles and flaring at the hem, pegged out with guy ropes, its back closed. `look` = [canvas, patch slot,
## icon a, icon b]. Turned three-quarters to the camera: a slope and the closed back read as a tent, not a flat sheet.
static func tent(root: Node3D, mesh: KitMesh, base: Vector3, facing: Vector3, look: Array) -> void:
	var length: float = 2.8
	var half: float = 1.3
	var ridge: float = 2.05
	var fwd: Vector3 = facing.normalized()
	var right: Vector3 = Vector3(fwd.z, 0, -fwd.x)
	var at: Callable = func(along: float, across: float, y: float) -> Vector3: return base + fwd * along + right * across + Vector3(0, y, 0)
	var canvas: String = str(look[0])
	var light: Color = Color(1, 1, 1)
	var shade: Color = Color(0.8, 0.8, 0.8)
	var hem: Color = Color(0.64, 0.64, 0.64)
	var steps: int = 4
	for sgn: float in [-1.0, 1.0]:
		for i: int in range(steps):
			var a0: float = -length * 0.5 + length * float(i) / float(steps)
			var a1: float = -length * 0.5 + length * float(i + 1) / float(steps)
			var sag0: float = 0.16 * sin(PI * float(i) / float(steps))
			var sag1: float = 0.16 * sin(PI * float(i + 1) / float(steps))
			var top0: Vector3 = at.call(a0, 0.0, ridge - sag0)
			var top1: Vector3 = at.call(a1, 0.0, ridge - sag1)
			var mid0: Vector3 = at.call(a0, sgn * half * 0.55, ridge * 0.5 - sag0 * 0.5 + 0.05)
			var mid1: Vector3 = at.call(a1, sgn * half * 0.55, ridge * 0.5 - sag1 * 0.5 + 0.05)
			var hem0: Vector3 = at.call(a0, sgn * (half + 0.12), 0.06)
			var hem1: Vector3 = at.call(a1, sgn * (half + 0.12), 0.06)
			var out: Vector3 = right * sgn + Vector3(0, 0.8, 0)
			for face: float in [1.0, -1.0]:
				mesh.quad(canvas, [top0, top1, mid1, mid0], out * face, [light, light, shade, shade])
				mesh.quad(canvas, [mid0, mid1, hem1, hem0], out * face, [shade, shade, hem, hem])
	var back: float = -length * 0.5
	for face: float in [1.0, -1.0]:
		mesh.tri(canvas, [at.call(back, -half - 0.12, 0.06), at.call(back, half + 0.12, 0.06), at.call(back, 0.0, ridge)], -fwd * face, [hem, hem, light])
	var front: float = length * 0.5
	mesh.tri("dark", [at.call(front - 0.08, -half * 0.8, 0.05), at.call(front - 0.08, half * 0.8, 0.05), at.call(front - 0.08, 0.0, ridge * 0.92)], fwd)
	for sgn: float in [-1.0, 1.0]:
		var flap: Array[Vector3] = [at.call(front, 0.0, ridge), at.call(front + 0.35, sgn * half * 0.9, 0.3), at.call(front, sgn * (half + 0.12), 0.06)]
		mesh.tri(canvas, flap, fwd + right * sgn)
		mesh.tri(canvas, flap, -fwd - right * sgn)
	for end: float in [back - 0.06, front + 0.06]:
		mesh.tube("wood_dark", at.call(end, 0.0, 0.0), at.call(end, 0.0, ridge + 0.3), 0.06, 6)
		var peg: Vector3 = at.call(end + signf(end) * 0.9, 0.0, 0.0)
		mesh.tube("rope", at.call(end, 0.0, ridge + 0.2), peg + Vector3(0, 0.15, 0), 0.015, 4, false)
		mesh.tube("wood_dark", peg, peg + Vector3(0, 0.22, 0), 0.03, 4)
	mesh.tube("wood_dark", at.call(back - 0.1, 0.0, ridge + 0.02), at.call(front + 0.1, 0.0, ridge + 0.02), 0.05, 6)
	# the second Path's patch stitched on the slope the camera sees, both Paths' essences on it, a warm lantern at the open end
	var near: float = 1.0 if right.z >= 0.0 else -1.0
	mesh.quad(str(look[1]), [at.call(-0.65, near * half * 0.22, ridge * 0.8 + 0.02), at.call(0.55, near * half * 0.22, ridge * 0.8 + 0.02), at.call(0.55, near * half * 0.82, ridge * 0.36 + 0.02), at.call(-0.65, near * half * 0.82, ridge * 0.36 + 0.02)], right * near + Vector3(0, 0.8, 0))
	var yaw: float = rad_to_deg(atan2(right.x * near, right.z * near))
	icon(root, PATH_ICONS[int(look[2])], at.call(-0.3, near * (half * 0.62 + 0.25), ridge * 0.55), 0.5, yaw)
	icon(root, PATH_ICONS[int(look[3])], at.call(0.4, near * (half * 0.62 + 0.25), ridge * 0.55), 0.42, yaw)
	mesh.box("lantern", at.call(front + 0.06, 0.0, ridge - 0.25), Vector3(0.18, 0.24, 0.18))


## A free-standing ruined wall of the wasteland's clusters, `length` x about `height`: ash-blackened stone (CAP-WALL-ASH) with a jagged stepped top,
## a broken or boarded window from the outpost sheet, fallen blocks at its foot. Origin at its middle on the ground, its face +z.
static func ruin_fragment(length: float, height: float, seed_value: int) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh)
	var stone: Array[String] = ASH_STONE if seed_value % 2 == 0 else PALE_STONE
	masonry(mesh, stone, Vector3(-length * 0.5, 0, 0), Vector3(length * 0.5, 0, 0), 0.55, height, 4400 + seed_value, 0.65)
	K.card(mesh, "CAP-SHEET-OUTPOST-04" if seed_value % 3 != 0 else "CAP-SHEET-OUTPOST-05", Vector3(-length * 0.22, height * 0.2, 0.29), minf(1.1, height * 0.45), Vector3(0, 0, 1))
	return finish(root, mesh, [], height)


## A ruined house of the old kingdom (the ruined outpost's fallen guardhouses; the outpost paint-over): pale crumbling brick (CAP-WALL-RUIN) walls with
## jagged tops, a gable end still standing, the roof (CAP-ROOF-BROKEN) slumped in on one side with charred timbers poking out, a splintered or barred
## door and broken windows from the outpost sheet, rubble round its foot. `w` x `h` x `d` centred, the front +z.
static func ruined_house(w: float, h: float, d: float, lean: float, seed_value: int) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 4800 + seed_value
	var t: float = 0.45
	# the four walls stacked from the old kingdom's pale blocks: the back and the left (gable) end stand nearly whole, the front and the right end
	# are bitten down; the gable end's stub still carries the roof
	var hw: float = w * 0.5 - t * 0.5
	var hd: float = d * 0.5 - t * 0.5
	masonry(mesh, PALE_STONE, Vector3(-w * 0.5, 0, -hd), Vector3(w * 0.5, 0, -hd), t, h, 4800 + seed_value, 0.25, false)
	masonry(mesh, PALE_STONE, Vector3(-hw, 0, -d * 0.5 + t), Vector3(-hw, 0, d * 0.5 - t), t, h, 4810 + seed_value, 0.1, false)
	masonry(mesh, PALE_STONE, Vector3(-w * 0.5, 0, hd), Vector3(w * 0.5, 0, hd), t, h * 0.9, 4820 + seed_value, 0.6)
	masonry(mesh, PALE_STONE, Vector3(hw, 0, -d * 0.5 + t), Vector3(hw, 0, d * 0.5 - t), t, h * 0.8, 4830 + seed_value, 0.7)
	# the gable end still standing on the left, the roof slumped from it into the house
	var gable: Array[Vector3] = [Vector3(-w * 0.5, h, -d * 0.5), Vector3(-w * 0.5, h, d * 0.5), Vector3(-w * 0.5, h + d * 0.4, 0)]
	mesh.tri("ruin", gable, Vector3(-1, 0, 0))
	mesh.tri("ruin", gable, Vector3(1, 0, 0))
	var drop: float = h * (0.45 + absf(lean) * 0.02)
	mesh.quad("roof_broken", [Vector3(-w * 0.5, h + d * 0.4, 0), Vector3(-w * 0.5, h - 0.1, d * 0.5 + 0.3), Vector3(w * 0.15, drop, d * 0.5 + 0.2), Vector3(w * 0.15, drop + d * 0.35, 0)], Vector3(0.2, 1, 0.6))
	mesh.quad("roof_broken", [Vector3(-w * 0.5, h + d * 0.4, 0), Vector3(-w * 0.5, h - 0.1, d * 0.5 + 0.3), Vector3(w * 0.15, drop, d * 0.5 + 0.2), Vector3(w * 0.15, drop + d * 0.35, 0)], Vector3(-0.2, -1, -0.6))
	for beam: int in range(4):
		var z: float = -d * 0.4 + float(beam) * d * 0.27
		mesh.tube("wood_dark", Vector3(-w * 0.5 + 0.2, h + d * 0.3 * (1.0 - absf(z) / d), z), Vector3(w * rng.randf_range(0.0, 0.45), h * rng.randf_range(0.5, 1.1), z + rng.randf_range(-0.3, 0.3)), 0.08, 5)
	# the door and the windows on the front, rubble at the foot
	K.card(mesh, "CAP-SHEET-OUTPOST-02" if seed_value % 2 == 0 else "CAP-SHEET-OUTPOST-03", Vector3(-w * 0.15, 0.0, d * 0.5 + 0.02), minf(2.2, h * 0.75), Vector3(0, 0, 1))
	K.card(mesh, "CAP-SHEET-OUTPOST-04", Vector3(w * 0.28, h * 0.32, d * 0.5 + 0.02), 1.1, Vector3(0, 0, 1))
	K.card(mesh, "CAP-SHEET-RUBBLE-01", Vector3(w * 0.45, 0.0, d * 0.5 + 0.6), 1.0, Vector3(0, 0, 1))
	for index: int in range(5):
		var p: Vector3 = Vector3(rng.randf_range(-w * 0.6, w * 0.6), 0.2, d * 0.5 + rng.randf_range(0.3, 1.0))
		mesh.box("ruin", p, Vector3(0.45, 0.36, 0.4), Basis(Vector3.UP, rng.randf() * TAU), 0.04, 0.75)
	root.rotation_degrees.z = lean * 0.15
	return finish(root, mesh, [], h + d * 0.4)


## The Old Service Tunnels' mouth (CAP-HERO-SERVICE-TUNNEL): a heavy old iron hatch in an arched stone tunnel mouth set into the base of the great
## wall's outer face, overgrown with dead branches and forgotten, a dim lantern beside it, rift crystals breaking through at its sides. Origin at the
## wall's face; nothing reaches more than 1.2 m out, so the door spot in front stays clear. The lantern is dim and cold (the camp keeps the only warm
## light outside).
static func tunnel_mouth() -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "TunnelMouth"
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh)
	var spring: float = 2.8
	var inner: float = 2.6
	var outer: float = 3.5
	mesh.quad("dark", [Vector3(-inner, 0.02, 0.05), Vector3(inner, 0.02, 0.05), Vector3(inner, spring, 0.05), Vector3(-inner, spring, 0.05)], Vector3(0, 0, 1))
	for side: float in [-1.0, 1.0]:
		mesh.box("ash", Vector3(side * (inner + outer) * 0.5, spring * 0.5, 0.55), Vector3(outer - inner, spring, 1.1), Basis.IDENTITY, 0.06, 0.7)
	var steps: int = 11
	for index: int in range(steps):
		var a0: float = PI * float(index) / float(steps)
		var a1: float = PI * float(index + 1) / float(steps)
		var mid: float = (a0 + a1) * 0.5
		var center: Vector3 = Vector3(cos(mid) * (inner + outer) * 0.5, spring + sin(mid) * (inner + outer) * 0.5, 0.55)
		mesh.box("ash", center, Vector3((outer - inner) * 0.98, (a1 - a0) * outer * 0.95, 1.1), Basis(Vector3(0, 0, 1), mid - PI * 0.5), 0.05, 0.85)
		mesh.tri("dark", [Vector3(0, spring, 0.05), Vector3(cos(a0) * inner, spring + sin(a0) * inner, 0.05), Vector3(cos(a1) * inner, spring + sin(a1) * inner, 0.05)], Vector3(0, 0, 1))
	K.card(mesh, "CAP-SHEET-OUTPOST-01", Vector3(0, 0.0, 0.25), 4.1, Vector3(0, 0, 1))
	mesh.box("iron", Vector3(outer + 0.15, 2.5, 0.9), Vector3(0.5, 0.08, 0.08))
	mesh.box("iron_dark", Vector3(outer + 0.35, 2.15, 0.9), Vector3(0.34, 0.5, 0.34))
	mesh.set_material("lantern_dim", EnvKit.glow(Color("c8d0b8"), 0.6))
	mesh.box("lantern_dim", Vector3(outer + 0.35, 2.15, 0.9), Vector3(0.24, 0.36, 0.36))
	for branch: Array in [[Vector3(-4.6, 0.2, 0.4), Vector3(-3.2, 3.6, 0.9), Vector3(-0.8, 5.8, 1.0)], [Vector3(4.4, 0.3, 0.4), Vector3(3.6, 4.0, 0.9), Vector3(1.2, 6.0, 1.0)]]:
		for index: int in range(branch.size() - 1):
			mesh.tube("wood_dark", branch[index] as Vector3, branch[index + 1] as Vector3, 0.09 - 0.025 * float(index), 5)
	K.card(mesh, "CAP-PLANT-CRYSTAL", Vector3(-5.0, 0.0, 0.5), 1.9, Vector3(0, 0, 1))
	K.card(mesh, "CAP-PLANT-CRYSTAL", Vector3(5.2, 0.0, 0.4), 1.5, Vector3(0, 0, 1), true)
	K.card(mesh, "CAP-SHEET-RUBBLE-01", Vector3(-3.6, 0.0, 1.0), 1.1, Vector3(0, 0, 1))
	K.card(mesh, "CAP-TREE-DEAD", Vector3(-6.4, 0.0, 0.3), 3.0, Vector3(0, 0, 1))
	return finish(root, mesh, [], 7.0)


## The resistance camp (CAP-HERO-RESISTANCE-CAMP), the only warm light in the wasteland: patched tents and a lean-to of salvaged planks round the
## fire, colourful scraps of all four Paths stitched into the canvas (each Path's colour and essence), a rope of warm lanterns between the tents,
## crates and barrels, a rag banner. World coordinates (`CapitalLayout.CAMP_TENTS`, `CAMP_LEAN_TO`); the fire is the `campfire` prop.
static func camp() -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "ResistanceCamp"
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh)
	mesh.set_material("lantern", EnvKit.glow(Color("ffbe6a"), 2.6))
	# tent 0: Beefcake red with a Gourmand copper patch; tent 1: Necrocrat teal with a Refusemancer green patch; each turned so its open end looks
	# at the fire (the camera sees a slope and the closed back at three-quarters, as in the concept)
	var canvases: Array[Array] = [["canvas_red", "canvas_copper", 0, 1], ["canvas_teal", "canvas_green", 2, 3]]
	var fire: Vector3 = Vector3(CapitalLayout.CAMP_FIRE.x, 0, CapitalLayout.CAMP_FIRE.y)
	for index: int in range(CapitalLayout.CAMP_TENTS.size()):
		var at: Vector2 = CapitalLayout.CAMP_TENTS[index]
		var base: Vector3 = Vector3(at.x, 0, at.y)
		tent(root, mesh, base, fire - base, canvases[index])
		# crates and a barrel tucked behind each tent, against the ruins
		var away: Vector3 = (base - fire).normalized()
		var tuck: Vector3 = base + away * 2.0
		crate(mesh, tuck + Vector3(0, 0, 0.9), Vector3(0.75, 0.7, 0.7), 0.25)
		crate(mesh, tuck + Vector3(0, 0.7, 0.9), Vector3(0.55, 0.5, 0.55), -0.3)
		barrel(mesh, tuck + Vector3(0, 0, -0.5))
	# log seats round the fire (the concept), on the far side from the camera
	for angle: float in [-2.2, -1.57, -0.94]:
		var seat: Vector3 = fire + Vector3(cos(angle), 0, sin(angle)) * 1.6
		var tangent: Vector3 = Vector3(-sin(angle), 0, cos(angle)) * 0.5
		mesh.tube("wood", seat - tangent + Vector3(0, 0.2, 0), seat + tangent + Vector3(0, 0.2, 0), 0.2, 8)
	# the lean-to: a Gourmand-copper canvas roof on salvaged planks, bedrolls under it
	var lean: Vector3 = Vector3(CapitalLayout.CAMP_LEAN_TO.x, 0, CapitalLayout.CAMP_LEAN_TO.y)
	for side: float in [-1.0, 1.0]:
		mesh.tube("wood_dark", lean + Vector3(0.9, 0, side * 1.4), lean + Vector3(0.9, 2.1, side * 1.4), 0.07, 5)
		mesh.tube("wood_dark", lean + Vector3(-1.1, 0, side * 1.4), lean + Vector3(-1.1, 0.95, side * 1.4), 0.06, 5)
	for step: int in range(3):
		var y0: float = 2.1 - 1.2 * float(step) / 3.0
		var y1: float = 2.1 - 1.2 * float(step + 1) / 3.0
		var x0: float = 0.9 - 2.0 * float(step) / 3.0
		var x1: float = 0.9 - 2.0 * float(step + 1) / 3.0
		var sag: float = 0.08 * sin(PI * (float(step) + 0.5) / 3.0)
		var strip: Array[Vector3] = [lean + Vector3(x0, y0, -1.6), lean + Vector3(x0, y0, 1.6), lean + Vector3(x1, y1 - sag, 1.6), lean + Vector3(x1, y1 - sag, -1.6)]
		mesh.quad("canvas_copper", strip, Vector3(0.5, 1, 0))
		mesh.quad("canvas_copper", strip, Vector3(-0.5, -1, 0))
	for z: float in [-0.7, 0.7]:
		mesh.tube("canvas_tan", lean + Vector3(-0.75, 0.16, z), lean + Vector3(0.75, 0.16, z), 0.16, 8)
	icon(root, PATH_ICONS[1], lean + Vector3(0.92, 1.6, 0.0), 0.6, 90.0)
	# the rag banner: a Refusemancer-green cloth on a pole, the leaf Path's essence on it
	var pole: Vector3 = lean + Vector3(0.0, 0, -2.2)
	mesh.tube("wood_dark", pole, pole + Vector3(0, 4.0, 0), 0.06, 5)
	var cloth: Array[Vector3] = [pole + Vector3(0.05, 2.6, 0), pole + Vector3(1.35, 2.75, 0), pole + Vector3(1.3, 3.8, 0), pole + Vector3(0.05, 3.9, 0)]
	mesh.quad("canvas_green", cloth, Vector3(0, 0, 1))
	mesh.quad("canvas_green", cloth, Vector3(0, 0, -1))
	icon(root, PATH_ICONS[3], pole + Vector3(0.7, 3.25, 0.03), 0.6)
	# the rope of warm lanterns between the tents' north poles, and the light they give
	var a: Vector3 = Vector3(CapitalLayout.CAMP_TENTS[0].x + 1.65, 2.4, CapitalLayout.CAMP_TENTS[0].y)
	var b: Vector3 = Vector3(CapitalLayout.CAMP_TENTS[1].x - 1.65, 2.4, CapitalLayout.CAMP_TENTS[1].y)
	var previous: Vector3 = a
	for index: int in range(1, 13):
		var t: float = float(index) / 12.0
		var point: Vector3 = a.lerp(b, t) - Vector3(0, 0.7 * sin(t * PI), 0)
		mesh.tube("rope", previous, point, 0.02, 4, false)
		previous = point
		if index % 2 == 1:
			mesh.box("lantern", point - Vector3(0, 0.2, 0), Vector3(0.16, 0.22, 0.16))
	var glow: OmniLight3D = OmniLight3D.new()
	glow.name = "LanternLight"
	glow.light_color = Color("ffb060")
	glow.light_energy = 1.5
	glow.omni_range = 9.0
	glow.position = a.lerp(b, 0.5) - Vector3(0, 0.9, 0)
	root.add_child(glow)
	# the old stone ruins the camp shelters in (the concept): crumbling pale walls with jagged tops, broken pillars at their ends, fallen blocks
	for index: int in range(CapitalLayout.CAMP_RUINS.size()):
		_ruin_wall(mesh, CapitalLayout.CAMP_RUINS[index], 300 + index)
	K.card(mesh, "CAP-SHEET-RUBBLE-06", Vector3(17.6, 0.0, 113.0), 1.3, Vector3(0, 0, 1))
	K.card(mesh, "CAP-SHEET-RUBBLE-01", Vector3(46.8, 0.0, 113.4), 1.2, Vector3(0, 0, 1), true)
	finish(root, mesh, [], 4.0)
	root.set_meta("lights", [glow])
	return root
