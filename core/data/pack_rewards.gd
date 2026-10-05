class_name PackRewards
extends RefCounted
## Pack rewards as plain data: a list of {"id": pack id, "count": int} entries, kept in a result Dictionary under "packs". The Session
## grants them, the reward screens describe them (`labels`, `dungeon_lines`) with text from the story data.


static func entry(pack_id: String, count: int = 1) -> Dictionary:
	return {"id": pack_id, "count": count}


## "Beefcake Pack" / "2x Gilded Beefcake Pack, Beefcake Pack" for a list of entries.
static func labels(packs: Array) -> String:
	var parts: PackedStringArray = []
	for item: Variant in packs:
		var pack_entry: Dictionary = item as Dictionary
		var pack: PackData = PackCatalog.find(str(pack_entry.get("id", "")))
		var title: String = pack.display_name if pack != null else str(pack_entry.get("id", ""))
		var count: int = int(pack_entry.get("count", 1))
		parts.append(title if count == 1 else "%dx %s" % [count, title])
	return ", ".join(parts)


## The lines a zone's main-dungeon result adds to its announcement or toast: the pack every clear gives, the first-clear bonus and the
## Pack Vendor unlock.
static func dungeon_lines(result: Dictionary, story: StoryText) -> Array[String]:
	var lines: Array[String] = []
	var packs: Array = result.get("packs", []) as Array
	if packs.is_empty():
		return lines
	lines.append(story.text("pack.reward.clear") % labels(packs))
	if bool(result.get("first_clear", false)):
		var bonus: Array = result.get("bonus_packs", []) as Array
		var parts: PackedStringArray = []
		if not bonus.is_empty():
			parts.append(labels(bonus))
		if int(result.get("bonus_gold", 0)) > 0:
			parts.append("%d gold" % int(result["bonus_gold"]))
		if int(result.get("bonus_xp", 0)) > 0:
			parts.append("%d XP" % int(result["bonus_xp"]))
		if not parts.is_empty():
			lines.append(story.text("pack.reward.first_bonus") % ", ".join(parts))
		if str(result.get("vendor_unlock", "")) != "":
			lines.append(story.text("pack.reward.vendor_unlock") % str(result["vendor_unlock"]))
	return lines


## The first win of a zone's minigame pays that Path's Path Pack (once; later wins pay the usual gold/XP). Sets `result["pack"]` to the
## pack id so the minigame's result line can show it.
static func grant_minigame_prize(result: Dictionary) -> void:
	if not bool(result.get("first_win", false)):
		return
	var pack_id: String = PackRules.path_pack_id(PackRules.path_for_zone(ZoneDefs.current().id))
	if PackCatalog.find(pack_id) != null and Session.add_pack(pack_id):
		result["pack"] = pack_id


## " + Beefcake Pack" style text for a minigame result line (empty when no pack was won).
static func minigame_text(reward: Dictionary) -> String:
	var pack_id: String = str(reward.get("pack", ""))
	if pack_id.is_empty():
		return ""
	return labels([entry(pack_id)])
