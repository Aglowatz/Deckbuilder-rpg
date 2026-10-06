class_name ZoneEffects
extends RefCounted
## Zone-wide buffs and debuffs (Part C): in each zone (and its dungeons) one Path's cards are
## **buffed** and its rival Path's cards **debuffed**, for BOTH the player and the enemy, through
## the normal Modifier pipeline (`ModifierSource` of kind ZONE). The rivalries come from the story:
## Beefcakes (chaotic, "there-ish, on-time-ish") vs. Necrocrats (orderly, by the book) and
## Gourmands (snooty and proper) vs. Refusemancers ("garbage eaters"). See docs/design/story_bible.md.
##
## | Zone | Buff | Debuff |
## | Gainlands | Pump It Up: Beefcake units +1 attack | Processing Time: Necrocrat units enter exhausted |
## | D.N.A. | Approved Procedure: Necrocrat units +1 defense | Unauthorized Activity: Beefcake cards cost 1 more |
## | Endless Buffet | Well Fed: Gourmand units +1/+1 | Dress Code Violation: Refusemancer units -1 attack |
## | Verdant Dump | Overgrowth: Refusemancer units +2 defense | Spoilage: Gourmand units -1 defense |
##
## Names and flavor text live in each zone's story file (`effect.buff.name`, `effect.buff.flavor`,
## `effect.debuff.name`, `effect.debuff.flavor`); the mechanical description is generated from the modifier.


class Effect:
	extends RefCounted
	var zone_id: String = ""
	## The Path whose cards are buffed, and the rival Path whose cards are debuffed.
	var path: Affinity.Type = Affinity.Type.NEUTRAL
	var rival: Affinity.Type = Affinity.Type.NEUTRAL
	var buff: Modifier
	var debuff: Modifier

	func buff_name() -> String:
		return ZoneStoryText.for_zone(zone_id).text("effect.buff.name")

	func debuff_name() -> String:
		return ZoneStoryText.for_zone(zone_id).text("effect.debuff.name")

	func buff_flavor() -> String:
		return ZoneStoryText.for_zone(zone_id).text("effect.buff.flavor")

	func debuff_flavor() -> String:
		return ZoneStoryText.for_zone(zone_id).text("effect.debuff.flavor")

	func buff_mechanic() -> String:
		return ZoneEffects.mechanic_text(buff)

	func debuff_mechanic() -> String:
		return ZoneEffects.mechanic_text(debuff)

	## "Pump It Up: Beefcake units get +1 attack." - one line for HUD rows and tooltips.
	func buff_line() -> String:
		return "%s: %s" % [buff_name(), buff_mechanic()]

	func debuff_line() -> String:
		return "%s: %s" % [debuff_name(), debuff_mechanic()]

	## The longer tooltip: both lines plus their flavor.
	func tooltip() -> String:
		return "ZONE EFFECTS (they apply to you and to the enemy)\n[+] %s\n    %s\n[-] %s\n    %s" % [buff_line(), buff_flavor(), debuff_line(), debuff_flavor()]

	## The ModifierSource carrying both modifiers (applied to player and enemy alike).
	func source() -> ModifierSource:
		var result: ModifierSource = ModifierSource.new()
		result.source_name = "%s zone effects" % zone_id
		result.source_kind = ModifierSource.SourceKind.ZONE
		result.modifiers = [buff, debuff] as Array[Modifier]
		return result


static var _cache: Dictionary = {}


## The effects of a zone (and of its dungeons), or null for an unknown zone id.
static func for_zone(zone_id: String) -> Effect:
	if not _cache.has(zone_id):
		_cache[zone_id] = _build(zone_id)
	return _cache[zone_id] as Effect


static func has_effect(zone_id: String) -> bool:
	return for_zone(zone_id) != null


## The ModifierSource to feed the pipeline for a battle in `zone_id` (null outside the four zones).
static func source_for(zone_id: String) -> ModifierSource:
	var effect: Effect = for_zone(zone_id)
	return effect.source() if effect != null else null


## The Path whose zone this is (Beefcake for the Gainlands...).
static func path_of(zone_id: String) -> Affinity.Type:
	match zone_id:
		GainlandsZone.ID:
			return Affinity.Type.BEEFCAKE
		BuffetZone.ID:
			return Affinity.Type.GOURMAND
		HeapZone.ID:
			return Affinity.Type.REFUSEMANCER
		DnaZone.ID:
			return Affinity.Type.NECROCRAT
	return Affinity.Type.NEUTRAL


## The rival Path: Beefcake <-> Necrocrat, Gourmand <-> Refusemancer.
static func rival_of(path: Affinity.Type) -> Affinity.Type:
	match path:
		Affinity.Type.BEEFCAKE:
			return Affinity.Type.NECROCRAT
		Affinity.Type.NECROCRAT:
			return Affinity.Type.BEEFCAKE
		Affinity.Type.GOURMAND:
			return Affinity.Type.REFUSEMANCER
		Affinity.Type.REFUSEMANCER:
			return Affinity.Type.GOURMAND
	return Affinity.Type.NEUTRAL


static func _build(zone_id: String) -> Effect:
	var path: Affinity.Type = path_of(zone_id)
	if path == Affinity.Type.NEUTRAL:
		return null
	var effect: Effect = Effect.new()
	effect.zone_id = zone_id
	effect.path = path
	effect.rival = rival_of(path)
	match zone_id:
		GainlandsZone.ID:
			effect.buff = _mod(Modifier.Kind.STAT_CHANGE, path, 1, 0, "Pump It Up")
			effect.debuff = _mod(Modifier.Kind.ENTER_EXHAUSTED, effect.rival, 1, 0, "Processing Time")
		DnaZone.ID:
			effect.buff = _mod(Modifier.Kind.STAT_CHANGE, path, 0, 1, "Approved Procedure")
			effect.debuff = _mod(Modifier.Kind.COST_CHANGE, effect.rival, 1, 0, "Unauthorized Activity")
		BuffetZone.ID:
			effect.buff = _mod(Modifier.Kind.STAT_CHANGE, path, 1, 1, "Well Fed")
			effect.debuff = _mod(Modifier.Kind.STAT_CHANGE, effect.rival, -1, 0, "Dress Code Violation")
		HeapZone.ID:
			effect.buff = _mod(Modifier.Kind.STAT_CHANGE, path, 0, 2, "Overgrowth")
			effect.debuff = _mod(Modifier.Kind.STAT_CHANGE, effect.rival, 0, -1, "Spoilage")
	return effect


static func _mod(kind: Modifier.Kind, color: Affinity.Type, value: int, value2: int, label: String) -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = kind
	modifier.color = int(color)
	modifier.value = value
	modifier.value2 = value2
	modifier.label = label
	return modifier


## Plain-language description of one zone modifier ("Beefcake units get +1 attack.").
static func mechanic_text(modifier: Modifier) -> String:
	var path: String = Affinity.display_name(modifier.color as Affinity.Type)
	match modifier.kind:
		Modifier.Kind.STAT_CHANGE:
			var parts: PackedStringArray = []
			if modifier.value != 0:
				parts.append("%+d attack" % modifier.value)
			if modifier.value2 != 0:
				parts.append("%+d defense" % modifier.value2)
			return "%s units get %s." % [path, " and ".join(parts)]
		Modifier.Kind.COST_CHANGE:
			if modifier.value > 0:
				return "%s cards cost %d more." % [path, modifier.value]
			return "%s cards cost %d less." % [path, -modifier.value]
		Modifier.Kind.ENTER_EXHAUSTED:
			return "%s units enter exhausted (they cannot block until readied)." % path
	return modifier.label
