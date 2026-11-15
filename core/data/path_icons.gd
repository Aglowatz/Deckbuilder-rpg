class_name PathIcons
extends RefCounted
## Fable Nov 14 (Part 4): the one canonical icon of each Path (docs/art/path_icon_style_guide.md). Every place in code that shows "this
## Path" asks here: the energy orbs and card costs (`IconArt.ENERGY_IDS` is the same table), filters, signs, banners, feats, the map.
## A Path is never shown by another symbol (a dumbbell, a ladle, a stamp, a sun, a wave or a flame are resources, props or old art).
## Pure data: no scene tree.

const ICONS: Dictionary = {
	Affinity.Type.BEEFCAKE: "ICON-ENERGY-B",
	Affinity.Type.GOURMAND: "ICON-ENERGY-G",
	Affinity.Type.REFUSEMANCER: "ICON-ENERGY-R",
	Affinity.Type.NECROCRAT: "ICON-ENERGY-N",
	Affinity.Type.NEUTRAL: "ICON-ENERGY-GENERIC",
}

## What the picture is, in a few words (the style guide's "shape").
const SHAPES: Dictionary = {
	Affinity.Type.BEEFCAKE: "a flexed arm",
	Affinity.Type.GOURMAND: "a chef's hat",
	Affinity.Type.REFUSEMANCER: "a leaf inside three recycling arrows",
	Affinity.Type.NECROCRAT: "a skull in green ghost-flame",
	Affinity.Type.NEUTRAL: "a plain stone disc",
}

## The Path's colour (the disc of its icon) and its darker rim, as hex. The game's UI tints (`Affinity` colours) may be lighter or darker
## for legibility; these are what a painter matches.
const COLORS: Dictionary = {
	Affinity.Type.BEEFCAKE: "C8321E",
	Affinity.Type.GOURMAND: "D9824A",
	Affinity.Type.REFUSEMANCER: "5C7A2E",
	Affinity.Type.NECROCRAT: "5E6B60",
	Affinity.Type.NEUTRAL: "9A9A9A",
}

## The order the four are always listed and drawn in (a ring reads clockwise from the top).
const ORDER: Array[Affinity.Type] = [Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.NECROCRAT]

## The smallest size the coloured icon is drawn at, in pixels at 1080p (below it the skull and the leaf stop reading).
const MIN_PX: int = 24


static func icon(path: Affinity.Type) -> String:
	return str(ICONS.get(path, ICONS[Affinity.Type.NEUTRAL]))


static func shape(path: Affinity.Type) -> String:
	return str(SHAPES.get(path, ""))


static func color(path: Affinity.Type) -> Color:
	return Color.html(str(COLORS.get(path, COLORS[Affinity.Type.NEUTRAL])))


## The four Paths' icons in the canonical order.
static func four() -> Array[String]:
	var ids: Array[String] = []
	for path: Affinity.Type in ORDER:
		ids.append(icon(path))
	return ids


## "the flexed arm, the chef's hat, the leaf and the skull": the crest's four signs in words, for story text.
static func four_in_words() -> String:
	return "the flexed arm, the chef's hat, the leaf and the skull"
