class_name PlayerSetup
extends RefCounted
## Everything needed to seat one player in a duel.

var player_name: String = "Player"
var deck: Deck
var profile: PlayerProfile
## All modifiers affecting this player (gear, zone, dungeon, boons...).
var modifiers: ModifierSet = ModifierSet.new()
## Life at the start of the duel; -1 = max life (+ STARTING_LIFE modifiers).
var starting_life: int = -1


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
