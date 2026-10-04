class_name GainlandsEnemies
extends RefCounted
## The three roaming enemy designs of the Gainlands (placeholder numbers - balance is out of scope):
##
##  - `brute`   Flexing Brute          - slow; touching starts a Beefcake-deck card battle.
##  - `golem`   Protein Shake Golem    - slow; touching starts a (defensive) Beefcake-deck battle.
##  - `sprite`  Sprinting Energy Sprite - fast; 2 damage with knockback and a short invulnerability
##                                       window on touch; it never starts a battle.

const BRUTE: String = "brute"
const GOLEM: String = "golem"
const SPRITE: String = "sprite"
const IDS: Array[String] = [BRUTE, GOLEM, SPRITE]
const SPRITE_DAMAGE: int = 2


static func info(id: String) -> ZoneEnemyInfo:
	var made: ZoneEnemyInfo = ZoneEnemyInfo.new()
	made.id = id
	match id:
		BRUTE:
			made.display_name = "Flexing Brute"
			made.kind = ZoneEnemyInfo.Kind.BATTLE
			made.patrol_speed = 0.9
			made.chase_speed = 2.0
			made.aggro_range = 6.0
			made.leash_range = 9.5
			made.recipe = {
				"infrastructure:A": 16, "gym_rat": 3, "pump_chaser": 3, "courtesy_chucker": 2,
				"flex_off": 2, "leg_day": 1,
			}
			made.life = 14
			made.ai_name = "Aggressive"
			made.gold_reward = 30
			made.xp_reward = 40
			made.model = "kaykit:Barbarian"
			made.tint = Color(1.0, 0.72, 0.5)
			made.model_scale = 0.62
			made.anim_idle = &"Idle"
			made.anim_walk = &"Walking_A"
			made.anim_run = &"Running_A"
			made.accessories = [
				{"offset": Vector3(0.38, 0.55, 0.12), "size": Vector3(0.09, 0.09, 0.42), "color": Color(0.25, 0.25, 0.3)},
				{"offset": Vector3(0.38, 0.55, 0.36), "size": Vector3(0.2, 0.2, 0.2), "color": Color(0.35, 0.35, 0.4)},
				{"offset": Vector3(0.38, 0.55, -0.12), "size": Vector3(0.2, 0.2, 0.2), "color": Color(0.35, 0.35, 0.4)},
			]
		GOLEM:
			made.display_name = "Protein Shake Golem"
			made.kind = ZoneEnemyInfo.Kind.BATTLE
			made.patrol_speed = 0.7
			made.chase_speed = 1.7
			made.aggro_range = 5.0
			made.leash_range = 8.0
			made.recipe = {
				"infrastructure:A": 15, "protein_golem": 4, "mill_hand": 3, "cheat_day": 2,
				"gym_rat": 2, "pre_workout": 1,
			}
			made.life = 16
			made.ai_name = "Defensive"
			made.gold_reward = 35
			made.xp_reward = 45
			made.model = "proc:golem"
			made.tint = Color.WHITE
			made.model_scale = 1.2
		SPRITE:
			made.display_name = "Sprinting Energy Sprite"
			made.kind = ZoneEnemyInfo.Kind.DAMAGE
			made.damage = SPRITE_DAMAGE
			made.patrol_speed = 2.2
			made.chase_speed = 4.9
			made.aggro_range = 7.0
			made.leash_range = 11.0
			made.touch_range = 0.6
			made.model = "proc:sprite"
			made.tint = Color.WHITE
			made.model_scale = 1.35
			made.hover = true
	return made


static func deck(content: ContentSet, id: String) -> Deck:
	return ZoneEnemies.deck(content, GainlandsZone.ID, id)
