extends GutTest
## Parts G + H: the quiz rules and the matching game rules.

var story: ZoneStoryText


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.NECROCRAT)
	Session.level_track_grants = false  # these tests count gold and packs exactly; the reward track pays its own (test_level_track)
	story = ZoneStoryText.shared()


func test_quiz_first_pass_reward_scales_and_failing_pays_nothing() -> void:
	assert_eq(int(QuizRules.payout(story, 2, false)["gold"]), 0, "below the pass mark pays nothing")
	assert_gt(int(QuizRules.payout(story, 4, false)["gold"]), int(QuizRules.payout(story, 3, false)["gold"]), "a better first pass pays more")


func test_quiz_first_pass_pays_large_then_every_attempt_pays_small() -> void:
	var start: int = Session.gold
	QuizRules.apply(story, 2)
	assert_eq(Session.gold, start, "failing before the first pass pays nothing")
	QuizRules.apply(story, 4)
	var large: int = int(story.quiz_rewards[4]["gold"])
	assert_eq(Session.gold - start, large, "first pass pays the large reward")
	var after_large: int = Session.gold
	QuizRules.apply(story, 1)
	var small: int = int(story.quiz_repeat_reward["gold"])
	assert_eq(Session.gold - after_large, small, "any later completion pays the small reward")
	assert_lt(small, large)
	QuizRules.apply(story, 4)
	assert_eq(Session.gold - after_large, small * 2, "and again, forever")
	assert_true(Session.flag(DnaZone.FLAG_QUIZ_DONE))


func test_match_game_has_eight_pairs_and_matching_works() -> void:
	var game: MatchGame = MatchGame.new(123)
	assert_eq(game.slot_count(), 16)
	var counts: Dictionary = {}
	for icon: int in game.cards:
		counts[icon] = int(counts.get(icon, 0)) + 1
	assert_eq(counts.size(), 8)
	for icon: Variant in counts.keys():
		assert_eq(int(counts[icon]), 2)
	# Find a real pair and flip it.
	var first: int = 0
	var second: int = game.cards.find(game.cards[0], 1)
	assert_eq(game.flip(first), "first")
	assert_eq(game.flip(second), "match")
	game.resolve()
	assert_eq(game.pairs_found, 1)
	assert_eq(game.moves, 1)
	assert_eq(game.flip(first), "ignored", "matched cards cannot be flipped")


func test_match_game_perfect_play_scores_three_stars() -> void:
	var game: MatchGame = MatchGame.new(7)
	for icon: int in range(MatchGame.PAIRS):
		var a: int = game.cards.find(icon)
		var b: int = game.cards.find(icon, a + 1)
		game.flip(a)
		game.flip(b)
		game.resolve()
	assert_true(game.is_won())
	assert_eq(game.moves, 8)
	assert_eq(game.stars(), 3)


func test_match_game_loses_when_moves_run_out() -> void:
	var game: MatchGame = MatchGame.new(9)
	var a: int = 0
	var b: int = 0
	while b == a or game.cards[b] == game.cards[a]:
		b += 1
	for i: int in range(MatchGame.MAX_MOVES):
		assert_eq(game.flip(a), "first")
		assert_eq(game.flip(b), "mismatch")
		game.resolve()
	assert_true(game.is_lost())
	assert_eq(game.stars(), 0)
	assert_eq(game.flip(a), "ignored")
