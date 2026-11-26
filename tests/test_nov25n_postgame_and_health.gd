extends CardTestBase
## Nov 25 night, Part E (every postgame fight has rules of its own and shows them) and Part F (health for every Path: reworked and new
## cards, each in the card sources).

const POSTGAME_FOES: Array[String] = ["Intake Orderly", "Escaped Specimen", "Hybrid Specimen", "Siphon's Research Assistant", "Antechamber Sentry",
	"The Failed Experiment", "The Drain Warden", "Rival Lifter at Base Camp", "Squat Rack Sentinel", "The Ancient Spotter"]


func test_every_postgame_foe_has_rules_and_a_before_the_fight_panel() -> void:
	for foe: String in POSTGAME_FOES:
		assert_true(EncounterModifiers.has_rules(foe), "%s has rules of its own" % foe)
		assert_false(RuleBadges.for_encounter(EncounterModifiers.rules(foe)).is_empty(), "%s: its rules show as rows on the panel" % foe)
	for key: String in ["D-LAB", "S-BEEF", "S-GALLERY"]:
		var map: DungeonMap = MainDungeons.build_map(key)
		for node: DungeonMap.MapNode in map.nodes:
			if DungeonMap.is_battle_kind(node.kind) and not node.enemy_name.is_empty():
				assert_true(EncounterModifiers.has_rules(node.enemy_name), "%s %d %s" % [key, node.number, node.enemy_name])


func test_every_postgame_fight_is_different() -> void:
	var seen: Dictionary = {}
	for foe: String in POSTGAME_FOES:
		var names: Array[String] = []
		for rule: EncounterModifiers.Rule in EncounterModifiers.rules(foe):
			names.append(rule.name)
		names.sort()
		var key: String = ",".join(names)
		assert_false(seen.has(key), "%s does not repeat %s's rules" % [foe, str(seen.get(key, ""))])
		seen[key] = foe


func test_the_new_rule_kinds_work() -> void:
	var head_start: EncounterModifiers.Rule = EncounterModifiers.build_rule({"name": "x", "kind": "starting_infrastructure", "count": 2})
	assert_eq(head_start.modifiers[0].kind, Modifier.Kind.STARTING_INFRASTRUCTURE)
	assert_eq(head_start.modifiers[0].value, 2)
	var ban: EncounterModifiers.Rule = EncounterModifiers.build_rule({"name": "y", "kind": "ban_type", "type": "spell"})
	assert_eq(ban.modifiers[0].kind, Modifier.Kind.BANNED_CARD_TYPE)
	var game: GameState = _game()
	_energy(game)
	GameFactory.add_infrastructure_cards(game, 1, 3, Affinity.Type.BEEFCAKE)
	for i: int in range(6):
		game.players[1].deck.append(game.create_instance(GameFactory.infra(Affinity.Type.BEEFCAKE), 1))
	var before: int = game.players[1].infrastructure.size()
	game._put_infrastructure_from_deck(1)
	game._put_infrastructure_from_deck(1)
	assert_eq(game.players[1].infrastructure.size(), before + 2, "the Orderly's Pre-Filed puts two in play")


# ---- Part F ------------------------------------------------------------------------------------------------------------------------


func test_every_path_can_restore_hp() -> void:
	var healers: Dictionary = {}
	for card: CardData in CardSet.all_cards():
		if card.is_token or CardAvailability.is_enemy_only(card):
			continue
		var script: String = card.script_text
		if script.contains("gain(me,") or script.contains("nourish") or card.rules_text.contains("Nourish") or card.rules_text.contains("gain %s HP"):
			for path: Affinity.Type in card.paths():
				healers[int(path)] = int(healers.get(int(path), 0)) + 1
	for path: Affinity.Type in Affinity.colored_types():
		assert_gte(int(healers.get(int(path), 0)), 4, "%s has at least four cards that restore HP (%d)" % [Affinity.display_name(path), int(healers.get(int(path), 0))])


func test_the_reworked_cards() -> void:
	assert_eq(CardSet.card("B-13").rules_text, "Hustle.\n\nWhen this unit enters, gain 3 HP.")
	assert_eq(CardSet.card("B-23").rules_text, "Pay 1: gain 2 HP. Do this only once per turn.")
	assert_string_contains(CardSet.card("N-20").rules_text, "gain HP equal to the destroyed unit's defense")
	assert_string_contains(CardSet.card("N-10").rules_text, "+0/+1 and Nourish")
	assert_string_contains(CardSet.card("R-10").rules_text, "Eat garbage: gain 2 HP")
	assert_string_contains(CardSet.card("R-01").rules_text, "Eat garbage: gain 1 HP")
	var game: GameState = _game()
	_energy(game)
	game.players[0].max_hp = 40
	game.players[0].hp = 10
	_play(game, "B-13")
	assert_eq(game.players[0].hp, 13, "Hulking Hauler: +3 HP on entering")
	var bar: CardInstance = _field(game, 0, "B-23")
	assert_true(_activate(game, bar), "Snack Bar: pay 1")
	assert_eq(game.players[0].hp, 15)
	assert_false(_activate(game, bar), "once per turn")


func test_the_new_cards_heal_and_are_in_the_card_sources() -> void:
	var expected: Dictionary = {"B-39": "Cool-Down Stretch", "N-39": "Soul Collector", "R-38": "Compost Tea", "G-36": "Bone Broth Cook", "C-41": "Field Bandages"}
	for id: String in expected:
		var card: CardData = CardSet.card(id)
		assert_not_null(card, id)
		if card == null:
			continue
		assert_eq(card.display_name, expected[id])
		assert_eq(CardAvailability.kind_of(card), CardAvailability.Kind.GENERAL, "%s can be found: packs, shops, rewards, drafts" % id)
		assert_true(FileAccess.file_exists("res://assets/art/cards/%s.webp" % id), "%s has temporary art" % id)
		assert_true(FileAccess.get_file_as_string("res://docs/art/batch22.csv").contains(id), "%s has an art row in Batch 22" % id)
	var game: GameState = _game()
	_energy(game)
	game.players[0].max_hp = 40
	game.players[0].hp = 10
	_play(game, "B-39")
	assert_eq(game.players[0].hp, 14, "Cool-Down Stretch: +4")
	assert_eq(_count(game, 0, KIND.IRON), 1)
	var opp_hp: int = game.players[1].hp
	_play(game, "N-39")
	assert_eq(game.players[0].hp, 16, "Soul Collector: +2")
	assert_eq(game.players[1].hp, opp_hp - 2)
	_give(game, 0, KIND.GARBAGE, 2)
	_play(game, "R-38")
	assert_eq(game.players[0].hp, 21, "Compost Tea: +5 for two Garbage")
	var bandages: CardInstance = _field(game, 0, "C-41")
	var hand: int = game.players[0].hand.size()
	game.players[0].deck.append(game.create_instance(GameFactory.vanilla(1, 1), 0))
	assert_true(_activate(game, bandages))
	assert_eq(game.players[0].hp, 24)
	assert_eq(game.players[0].hand.size(), hand + 1)
	var draft_pool: Array[CardData] = DraftEngine.card_pool(Session.content, DraftEngine.start(Session.content, "open", [int(Affinity.Type.GOURMAND)] as Array[int], 20, 5))
	var ids: Array[String] = []
	for card: CardData in draft_pool:
		ids.append(card.id)
	assert_true(ids.has("G-36"), "Bone Broth Cook is in a Gourmand draft's pool")
