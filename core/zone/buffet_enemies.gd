class_name BuffetEnemies
extends RefCounted
## The roaming enemy designs of the Endless Buffet (placeholder numbers - balance is out of scope):
##
##  - `loaf`      Meatloaf Golem      - slow, lumbering; touching starts a (aggressive) Gourmand-deck battle.
##  - `jelly`     Gelatin Sentinel    - slow, wobbling; touching starts a (defensive) Gourmand-deck battle.
##  - `meatball`  Runaway Meatball    - fast, rolling; 2 damage with knockback and a short invulnerability
##                                      window on touch; it never starts a battle.
##  - `casserole` Colonel Casserole   - the battle gate's golem: never roams, you fight it at its gate.

const LOAF: String = "loaf"
const JELLY: String = "jelly"
const MEATBALL: String = "meatball"
const CASSEROLE: String = "casserole"
const IDS: Array[String] = [LOAF, JELLY, MEATBALL]
const MEATBALL_DAMAGE: int = 2


static func info(id: String) -> ZoneEnemyInfo:
	var made: ZoneEnemyInfo = ZoneEnemyInfo.new()
	made.id = id
	match id:
		LOAF:
			made.display_name = "Meatloaf Golem"
			made.kind = ZoneEnemyInfo.Kind.BATTLE
			made.patrol_speed = 0.7
			made.chase_speed = 1.8
			made.aggro_range = 5.5
			made.leash_range = 8.5
			made.recipe = {
				"infrastructure:B": 16, "breadstick_sentry": 3, "meatloaf_golem": 3, "gravy_courier": 2,
				"food_fight": 2, "soup_of_the_day": 1,
			}
			made.life = 14
			made.ai_name = "Aggressive"
			made.gold_reward = 30
			made.xp_reward = 40
			made.model = "buffet:loaf"
			made.model_scale = 1.35
		JELLY:
			made.display_name = "Gelatin Sentinel"
			made.kind = ZoneEnemyInfo.Kind.BATTLE
			made.patrol_speed = 0.6
			made.chase_speed = 1.6
			made.aggro_range = 5.0
			made.leash_range = 8.0
			made.recipe = {
				"infrastructure:B": 15, "gelatin_sentinel": 4, "sneeze_guard": 2, "soup_of_the_day": 3,
				"sous_assist": 2, "souffle_sprite": 1,
			}
			made.life = 16
			made.ai_name = "Defensive"
			made.gold_reward = 35
			made.xp_reward = 45
			made.model = "buffet:jelly"
			made.model_scale = 1.35
		MEATBALL:
			made.display_name = "Runaway Meatball"
			made.kind = ZoneEnemyInfo.Kind.DAMAGE
			made.damage = MEATBALL_DAMAGE
			made.patrol_speed = 2.3
			made.chase_speed = 4.9
			made.aggro_range = 7.0
			made.leash_range = 11.0
			made.touch_range = 0.65
			made.model = "buffet:meatball"
			made.model_scale = 1.0
		CASSEROLE:
			made.display_name = "Colonel Casserole"
			made.kind = ZoneEnemyInfo.Kind.BATTLE
			made.recipe = {
				"infrastructure:B": 16, "meatloaf_golem": 3, "gelatin_sentinel": 2, "breadstick_sentry": 3,
				"sneeze_guard": 2, "food_fight": 2, "sous_assist": 1,
			}
			made.life = 16
			made.ai_name = "Balanced"
			made.gold_reward = 50
			made.xp_reward = 60
			made.model = "buffet:casserole"
	return made


static func deck(content: ContentSet, id: String) -> Deck:
	return ZoneEnemies.deck(content, BuffetZone.ID, id)
