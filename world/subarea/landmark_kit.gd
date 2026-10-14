class_name LandmarkKit
extends RefCounted
## Simple, clearly shaped stand-ins for the hero landmarks of an area (Art Bible G-08, layer 3) until their art exists: right size, right silhouette, zone colours.
## `build(spec)` takes {kind, size: [w, h, d] metres, color: "#hex", accent: "#hex", glow: "#hex"?, id: "GAIN-HERO-WHEEL"?} and returns a Node3D whose
## meta carries "circles" (Array of Vector3: local x, z, radius) so the area can make it solid, "footprint" (Vector2) and "height".
## The origin is on the ground at the centre of the footprint; the front is +z.

const KINDS: Array[String] = [
	"wheel", "tower", "windmill", "dome", "tiers", "facade", "gatewall", "arch", "statue", "giant_tree", "mound", "obelisk", "colonnade", "stair",
	"island", "cliff", "bridge", "shrine", "rift", "tank", "hatch", "box", "cylinder", "hut", "river", "lawn_row",
]


static func build(spec: Dictionary) -> Node3D:
	# A hero landmark modelled after its concept (HeroLandmarks) replaces the stand-in outright.
	var hero: Node3D = HeroLandmarks.build(spec)
	if hero != null:
		return hero
	var kind: String = str(spec.get("kind", "box"))
	var size_array: Array = spec.get("size", [4.0, 4.0, 4.0]) as Array
	var size: Vector3 = Vector3(float(size_array[0]), float(size_array[1]), float(size_array[2]))
	var main: Color = Color.html(str(spec.get("color", "#b8b0a0")))
	var accent: Color = Color.html(str(spec.get("accent", "#6a5a48")))
	var glow: Color = Color.html(str(spec.get("glow", "#ffd890")))
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("flat", EnvKit.flat(Color.WHITE, "landmark"))
	mesh.set_material("glow", EnvKit.glow(glow, 1.7))
	# `surface` / `accent_surface`: a kit surface id (GAIN-WALL-BRICK ...) instead of a flat colour; the stand-in then reads in the zone's materials.
	if spec.has("surface") and EnvKit.has(str(spec["surface"])):
		mesh.set_material("main", EnvKit.material(str(spec["surface"]), false, Color.html(str(spec.get("surface_tint", "#ffffff")))))
	else:
		mesh.alias("main", "flat", main)
	if spec.has("accent_surface") and EnvKit.has(str(spec["accent_surface"])):
		mesh.set_material("accent", EnvKit.material(str(spec["accent_surface"])))
	else:
		mesh.alias("accent", "flat", accent)
	if spec.has("surface") and EnvKit.has(str(spec["surface"])):
		mesh.alias("dark", "main", Color(0.62, 0.6, 0.62))
		mesh.alias("light", "main", Color(1.12, 1.1, 1.06))
	else:
		mesh.alias("dark", "flat", main.darkened(0.45))
		mesh.alias("light", "flat", main.lightened(0.35))
	mesh.alias("water", "flat", Color.html(str(spec.get("water", "#6fb0d8"))))
	var circles: Array[Vector3] = []
	match kind:
		"wheel":
			_wheel(mesh, size, circles)
		"tower":
			_tower(mesh, size, circles)
		"windmill":
			_windmill(mesh, size, circles)
		"dome":
			_dome(mesh, size, circles)
		"tiers":
			_tiers(mesh, size, circles)
		"facade":
			_facade(mesh, size, circles)
		"gatewall":
			_gatewall(mesh, size, circles)
		"arch":
			_arch(mesh, size, circles)
		"statue":
			_statue(mesh, size, circles)
		"giant_tree":
			_giant_tree(mesh, size, circles)
		"mound":
			_mound(mesh, size, circles)
		"obelisk":
			_obelisk(mesh, size, circles)
		"colonnade":
			_colonnade(mesh, size, circles)
		"stair":
			_stair(mesh, size, circles)
		"island":
			_island(mesh, size, circles)
		"cliff":
			_cliff(mesh, size, circles)
		"bridge":
			_bridge(mesh, size, circles)
		"shrine":
			_shrine(mesh, size, circles)
		"rift":
			_rift(mesh, size, circles)
		"tank":
			_tank(mesh, size, circles)
		"hatch":
			_hatch(mesh, size, circles)
		"hut":
			_hut(mesh, size, circles)
		"river":
			_river(mesh, size, circles)
		"lawn_row":
			_lawn_row(mesh, size, circles)
		"cylinder":
			mesh.lathe("main", Vector3.ZERO, [Vector2(size.x * 0.5, 0.0), Vector2(size.x * 0.5, size.y)], 16, 0.9, true, true)
			circles.append(Vector3(0.0, 0.0, size.x * 0.5))
		_:
			mesh.box("main", Vector3(0.0, size.y * 0.5, 0.0), size, Basis.IDENTITY, 0.08, 0.9)
			_footprint_circles(size, circles)
	var root: Node3D = Node3D.new()
	root.name = "Landmark_%s" % str(spec.get("id", kind))
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	if bool(spec.get("no_fade", false)) or kind in ["river", "lawn_row", "hatch", "island"]:
		body.set_meta(&"no_occlusion_fade", true)
	root.add_child(body)
	root.set_meta("circles", circles)
	root.set_meta("footprint", Vector2(size.x, size.z))
	root.set_meta("height", size.y)
	root.set_meta("kind", kind)
	return root


