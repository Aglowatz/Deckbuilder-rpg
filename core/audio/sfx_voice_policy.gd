class_name SfxVoicePolicy
extends RefCounted
## Voice limits and priorities (docs/audio/sound_direction.md, "Many sounds at once"): which pooled player a new sound may take, so a busy battle
## never turns to mush and the important sounds always get through.
##
## `voices` is one Dictionary per player: `busy` (playing), `event` (what it plays), `priority` (0-100) and `started` (seconds). The rules, in order:
## 1. an event at its own limit (`max_same` instances playing) replaces its own oldest instance (a burst of hits stays a burst, not a pile-up);
## 2. otherwise a free player;
## 3. otherwise the lowest-priority busy player (the oldest among equals), if it is not more important than the new sound;
## 4. otherwise the new sound is dropped (-1).


static func choose(voices: Array[Dictionary], event_name: String, priority: int, max_same: int) -> int:
	var same: Array[int] = []
	for index: int in range(voices.size()):
		var voice: Dictionary = voices[index]
		if bool(voice.get("busy", false)) and str(voice.get("event", "")) == event_name:
			same.append(index)
	if max_same > 0 and same.size() >= max_same:
		return _oldest(voices, same)
	for index: int in range(voices.size()):
		if not bool(voices[index].get("busy", false)):
			return index
	var weakest: int = -1
	for index: int in range(voices.size()):
		var voice: Dictionary = voices[index]
		if weakest < 0:
			weakest = index
			continue
		var best: Dictionary = voices[weakest]
		var p: int = int(voice.get("priority", 0))
		var bp: int = int(best.get("priority", 0))
		if p < bp or (p == bp and float(voice.get("started", 0.0)) < float(best.get("started", 0.0))):
			weakest = index
	if weakest >= 0 and int(voices[weakest].get("priority", 0)) <= priority:
		return weakest
	return -1


static func _oldest(voices: Array[Dictionary], indices: Array[int]) -> int:
	var result: int = indices[0]
	for index: int in indices:
		if float(voices[index].get("started", 0.0)) < float(voices[result].get("started", 0.0)):
			result = index
	return result
