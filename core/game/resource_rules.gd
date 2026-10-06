class_name ResourceRules
extends RefCounted
## The Resource system (Brief 14, Part B): creating, using, destroying and spending resources, and the three built-in
## "pay 1 energy, use one" abilities (Iron, Red Tape, Contract) plus the Eat Garbage cost. Operates on a GameState.
## Resources are token permanents in `PlayerState.resources`; every one is a CardInstance of a resource token CardData.

static var _data_cache: Dictionary = {}


## The (cached, code-built) token card for a resource kind.
static func data_for(kind: ResourceKind.Kind) -> CardData:
	if _data_cache.has(int(kind)):
		return _data_cache[int(kind)] as CardData
	var card: CardData = CardData.new()
	card.id = ResourceKind.card_id(kind)
	card.display_name = ResourceKind.display_name(kind)
	card.type = CardEnums.CardType.RESOURCE
	card.is_token = true
	card.resource_kind = int(kind)
	card.color = ResourceKind.path_of(kind)
	card.rules_text = str(ResourceKind.DESCRIPTIONS[kind])
	card.rarity = CardEnums.Rarity.COMMON
	card.defense = 0
	card.not_in_packs = true
	_data_cache[int(kind)] = card
	return card


# ---- Creating, using, removing ------------------------------------------------------------


## Creates `count` resources of `kind` for `player_index` (after "double the resources" effects). Returns them.
static func create(state: GameState, player_index: int, kind: ResourceKind.Kind, count: int = 1, source_uid: int = 0) -> Array[CardInstance]:
	var created: Array[CardInstance] = []
	if count <= 0 or state.is_over():
		return created
	var total: int = count * StaticEffects.resource_multiplier(state, player_index, kind)
	var player: PlayerState = state.players[player_index]
	for i: int in range(total):
		var card: CardInstance = state.create_instance(data_for(kind), player_index)
		card.entered_turn = state.turn
		player.resources.append(card)
		created.append(card)
		state.emit_event(GameEvent.Type.RESOURCE_CREATED, player_index, card.uid, source_uid, 1, int(kind))
	for card: CardInstance in created:
		if state.is_over():
			break
		state.fire_game_event("resource_created", {"card": card, "player": player_index, "kind": int(kind), "source": source_uid})
		state.fire_game_event("creates_token", {"card": card, "player": player_index, "source": source_uid})
	return created


## Spends `count` resources of `kind` ("use"): removes them from the zone. False (and nothing happens) when there are too few.
static func use(state: GameState, player_index: int, kind: ResourceKind.Kind, count: int = 1) -> bool:
	var player: PlayerState = state.players[player_index]
	if count <= 0:
		return true
	if player.count_resource(kind) < count:
		return false
	var removed: int = 0
	for card: CardInstance in player.resources.duplicate():
		if card.data.resource_kind != int(kind):
			continue
		player.resources.erase(card)
		state.emit_event(GameEvent.Type.RESOURCE_USED, player_index, card.uid, 0, 1, int(kind))
		removed += 1
		if removed >= count:
			break
	for i: int in range(removed):
		state.fire_game_event("resource_used", {"player": player_index, "kind": int(kind)})
	return true


## Uses `count` resources of any kinds in `kinds` (cheapest first). False when there are not enough in total.
static func use_any_of(state: GameState, player_index: int, kinds: Array[ResourceKind.Kind], count: int) -> bool:
	var player: PlayerState = state.players[player_index]
	var have: int = 0
	for kind: ResourceKind.Kind in kinds:
		have += player.count_resource(kind)
	if have < count:
		return false
	var left: int = count
	for kind: ResourceKind.Kind in kinds:
		var take: int = mini(left, player.count_resource(kind))
		if take > 0 and use(state, player_index, kind, take):
			left -= take
	return true


## Removes one specific resource without "using" it (destroyed or Shredded by a card).
static func remove(state: GameState, card: CardInstance, shredded: bool = false) -> bool:
	var player: PlayerState = state.players[card.owner]
	if not player.resources.has(card):
		return false
	player.resources.erase(card)
	state.emit_event(GameEvent.Type.RESOURCE_REMOVED, card.owner, card.uid, 0, 1 if shredded else 0, card.data.resource_kind)
	return true


