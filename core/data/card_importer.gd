class_name CardImporter
extends RefCounted
## The card pipeline (docs/card_pipeline.md): reads the exported Google Sheet CSVs (`data/source/card_list.csv`,
## `token_list.csv`), attaches each card's script from `data/scripts/*.txt`, and produces `CardData` keyed by Card ID.
## `tools/import_cards.gd` writes the resources and the import report; tests use the same functions.

const CARD_CSV: String = "res://data/source/card_list.csv"
const TOKEN_CSV: String = "res://data/source/token_list.csv"
const OVERRIDES_CSV: String = "res://data/source/card_overrides.csv"
const SCRIPT_DIR: String = "res://data/scripts/"
const CARD_DIR: String = "res://data/cards/"
const TOKEN_DIR: String = "res://data/tokens/"

## Card sheet columns.
const COL_SECTION: int = 0
const COL_RARITY: int = 1
const COL_NAME: int = 2
const COL_COST: int = 3
const COL_TYPE: int = 4
const COL_TEXT: int = 5
const COL_STATS: int = 6
const COL_FLAVOR: int = 7
const COL_IMAGE: int = 8
const COL_ID: int = 14


## One imported card or token with everything the report needs.
class Entry:
	extends RefCounted
	var id: String = ""
	var is_token: bool = false
	var data: CardData
	var rules_text: String = ""
	## Hash of the sheet's rules text now, and the hash recorded in the script when it was written.
	var text_hash: String = ""
	var script_hash: String = ""
	var has_script: bool = false
	var problems: Array[String] = []
	var unsupported: Array[String] = []


# ---- CSV --------------------------------------------------------------------------------------------


static func read_csv(path: String) -> Array[PackedStringArray]:
	var rows: Array[PackedStringArray] = []
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return rows
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() == 1 and row[0].is_empty():
			continue
		rows.append(row)
	return rows


## Hash of a rules text (whitespace-insensitive), stored with each script to detect later edits in the sheet.
static func hash_text(text: String) -> String:
	var normalized: String = text.replace("\r", "").strip_edges()
	var regex: RegEx = RegEx.new()
	regex.compile("\\s+")
	normalized = regex.sub(normalized, " ", true)
	return normalized.md5_text().substr(0, 12)


# ---- Scripts -----------------------------------------------------------------------------------------


## All scripts in data/scripts/*.txt: Card ID -> {"text": body, "hash": recorded hash ("" if none), "file": path}.
static func load_scripts() -> Dictionary:
	var scripts: Dictionary = {}
	var dir: DirAccess = DirAccess.open(SCRIPT_DIR)
	if dir == null:
		return scripts
	var files: Array[String] = []
	for file_name: String in dir.get_files():
		if file_name.ends_with(".txt"):
			files.append(file_name)
	files.sort()
	var header: RegEx = RegEx.new()
	header.compile("^==\\s+(\\S+)(?:\\s+@([0-9a-f]+))?")
	for file_name: String in files:
		var file: FileAccess = FileAccess.open(SCRIPT_DIR + file_name, FileAccess.READ)
		if file == null:
			continue
		var current_id: String = ""
		var body: Array[String] = []
		var current_hash: String = ""
		for line: String in file.get_as_text().split("\n"):
			var found: RegExMatch = header.search(line)
			if found != null:
				if not current_id.is_empty():
					scripts[current_id] = {"text": "\n".join(body).strip_edges(), "hash": current_hash, "file": SCRIPT_DIR + file_name}
				current_id = found.get_string(1)
				current_hash = found.get_string(2)
				body = []
			elif not current_id.is_empty():
				body.append(line.strip_edges(false, true))
		if not current_id.is_empty():
			scripts[current_id] = {"text": "\n".join(body).strip_edges(), "hash": current_hash, "file": SCRIPT_DIR + file_name}
	return scripts


