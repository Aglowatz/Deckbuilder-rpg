extends GutTest
## Fable Nov 12c (A8): the Crease is an enclosed cavern (no sky, no black doorways), its people stand clear of the props, one quest leads
## every player to it, and the HUD shows one "Services restored" bar.

var layout: CapitalLayout
var holder: Node3D
var crease: CapitalCrease


func before_all() -> void:
	layout = CapitalLayout.new()
	layout.build()
	holder = Node3D.new()
	add_child(holder)
	crease = CapitalCrease.build(holder)


func after_all() -> void:
	holder.free()
	Session.new_game()


func _props_of(kind: String) -> Array[CapitalLayout.Prop]:
	var found: Array[CapitalLayout.Prop] = []
	for prop: CapitalLayout.Prop in layout.props:
		if prop.kind == kind:
			found.append(prop)
	return found


func test_the_shell_closes_every_side_the_camera_can_see() -> void:
	for piece: String in ["WallNorth", "WallWest", "WallEast", "Ceiling", "FloorSouth", "Spikes", "Puddles"]:
		var node: MeshInstance3D = crease.root.get_node_or_null(piece) as MeshInstance3D
		assert_not_null(node, "%s is built" % piece)
		if node != null:
			assert_not_null(node.get_active_material(0), "%s has its material" % piece)
			assert_true(node.has_meta(&"no_occlusion_fade"), "%s never fades for the camera" % piece)
	var ceiling: AABB = (crease.root.get_node("Ceiling") as MeshInstance3D).get_aabb()
	var hall: Rect2 = CapitalCrease.HALL
	assert_lt(ceiling.position.x, hall.position.x - 4.0, "the ceiling runs past the west wall")
	assert_gt(ceiling.end.x, hall.end.x + 4.0, "and past the east wall")
	assert_lt(ceiling.position.z, hall.position.y)
	# the camera trails up to 16 m south of the hero and rides under 6 m: the roof is over it wherever the hero stands
	assert_gt(ceiling.end.z, hall.end.y + 18.0, "the ceiling runs on south over the camera")
	assert_gt(ceiling.position.y, 6.6, "over the default camera's height")
	for side: String in ["WallWest", "WallEast"]:
		var wall: AABB = (crease.root.get_node(side) as MeshInstance3D).get_aabb()
		assert_gt(wall.end.z, hall.end.y + 18.0, "%s runs on south past the camera" % side)
		assert_gt(wall.end.y, CapitalCrease.CEILING_Y, "%s reaches the ceiling" % side)
	var south: AABB = (crease.root.get_node("FloorSouth") as MeshInstance3D).get_aabb()
	assert_gt(south.end.z, hall.end.y + 18.0, "rock floor under the camera's view south of the hall")
	assert_gt(south.position.y, -0.03, "over the far apron (-0.03), or the grey apron would show instead")


func test_stalactites_hang_clear_of_the_lens() -> void:
	assert_gt(crease.stalactites, 40)
	assert_gt(crease.stalagmites, 20)
	assert_gt(crease.lowest_tip, 6.2, "over the camera's corridor no tip comes down to the lens (5.7 m)")


func test_warm_pools_and_cool_glows() -> void:
	var warm: int = 0
	var cool: int = 0
	for light: OmniLight3D in crease.lights:
		assert_false(light.shadow_enabled)
		if light.light_color.r > light.light_color.b:
			warm += 1
		else:
			cool += 1
	assert_gte(warm, 8, "lantern pools")
	assert_between(cool, 3, 6, "a few crystal glows")
	for lantern: Vector3 in CapitalCrease.LANTERNS:
		assert_lt(lantern.y, 140.0, "chained lanterns only along the north side (one in the middle dangles in front of the camera)")
	assert_eq(crease.root.find_children("Drip*", "CPUParticles3D", true, false).size(), CapitalCrease.DRIPS.size(), "dripping stalactites")


