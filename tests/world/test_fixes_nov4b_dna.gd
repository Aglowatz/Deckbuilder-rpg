extends GutTest
## Fix pass Nov 4 (B), Part 3.2-3.3: the D.N.A. The elevators stand flush against the elevator bank's north wall, clear of the corridor to the executive
## floor; the lobby's west passage (gate -> breakroom doorway) is clear of props, at least 2 m wide.

var host: Node3D
var builder: DnaBuilder


func before_all() -> void:
	host = Node3D.new()
	add_child(host)
	builder = DnaBuilder.new()
	builder.build(host)
	DnaDressing.build(host, builder, 2)


func after_all() -> void:
	host.queue_free()


func test_the_elevators_are_flush_with_the_wall_and_clear_of_the_corridor() -> void:
	var elevators: Array[Node] = builder.root.find_children("*Elevator*", "Node3D", true, false)
	assert_gt(elevators.size(), 0, "the elevators are built (same-named siblings get renamed, so not all match by name)")
	for key: String in ["elevator_1", "elevator_2", "mini_dungeon", "elevator_4"]:
		var anchor: Vector3 = builder.layout.anchors[key] as Vector3
		assert_true(anchor.x + 1.05 <= 43.0 or anchor.x - 1.05 >= 47.0, "%s clear of the corridor" % key)
	for node: Node in elevators:
		var at: Vector3 = (node as Node3D).global_position
		assert_almost_eq(at.z, DnaLayout.ELEVATOR_WALL_Z, 0.01, "flush with the north wall")
		assert_true(at.x + 1.05 <= 43.0 or at.x - 1.05 >= 47.0, "clear of the corridor opening (x 43-47): %.2f" % at.x)
		assert_almost_eq(fposmod(at.x, 1.0), 0.0, 0.01, "on a whole pair of wall cells")


func test_the_lobby_west_passage_is_two_metres_wide_from_the_gate_to_the_breakroom() -> void:
	var lobby: Rect2 = Rect2(34.0, 46.0, 22.0, 14.0)
	var wide: Callable = func(pos: Vector3) -> bool: return lobby.has_point(Vector2(pos.x, pos.z)) and builder.is_walkable(pos, 1.0)
	var start: Vector3 = Vector3(46.5, 0.0, 57.5)
	assert_true(bool(wide.call(start)), "a 2 m body fits inside the gate")
	assert_eq(WalkProbe.unreachable(wide, start, lobby, {"breakroom_door": Vector3(36.2, 0.0, 53.0)}), [] as Array[String], "a 2 m wide way to the breakroom's doorway")
	var passage: Rect2 = DnaLayout.LOBBY_WEST_PASSAGE
	for z: float in [49.5, 51.0, 53.0, 55.5, 57.5]:
		assert_true(builder.is_walkable(Vector3(passage.position.x + 2.4, 0.0, z), 0.9), "the west strip is clear at z %.1f" % z)
