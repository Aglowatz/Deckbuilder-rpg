class_name EncounterCatalog
extends RefCounted
## Rebalance Part B: every fight in the game as `EncounterSpec`s, read from the game's own definitions (the tutorial map, the
## corrupted NPCs and town bosses, the zones' roamers and gate fights, every dungeon node including Primm's three phases, the
## arena battles). The balance simulation plays this list; nothing here is a copy of a number that lives elsewhere.

const ZONE_ROAMERS: Dictionary = {
	"beefcake": ["brute", "golem"],
	"necrocrat": ["manager", "intern"],
	"gourmand": ["loaf", "jelly", "casserole"],
	"refusemancer": ["golem", "scarecrow"],
	"final": ["officer", "inspector", "wretch", "spotless"],
}
const ZONE_ELITES: Array[String] = ["casserole", "spotless"]


static func all(content: ContentSet) -> Array[EncounterSpec]:
	var result: Array[EncounterSpec] = []
	result.append_array(tutorial())
	result.append_array(town(content))
	result.append_array(zones())
	result.append_array(dungeons())
	result.append_array(arena())
	return result


static func find(content: ContentSet, id: String) -> EncounterSpec:
	for spec: EncounterSpec in all(content):
		if spec.id == id:
			return spec
	return null


## The specs whose id or group contains `filter` (empty = all).
static func filtered(content: ContentSet, filter: String) -> Array[EncounterSpec]:
	var result: Array[EncounterSpec] = []
	for spec: EncounterSpec in all(content):
		if filter.is_empty() or spec.id.contains(filter) or spec.group.contains(filter) or spec.sequence == filter:
			result.append(spec)
	return result


# ---- The tutorial ------------------------------------------------------------------------------------------------------------


static func tutorial() -> Array[EncounterSpec]:
	var result: Array[EncounterSpec] = []
	var map: DungeonMap = TrialOfTheHollow.build_map()
	for node: DungeonMap.MapNode in map.nodes:
		if not DungeonMap.is_battle_kind(node.kind):
			continue
		var spec: EncounterSpec = EncounterSpec.new()
		spec.id = "tutorial:%d" % node.number
		spec.title = "%s (%s)" % [node.title, node.enemy_name]
		spec.group = "tutorial"
		spec.kind = EncounterSpec.Kind.TUTORIAL
		spec.expected_level = ProgressionModel.level_for("tutorial")
		spec.enemy_name = node.enemy_name
		spec.enemy_hp = node.enemy_hp
		spec.enemy_ai_name = node.ai_name
		spec.enemy_recipe = TrialOfTheHollow.enemy_recipe(node.enemy_name)
		spec.first_player = 0 if node.tutorial else -1
		spec.sequence = "tutorial"
		_attach_rules(spec, node.enemy_name)
		result.append(spec)
	return result


# ---- Town: the corrupted NPCs and the three scripted bosses ----------------------------------------------------------------------


