extends CardTestBase
## Fable Nov 19 (Part 5): Primm's Castle choice nodes carry drawbacks like every other dungeon (its rooms and fights are unchanged),
## and the enemy-side drawback "the enemy starts with an extra unit" (Modifier.Kind.STARTING_UNITS, boon spec key foe_unit).


func _content() -> Dictionary:
	return (JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons/dungeon_content.json")) as Dictionary)["dungeons"] as Dictionary


func _tokens(dungeon: String, node: String, label: String) -> Array:
	for choice: Variant in ((((_content()[dungeon] as Dictionary)["events"] as Dictionary)[node] as Dictionary)["choices"]) as Array:
		if str((choice as Array)[0]) == label:
			return (choice as Array).slice(2)
	return []


func test_the_three_purely_good_castle_options_have_a_drawback() -> void:
	for spec: Array in [["3", "Study the portrait"], ["12", "Read the notes"], ["22", "Pick the odd one out"], ["3", "Count the reflections"], ["12", "Take the samples"], ["22", "Pick a handful of the rest"]]:
		var tokens: Array = _tokens("D-PC", str(spec[0]), str(spec[1]))
		assert_gte(tokens.size(), 2, "%s: a boon and a drawback" % str(spec[1]))
		var bad: bool = false
		for token: Variant in tokens:
			var kind: String = str(token).split(":")[0]
			bad = bad or kind == "damage" or kind == "pay" or (kind == "curse" and BoonText.is_curse(DungeonBuilder.boon_from(str(token).substr(6))))
		assert_true(bad, "%s has a drawback: %s" % [str(spec[1]), str(tokens)])


func test_enemy_side_drawbacks_in_the_castle_last_one_fight_only() -> void:
	# Primm's own fight is never touched: anything that strengthens the enemy in the castle ends after the next fight
	var events: Dictionary = (_content()["D-PC"] as Dictionary)["events"] as Dictionary
	var found: int = 0
	for node: String in events.keys():
		for choice: Variant in (events[node] as Dictionary).get("choices", []) as Array:
			for token: Variant in (choice as Array).slice(2):
				if str(token).begins_with("curse:") or str(token).begins_with("boon:"):
					var source: ModifierSource = DungeonBuilder.boon_from(str(token).split(":", true, 1)[1])
					if source.for_enemy:
						found += 1
						assert_eq(source.fights_left, 1, "%s: %s" % [node, str(token)])
	assert_gte(found, 2)


func test_the_castle_story_events_have_no_purely_good_option() -> void:
	var source: String = FileAccess.get_file_as_string("res://core/dungeon/primms_castle_dungeon.gd")
	var lines_checked: int = 0
	for id: String in ["corrected", "journals"]:
		for line: String in source.split("\n"):
			if line.strip_edges().begins_with(id + ".choice("):
				lines_checked += 1
				assert_true(line.contains("DungeonEvent.damage(") or line.contains("max_hp=-"), "%s: %s" % [id, line.strip_edges().left(80)])
	assert_eq(lines_checked, 5, "three options at the Corrected, two at the journals")


func test_foe_unit_puts_a_unit_on_the_enemys_side_at_the_start() -> void:
	var source: ModifierSource = DungeonBuilder.boon_from("Alarm Raised|foe_unit=25,next=1")
	assert_true(source.for_enemy, "the whole source goes to the enemy")
	assert_true(BoonText.is_curse(source))
	assert_eq(source.fights_left, 1)
	assert_string_contains(BoonText.short(source), "the enemy starts with a Failed Experiment (3/3) on the field")
	var mine: ModifierSet = ModifierPipeline.build(null, null, [source] as Array[ModifierSource])
	assert_false(mine.has(Modifier.Kind.STARTING_UNITS), "not on the player's side")
	var game: GameState = _game()
	game.players[1].modifiers.add_source(source)
	var before_enemy: int = game.players[1].field.size()
	var before_mine: int = game.players[0].field.size()
	game._begin_playing()
	assert_eq(game.players[1].field.size(), before_enemy + 1, "the enemy starts with one more unit")
	assert_eq(game.players[0].field.size(), before_mine, "the player does not")
	var unit: CardInstance = game.players[1].field[game.players[1].field.size() - 1]
	assert_eq(unit.data.display_name, "Failed Experiment")


func test_two_units_and_an_unknown_token() -> void:
	var two: ModifierSource = DungeonBuilder.boon_from("Reinforcements|foe_unit=16,foe_units=2")
	var game: GameState = _game()
	game.players[1].modifiers.add_source(two)
	game._begin_playing()
	assert_eq(_on_field(game, 1, "T-16").size(), 2, "two Militia")
	var none: ModifierSource = DungeonBuilder.boon_from("Nothing|foe_unit=99")
	assert_false(ModifierPipeline.build_for_enemy([none] as Array[ModifierSource]).has(Modifier.Kind.STARTING_UNITS), "an unknown token adds nothing")


func test_the_summon_is_used_in_three_choice_nodes() -> void:
	var uses: Array[String] = []
	var content: Dictionary = _content()
	for dungeon: String in content.keys():
		var events: Dictionary = (content[dungeon] as Dictionary).get("events", {}) as Dictionary
		for node: String in events.keys():
			for choice: Variant in (events[node] as Dictionary).get("choices", []) as Array:
				for token: Variant in (choice as Array).slice(2):
					if str(token).contains("foe_unit="):
						uses.append("%s %s" % [dungeon, node])
	assert_eq(uses.size(), 3, str(uses))
	assert_true(uses.has("D-HFA 2") and uses.has("D-LAB 12") and uses.has("D-PC 3"))
