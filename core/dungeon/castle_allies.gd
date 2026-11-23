class_name CastleAllies
extends RefCounted
## Fable Nov 21 castle (Parts 3 and 4): the four zone leaders in Primm's Castle. Each freed zone's leader waits in an ALLY ROOM of the
## castle (the room numbers of the dungeon list, `ROOMS`). The room is a moderately hard fight with a twist (the foe's own rules and
## script in data/encounters); when the zone is freed, a short scene plays before and after it (`data/story/story_scenes.json`,
## `pc_ally_<zone>_before` / `_after`) and winning earns that leader's HELP AGAINST PRIMM for this run. When the zone is not freed, the
## room is the same fight with no leader, no scene and no help: it pays `FAIR_REWARD_GOLD` instead.
##
## The earned help is a marker boon on the run (`marker`: no modifiers, so the castle's other fights are untouched); the Model Room's
## three duels read the markers and add the real rules to the player's seat (`help_source`). This replaces the passive leader boons
## every freed leader used to lend at Primm's door (`PrimmBoss.leader_boon`, to Nov 21).
##
## The Gilded Pantry (room 2) is the Grand Chef's room and also the optional Pantry Mimic fight: whoever wins it takes a Gilded Pack
## and picks one strong boon for the last fight (`SPOILS_EVENT`), freed Buffet or not.

const DUNGEON_KEY: String = "final"
const ZONES: Array[String] = ["beefcake", "gourmand", "necrocrat", "refusemancer"]
## Room number (the dungeon list's D-PC rows) -> the zone whose leader waits there.
const ROOMS: Dictionary = {8: "beefcake", 2: "gourmand", 11: "necrocrat", 14: "refusemancer"}
const PANTRY_ROOM: int = 2
const SPOILS_EVENT: String = "pc_mimic_larder"
const SPOILS_PACK: String = "gilded_general"
## Fable Nov 22 night (the owner's answer to "the all-allies route has no heal"): the fourth row of that route is Agnes's room, so its
## "heal 6 for a cost" stop is in that room, after the fight: the archivists' kettle, with the Garden's rules (heal `REST_HEAL` for
## `REST_COST` gold, or for a drawback in the next fight, or walk on). Once per run, freed D.N.A. or not.
const REST_ROOM: int = 11
const REST_EVENT: String = "pc_archive_kettle"
const REST_HEAL: int = 6
const REST_COST: int = 60
## What an ally room pays when its zone is not freed (no leader, no help).
const FAIR_REWARD_GOLD: int = 120
## Grandmaster Flex walks in at the start of the player's second turn.
const FLEX_TURN: int = 2
const FLEX_TOKEN: String = "T-15"
const MARKER_PREFIX: String = "Ally: "

const LEADERS: Dictionary = {
	"beefcake": "Grandmaster Flex", "gourmand": "The Grand Chef", "necrocrat": "Agnes Overdue", "refusemancer": "Archdruid Compostella",
}
## The name of each help as a rule badge in Primm's fight.
const HELP_NAMES: Dictionary = {
	"beefcake": "Grandmaster Flex Stands With You", "gourmand": "The Grand Chef's Recipe", "necrocrat": "Agnes's Appeal", "refusemancer": "Compostella's Handful of Earth",
}
const HELP_ICONS: Dictionary = {
	"beefcake": "lorc/muscle-up", "gourmand": "delapouite/chef-toque", "necrocrat": "delapouite/stamper", "refusemancer": "lorc/sprout",
}
const ZONE_NAMES: Dictionary = {"beefcake": "the Gainlands", "gourmand": "the Endless Buffet", "necrocrat": "the D.N.A.", "refusemancer": "the Verdant Dump"}
## Grandmaster Flex as he fights beside you in the Model Room (tuned in Part 6; his House of Gains token T-15 is a 3/5).
const FLEX_ATTACK: int = 3
const FLEX_DEFENSE: int = 5
## The objective of each ally room, in one line (the map's tooltip).
const OBJECTIVES: Dictionary = {
	"beefcake": "Hold the line: keep a Captured Trainee alive until the Sergeant's 6th turn begins, or beat him outright.",
	"gourmand": "Win back the stolen recipe book from the Pantry Mimic.",
	"necrocrat": "Get the appeal through: beat Percival Plume before his 12th turn begins.",
	"refusemancer": "Clean out the polish: destroy the three Spotless Statues, or beat the Gardener outright.",
}


