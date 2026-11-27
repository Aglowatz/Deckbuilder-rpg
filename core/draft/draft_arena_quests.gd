class_name DraftArenaQuests
extends RefCounted
## The Shuffle House's quests (Fable big pass Nov 23; rewritten for the four modes on Nov 24).
##   - **The main quest "The House Always Deals"**: once three zones are freed (which opens the Shuffle House if the zone drafts
##     have not), the story sends the player to Octavia Eightfold, who asks them to PLAY the Shuffled Halls once, win or lose. A soft
##     push for players who skipped drafting; every other quest carries on beside it.
##   - **The arena line**, added by itself the moment the Shuffle House opens, points at the four modes and the Shuffled Halls:
##     Classic Draft (finish one; then win one with each pair of Paths; with three Paths; with all four), High Rollers, Dungeon
##     Draft, Mystery Mini, and - a side quest of its own, separate from the main quest - BEATING the Shuffled Halls.
## They watch the flags and counters `Session` keeps for drafts (`draft_won:<id>`, `draft_finished:<kind>`, `draft_won_kind:<kind>`,
## `draft_halls_played`). A Classic or High Rollers win with two, three or four Paths sets that set's flag
## (`DraftArena.paths_goal_flag`: the flags of the separate tables of Nov 23, so a save that won those keeps its progress).

const MAIN_QUEST: String = "main_shuffle_house"
const OPEN_QUEST: String = "arena_open_table"
const PAIRS_QUEST: String = "arena_two_of_a_kind"
const TRIOS_QUEST: String = "arena_threes_company"
const QUAD_QUEST: String = "arena_full_house"
const HIGH_QUEST: String = "arena_high_rollers"
const HALLS_QUEST: String = "arena_lost_in_the_halls"
const MYSTERY_QUEST: String = "arena_spin_the_wheel"
const DUNGEON_QUEST: String = "arena_dungeon_regular"
## Quests whose card prize is a three- or four-Path card: each has a last step that waits for Primm's defeat.
const PRIZES_AFTER_PRIMM: Array[String] = [HALLS_QUEST]
const WHERE: String = "The Shuffle House, on the lawn north-east of Crosspath's square"
const AREA: String = "town"
const SPOT: String = "shuffle_house"


