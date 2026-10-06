class_name DungeonSimulation
extends RefCounted
## Plays one full AI-vs-AI run through a dungeon map, carrying HP and challenge outcomes
## between nodes exactly like a real playthrough (via `DungeonRun`), with no UI. Used to verify
## tutorial-dungeon balance (docs/balance_report.md) - see `tools/run_dungeon_simulation.gd`.

const MAX_STEPS_PER_GAME: int = 5000


class RunResult:
	extends RefCounted
	var won: bool = false
	var turns_played: int = 0
	var final_hp: int = 0
	## The node title the run ended at, if it failed (empty when it won).
	var failed_at: String = ""
	## How many times the enemy AI actually declared at least one attacker, across every
	## encounter in the run (Part D: confirms tutorial opponents don't just sit there).
	var enemy_attacks: int = 0
	## The run's deck size when it ended (Part C: starts at 42, should reach 45 by a won boss
	## fight via the 3 on-element reward picks - see `reward_color` on `run_once`).
	var final_deck_size: int = 0


## Plays one dungeon encounter to completion inside `run` (HP carries over via
## `DungeonRun.start_encounter`/`finish_encounter`). Returns the finished GameState. `counters`,
## if given, has `counters.enemy_attacks` incremented once per real enemy attack declaration.
static func play_encounter(
	run: DungeonRun,
	enemy: PlayerSetup,
	player_ai: AIPlayer,
	enemy_ai: AIPlayer,
	seed_value: int,
	first_player: int,
	counters: RunResult = null,
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
		if who == 1 and counters != null and action.type == GameAction.Type.DECLARE_ATTACKERS and not action.uids.is_empty():
			counters.enemy_attacks += 1
		if not game.apply_action(action):
			if not game.apply_action(GameAction.pass_phase(who)):
				break
	return game


## Plays one full run through `map` with `deck`, controlled by `player_ai`. Enemy decks/AI
## personalities/challenge come from `content` via the map's own node data (so this plays
## whatever `TrialOfTheHollow.build_map()` currently describes).
##
## `reward_color`, when given, simulates Part C's tutorial reward picks exactly like a real
## playthrough: after every won BATTLE/BOSS node, one card is drawn from
## `RewardGenerator.card_choices_for_color(reward_color, ...)` and added to the run's deck
## immediately (`DungeonRun.gain_card`), so later encounters actually play with the grown deck.
static func run_once(
	content: ContentSet,
	map: DungeonMap,
	deck: Deck,
	player_ai: AIPlayer,
	seed_value: int,
	reward_color: Affinity.Type = Affinity.Type.NEUTRAL,
) -> RunResult:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var run: DungeonRun = DungeonRun.enter(PlayerProfile.new(), deck, [TrialOfTheHollow.deck_size_waiver()] as Array[ModifierSource])
	var result: RunResult = RunResult.new()
	for map_node: DungeonMap.MapNode in map.nodes:
		match map_node.kind:
			DungeonMap.Kind.BATTLE, DungeonMap.Kind.BOSS:
				var enemy: PlayerSetup = TrialOfTheHollow.enemy_setup(content, map_node)
				var enemy_ai: AIPlayer = AIPlayer.new(TrialOfTheHollow.personality(content, map_node.ai_name))
				var first_player: int = 0 if map_node.tutorial else rng.randi_range(0, 1)
				var game: GameState = play_encounter(run, enemy, player_ai, enemy_ai, seed_value + map_node.id * 97 + 1, first_player, result)
				run.finish_encounter(game)
				result.turns_played += game.turn
				if run.is_over():
					result.failed_at = map_node.title
					result.final_hp = run.hp
					result.final_deck_size = run.current_deck().size()
					return result
				if reward_color != Affinity.Type.NEUTRAL:
					var picks: Array[CardData] = RewardGenerator.card_choices_for_color(content, reward_color, rng, map_node.card_choices, map_node.kind == DungeonMap.Kind.BOSS)
					if not picks.is_empty():
						run.gain_card(picks[0])
			DungeonMap.Kind.CHALLENGE:
				var challenge: ChallengeData = _find_challenge(content, map_node.challenge_id)
				if challenge != null:
					ChallengeResolver.resolve(challenge, run, rng)
				if run.is_over():
					result.failed_at = map_node.title
					result.final_hp = run.hp
					result.final_deck_size = run.current_deck().size()
					return result
			DungeonMap.Kind.SHRINE:
				run.heal(map_node.heal_amount)
	result.won = not run.is_over()
	result.final_hp = run.hp
	result.final_deck_size = run.current_deck().size()
	return result


## Plays `runs` full dungeon runs and reports the win rate.
static func run_many(content: ContentSet, map: DungeonMap, deck: Deck, player_ai: AIPlayer, runs: int, base_seed: int = 5000, reward_color: Affinity.Type = Affinity.Type.NEUTRAL) -> Array[RunResult]:
	var results: Array[RunResult] = []
	for i: int in range(runs):
		results.append(run_once(content, map, deck, player_ai, base_seed + i, reward_color))
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
