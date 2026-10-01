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

enum Kind { BATTLE, DAMAGE }

const MANAGER: String = "manager"
const INTERN: String = "intern"
const COURIER: String = "courier"
const IDS: Array[String] = [MANAGER, INTERN, COURIER]

## The player walks at TownPlayer.SPEED (3.4). Slow types must stay clearly below it.
const PLAYER_SPEED: float = 3.4

const COURIER_DAMAGE: int = 2
## Seconds of invulnerability after the player takes a hit, and the knockback shove (metres).
const HIT_COOLDOWN: float = 1.6
const KNOCKBACK_DISTANCE: float = 1.7
## Seconds a defeated/just-hit enemy cannot touch the player again (so they can walk away).
const COURIER_RETREAT_TIME: float = 2.2


class Info:
	extends RefCounted
	var id: String = ""
	var display_name: String = ""
	var kind: Kind = Kind.BATTLE
	var patrol_speed: float = 0.0
	var chase_speed: float = 0.0
	## Starts chasing when the player is this close (metres) ...
	var aggro_range: float = 0.0
	## ... and gives up once the player is this far from the enemy's patrol home (metres).
	var leash_range: float = 0.0
	var touch_range: float = 0.55
	## Battle opponents only.
	var recipe: Dictionary = {}
	var life: int = 10
	var ai_name: String = "Balanced"
	var gold_reward: int = 0
	var xp_reward: int = 0
	## Visual: a Kenney Graveyard Kit character, a tint, and a scale.
	var model: String = ""
	var tint: Color = Color.WHITE
	var model_scale: float = 1.0


static func info(id: String) -> Info:
	var made: Info = Info.new()
	made.id = id
	match id:
		MANAGER:
			made.display_name = "Shambling Middle Manager"
			made.kind = Kind.BATTLE
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
		INTERN:
			made.display_name = "Zombie Intern"
			made.kind = Kind.BATTLE
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
		COURIER:
			made.display_name = "Speedy Ghost Courier"
			made.kind = Kind.DAMAGE
			made.patrol_speed = 2.0
			made.chase_speed = 4.7
			made.aggro_range = 6.5
			made.leash_range = 11.0
			made.touch_range = 0.6
			made.model = "character-ghost"
			made.tint = Color(0.7, 1.0, 1.0)
			made.model_scale = 0.95
	return made


static func is_slow(id: String) -> bool:
	return info(id).chase_speed < PLAYER_SPEED


static func deck(content: ContentSet, id: String) -> Deck:
	var data: Info = info(id)
	return ZoneDecks.from_recipe(content, data.display_name, data.recipe)


static func personality(content: ContentSet, id: String) -> AIPersonality:
	var wanted: String = info(id).ai_name
	for candidate: AIPersonality in content.personalities:
		if candidate.personality_name == wanted:
			return candidate
	return AIPersonality.balanced()


## The enemy seat for a zone duel: a Necrocrat deck and the type's own life total.
static func enemy_setup(content: ContentSet, id: String) -> PlayerSetup:
	var data: Info = info(id)
	var setup: PlayerSetup = PlayerSetup.create(deck(content, id), null, [] as Array[ModifierSource], data.display_name)
	setup.starting_life = data.life
	setup.profile = PlayerProfile.new()
	setup.profile.max_life = data.life
	return setup
