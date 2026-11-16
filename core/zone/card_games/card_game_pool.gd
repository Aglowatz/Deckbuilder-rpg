class_name CardGamePool
extends RefCounted
## Fable Nov 16b (Part 2): the cards the four zone card minigames are dealt from - the zone's own Path plus the colourless cards, real
## cards a player can own (no tokens, no enemy-only cards, no reward-locked surprises), in id order so a seed deals the same game.

## The four bins of "Sort It Out" (the Verdant Dump), in order.
enum Kind { UNIT, SPELL, INFRASTRUCTURE, OTHER }

const KIND_NAMES: Array[String] = ["Unit", "Spell", "Infrastructure", "Other"]


## Every dealable card of `zone_id`: one Path (the zone's) or colourless, not Infrastructure.
static func cards(content: ContentSet, zone_id: String) -> Array[CardData]:
	var path: Affinity.Type = ZoneEffects.path_of(zone_id)
	var result: Array[CardData] = []
	for card: CardData in content.cards.values():
		if card.is_token or card.is_basic or card.is_infrastructure() or card.is_resource():
			continue
		if CardAvailability.is_enemy_only(card) or CardAvailability.is_reward_locked(card):
			continue
		var paths: Array[Affinity.Type] = card.paths()
		if paths.size() > 1 or (paths.size() == 1 and paths[0] != path):
			continue
		result.append(card)
	result.sort_custom(func(a: CardData, b: CardData) -> bool: return a.id < b.id)
	return result


static func units(content: ContentSet, zone_id: String) -> Array[CardData]:
	var result: Array[CardData] = []
	for card: CardData in cards(content, zone_id):
		if card.is_unit():
			result.append(card)
	return result


## The Infrastructure cards a zone's games may show: the Path's basic one and any other Infrastructure of the Path or colourless.
static func infrastructure(content: ContentSet, zone_id: String) -> Array[CardData]:
	var path: Affinity.Type = ZoneEffects.path_of(zone_id)
	var result: Array[CardData] = []
	var basic: CardData = content.infrastructure.get(int(path)) as CardData
	if basic != null:
		result.append(basic)
	for card: CardData in content.cards.values():
		if card == basic or card.is_token or not card.is_infrastructure() or CardAvailability.is_enemy_only(card):
			continue
		var paths: Array[Affinity.Type] = card.paths()
		if paths.size() > 1 or (paths.size() == 1 and paths[0] != path):
			continue
		result.append(card)
	result.sort_custom(func(a: CardData, b: CardData) -> bool: return a.id < b.id)
	return result


## Which of the four bins a card belongs in.
static func kind_of(card: CardData) -> Kind:
	if card.is_infrastructure():
		return Kind.INFRASTRUCTURE
	if card.is_unit():
		return Kind.UNIT
	if card.type == CardEnums.CardType.SPELL:
		return Kind.SPELL
	return Kind.OTHER


## A card's power as the games read it: a unit's attack; anything else has none (0).
static func power_of(card: CardData) -> int:
	return card.attack if card.is_unit() else 0


## Stars for a won game by how many slips it took (misses, strikes, swaps...): none 3, one or two 2, more 1. A lost game: 0.
static func stars_for(won: bool, slips: int) -> int:
	if not won:
		return 0
	return 3 if slips <= 0 else (2 if slips <= 2 else 1)
