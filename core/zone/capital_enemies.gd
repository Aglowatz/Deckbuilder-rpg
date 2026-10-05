class_name CapitalEnemies
extends RefCounted
## The roaming enemy designs of the Capital (placeholder numbers - balance is out of scope):
##
##  - `officer`   Compliance Officer   - slow; touching starts a (balanced) Necrocrat/Gourmand-deck battle ("a courtesy citation").
##  - `inspector` Perfection Inspector - slow; touching starts a (defensive) battle ("your smile is 0.4 degrees off").
##  - `tidybot`   Tidy-Bot             - FAST; 2 damage with knockback and a short invulnerability window; never starts a battle.
##  - `wretch`    Rift Wretch          - slow; spawned by a rift (the guardian of a sealable one); an aggressive battle.
##  - `swarm`     Shard Swarm          - FAST; rift-spawned; 2 damage with knockback; never starts a battle.
##  - `gate_captain` The Approved Gate Captain - not a roamer: the CHALLENGING battle that opens the gate.

const OFFICER: String = "officer"
const INSPECTOR: String = "inspector"
const TIDYBOT: String = "tidybot"
const WRETCH: String = "wretch"
const SWARM: String = "swarm"
const GATE_CAPTAIN: String = "gate_captain"
const IDS: Array[String] = [OFFICER, INSPECTOR, TIDYBOT, WRETCH, SWARM]
const FAST_DAMAGE: int = 2


static func info(id: String) -> ZoneEnemyInfo:
	var made: ZoneEnemyInfo = ZoneEnemyInfo.new()
	made.id = id
	match id:
		OFFICER:
			made.display_name = "Compliance Officer"
			made.kind = ZoneEnemyInfo.Kind.BATTLE
			made.patrol_speed = 0.7
			made.chase_speed = 1.9
			made.aggro_range = 5.5
			made.leash_range = 8.5
			made.recipe = {
				"infrastructure:D": 9, "infrastructure:B": 7, "compliance_officer": 4, "gate_guard": 3, "citation": 3,
				"decree_of_order": 2, "middle_manager": 2,
			}
			made.life = 14
			made.ai_name = "Balanced"
			made.gold_reward = 35
			made.xp_reward = 45
			made.model = "kaykit:Knight"
			made.anim_idle = &"Idle"
			made.anim_walk = &"Walking_A"
			made.anim_run = &"Running_A"
			made.tint = Color(0.78, 0.8, 0.9)
			made.model_scale = 1.15
			made.accessories = [
				{"offset": Vector3(0.0, 0.95, 0.38), "size": Vector3(0.38, 0.5, 0.05), "color": Color(0.95, 0.93, 0.85)},
				{"offset": Vector3(0.0, 1.5, 0.0), "size": Vector3(0.5, 0.12, 0.5), "color": Color(0.18, 0.2, 0.3)},
			] as Array[Dictionary]
		INSPECTOR:
			made.display_name = "Perfection Inspector"
			made.kind = ZoneEnemyInfo.Kind.BATTLE
			made.patrol_speed = 0.6
			made.chase_speed = 1.7
			made.aggro_range = 5.0
			made.leash_range = 8.0
			made.recipe = {
				"infrastructure:D": 9, "infrastructure:A": 6, "perfection_inspector": 4, "compliance_officer": 3,
				"citation": 3, "tidy_bot": 3, "soul_auditor": 2,
			}
			made.life = 16
			made.ai_name = "Defensive"
			made.gold_reward = 40
			made.xp_reward = 50
			made.model = "kaykit:Mage"
			made.anim_idle = &"Idle"
			made.anim_walk = &"Walking_A"
			made.anim_run = &"Running_A"
			made.tint = Color(1.25, 1.25, 1.3)
			made.model_scale = 1.15
			made.accessories = [
				{"offset": Vector3(0.38, 0.8, 0.2), "size": Vector3(0.14, 0.3, 0.05), "color": Color(0.9, 0.9, 0.95)},
				{"offset": Vector3(-0.3, 0.8, 0.25), "size": Vector3(0.16, 0.16, 0.16), "color": Color(0.95, 0.95, 1.0)},
			] as Array[Dictionary]
		TIDYBOT:
			made.display_name = "Tidy-Bot"
			made.kind = ZoneEnemyInfo.Kind.DAMAGE
			made.damage = FAST_DAMAGE
			made.patrol_speed = 2.4
			made.chase_speed = 5.0
			made.aggro_range = 7.0
			made.leash_range = 11.0
			made.touch_range = 0.7
			made.model = "capital:tidybot"
			made.model_scale = 1.0
		WRETCH:
			made.display_name = "Rift Wretch"
			made.kind = ZoneEnemyInfo.Kind.BATTLE
			made.patrol_speed = 0.7
			made.chase_speed = 1.8
			made.aggro_range = 5.5
			made.leash_range = 8.0
			made.recipe = {
				"infrastructure:C": 8, "infrastructure:D": 7, "rift_wretch": 4, "shard_swarm": 3, "landfill_hog": 3,
				"compost_golem": 2, "vine_snare": 2, "cubicle_zombie": 2,
			}
			made.life = 15
			made.ai_name = "Aggressive"
			made.gold_reward = 45
			made.xp_reward = 55
			made.model = "capital:wretch"
			made.model_scale = 1.2
		SWARM:
			made.display_name = "Shard Swarm"
			made.kind = ZoneEnemyInfo.Kind.DAMAGE
			made.damage = FAST_DAMAGE
			made.patrol_speed = 2.6
			made.chase_speed = 5.2
			made.aggro_range = 7.5
			made.leash_range = 11.0
			made.touch_range = 0.7
			made.model = "capital:swarm"
			made.model_scale = 1.0
			made.hover = true
		GATE_CAPTAIN:
			made.display_name = "The Approved Gate Captain"
			made.kind = ZoneEnemyInfo.Kind.BATTLE
			made.recipe = {
				"infrastructure:D": 8, "infrastructure:B": 8, "approved_gate_captain": 2, "gate_guard": 4, "compliance_officer": 4,
				"citation": 4, "perfection_inspector": 3, "decree_of_order": 3, "middle_manager": 2, "sneeze_guard": 2,
			}
			made.life = 24
			made.ai_name = "Aggressive"
			made.gold_reward = 120
			made.xp_reward = 120
			made.model = "kaykit:Knight"
			made.anim_idle = &"Idle"
			made.anim_walk = &"Walking_A"
			made.anim_run = &"Running_A"
	return made


static func deck(content: ContentSet, id: String) -> Deck:
	return ZoneEnemies.deck(content, CapitalZone.ID, id)
