extends GutTest
## Overnight Nov 19 (Part 2.7): the duplicate-character probe. In every zone, before and after it is freed (the Capital: after the
## ending), no character (NPC id) stands in two places at once: the zone's own NPCs, the freed NPCs ZoneScene actually builds and Old
## Hob together name each character once. The D.N.A.'s Agnes Overdue stood at her front desk and by the hub after the freeing.


func _ids_before(def: ZoneDef) -> Array[String]:
	var ids: Array[String] = []
	for entry: Dictionary in def.npcs:
		var npc_id: String = str(entry.get("npc_id", ""))
		if not npc_id.is_empty() and not GENERIC.has(npc_id):
			ids.append(npc_id)
	return ids


## Background figures many of whom may stand about (not one character).
const GENERIC: Array[String] = ["NPC-CITIZEN"]


func _ids_after(def: ZoneDef) -> Array[String]:
	var ids: Array[String] = _ids_before(def)
	for entry: Dictionary in ZoneScene.freed_npcs_to_build(def):
		var npc_id: String = str(entry.get("npc_id", ""))
		if not npc_id.is_empty():
			ids.append(npc_id)
	return ids


func _dupes(ids: Array[String]) -> Array[String]:
	var seen: Dictionary = {}
	var dupes: Array[String] = []
	for id: String in ids:
		if seen.has(id) and not dupes.has(id):
			dupes.append(id)
		seen[id] = true
	return dupes


func test_no_character_stands_twice_in_any_zone_state() -> void:
	var checked: int = 0
	for zone_id: String in ZoneDefs.all_ids():
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		if def == null:
			continue
		checked += 1
		assert_eq(_dupes(_ids_before(def)), [] as Array[String], "%s before it is freed" % zone_id)
		var after: Array[String] = _ids_after(def)
		assert_eq(_dupes(after), [] as Array[String], "%s after it is freed" % zone_id)
		assert_false(after.has(OldHob.NPC_ID), "%s: Old Hob is only his cameo" % zone_id)
	assert_gt(checked, 4, "every zone checked")


func test_the_dna_has_one_agnes_after_it_is_freed() -> void:
	var def: ZoneDef = ZoneDefs.get_def("necrocrat")
	var agnes: int = _ids_after(def).count("NPC-AGNES")
	assert_eq(agnes, 1, "one Agnes Overdue in the freed D.N.A.")
