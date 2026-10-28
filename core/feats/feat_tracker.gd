class_name FeatTracker
extends RefCounted
## Overnight Oct 27-28, Part 3: decides which feats a campaign has just earned. State feats are scored against a snapshot of the save
## (flags, counters, zones freed, collection percent, cleared dungeons, quests, level, arena clears) - the same call runs on load, so an
## old save earns what it already did (retroactive). Battle feats are scored once per won battle from the battle's facts and the
## `FeatWatcher` moments. Pure logic: the session builds the snapshot, pays the rewards and shows the toast.

var state: FeatState = FeatState.new()
var watcher: FeatWatcher = FeatWatcher.new()


func reset() -> void:
	state = FeatState.new()
	watcher.detach()


func load(data: Dictionary) -> void:
	state = FeatState.new()
	state.from_dict(data)


## Starts watching a live battle (the battle's `GameState`).
func watch(game: GameState) -> void:
	watcher.attach(game)


## Every state feat the snapshot now satisfies and the campaign had not earned: recorded in `state`, returned in file order.
func evaluate(snapshot: Dictionary) -> Array[String]:
	var earned: Array[String] = []
	for def: FeatDefs.Def in FeatDefs.all():
		if not def.is_state() or state.has(def.id):
			continue
		if state_met(def.trigger, snapshot):
			state.unlock(def.id)
			earned.append(def.id)
	return earned


## A won battle: `info` = {boss: bool, flawless: bool, hp_left: int, deck_paths: int} plus the watcher's moments (detached afterwards).
func on_battle(info: Dictionary) -> Array[String]:
	var moments: Dictionary = watcher.moments()
	watcher.detach()
	var earned: Array[String] = []
	for def: FeatDefs.Def in FeatDefs.all():
		if def.is_state() or state.has(def.id):
			continue
		if battle_met(def.trigger, info, moments):
			state.unlock(def.id)
			earned.append(def.id)
	return earned


static func state_met(trigger: Dictionary, snapshot: Dictionary) -> bool:
	var flags: Dictionary = snapshot.get("flags", {}) as Dictionary
	match str(trigger.get("kind", "")):
		"flag":
			return bool(flags.get(str(trigger.get("flag", "")), false))
		"flags":
			for name: Variant in trigger.get("flags", []) as Array:
				if not bool(flags.get(str(name), false)):
					return false
			var any_of: Array = trigger.get("any_of", []) as Array
			if any_of.is_empty():
				return true
			for name: Variant in any_of:
				if bool(flags.get(str(name), false)):
					return true
			return false
		"zones":
			return int(snapshot.get("zones", 0)) >= int(trigger.get("count", 4))
		"counter":
			var counters: Dictionary = snapshot.get("counters", {}) as Dictionary
			return int(counters.get(str(trigger.get("counter", "")), 0)) >= int(trigger.get("at_least", 1))
		"collection":
			return int(snapshot.get("collection", 0)) >= int(trigger.get("percent", 100))
		"dungeon":
			return (snapshot.get("cleared_dungeons", []) as Array).has(str(trigger.get("name", "")))
		"snapshot":
			return int(snapshot.get(str(trigger.get("key", "")), 0)) >= int(trigger.get("at_least", 1))
		"quest":
			return (snapshot.get("quests", []) as Array).has(str(trigger.get("id", "")))
	return false


static func battle_met(trigger: Dictionary, info: Dictionary, moments: Dictionary) -> bool:
	match str(trigger.get("kind", "")):
		"battle":
			if bool(trigger.get("boss", false)) and not bool(info.get("boss", false)):
				return false
			if bool(trigger.get("flawless", false)) and not bool(info.get("flawless", false)):
				return false
			if trigger.has("hp_at_most") and int(info.get("hp_left", 99)) > int(trigger["hp_at_most"]):
				return false
			if trigger.has("deck_paths_at_least") and int(info.get("deck_paths", 1)) < int(trigger["deck_paths_at_least"]):
				return false
			return true
		"moment":
			return int(moments.get(str(trigger.get("key", "")), 0)) >= int(trigger.get("at_least", 1))
	return false
