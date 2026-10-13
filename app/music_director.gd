class_name MusicDirector
extends RefCounted
## Which music ID plays where (docs/audio/music_integration.md). Pure functions of the game state, so every mapping is testable; the scenes just ask
## (`Audio.play_music(MusicDirector.town(Session.flags))`). Column C/E of `data/source/music_list.csv` is the source of the table below: a cue is
## chosen by location, encounter and world state, never by the player's deck. Every function returns an ID; an ID without a file falls back through
## `fallback_id` (and finally to the synthesized tracks), so nothing is silent.

# ---- The four Paths -----------------------------------------------------------------------------------

## Zone id -> the Path's cues. Keys: exp/freed/battle (the zone), dun_exp/dun_battle/boss (its main dungeon), release (the leader's rescue scene), minigame,
## zone_sting (the zone freed), broken/restored (its Capital district), quest (its Capital quest NPC), shop (its vendor screen).
const PATHS: Dictionary = {
	"beefcake": {
		"exp": "MUS-BEEF-EXP", "freed": "MUS-BEEF-FREED", "battle": "MUS-BEEF-BATTLE", "dun_exp": "MUS-BEEF-DUN-EXP", "dun_battle": "MUS-BEEF-DUN-BATTLE",
		"boss": "MUS-BEEF-BOSS", "release": "MUS-BEEF-RELEASE", "minigame": "MUS-MINIGAME-BEEF", "zone_sting": "STG-ZONE-BEEF",
		"broken": "MUS-CAP-BEEF-BROKEN", "restored": "MUS-CAP-BEEF-RESTORED", "quest": "MUS-QUEST-ROLLO",
	},
	"gourmand": {
		"exp": "MUS-GOUR-EXP", "freed": "MUS-GOUR-FREED", "battle": "MUS-GOUR-BATTLE", "dun_exp": "MUS-GOUR-DUN-EXP", "dun_battle": "MUS-GOUR-DUN-BATTLE",
		"boss": "MUS-GOUR-BOSS", "release": "MUS-GOUR-RELEASE", "minigame": "MUS-MINIGAME-GOUR", "zone_sting": "STG-ZONE-GOUR",
		"broken": "MUS-CAP-GOUR-BROKEN", "restored": "MUS-CAP-GOUR-RESTORED", "quest": "MUS-QUEST-MARLO",
	},
	"necrocrat": {
		"exp": "MUS-NECRO-EXP", "freed": "MUS-NECRO-FREED", "battle": "MUS-NECRO-BATTLE", "dun_exp": "MUS-NECRO-DUN-EXP", "dun_battle": "MUS-NECRO-DUN-BATTLE",
		"boss": "MUS-NECRO-BOSS", "release": "MUS-NECRO-RELEASE", "minigame": "MUS-MINIGAME-NECRO", "zone_sting": "STG-ZONE-NECRO",
		"broken": "MUS-CAP-NECRO-BROKEN", "restored": "MUS-CAP-NECRO-RESTORED", "quest": "MUS-QUEST-PELL",
	},
	"refusemancer": {
		"exp": "MUS-REF-EXP", "freed": "MUS-REF-FREED", "battle": "MUS-REF-BATTLE", "dun_exp": "MUS-REF-DUN-EXP", "dun_battle": "MUS-REF-DUN-BATTLE",
		"boss": "MUS-REF-BOSS", "release": "MUS-REF-RELEASE", "minigame": "MUS-MINIGAME-REF", "zone_sting": "STG-ZONE-REF",
		"broken": "MUS-CAP-REF-BROKEN", "restored": "MUS-CAP-REF-RESTORED", "quest": "MUS-QUEST-FERN",
	},
}

