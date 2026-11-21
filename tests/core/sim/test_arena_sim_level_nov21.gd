extends GutTest
## Fable Nov 21 review (Part 3.2): the balance sim played Diamond Sand (the Arena's tier 4, added Nov 19) with a level-1 player, because
## the tier has no entry in ProgressionModel.LEVELS. The sim now assumes the postgame level for it. The game's own use of that table (the
## prize multiplier of a first clear) is untouched: a tier with no entry still pays its printed prize.


func test_the_sim_plays_every_arena_bout_at_a_real_level() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	var bouts: int = 0
	for spec: EncounterSpec in EncounterCatalog.all(content):
		if spec.group != "arena":
			continue
		bouts += 1
		assert_gte(spec.expected_level, 8, "%s is simulated at level %d" % [spec.title, spec.expected_level])
		if spec.id == "arena:arena_four_fists_unbound":
			assert_eq(spec.expected_level, EncounterCatalog.ARENA_SIM_FALLBACK_LEVEL, "Diamond Sand is simulated at the postgame level")
	assert_eq(bouts, 6, "the six Arena battles (the four puzzles are boards, not balance)")


func test_the_games_prize_multiplier_is_untouched() -> void:
	assert_false(ProgressionModel.LEVELS.has("arena:4"), "no level was added to the table the prizes read")
	assert_eq(ArenaScenario.prize_factor(4, 30), 1.0, "Diamond Sand pays its printed prize at any level")
	assert_eq(ArenaScenario.prize_factor(1, 16), 2.0, "Bronze Sand at level 16 still pays double (16 / 8)")
