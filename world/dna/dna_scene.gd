class_name DnaScene
extends ZoneScene
## The playable D.N.A. (Department of Necrotic Affairs): the Necrocrat zone. The shared zone
## framework (`ZoneScene`) provides the hub, HP rules, enemies, chests, quiz/minigame/puzzle
## launchers and the minimap; this subclass only adds what is unique to the office complex: the cold
## green look, the flickering tube lights (a pooled-light system) and the four office interactables.

const LIGHT_POOL: int = 8

## The layout (typed access to the D.N.A.'s own builder).
var dna: DnaBuilder
var _light_pool: Array[OmniLight3D] = []
var _light_groups: Array[int] = []
var _light_timer: float = 0.0


func _zone_id() -> String:
	return DnaZone.ID


func _make_map() -> ZoneMap:
	dna = DnaBuilder.new()
	return dna


func _build_environment() -> void:
	add_child(DnaLook.environment())
	add_child(DnaLook.moonlight())


func _build_zone_extras() -> void:
	_build_lights()
	# Arriving on the approach causeway (DN-6): the hero faces the gate so the zone opens up ahead; the walk-off exit arms once they have been inside.
	if DnaLayout.on_approach(player.position.x, player.position.z):
		player.face(player.position + Vector3(0.0, 0.0, -2.0))
		_exit_armed = false


func _grade_enemy(model: Node3D) -> void:
	DnaMaterials.grade_node(model, 0.4)


func _make_puzzle_screen() -> OverlayScreen:
	return TubePuzzleScreen.new()


func _make_minigame_screen() -> OverlayScreen:
	return MatchGameScreen.new()


func _interact_zone(spot: ZoneSpot) -> void:
	match spot.id:
		"coffee":
			DnaInteractables.coffee(self)
		"time_clock":
			DnaInteractables.time_clock(self)
		"printer":
			DnaInteractables.printer(self)
		"suggestion":
			DnaInteractables.suggestion_box(self)


func _zone_process(delta: float) -> void:
	_update_flicker()
	DnaMaterials.set_hero_pos(player.position)
	_update_causeway_exit()
	_light_timer -= delta
	if _light_timer <= 0.0:
		_light_timer = 0.25
		_assign_lights()


# ---- Lighting: flicker and the pooled lights --------------------------------------------------


func _build_lights() -> void:
	for i: int in range(LIGHT_POOL):
		var light: OmniLight3D = OmniLight3D.new()
		light.omni_range = 8.5
		light.light_energy = 0.0
		light.light_color = Color(0.7, 1.0, 0.82)
		light.shadow_enabled = false
		light.omni_attenuation = 1.3
		add_child(light)
		_light_pool.append(light)
		_light_groups.append(0)
	_assign_lights()


func _flicker(group: int) -> float:
	match group:
		1:
			var slot: float = floorf(_time * 11.0)
			var r: float = fposmod(sin(slot * 12.9898 + 4.1) * 43758.5453, 1.0)
			return 0.1 if r > 0.94 else (0.55 if r > 0.9 else 1.0)
		2:
			var cut: float = fposmod(_time * 0.21 + 0.37, 1.0)
			return 0.0 if cut < 0.025 else 0.9 + 0.1 * sin(_time * 53.0)
		3:
			var slot3: float = floorf(_time * 6.0)
			var r3: float = fposmod(sin(slot3 * 78.233 + 1.7) * 12345.6789, 1.0)
			return 0.35 if r3 > 0.86 else 0.92 + 0.08 * sin(_time * 31.0)
	return 1.0


func _update_flicker() -> void:
	for entry: Variant in DnaMaterials.glow_materials():
		var glow: ShaderMaterial = entry as ShaderMaterial
		glow.set_shader_parameter("energy", _flicker(int(glow.get_meta("group", 0))))
	for i: int in range(_light_pool.size()):
		var light: OmniLight3D = _light_pool[i]
		light.light_energy = lerpf(light.light_energy, 2.6 * _flicker(_light_groups[i]) * float(int(light.get_meta("on", 0))), 0.5)


## Moves the pooled lights onto the nearest tube fixtures around the player.
func _assign_lights() -> void:
	var fixtures: Array[DnaLayout.LightSpot] = dna.layout.lights.duplicate()
	var here: Vector3 = player.position
	fixtures.sort_custom(func(a: DnaLayout.LightSpot, b: DnaLayout.LightSpot) -> bool:
		return a.pos.distance_squared_to(here) < b.pos.distance_squared_to(here))
	for i: int in range(_light_pool.size()):
		var light: OmniLight3D = _light_pool[i]
		if i < fixtures.size() and fixtures[i].pos.distance_to(here) < 16.0:
			var fixture: DnaLayout.LightSpot = fixtures[i]
			light.position = fixture.pos - Vector3(0, 0.3, 0)
			light.light_color = fixture.color
			_light_groups[i] = fixture.group
			light.set_meta("on", 1)
		else:
			light.set_meta("on", 0)


## The way out is walked (DN-6): the causeway's last metre leaves for town by itself (the E spot on it still asks). It arms only once the hero has been
## well inside the zone, so the arrival itself or a screenshot teleport onto the end never trips it.
const EXIT_ARM_Z: float = 62.0
var _exit_armed: bool = false


func _update_causeway_exit() -> void:
	if _locked or dialogue.active or _fainting:
		return
	var pos: Vector3 = player.position
	if not DnaLayout.on_approach(pos.x, pos.z):
		if pos.z < EXIT_ARM_Z:
			_exit_armed = true
		return
	if pos.z < EXIT_ARM_Z:
		_exit_armed = true
	elif _exit_armed and pos.z > DnaLayout.EXIT_EDGE_Z:
		_exit_armed = false
		_locked = true
		player.input_enabled = false
		Audio.sfx(&"door")
		Session.leave_zone()


## No generic furniture scatter in the D.N.A. (DN-5): the hub is dressed by its layout and DnaDressing only.
func _dress_zone() -> void:
	pass


## The D.N.A. keeps its colour for the things that matter: the Rift Express beams crimson-red.
func _station_beacon_color() -> Color:
	return Color(1.0, 0.3, 0.2)