## All of a player's resources, optionally only of the given kinds (empty = every kind).
static func of_player(state: GameState, player_index: int, kinds: Array[ResourceKind.Kind] = [] as Array[ResourceKind.Kind]) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for card: CardInstance in state.players[player_index].resources:
		if kinds.is_empty() or kinds.has(card.data.resource_kind as ResourceKind.Kind):
			result.append(card)
	return result


# ---- The built-in abilities (Iron, Red Tape, Contract) ---------------------------------------


## +1 attack per Iron use (+2 with Chancellor Clench).
static func iron_amount(state: GameState, player_index: int) -> int:
	return 2 if StaticEffects.player_flag(state, player_index, "iron_plus_2") else 1


## -1 attack per Red Tape use (-2 with Chancellor Clench).
static func red_tape_amount(state: GameState, player_index: int) -> int:
	return 2 if StaticEffects.player_flag(state, player_index, "red_tape_minus_2") else 1


## Units a player may target with `kind`'s use ability.
static func use_targets(state: GameState, player_index: int, kind: ResourceKind.Kind) -> Array[int]:
	var result: Array[int] = []
	if not ResourceKind.has_use_ability(kind):
		return result
	for player: PlayerState in state.players:
		for unit: CardInstance in player.units():
			if state.can_be_targeted_by(unit, player_index):
				result.append(unit.uid)
	return result


static func can_use_ability(state: GameState, player_index: int, kind: ResourceKind.Kind, target_uid: int) -> bool:
	if not ResourceKind.has_use_ability(kind):
		return false
	if not state.in_main_phase() or player_index != state.active:
		return false
	var player: PlayerState = state.players[player_index]
	if player.count_resource(kind) < 1:
		return false
	if not state.can_pay_energy(player_index, 1, [] as Array[Affinity.Type]):
		return false
	var target: CardInstance = state.find_permanent(target_uid)
	return target != null and target.data.is_unit() and state.can_be_targeted_by(target, player_index)


## Pays 1 energy, uses one resource of `kind` and applies its effect to the target unit.
static func use_ability(state: GameState, player_index: int, kind: ResourceKind.Kind, target_uid: int) -> bool:
	if not can_use_ability(state, player_index, kind, target_uid):
		return false
	var target: CardInstance = state.find_permanent(target_uid)
	if not state.pay_energy(player_index, 1, [] as Array[Affinity.Type], [] as Array[int], 0):
		return false
	if not use(state, player_index, kind, 1):
		return false
	state.emit_event(GameEvent.Type.ABILITY_ACTIVATED, player_index, target_uid, 0, -1 - int(kind))
	match kind:
		ResourceKind.Kind.IRON:
			state.change_stats(target, iron_amount(state, player_index), 0, false)
		ResourceKind.Kind.RED_TAPE:
			state.change_stats(target, -red_tape_amount(state, player_index), 0, false)
		ResourceKind.Kind.CONTRACT:
			state.exhaust_unit(target, true)
	state.check_state()
	return true


# ---- Eating garbage -------------------------------------------------------------------------


## Eat garbage is a cost: pay 1 energy, lose 1 HP, use a Garbage (the Raccoon removes the energy and HP parts).
## You cannot eat if it would reduce you to 0 HP.
static func can_eat(state: GameState, player_index: int, times: int = 1) -> bool:
	var player: PlayerState = state.players[player_index]
	if player.count_resource(ResourceKind.Kind.GARBAGE) < times:
		return false
	if StaticEffects.player_flag(state, player_index, "free_eat"):
		return true
	return player.hp > times and state.can_pay_energy(player_index, times, [] as Array[Affinity.Type])


static func eat(state: GameState, player_index: int, times: int = 1) -> bool:
	if not can_eat(state, player_index, times):
		return false
	var free: bool = StaticEffects.player_flag(state, player_index, "free_eat")
	if not free:
		if not state.pay_energy(player_index, times, [] as Array[Affinity.Type], [] as Array[int], 0):
			return false
		state.lose_hp(player_index, times)
	if not use(state, player_index, ResourceKind.Kind.GARBAGE, times):
		return false
	for i: int in range(times):
		state.emit_event(GameEvent.Type.GARBAGE_EATEN, player_index)
		state.fire_game_event("eat", {"player": player_index})
	return true
