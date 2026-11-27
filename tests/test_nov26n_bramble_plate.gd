extends GutTest
## Nov 26 night (Part A): the Dump's entrance bridge bunting is lifted about half a metre so it no longer hides Brother Bramble's name plate
## from the low camera (the NPC visibility probe saw the line lens (y 2.8) -> plate cross the bunting at y 2.1..3.3).

const LOW_LENS_Y: float = 2.8


func test_bunting_hangs_above_the_low_camera_sight_line() -> void:
	var bridge: Node3D = HeapLandmarks.entrance_bridge(10.0, 4.0)
	autofree(bridge)
	var bunting: MeshInstance3D = bridge.get_node_or_null("Bunting") as MeshInstance3D
	assert_not_null(bunting, "the bunting is its own mesh")
	if bunting == null:
		return
	var box: AABB = bunting.transform * bunting.get_aabb()
	assert_gt(box.position.y, LOW_LENS_Y, "the lowest pennant hangs above the low camera's height (was 2.1)")


func test_gate_is_taller_than_before() -> void:
	assert_almost_eq(HeapLandmarks.BRIDGE_GATE_H, 4.0, 0.001, "the gate posts rose 0.6 m with the bunting")
	assert_lt(HeapLandmarks.BRIDGE_BUNTING_SAG, 0.7, "the rope sags less than before")
