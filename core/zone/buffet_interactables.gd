class_name BuffetInteractables
extends RefCounted
## The rules behind the Endless Buffet's interactables (all effects are real; the scene only animates them):
##  - Taste-Test Station (8 gold): a blind taste test with a random result - heal 3, heal 6, +1 max life
##    for the visit, a tip in gold, a bland bite (nothing) or a too-spicy one (-1 life, never below 1).
##    Counts for nothing else but is the only random-effect interactable.
##  - The Grand Oven: bakes a Hearty Pot Pie (an item that heals 6) from honey, basil and a ghost pepper.
##    Counts for "Bake Me a Pie".
##  - The Soup Fountain: up to 3 ladles per visit, each heals 2.
##  - Fortune Cookie Dispenser (5 gold): the cookie's fortune is the next hint about a hidden stash
##    (story key `fortune.hints`), cycling through them.
##  - Old Meatloaf (the broken golem): mend him with sea salt and a black truffle (once ever).
##  - Ingredient pickups: once per visit each; stock persists in the campaign.

const TASTE_COST: int = 8
const COOKIE_COST: int = 5
const FOUNTAIN_LIMIT: int = 3
const FOUNTAIN_HEAL: int = 2
const TASTE_TIP: int = 25
const TASTE_MAX_LIFE_BONUS: int = 1
const VISIT_FOUNTAIN: String = "fountain"
const PICKUP_PREFIX: String = "pick_"


## Outcome for a roll in [0, 1): kept separate so tests can pin every branch.
static func taste_outcome(roll: float) -> String:
	if roll < 0.25:
		return "good"
	if roll < 0.40:
		return "great"
	if roll < 0.55:
		return "buff"
	if roll < 0.68:
		return "tip"
	if roll < 0.82:
		return "spicy"
	return "bland"


## Applies a taste-test outcome to the visit; returns a short description of the effect for the toast.
static func apply_taste(run: ZoneRun, outcome: String) -> String:
	match outcome:
		"good":
			return "+%d life" % run.heal(3)
		"great":
			return "+%d life" % run.heal(6)
		"buff":
			run.add_buff(GainlandsInteractables.max_life_buff("Refined Palate", TASTE_MAX_LIFE_BONUS))
			return "+%d max life this visit" % TASTE_MAX_LIFE_BONUS
		"tip":
			Session.add_gold(TASTE_TIP)
			return "+%d gold" % TASTE_TIP
		"spicy":
			var before: int = run.life
			run.life = maxi(1, run.life - 1)
			return "-%d life" % (before - run.life)
	return ""


## Picking up an ingredient: once per visit. Returns false when it was already taken this visit.
static func pick_up(run: ZoneRun, ingredient_id: String) -> bool:
	var key: String = PICKUP_PREFIX + ingredient_id
	if run.visit_count(key) > 0:
		return false
	run.bump_visit(key)
	var stock_name: String = BuffetZone.stock_key(ingredient_id)
	Session.counters[stock_name] = stock(ingredient_id) + 1
	Session.bump_counter(BuffetZone.COUNTER_GATHERED)
	Session.refresh_quests()
	return true


static func picked_this_visit(run: ZoneRun, ingredient_id: String) -> bool:
	return run.visit_count(PICKUP_PREFIX + ingredient_id) > 0


static func can_bake() -> bool:
	return has_all(BuffetZone.OVEN_RECIPE)


## Bakes one Hearty Pot Pie (consumes the ingredients). Returns false when the stock is missing.
static func bake() -> bool:
	if not can_bake():
		return false
	spend(BuffetZone.OVEN_RECIPE)
	var pie: ItemData = Session.content.item(BuffetZone.PIE_ITEM_ID)
	if pie != null:
		Session.add_item(pie)
	Session.bump_counter(BuffetZone.COUNTER_BAKED)
	Session.refresh_quests()
	return true


static func can_ladle(run: ZoneRun) -> bool:
	return run.visit_count(VISIT_FOUNTAIN) < FOUNTAIN_LIMIT


## One ladle of soup: returns {ok, number, healed}.
static func ladle(run: ZoneRun) -> Dictionary:
	if not can_ladle(run):
		return {"ok": false, "number": FOUNTAIN_LIMIT, "healed": 0}
	var number: int = run.bump_visit(VISIT_FOUNTAIN)
	return {"ok": true, "number": number, "healed": run.heal(FOUNTAIN_HEAL)}


## The index of the fortune a cookie gives, given how many have been cracked so far.
static func fortune_index(cookies_cracked: int, hint_count: int) -> int:
	return cookies_cracked % maxi(hint_count, 1)


static func can_mend() -> bool:
	return has_all(BuffetZone.MEND_RECIPE) and not Session.flag(BuffetZone.FLAG_MENDED)


## Mends Old Meatloaf (consumes sea salt and a truffle, sets the flag once ever).
static func mend() -> bool:
	if not can_mend():
		return false
	spend(BuffetZone.MEND_RECIPE)
	Session.set_flag(BuffetZone.FLAG_MENDED)
	Session.refresh_quests()
	return true


## Falling into the soup: 1 damage to the zone life and a line in the zone log. Returns {damage, down, log}.
static func apply_soup_fall(run: ZoneRun, place: String, log_template: String) -> Dictionary:
	var before: int = run.life
	run.damage(BuffetZone.SOUP_DAMAGE)
	var line: String = log_template % place
	Session.log_zone_event(line)
	return {"damage": before - run.life, "down": run.is_down(), "log": line}


# ---- Ingredient stock and gates (anything that needs the Session lives here, not in the pure data classes) ----


static func stock(ingredient_id: String) -> int:
	return int(Session.counters.get(BuffetZone.stock_key(ingredient_id), 0))


static func has_all(ingredient_ids: Array[String]) -> bool:
	for ingredient_id: String in ingredient_ids:
		if stock(ingredient_id) < 1:
			return false
	return true


## Consumes one of each listed ingredient (call only after `has_all`).
static func spend(ingredient_ids: Array[String]) -> void:
	for ingredient_id: String in ingredient_ids:
		Session.counters[BuffetZone.stock_key(ingredient_id)] = maxi(0, stock(ingredient_id) - 1)


static func gate_is_open(gate: BuffetGates.Gate) -> bool:
	return Session.flag(gate.flag)


## Opens a gate for good. The ingredient gate also consumes the saffron.
static func open_gate(gate: BuffetGates.Gate) -> void:
	if gate.kind == "ingredient":
		spend(["saffron"] as Array[String])
	Session.set_flag(gate.flag)
	Session.refresh_quests()
	Session.save_game()
