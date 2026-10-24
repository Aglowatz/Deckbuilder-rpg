class_name ZoneEnemies
extends RefCounted
## Zone-independent access to roaming enemy data: dispatches on the zone id to that zone's enemy
## table and builds the decks/personalities/duel seats from the shared `ZoneEnemyInfo`.

## The design speed the enemy numbers were tuned against (3.4). The player now walks faster (TownPlayer.SPEED, storybook scale); `ZoneEnemy` multiplies enemy speeds by the same ratio so the relations (slow types below the player, couriers above) hold.
const PLAYER_SPEED: float = 3.4
## Seconds of invulnerability after the player takes a hit, and the knockback shove (metres).
const HIT_COOLDOWN: float = 1.6
const KNOCKBACK_DISTANCE: float = 1.7
## Seconds a defeated/just-hit enemy cannot touch the player again (so they can walk away).
const RETREAT_TIME: float = 2.2


static func info(zone_id: String, enemy_id: String) -> ZoneEnemyInfo:
	match zone_id:
		GainlandsZone.ID:
			return GainlandsEnemies.info(enemy_id)
		CapitalZone.ID:
			return CapitalEnemies.info(enemy_id)
		HeapZone.ID:
			return HeapEnemies.info(enemy_id)
		BuffetZone.ID:
			return BuffetEnemies.info(enemy_id)
	return DnaEnemies.info(enemy_id)


static func is_slow(zone_id: String, enemy_id: String) -> bool:
	return info(zone_id, enemy_id).chase_speed < PLAYER_SPEED


static func deck(content: ContentSet, zone_id: String, enemy_id: String) -> Deck:
	var data: ZoneEnemyInfo = info(zone_id, enemy_id)
	return ZoneDecks.from_recipe(content, data.display_name, data.recipe)


static func personality(content: ContentSet, zone_id: String, enemy_id: String) -> AIPersonality:
	return ZoneDecks.personality(content, info(zone_id, enemy_id).ai_name)


## Overnight Oct 23, Part 2: once a zone is freed, its roamers come back as sparring partners playing two Paths - their own and a
## neighbour's - each deck built around one synergy a player can copy (EnemyDecks' two-Path archetypes).
const FREED_DECKS: Dictionary = {
	"beefcake": "gourmand_beefcake_bulk", "necrocrat": "necrocrat_beefcake", "gourmand": "gourmand_refusemancer_farm",
	"refusemancer": "beefcake_refusemancer_gym",
}
## A sparring partner is met well after the zone's own level: more HP, so the two Paths have time to show their synergy.
const FREED_HP_BONUS: int = 10


## The two-Path recipe a freed zone's roamer plays ({} when it keeps its own: elites, touch-damage roamers, the Capital), the same
## size and number of basics as its own deck.
static func freed_recipe(zone_id: String, enemy_id: String) -> Dictionary:
	if not FREED_DECKS.has(zone_id) or EncounterCatalog.ZONE_ELITES.has(enemy_id):
		return {}
	var data: ZoneEnemyInfo = info(zone_id, enemy_id)
	if data == null or data.kind != ZoneEnemyInfo.Kind.BATTLE or data.recipe.is_empty():
		return {}
	var total: int = 0
	var basics: int = 0
	for id: Variant in data.recipe.keys():
		total += int(data.recipe[id])
		if str(id).begins_with("BAS-"):
			basics += int(data.recipe[id])
	return EnemyDecks.trimmed(str(FREED_DECKS[zone_id]), total, basics)


## The enemy seat for a zone duel: the type's deck and its own HP total (`freed`: the zone is free - a two-Path sparring deck).
static func enemy_setup(content: ContentSet, zone_id: String, enemy_id: String, freed: bool = false) -> PlayerSetup:
	var data: ZoneEnemyInfo = info(zone_id, enemy_id)
	var sparring: Dictionary = freed_recipe(zone_id, enemy_id) if freed else {}
	var seat_deck: Deck = ZoneDecks.from_recipe(content, data.display_name, sparring) if not sparring.is_empty() else deck(content, zone_id, enemy_id)
	var setup: PlayerSetup = PlayerSetup.create(seat_deck, null, [] as Array[ModifierSource], data.display_name)
	var hp: int = data.hp + (FREED_HP_BONUS if not sparring.is_empty() else 0)
	setup.starting_hp = hp
	setup.profile = PlayerProfile.new()
	setup.profile.max_hp = hp
	# Rebalance Part E: the roamer's one-sided encounter rules (data/encounters/modifiers.json), keyed "zone:<zone>:<enemy>".
	EncounterModifiers.apply_to_enemy(setup, EncounterModifiers.zone_key(zone_id, enemy_id))
	return setup
