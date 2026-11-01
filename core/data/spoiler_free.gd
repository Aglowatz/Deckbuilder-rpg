class_name SpoilerFree
extends RefCounted
## Overnight Oct 30-31 (mid-game critic #5): names as the player may see them before a reveal. The data sheets name characters with their
## secret in brackets ("Old Hob the Gravedigger (secretly Death)", "The Doppelganger (posing as Grand Chef Escoffina)", "(later named
## Escoffina)"); the plates, node cards and boss lines show the cover name only. The sheets themselves are unchanged.


## Overnight Oct 31 - Nov 1 (the designer's answer 10): characters whose plate changes at a story reveal. Keyed by NPC ID; `cover` is
## the name until then, `name` after; the reveal counts once ANY of `flags` is set (the naming cutscene, or the zone freed for saves
## made before the cutscene had a seen flag). `GameSession.sync_story_tokens` feeds the flags in (`sync`).
const REVEALS: Dictionary = {
	"NPC-DOPPEL": {"cover": "The Doppelganger", "name": "The Doppelganger", "flags": ["cutscene_seen_wonder", "zone_gourmand_completed"]},  # Nov 1: the designer keeps "The Doppelganger" after the reveal too
}

static var _revealed: Dictionary = {}


## Records which REVEALS have happened, from the save's flags.
static func sync(flags: Dictionary) -> void:
	_revealed.clear()
	for npc_id: String in REVEALS:
		for flag: Variant in (REVEALS[npc_id] as Dictionary)["flags"] as Array:
			if bool(flags.get(str(flag), false)):
				_revealed[npc_id] = true


static func is_revealed(npc_id: String) -> bool:
	return _revealed.has(npc_id)


## The plate for NPC `npc_id` once revealed, else `fallback`.
static func npc_name(npc_id: String, fallback: String) -> String:
	if is_revealed(npc_id):
		return str((REVEALS[npc_id] as Dictionary)["name"])
	return fallback


## A cover name ("The Doppelganger") -> its revealed name once that reveal has happened; any other text as it is.
static func revealed(text: String) -> String:
	for npc_id: String in REVEALS:
		if is_revealed(npc_id) and text == str((REVEALS[npc_id] as Dictionary)["cover"]):
			return str((REVEALS[npc_id] as Dictionary)["name"])
	return text


## "X (posing as Y)" -> "Y"; "X (secretly Y)" / "X (later named Y)" -> "X"; anything else as it is.
static func name(text: String) -> String:
	var open: int = text.find(" (")
	if open < 0 or not text.ends_with(")"):
		return text
	var inside: String = text.substr(open + 2, text.length() - open - 3)
	var lowered: String = inside.to_lower()
	if lowered.begins_with("posing as "):
		return inside.substr(10).strip_edges()
	if lowered.begins_with("secretly ") or lowered.begins_with("later named "):
		return text.substr(0, open).strip_edges()
	return text
