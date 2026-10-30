class_name GainlandsEnemies
extends RefCounted
## The three roaming enemy designs of the Gainlands (placeholder numbers - balance is out of scope):
##
##  - `brute`   Quota Spotter          - slow; touching starts a Beefcake-deck card battle.
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
			made.display_name = "Quota Spotter"
			made.kind = ZoneEnemyInfo.Kind.BATTLE
			made.patrol_speed = 0.9
			made.chase_speed = 2.0
			made.aggro_range = 6.0
			made.leash_range = 9.5
			made.recipe = EnemyDecks.trimmed("beefcake_rush", 24, 11)  # Oct 21: 11 basics (was 14; Rebalance Part E: 27 cards / 16 infra, 14 HP, Aggressive -> 24, 9, Balanced)
			made.hp = 4  # Oct 21: the L5 Necrocrat brief (was 7; 63% at 9 HP on Oct 18)
			made.ai_name = "Balanced"
			made.gold_reward = Economy.roamer_gold("beefcake")
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
			made.recipe = {"BAS-B": 9, "B-05": 2, "B-08": 3, "B-09": 2, "B-02": 2, "B-14": 2, "B-16": 2, "B-15": 1, "B-18": 1}  # Oct 21: the tools without the burst and removal (Kettlebell, Yeet, Pre-Workout); was trimmed("beefcake_tools", 24, 12)
			made.hp = 3  # Oct 21: the L5 Necrocrat brief (was 7; 63% at 9 HP on Oct 18)
			made.ai_name = "Aggressive"  # Oct 21: was Defensive: it walled every Path out (~65%) and won late on Iron
			made.gold_reward = Economy.roamer_gold("beefcake")
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
