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
## Quest log changed (started, progressed, completed) - the HUD tracker redraws.
signal quest_changed
## A quest toast: text, and true when it is a "new quest" (false = completed).
signal quest_notice(text: String, is_new: bool)
## A zone was freed (its dungeon boss fell): the zone id. The Arena and the Alchemist listen for this.
signal zone_completed(zone_id: String)
## The player's zone life changed (battle/enemy hit/heal) - HUD redraws and flashes.
signal zone_life_changed(life: int, max_life: int)
