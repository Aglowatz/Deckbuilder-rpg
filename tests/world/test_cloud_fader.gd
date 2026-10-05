extends GutTest
## Clouds fade out when they sit between the camera and the hero, and stay solid when they do not.


func test_cloud_between_camera_and_hero_fades() -> void:
	var camera: Vector3 = Vector3(0, 16, 12)
	var hero: Vector3 = Vector3(0, 0.6, 0)
	assert_lt(CloudFader.target_alpha(camera, hero, Vector3(0, 8, 6), 3.0), 0.1, "right on the line of sight")
	assert_lt(CloudFader.target_alpha(camera, hero, camera + Vector3(0, 1, 0), 3.0), 0.1, "next to the camera")


func test_far_or_high_clouds_stay_visible() -> void:
	var camera: Vector3 = Vector3(0, 16, 12)
	var hero: Vector3 = Vector3(0, 0.6, 0)
	assert_gt(CloudFader.target_alpha(camera, hero, Vector3(40, 26, -30), 3.0), 0.9, "far to the side")
	assert_gt(CloudFader.target_alpha(camera, hero, Vector3(0, 40, 0), 3.0), 0.9, "high above the hero")


func test_adopt_makes_clouds_translucent_and_unconverted() -> void:
	var fader: CloudFader = CloudFader.new()
	add_child_autofree(fader)
	var cloud: Node3D = ModelKit.nature("cloud_small")
	add_child_autofree(cloud)
	fader.adopt(cloud, 3.0)
	assert_eq(fader.cloud_count(), 1)
	for node: Node in cloud.find_children("*", "MeshInstance3D", true, false):
		var material: StandardMaterial3D = (node as MeshInstance3D).material_override as StandardMaterial3D
		assert_eq(material.transparency, BaseMaterial3D.TRANSPARENCY_ALPHA)
		assert_true(node.has_meta(StyleToon.META_NO_TOON))
