class_name SpoilerFree
extends RefCounted
## Overnight Oct 30-31 (mid-game critic #5): names as the player may see them before a reveal. The data sheets name characters with their
## secret in brackets ("Old Hob the Gravedigger (secretly Death)", "The Doppelganger (posing as Grand Chef Escoffina)", "(later named
## Escoffina)"); the plates, node cards and boss lines show the cover name only. The sheets themselves are unchanged.


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
