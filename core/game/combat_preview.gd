class_name CombatPreview
extends RefCounted
## Predicts what a combat will do before anyone commits to it: plays the attack (and the blocks) out on a clone of the game
## and reads the difference. The viewer's opponent's set traps are left out of the clone, so the preview never leaks a
## hidden trap (a trap can still change the real outcome). Rules are untouched: this only runs CombatResolver on a copy.


## The outcome of `attackers` attacking with `blocks` (attacker uid -> blocker uid), as seen by `viewer`.
## Returns {"units": {uid: {"damage": int, "dies": bool}}, "players": [damage to player 0, damage to player 1], "valid": bool}.
## Works in the attack step (`blocks` is then the defender's assumed blocks, usually none) and in the block step.
static func predict(state: GameState, viewer: int, attackers: Array[int], blocks: Dictionary) -> Dictionary:
	var result: Dictionary = {"units": {}, "players": [0, 0], "valid": false}
	if state.stage != GameState.Stage.PLAYING or state.phase != GameState.Phase.COMBAT:
		return result
	var trial: GameState = state.clone(false, 1 - viewer)
	if trial.combat_step == GameState.CombatStep.DECLARE_ATTACKERS:
		if attackers.is_empty() or not trial.declare_attackers(attackers):
			return result
	if not trial.is_over() and trial.combat_step == GameState.CombatStep.DECLARE_BLOCKERS:
		var legal: Dictionary = {}
		for key: Variant in blocks.keys():
			if trial.attackers.has(int(key)):
				legal[int(key)] = int(blocks[key])
		if not trial.declare_blockers(legal):
			trial.declare_blockers({})
	result["valid"] = true
	var players: Array = result["players"] as Array
	for index: int in range(2):
		players[index] = maxi(0, state.players[index].hp - trial.players[index].hp)
	var units: Dictionary = result["units"] as Dictionary
	for player: PlayerState in state.players:
		for card: CardInstance in player.units():
			var after: CardInstance = trial.find_permanent(card.uid)
			if after == null:
				units[card.uid] = {"damage": maxi(1, state.get_defense(card) - card.damage), "dies": true}
			elif after.damage > card.damage:
				units[card.uid] = {"damage": after.damage - card.damage, "dies": false}
	return result
