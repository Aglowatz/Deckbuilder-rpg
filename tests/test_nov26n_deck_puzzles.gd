extends GutTest
## Nov 26 night (Part A2): Octavia's five deck-building puzzles at the Shuffle House (DeckPuzzles). The opponent plays no cards and is the
## same every attempt (across runs and seeds); its rules apply; the quest steps advance on a win; the recorded winning line wins.

const SIM: GDScript = preload("res://tools/deck_puzzle_sim_tool.gd")
const LINES_FILE: String = "res://data/arena/deck_puzzle_lines.json"
var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func after_each() -> void:
	Session.save_enabled = true


## A passive player: basic Infrastructure only, so nothing of the player's interferes and only the opponent acts.
func _passive(level: int) -> Dictionary:
	return {"label": "passive", "kind": "test", "level": level, "cards": {"BAS-B": 45}}


func _game_for(id: String, cards: Dictionary = {"BAS-B": 45}, seed_value: int = 11) -> GameState:
	var encounter: ArenaEncounter = DeckPuzzles.find(id)
	var profile: PlayerProfile = PlayerSpec.make(ZoneDecks.from_recipe(content, "test", cards), DeckPuzzles.level_of(id)).profile(content)
	return ArenaScenario.build_game(content, encounter, profile, ZoneDecks.from_recipe(content, "test", cards), seed_value)


func _units(game: GameState, seat: int) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for card: CardInstance in game.players[seat].field:
		if card.data.is_unit():
			result.append(card)
	return result


## The player passes every phase (after keeping the opening hand); the opponent's AI plays its own seat.
func _pass_until_turn(game: GameState, turn: int) -> void:
	var foe: AIPlayer = AIPlayer.for_foe(AIPersonality.balanced(), AIPlayer.Skill.BOSS)
	foe.deterministic = true
	var me: AIPlayer = AIPlayer.for_foe(AIPersonality.balanced(), AIPlayer.Skill.ELITE)
	me.deterministic = true
	var steps: int = 0
	while not game.is_over() and game.turn < turn and steps < 3000:
		steps += 1
		var who: int = game.awaiting_player()
		var action: GameAction = foe.choose_action(game) if who == 1 else (GameAction.pass_phase(0) if game.stage == GameState.Stage.PLAYING else me.choose_action(game))
		if not game.apply_action(action):
			# a decision a pass does not answer (a discard at the hand limit): the player's AI answers it
			if not game.apply_action(me.choose_action(game) if who == 0 else GameAction.pass_phase(who)):
				game.apply_action(GameAction.pass_phase(who))


# ---- the data -------------------------------------------------------------------------------------------------------------------


func test_five_puzzles_in_order_each_a_quest_level() -> void:
	var ids: Array[String] = DeckPuzzles.ids()
	assert_eq(ids.size(), 5, "five puzzles")
	var quests: Array[String] = []
	for index: int in range(ids.size()):
		var id: String = ids[index]
		assert_eq(DeckPuzzles.order_of(id), index + 1, "%s is in order" % id)
		assert_false(DeckPuzzles.hint(id).is_empty(), "%s has Octavia's hint" % id)
		assert_true(DraftArenaQuests.ids().has(DeckPuzzles.quest_of(id)), "%s sits in an arena quest" % id)
		quests.append(DeckPuzzles.quest_of(id))
		assert_true(EncounterModifiers.has_rules(ArenaScenario.rules_key(DeckPuzzles.find(id))), "%s has its house rules" % id)
		if index > 0:
			assert_gte(DeckPuzzles.level_of(id), DeckPuzzles.level_of(ids[index - 1]), "easiest first")
	assert_eq(quests, ["arena_open_table", "arena_spin_the_wheel", "arena_high_rollers", "arena_two_of_a_kind", "arena_full_house"])
	assert_true(EncounterModifiers.problems().is_empty(), "the rules load cleanly: %s" % str(EncounterModifiers.problems()))
	assert_true(EncounterScripts.problems().is_empty(), "the timed moments load cleanly: %s" % str(EncounterScripts.problems()))


func test_the_opponent_plays_no_cards() -> void:
	for id: String in DeckPuzzles.ids():
		var encounter: ArenaEncounter = DeckPuzzles.find(id)
		assert_true(encounter.deck_puzzle)
		assert_eq(encounter.first_player, 0, "the player always goes first")
		for card_id: Variant in encounter.enemy_recipe.keys():
			assert_true(str(card_id).begins_with("BAS-"), "%s's deck is basic Infrastructure only" % id)
		assert_eq(ArenaDefs.find(id), encounter, "the arena pipeline finds it")
		assert_false(ArenaDefs.all().has(encounter), "it is not one of the Clashatorium's bouts")


