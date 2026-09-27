extends SceneTree
## Simulates many full runs through the Trial of the Hollow with the fixed neutral tutorial deck
## (AI-controlled) and reports the win rate, writing docs/balance_report.md's tutorial section.
## Run headless:
##   Godot --headless --path . -s res://tools/run_dungeon_simulation.gd -- --runs=500

const REPORT_PATH: String = "res://docs/balance_report.md"
const MARKER_START: String = "<!-- TUTORIAL_BALANCE_START -->"
const MARKER_END: String = "<!-- TUTORIAL_BALANCE_END -->"


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	var runs: int = int(args.get("runs", 500))
	var content: ContentSet = ContentLibrary.load_all()
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var deck: Deck = content.deck(CampaignStart.STARTER_DECK_NAME)
	var ai: AIPlayer = AIPlayer.new(AIPersonality.balanced())
	var results: Array[DungeonSimulation.RunResult] = DungeonSimulation.run_many(content, map, deck, ai, runs)
	var rate: float = DungeonSimulation.win_rate(results)
	var fail_counts: Dictionary = {}
	var turns: int = 0
	for result: DungeonSimulation.RunResult in results:
		turns += result.turns_played
		if not result.won:
			fail_counts[result.failed_at] = int(fail_counts.get(result.failed_at, 0)) + 1
	print("Tutorial dungeon: %d/%d runs won (%.1f%%), avg %.1f turns/run" % [
		roundi(rate * runs), runs, rate * 100.0, float(turns) / float(runs),
	])
	for node_title: Variant in fail_counts.keys():
		print("  lost at %s: %d" % [str(node_title), int(fail_counts[node_title])])
	_write_report(runs, rate, fail_counts)
	quit(0)


func _write_report(runs: int, rate: float, fail_counts: Dictionary) -> void:
	var lines: PackedStringArray = []
	lines.append(MARKER_START)
	lines.append("## Tutorial dungeon (Trial of the Hollow) balance")
	lines.append("")
	lines.append("Simulated with the AI (balanced personality) playing the fixed neutral tutorial deck")
	lines.append("through the whole dungeon (both battles, the challenge, the shrine and the boss), life")
	lines.append("carried between nodes, no dungeon-wide blessing - exactly what a human player gets.")
	lines.append("")
	lines.append("- **%d runs, %.1f%% won** (target: at least 85%%)." % [runs, rate * 100.0])
	if fail_counts.is_empty():
		lines.append("- No losses recorded.")
	else:
		lines.append("- Losses by node:")
		for node_title: Variant in fail_counts.keys():
			lines.append("  - %s: %d" % [str(node_title), int(fail_counts[node_title])])
	lines.append(MARKER_END)
	var block: String = "\n".join(lines)
	var path: String = ProjectSettings.globalize_path(REPORT_PATH)
	var existing: String = ""
	if FileAccess.file_exists(path):
		existing = FileAccess.get_file_as_string(path)
	var updated: String
	if existing.contains(MARKER_START) and existing.contains(MARKER_END):
		var start: int = existing.find(MARKER_START)
		var end: int = existing.find(MARKER_END) + MARKER_END.length()
		updated = existing.substr(0, start) + block + existing.substr(end)
	else:
		updated = existing + ("\n\n" if not existing.is_empty() else "") + block + "\n"
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(updated)
	file.close()
	print("Updated %s" % REPORT_PATH)