func test_no_black_doorways() -> void:
	assert_eq(_props_of("shaft_door").size(), 0, "the free-standing shaft doorways are gone")
	assert_eq(_props_of("shaft_hatch").size(), CapitalLayout.NETWORK_DESTINATIONS.size(), "each shaft is a hatch in the floor")
	for destination: String in CapitalLayout.NETWORK_DESTINATIONS:
		assert_true(layout.anchors.has("shaft_" + destination), "the %s shaft is still there to use" % destination)
	var arch: Array[CapitalLayout.Prop] = _props_of("tunnel_arch")
	assert_eq(arch.size(), 1)
	assert_gt(arch[0].pos.x, CapitalCrease.EAST_X - 1.2, "the mouth of the tunnel is set into the east rock wall, not free-standing")
	var ladder: Array[CapitalLayout.Prop] = _props_of("ladder")
	assert_lt(ladder[0].pos.x, CapitalCrease.WEST_X + 2.2, "the ladder stands against the west rock wall")
	for anchor: String in ["rift_station", "ladder_up", "tunnel_out", "crease_spawn"]:
		var at: Vector3 = layout.anchors[anchor] as Vector3
		assert_true(CapitalCrease.HALL.has_point(Vector2(at.x, at.z)), "%s is inside the hall" % anchor)
		assert_eq(layout.cell_at(int(floorf(at.x)), int(floorf(at.z))), CapitalLayout.Cell.GROUND, "%s stands on walkable floor" % anchor)


func test_everyone_stands_clear_of_the_props() -> void:
	for id: String in ["wren", "fig", "heal", "rift_station"]:
		var at: Vector3 = layout.anchors[id] as Vector3
		for prop: CapitalLayout.Prop in layout.props:
			if prop.pos.z < float(CapitalLayout.CREASE_Z0) or prop.kind in ["shaft_hatch", "crease_column", "map_table"]:
				continue
			var dx: float = absf(prop.pos.x - at.x)
			var south: float = prop.pos.z - at.z
			# nothing between the camera (south) and the person within reach of the sight line
			assert_false(dx < 1.1 and south > 0.4 and south < 4.0, "%s: a %s stands in front (%.1f m south, %.1f m aside)" % [id, prop.kind, south, dx])


func test_the_market_has_stalls_and_crates() -> void:
	assert_gte(_props_of("crease_stall").size(), 2)
	assert_gte(_props_of("crease_crate").size(), 5)


func test_one_quest_leads_to_the_crease_and_its_market() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.UNDER_CAPITAL)
	assert_not_null(quest)
	assert_true(quest.is_main(), "a main quest: it is not a side favour to overlook")
	assert_eq(quest.objectives.size(), 3)
	for objective: QuestObjective in quest.objectives:
		assert_eq(objective.target_kind, QuestObjective.TargetKind.SPOT, "%s has a pin" % objective.text)
		assert_eq(objective.target_area, CapitalZone.ID)
		assert_gt(objective.hint.length(), 40, "%s says where to go" % objective.text)
	assert_string_contains(quest.objectives[0].hint, "great gate")
	assert_string_contains(quest.objectives[1].hint, "Gate Plaza just inside")
	assert_string_contains(quest.objectives[2].hint, "north-east side of the Crease")
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	assert_true(Session.start_quest(QuestDefinitions.UNDER_CAPITAL, false))
	assert_true(Session.quest_log.track(QuestDefinitions.UNDER_CAPITAL), "it can take the tracker")
	assert_eq(Session.quest_log.current_index(quest, Session.unlock_state()), 0)
	Session.set_flag(CapitalZone.FLAG_INSIDE)
	assert_eq(Session.quest_log.current_index(quest, Session.unlock_state()), 1, "inside the wall: the manhole is next")
	Session.set_flag(CapitalZone.FLAG_HUB_KNOWN)
	assert_eq(Session.quest_log.current_index(quest, Session.unlock_state()), 2, "in the Crease: the Black Market is next")
	Session.set_flag(StringName(QuestDefinitions.FLAG_BLACK_MARKET_SEEN))
	Session.refresh_quests()
	assert_true(Session.quest_log.is_completed(QuestDefinitions.UNDER_CAPITAL), "done once the Black Market has been browsed")


func test_the_capital_starts_the_quest_and_shows_one_services_bar() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/capital/capital_scene.gd")
	assert_true(source.contains("Session.start_quest(QuestDefinitions.UNDER_CAPITAL, true)"), "started on first arrival")
	assert_true(source.contains("Session.quest_log.track(QuestDefinitions.UNDER_CAPITAL)"), "and tracked")
	assert_true(source.contains("for old: Node in hud.find_children(SERVICE_CHIP_NAME"), "the old services bar is removed before a new one is added")
	var chips: Control = Control.new()
	add_child_autofree(chips)
	for _again: int in range(3):
		for old: Node in chips.find_children(CapitalScene.SERVICE_CHIP_NAME + "*", "HudChip", true, false):
			old.get_parent().remove_child(old)
			old.queue_free()
		chips.add_child(HudChip.wrap("capital_services", "Services restored: 0 of 4", Color.WHITE, Control.new()))
	assert_eq(chips.find_children(CapitalScene.SERVICE_CHIP_NAME + "*", "HudChip", true, false).size(), 1, "three refreshes, one bar")
