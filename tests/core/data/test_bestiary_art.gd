extends GutTest
## Overnight Oct 17 (Phase 2 cycle 15): Bestiary pictures - ids match the request list, a missing picture keeps the icon.


func test_art_ids() -> void:
	assert_eq(Bestiary.art_id("Cave Scavenger"), "BST-CAVE-SCAVENGER")
	assert_eq(Bestiary.art_id("Chancellor Clench, Iron Regent"), "BST-CHANCELLOR-CLENCH-IRON-REGENT")
	assert_eq(Bestiary.art_id("Tidy-Bot"), "BST-TIDY-BOT")
	assert_eq(Bestiary.art_id("Primm - Standardization"), Bestiary.art_id("Primm, His Perfection"), "phase names share the boss's picture")


func test_every_entry_is_in_the_request_list() -> void:
	var path: String = "res://docs/art/bestiary_image_requests.md"
	if not FileAccess.file_exists(path):
		pass_test("no request list in this build")
		return
	var text: String = FileAccess.get_file_as_string(path)
	for entry: Bestiary.Entry in Bestiary.all():
		assert_true(text.contains("**%s**" % Bestiary.art_id(entry.name)), "%s is requested as %s" % [entry.name, Bestiary.art_id(entry.name)])


func test_a_missing_picture_keeps_the_icon() -> void:
	var entry: Bestiary.Entry = Bestiary.all()[0]
	if Bestiary.art(entry.name) != null:
		pass_test("this entry has a picture")
		return
	var picture: TextureRect = CodexScreen.beast_picture(entry, true, 84.0)
	assert_ne(picture.name, "BeastArt", "the icon, not a picture")
	picture.free()


func test_a_boss_without_a_picture_shows_its_portrait() -> void:
	var clench: Texture2D = Bestiary.portrait_art("Chancellor Clench, Iron Regent")
	assert_not_null(clench, "a boss who speaks has a dialogue portrait")
	assert_true(clench is AtlasTexture)
	assert_almost_eq(float(clench.get_width()), float(clench.get_height()), 1.0, "a square head-and-shoulders crop")
	assert_not_null(Bestiary.portrait_art("Hollow Warden"), "through the alias table")
	assert_null(Bestiary.portrait_art("Flexing Brute"), "a plain roamer keeps its icon")
