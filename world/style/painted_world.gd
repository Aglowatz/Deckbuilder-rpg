class_name PaintedWorld
extends Node
## Applies a zone's painted texture preset (data/art/texture_presets.json) to a built scene: the painted ground (an overlay grid above hex tiles, or the zone's own vertex-coloured
## terrain meshes swapped to the painted terrain material), the decal scatter, and the debug toggle (Shift+T in debug builds, or `--tex=0|1` in screenshot runs) that switches the
## whole look between the new textures and the old flat look. Building/prop materials are painted by `StyleToon` (see `PaintedClasses`); the toggle flips them through the
## `style_paint` shader global. Gameplay, collision and layouts are never touched: this is visual only.
##
## `context` (all optional): "bounds" Rect2 (x/z area the overlay and masks cover), "masks" {name: Callable(Vector2) -> 0..1}, "terrain" Array[MeshInstance3D] (vertex-coloured meshes to swap),
## "flat_hidden" Array[Node3D] (flat-look overlays hidden while painted), "avoid" Array[Vector3], "walls" Array[Dictionary], "height"/"floor" Callables for the decals.

signal toggled(painted: bool)

const OVERLAY_LIFT: float = 0.0256

var preset_id: StringName = &""
var preset: Dictionary = {}
var painted: bool = true
var material: ShaderMaterial
var overlay: MeshInstance3D
var decal_meshes: Array[MeshInstance3D] = []
var _scene: Node3D
var _swaps: Array[Dictionary] = []
var _flat_hidden: Array[Node3D] = []
var _hud_toast: Callable = Callable()


## Returns null (and the zone keeps its flat look) when the zone has no preset or its base texture is missing.
static func apply(scene: Node3D, area: WalkableArea, id: StringName, context: Dictionary = {}) -> PaintedWorld:
	var data: Dictionary = PaintedLibrary.preset(id)
	if data.is_empty() or OS.get_environment("NO_PAINT") != "":
		return null
	var world: PaintedWorld = PaintedWorld.new()
	world.name = "PaintedWorld"
	world.preset_id = id
	world.preset = data
	world._scene = scene
	if not world._build(area, context):
		world.free()
		return null
	scene.add_child(world)
	world._start_mode()
	return world


func _build(area: WalkableArea, context: Dictionary) -> bool:
	material = PaintedTerrain.material(preset, context)
	if material == null:
		push_warning("PaintedWorld: %s has no usable ground preset, keeping the flat look" % preset_id)
		return false
	var mode: String = str(preset.get("ground", "overlay"))
	var bounds: Rect2 = context.get("bounds", area.map_bounds() if area != null else Rect2(-30, -30, 60, 60)) as Rect2
	if mode == "overlay" and area != null and not OS.get_environment("PAINT_SKIP").contains("ground"):
		material.render_priority = -100
		overlay = PaintedGroundOverlay.build(area, bounds, float(context.get("lift", OVERLAY_LIFT)), material, context.get("cover", Callable()) as Callable)
		if overlay != null:
			_scene.add_child(overlay)
	for mesh: Variant in context.get("terrain", []) as Array:
		var instance: MeshInstance3D = mesh as MeshInstance3D
		if instance == null:
			continue
		_swaps.append({"mesh": instance, "old": instance.material_override, "new": _terrain_material_for(instance)})
	var variant_cache: Dictionary = {}
	for entry: Variant in context.get("swaps", []) as Array:
		var info: Dictionary = entry as Dictionary
		var target: GeometryInstance3D = info["node"] as GeometryInstance3D
		var surface: int = int(info.get("surface", -1))
		var replacement: Material = info.get("material") as Material
		if replacement == null and info.has("variant"):
			var variant_name: String = str(info["variant"])
			if not variant_cache.has(variant_name):
				variant_cache[variant_name] = _variant_material(variant_name, context)
			replacement = variant_cache[variant_name] as Material
		if target == null or replacement == null:
			continue
		var previous: Material = target.material_override if surface < 0 else (target as MeshInstance3D).get_surface_override_material(surface)
		_swaps.append({"mesh": target, "surface": surface, "old": previous, "new": replacement})
	for node: Variant in context.get("flat_hidden", []) as Array:
		_flat_hidden.append(node as Node3D)
	var entries: Array = preset.get("decals", []) as Array
	if not entries.is_empty() and not OS.get_environment("PAINT_SKIP").contains("decals"):
		var decal_context: Dictionary = context.duplicate()
		decal_context["area"] = area
		decal_context["bounds"] = bounds
		var quality: int = Settings.graphics_quality
		var placements: Array[PaintedDecals.Placement] = PaintedDecals.place(entries, decal_context, int(preset.get("seed", 7)), quality)
		decal_meshes = PaintedDecals.build(_scene, placements)
	return true


## Cliff/rim meshes of a zone (named in the preset under "rock_nodes") can use a different cliff texture than the ground.
func _terrain_material_for(_instance: MeshInstance3D) -> Material:
	return material


func _start_mode() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	for arg: String in args:
		if arg == "--tex=0":
			painted = false
	PaintedLibrary.set_enabled(painted)
	_apply_mode()


func _apply_mode() -> void:
	if overlay != null:
		overlay.visible = painted
	for swap: Dictionary in _swaps:
		var chosen: Material = (swap["new"] if painted else _flat_material(swap["old"] as Material)) as Material
		var target: GeometryInstance3D = swap["mesh"] as GeometryInstance3D
		if int(swap.get("surface", -1)) >= 0:
			(target as MeshInstance3D).set_surface_override_material(int(swap["surface"]), chosen)
		else:
			target.material_override = chosen
	for mesh: MeshInstance3D in decal_meshes:
		mesh.visible = painted
	for node: Node3D in _flat_hidden:
		if is_instance_valid(node):
			node.visible = not painted


func set_painted(value: bool) -> void:
	painted = value
	PaintedLibrary.set_enabled(value)
	_apply_mode()
	toggled.emit(value)


func toggle() -> void:
	set_painted(not painted)


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	var key: InputEventKey = event as InputEventKey
	# T opens the wardrobe in the zones (gameplay), so the debug toggle is Shift+T.
	if key != null and key.pressed and not key.echo and key.keycode == KEY_T and key.shift_pressed:
		get_viewport().set_input_as_handled()
		toggle()
		print("painted textures: %s" % ("ON" if painted else "OFF (old flat look)"))


func _exit_tree() -> void:
	PaintedLibrary.set_enabled(true)


## The flat look of a swapped mesh: a plain StandardMaterial3D that StyleRig had not converted yet becomes its toon version.
func _flat_material(old: Material) -> Material:
	if old is StandardMaterial3D:
		var toon: ShaderMaterial = StyleToon.toon_for(old, -1.0, false)
		return toon if toon != null else old
	return old


## A terrain material built from one of the preset's `variants` (the base preset's tuning with that variant's layers), e.g. one per D.N.A. floor kind.
func _variant_material(variant_name: String, context: Dictionary) -> ShaderMaterial:
	var variants: Dictionary = preset.get("variants", {}) as Dictionary
	if not variants.has(variant_name):
		return null
	var merged: Dictionary = preset.duplicate(true)
	merged.erase("variants")
	merged.merge(variants[variant_name] as Dictionary, true)
	return PaintedTerrain.material(merged, context)
