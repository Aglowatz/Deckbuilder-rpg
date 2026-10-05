class_name MainDungeons
extends RefCounted
## The four zones' final dungeons (Part E), keyed by zone id. Each is a `MainDungeonDef` (the static data:
## foes, events, challenges, rewards) plus a map built fresh for every run. Beating the boss completes
## the zone (`Session.complete_main_dungeon` -> `Session.complete_zone`).

static var _defs: Dictionary = {}


static func ids() -> Array[String]:
	return [TestKitchenDungeon.ZONE_ID, HouseOfGainsDungeon.ZONE_ID, HallOfApprovalsDungeon.ZONE_ID, RotheartDungeon.ZONE_ID, PrimmsCastleDungeon.ZONE_ID]


static func has_def(zone_id: String) -> bool:
	return ids().has(zone_id)


static func def(zone_id: String) -> MainDungeonDef:
	if not _defs.has(zone_id):
		match zone_id:
			TestKitchenDungeon.ZONE_ID:
				_defs[zone_id] = TestKitchenDungeon.build_def()
			HouseOfGainsDungeon.ZONE_ID:
				_defs[zone_id] = HouseOfGainsDungeon.build_def()
			HallOfApprovalsDungeon.ZONE_ID:
				_defs[zone_id] = HallOfApprovalsDungeon.build_def()
			RotheartDungeon.ZONE_ID:
				_defs[zone_id] = RotheartDungeon.build_def()
			PrimmsCastleDungeon.ZONE_ID:
				_defs[zone_id] = PrimmsCastleDungeon.build_def()
			_:
				return null
		_fill_challenge_text(_defs[zone_id] as MainDungeonDef)
	return _defs[zone_id] as MainDungeonDef


## The challenges' titles and descriptions come from the zone story file (`challenge.<id>.title/.text`).
static func _fill_challenge_text(dungeon: MainDungeonDef) -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone(dungeon.zone_id)
	for challenge_id: Variant in dungeon.challenges.keys():
		var challenge: ChallengeData = dungeon.challenges[challenge_id] as ChallengeData
		challenge.display_name = story.text("challenge.%s.title" % str(challenge_id))
		challenge.description = story.text("challenge.%s.text" % str(challenge_id))

## A fresh map for a new run of the zone's final dungeon.
static func build_map(zone_id: String) -> DungeonMap:
	var dungeon: MainDungeonDef = def(zone_id)
	match zone_id:
		TestKitchenDungeon.ZONE_ID:
			return TestKitchenDungeon.build_map(dungeon)
		HouseOfGainsDungeon.ZONE_ID:
			return HouseOfGainsDungeon.build_map(dungeon)
		HallOfApprovalsDungeon.ZONE_ID:
			return HallOfApprovalsDungeon.build_map(dungeon)
		RotheartDungeon.ZONE_ID:
			return RotheartDungeon.build_map(dungeon)
		PrimmsCastleDungeon.ZONE_ID:
			return PrimmsCastleDungeon.build_map(dungeon)
	return null


static func enemy_recipe(zone_id: String, enemy_name: String) -> Dictionary:
	var fighter: MainDungeonDef.Foe = def(zone_id).foe(enemy_name)
	return fighter.recipe if fighter != null else {}


static func enemy_setup(content: ContentSet, map_node: DungeonMap.MapNode, zone_id: String) -> PlayerSetup:
	var deck: Deck = ZoneDecks.from_recipe(content, map_node.enemy_name, enemy_recipe(zone_id, map_node.enemy_name))
	var setup: PlayerSetup = PlayerSetup.create(deck, null, [] as Array[ModifierSource], map_node.enemy_name)
	setup.starting_life = map_node.enemy_life
	setup.profile = PlayerProfile.new()
	setup.profile.max_life = maxi(map_node.enemy_life, PlayerProfile.START_MAX_LIFE)
	return setup


## The battle icon of a foe (a game-icons key) for the battle screen's portrait.
static func enemy_icon(zone_id: String, enemy_name: String) -> String:
	var fighter: MainDungeonDef.Foe = def(zone_id).foe(enemy_name)
	return fighter.icon if fighter != null else "lorc/imp"
