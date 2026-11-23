class_name DraftRules
extends RefCounted
## Draft mode, Phase 1 (docs/design/draft_mode.md): every number of the mode, read from data/draft/draft_rules.json so the owner can
## tune them without touching code (the picks, the rarity slots, where the equipment and item picks fall, the reroll, the deck, the
## run's end, the fee, the ban lists, the rewards).

const PATH: String = "res://data/draft/draft_rules.json"
const CARD_RARITY_KEYS: Array[String] = ["common", "uncommon", "epic", "legendary"]

static var _data: Dictionary = {}


static func data() -> Dictionary:
	if _data.is_empty():
		var file: FileAccess = FileAccess.open(PATH, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				_data = parsed as Dictionary
	return _data


## Tests only: drop the cache (after a test changed a value).
static func reload() -> void:
	_data = {}


static func number(key: String, fallback: int) -> int:
	return int(data().get(key, fallback))


static func card_picks() -> int:
	return number("card_picks", 25)


static func options() -> int:
	return number("options_per_pick", 3)


static func high_rarity_every() -> int:
	return number("high_rarity_every", 5)


static func rerolls() -> int:
	return number("rerolls", 1)


static func deck_cards() -> int:
	return number("deck_drafted_cards", 20)


static func deck_basics() -> int:
	return number("deck_basic_infrastructure", 15)


static func wins_to_finish() -> int:
	return number("wins_to_finish", 3)


static func losses_to_finish() -> int:
	return number("losses_to_finish", 2)


static func entry_fee() -> int:
	return number("entry_fee", 100)


static func first_attempt_free() -> bool:
	return bool(data().get("first_attempt_free", true))


static func item_slots() -> int:
	return number("item_slots", 2)


static func fit_weight() -> float:
	return float(data().get("fit_weight", 2.0))


static func int_list(key: String) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in data().get(key, []) as Array:
		result.append(int(value))
	return result


static func banned(key: String) -> Dictionary:
	var result: Dictionary = {}
	for value: Variant in data().get(key, []) as Array:
		result[str(value)] = true
	return result


## The weight of a card rarity on an ordinary pick, or on a high-rarity pick.
static func card_weight(rarity: CardEnums.Rarity, high: bool) -> float:
	var table: Dictionary = data().get("high_rarity_weights" if high else "rarity_weights", {}) as Dictionary
	return float(table.get(CARD_RARITY_KEYS[clampi(int(rarity), 0, 3)], 0.0))


static func equipment_weight(rarity: EquipmentData.Rarity) -> float:
	var table: Dictionary = data().get("equipment_rarity_weights", {}) as Dictionary
	return float(table.get(CARD_RARITY_KEYS[clampi(int(rarity), 0, 3)], 1.0))


## Gold and XP of a finished run by its wins: {"gold": n, "xp": n}.
static func replay_reward(wins: int) -> Dictionary:
	var table: Dictionary = (data().get("rewards", {}) as Dictionary).get("replay", {}) as Dictionary
	var gold: Array = table.get("gold", [0, 0, 0, 0]) as Array
	var xp: Array = table.get("xp", [0, 0, 0, 0]) as Array
	var index: int = clampi(wins, 0, gold.size() - 1)
	return {"gold": int(gold[index]), "xp": int(xp[clampi(wins, 0, xp.size() - 1)])}


static func first_win_bonus() -> Dictionary:
	var table: Dictionary = (data().get("rewards", {}) as Dictionary).get("first_win_bonus", {}) as Dictionary
	return {"gold": int(table.get("gold", 0)), "xp": int(table.get("xp", 0))}


static func rivals() -> Dictionary:
	return data().get("rivals", {}) as Dictionary