## `data/source/card_overrides.csv` (Card ID, not_in_packs): the hand-maintained flags that survive a re-import.
static func load_overrides() -> Dictionary:
	var overrides: Dictionary = {}
	var rows: Array[PackedStringArray] = read_csv(OVERRIDES_CSV)
	for index: int in range(1, rows.size()):
		var row: PackedStringArray = rows[index]
		if row.size() >= 2 and not row[0].strip_edges().is_empty():
			overrides[row[0].strip_edges()] = {"not_in_packs": row[1].strip_edges().to_lower() == "true"}
	return overrides


# ---- Cards --------------------------------------------------------------------------------------------


## Parses the card sheet. Rows with a value in "Card ID" are cards; rows with only a first column ending in ":" set the Path section.
static func parse_cards() -> Array[Entry]:
	var entries: Array[Entry] = []
	var rows: Array[PackedStringArray] = read_csv(CARD_CSV)
	var section_paths: Array[Affinity.Type] = []
	for index: int in range(1, rows.size()):
		var row: PackedStringArray = rows[index]
		if row.size() <= COL_ID:
			continue
		var id: String = row[COL_ID].strip_edges()
		if id.is_empty():
			var header: String = row[COL_SECTION].strip_edges()
			if header.ends_with(":") and row[COL_NAME].strip_edges().is_empty():
				section_paths = paths_from_section(header)
			continue
		var entry: Entry = Entry.new()
		entry.id = id
		entry.rules_text = row[COL_TEXT].strip_edges()
		entry.data = _card_from_row(row, id, section_paths)
		entries.append(entry)
	return entries


static func paths_from_section(header: String) -> Array[Affinity.Type]:
	var result: Array[Affinity.Type] = []
	var lowered: String = header.to_lower()
	if lowered.contains("4 color"):
		return Affinity.colored_types()
	for path: Affinity.Type in Affinity.colored_types():
		if lowered.contains(Affinity.display_name(path).to_lower()):
			result.append(path)
	return result


static func _card_from_row(row: PackedStringArray, id: String, section_paths: Array[Affinity.Type]) -> CardData:
	var card: CardData = CardData.new()
	card.id = id
	card.display_name = row[COL_NAME].strip_edges()
	card.type = type_from_text(row[COL_TYPE])
	card.rules_text = row[COL_TEXT].strip_edges()
	card.flavor_text = row[COL_FLAVOR].strip_edges()
	card.image_description = row[COL_IMAGE].strip_edges()
	var rarity_text: String = row[COL_RARITY]
	card.rarity = rarity_from_text(rarity_text)
	card.is_signature = rarity_text.to_lower().contains("signature")
	_apply_cost(card, row[COL_COST])
	if card.type == CardEnums.CardType.UNIT:
		var stats: PackedStringArray = row[COL_STATS].strip_edges().split("/")
		if stats.size() == 2 and stats[0].strip_edges().is_valid_int() and stats[1].strip_edges().is_valid_int():
			card.attack = int(stats[0])
			card.defense = int(stats[1])
	else:
		card.attack = 0
		card.defense = 0
	_apply_paths(card, section_paths)
	card.is_basic = id.begins_with("BAS-")
	return card


static func type_from_text(text: String) -> CardEnums.CardType:
	match text.strip_edges().to_lower():
		"unit":
			return CardEnums.CardType.UNIT
		"spell":
			return CardEnums.CardType.SPELL
		"trap":
			return CardEnums.CardType.TRAP
		"tool":
			return CardEnums.CardType.TOOL
		"wonder":
			return CardEnums.CardType.WONDER
		"infrastructure":
			return CardEnums.CardType.INFRASTRUCTURE
	return CardEnums.CardType.UNIT


static func rarity_from_text(text: String) -> CardEnums.Rarity:
	if text.contains("(U)"):
		return CardEnums.Rarity.UNCOMMON
	if text.contains("(E)"):
		return CardEnums.Rarity.EPIC
	if text.contains("(L)"):
		return CardEnums.Rarity.LEGENDARY
	return CardEnums.Rarity.COMMON


