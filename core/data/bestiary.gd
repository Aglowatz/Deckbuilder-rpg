class_name Bestiary
extends RefCounted
## Overnight Oct 17, Part 10: every enemy and boss (data/bestiary/bestiary.json): unknown until met, then its picture, a fun line,
## where it lives and how often it was beaten. Met / defeated counts live in the save's counters ("bestiary_met:<name>",
## "bestiary_won:<name>"), recorded when a battle starts and is won (`Session.start_battle` / `complete_battle`) or when a roamer
## that never fights touches the hero. Completion milestones (25/50/75/100 %) pay small rewards. Pure data: no scene tree.

const PATH: String = "res://data/bestiary/bestiary.json"
const MET_PREFIX: String = "bestiary_met:"
const WON_PREFIX: String = "bestiary_won:"
const FALLBACK_ICON: String = "lorc/magic-swirl"
## Overnight Oct 28 (the roster review, docs/design/enemy_roster_oct28.md): roamers renamed, old battle name -> new. Old saves' met / won
## counters and an old BST-* picture on disk keep working through `canonical`, `met_count` / `won_count` and `art`.
const RENAMED: Dictionary = {
	"Stray Gym Hound": "Pantry Hound", "Flexing Brute": "Quota Spotter", "Zombie Intern": "Unpaid Intern",
	"Possessed Scarecrow Druid": "Hungry Scarecrow", "Compliance Officer": "Correction Officer",
}
## A boss / lieutenant / gatekeeper entrance cut-out is a Portrait Image ID "CUT-<NPC key>" (CUT-CLENCH for NPC-CLENCH), imported by
## "import portraits" beside the dialogue portraits (`Portraits.known_portraits`). Until it exists the intro shows the transparent
## dialogue portrait itself, and the Bestiary square when there is no portrait either (`cutout`).
const CUTOUT_PREFIX: String = "CUT-"
## A roaming enemy's painted sprite set is the world-sprite character "FOE-<slug of its name>" (FOE-QUOTA-SPOTTER: files
## SPR-FOE-QUOTA-SPOTTER-FRONT_IDLE.png..., imported by "import npc sprites"); `ZoneEnemy` draws it instead of the 3D model once it exists.
const SPRITE_PREFIX: String = "FOE-"
## Discovery milestones: percent met -> reward ({gold} or {pack: "path"/id}). Paid once each (flag "bestiary_<percent>").
const MILESTONES: Array[Dictionary] = [
	{"percent": 25, "gold": 100},
	{"percent": 50, "pack": "path"},
	{"percent": 75, "gold": 250},
	{"percent": 100, "pack": "gilded"},
]


class Entry:
	extends RefCounted
	var name: String = ""
	var kind: String = "foe"
	var where: String = ""
	var icon: String = FALLBACK_ICON
	var blurb: String = ""

	func is_boss() -> bool:
		return kind == "boss"


static var _entries: Array[Entry] = []
## Overnight Oct 17 (Phase 2 cycle 15): an enemy's picture, when one has been made - assets/art/bestiary/<art_id>.webp (or .png), the ids and
## prompts in docs/art/bestiary_image_requests.md (`node tools/bestiary_requests.js`). Without one the Collection Book and the battle plate keep the icon.
const ART_DIR: String = "res://assets/art/bestiary"
static var _art_cache: Dictionary = {}


## Forgets the remembered pictures (after `BestiaryArt.import_from_source`, and in tests) so a newly imported BST-* file shows.
static func reset_art() -> void:
	_art_cache = {}


## "Cave Scavenger" -> "BST-CAVE-SCAVENGER" (letters and digits, everything else a single dash).
static func art_id(entry_name: String) -> String:
	return "BST-" + slug(canonical(entry_name))


## The world-sprite character key of an enemy: "FOE-" + the same slug as its Bestiary picture ("Quota Spotter" -> "FOE-QUOTA-SPOTTER").
static func sprite_key(entry_name: String) -> String:
	return SPRITE_PREFIX + slug(canonical(entry_name))


## The Bestiary picture ids an old name of a renamed enemy used (so a picture made under the old name still shows).
static func legacy_art_ids(entry_name: String) -> Array[String]:
	var key: String = canonical(entry_name)
	var ids: Array[String] = []
	for old: String in RENAMED:
		if str(RENAMED[old]) == key:
			ids.append("BST-" + slug(old))
	return ids


