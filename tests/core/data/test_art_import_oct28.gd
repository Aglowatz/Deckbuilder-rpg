extends GutTest
## Overnight Oct 28-29, art batches 1-4 (rows #1-74 of docs/art/art_batch_oct28.csv): the imported art is where the game looks for it - Maren's
## tortoise portraits, every roaming enemy's painted set, every entrance cut-out (Primm's phases too) and the 23 new Bestiary squares.

const WALK_SETS: Array[String] = [
	"FOE-PANTRY-HOUND", "FOE-LOST-JUNIOR-CLERK", "FOE-BIN-RACCOON", "FOE-QUOTA-SPOTTER", "FOE-PROTEIN-SHAKE-GOLEM", "FOE-SHAMBLING-MIDDLE-MANAGER",
	"FOE-UNPAID-INTERN", "FOE-MEATLOAF-GOLEM", "FOE-GELATIN-SENTINEL", "FOE-MOSSY-TRASH-GOLEM", "FOE-HUNGRY-SCARECROW", "FOE-CORRECTION-OFFICER",
	"FOE-PERFECTION-INSPECTOR", "FOE-RIFT-WRETCH",
]
const IDLE_SETS: Array[String] = [
	"FOE-SPRINTING-ENERGY-SPRITE", "FOE-SPEEDY-GHOST-COURIER", "FOE-RUNAWAY-MEATBALL", "FOE-COLONEL-CASSEROLE", "FOE-JUNK-GULL-FLOCK", "FOE-TIDY-BOT",
	"FOE-SHARD-SWARM",
]
const SQUARES: Array[String] = [
	"BST-PANTRY-HOUND", "BST-LOST-JUNIOR-CLERK", "BST-BIN-RACCOON", "BST-QUOTA-SPOTTER", "BST-HOLLOW-WARDEN", "BST-SHIRO-SWINDLE",
	"BST-THE-WARDEN-OF-THE-FOUR-SEALS", "BST-CHANCELLOR-CLENCH-IRON-REGENT", "BST-VIVIENNE-QUOTA-MINISTER-OF-EFFICIENCY", "BST-THE-ANCIENT-SPOTTER",
	"BST-THE-DOPPELGANGER", "BST-THE-ITAMAE-SUPREME", "BST-COLONEL-CORNELIUS-CRUMB-DIRECTOR-OF-CULINARY-DEFENSE", "BST-MORTIMER-GRIMSBY-CE-NO",
	"BST-BETTY-BONES-SURLY-SECRETARY", "BST-PERCIVAL-PLUME-DEPUTY-MINISTER-OF-GOOD-NEWS", "BST-COMPOSTELLA-THE-ROTHEART",
	"BST-HORTENSIA-CLIPWELL-ROYAL-GROUNDSKEEPER", "BST-HIS-MAJESTY-THE-RACCOON", "BST-CAPTAIN-SPOTLESS", "BST-ENFORCER-CAPTAIN-SPOTLESS",
	"BST-PRIMM-HIS-PERFECTION", "BST-THE-OLD-KINGDOM-AUTOMATON", "BST-DR-AMBROSE-SIPHON-CHIEF-PATH-OLOGIST",
]


func test_every_roaming_enemy_set_is_in_the_sprite_library() -> void:
	for key: String in WALK_SETS:
		var folder: String = key.replace("-", "_")
		assert_true(SpriteLibrary.has_character(folder), key)
		assert_eq((SpriteLibrary.info(folder)["walk_dirs"] as Array).size(), 5, "%s walks in all five directions" % key)
		assert_true(bool(SpriteLibrary.info(folder)["has_talk"]), "%s has the threat (TALK) pose" % key)
	for key: String in IDLE_SETS:
		var folder: String = key.replace("-", "_")
		assert_true(SpriteLibrary.has_character(folder), key)
		assert_eq((SpriteLibrary.info(folder)["walk_dirs"] as Array).size(), 0, "%s is an idle set (it hops)" % key)


