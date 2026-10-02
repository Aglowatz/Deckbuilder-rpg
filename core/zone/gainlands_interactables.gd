class_name GainlandsInteractables
extends RefCounted
## The rules behind the Gainlands' interactables (all effects are real; the scene only animates them):
##  - Protein Shake Stand (10 gold): a random result - heal 3, heal 6, +1 max life for the visit, a coin
##    back, an empty cup, or a bad shake (-1 life, never below 1). Counts for "Juice the Station".
##  - Flex Mirror: up to 3 flexes per visit, each heals 1 life. Counts for "Spot Me!".
##  - Spot Me (Gary under a barbell): a visit-long +2 max life buff, plus 30 gold and the quest flag the
##    first time ever.
##  - Colossal Hamster Wheel: run it once to power the grid (the portal ripper to Delt Deck needs it).

const SHAKE_COST: int = 10
const FLEX_LIMIT: int = 3
const FLEX_HEAL: int = 1
const SPOT_MAX_LIFE_BONUS: int = 2
const SPOT_GOLD: int = 30
const SHAKE_REFUND: int = 30
const SHAKE_MAX_LIFE_BONUS: int = 1
const VISIT_FLEXES: String = "flexes"
const VISIT_SPOT: String = "spot_me"


## Outcome for a roll in [0, 1): kept separate so tests can pin every branch.
static func shake_outcome(roll: float) -> String:
	if roll < 0.28:
		return "good"
	if roll < 0.43:
		return "great"
	if roll < 0.58:
		return "buff"
	if roll < 0.70:
		return "gold"
	if roll < 0.82:
		return "bad"
	return "empty"


## Applies a shake outcome to the visit; returns a short description of the effect for the toast.
static func apply_shake(run: ZoneRun, outcome: String) -> String:
	match outcome:
		"good":
			return "+%d life" % run.heal(3)
		"great":
			return "+%d life" % run.heal(6)
		"buff":
			run.add_buff(max_life_buff("Chalky Classic", SHAKE_MAX_LIFE_BONUS))
			return "+%d max life this visit" % SHAKE_MAX_LIFE_BONUS
		"gold":
			Session.add_gold(SHAKE_REFUND)
			return "+%d gold" % SHAKE_REFUND
		"bad":
			var before: int = run.life
			run.life = maxi(1, run.life - 1)
			return "-%d life" % (before - run.life)
	return ""


static func max_life_buff(buff_name: String, amount: int) -> ModifierSource:
	var source: ModifierSource = ModifierSource.new()
	source.source_name = buff_name
	source.source_kind = ModifierSource.SourceKind.ZONE
	var modifier: Modifier = Modifier.new()
	modifier.kind = Modifier.Kind.MAX_LIFE
	modifier.value = amount
	modifier.label = "%s: +%d max life this visit" % [buff_name, amount]
	source.modifiers = [modifier] as Array[Modifier]
	return source


static func can_flex(run: ZoneRun) -> bool:
	return run.visit_count(VISIT_FLEXES) < FLEX_LIMIT


## One flex: returns {ok, number, healed}. Counts toward the quest even when there is nothing to heal.
static func flex(run: ZoneRun) -> Dictionary:
	if not can_flex(run):
		return {"ok": false, "number": FLEX_LIMIT, "healed": 0}
	var number: int = run.bump_visit(VISIT_FLEXES)
	var healed: int = run.heal(FLEX_HEAL)
	Session.bump_counter(GainlandsZone.COUNTER_FLEXES)
	return {"ok": true, "number": number, "healed": healed}


## Helping Gary: the visit buff every time (once per visit), gold and the quest flag the first time ever.
## Returns {ok, first_time, gold}.
static func spot_gary(run: ZoneRun) -> Dictionary:
	if run.visit_count(VISIT_SPOT) > 0:
		return {"ok": false, "first_time": false, "gold": 0}
	run.bump_visit(VISIT_SPOT)
	run.add_buff(max_life_buff("Spotted Gary", SPOT_MAX_LIFE_BONUS))
	var first: bool = not Session.flag(GainlandsZone.FLAG_SPOTTED)
	var gold: int = 0
	if first:
		Session.set_flag(GainlandsZone.FLAG_SPOTTED)
		gold = SPOT_GOLD
		Session.add_gold(gold)
	Session.refresh_quests()
	return {"ok": true, "first_time": first, "gold": gold}


## Running the wheel: powers the grid once ever (returns true the first time).
static func run_wheel() -> bool:
	var first: bool = not Session.flag(GainlandsZone.FLAG_WHEEL_POWERED)
	Session.set_flag(GainlandsZone.FLAG_WHEEL_POWERED)
	Session.refresh_quests()
	return first


## Falling off an island: 1 damage to the zone life (`GainlandsZone.FALL_DAMAGE`) and a line in the
## zone log. Returns {damage, down, log}; the scene handles the respawn at the last safe spot.
static func apply_fall(run: ZoneRun, island_title: String, log_template: String) -> Dictionary:
	var before: int = run.life
	run.damage(GainlandsZone.FALL_DAMAGE)
	var line: String = log_template % island_title
	Session.log_zone_event(line)
	return {"damage": before - run.life, "down": run.is_down(), "log": line}
