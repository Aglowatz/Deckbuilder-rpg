class_name CardData
extends Resource
## Static definition of a card. Stored as .tres in data/cards/.

@export var id: String = ""
@export var display_name: String = ""
@export var type: CardEnums.CardType = CardEnums.CardType.UNIT
## For infrastructure: the energy type produced. For others: the card's color identity.
@export var color: Affinity.Type = Affinity.Type.NEUTRAL
## Brief 9, Part F: the SECOND Path of a multi-Path (dual-Path) card. NEUTRAL = a single-Path card. A multi-Path
## card has pips of both Paths (it needs energy from both), counts as BOTH Paths for the deck's Path limit
## and for zone effects, and is crafted at the Alchemist.
@export var color2: Affinity.Type = Affinity.Type.NEUTRAL
## Generic energy (payable by any infrastructure).
@export var generic_cost: int = 0
## One entry per colored pip; each must be paid by an infrastructure of that type.
@export var colored_pips: Array[Affinity.Type] = []
@export var attack: int = 0
@export var defense: int = 1
@export var keywords: Array[CardEnums.Keyword] = []
@export_multiline var rules_text: String = ""
@export var effects: Array[EffectData] = []
@export var rarity: CardEnums.Rarity = CardEnums.Rarity.COMMON
@export_multiline var flavor_text: String = ""
## Basic infrastructure are exempt from the copy limit.
@export var is_basic: bool = false
## Tokens are created by effects and cease to exist outside the field.
@export var is_token: bool = false
## Pack system: a card with this flag never appears in any pack (unique dungeon/quest rewards, chest cards, enemy-only
## cards...) and must be found another way. The ids are listed in `PackRules.NOT_IN_PACKS_IDS`.
@export var not_in_packs: bool = false
## Brief 14: the designed card set. `paths_all` is the authoritative Path list of a card with 3-4 Paths (empty = derive
## the Paths from `color` / `color2`, the way the older 1-2 Path cards do). `color` / `color2` still mirror the first two Paths.
@export var paths_all: Array[Affinity.Type] = []
## For resource token cards: the `ResourceKind.Kind` (-1 = not a resource).
@export var resource_kind: int = -1
## Infrastructure that produces energy of any one Path (e.g. Old Kingdom Crossroads).
@export var produces_any: bool = false
## The card's rules as a script (see docs/card_pipeline.md) and a hash of the sheet's rules text at the time it was scripted.
@export_multiline var script_text: String = ""
@export var rules_hash: String = ""
## Art-pipeline metadata from the card sheet (never shown in game).
@export_multiline var image_description: String = ""
@export var is_signature: bool = false


## The parsed card script (cached per card; re-parsed if `script_text` changes).
var _parsed_cache: ScriptParser.Parsed
var _parsed_for: String = ""
var _has_static: bool = false


func parsed_script() -> ScriptParser.Parsed:
	if _parsed_cache == null or _parsed_for != script_text:
		_parsed_cache = ScriptCache.parsed_text(script_text)
		_parsed_for = script_text
		_has_static = false
		for ability: CardAbility in _parsed_cache.abilities:
			if ability.is_static_kind():
				_has_static = true
	return _parsed_cache


func abilities() -> Array[CardAbility]:
	return parsed_script().abilities


## Whether a `when(...)` or `trap(...)` ability of this card listens to the event.
func listens_to(event_name: String) -> bool:
	return parsed_script().events.has(event_name)

## True when the card has any continuous ability (aura, host effect, static flag, cost change).
func has_static_abilities() -> bool:
	parsed_script()
	return _has_static


func energy_value() -> int:
	return generic_cost + colored_pips.size()


func is_multipath() -> bool:
	if not paths_all.is_empty():
		return paths_all.size() >= 2
	return color != Affinity.Type.NEUTRAL and color2 != Affinity.Type.NEUTRAL and color2 != color


## Every Path this card belongs to (none for a neutral card, one normally, two for a multi-Path card).
func paths() -> Array[Affinity.Type]:
	if not paths_all.is_empty():
		return paths_all
	var result: Array[Affinity.Type] = []
	if color != Affinity.Type.NEUTRAL:
		result.append(color)
	if is_multipath():
		result.append(color2)
	return result


func is_on_path(path: Affinity.Type) -> bool:
	return path != Affinity.Type.NEUTRAL and paths().has(path)


## The Paths of energy an infrastructure can produce (one per activation): all four for an any-Path
## infrastructure, otherwise its own Path(s). Empty for non-infrastructure.
func produced_paths() -> Array[Affinity.Type]:
	if not is_infrastructure():
		return [] as Array[Affinity.Type]
	if produces_any:
		return Affinity.colored_types()
	return paths()


func is_resource() -> bool:
	return type == CardEnums.CardType.RESOURCE


func is_tool() -> bool:
	return type == CardEnums.CardType.TOOL


func is_wonder() -> bool:
	return type == CardEnums.CardType.WONDER

func is_infrastructure() -> bool:
	return type == CardEnums.CardType.INFRASTRUCTURE


func is_unit() -> bool:
	return type == CardEnums.CardType.UNIT


## Units, wonders and tools stay on the field after being played.
func is_permanent() -> bool:
	return type == CardEnums.CardType.UNIT or type == CardEnums.CardType.WONDER or type == CardEnums.CardType.TOOL


func has_keyword(keyword: CardEnums.Keyword) -> bool:
	return keywords.has(keyword)


func effects_for(trigger: CardEnums.Trigger) -> Array[EffectData]:
	var result: Array[EffectData] = []
	for effect: EffectData in effects:
		if effect.trigger == trigger:
			result.append(effect)
	return result


func has_trigger(trigger: CardEnums.Trigger) -> bool:
	for effect: EffectData in effects:
		if effect.trigger == trigger:
			return true
	return false


## Infrastructure (and basic cards) are exempt from the 4-copy limit and never need to be owned.
func is_unlimited() -> bool:
	return is_basic or is_infrastructure()
