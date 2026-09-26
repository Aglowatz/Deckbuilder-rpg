class_name ModifierPipeline
extends RefCounted
## The one place that turns "everything affecting a player" into a ModifierSet.
## Equipment, items, zone effects, dungeon effects and boons all flow through the same
## Modifier type, so the engine never needs to know where a modifier came from.


## Player-side pipeline: the profile's equipment and items, the current zone, and any
## dungeon-wide sources (dungeon rules, boons).
static func build(
	profile: PlayerProfile,
	zone: ModifierSource = null,
	dungeon_sources: Array[ModifierSource] = [],
) -> ModifierSet:
	var mods: ModifierSet = ModifierSet.new()
	if profile != null:
		mods.add_sources(profile.equipment)
		mods.add_sources(profile.items)
	if zone != null:
		mods.add_source(zone)
	mods.add_sources(dungeon_sources)
	return mods


## Opponent-side pipeline: zone and dungeon effects may affect enemies too.
static func build_for_enemy(
	enemy_sources: Array[ModifierSource] = [],
	zone: ModifierSource = null,
) -> ModifierSet:
	var mods: ModifierSet = ModifierSet.new()
	if zone != null:
		mods.add_source(zone)
	mods.add_sources(enemy_sources)
	return mods
