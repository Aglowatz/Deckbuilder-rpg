class_name ZoneRun
extends RefCounted
## One visit to a zone (the D.N.A.). Implements the zone HP rules (docs/design/zones.md):
## HP persists between battles and enemy hits for the whole visit - there is no healing after a
## battle. The only ways back up are the hub's healing spot, items/cards, or leaving to town (a
## fresh visit starts at full HP). At 0 HP the player wakes up at the hub at full HP and
## pays a small gold "paperwork fee".
##
## HP itself lives in a wrapped `DungeonRun` so everything that already knows how to heal or
## damage a run (consumable items, `ItemUseResolver`, battles via `start_encounter`) works unchanged.

## Gold taken when the player is carried back to the hub at 0 HP (never more than they have).
const PAPERWORK_FEE: int = 15

var zone_id: String = ""
var run: DungeonRun
## Ids of roaming enemies beaten this visit - they stay gone until the zone is re-entered.
var defeated_enemies: Array[String] = []
## Where the player stood before a battle/the mini dungeon (so they resume there).
var return_position: Vector3 = Vector3.ZERO
var has_return_position: bool = false
## Every paperwork fee charged this visit ("log it"): human-readable lines.
var fee_log: Array[String] = []
var fees_paid: int = 0
## The time clock's once-per-visit buff.
var punched_in: bool = false
## Per-visit counters for zone interactables (flexes at the mirror, buffs taken...): key -> count.
var visit_counts: Dictionary = {}


static func enter(zone: String, profile: PlayerProfile, deck: Deck) -> ZoneRun:
	var visit: ZoneRun = ZoneRun.new()
	visit.zone_id = zone
	visit.run = DungeonRun.enter(profile, deck, [] as Array[ModifierSource])
	return visit


var hp: int:
	get:
		return run.hp
	set(value):
		run.hp = clampi(value, 0, run.max_hp())


func max_hp() -> int:
	return run.max_hp()


func is_down() -> bool:
	return run.hp <= 0


func damage(amount: int) -> void:
	if amount <= 0:
		return
	run.hp = maxi(0, run.hp - amount)


## Heals up to max HP. Returns how much HP was actually restored.
func heal(amount: int) -> int:
	var before: int = run.hp
	run.hp = mini(run.hp + maxi(amount, 0), run.max_hp())
	return run.hp - before


func fully_heal() -> int:
	return heal(run.max_hp())


## Carried to the hub at 0 HP: back to full HP, minus the paperwork fee. Returns the fee
## actually charged (capped at the gold the player has).
func wake_at_hub(gold_available: int, cause: String = "") -> int:
	run.hp = run.max_hp()
	run.failed = false
	var def: ZoneDef = ZoneDefs.get_def(zone_id)
	var fee: int = mini(def.fee, maxi(gold_available, 0))
	fees_paid += fee
	var reason: String = cause if not cause.is_empty() else "declared Deceased (again)"
	fee_log.append("%s %d gold - %s" % [def.fee_label, fee, reason])
	return fee


## Records the HP left after a duel fought inside the zone (a loss leaves 0).
func finish_battle(game: GameState) -> void:
	run.hp = clampi(game.players[0].hp, 0, run.max_hp())


## Adds a visit-long buff (a ModifierSource); max-HP buffs raise current HP too.
func add_buff(source: ModifierSource) -> void:
	run.add_dungeon_source(source)


func visit_count(key: String) -> int:
	return int(visit_counts.get(key, 0))


func bump_visit(key: String) -> int:
	visit_counts[key] = visit_count(key) + 1
	return visit_count(key)


func mark_defeated(enemy_id: String) -> void:
	if not defeated_enemies.has(enemy_id):
		defeated_enemies.append(enemy_id)


func is_defeated(enemy_id: String) -> bool:
	return defeated_enemies.has(enemy_id)
