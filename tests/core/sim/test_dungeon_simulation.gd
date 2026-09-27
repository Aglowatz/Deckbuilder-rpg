extends GutTest
## Part D verification: the tutorial AI actually attacks. Part C verification: the tutorial's
## reward picks (simulated via `reward_color`) grow the run's deck from 42 to 45 cards along the
## way. The full win-rate check across all four elements lives in
## `tools/run_dungeon_simulation.gd` -> docs/balance_report.md (too slow to run per GUT invocation).

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func test_enemy_attacks_at_least_once_across_the_tutorial() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var deck: Deck = CampaignStart.starter_deck(content, Affinity.Type.A)
	var ai: AIPlayer = AIPlayer.new(AIPersonality.balanced())
	var any_attacked: bool = false
	for seed_value: int in range(10):
		var result: DungeonSimulation.RunResult = DungeonSimulation.run_once(content, map, deck, ai, 42000 + seed_value, Affinity.Type.A)
		if result.enemy_attacks > 0:
			any_attacked = true
	assert_true(any_attacked, "the tutorial's Aggressive (tutorial) AI should attack at least once in 10 runs")


## A won run should have picked up all 3 on-element rewards (42 + 3 = 45) - unless the Hollow Well
## challenge along the way was lost, which costs a card (a pre-existing, intentional risk of that
## challenge, not something Part C changes), landing on 44 instead. See docs/design/
## open_questions.md D51.
func test_reward_picks_grow_the_deck_from_42_towards_45() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var deck: Deck = CampaignStart.starter_deck(content, Affinity.Type.B)
	assert_eq(deck.size(), 42)
	var ai: AIPlayer = AIPlayer.new(AIPersonality.balanced())
	var reached_45: bool = false
	for seed_value: int in range(20):
		var result: DungeonSimulation.RunResult = DungeonSimulation.run_once(content, map, deck, ai, 51000 + seed_value, Affinity.Type.B)
		assert_gte(result.final_deck_size, 42, "the deck never shrinks below the starter size")
		if result.won:
			assert_true(result.final_deck_size == 44 or result.final_deck_size == 45, "a full clear should be 45 (or 44 if the Hollow Well challenge cost a card)")
			if result.final_deck_size == 45:
				reached_45 = true
	assert_true(reached_45, "at least one of 20 runs should win, keep the challenge card, and reach 45 cards")


func test_no_reward_color_means_the_deck_never_grows() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var deck: Deck = CampaignStart.starter_deck(content, Affinity.Type.C)
	var ai: AIPlayer = AIPlayer.new(AIPersonality.balanced())
	var result: DungeonSimulation.RunResult = DungeonSimulation.run_once(content, map, deck, ai, 61001)
	assert_eq(result.final_deck_size, 42, "without a reward_color, the deck stays at its starting size")
