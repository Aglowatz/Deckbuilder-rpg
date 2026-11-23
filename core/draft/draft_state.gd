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
## Two-Path cards may be offered (all four zones freed); three- and four-Path cards may be offered (Primm defeated).
var two_path_ok: bool = false
var multi_path_ok: bool = false
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
## Basic Infrastructure by Path (Affinity.Type value -> count), 15 in all.
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


func is_finished() -> bool:
	return wins >= DraftRules.wins_to_finish() or losses >= DraftRules.losses_to_finish()


func full_win() -> bool:
	return wins >= DraftRules.wins_to_finish()


func fights_played() -> int:
	return wins + losses


func to_dict() -> Dictionary:
	return {
		"challenge_id": challenge_id, "paths": paths.duplicate(), "seed": seed, "level": level, "two_path_ok": two_path_ok, "multi_path_ok": multi_path_ok,
		"phase": phase, "step": step, "cards": cards.duplicate(), "equipment": equipment.duplicate(), "items": items.duplicate(), "offer": offer.duplicate(true),
		"rerolls_left": rerolls_left, "rerolled": rerolled, "bench": bench.duplicate(), "basics": _string_keys(basics), "wins": wins, "losses": losses,
		"rivals": rivals.duplicate(true), "fee_paid": fee_paid, "rewarded": rewarded, "kept_card": kept_card, "result": result.duplicate(true),
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
	for key: String in ["slot", "pick"]:
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
		var recipe: Dictionary = {}
		for id: Variant in (rival.get("recipe", {}) as Dictionary).keys():
			recipe[str(id)] = int((rival["recipe"] as Dictionary)[id])
		rival["recipe"] = recipe
		state.rivals.append(rival)
	state.fee_paid = int(data.get("fee_paid", 0))
	state.rewarded = bool(data.get("rewarded", false))
	state.kept_card = str(data.get("kept_card", ""))
	state.result = (data.get("result", {}) as Dictionary).duplicate(true)
	return state


static func _string_keys(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in source.keys():
		result[str(key)] = source[key]
	return result
