class_name AudioCatalog
extends RefCounted
## Maps sound names to files (all Kenney packs, see CREDITS.md). Several files per name are
## chosen at random for variety. tools/sync_assets.sh copies every path listed here from
## _asset_library/ into assets/audio/.

const UI: String = "res://assets/audio/kenney_ui-audio/"
const IFACE: String = "res://assets/audio/kenney_interface-sounds/"
const IMPACT: String = "res://assets/audio/kenney_impact-sounds/"
const RPG: String = "res://assets/audio/kenney_rpg-audio/"
const CASINO: String = "res://assets/audio/kenney_casino-audio/"
const JINGLE: String = "res://assets/audio/kenney_music-jingles/"


static func sounds() -> Dictionary:
	return {
		&"ui_hover": [UI + "rollover2.ogg"],
		&"ui_click": [UI + "click3.ogg"],
		&"ui_confirm": [IFACE + "confirmation_002.ogg"],
		&"ui_back": [IFACE + "back_001.ogg"],
		&"ui_error": [IFACE + "error_004.ogg"],
		&"ui_open": [IFACE + "open_001.ogg"],
		&"ui_close": [IFACE + "close_001.ogg"],
		&"ui_toggle": [IFACE + "toggle_001.ogg"],
		&"ui_tick": [IFACE + "tick_001.ogg"],
		&"ui_select": [IFACE + "select_003.ogg"],
		&"card_draw": [CASINO + "card-slide-1.ogg", CASINO + "card-slide-2.ogg", CASINO + "card-slide-3.ogg"],
		&"card_play": [CASINO + "card-place-1.ogg", CASINO + "card-place-2.ogg", CASINO + "card-place-3.ogg"],
		&"card_hover": [CASINO + "card-fan-1.ogg"],
		&"card_discard": [CASINO + "card-shove-1.ogg", CASINO + "card-shove-2.ogg"],
		&"card_shuffle": [CASINO + "card-shuffle.ogg"],
		&"land_play": [IMPACT + "impactWood_light_000.ogg", IMPACT + "impactWood_light_001.ogg"],
		&"attack": [RPG + "drawKnife1.ogg", RPG + "drawKnife2.ogg", RPG + "drawKnife3.ogg"],
		&"hit_light": [IMPACT + "impactPunch_medium_000.ogg", IMPACT + "impactPunch_medium_001.ogg", IMPACT + "impactPunch_medium_002.ogg"],
		&"hit_heavy": [IMPACT + "impactPunch_heavy_000.ogg", IMPACT + "impactPunch_heavy_001.ogg"],
		&"hit_metal": [IMPACT + "impactMetal_medium_000.ogg", IMPACT + "impactMetal_medium_001.ogg"],
		&"death": [IMPACT + "impactGlass_medium_000.ogg", IMPACT + "impactGlass_medium_001.ogg"],
		&"spell": [IFACE + "maximize_006.ogg", IFACE + "maximize_008.ogg"],
		&"heal": [IFACE + "confirmation_001.ogg"],
		&"trap": [RPG + "metalLatch.ogg"],
		&"turn_start": [IMPACT + "impactBell_heavy_000.ogg"],
		&"coins": [RPG + "handleCoins.ogg", RPG + "handleCoins2.ogg"],
			&"chest_open": [RPG + "metalLatch.ogg"],
		&"footstep": [
			IMPACT + "footstep_grass_000.ogg", IMPACT + "footstep_grass_001.ogg",
			IMPACT + "footstep_grass_002.ogg", IMPACT + "footstep_grass_003.ogg",
		],
		&"door": [RPG + "doorOpen_1.ogg"],
		&"book": [RPG + "bookFlip1.ogg", RPG + "bookFlip2.ogg"],
		&"victory": [JINGLE + "Steel jingles/jingles_STEEL00.ogg"],
		# New brief, Part A: a distinct fanfare for the level-up popup (not the battle-win jingle,
		# since a level-up can happen with no battle at all - e.g. the dev shrine).
		&"level_up": [JINGLE + "8-Bit jingles/jingles_NES03.ogg"],
		&"defeat": [JINGLE + "Hit jingles/jingles_HIT03.ogg"],
		&"dialogue": [IFACE + "tick_002.ogg"],
		# Card packs: the tear (cloth ripping) and the reveals (the rare chimes/fanfare are synthesized in `MusicSynth`).
		&"pack_tear": [RPG + "cloth1.ogg", RPG + "cloth3.ogg", RPG + "drawKnife2.ogg"],
		&"pack_flip": [CASINO + "card-slide-1.ogg", CASINO + "card-slide-2.ogg"],
	}
