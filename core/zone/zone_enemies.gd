class_name ZoneEnemies
extends RefCounted
## Zone-independent access to roaming enemy data: dispatches on the zone id to that zone's enemy
## table and builds the decks/personalities/duel seats from the shared `ZoneEnemyInfo`.

## The player walks at TownPlayer.SPEED (3.4). Slow types must stay clearly below it.
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


## The enemy seat for a zone duel: the type's deck and its own life total.
static func enemy_setup(content: ContentSet, zone_id: String, enemy_id: String) -> PlayerSetup:
	var data: ZoneEnemyInfo = info(zone_id, enemy_id)
	var setup: PlayerSetup = PlayerSetup.create(deck(content, zone_id, enemy_id), null, [] as Array[ModifierSource], data.display_name)
	setup.starting_life = data.life
	setup.profile = PlayerProfile.new()
	setup.profile.max_life = data.life
	return setup
