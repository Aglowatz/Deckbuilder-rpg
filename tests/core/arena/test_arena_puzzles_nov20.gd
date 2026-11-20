extends GutTest
## Fable Nov 20, Part 7: the Arena puzzles, rebuilt. Each puzzle (Bronze to Diamond) is checked by `PuzzleSolver`, a full search over
## the player's legal plays for the turn on the real engine, against every way the opponent can block:
##  - it can be won this turn;
##  - it has exactly ONE solution (the same plays in another order, or a spare harmless play added, are the same solution);
##  - that solution is the intended one (the cards the design notes name);
##  - no decoy is part of it;
##  - every naive line (just attacking, the obvious card first...) fails: no win is left after it;
##  - and the solver's line, replayed action by action on a fresh game, really ends with the opponent at 0 HP.
## One test per puzzle. The Diamond puzzle's search is the long one (about 110 000 positions, a few minutes).

## The cards the one solution must play or use, per puzzle (words as the solver prints them).
const INTENDED: Dictionary = {
	"arena_lethal_lunch": ["Play Vigor Mortis on Beefy Bouncer", "Play Flex on 'Em", "Attack with Beefy Bouncer, Gym Bro"],
	"arena_hold_the_line": ["Play Shaker Bottle", "Use Shaker Bottle on Gym Bro", "Play Sir Loin, Prime Cut on their Tavern Regular", "Attack with Gym Bro, Sir Loin, Prime Cut"],
	"arena_zero_to_hero": ["Play Become Useful at Work (paying with Skeleton Clerk)", "Play Plague of Rats", "Use Necro Rat, Chairman of the Sewer Board on their Old Kingdom Automaton", "Attack with Necro Rat, Chairman of the Sewer Board, Rat King Bureaucrat"],
	"arena_final_bell": ["Use Millstone Pusher (2nd ability)", "Play GLP-100", "Use GLP-100 on Un-Deadlifter", "Play Flex on 'Em", "Play Death Grip", "Play Dead Weight on the opponent (paying with Un-Deadlifter)"],
}
const MIN_STEPS: Dictionary = {"arena_lethal_lunch": 2, "arena_hold_the_line": 3, "arena_zero_to_hero": 4, "arena_final_bell": 5}
const MIN_DECOYS: Dictionary = {"arena_lethal_lunch": 1, "arena_hold_the_line": 1, "arena_zero_to_hero": 2, "arena_final_bell": 2}


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func _check(puzzle_id: String) -> void:
	var encounter: ArenaEncounter = ArenaDefs.find(puzzle_id)
	assert_not_null(encounter, puzzle_id)
	assert_true(encounter.is_puzzle())
	assert_eq(encounter.goal, ArenaEncounter.Goal.WIN_THIS_TURN, "one turn")
	var report: PuzzleCheck.Report = PuzzleCheck.run(Session.content, encounter)
	gut.p("%s: %d positions, %d winning lines, %d solution(s)" % [puzzle_id, report.states, report.winning_lines, report.solutions.size()])
	assert_true(report.complete, "the search covered every line")
	assert_true(report.solvable, "%s can be won this turn" % puzzle_id)
	assert_eq(report.solutions.size(), 1, "%s has exactly one solution: %s" % [puzzle_id, str(report.solutions)])
	if report.solutions.size() != 1:
		return
	var key: String = report.solutions[0]
	for step: String in INTENDED[puzzle_id] as Array:
		assert_string_contains(key, step, "the solution is the intended one")
	# decoys: named in the notes, on the table, and in no solution
	assert_gte(encounter.decoys.size(), int(MIN_DECOYS[puzzle_id]), "decoys on the table")
	for name: Variant in report.decoys_used.keys():
		assert_false(bool(report.decoys_used[name]), "%s: the decoy %s is in no solution" % [puzzle_id, str(name)])
	# naive lines: each fails
	assert_gte(encounter.naive_lines.size(), 3, "naive lines are written down")
	for name: Variant in report.naive.keys():
		assert_eq(str(report.naive[name]), "fails", "%s: the naive line '%s'" % [puzzle_id, str(name)])
	assert_true(report.naive.has("Just attack"), "attacking with everything is one of them")
	# the solver's own line, replayed on a fresh game with the opponent blocking at its worst for the player
	var line: PackedStringArray = report.solution_lines[0]
	assert_eq(PuzzleCheck.try_line(Session.content, encounter, Array(line)), "WINS", "replayed step by step: %s" % " -> ".join(line))
	var plays: int = 0
	for step: String in line:
		plays += 1 if step != "No attack" else 0
	assert_gte(plays, int(MIN_STEPS[puzzle_id]), "the tier's number of steps")


func test_bronze_back_from_the_dead_back_to_the_gym() -> void:
	_check("arena_lethal_lunch")


func test_silver_mise_en_place() -> void:
	_check("arena_hold_the_line")


func test_gold_the_chairman_needs_a_quorum() -> void:
	_check("arena_zero_to_hero")


func test_diamond_the_heaviest_paperwork() -> void:
	_check("arena_final_bell")


