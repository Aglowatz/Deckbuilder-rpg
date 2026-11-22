extends GutTest
## Batch 16 (Nov 16): the 46 approved images are imported and wired - Fig Sly, the four story stills, Sergeant Scuff's three pictures, the
## two card backs, the Path feats badge, the four plinth statues, Crosspath's freed banners (and the two ring banners), the freed Capital's
## two banners, the logo, Crosspath's shore stones, the Crease market, the Rescuer's walk, Quadzilla's and the Cairn's portraits, the
## D.N.A. debris and the five packs.

const KIT_IDS: Array[String] = [
	"DEC-PLINTH-BEEF", "DEC-PLINTH-GOUR", "DEC-PLINTH-REF", "DEC-PLINTH-NECRO",
	"TOWN-SHEET-FREED-BANNERS-01", "TOWN-SHEET-FREED-BANNERS-02", "TOWN-SHEET-FREED-BANNERS-03", "TOWN-SHEET-FREED-BANNERS-04",
	"TOWN-SHEET-FREED-BANNERS-05", "TOWN-SHEET-FREED-BANNERS-06", "CAP-BANNER-FREED-03", "CAP-BANNER-FREED-04",
	"TOWN-PROP-SHORE-STONES-01", "TOWN-PROP-SHORE-STONES-02", "TOWN-PROP-SHORE-STONES-03",
	"CAP-PROP-CREASE-STALL-01", "CAP-PROP-CREASE-STALL-02", "CAP-PROP-CREASE-CRATES", "DNA-PROP-CRATES", "DNA-PROP-CABINET-TIPPED",
]
const UI_IDS: Array[String] = ["UI-CARDBACK-B", "UI-CARDBACK-N", "UI-PACK-GILDED-N", "UI-PACK-GILDED-G", "UI-PACK-GILDED-R", "UI-PACK-N", "UI-PACK-R"]
const PORTRAIT_IDS: Array[String] = ["V-FIGSLY", "NPC-SCUFF", "CUT-SCUFF", "NPC-QUADZILLA", "NPC-CAIRN"]
const KEY_ART_IDS: Array[String] = ["STORY-MEMORY-3", "STORY-MEMORY-4", "STORY-REUNION", "STORY-EPI-FILE-COMPLETE", "LOGO-EMBLEM", "LOGO-WORDMARK", "APP-ICON"]


func test_every_piece_is_imported() -> void:
	for id: String in KIT_IDS:
		assert_true(EnvKit.has_art(id), "%s is in the game" % id)
	for id: String in UI_IDS:
		assert_true(UiArt.has(id), "%s is in the game" % id)
	for id: String in PORTRAIT_IDS:
		assert_true(Portraits.has_portrait(id), "%s is in the game" % id)
	for id: String in KEY_ART_IDS:
		assert_true(KeyArt.has(id), "%s is in the game" % id)
	assert_true(IconArt.has("ICON-FEAT-PATHS"))
	assert_true(ResourceLoader.exists("res://assets/art/bestiary/BST-ENFORCER-SERGEANT-SCUFF.webp"))


func test_sergeant_scuff_has_his_own_pictures() -> void:
	assert_true(Portraits.STAND_INS.is_empty(), "no borrowed dialogue portrait")
	# Fable Nov 21 castle: the Pantry Mimic borrows the Echo of the Doppelganger until its Batch 19 portrait (BST-THE-PANTRY-MIMIC) arrives; nothing else borrows.
	assert_eq(Bestiary.ART_STAND_INS, {"The Pantry Mimic": "BST-ECHO-OF-THE-DOPPELGANGER"}, "no borrowed Bestiary square but the Mimic's")
	assert_false(Bestiary.CUTOUTS_AWAITING_ART.has("CUT-SCUFF"))
	assert_eq(Bestiary.cutout_id("Enforcer Sergeant Scuff"), "CUT-SCUFF")
	assert_eq(Bestiary.cutout("Enforcer Sergeant Scuff"), Portraits.texture_for("CUT-SCUFF"), "his boss intro slides his own cut-out in")
	assert_eq(Bestiary.art("Enforcer Sergeant Scuff").resource_path, "res://assets/art/bestiary/BST-ENFORCER-SERGEANT-SCUFF.webp")
	assert_eq(NpcRegistry.story_speaker("dungeon.dg_s_cap_boss.after"), "NPC-SCUFF")


