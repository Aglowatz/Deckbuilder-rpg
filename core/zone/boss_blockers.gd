class_name BossBlockers
extends RefCounted
## Fix pass Nov 4 (Part 1.6): the overworld duels whose foe stands in the way until beaten. Winning sets the foe's "defeated" flag at once
## (`GameSession.resolve_zone_battle`, whatever ended the duel: a normal win or the dev win), and the zone scene moves the blocker aside
## from that flag (`ZoneScene.sync_world_flags`) - on a rebuild, on the return to a parked scene and whenever the flag is set.
##
## | Zone | Duel spot | Flag | What moves |
## | Endless Buffet | gate_casserole (Colonel Casserole) | buf_gate_battle_open | the golem steps off the Pancake Mesa road |
## | Capital | spotless (Captain Spotless) | cap_gate_open (+ cap_inside) | the gate barrier lifts |
## The four hub gatekeepers (`Gatekeepers`) clear their obstacles from `CorruptedNpcs.unlock_flag`; the town is rebuilt after those duels.

## zone id -> {duel spot (zone enemy instance id) -> flag}.
const FLAGS: Dictionary = {
	"gourmand": {"gate_casserole": &"buf_gate_battle_open"},
	"final": {"spotless": &"cap_gate_open"},
}


## The flag a win at `instance_id` in `zone_id` sets (&"" when that duel blocks nothing).
static func flag_for(zone_id: String, instance_id: String) -> StringName:
	var spots: Dictionary = FLAGS.get(zone_id, {}) as Dictionary
	return spots.get(instance_id, &"") as StringName
