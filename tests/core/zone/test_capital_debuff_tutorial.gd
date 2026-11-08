extends GutTest
## Overnight Nov 7-8, Part 1.6: the Capital's first-visit debuff tutorial names each active debuff and how to lift it, and the Glossary has it.


func test_the_tutorial_lists_only_the_active_debuffs_and_how_to_lift_them() -> void:
	var flags: Dictionary = {}
	var text: String = CapitalDebuffs.tutorial_text(flags)
	for debuff: CapitalDebuffs.Debuff in CapitalDebuffs.all():
		assert_string_contains(text, debuff.name_text())
	assert_string_contains(text, "upper left")
	assert_string_contains(text, "Free a Path's zone")
	flags[str(ZoneCompletion.flag_name("beefcake"))] = true
	assert_false(CapitalDebuffs.tutorial_text(flags).contains(CapitalDebuffs.find("beefcake").name_text()), "a lifted debuff is not listed")


func test_the_glossary_explains_the_capital_debuffs() -> void:
	var rows: Array[Array] = GlossaryPanel.entries(GlossaryPanel.TABS.find("Zones"))
	var titles: PackedStringArray = []
	for row: Array in rows:
		titles.append(str(row[0]))
	assert_true(titles.has("Capital debuffs"))
	for debuff: CapitalDebuffs.Debuff in CapitalDebuffs.all():
		assert_true(" ".join(titles).contains(debuff.name_text()), debuff.zone_id)
