extends GutTest
## Vertical slice, Part B: props, clusters, painted tree cards and flower clumps.


func test_every_prop_builds() -> void:
	for prop_name: String in PropKit.NAMES:
		var node: Node3D = PropKit.make(prop_name)
		assert_not_null(node, "%s builds" % prop_name)
		if node == null:
			continue
		add_child_autofree(node)
		var body: MeshInstance3D = node.get_child(0) as MeshInstance3D
		assert_not_null(body.mesh, "%s has a mesh" % prop_name)
		# a painted card prop (fence, signpost with art) is a few quads by design; geometry props are far more
		var card_prop: bool = (prop_name.begins_with("fence") or prop_name == "signpost") and EnvKit.has_art("ENV-PROP-FENCE")
		assert_gt(int(node.get_meta("triangles")), 0 if card_prop else 20, "%s is more than a primitive" % prop_name)
		assert_lt(int(node.get_meta("triangles")), 4000, "%s stays light" % prop_name)


func test_props_follow_the_scale_rule() -> void:
	var hero: float = 1.25
	var barrel: Node3D = PropKit.barrel()
	add_child_autofree(barrel)
	var barrel_h: float = (barrel.get_child(0) as MeshInstance3D).mesh.get_aabb().size.y
	assert_between(barrel_h / hero, 0.7, 1.0, "a barrel reaches the hero's chest")
	var post: Node3D = PropKit.lantern_post()
	add_child_autofree(post)
	var post_h: float = (post.get_child(0) as MeshInstance3D).mesh.get_aabb().size.y
	assert_gt(post_h / hero, 3.0, "a lantern post towers over the hero")
	var fence: Node3D = PropKit.fence(3.0, true)
	add_child_autofree(fence)
	var fence_h: float = (fence.get_child(0) as MeshInstance3D).mesh.get_aabb().size.y
	assert_between(fence_h / hero, 0.7, 1.1, "a fence is about hero height")


func test_lanterns_carry_real_lights() -> void:
	for prop_name: String in ["lantern_post", "banner_post", "hanging_lantern", "stall"]:
		var node: Node3D = PropKit.make(prop_name)
		add_child_autofree(node)
		var lights: Array = node.get_meta("lights") as Array
		assert_gt(lights.size(), 0, "%s has a warm light" % prop_name)
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var post: Node3D = PropKit.lantern_post()
	holder.add_child(post)
	post.position = Vector3(5, 0, 5)
	var created: Array[OmniLight3D] = KitLights.attach(holder, holder, null, false)
	assert_eq(created.size(), 1)
	assert_gt(created[0].global_position.y, 3.0, "the light sits up in the lantern")
	assert_almost_eq(created[0].global_position.x, 5.7, 0.05)


func test_every_cluster_builds_with_obstacles() -> void:
	for cluster_name: String in PropClusters.NAMES:
		var cluster: Node3D = PropClusters.make(cluster_name)
		assert_not_null(cluster, "%s builds" % cluster_name)
		if cluster == null:
			continue
		add_child_autofree(cluster)
		assert_gt(cluster.get_child_count(), 1, "%s has several pieces" % cluster_name)
		assert_true(cluster.has_meta("circles"))
		assert_gt(float(cluster.get_meta("length")), 1.0)


func test_cluster_pieces_stay_off_the_front_lane() -> void:
	for cluster_name: String in ["doorstep", "crates", "bench_nook", "fence_garden"]:
		var cluster: Node3D = PropClusters.make(cluster_name)
		add_child_autofree(cluster)
		for circle: Vector3 in cluster.get_meta("circles") as Array[Vector3]:
			assert_lt(circle.y + circle.z, float(cluster.get_meta("depth")) + 0.6, "%s keeps its front clear" % cluster_name)


func test_trees_are_cards_with_kit_slots() -> void:
	for tree_name: String in TreeCards.names():
		var tree: Node3D = TreeCards.make(tree_name)
		add_child_autofree(tree)
		var card: MeshInstance3D = tree.get_child(0) as MeshInstance3D
		assert_true(card.material_override is ShaderMaterial, "%s is a painted card" % tree_name)
		var data: Dictionary = TreeCards.KINDS[tree_name] as Dictionary
		var small: bool = bool(data.get("plant", false)) or bool(data.get("prop", false))  # plants and the D.N.A. prop cards are hero-sized; trees stand three heroes tall
		assert_gt(card.scale.y, 0.9 if small else 3.0, "%s stands tall" % tree_name)
		var texture: Texture2D = (card.material_override as ShaderMaterial).get_shader_parameter("card_tex") as Texture2D
		assert_not_null(texture, "%s has its placeholder painting" % tree_name)


func test_clumps_are_irregular_and_bounded() -> void:
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var entries: Array[Dictionary] = [{"pos": Vector3(3, 0, 3), "radius": 1.0, "count": 12, "cells": [2, 3, 0]}]
	var clump: MultiMeshInstance3D = KitFoliage.clumps(holder, entries, 5)
	assert_not_null(clump)
	assert_eq(clump.multimesh.instance_count, 12)
	var points: Array[Vector3] = clump.get_meta("points") as Array[Vector3]
	var heights: Array[float] = clump.get_meta("heights") as Array[float]
	assert_eq(points.size(), 12)
	var scales: Dictionary = {}
	for index: int in range(12):
		assert_lte(Vector2(points[index].x - 3.0, points[index].z - 3.0).length(), 1.01)
		scales[snappedf(heights[index], 0.01)] = true
	assert_gt(scales.size(), 4, "plant heights vary")