## "3(R)(R)(R)", "(G)", "1 (R)", "2", "N/A": generic digits first, then one colored pip per (X).
static func _apply_cost(card: CardData, text: String) -> void:
	card.generic_cost = 0
	card.colored_pips = [] as Array[Affinity.Type]
	var cleaned: String = text.strip_edges()
	if cleaned.is_empty() or cleaned.to_upper() == "N/A":
		return
	var digits: String = ""
	var index: int = 0
	while index < cleaned.length():
		var character: String = cleaned[index]
		if character.is_valid_int():
			digits += character
		elif character == "(":
			var close: int = cleaned.find(")", index)
			if close > index:
				var path: Affinity.Type = Affinity.from_symbol(cleaned.substr(index + 1, close - index - 1))
				if path != Affinity.Type.NEUTRAL:
					card.colored_pips.append(path)
				index = close
		index += 1
	card.generic_cost = int(digits) if not digits.is_empty() else 0


static func _apply_paths(card: CardData, paths: Array[Affinity.Type]) -> void:
	card.paths_all = paths.duplicate()
	card.color = paths[0] if paths.size() >= 1 else Affinity.Type.NEUTRAL
	card.color2 = paths[1] if paths.size() >= 2 else Affinity.Type.NEUTRAL


# ---- Tokens ---------------------------------------------------------------------------------------------


static func parse_tokens() -> Array[Entry]:
	var entries: Array[Entry] = []
	var rows: Array[PackedStringArray] = read_csv(TOKEN_CSV)
	for index: int in range(1, rows.size()):
		var row: PackedStringArray = rows[index]
		if row.size() < 7 or row[0].strip_edges().is_empty():
			continue
		var entry: Entry = Entry.new()
		entry.id = row[0].strip_edges()
		entry.is_token = true
		entry.rules_text = row[3].strip_edges()
		var card: CardData = CardData.new()
		card.id = entry.id
		card.display_name = row[1].strip_edges()
		card.is_token = true
		card.not_in_packs = true
		card.rules_text = row[3].strip_edges()
		card.flavor_text = row[5].strip_edges()
		card.image_description = row[6].strip_edges()
		var type_text: String = row[2].to_lower()
		if type_text.begins_with("resource token"):
			card.type = CardEnums.CardType.RESOURCE
			card.resource_kind = ResourceKind.from_card_id(entry.id)
			card.defense = 0
		elif type_text.begins_with("special token"):
			card.type = CardEnums.CardType.TOKEN
			card.resource_kind = ResourceKind.from_card_id(entry.id)
			card.defense = 0
		else:
			card.type = CardEnums.CardType.UNIT
			var stats: PackedStringArray = row[4].strip_edges().split("/")
			if stats.size() == 2 and stats[0].strip_edges().is_valid_int() and stats[1].strip_edges().is_valid_int():
				card.attack = int(stats[0])
				card.defense = int(stats[1])
			else:
				card.attack = 0
				card.defense = 0
		var paths: Array[Affinity.Type] = []
		for path: Affinity.Type in Affinity.colored_types():
			if type_text.contains(Affinity.display_name(path).to_lower()):
				paths.append(path)
		_apply_paths(card, paths)
		entry.data = card
		entries.append(entry)
	return entries


## The three resources the token sheet does not list (they are only described in the Design Guidance), and the Capital's junk card.
static func extra_resource_tokens() -> Array[Entry]:
	var entries: Array[Entry] = []
	for kind: ResourceKind.Kind in [ResourceKind.Kind.IRON, ResourceKind.Kind.INGREDIENT, ResourceKind.Kind.GARBAGE]:
		var entry: Entry = Entry.new()
		entry.id = ResourceKind.card_id(kind)
		entry.is_token = true
		entry.data = ResourceRules.data_for(kind).duplicate() as CardData
		entry.rules_text = entry.data.rules_text
		entry.data.paths_all = [ResourceKind.path_of(kind)] as Array[Affinity.Type]
		entries.append(entry)
	entries.append(_junk_entry())
	return entries


