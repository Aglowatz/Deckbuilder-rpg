class_name MainDungeons
extends RefCounted
## The dungeons built from the designer's list (`DungeonCatalog`), keyed by a "dungeon key": the zone id for a zone's final dungeon ("beefcake" =
## the House of Gains) and the dungeon ID for a side dungeon ("S-BEEF"). Each is a `MainDungeonDef` (the static data: foes, events, challenges,
## rewards) plus a map built fresh for every run. Beating a main dungeon's boss completes the zone (`Session.resolve_main_dungeon`); a side dungeon
## pays its unique card once and small gold plus a pack on repeats (`Session.resolve_mini_dungeon`).

static var _defs: Dictionary = {}


## The zones that have a final dungeon.
static func ids() -> Array[String]:
	return [TestKitchenDungeon.ZONE_ID, HouseOfGainsDungeon.ZONE_ID, HallOfApprovalsDungeon.ZONE_ID, RotheartDungeon.ZONE_ID, PrimmsCastleDungeon.ZONE_ID]


## The IDs of the six side dungeons.
static func side_ids() -> Array[String]:
	var result: Array[String] = []
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if blueprint.is_side():
			result.append(blueprint.id)
	return result


static func has_def(key: String) -> bool:
	return ids().has(key) or side_ids().has(key)


static func is_side(key: String) -> bool:
	return side_ids().has(key)


## The blueprint behind a dungeon key.
static func blueprint(key: String) -> DungeonCatalog.Blueprint:
	return DungeonCatalog.find(key) if is_side(key) else DungeonCatalog.main_for_zone(key)


static func def(key: String) -> MainDungeonDef:
	if not _defs.has(key):
		match key:
			TestKitchenDungeon.ZONE_ID:
				_defs[key] = TestKitchenDungeon.build_def()
			HouseOfGainsDungeon.ZONE_ID:
				_defs[key] = HouseOfGainsDungeon.build_def()
			HallOfApprovalsDungeon.ZONE_ID:
				_defs[key] = HallOfApprovalsDungeon.build_def()
			RotheartDungeon.ZONE_ID:
				_defs[key] = RotheartDungeon.build_def()
			PrimmsCastleDungeon.ZONE_ID:
				_defs[key] = PrimmsCastleDungeon.build_def()
			_:
				if not is_side(key):
					return null
				_defs[key] = DungeonBuilder.build_def(DungeonCatalog.find(key))
		_fill_challenge_text(_defs[key] as MainDungeonDef)
	return _defs[key] as MainDungeonDef


## The challenges' titles and descriptions come from the story (`challenge.<id>.title/.text`; the content file's text wins).
static func _fill_challenge_text(dungeon: MainDungeonDef) -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone(dungeon.zone_id)
	for challenge_id: Variant in dungeon.challenges.keys():
		var challenge: ChallengeData = dungeon.challenges[challenge_id] as ChallengeData
		challenge.display_name = story.text("challenge.%s.title" % str(challenge_id))
		challenge.description = story.text("challenge.%s.text" % str(challenge_id))


## A fresh map for a new run of the dungeon.
static func build_map(key: String) -> DungeonMap:
	var dungeon: MainDungeonDef = def(key)
	var plan: DungeonCatalog.Blueprint = blueprint(key)
	if dungeon == null or plan == null:
		return null
	return DungeonBuilder.build_map(plan, dungeon)


static func enemy_recipe(key: String, enemy_name: String) -> Dictionary:
	var fighter: MainDungeonDef.Foe = def(key).foe(enemy_name)
	return fighter.recipe if fighter != null else {}


static func enemy_setup(content: ContentSet, map_node: DungeonMap.MapNode, key: String) -> PlayerSetup:
	var deck: Deck = ZoneDecks.from_recipe(content, map_node.enemy_name, enemy_recipe(key, map_node.enemy_name))
	var setup: PlayerSetup = PlayerSetup.create(deck, null, [] as Array[ModifierSource], map_node.enemy_name)
	setup.starting_hp = map_node.enemy_hp
	setup.profile = PlayerProfile.new()
	setup.profile.max_hp = maxi(map_node.enemy_hp, PlayerProfile.START_MAX_HP)
	return setup


## The battle icon of a foe (a game-icons key) for the battle screen's portrait.
static func enemy_icon(key: String, enemy_name: String) -> String:
	var fighter: MainDungeonDef.Foe = def(key).foe(enemy_name)
	return fighter.icon if fighter != null else "lorc/imp"


## Forgets the built definitions (tests, and so edited data is read again).
static func reset() -> void:
	_defs = {}
