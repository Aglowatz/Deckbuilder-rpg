extends SceneTree
## Fable Nov 20 (Part 7): the Arena puzzle lab and report. Solves every puzzle of a puzzle file with `PuzzleSolver` and prints, for
## each: the board, whether it can be won, the solutions (and how many winning lines there are in all), whether a decoy is used by
## any solution, and whether each naive line fails.
##   Godot --headless --path . -s res://tools/arena_puzzle_lab.gd                      the game's puzzles (data/arena/arena_puzzles.json)
##   ... -- --file=res://_logs/puzzle_draft.json [--id=<puzzle id>] [--lines=8]         a draft file, one puzzle, more example lines
##   ... -- --out=res://docs/design/arena_puzzles_nov20.md                             also writes the report as a table


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _args() -> Dictionary:
	var result: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--") and arg.contains("="):
			var parts: PackedStringArray = arg.trim_prefix("--").split("=", true, 1)
			result[parts[0]] = parts[1]
	return result


func _run() -> void:
	var args: Dictionary = _args()
	var defs: GDScript = load("res://core/arena/arena_defs.gd") as GDScript
	var check: GDScript = load("res://core/arena/puzzle_check.gd") as GDScript
	var library: GDScript = load("res://core/sim/content_library.gd") as GDScript
	var content: Variant = library.call("load_all")
	var file: String = str(args.get("file", defs.get("PUZZLE_FILE")))
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(file))
	if not (parsed is Dictionary):
		print("lab: cannot read %s" % file)
		quit(1)
		return
	var puzzles: Dictionary = (parsed as Dictionary).get("puzzles", {}) as Dictionary
	var only: String = str(args.get("id", ""))
	var show: int = int(args.get("lines", 3))
	var all_ok: bool = true
	var table: PackedStringArray = []
	for id: Variant in puzzles.keys():
		if not only.is_empty() and str(id) != only:
			continue
		var row: Dictionary = puzzles[id] as Dictionary
		var encounter: Variant = defs.call("puzzle_from", str(id), int(row.get("tier", 1)), row)
		var started: int = Time.get_ticks_msec()
		var report: Variant = check.call("run", content, encounter)
		print("==== %s (tier %d): %s" % [str(id), int(row.get("tier", 1)), str(row.get("title", ""))])
		for line: String in report.get("board") as PackedStringArray:
			print("  " + line)
		print("  solvable: %s | search complete: %s | positions: %d | winning lines: %d | solutions: %d | %d ms" % [str(report.get("solvable")), str(report.get("complete")), int(report.get("states")), int(report.get("winning_lines")), (report.get("solutions") as Array).size(), Time.get_ticks_msec() - started])
		var lines: Array = report.get("solution_lines") as Array
		for index: int in range(mini(lines.size(), show)):
			print("  solution %d: %s" % [index + 1, " -> ".join(lines[index] as PackedStringArray)])
		for name: Variant in (report.get("decoys_used") as Dictionary).keys():
			print("  decoy %s: %s" % [str(name), "USED BY A SOLUTION" if bool((report.get("decoys_used") as Dictionary)[name]) else "in no solution"])
		for name: Variant in (report.get("naive") as Dictionary).keys():
			print("  naive line '%s': %s" % [str(name), str((report.get("naive") as Dictionary)[name])])
		var ok: bool = bool(report.call("ok")) and lines.size() == 1
		print("  verdict: %s" % ("OK (one solution, decoys unused, naive lines fail)" if ok else "NOT YET"))
		all_ok = all_ok and ok
		table.append("| %d | %s | %s | %s | %s | %d winning lines, %d solution(s), %d positions searched | %s |" % [int(row.get("tier", 1)), str(row.get("title", "")), " + ".join(PackedStringArray(row.get("paths", []) as Array)), str(row.get("synergy", "")),
			" -> ".join(lines[0] as PackedStringArray) if not lines.is_empty() else "-", int(report.get("winning_lines")), lines.size(), int(report.get("states")), "; ".join(_decoy_words(row))])
	if args.has("out"):
		var handle: FileAccess = FileAccess.open(str(args["out"]), FileAccess.WRITE)
		handle.store_string("| Tier | Title | Paths | Synergy | The solver's solution | Search | Decoys |\n|---|---|---|---|---|---|---|\n" + "\n".join(table) + "\n")
		handle.close()
	print("lab: %s" % ("every puzzle OK" if all_ok else "NOT every puzzle is OK"))
	quit(0 if all_ok else 1)


func _decoy_words(row: Dictionary) -> PackedStringArray:
	var words: PackedStringArray = []
	for decoy: Variant in row.get("decoys", []) as Array:
		words.append("%s (%s)" % [str((decoy as Dictionary).get("card", "")), str((decoy as Dictionary).get("why", ""))])
	return words
