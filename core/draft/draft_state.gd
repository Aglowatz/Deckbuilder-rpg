class_name DraftState
extends RefCounted
## Draft mode, Phase 1: one draft in progress, from the Path choice to the end of its run. Plain data, saved with the game
## (`to_dict` / `from_dict`), so a draft resumes after quitting: the picks, the offer on the table, the reroll, the deck, the rivals
## and the wins and losses. `DraftEngine` holds the rules that change it.

const PHASE_PICK: String = "pick"
const PHASE_DECK: String = "deck"
const PHASE_RUN: String = "run"
const PHASE_DONE: String = "done"

var challenge_id: String = ""
## The Paths of this draft (Affinity.Type values); Pathless cards are always offered.
var paths: Array[int] = []
var seed: int = 1
## The player's level when the draft began: the base HP and the hand size of the run.
var level: int = 1
## Two-Path cards may be offered (a zone is freed and the draft has two Paths or more); three- and four-Path cards (Primm defeated).
var two_path_ok: bool = false
var multi_path_ok: bool = false
## Fable Nov 24: how many Paths the story allowed when the draft began (1, 2 or 4). The opponents of a Classic or High Rollers
## Draft take their number of Paths from this, never from the player's choice. 0 in a save from before: the old rule then.
var max_paths: int = 0
var phase: String = PHASE_PICK
## Index into `DraftEngine.schedule()`.
var step: int = 0
## The drafted card ids in pick order, the equipment ids and the item ids.
var cards: Array[String] = []
var equipment: Array[String] = []
var items: Array[String] = []
## The offer on the table: {"kind": "card" | "equipment" | "item", "options": [ids], "slot": int, "pick": n, "high": bool}.
var offer: Dictionary = {}
var rerolls_left: int = 0
## How many times the current step was rerolled (part of the offer's seed).
var rerolled: int = 0
## Indices into `cards` left out of the deck (the deck plays 20 of the 25).
var bench: Array[int] = []
## Basic Infrastructure by Path (Affinity.Type value -> count): 15 in all by default; the player sets each amount (Nov 23).
var basics: Dictionary = {}
var wins: int = 0
var losses: int = 0
## The three rivals: {"name", "npc_id", "personality", "ai", "hp", "recipe": {id: copies}, "title"}.
var rivals: Array[Dictionary] = []
## The fee was paid (or this was the free first attempt); the rewards were paid; the kept card (after a full win).
var fee_paid: int = 0
var rewarded: bool = false
var kept_card: String = ""
## The reward of the finished run, for the result screen.
var result: Dictionary = {}
## Fable big pass Nov 23: the pieces of equipment already offered in this draft (a piece is not offered twice unless its slot runs out).
var offered_equipment: Array[String] = []
## A dungeon draft: the dungeon it plays (a `MainDungeons` key; set when the draft starts, or at the door for Mystery Mini), and how it
## ended (`dungeon_over`: the run is finished; `dungeon_cleared`: the boss fell). `fights_won` counts its fights for the consolation.
var dungeon_key: String = ""
var dungeon_over: bool = false
var dungeon_cleared: bool = false
var fights_won: int = 0


func is_dungeon() -> bool:
	return DraftArena.is_dungeon(challenge_id)


func is_finished() -> bool:
	if is_dungeon():
		return dungeon_over
	return wins >= DraftChallenges.wins_to_finish(challenge_id) or losses >= DraftChallenges.losses_to_finish(challenge_id)


## A table draft won with three wins, or a dungeon draft whose boss fell.
func full_win() -> bool:
	if is_dungeon():
		return dungeon_cleared
	return wins >= DraftChallenges.wins_to_finish(challenge_id)


func fights_played() -> int:
	return wins + losses