static func town(content: ContentSet) -> Array[EncounterSpec]:
	var result: Array[EncounterSpec] = []
	# Playtest v0.4.0 Part D: the three Crosspath outskirts roamers, fought by a level-1 starter straight out of the cave.
	for roamer_id: String in TownEnemies.IDS:
		var roamer: ZoneEnemyInfo = TownEnemies.info(roamer_id)
		var roamer_spec: EncounterSpec = EncounterSpec.new()
		roamer_spec.id = "town:roamer:%s" % roamer_id
		roamer_spec.title = roamer.display_name
		roamer_spec.group = "town:roamer"
		roamer_spec.kind = EncounterSpec.Kind.NORMAL
		roamer_spec.expected_level = ProgressionModel.level_for("town:roamer")
		roamer_spec.enemy_name = roamer.display_name
		roamer_spec.enemy_hp = roamer.hp
		roamer_spec.enemy_ai_name = roamer.ai_name
		roamer_spec.enemy_recipe = roamer.recipe
		roamer_spec.notes = "outskirts roamer: a level-1 starter should win 85%+"
		_attach_rules(roamer_spec, EncounterModifiers.zone_key(TownEnemies.ZONE_KEY, roamer_id))
		result.append(roamer_spec)
	for npc_id: String in CorruptedNpcs.IDS:
		var spec: EncounterSpec = EncounterSpec.new()
		spec.id = "town:npc:%s" % npc_id
		spec.title = CorruptedNpcs.display_name(npc_id)
		spec.group = "town"
		spec.kind = EncounterSpec.Kind.ELITE
		spec.expected_level = ProgressionModel.level_for("town:npc")
		spec.enemy_name = CorruptedNpcs.display_name(npc_id)
		spec.enemy_hp = int(CorruptedNpcs.HP_BY_ID.get(npc_id, CorruptedNpcs.STARTING_HP))  # Overnight Oct 18: was STARTING_HP for all four (the game uses HP_BY_ID)
		spec.enemy_ai_name = str(CorruptedNpcs.AI_NAMES.get(npc_id, "Balanced"))
		spec.enemy_recipe = CorruptedNpcs.recipe(npc_id)
		_attach_rules(spec, spec.id)
		result.append(spec)
	var graveyard: EncounterSpec = EncounterSpec.new()
	graveyard.id = "town:graveyard"
	graveyard.title = GraveyardBoss.DISPLAY_NAME
	graveyard.group = "town"
	graveyard.kind = EncounterSpec.Kind.BOSS
	graveyard.expected_level = ProgressionModel.level_for("town:graveyard")
	graveyard.enemy_name = GraveyardBoss.DISPLAY_NAME
	graveyard.enemy_hp = GraveyardBoss.STARTING_HP
	graveyard.enemy_ai_name = GraveyardBoss.AI_NAME
	graveyard.enemy_builder = GraveyardBoss.enemy_setup
	graveyard.notes = "scripted escalating summons"
	result.append(graveyard)
	var ninja: EncounterSpec = EncounterSpec.new()
	ninja.id = "town:ninja"
	ninja.title = NinjaBoss.DISPLAY_NAME
	ninja.group = "town"
	ninja.kind = EncounterSpec.Kind.BOSS
	ninja.expected_level = ProgressionModel.level_for("town:ninja")
	ninja.enemy_name = NinjaBoss.DISPLAY_NAME
	ninja.enemy_hp = NinjaBoss.STARTING_HP
	ninja.enemy_ai_name = NinjaBoss.AI_NAME
	ninja.enemy_builder = NinjaBoss.enemy_setup
	_attach_rules(ninja, NinjaBoss.RULES_KEY)  # Daytime Oct 19: Shiro's rules were never read (his stat rules "did not move" him)
	result.append(ninja)
	var vault: EncounterSpec = EncounterSpec.new()
	vault.id = "town:vault"
	vault.title = VaultGuardian.DISPLAY_NAME
	vault.group = "town"
	vault.kind = EncounterSpec.Kind.BOSS
	vault.expected_level = ProgressionModel.level_for("town:vault")
	vault.enemy_name = VaultGuardian.DISPLAY_NAME
	vault.enemy_hp = VaultGuardian.STARTING_HP
	vault.enemy_ai_name = VaultGuardian.AI_NAME
	vault.enemy_builder = VaultGuardian.enemy_setup
	vault.notes = "scripted escalating summons; postgame-grade"
	result.append(vault)
	# Overnight Oct 19-20, Part 6: the Old Well secret quest's duel (its own group, so the town group keeps its seven fights).
	var echo: EncounterSpec = EncounterSpec.new()
	echo.id = OldWellQuest.SIM_ID
	echo.title = OldWellQuest.DISPLAY_NAME
	echo.group = OldWellQuest.SIM_GROUP
	echo.kind = EncounterSpec.Kind.BOSS
	echo.expected_level = ProgressionModel.level_for(OldWellQuest.SIM_ID, OldWellQuest.EXPECTED_LEVEL)
	echo.enemy_name = OldWellQuest.DISPLAY_NAME
	echo.enemy_hp = OldWellQuest.STARTING_HP
	echo.enemy_ai_name = OldWellQuest.AI_NAME
	echo.enemy_builder = OldWellQuest.enemy_setup
	_attach_rules(echo, OldWellQuest.RULES_KEY)
	echo.notes = "secret quest boss: heals 2 a turn, starts with one of each Path's resource"
	result.append(echo)
	return result


