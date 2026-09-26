extends SceneTree
## Round-robin AI-vs-AI simulation of the sample decks; writes a markdown balance report.
##   Godot --headless --path . -s res://tools/run_simulation.gd -- --games=100 --out=res://docs/balance_report.md
## Optional: --seed=1000  --notes=res://docs/balance_notes.md  --mirrors

func _init() -> void:
	var games: int = 100
	var out_path: String = "res://docs/balance_report.md"
	var notes_path: String = ""
	var base_seed: int = 1000
	var mirrors: bool = false
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--games="):
			games = int(arg.trim_prefix("--games="))
		elif arg.begins_with("--out="):
			out_path = arg.trim_prefix("--out=")
		elif arg.begins_with("--seed="):
			base_seed = int(arg.trim_prefix("--seed="))
		elif arg.begins_with("--notes="):
			notes_path = arg.trim_prefix("--notes=")
		elif arg == "--mirrors":
			mirrors = true
	var content: ContentSet = ContentLibrary.load_all()
	if content.decks.is_empty():
		push_error("No decks found in data/decks/. Run tools/generate_content.gd first.")
		quit(1)
		return
	var runner: SimulationRunner = SimulationRunner.new()
	var results: Array[MatchupStats] = []
	var started: int = Time.get_ticks_msec()
	for i: int in range(content.decks.size()):
		for j: int in range(i, content.decks.size()):
			if i == j and not mirrors:
				continue
			var stats: MatchupStats = runner.run_matchup(content.decks[i], content.decks[j], games, base_seed + (i * 10 + j) * 100000)
			results.append(stats)
			print("%s vs %s: %d-%d-%d, %.1f turns avg (%.0fs elapsed)" % [
				stats.deck_a, stats.deck_b, stats.wins_a, stats.wins_b, stats.draws,
				stats.average_turns(), float(Time.get_ticks_msec() - started) / 1000.0,
			])
	var notes: String = ""
	if notes_path != "" and FileAccess.file_exists(notes_path):
		notes = FileAccess.get_file_as_string(notes_path)
	var report: String = BalanceReport.build(content.decks, results, games, notes)
	var file: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write %s" % out_path)
		quit(1)
		return
	file.store_string(report)
	file.close()
	print("Wrote %s" % out_path)
	quit(0)