## Dungeon ID (the dungeon list's column A) -> its cues. Side dungeons have one battle song for ordinary fights and their boss (the BOSS row is a
## compatibility alias of the BATTLE row, so the registry resolves both to one file).
const DUNGEONS: Dictionary = {
	"D-TUT": {"exp": "MUS-TUT-EXP", "battle": "MUS-TUT-BATTLE", "boss": "MUS-TUT-BOSS"},
	"D-HOG": {"exp": "MUS-BEEF-DUN-EXP", "battle": "MUS-BEEF-DUN-BATTLE", "boss": "MUS-BEEF-BOSS"},
	"D-TTK": {"exp": "MUS-GOUR-DUN-EXP", "battle": "MUS-GOUR-DUN-BATTLE", "boss": "MUS-GOUR-BOSS"},
	"D-HFA": {"exp": "MUS-NECRO-DUN-EXP", "battle": "MUS-NECRO-DUN-BATTLE", "boss": "MUS-NECRO-BOSS"},
	"D-ROT": {"exp": "MUS-REF-DUN-EXP", "battle": "MUS-REF-DUN-BATTLE", "boss": "MUS-REF-BOSS"},
	"D-PC": {"exp": "MUS-CASTLE-EXP", "battle": "MUS-CASTLE-BATTLE", "boss": "MUS-PRIMM-01"},
	"D-LAB": {"exp": "MUS-LAB-EXP", "battle": "MUS-LAB-BATTLE", "boss": "MUS-SIPHON-BOSS"},
	"S-BEEF": {"exp": "MUS-SWOLY-EXP", "battle": "MUS-SWOLY-BATTLE", "boss": "MUS-SWOLY-BOSS"},
	"S-GOUR": {"exp": "MUS-OMAKASE-EXP", "battle": "MUS-OMAKASE-BATTLE", "boss": "MUS-OMAKASE-BOSS"},
	"S-NECRO": {"exp": "MUS-WAIT-EXP", "battle": "MUS-WAIT-BATTLE", "boss": "MUS-WAIT-BOSS"},
	"S-REF": {"exp": "MUS-PANDA-EXP", "battle": "MUS-PANDA-BATTLE", "boss": "MUS-PANDA-BOSS"},
	"S-CAP": {"exp": "MUS-TUNNEL-EXP", "battle": "MUS-TUNNEL-BATTLE", "boss": "MUS-TUNNEL-BOSS"},
	"S-TOWN": {"exp": "MUS-VAULT-EXP", "battle": "MUS-VAULT-BATTLE", "boss": "MUS-VAULT-BOSS"},
}

## Battleboard ID (the battle's board) -> the dungeon whose battle cues it uses, or the cue itself (outside the dungeons).
const BOARD_DUNGEON: Dictionary = {
	"BB-TUT": "D-TUT", "BB-HOG": "D-HOG", "BB-TTK": "D-TTK", "BB-HFA": "D-HFA", "BB-ROT": "D-ROT", "BB-PC": "D-PC", "BB-LAB": "D-LAB",
	"BB-S-BEEF": "S-BEEF", "BB-S-GOUR": "S-GOUR", "BB-S-NECRO": "S-NECRO", "BB-S-REF": "S-REF", "BB-S-CAP": "S-CAP", "BB-S-TOWN": "S-TOWN",
}
const BOARD_CUE: Dictionary = {
	"BB-TOWN": "MUS-TOWN-BATTLE", "BB-GRAVE": "MUS-GRAVE-BATTLE", "BB-ARENA": "MUS-ARENA-BATTLE",
	"BB-GAIN": "MUS-BEEF-BATTLE", "BB-BUFF": "MUS-GOUR-BATTLE", "BB-DNA": "MUS-NECRO-BATTLE", "BB-DUMP": "MUS-REF-BATTLE",
	"BB-CAP-OUT": "MUS-CAP-OUT-BATTLE", "BB-CAP-IN": "MUS-CAP-FACADE-BATTLE", "BB-PC-BOSS": "MUS-PRIMM-01",
}
## The zone ids that map to a Path's overworld board (the zone key of a battle that carries no board).
const ZONE_BOARD: Dictionary = {"beefcake": "BB-GAIN", "gourmand": "BB-BUFF", "necrocrat": "BB-DNA", "refusemancer": "BB-DUMP"}

