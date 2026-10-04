class_name HeapInteractables
extends RefCounted
## The rules behind the Verdant Dump's interactables (all effects are real; the scene only animates them):
##  - Pickups: beans, fertilizer and junk, once per visit each; the stock persists in the campaign.
##  - The Compost Bin: 2 piles of junk make a "Compost Cocktail" - +1 max life for the visit (twice per visit).
##  - Crop plots: plant a crop with a sack of fertilizer; it ripens after `HeapGrowth.CROP_SECONDS` of real time in
##    the same visit; harvesting heals 4 and pays 15 gold.
##  - The Druid Shrine: kneel once per visit for the "Blessing of Bloom" (+1 max life for the visit, heal 3).
##  - The Feeding Trough: feed it a pile of junk, the animals pay 12 gold (3 feedings per visit).
##  - Growing: plant a Magic Bean at a sprout mound, or let a druid grow it once her condition is met.
##  - Barricades: smashed by a charging mount.
##  - Escaped animals: shoo each one back to the pen once per visit.

const COMPOST_COST: int = 2
const COMPOST_LIMIT: int = 2
const COMPOST_MAX_LIFE_BONUS: int = 1
const HARVEST_HEAL: int = 4
const HARVEST_GOLD: int = 15
const FEED_GOLD: int = 12
const FEED_LIMIT: int = 3
const BLESSING_HEAL: int = 3
const BLESSING_MAX_LIFE_BONUS: int = 1
const PICKUP_PREFIX: String = "pick_"
const VISIT_COMPOST: String = "compost"
const VISIT_FEED: String = "feed"
const VISIT_BLESSED: String = "blessed"
const VISIT_HERDED_PREFIX: String = "herded_"


static func stock(kind: String) -> int:
	return int(Session.counters.get(HeapZone.stock_key(kind), 0))


static func spend(kind: String, amount: int = 1) -> void:
	Session.counters[HeapZone.stock_key(kind)] = maxi(0, stock(kind) - amount)


static func give(kind: String, amount: int = 1) -> void:
	Session.counters[HeapZone.stock_key(kind)] = stock(kind) + amount


## Picking up a stock item: once per visit. Returns false when it was already taken this visit.
static func pick_up(run: ZoneRun, pickup_id: String) -> bool:
	var key: String = PICKUP_PREFIX + pickup_id
	if run.visit_count(key) > 0:
		return false
	run.bump_visit(key)
	var kind: String = HeapZone.pickup_kind(pickup_id)
	give(kind)
	if kind == "fert":
		Session.bump_counter(HeapZone.COUNTER_FERTILIZER)
	Session.refresh_quests()
	return true


static func picked_this_visit(run: ZoneRun, pickup_id: String) -> bool:
	return run.visit_count(PICKUP_PREFIX + pickup_id) > 0


# ---- Compost bin, shrine, trough ------------------------------------------------------------------------


static func can_compost(run: ZoneRun) -> bool:
	return stock("junk") >= COMPOST_COST and run.visit_count(VISIT_COMPOST) < COMPOST_LIMIT


## Composts two piles of junk into a visit-long buff. Returns false when it cannot.
static func compost(run: ZoneRun) -> bool:
	if not can_compost(run):
		return false
	spend("junk", COMPOST_COST)
	run.bump_visit(VISIT_COMPOST)
	run.add_buff(GainlandsInteractables.max_life_buff("Compost Cocktail", COMPOST_MAX_LIFE_BONUS))
	Session.bump_counter(HeapZone.COUNTER_COMPOSTED)
	Session.refresh_quests()
	return true


static func can_bless(run: ZoneRun) -> bool:
	return run.visit_count(VISIT_BLESSED) == 0


## The druid shrine's blessing, once per visit. Returns {ok, healed}.
static func bless(run: ZoneRun) -> Dictionary:
	if not can_bless(run):
		return {"ok": false, "healed": 0}
	run.bump_visit(VISIT_BLESSED)
	run.add_buff(GainlandsInteractables.max_life_buff("Blessing of Bloom", BLESSING_MAX_LIFE_BONUS))
	return {"ok": true, "healed": run.heal(BLESSING_HEAL)}


