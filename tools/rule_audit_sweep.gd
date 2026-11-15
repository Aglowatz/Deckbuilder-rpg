class_name RuleAuditSweep
extends RefCounted
## Fable Nov 15 (Part 4): builds every fight of the game the way the game does (the Session's own makers) and asks `RuleAudit` which of
## the rules on its seats no shown badge covers. One row per fight: {"where", "foe", "badges": [names], "missing": [lines]}.
## Roamers of every zone (the Capital's also beside an open rift), every fight node of every dungeon (the four Path zones are entered as
## a first zone, so the early-zone ease is on; Primm's three phases), the gatekeepers, the town's roamers, the Graveyard, Shiro, the
## vault, the Old Well, the store room, the Arena and Quota's rematch. Needs the Session autoload: run from a GUT test
## (tests/test_rule_audit.gd), which also writes `_logs/rule_audit.json` for the report.

const PATH_ZONES: Array[String] = ["beefcake", "necrocrat", "gourmand", "refusemancer"]
const FIGHT_KINDS: Array[DungeonMap.Kind] = [DungeonMap.Kind.BATTLE, DungeonMap.Kind.ELITE, DungeonMap.Kind.BOSS]
const ZONE_ENEMIES: Dictionary = {
	"beefcake": GainlandsEnemies.IDS, "necrocrat": DnaEnemies.IDS, "gourmand": BuffetEnemies.IDS, "refusemancer": HeapEnemies.IDS,
	"final": CapitalEnemies.IDS,
}


static func _row(where: String, context: BattleContext) -> Dictionary:
	var names: Array[String] = []
	for badge: RuleBadges.Badge in context.rule_badges:
		names.append(badge.name)
	return {"where": where, "foe": context.enemy_name, "badges": names, "missing": RuleAudit.unshown(context)}


static func _fresh() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.main_dungeon_active = false
	Session.mini_active = false
	Session.town_side_active = false
	Session.zone_empower_next = false


static func _dungeon_rows(where: String, rows: Array[Dictionary]) -> void:
	for node: DungeonMap.MapNode in Session.dungeon_map.nodes:
		if not FIGHT_KINDS.has(node.kind):
			continue
		if node.kind == DungeonMap.Kind.BOSS and node.enemy_name == PrimmBoss.BOSS_FOE:
			for phase: int in range(3):
				Session.boss_phase = phase
				rows.append(_row("%s node %d phase %d" % [where, node.number, phase + 1], Session.make_dungeon_battle(node)))
			Session.boss_phase = 0
			continue
		rows.append(_row("%s node %d" % [where, node.number], Session.make_dungeon_battle(node)))


static func _enter_zone(zone_id: String) -> void:
	_fresh()
	Session.zone_run = ZoneRun.enter(zone_id, Session.profile, Session.deck)


static func _enter_dungeon(key: String, main: bool, extra_sources: Array[ModifierSource] = []) -> void:
	Session.dungeon_key = key
	Session.dungeon_map = MainDungeons.build_map(key)
	var sources: Array[ModifierSource] = []
	if Session.zone_run != null:
		sources.append_array(Session.zone_run.run.dungeon_sources)
	sources.append_array(extra_sources)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, sources)
	Session.main_dungeon_active = main
	Session.mini_active = not main
	Session.boss_phase = 0


static func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	# the zones: roamers, the main dungeon, the side dungeons
	for zone_id: String in ZONE_ENEMIES.keys():
		_enter_zone(zone_id)
		for enemy_id: String in ZONE_ENEMIES[zone_id] as Array[String]:
			var data: ZoneEnemyInfo = ZoneEnemies.info(zone_id, enemy_id)
			if data == null or data.kind != ZoneEnemyInfo.Kind.BATTLE:
				continue
			rows.append(_row("zone %s roamer %s" % [zone_id, enemy_id], Session.make_zone_battle(enemy_id, "audit")))
			if zone_id == CapitalZone.ID:
				Session.zone_empower_next = true
				rows.append(_row("zone %s roamer %s beside an open rift" % [zone_id, enemy_id], Session.make_zone_battle(enemy_id, "audit")))
		if zone_id == CapitalZone.ID:
			rows.append(_row("zone final: Captain Spotless at the gate", Session.make_zone_battle(CapitalEnemies.SPOTLESS, CapitalEnemies.SPOTLESS)))
			rows.append(_row("zone final: Quota's rematch", Session.make_quota_yards_battle()))
		if MainDungeons.has_def(zone_id):
			_enter_dungeon(zone_id, true)
			_dungeon_rows("%s main dungeon" % zone_id, rows)
		for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
			if plan.zone_id != zone_id or plan.id == zone_id or not MainDungeons.has_def(plan.id) or (MainDungeons.blueprint(zone_id) != null and MainDungeons.blueprint(zone_id).id == plan.id):
				continue
			var extra: Array[ModifierSource] = []
			if plan.id == ShatteredGallery.DUNGEON_ID:
				extra.append(ShatteredGallery.silver_reserve())
			_enter_dungeon(plan.id, false, extra)
			_dungeon_rows("%s (%s)" % [plan.id, zone_id], rows)
		Session.main_dungeon_active = false
		Session.mini_active = false
	# the dungeons outside the zones: the town's vault dungeon and the Lab (run like `enter_town_side_dungeon` / `enter_lab`)
	for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if ZONE_ENEMIES.has(plan.zone_id) or not MainDungeons.has_def(plan.id):
			continue
		_fresh()
		Session.zone_run = null
		var sources: Array[ModifierSource] = []
		if plan.id == PathologyLab.DUNGEON_ID and DungeonRules.player_source(plan.id) != null:
			sources.append(DungeonRules.player_source(plan.id))
		_enter_dungeon(plan.id, false, sources)
		Session.town_side_active = true
		_dungeon_rows("%s (%s)" % [plan.id, plan.zone_id], rows)
	# the tutorial cave
	_fresh()
	Session.zone_run = null
	Session.dungeon_key = ""
	Session.dungeon_map = TrialOfTheHollow.build_map()
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	_dungeon_rows("the Forgotten Cave", rows)
	# Crosspath's own fights
	_fresh()
	Session.zone_run = null
	for enemy_id: String in TownEnemies.IDS:
		rows.append(_row("town roamer %s" % enemy_id, Session.make_town_battle(enemy_id, "audit")))
	for gate_id: String in Gatekeepers.IDS:
		rows.append(_row("gatekeeper %s" % gate_id, Session.make_npc_challenge_battle(gate_id)))
	rows.append(_row("town: the Graveyard", Session.make_graveyard_battle()))
	rows.append(_row("town: Shiro", Session.make_ninja_battle()))
	rows.append(_row("town: the vault", Session.make_vault_battle()))
	rows.append(_row("town: the Old Well", Session.make_old_well_battle()))
	rows.append(_row("town: the store room", Session.make_storeroom_battle()))
	for encounter: ArenaEncounter in ArenaDefs.all():
		rows.append(_row("arena %s" % encounter.id, Session.make_arena_battle(encounter.id)))
	_fresh()
	return rows
