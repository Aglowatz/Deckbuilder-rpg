extends Logger
## Overnight Oct 17, Part 13: forwards engine errors and warnings to the playthrough bot (`TourBot.record`). Called from any thread, so it
## only hands the text over (deferred to the main thread).

var bot: Object = null


func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
	if bot == null:
		return
	var kind: String = "warning" if error_type == ERROR_TYPE_WARNING else "error"
	var text: String = "%s (%s:%d in %s)" % [rationale if not rationale.is_empty() else code, file.get_file(), line, function]
	bot.call_deferred(&"record", kind, text)


func _log_message(message: String, error: bool) -> void:
	if bot != null and error and not message.strip_edges().is_empty():
		bot.call_deferred(&"record", "error", message)
