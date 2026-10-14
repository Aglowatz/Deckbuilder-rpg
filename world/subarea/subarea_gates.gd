class_name SubAreaGates
extends Node3D
## The gates a hub scene shows for its sub-areas (data `gates` of `data/subareas/<area>/_zone.json`): a stone arch with a soft light pillar and a pictogram (G-03: no lettering in the world; the name shows in the HUD prompt when the hero is near). Walking up and
## pressing the interact key loads the sub-area scene (the hub is freed; zone state lives in the session). One node per hub scene: `SubAreaGates.install(scene, areas)`.
## It polls the hero's distance itself so the hub scenes need no interaction code of their own; it stays quiet while the hub is locked or a dialogue is open.

const RADIUS: float = 2.8

var host: Node3D
var gates: Array[Dictionary] = []

var _icons: Array[MeshInstance3D] = []
var _near: int = -1
var _prompting: bool = false

const FALLBACK_ICON: String = "ICON-MAP-EXIT"


## Adds the gates of `area_ids` to `hub`. Returns the node (null when there is nothing to show).
static func install(hub: Node3D, area_ids: Array[String]) -> SubAreaGates:
	var list: Array[Dictionary] = []
	for area_id: String in area_ids:
		var needs: String = str(SubAreaDefs.area(area_id).get("requires_flag", ""))
		if needs != "" and not Session.flag(StringName(needs)):
			continue
		for gate: Dictionary in SubAreaDefs.gates(area_id):
			var gate_flag: String = str(gate.get("requires_flag", ""))
			if gate_flag != "" and not Session.flag(StringName(gate_flag)):
				continue
			var entry: Dictionary = gate.duplicate()
			entry["area"] = area_id
			list.append(entry)
	if list.is_empty():
		return null
	var node: SubAreaGates = SubAreaGates.new()
	node.name = "SubAreaGates"
	node.host = hub
	node.gates = list
	hub.add_child(node)
	return node


func _ready() -> void:
	for gate: Dictionary in gates:
		var pos: Vector3 = SubAreaMap.pos3(gate["pos"])
		var spec: Dictionary = {"kind": "arch", "size": [4.6, 3.8, 0.8], "color": str(gate.get("color", "#a89a80")), "accent": str(gate.get("accent", "#6a5a48")), "no_fade": true, "id": "gate"}
		# a gate may wear kit surfaces like any landmark (the Gainlands gates: bleached timber and brass; the locked one brick and iron)
		for key: String in ["surface", "surface_tint", "accent_surface"]:
			if gate.has(key):
				spec[key] = gate[key]
		var arch: Node3D = LandmarkKit.build(spec)
		add_child(arch)
		arch.position = pos
		arch.rotation_degrees.y = float(gate.get("yaw", 0.0))
		if is_locked(gate):
			# Closed for now (GC-11): a plank panel with crossed timbers fills the arch, no light pillar; the prompt says "coming soon" and E goes nowhere.
			add_child(_barrier(pos, float(gate.get("yaw", 0.0))))
		else:
			StyleBeacon.build(self, pos, Color(0.8, 0.9, 1.0), 5.0, 0.07)
		var icon_id: String = str(gate.get("icon", FALLBACK_ICON))
		var picture: MeshInstance3D = MeshInstance3D.new()
		picture.name = "GateIcon"
		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(1.5, 1.5)
		picture.mesh = quad
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_texture = IconArt.texture(icon_id if IconArt.has(icon_id) else FALLBACK_ICON, 128.0)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		material.no_depth_test = true
		material.albedo_color = Color(1, 1, 1, 0.0)
		material.set_meta(StyleToon.META_NO_TOON, true)
		picture.material_override = material
		picture.set_meta(StyleToon.META_NO_TOON, true)
		picture.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		picture.position = pos + Vector3(0.0, 4.6, 0.0)
		add_child(picture)
		_icons.append(picture)


func _hero() -> Node3D:
	return host.get("player") as Node3D


func _busy() -> bool:
	if bool(host.get("_locked")):
		return true
	var dialogue: Variant = host.get("dialogue")
	return dialogue != null and bool((dialogue as Object).get("active"))