const PRIMM_PHASES: Array[String] = ["MUS-PRIMM-01", "MUS-PRIMM-02", "MUS-PRIMM-03"]
## Capital district area id (`CapitalLayout`) -> the Path whose completion flag decides its broken/restored cue.
const CAPITAL_DISTRICTS: Dictionary = {"transit": "beefcake", "hungry": "gourmand", "grave": "necrocrat", "reek": "refusemancer"}
## The Gold Sand tier of the Arena (and above) is the Arena's high-tier music.
const ARENA_ELITE_TIER: int = 3


# ---- Menus and the overworld ---------------------------------------------------------------------------


static func title() -> String:
	return "MUS-TITLE"


## The prologue forest (waking, the Rescuer, the starting Path choice).
static func forest() -> String:
	return "MUS-FOREST"


## The town: the restored cue once all four zones are free (partial recovery keeps the base theme).
static func town(flags: Dictionary) -> String:
	if ZoneCompletion.count(flags) >= ZoneCompletion.TOTAL_ZONES:
		return "MUS-TOWN-FREED"
	return "MUS-TOWN"


static func graveyard() -> String:
	return "MUS-GRAVE-EXP"


static func deck_station() -> String:
	return "MUS-DECK"


## A Path's zone: exploration, or the freed version once that zone's own completion flag is set. The Capital is `capital_area`.
static func zone_area(zone_id: String, flags: Dictionary) -> String:
	if not PATHS.has(zone_id):
		return "MUS-TOWN"
	var cues: Dictionary = PATHS[zone_id] as Dictionary
	if ZoneCompletion.is_completed(flags, zone_id):
		return str(cues["freed"])
	return str(cues["exp"])


## The Capital by the area the hero stands in (`CapitalLayout` area ids) and the world state: outside the walls, the facade, the four districts
## (broken until their Path's zone is freed), the Correction Ward, the Crease, and the restored city once Primm has fallen.
static func capital_area(area_id: String, flags: Dictionary, inside: bool) -> String:
	if CAPITAL_DISTRICTS.has(area_id):
		var path: Dictionary = PATHS[str(CAPITAL_DISTRICTS[area_id])] as Dictionary
		if ZoneCompletion.is_completed(flags, str(CAPITAL_DISTRICTS[area_id])):
			return str(path["restored"])
		return str(path["broken"])
	var restored: bool = bool(flags.get(str(CapitalZone.FLAG_FREED), false))
	match area_id:
		"crease":
			return "MUS-CREASE"
		"ward":
			return "MUS-CAP-CORRECTION"
		"outskirts", "gate":
			return "MUS-CAP-RESTORED" if restored and inside else "MUS-CAP-OUT-EXP"
		"plaza", "perfection", "approach", "yard":
			return "MUS-CAP-RESTORED" if restored else "MUS-CAP-FACADE-EXP"
	return "MUS-CAP-RESTORED" if (restored and inside) else ("MUS-CAP-FACADE-EXP" if inside else "MUS-CAP-OUT-EXP")


# ---- Dungeons and battles -----------------------------------------------------------------------------


## The dungeon id the session is in: the tutorial cave when no main or side dungeon is active.
static func dungeon_id(session_dungeon_key: String, main_or_side_active: bool) -> String:
	if not main_or_side_active:
		return "D-TUT"
	var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(session_dungeon_key)
	return plan.id if plan != null else "D-TUT"


## The dungeon id of the running session (the tutorial cave when no catalogue dungeon is active).
static func session_dungeon_id() -> String:
	return dungeon_id(Session.dungeon_key, Session.main_dungeon_active or Session.mini_active or Session.town_side_active)


