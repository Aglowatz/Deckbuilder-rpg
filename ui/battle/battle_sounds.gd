class_name BattleSounds
extends RefCounted
## Which sound a battle moment makes (docs/audio/sound_direction.md, "Battle"): the card's weight, its Path's summon and death, each resource and token
## gained or spent, and the hit by its size. Pure mappings to bank events; `BattleBoard` plays them on the animation beats, so they keep in sync at every
## battle speed (their layer delays shrink with it).

## A card costing this much or more lands heavy; this much or less is light.
const HEAVY_COST: int = 5
const CHEAP_COST: int = 2


static func path_key(color: Affinity.Type) -> String:
	match color:
		Affinity.Type.BEEFCAKE:
			return "beefcake"
		Affinity.Type.NECROCRAT:
			return "necrocrat"
		Affinity.Type.GOURMAND:
			return "gourmand"
		Affinity.Type.REFUSEMANCER:
			return "refusemancer"
	return "neutral"


static func cost_of(data: CardData) -> int:
	if data == null:
		return 0
	return data.generic_cost + data.colored_pips.size()


## The card going to the middle when it is played: by type and weight.
static func play(data: CardData) -> StringName:
	if data == null:
		return &"card_play"
	var cost: int = cost_of(data)
	match data.type:
		CardEnums.CardType.SPELL:
			return &"spell_cast_big" if cost >= HEAVY_COST - 1 else &"spell_cast"
		CardEnums.CardType.WONDER:
			return &"wonder_play"
		CardEnums.CardType.TOOL:
			return &"card_play_cheap" if cost <= CHEAP_COST else &"card_play"
	if cost >= HEAVY_COST:
		return &"card_play_heavy"
	if cost <= CHEAP_COST:
		return &"card_play_cheap"
	return &"card_play"


## A unit landing on the field: its Path's summon.
static func summon(data: CardData) -> StringName:
	return StringName("summon_" + path_key(data.color if data != null else Affinity.Type.NEUTRAL))


static func death(data: CardData) -> StringName:
	return StringName("death_" + path_key(data.color if data != null else Affinity.Type.NEUTRAL))


## A resource or token gained (or spent).
static func resource(kind: int, gained: bool) -> StringName:
	var stem: String = ""
	match kind:
		ResourceKind.Kind.IRON:
			stem = "iron"
		ResourceKind.Kind.RED_TAPE:
			stem = "redtape"
		ResourceKind.Kind.CONTRACT:
			stem = "contract"
		ResourceKind.Kind.INGREDIENT:
			stem = "ingredient"
		ResourceKind.Kind.GARBAGE:
			stem = "garbage"
	if stem.is_empty():
		return &"resource_gain" if gained else &"energy_tick"
	return StringName(stem + ("_gain" if gained else "_spend"))


## A blow by its size: on a unit light (1), medium (2-3) or heavy (4+); on a hero always the body blow, heavy from 3.
static func hit(amount: int, on_player: bool) -> StringName:
	if on_player:
		return &"hit_heavy" if amount >= 5 else &"hit_player"
	if amount >= 4:
		return &"hit_heavy"
	if amount >= 2:
		return &"hit_medium"
	return &"hit_light"
