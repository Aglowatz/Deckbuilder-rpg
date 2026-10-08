extends SceneTree
## Simulates many full runs through the Forgotten Cave with each element's 42-card starter
## deck (AI-controlled), the 3 tutorial reward picks added along the way exactly like a real
## playthrough (Part C), and reports the win rate per element plus overall - writing docs/
## balance_report.md's tutorial section. Also confirms the tutorial opponents actually attack
## (Part D). Run headless:
##   Godot --headless --path . -s res://tools/run_dungeon_simulation.gd -- --runs=500

const REPORT_PATH: String = "res://docs/balance_report.md"
const MARKER_START: String = "<!-- TUTORIAL_BALANCE_START -->"
const MARKER_END: String = "<!-- TUTORIAL_BALANCE_END -->"
const TARGET_WIN_RATE: float = 0.85


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	var runs: int = int(args.get("runs", 500))
	var content: ContentSet = ContentLibrary.load_all()
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var ai: AIPlayer = AIPlayer.new(AIPersonality.balanced())
	var per_element: Array[Dictionary] = []
	var total_runs: int = 0
	var total_wins: int = 0
	var total_enemy_attacks: int = 0
	for color: Affinity.Type in Affinity.colored_types():
		var deck: Deck = CampaignStart.starter_deck(content, color)
		var results: Array[DungeonSimulation.RunResult] = DungeonSimulation.run_many(content, map, deck, ai, runs, 5000 + int(color) * 100000, color)
		var rate: float = DungeonSimulation.win_rate(results)
		var fail_counts: Dictionary = {}
		var turns: int = 0
		var enemy_attacks: int = 0
		for result: DungeonSimulation.RunResult in results:
			turns += result.turns_played
			enemy_attacks += result.enemy_attacks
			if not result.won:
				fail_counts[result.failed_at] = int(fail_counts.get(result.failed_at, 0)) + 1
		per_element.append({
			"color": color, "rate": rate, "fail_counts": fail_counts,
			"avg_turns": float(turns) / float(runs), "enemy_attacks": enemy_attacks,
		})
		total_runs += runs
		total_wins += roundi(rate * runs)
		total_enemy_attacks += enemy_attacks
		print("%s starter: %d/%d runs won (%.1f%%), avg %.1f turns/run, %d enemy attacks" % [
			Affinity.display_name(color), roundi(rate * runs), runs, rate * 100.0, float(turns) / float(runs), enemy_attacks,
		])
		for node_title: Variant in fail_counts.keys():
			print("  lost at %s: %d" % [str(node_title), int(fail_counts[node_title])])
	var overall_rate: float = float(total_wins) / float(total_runs)
	print("Overall: %d/%d runs won (%.1f%%), %d total enemy attacks" % [total_wins, total_runs, overall_rate * 100.0, total_enemy_attacks])
	_write_report(runs, per_element, overall_rate, total_runs, total_wins, total_enemy_attacks)
	quit(0)


func _write_report(runs: int, per_element: Array[Dictionary], overall_rate: float, total_runs: int, total_wins: int, total_enemy_attacks: int) -> void:
	var lines: PackedStringArray = []
	lines.append(MARKER_START)
	lines.append("## Tutorial dungeon (The Forgotten Cave) balance")
	lines.append("")
	lines.append("Simulated with the AI (balanced personality) playing each element's real 42-card starter")
	lines.append("deck (23 neutral spells + 19 basic infrastructure, Part C) through the whole dungeon (both battles,")
	lines.append("the challenge, the shrine and the boss), picking one of the 3 offered on-element reward")
	lines.append("cards after each battle exactly like a real playthrough (so the deck grows to 45 cards by")
	lines.append("the boss), HP carried between nodes, no dungeon-wide blessing - exactly what a human")
	lines.append("player gets. Non-boss opponents use only weak, vanilla decks with an eager \"Aggressive")
	lines.append("(tutorial)\" AI (attacks readily, does not play around counter-attacks - Part D); the boss")
	lines.append("uses the real (smarter than \"Aggressive (tutorial)\") \"Balanced\" AI and a few real")
	lines.append("effects (a death trigger, token generation) rather than an all-vanilla deck.")
	lines.append("")
	lines.append("- **%d runs per element (%d total), %.1f%% won overall** (target: at least %.0f%%)." % [runs, total_runs, overall_rate * 100.0, TARGET_WIN_RATE * 100.0])
	lines.append("- **%d enemy attacks declared across every run** - confirms the tutorial AI actually attacks (it never did before Part D), so the player's own traps (Pitfall etc.) are genuinely tested." % total_enemy_attacks)
	lines.append("")
	lines.append("| Element | Win rate | Avg turns/run | Enemy attacks | Losses by node |")
	lines.append("|---|---|---|---|---|")
	for entry: Dictionary in per_element:
		var color: Affinity.Type = entry["color"] as Affinity.Type
		var fail_counts: Dictionary = entry["fail_counts"] as Dictionary
		var losses: String = "none"
		if not fail_counts.is_empty():
			var parts: PackedStringArray = []
			for node_title: Variant in fail_counts.keys():
				parts.append("%s: %d" % [str(node_title), int(fail_counts[node_title])])
			losses = ", ".join(parts)
		lines.append("| %s | %.1f%% | %.1f | %d | %s |" % [
			Affinity.display_name(color), float(entry["rate"]) * 100.0, float(entry["avg_turns"]), int(entry["enemy_attacks"]), losses,
		])
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