## A dungeon's node map (and its ordinary events).
static func dungeon_exploration(dungeon: String) -> String:
	var cues: Dictionary = DUNGEONS.get(dungeon, DUNGEONS["D-TUT"]) as Dictionary
	return str(cues["exp"])


## The song of a battle. Chosen by who is fighting where: a story duel (Shiro, the Warden, the graveyard) by its own cue, the final boss by its
## ACTUAL phase, an arena fight by its tier, a dungeon fight by the battleboard, the rest by the overworld board of the zone.
static func for_battle(context: BattleContext, flags: Dictionary = {}) -> String:
	if context.boss_phase >= 0:
		return PRIMM_PHASES[clampi(context.boss_phase, 0, PRIMM_PHASES.size() - 1)]
	if context.is_ninja_boss:
		return "MUS-SHIRO-BOSS"
	if context.is_vault_boss:
		return "MUS-VAULT-BOSS"
	if context.is_graveyard_boss:
		return "MUS-GRAVE-BATTLE"
	if not context.arena_id.is_empty():
		var encounter: ArenaEncounter = ArenaDefs.find(context.arena_id)
		return "MUS-ARENA-ELITE" if encounter != null and encounter.tier >= ARENA_ELITE_TIER else "MUS-ARENA-BATTLE"
	var board: String = board_id(context)
	if context.zone_id == CapitalZone.ID or board == "BB-CAP-OUT" or board == "BB-CAP-IN":
		return _capital_battle(context, board)
	if BOARD_DUNGEON.has(board):
		var cues: Dictionary = DUNGEONS[str(BOARD_DUNGEON[board])] as Dictionary
		return str(cues["boss"]) if context.is_boss else str(cues["battle"])
	if BOARD_CUE.has(board):
		return str(BOARD_CUE[board])
	if context.tutorial:
		return "MUS-TUT-BATTLE"
	if ZONE_BOARD.has(context.zone_id):
		return str(BOARD_CUE[str(ZONE_BOARD[context.zone_id])])
	if not context.town_npc_id.is_empty():
		return "MUS-TOWN-BATTLE"
	return "MUS-TOWN-BATTLE"


## The battleboard ID of a context: its key is a board ID itself (dungeon fights carry `BB-HOG`) or a context key of `data/battleboards.json`.
static func board_id(context: BattleContext) -> String:
	if context.board_key.begins_with("BB-"):
		return context.board_key
	return Battleboards.board_for(context.board_key)


static func _capital_battle(context: BattleContext, board: String) -> String:
	match context.zone_enemy_type:
		CapitalEnemies.SPOTLESS:
			return "MUS-CAP-ENFORCER"
		CapitalEnemies.WRETCH, CapitalEnemies.SWARM:
			return "MUS-CAP-RIFT"
		CapitalEnemies.OFFICER, CapitalEnemies.INSPECTOR:
			return "MUS-CAP-ENFORCER"
	return "MUS-CAP-FACADE-BATTLE" if board == "BB-CAP-IN" else "MUS-CAP-OUT-BATTLE"


# ---- Shops, minigames and the story ---------------------------------------------------------------------


## A vendor screen's theme (VS-SABLE -> MUS-SHOP-SABLE). The Alchemist has her own postgame arrangement. "" = not a vendor.
static func shop(vendor_screen_id: String, postgame: bool = false) -> String:
	if not vendor_screen_id.begins_with("VS-"):
		return ""
	if vendor_screen_id == "VS-ALEMBIC" and postgame:
		return "MUS-SHOP-ALEMBIC-POST"
	return "MUS-SHOP-%s" % vendor_screen_id.trim_prefix("VS-")


static func quiz() -> String:
	return "MUS-QUIZ"


## A Path's minigame (the zone it belongs to).
static func minigame(zone_id: String) -> String:
	if PATHS.has(zone_id):
		return str((PATHS[zone_id] as Dictionary)["minigame"])
	return "MUS-QUIZ"


