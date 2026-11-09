class_name QuestAudit
extends RefCounted
## Overnight Nov 8-9, Part 1.1: static quest completability check. Walks every quest in `QuestCatalog` and builds the graph of quests and
## steps (what starts each, what completes each step, where its giver / target lives), then flags:
##   - rewards (quest or milestone) pointing at missing items, cards, equipment or packs;
##   - prerequisites / conditions naming a quest, dungeon or card that does not exist, and prerequisite cycles;
##   - steps gated on a flag, counter or secret that NOTHING in the game sets (no producer found in the source or the data);
##   - quest givers who are not standing anywhere (a non-auto quest whose giver name is never used by a world script or data row);
##   - marker spots (giver, turn-in, step targets) that no world script or zone definition declares;
##   - areas that are not real areas;
##   - order traps: a COUNTER step counts from acceptance, so a counter bumped only by a one-time event (a boss, a gatekeeper) that the
##     player can trigger before taking the quest would never move again.
## Run by tests/core/quests/test_quest_audit.gd (the suite fails on any error) and `bash tools/quest_audit.sh` (writes the report
## docs/quests/quest_audit.md). Errors must be fixed; warnings are listed for a human to read.

const SOURCE_DIRS: Array[String] = ["res://app", "res://core", "res://world", "res://ui"]
const DATA_DIRS: Array[String] = ["res://data/story", "res://data/feats", "res://data/npcs", "res://data/dungeons", "res://data/encounters"]
const QUEST_SOURCES: Array[String] = ["res://core/quests/quest_definitions.gd", "res://core/quests/zone_quest_definitions.gd"]
const AREAS_EXTRA: Array[String] = ["town", "forest", "start", "lab", ""]
## Words on a line that make it a place where a flag / counter / secret is SET (a producer).
const PRODUCER_MARKS: Array[String] = ["set_flag(", "bump_counter(", "_bump_counter_raw(", "found_secret(", "flags[", "counters[", "unlock_flags",
	"found_secrets.append", "\"flag\"", "\"set_flag\"", "\"sets\"", "\"on_win_flag\"", "\"win_flag\"", "_FLAG", "flag_on", "mark_seen(", "remember(", "\"flags\""]


## Counters bumped only by a one-time event. A COUNTER step on one of these must not count from acceptance (see the order check).
const ONE_SHOT_COUNTER_HINTS: Array[String] = ["boss", "gatekeeper", "primm", "final_"]

var errors: PackedStringArray = []
var warnings: PackedStringArray = []
var rows: Array[Dictionary] = []

var _sources: Dictionary = {}  # path -> PackedStringArray lines
var _consts: Dictionary = {}  # value -> Array of const names
var _producer_lines: PackedStringArray = []
var _all_text_no_quests: String = ""
var _content: ContentSet
var _quest_ids: Dictionary = {}
var _dungeon_names: Dictionary = {}
var _areas: Dictionary = {}
var _reward_flags: Dictionary = {}
## Keys built at run time by a generator (a format string or a ZoneDef field) -> where they come from. Built by calling the generators,
## so a key outside their real output (a typo, a missing arena bout) still counts as unproduced.
var _generated: Dictionary = {}
var _zone_spots: Dictionary = {}


static func run() -> QuestAudit:
	var audit: QuestAudit = QuestAudit.new()
	audit._scan()
	audit._check()
	return audit


func _scan() -> void:
	_content = ContentLibrary.load_all()
	for dir_path: String in SOURCE_DIRS:
		_read_dir(dir_path, ".gd")
	for dir_path: String in DATA_DIRS:
		_read_dir(dir_path, ".json")
	var parts: PackedStringArray = []
	var const_re: RegEx = RegEx.create_from_string("const\\s+([A-Z0-9_]+)\\s*(?::\\s*\\w+)?\\s*:?=\\s*&?\"([^\"]+)\"")
	for path: String in _sources.keys():
		var lines: PackedStringArray = _sources[path]
		var is_quest_file: bool = path in QUEST_SOURCES
		for line: String in lines:
			for m: RegExMatch in const_re.search_all(line):
				var value: String = m.get_string(2)
				if not _consts.has(value):
					_consts[value] = []
				(_consts[value] as Array).append(m.get_string(1))
			if is_quest_file and "Condition." in line:
				continue
			for mark: String in PRODUCER_MARKS:
				if mark in line:
					_producer_lines.append(line)
					break
		if not is_quest_file:
			parts.append("\n".join(lines))
	_all_text_no_quests = "\n".join(parts)
	for quest: QuestData in QuestCatalog.all():
		_quest_ids[quest.id] = true
		for flag_name: String in quest.reward_unlock_flags:
			_reward_flags[flag_name] = quest.id
		for objective: QuestObjective in quest.objectives:
			if objective.milestone != null:
				for flag_name: String in objective.milestone.unlock_flags:
					_reward_flags[flag_name] = quest.id
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		_dungeon_names[blueprint.dungeon_name] = true
	for zone_id: String in ZoneDefs.all_ids():
		_areas[zone_id] = true
	for extra: String in AREAS_EXTRA:
		_areas[extra] = true
	_collect_generated()


