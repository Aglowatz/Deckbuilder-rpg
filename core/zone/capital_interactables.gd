class_name CapitalInteractables
extends RefCounted
## The rules behind the Capital's interactables (all effects are real; the scene only animates them and shows the text):
##  - Deface propaganda: a portrait of Primm, once each, pays a little gold ("a small reward") and is saved.
##  - The Anonymous Complaint Box: at most `COMPLAINT_LIMIT` per visit; the reply cycles: compensation (gold), a heal, "noted"
##    (nothing) and "an Inspector is dispatched" (a little damage).
##  - Rift-stones: seal a (sealable) rift once its guardian is beaten; pays the rift's reward; saved.
##  - Quest pickups and objects: recipe cards, banished compost heaps, the stamp, the seed (once each, saved), free a wheel
##    crew, cut the cable, spoil the paste, lay Grandfather Marrow to rest, plant the seed in the sick patch.
## Results are dictionaries: `ok` (the effect happened), `key` (the story text key of what to say) and extras.

const COMPLAINT_LIMIT: int = 2
const COMPLAINT_REPLIES: Array[String] = ["compensation", "tea", "noted", "inspector"]
const COMPENSATION_GOLD: int = 15
const TEA_HEAL: int = 2
const INSPECTOR_DAMAGE: int = 1
const PERMIT_LOOPS: Array[String] = ["permit_1", "permit_2", "permit_3"]

## How many of the four Path insights into Primm the player has collected (each Path quest sets its flag on hand-in).

static func insight_count(flags: Dictionary) -> int:
	var count: int = 0
	for zone_id: String in ZoneDefs.ids():
		if bool(flags.get(str(CapitalZone.insight_flag(zone_id)), false)):
			count += 1
	return count


# ---- Propaganda --------------------------------------------------------------------------------------------


static func deface(spot_id: String) -> Dictionary:
	var secret: String = CapitalZone.secret_id("deface", spot_id)
	if Session.found_secret(secret):
		return {"ok": false, "key": "fx.deface_again"}
	Session.discover_secret(secret)
	Session.add_gold(CapitalZone.DEFACE_REWARD)
	Session.bump_counter(CapitalZone.COUNTER_DEFACED)
	return {"ok": true, "key": "fx.deface", "gold": CapitalZone.DEFACE_REWARD}


# ---- The complaint box -------------------------------------------------------------------------------------------


static func complaint(run: ZoneRun) -> Dictionary:
	if run.visit_count("complaints") >= COMPLAINT_LIMIT:
		return {"ok": false, "key": "fx.complaint_limit"}
	var index: int = Session.counter(CapitalZone.COUNTER_COMPLAINTS) % COMPLAINT_REPLIES.size()
	run.bump_visit("complaints")
	Session.bump_counter(CapitalZone.COUNTER_COMPLAINTS)
	var reply: String = COMPLAINT_REPLIES[index]
	var result: Dictionary = {"ok": true, "key": "fx.complaint_" + reply, "reply": reply}
	match reply:
		"compensation":
			Session.add_gold(COMPENSATION_GOLD)
			result["gold"] = COMPENSATION_GOLD
		"tea":
			result["healed"] = run.heal(TEA_HEAL)
		"inspector":
			run.damage(INSPECTOR_DAMAGE)
			result["damage"] = INSPECTOR_DAMAGE
	return result


# ---- Rifts -------------------------------------------------------------------------------------------------------------


## Seals a rift: it must be sealable, still open, and its guardian beaten (this visit) - or it is simply closed already.
static func seal_rift(run: ZoneRun, rift_id: String) -> Dictionary:
	var entry: Dictionary = CapitalRifts.find(rift_id)
	if entry.is_empty() or not bool(entry["sealable"]):
		return {"ok": false, "key": "fx.seal_cannot"}
	if CapitalRifts.is_sealed(Session.flags, rift_id):
		return {"ok": false, "key": "fx.seal_done"}
	if not run.is_defeated(CapitalRifts.guardian_id(rift_id)):
		return {"ok": false, "key": "fx.seal_guarded"}
	Session.set_flag(CapitalRifts.sealed_flag(rift_id))
	Session.bump_counter(CapitalZone.COUNTER_RIFTS_SEALED)
	var reward: Dictionary = entry["reward"] as Dictionary
	var parts: PackedStringArray = []
	var gold: int = int(reward.get("gold", 0))
	if gold > 0:
		Session.add_gold(gold)
		parts.append("+%d gold" % gold)
	var item_id: String = str(reward.get("item", ""))
	if not item_id.is_empty() and Session.content.item(item_id) != null:
		Session.add_item(Session.content.item(item_id))
		parts.append(Session.content.item(item_id).display_name)
	var card_id: String = str(reward.get("card", ""))
	if not card_id.is_empty() and Session.card_by_id(card_id) != null:
		Session.add_cards([Session.card_by_id(card_id)] as Array[CardData])
		parts.append(Session.card_by_id(card_id).display_name)
	return {"ok": true, "key": "fx.seal", "reward_text": ", ".join(parts), "rift": rift_id}


