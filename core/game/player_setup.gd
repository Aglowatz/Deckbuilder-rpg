class_name PlayerSetup
extends RefCounted
## Everything needed to seat one player in a duel.

var player_name: String = "Player"
var deck: Deck
var profile: PlayerProfile
## All modifiers affecting this player (gear, zone, dungeon, boons...).
var modifiers: ModifierSet = ModifierSet.new()
## HP at the start of the duel; -1 = max HP (+ STARTING_LIFE modifiers).
var starting_hp: int = -1
## Overnight Nov 4-5, Part 8: a max HP below the profile's floor (the tutorial cave's 3-HP foes, whose bar read 3 of 15); -1 = from the profile.
var max_hp_cap: int = -1


## Builds a setup whose modifiers are the profile's gear plus any extra sources.
static func create(
	player_deck: Deck,
	player_profile: PlayerProfile = null,
	extra_sources: Array[ModifierSource] = [],
	name: String = "Player",
) -> PlayerSetup:
	var setup: PlayerSetup = PlayerSetup.new()
	setup.player_name = name
	setup.deck = player_deck
	setup.profile = player_profile if player_profile != null else PlayerProfile.new()
	setup.modifiers = setup.profile.gear_modifiers()
	setup.modifiers.add_sources(extra_sources)
	return setup
