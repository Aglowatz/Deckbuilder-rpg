class_name CosmeticMeshes
extends RefCounted
## Builds the hats and cloaks (docs/art/cosmetics.md). Everything here is procedural (ProcMesh primitives in the style guide palette) except the wizard hat,
## which is lifted from the KayKit Mage. Hats are built in "hat space" (origin at the middle of the hat's base, +Y up, +Z the way the hero faces);
## cloaks hang from their root (the shoulders) in a chain of pivots so `CloakSway` can bend them as the hero moves.

const WIZARD_HAT_MODEL: String = "res://assets/KayKit-Character-Pack-Adventures-1.0/Characters/Mage.glb"

## Where the hat origin sits in the head bone's space, and where the cloak root sits in the chest bone's space (tuned by screenshot).
const HAT_OFFSET: Vector3 = Vector3(0.0, 0.66, 0.0)
const CLOAK_OFFSET: Vector3 = Vector3(0.0, 0.2, -0.42)


static func build_hat(item_id: String, dye_index: int) -> Node3D:
	var primary: Color = Dye.primary(dye_index)
	var secondary: Color = Dye.secondary(dye_index)
	var root: Node3D = Node3D.new()
	root.name = "Hat"
	root.set_meta("cosmetic_id", item_id)
	var mesh: ProcMesh = ProcMesh.new()
	match item_id:
		"hat_wizard":
			return _wizard(root, primary, secondary)
		"hat_wide_brim":
			mesh.ring(0.0, 0.34, 0.9, 0.05, 20, primary, Transform3D.IDENTITY, 0.95)
			mesh.frustum(0.0, 0.36, 0.44, 0.38, 16, primary.lightened(0.06), Transform3D.IDENTITY, true, false, 1.0)
			mesh.frustum(0.02, 0.13, 0.452, 0.436, 16, secondary)
		"hat_beanie":
			mesh.sphere(Vector3(0, 0.12, 0), 0.54, 6, 14, primary, Transform3D.IDENTITY, 0.78)
			mesh.frustum(-0.12, 0.14, 0.56, 0.56, 14, secondary, Transform3D.IDENTITY, false, false)
			mesh.ring(0.14, 0.4, 0.56, 0.03, 14, secondary.lightened(0.05))
			mesh.sphere(Vector3(0, 0.58, 0), 0.14, 4, 8, secondary)
		"hat_tricorn":
			mesh.frustum(0.0, 0.26, 0.46, 0.42, 14, primary)
			mesh.ring(-0.02, 0.4, 0.74, 0.05, 18, primary.darkened(0.1), Transform3D.IDENTITY, 0.92)
			for angle: float in [90.0, 210.0, 330.0]:
				var a: float = deg_to_rad(angle)
				var left: Vector3 = Vector3(cos(a - 0.62) * 0.46, 0.0, sin(a - 0.62) * 0.46)
				var right: Vector3 = Vector3(cos(a + 0.62) * 0.46, 0.0, sin(a + 0.62) * 0.46)
				var tip: Vector3 = Vector3(cos(a) * 0.74, 0.34, sin(a) * 0.74)
				mesh.tri(left, tip, right, primary.darkened(0.04))
				mesh.tri(left, Vector3(cos(a - 0.3) * 0.74, 0.02, sin(a - 0.3) * 0.74), tip, secondary)
				mesh.tri(right, tip, Vector3(cos(a + 0.3) * 0.74, 0.02, sin(a + 0.3) * 0.74), secondary)
			mesh.frustum(0.02, 0.1, 0.472, 0.465, 14, secondary)
		"hat_leaf_crown":
			var twig: Color = Color("7a5a3a")
			mesh.frustum(0.0, 0.07, 0.5, 0.5, 18, twig, Transform3D.IDENTITY, false, false)
			var leaf_tones: Array[Color] = [primary, primary.lightened(0.18), primary.darkened(0.18)]
			for i: int in range(11):
				var angle: float = TAU * float(i) / 11.0
				var xform: Transform3D = Transform3D(Basis(Vector3.UP, -angle) * Basis(Vector3(1, 0, 0), deg_to_rad(-12.0 - 18.0 * float(i % 2))), Vector3(cos(angle) * 0.5, 0.05, sin(angle) * 0.5))
				var tone: Color = leaf_tones[i % 3]
				mesh.tri(Vector3(0, 0, -0.1), Vector3(0.26, 0.04, 0.0), Vector3(0, 0, 0.1), tone, xform)
				mesh.tri(Vector3(0, 0, -0.1), Vector3(0, 0, 0.1), Vector3(0.0, 0.2, 0.0), tone.lightened(0.1), xform)
				mesh.tri(Vector3(0, 0.2, 0), Vector3(0.26, 0.04, 0.0), Vector3(0, 0, 0.1), tone.darkened(0.08), xform)
			for i: int in range(4):
				var angle2: float = TAU * (float(i) + 0.5) / 4.0
				mesh.sphere(Vector3(cos(angle2) * 0.52, 0.08, sin(angle2) * 0.52), 0.06, 3, 6, Color("d8453a"))
		"hat_chef":
			mesh.frustum(0.0, 0.26, 0.44, 0.46, 16, primary, Transform3D.IDENTITY, false, false)
			mesh.sphere(Vector3(0, 0.55, 0), 0.5, 5, 14, primary.lightened(0.04), Transform3D.IDENTITY, 0.85)
			for i: int in range(6):
				var angle3: float = TAU * float(i) / 6.0
				mesh.sphere(Vector3(cos(angle3) * 0.34, 0.5, sin(angle3) * 0.34), 0.22, 3, 8, primary.darkened(0.04))
			mesh.frustum(0.0, 0.07, 0.452, 0.452, 16, secondary, Transform3D.IDENTITY, false, false)
		"hat_bowler":
			mesh.sphere(Vector3(0, 0.05, 0), 0.52, 6, 14, primary, Transform3D.IDENTITY, 0.95)
			mesh.ring(0.0, 0.42, 0.68, 0.04, 16, primary.darkened(0.08), Transform3D.IDENTITY, 0.95)
			mesh.frustum(0.03, 0.14, 0.5, 0.5, 14, secondary, Transform3D.IDENTITY, false, false)
		"hat_top_hat":
			mesh.frustum(0.0, 0.92, 0.38, 0.36, 16, primary)
			mesh.ring(0.0, 0.3, 0.66, 0.05, 18, primary.darkened(0.06))
			mesh.frustum(0.03, 0.19, 0.392, 0.385, 16, secondary)
			mesh.box(Vector3(0.0, 0.11, 0.382), Vector3(0.14, 0.14, 0.03), Color("f2c13c"))
		"hat_cat_ears":
			mesh.ring(0.18, 0.5, 0.57, 0.07, 16, secondary.darkened(0.1), Transform3D.IDENTITY, 0.96)
			for side: float in [-1.0, 1.0]:
				var ear: Transform3D = Transform3D(Basis(Vector3(0, 0, 1), deg_to_rad(-side * 18.0)), Vector3(side * 0.31, 0.2, 0.0))
				mesh.frustum(0.0, 0.34, 0.2, 0.0, 4, primary, ear)
				mesh.frustum(0.02, 0.26, 0.12, 0.0, 4, Color("f4a8c0"), Transform3D(ear.basis, ear.origin + Vector3(0, 0.0, 0.07)))
		"hat_straw":
			mesh.ring(0.0, 0.36, 1.0, 0.04, 22, primary, Transform3D(Basis(Vector3(1, 0, 0), deg_to_rad(2.0)), Vector3.ZERO), 0.98)
			mesh.frustum(0.0, 0.3, 0.46, 0.4, 16, primary.lightened(0.08))
			mesh.frustum(0.02, 0.12, 0.466, 0.45, 16, secondary)
		"hat_party":
			var tilt: Transform3D = Transform3D(Basis(Vector3(1, 0, 0), deg_to_rad(-9.0)), Vector3(0, 0, 0.04))
			mesh.frustum(0.0, 0.32, 0.34, 0.24, 14, primary, tilt, false)
			mesh.frustum(0.32, 0.62, 0.24, 0.13, 14, secondary, tilt, false)
			mesh.frustum(0.62, 0.9, 0.13, 0.0, 14, primary, tilt)
			mesh.sphere(Vector3(0, 0.93, 0.0) + Vector3(0, 0, -0.16), 0.1, 4, 8, Color("f2c13c"))
		"hat_mushroom":
			mesh.sphere(Vector3(0, 0.1, 0), 0.7, 7, 16, primary, Transform3D.IDENTITY, 0.6)
			mesh.ring(0.05, 0.3, 0.62, 0.02, 16, Color("f1e6cf"), Transform3D.IDENTITY, 1.0, Color("f1e6cf"))
			for i: int in range(7):
				var angle4: float = TAU * float(i) / 7.0 + 0.4
				var radius: float = 0.36 if i % 2 == 0 else 0.5
				var height: float = 0.1 + sqrt(maxf(0.0, 1.0 - (radius / 0.7) * (radius / 0.7))) * 0.7 * 0.6
				mesh.sphere(Vector3(cos(angle4) * radius, height, sin(angle4) * radius), 0.09, 3, 6, Color("f6efe0"), Transform3D.IDENTITY, 0.45)
			mesh.sphere(Vector3(0, 0.69, 0), 0.09, 3, 6, Color("f6efe0"), Transform3D.IDENTITY, 0.45)
		_:
			return null
	var instance: MeshInstance3D = mesh.build("HatMesh")
	root.add_child(instance)
	return root