## The zone whose leader waits in room `number` of `dungeon_key` ("" for any other room or dungeon).
static func zone_of_room(dungeon_key: String, number: int) -> String:
	if dungeon_key != DUNGEON_KEY:
		return ""
	return str(ROOMS.get(number, ""))


static func room_of(zone_id: String) -> int:
	for number: Variant in ROOMS.keys():
		if str(ROOMS[number]) == zone_id:
			return int(number)
	return 0


## True when the leader is in the room: the zone is freed.
static func leader_present(flags: Dictionary, zone_id: String) -> bool:
	return ZONES.has(zone_id) and ZoneCompletion.is_completed(flags, zone_id)


## What the leader's help does in Primm's fight, in plain words.
static func help_text(zone_id: String) -> String:
	match zone_id:
		"beefcake":
			var flex: CardData = flex_token()
			var size: String = "%d/%d" % [flex.attack, flex.defense] if flex != null else "strong"
			return "Grandmaster Flex (%s) joins your side at the start of your turn %d, ready to fight." % [size, FLEX_TURN]
		"gourmand":
			return "You draw 1 extra card each turn."
		"necrocrat":
			return "Your non-unit cards cost 1 less generic energy."
		"refusemancer":
			return "All your units get +1/+1."
	return ""


## Flex's unit in Primm's fight: his own token and picture, at the castle's size.
static func flex_token() -> CardData:
	var base: CardData = TokenRegistry.data(FLEX_TOKEN)
	if base == null:
		return null
	var flex: CardData = base.duplicate() as CardData
	flex.attack = FLEX_ATTACK
	flex.defense = FLEX_DEFENSE
	flex.rules_text = "He walked here from the Gainlands to stand beside you."
	return flex


static func marker_name(zone_id: String) -> String:
	return MARKER_PREFIX + str(LEADERS.get(zone_id, zone_id))


## The marker boon a won ally room leaves on the run (no modifiers: the help only counts in the Model Room).
static func marker(zone_id: String) -> ModifierSource:
	return MainDungeonDef.boon_source(marker_name(zone_id), [] as Array[Modifier])


static func is_marker(source: ModifierSource) -> bool:
	return source != null and source.source_name.begins_with(MARKER_PREFIX) and zone_of_marker(source.source_name) != ""


static func zone_of_marker(source_name: String) -> String:
	for zone_id: String in ZONES:
		if marker_name(zone_id) == source_name:
			return zone_id
	return ""


## The line a marker shows in the run's boon list ("will help against Primm: ...").
static func marker_text(source_name: String) -> String:
	var zone_id: String = zone_of_marker(source_name)
	return "" if zone_id.is_empty() else "against Primm: %s" % help_text(zone_id).trim_suffix(".").to_lower().replace("grandmaster flex", "Grandmaster Flex")


## The zones whose leaders this run has won over, in the fixed order.
static func earned(run: DungeonRun) -> Array[String]:
	var result: Array[String] = []
	if run == null:
		return result
	for zone_id: String in ZONES:
		for source: ModifierSource in run.dungeon_sources:
			if source != null and source.source_name == marker_name(zone_id):
				result.append(zone_id)
				break
	return result


static func has_ally(run: DungeonRun, zone_id: String) -> bool:
	return earned(run).has(zone_id)


## The rules one leader's help adds to the player's seat in Primm's fight.
static func help_modifiers(zone_id: String) -> Array[Modifier]:
	var made: Array[Modifier] = []
	match zone_id:
		"beefcake":
			var flex: CardData = flex_token()
			if flex != null:
				var arriving: Modifier = CardBuilder.modifier(Modifier.Kind.ARRIVING_UNIT, FLEX_TURN)
				arriving.tokens = [flex] as Array[CardData]
				made.append(arriving)
		"gourmand":
			made.append(CardBuilder.modifier(Modifier.Kind.EXTRA_DRAWS, 1))
		"necrocrat":
			made.append(CardBuilder.modifier(Modifier.Kind.NON_UNIT_COST_CHANGE, -1))
		"refusemancer":
			made.append(CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 1))
	for modifier: Modifier in made:
		modifier.label = str(HELP_NAMES.get(zone_id, ""))
	return made


## Everything the given leaders add to the player's seat in Primm's fight, as one source (null when nobody helps).
static func help_source(zones: Array[String]) -> ModifierSource:
	var modifiers: Array[Modifier] = []
	for zone_id: String in zones:
		modifiers.append_array(help_modifiers(zone_id))
	if modifiers.is_empty():
		return null
	return CardBuilder.modifier_source("The leaders stand with you", ModifierSource.SourceKind.BOON, modifiers)


