extends GutTest
## Brief 14, Part D: the card importer: the sheets parse into the right cards, every card and token has a supported script, hashes
## detect edited rules text, resources round-trip through .tres, and the report is clean.


func before_all() -> void:
	CardSet.load_all()


func test_the_sheets_are_fully_scripted_with_only_supported_mechanics() -> void:
	var problems: Array[String] = []
	for entry: CardImporter.Entry in CardSet.entries():
		for message: String in entry.problems:
			problems.append("%s: %s" % [entry.id, message])
		for message: String in entry.unsupported:
			problems.append("%s: unsupported %s" % [entry.id, message])
		if entry.has_script and entry.script_hash != entry.text_hash:
			problems.append("%s: script hash %s != sheet hash %s (re-script, then --stamp)" % [entry.id, entry.script_hash, entry.text_hash])
	assert_eq(problems, [] as Array[String], "importer problems")


func test_counts_and_ids() -> void:
	assert_eq(CardSet.all_cards().size(), 312, "312 cards in the sheet")
	assert_eq(CardSet.all_tokens().size(), 27, "23 sheet tokens + 3 Design-Guidance-only resources")
	var seen: Dictionary = {}
	for card: CardData in CardSet.all_cards():
		assert_false(seen.has(card.id), "duplicate id %s" % card.id)
		seen[card.id] = true
	assert_true(seen.has("R-01") and seen.has("BAS-B") and seen.has("P4-03") and seen.has("INF-11"))


func test_cost_parsing_handles_every_format_in_the_sheet() -> void:
	var cases: Dictionary = {
		"R-01": [0, [Affinity.Type.REFUSEMANCER]],
		"R-03": [3, [Affinity.Type.REFUSEMANCER]],
		"R-21": [1, [Affinity.Type.REFUSEMANCER]],
		"R-29": [3, [Affinity.Type.REFUSEMANCER, Affinity.Type.REFUSEMANCER, Affinity.Type.REFUSEMANCER]],
		"B-32": [5, [Affinity.Type.BEEFCAKE, Affinity.Type.BEEFCAKE]],
		"GRN-08": [0, [Affinity.Type.GOURMAND, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.REFUSEMANCER, Affinity.Type.NECROCRAT, Affinity.Type.NECROCRAT]],
		"C-09": [5, []],
		"INF-01": [0, []],
	}
	for id: Variant in cases.keys():
		var card: CardData = CardSet.card(str(id))
		var expected: Array = cases[id] as Array
		assert_eq(card.generic_cost, int(expected[0]), "%s generic cost" % id)
		var pips: Array[Affinity.Type] = []
		for pip: Variant in expected[1] as Array:
			pips.append(int(pip) as Affinity.Type)
		assert_eq(card.colored_pips, pips, "%s pips" % id)


func test_paths_come_from_the_sheet_section() -> void:
	assert_eq(CardSet.card("R-01").paths(), [Affinity.Type.REFUSEMANCER] as Array[Affinity.Type])
	assert_eq(CardSet.card("GN-01").paths().size(), 2, "Sous Boo has one (N) pip but is a Gourmand/Necrocrat card")
	assert_eq(CardSet.card("GRB-04").paths().size(), 3)
	assert_eq(CardSet.card("P4-01").paths().size(), 4)
	assert_eq(CardSet.card("C-01").paths().size(), 0, "Colorless")
	assert_eq(CardSet.card("INF-05").paths().size(), 2, "a dual Infrastructure takes its Paths from its produce line")
	assert_true(CardSet.card("INF-11").produces_any)
	assert_true(CardSet.card("BAS-N").is_basic)
	assert_false(CardSet.card("INF-02").is_basic)


func test_types_stats_rarity_and_text() -> void:
	var goat: CardData = CardSet.card("R-04")
	assert_eq(goat.type, CardEnums.CardType.UNIT)
	assert_eq(goat.attack, 2)
	assert_eq(goat.defense, 2)
	assert_eq(goat.rarity, CardEnums.Rarity.COMMON)
	assert_eq(goat.display_name, "Rubbish Goat")
	assert_true(goat.rules_text.begins_with("When this unit enters"))
	assert_false(goat.flavor_text.is_empty())
	assert_false(goat.image_description.is_empty(), "image description is kept as metadata")
	assert_eq(CardSet.card("R-33").rarity, CardEnums.Rarity.LEGENDARY)
	assert_true(CardSet.card("R-33").is_signature)
	assert_false(CardSet.card("R-32").is_signature)
	assert_eq(CardSet.card("R-27").rarity, CardEnums.Rarity.EPIC)
	assert_eq(CardSet.card("G-19").type, CardEnums.CardType.TOOL)
	assert_eq(CardSet.card("G-14").type, CardEnums.CardType.WONDER)
	assert_eq(CardSet.card("G-16").type, CardEnums.CardType.TRAP)
	assert_eq(CardSet.card("G-20").type, CardEnums.CardType.SPELL)
	assert_eq(CardSet.card("BAS-G").type, CardEnums.CardType.INFRASTRUCTURE)
	assert_false(CardSet.card("R-01").not_in_packs, "pack eligibility defaults to true")


func test_keywords_are_read_from_scripts() -> void:
	assert_true(CardSet.card("R-07").has_keyword(CardEnums.Keyword.SWAT))
	assert_true(CardSet.card("P4-01").has_keyword(CardEnums.Keyword.NOURISH))
	assert_eq(CardSet.card("P4-01").keywords.size(), 4)
	assert_true(CardSet.card("G-27").has_keyword(CardEnums.Keyword.BULLDOZE))


