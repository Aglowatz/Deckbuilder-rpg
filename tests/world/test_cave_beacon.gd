extends GutTest
## Fresh eyes Oct 30: the forest's cave beacon - a QuestMarkerLayer with a fixed objective (no quest behind it) puts the chevron and the
## edge pointer on the gate, and the gate's map point is an objective (drawn through the fog, clamped to the minimap's edge).

const GATE: Vector3 = Vector3(10.4, 0.0, -19.4)


func before_each() -> void:
	Session.ensure_game()


func test_fixed_objective_marks_the_gate() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var camera: Camera3D = Camera3D.new()
	root.add_child(camera)
	var hud: Control = Control.new()
	root.add_child(hud)
	var layer: QuestMarkerLayer = QuestMarkerLayer.install(root, Areas.START, camera, func(_spot_id: String) -> Dictionary: return {}, hud)
	layer.set_fixed_objective({"pos": GATE, "top": 1.9})
	var at: Vector3 = layer.objective_position()
	assert_ne(at, Vector3.INF, "the objective marker is shown")
	assert_almost_eq(at.x, GATE.x, 0.01, "over the gate (x)")
	assert_almost_eq(at.z, GATE.z, 0.01, "over the gate (z)")
	assert_gt(at.y, GATE.y + 1.9, "floats above the gate's top")
	assert_true(layer.pointer.target_valid, "the HUD edge pointer has a target")
	assert_almost_eq(layer.pointer.target.x, GATE.x, 0.01, "the pointer aims at the gate")
	# A quest refresh (none exist in the forest) keeps the fixed objective.
	layer.refresh()
	assert_ne(layer.objective_position(), Vector3.INF, "the refresh keeps the fixed objective")
	layer.set_fixed_objective({})
	layer.refresh()
	assert_eq(layer.objective_position(), Vector3.INF, "cleared with an empty dictionary")


func test_objective_poi_shows_through_fog() -> void:
	var poi: MapPoi = MapPoi.make(MapPoi.Kind.DUNGEON, GATE, "Cave gate")
	var fog: FogOfWar = FogOfWar.for_bounds(Rect2(Vector2(-30, -30), Vector2(60, 60)))
	assert_eq(MapView.visible_pois([poi] as Array[MapPoi], fog).size(), 0, "a fogged point is hidden")
	poi.objective = true
	assert_eq(MapView.visible_pois([poi] as Array[MapPoi], fog).size(), 1, "the objective shows through the fog")
