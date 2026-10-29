extends GutTest
## The D.N.A. slice, Part A (docs/art/dna_slice.md): the imported zone kit resolves through EnvKit, the sliced cabinets are ground props (not wall plaques), the painted
## texture aliases resolve, the four hero landmarks build from their concepts to the sizes in the sub-area data, and the mood carries the overcast sky panorama and the
## tower skyline cards.

const ZonePrep: GDScript = preload("res://tools/zone_kit_prep.gd")
const SHEET_IDS: Array[String] = [
	"DNA-HERO-FINAL-APPROVALS", "DNA-HERO-FILING-TOWER", "DNA-HERO-ENDLESS-QUEUE", "DNA-HERO-RECORDS-STAIR", "DNA-WALL-GREY", "DNA-ROOF-SLATE", "DNA-PATH-QUEUE",
	"DNA-TRIM-BRASS", "DNA-SHEET-DOORS", "DNA-SHEET-WINDOWS", "DNA-SHEET-SIGNS", "DNA-SHEET-CABINETS", "DNA-PLANT-OFFICE", "DNA-PLANT-LILY", "DNA-TREE-DEAD",
	"DNA-SKY-GLOOM", "DNA-BD-TOWERS", "DNA-PROP-DESK", "DNA-PROP-STAMP", "DNA-PROP-ROPE", "DNA-PROP-GHOSTLAMP", "DNA-PROP-PAPER", "DNA-DEC-COFFEE", "DNA-DEC-FOOT",
]
const LANDMARK_SIZES: Dictionary = {
	"DNA-HERO-FINAL-APPROVALS": [32.0, 18.0, 7.0], "DNA-HERO-FILING-TOWER": [10.0, 22.0, 6.0], "DNA-HERO-ENDLESS-QUEUE": [56.0, 3.0, 2.0], "DNA-HERO-RECORDS-STAIR": [9.0, 5.0, 8.0],
}


func test_every_sheet_id_is_registered_and_has_art() -> void:
	var ids: Array[String] = EnvKit.zone_ids("dna")
	for id: String in SHEET_IDS:
		assert_true(ids.has(id), "%s is in the dna registry" % id)
		assert_eq(EnvKit.zone_of(id), "dna", "%s belongs to the dna kit" % id)
		if not id.contains("-HERO-") and not id.contains("-SHEET-"):
			assert_true(EnvKit.has_art(id), "%s has its art file" % id)  # concepts are references, sheets live on as their six parts
	assert_eq(EnvKit.entry("DNA-SHEET-CABINETS").get("parts", []).size(), 6, "the cabinet sheet lists six parts")
	assert_not_null(EnvKit.map_texture("DNA-WALL-GREY", "n"), "surfaces carry a normal map")
	assert_almost_eq(EnvKit.tile_size("DNA-WALL-GREY"), 2.56, 0.01, "one texel density with the town kit (400 px/m)")


func test_cabinets_are_ground_props_not_plaques() -> void:
	for index: int in range(1, 7):
		var id: String = "DNA-SHEET-CABINETS-%02d" % index
		assert_eq(str(EnvKit.entry(id).get("group", "")), "prop", "%s is a prop" % id)
		assert_almost_eq(EnvKit.pivot(id).x, 0.5, 0.001, "%s pivots at the bottom centre" % id)
		assert_almost_eq(EnvKit.pivot(id).y, 1.0, 0.001, "%s pivots at the bottom centre" % id)
		assert_gt(ZoneClusters.card_height(id), 0.9, "%s has a hand height" % id)
	assert_eq(ZonePrep.group_for("DNA-SHEET-CABINETS", "Cutout sheet", "Sliced into props", "Filing cabinets"), "prop")
	assert_eq(ZonePrep.group_for("DNA-SHEET-SIGNS", "Cutout sheet", "Sliced into icon signs", "Icon plaques"), "sign")
	assert_almost_eq(EnvKit.pivot("DNA-SHEET-SIGNS-01").x, 0.0, 0.001, "plaques pivot at their bracket")
	assert_almost_eq(EnvKit.pivot("DNA-TREE-DEAD").y, 1.0, 0.001, "plants at the trunk base")


