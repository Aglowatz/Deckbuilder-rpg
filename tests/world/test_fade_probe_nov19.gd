extends GutTest
## Fable Nov 19 (Part 1): the fade probe. Builds every place (Crosspath, the Opening Forest, the Gainlands, the Buffet, the Dump, the
## D.N.A., the Capital with the Crease), lists every thing the occlusion fader knows with its type and rule, walks the hero over every
## walkable cell at the default and the Low camera, and fails if a low blocker, a small prop or a sign can fade anywhere.
## The full scenes (with their dressing and people) are swept the same way by `bash tools/run_fade_probe.sh`.

const STEP: float = 3.0


func _sweep(place: String, map: Object, root: Node3D) -> void:
	var camera: Camera3D = Camera3D.new()
	root.add_child(camera)
	var hero: Node3D = Node3D.new()
	root.add_child(hero)
	var fader: OcclusionFader = OcclusionFader.new()
	fader.camera = camera
	fader.hero = hero
	fader.root = root
	fader.set_process(false)
	root.add_child(fader)
	fader.scan_now()
	var counts: Dictionary = {}
	for row: Dictionary in fader.catalogue():
		counts[row["type"]] = int(counts.get(row["type"], 0)) + 1
		if str(row["type"]) != str(OcclusionFader.TALL_OCCLUDER):
			assert_false(bool(row["can_fade"]), "%s: %s (%s) can fade" % [place, str(row["name"]), str(row["type"])])
	var keep_angle: int = Settings.camera_angle
	var cells: int = 0
	var faded: Dictionary = {}
	var offenders: Dictionary = {}
	for angle: int in [0, 3]:
		Settings.camera_angle = angle
		var arm: Vector3 = CameraRig.shape(WorldLookRig.base_offset())
		var x: float = -60.0
		while x < 261.0:
			var z: float = -60.0
			while z < 261.0:
				var at: Vector3 = Vector3(x + 0.5, 0.0, z + 0.5)
				z += STEP
				if not bool(map.call("is_walkable", at)):
					continue
				if map.has_method("height_at"):
					at.y = float(map.call("height_at", at))
				cells += 1
				hero.position = at
				camera.position = at + arm
				for entry: Dictionary in fader.verdict_now(true):
					faded[entry["name"]] = true
					var size: Vector3 = entry["size"] as Vector3
					# checked here on the box of the piece itself, not by the word of the fader
					if str(entry["kind"]) != str(OcclusionFader.TALL_OCCLUDER) or size.y < OcclusionFader.SHOULDER or str(entry["name"]).to_lower().contains("signpost"):
						offenders["%s/%s %s %s" % [str(entry["name"]), str(entry["piece"]), str(entry["kind"]), str(size.snapped(Vector3(0.1, 0.1, 0.1)))]] = true
			x += STEP
	Settings.camera_angle = keep_angle
	gut.p("%s: %d things known %s; %d cells x 2 cameras; %d can go see-through" % [place, fader.catalogue().size(), str(counts), cells / 2, faded.size()])
	assert_gt(cells, 20, "%s was walked" % place)
	assert_eq(offenders.keys(), [], "%s: a low blocker, a small prop or a sign can fade" % place)


func _zone(place: String, builder: Object) -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	builder.call("build", root)
	_sweep(place, builder, root)


func test_crosspath() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var town: TownBuilder = TownBuilder.new()
	town.build(root)
	TownSquare.build(root, town, GraphicsQuality.Level.MEDIUM)
	_sweep("Crosspath", town, root)


func test_the_opening_forest() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var area: StartingAreaBuilder = StartingAreaBuilder.new()
	area.build(root)
	_sweep("Opening Forest", area, root)


func test_the_gainlands() -> void:
	_zone("Gainlands", GainlandsBuilder.new())


func test_the_buffet() -> void:
	_zone("Buffet", BuffetBuilder.new())


func test_the_dump() -> void:
	_zone("Dump", HeapBuilder.new())


func test_the_dna() -> void:
	_zone("D.N.A.", DnaBuilder.new())


func test_the_capital_and_the_crease() -> void:
	_zone("Capital", CapitalBuilder.new())
