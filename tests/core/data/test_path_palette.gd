extends GutTest
## Fable Nov 19 (Part 3): one official colour per Path, in one file (core/data/path_palette.json, docs/art/path_colour_guide.md).


func test_the_file_has_every_path_and_every_role() -> void:
	var parsed: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PathPalette.FILE)) as Dictionary
	var paths: Dictionary = parsed["paths"] as Dictionary
	for key: String in ["beefcake", "gourmand", "refusemancer", "necrocrat", "colorless"]:
		assert_true(paths.has(key), key)
		for role: String in PathPalette.ROLES:
			var hex: String = str((paths[key] as Dictionary).get(role, ""))
			assert_true(hex.is_valid_html_color() and hex.length() == 6, "%s %s is a hex colour" % [key, role])


func test_the_ui_tint_is_the_palette() -> void:
	PathPalette.reload()
	for path: Affinity.Type in PathIcons.ORDER:
		assert_eq(UIStyle.affinity_color(path), PathPalette.main(path))
		assert_ne(PathPalette.main(path), PathPalette.accent(path), "main and accent differ")
	assert_eq(PathPalette.ring().size(), 4)
	assert_eq(PathPalette.of_id("nonsense"), PathPalette.main(Affinity.Type.NEUTRAL), "anything else is colorless")


func test_the_four_are_easy_to_tell_apart() -> void:
	# a simple guard (the real check, with colour-blind simulation, is tools/path_palette_check.py): no two mains are close in RGB
	var ring: Array[Color] = PathPalette.ring()
	for a: int in range(ring.size()):
		for b: int in range(a + 1, ring.size()):
			var gap: float = Vector3(ring[a].r - ring[b].r, ring[a].g - ring[b].g, ring[a].b - ring[b].b).length()
			assert_gt(gap, 0.3, "Paths %d and %d" % [a, b])

## Fable Nov 20 (the owner's decision): Gourmand is blue again and Necrocrat violet; Beefcake red and Refusemancer moss stay.
func test_gourmand_is_blue_and_necrocrat_is_violet() -> void:
	PathPalette.reload()
	var gourmand: Color = PathPalette.main(Affinity.Type.GOURMAND)
	assert_gt(gourmand.b, gourmand.r + 0.3, "blue")
	assert_gt(gourmand.b, gourmand.g, "blue, not teal")
	var necrocrat: Color = PathPalette.main(Affinity.Type.NECROCRAT)
	assert_eq(necrocrat.to_html(false), "9a5fc7", "the old violet")
	# the blue is the lighter of the two, so red-green colour-blind players can tell them apart by brightness
	assert_gt(gourmand.get_luminance(), necrocrat.get_luminance() + 0.12)
	var beefcake: Color = PathPalette.main(Affinity.Type.BEEFCAKE)
	assert_gt(beefcake.r, beefcake.g + 0.4, "red stays")
	var moss: Color = PathPalette.main(Affinity.Type.REFUSEMANCER)
	assert_gt(moss.g, moss.r, "moss green stays")


func test_no_file_keeps_a_path_colour_table_of_its_own() -> void:
	for old_hex: String in ["4a8fe0", "9a5fc7", "e2553f", "5aa84e", "f0c494", "72e55b"]:
		for path: String in ["res://ui/ui_style.gd", "res://ui/card/card_view.gd", "res://core/data/pack_definitions.gd", "res://core/dungeon/boss_intros.gd", "res://world/kit/kit_textures.gd", "res://world/dungeon_backdrop.gd", "res://core/dungeon/ending_defs.gd"]:
			assert_false(FileAccess.get_file_as_string(path).to_lower().contains(old_hex), "%s still holds the old tint %s" % [path, old_hex])
	for gone: Array in [["res://ui/ui_style.gd", "AFFINITY_COLORS"], ["res://core/data/pack_definitions.gd", "PATH_COLORS"], ["res://ui/card/card_view.gd", "FRAME_CLOTH"], ["res://world/kit/kit_textures.gd", "PATH_COLORS: Array"]]:
		assert_false(FileAccess.get_file_as_string(str(gone[0])).contains(str(gone[1])), "%s: %s is gone" % [str(gone[0]), str(gone[1])])


func test_a_path_pack_takes_its_path_colour() -> void:
	var pack: PackData = PackData.new()
	pack.kind = PackData.Kind.PATH
	pack.path = Affinity.Type.NECROCRAT
	pack.art_color = Color(0.6, 0.42, 0.88)
	assert_eq(pack.tint(), PathPalette.main(Affinity.Type.NECROCRAT), "the palette, not the colour saved in its file")
	pack.path = Affinity.Type.NEUTRAL
	pack.kind = PackData.Kind.GENERAL
	assert_eq(pack.tint(), pack.art_color, "a general pack keeps its own colour")


func test_boss_intro_bands_use_the_palette() -> void:
	assert_eq(BossIntros.band_color("gourmand"), PathPalette.of_id("gourmand"))
	assert_eq(BossIntros.band_color("regime"), BossIntros.OTHER_COLORS["regime"])