static func can_feed(run: ZoneRun) -> bool:
	return stock("junk") >= 1 and run.visit_count(VISIT_FEED) < FEED_LIMIT


## Feeds the animals a pile of junk for gold. Returns false when it cannot.
static func feed(run: ZoneRun) -> bool:
	if not can_feed(run):
		return false
	spend("junk")
	run.bump_visit(VISIT_FEED)
	Session.add_gold(FEED_GOLD)
	Session.bump_counter(HeapZone.COUNTER_FEEDINGS)
	Session.refresh_quests()
	return true


# ---- Crops ---------------------------------------------------------------------------------------------------


static func _crop_key(plot: int) -> String:
	return "crop_%d" % plot


## "empty", "growing" or "ripe" at wall-clock `now` (seconds).
static func crop_state(run: ZoneRun, plot: int, now: float) -> String:
	var planted: int = run.visit_count(_crop_key(plot))
	if planted <= 0:
		return "empty"
	return "ripe" if now - float(planted) >= HeapGrowth.CROP_SECONDS else "growing"


## Plants a crop (costs a sack of fertilizer). Returns false when the plot is taken or there is no fertilizer.
static func plant(run: ZoneRun, plot: int, now: float) -> bool:
	if crop_state(run, plot, now) != "empty" or stock("fert") < 1:
		return false
	spend("fert")
	run.visit_counts[_crop_key(plot)] = maxi(1, int(now))
	return true


## Harvests a ripe crop: heals and pays. Returns {ok, healed, gold}.
static func harvest(run: ZoneRun, plot: int, now: float) -> Dictionary:
	if crop_state(run, plot, now) != "ripe":
		return {"ok": false, "healed": 0, "gold": 0}
	run.visit_counts[_crop_key(plot)] = 0
	Session.add_gold(HARVEST_GOLD)
	Session.bump_counter(HeapZone.COUNTER_HARVESTS)
	Session.refresh_quests()
	return {"ok": true, "healed": run.heal(HARVEST_HEAL), "gold": HARVEST_GOLD}


# ---- Growing and smashing ----------------------------------------------------------------------------------


static func is_grown(growth: HeapGrowth.Growth) -> bool:
	return Session.flag(growth.flag)


static func can_grow(growth: HeapGrowth.Growth) -> bool:
	if is_grown(growth):
		return false
	if growth.how == "bean":
		return stock("bean") >= 1
	return HeapGrowth.requirement_met(growth, Session.unlock_state())


## Grows a bridge or beanstalk for good (a bean is used up). Returns false when it cannot.
static func grow(growth: HeapGrowth.Growth) -> bool:
	if not can_grow(growth):
		return false
	if growth.how == "bean":
		spend("bean")
	Session.set_flag(growth.flag)
	Session.bump_counter(HeapZone.COUNTER_GROWN)
	Session.refresh_quests()
	Session.save_game()
	return true


static func is_smashed(barricade: HeapGrowth.Barricade) -> bool:
	return Session.flag(barricade.flag)


static func smash(barricade: HeapGrowth.Barricade) -> void:
	if is_smashed(barricade):
		return
	Session.set_flag(barricade.flag)
	Session.bump_counter(HeapZone.COUNTER_CHARGES)
	Session.refresh_quests()
	Session.save_game()


## Shooing an escaped animal back to the pen: once per visit each. Returns false when already done.
static func herd(run: ZoneRun, animal: int) -> bool:
	var key: String = VISIT_HERDED_PREFIX + str(animal)
	if run.visit_count(key) > 0:
		return false
	run.bump_visit(key)
	Session.bump_counter(HeapZone.COUNTER_HERDED)
	Session.refresh_quests()
	return true


static func herded_this_visit(run: ZoneRun, animal: int) -> bool:
	return run.visit_count(VISIT_HERDED_PREFIX + str(animal)) > 0


## Falling into the compost pit or the recycling stream: 1 damage and a line in the zone log. Returns {damage, down, log}.
static func apply_hazard_fall(run: ZoneRun, place: String, log_template: String) -> Dictionary:
	var before: int = run.life
	run.damage(HeapZone.HAZARD_DAMAGE)
	var line: String = log_template % place
	Session.log_zone_event(line)
	return {"damage": before - run.life, "down": run.is_down(), "log": line}
