class_name HeapGrowth
extends RefCounted
## The things a Refusemancer can grow in the Verdant Heap: two kinds of crossing - VINE BRIDGES across the recycling
## stream and BEANSTALK LADDERS up the junk mountains - and how each is grown: by a DRUID NPC once a condition is
## met (the centre bridge: Druid Sorrel wants the herd rounded up), or by planting a MAGIC BEAN at its sprout mound.
## Once grown it stays grown (a flag). Also the junk barricades (smashed by a charging mount) and a few counts.

const CROP_PLOTS: int = 3
const ESCAPED_ANIMALS: int = 3
## Seconds a planted crop needs before it can be harvested.
const CROP_SECONDS: float = 45.0


class Growth:
	extends RefCounted
	var id: String = ""
	## "bridge" or "ladder".
	var kind: String = ""
	## "druid" (an NPC grows it when `requirement` is met) or "bean" (plant a Magic Bean at its mound).
	var how: String = ""
	var title: String = ""
	var speaker: String = ""
	## Layout anchor of the growing spot (the druid or the sprout mound).
	var anchor: String = ""
	var flag: StringName = &""
	var requirement: Condition

	func key(suffix: String) -> String:
		return "grow.%s.%s" % [id, suffix]


class Barricade:
	extends RefCounted
	var id: String = ""
	var title: String = ""
	var anchor: String = ""
	var flag: StringName = &""


static func _growth(id: String, kind: String, how: String, title: String, speaker: String, anchor: String, requirement: Condition = null) -> Growth:
	var growth: Growth = Growth.new()
	growth.id = id
	growth.kind = kind
	growth.how = how
	growth.title = title
	growth.speaker = speaker
	growth.anchor = anchor
	growth.flag = StringName("heap_grown_" + id)
	growth.requirement = requirement
	return growth


static func all() -> Array[Growth]:
	return [
		_growth("bridge_center", "bridge", "druid", "Druid Sorrel's Vine Bridge", "Druid Sorrel", "sorrel", Condition.quest_completed(HeapZone.QUEST_HERD)),
		_growth("bridge_west", "bridge", "bean", "West Sprout Mound (vine bridge)", "the mound", "mound_west"),
		_growth("bridge_east", "bridge", "bean", "East Sprout Mound (vine bridge)", "the mound", "mound_east"),
		_growth("ladder_a", "ladder", "bean", "Mount Scrapmore Sprout Mound (beanstalk)", "the mound", "mound_a"),
		_growth("ladder_b", "ladder", "bean", "Rust Peak Sprout Mound (beanstalk)", "the mound", "mound_b"),
	] as Array[Growth]


static func find(id: String) -> Growth:
	for growth: Growth in all():
		if growth.id == id:
			return growth
	return null


static func _barricade(id: String, title: String, anchor: String) -> Barricade:
	var barricade: Barricade = Barricade.new()
	barricade.id = id
	barricade.title = title
	barricade.anchor = anchor
	barricade.flag = StringName("heap_smashed_" + id)
	return barricade


static func barricades() -> Array[Barricade]:
	return [
		_barricade("gate", "The Junk Barricade", "barricade_gate"),
		_barricade("dam", "The Junk Dam", "barricade_dam"),
	] as Array[Barricade]


static func find_barricade(id: String) -> Barricade:
	for barricade: Barricade in barricades():
		if barricade.id == id:
			return barricade
	return null


## True when a druid's requirement is met right now (bean growths never have one).
static func requirement_met(growth: Growth, state: UnlockState) -> bool:
	return Condition.met(growth.requirement, state)
