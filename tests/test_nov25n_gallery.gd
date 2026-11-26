extends GutTest
## Nov 25 night (Part D): the Shattered Gallery's Echoes bring their originals' rules and scripted events (harder), and the Silver
## Reserve is a choice of 1 of 3 boons at the Cracked Frame instead of +40 max HP for everyone.

const ECHOES: Dictionary = {
	"Echo of Vivienne Quota": "Stopwatch, Reflected",
	"Echo of Chancellor Clench": "Reinforcements, Reflected",
	"Echo of Percival Plume": "Positive Spin, Reflected",
	"Echo of Mortimer Grimsby": "Temp Agency, Reflected",
	"Echo of the Doppelganger": "Plated Just So, Reflected",
	"Echo of Hortensia Clipwell": "Royal Groundskeeper, Reflected",
	"Echo of the Rotheart": "Rot Takes Root, Reflected",
}


func test_every_echo_carries_its_originals_rule_and_events() -> void:
	for echo: String in ECHOES:
		var names: Array[String] = []
		for rule: EncounterModifiers.Rule in EncounterModifiers.rules(echo):
			names.append(rule.name)
		assert_true(names.has(ECHOES[echo]), "%s has %s (%s)" % [echo, ECHOES[echo], str(names)])
		assert_gte(names.size(), 2, "%s keeps its own twisted rule too" % echo)
		assert_true(EncounterScripts.has_script(echo), "%s has its original's scripted events" % echo)
	# harder, never softer: no Echo falters near the end (the originals' -1/-0 beats are not carried over)
	var scripts: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters/encounter_scripts.json")) as Dictionary
	for echo: String in ECHOES:
		for event: Variant in scripts.get(echo, []) as Array:
			for effect: Variant in (event as Dictionary).get("effects", []) as Array:
				var rule: Dictionary = (effect as Dictionary).get("rule", {}) as Dictionary
				assert_false(int(rule.get("atk", 0)) < 0, "%s: no event weakens the Echo" % echo)
				assert_ne(str((effect as Dictionary).get("kind", "")), "remove_rule", "%s: no event takes a rule away" % echo)
			assert_false((event as Dictionary).has("line"), "%s: the original's spoken line stays with the original" % echo)


func test_the_echoes_carry_their_originals_numbers() -> void:
	assert_eq(_stat("Echo of Vivienne Quota").x, 1, "Quota's +1 attack")
	assert_eq(_stat("Echo of Percival Plume"), Vector2i(1, 1))
	assert_eq(_stat("Echo of the Doppelganger"), Vector2i(1, 1))
	var clench: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters/modifiers.json"))["Echo of Chancellor Clench"]
	var every: int = 0
	for rule: Variant in clench:
		if str((rule as Dictionary).get("kind", "")) == "timed_summon":
			every = int((rule as Dictionary).get("every", 0))
	assert_eq(every, 5, "reinforcements every fifth turn, as for Clench")


func _stat(echo: String) -> Vector2i:
	for rule: EncounterModifiers.Rule in EncounterModifiers.rules(echo):
		if rule.name == ECHOES[echo]:
			for modifier: Modifier in rule.modifiers:
				if modifier.kind == Modifier.Kind.STAT_CHANGE:
					return Vector2i(modifier.value, modifier.value2)
	return Vector2i.ZERO


