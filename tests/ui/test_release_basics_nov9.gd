extends GutTest
## Overnight Nov 8-9: the release basics (Part 4) and the art audit's code fixes (Part 2).


func test_species_flipping_expression_variants_are_never_shown() -> void:
	for id: String in ["NPC-GATEKEEPER", "V-SABLE", "V-TONIC", "V-FENWICK", "V-THREADWELL"]:
		assert_true(Portraits.HELD_EXPRESSIONS.has(id), id)
		assert_false(Portraits.has_expression(id, "happy"), "%s: no variant is offered" % id)
	var base: Texture2D = Portraits.texture_for("V-SABLE")
	var pleased: Texture2D = Portraits.texture_for("V-SABLE", "pleased")
	assert_not_null(base)
	assert_eq(pleased, base, "Sable stays the fox when she is pleased")
	assert_true(Portraits.has_expression("NPC-ELDER", "happy"), "matching variants still work (Maren)")


func test_credits_read_the_text_and_fill_the_version() -> void:
	var rows: Array[Array] = CreditsPanel.paragraphs()
	assert_gt(rows.size(), 10)
	var all: String = ""
	for row: Array in rows:
		all += str(row[1]) + "\n"
	assert_string_contains(all, "Godot Engine")
	assert_string_contains(all, "SIL Open Font License")
	assert_string_contains(all, "FluidR3_GM")
	assert_string_contains(all, "AI")
	assert_string_contains(all, str(ProjectSettings.get_setting("application/config/version", "")))
	assert_false(all.contains("{creator}") or all.contains("{version}"), "placeholders are filled or dropped")


func test_credits_panel_builds_with_the_engine_notices() -> void:
	var panel: CreditsPanel = CreditsPanel.make()
	add_child_autofree(panel)
	await wait_frames(2)
	assert_not_null(panel.find_child("CloseCredits", true, false))
	var texts: String = ""
	for label: Node in panel.find_children("*", "Label", true, false):
		texts += (label as Label).text
	assert_string_contains(texts, "Third-party components in Godot Engine")
	assert_string_contains(texts, "FreeType")


func test_the_support_button_hides_while_no_url_is_set() -> void:
	if CreditsPanel.support_url().is_empty():
		assert_null(CreditsPanel.support_button(), "no url, no button")
	else:
		assert_not_null(CreditsPanel.support_button())


func test_the_title_menu_has_credits() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/screens/title_screen.gd")
	assert_string_contains(source, "_menu_button(\"Credits\"")
	assert_string_contains(source, "CreditsPanel.support_url()")


func test_the_log_text_for_bug_reports_never_fails() -> void:
	var text: String = SettingsPanel.log_text()
	assert_false(text.is_empty())
	assert_lte(text.length(), 200_000)


func test_cinzel_carries_its_own_licence() -> void:
	var licence: String = FileAccess.get_file_as_string("res://assets/fonts/Cinzel/OFL.txt")
	assert_string_contains(licence, "Cinzel Project Authors")
	assert_false(licence.begins_with("Copyright 2013 The Alegreya Sans"))


func test_a_damaged_save_or_settings_file_loads_as_nothing() -> void:
	var path: String = "user://test_damaged_save.json"
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{ this is not json ]]")
	file.close()
	assert_eq(SaveSystem.read(path), {}, "a damaged save reads as empty (the slot list shows it as empty, the game starts)")
	SaveSystem.delete(path)


## Part 1.3: every scene the export ships loads (its scripts and every dependency resolve).
func test_every_shipped_scene_loads() -> void:
	var dir: DirAccess = DirAccess.open("res://scenes")
	var count: int = 0
	for file: String in dir.get_files():
		if not file.ends_with(".tscn"):
			continue
		var scene: PackedScene = ResourceLoader.load("res://scenes/" + file) as PackedScene
		assert_not_null(scene, file)
		if scene != null:
			assert_true(scene.can_instantiate(), file)
		count += 1
	assert_gte(count, 12)