## Upper-case letters and digits of `text`, everything else a single dash.
static func slug(text: String) -> String:
	var slug: String = ""
	for character: String in text.to_upper():
		var code: int = character.unicode_at(0)
		var keep: bool = (code >= 65 and code <= 90) or (code >= 48 and code <= 57)
		if keep:
			slug += character
		elif not slug.ends_with("-") and not slug.is_empty():
			slug += "-"
	return slug.trim_suffix("-")


## The picture of an entry (by name), or null when none has been made yet. Remembered per name.
## Overnight Oct 18, Phase 2 cycle 13: without a bestiary picture, an enemy who is also a speaking character (a boss, a corrupted NPC, Shiro...)
## shows the head and shoulders of their dialogue portrait.
static func art(entry_name: String) -> Texture2D:
	var id: String = art_id(entry_name)
	if _art_cache.has(id):
		return _art_cache[id] as Texture2D
	var texture: Texture2D = null
	var candidates: Array[String] = [id]
	candidates.append_array(legacy_art_ids(entry_name))
	for candidate: String in candidates:
		for extension: String in ["webp", "png"]:
			var path: String = "%s/%s.%s" % [ART_DIR, candidate, extension]
			if ResourceLoader.exists(path):
				texture = load(path) as Texture2D
				break
		if texture != null:
			break
	if texture == null:
		texture = portrait_art(entry_name)
	_art_cache[id] = texture
	return texture


## Bestiary names that differ from the speaking character's name in the NPC list.
const PORTRAIT_ALIASES: Dictionary = {
	"Hollow Warden": "NPC-WARDEN", "Primm, His Perfection": "NPC-PRIMM", "Enforcer Captain Spotless": "NPC-SPOTLESS",
	"The Old Kingdom Automaton": "NPC-AUTOMATON", "Dr. Ambrose Siphon, Chief Path-ologist": "NPC-SIPHON", "The Warden of the Four Seals": "NPC-VAULTWARDEN",
}


## The NPC list id of the speaking character an enemy name belongs to ("" for a nameless foe): an alias, else the registry's speaker lookup.
static func portrait_npc_id(entry_name: String) -> String:
	var npc_id: String = str(PORTRAIT_ALIASES.get(canonical(entry_name), ""))
	if npc_id.is_empty():
		npc_id = NpcRegistry.resolve_speaker(canonical(entry_name))
	if npc_id.is_empty():
		npc_id = NpcRegistry.resolve_speaker(entry_name)
	return npc_id


## Overnight Oct 28: the Portrait Image ID of an enemy's entrance cut-out ("CUT-CLENCH"), "" when the enemy is no speaking character.
static func cutout_id(entry_name: String) -> String:
	var npc_id: String = portrait_npc_id(entry_name)
	var npc: NpcRegistry.Entry = NpcRegistry.find(npc_id) if not npc_id.is_empty() else null
	if npc == null or npc.portrait_id.is_empty():
		return ""
	return CUTOUT_PREFIX + npc.portrait_id.substr(npc.portrait_id.find("-") + 1)


## The transparent figure the boss intro slides in: the imported CUT-* cut-out, else the dialogue portrait itself (already transparent),
## else null (the intro then shows the Bestiary square, `art`).
static func cutout(entry_name: String, phase: int = -1) -> Texture2D:
	var id: String = cutout_id(entry_name)
	if id.is_empty():
		return null
	var expression: String = phase_cutout_expression(entry_name, phase)
	if not expression.is_empty() and Portraits.has_expression(id, expression):
		return Portraits.texture_for(id, expression)
	if Portraits.has_portrait(id):
		return Portraits.texture_for(id)
	var npc: NpcRegistry.Entry = NpcRegistry.find(portrait_npc_id(entry_name))
	if npc == null or not Portraits.has_portrait(npc.portrait_id):
		return null
	return Portraits.texture_for(npc.portrait_id)


## Overnight Oct 28-29: the final boss's later phases wear their own cut-outs (CUT-PRIMM_CRACKED, CUT-PRIMM_UNRAVELLED); the phase is the
## battle's 0-based boss phase (-1 for every other battle).
const PHASE_CUTOUTS: Dictionary = {"Primm, His Perfection": ["", "CRACKED", "UNRAVELLED"]}


## The expression suffix of the cut-out for the given phase of this boss ("" for the base picture).
static func phase_cutout_expression(entry_name: String, phase: int) -> String:
	var list: Array = PHASE_CUTOUTS.get(canonical(entry_name), []) as Array
	if phase < 0 or phase >= list.size():
		return ""
	return str(list[phase])