func test_quadzilla_and_the_cairn_speak_with_a_portrait() -> void:
	assert_eq(NpcRegistry.resolve_speaker("The Restless Cairn"), "NPC-CAIRN", "the Graveyard's lines are started by this name")
	assert_eq(NpcRegistry.story_speaker("dungeon.dg_s_iron_boss.before"), "NPC-QUADZILLA")
	assert_eq(NpcRegistry.story_speaker("dungeon.dg_s_iron_boss.after"), "NPC-QUADZILLA")
	for id: String in ["NPC-QUADZILLA", "NPC-CAIRN"]:
		assert_not_null(Portraits.texture_for(NpcRegistry.find(id).portrait_id), "%s has a portrait" % id)


func test_the_crease_market_uses_its_own_furniture() -> void:
	assert_eq(str(CapitalProps.CREASE_STALL[0]), "CAP-PROP-CREASE-STALL-01", "Fig Sly's stall")
	assert_eq(str(CapitalProps.CREASE_STALL_2[0]), "CAP-PROP-CREASE-STALL-02")
	assert_eq(str(CapitalProps.CREASE_CRATES[0]), "CAP-PROP-CREASE-CRATES")
	var layout: CapitalLayout = CapitalLayout.new()
	layout.build()
	var fig: Vector3 = layout.anchors["fig"] as Vector3
	var stalls: Array[CapitalLayout.Prop] = []
	for prop: CapitalLayout.Prop in layout.props:
		if prop.kind == "crease_stall":
			stalls.append(prop)
	assert_eq(stalls.size(), 2, "two stalls in the market")
	for prop: CapitalLayout.Prop in stalls:
		if prop.variant == 0:
			assert_lt(absf(prop.pos.x - fig.x), 0.6, "Fig Sly stands in front of stall 01")
			assert_lt(prop.pos.z, fig.z, "the stall is behind him (north)")
	assert_eq(stalls[0].variant + stalls[1].variant, 1, "one of each stall")


func test_the_dna_debris_is_the_painted_cabinet_and_crates() -> void:
	var ids: Dictionary = {}
	for entry: Array in DnaWasteland.OFFICE_DEBRIS:
		ids[str(entry[0])] = true
		if str(entry[0]).begins_with("DNA-PROP-"):
			assert_eq(float(entry[4]), 0.0, "%s stands as painted (no card turned on its side)" % str(entry[0]))
		assert_false(str(entry[0]).begins_with("DNA-SHEET-CABINETS"), "no upright cabinet card rolled over")
	assert_true(ids.has("DNA-PROP-CABINET-TIPPED"))
	assert_true(ids.has("DNA-PROP-CRATES"))


func test_crosspath_hangs_the_ring_banners_and_paints_its_shore_stones() -> void:
	assert_eq(TownScene.RING_BANNERS, ["TOWN-SHEET-FREED-BANNERS-05", "TOWN-SHEET-FREED-BANNERS-06"] as Array[String])
	assert_eq(str(TownScene.FREED_BANNERS["necrocrat"]), "TOWN-SHEET-FREED-BANNERS-03", "the skull banner")
	assert_eq(str(TownScene.FREED_BANNERS["refusemancer"]), "TOWN-SHEET-FREED-BANNERS-04", "the leaf banner")
	for entry: Array in BoundaryKit.SHORE_STONE_ART:
		assert_true(EnvKit.has_art(str(entry[0])), "%s is imported, so the bank uses the painted stones" % str(entry[0]))


func test_the_path_feats_badge_heads_the_one_path_groups() -> void:
	assert_eq(FeatDefs.PATHS_BADGE, "ICON-FEAT-PATHS")
	assert_eq(FeatDefs.GROUP_ORDER.find(FeatDefs.PATH_GROUPS[0]), FeatDefs.GROUP_ORDER.find("Beefcake"))
	var panel: FeatsPanel = FeatsPanel.make()
	add_child_autofree(panel)
	await get_tree().process_frame
	var heading: Node = panel.find_child("*PathFeatsHeading*", true, false)
	assert_not_null(heading, "the Feats page shows the badge")
	if heading != null:
		var beefcake: Node = panel.find_child("*Group_Beefcake*", true, false)
		assert_not_null(beefcake)
		if beefcake != null:
			assert_eq(heading.get_index() + 1, beefcake.get_parent().get_index(), "just above the first one-Path group")


func test_the_export_icon_is_the_new_app_icon() -> void:
	assert_true(FileAccess.file_exists("res://assets/icon/app_icon.ico"))
	var preset: String = FileAccess.get_file_as_string("res://export_presets.cfg")
	assert_true(preset.contains("application/icon=\"res://assets/icon/app_icon.ico\""), "the Windows preset points at the .ico")
	var manifest: String = FileAccess.get_file_as_string("res://data/source/key_art_import_manifest.csv")
	assert_true(manifest.contains("APP-ICON"), "the importer that writes the .ico has seen the new APP-ICON")
