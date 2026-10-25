class_name QuestLog
extends RefCounted
## The player's quest state: which quests are active/completed, plus the counter baselines taken
## when a quest started (so "defeat 3 enemies" counts from acceptance, not from the save's
## lifetime total). Pure data + rules; `Session` applies rewards and emits the UI events.

var active: Array[String] = []
var completed: Array[String] = []
## "<quest id>|<counter key>" -> the counter's value when the quest started.
var baselines: Dictionary = {}
## The quest shown in the HUD tracker (chosen in the Quest Log); a newly started quest becomes the tracked one.
var tracked: String = ""
## Overnight Oct 16: milestone rewards already paid ("<quest id>#<objective index>"), the last seen progress per active quest (recency), and the
## save format version (1 = before categories and milestones; `QuestMigration` upgrades it).
var milestones_paid: Array[String] = []
var progress_seen: Dictionary = {}
var version: int = VERSION

const VERSION: int = 4  # 3 = Oct 20: the early-game chain (QuestMigration sets the legacy flag on older saves past it); 4 = Oct 25: Make It Yours opens with a pack


func is_active(quest_id: String) -> bool:
	return active.has(quest_id)


func is_completed(quest_id: String) -> bool:
	return completed.has(quest_id)


func can_start(quest: QuestData, state: UnlockState) -> bool:
	if quest == null or is_active(quest.id) or is_completed(quest.id):
		return false
	return Condition.met(quest.prerequisite, state)


func start(quest: QuestData, state: UnlockState) -> bool:
	if not can_start(quest, state):
		return false
	active.append(quest.id)
	tracked = quest.id
	for objective: QuestObjective in quest.objectives:
		var cond: Condition = objective.condition
		if cond != null and cond.kind == Condition.Kind.COUNTER:
			baselines[_baseline_key(quest.id, cond.key)] = int(state.counters.get(cond.key, 0))
	return true


## (current, target) progress of one objective. Non-counter objectives are (0|1, 1).
func objective_progress(quest: QuestData, index: int, state: UnlockState) -> Vector2i:
	var cond: Condition = quest.objectives[index].condition
	if cond != null and cond.kind == Condition.Kind.COUNTER:
		var base: int = int(baselines.get(_baseline_key(quest.id, cond.key), 0))
		var value: int = maxi(0, int(state.counters.get(cond.key, 0)) - base)
		return Vector2i(mini(value, cond.amount), cond.amount)
	return Vector2i(1 if Condition.met(cond, state) else 0, 1)


func objective_met(quest: QuestData, index: int, state: UnlockState) -> bool:
	var progress: Vector2i = objective_progress(quest, index, state)
	return progress.x >= progress.y


func objectives_met_count(quest: QuestData, state: UnlockState) -> int:
	var count: int = 0
	for index: int in range(quest.objectives.size()):
		if objective_met(quest, index, state):
			count += 1
	return count


func all_objectives_met(quest: QuestData, state: UnlockState) -> bool:
	return objectives_met_count(quest, state) == quest.objectives.size()


## Active, every objective met, and waiting for the player to talk to the turn-in NPC.
func is_ready_to_turn_in(quest: QuestData, state: UnlockState) -> bool:
	return is_active(quest.id) and not quest.turn_in_npc.is_empty() and all_objectives_met(quest, state)


## Moves an active quest to completed. Returns false if it was not active.
func complete(quest_id: String) -> bool:
	if not active.has(quest_id):
		return false
	active.erase(quest_id)
	completed.append(quest_id)
	return true


## Ids of active quests with no turn-in NPC whose objectives are all met (to be completed now).
func auto_completable(catalog: Array[QuestData], state: UnlockState) -> Array[String]:
	var result: Array[String] = []
	for quest: QuestData in catalog:
		if is_active(quest.id) and quest.turn_in_npc.is_empty() and all_objectives_met(quest, state):
			result.append(quest.id)
	return result


func to_dict() -> Dictionary:
	return {"active": active, "completed": completed, "baselines": baselines, "tracked": tracked, "milestones_paid": milestones_paid, "progress_seen": progress_seen, "version": version}


func from_dict(data: Dictionary) -> void:
	active.assign(data.get("active", []) as Array)
	completed.assign(data.get("completed", []) as Array)
	baselines = (data.get("baselines", {}) as Dictionary).duplicate()
	tracked = str(data.get("tracked", ""))
	milestones_paid.assign(data.get("milestones_paid", []) as Array)
	progress_seen = (data.get("progress_seen", {}) as Dictionary).duplicate()
	version = int(data.get("version", 1))


func reset() -> void:
	active.clear()
	completed.clear()
	baselines.clear()
	tracked = ""
	milestones_paid.clear()
	progress_seen.clear()
	version = VERSION


static func _baseline_key(quest_id: String, counter_key: String) -> String:
	return "%s|%s" % [quest_id, counter_key]


## The id of the quest the HUD tracker shows: the chosen one while it is active, otherwise the most recently started active quest ("" with none).
func tracked_id() -> String:
	if tracked != "" and active.has(tracked):
		return tracked
	return active[active.size() - 1] if not active.is_empty() else ""