func test_painted_texture_aliases_resolve() -> void:
	for id: String in ["TEX-DNA-CARPET", "TEX-DNA-MARBLE", "TEX-DNA-LINOLEUM", "TEX-DNA-CHECKERTILE", "TEX-DNA-PANELING", "TEX-DNA-WALLPAPER", "DEC-PAPERS", "DEC-ECTOPLASM"]:
		assert_true(EnvKit.has(id), "%s is registered" % id)
		assert_eq(EnvKit.status(id), "placeholder", "%s has no kit file of its own" % id)
		assert_not_null(EnvKit.texture(id), "%s resolves to the painted texture" % id)


func test_hero_landmarks_build_to_their_sizes() -> void:
	for id: String in LANDMARK_SIZES.keys():
		assert_true(HeroLandmarks.has_model(id), "%s has a model" % id)
		var size: Array = LANDMARK_SIZES[id] as Array
		var node: Node3D = LandmarkKit.build({"id": id, "kind": "facade", "size": size, "color": "#6e7470", "accent": "#8a2e2e"})
		assert_not_null(node, "%s builds" % id)
		if node == null:
			continue
		add_child_autofree(node)
		assert_eq(str(node.get_meta("hero_id", "")), id, "the hero model, not the stand-in")
		assert_eq(node.get_meta("footprint"), Vector2(float(size[0]), float(size[2])), "%s keeps the data footprint" % id)
		assert_gt((node.get_meta("circles") as Array).size(), 0, "%s blocks the hero" % id)
		assert_gt(int(node.get_meta("triangles")), 100, "%s is modelled" % id)
		assert_lt(int(node.get_meta("triangles")), 90000, "%s stays cheap" % id)
		assert_true(node.has_meta(&"no_wind"), "%s does not sway" % id)
		assert_eq(node.find_children("*", "Label3D", true, false).size(), 0, "no lettering on %s" % id)
		var body: MeshInstance3D = node.get_child(0) as MeshInstance3D
		assert_not_null(body, "%s has a body mesh" % id)
		var aabb: AABB = body.get_aabb()
		assert_gt(aabb.size.y, float(size[1]) * 0.8, "%s reaches most of its height" % id)
		assert_lt(aabb.size.x, float(size[0]) * 1.3, "%s stays near its width" % id)
	assert_gt((LandmarkKit.build({"id": "DNA-HERO-ENDLESS-QUEUE", "size": [56.0, 3.0, 2.0]}).get_meta("lights") as Array).size(), 2, "the queue carries ghost lamps")


func test_the_mood_carries_the_sky_panorama_and_the_tower_skyline() -> void:
	var mood: Dictionary = WorldLookRig.mood_for(&"dna")
	var sky: Dictionary = mood.get("sky", {}) as Dictionary
	assert_eq(str(sky.get("panorama", "")), "DNA-SKY-GLOOM", "the overcast sky is the kit backdrop")
	assert_true(bool(sky.get("enabled", false)))
	var cards: Array = (mood.get("scenery", {}) as Dictionary).get("kit_cards", []) as Array
	var towers: Array = cards.filter(func(card: Variant) -> bool: return str((card as Dictionary).get("id", "")) == "DNA-BD-TOWERS")
	assert_eq(towers.size(), 4, "the tower skyline rings the zone")
	# art import Oct 29: the Hall of Final Approvals facade stands in front of the north towers
	assert_eq(cards.size(), 5)
	assert_true(cards.any(func(card: Variant) -> bool: return str((card as Dictionary).get("id", "")) == "DNA-BD-HALL-FACADE"))
	assert_eq(WorldSky.new().get("_palette").size(), 0, "a fresh sky has no palette yet")


