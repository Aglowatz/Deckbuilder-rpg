class_name ShatteredGallery
extends RefCounted
## Overnight Nov 4-5, Part 5: The Shattered Gallery (S-GALLERY), the postgame dungeon behind the cracked mirror at Primm's castle door
## (docs/design/shattered_gallery.md). Three wings of Echoes - mirror versions of bosses and lieutenants the player beat, their own decks
## with more HP and one twisted rule each (data/encounters/modifiers.json) - then the mirror room, where The Perfect Copy plays an exact copy
## of the player's current deck. Mirror rules stack wing by wing (`DungeonRules`, "S-GALLERY"). Zone HP carries through; there is no
## healing between fights except one costly rest (node 8). Opened by Wren's postgame quest "Cracks in the Glass".

const DUNGEON_ID: String = "S-GALLERY"
const DUNGEON_NAME: String = "The Shattered Gallery"
const BOSS_NAME: String = "The Perfect Copy"
const ECHO_PREFIX: String = "Echo of "

## Node numbers each stacking rule covers (the Iron wing starts at 2, Order at 5, Appetite at 9). The mirror room (13) keeps only Silvered: with
## all three on top of its own extra draw The Perfect Copy won 97% against a strong late deck (Overnight Nov 4-5 sim).
const WING_IRON_ON: Array = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
const WING_ORDER_ON: Array = [5, 6, 7, 8, 9, 10, 11, 12, 13]
const WING_APPETITE_ON: Array = [9, 10, 11, 12]

## The Perfect Copy has the player's max HP plus this much, and draws one card more each turn (its encounter rule).
const PERFECT_COPY_HP_BONUS: int = 20

## Silver Reserve: the run starts at full HP with this much more max life (a duel costs a strong late deck about 10 HP, and nothing heals
## between the eight duels; without it no simulated run got past the third Echo).
const SILVER_RESERVE: int = 40


static func silver_reserve() -> ModifierSource:
	return CardBuilder.modifier_source("Silver Reserve", ModifierSource.SourceKind.BOON, [CardBuilder.modifier(Modifier.Kind.MAX_HP, SILVER_RESERVE)] as Array[Modifier])


## The quest that opens the glass (Wren, in the Crease, after Primm) and its flags.
const QUEST_ID: String = "cracks_in_the_glass"
const FLAG_MIRROR_SEEN: String = "gallery_mirror_seen"
const FLAG_CLEARED: StringName = &"gallery_cleared"
## The first clear's prizes: gold, essence of every Path, the Mirrored card finish (CosmeticState.mirrored_unlocked).
const FIRST_CLEAR_GOLD: int = 1500
const FIRST_CLEAR_ESSENCE: int = 6
const FEAT_ID: String = "through_the_glass"


## True for an Echo or the Perfect Copy: their pictures are drawn through the silver mirror shader (`MirrorTint`).
static func is_mirror_foe(enemy_name: String) -> bool:
	return enemy_name.begins_with(ECHO_PREFIX) or enemy_name == BOSS_NAME


## The enemy an Echo reflects ("Echo of Chancellor Clench" -> "Chancellor Clench"), for its Bestiary picture and sprite.
static func original_of(enemy_name: String) -> String:
	return enemy_name.trim_prefix(ECHO_PREFIX) if enemy_name.begins_with(ECHO_PREFIX) else enemy_name


## The Perfect Copy's seat: an exact copy of `player_deck` (the run's current deck, lost cards and all), the player's max HP plus
## PERFECT_COPY_HP_BONUS, and its encounter rule (one extra card a turn).
static func perfect_copy_setup(player_deck: Deck, player_max_hp: int) -> PlayerSetup:
	var deck: Deck = Deck.new()
	deck.deck_name = "Your Reflection"
	deck.cards = player_deck.cards.duplicate()
	var setup: PlayerSetup = PlayerSetup.create(deck, null, [] as Array[ModifierSource], BOSS_NAME)
	setup.starting_hp = player_max_hp + PERFECT_COPY_HP_BONUS
	setup.profile = PlayerProfile.new()
	setup.profile.max_hp = setup.starting_hp
	EncounterModifiers.apply_to_enemy(setup, BOSS_NAME)
	return setup

