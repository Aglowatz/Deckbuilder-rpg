class_name OldWellQuest
extends RefCounted
## Overnight Oct 19-20, Part 6: the Old Well secret quest ("The Water Under the Well"). Touching the Old Well in Crosspath once a Path zone is
## free plays a vision and starts a hidden quest; two hums answer, one at the head of the Verdant Dump's river on its highest terrace and one at
## the little gravy pond in the Endless Buffet's Broccoli Forest (any order, each an interact spot that only exists while that step is open);
## back at the well, a node-based duel against the Wellspring's Echo (a four-Path deck with one one-sided rule, "The Spring Remembers"); the
## first win completes the quest (a unique relic, gold, XP) and plays the final vision. The vault under the well (S-TOWN) is untouched.
## Single source of truth for ids, flags, spot positions, the deck and the reward; the text is `data/story/old_well_story.json`
## (`OldWellStory`), the world side is `world/old_well/old_well_spot.gd` and `TownScene._use_well`. Lore: docs/design/story_bible.md section 4.

const QUEST_ID: String = "secret_old_well"
## Set when the Dump's and the Buffet's hums are found, and when the Echo is beaten the first time (the quest's three objectives).
const FLAG_HEAP: StringName = &"old_well_heap_found"
const FLAG_BUFFET: StringName = &"old_well_buffet_found"
const FLAG_DEFEATED: StringName = &"old_well_echo_defeated"
## The two zones (ZoneDefs ids) with a task, and the flag each sets.
const ZONE_FLAGS: Dictionary = {"refusemancer": FLAG_HEAP, "gourmand": FLAG_BUFFET}
## Where each hum is (x, 0, z), in the zone's own layout coordinates. Both stand inside the kept-clear band beside a route (nothing scattered or
## solid is ever placed there, `HeapLayout._is_clear` / `BuffetLayout._is_clear`), so they are always reachable and never block a lane:
## - the Dump: the Overgrown Plateau (T3, the highest terrace), west edge, where the river starts its fall down the gorge, just off the lane
##   round Rust Peak;
## - the Buffet: the bank of the little gravy pond in the Broccoli Forest, just off the forest road.
const SPOTS: Dictionary = {"refusemancer": Vector3(20.6, 0.0, 33.0), "gourmand": Vector3(25.5, 0.0, 63.0)}
const SPOT_RADIUS: float = 1.3
## The well's vision waits until this many Path zones are free (a fresh Wanderer only hears the old greeting).
const MIN_ZONES_FREED: int = 1
## The ZoneSpot kind both zone scenes route to `OldWellSpot.use`.
const SPOT_KIND: String = "old_well"

## The one-sided rule's key in data/encounters/modifiers.json (EncounterModifiers), applied in `Session.make_old_well_battle` and the sim.
const RULES_KEY: String = "town:old_well"
const DISPLAY_NAME: String = "The Wellspring's Echo"
## The balance sim's group (`--what=encounters --filter=old_well`) and the level the quest is meant for: both the Buffet (zone 3 of the model's
## order, level 12) and the Dump (zone 4, level 15) explored, before the Capital (18).
const SIM_ID: String = "town:old_well"
const SIM_GROUP: String = "secret:old_well"
const EXPECTED_LEVEL: int = 16
## Placeholder numbers, to be tuned with the sim (main session).
const STARTING_HP: int = 32
const AI_NAME: String = "Balanced"
## The Echo's deck: one spring, four streams - every Path's Infrastructure in equal parts, a little of each Path's best (Beefcake pressure,
## Gourmand removal and healing, Necrocrat fliers and recursion, Refusemancer walls), two Village Wells (the water), the Harmony Engine and the
## Reunion of the Paths. 40 cards, existing cards only.
const DECK_RECIPE: Dictionary = {
	"BAS-B": 5, "BAS-G": 5, "BAS-N": 5, "BAS-R": 5,
	"C-19": 2, "G-06": 2, "R-09": 2, "B-12": 2, "N-06": 2,
	"G-22": 1, "N-15": 1, "B-28": 1, "R-29": 1, "N-28": 1, "B-11": 1,
	"C-34": 1, "P4-02": 1, "GRN-01": 1, "C-24": 1,
}

## The quest's completion reward (paid once by the quest system when the Echo falls).
const REWARD_EQUIPMENT_ID: String = "first_water_phial"
const REWARD_GOLD: int = 250
const REWARD_XP: int = 300

enum Stage {
	## Not started (the well only hums at the Wanderer's own Path).
	HIDDEN,
	## Started; at least one of the two hums still to find.
	LISTENING,
	## Both hums found: the well is ready for the Echo.
	READY,
	## The Echo is beaten and the quest is done.
	DONE,
}


## Where the quest stands, from the quest log's state and the save's flags.
static func stage(quest_active: bool, quest_completed: bool, flags: Dictionary) -> Stage:
	if quest_completed or _has(flags, FLAG_DEFEATED):
		return Stage.DONE
	if not quest_active:
		return Stage.HIDDEN
	return Stage.READY if tasks_found(flags) >= ZONE_FLAGS.size() else Stage.LISTENING


## True when touching the well starts the quest: `startable` (the quest log can start it: not active, not done) and enough zones free.
static func can_begin(startable: bool, flags: Dictionary) -> bool:
	return startable and ZoneCompletion.count(flags) >= MIN_ZONES_FREED


static func is_task_zone(zone_id: String) -> bool:
	return ZONE_FLAGS.has(zone_id)


static func flag_for(zone_id: String) -> StringName:
	return StringName(str(ZONE_FLAGS.get(zone_id, "")))


