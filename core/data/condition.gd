class_name Condition
extends Resource
## A single reusable, data-driven unlock condition (Resource, so it can be saved as `.tres` data
## or built with `CardBuilder`-style helpers) - the one thing vendors, gates, NPC dialogue and
## secrets all check to decide whether something is available yet. See `UnlockState` for what it
## reads (a plain-data snapshot of progress, kept separate from `Session` so this stays pure
## `core/` logic with no scene-tree dependency) and `docs/design/open_questions.md` D37.

enum Kind {
	## key = the flag name.
	FLAG_SET,
	## key = the dungeon name.
	DUNGEON_CLEARED,
	## key = the card id; amount = copies owned (default 1).
	CARD_OWNED,
	## key = the secret id.
	SECRET_FOUND,
	## amount = minimum lifetime gold spent.
	GOLD_SPENT,
	## amount = minimum player level.
	PLAYER_LEVEL,
	## key = the quest id.
	QUEST_COMPLETED,
	## True when every entry in `sub_conditions` is met.
	ALL_OF,
	## True when at least one entry in `sub_conditions` is met.
	ANY_OF,
	## key = a Session counter name (enemies defeated, minigames won...); amount = the minimum value.
	## Appended last on purpose: Kind is saved as an int in vendor .tres files.
	COUNTER,
}

@export var kind: Kind = Kind.FLAG_SET
@export var key: String = ""
@export var amount: int = 1
@export var sub_conditions: Array[Condition] = []

## Always-unlocked shorthand: no condition at all.
static func always() -> Condition:
	return null


static func flag(name: String) -> Condition:
	return _make(Kind.FLAG_SET, name)


static func dungeon_cleared(dungeon_name: String) -> Condition:
	return _make(Kind.DUNGEON_CLEARED, dungeon_name)


static func card_owned(card_id: String, copies: int = 1) -> Condition:
	return _make(Kind.CARD_OWNED, card_id, copies)


static func secret_found(secret_id: String) -> Condition:
	return _make(Kind.SECRET_FOUND, secret_id)


static func gold_spent(amount_value: int) -> Condition:
	return _make(Kind.GOLD_SPENT, "", amount_value)


static func player_level(level: int) -> Condition:
	return _make(Kind.PLAYER_LEVEL, "", level)


static func quest_completed(quest_id: String) -> Condition:
	return _make(Kind.QUEST_COMPLETED, quest_id)


static func counter(counter_name: String, at_least: int = 1) -> Condition:
	return _make(Kind.COUNTER, counter_name, at_least)


static func all_of(conditions: Array[Condition]) -> Condition:
	var made: Condition = Condition.new()
	made.kind = Kind.ALL_OF
	made.sub_conditions = conditions
	return made


static func any_of(conditions: Array[Condition]) -> Condition:
	var made: Condition = Condition.new()
	made.kind = Kind.ANY_OF
	made.sub_conditions = conditions
	return made


static func _make(condition_kind: Kind, key_value: String, amount_value: int = 1) -> Condition:
	var made: Condition = Condition.new()
	made.kind = condition_kind
	made.key = key_value
	made.amount = amount_value
	return made


## True when `state` (a plain-data progress snapshot) satisfies this condition. A null
## Condition is always met - the common case of "no unlock condition, always available".
static func met(condition: Condition, state: UnlockState) -> bool:
	if condition == null:
		return true
	match condition.kind:
		Kind.FLAG_SET:
			return state.flags.get(condition.key, false) == true
		Kind.DUNGEON_CLEARED:
			return state.cleared_dungeons.has(condition.key)
		Kind.CARD_OWNED:
			return int(state.owned_cards.get(condition.key, 0)) >= condition.amount
		Kind.SECRET_FOUND:
			return state.found_secrets.has(condition.key)
		Kind.GOLD_SPENT:
			return state.gold_spent >= condition.amount
		Kind.PLAYER_LEVEL:
			return state.player_level >= condition.amount
		Kind.QUEST_COMPLETED:
			return state.completed_quests.has(condition.key)
		Kind.COUNTER:
			return int(state.counters.get(condition.key, 0)) >= condition.amount
		Kind.ALL_OF:
			for sub: Condition in condition.sub_conditions:
				if not met(sub, state):
					return false
			return true
		Kind.ANY_OF:
			for sub: Condition in condition.sub_conditions:
				if met(sub, state):
					return true
			return condition.sub_conditions.is_empty()
	return false


## A short, spoiler-free description for a locked item's "???" teaser.
static func teaser(condition: Condition) -> String:
	if condition == null:
		return ""
	match condition.kind:
		Kind.FLAG_SET:
			return "Locked."
		Kind.DUNGEON_CLEARED:
			return "Clear %s to unlock." % condition.key
		Kind.CARD_OWNED:
			return "Own %d %s to unlock." % [condition.amount, "copy" if condition.amount == 1 else "copies"]
		Kind.SECRET_FOUND:
			return "Find a hidden secret to unlock."
		Kind.GOLD_SPENT:
			return "Spend %d gold in total to unlock." % condition.amount
		Kind.PLAYER_LEVEL:
			return "Reach level %d to unlock." % condition.amount
		Kind.QUEST_COMPLETED:
			return "Complete %s to unlock." % condition.key
		Kind.COUNTER:
			return "Keep going (%d needed)." % condition.amount
		Kind.ALL_OF, Kind.ANY_OF:
			return "Locked."
	return "Locked."
