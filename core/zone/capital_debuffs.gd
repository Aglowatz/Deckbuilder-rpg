class_name CapitalDebuffs
extends RefCounted
## The four broken services of the Capital (Brief 10): while a Path's zone is not yet completed, the Capital suffers that
## Path's broken service as a debuff, and each completed zone removes its debuff.
##
## | Path (zone id)          | Debuff        | In duels (Modifier pipeline)              | In the world |
## | Beefcake (beefcake)     | Blackout      | your units enter exhausted            | darkness, slower movement, no travel |
## | Gourmand (gourmand)     | Famine        | max HP -5                               | healing items do not work |
## | Necrocrat (necrocrat)   | Restless Dead | enemy units may return from the grave | - |
## | Refusemancer (refusemancer) | Clutter   | 3 junk cards are shuffled into your deck  | - |
##
## Names, flavor and "what changed when freed" text are in the Capital's story file (`debuff.<zone id>.*`).

const BLACKOUT_SPEED: float = 0.8
const FAMINE_MAX_HP: int = -5
const RETURN_CHANCE_PERCENT: int = 35
const JUNK_COUNT: int = 3
## Visible-change keys of the world (the Capital scene reads these).
const WORLD_DARKNESS: String = "darkness"
const WORLD_SLOW: String = "slow"
const WORLD_NO_TRAVEL: String = "no_travel"
const WORLD_NO_FOOD_HEAL: String = "no_food_heal"


class Debuff:
	extends RefCounted
	## The zone id of the Path whose service is broken ("beefcake", "gourmand", "necrocrat", "refusemancer").
	var zone_id: String = ""
	var path: Affinity.Type = Affinity.Type.NEUTRAL
	## Modifier(s) on the player's side and on the enemy's side while the debuff is active.
	var player_modifiers: Array[Modifier] = []
	var enemy_modifiers: Array[Modifier] = []
	## World rules (WORLD_* keys).
	var world: Array[String] = []

	func name_text() -> String:
		return ZoneStoryText.for_zone(CapitalZone.ID).text("debuff.%s.name" % zone_id)

	func flavor_text() -> String:
		return ZoneStoryText.for_zone(CapitalZone.ID).text("debuff.%s.flavor" % zone_id)

	func freed_text() -> String:
		return ZoneStoryText.for_zone(CapitalZone.ID).text("debuff.%s.freed" % zone_id)

	## One line of what the debuff does, generated from its modifiers plus its world rules.
	func mechanic_text() -> String:
		var parts: PackedStringArray = []
		for modifier: Modifier in player_modifiers:
			parts.append(CapitalDebuffs.modifier_text(modifier, true))
		for modifier: Modifier in enemy_modifiers:
			parts.append(CapitalDebuffs.modifier_text(modifier, false))
		var story: ZoneStoryText = ZoneStoryText.for_zone(CapitalZone.ID)
		for rule: String in world:
			parts.append(story.text("debuff.rule.%s" % rule))
		return " ".join(parts)

	func tooltip(active: bool) -> String:
		if active:
			return "%s (active)\n%s\n\n%s\n\nFree %s to remove it." % [name_text(), mechanic_text(), flavor_text(), Affinity.display_name(path)]
		return "%s (restored)\n%s" % [name_text(), freed_text()]


static var _all: Array[Debuff] = []


static func all() -> Array[Debuff]:
	if _all.is_empty():
		_all = [_beefcake(), _gourmand(), _necrocrat(), _refusemancer()] as Array[Debuff]
	return _all


static func find(zone_id: String) -> Debuff:
	for debuff: Debuff in all():
		if debuff.zone_id == zone_id:
			return debuff
	return null


static func is_active(flags: Dictionary, zone_id: String) -> bool:
	return not ZoneCompletion.is_completed(flags, zone_id)


## The debuffs still in force.
static func active(flags: Dictionary) -> Array[Debuff]:
	var result: Array[Debuff] = []
	for debuff: Debuff in all():
		if is_active(flags, debuff.zone_id):
			result.append(debuff)
	return result


## Modifiers that go to the player's side in every Capital duel.
static func player_source(flags: Dictionary, content: ContentSet) -> ModifierSource:
	return _source(flags, content, true)


## Modifiers that go to the enemy's side in every Capital duel.
static func enemy_source(flags: Dictionary, content: ContentSet) -> ModifierSource:
	return _source(flags, content, false)


