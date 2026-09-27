class_name DungeonDeckbuilderScreen
extends DeckbuilderScreen
## The Deck Station, reachable from the dungeon map (Part C): same screen, same validation rules
## as town, but it edits the current dungeon run's deck (`DungeonRun.current_deck()`, base deck
## plus anything lost/gained so far this run) and its modifiers (e.g. the tutorial's MIN_DECK_SIZE
## waiver, so a 42-card starter deck is legal to save mid-run) instead of the town deck.
##
## Saving replaces `run.base_deck` with the edited deck and clears the lost/gained lists, since
## the editor's snapshot already reflects the full "current" state - there is nothing left to
## re-apply on top of it.


func _source_deck() -> Deck:
	return Session.run.current_deck()


func _active_modifiers() -> ModifierSet:
	return Session.run.modifiers()


func _write_back(edited: Deck) -> void:
	Session.run.base_deck = edited
	Session.run.base_deck.deck_name = Session.DECK_NAME
	Session.run.lost_cards.clear()
	Session.run.gained_cards.clear()
	Session.save_game()