## ZoneDef fields whose values the generic zone handlers set (field name -> the handler that sets it).
const ZONE_DEF_PRODUCED: Array[String] = ["flag_quiz_done", "flag_quiz_passed", "flag_puzzle_solved", "flag_mini_cleared", "flag_minigame_first",
	"counter_chests", "counter_enemies"]


func _collect_generated() -> void:
	for zone_id: String in Gatekeepers.IDS:
		_generated[str(Gatekeepers.entered_flag(zone_id))] = "Gatekeepers.entered_flag (GameSession, first entry)"
	for n: int in range(1, MemoryDefs.COUNT + 1):
		_generated[str(MemoryDefs.flag_name(n))] = "MemoryDefs.flag_name (memory recovered)"
	for table: String in CardMatchCircuit.ZONES + [CardMatchCircuit.FINAL]:
		_generated[CardMatchCircuit.flag_name(table)] = "CardMatchCircuit.flag_name (table beaten)"
	for encounter: ArenaEncounter in ArenaDefs.all():
		_generated[str(ArenaDefs.flag_name(encounter.id))] = "ArenaDefs.flag_name (bout won)"
	for barricade: HeapGrowth.Barricade in HeapGrowth.barricades():
		_generated[str(barricade.flag)] = "HeapGrowth barricade smashed"
	for zone_id: String in ZoneDefs.all_ids():
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		if def == null:
			continue
		for field: String in ZONE_DEF_PRODUCED:
			var value: String = str(def.get(field))
			if not value.is_empty():
				_generated[value] = "ZoneDef.%s of %s" % [field, zone_id]
		for spot: Dictionary in def.spots:
			_zone_spots[str(spot.get("id", ""))] = zone_id


func _read_dir(dir_path: String, ext: String) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		var full: String = dir_path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				_read_dir(full, ext)
		elif entry.ends_with(ext):
			var text: String = FileAccess.get_file_as_string(full)
			_sources[full] = text.replace("\r", "").split("\n")
		entry = dir.get_next()
	dir.list_dir_end()


func _check() -> void:
	for quest: QuestData in QuestCatalog.all():
		_check_quest(quest)
	_check_cycles()