# ---- deterministic -----------------------------------------------------------------------------------------------------------------


func test_each_opponent_is_the_same_across_runs_and_seeds() -> void:
	for id: String in DeckPuzzles.ids():
		var first: Array[String] = []
		SIM.play(content, id, _passive(DeckPuzzles.level_of(id)), 101, first)
		for seed_value: int in [101, 202, 9999]:
			var again: Array[String] = []
			SIM.play(content, id, _passive(DeckPuzzles.level_of(id)), seed_value, again)
			assert_eq(again, first, "%s: the same sequence with seed %d" % [id, seed_value])
		assert_gt(first.size(), 3, "%s: the bout went on for some turns" % id)


func test_a_real_deck_replays_the_same_bout_for_the_same_seed() -> void:
	var id: String = DeckPuzzles.ids()[0]
	var spec: Dictionary = (DeckPuzzles.row(id).get("sim_decks", []) as Array)[0] as Dictionary
	var a: Array[String] = []
	var b: Array[String] = []
	SIM.play(content, id, spec, 77, a)
	SIM.play(content, id, spec, 77, b)
	assert_eq(a, b, "deck + seed = the same game")


# ---- the rules apply ---------------------------------------------------------------------------------------------------------------


func test_tea_garden_sprouts_grow_and_never_block() -> void:
	var game: GameState = _game_for("deckpuzzle_tea_garden")
	_pass_until_turn(game, 4)  # her turn 2 has started
	var sprouts: Array[CardInstance] = _units(game, 1)
	assert_eq(sprouts.size(), 2, "one sprout a turn")
	var sizes: Array[int] = []
	for sprout: CardInstance in sprouts:
		sizes.append(game.get_attack(sprout))
		assert_true(sprout.cannot_block, "her sprouts never block")
	sizes.sort()
	assert_eq(sizes, [1, 3], "the first sprout grew by two before the second came up")


func test_velvet_rope_bouncers_stop_after_last_call() -> void:
	var game: GameState = _game_for("deckpuzzle_velvet_rope")
	_pass_until_turn(game, 2)
	assert_eq(_units(game, 1).size(), 4, "four bouncers on his first turn")
	_pass_until_turn(game, 14)  # his turn 7 has started
	assert_eq(_units(game, 1).size(), 24, "his first six turns bring four each (the doors close on his turn 6, after the sixth group), then no more")
	assert_true(game.players[1].modifiers.has(Modifier.Kind.ALWAYS_BLOCK), "they block whenever they can")


func test_last_ride_ends_the_bout_on_her_seventh_turn() -> void:
	var game: GameState = _game_for("deckpuzzle_last_ride")
	_pass_until_turn(game, 1)
	assert_eq(_units(game, 1).size(), 4, "four ponies to start")
	_pass_until_turn(game, 20)
	assert_true(game.is_over(), "the music stopped")
	assert_eq(game.winner, 1, "still standing on her turn 7: the bout is lost")
	assert_true(game.turn <= 14, "on her 7th turn (game turn 14)")


func test_confetti_drain_cuts_both_ways() -> void:
	var game: GameState = _game_for("deckpuzzle_confetti")
	var hp: int = game.players[1].hp
	var mine: CardInstance = game.create_token(0, TokenRegistry.data("T-02"))
	game.destroy_unit(mine)
	game.check_state()
	assert_eq(game.players[1].hp, hp - 2, "one of YOUR units died: Tilda loses 2")
	var my_hp: int = game.players[0].hp
	var hers: CardInstance = game.create_token(1, TokenRegistry.data("T-02"))
	game.destroy_unit(hers)
	game.check_state()
	assert_eq(game.players[0].hp, my_hp - 2, "one of HER units died: you lose 2")


func test_all_in_hal_folds_to_a_full_table() -> void:
	var game: GameState = _game_for("deckpuzzle_all_in")
	for index: int in range(6):
		game.create_token(0, TokenRegistry.data("T-16"))
	game.check_state()
	assert_false(game.is_over(), "six is not a full table")
	game.create_token(0, TokenRegistry.data("T-16"))
	game.check_state()
	assert_true(game.is_over() and game.winner == 0, "seven units: Hal folds, you win")


# ---- the game: open, the quest step, the prize -------------------------------------------------------------------------------------


