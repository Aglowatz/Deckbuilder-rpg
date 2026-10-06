class_name HeapEnemies
extends RefCounted
## The roaming enemy designs of the Verdant Dump (placeholder numbers - balance is out of scope):
##
##  - `golem`     Mossy Trash Golem        - slow and hulking; touching starts an (aggressive) Refusemancer-deck battle.
##  - `scarecrow` Possessed Scarecrow Druid - slow; touching starts a (defensive) Refusemancer-deck battle.
##  - `gulls`     Junk Gull Flock          - fast, dive-bombing; 2 damage with knockback and a short invulnerability
##                                           window on touch; it never starts a battle.

const GOLEM: String = "golem"
const SCARECROW: String = "scarecrow"
const GULLS: String = "gulls"
const IDS: Array[String] = [GOLEM, SCARECROW, GULLS]
const GULL_DAMAGE: int = 2


static func info(id: String) -> ZoneEnemyInfo:
	var made: ZoneEnemyInfo = ZoneEnemyInfo.new()
	made.id = id
	match id:
		GOLEM:
			made.display_name = "Mossy Trash Golem"
			made.kind = ZoneEnemyInfo.Kind.BATTLE
			made.patrol_speed = 0.7
			made.chase_speed = 1.8
			made.aggro_range = 5.5
			made.leash_range = 8.5
			made.recipe = {
				"infrastructure:C": 16, "scrap_goat": 3, "compost_golem": 3, "dung_beetle": 2,
				"vine_snare": 2, "sprout_surge": 1,
			}
			made.hp = 14
			made.ai_name = "Aggressive"
			made.gold_reward = 30
			made.xp_reward = 40
			made.model = "heap:golem"
			made.model_scale = 1.3
		SCARECROW:
			made.display_name = "Possessed Scarecrow Druid"
			made.kind = ZoneEnemyInfo.Kind.BATTLE
			made.patrol_speed = 0.6
			made.chase_speed = 1.6
			made.aggro_range = 5.0
			made.leash_range = 8.0
			made.recipe = {
				"infrastructure:C": 15, "tin_can_raccoon": 3, "bramble_trap": 2, "harvest_moon": 3,
				"dung_beetle": 3, "fertilizer_burst": 1,
			}
			made.hp = 16
			made.ai_name = "Defensive"
			made.gold_reward = 35
			made.xp_reward = 45
			made.model = "heap:scarecrow"
			made.model_scale = 1.3
		GULLS:
			made.display_name = "Junk Gull Flock"
			made.kind = ZoneEnemyInfo.Kind.DAMAGE
			made.damage = GULL_DAMAGE
			made.patrol_speed = 2.3
			made.chase_speed = 4.9
			made.aggro_range = 7.0
			made.leash_range = 11.0
			made.touch_range = 0.7
			made.model = "heap:gulls"
			made.model_scale = 1.1
			made.hover = true
	return made


static func deck(content: ContentSet, id: String) -> Deck:
	return ZoneEnemies.deck(content, HeapZone.ID, id)
