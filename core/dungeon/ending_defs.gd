class_name EndingDefs
extends RefCounted
## The ending sequence after Primm falls (Brief 10, Part E): the facade crumbles, the rifts close and the four Paths reunite; the theme
## is that Primm demanded ONE way for everyone and his fall frees the Paths to MIX again (different Paths working together is what made the
## kingdom strong). Then placeholder credits, the postgame announcement and a return to the (changed) Capital. All text is in the Capital's
## story file under `ending.*`; `fx` names a visual the `EndingScreen` plays on that beat.

## [{n, fx}] in order (the numbers are story keys, not positions: beats 8-10 were added by Story v2). The text of beat N is the story key `ending.beat.N` and its heading `ending.beat.N.title`.
const BEATS: Array[Dictionary] = [
	{"n": 1, "fx": "crumble"},
	{"n": 8, "fx": "throne"},
	{"n": 2, "fx": "facade"},
	{"n": 3, "fx": "rifts"},
	{"n": 9, "fx": "primm_sees"},
	{"n": 4, "fx": "wrinkles"},
	{"n": 5, "fx": "reunion"},
	{"n": 10, "fx": "stamp"},
	{"n": 6, "fx": "unite"},
	{"n": 7, "fx": "dove"},
]

## The postgame announcement's story keys (`ending.postgame.title`, `.body`, `.line.1`, `.line.2`, `.line.3`).
const POSTGAME_LINES: int = 3
## How many credits lines the story file has (`ending.credits.1` ...).
const CREDITS_LINES: int = 12
## The Path icons shown in the reunion: [icon, tint] for Beefcake, Gourmand, Refusemancer, Necrocrat.
const PATH_ICONS: Array[Dictionary] = [
	# Fable Nov 14 (Part 4): "art" is the canonical Path icon (PathIcons), drawn in its own colours wherever it exists; "icon" (the old
	# silhouettes: a viking head, a tree face, a stamp) is only the fallback when the icon art is missing. "color" tints glows and gems.
	{"icon": "delapouite/biceps", "art": "ICON-ENERGY-B", "color": "e2553f"},
	{"icon": "delapouite/chef-toque", "art": "ICON-ENERGY-G", "color": "f2c14e"},
	{"icon": "lorc/recycle", "art": "ICON-ENERGY-R", "color": "7bc86c"},
	{"icon": "lorc/skull-crack", "art": "ICON-ENERGY-N", "color": "a870d8"},
]


static func beat_key(n: int) -> String:
	return "ending.beat.%d" % n


static func beat_title_key(n: int) -> String:
	return "ending.beat.%d.title" % n