static func _footprint_circles(size: Vector3, circles: Array[Vector3]) -> void:
	var radius: float = minf(size.x, size.z) * 0.5
	var length: float = maxf(size.x, size.z)
	var count: int = maxi(1, int(ceil((length - radius * 2.0) / (radius * 1.2))) + 1)
	for index: int in range(count):
		var t: float = 0.5 if count == 1 else float(index) / float(count - 1)
		var offset: float = lerpf(-(length * 0.5 - radius), length * 0.5 - radius, t)
		circles.append(Vector3(offset, 0.0, radius) if size.x >= size.z else Vector3(0.0, offset, radius))


static func _wheel(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var radius: float = size.y * 0.5 - 0.3
	var center: Vector3 = Vector3(0.0, radius + 0.9, 0.0)
	var segments: int = 28
	for side: float in [-1.0, 1.0]:
		var z: float = side * size.z * 0.4
		var previous: Vector3 = center + Vector3(radius, 0.0, z)
		for step: int in range(1, segments + 1):
			var a: float = TAU * float(step) / float(segments)
			var point: Vector3 = center + Vector3(cos(a) * radius, sin(a) * radius, z)
			mesh.tube("main", previous, point, 0.32, 6, false)
			previous = point
	for spoke: int in range(8):
		var a: float = TAU * float(spoke) / 8.0
		var rim: Vector3 = center + Vector3(cos(a) * radius, sin(a) * radius, 0.0)
		for side: float in [-1.0, 1.0]:
			mesh.tube("accent", center + Vector3(0, 0, side * size.z * 0.4), rim + Vector3(0, 0, side * size.z * 0.4), 0.14, 5, false)
	for step: int in range(0, segments, 2):
		var a: float = TAU * float(step) / float(segments)
		var p: Vector3 = center + Vector3(cos(a) * radius, sin(a) * radius, 0.0)
		mesh.tube("dark", p + Vector3(0, 0, -size.z * 0.4), p + Vector3(0, 0, size.z * 0.4), 0.1, 5, false)
	mesh.tube("accent", center + Vector3(0, 0, -size.z * 0.6), center + Vector3(0, 0, size.z * 0.6), 0.28, 8, true)
	for side: float in [-1.0, 1.0]:
		var z: float = side * size.z * 0.6
		mesh.tube("dark", Vector3(-radius * 0.55, 0.0, z), center + Vector3(0, 0, z), 0.22, 6, true)
		mesh.tube("dark", Vector3(radius * 0.55, 0.0, z), center + Vector3(0, 0, z), 0.22, 6, true)
	mesh.box("dark", Vector3(0, 0.25, 0), Vector3(radius * 1.5, 0.5, size.z * 1.4), Basis.IDENTITY, 0.05)
	_footprint_circles(Vector3(radius * 1.5, size.y, size.z * 1.4), circles)


static func _tower(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	mesh.box("main", Vector3(0, size.y * 0.5, 0), size, Basis.IDENTITY, 0.06, 0.9)
	var rows: int = maxi(3, int(size.y / 1.1))
	var cols: int = maxi(2, int(size.x / 1.2))
	for row: int in range(rows):
		for col: int in range(cols):
			var x: float = -size.x * 0.5 + (float(col) + 0.5) * size.x / float(cols)
			var y: float = (float(row) + 0.5) * size.y / float(rows)
			mesh.box("dark", Vector3(x, y, size.z * 0.5 + 0.03), Vector3(size.x / float(cols) - 0.18, size.y / float(rows) - 0.2, 0.08), Basis.IDENTITY, 0.02)
			mesh.box("accent", Vector3(x, y, size.z * 0.5 + 0.09), Vector3(size.x / float(cols) * 0.3, 0.1, 0.06), Basis.IDENTITY, 0.0)
	mesh.box("accent", Vector3(0, size.y + 0.15, 0), Vector3(size.x + 0.3, 0.3, size.z + 0.3), Basis.IDENTITY, 0.05)
	_footprint_circles(size, circles)


static func _windmill(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var r: float = size.x * 0.5
	mesh.lathe("main", Vector3.ZERO, [Vector2(r, 0.0), Vector2(r * 0.72, size.y * 0.8)], 12, 0.9, true, false)
	mesh.lathe("accent", Vector3(0, size.y * 0.8, 0), [Vector2(r * 0.85, 0.0), Vector2(r * 0.8, 0.3), Vector2(0.0, size.y * 0.2)], 12, 0.9, false, false)
	var hub: Vector3 = Vector3(0, size.y * 0.78, r * 0.8)
	for blade: int in range(4):
		var a: float = float(blade) * PI * 0.5 + 0.35
		var tip: Vector3 = hub + Vector3(cos(a), sin(a), 0.0) * size.y * 0.5
		mesh.tube("dark", hub, tip, 0.12, 5, false)
		var mid: Vector3 = hub + Vector3(cos(a), sin(a), 0.0) * size.y * 0.3
		var sail_basis: Basis = Basis(Vector3(0, 0, 1), a)
		mesh.box("light", mid + Vector3(0, 0, 0.1), Vector3(size.y * 0.32, 0.9, 0.06), sail_basis, 0.0)
	circles.append(Vector3(0.0, 0.0, r))


static func _dome(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var r: float = size.x * 0.5
	mesh.lathe("main", Vector3.ZERO, [Vector2(r, 0.0), Vector2(r, size.y * 0.45)], 16, 0.9, true, false)
	mesh.blob("accent", Vector3(0, size.y * 0.45, 0), Vector3(r, size.y * 0.55, r), 6, 16, 0.9)
	mesh.tube("accent", Vector3(0, size.y * 0.95, 0), Vector3(0, size.y * 1.12, 0), 0.1, 6, true)
	circles.append(Vector3(0.0, 0.0, r))


static func _tiers(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var count: int = 4
	var y: float = 0.0
	for tier: int in range(count):
		var r: float = size.x * 0.5 * (1.0 - float(tier) * 0.22)
		var h: float = size.y / float(count + 1)
		mesh.lathe("main" if tier % 2 == 0 else "light", Vector3(0, y, 0), [Vector2(r, 0.0), Vector2(r, h)], 18, 0.9, true, true)
		mesh.lathe("accent", Vector3(0, y + h, 0), [Vector2(r + 0.12, 0.0), Vector2(r + 0.12, 0.18)], 18, 0.9, true, true)
		y += h + 0.18
	mesh.blob("accent", Vector3(0, y + 0.3, 0), Vector3(0.45, 0.45, 0.45), 4, 8, 1.0)
	circles.append(Vector3(0.0, 0.0, size.x * 0.5))


static func _facade(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	mesh.box("main", Vector3(0, size.y * 0.4, 0), Vector3(size.x, size.y * 0.8, size.z), Basis.IDENTITY, 0.06, 0.9)
	var half: float = size.x * 0.5
	mesh.tri("accent", [Vector3(-half, size.y * 0.8, size.z * 0.5), Vector3(half, size.y * 0.8, size.z * 0.5), Vector3(0, size.y, size.z * 0.5)], Vector3(0, 0, 1))
	mesh.box("dark", Vector3(0, size.y * 0.24, size.z * 0.5 + 0.04), Vector3(size.x * 0.16, size.y * 0.46, 0.1), Basis.IDENTITY, 0.02)
	var columns: int = maxi(2, int(size.x / 2.2))
	for column: int in range(columns):
		var x: float = -half + 0.7 + (size.x - 1.4) * float(column) / float(columns - 1)
		mesh.tube("light", Vector3(x, 0.0, size.z * 0.5 + 0.5), Vector3(x, size.y * 0.78, size.z * 0.5 + 0.5), 0.26, 8, true)
	mesh.box("accent", Vector3(0, size.y * 0.8, size.z * 0.5 + 0.5), Vector3(size.x + 0.4, 0.4, 1.2), Basis.IDENTITY, 0.04)
	_footprint_circles(size, circles)


static func _gatewall(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var gap: float = minf(size.x * 0.22, 6.0)
	var half_len: float = (size.x - gap) * 0.5
	for side: float in [-1.0, 1.0]:
		var cx: float = side * (gap * 0.5 + half_len * 0.5)
		mesh.box("main", Vector3(cx, size.y * 0.5, 0), Vector3(half_len, size.y, size.z), Basis.IDENTITY, 0.08, 0.9)
		mesh.box("accent", Vector3(cx, size.y + 0.2, 0), Vector3(half_len + 0.2, 0.4, size.z + 0.3), Basis.IDENTITY, 0.04)
		circles.append(Vector3(cx, 0.0, size.z * 0.5))
		var extra: int = maxi(1, int(half_len / (size.z * 0.9)))
		for index: int in range(extra):
			circles.append(Vector3(cx + (float(index) - float(extra - 1) * 0.5) * size.z * 0.9, 0.0, size.z * 0.5))
		mesh.box("accent", Vector3(side * (gap * 0.5 + 0.5), size.y * 0.5, 0), Vector3(1.0, size.y + 1.2, size.z + 0.8), Basis.IDENTITY, 0.06)
	mesh.box("main", Vector3(0, size.y * 0.8, 0), Vector3(gap, size.y * 0.4, size.z), Basis.IDENTITY, 0.06)


static func _arch(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var pillar: float = maxf(size.x * 0.14, 0.6)
	for side: float in [-1.0, 1.0]:
		mesh.box("main", Vector3(side * (size.x * 0.5 - pillar * 0.5), size.y * 0.5, 0), Vector3(pillar, size.y, size.z), Basis.IDENTITY, 0.06)
		circles.append(Vector3(side * (size.x * 0.5 - pillar * 0.5), 0.0, maxf(pillar, size.z) * 0.5))
	mesh.box("accent", Vector3(0, size.y - pillar * 0.5, 0), Vector3(size.x, pillar, size.z), Basis.IDENTITY, 0.06)


static func _statue(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var base_h: float = size.y * 0.25
	mesh.box("dark", Vector3(0, base_h * 0.5, 0), Vector3(size.x, base_h, size.z), Basis.IDENTITY, 0.05)
	mesh.lathe("main", Vector3(0, base_h, 0), [Vector2(size.x * 0.32, 0.0), Vector2(size.x * 0.22, size.y * 0.38), Vector2(size.x * 0.12, size.y * 0.5)], 10, 0.9, true, false)
	mesh.blob("light", Vector3(0, base_h + size.y * 0.58, 0), Vector3(size.x * 0.13, size.x * 0.15, size.x * 0.13), 5, 9, 0.95)
	circles.append(Vector3(0.0, 0.0, size.x * 0.5))


static func _giant_tree(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var trunk: float = size.x * 0.1
	mesh.lathe("accent", Vector3.ZERO, [Vector2(trunk * 1.6, 0.0), Vector2(trunk, size.y * 0.4), Vector2(trunk * 0.8, size.y * 0.62)], 10, 0.9, true, false)
	mesh.blob("main", Vector3(0, size.y * 0.72, 0), Vector3(size.x * 0.5, size.y * 0.3, size.z * 0.5), 6, 12, 0.9)
	mesh.blob("light", Vector3(-size.x * 0.22, size.y * 0.6, size.z * 0.1), Vector3(size.x * 0.3, size.y * 0.2, size.z * 0.3), 5, 10, 0.9)
	mesh.blob("dark", Vector3(size.x * 0.24, size.y * 0.66, -size.z * 0.1), Vector3(size.x * 0.3, size.y * 0.22, size.z * 0.3), 5, 10, 0.9)
	circles.append(Vector3(0.0, 0.0, trunk * 1.5))


static func _mound(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	mesh.blob("main", Vector3(0, size.y * 0.3, 0), Vector3(size.x * 0.5, size.y * 0.5, size.z * 0.5), 6, 14, 0.9)
	mesh.blob("accent", Vector3(-size.x * 0.18, size.y * 0.55, size.z * 0.08), Vector3(size.x * 0.28, size.y * 0.35, size.z * 0.28), 5, 10, 0.9)
	mesh.blob("dark", Vector3(size.x * 0.2, size.y * 0.45, -size.z * 0.1), Vector3(size.x * 0.26, size.y * 0.3, size.z * 0.26), 5, 10, 0.9)
	var bits: int = 7
	for index: int in range(bits):
		var a: float = float(index) * 2.4
		var p: Vector3 = Vector3(cos(a) * size.x * 0.3, size.y * (0.2 + 0.12 * float(index % 4)), sin(a) * size.z * 0.3)
		mesh.box("light" if index % 2 == 0 else "accent", p, Vector3(0.9, 0.5, 0.7), Basis(Vector3.UP, a), 0.04)
	circles.append(Vector3(0.0, 0.0, minf(size.x, size.z) * 0.36))


static func _obelisk(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	mesh.lathe("main", Vector3.ZERO, [Vector2(size.x * 0.6, 0.0), Vector2(size.x * 0.5, size.y * 0.9), Vector2(size.x * 0.15, size.y)], 4, 0.9, true, true)
	mesh.box("glow", Vector3(0, size.y * 0.55, size.x * 0.28), Vector3(size.x * 0.18, size.y * 0.35, 0.06), Basis.IDENTITY, 0.0)
	circles.append(Vector3(0.0, 0.0, size.x * 0.55))


static func _colonnade(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var count: int = maxi(3, int(size.x / 2.4))
	for column: int in range(count):
		var x: float = -size.x * 0.5 + size.x * float(column) / float(count - 1)
		mesh.tube("light", Vector3(x, 0.0, 0.0), Vector3(x, size.y * 0.88, 0.0), minf(0.4, size.z * 0.4), 10, true)
		circles.append(Vector3(x, 0.0, 0.5))
	mesh.box("accent", Vector3(0, size.y * 0.94, 0), Vector3(size.x + 0.8, size.y * 0.12, size.z + 0.4), Basis.IDENTITY, 0.05)
	mesh.box("main", Vector3(0, 0.1, 0), Vector3(size.x + 0.8, 0.2, size.z + 0.8), Basis.IDENTITY, 0.03)


static func _stair(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var steps: int = maxi(3, int(size.y / 0.35))
	for step: int in range(steps):
		var depth: float = size.z * (1.0 - float(step) / float(steps))
		var h: float = size.y * float(step + 1) / float(steps)
		mesh.box("main" if step % 2 == 0 else "light", Vector3(0, h * 0.5, -size.z * 0.5 + depth * 0.5), Vector3(size.x, h, depth), Basis.IDENTITY, 0.02)
	# Walkable ramp look only: no collision circles (the hero walks up as a slope would be: kept flat, so it blocks like a plinth).
	_footprint_circles(size, circles)


static func _island(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var r: float = size.x * 0.5
	var lift: float = size.y
	mesh.lathe("main", Vector3(0, lift, 0), [Vector2(r, 0.0), Vector2(r * 0.96, -0.5), Vector2(r * 0.72, -size.y * 0.8), Vector2(r * 0.42, -size.y * 1.3), Vector2(r * 0.1, -size.y * 1.6)], 14, 0.9, false, false)
	# a domed grass top, rock lumps round the rim and underneath, vines hanging off the edge
	mesh.blob("accent", Vector3(0, lift - 0.2, 0), Vector3(r, 0.5, r), 3, 14, 1.0)
	for index: int in range(6):
		var a: float = float(index) * 1.05 + 0.4
		mesh.blob("main", Vector3(cos(a) * r * 0.86, lift - 0.4 - float(index % 3) * 0.3, sin(a) * r * 0.86), Vector3(r * 0.26, r * 0.2, r * 0.24), 3, 7, 0.85)
		var from: Vector3 = Vector3(cos(a + 0.5) * r * 0.95, lift - 0.1, sin(a + 0.5) * r * 0.95)
		mesh.tube("accent", from, from - Vector3(0, 0.8 + float(index % 3) * 0.5, 0), 0.07, 4, true)
	mesh.blob("main", Vector3(0, lift - size.y * 1.35, 0), Vector3(r * 0.3, r * 0.35, r * 0.3), 4, 8, 0.8)


static func _cliff(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	mesh.box("main", Vector3(0, size.y * 0.5, 0), size, Basis.IDENTITY, 0.5, 0.9)
	mesh.box("accent", Vector3(0, size.y + 0.1, 0), Vector3(size.x * 0.96, 0.4, size.z * 0.96), Basis.IDENTITY, 0.2)
	_footprint_circles(size, circles)


static func _bridge(mesh: KitMesh, size: Vector3, _circles: Array[Vector3]) -> void:
	mesh.box("accent", Vector3(0, 0.25, 0), Vector3(size.x, 0.3, size.z), Basis.IDENTITY, 0.03)
	for side: float in [-1.0, 1.0]:
		mesh.box("dark", Vector3(0, 0.9, side * size.z * 0.5), Vector3(size.x, 0.12, 0.14), Basis.IDENTITY, 0.0)
		for post: int in range(0, int(size.x / 1.6) + 1):
			mesh.box("dark", Vector3(-size.x * 0.5 + float(post) * 1.6, 0.55, side * size.z * 0.5), Vector3(0.14, 0.9, 0.14), Basis.IDENTITY, 0.0)


static func _shrine(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	mesh.box("dark", Vector3(0, 0.2, 0), Vector3(size.x, 0.4, size.z), Basis.IDENTITY, 0.04)
	mesh.box("main", Vector3(0, size.y * 0.45, 0), Vector3(size.x * 0.7, size.y * 0.7, size.z * 0.7), Basis.IDENTITY, 0.05)
	mesh.tri("accent", [Vector3(-size.x * 0.5, size.y * 0.8, size.z * 0.4), Vector3(size.x * 0.5, size.y * 0.8, size.z * 0.4), Vector3(0, size.y, size.z * 0.4)], Vector3(0, 0, 1))
	mesh.box("glow", Vector3(0, size.y * 0.45, size.z * 0.36), Vector3(size.x * 0.3, size.y * 0.35, 0.06), Basis.IDENTITY, 0.0)
	circles.append(Vector3(0.0, 0.0, maxf(size.x, size.z) * 0.5))


static func _rift(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	mesh.blob("glow", Vector3(0, size.y * 0.5, 0), Vector3(size.x * 0.35, size.y * 0.5, 0.15), 6, 14, 1.0)
	circles.append(Vector3(0.0, 0.0, size.x * 0.4))


static func _tank(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var r: float = size.x * 0.5
	mesh.lathe("dark", Vector3.ZERO, [Vector2(r + 0.15, 0.0), Vector2(r + 0.15, 0.3)], 14, 0.9, true, true)
	mesh.lathe("glow", Vector3(0, 0.3, 0), [Vector2(r, 0.0), Vector2(r, size.y - 0.6)], 14, 1.0, false, false)
	mesh.lathe("dark", Vector3(0, size.y - 0.3, 0), [Vector2(r + 0.15, 0.0), Vector2(r + 0.15, 0.3)], 14, 0.9, true, true)
	for post: int in range(4):
		var a: float = float(post) * PI * 0.5 + 0.8
		mesh.tube("accent", Vector3(cos(a) * (r + 0.1), 0.2, sin(a) * (r + 0.1)), Vector3(cos(a) * (r + 0.1), size.y - 0.2, sin(a) * (r + 0.1)), 0.08, 5, false)
	circles.append(Vector3(0.0, 0.0, r + 0.2))


static func _hatch(mesh: KitMesh, size: Vector3, _circles: Array[Vector3]) -> void:
	mesh.lathe("dark", Vector3.ZERO, [Vector2(size.x * 0.5 + 0.25, 0.0), Vector2(size.x * 0.5 + 0.25, 0.12)], 14, 1.0, false, true)
	mesh.lathe("main", Vector3(0, 0.12, 0), [Vector2(size.x * 0.5, 0.0), Vector2(size.x * 0.5, 0.1)], 14, 1.0, false, true)
	mesh.box("accent", Vector3(0, 0.3, 0), Vector3(size.x * 0.45, 0.1, 0.18), Basis.IDENTITY, 0.0)


static func _hut(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	mesh.box("main", Vector3(0, size.y * 0.35, 0), Vector3(size.x, size.y * 0.7, size.z), Basis.IDENTITY, 0.06, 0.9)
	mesh.box("accent", Vector3(0, size.y * 0.78, 0), Vector3(size.x * 1.15, size.y * 0.16, size.z * 1.15), Basis.IDENTITY, 0.05)
	mesh.box("dark", Vector3(0, size.y * 0.3, size.z * 0.5 + 0.03), Vector3(size.x * 0.28, size.y * 0.55, 0.08), Basis.IDENTITY, 0.02)
	_footprint_circles(size, circles)


static func _river(mesh: KitMesh, size: Vector3, _circles: Array[Vector3]) -> void:
	mesh.box("water", Vector3(0, 0.02, 0), Vector3(size.x, 0.06, size.z), Basis.IDENTITY, 0.0, 1.0)


static func _lawn_row(mesh: KitMesh, size: Vector3, _circles: Array[Vector3]) -> void:
	mesh.box("main", Vector3(0, 0.04, 0), Vector3(size.x, 0.08, size.z), Basis.IDENTITY, 0.03, 1.0)
