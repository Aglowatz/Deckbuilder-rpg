class_name DungeonSimulation
extends RefCounted
## Plays one full AI-vs-AI run through a dungeon map, carrying life and challenge outcomes
## between nodes exactly like a real playthrough (via `DungeonRun`), with no UI. Used to verify
## tutorial-dungeon balance (docs/balance_report.md) - see `tools/run_dungeon_simulation.gd`.

const MAX_STEPS_PER_GAME: int = 5000


class RunResult:
	extends RefCounted
	var won: bool = false
	var turns_played: int = 0
	var final_life: int = 0
	## The node title the run ended at, if it failed (empty when it won).
	var failed_at: String = ""


## Plays one dungeon encounter to completion inside `run` (life carries over via
## `DungeonRun.start_encounter`/`finish_encounter`). Returns the finished GameState.
static func play_encounter(
	run: DungeonRun,
	enemy: PlayerSetup,
	player_ai: AIPlayer,
	enemy_ai: AIPlayer,
	seed_value: int,
	first_player: int,
) -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = seed_value
	options.first_player = first_player
	options.turn_limit = 60
	options.record_events = false
	var game: GameState = run.start_encounter(enemy, null, options)
	var ais: Array[AIPlayer] = [player_ai, enemy_ai]
	var steps: int = 0
	while not game.is_over() and steps < MAX_STEPS_PER_GAME:
		steps += 1
		var who: int = game.awaiting_player()
		var action: GameAction = ais[who].choose_action(game)
		if not game.apply_action(action):
			if not game.apply_action(GameAction.pass_phase(who)):
				break
	return game


## Plays one full run through `map` with `deck`, controlled by `player_ai`. Enemy decks/AI
## personalities/challenge come from `content` via the map's own node data (so this plays
## whatever `TrialOfTheHollow.build_map()` currently describes).
static func run_once(
	content: ContentSet,
	map: DungeonMap,
	deck: Deck,
	player_ai: AIPlayer,
	seed_value: int,
) -> RunResult:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var run: DungeonRun = DungeonRun.enter(PlayerProfile.new(), deck, [] as Array[ModifierSource])
	var result: RunResult = RunResult.new()
	for map_node: DungeonMap.MapNode in map.nodes:
		match map_node.kind:
			DungeonMap.Kind.BATTLE, DungeonMap.Kind.BOSS:
				var enemy: PlayerSetup = TrialOfTheHollow.enemy_setup(content, map_node)
				var enemy_ai: AIPlayer = AIPlayer.new(TrialOfTheHollow.personality(content, map_node.ai_name))
				var first_player: int = 0 if map_node.tutorial else rng.randi_range(0, 1)
				var game: GameState = play_encounter(run, enemy, player_ai, enemy_ai, seed_value + map_node.id * 97 + 1, first_player)
				run.finish_encounter(game)
				result.turns_played += game.turn
				if run.is_over():
					result.failed_at = map_node.title
					result.final_life = run.life
					return result
			DungeonMap.Kind.CHALLENGE:
				var challenge: ChallengeData = _find_challenge(content, map_node.challenge_id)
				if challenge != null:
					ChallengeResolver.resolve(challenge, run, rng)
				if run.is_over():
					result.failed_at = map_node.title
					result.final_life = run.life
					return result
			DungeonMap.Kind.SHRINE:
				run.heal(map_node.heal_amount)
	result.won = not run.is_over()
	result.final_life = run.life
	return result


## Plays `runs` full dungeon runs and reports the win rate.
static func run_many(content: ContentSet, map: DungeonMap, deck: Deck, player_ai: AIPlayer, runs: int, base_seed: int = 5000) -> Array[RunResult]:
	var results: Array[RunResult] = []
	for i: int in range(runs):
		results.append(run_once(content, map, deck, player_ai, base_seed + i))
	return results


static func win_rate(results: Array[RunResult]) -> float:
	if results.is_empty():
		return 0.0
	var wins: int = 0
	for result: RunResult in results:
		if result.won:
			wins += 1
	return float(wins) / float(results.size())


static func _find_challenge(content: ContentSet, id: String) -> ChallengeData:
	for challenge: ChallengeData in content.challenges:
		if challenge.id == id:
			return challenge
	return null
