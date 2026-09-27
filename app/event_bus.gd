extends Node
## Global signal hub. Decouples systems that should not know about each other
## (e.g. gameplay code asking for a sound, tutorial hints listening to battle events).

## Emitted when gold changes (new total).
signal gold_changed(total: int)
## A short message shown to the player (toast).
signal toast_requested(text: String)
## Something happened the tutorial layer may care about ("town_visited", "card_played", ...).
signal tutorial_event(id: StringName)
## The player's collection or deck changed.
signal collection_changed
