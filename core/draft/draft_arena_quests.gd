class_name DraftArenaQuests
extends RefCounted
## Fable big pass Nov 23 (Part 4): the Shuffle House's quests.
##   - **The main quest "The House Always Deals"**: once three zones are freed (which opens the Shuffle House if the zone drafts
##     have not), the story sends the player to Octavia Eightfold, who asks them to PLAY the Shuffled Halls once, win or lose. A soft
##     push for players who skipped drafting; every other quest carries on beside it.
##   - **The arena line**: one quest per kind of arena encounter, all added by themselves the moment the Shuffle House opens (the
##     Open Draft, the six two-Path tables, three and four Paths, the win-three tables, the Shuffled Halls, Mystery Mini, the
##     dungeon drafts).
## They watch the flags and counters `Session` keeps for drafts (`draft_won:<id>`, `draft_finished:<kind>`, `draft_won_kind:<kind>`,
## `draft_halls_played`).

const MAIN_QUEST: String = "main_shuffle_house"
const OPEN_QUEST: String = "arena_open_table"
const PAIRS_QUEST: String = "arena_two_of_a_kind"
const TRIOS_QUEST: String = "arena_threes_company"
const QUAD_QUEST: String = "arena_full_house"
const HIGH_QUEST: String = "arena_high_rollers"
const HALLS_QUEST: String = "arena_lost_in_the_halls"
const MYSTERY_QUEST: String = "arena_spin_the_wheel"
const DUNGEON_QUEST: String = "arena_dungeon_regular"
const WHERE: String = "The Shuffle House, on the north-east corner of Crosspath's square"
const AREA: String = "town"
const SPOT: String = "shuffle_house"


static func quests() -> Array[QuestData]:
	var result: Array[QuestData] = []
	result.append(_main())
	var open: Condition = Condition.flag(DraftChallenges.ARENA_FLAG)
	var after_primm: Condition = Condition.all_of([open, Condition.flag(str(MultiPathLock.FLAG_UNLOCKED))] as Array[Condition])
	var two_paths: Condition = Condition.all_of([open, Condition.zones_completed(1)] as Array[Condition])
	# -- the Open Draft
	var first: QuestData = _side(OPEN_QUEST, 80, "Open Table", "The Shuffle House is open, and at Octavia Eightfold's tables you choose your own Paths. Sit down at the Open Draft and play one run to the end, win or lose.", open)
	first.objectives = [_step("Finish an Open Draft at the Shuffle House (win or lose)", Condition.counter("draft_finished:%s" % DraftArena.KIND_OPEN, 1))] as Array[QuestObjective]
	first.reward_gold = 120
	first.reward_xp = 120
	first.reward_pack_ids = ["general_1"] as Array[String]
	result.append(first)
	# -- the six two-Path tables
	var pairs: QuestData = _side(PAIRS_QUEST, 81, "Two of a Kind", "Six tables, one for every pair of Paths. Two-Path drafts and two-Path cards open with the first freed zone. Win all six.", two_paths)
	var pair_steps: Array[QuestObjective] = []
	for id: String in DraftArena.pair_ids():
		pair_steps.append(_step("Win the %s table" % DraftArena.title(id), Condition.flag(DraftChallenges.won_flag(id))))
	pairs.objectives = pair_steps
	pairs.reward_gold = 600
	pairs.reward_xp = 500
	pairs.reward_pack_ids = ["gilded_general", "gilded_general"] as Array[String]
	result.append(pairs)
	# -- three Paths, then all four (after Primm)
	var trios: QuestData = _side(TRIOS_QUEST, 82, "Three's Company", "With Primm defeated the three-Path tables are open: four of them, each leaving one Path out. Win all four.", after_primm)
	var trio_steps: Array[QuestObjective] = []
	for id: String in DraftArena.trio_ids():
		trio_steps.append(_step("Win the table of %s" % DraftArena.path_names(DraftArena.fixed_paths(id), ", "), Condition.flag(DraftChallenges.won_flag(id))))
	trios.objectives = trio_steps
	trios.reward_gold = 700
	trios.reward_xp = 600
	trios.reward_pack_ids = [PackRules.PRISMATIC_ID, PackRules.PRISMATIC_ID] as Array[String]
	result.append(trios)
	var quad: QuestData = _side(QUAD_QUEST, 83, "Full House", "All four Paths at one table: the largest pool there is, and the only table where a four-Path card can be drafted. Win it.", after_primm)
	quad.objectives = [_step("Win the All Four Paths table", Condition.flag(DraftChallenges.won_flag(DraftArena.QUAD_ID)))] as Array[QuestObjective]
	quad.reward_gold = 500
	quad.reward_xp = 500
	quad.reward_pack_ids = [PackRules.PRISMATIC_ID, PackRules.PRISMATIC_ID] as Array[String]
	result.append(quad)
	# -- the harder win-three tables
	var high: QuestData = _side(HIGH_QUEST, 84, "High Rollers", "Octavia's harder tables: win all three fights, and one loss ends the run. The rivals there draft from the same equipment as you, the best pieces included.", open)
	var high_steps: Array[QuestObjective] = []
	for id: String in DraftArena.high_ids():
		high_steps.append(_step("Win at %s" % DraftArena.title(id), Condition.flag(DraftChallenges.won_flag(id))))
	high.objectives = high_steps
	high.reward_gold = 800
	high.reward_xp = 700
	high.reward_pack_ids = ["gilded_general", "gilded_general"] as Array[String]
	result.append(high)
	# -- the Shuffled Halls: Octavia's own card is the prize
	var halls: QuestData = _side(HALLS_QUEST, 85, "Lost in the Halls", "The Shuffled Halls run behind the Shuffle House's stage: eighteen rooms, one HP pool, Trey Pickett in the Auction Ring and Octavia Eightfold at the Big Wheel. Clear them.", open)
	halls.objectives = [_step("Clear the Shuffled Halls (beat Octavia Eightfold)", Condition.flag(DraftChallenges.won_flag(DraftArena.HALLS_ID)))] as Array[QuestObjective]
	halls.reward_gold = 400
	halls.reward_xp = 400
	halls.reward_card_ids = [DraftRivals.OCTAVIA_CARD] as Array[String]
	result.append(halls)
	# -- Mystery Mini and the dungeon drafts
	var mystery: QuestData = _side(MYSTERY_QUEST, 86, "Spin the Wheel", "Mystery Mini: draft a deck, then the wheel picks a mini dungeon you have cleared before. Clear the one it lands on.", open)
	mystery.objectives = [_step("Clear a Mystery Mini", Condition.flag(DraftChallenges.won_flag(DraftArena.MYSTERY_ID)))] as Array[QuestObjective]
	mystery.reward_gold = 250
	mystery.reward_xp = 250
	mystery.reward_pack_ids = ["gilded_general"] as Array[String]
	result.append(mystery)
	var regular: QuestData = _side(DUNGEON_QUEST, 87, "Dungeon Regular", "Any dungeon you have cleared with your own deck can be played again with a drafted one, from the Dungeon Drafts tile of the Shuffle House. Clear three dungeon drafts.", open)
	regular.objectives = [_step("Clear three dungeon drafts", Condition.counter("draft_won_kind:%s" % DraftArena.KIND_DUNGEON, 3))] as Array[QuestObjective]
	regular.reward_gold = 450
	regular.reward_xp = 450
	regular.reward_pack_ids = ["gilded_general"] as Array[String]
	result.append(regular)
	return result


