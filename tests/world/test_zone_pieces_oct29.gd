extends GutTest
## Art import Oct 29, Part 3: the zone pieces of art batches 5-9 (kit rows imported, backdrop strips in the moods, the D.N.A.'s hand-placed pieces).

const NEW_IDS: Array[String] = [
	"OF-HERO-CAVE-MOUTH", "OF-BD-TORCHLINE", "OF-TREE-GIANT-01", "OF-TREE-GIANT-02", "OF-TREE-GIANT-03", "OF-PROP-LAB-HATCH",
	"TOWN-BD-HORIZON", "TOWN-HERO-FOUNTAIN", "TOWN-SHEET-FREED-BANNERS-01", "TOWN-SHEET-FREED-BANNERS-04",
	"GAIN-BD-HOUSE-OF-GAINS", "GAIN-HERO-HAMSTER-WHEEL", "GAIN-SHEET-FLOATING-ISLANDS-03", "GAIN-DEC-REGIME-POSTERS-06",
	"DNA-BD-HALL-FACADE", "DNA-SHEET-FILING-TOWERS-04", "DNA-SHEET-GHOST-QUEUE-06", "DNA-SHEET-PROPS-06", "DNA-DEC-FORMS-05",
	"BUFF-BD-CAKE-CATHEDRAL", "BUFF-BD-TEST-KITCHEN", "BUFF-SHEET-TASTING-STANDS-06", "BUFF-DEC-ROSETTES-06",
	"DUMP-BD-ROTHEART-SKY", "DUMP-HERO-JUNK-MOUNTAIN", "DUMP-HERO-THRONE-DUMPSTER", "DUMP-SHEET-ENTRANCE-FLAGS-02", "DUMP-DEC-CORRUPTION-06",
	"CAPI-BD-GREAT-WALL", "CAPI-BD-CASTLE", "CAPI-DEC-LOST-PROPERTY-01", "CAPI-SHEET-RIFTS-06", "CAPI-PROP-PRIMM-STATUE", "CAPI-PROP-STATUE-FALLEN", "CAP-PATH-WHITE",
]


func test_every_new_piece_is_registered_with_its_art() -> void:
	for id: String in NEW_IDS:
		assert_true(EnvKit.has(id), "%s registered" % id)
		assert_true(EnvKit.has_art(id), "%s imported" % id)
	assert_eq(str(EnvKit.entry("DUMP-HERO-JUNK-MOUNTAIN").get("lock", "")), "CUTOUT", "the junk mountain redo is a painted cut-out")


func test_backdrop_strips_stand_in_their_moods() -> void:
	var wanted: Dictionary = {&"start": "OF-BD-TORCHLINE", &"town": "TOWN-BD-HORIZON", &"gainlands": "GAIN-BD-HOUSE-OF-GAINS", &"dna": "DNA-BD-HALL-FACADE",
		&"buffet": "BUFF-BD-TEST-KITCHEN", &"heap": "DUMP-BD-ROTHEART-SKY", &"capital_outskirts": "CAPI-BD-GREAT-WALL", &"capital_inside": "CAPI-BD-CASTLE"}
	for mood: StringName in wanted.keys():
		var cards: Array = ((WorldLookRig.mood_for(mood).get("scenery", {}) as Dictionary).get("kit_cards", []) as Array)
		assert_true(cards.any(func(card: Variant) -> bool: return str((card as Dictionary).get("id", "")) == str(wanted[mood])), "%s carries %s" % [mood, wanted[mood]])
	var heap_cards: Array = ((WorldLookRig.mood_for(&"heap").get("scenery", {}) as Dictionary).get("kit_cards", []) as Array)
	assert_false(heap_cards.any(func(card: Variant) -> bool: return str((card as Dictionary).get("id", "")) == "DUMP-BD-ROTHEART"), "the baked-sky Rotheart stays unused")


func test_dna_pieces_and_the_ghost_queue_are_placed_clear() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: DnaBuilder = DnaBuilder.new()
	builder.build(host)
	var dressing: DnaDressing = DnaDressing.build(host, builder, GraphicsQuality.Level.HIGH)
	assert_not_null(dressing.root.find_child("Kit_DNA-SHEET-GHOST-QUEUE-01", true, false), "the queue of ghosts stands in the lobby")
	assert_not_null(dressing.root.find_child("Kit_DNA-SHEET-FILING-TOWERS-03", true, false), "a filing tower stands in a cubicle farm")
	for anchor_id: String in ["pip", "dolores", "vendor", "heal"]:
		if builder.has_anchor(anchor_id):
			assert_true(builder.is_walkable(builder.anchor(anchor_id) + Vector3(0, 0, 0.8), 0.3) or builder.is_walkable(builder.anchor(anchor_id) + Vector3(0, 0, -0.8), 0.3), "%s can still be reached" % anchor_id)


func test_missing_art_places_nothing() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	assert_null(KitPieces.stand(host, "NO-SUCH-PIECE", Vector3.ZERO, 2.0))
	assert_null(KitPieces.wall(host, "NO-SUCH-PIECE", Vector3.ZERO, 0.0, 1.0))
	assert_null(KitPieces.ground(host, "NO-SUCH-PIECE", Vector3.ZERO, 0.0, 1.0))
	assert_eq(host.get_child_count(), 0)
