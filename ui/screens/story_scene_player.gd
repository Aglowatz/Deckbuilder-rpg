class_name StoryScenePlayer
extends RefCounted
## Plays a `StoryScenes` scene in a dialogue box, one speaker after another, then calls `then`. Sets the scene's flags (`once_flag`,
## `sets`) when the last box closes, and saves.


static func play(dialogue: DialogueBox, id: String, then: Callable = Callable()) -> void:
	var steps: Array[Dictionary] = StoryScenes.steps(id)
	if dialogue == null or steps.is_empty():
		_finish(id, then)
		return
	GameLog.info("story", "scene %s" % id)
	_play_step(dialogue, id, steps, 0, then)


static func _play_step(dialogue: DialogueBox, id: String, steps: Array[Dictionary], index: int, then: Callable) -> void:
	if index >= steps.size() or not is_instance_valid(dialogue):
		_finish(id, then)
		return
	var step: Dictionary = steps[index]
	var speaker_id: String = str(step["speaker_id"])
	if speaker_id == StoryScenes.SET_FLAGS:
		for flag: String in step["lines"] as Array[String]:
			Session.set_flag(StringName(flag))
		_play_step(dialogue, id, steps, index + 1, then)
		return
	dialogue.start(label_for(speaker_id), step["lines"] as Array[String], speaker_id)
	dialogue.finished.connect(func() -> void: _play_step(dialogue, id, steps, index + 1, then), CONNECT_ONE_SHOT)


## The name plate: the Rescuer goes by `{rescuer}` (her name only once Plume has said it); everyone else by their list name.
static func label_for(speaker_id: String) -> String:
	if speaker_id == StoryScenes.RESCUER_ID:
		return RoyalFamily.fill("{rescuer}")
	return ""


static func _finish(id: String, then: Callable) -> void:
	for flag: String in StoryScenes.flags_set(id):
		Session.set_flag(StringName(flag))
	if not StoryScenes.flags_set(id).is_empty():
		Session.save_game()
	if then.is_valid():
		then.call()
