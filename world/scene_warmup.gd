class_name SceneWarmup
extends Node
## v0.4.2 hotfix: files a scene will load on the main thread soon after it appears - every frame of the painted characters walking about (a new
## facing loads its frames on first use), the footstep and UI sounds, the ambience, the portraits of an opening conversation - are asked for on
## loader threads while the loading screen is still up, and held for the scene's life, so their later `load()` is a cache hit. Before this the
## first seconds in Crosspath stalled 200-1400 ms several times while Maren was talking. SceneManager waits for `is_done()` (at most TIMEOUT).

const TIMEOUT_SECONDS: float = 20.0

var _pending: Array[String] = []
var _held: Array[Resource] = []
var _requested: int = 0
var _waited: float = 0.0


## Every frame (all facings, walk cycle, talk pose) of each painted character in `characters`.
func add_sprite_characters(characters: Array[String]) -> void:
	for character: String in characters:
		if not SpriteLibrary.has_character(character):
			continue
		var frames: Array = SpriteLibrary.info(character).get("frames", []) as Array
		var keys: Array[String] = []
		for key: Variant in frames:
			keys.append(str(key))
		for direction: Variant in SpriteLibrary.info(character).get("dirs", []) as Array:
			keys.append("%s_TALK" % str(direction))
		for key: String in keys:
			add_path("%s%s/%s.png" % [SpriteLibrary.FOLDER, character, key])


## The painted characters of every SpriteActor (and sprite-driven node) under `root`.
static func sprite_characters_under(root: Node) -> Array[String]:
	var found: Array[String] = []
	for node: Node in root.find_children("*", "Node3D", true, false):
		if not ("character" in node):
			continue
		var character: String = str(node.get("character"))
		if not character.is_empty() and not found.has(character):
			found.append(character)
	return found


## The files of sound events (every layer's set) - footsteps, the dialogue voice, UI ticks.
func add_sound_events(events: Array[String]) -> void:
	if Audio.bank == null:
		return
	for event_name: String in events:
		if not Audio.bank.has_event(event_name):
			continue
		for layer: Variant in Audio.bank.event(event_name).get("layers", []) as Array:
			for path: Variant in Audio.bank.files(str((layer as Dictionary).get("set", ""))):
				add_path(str(path))


## The beds and one-shots of ambience profiles.
func add_ambience(profiles: Array[String]) -> void:
	if Audio.bank == null:
		return
	for profile_name: String in profiles:
		var profile: Dictionary = AmbienceProfiles.resolved(profile_name)
		for group: String in ["beds", "oneshots"]:
			for entry: Variant in profile.get(group, []) as Array:
				for path: Variant in Audio.bank.files(str((entry as Dictionary).get("set", ""))):
					add_path(str(path))


## The portraits (base and every expression tag the lines use) of an upcoming conversation.
func add_portraits(npc_ids: Array[String], lines: Array[String]) -> void:
	var expressions: Array[String] = [""]
	for line: String in lines:
		var tag: String = str(DialogueBox._split_expression(line)[0])
		if not expressions.has(tag):
			expressions.append(tag)
	for npc_id: String in npc_ids:
		var entry: NpcRegistry.Entry = NpcRegistry.find(npc_id)
		if entry == null:
			continue
		for expression: String in expressions:
			add_path(Portraits._path(entry.portrait_id, expression))


func add_path(path: String) -> void:
	if path.is_empty() or _pending.has(path) or not ResourceLoader.exists(path):
		return
	if ResourceLoader.has_cached(path):
		_held.append(load(path))  # already in memory: just keep it there
		return
	if ResourceLoader.load_threaded_request(path) == OK:
		_pending.append(path)
		_requested += 1


func is_done() -> bool:
	return _pending.is_empty()


func requested() -> int:
	return _requested


func _process(delta: float) -> void:
	if _pending.is_empty():
		return
	_waited += delta
	for index: int in range(_pending.size() - 1, -1, -1):
		var path: String = _pending[index]
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var resource: Resource = ResourceLoader.load_threaded_get(path)
			if resource != null:
				_held.append(resource)
			_pending.remove_at(index)
		elif status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_pending.remove_at(index)
	if _waited > TIMEOUT_SECONDS and not _pending.is_empty():
		push_warning("SceneWarmup: %d files still loading after %.0f s; going on without them" % [_pending.size(), TIMEOUT_SECONDS])
		_pending.clear()