## `base` (the phase's own player rules, may be null) plus the help of the leaders this run has won over.
static func with_help(base: ModifierSource, run: DungeonRun) -> ModifierSource:
	var help: ModifierSource = help_source(earned(run))
	if help == null:
		return base
	if base == null:
		return help
	var merged: ModifierSource = ModifierSource.new()
	merged.source_name = "%s + %s" % [base.source_name, help.source_name]
	merged.source_kind = base.source_kind
	merged.modifiers = base.modifiers.duplicate()
	merged.modifiers.append_array(help.modifiers)
	return merged


## One badge per leader who helps in Primm's fight (green, on the player's side), covering that help's rules.
static func help_badges(run: DungeonRun) -> Array[RuleBadges.Badge]:
	var result: Array[RuleBadges.Badge] = []
	for zone_id: String in earned(run):
		var badge: RuleBadges.Badge = RuleBadges.special(str(HELP_NAMES[zone_id]), help_text(zone_id), str(HELP_ICONS[zone_id]), help_modifiers(zone_id), true)
		badge.kind = "ally"
		badge.side = RuleBadges.SIDE_PLAYER
		result.append(badge)
	return result


## A won ally room: with the leader present, the run gains their marker (once) and the zone id is returned; otherwise "" (the caller
## pays the fair reward).
static func win_room(run: DungeonRun, flags: Dictionary, dungeon_key: String, number: int) -> String:
	var zone_id: String = zone_of_room(dungeon_key, number)
	if zone_id.is_empty() or run == null or not leader_present(flags, zone_id):
		return ""
	if not has_ally(run, zone_id):
		run.add_dungeon_source(marker(zone_id))
	return zone_id


## The scene played when an ally room is entered / won ("" when the zone is not freed or the room is no ally room).
static func scene_before(flags: Dictionary, dungeon_key: String, number: int) -> String:
	return _scene(flags, dungeon_key, number, "before")


static func scene_after(flags: Dictionary, dungeon_key: String, number: int) -> String:
	return _scene(flags, dungeon_key, number, "after")


static func _scene(flags: Dictionary, dungeon_key: String, number: int, part: String) -> String:
	var zone_id: String = zone_of_room(dungeon_key, number)
	if zone_id.is_empty() or not leader_present(flags, zone_id):
		return ""
	var id: String = "pc_ally_%s_%s" % [zone_id, part]
	return id if StoryScenes.has(id) else ""


## The lines an ally room adds to its tooltip on the castle map: who waits there, the objective, and the help (earned or to be earned).
static func room_lines(flags: Dictionary, run: DungeonRun, dungeon_key: String, number: int) -> Array[String]:
	var lines: Array[String] = []
	var zone_id: String = zone_of_room(dungeon_key, number)
	if zone_id.is_empty():
		return lines
	var leader: String = str(LEADERS[zone_id])
	lines.append("Objective: %s" % str(OBJECTIVES[zone_id]))
	if number == REST_ROOM:
		lines.append(REST_LINE)
	if has_ally(run, zone_id):
		lines.append("%s will help against Primm: %s" % [leader, help_text(zone_id)])
	elif leader_present(flags, zone_id):
		lines.append("Ally room: %s is here. Win, and against Primm: %s" % [leader, help_text(zone_id)])
	else:
		lines.append("Nobody waits here: %s is not free yet. The same fight, for %d gold." % [str(ZONE_NAMES[zone_id]), FAIR_REWARD_GOLD])
	return lines


## The map tooltip's line for the room with the kettle.
const REST_LINE: String = "After the fight: the archivists' kettle (heal 6 for 60 gold or for a drawback)."


## The summary line of Primm's door ("3 of 4 leaders stand with you: ...").
static func door_lines(run: DungeonRun) -> Array[String]:
	var zones: Array[String] = earned(run)
	if zones.is_empty():
		return ["Nobody stands beside you. You found no leader in the castle's four wings, so you step into the chamber alone.", "(Free a zone, then win its leader's room in the castle, and that leader will stand with you here.)"]
	var lines: Array[String] = []
	for zone_id: String in zones:
		lines.append("%s is with you. (%s)" % [str(LEADERS[zone_id]), help_text(zone_id)])
	return lines
