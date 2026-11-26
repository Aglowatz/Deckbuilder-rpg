class_name OpponentHands
extends RefCounted
## Nov 25 night (Part C): opponents in the postgame dungeons and in drafts are never crippled at the start. The owner: "many start with 5
## and discard 2, which leaves them unable to act." Each such foe holds at least MIN_HAND cards when its first turn begins (a boss one
## more), its max hand is never under that, and its opening hand is a sensible mix: at least INFRA_FLOOR Infrastructure and at least
## PLAY_FLOOR other cards (a hidden soft mulligan on the game's seeded RNG, like the floor every foe has had since Nov 21).

const MIN_HAND: int = 8
## The owner: "bosses can have more". Measured: with one more the postgame bosses were all but unbeatable for a strong deck
## (docs/design/sim/nov25n/postgame_runs.md), so a boss holds the same minimum; the knob stays.
const BOSS_EXTRA: int = 0
const INFRA_FLOOR: int = 3
const PLAY_FLOOR: int = 4
const SOURCE_NAME: String = "A Full Hand"
## The postgame dungeons (the dungeon list's "Postgame Dungeon" type is the Lab and the Gallery; Mount Swolympus opens after Primm and the
## Iron Cave, although it sits in the postgame file, is an early Gainlands cave: not one). The vault's guardian (the four levers) is handled by its own setup.
const POSTGAME_DUNGEONS: Array[String] = ["D-LAB", "S-GALLERY", "S-BEEF"]


static func is_postgame_dungeon(key: String) -> bool:
	return POSTGAME_DUNGEONS.has(key) or MainDungeons.is_postgame(key)


## The opening hand a foe of this kind is dealt (the foe's turn draw comes on top when it goes second).
static func opening_size(boss: bool) -> int:
	return MIN_HAND + (BOSS_EXTRA if boss else 0)


## Gives the seat its full hand: the profile's opening hand at MIN_HAND (the profile's own cap is 8), a boss's extra card as a rule
## source, and a max hand that holds it all.
static func apply(setup: PlayerSetup, boss: bool = false) -> void:
	if setup == null:
		return
	if setup.profile == null:
		setup.profile = PlayerProfile.new()
	# the opening hand itself is sized by the game when it knows who goes first (`GameOptions.foe_first_turn_hand`): 8 when the foe goes
	# first, 7 and its turn draw when it goes second - the owner's "at least 8 cards when their first turn begins"
	setup.profile.max_hand_size = maxi(setup.profile.max_hand_size, PlayerProfile.DEFAULT_MAX_HAND_SIZE)
	var extra: int = opening_size(boss) - PlayerProfile.MAX_OPENING_HAND
	if extra > 0 and not _has_extra(setup):
		# a plain modifier on the seat (no rule source: it is how the foe is dealt, not a rule of the fight)
		var modifier: Modifier = CardBuilder.modifier(Modifier.Kind.OPENING_HAND_SIZE, extra)
		modifier.label = SOURCE_NAME
		setup.modifiers.add(modifier)


## The opening-hand mix for the AI seat of such a fight.
static func apply_options(options: GameOptions) -> void:
	if options == null:
		return
	options.foe_opening_infrastructure_floor = maxi(options.foe_opening_infrastructure_floor, INFRA_FLOOR)
	options.foe_opening_play_floor = maxi(options.foe_opening_play_floor, PLAY_FLOOR)
	options.foe_first_turn_hand = maxi(options.foe_first_turn_hand, MIN_HAND)


static func _has_extra(setup: PlayerSetup) -> bool:
	for modifier: Modifier in setup.modifiers.modifiers:
		if modifier.label == SOURCE_NAME:
			return true
	return false