func test_tables_open_in_order_and_the_last_after_primm() -> void:
	var ids: Array[String] = DeckPuzzles.ids()
	assert_false(DeckPuzzles.is_open(ids[0], Session.flags), "the house is shut")
	Session.set_flag(StringName(DraftChallenges.ARENA_FLAG))
	assert_true(DeckPuzzles.is_open(ids[0], Session.flags), "the first table opens with the house")
	assert_false(DeckPuzzles.is_open(ids[1], Session.flags), "the second waits for the first")
	for index: int in range(4):
		Session.set_flag(DeckPuzzles.won_flag(ids[index]))
	assert_true(DeckPuzzles.is_open(ids[3], Session.flags))
	assert_false(DeckPuzzles.is_open(ids[4], Session.flags), "the last waits for Primm")
	Session.set_flag(MultiPathLock.FLAG_UNLOCKED)
	assert_true(DeckPuzzles.is_open(ids[4], Session.flags))


func test_a_win_pays_once_and_advances_its_quest_step() -> void:
	Session.set_flag(StringName(DraftChallenges.ARENA_FLAG))
	var id: String = DeckPuzzles.ids()[0]
	var quest: QuestData = null
	for each: QuestData in DraftArenaQuests.quests():
		if each.id == DeckPuzzles.quest_of(id):
			quest = each
	assert_not_null(quest)
	var last: QuestObjective = quest.objectives[quest.objectives.size() - 1]
	assert_true(last.text.contains(str(DeckPuzzles.row(id)["title"])), "the quest's last step is the table")
	assert_false(Condition.met(last.condition, Session.unlock_state()), "not yet")
	var gold: int = Session.gold
	var context: BattleContext = Session.make_arena_battle(id)
	assert_true(context.ai.deterministic, "the opponent plays deterministically in the game too")
	context.game._end_game(0, false)
	var result: Dictionary = Session.resolve_arena_battle(context)
	assert_true(bool(result["won"]) and bool(result["first_clear"]) and bool(result["deck_puzzle"]))
	assert_gte(Session.gold, gold + int((DeckPuzzles.row(id)["reward"] as Dictionary)["gold"]), "the prize is paid (and the quest's own reward if it completes)")
	assert_true(Condition.met(last.condition, Session.unlock_state()), "the quest step is met")
	assert_true(DeckPuzzles.is_open(DeckPuzzles.ids()[1], Session.flags), "the next table opens")
	var replay: BattleContext = Session.make_arena_battle(id)
	replay.game._end_game(0, false)
	var gold_after: int = Session.gold
	Session.resolve_arena_battle(replay)
	assert_eq(Session.gold, gold_after, "a replay pays nothing")
	var lost: BattleContext = Session.make_arena_battle(DeckPuzzles.ids()[1])
	lost.game._end_game(1, false)
	assert_false(bool(Session.resolve_arena_battle(lost)["won"]), "a loss can be retried")
	assert_false(Session.flag(DeckPuzzles.won_flag(DeckPuzzles.ids()[1])))


func test_a_completed_quest_stays_completed() -> void:
	# a save that finished Open Table before tonight keeps it finished, and can still play the table
	Session.set_flag(StringName(DraftChallenges.ARENA_FLAG))
	Session.quest_log.completed.append("arena_open_table")
	assert_true(Session.quest_log.is_completed("arena_open_table"))
	assert_true(DeckPuzzles.is_open(DeckPuzzles.ids()[0], Session.flags))


# ---- the recorded winning lines win -------------------------------------------------------------------------------------------------


func test_each_recorded_winning_line_wins() -> void:
	assert_true(FileAccess.file_exists(LINES_FILE), "the winning lines are recorded")
	var lines: Dictionary = (JSON.parse_string(FileAccess.get_file_as_string(LINES_FILE)) as Dictionary).get("lines", {}) as Dictionary
	for id: String in DeckPuzzles.ids():
		assert_true(lines.has(id), "%s has a recorded winning line" % id)
		if not lines.has(id):
			continue
		var line: Dictionary = lines[id] as Dictionary
		var spec: Dictionary = {}
		for deck: Variant in DeckPuzzles.row(id).get("sim_decks", []) as Array:
			if str((deck as Dictionary).get("label", "")) == str(line["deck"]):
				spec = deck as Dictionary
		assert_false(spec.is_empty(), "%s: the line's deck is listed" % id)
		var log: Array[String] = []
		var game: GameState = SIM.play(content, id, spec, int(line["seed"]), log)
		assert_true(DeckPuzzles.find(id).player_won(game), "%s: the recorded line (%s, seed %d) wins" % [id, str(line["deck"]), int(line["seed"])])
