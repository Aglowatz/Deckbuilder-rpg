extends GutTest
## Overnight Oct 30-31, Part 3: the sprint (Shift / a controller's left-stick click / Settings > Always sprint; never on a mount) and fast
## travel from the map (a freed zone's station counts as reached; only reached stations; never a dungeon).

var _always: bool = false


func before_each() -> void:
	_always = Settings.always_sprint


func after_each() -> void:
	Settings.always_sprint = _always


func test_always_sprint_sprints_on_foot_only() -> void:
	var hero: TownPlayer = TownPlayer.new()
	autofree(hero)
	Settings.always_sprint = false
	assert_false(hero.wants_sprint(), "walking by default")
	Settings.always_sprint = true
	assert_true(hero.wants_sprint(), "Always sprint")
	hero.speed_multiplier = 1.8
	assert_false(hero.wants_sprint(), "a mount is faster already")
	hero.speed_multiplier = 1.0
	hero.airborne = true
	assert_false(hero.wants_sprint(), "not while thrown or falling")


func test_sprint_is_a_bindable_overworld_action() -> void:
	assert_true(Keybinds.action_ids().has(&"sprint"))
	assert_eq(Keybinds.group_of(&"sprint"), Keybinds.GROUP_OVERWORLD)
	assert_true(InputMap.has_action(&"sprint"))
	assert_gt(TownPlayer.SPRINT, 1.3, "clearly faster")
	assert_lt(TownPlayer.SPRINT, 2.0, "not a teleport: encounters still get their look")


func test_a_freed_zone_counts_as_a_reached_station() -> void:
	var flags: Dictionary = {}
	assert_false(FastTravel.is_unlocked(flags, "gourmand"))
	flags[str(ZoneCompletion.flag_name("gourmand"))] = true
	assert_true(FastTravel.is_unlocked(flags, "gourmand"), "freed = visited")
	assert_true(FastTravel.destinations(flags, FastTravel.TOWN).has("gourmand"))
	assert_false(FastTravel.is_unlocked(flags, CapitalZone.ID), "the Capital still needs its station reached")


func test_no_station_is_a_dungeon() -> void:
	for station_id: String in FastTravel.station_ids():
		assert_false(station_id.begins_with("D-") or station_id.begins_with("S-"), "%s is not a dungeon" % station_id)
		assert_true(station_id == FastTravel.TOWN or station_id == FastTravel.FOREST or ZoneDefs.has_def(station_id), "%s is a hub or a zone town" % station_id)
