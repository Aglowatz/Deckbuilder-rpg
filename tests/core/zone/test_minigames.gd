extends GutTest
## Parts G + H: the quiz rules and the matching game rules.

var story: ZoneStoryText


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.D)
	story = ZoneStoryText.shared()


func test_quiz_has_four_questions_each_with_a_valid_correct_answer() -> void:
	assert_eq(story.quiz_questions.size(), 4)
	for question: Dictionary in story.quiz_questions:
		assert_eq((question["a"] as Array).size(), 4)
		assert_between(int(question["correct"]), 0, 3)


func test_every_quiz_answer_is_discoverable_in_the_zone_text() -> void:
	# The correct answer's key words must appear in at least one sign/memo/NPC line.
	var haystack: String = ""
	for key: Variant in story.lines.keys():
		haystack += " ".join(story.get_lines(str(key))).to_lower() + " "
	for question: Dictionary in story.quiz_questions:
		var answer: String = str((question["a"] as Array)[int(question["correct"])]).to_lower().replace("\"", "")
		var needle: String = answer.trim_suffix(".")
		assert_true(haystack.contains(needle), "answer '%s' appears in the zone's signs/memos/dialogue" % needle)


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


func test_quiz_scoring() -> void:
	var answers: Array[int] = []
	for question: Dictionary in story.quiz_questions:
		answers.append(int(question["correct"]))
	assert_eq(QuizRules.score(story, answers), 4)
	answers[0] = (answers[0] + 1) % 4
	assert_eq(QuizRules.score(story, answers), 3)


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


func test_match_first_win_is_large_then_every_win_is_small() -> void:
	var start: int = Session.gold
	var first: Dictionary = MatchGame.apply_result(1)
	assert_true(bool(first["first_win"]))
	var expected_first: int = int(MatchGame.STAR_REWARDS[1]["gold"]) * 2 + int(MatchGame.FIRST_WIN_BONUS["gold"])
	assert_eq(Session.gold - start, expected_first)
	var after_first: int = Session.gold
	var again: Dictionary = MatchGame.apply_result(1)
	assert_false(bool(again["first_win"]))
	assert_eq(int(again["gold"]), int(MatchGame.REPEAT_REWARD["gold"]), "any later win pays the small reward")
	assert_lt(int(again["gold"]), expected_first)
	MatchGame.apply_result(3)
	assert_eq(Session.gold - after_first, int(MatchGame.REPEAT_REWARD["gold"]) * 2)
	assert_eq(int(MatchGame.apply_result(0)["gold"]), 0, "a loss pays nothing")