func _check_quest(quest: QuestData) -> void:
	var where: String = "quest %s" % quest.id
	# Rewards
	_check_rewards(where, quest.reward_item_ids, quest.reward_card_ids, quest.reward_equipment_ids, quest.reward_pack_ids)
	# Giver / turn-in
	if not _areas.has(quest.giver_area):
		errors.append("%s: giver area '%s' is not an area" % [where, quest.giver_area])
	if not _areas.has(quest.turn_in_area):
		errors.append("%s: turn-in area '%s' is not an area" % [where, quest.turn_in_area])
	if not quest.auto_give:
		if quest.giver_npc.is_empty():
			if not _started_by_code(quest.id):
				errors.append("%s: not auto-given, no giver NPC, and no script starts it" % where)
		elif not _name_is_used(quest.giver_npc) and not _started_by_code(quest.id):
			errors.append("%s: giver '%s' stands nowhere (no world script or data row uses that name)" % [where, quest.giver_npc])
	if not quest.turn_in_npc.is_empty() and not _name_is_used(quest.turn_in_npc):
		errors.append("%s: turn-in NPC '%s' stands nowhere" % [where, quest.turn_in_npc])
	if not quest.turn_in_npc.is_empty() and quest.turn_in_area.is_empty():
		warnings.append("%s: turn-in NPC '%s' has no turn-in area (no '?' mark, no goal pointer)" % [where, quest.turn_in_npc])
	for spot: String in [quest.giver_spot, quest.turn_in_spot]:
		if not spot.is_empty() and not _spot_declared(spot):
			errors.append("%s: spot '%s' is declared by no world script or zone" % [where, spot])
	# Prerequisite
	_check_condition(where + " prerequisite", quest.prerequisite, quest, -1)
	# Steps
	var step_texts: PackedStringArray = []
	for i: int in quest.objectives.size():
		var objective: QuestObjective = quest.objectives[i]
		var step_where: String = "%s step %d (%s)" % [where, i + 1, objective.text]
		if objective.condition == null:
			warnings.append("%s: no condition (always done)" % step_where)
		_check_condition(step_where, objective.condition, quest, i)
		if not _areas.has(objective.target_area):
			errors.append("%s: target area '%s' is not an area" % [step_where, objective.target_area])
		if not objective.target_id.is_empty() and objective.target_id != QuestDefinitions.OUTSKIRTS_SPOT and not _spot_declared(objective.target_id):
			errors.append("%s: target spot '%s' is declared by no world script or zone" % [step_where, objective.target_id])
		if objective.milestone != null:
			var m: QuestReward = objective.milestone
			_check_rewards(step_where + " milestone", m.item_ids, m.card_ids, m.equipment_ids, m.pack_ids)
		step_texts.append("%d. %s [%s]" % [i + 1, objective.text, _describe(objective.condition)])
	rows.append({
		"id": quest.id, "title": quest.title, "category": quest.category_tag(),
		"start": "auto" if quest.auto_give else ("%s @ %s/%s" % [quest.giver_npc, quest.giver_area, quest.giver_spot] if not quest.giver_npc.is_empty() else "script"),
		"prereq": _describe(quest.prerequisite), "steps": step_texts,
		"turn_in": ("%s @ %s/%s" % [quest.turn_in_npc, quest.turn_in_area, quest.turn_in_spot]) if not quest.turn_in_npc.is_empty() else "on completion",
	})


func _check_rewards(where: String, items: Array[String], cards: Array[String], equipment: Array[String], packs: Array[String]) -> void:
	for id: String in items:
		if not _content.items.has(id):
			errors.append("%s: reward item '%s' does not exist" % [where, id])
	for id: String in cards:
		if not _card_exists(id):
			errors.append("%s: reward card '%s' does not exist" % [where, id])
	for id: String in equipment:
		if not _content.equipment.has(id) and not _content.zone_equipment.has(id):
			errors.append("%s: reward equipment '%s' does not exist" % [where, id])
	for id: String in packs:
		if PackCatalog.find(id) == null:
			errors.append("%s: reward pack '%s' does not exist" % [where, id])


func _card_exists(id: String) -> bool:
	return _content.cards.has(id) or _content.multipath_cards.has(id) or _content.zone_cards.has(id)


func _check_condition(where: String, condition: Condition, quest: QuestData, step: int) -> void:
	if condition == null:
		return
	match condition.kind:
		Condition.Kind.ALL_OF, Condition.Kind.ANY_OF:
			for sub: Condition in condition.sub_conditions:
				_check_condition(where, sub, quest, step)
		Condition.Kind.QUEST_COMPLETED:
			if not _quest_ids.has(condition.key):
				errors.append("%s: needs quest '%s', which does not exist" % [where, condition.key])
			elif condition.key == quest.id:
				errors.append("%s: needs itself" % where)
		Condition.Kind.DUNGEON_CLEARED:
			if not _dungeon_names.has(condition.key) and not _literal_used(condition.key):
				errors.append("%s: needs dungeon '%s', which does not exist" % [where, condition.key])
		Condition.Kind.CARD_OWNED:
			if not _card_exists(condition.key):
				errors.append("%s: needs card '%s', which does not exist" % [where, condition.key])
		Condition.Kind.FLAG_SET, Condition.Kind.COUNTER, Condition.Kind.SECRET_FOUND:
			if condition.key.is_empty():
				errors.append("%s: empty key" % where)
			elif not _has_producer(condition.key):
				errors.append("%s: %s '%s' is set by nothing (no producer found)" % [where, Condition.Kind.keys()[condition.kind].to_lower(), condition.key])
			if condition.kind == Condition.Kind.COUNTER and step >= 0 and not QuestLog.counts_lifetime(condition.key):
				var once: String = _once_ever_bump(condition.key)
				if not once.is_empty():
					errors.append("%s: counter '%s' counts from acceptance but is bumped by a once-ever action (%s) - add it to QuestLog.LIFETIME_COUNTERS" % [where, condition.key, once])
				for hint: String in ONE_SHOT_COUNTER_HINTS:
					if hint in condition.key:
						warnings.append("%s: counter '%s' counts from acceptance and sounds one-time - check it can still move after an early win" % [where, condition.key])
						break


