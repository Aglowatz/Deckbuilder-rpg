extends Logger
## Nov 27 day (Part A): the soak bot's engine logger - like `tour_bot_logger.gd`, plus the GDScript backtrace of each error (which script
## emitted the signal whose freed lambda fired, which line pushed the error), so a problem found at random can be traced. Called from any
## thread: it only hands the text over, deferred to the main thread.

var bot: Object = null


func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, script_backtraces: Array[ScriptBacktrace]) -> void:
	if bot == null:
		return
	var kind: String = "warning" if error_type == ERROR_TYPE_WARNING else "error"
	var text: String = "%s (%s:%d in %s)" % [rationale if not rationale.is_empty() else code, file.get_file(), line, function]
	var frames: PackedStringArray = []
	for trace: ScriptBacktrace in script_backtraces:
		for index: int in range(mini(trace.get_frame_count(), 6)):
			frames.append("%s:%d %s" % [trace.get_frame_file(index).get_file(), trace.get_frame_line(index), trace.get_frame_function(index)])
	if not frames.is_empty():
		text += " <- " + " <- ".join(frames)
	bot.call_deferred(&"record", kind, text)


func _log_message(message: String, error: bool) -> void:
	if bot != null and error and not message.strip_edges().is_empty():
		bot.call_deferred(&"record", "error", message)