## The wizard hat is the KayKit Mage's own hat mesh (CC0), tinted by the dye, scaled to sit on the Rogue.
static func _wizard(root: Node3D, primary: Color, secondary: Color) -> Node3D:
	var source: Node3D = ModelKit.scene(WIZARD_HAT_MODEL).instantiate() as Node3D
	var found: Array[Node] = source.find_children("*Hat*", "MeshInstance3D", true, false)
	if found.is_empty():
		source.free()
		return _fallback_wizard(root, primary, secondary)
	var hat_mesh: MeshInstance3D = found[0] as MeshInstance3D
	var copy: MeshInstance3D = MeshInstance3D.new()
	copy.name = "HatMesh"
	copy.mesh = hat_mesh.mesh
	var material: Material = hat_mesh.get_active_material(0)
	if material is StandardMaterial3D:
		var tinted: StandardMaterial3D = (material as StandardMaterial3D).duplicate() as StandardMaterial3D
		tinted.albedo_color = Color.WHITE.lerp(primary, 0.85)
		copy.material_override = tinted
	copy.position = Vector3(0.0, 0.1, 0.0)
	copy.scale = Vector3.ONE * 0.86
	root.add_child(copy)
	root.set_meta("source_scale", 1.0)
	source.free()
	return root


static func _fallback_wizard(root: Node3D, primary: Color, secondary: Color) -> Node3D:
	var mesh: ProcMesh = ProcMesh.new()
	mesh.ring(0.0, 0.34, 0.86, 0.05, 20, primary, Transform3D.IDENTITY, 0.95)
	mesh.frustum(0.0, 0.55, 0.44, 0.26, 16, primary)
	mesh.frustum(0.55, 1.05, 0.26, 0.0, 16, primary.lightened(0.05), Transform3D(Basis(Vector3(1, 0, 0), deg_to_rad(-14.0)), Vector3(0, 0, 0)))
	mesh.frustum(0.02, 0.14, 0.452, 0.43, 16, secondary)
	root.add_child(mesh.build("HatMesh"))
	return root