## The leader's release / liberation scene of a Path.
static func release(zone_id: String) -> String:
	if PATHS.has(zone_id):
		return str((PATHS[zone_id] as Dictionary)["release"])
	return ""


## The sting for a zone freed.
static func zone_freed_sting(zone_id: String) -> String:
	if PATHS.has(zone_id):
		return str((PATHS[zone_id] as Dictionary)["zone_sting"])
	return "STG-DUNGEON"


## The memory scene N (the Nth zone freed, whichever zone it was).
static func memory(number: int) -> String:
	return "MUS-MEM-%02d" % clampi(number, 1, 4)


## The major-quest conclusion of a Capital Path quest NPC ("fern", "pell", "rollo", "marlo"; "" for any other).
static func quest_conclusion(npc: String) -> String:
	for zone_id: Variant in PATHS.keys():
		var cue: String = str((PATHS[zone_id] as Dictionary)["quest"])
		if cue.ends_with("-%s" % npc.to_upper()):
			return cue
	return ""


## Cutscene id (`CutsceneDefs`) -> its cue, "" when the scene keeps the music under it.
static func cutscene(scene_id: String) -> String:
	match scene_id:
		"rescue":
			return release("beefcake")
		"wonder":
			return release("gourmand")
		"vacancy":
			return release("necrocrat")
		"sever":
			return release("refusemancer")
		"primm_intro", "primm_p1", "primm_p2":
			return "MUS-PRIMM-BREAK"
		"primm_reveal":
			return "MUS-MEM-04"
		"primm_end":
			return "MUS-PRIMM-DEFEAT"
	return ""


## A dungeon story node / event (the node's story key such as "dungeon.pc_gallery.before", or the event id) -> its cue, "" for none.
static func story_node(node_key: String) -> String:
	var node_id: String = node_key.trim_prefix("dungeon.").trim_suffix(".before").trim_suffix(".after")
	match node_id:
		"pc_early_journals", "pc_archive_gate":
			return "MUS-ARCHIVE"
		"pc_gallery":
			return "MUS-GALLERY"
		"dg_d_lab_7":
			return "MUS-LAB-CELL"
		"dg_lab_rescue":
			return "MUS-LAB-RESCUE"
	return ""


## The ending's beats (`EndingDefs.BEATS` fx names) -> the cue that starts at that beat, "" to keep what plays.
static func ending_beat(fx: String) -> String:
	match fx:
		"crumble":
			return "MUS-PRIMM-DEFEAT"
		"throne":
			return "MUS-THRONE"
		"reunion":
			return "MUS-REUNION"
	return ""


static func credits() -> String:
	return "MUS-CREDITS"


# ---- Fallbacks ----------------------------------------------------------------------------------------


## What plays when `id` has no loadable file: by its category in the catalogue (combat/boss -> the town fight song, menu/shop -> the deck theme,
## everything else the town theme), never "". An unknown ID gets the same by its name. The manager falls back to the synthesized tracks after this.
static func fallback_id(id: String) -> String:
	var found: AudioRegistry.Entry = AudioRegistry.entry(id)
	var category: String = found.category if found != null else ""
	if category.is_empty():
		if id.ends_with("-BATTLE") or id.ends_with("-BOSS") or id.begins_with("MUS-PRIMM"):
			category = "Combat"
		elif id.begins_with("MUS-SHOP") or id == "MUS-DECK" or id == "MUS-QUIZ":
			category = "Menu"
	var candidate: String = "MUS-TOWN"
	match category:
		"Combat", "Boss":
			candidate = "MUS-TOWN-BATTLE"
		"Menu", "Shop", "Minigame":
			candidate = "MUS-DECK"
	if candidate != id and AudioRegistry.is_playable(candidate):
		return candidate
	if id != "MUS-TOWN" and AudioRegistry.is_playable("MUS-TOWN"):
		return "MUS-TOWN"
	return ""
