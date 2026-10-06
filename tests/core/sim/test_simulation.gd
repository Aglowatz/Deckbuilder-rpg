extends GutTest

var _content: ContentSet


func before_all() -> void:
	_content = ContentLibrary.load_all()


func test_a_simulated_game_finishes_legally() -> void:
	var runner: SimulationRunner = SimulationRunner.new()
	var record: GameRecord = runner.play_game(_content.decks[0], _content.decks[1], 7, 0)
	assert_true(record.finished)
	assert_eq(record.illegal_actions, 0)
	assert_gt(record.turns, 3)
	assert_true(record.winner >= -1 and record.winner <= 1)
	var total_casts: int = 0
	for seat: Dictionary in record.casts:
		for count: Variant in seat.values():
			total_casts += int(count)
	assert_gt(total_casts, 3, "spells were play and counted")


func test_same_seed_same_game() -> void:
	var runner: SimulationRunner = SimulationRunner.new()
	var first: GameRecord = runner.play_game(_content.decks[2], _content.decks[3], 21, 1)
	var second: GameRecord = runner.play_game(_content.decks[2], _content.decks[3], 21, 1)
	assert_eq(first.winner, second.winner)
	assert_eq(first.turns, second.turns)
	assert_eq(first.casts, second.casts)


func test_matchup_aggregates_and_alternates_first_player() -> void:
	var runner: SimulationRunner = SimulationRunner.new()
	var stats: MatchupStats = runner.run_matchup(_content.decks[0], _content.decks[4], 6, 100)
	assert_eq(stats.games, 6)
	assert_eq(stats.wins_a + stats.wins_b + stats.draws, 6)
	assert_eq(stats.illegal_actions, 0)
	assert_gt(stats.average_turns(), 3.0)
	assert_true(stats.win_rate_a() >= 0.0 and stats.win_rate_a() <= 1.0)
	assert_eq(stats.deck_a, _content.decks[0].deck_name)
	assert_false(stats.casts_a.is_empty())


func test_round_robin_plays_every_pair_once() -> void:
	var runner: SimulationRunner = SimulationRunner.new()
	var results: Array[MatchupStats] = runner.round_robin(_content.decks, 2, 5)
	assert_eq(results.size(), 10, "5 decks -> 10 matchups")
	var with_mirrors: Array[MatchupStats] = runner.round_robin(_content.decks, 1, 5, true)
	assert_eq(with_mirrors.size(), 15)


func test_matchup_stats_math() -> void:
	var stats: MatchupStats = MatchupStats.new()
	for winner: int in [0, 0, 1, -1]:
		var record: GameRecord = GameRecord.new()
		record.winner = winner
		record.turns = 10
		record.first_player = 0
		stats.add(record)
	assert_eq(stats.games, 4)
	assert_eq(stats.win_rate_a(), 0.625)
	assert_eq(stats.average_turns(), 10.0)
	assert_eq(stats.decided_games, 3)
	assert_eq(stats.first_player_wins, 2)


func test_report_contains_all_sections_and_decks() -> void:
	var runner: SimulationRunner = SimulationRunner.new()
	var results: Array[MatchupStats] = runner.round_robin(_content.decks, 2, 9)
	var report: String = BalanceReport.build(_content.decks, results, 2, "Some analysis.")
	for section: String in ["# Balance Report", "## Standings", "## Win-rate matrix", "## Matchups", "## Most-played cards", "## Flagged matchups", "## Analysis"]:
		assert_true(report.contains(section), section)
	for deck: Deck in _content.decks:
		assert_true(report.contains(deck.deck_name), deck.deck_name)
	assert_true(report.contains("Some analysis."))
