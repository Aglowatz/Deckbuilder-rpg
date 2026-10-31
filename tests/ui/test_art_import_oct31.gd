extends GutTest
## Art import Oct 31 (batch 10): the Glossary and Feats menu icons; Captain Spotless's roamer walk set.

const ICONS: Array[String] = ["ICON-UI-GLOSSARY", "ICON-UI-FEATS"]


func test_the_two_menu_icons_are_imported() -> void:
	for id: String in ICONS:
		assert_true(IconArt.has(id), "%s is in the game" % id)


func test_the_glossary_and_feats_pages_show_their_icon_before_the_heading() -> void:
	var glossary: GlossaryPanel = GlossaryPanel.make()
	add_child_autofree(glossary)
	assert_not_null(glossary.find_child("GlossaryIcon", true, false), "Glossary heading icon")
	var feats: FeatsPanel = FeatsPanel.make()
	add_child_autofree(feats)
	assert_not_null(feats.find_child("FeatsIcon", true, false), "Feats heading icon")


func test_the_pause_menu_and_the_hud_menu_name_the_icons() -> void:
	# Source scan: the buttons are built inside larger screens that need the whole session to run.
	for path: String in ["res://ui/screens/pause_menu.gd", "res://ui/town/town_hud.gd"]:
		var source: String = FileAccess.get_file_as_string(path)
		for id: String in ICONS:
			assert_true(source.contains("\"%s\"" % id), "%s uses %s" % [path.get_file(), id])


func test_captain_spotless_walks_with_his_own_roamer_set_and_the_gate_keeps_his_npc_set() -> void:
	var info: ZoneEnemyInfo = ZoneEnemies.info(CapitalZone.ID, CapitalEnemies.SPOTLESS)
	var key: String = info.sprite_key().replace("-", "_")  # the lookup ZoneEnemy._make_model does
	assert_eq(key, "FOE_CAPTAIN_SPOTLESS")
	assert_true(SpriteLibrary.has_character(key), "the imported folder / manifest key matches the lookup")
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/art/world_test/sprites/manifest.json")) as Dictionary
	var entry: Dictionary = manifest.get(key, {}) as Dictionary
	assert_eq((entry.get("walk_dirs", []) as Array).size(), 5, "walks in all five directions")
	assert_true(bool(entry.get("has_talk", false)), "FRONT_TALK for the encounter")
	assert_true(SpriteLibrary.has_character("SPOTLESS"), "the stationary gate set stays")