func to_dict() -> Dictionary:
	return {
		"challenge_id": challenge_id, "paths": paths.duplicate(), "seed": seed, "level": level, "two_path_ok": two_path_ok, "multi_path_ok": multi_path_ok, "max_paths": max_paths,
		"phase": phase, "step": step, "cards": cards.duplicate(), "equipment": equipment.duplicate(), "items": items.duplicate(), "offer": offer.duplicate(true),
		"rerolls_left": rerolls_left, "rerolled": rerolled, "bench": bench.duplicate(), "basics": _string_keys(basics), "wins": wins, "losses": losses,
		"rivals": rivals.duplicate(true), "fee_paid": fee_paid, "rewarded": rewarded, "kept_card": kept_card, "result": result.duplicate(true),
		"offered_equipment": offered_equipment.duplicate(), "dungeon_key": dungeon_key, "dungeon_over": dungeon_over, "dungeon_cleared": dungeon_cleared, "fights_won": fights_won,
	}


static func from_dict(data: Dictionary) -> DraftState:
	if data.is_empty() or str(data.get("challenge_id", "")).is_empty():
		return null
	var state: DraftState = DraftState.new()
	state.challenge_id = str(data.get("challenge_id", ""))
	for value: Variant in data.get("paths", []) as Array:
		state.paths.append(int(value))
	state.seed = int(data.get("seed", 1))
	state.level = int(data.get("level", 1))
	state.two_path_ok = bool(data.get("two_path_ok", false))
	state.multi_path_ok = bool(data.get("multi_path_ok", false))
	state.max_paths = int(data.get("max_paths", 0))
	state.phase = str(data.get("phase", PHASE_PICK))
	state.step = int(data.get("step", 0))
	for value: Variant in data.get("cards", []) as Array:
		state.cards.append(str(value))
	for value: Variant in data.get("equipment", []) as Array:
		state.equipment.append(str(value))
	for value: Variant in data.get("items", []) as Array:
		state.items.append(str(value))
	state.offer = (data.get("offer", {}) as Dictionary).duplicate(true)
	if state.offer.has("options"):
		var options: Array[String] = []
		for value: Variant in state.offer["options"] as Array:
			options.append(str(value))
		state.offer["options"] = options
	for key: String in ["slot", "pick", "room"]:
		if state.offer.has(key):
			state.offer[key] = int(state.offer[key])  # JSON hands numbers back as floats
	state.rerolls_left = int(data.get("rerolls_left", 0))
	state.rerolled = int(data.get("rerolled", 0))
	for value: Variant in data.get("bench", []) as Array:
		state.bench.append(int(value))
	var saved_basics: Dictionary = data.get("basics", {}) as Dictionary
	for key: Variant in saved_basics.keys():
		state.basics[int(str(key))] = int(saved_basics[key])
	state.wins = int(data.get("wins", 0))
	state.losses = int(data.get("losses", 0))
	for value: Variant in data.get("rivals", []) as Array:
		var rival: Dictionary = (value as Dictionary).duplicate(true)
		rival["hp"] = int(rival.get("hp", 20))
		if rival.has("room"):
			rival["room"] = int(rival["room"])
		if rival.has("paths"):
			var rival_paths: Array[int] = []
			for path: Variant in rival["paths"] as Array:
				rival_paths.append(int(path))
			rival["paths"] = rival_paths
		var recipe: Dictionary = {}
		for id: Variant in (rival.get("recipe", {}) as Dictionary).keys():
			recipe[str(id)] = int((rival["recipe"] as Dictionary)[id])
		rival["recipe"] = recipe
		state.rivals.append(rival)
	state.fee_paid = int(data.get("fee_paid", 0))
	state.rewarded = bool(data.get("rewarded", false))
	state.kept_card = str(data.get("kept_card", ""))
	state.result = (data.get("result", {}) as Dictionary).duplicate(true)
	for value: Variant in data.get("offered_equipment", []) as Array:
		state.offered_equipment.append(str(value))
	state.dungeon_key = str(data.get("dungeon_key", ""))
	state.dungeon_over = bool(data.get("dungeon_over", false))
	state.dungeon_cleared = bool(data.get("dungeon_cleared", false))
	state.fights_won = int(data.get("fights_won", 0))
	return state


static func _string_keys(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in source.keys():
		result[str(key)] = source[key]
	return result