func test_part_c_dressing_data_resolves() -> void:
	ZoneStyles.use_preset(StylePresets.DNA)
	assert_eq(ZoneStyles.swap("ENV-WALL-TIMBER"), "DNA-WALL-GREY", "timber walls become gray stone")
	assert_eq(ZoneStyles.swap("ENV-DOOR-02"), "DNA-SHEET-DOORS-02")
	assert_eq(ZoneStyles.swap("ENV-TREE-OAK"), "DNA-TREE-DEAD", "trees become dead topiary")
	assert_eq(ZoneStyles.swap("ENV-GROUND-DIRTPATH"), "DNA-PATH-QUEUE", "dirt paths become queue lanes")
	for cluster_name: String in ["clerk_desk", "cabinet_row", "paper_towers", "queue_rope", "lamp_planter", "lily_nook", "stamp_shrine"]:
		assert_true(ZoneClusters.has(cluster_name), "%s is a D.N.A. cluster" % cluster_name)
		var cluster: Node3D = PropClusters.make(cluster_name, 7)
		assert_not_null(cluster, "%s builds" % cluster_name)
		if cluster != null:
			add_child_autofree(cluster)
	for preset_name: String in ["dna_office_block", "dna_records_annex", "dna_booth"]:
		var spec: Dictionary = BuildingPresets.spec(preset_name)
		assert_eq(str(spec.get("wall", "")).begins_with("DNA-") or str(spec.get("wall", "")).begins_with("TEX-DNA-"), true, "%s is walled in the kit" % preset_name)
		assert_between(float(spec.get("ground_height", 0.0)) / StorybookScale.HERO_HEIGHT, 1.2, 1.9, "%s: a storey is about 1.5 heroes" % preset_name)
	ZoneStyles.use_preset(StylePresets.TOWN)


func test_part_c_hub_dressing_keeps_clear() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: DnaBuilder = DnaBuilder.new()
	builder.build(host)
	var dressing: DnaDressing = DnaDressing.build(host, builder, GraphicsQuality.Level.HIGH)
	assert_gt(dressing.count, 6, "the hub carries a few kit clusters and decals")
	# art import Oct 29: +6 form decals, the filing towers, lamps, topiary and the ghost queue (40 at the time; the lobby shot reads clear)
	assert_lt(dressing.count, 50, "but stays uncluttered")
	var centre: Vector3 = builder.anchor("lobby_center")
	for child: Node in dressing.root.get_children():
		if not child.name.begins_with("Cluster_"):
			continue
		var pos: Vector3 = (child as Node3D).position
		assert_gt(Vector2(pos.x - centre.x, pos.z - centre.z).length(), 5.0, "the plaza middle stays open")
		assert_false(DnaLayout.on_approach(pos.x, pos.z), "nothing on the causeway")
		var room: DnaLayout.Room = builder.layout.room_at(pos)
		assert_true(room != null and room.id != "exec", "nothing in the Hall's forecourt")
		for key: String in ["dolores", "pip", "barnaby", "heal", "quiz", "matching", "puzzle", "main_dungeon", "mini_dungeon", "spawn", "exit"]:
			var anchor: Vector3 = builder.anchor(key)
			assert_gt(Vector2(pos.x - anchor.x, pos.z - anchor.z).length(), 2.3, "clear of %s" % key)
	# where the hero stands to use each spot (Agnes and the clerk stand behind their counters: the hero is on the other side)
	var stands: Dictionary = {"dolores": Vector3(0, 0, 2.0), "pip": Vector3(0, 0, -1.6), "heal": Vector3(0, 0, 1.2), "quiz": Vector3(0, 0, 1.2), "puzzle": Vector3(0, 0, 1.2), "coffee": Vector3(0, 0, 1.2), "main_dungeon": Vector3(0, 0, 1.2)}
	for key: String in stands.keys():
		assert_true(builder.is_walkable(builder.anchor(key) + (stands[key] as Vector3)), "the way up to %s is still open after dressing" % key)