func _process(_delta: float) -> void:
	var hero: Node3D = _hero()
	if hero == null:
		return
	var best: int = -1
	var best_distance: float = 1e9
	for index: int in range(gates.size()):
		var pos: Vector3 = SubAreaMap.pos3(gates[index]["pos"])
		var distance: float = Vector2(hero.position.x - pos.x, hero.position.z - pos.z).length()
		var alpha: float = clampf(1.0 - (distance - RADIUS) / 4.0, 0.0, 1.0)
		((_icons[index].material_override) as StandardMaterial3D).albedo_color.a = alpha
		if distance <= RADIUS and distance < best_distance:
			best = index
			best_distance = distance
	_near = -1 if _busy() else best
	_update_prompt()


## A gate marked `locked` in the data (Mount Swolympus, postponed to the postgame, GC-11): shown closed, never entered.
static func is_locked(gate: Dictionary) -> bool:
	return bool(gate.get("locked", false))


## The closed panel inside a locked arch: bleached planks with two crossed timbers and an iron band, in the same frame as the arch.
func _barrier(pos: Vector3, yaw: float) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("plank", EnvKit.material("GAIN-WALL-BLEACH" if EnvKit.has("GAIN-WALL-BLEACH") else "ENV-WALL-PLANK", false, Color(0.8, 0.72, 0.6)))
	mesh.set_material("iron", EnvKit.material("GAIN-WALL-IRON" if EnvKit.has("GAIN-WALL-IRON") else "ENV-WALL-FOUNDATION"))
	mesh.box("plank", Vector3(0, 1.5, 0), Vector3(3.4, 3.0, 0.22), Basis.IDENTITY, 0.02, 0.9)
	mesh.box("iron", Vector3(0, 2.9, 0.14), Vector3(3.5, 0.3, 0.1), Basis.IDENTITY, 0.0)
	for sign_dir: float in [-1.0, 1.0]:
		mesh.box("iron", Vector3(0, 1.5, 0.16), Vector3(0.34, 4.2, 0.14), Basis(Vector3(0, 0, 1), sign_dir * 0.72), 0.0)
	var panel: MeshInstance3D = mesh.instance("Barrier")
	panel.set_meta(PaintedClasses.META_NO_PAINT, true)
	var holder: Node3D = Node3D.new()
	holder.name = "GateBarrier"
	holder.add_child(panel)
	holder.position = pos
	holder.rotation_degrees.y = yaw
	return holder


## The gate's name shows in the HUD prompt (never as 3D lettering). The hub clears its own prompt only when its nearest spot changes, so this one is cleared here.
func _update_prompt() -> void:
	var hud: Object = host.get("hud") as Object
	if hud == null:
		return
	if _near >= 0:
		var gate: Dictionary = gates[_near]
		if is_locked(gate):
			hud.call("show_prompt", "[E]  %s" % str(gate.get("locked_prompt", "%s (coming soon)" % str(gate.get("label", "Onward")))))
		else:
			hud.call("show_prompt", "[E]  %s" % str(gate.get("label", "Onward")))
		_prompting = true
	elif _prompting:
		_prompting = false
		var hub_near: Variant = host.get("_near")
		if hub_near == null or (hub_near is int and int(hub_near) < 0):
			hud.call("hide_prompt")


func _unhandled_input(event: InputEvent) -> void:
	if _near < 0 or _busy():
		return
	if event is InputEventKey and event.is_action_pressed(&"interact") and not (event as InputEventKey).echo:
		get_viewport().set_input_as_handled()
		go(_near)


## Loads the sub-area behind gate `index` (also the entry point of tests). A locked gate only says so.
func go(index: int) -> void:
	var gate: Dictionary = gates[index]
	if is_locked(gate):
		Audio.sfx(&"ui_error")
		var hud: Object = host.get("hud") as Object
		if hud != null:
			hud.call("toast", str(gate.get("locked_text", "Coming soon.")), UIStyle.PARCHMENT)
		return
	Audio.sfx(&"door")
	Session.save_game()
	SubAreaScene.enter(str(gate["area"]), str(gate["sub"]), str(gate.get("id", "")))
