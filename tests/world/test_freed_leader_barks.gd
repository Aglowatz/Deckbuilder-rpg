extends GutTest
## Overnight Oct 17 (Phase 2 cycle 16): every freed leader standing in a zone (and Captain Spotless at the Capital gate) has passing lines.


func test_every_freed_leader_and_listed_npc_has_lines() -> void:
	for zone_id: String in ZoneDefs.all_ids():
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		if def == null:
			continue
		for entry: Dictionary in def.freed_npcs:
			var npc_id: String = str(entry.get("npc_id", ""))
			if npc_id.is_empty():
				continue
			assert_gte(NpcRegistry.barks(npc_id).size(), 2, "%s (%s, freed) has lines" % [npc_id, zone_id])
	assert_gte(NpcRegistry.barks("NPC-SPOTLESS").size(), 2, "Captain Spotless has lines")