## The spot of `zone_id` ((x, 0, z); Vector3.ZERO in a zone without one).
static func spot_for(zone_id: String) -> Vector3:
	return SPOTS.get(zone_id, Vector3.ZERO) as Vector3


## True while `zone_id`'s hum is there to be found: the quest is active and that step is not done yet.
static func task_open(zone_id: String, quest_active: bool, flags: Dictionary) -> bool:
	return quest_active and is_task_zone(zone_id) and not _has(flags, flag_for(zone_id))


## How many of the two hums were found.
static func tasks_found(flags: Dictionary) -> int:
	var count: int = 0
	for zone_id: String in ZONE_FLAGS.keys():
		if _has(flags, flag_for(zone_id)):
			count += 1
	return count


static func _has(flags: Dictionary, name: StringName) -> bool:
	return bool(flags.get(str(name), false))


# ---- The quest -------------------------------------------------------------------------------------------------------------


## The quest definition (`QuestDefinitions.build_all`). Never auto-given: `Session.begin_old_well_quest` starts it from the well's vision, and only
## once a Path zone is free (MIN_ZONES_FREED), so a fresh Wanderer touching the well meets the old greeting. No objective has a world marker
## (a secret: the Quest Log's "where to go" line is the only pointer); the steps are any-order flags, the last one the Echo's defeat.
static func quest() -> QuestData:
	var story: OldWellStory = OldWellStory.shared()
	var made: QuestData = QuestData.new()
	made.id = QUEST_ID
	made.category = QuestData.Category.SIDE
	made.order = 142
	made.title = story.text("quest.title")
	made.summary = story.text("quest.summary")
	# No prerequisite on the quest itself (like the other hidden quests), so it never shows up as "New quest available" in a reward box when the
	# first zone is freed; `Session.old_well_can_begin` checks MIN_ZONES_FREED instead.
	made.objectives = [
		QuestObjective.make(story.text("quest.step.heap"), Condition.flag(str(FLAG_HEAP))).at(QuestObjective.TargetKind.SPOT, "", "", story.text("quest.hint.heap")),
		QuestObjective.make(story.text("quest.step.buffet"), Condition.flag(str(FLAG_BUFFET))).at(QuestObjective.TargetKind.SPOT, "", "", story.text("quest.hint.buffet")),
		QuestObjective.make(story.text("quest.step.echo"), Condition.flag(str(FLAG_DEFEATED))).at(QuestObjective.TargetKind.BATTLE, "", "", story.text("quest.hint.echo")),
	] as Array[QuestObjective]
	made.reward_gold = REWARD_GOLD
	made.reward_xp = REWARD_XP
	made.reward_equipment_ids = [REWARD_EQUIPMENT_ID] as Array[String]
	return made


# ---- The Echo --------------------------------------------------------------------------------------------------------------


static func deck(content: ContentSet) -> Deck:
	return ZoneDecks.from_recipe(content, DISPLAY_NAME, DECK_RECIPE)


static func personality(content: ContentSet) -> AIPersonality:
	return ZoneDecks.personality(content, AI_NAME)


## The Echo's seat: its deck and life. Its one-sided rule is added by the caller (`EncounterModifiers.apply_to_enemy` in the duel,
## `EncounterCatalog._attach_rules` in the sim), like Shiro's.
static func enemy_setup(content: ContentSet) -> PlayerSetup:
	var setup: PlayerSetup = PlayerSetup.create(deck(content), null, [] as Array[ModifierSource], DISPLAY_NAME)
	setup.starting_hp = STARTING_HP
	setup.profile = PlayerProfile.new()
	setup.profile.max_hp = STARTING_HP
	return setup


# ---- The reward ------------------------------------------------------------------------------------------------------------


## The Phial of First Water (a relic, never sold): the water that fed all four Paths makes multi-Path cards cheaper and mends a little every turn.
## Existing Modifier kinds only (MULTIPATH_COST_CHANGE on the owner, START_OF_TURN_EFFECT gain HP). `ProgressionContent.zone_equipment` adds it;
## `tools/generate_content.gd` writes data/equipment/zone/first_water_phial.tres.
static func add_equipment(result: Dictionary) -> void:
	var gain: EffectData = EffectData.new()
	gain.op = CardEnums.EffectOp.GAIN_HP
	gain.amount = 1
	gain.target = CardEnums.TargetKind.CONTROLLER
	var mend: Modifier = Modifier.new()
	mend.kind = Modifier.Kind.START_OF_TURN_EFFECT
	mend.effect = gain
	var cheaper: Modifier = Modifier.new()
	cheaper.kind = Modifier.Kind.MULTIPATH_COST_CHANGE
	cheaper.value = -1
	var piece: EquipmentData = EquipmentData.new()
	piece.id = REWARD_EQUIPMENT_ID
	piece.source_name = "Phial of First Water"
	piece.source_kind = ModifierSource.SourceKind.EQUIPMENT
	piece.slot = EquipmentData.Slot.RELIC
	var deep: Modifier = Modifier.new()
	deep.kind = Modifier.Kind.MAX_HP
	deep.value = 3
	piece.description = "Your multi-Path cards cost 1 less generic energy. At the start of your turn, gain 1 HP. Max HP +3."
	piece.modifiers = [cheaper, mend, deep] as Array[Modifier]  # Oct 29: a Legendary's worth
	piece.advanced = true
	piece.rarity = EquipmentData.Rarity.LEGENDARY
	piece.tier = 3
	piece.flavor_text = "A thimble of the water that fed all four Paths. It does not slosh. It waits."
	piece.source = "Secret quest: The Water Under the Well"
	result[piece.id] = piece
