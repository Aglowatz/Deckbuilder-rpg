class_name CutsceneDefs
extends RefCounted
## The short story scenes of the zone dungeons (Part E): the Test Kitchen's REVEAL (the leader is a
## doppelganger), the House of Gains' RESCUE (the emaciated leader joins you) and FLEX (he throws off his
## outer clothes: still incredibly muscular - true strength comes from the heart and the mind), and the
## Rotheart's SEVER (the Archdruid cut free). Each scene is a list of beats; the text of beat N is the story
## key `cutscene.<id>.<N>` with its speaker in `cutscene.<id>.<N>.speaker`. `fx` names a visual effect the
## `CutsceneScreen` plays on that beat.

const SCENES: Dictionary = {
	"reveal": {"zone": "gourmand", "beats": [[1, ""], [2, ""], [3, "shake"], [4, "mask_off"], [5, "reveal_form"]]},
	"rescue": {"zone": "beefcake", "beats": [[1, ""], [2, ""], [3, "stand_up"]]},
	"flex": {"zone": "beefcake", "beats": [[1, ""], [2, "coat_off"], [3, "muscle_reveal"], [4, "stagger"], [5, ""]]},
	"sever": {"zone": "refusemancer", "beats": [[1, "shake"], [2, ""], [3, "roots_retract"], [4, "cleansed"]]},
	# Story v2 Part F: the true chef's dish breaks the enchantment and she gives her name away; Agnes takes the vacant office.
	"wonder": {"zone": "gourmand", "beats": [[1, ""], [2, ""], [3, ""], [4, "cleansed"], [5, "shake"], [6, ""], [7, ""]]},
	"vacancy": {"zone": "necrocrat", "beats": [[1, ""], [2, ""], [3, ""], [4, "crown"], [5, ""], [6, ""]]},
	# Brief 10: Primm, before the fight, between its phases and after it (text in the Capital's story file).
	"primm_intro": {"zone": "final", "beats": [[1, ""], [2, "crown"], [3, ""], [4, ""], [5, "shake"], [6, ""]]},
	# Story v2: played before the fight when the Wanderer has not freed all four zones: Primm tells him who he is.
	"primm_reveal": {"zone": "final", "beats": [[1, ""], [2, ""], [3, "shake"], [4, ""], [5, "crown"]]},
	"primm_p1": {"zone": "final", "beats": [[1, "crack"], [2, ""], [3, ""], [4, "shake"]]},
	"primm_p2": {"zone": "final", "beats": [[1, "mirror"], [2, ""], [3, ""], [4, "unravel"], [5, ""]]},
	"primm_end": {"zone": "final", "beats": [[1, "crack"], [2, "crown_off"], [3, ""], [4, ""], [5, "shrink"], [6, ""], [7, ""], [8, "dove"]]},
}


static func has_scene(scene_id: String) -> bool:
	return SCENES.has(scene_id)


static func zone_of(scene_id: String) -> String:
	return str((SCENES.get(scene_id, {}) as Dictionary).get("zone", ""))


## The Wanderer's lines in the Primm fight that quote the four leaders' lessons. Overnight Oct 19: the Capital is open from the start, so a
## hero who storms the castle before freeing those zones says `<key>.rushed` instead (his own words, no quotes from leaders he never met).
const RUSHED_KEYS: Array[String] = ["cutscene.primm_p1.2", "cutscene.primm_p2.2", "cutscene.primm_end.3"]


## Overnight Oct 22, Part 2: which freed zones each of those lines quotes (Flex's strength; the Grand Chef's blank page and Agnes's respect;
## Compostella's letting go). A line quotes only the leaders whose zones are free: all of them = the key, none = `.rushed`, some =
## `<key>.<zone id>` (the D.N.A. / Buffet line has one variant per leader).
const LESSON_ZONES: Dictionary = {
	"cutscene.primm_p1.2": ["beefcake"],
	"cutscene.primm_p2.2": ["gourmand", "necrocrat"],
	"cutscene.primm_end.3": ["refusemancer"],
}
const ALL_LESSON_ZONES: Array[String] = ["beefcake", "necrocrat", "gourmand", "refusemancer"]


## [{n, fx, key, speaker_key}] for `scene_id`. `rushed`: no zone is freed (every lesson line in the Wanderer's own words, see RUSHED_KEYS).
static func beats(scene_id: String, rushed: bool = false) -> Array[Dictionary]:
	return beats_for(scene_id, [] as Array[String] if rushed else ALL_LESSON_ZONES)


## [{n, fx, key, speaker_key}] for `scene_id` with `freed` zone ids: each lesson line quotes only the leaders of freed zones.
static func beats_for(scene_id: String, freed: Array[String]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Variant in ((SCENES.get(scene_id, {}) as Dictionary).get("beats", []) as Array):
		var pair: Array = entry as Array
		var key: String = "cutscene.%s.%d" % [scene_id, int(pair[0])]
		result.append({
			"n": int(pair[0]), "fx": str(pair[1]),
			"key": lesson_key(key, freed),
			"speaker_key": "cutscene.%s.%d.speaker" % [scene_id, int(pair[0])],
		})
	return result


## The variant of a lesson line for the freed zones (see LESSON_ZONES); other keys come back unchanged.
static func lesson_key(key: String, freed: Array[String]) -> String:
	if not LESSON_ZONES.has(key):
		return key
	var have: Array[String] = []
	for zone_id: Variant in LESSON_ZONES[key] as Array:
		if freed.has(str(zone_id)):
			have.append(str(zone_id))
	if have.size() == (LESSON_ZONES[key] as Array).size():
		return key
	if have.is_empty():
		return key + ".rushed"
	return key + "." + have[0]