## The first bump site of a counter that sits behind a once-ever guard (a found / discovered secret), as "file:line", or "".
func _once_ever_bump(key: String) -> String:
	var names: Array = _consts.get(key, []) as Array
	for path: String in _sources.keys():
		if path in QUEST_SOURCES or not path.ends_with(".gd"):
			continue
		var lines: PackedStringArray = _sources[path]
		for i: int in lines.size():
			var line: String = lines[i]
			if not "bump_counter(" in line:
				continue
			var hit: bool = ("\"%s\"" % key) in line
			for const_name: Variant in names:
				hit = hit or _word_in(str(const_name), line)
			if not hit:
				continue
			for j: int in range(maxi(0, i - 10), i):
				if "found_secret(" in lines[j] or "discover_secret(" in lines[j]:
					return "%s:%d" % [path.get_file(), i + 1]
	return ""


func _check_cycles() -> void:
	var needs: Dictionary = {}
	for quest: QuestData in QuestCatalog.all():
		var found: Array[String] = []
		_collect_quest_needs(quest.prerequisite, found)
		needs[quest.id] = found
	for start: String in needs.keys():
		var seen: Dictionary = {}
		var stack: Array[String] = [start]
		while not stack.is_empty():
			var current: String = stack.pop_back()
			for next: String in needs.get(current, []):
				if next == start:
					errors.append("quest %s: prerequisite cycle (back through %s)" % [start, current])
					stack.clear()
					break
				if not seen.has(next):
					seen[next] = true
					stack.append(next)


func _collect_quest_needs(condition: Condition, into: Array[String]) -> void:
	if condition == null:
		return
	if condition.kind == Condition.Kind.QUEST_COMPLETED:
		into.append(condition.key)
	elif condition.kind == Condition.Kind.ALL_OF:
		for sub: Condition in condition.sub_conditions:
			_collect_quest_needs(sub, into)


func _has_producer(key: String) -> bool:
	if _reward_flags.has(key):
		return true
	if _generated.has(key):
		return true
	var quoted: String = "\"%s\"" % key
	var names: Array = _consts.get(key, []) as Array
	for line: String in _producer_lines:
		if quoted in line:
			return true
		for const_name: Variant in names:
			if _word_in(str(const_name), line):
				return true
	# A constant holding the key passed to a setter helper elsewhere (e.g. `_mark(FLAG_X)` whose body calls set_flag).
	for const_name: Variant in names:
		if _const_used_beyond_declaration(str(const_name)):
			return _const_reaches_setter(str(const_name))
	return false


func _const_used_beyond_declaration(const_name: String) -> bool:
	var count: int = 0
	for path: String in _sources.keys():
		if path in QUEST_SOURCES:
			continue
		for line: String in _sources[path]:
			if _word_in(const_name, line) and not line.strip_edges().begins_with("const "):
				count += 1
	return count > 0


## True when a line outside the quest files hands the constant to a function whose body sets a flag / counter / secret.
func _const_reaches_setter(const_name: String) -> bool:
	var call_re: RegEx = RegEx.create_from_string("(\\w+)\\([^)]*\\b%s\\b" % const_name)
	for path: String in _sources.keys():
		if path in QUEST_SOURCES:
			continue
		for line: String in _sources[path]:
			if not _word_in(const_name, line) or line.strip_edges().begins_with("const "):
				continue
			for m: RegExMatch in call_re.search_all(line):
				if _function_sets(m.get_string(1)):
					return true
	return false


