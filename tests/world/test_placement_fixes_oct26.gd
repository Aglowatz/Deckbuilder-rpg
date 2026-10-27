extends GutTest
## Fixes Oct 26, Part 6: the Gainlands power pipes join the three hamster wheels without crossing a walking path; the Buffet's Sous-Chef Tarragon
## and Rip stand on open ground clear of the Rift Express; the Capital's exit clerk stands beside his booth, not inside it.
## (The every-zone NPC overlap check is tools/npc_overlap_probe.gd: it needs the scenes running; results in docs/fixes_oct26.md.)


func test_the_power_pipes_join_the_wheels_and_never_cross_a_path() -> void:
	var layout: GainlandsLayout = GainlandsLayout.new()
	layout.build()
	var wheels: Array[Vector3] = []
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.kind == "wheel":
			wheels.append(Vector3(prop.pos.x, prop.pos.z, 4.2 * (1.0 if prop.variant == 0 else (0.85 if prop.variant == 1 else 0.75))))
	assert_eq(wheels.size(), 3, "three hamster wheels")
	var touched: Dictionary = {}
	for line: PackedVector2Array in layout.pipes:
		for i: int in range(line.size() - 1):
			for k: int in range(11):
				var p: Vector2 = line[i].lerp(line[i + 1], float(k) / 10.0)
				assert_gt(layout.path_edge_distance(p.x, p.y), GainlandsLayout.PIPE_PATH_GAP, "pipe point (%.1f, %.1f) stays off every path" % [p.x, p.y])
		for end: Vector2 in [line[0], line[line.size() - 1]]:
			for w: int in range(wheels.size()):
				# an end meets a wheel at its rim's foot: within a metre and a half of the rim's span
				var wheel: Vector3 = wheels[w]
				if absf(end.y - wheel.y) < 1.5 and absf(end.x - wheel.x) < wheel.z + 1.5:
					touched[w] = true
	assert_eq(touched.size(), 3, "every wheel is on the line (wheel to wheel)")


func test_tarragon_and_rip_stand_clear_of_the_rift_express() -> void:
	var layout: BuffetLayout = BuffetLayout.new()
	layout.build()
	var station: Vector3 = layout.anchors["rift_station"] as Vector3
	var tarragon: Vector3 = layout.anchors["tarragon"] as Vector3
	var scene: BuffetScene = BuffetScene.new()
	var rip: Vector3 = station + scene._rift_operator_offset()
	scene.free()
	assert_gt(Vector2(tarragon.x - station.x, tarragon.z - station.z).length(), 1.3 + 1.2, "Tarragon well off the station's 1.3 m footprint")
	assert_gt(Vector2(rip.x - station.x, rip.z - station.z).length(), 1.3 + 1.2, "Rip off the station's platform")
	assert_gt(Vector2(rip.x - tarragon.x, rip.z - tarragon.z).length(), 2.0, "the two keep apart")
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.layout.build()
	for at: Vector3 in [tarragon, rip]:
		for k: int in range(8):
			var angle: float = TAU * float(k) / 8.0
			assert_true(builder.is_walkable(at + Vector3(cos(angle), 0.0, sin(angle)) * 0.75, 0.2), "open ground round (%.1f, %.1f)" % [at.x, at.z])


func test_the_exit_clerk_stands_beside_his_booth() -> void:
	var entry: Dictionary = {}
	for npc: Dictionary in CapitalZone.build_def().npcs:
		if str(npc["id"]) == "exit_clerk":
			entry = npc
	assert_false(entry.is_empty())
	var offset: Vector3 = entry.get("offset", Vector3.ZERO) as Vector3
	assert_gt(Vector2(offset.x, offset.z).length(), 1.2, "out of the booth (he shares its anchor)")
	assert_eq(float(entry["yaw"]), 0.0, "facing the plaza")