## The junk card the Capital's Clutter service debuff shuffles into your deck (not in the sheets).
static func _junk_entry() -> Entry:
	var entry: Entry = Entry.new()
	entry.id = "JUNK-01"
	entry.is_token = true
	var card: CardData = CardData.new()
	card.id = entry.id
	card.display_name = "Heap of Rubbish"
	card.type = CardEnums.CardType.TOKEN
	card.is_token = true
	card.not_in_packs = true
	card.generic_cost = 1
	card.defense = 0
	card.rules_text = "You lose 1 HP. Somebody has to take it out."
	card.flavor_text = "Banished behind the facade for being untidy. It did not go quietly."
	card.image_description = "A teetering heap of tidy-looking rubbish bags with one unmistakably untidy banana peel on top."
	entry.rules_text = card.rules_text
	entry.data = card
	return entry


# ---- Putting it together --------------------------------------------------------------------------------


## Every card and token from the sheets, with scripts, keywords and flags attached and problems collected.
static func build_all() -> Array[Entry]:
	var scripts: Dictionary = load_scripts()
	var overrides: Dictionary = load_overrides()
	var all_entries: Array[Entry] = []
	all_entries.append_array(parse_cards())
	all_entries.append_array(parse_tokens())
	all_entries.append_array(extra_resource_tokens())
	for entry: Entry in all_entries:
		attach_script(entry, scripts)
		if overrides.has(entry.id):
			entry.data.not_in_packs = bool((overrides[entry.id] as Dictionary).get("not_in_packs", false))
	return all_entries


static func attach_script(entry: Entry, scripts: Dictionary) -> void:
	entry.text_hash = hash_text(entry.rules_text)
	entry.data.rules_hash = entry.text_hash
	if not scripts.has(entry.id):
		entry.has_script = false
		if _needs_script(entry):
			entry.problems.append("no script")
		return
	var script: Dictionary = scripts[entry.id] as Dictionary
	entry.has_script = true
	entry.script_hash = str(script["hash"])
	entry.data.script_text = str(script["text"])
	var parsed: ScriptParser.Parsed = ScriptParser.parse(entry.data.script_text)
	for message: String in parsed.errors:
		entry.problems.append(message)
	entry.unsupported.append_array(unsupported_names(parsed))
	entry.data.keywords = parsed.keywords.duplicate()
	if entry.data.is_infrastructure():
		var produced: Array[Affinity.Type] = parsed.produces.duplicate()
		entry.data.produces_any = parsed.produces_any
		if not produced.is_empty():
			_apply_paths(entry.data, produced)


## A card with no rules text (vanilla units, or a token with nothing to script) needs no script.
static func _needs_script(entry: Entry) -> bool:
	if entry.data.is_resource():
		return false
	return not entry.rules_text.strip_edges().is_empty()


## Ops, value functions, events and flags in a parsed script that the engine does not implement.
static func unsupported_names(parsed: ScriptParser.Parsed) -> Array[String]:
	var found: Array[String] = []
	for ability: CardAbility in parsed.abilities:
		if not ability.event.is_empty() and not GameState.EVENT_NAMES.has(ability.event):
			_note(found, "event '%s'" % ability.event)
		for fx: CardAbility.Fx in ability.effects:
			_check_fx(fx, true, found)
		if ability.condition != null:
			_check_fx(ability.condition, false, found)
	return found


static func _check_fx(fx: CardAbility.Fx, as_effect: bool, found: Array[String]) -> void:
	if as_effect:
		if not AbilityOps.OP_NAMES.has(fx.name):
			_note(found, "op '%s'" % fx.name)
		if fx.name == "flag" and not fx.args.is_empty() and not StaticEffects.FLAG_NAMES.has(str(fx.args[0])):
			_note(found, "flag '%s'" % str(fx.args[0]))
	elif not AbilityRunner.VALUE_NAMES.has(fx.name):
		_note(found, "value '%s'" % fx.name)
	for arg: Variant in fx.args:
		if arg is CardAbility.Fx:
			_check_fx(arg as CardAbility.Fx, false, found)
		elif arg is CardAbility.FxBlock:
			for inner: CardAbility.Fx in (arg as CardAbility.FxBlock).effects:
				_check_fx(inner, true, found)


static func _note(found: Array[String], message: String) -> void:
	if not found.has(message):
		found.append(message)