func _function_sets(func_name: String) -> bool:
	for path: String in _sources.keys():
		var lines: PackedStringArray = _sources[path]
		for i: int in lines.size():
			if not lines[i].contains("func %s(" % func_name):
				continue
			for j: int in range(i + 1, mini(i + 25, lines.size())):
				if lines[j].begins_with("func ") or lines[j].begins_with("static func "):
					break
				for mark: String in ["set_flag(", "bump_counter(", "found_secret(", "flags[", "counters["]:
					if mark in lines[j]:
						return true
	return false


func _started_by_code(quest_id: String) -> bool:
	var quoted: String = "\"%s\"" % quest_id
	var names: Array = _consts.get(quest_id, []) as Array
	for path: String in _sources.keys():
		for line: String in _sources[path]:
			if not "start_quest(" in line:
				continue
			if quoted in line:
				return true
			for const_name: Variant in names:
				if _word_in(str(const_name), line):
					return true
			if "quest_id" in line or ".id" in line:
				# a generic start (start_quest(quest_id) / start_quest(quest.id)) - callers pass the id along; trust it when the id is used elsewhere
				if _literal_used(quest_id):
					return true
	return false


func _name_is_used(npc_name: String) -> bool:
	if _literal_used(npc_name):
		return true
	for const_name: Variant in _consts.get(npc_name, []) as Array:
		if _const_used_beyond_declaration(str(const_name)):
			return true
	return false


func _spot_declared(spot: String) -> bool:
	return _zone_spots.has(spot) or _literal_used(spot) or _consts.has(spot) or spot.begins_with("portal_") or spot.begins_with("npc_")


func _literal_used(text: String) -> bool:
	return ("\"%s\"" % text) in _all_text_no_quests or ("&\"%s\"" % text) in _all_text_no_quests


static func _word_in(word: String, line: String) -> bool:
	var at: int = line.find(word)
	while at >= 0:
		var before_ok: bool = at == 0 or not _is_word_char(line[at - 1])
		var after: int = at + word.length()
		var after_ok: bool = after >= line.length() or not _is_word_char(line[after])
		if before_ok and after_ok:
			return true
		at = line.find(word, at + 1)
	return false


static func _is_word_char(c: String) -> bool:
	return (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or (c >= "0" and c <= "9") or c == "_"


static func _describe(condition: Condition) -> String:
	if condition == null:
		return "-"
	match condition.kind:
		Condition.Kind.ALL_OF:
			return "all(" + ", ".join(condition.sub_conditions.map(func(c: Condition) -> String: return _describe(c))) + ")"
		Condition.Kind.ANY_OF:
			return "any(" + ", ".join(condition.sub_conditions.map(func(c: Condition) -> String: return _describe(c))) + ")"
		Condition.Kind.POSTGAME:
			return "postgame"
		Condition.Kind.PLAYER_LEVEL, Condition.Kind.GOLD_SPENT, Condition.Kind.ZONES_COMPLETED:
			return "%s>=%d" % [Condition.Kind.keys()[condition.kind].to_lower(), condition.amount]
	var text: String = "%s:%s" % [Condition.Kind.keys()[condition.kind].to_lower(), condition.key]
	if condition.amount > 1:
		text += " x%d" % condition.amount
	return text


## The markdown report (graph + findings).
func report() -> String:
	var out: PackedStringArray = ["# Quest audit", "", "Generated by `tools/quest_audit.gd` (`bash tools/quest_audit.sh`). %d quests, %d errors, %d warnings." % [rows.size(), errors.size(), warnings.size()], ""]
	out.append("## Errors")
	out.append("")
	if errors.is_empty():
		out.append("None.")
	for e: String in errors:
		out.append("- " + e)
	out.append("")
	out.append("## Warnings (read by hand)")
	out.append("")
	if warnings.is_empty():
		out.append("None.")
	for w: String in warnings:
		out.append("- " + w)
	out.append("")
	out.append("## Graph")
	out.append("")
	for row: Dictionary in rows:
		out.append("### %s - %s (%s)" % [row["id"], row["title"], row["category"]])
		out.append("- starts: %s; needs: %s; hands in: %s" % [row["start"], row["prereq"], row["turn_in"]])
		for step: String in row["steps"]:
			out.append("  - " + step)
		out.append("")
	return "\n".join(out)