# ---- Cloaks -------------------------------------------------------------------------------------------------------------------------


## A cloak: a root at the shoulders with `segments` chained pivots (Seg0 top ... SegN-1 bottom). `sway_weights` / `sway_rates` feed `CloakSway`.
static func build_cloak(item_id: String, dye_index: int) -> Node3D:
	var primary: Color = Dye.primary(dye_index)
	var secondary: Color = Dye.secondary(dye_index)
	var root: Node3D = Node3D.new()
	root.name = "Cloak"
	root.set_meta("cosmetic_id", item_id)
	var spec: Dictionary = {}
	match item_id:
		"cloak_short":
			spec = {"segments": 2, "length": 0.5, "w_top": 0.78, "w_bottom": 0.95, "curve": 0.12, "color": primary, "hem": secondary}
		"cloak_traveler":
			spec = {"segments": 3, "length": 0.92, "w_top": 0.78, "w_bottom": 1.1, "curve": 0.16, "color": primary, "hem": primary.darkened(0.2)}
		"cloak_hooded":
			spec = {"segments": 3, "length": 0.9, "w_top": 0.8, "w_bottom": 1.12, "curve": 0.16, "color": primary, "hem": secondary}
		"cloak_tattered":
			spec = {"segments": 3, "length": 0.95, "w_top": 0.78, "w_bottom": 1.15, "curve": 0.14, "color": primary.darkened(0.12), "hem": primary.darkened(0.3), "jagged": 0.16}
		"cloak_royal":
			spec = {"segments": 3, "length": 1.02, "w_top": 0.92, "w_bottom": 1.45, "curve": 0.2, "color": primary, "hem": secondary}
		"cloak_patchwork":
			spec = {"segments": 3, "length": 0.88, "w_top": 0.8, "w_bottom": 1.08, "curve": 0.15, "color": primary, "hem": secondary, "patches": true}
		"cloak_poncho":
			spec = {"segments": 2, "length": 0.62, "w_top": 0.9, "w_bottom": 1.1, "curve": 0.14, "color": primary, "hem": secondary, "stripes": 4}
		"cloak_leaf":
			spec = {"segments": 3, "length": 0.8, "w_top": 0.76, "w_bottom": 1.0, "curve": 0.15, "color": primary, "hem": primary.darkened(0.2), "leaves": true}
		"cloak_star":
			spec = {"segments": 3, "length": 0.95, "w_top": 0.78, "w_bottom": 1.12, "curve": 0.16, "color": primary.darkened(0.22), "hem": secondary, "stars": true}
		"cloak_four_seals":
			spec = {"segments": 3, "length": 1.0, "w_top": 0.8, "w_bottom": 1.2, "curve": 0.18, "color": primary.darkened(0.15), "hem": secondary, "patches": true}
		"cloak_scarf":
			spec = {"segments": 5, "length": 1.1, "w_top": 0.2, "w_bottom": 0.24, "curve": 0.0, "color": primary, "hem": secondary, "scarf": true}
		_:
			return null
	_build_segments(root, spec, item_id, primary, secondary)
	_build_root_pieces(root, item_id, primary, secondary)
	return root


