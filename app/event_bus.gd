extends Node
## Global signal hub. Decouples systems that should not know about each other
## (e.g. gameplay code asking for a sound, tutorial hints listening to battle events).

## Emitted when gold changes (new total).
signal gold_changed(total: int)
## A short message shown to the player (toast).
signal toast_requested(text: String)
## Overnight Oct 17, Part 14: the hero put a foot down at `position` on `surface` (AmbientFx puffs a little of the ground).
signal hero_footstep(position: Vector3, surface: StringName)
## Something happened the tutorial layer may care about ("town_visited", "card_played", ...).
signal tutorial_event(id: StringName)
## Controller support (Oct 26): the player switched between the keyboard/mouse and a controller (`InputDevice`); prompts re-render.
signal input_device_changed(using_pad: bool)
## The player's collection or deck changed.
signal collection_changed
## Unopened packs were granted, bought or opened (the Character screen refreshes its Packs list).
signal packs_changed
## The hero cosmetics (hat, cloak, dyes, owned items) changed: live hero models rebuild their look.
signal cosmetics_changed
## Quest log changed (started, progressed, completed) - the HUD tracker redraws.
signal quest_changed
## A quest toast: text, and true when it is a "new quest" (false = completed).
signal quest_notice(text: String, is_new: bool)
## Fixes Oct 25, Part 7: a quest started ("start"), a step was done ("step") or a quest finished ("complete") - the quest update banner
## (`QuestNoticeLayer`). `detail`: the reward line for "complete", an extra note for the others ("" = none).
signal quest_update(kind: String, quest_id: String, detail: String)
## A spare copy of a card was converted (Part F): the message to show, essence by Path ({Affinity.Type: amount})
## and gold gained (one of the two is empty/0).
signal essence_converted(message: String, essence: Dictionary, gold: int)
## A Grand Clashatorium fight ended (Part G): the encounter id and whether the player won.
signal arena_fight_finished(encounter_id: String, won: bool)
## A zone was freed (its dungeon boss fell): the zone id. The Arena and the Alchemist listen for this.
signal zone_completed(zone_id: String)
## The player's zone HP changed (battle/enemy hit/heal) - HUD redraws and flashes.
signal zone_hp_changed(hp: int, max_hp: int)
