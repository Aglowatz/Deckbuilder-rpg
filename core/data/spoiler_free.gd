class_name SpoilerFree
extends RefCounted
## Overnight Oct 30-31 (mid-game critic #5): names as the player may see them before a reveal. The data sheets name characters with their
## secret in brackets ("Old Hob the Gravedigger (secretly Death)", "The Doppelganger (posing as Grand Chef Escoffina)", "(later named
## Escoffina)"); the plates, node cards and boss lines show the cover name only. The sheets themselves are unchanged.


## Overnight Oct 31 - Nov 1 (the designer's answer 10): characters whose plate changes at a story reveal. Keyed by NPC ID; `cover` is
## the name until then, `name` after; the reveal counts once ANY of `flags` is set (the naming cutscene, or the zone freed for saves
## made before the cutscene had a seen flag). `GameSession.sync_story_tokens` feeds the flags in (`sync`).
## Fable pass Nov 1 (Part 4, the story's naming): the real chef is "The Grand Chef"; the impostor is "The Doppelganger" - it poses as
## the chef before the reveal ("posing as Grand Chef Escoffina": the node blurb shows the cover), the boss fight always reads "The
## Doppelganger" (`BossIntros` never applies the reveal), and after the naming cutscene the apprentice reads "Escoffina" (the registry
## plate, the freed Buffet's NPC). A dialogue line whose speaker label is one of these names keeps that label (`plate_for`), so the
## naming cutscene can move from "The Doppelganger" to "Escoffina" beat by beat.
const REVEALS: Dictionary = {
	"NPC-DOPPEL": {"cover": "The Doppelganger", "name": "Escoffina", "flags": ["cutscene_seen_wonder", "zone_gourmand_completed"]},
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


## "X (posing as Y)" -> "Y" until X's reveal, "X" after; "X (secretly Y)" / "X (later named Y)" / "X (formerly Y)" -> "X"; anything
## else as it is.
static func name(text: String) -> String:
	var open: int = text.find(" (")
	if open < 0 or not text.ends_with(")"):
		return text
	var inside: String = text.substr(open + 2, text.length() - open - 3)
	var lowered: String = inside.to_lower()
	var subject: String = text.substr(0, open).strip_edges()
	if lowered.begins_with("posing as "):
		# Fable pass Nov 1: once the impostor is revealed, the node blurb names it, not the face it wore.
		if _is_revealed_cover(subject):
			return subject
		return inside.substr(10).strip_edges()
	if lowered.begins_with("secretly ") or lowered.begins_with("later named ") or lowered.begins_with("formerly "):
		return subject
	return text


static func _is_revealed_cover(cover: String) -> bool:
	for npc_id: String in REVEALS:
		if is_revealed(npc_id) and str((REVEALS[npc_id] as Dictionary)["cover"]) == cover:
			return true
	return false


## Fable pass Nov 1: the dialogue plate for a line of `npc_id` labelled `speaker`: a label that is the cover or the revealed name of a
## REVEALS character stays as written (the writer chose it for the beat); otherwise `fallback` (the registry plate).
static func plate_for(npc_id: String, speaker: String, fallback: String) -> String:
	if REVEALS.has(npc_id):
		var entry: Dictionary = REVEALS[npc_id] as Dictionary
		var label: String = speaker.strip_edges()
		if label == str(entry["cover"]) or label == str(entry["name"]):
			return label
	return fallback
