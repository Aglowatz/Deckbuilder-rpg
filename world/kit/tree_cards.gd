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
	# The D.N.A. kit cards (DnaBuilder.CARD_KINDS): the plants sway, the posts, desks and cabinets stand still.
	"dna_plant": {"id": "DNA-PLANT-OFFICE", "size": Vector2(1.05, 1.8), "radius": 0.3, "plant": true},
	"dna_lily": {"id": "DNA-PLANT-LILY", "size": Vector2(0.68, 1.3), "radius": 0.2, "plant": true},
	"dna_topiary": {"id": "DNA-TREE-DEAD", "size": Vector2(1.26, 2.2), "radius": 0.4, "plant": true},
	"dna_lamp": {"id": "DNA-PROP-GHOSTLAMP", "size": Vector2(0.7, 2.6), "radius": 0.22, "prop": true},
	"dna_desk": {"id": "DNA-PROP-DESK", "size": Vector2(1.63, 1.3), "radius": 0.5, "prop": true},
	"dna_paper": {"id": "DNA-PROP-PAPER", "size": Vector2(1.35, 1.4), "radius": 0.35, "prop": true},
	"dna_stamp": {"id": "DNA-PROP-STAMP", "size": Vector2(0.89, 1.0), "radius": 0.3, "prop": true},
	"dna_rope": {"id": "DNA-PROP-ROPE", "size": Vector2(1.0, 1.0), "radius": 0.25, "prop": true},
	"dna_cabinet_1": {"id": "DNA-SHEET-CABINETS-01", "size": Vector2(0.77, 1.6), "radius": 0.3, "prop": true},
	"dna_cabinet_2": {"id": "DNA-SHEET-CABINETS-02", "size": Vector2(1.56, 1.3), "radius": 0.5, "prop": true},
	"dna_cabinet_3": {"id": "DNA-SHEET-CABINETS-03", "size": Vector2(0.92, 1.6), "radius": 0.3, "prop": true},
	"dna_cabinet_4": {"id": "DNA-SHEET-CABINETS-04", "size": Vector2(1.52, 1.3), "radius": 0.5, "prop": true},
	"dna_cabinet_5": {"id": "DNA-SHEET-CABINETS-05", "size": Vector2(0.83, 1.4), "radius": 0.3, "prop": true},
	"dna_cabinet_6": {"id": "DNA-SHEET-CABINETS-06", "size": Vector2(1.02, 1.2), "radius": 0.35, "prop": true},
	# The Endless Buffet kit cards (docs/art/buffet_slice.md): broccoli and cauliflower trees, herb and leek plants, the painted props.
	"buff_broccoli": {"id": "BUFF-TREE-BROCCOLI", "size": Vector2(4.55, 5.5), "radius": 0.4},
	"buff_cauli": {"id": "BUFF-TREE-CAULI", "size": Vector2(3.9, 4.8), "radius": 0.4},
	"buff_herb": {"id": "BUFF-PLANT-HERB", "size": Vector2(1.27, 1.3), "radius": 0.0, "plant": true},
	"buff_leek": {"id": "BUFF-PLANT-LEEK", "size": Vector2(1.26, 2.1), "radius": 0.2, "plant": true},
	"buff_cloche": {"id": "BUFF-PROP-CLOCHE", "size": Vector2(1.25, 1.0), "radius": 0.45, "prop": true},
	"buff_pot": {"id": "BUFF-PROP-POT", "size": Vector2(1.65, 1.6), "radius": 0.6, "prop": true},
	"buff_cutlery": {"id": "BUFF-PROP-CUTLERY", "size": Vector2(1.62, 3.4), "radius": 0.35, "prop": true},
	"buff_flour": {"id": "BUFF-PROP-FLOUR", "size": Vector2(1.28, 1.2), "radius": 0.5, "prop": true},
	"buff_cakestand": {"id": "BUFF-PROP-CAKESTAND", "size": Vector2(1.15, 1.4), "radius": 0.4, "prop": true},
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