static func quests() -> Array[QuestData]:
	var result: Array[QuestData] = []
	result.append(_main())
	var open: Condition = Condition.flag(DraftChallenges.ARENA_FLAG)
	var after_primm: Condition = Condition.all_of([open, Condition.flag(str(MultiPathLock.FLAG_UNLOCKED))] as Array[Condition])
	var two_paths: Condition = Condition.all_of([open, Condition.zones_completed(1)] as Array[Condition])
	# -- Classic Draft: sit down once
	var first: QuestData = _side(OPEN_QUEST, 80, "Open Table", "The Shuffle House is open. Octavia Eightfold's first mode is the Classic Draft: choose your own Paths, draft a deck, and play three opponents from all over the kingdom. Play one run to the end, win or lose.", open)
	first.objectives = [_step("Finish a Classic Draft at the Shuffle House (win or lose)", Condition.counter("draft_finished:%s" % DraftArena.KIND_OPEN, 1))] as Array[QuestObjective]
	first.reward_gold = 120
	first.reward_xp = 120
	first.reward_pack_ids = ["general_1"] as Array[String]
	result.append(first)
	# -- every pair of Paths, in Classic or High Rollers
	var pairs: QuestData = _side(PAIRS_QUEST, 81, "Two of a Kind", "Two Paths at once open with the first freed zone. There are six pairs. Win a Classic Draft (or a High Rollers Draft) with each of them: switch on exactly those two Paths before you start.", two_paths)
	var pair_steps: Array[QuestObjective] = []
	for id: String in DraftArena.pair_ids():
		pair_steps.append(_step("Win a Classic or High Rollers Draft with %s" % DraftArena.path_names(DraftArena.fixed_paths(id)), Condition.flag(DraftChallenges.won_flag(id))))
	pairs.objectives = pair_steps
	pairs.reward_gold = 600
	pairs.reward_xp = 500
	pairs.reward_pack_ids = ["gilded_general", "gilded_general"] as Array[String]
	result.append(pairs)
	# -- three Paths, then all four (after Primm)
	var any_trio: Array[Condition] = []
	for id: String in DraftArena.trio_ids():
		any_trio.append(Condition.flag(DraftChallenges.won_flag(id)))
	var trios: QuestData = _side(TRIOS_QUEST, 82, "Three's Company", "With Primm defeated, three Paths fit in one draft. Win a Classic Draft (or a High Rollers Draft) with exactly three Paths switched on. Any three.", after_primm)
	trios.objectives = [_step("Win a Classic or High Rollers Draft with three Paths", Condition.any_of(any_trio))] as Array[QuestObjective]
	trios.reward_gold = 500
	trios.reward_xp = 450
	trios.reward_pack_ids = [PackRules.PRISMATIC_ID] as Array[String]
	result.append(trios)
	var quad: QuestData = _side(QUAD_QUEST, 83, "Full House", "All four Paths in one draft: the largest pool there is, and the only draft where a four-Path card can turn up. Win a Classic Draft (or a High Rollers Draft) with all four Paths switched on.", after_primm)
	quad.objectives = [_step("Win a Classic or High Rollers Draft with all four Paths", Condition.flag(DraftChallenges.won_flag(DraftArena.QUAD_ID)))] as Array[QuestObjective]
	quad.reward_gold = 500
	quad.reward_xp = 500
	quad.reward_pack_ids = [PackRules.PRISMATIC_ID, PackRules.PRISMATIC_ID] as Array[String]
	result.append(quad)
	# -- High Rollers: the fee, the opponents in the best gear
	var any_high: Array[Condition] = [Condition.flag(DraftChallenges.won_flag(DraftArena.HIGH_ID))]
	for id: String in DraftArena.high_ids():
		any_high.append(Condition.flag(DraftChallenges.won_flag(id)))  # a win at one of the retired win-three tables counts
	var high: QuestData = _side(HIGH_QUEST, 84, "High Rollers", "The High Rollers Draft is a Classic Draft for higher stakes: there is a fee at the door, and the opponents may wear every piece of equipment you may, the best ones included. It pays more, Prismatic Packs too. Win one; then win three.", open)
	high.objectives = [_step("Win a High Rollers Draft", Condition.any_of(any_high)),
		_step("Win three High Rollers Drafts", Condition.counter("draft_won_kind:%s" % DraftArena.KIND_HIGH, 3))] as Array[QuestObjective]
	high.reward_gold = 800
	high.reward_xp = 700
	high.reward_pack_ids = ["gilded_general", "gilded_general"] as Array[String]
	result.append(high)
	# -- the Shuffled Halls: BEATING them is this side quest (the main quest only asks for one walk); Octavia's own card is the prize
	var halls: QuestData = _side(HALLS_QUEST, 85, "Lost in the Halls", "The Shuffled Halls run behind the Shuffle House's stage: eighteen rooms, one HP pool, a dealer with a house rule at every table, Trey Pickett in the Auction Ring and Octavia Eightfold at the Big Wheel. Beat them: cashing out at the Counting Halls does not count.", open)
	# Octavia's card is of all four Paths, and no card of three or four Paths is handed out before Primm falls (`MultiPathLock`):
	# the clear counts whenever it is made, the prize is handed over once the kingdom is free
	halls.objectives = [_step("Clear the Shuffled Halls (beat Octavia Eightfold at the Big Wheel)", Condition.flag(DraftChallenges.won_flag(DraftArena.HALLS_ID))),
		_step("Defeat Primm (a card of all four Paths stays sealed until then)", Condition.flag(str(MultiPathLock.FLAG_UNLOCKED)))] as Array[QuestObjective]
	halls.reward_gold = 400
	halls.reward_xp = 400
	halls.reward_card_ids = [DraftRivals.OCTAVIA_CARD] as Array[String]
	result.append(halls)
	# -- Mystery Mini and the Dungeon Draft
	var mystery: QuestData = _side(MYSTERY_QUEST, 86, "Spin the Wheel", "Mystery Mini: draft a deck, then the wheel picks a mini dungeon, three fights on one HP pool. It pays a pack of that dungeon's Path. Clear the one it lands on.", open)
	mystery.objectives = [_step("Clear a Mystery Mini", Condition.flag(DraftChallenges.won_flag(DraftArena.MYSTERY_ID)))] as Array[QuestObjective]
	mystery.reward_gold = 250
	mystery.reward_xp = 250
	mystery.reward_pack_ids = ["gilded_general"] as Array[String]
	result.append(mystery)
	var regular: QuestData = _side(DUNGEON_QUEST, 87, "Dungeon Regular", "Dungeon Draft: any large dungeon you have cleared with your own deck can be played again with a drafted one (every zone's main dungeon, and the big ones beyond). It pays Prismatic Packs. Clear three Dungeon Drafts.", open)
	regular.objectives = [_step("Clear three Dungeon Drafts", Condition.counter("draft_won_kind:%s" % DraftArena.KIND_DUNGEON, 3))] as Array[QuestObjective]
	regular.reward_gold = 450
	regular.reward_xp = 450
	regular.reward_pack_ids = ["gilded_general"] as Array[String]
	result.append(regular)
	# Nov 26 night (Part A2): Octavia's five deck-building puzzles, one in each level of the line (easiest first: Open Table, Spin the Wheel,
	# High Rollers, Two of a Kind, Full House). Winning the level's puzzle is the quest's last step; each table opens once the one before it is
	# won, so a player who finished a quest before tonight can still go back and play its table (a completed quest stays completed).
	for quest: QuestData in result:
		var puzzle: String = DeckPuzzles.for_quest(quest.id)
		if puzzle.is_empty():
			continue
		quest.summary += " %s" % puzzle_summary(puzzle)
		var steps: Array[QuestObjective] = quest.objectives.duplicate()
		steps.append(_step(DeckPuzzles.step_words(puzzle), Condition.flag(str(DeckPuzzles.won_flag(puzzle)))))
		quest.objectives = steps
	return result


## The line a puzzle adds to its quest's summary.
static func puzzle_summary(puzzle: String) -> String:
	var order: int = DeckPuzzles.order_of(puzzle)
	var title: String = str(DeckPuzzles.row(puzzle).get("title", puzzle))
	if order <= 1:
		return "Octavia also keeps a puzzle table at this level, \"%s\": bring your own deck and find the trick." % title
	return "Octavia's puzzle table for this level is \"%s\" (it opens once you have won table %d): bring your own deck and find the trick." % [title, order - 1]


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
