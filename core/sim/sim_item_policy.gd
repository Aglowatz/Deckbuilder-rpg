class_name SimItemPolicy
extends RefCounted
## Rebalance Part B: how the simulated player spends consumables - a few sensible rules a real player would follow, run at the start
## of each of their main phases before the AI acts. `items` is the live bag (item id -> uses left) and is spent in place.

const LOW_HP: int = 4


## Uses at most one item; true when one was used. Call again until false (at most once per item kind per turn).
static func act(game: GameState, player_index: int, items: Dictionary, content: ContentSet, used_this_turn: Dictionary) -> bool:
	if items.is_empty() or game.is_over() or not game.in_main_phase() or game.active != player_index:
		return false
	var player: PlayerState = game.players[player_index]
	var ids: Array = items.keys()
	ids.sort()
	for id: Variant in ids:
		if int(items[id]) <= 0 or used_this_turn.has(id):
			continue
		var item: ItemData = content.item(str(id))
		if item == null or item.effect == null or not game.can_use_item(player_index, item):
			continue
		var target: int = 0
		var wanted: bool = false
		match item.effect.op:
			CardEnums.EffectOp.GAIN_HP:
				wanted = player.hp <= LOW_HP or (player.hp <= player.max_hp / 2 and player.max_hp - player.hp >= item.effect.amount)
			CardEnums.EffectOp.DEAL_DAMAGE:
				target = _best_enemy_unit(game, player_index, item, func(unit: CardInstance) -> bool: return game.get_defense(unit) - unit.damage <= item.effect.amount)
				wanted = target != 0
			CardEnums.EffectOp.SEND_BACK:
				target = _best_enemy_unit(game, player_index, item, func(unit: CardInstance) -> bool: return game.get_attack(unit) >= 4 or game.get_defense(unit) >= 5)
				wanted = target != 0
			CardEnums.EffectOp.BUFF:
				if game.phase == GameState.Phase.MAIN1 and not game.possible_attackers(player_index).is_empty():
					target = _best_own_attacker(game, player_index, item)
					wanted = target != 0
			CardEnums.EffectOp.DRAW:
				wanted = player.hand.size() <= 2
			CardEnums.EffectOp.CREATE_RESOURCE:
				wanted = game.turn >= 3
			CardEnums.EffectOp.TOSS, CardEnums.EffectOp.BURY:
				wanted = game.turn >= 3
			CardEnums.EffectOp.SUMMON_TOKEN:
				wanted = player.units().size() < game.players[1 - player_index].units().size()
			_:
				wanted = false
		if not wanted:
			continue
		if game.use_item(player_index, item, target):
			items[id] = int(items[id]) - 1
			used_this_turn[id] = true
			return true
	return false


static func _best_enemy_unit(game: GameState, player_index: int, item: ItemData, accept: Callable) -> int:
	var best: int = 0
	var best_value: int = -1
	for ref: int in game.legal_targets(player_index, item.effect, 0):
		if Targets.is_player(ref):
			continue
		var unit: CardInstance = game.find_permanent(ref)
		if unit == null or unit.owner == player_index or not bool(accept.call(unit)):
			continue
		var value: int = EffectResolver.unit_value(game, unit)
		if value > best_value:
			best_value = value
			best = ref
	return best


static func _best_own_attacker(game: GameState, player_index: int, item: ItemData) -> int:
	var attackers: Array[CardInstance] = game.possible_attackers(player_index)
	var best: int = 0
	var best_attack: int = -1
	for ref: int in game.legal_targets(player_index, item.effect, 0):
		if Targets.is_player(ref):
			continue
		var unit: CardInstance = game.find_permanent(ref)
		if unit == null or not attackers.has(unit):
			continue
		if game.get_attack(unit) > best_attack:
			best_attack = game.get_attack(unit)
			best = ref
	return best
