class_name PuzzleCheck
extends RefCounted
## Fable Nov 20 (Part 7): what the tests and the report ask about one Arena puzzle, on top of `PuzzleSolver`: is it solvable, how many
## solutions does it have, is the intended line among them, does any solution use a decoy, and does each naive line fail.
## A naive line is {"name": ..., "steps": [...]} with the solver's own words for a step ("Play Dry Scoop on Gym Bro",
## "Use Kettlebell on their Riot Shield Recruit", "Use Iron on Gym Bro", "Attack with *" for every unit that can attack).


class Report:
	extends RefCounted
	var id: String = ""
	var solvable: bool = false
	var complete: bool = true
	var states: int = 0
	var winning_lines: int = 0
	var solutions: Array[String] = []
	var solution_lines: Array[PackedStringArray] = []
	## decoy card name -> true when some solution plays or uses it (it must not)
	var decoys_used: Dictionary = {}
	## naive line name -> "fails" / "WINS" / "cannot be played: <step>"
	var naive: Dictionary = {}
	var board: PackedStringArray = []

	func ok() -> bool:
		if not solvable or not complete:
			return false
		for used: Variant in decoys_used.values():
			if bool(used):
				return false
		for verdict: Variant in naive.values():
			if str(verdict) != "fails":
				return false
		return true


static func build(content: ContentSet, encounter: ArenaEncounter) -> GameState:
	var profile: PlayerProfile = PlayerProfile.new()
	return ArenaScenario.build_game(content, encounter, profile, null, 7)


static func run(content: ContentSet, encounter: ArenaEncounter) -> Report:
	var report: Report = Report.new()
	report.id = encounter.id
	var game: GameState = build(content, encounter)
	report.board = board_lines(game)
	var solver: PuzzleSolver = PuzzleSolver.new()
	var result: PuzzleSolver.Result = solver.solve(game)
	report.solvable = result.solvable
	report.complete = result.complete
	report.states = result.states
	report.winning_lines = result.lines.size()
	report.solutions = result.minimal
	report.solution_lines = result.minimal_lines()
	for decoy: Dictionary in encounter.decoys:
		var name: String = str(decoy.get("card", ""))
		var used: bool = false
		for key: String in result.minimal:
			used = used or key.contains("Play %s" % name) or key.contains("Use %s" % name)
		report.decoys_used[name] = used
	for line: Dictionary in encounter.naive_lines:
		# the same solver: what it already knows about this puzzle's positions answers most of a naive line at once
		report.naive[str(line.get("name", "?"))] = try_line(content, encounter, line.get("steps", []) as Array, solver)
	return report


## Plays `steps` from the puzzle's start and says whether the player can still win afterwards.
static func try_line(content: ContentSet, encounter: ArenaEncounter, steps: Array, known: PuzzleSolver = null) -> String:
	var game: GameState = build(content, encounter)
	var solver: PuzzleSolver = known if known != null else PuzzleSolver.new()
	solver._hero = 0
	for step: Variant in steps:
		var wanted: String = str(step)
		if game.players[1].hp <= 0:
			return "WINS"
		if wanted.begins_with("Attack with") or wanted == "No attack":
			if game.phase == GameState.Phase.MAIN1:
				game.advance_phase()
		var found: GameAction = null
		for action: GameAction in solver.hero_actions(game):
			var word: String = solver.describe(game, action)
			if word == wanted or (wanted == "Attack with *" and action.type == GameAction.Type.DECLARE_ATTACKERS and action.uids.size() == game.possible_attackers(0).size() and not action.uids.is_empty()):
				found = action
				break
		if found == null or not game.apply_action(found):
			return "cannot be played: %s" % wanted
		# the opponent blocks as badly for the player as it can
		while game.awaiting_player() == 1 and not game.is_over() and game.players[1].hp > 0:
			var worst: GameAction = null
			for answer: GameAction in solver.foe_actions(game):
				var trial: GameState = game.clone(false)
				if trial.apply_action(answer) and not solver.can_win(trial):
					worst = answer
					break
				if worst == null:
					worst = answer
			if worst == null or not game.apply_action(worst):
				break
	if game.players[1].hp <= 0:
		return "WINS"
	return "WINS" if solver.can_win(game) else "fails"


## The start position in words (for the report and for checking that everything needed is visible).
static func board_lines(game: GameState) -> PackedStringArray:
	var lines: PackedStringArray = []
	for index: int in [0, 1]:
		var player: PlayerState = game.players[index]
		var who: String = "You" if index == 0 else "Opponent"
		var energy: Dictionary = {}
		for card: CardInstance in player.infrastructure:
			energy[card.data.display_name] = int(energy.get(card.data.display_name, 0)) + 1
		var field: PackedStringArray = []
		for card: CardInstance in player.field:
			field.append("%s %d/%d" % [card.data.display_name, game.get_attack(card), game.get_defense(card)] if card.data.is_unit() else card.data.display_name)
		var hand: PackedStringArray = []
		for card: CardInstance in player.hand:
			hand.append(card.data.display_name)
		var extras: PackedStringArray = []
		for card: CardInstance in player.resources:
			extras.append(card.data.display_name)
		for card: CardInstance in player.tokens:
			extras.append(card.data.display_name)
		var refuse: PackedStringArray = []
		for card: CardInstance in player.refuse_pile:
			refuse.append(card.data.display_name)
		lines.append("%s: %d HP | energy %s | field: %s | hand: %s | resources: %s | Refuse Pile: %s" % [who, player.hp, str(energy), ", ".join(field), ", ".join(hand), ", ".join(extras), ", ".join(refuse)])
	return lines