func test_the_silver_reserve_offers_three_distinct_boons_and_no_longer_gives_forty() -> void:
	assert_eq(ShatteredGallery.SILVER_OFFER, 3)
	assert_gte(ShatteredGallery.SILVER_BOONS.size(), 8, "a pool of the owner's six and a few more")
	var seen: Dictionary = {}
	for seed_value: int in range(40):
		var offer: Array[String] = ShatteredGallery.silver_offer(seed_value)
		assert_eq(offer.size(), 3)
		var unique: Dictionary = {}
		for id: String in offer:
			unique[id] = true
			seen[id] = true
		assert_eq(unique.size(), 3, "three different boons")
	assert_eq(seen.size(), ShatteredGallery.SILVER_BOONS.size(), "every boon comes up")
	assert_eq(ShatteredGallery.silver_offer(7), ShatteredGallery.silver_offer(7), "the same run sees the same three")
	var session: String = FileAccess.get_file_as_string("res://app/game_session.gd")
	assert_false(session.contains("run.dungeon_sources.append(ShatteredGallery.silver_reserve())"), "nobody gets the old +40 on entry")
	for entry: Array in ShatteredGallery.SILVER_BOONS:
		var source: ModifierSource = ShatteredGallery.silver_boon(str(entry[0]))
		assert_not_null(source, str(entry[0]))
		assert_true(source.source_name.begins_with(ShatteredGallery.SILVER_PREFIX))
		assert_false(BoonText.is_curse(source), "%s is a boon" % str(entry[0]))
		for modifier: Modifier in source.modifiers:
			assert_false(modifier.kind == Modifier.Kind.MAX_HP and modifier.value >= 40, "no +40 any more")


func test_the_boons_do_what_they_say() -> void:
	var expect: Dictionary = {
		"thick": [Modifier.Kind.MAX_HP, 30], "guard": [Modifier.Kind.STAT_CHANGE, 0], "edge": [Modifier.Kind.STAT_CHANGE, 1],
		"look": [Modifier.Kind.EXTRA_DRAWS, 1], "start": [Modifier.Kind.STARTING_INFRASTRUCTURE, 1], "mend": [Modifier.Kind.STARTING_HP, 8],
	}
	for id: String in expect:
		var source: ModifierSource = ShatteredGallery.silver_boon(id)
		var found: bool = false
		for modifier: Modifier in source.modifiers:
			if modifier.kind == expect[id][0] and modifier.value == expect[id][1]:
				found = true
		assert_true(found, "%s carries its modifier" % id)
	var purse: ModifierSource = ShatteredGallery.silver_boon("purse")
	var kinds: Dictionary = {}
	for modifier: Modifier in purse.modifiers:
		if modifier.kind == Modifier.Kind.STARTING_RESOURCES:
			kinds[modifier.value2] = true
	assert_eq(kinds.size(), 4, "one of each resource")


func test_a_head_start_puts_an_infrastructure_in_play() -> void:
	var game: GameState = GameFactory.blank_game(3)
	var player: PlayerState = game.players[0]
	player.deck.clear()
	player.deck.append(game.create_instance(GameFactory.infra(Affinity.Type.BEEFCAKE), 0))
	player.deck.append(game.create_instance(GameFactory.vanilla(1, 1), 0))
	var before: int = player.infrastructure.size()
	assert_true(game._put_infrastructure_from_deck(0))
	assert_eq(player.infrastructure.size(), before + 1)
	assert_false(player.infrastructure[player.infrastructure.size() - 1].exhausted, "ready to use")
	assert_false(game._put_infrastructure_from_deck(0), "no Infrastructure left in the deck")


func test_the_choice_pop_up_picks_one_boon_for_the_run() -> void:
	var event: DungeonEvent = ShatteredGallery.silver_event(11)
	assert_eq(event.choices.size(), 3)
	var run: DungeonRun = DungeonRun.enter(PlayerProfile.new(), _deck(), [] as Array[ModifierSource])
	assert_false(ShatteredGallery.has_silver(run))
	var result: EventResolver.Result = EventResolver.resolve(event, 0, run, null, 0)
	assert_true(result.ok)
	assert_eq(result.boons.size(), 1)
	assert_true(ShatteredGallery.has_silver(run), "the run carries its boon (offered once)")
	assert_false(DungeonCatalog.text_lines(event.choice_key(0)).is_empty(), "the button has its name")
	var map_screen: String = FileAccess.get_file_as_string("res://ui/dungeon/dungeon_map_screen.gd")
	assert_true(map_screen.contains("_offer_silver_reserve"), "the map opens the choice")


func _deck() -> Deck:
	var deck: Deck = Deck.new()
	for index: int in range(30):
		deck.cards.append(GameFactory.vanilla(2, 2))
	return deck