func test_every_puzzle_combines_two_paths_and_says_so() -> void:
	var pairs: Dictionary = {}
	var steps_by_tier: Dictionary = {}
	for encounter: ArenaEncounter in ArenaDefs.all():
		if not encounter.is_puzzle():
			continue
		assert_gte(encounter.paths.size(), 2, "%s combines at least two Paths" % encounter.id)
		pairs[" + ".join(PackedStringArray(encounter.paths))] = true
		for text: String in [encounter.title(), encounter.blurb(), encounter.rules(), encounter.lesson, encounter.synergy]:
			assert_gt(text.length(), 10, "%s: every text is written" % encounter.id)
		assert_false(encounter.blurb().contains(encounter.solution[0].substr(0, 20)), "the brief does not give the first step away")
		steps_by_tier[encounter.tier] = encounter.solution.size()
		# every Path named is really on the table: a card of that Path, or a dual card with it, in hand, on the field or in the pile
		var player: Dictionary = encounter.preset["player"] as Dictionary
		var ids: Array = (player.get("hand", {}) as Dictionary).keys() + (player.get("field", {}) as Dictionary).keys() + (player.get("refuse", {}) as Dictionary).keys()
		var multi: bool = false
		for path_name: String in encounter.paths:
			var found: bool = false
			for id: Variant in ids:
				var card: CardData = ArenaScenario._preset_card(Session.content, str(id))
				assert_not_null(card, "%s: %s is a real card" % [encounter.id, str(id)])
				if card == null:
					continue
				multi = multi or card.is_multipath()
				for path: Affinity.Type in card.paths():
					found = found or Affinity.display_name(path) == path_name
			assert_true(found, "%s: a %s card is on the table" % [encounter.id, path_name])
		assert_true(multi, "%s uses a multi-Path card" % encounter.id)
	assert_eq(pairs.size(), 4, "four puzzles, four different combinations of Paths: %s" % str(pairs.keys()))
	assert_eq(steps_by_tier.size(), 4, "one puzzle in each tier, Bronze to Diamond")
	assert_lt(int(steps_by_tier[1]), int(steps_by_tier[3]) + 1, "harder by tier")
	assert_gte(int(steps_by_tier[4]), int(steps_by_tier[3]), "Diamond has the most steps")


func test_the_puzzles_keep_their_ids_tiers_and_prizes() -> void:
	var expected: Dictionary = {
		"arena_lethal_lunch": [1, {"gold": 120, "xp": 40, "pack": "general_1"}],
		"arena_hold_the_line": [2, {"gold": 150, "xp": 80, "pack": "general_2"}],
		"arena_zero_to_hero": [3, {"gold": 200, "xp": 120, "pack": "general_2", "item": "energy_draught"}],
		"arena_final_bell": [4, {"gold": 300, "xp": 150, "pack": "general_2", "essence": {"primary": 6}}],
	}
	for id: String in expected.keys():
		var encounter: ArenaEncounter = ArenaDefs.find(id)
		assert_eq(encounter.tier, int((expected[id] as Array)[0]), id)
		assert_eq(encounter.reward, (expected[id] as Array)[1] as Dictionary, "%s keeps its prize" % id)
	# the Arena's battles are untouched (the owner tunes them by hand)
	for id: String in ["arena_warmup", "arena_neutral_mile", "arena_spells_only", "arena_four_fists", "arena_marshal", "arena_four_fists_unbound"]:
		assert_false(ArenaDefs.find(id).is_puzzle(), id)
	assert_eq(ArenaDefs.find("arena_four_fists").enemy_hp, 33)
	assert_eq(ArenaDefs.find("arena_marshal").enemy_hp, 46)
	assert_eq(ArenaDefs.find("arena_four_fists_unbound").enemy_hp, 54)


func test_a_solved_puzzle_says_what_you_just_did() -> void:
	var encounter: ArenaEncounter = ArenaDefs.find("arena_lethal_lunch")
	assert_string_contains(encounter.lesson, "Hustle")
	var screen: ArenaScreen = ArenaScreen.new()
	assert_string_contains(FileAccess.get_file_as_string("res://ui/town/arena_screen.gd"), "What you just did: %s")
	assert_string_contains(FileAccess.get_file_as_string("res://ui/battle/battle_screen.gd"), "PuzzleLesson")
	screen.free()
	assert_eq(encounter.title(), "Back from the Dead, Back to the Gym")


func test_the_solver_counts_a_reordered_line_once() -> void:
	var a: PackedStringArray = ["Play A", "Play B on X", "Attack with X, Y", "Play C"]
	var b: PackedStringArray = ["Play B on X", "Play A", "Attack with X, Y", "Play C"]
	assert_eq(PuzzleSolver.solution_key(a), PuzzleSolver.solution_key(b), "the same plays before combat in another order")
	var with_spare: String = PuzzleSolver.solution_key(PackedStringArray(["Play A", "Play B on X", "Play D", "Attack with X, Y", "Play C"]))
	var moved: String = PuzzleSolver.solution_key(PackedStringArray(["Play A", "Attack with X, Y", "Play B on X", "Play C"]))
	var other: String = PuzzleSolver.solution_key(PackedStringArray(["Play E", "Attack with X"]))
	var minimal: Array[String] = PuzzleSolver._minimal([PuzzleSolver.solution_key(a), with_spare, moved, other])
	assert_eq(minimal.size(), 2, "a spare play added, or a play moved after combat, is not a new solution: %s" % str(minimal))