## Picks the tracked quest (an active one). False otherwise.
func track(quest_id: String) -> bool:
	if not active.has(quest_id):
		return false
	tracked = quest_id
	return true


# ---- Overnight Oct 16: ordered objectives, milestones, recency, cycling ----------------------------------------------------------

## Index of the current step: the first objective not yet met (objectives are ordered). `objectives.size()` when every one is met.
func current_index(quest: QuestData, state: UnlockState) -> int:
	for index: int in range(quest.objectives.size()):
		if not objective_met(quest, index, state):
			return index
	return quest.objectives.size()


## The current step's objective (null when all are met).
func current_objective(quest: QuestData, state: UnlockState) -> QuestObjective:
	var index: int = current_index(quest, state)
	return quest.objectives[index] if index < quest.objectives.size() else null


## Sum of every objective's progress - grows whenever the quest moves forward (the tracker's "most recently updated" rule).
func progress_value(quest: QuestData, state: UnlockState) -> int:
	var total: int = 0
	for index: int in range(quest.objectives.size()):
		total += objective_progress(quest, index, state).x
	return total


## Active quests whose progress grew since the last call (oldest first), remembering the new values. A quest seen for the first time
## records its value without counting as an update (starting a quest already makes it the tracked one).
func take_updates(catalog: Array[QuestData], state: UnlockState) -> Array[String]:
	var result: Array[String] = []
	for quest: QuestData in catalog:
		if not is_active(quest.id):
			continue
		var value: int = progress_value(quest, state)
		if progress_seen.has(quest.id) and value > int(progress_seen[quest.id]):
			result.append(quest.id)
		progress_seen[quest.id] = value
	return result


## (quest, objective index) pairs whose milestone reward is due: the objective is met, the quest is active and it was not paid before.
## Marks them paid; the caller pays them.
func take_due_milestones(catalog: Array[QuestData], state: UnlockState) -> Array[Array]:
	var result: Array[Array] = []
	for quest: QuestData in catalog:
		if not is_active(quest.id):
			continue
		for index: int in range(quest.objectives.size()):
			var objective: QuestObjective = quest.objectives[index]
			if objective.milestone == null or milestones_paid.has(_milestone_key(quest.id, index)):
				continue
			if objective_met(quest, index, state):
				milestones_paid.append(_milestone_key(quest.id, index))
				result.append([quest, index])
	return result


## Marks every milestone of `quest` that is already met as paid without paying it (old saves that got there before milestones existed).
func settle_milestones(quest: QuestData, state: UnlockState) -> void:
	for index: int in range(quest.objectives.size()):
		if quest.objectives[index].milestone != null and objective_met(quest, index, state) and not milestones_paid.has(_milestone_key(quest.id, index)):
			milestones_paid.append(_milestone_key(quest.id, index))


func milestone_paid(quest_id: String, index: int) -> bool:
	return milestones_paid.has(_milestone_key(quest_id, index))


static func _milestone_key(quest_id: String, index: int) -> String:
	return "%s#%d" % [quest_id, index]


## Active quests in the order the tracker toggles through them: MAIN before SIDE, then by `order`.
func cycle_order(catalog: Array[QuestData]) -> Array[String]:
	var quests: Array[QuestData] = []
	for quest: QuestData in catalog:
		if is_active(quest.id):
			quests.append(quest)
	quests.sort_custom(func(a: QuestData, b: QuestData) -> bool:
		if a.category != b.category:
			return a.category < b.category
		return a.order < b.order)
	var ids: Array[String] = []
	for quest: QuestData in quests:
		ids.append(quest.id)
	return ids


## Tracks the next (`step` 1) or previous (-1) active quest and returns its id ("" with none active).
func cycle(catalog: Array[QuestData], step: int) -> String:
	var ids: Array[String] = cycle_order(catalog)
	if ids.is_empty():
		return ""
	var at: int = ids.find(tracked_id())
	var next: int = posmod((at if at >= 0 else 0) + (step if at >= 0 else 0), ids.size())
	tracked = ids[next]
	return tracked


# ---- Oct 20, Part 5: objectives revealed one at a time ---------------------------------------------------------------------------

## The steps the player may see: every step before the current one (all done) and the current one; a finished quest shows them all. Later
## steps stay hidden until the one before is done, even if their condition is already met (no step ever spoils what comes next). The
## HUD tracker and the Quest Log both draw exactly these, plus one "???" line when `hidden_steps` > 0.
func visible_steps(quest: QuestData, state: UnlockState) -> Array[int]:
	var result: Array[int] = []
	var last: int = quest.objectives.size() - 1 if is_completed(quest.id) else mini(current_index(quest, state), quest.objectives.size() - 1)
	for index: int in range(last + 1):
		result.append(index)
	return result


## How many steps are still hidden (0 once the current step is the last, or the quest is ready to hand in or done).
func hidden_steps(quest: QuestData, state: UnlockState) -> int:
	return quest.objectives.size() - visible_steps(quest, state).size()


## The placeholder drawn for the hidden steps (one line, however many there are).
const HIDDEN_STEPS_TEXT: String = "???"
