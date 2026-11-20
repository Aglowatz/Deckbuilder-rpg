class_name MultiPathLock
extends RefCounted
## Fable Nov 21 (Part 3, the owner's rule): cards of THREE or FOUR Paths wait for Primm. Until he is defeated no pack, reward, chest,
## shop or brew may produce one, and none may be put in a deck; a copy already owned stays owned. After his defeat they are ordinary
## cards again. (A deck could not hold one before either - two Paths is the limit until the postgame - but the game still handed them
## out, which read as a prize the player could never use.)
##
## How it is enforced:
## - every generator already asks `CardAvailability.allowed(card, earned)`; that now also refuses a locked card unless `earned` carries
##   `UNLOCK_KEY`, which `Session.earned_cards_map()` adds once the `primm_defeated` flag is set. A caller with no map (a sim, a test)
##   gets the before-Primm answer;
## - `DeckEditor.why_not_add` refuses one with `reason()` (the Deck Station shows it as a pop-up to confirm);
## - `Session.add_cards` is the one door every granted card walks through: it counts a locked card that still arrives
##   (`Session.locked_multi_path_grants`) so the tests can prove no source leaks.

const MIN_PATHS: int = 3
## The marker `Session.earned_cards_map()` adds after Primm's defeat (never a card id: ids hold no '#').
const UNLOCK_KEY: String = "#multi_path_unlocked"
const FLAG_UNLOCKED: StringName = &"primm_defeated"
## Set once the "now unlocked" notice has been shown after Primm's defeat.
const FLAG_NOTICE_SHOWN: StringName = &"multi_path_notice_shown"
## The once-ever tip the Deck Station shows the first time the player's collection holds a locked card.
const TIP_ID: String = "multi_path_locked"

const RULE_TITLE: String = "Three- and four-Path cards"
const RULE_TEXT: String = "A card that walks three or four Paths is sealed until {villain} is defeated: no pack, shop, reward, chest or brew gives one before then, and it cannot go in a deck. Any you already own stay yours and wait in your collection."
const UNLOCKED_TITLE: String = "Three- and four-Path cards are open"
const UNLOCKED_TEXT: String = "With {villain} defeated, cards of three and four Paths are no longer sealed. They can go in your decks, and packs, shops, rewards and Auntie Alembic's brews may hold them from now on."


## A card of three or four Paths (never a token, never basic Infrastructure).
static func is_multi(card: CardData) -> bool:
	return card != null and not card.is_token and not card.is_unlimited() and card.paths().size() >= MIN_PATHS


static func unlocked(earned: Dictionary) -> bool:
	return earned.has(UNLOCK_KEY)


## Whether a generator must leave `card` out for a player whose earned map is `earned`.
static func blocks(card: CardData, earned: Dictionary = {}) -> bool:
	return is_multi(card) and not unlocked(earned)


## Whether `card` is locked for the player with this profile (the deck rules' side: `postgame_unlocked` is set with Primm's defeat).
static func locked_for(card: CardData, profile: PlayerProfile) -> bool:
	return is_multi(card) and (profile == null or not profile.postgame_unlocked)


## "Three-Path" / "Four-Path".
static func kind_name(card: CardData) -> String:
	return "Four-Path" if card != null and card.paths().size() >= 4 else "Three-Path"


## Why `card` cannot be added to a deck yet (the pop-up's body).
static func reason(card: CardData) -> String:
	return Villain.fill("%s is a %s card. Cards of three or four Paths are sealed until {villain} is defeated, so it cannot go in a deck yet. It stays in your collection until then." % [card.display_name, kind_name(card).to_lower()])


static func rule_text() -> String:
	return Villain.fill(RULE_TEXT)


static func unlocked_text() -> String:
	return Villain.fill(UNLOCKED_TEXT)
