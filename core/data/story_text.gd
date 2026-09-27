class_name StoryText
extends Resource
## All narrative/placeholder dialogue text that isn't tied to a specific NPC's own script, kept
## in one place so it is easy to find and rewrite. Currently just the wake-up scene that opens
## the game; add more exported arrays here as the story grows instead of hardcoding lines in
## scene scripts.

## The hero wakes up alone and talks to themselves, before noticing the way out.
@export var awakening_lines: Array[String] = [
	"Where am I?",
	"What happened?",
	"My head...",
	"...There. Light, through the rocks. That must be the way out.",
]