# ---- The zones' roamers and gate fights ---------------------------------------------------------------------------------------


static func zones() -> Array[EncounterSpec]:
	var result: Array[EncounterSpec] = []
	for zone_id: String in ProgressionModel.ZONE_ORDER:
		for enemy_id: String in ZONE_ROAMERS.get(zone_id, []) as Array:
			var info: ZoneEnemyInfo = ZoneEnemies.info(zone_id, enemy_id)
			if info.kind != ZoneEnemyInfo.Kind.BATTLE:
				continue
			var spec: EncounterSpec = EncounterSpec.new()
			spec.id = "zone:%s:%s" % [zone_id, enemy_id]
			spec.title = info.display_name
			spec.group = "zone:%s" % zone_id
			spec.kind = EncounterSpec.Kind.ELITE if ZONE_ELITES.has(enemy_id) else EncounterSpec.Kind.NORMAL
			spec.expected_level = ProgressionModel.level_for("zone:%s" % zone_id)
			spec.zone_id = zone_id
			spec.enemy_name = info.display_name
			spec.enemy_hp = info.hp
			spec.enemy_ai_name = info.ai_name
			spec.enemy_recipe = info.recipe
			if not ZONE_ELITES.has(enemy_id):
				spec.sequence = "zone:%s" % zone_id
			_attach_rules(spec, EncounterModifiers.zone_key(zone_id, enemy_id))
			result.append(spec)
	return result


# ---- Every dungeon node (main, side, postgame), Primm as three phases ---------------------------------------------------------


static func dungeons() -> Array[EncounterSpec]:
	var result: Array[EncounterSpec] = []
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if blueprint.id == DungeonCatalog.TUTORIAL_ID:
			continue
		var key: String = blueprint.id if (blueprint.is_side() or blueprint.is_postgame()) else blueprint.zone_id
		if not MainDungeons.has_def(key):
			continue
		var def: MainDungeonDef = MainDungeons.def(key)
		var map: DungeonMap = MainDungeons.build_map(key)
		if def == null or map == null:
			continue
		var base_level: int = ProgressionModel.level_for(blueprint.id, ProgressionModel.level_for("zone:%s" % blueprint.zone_id, 10) + 2)
		var group: String = ("postgame:%s" if blueprint.is_postgame() else ("side:%s" if blueprint.is_side() else "dungeon:%s")) % blueprint.id
		for node: DungeonMap.MapNode in map.nodes:
			if not DungeonMap.is_battle_kind(node.kind):
				continue
			if node.enemy_name == PrimmBoss.BOSS_FOE:
				result.append_array(_primm(blueprint, key, node, base_level))
				continue
			var fighter: MainDungeonDef.Foe = def.foe(node.enemy_name)
			if fighter == null:
				continue
			var spec: EncounterSpec = EncounterSpec.new()
			spec.id = "%s:%d" % [blueprint.id, node.number]
			spec.title = "%s - %s" % [node.title, node.enemy_name]
			spec.group = group
			spec.kind = _kind_of(node.kind)
			spec.expected_level = base_level + (2 if spec.kind == EncounterSpec.Kind.BOSS else (1 if spec.kind == EncounterSpec.Kind.ELITE else 0))
			spec.zone_id = blueprint.zone_id if ZoneEffects.has_effect(blueprint.zone_id) else ""
			spec.dungeon_key = key
			spec.node_number = node.number
			spec.enemy_name = node.enemy_name
			spec.enemy_hp = fighter.hp
			spec.enemy_ai_name = fighter.ai_name
			spec.enemy_recipe = fighter.recipe
			if blueprint.is_side():
				spec.sequence = "side:%s" % blueprint.id
			_attach_rules(spec, node.enemy_name)
			result.append(spec)
	return result


