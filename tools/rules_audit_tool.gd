extends RefCounted
## Overnight Nov 4-5, Part 1.7: writes every fight's pre-fight rule list (the badges the brief shows: zone, dungeon, encounter, scripted) to
## _logs/rules_audit.json, one entry per dungeon fight node and per zone roamer, so tools/rules_audit.js can look for duplicates, near-twins and
## contradictions. Pure data, no scene.


func run(_tree: SceneTree) -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	var out: Array = []
	for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if not MainDungeons.has_def(plan.id) and not MainDungeons.has_def(plan.zone_id):
			continue
		var map: DungeonMap = MainDungeons.build_map(plan.id if MainDungeons.has_def(plan.id) else plan.zone_id)
		for node: DungeonMap.MapNode in map.nodes:
			if not node.kind in [DungeonMap.Kind.BATTLE, DungeonMap.Kind.ELITE, DungeonMap.Kind.BOSS]:
				continue
			var keys: Array[String] = [node.enemy_name]
			if node.kind == DungeonMap.Kind.BOSS and node.enemy_name == PrimmBoss.BOSS_FOE:
				keys = [PrimmBoss.rules_key(0), PrimmBoss.rules_key(1), PrimmBoss.rules_key(2)]
			for key: String in keys:
				var rule_key: String = plan.id if not DungeonRules.rules(plan.id).is_empty() else plan.zone_id
				var badges: Array[RuleBadges.Badge] = RuleBadges.for_run(plan.zone_id, rule_key, [] as Array[ModifierSource], node.number)
				badges.append_array(RuleBadges.for_encounter(EncounterModifiers.rules(key)))
				out.append({"where": "%s node %d" % [plan.id, node.number], "foe": key, "badges": _rows(badges)})
	for zone_id: String in ZoneDefs.ids():
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		for spawn: Variant in def.enemy_ids() if def.has_method("enemy_ids") else []:
			var key: String = EncounterModifiers.zone_key(zone_id, str(spawn))
			var badges: Array[RuleBadges.Badge] = RuleBadges.for_zone(zone_id)
			badges.append_array(RuleBadges.for_encounter(EncounterModifiers.rules(key)))
			out.append({"where": "zone %s" % zone_id, "foe": key, "badges": _rows(badges)})
	var file: FileAccess = FileAccess.open("res://_logs/rules_audit.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(out, "\t"))
	file.close()
	print("rules audit: %d fights" % out.size())


func _rows(badges: Array[RuleBadges.Badge]) -> Array:
	var rows: Array = []
	for badge: RuleBadges.Badge in badges:
		rows.append({"kind": badge.kind, "name": badge.name, "text": badge.text, "side": badge.side, "hidden": badge.hidden})
	return rows
