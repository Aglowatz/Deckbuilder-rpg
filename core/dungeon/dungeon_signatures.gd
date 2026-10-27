class_name DungeonSignatures
extends RefCounted
## Cards Oct 27, Part 2: each main dungeon's second REWARD-LOCKED chase card, offered in its boss's card pick (one of the three
## choices, every first clear and every later clear) until the player has earned it. The first-clear grant (the Legendary leader card
## or Mass Layoffs) is `MainDungeonDef.reward_card_id`; the side dungeons' single prize is theirs (`ZoneDef.mini.reward_card_id`).
## The whole table, with reasons: `docs/design/card_availability.md`.

const BOSS_PICKS: Dictionary = {
	"D-HOG": "NB-17",  # Iron Filing Clerk: the Iron Regent's own engine, Necrocrat / Beefcake
	"D-HFA": "N-19",  # Resting In Peace Clause: the Hall's fine print ("It reads you back.")
	"D-TTK": "G-28",  # Chef de Golem: the Doppelganger's golem master (the shelf sells it once earned, as before: after the boss)
	"D-ROT": "R-29",  # Mount Trashmore: the heap under the Rotheart
	"D-PC": "C-34",  # The Harmony Engine: the castle's four-Path core
}


static func boss_pick_id(dungeon_key: String) -> String:
	return str(BOSS_PICKS.get(dungeon_key, ""))


static func all_ids() -> Array[String]:
	var result: Array[String] = []
	for id: Variant in BOSS_PICKS.values():
		result.append(str(id))
	return result