func test_tokens() -> void:
	var golem: CardData = CardSet.card("T-01")
	assert_true(golem.is_token)
	assert_eq(golem.attack, 3)
	assert_eq(golem.type, CardEnums.CardType.UNIT)
	assert_true(CardSet.card("T-07").has_keyword(CardEnums.Keyword.BULLDOZE))
	assert_eq(CardSet.card("T-13").type, CardEnums.CardType.RESOURCE)
	assert_eq(CardSet.card("T-13").resource_kind, int(ResourceKind.Kind.CONTRACT))
	assert_eq(CardSet.card("T-12").type, CardEnums.CardType.TOKEN, "the Clause is a special token")
	assert_eq(CardSet.card("T-15").attack, 7)
	assert_true(CardSet.card("T-15").has_keyword(CardEnums.Keyword.UNBREAKABLE))
	assert_eq(CardSet.card("T-17").paths().size(), 2, "Compost Golem is Gourmand/Refusemancer")
	assert_true(CardSet.card("RES-IRON").is_resource())


func test_rules_text_hash_ignores_whitespace_but_not_edits() -> void:
	var original: String = "When this unit enters, create a Garbage."
	assert_eq(CardImporter.hash_text(original), CardImporter.hash_text("  When this unit enters,\n create a   Garbage.  "))
	assert_ne(CardImporter.hash_text(original), CardImporter.hash_text("When this unit enters, create two Garbage."))


func test_an_edited_sheet_text_is_reported_as_needing_a_new_script() -> void:
	var entry: CardImporter.Entry = null
	for candidate: CardImporter.Entry in CardSet.entries():
		if candidate.id == "R-06":
			entry = candidate
	assert_not_null(entry)
	var edited_hash: String = CardImporter.hash_text("When this unit enters, create two Garbage.")
	assert_ne(entry.script_hash, edited_hash, "the script was written for the old text")
	assert_eq(entry.script_hash, entry.text_hash)


func test_unsupported_mechanics_are_detected() -> void:
	var parsed: ScriptParser.Parsed = ScriptParser.parse("when(unit_explodes) => frobnicate(self); damage(opp,wibble(3))\nact | exhaust => flag(not_a_flag)")
	var found: Array[String] = CardImporter.unsupported_names(parsed)
	assert_true(found.has("event 'unit_explodes'"))
	assert_true(found.has("op 'frobnicate'"))
	assert_true(found.has("value 'wibble'"))
	assert_true(found.has("flag 'not_a_flag'"))


func test_script_parser_reports_syntax_errors() -> void:
	var parsed: ScriptParser.Parsed = ScriptParser.parse("nonsense => create(garbage)\nenter => create(garbage\nkw flapping")
	assert_gte(parsed.errors.size(), 2)


func test_round_trip_through_tres_keeps_everything() -> void:
	var path: String = "user://importer_round_trip.tres"
	for id: String in ["R-04", "N-33", "GRN-08", "BAS-R", "INF-11", "T-12"]:
		var original: CardData = CardSet.card(id)
		var copy: CardData = original.duplicate() as CardData
		assert_eq(ResourceSaver.save(copy, path), OK)
		var loaded: CardData = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as CardData
		assert_not_null(loaded)
		assert_eq(loaded.id, original.id)
		assert_eq(loaded.display_name, original.display_name)
		assert_eq(loaded.type, original.type)
		assert_eq(loaded.generic_cost, original.generic_cost)
		assert_eq(loaded.colored_pips, original.colored_pips)
		assert_eq(loaded.paths(), original.paths())
		assert_eq(loaded.attack, original.attack)
		assert_eq(loaded.defense, original.defense)
		assert_eq(loaded.keywords, original.keywords)
		assert_eq(loaded.script_text, original.script_text)
		assert_eq(loaded.rules_hash, original.rules_hash)
		assert_eq(loaded.rules_text, original.rules_text)
		assert_eq(loaded.rarity, original.rarity)
		assert_eq(loaded.produces_any, original.produces_any)
		assert_eq(loaded.resource_kind, original.resource_kind)
		assert_eq(loaded.abilities().size(), original.abilities().size(), "the loaded card parses to the same abilities")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_script_files_have_no_orphans_and_the_sheet_has_no_unscripted_text() -> void:
	var scripts: Dictionary = CardImporter.load_scripts()
	var ids: Dictionary = {}
	for entry: CardImporter.Entry in CardSet.entries():
		ids[entry.id] = true
	for id: Variant in scripts.keys():
		assert_true(ids.has(id), "script for %s has no card in the sheet" % id)
	for entry: CardImporter.Entry in CardSet.entries():
		if not entry.data.is_resource() and not entry.rules_text.is_empty():
			assert_true(scripts.has(entry.id), "%s has rules text but no script" % entry.id)


func test_ability_describer_gives_readable_text() -> void:
	var diver: CardAbility = CardSet.card("R-02").abilities()[0]
	assert_eq(AbilityDescriber.describe(diver), "Exhaust, Pay 1: create Garbage")
	var chef: CardAbility = CardSet.card("G-33").abilities()[1]
	assert_true(AbilityDescriber.describe(chef).contains("Use X Ingredient"))