## Every cut-out id a boss / lieutenant / gatekeeper entrance can use (one per speaking character with an entrance), sorted: the ids
## "import portraits" accepts and the list of cut-outs still to make.
static func cutout_ids() -> Array[String]:
	var ids: Array[String] = []
	for key: String in BossIntros.keys():
		var id: String = cutout_id(key)
		if not id.is_empty() and not ids.has(id):
			ids.append(id)
	ids.sort()
	return ids


## The square head-and-shoulders crop of the enemy's dialogue portrait (top of the 2:3 image), or null when the enemy is no NPC with a portrait.
static func portrait_art(entry_name: String) -> Texture2D:
	var npc_id: String = portrait_npc_id(entry_name)
	var npc: NpcRegistry.Entry = NpcRegistry.find(npc_id) if not npc_id.is_empty() else null
	if npc == null or npc.portrait_id.is_empty() or not Portraits.has_portrait(npc.portrait_id):
		return null
	var full: Texture2D = Portraits.texture_for(npc.portrait_id)
	if full == null:
		return null
	var side: float = minf(float(full.get_width()), float(full.get_height()))
	var crop: AtlasTexture = AtlasTexture.new()
	crop.atlas = full
	crop.region = Rect2(0.0, 0.0, side, side)
	return crop


static func all() -> Array[Entry]:
	if _entries.is_empty() and FileAccess.file_exists(PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if parsed is Dictionary:
			for row: Variant in (parsed as Dictionary).get("entries", []) as Array:
				var data: Dictionary = row as Dictionary
				var entry: Entry = Entry.new()
				entry.name = str(data.get("name", ""))
				entry.kind = str(data.get("kind", "foe"))
				entry.where = str(data.get("where", ""))
				entry.icon = str(data.get("icon", FALLBACK_ICON))
				entry.blurb = str(data.get("blurb", ""))
				_entries.append(entry)
	return _entries


static func find(enemy_name: String) -> Entry:
	var key: String = canonical(enemy_name)
	for entry: Entry in all():
		if entry.name == key:
			return entry
	return null


## Battle names that differ from the entry: the final boss's node id and its phase names ("Primm - Standardization"), and the
## corrupted wanderers (all four are one entry).
static func canonical(enemy_name: String) -> String:
	if enemy_name == "PRIMM_BOSS" or enemy_name.begins_with("Primm"):
		return "Primm, His Perfection"
	if enemy_name in CorruptedNpcs.DISPLAY_NAMES.values():
		return "Corrupted Wanderers"
	if RENAMED.has(enemy_name):
		return str(RENAMED[enemy_name])
	return enemy_name


static func met_count(counters: Dictionary, enemy_name: String) -> int:
	return _count(counters, MET_PREFIX, enemy_name)


static func won_count(counters: Dictionary, enemy_name: String) -> int:
	return _count(counters, WON_PREFIX, enemy_name)


## A counter under the entry's name plus whatever an old save recorded under a name it was renamed from.
static func _count(counters: Dictionary, prefix: String, enemy_name: String) -> int:
	var key: String = canonical(enemy_name)
	var total: int = int(counters.get(prefix + key, 0))
	for old: String in RENAMED:
		if str(RENAMED[old]) == key:
			total += int(counters.get(prefix + old, 0))
	return total


static func is_known(counters: Dictionary, enemy_name: String) -> bool:
	return met_count(counters, enemy_name) > 0 or won_count(counters, enemy_name) > 0


## How many entries are known: (known, total).
static func progress(counters: Dictionary) -> Vector2i:
	var known: int = 0
	for entry: Entry in all():
		if is_known(counters, entry.name):
			known += 1
	return Vector2i(known, all().size())


static func percent(counters: Dictionary) -> int:
	var p: Vector2i = progress(counters)
	return 0 if p.y == 0 else int(floor(100.0 * float(p.x) / float(p.y)))


## Milestones reached but not yet paid (their flags are not set).
static func due_milestones(counters: Dictionary, flags: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var reached: int = percent(counters)
	for milestone: Dictionary in MILESTONES:
		var flag: String = "bestiary_%d" % int(milestone["percent"])
		if reached >= int(milestone["percent"]) and not bool(flags.get(flag, false)):
			result.append(milestone)
	return result
