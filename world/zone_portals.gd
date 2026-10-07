class_name ZonePortals
extends RefCounted
## Part G: the 5 placeholder zone portals in town - one per element, one for the final area. The
## single source of truth for their id/display name/tint, shared by `TownBuilder` (placing the
## portal structures) and `ZonePlaceholderScene` (the "coming soon" area each one leads to).
## Building the real zones is explicitly out of scope for this pass.

const FINAL_ID: String = "final"

## The label a passageway shows (and its signpost reads): only the destination, like "The Capital".
const DESTINATION_NAMES: Dictionary = {
	"beefcake": "The Gainlands",
	"necrocrat": "The Department of Necrotic Affairs",
	"gourmand": "The Endless Buffet",
	"refusemancer": "The Verdant Dump",
	"final": "The Capital",
}

class Info:
	extends RefCounted
	var id: String = ""
	var display_name: String = ""
	var tint: Color = Color.WHITE


## One per element, in `Affinity.colored_types()` order, plus the final area last.
static func all() -> Array[Info]:
	var result: Array[Info] = []
	for color: Affinity.Type in Affinity.colored_types():
		var info: Info = Info.new()
		info.id = UIStyle.affinity_name(color).to_lower()
		info.display_name = str(DESTINATION_NAMES.get(info.id, "%s Path" % UIStyle.affinity_name(color)))
		info.tint = UIStyle.affinity_color(color)
		result.append(info)
	var final_info: Info = Info.new()
	final_info.id = FINAL_ID
	final_info.display_name = str(DESTINATION_NAMES[FINAL_ID])
	final_info.tint = UIStyle.GOLD
	result.append(final_info)
	return result


static func find(id: String) -> Info:
	for info: Info in all():
		if info.id == id:
			return info
	return null
