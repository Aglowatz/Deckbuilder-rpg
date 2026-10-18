extends SceneTree
## Overnight Oct 17, Part 6: writes docs/design/level_rewards.md from the reward track (data/progression/level_track.json via
## ProgressionTable). Run: Godot --headless --path . -s res://tools/level_rewards_doc.gd

const OUT: String = "res://docs/design/level_rewards.md"


func _initialize() -> void:
	var rows: Array[LevelData] = ProgressionTable.build()
	var lines: PackedStringArray = []
	lines.append("# Level rewards (1-30)")
	lines.append("")
	lines.append("Generated from `data/progression/level_track.json` by `tools/level_rewards_doc.gd` - edit the data file, then re-run the tool.")
	lines.append("Every level grants something; **bold** levels are the big unlocks (the level-up screen highlights them). Packs marked")
	lines.append("\"Path\" / \"Gilded\" are the player's own Path (Beefcake shown here). Stats (HP, hands, item slots) are computed by")
	lines.append("`ProgressionTable` from the track's `stats` section.")
	lines.append("")
	lines.append("| Level | XP to reach | Headline | Rewards |")
	lines.append("|---|---|---|---|")
	for index: int in range(rows.size()):
		var row: LevelData = rows[index]
		var previous: LevelData = rows[index - 1] if index > 0 else null
		var rewards: String = "Starting stats." if previous == null else " ".join(ProgressionTable.reward_lines(row, previous, Affinity.Type.BEEFCAKE))
		var level_text: String = "**%d**" % row.level if row.big else str(row.level)
		var headline: String = "**%s**" % row.headline if row.big and not row.headline.is_empty() else row.headline
		lines.append("| %s | %d | %s | %s |" % [level_text, row.xp_to_reach, headline, rewards])
	lines.append("")
	lines.append("## Anchors")
	lines.append("")
	lines.append("- **Level 5**: the armory quest (\"Some Assembly Required\") starts by itself and unlocks every equipment slot; first Epic gear.")
	lines.append("- **Levels 7, 14, 21**: two more Deck Station slots each (4 -> 10).")
	lines.append("- **Copy caps** reach 3 for every rarity by level 30: Uncommon 9, Epic 12/22, Legendary 18/30.")
	lines.append("- **Equipment caps**: Epic 1/2/3/5 at 5/13/19/25, Uncommon 3/5 at 10/16, Legendary 1/2 at 22/28.")
	lines.append("")
	lines.append("## XP curve")
	lines.append("")
	lines.append("Unchanged: 15 x L x (L-1) up to level 20 (5700 XP), then +40 x (L-20) x (L-19) (10100 XP at 30). `tools/xp_budget.gd` sums what one")
	lines.append("playthrough offers; see the Overnight Oct 17 report for the numbers and the reasoning.")
	var file: FileAccess = FileAccess.open(OUT, FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n")
	file.close()
	print("wrote %s (%d levels)" % [OUT, rows.size()])
	quit()