static func _build_segments(root: Node3D, spec: Dictionary, item_id: String, primary: Color, secondary: Color) -> void:
	var count: int = int(spec["segments"])
	var length: float = float(spec["length"])
	var seg_len: float = length / float(count)
	var w_top: float = float(spec["w_top"])
	var w_bottom: float = float(spec["w_bottom"])
	var parent: Node3D = root
	var pivots: Array[Node3D] = []
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash(item_id)
	var strands: int = 2 if bool(spec.get("scarf", false)) else 1
	for strand: int in range(strands):
		parent = root
		for i: int in range(count):
			var pivot: Node3D = Node3D.new()
			pivot.name = "Seg%d" % i if strands == 1 else "Strand%dSeg%d" % [strand, i]
			if i > 0:
				pivot.position = Vector3(0.0, -seg_len, 0.0)
			elif strands == 2:
				pivot.position = Vector3((-0.16 if strand == 0 else 0.16), 0.0, 0.0)
			parent.add_child(pivot)
			var t0: float = float(i) / float(count)
			var t1: float = float(i + 1) / float(count)
			var wt: float = lerpf(w_top, w_bottom, t0)
			var wb: float = lerpf(w_top, w_bottom, t1)
			var mesh: ProcMesh = ProcMesh.new()
			var color: Color = spec["color"] as Color
			var color_b: Color = Color(0, 0, 0, 0)
			var jag: float = float(spec.get("jagged", 0.0)) if i == count - 1 else 0.0
			var columns: int = 8
			var stripes: int = int(spec.get("stripes", 0))
			if bool(spec.get("patches", false)):
				color = [primary, secondary, primary.lerp(Dye.primary((Dye.PALETTE.size() + 5) % Dye.PALETTE.size()), 0.6)][i % 3]
				color_b = [secondary, primary.darkened(0.15), primary][i % 3]
				stripes = 4
			elif stripes > 0:
				color_b = secondary
			if i == count - 1 and not bool(spec.get("scarf", false)) and not bool(spec.get("patches", false)) and stripes == 0:
				mesh.panel(0.0, -seg_len * 0.8, wt, lerpf(wt, wb, 0.8), 0.0, float(spec["curve"]) * 0.9, columns, color, Transform3D.IDENTITY, jag)
				mesh.panel(-seg_len * 0.8, -seg_len, lerpf(wt, wb, 0.8), wb, 0.0, float(spec["curve"]), columns, spec["hem"] as Color, Transform3D.IDENTITY, jag)
			else:
				mesh.panel(0.0, -seg_len, wt, wb, 0.0, float(spec["curve"]), columns, color, Transform3D.IDENTITY, jag, color_b, stripes)
			if bool(spec.get("leaves", false)):
				_leaf_scales(mesh, seg_len, wt, rng, primary)
			if bool(spec.get("stars", false)):
				_stars(mesh, seg_len, wt, rng)
			var instance: MeshInstance3D = mesh.build("Panel")
			pivot.add_child(instance)
			if bool(spec.get("leaves", false)):
				# the leaf scales replace the flat panel's colour look: keep both (the panel is the dark backing)
				pass
			pivots.append(pivot)
			parent = pivot
	root.set_meta("pivot_count", pivots.size())
	root.set_meta("scarf", bool(spec.get("scarf", false)))


