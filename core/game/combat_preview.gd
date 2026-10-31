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
				# Overnight Oct 30-31, Part 4: the HP the unit keeps (the badge says "-2  3 left").
				units[card.uid] = {"damage": after.damage - card.damage, "dies": false, "hp_left": trial.get_defense(after) - after.damage}
	return result


## Overnight Oct 30-31, Part 4 (attack previews): the result of ONE of the viewer's own actions - a card played on a target, an ability, a
## Resource spent on a target - played out on a clone (the opponent's set traps left out, as above). Only the viewer's action is
## resolved; nothing about the opponent's plans is read or shown. Returns predict's shape plus, per changed unit, its stats before and
## after ({"damage", "dies", "attack_before", "defense_before", "attack", "defense", "hp_left"}) and "heals" per player.
static func predict_action(state: GameState, viewer: int, action: GameAction) -> Dictionary:
	var result: Dictionary = {"units": {}, "players": [0, 0], "heals": [0, 0], "valid": false}
	if state.stage != GameState.Stage.PLAYING or action == null or action.player != viewer:
		return result
	var trial: GameState = state.clone(false, 1 - viewer)
	if not trial.apply_action(action):
		return result
	result["valid"] = true
	var players: Array = result["players"] as Array
	var heals: Array = result["heals"] as Array
	for index: int in range(2):
		var change: int = trial.players[index].hp - state.players[index].hp
		players[index] = maxi(0, -change)
		heals[index] = maxi(0, change)
	var units: Dictionary = result["units"] as Dictionary
	for player: PlayerState in state.players:
		for card: CardInstance in player.units():
			var entry: Dictionary = unit_change(state, card, trial, trial.find_permanent(card.uid))
			if not entry.is_empty():
				units[card.uid] = entry
	return result


## One unit before (`card` in `state`) and after (`after` in `trial`, null when it left the board): {} when nothing changed.
static func unit_change(state: GameState, card: CardInstance, trial: GameState, after: CardInstance) -> Dictionary:
	var attack_before: int = state.get_attack(card)
	var defense_before: int = state.get_defense(card)
	var hp_before: int = defense_before - card.damage
	if after == null:
		return {"damage": maxi(1, hp_before), "dies": true, "attack_before": attack_before, "defense_before": defense_before, "attack": 0, "defense": 0, "hp_left": 0}
	var attack: int = trial.get_attack(after)
	var defense: int = trial.get_defense(after)
	var damage: int = maxi(0, after.damage - card.damage)
	if damage == 0 and attack == attack_before and defense == defense_before and after.damage == card.damage:
		return {}
	return {"damage": damage, "dies": false, "attack_before": attack_before, "defense_before": defense_before, "attack": attack, "defense": defense, "hp_left": defense - after.damage}


## The badge text of a unit change: "-3 (1 left)", "+2/+1 -> 4/3", "-1/-0 -> 1/2", "dies".
static func badge_text(entry: Dictionary) -> String:
	if entry.is_empty():
		return ""
	if bool(entry.get("dies", false)):
		return "-%d" % int(entry["damage"])
	var parts: Array[String] = []
	var damage: int = int(entry.get("damage", 0))
	if damage > 0:
		parts.append("-%d (%d left)" % [damage, int(entry.get("hp_left", 0))])
	var d_attack: int = int(entry.get("attack", 0)) - int(entry.get("attack_before", 0))
	var d_defense: int = int(entry.get("defense", 0)) - int(entry.get("defense_before", 0))
	if entry.has("attack") and (d_attack != 0 or d_defense != 0):
		parts.append("%s%d/%s%d -> %d/%d" % ["+" if d_attack >= 0 else "", d_attack, "+" if d_defense >= 0 else "", d_defense, int(entry["attack"]), int(entry["defense"])])
	return "  ".join(parts)