func test_relative_heights_come_from_the_batch_sheet() -> void:
	assert_almost_eq(float(SpriteLibrary.info("FOE_PANTRY_HOUND")["rel_height"]), 0.75, 0.001)
	assert_almost_eq(float(SpriteLibrary.info("FOE_PROTEIN_SHAKE_GOLEM")["rel_height"]), 1.35, 0.001)
	assert_almost_eq(float(SpriteLibrary.info("FOE_LOST_JUNIOR_CLERK")["rel_height"]), 0.6, 0.001)
	assert_almost_eq(float(SpriteLibrary.info("ELDER")["rel_height"]), 0.7, 0.001)


func test_roaming_enemies_draw_their_painted_set_untinted() -> void:
	var area: ZoneMap = ZoneMap.new()
	for zone_and_id: Array in [[GainlandsZone.ID, "brute"], [DnaZone.ID, "courier"], [HeapZone.ID, "gulls"], [CapitalZone.ID, "officer"]]:
		var enemy: ZoneEnemy = ZoneEnemy.new()
		add_child_autofree(enemy)
		enemy.setup(ZoneEnemies.info(str(zone_and_id[0]), str(zone_and_id[1])), "t", Vector3.ZERO, 0.0, area, null)
		assert_true(enemy.is_sprite(), "%s/%s is a painted sprite" % zone_and_id)
		var actor: SpriteActor = enemy.get_child(0) as SpriteActor
		assert_eq(actor.tint, Color.WHITE, "the 3D model's tint is not laid over the painting")
	var town: ZoneEnemy = ZoneEnemy.new()
	add_child_autofree(town)
	town.setup(TownEnemies.info("hound"), "t", Vector3.ZERO, 0.0, area, null)
	assert_true(town.is_sprite(), "the Crosspath Pantry Hound is painted")


func test_maren_has_her_three_tortoise_portraits() -> void:
	assert_true(Portraits.has_portrait("NPC-ELDER"))
	assert_true(Portraits.has_expression("NPC-ELDER", "HAPPY"))
	assert_true(Portraits.has_expression("NPC-ELDER", "WORRIED"))
	assert_ne(Portraits.texture_for("NPC-ELDER", "HAPPY"), Portraits.texture_for("NPC-ELDER"))


func test_every_entrance_has_its_cut_out() -> void:
	var missing: Array[String] = []
	for id: String in Bestiary.cutout_ids():
		if not Portraits.has_portrait(id):
			missing.append(id)
	assert_eq(missing, [] as Array[String], "every entrance's CUT-* exists")
	assert_true(Bestiary.cutout_ids().size() >= 24, "the entrances cover the delivered set")


func test_primm_phases_wear_their_own_cut_outs() -> void:
	var base: Texture2D = Bestiary.cutout("Primm, His Perfection", 0)
	var cracked: Texture2D = Bestiary.cutout("Primm, His Perfection", 1)
	var unravelled: Texture2D = Bestiary.cutout("Primm, His Perfection", 2)
	assert_eq(base, Portraits.texture_for("CUT-PRIMM"))
	assert_eq(cracked, Portraits.texture_for("CUT-PRIMM", "CRACKED"))
	assert_eq(unravelled, Portraits.texture_for("CUT-PRIMM", "UNRAVELLED"))
	assert_ne(cracked, base)
	assert_eq(Bestiary.cutout("PRIMM_BOSS", 1), cracked, "the node id and phase names share the boss's set")
	assert_eq(Bestiary.cutout("Primm, His Perfection"), base, "no phase -> the base cut-out")
	assert_eq(Bestiary.phase_cutout_expression("Chancellor Clench, Iron Regent", 1), "", "only Primm has phase cut-outs")


func test_the_new_bestiary_squares_show() -> void:
	for id: String in SQUARES:
		assert_true(ResourceLoader.exists("%s/%s.webp" % [Bestiary.ART_DIR, id]), id)
	Bestiary.reset_art()
	assert_ne(Bestiary.art("Captain Spotless"), null)
	assert_ne(Bestiary.art("Enforcer Captain Spotless"), null, "the Old Service Tunnels name has its picture")
	assert_ne(Bestiary.art("Stray Gym Hound"), null, "an old name still finds a picture")
