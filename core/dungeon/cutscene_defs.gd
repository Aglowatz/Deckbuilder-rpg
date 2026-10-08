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
	"primm_p1": {"zone": "final", "beats": [[1, "crack"], [2, ""], [3, ""], [4, "shake"]]},
	"primm_p2": {"zone": "final", "beats": [[1, "mirror"], [2, ""], [3, ""], [4, "unravel"], [5, ""]]},
	"primm_end": {"zone": "final", "beats": [[1, "crack"], [2, "crown_off"], [3, ""], [4, ""], [5, "shrink"], [6, ""], [7, ""], [8, "dove"]]},
}


static func has_scene(scene_id: String) -> bool:
	return SCENES.has(scene_id)


static func zone_of(scene_id: String) -> String:
	return str((SCENES.get(scene_id, {}) as Dictionary).get("zone", ""))


## [{n, fx, key, speaker_key}] for `scene_id`.
static func beats(scene_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Variant in ((SCENES.get(scene_id, {}) as Dictionary).get("beats", []) as Array):
		var pair: Array = entry as Array
		result.append({
			"n": int(pair[0]), "fx": str(pair[1]),
			"key": "cutscene.%s.%d" % [scene_id, int(pair[0])],
			"speaker_key": "cutscene.%s.%d.speaker" % [scene_id, int(pair[0])],
		})
	return result