static func _primm(blueprint: DungeonCatalog.Blueprint, key: String, node: DungeonMap.MapNode, base_level: int) -> Array[EncounterSpec]:
	var result: Array[EncounterSpec] = []
	for index: int in range(PrimmBoss.PHASES):
		var phase: PrimmBoss.Phase = PrimmBoss.phase(index)
		var spec: EncounterSpec = EncounterSpec.new()
		spec.id = "%s:%d:phase%d" % [blueprint.id, node.number, index + 1]
		spec.title = "Primm - phase %d (%s)" % [index + 1, phase.key]
		spec.group = "dungeon:%s" % blueprint.id
		spec.kind = EncounterSpec.Kind.BOSS
		spec.expected_level = base_level + 2
		spec.dungeon_key = key
		spec.node_number = node.number
		spec.enemy_name = "Primm (%s)" % phase.key
		spec.enemy_hp = phase.hp
		spec.enemy_ai_name = phase.ai_name
		spec.enemy_recipe = phase.recipe
		spec.mirror_player_deck = phase.mirror
		if not phase.enemy_modifiers.is_empty():
			spec.enemy_sources.append(CardBuilder.modifier_source("Primm: %s" % phase.key, ModifierSource.SourceKind.ZONE, phase.enemy_modifiers))
		var rules: ModifierSource = PrimmBoss.player_rules(index)
		if rules != null:
			spec.player_sources.append(rules)
		_attach_rules(spec, PrimmBoss.rules_key(index))
		# Daytime Oct 19: the four freed leaders stand beside you (the story frees every zone before the castle; `Session.begin_primm_fight`).
		for zone_id: String in PrimmBoss.LEADERS.keys():
			var boon: ModifierSource = PrimmBoss.leader_boon(zone_id)
			if boon != null:
				spec.player_sources.append(boon)
		spec.sequence = "boss:primm"
		result.append(spec)
	return result


static func _kind_of(kind: DungeonMap.Kind) -> EncounterSpec.Kind:
	match kind:
		DungeonMap.Kind.ELITE:
			return EncounterSpec.Kind.ELITE
		DungeonMap.Kind.BOSS:
			return EncounterSpec.Kind.BOSS
	return EncounterSpec.Kind.NORMAL


# ---- The arena's battles (puzzles are hand-made boards, not balance) ----------------------------------------------------------


static func arena() -> Array[EncounterSpec]:
	var result: Array[EncounterSpec] = []
	for encounter: ArenaEncounter in ArenaDefs.all():
		if encounter.is_puzzle():
			continue
		var spec: EncounterSpec = EncounterSpec.new()
		spec.id = "arena:%s" % encounter.id
		spec.title = "Arena tier %d - %s" % [encounter.tier, encounter.enemy_name]
		spec.group = "arena"
		spec.kind = EncounterSpec.Kind.BOSS if encounter.tier >= 3 else (EncounterSpec.Kind.ELITE if encounter.tier == 2 else EncounterSpec.Kind.NORMAL)
		spec.expected_level = ProgressionModel.level_for("arena:%d" % encounter.tier)
		spec.enemy_name = encounter.enemy_name
		spec.enemy_hp = encounter.enemy_hp
		spec.enemy_ai_name = encounter.enemy_ai
		spec.enemy_recipe = encounter.enemy_recipe
		spec.player_recipe = encounter.player_recipe
		spec.player_hp = encounter.player_hp
		spec.first_player = encounter.first_player if encounter.is_puzzle() else -1
		if not encounter.player_rules.is_empty():
			spec.player_sources.append(CardBuilder.modifier_source("Arena rules", ModifierSource.SourceKind.DUNGEON, encounter.player_rules.duplicate()))
		_attach_rules(spec, spec.id)
		result.append(spec)
	return result


## The one-sided encounter rules of `key` (data/encounters/modifiers.json) on the spec's seats - the same data the game applies.
static func _attach_rules(spec: EncounterSpec, key: String) -> void:
	var enemy_side: ModifierSource = EncounterModifiers.enemy_source(key)
	if enemy_side != null:
		spec.enemy_sources.append(enemy_side)
	var player_side: ModifierSource = EncounterModifiers.player_source(key)
	if player_side != null:
		spec.player_sources.append(player_side)
