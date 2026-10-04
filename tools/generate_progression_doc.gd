extends SceneTree
## Writes the levels-1-30 table (and its intro bullets) in docs/design/progression.md from
## ProgressionTable.build() (the one source of truth for Part E's level table). Run after
## changing anything in core/data/progression_table.gd:
##   Godot --headless --path . -s res://tools/generate_progression_doc.gd
##
## New brief, Part D: only regenerates everything ABOVE the first "## Equipment" heading -
## everything from there on (equipment/items tables, pricing notes, etc.) is hand-maintained
## prose now (it grew real narrative content in Parts B/C this tool can't usefully author) and is
## read back from the existing file untouched. If that heading is ever renamed, update
## SPLIT_HEADING below to match.

const DOC_PATH: String = "res://docs/design/progression.md"
const SPLIT_HEADING: String = "## Equipment"


func _initialize() -> void:
	var rows: Array[LevelData] = ProgressionTable.build()
	var lines: PackedStringArray = []
	lines.append("# Player Progression (Part E)")
	lines.append("")
	lines.append("Levels 1-30. Generated from `core/data/progression_table.gd` by `tools/")
	lines.append("generate_progression_doc.gd` - edit the table, not this file, then regenerate.")
	lines.append("")
	lines.append("- **XP**: every encounter grants XP scaled by difficulty (`EncounterRewards`):")
	lines.append("  Tutorial 15, Normal 30, Elite 60, Boss 120. The curve below is tuned so finishing")
	lines.append("  the main story lands around **level 20**; levels 21-30 are postgame.")
	lines.append("- **Starting life**: 10 at level 1, +1 on every even level, reaching **25 at level 30**")
	lines.append("  (before equipment/item modifiers).")
	lines.append("- **Opening hand size**: 5 at level 1, gradually up to **8** at level 24+.")
	lines.append("- **Item slots**: 1 at level 1, gradually up to **4** at level 30.")
	lines.append("- **Equipment slots** (Helm/Weapon/Armor/Boots/Relic): 0 at level 1; one is chosen")
	lines.append("  and unlocked at levels 5, 10, 15, 20 and 25 - all five are unlocked by level 25.")
	lines.append("- **Deck copy limit**: 4 copies of every non-infrastructure card at every level; infrastructure is unlimited.")
	lines.append("  (The old rarity-based limits were removed - the levels that raised them now grant gold, vendor")
	lines.append("  discounts, a bigger max hand size and a vendor-stock unlock instead.)")
	lines.append("- **Max hand size**: 10, +1 at levels 14 and 28.")
	lines.append("- Every level grants something: a real stat/slot/limit increase, an equipment choice,")
	lines.append("  a vendor unlock/discount, or gold - New brief, Part D removed random card-choice")
	lines.append("  level rewards entirely.")
	lines.append("")
	lines.append("| Level | XP to reach | Life | Hand | Max hand | Items | Grants |")
	lines.append("|---:|---:|---:|---:|---:|---:|---|")
	for row: LevelData in rows:
		lines.append("| %d | %d | %d | %d | %d | %d | %s |" % [
			row.level, row.xp_to_reach, row.max_life, row.opening_hand_size, row.max_hand_size, row.item_slots,
			row.summary,
		])
	lines.append("")
	lines.append("## Level-up rewards (New brief, Part D)")
	lines.append("")
	lines.append("Random card-choice level rewards were removed entirely - every level now grants only")
	lines.append("real stat/slot/limit increases, an equipment-slot choice, gold, a permanent vendor")
	lines.append("discount, or a vendor-stock unlock (see `PlayerProfile.vendor_discount_percent`/")
	lines.append("`Session.effective_price()` - the discount actually reduces what every vendor charges,")
	lines.append("not just what it displays). Two specific one-time unlocks, chosen to land \"around when")
	lines.append("the player has 1-2 equipment slots\": level %d unlocks the equipment vendor's 5 advanced" % ProgressionTable.EQUIPMENT_VENDOR_UNLOCK_LEVEL)
	lines.append("pieces (right alongside that level's own equipment-slot choice); level %d unlocks the item" % ProgressionTable.ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL)
	lines.append("vendor's second (advanced) half. Both are plain `Condition.player_level(...)` checks read")
	lines.append("live against the profile - no flag to set, no save-data migration. The level-up popup")
	lines.append("announces every reward explicitly (`LevelUpScreen._bonuses_for`).")
	lines.append("")
	var path: String = ProjectSettings.globalize_path(DOC_PATH)
	var existing: String = ""
	if FileAccess.file_exists(path):
		existing = FileAccess.get_file_as_string(path)
	var split_at: int = existing.find(SPLIT_HEADING)
	if split_at < 0:
		push_error("generate_progression_doc: %s heading not found in %s - hand-maintained section left untouched instead of being silently deleted; add the heading back (or update SPLIT_HEADING) before regenerating." % [SPLIT_HEADING, DOC_PATH])
		quit(1)
		return
	var kept_tail: String = existing.substr(split_at)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n" + kept_tail)
	file.close()
	print("Wrote %s (kept the hand-maintained section from %s onward)" % [DOC_PATH, SPLIT_HEADING])
	quit(0)
