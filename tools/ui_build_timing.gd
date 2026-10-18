extends RefCounted
## Overnight Oct 17 (Phase 2, performance): how long each big screen takes to build (add_child -> _ready) on the CPU, twice each.
## Run: Godot --headless --path . -s res://tools/ui_build_timing_run.gd


func run(tree: SceneTree) -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var makers: Dictionary = {
		"deck_station": func() -> Control: return DeckbuilderScreen.new(),
		"character": func() -> Control: return CharacterScreen.new(),
		"codex": func() -> Control: return CodexScreen.new(),
		"vendor": func() -> Control:
			var screen: VendorScreen = VendorScreen.new()
			screen.pack_vendor_id = PackData.VENDOR_CARD
			screen.vendor_screen_id = "VS-SABLE"
			return screen,
		"quest_log": func() -> Control: return QuestLogScreen.new(),
	}
	for key: Variant in makers.keys():
		for round: int in range(2):
			var started: int = Time.get_ticks_usec()
			var screen: Control = (makers[key] as Callable).call() as Control
			tree.root.add_child(screen)
			var built: int = Time.get_ticks_usec()
			await tree.process_frame
			var framed: int = Time.get_ticks_usec()
			print("ui_build_timing: %s round %d: build %.1f ms, next frame %.1f ms, nodes %d" % [str(key), round + 1, (built - started) / 1000.0, (framed - built) / 1000.0, screen.find_children("*", "", true, false).size()])
			screen.queue_free()
			await tree.process_frame
