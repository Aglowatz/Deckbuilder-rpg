class_name DnaEnemies
extends RefCounted
## The three roaming enemy designs of the D.N.A. (single source of truth for stats, AI ranges,
## decks and rewards - the scene only places and animates them). Placeholder numbers, balance is
## out of scope for this proof of concept.
##
##  - `manager`  Shambling Middle Manager - slow, touching starts a card battle.
##  - `intern`   Zombie Intern            - slow, touching starts a card battle.
##  - `courier`  Speedy Ghost Courier     - fast, touching deals 2 damage with knockback and a short
##                                           invulnerability window; it never starts a battle.
## Shared contact constants live in `ZoneEnemies`; the shapes in `ZoneEnemyInfo`.

const MANAGER: String = "manager"
const INTERN: String = "intern"
const COURIER: String = "courier"
const IDS: Array[String] = [MANAGER, INTERN, COURIER]

const PLAYER_SPEED: float = ZoneEnemies.PLAYER_SPEED
const COURIER_DAMAGE: int = 2
const HIT_COOLDOWN: float = ZoneEnemies.HIT_COOLDOWN
const KNOCKBACK_DISTANCE: float = ZoneEnemies.KNOCKBACK_DISTANCE
const COURIER_RETREAT_TIME: float = ZoneEnemies.RETREAT_TIME


static func info(id: String) -> ZoneEnemyInfo:
	var made: ZoneEnemyInfo = ZoneEnemyInfo.new()
	made.id = id
	match id:
		MANAGER:
			made.display_name = "Shambling Middle Manager"
			made.kind = ZoneEnemyInfo.Kind.BATTLE
			made.patrol_speed = 0.8
			made.chase_speed = 1.9
			made.aggro_range = 5.5
			made.leash_range = 9.0
			made.recipe = {
				"land:D": 16, "middle_manager": 3, "cubicle_zombie": 3, "soul_auditor": 2,
				"performance_review": 2, "death_benefits": 1,
			}
			made.life = 14
			made.ai_name = "Balanced"
			made.gold_reward = 30
			made.xp_reward = 40
			made.model = "character-zombie"
			made.tint = Color(0.78, 0.85, 1.0)
			made.model_scale = 1.1
			made.accessories = [
				{"offset": Vector3(0.05, 0.32, 0.17), "size": Vector3(0.07, 0.3, 0.02), "color": Color(0.75, 0.1, 0.1)},
				{"offset": Vector3(0.28, 0.3, 0.12), "size": Vector3(0.22, 0.28, 0.03), "color": Color(0.85, 0.82, 0.7)},
			]
		INTERN:
			made.display_name = "Zombie Intern"
			made.kind = ZoneEnemyInfo.Kind.BATTLE
			made.patrol_speed = 1.0
			made.chase_speed = 2.2
			made.aggro_range = 5.0
			made.leash_range = 8.0
			made.recipe = {
				"land:D": 15, "overdue_intern": 4, "cubicle_zombie": 3, "mandatory_fun_day": 2,
				"take_a_number": 1, "hr_reaper": 1,
			}
			made.life = 10
			made.ai_name = "Aggressive"
			made.gold_reward = 25
			made.xp_reward = 35
			made.model = "character-skeleton"
			made.tint = Color(0.75, 1.0, 0.7)
			made.model_scale = 0.9
			made.accessories = [
				{"offset": Vector3(0.0, 0.32, 0.15), "size": Vector3(0.06, 0.28, 0.02), "color": Color(0.9, 0.6, 0.1)},
				{"offset": Vector3(-0.28, 0.28, 0.1), "size": Vector3(0.1, 0.13, 0.1), "color": Color(0.95, 0.95, 0.9)},
			]
		COURIER:
			made.display_name = "Speedy Ghost Courier"
			made.kind = ZoneEnemyInfo.Kind.DAMAGE
			made.damage = COURIER_DAMAGE
			made.patrol_speed = 2.0
			made.chase_speed = 4.7
			made.aggro_range = 6.5
			made.leash_range = 11.0
			made.touch_range = 0.6
			made.model = "character-ghost"
			made.tint = Color(0.7, 1.0, 1.0)
			made.model_scale = 0.95
			made.hover = true
			made.ghostly = true
			made.accessories = [
				{"offset": Vector3(0.3, 0.28, 0.12), "size": Vector3(0.24, 0.16, 0.03), "color": Color(1.0, 0.95, 0.7)},
			]
	return made


static func is_slow(id: String) -> bool:
	return info(id).chase_speed < PLAYER_SPEED


static func deck(content: ContentSet, id: String) -> Deck:
	return ZoneEnemies.deck(content, DnaZone.ID, id)


static func personality(content: ContentSet, id: String) -> AIPersonality:
	return ZoneEnemies.personality(content, DnaZone.ID, id)


## The enemy seat for a zone duel: a Necrocrat deck and the type's own life total.
static func enemy_setup(content: ContentSet, id: String) -> PlayerSetup:
	return ZoneEnemies.enemy_setup(content, DnaZone.ID, id)
