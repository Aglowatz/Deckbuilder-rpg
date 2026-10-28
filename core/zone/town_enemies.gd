class_name TownEnemies
extends RefCounted
## Playtest v0.4.0, Part D: three easy roaming enemies on the outskirts of Crosspath (the lanes round the edge of the hub, never the
## square), so a fresh deck has something to fight between the Forgotten Cave and the gatekeepers. They respawn after a while
## (`RESPAWN_SECONDS`), pay a little gold and XP, and together with the tutorial and the two starter quests carry a new hero to
## level 5 (the armory) in a few fights. Tuned with the balance sim so every Path's starter deck wins 85%+ (docs/design/balance_log.md).
##
##  - `hound`    Pantry Hound          - a sauce-drunk Buffet spaniel (Oct 28; was the Stray Gym Hound): a thin aggressive deck, 6 HP.
##  - `clerk`    Lost Junior Clerk     - a Necrocrat intern who took a wrong turn: a thin control deck, 7 HP.
##  - `raccoon`  Bin Raccoon           - a garbage-eating pest from the Dump road: a thin Refusemancer deck, 6 HP.

const HOUND: String = "hound"
const CLERK: String = "clerk"
const RACCOON: String = "raccoon"
const IDS: Array[String] = [HOUND, CLERK, RACCOON]
## The zone key the sim, the encounter rules and the bestiary file these fights under.
const ZONE_KEY: String = "town"
## A beaten roamer comes back after this long (game clock; walking out and back in does not reset it).
const RESPAWN_SECONDS: int = 240

## Where each one lives: home (x, z) on the loop lane round the town's edge, well away from the square, the spawn and the passages.
const SPAWNS: Array[Dictionary] = [
	{"id": "town_hound", "type": HOUND, "home": Vector3(50.0, 0.0, -17.6), "patrol": 3.2},
	{"id": "town_clerk", "type": CLERK, "home": Vector3(-16.6, 0.0, 6.0), "patrol": 3.0},
	{"id": "town_raccoon", "type": RACCOON, "home": Vector3(46.0, 0.0, 63.4), "patrol": 3.0},
]


static func info(id: String) -> ZoneEnemyInfo:
	var made: ZoneEnemyInfo = ZoneEnemyInfo.new()
	made.id = id
	made.kind = ZoneEnemyInfo.Kind.BATTLE
	made.patrol_speed = 0.8
	made.chase_speed = 1.9
	made.aggro_range = 4.5
	made.leash_range = 7.0
	match id:
		HOUND:
			made.display_name = "Pantry Hound"
			made.recipe = EnemyDecks.trimmed("gourmand_control", 20, 13)  # sim: beefcake_rush 6 HP 62%, beefcake_tools 5 HP 67% (Iron bursts), colorless_militia 5 HP 55%, necro_zombies 5 HP 72%
			made.hp = 3  # sim: 83% at 5 HP; Oct 22: 3 for the neutral-heavy starting decks (docs/design/balance_log.md)
			# Battle AI upgrade, Part 5: a level-1 roamer should not cook 4/4 Cake Golems or Plate the starter's only wall (63% under the new AI).
			made.recipe.erase("G-08")
			made.recipe.erase("G-20")
			made.ai_name = "Defensive"
			made.gold_reward = 12
			made.xp_reward = 30
			made.model = "character-zombie"
			made.tint = Color(1.0, 0.82, 0.6)
			made.model_scale = 0.75
			made.anim_idle = &"idle"
			made.anim_walk = &"walk"
			made.anim_run = &"sprint"
		CLERK:
			made.display_name = "Lost Junior Clerk"
			made.recipe = EnemyDecks.trimmed("necro_control", 20, 10)
			made.hp = 4  # Oct 22: was 5 (neutral-heavy starting decks); sim: 88% at 7 and at 6 HP (Gourmand 80); a touch easier so every Path clears 85+
			made.ai_name = "Defensive"
			made.gold_reward = 14
			made.xp_reward = 32
			made.model = "kaykit:Rogue"
			made.tint = Color(0.82, 0.86, 1.0)
			made.model_scale = 0.6
			made.anim_idle = &"Idle"
			made.anim_walk = &"Walking_A"
			made.anim_run = &"Running_A"
			made.accessories = [
				{"offset": Vector3(0.0, 0.62, 0.2), "size": Vector3(0.12, 0.26, 0.03), "color": Color(0.45, 0.2, 0.25)},
				{"offset": Vector3(0.28, 0.5, 0.18), "size": Vector3(0.16, 0.2, 0.03), "color": Color(0.92, 0.9, 0.8)},
			]
		RACCOON:
			made.display_name = "Bin Raccoon"
			made.recipe = EnemyDecks.trimmed("refuse_rats", 20, 13)  # sim: 20/10 at 6 HP was 68%, 20/12 at 5 HP 82% (raccoon v1, v2); Oct 22: 20/13
			made.hp = 3  # Oct 22: was 4 (neutral-heavy starting decks)
			made.ai_name = "Defensive"
			made.gold_reward = 12
			made.xp_reward = 30
			made.model = "character-keeper"
			made.tint = Color(0.6, 0.6, 0.65)
			made.model_scale = 0.62
			made.anim_idle = &"idle"
			made.anim_walk = &"walk"
			made.anim_run = &"sprint"
	return made


static func display_name(id: String) -> String:
	return info(id).display_name


static func deck(content: ContentSet, id: String) -> Deck:
	var data: ZoneEnemyInfo = info(id)
	return ZoneDecks.from_recipe(content, data.display_name, data.recipe)


static func personality(content: ContentSet, id: String) -> AIPersonality:
	return ZoneDecks.personality(content, info(id).ai_name)


## The enemy seat for a Crosspath duel: the roamer's thin deck at its own small HP total (plus any one-sided rules keyed "zone:town:<id>").
static func enemy_setup(content: ContentSet, id: String) -> PlayerSetup:
	var data: ZoneEnemyInfo = info(id)
	var setup: PlayerSetup = PlayerSetup.create(deck(content, id), null, [] as Array[ModifierSource], data.display_name)
	setup.starting_hp = data.hp
	setup.profile = PlayerProfile.new()
	setup.profile.max_hp = data.hp
	EncounterModifiers.apply_to_enemy(setup, EncounterModifiers.zone_key(ZONE_KEY, id))
	return setup


## The spawn entry of an instance id ({} when unknown).
static func spawn(instance_id: String) -> Dictionary:
	for entry: Dictionary in SPAWNS:
		if str(entry["id"]) == instance_id:
			return entry
	return {}
