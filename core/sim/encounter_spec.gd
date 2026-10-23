class_name EncounterSpec
extends RefCounted
## One fight of the game as the balance simulation sees it (Rebalance Part B): who the enemy is (deck recipe, HP, AI), the one-sided
## rules on either seat, where it is fought (zone effects, dungeon rules), what the on-level player should look like
## (`expected_level`) and the win-rate band it should land in. Built by `EncounterCatalog` from the game's own definitions, so the
## simulation plays exactly what the player meets.

enum Kind { TUTORIAL, NORMAL, ELITE, BOSS }

## Target player win-rate bands (first try, on-level player) per kind: [low, high].
const TARGETS: Dictionary = {
	Kind.TUTORIAL: [0.85, 1.0],
	Kind.NORMAL: [0.80, 1.0],
	Kind.ELITE: [0.60, 0.75],
	Kind.BOSS: [0.40, 0.60],
}
const TURNS_TARGET: Array[int] = [6, 10]

var id: String = ""
var title: String = ""
## "tutorial", "town", "zone:<zone id>", "dungeon:<D-ID>", "side:<S-ID>", "arena", "postgame:<D-ID>".
var group: String = ""
var kind: Kind = Kind.NORMAL
var expected_level: int = 1
## The zone whose effects apply to both seats ("" = none).
var zone_id: String = ""
## The dungeon key (`MainDungeons`) and node number whose `DungeonRules` apply ("" = none).
var dungeon_key: String = ""
var node_number: int = 0
var enemy_name: String = "Enemy"
var enemy_hp: int = 15
var enemy_ai_name: String = "Balanced"
## Card ID -> copies (BAS-x are the basic Infrastructure).
var enemy_recipe: Dictionary = {}
## A builder (ContentSet -> PlayerSetup) for the scripted bosses that assemble their own seat (the Graveyard, the Vault, Shiro Swindle);
## when set it replaces `enemy_recipe` / `enemy_hp` / `enemy_sources`.
var enemy_builder: Callable = Callable()
## One-sided rules: on the enemy's seat and on the player's seat (shown to the player as icon + tooltip, `EncounterModifiers`).
var enemy_sources: Array[ModifierSource] = []
var player_sources: Array[ModifierSource] = []
## 0 / 1 = fixed first player, -1 = alternate with the seed.
var first_player: int = -1
## Primm's Reflection phase: the enemy plays a copy of the player's deck.
var mirror_player_deck: bool = false
## Tokens placed on the player's field at the start (Grandmaster Flex in the House of Gains boss duel).
var ally_token_ids: Array[String] = []
## Arena battles with a restricted kit replace the player's deck (Card ID -> copies) and may fix the player's HP.
var player_recipe: Dictionary = {}
var player_hp: int = -1
## Fights that share one HP pool without healing between them (a zone's roamers, a side dungeon): the sequence key.
var sequence: String = ""
var notes: String = ""


static func kind_name(value: Kind) -> String:
	return str(Kind.keys()[value]).capitalize()


## Battle AI upgrade, Part 4: the AI skill each kind of fight plays at (the game and the sim use the same mapping).
static func skill_for(value: Kind) -> AIPlayer.Skill:
	match value:
		Kind.BOSS:
			return AIPlayer.Skill.BOSS
		Kind.ELITE:
			return AIPlayer.Skill.ELITE
	return AIPlayer.Skill.NORMAL


func target() -> Array:
	return TARGETS[kind] as Array


func target_text() -> String:
	var band: Array = target()
	return "%d-%d%%" % [roundi(float(band[0]) * 100.0), roundi(float(band[1]) * 100.0)]


func in_target(win_rate: float) -> bool:
	var band: Array = target()
	return win_rate >= float(band[0]) - 0.0001 and win_rate <= float(band[1]) + 0.0001


## The enemy's seat for one game. `player_deck` is only read by a mirror encounter.
func build_enemy(content: ContentSet, player_deck: Deck) -> PlayerSetup:
	if enemy_builder.is_valid():
		var built: PlayerSetup = enemy_builder.call(content) as PlayerSetup
		for source: ModifierSource in enemy_sources:
			built.modifiers.add_source(source)
		return built
	var deck: Deck
	if mirror_player_deck and player_deck != null:
		deck = Deck.new()
		deck.deck_name = "A Perfect Copy"
		deck.cards = player_deck.cards.duplicate()
	else:
		deck = ZoneDecks.from_recipe(content, enemy_name, enemy_recipe)
	var setup: PlayerSetup = PlayerSetup.create(deck, null, [] as Array[ModifierSource], enemy_name)
	setup.starting_hp = enemy_hp
	setup.profile = PlayerProfile.new()
	setup.profile.max_hp = maxi(enemy_hp, PlayerProfile.START_MAX_HP)
	for source: ModifierSource in enemy_sources:
		setup.modifiers.add_source(source)
	return setup


## The rules both seats get here: the zone's effects plus the dungeon's shared rules (null when none).
func shared_source() -> ModifierSource:
	var zone_source: ModifierSource = ZoneEffects.source_for(zone_id) if not zone_id.is_empty() else null
	if dungeon_key.is_empty():
		return zone_source
	return DungeonRules.with_shared(zone_source, dungeon_key, node_number)


## The player-only dungeon rules here (null when none).
func player_rules_source() -> ModifierSource:
	if dungeon_key.is_empty():
		return null
	return DungeonRules.player_source(dungeon_key, node_number)


## The one-sided rules as short labels (for reports).
func modifier_labels() -> Array[String]:
	var result: Array[String] = []
	for source: ModifierSource in enemy_sources:
		result.append("enemy: " + source.source_name)
	for source: ModifierSource in player_sources:
		result.append("player: " + source.source_name)
	if mirror_player_deck:
		result.append("mirror deck")
	for id: String in ally_token_ids:
		result.append("ally " + id)
	return result