## The main quest: three zones are free, Octavia wants a word, and the Shuffled Halls want walking once (win or lose).
static func _main() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = MAIN_QUEST
	quest.category = QuestData.Category.MAIN
	quest.order = 5
	quest.title = "The House Always Deals"
	quest.summary = "Three zones are free, and word of it has reached the Shuffle House in Crosspath. Octavia Eightfold, who runs the draft arena there, is asking for you by name. She wants you to walk the Shuffled Halls once; you don't have to win."
	quest.auto_give = true
	quest.prerequisite = Condition.zones_completed(DraftArena.ZONES_TO_OPEN)
	quest.objectives = [
		_step("Meet Octavia Eightfold at the Shuffle House in Crosspath", Condition.flag(DraftArena.MET_FLAG)),
		_step("Play the Shuffled Halls once: draft a deck and walk in (win or lose)", Condition.counter("draft_halls_played", 1)),
	] as Array[QuestObjective]
	quest.reward_gold = 300
	quest.reward_xp = 300
	quest.reward_pack_ids = ["gilded_general"] as Array[String]
	return quest


static func _side(id: String, order: int, title: String, summary: String, prerequisite: Condition) -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = id
	quest.category = QuestData.Category.SIDE
	quest.order = order
	quest.title = title
	quest.summary = summary
	quest.auto_give = true
	quest.prerequisite = prerequisite
	return quest


static func _step(words: String, done: Condition) -> QuestObjective:
	return QuestObjective.make(words, done).at(QuestObjective.TargetKind.SPOT, AREA, SPOT, WHERE)


static func ids() -> Array[String]:
	return [MAIN_QUEST, OPEN_QUEST, PAIRS_QUEST, TRIOS_QUEST, QUAD_QUEST, HIGH_QUEST, HALLS_QUEST, MYSTERY_QUEST, DUNGEON_QUEST]
