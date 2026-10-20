class_name OldWellSpot
extends RefCounted
## Overnight Oct 19-20, Part 6: the world side of the Old Well secret quest. In the Verdant Dump and the Endless Buffet a faint hum (a small
## cyan light and a few rising motes, no marker, no plate, no words) stands at `OldWellQuest.SPOTS` while that step is open; walking up shows the
## prompt, using it plays the find (narration) and records the step. `play` chains beats with different speakers through one DialogueBox
## (the town's vision, the Echo's lines and the final reveal use it too).

const GLOW_NAME: String = "OldWellHum"
const GLOW_COLOR: Color = Color("7fe0ff")
const SPOT_ID: String = "old_well_hum"


## Builds `zone_id`'s hum in `scene` when the quest is at that step; nothing otherwise (the secret stays invisible). A screenshot can force it
## (`--oldwell`, e.g. `bash tools/shot.sh res://scenes/heap_zone.tscn hum --oldwell --pos=20.6,35.5`).
static func build(scene: ZoneScene, zone_id: String) -> void:
	if not OldWellQuest.is_task_zone(zone_id):
		return
	if not Session.old_well_task_open(zone_id) and not scene._screenshot_args.has("oldwell"):
		return
	var pos: Vector3 = OldWellQuest.spot_for(zone_id)
	pos.y = scene.builder.height_at(pos)
	var glow: Node3D = make_glow()
	glow.name = GLOW_NAME
	scene.add_child(glow)
	glow.position = pos
	start_pulse(glow)
	scene._add_spot(SPOT_ID, "", pos, OldWellQuest.SPOT_RADIUS, OldWellStory.shared().text("prompt.%s" % zone_id), false, OldWellQuest.SPOT_KIND,
		{"hidden": true, "zone": zone_id})


## The faint hum: a weak light a little above the ground, a thin film of water on the ground and a few motes rising (the Old Well's own look, smaller).
static func make_glow() -> Node3D:
	var root: Node3D = Node3D.new()
	var light: OmniLight3D = OmniLight3D.new()
	light.name = "Light"
	light.light_color = GLOW_COLOR
	light.light_energy = 0.8
	light.omni_range = 2.6
	light.shadow_enabled = false
	light.position = Vector3(0.0, 0.7, 0.0)
	root.add_child(light)
	var film: MeshInstance3D = MeshInstance3D.new()
	film.name = "Film"
	var disc: CylinderMesh = CylinderMesh.new()
	disc.top_radius = 0.42
	disc.bottom_radius = 0.42
	disc.height = 0.02
	disc.radial_segments = 20
	var water: StandardMaterial3D = StandardMaterial3D.new()
	water.albedo_color = Color(0.5, 0.88, 1.0, 0.45)
	water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water.emission_enabled = true
	water.emission = GLOW_COLOR
	water.emission_energy_multiplier = 0.9
	water.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	disc.material = water
	film.mesh = disc
	film.position = Vector3(0.0, 0.04, 0.0)
	root.add_child(film)
	var motes: CPUParticles3D = CPUParticles3D.new()
	motes.name = "Motes"
	motes.amount = 10
	motes.lifetime = 2.4
	motes.direction = Vector3.UP
	motes.spread = 20.0
	motes.initial_velocity_min = 0.25
	motes.initial_velocity_max = 0.55
	motes.gravity = Vector3.ZERO
	motes.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	motes.emission_sphere_radius = 0.3
	var mote: SphereMesh = SphereMesh.new()
	mote.radius = 0.03
	mote.height = 0.06
	var glow_material: StandardMaterial3D = StandardMaterial3D.new()
	glow_material.albedo_color = Color("aef0ff")
	glow_material.emission_enabled = true
	glow_material.emission = GLOW_COLOR
	glow_material.emission_energy_multiplier = 2.4
	glow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mote.material = glow_material
	motes.mesh = mote
	motes.position = Vector3(0.0, 0.2, 0.0)
	root.add_child(motes)
	return root


## A slow breathing pulse on the light (the node must be in the tree).
static func start_pulse(glow: Node3D) -> void:
	var light: OmniLight3D = glow.get_node_or_null("Light") as OmniLight3D
	if light == null or not glow.is_inside_tree():
		return
	var tween: Tween = glow.create_tween().set_loops()
	tween.tween_property(light, "light_energy", 1.15, 1.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(light, "light_energy", 0.55, 1.8).set_trans(Tween.TRANS_SINE)


## Using the hum: the find's narration, the step recorded (first, so a closed game mid-dialogue keeps it), the spot gone, the light fading out.
static func use(scene: ZoneScene, spot: ZoneSpot) -> void:
	var zone_id: String = str(spot.data.get("zone", ""))
	scene.player.face(spot.position)
	scene.spots.erase(spot)
	if spot.marker != null:
		spot.marker.queue_free()
	if spot.plate != null:
		spot.plate.queue_free()
	if not Session.find_old_well_hum(zone_id):
		return
	Audio.sfx(&"ui_confirm", -4.0)
	var story: OldWellStory = OldWellStory.shared()
	var both: bool = OldWellQuest.tasks_found(Session.flags) >= OldWellQuest.ZONE_FLAGS.size()
	var beats: Array[OldWellStory.Beat] = story.get_beats("find.%s" % zone_id)
	beats.append_array(story.get_beats("find.both" if both else "find.one"))
	play(scene.dialogue, beats, func() -> void:
		scene.hud.toast(story.text("toast.both" if both else "toast.found"), Color("aef0ff")))
	fade_out(scene.get_node_or_null(GLOW_NAME) as Node3D)


static func fade_out(glow: Node3D) -> void:
	if glow == null or not glow.is_inside_tree():
		return
	var motes: CPUParticles3D = glow.get_node_or_null("Motes") as CPUParticles3D
	if motes != null:
		motes.emitting = false
	var light: OmniLight3D = glow.get_node_or_null("Light") as OmniLight3D
	var tween: Tween = glow.create_tween()
	if light != null:
		tween.tween_property(light, "light_energy", 0.0, 2.5)
	tween.tween_callback(glow.queue_free)


## Plays `beats` one after another in `dialogue` (each beat its own speaker), then calls `then`.
static func play(dialogue: DialogueBox, beats: Array[OldWellStory.Beat], then: Callable = Callable()) -> void:
	if beats.is_empty():
		if then.is_valid():
			then.call()
		return
	var first: OldWellStory.Beat = beats[0]
	var rest: Array[OldWellStory.Beat] = []
	for index: int in range(1, beats.size()):
		rest.append(beats[index])
	dialogue.start(first.speaker, first.lines)
	dialogue.finished.connect(func() -> void: play(dialogue, rest, then), CONNECT_ONE_SHOT)
