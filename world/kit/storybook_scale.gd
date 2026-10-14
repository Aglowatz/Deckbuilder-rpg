class_name StorybookScale
extends RefCounted
## The storybook scale (Art Bible G-01, docs/art/art_bible.md): one set of numbers every scene and the kits read.
## Characters are 85-90% of a door's height. One storey of a building is about 1.5x the hero; doors and windows are oversized, walls short,
## trees 2.5-4x the hero, props slightly oversized (a barrel reaches the waist). Big and small characters keep their Relative Height.
##
## Before the overnight scale pass the hero was 1.25 m against a 3.4 m door (a third). The hero grew by `CHAR_FACTOR` and buildings were compressed.

const CHAR_FACTOR: float = 1.36
## The hero in metres (a character of relative height 1.0).
const HERO_HEIGHT: float = 1.25 * CHAR_FACTOR
## Model scale of a 3D character at the hero's size (was 0.34).
const MODEL_SCALE: float = 0.34 * CHAR_FACTOR
const DOOR_H: float = 1.95
const DOOR_W: float = 1.25
## One storey (wall height incl. its share of roof line) is 1.5 hero heights.
const STOREY_H: float = HERO_HEIGHT * 1.5
## Old building heights times this give the storybook ones (presets, sockets).
const BUILDING_V: float = 0.64
const TREE_MIN: float = HERO_HEIGHT * 2.5
const TREE_MAX: float = HERO_HEIGHT * 4.0
## A barrel reaches the hero's waist.
const BARREL_H: float = 1.0
const CRATE_H: float = 0.8
## Walking pace (was 3.4 for the 1.25 m hero) and the body radius used for collision (was 0.22).
const WALK_SPEED: float = 4.9
const BODY_RADIUS: float = 0.3
## Interaction spots reach this much farther (the hero's arms are longer).
const INTERACT_FACTOR: float = 1.2
