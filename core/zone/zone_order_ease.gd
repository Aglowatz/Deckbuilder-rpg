class_name ZoneOrderEase
extends RefCounted
## Overnight Nov 4-5, Part 3 (docs/balance/early_game_nov5.md): Maren sends every player to their OWN Path's zone first (PathDirection), but
## the four zones are tuned for one order - the Gainlands (1), the D.N.A. (2), the Endless Buffet (3), the Verdant Dump (4). A Refusemancer
## reached the Rotheart at level 9 against foes made for level 17 and cleared it 1 time in 10. This eases a zone's foes (its main dungeon, its
## side dungeon and its roamers) by how many places EARLIER than designed the player arrives, and a little more for the very first zone
## (the starter deck plus a couple of buys). Foes keep their decks and rules; only their HP shrinks. Pure rules.

## Zone -> its designed place in the order (1-4).
const DESIGNED_PLACE: Dictionary = {"beefcake": 1, "necrocrat": 2, "gourmand": 3, "refusemancer": 4}
## HP factor by how many places early the zone is entered (0, 1, 2, 3).
const EARLY_HP_FACTOR: Array[float] = [1.0, 0.95, 0.85, 0.42]
## Extra factor while no zone is freed yet (the player's first zone).
const FIRST_ZONE_FACTOR: float = 0.85


## How many places earlier than designed the zone is being played (0 when on time or late).
static func places_early(zone_id: String, zones_freed: int) -> int:
	if not DESIGNED_PLACE.has(zone_id):
		return 0
	return maxi(0, int(DESIGNED_PLACE[zone_id]) - (zones_freed + 1))


## The HP factor for the zone's foes right now (1.0 = as designed). A freed zone is never eased (its fights are the post-freeing ones).
static func hp_factor(zone_id: String, zones_freed: int, zone_freed: bool = false) -> float:
	if zone_freed or not DESIGNED_PLACE.has(zone_id):
		return 1.0
	var factor: float = EARLY_HP_FACTOR[clampi(places_early(zone_id, zones_freed), 0, EARLY_HP_FACTOR.size() - 1)]
	if zones_freed == 0:
		factor *= FIRST_ZONE_FACTOR
	return factor


## Units of a zone entered at least one place early hit 1 softer (HP alone left its bosses winning half the time against a starter deck).
const EARLY_ATTACK_EASE: int = -1


## The attack ease for the zone right now (0 = none).
static func attack_ease(zone_id: String, zones_freed: int, zone_freed: bool = false) -> int:
	return EARLY_ATTACK_EASE if not zone_freed and places_early(zone_id, zones_freed) > 0 else 0


## Eases an enemy seat in the zone: HP times hp_factor and, when the zone is early, the attack ease on its units.
static func ease_seat(setup: PlayerSetup, zone_id: String, zones_freed: int, zone_freed: bool = false) -> void:
	apply(setup, hp_factor(zone_id, zones_freed, zone_freed))
	var attack: int = attack_ease(zone_id, zones_freed, zone_freed)
	if setup != null and attack != 0:
		setup.modifiers.add_source(CardBuilder.modifier_source("Zone order ease", ModifierSource.SourceKind.ZONE, [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, attack, Modifier.ANY_COLOR, 0)] as Array[Modifier]))


## Eases an enemy seat in place: its starting and max HP times `factor` (at least 4).
static func apply(setup: PlayerSetup, factor: float) -> void:
	if setup == null or is_equal_approx(factor, 1.0):
		return
	setup.starting_hp = maxi(4, roundi(float(setup.starting_hp) * factor))
	if setup.profile != null:
		setup.profile.max_hp = maxi(setup.starting_hp, roundi(float(setup.profile.max_hp) * factor))
