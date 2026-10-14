class_name TreeCards
extends RefCounted
## Trees as painted cards (ENV-TREE-OAK / FRUIT / PINE / BIRCH, vertical slice Part B): one camera-facing, gently swaying card per tree with a soft shadow, instead of the old
## KayKit cones. Sizes are metres (width x height) and follow the paint-over: a tree stands about three heroes tall.

const KINDS: Dictionary = {
	"oak": {"id": "ENV-TREE-OAK", "size": Vector2(5.3, 5.4), "radius": 0.35},
	"fruit": {"id": "ENV-TREE-FRUIT", "size": Vector2(3.9, 4.4), "radius": 0.3},
	"pine": {"id": "ENV-TREE-PINE", "size": Vector2(3.7, 6.6), "radius": 0.3},
	"birch": {"id": "ENV-TREE-BIRCH", "size": Vector2(3.3, 5.7), "radius": 0.25},
	# Zone kit plants (data/art/zone_kits/*.json): the Gainlands sunflower clump, hay stack and sky tree.
	"sunflower": {"id": "GAIN-PLANT-SUNFLOWER", "size": Vector2(1.7, 2.1), "radius": 0.0, "plant": true},
	"hay": {"id": "GAIN-PLANT-HAY", "size": Vector2(2.4, 1.95), "radius": 0.6, "plant": true},
	"sky": {"id": "GAIN-TREE-SKY", "size": Vector2(5.2, 6.4), "radius": 0.4},
}


static func make(tree_name: String, scale_value: float = 1.0, shadow: bool = true) -> Node3D:
	if not KINDS.has(tree_name):
		return null
	var data: Dictionary = KINDS[tree_name] as Dictionary
	var root: Node3D = Node3D.new()
	root.name = "Tree_%s" % tree_name
	root.add_child(KitFoliage.card(str(data["id"]), (data["size"] as Vector2) * scale_value, shadow))
	root.set_meta("radius", float(data["radius"]) * scale_value)
	return root


static func names() -> Array[String]:
	var result: Array[String] = []
	for key: Variant in KINDS.keys():
		result.append(str(key))
	return result