static func _source(flags: Dictionary, content: ContentSet, for_player: bool) -> ModifierSource:
	var mods: Array[Modifier] = []
	for debuff: Debuff in active(flags):
		for modifier: Modifier in (debuff.player_modifiers if for_player else debuff.enemy_modifiers):
			var copy: Modifier = modifier.duplicate() as Modifier
			if copy.kind == Modifier.Kind.SHUFFLE_JUNK_INTO_DECK:
				var junk: CardData = content.card(CapitalContent.JUNK_ID) if content != null else null
				copy.tokens = [junk] as Array[CardData] if junk != null else ([] as Array[CardData])
			mods.append(copy)
	if mods.is_empty():
		return null
	return CardBuilder.modifier_source("The Capital's broken services", ModifierSource.SourceKind.ZONE, mods)


# ---- World rules -----------------------------------------------------------------------------------


static func has_world_rule(flags: Dictionary, rule: String) -> bool:
	for debuff: Debuff in active(flags):
		if debuff.world.has(rule):
			return true
	return false


static func darkness(flags: Dictionary) -> bool:
	return has_world_rule(flags, WORLD_DARKNESS)


static func travel_blocked(flags: Dictionary) -> bool:
	return has_world_rule(flags, WORLD_NO_TRAVEL)


static func food_healing_blocked(flags: Dictionary) -> bool:
	return has_world_rule(flags, WORLD_NO_FOOD_HEAL)


## The player's movement multiplier in the Capital (Blackout slows you).
static func speed_multiplier(flags: Dictionary) -> float:
	return BLACKOUT_SPEED if has_world_rule(flags, WORLD_SLOW) else 1.0


## The max-HP change the active debuffs cause (Famine).
static func max_hp_change(flags: Dictionary) -> int:
	var total: int = 0
	for debuff: Debuff in active(flags):
		for modifier: Modifier in debuff.player_modifiers:
			if modifier.kind == Modifier.Kind.MAX_HP:
				total += modifier.value
	return total


# ---- Definitions --------------------------------------------------------------------------------------


static func _beefcake() -> Debuff:
	var debuff: Debuff = Debuff.new()
	debuff.zone_id = "beefcake"
	debuff.path = Affinity.Type.BEEFCAKE
	debuff.player_modifiers = [_mod(Modifier.Kind.ENTER_EXHAUSTED, 1, "Blackout")] as Array[Modifier]
	debuff.world = [WORLD_DARKNESS, WORLD_SLOW, WORLD_NO_TRAVEL] as Array[String]
	return debuff


static func _gourmand() -> Debuff:
	var debuff: Debuff = Debuff.new()
	debuff.zone_id = "gourmand"
	debuff.path = Affinity.Type.GOURMAND
	debuff.player_modifiers = [_mod(Modifier.Kind.MAX_HP, FAMINE_MAX_HP, "Famine")] as Array[Modifier]
	debuff.world = [WORLD_NO_FOOD_HEAL] as Array[String]
	return debuff


static func _necrocrat() -> Debuff:
	var debuff: Debuff = Debuff.new()
	debuff.zone_id = "necrocrat"
	debuff.path = Affinity.Type.NECROCRAT
	debuff.enemy_modifiers = [_mod(Modifier.Kind.GRAVEYARD_RETURN_CHANCE, RETURN_CHANCE_PERCENT, "Restless Dead")] as Array[Modifier]
	return debuff


static func _refusemancer() -> Debuff:
	var debuff: Debuff = Debuff.new()
	debuff.zone_id = "refusemancer"
	debuff.path = Affinity.Type.REFUSEMANCER
	debuff.player_modifiers = [_mod(Modifier.Kind.SHUFFLE_JUNK_INTO_DECK, JUNK_COUNT, "Clutter")] as Array[Modifier]
	return debuff


static func _mod(kind: Modifier.Kind, value: int, label: String) -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = kind
	modifier.value = value
	modifier.label = label
	return modifier


## Plain-language description of one debuff modifier.
static func modifier_text(modifier: Modifier, on_player: bool) -> String:
	match modifier.kind:
		Modifier.Kind.ENTER_EXHAUSTED:
			return "In duels your units enter exhausted."
		Modifier.Kind.MAX_HP:
			return "Your max HP is %d lower." % absi(modifier.value)
		Modifier.Kind.GRAVEYARD_RETURN_CHANCE:
			return "In duels, each enemy unit that dies has a %d%% chance to climb back out of the Refuse Pile." % modifier.value
		Modifier.Kind.SHUFFLE_JUNK_INTO_DECK:
			return "In duels, %d Heaps of Rubbish are shuffled into your deck." % modifier.value
	return modifier.label if on_player else modifier.label