# ---- Quest pickups and objects ---------------------------------------------------------------------------------------------


## Taking a pickup (a recipe card, a compost heap, the stamp, the seed): once, saved.
static func pick_up(pickup_id: String) -> Dictionary:
	var kind: String = str(CapitalZone.PICKUPS.get(pickup_id, ""))
	if kind.is_empty():
		return {"ok": false, "key": "fx.pickup_unknown"}
	var secret: String = CapitalZone.secret_id("pick", pickup_id)
	if Session.found_secret(secret):
		return {"ok": false, "key": "fx.pickup_again"}
	Session.discover_secret(secret)
	match kind:
		"recipe":
			Session.bump_counter(CapitalZone.COUNTER_RECIPES)
		"compost":
			Session.bump_counter(CapitalZone.COUNTER_COMPOST)
		"stamp":
			Session.set_flag(CapitalZone.FLAG_STAMP)
		"seed":
			Session.set_flag(CapitalZone.FLAG_SEED_FOUND)
	Session.refresh_quests()
	return {"ok": true, "key": "fx.pickup_" + kind, "kind": kind}


static func free_wheel(n: int) -> Dictionary:
	var secret: String = CapitalZone.secret_id("wheel", str(n))
	if Session.found_secret(secret):
		return {"ok": false, "key": "fx.wheel_again", "n": n}
	Session.discover_secret(secret)
	Session.bump_counter(CapitalZone.COUNTER_WHEELS)
	var all_free: bool = Session.counter(CapitalZone.COUNTER_WHEELS) >= 3
	return {"ok": true, "key": "fx.wheel_%d" % n, "n": n, "all": all_free}


static func cut_cable() -> Dictionary:
	if Session.flag(CapitalZone.FLAG_CABLE_CUT):
		return {"ok": false, "key": "fx.cable_again"}
	Session.set_flag(CapitalZone.FLAG_CABLE_CUT)
	return {"ok": true, "key": "fx.cable"}


static func spoil_paste() -> Dictionary:
	if Session.flag(CapitalZone.FLAG_PASTE_SPOILED):
		return {"ok": false, "key": "fx.paste_again"}
	Session.set_flag(CapitalZone.FLAG_PASTE_SPOILED)
	return {"ok": true, "key": "fx.paste"}


static func lay_to_rest() -> Dictionary:
	if Session.flag(CapitalZone.FLAG_LAID_TO_REST):
		return {"ok": false, "key": "fx.plot_again"}
	if not Session.flag(CapitalZone.FLAG_STAMP):
		return {"ok": false, "key": "fx.plot_locked"}
	Session.set_flag(CapitalZone.FLAG_LAID_TO_REST)
	return {"ok": true, "key": "fx.plot"}


static func plant_seed() -> Dictionary:
	if Session.flag(CapitalZone.FLAG_SEED_PLANTED):
		return {"ok": false, "key": "fx.patch_again"}
	if not Session.flag(CapitalZone.FLAG_SEED_FOUND):
		return {"ok": false, "key": "fx.patch_locked"}
	Session.set_flag(CapitalZone.FLAG_SEED_PLANTED)
	return {"ok": true, "key": "fx.patch"}


## The Permit Office window: the paperwork loops (three different loops, then round again).
static func permit_loop() -> Dictionary:
	var index: int = Session.counter("cap_permit_visits") % PERMIT_LOOPS.size()
	Session.bump_counter("cap_permit_visits")
	return {"ok": true, "key": "fx." + PERMIT_LOOPS[index]}


# ---- Travel ---------------------------------------------------------------------------------------------------------------------


## The service-tunnel network is down while the Beefcake service is broken.
static func can_travel(flags: Dictionary) -> bool:
	return not CapitalDebuffs.travel_blocked(flags)
