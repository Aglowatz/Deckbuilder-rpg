class_name MiniDungeon
extends RefCounted
## A zone's side dungeon (S-BEEF Mount Swolympus, S-NECRO the Waiting Room of Eternity, S-GOUR Omakase, S-REF the Trash Panda Throne, S-CAP the Old Service
## Tunnels; the town's S-TOWN Forgotten Vault is run from the town): three battles in a row on the node-map system, then a unique card (one time only),
## and small gold plus a pack on repeat clears. Everything comes from the dungeon list (`DungeonCatalog` / `DungeonBuilder`). A zone's side dungeon follows the zone's
## HP rules: the run starts at the zone's current HP, nothing heals between fights, the HP left goes back to the zone, losing wakes you at the hub (fee).

const BATTLE_COUNT: int = 3
## The D.N.A.'s reward (kept for the existing tests/docs); the others are read from the dungeon list (`ZoneDef.mini.reward_card_id`).
const REWARD_CARD_ID: String = "N-30"
const DUNGEON_NAME: String = "The Waiting Room of Eternity"


## The `MiniDef` (name, reward, the three battles) of a zone's side dungeon.
static func def_for(zone_id: String) -> ZoneDef.MiniDef:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.side_for_zone(zone_id)
	var mini: ZoneDef.MiniDef = ZoneDef.MiniDef.new()
	if plan == null:
		return mini
	var built: MainDungeonDef = DungeonBuilder.build_def(plan)
	mini.dungeon_id = plan.id
	mini.dungeon_name = plan.dungeon_name
	mini.start_title = "Entrance"
	mini.start_blurb = plan.theme
	mini.reward_card_id = plan.reward_card_id()
	for node: DungeonCatalog.BlueprintNode in plan.nodes:
		if not DungeonMap.is_battle_kind(DungeonBuilder.kind_of(node.type)):
			continue
		var fighter: MainDungeonDef.Foe = built.foe(DungeonBuilder.foe_name_of(plan, node))
		var battle: ZoneDef.MiniBattle = ZoneDef.MiniBattle.new()
		battle.title = node.node_name
		battle.blurb = "%s stands in the way." % fighter.enemy_name
		battle.enemy = fighter.enemy_name
		battle.hp = fighter.hp
		battle.ai_name = fighter.ai_name
		battle.elite = node.type == "boss"
		battle.recipe = fighter.recipe
		mini.battles.append(battle)
	return mini


static func build_map(zone_id: String = DnaZone.ID) -> DungeonMap:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.side_for_zone(zone_id)
	return MainDungeons.build_map(plan.id) if plan != null else DungeonMap.new()


static func enemy_recipe(enemy_name: String, zone_id: String = DnaZone.ID) -> Dictionary:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.side_for_zone(zone_id)
	return MainDungeons.enemy_recipe(plan.id, enemy_name) if plan != null else {}


static func enemy_setup(content: ContentSet, map_node: DungeonMap.MapNode, zone_id: String = DnaZone.ID) -> PlayerSetup:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.side_for_zone(zone_id)
	return MainDungeons.enemy_setup(content, map_node, plan.id)
