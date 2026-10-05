class_name Dye
extends RefCounted
## The shared dye palette for hats and cloaks. A dye is an index into `PALETTE`; the secondary (trim) colour is derived from the primary.

const PALETTE: Array[Dictionary] = [
	{"name": "Crimson", "color": Color("d6403a")},
	{"name": "Sunset", "color": Color("f08a3c")},
	{"name": "Gold", "color": Color("f2c13c")},
	{"name": "Meadow", "color": Color("6cbf55")},
	{"name": "Teal", "color": Color("2fae9c")},
	{"name": "Sky", "color": Color("4a9be0")},
	{"name": "Royal", "color": Color("5a52c8")},
	{"name": "Plum", "color": Color("9a4ab8")},
	{"name": "Rose", "color": Color("ee7fa6")},
	{"name": "Cream", "color": Color("f1e6cf")},
	{"name": "Slate", "color": Color("6a7388")},
	{"name": "Ink", "color": Color("2c2840")},
]


static func count() -> int:
	return PALETTE.size()


static func clamp_index(index: int) -> int:
	return clampi(index, 0, PALETTE.size() - 1)


static func dye_name(index: int) -> String:
	return str(PALETTE[clamp_index(index)]["name"])


static func primary(index: int) -> Color:
	return PALETTE[clamp_index(index)]["color"] as Color


## The trim colour that goes with a primary: lighter for dark dyes, deeper for light ones, nudged toward warm.
static func secondary(index: int) -> Color:
	var base: Color = primary(index)
	var luma: float = base.r * 0.299 + base.g * 0.587 + base.b * 0.114
	var trim: Color = base.lightened(0.38) if luma < 0.5 else base.darkened(0.38)
	return trim.lerp(Color("ffd9a0"), 0.12)