static func _leaf_scales(mesh: ProcMesh, seg_len: float, width: float, rng: RandomNumberGenerator, primary: Color) -> void:
	mesh.facing(Vector3(0, 0, -1))
	var rows: int = 3
	for row: int in range(rows):
		var y: float = -seg_len * (float(row) + 0.5) / float(rows) + seg_len * 0.15
		var count: int = 6
		for i: int in range(count):
			var x: float = (float(i) / float(count - 1) - 0.5) * width * 0.92 + (0.06 if row % 2 == 1 else 0.0)
			var tone: Color = primary.lerp(Color("c8e860"), rng.randf_range(0.0, 0.45)).darkened(rng.randf_range(0.0, 0.18))
			var z: float = -0.015 - 0.01 * float(row)
			mesh.tri(Vector3(x - 0.09, y + 0.08, z), Vector3(x + 0.09, y + 0.08, z), Vector3(x, y - 0.12, z - 0.01), tone)
			mesh.tri(Vector3(x - 0.09, y + 0.08, z), Vector3(x, y + 0.2, z), Vector3(x + 0.09, y + 0.08, z), tone.lightened(0.1))


static func _stars(mesh: ProcMesh, seg_len: float, width: float, rng: RandomNumberGenerator) -> void:
	for i: int in range(5):
		var x: float = rng.randf_range(-0.4, 0.4) * width
		var y: float = rng.randf_range(-0.9, -0.1) * seg_len
		var s: float = rng.randf_range(0.035, 0.065)
		var z: float = -0.02
		var gold: Color = Color("ffe27a")
		mesh.facing(Vector3(0, 0, -1))
		mesh.quad(Vector3(x - s, y, z), Vector3(x, y + s * 2.2, z), Vector3(x + s, y, z), Vector3(x, y - s * 2.2, z), gold)
		mesh.quad(Vector3(x - s * 2.2, y, z), Vector3(x, y + s, z), Vector3(x + s * 2.2, y, z), Vector3(x, y - s, z), gold.darkened(0.05))


## Pieces that hang on the root (not swaying much): collars, hoods, clasps, neck wraps.
static func _build_root_pieces(root: Node3D, item_id: String, primary: Color, secondary: Color) -> void:
	var mesh: ProcMesh = ProcMesh.new()
	var gold: Color = Color("f2c13c")
	match item_id:
		"cloak_short", "cloak_traveler", "cloak_patchwork", "cloak_tattered", "cloak_leaf", "cloak_star", "cloak_four_seals":
			mesh.sphere(Vector3(0, 0.0, 0.0), 0.075, 3, 8, gold, Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, 0.3)))
			mesh.frustum(-0.06, 0.03, 0.4, 0.38, 12, secondary, Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, 0.32)), false, false, 0.78)
		"cloak_hooded":
			mesh.frustum(-0.06, 0.03, 0.4, 0.38, 12, secondary, Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, 0.32)), false, false, 0.78)
			mesh.sphere(Vector3(0.0, 0.2, -0.06), 0.34, 5, 10, primary, Transform3D.IDENTITY, 1.0, 0.9)
			mesh.sphere(Vector3(0.0, 0.1, -0.16), 0.3, 4, 8, primary.darkened(0.15))
		"cloak_royal":
			for i: int in range(9):
				var angle: float = deg_to_rad(-200.0 + 220.0 * float(i) / 8.0)
				mesh.sphere(Vector3(cos(angle) * 0.42, 0.03, sin(angle) * 0.3 + 0.28), 0.17, 3, 7, Color("f6efe2"))
			mesh.sphere(Vector3(0.0, -0.02, 0.58), 0.09, 4, 8, gold)
			mesh.box(Vector3(0.0, -0.14, -0.0), Vector3(0.9, 0.05, 0.02), gold)
		"cloak_poncho":
			mesh.frustum(-0.05, 0.05, 0.42, 0.36, 12, secondary, Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, 0.3)), false, false, 0.78)
		"cloak_scarf":
			mesh.frustum(-0.06, 0.1, 0.4, 0.36, 12, primary, Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, 0.3)), false, false, 0.8)
			mesh.frustum(-0.1, 0.0, 0.405, 0.4, 12, secondary, Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, 0.3)), false, false, 0.8)
	if not mesh.is_empty():
		root.add_child(mesh.build("Trim"))
	if item_id == "cloak_poncho":
		# the front drape of the poncho: a second, shorter panel on the chest
		var front: ProcMesh = ProcMesh.new()
		front.panel(0.0, -0.5, 0.8, 1.0, 0.0, -0.1, 8, primary, Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, 0.62)), 0.0, secondary, 4)
		root.add_child(front.build("FrontDrape"))
