extends GutTest
## Art import Oct 29, Part 2: the new card art, the lieutenant relic icons, the feat group icons, the Dump farmhands' and Primm's sets.

const NEW_CARDS: Array[String] = ["B-34", "B-35", "B-36", "C-35", "G-34", "G-35", "N-10", "N-34", "N-35", "N-36", "N-37", "N-38", "NB-17", "R-34", "R-35", "R-36"]
const RELICS: Array[String] = ["quotas_stopwatch", "colonels_ladle", "plumes_quill", "clipwells_shears"]


func test_new_cards_have_art() -> void:
	for card_id: String in NEW_CARDS:
		assert_true(CardArt.has_art(card_id), "%s has art" % card_id)


func test_lieutenant_relics_have_their_own_icons() -> void:
	for relic: String in RELICS:
		var piece: EquipmentData = load("res://data/equipment/zone/%s.tres" % relic) as EquipmentData
		assert_not_null(piece, relic)
		assert_true(IconArt.has_equipment_icon(piece), "%s shows its own icon" % relic)


func test_every_feat_group_has_an_icon() -> void:
	for group: String in FeatDefs.GROUP_ORDER:
		var icon_id: String = FeatDefs.group_icon(group)
		assert_ne(icon_id, "", group)
		assert_true(IconArt.has(icon_id), "%s -> %s imported" % [group, icon_id])
	assert_true(IconArt.has(FeatDefs.SECRET_ICON))
	assert_true(IconArt.import_ids().has("ICON-FEAT-PATHS"), "the importer accepts the feat icons")


func test_hidden_feats_show_the_secret_icon_until_earned() -> void:
	var def: FeatDefs.Def = FeatDefs.Def.new()
	def.group = "Story"
	def.hidden = true
	assert_eq(FeatDefs.icon_for(def, false), FeatDefs.SECRET_ICON)
	assert_eq(FeatDefs.icon_for(def, true), "ICON-FEAT-STORY")
	def.group = "Necrocrat"
	assert_eq(FeatDefs.icon_for(def, true), "ICON-FEAT-PATHS")


func test_farmhands_and_postgame_primm_have_painted_sets() -> void:
	for key: String in ["DUMPWORKER", "PRIMM"]:
		assert_true(SpriteLibrary.has_character(key), key)
		assert_true(SpriteLibrary.info(key).get("dirs", []).has("FRONT"), "%s front view" % key)
	assert_eq(NpcSprites.character_for("NPC-PRIMM"), "PRIMM", "Primm in the Crease draws his set")
