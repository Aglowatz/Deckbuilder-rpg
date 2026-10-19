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


## "Cave Scavenger" -> "BST-CAVE-SCAVENGER" (letters and digits, everything else a single dash).
static func art_id(entry_name: String) -> String:
	var slug: String = ""
	for character: String in canonical(entry_name).to_upper():
		var code: int = character.unicode_at(0)
		var keep: bool = (code >= 65 and code <= 90) or (code >= 48 and code <= 57)
		if keep:
			slug += character
		elif not slug.ends_with("-") and not slug.is_empty():
			slug += "-"
	return "BST-" + slug.trim_suffix("-")


## The picture of an entry (by name), or null when none has been made yet. Remembered per name.
## Overnight Oct 18, Phase 2 cycle 13: without a bestiary picture, an enemy who is also a speaking character (a boss, a corrupted NPC, Shiro...)
## shows the head and shoulders of their dialogue portrait.
static func art(entry_name: String) -> Texture2D:
	var id: String = art_id(entry_name)
	if _art_cache.has(id):
		return _art_cache[id] as Texture2D
	var texture: Texture2D = null
	for extension: String in ["webp", "png"]:
		var path: String = "%s/%s.%s" % [ART_DIR, id, extension]
		if ResourceLoader.exists(path):
			texture = load(path) as Texture2D
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


## The square head-and-shoulders crop of the enemy's dialogue portrait (top of the 2:3 image), or null when the enemy is no NPC with a portrait.
static func portrait_art(entry_name: String) -> Texture2D:
	var npc_id: String = str(PORTRAIT_ALIASES.get(canonical(entry_name), ""))
	if npc_id.is_empty():
		npc_id = NpcRegistry.resolve_speaker(canonical(entry_name))
	if npc_id.is_empty():
		npc_id = NpcRegistry.resolve_speaker(entry_name)
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
	return enemy_name


static func met_count(counters: Dictionary, enemy_name: String) -> int:
	return int(counters.get(MET_PREFIX + canonical(enemy_name), 0))


static func won_count(counters: Dictionary, enemy_name: String) -> int:
	return int(counters.get(WON_PREFIX + canonical(enemy_name), 0))


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
