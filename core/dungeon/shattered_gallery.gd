class_name ShatteredGallery
extends RefCounted
## Overnight Nov 4-5, Part 5: The Shattered Gallery (S-GALLERY), the postgame dungeon behind the cracked mirror at the top of Grave Row
## (docs/design/shattered_gallery.md). Three wings of Echoes - mirror versions of bosses and lieutenants the player beat, their own decks
## with more HP and one twisted rule each (data/encounters/modifiers.json) - then the mirror room, where The Perfect Copy plays an exact copy
## of the player's current deck. Mirror rules stack wing by wing (`DungeonRules`, "S-GALLERY"). Zone HP carries through; there is no
## healing between fights except one costly rest (node 8). Opened by Wren's postgame quest "Cracks in the Glass".

const DUNGEON_ID: String = "S-GALLERY"
const DUNGEON_NAME: String = "The Shattered Gallery"
const BOSS_NAME: String = "The Perfect Copy"
const ECHO_PREFIX: String = "Echo of "
## Import Nov 8 (Batch 13): every Gallery fight plays on BB-S-GALLERY (the dungeon's board); the final room, The Perfect Copy, on its own
## BB-S-GALLERY-ALT so the boss fight looks different (the dungeon board stays when the ALT is not imported).
const BOSS_BOARD: String = "BB-S-GALLERY-ALT"


## The board of a Gallery fight: the ALT board for the boss (The Perfect Copy), else `dungeon_board`.
static func board_for(is_boss: bool, dungeon_board: String) -> String:
	if is_boss and Battleboards.has_own_image(BOSS_BOARD):
		return BOSS_BOARD
	return dungeon_board

## Node numbers each stacking rule covers (the Iron wing starts at 2, Order at 5, Appetite at 9). The mirror room (13) keeps only Silvered: with
## all three on top of its own extra draw The Perfect Copy won 97% against a strong late deck (Overnight Nov 4-5 sim).
const WING_IRON_ON: Array = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
const WING_ORDER_ON: Array = [5, 6, 7, 8, 9, 10, 11, 12, 13]
## Overnight Nov 7-8, Part 4 (approved): Perfect Form no longer stacks on the third wing's ordinary fights - only from the Evergreen Frame (11) on.
const WING_APPETITE_ON: Array = [11, 12]

## The Perfect Copy has the player's max HP plus this much, and draws one card more each turn (its encounter rule).
const PERFECT_COPY_HP_BONUS: int = 20

## Nov 25 night (Part D.2): the Silver Reserve is no longer +40 max HP for everyone. At the Cracked Frame (the entrance) the player picks
## ONE of THREE boons drawn at random from this pool; it lasts for the run. Each entry: id, name, boon spec (`DungeonBuilder.boon_from`),
## what it does in words. Balanced against each other in docs/design/sim/nov25n/gallery_boons.md.
const SILVER_PREFIX: String = "Silver Reserve: "
const SILVER_BOONS: Array = [
	["thick", "Thick Glass", "max_hp=30", "+30 max HP for the run."],
	["guard", "Polished Guard", "def=2", "Your units get +0/+2."],
	["edge", "Silvered Edge", "atk=1,def=1", "Your units get +1/+1."],
	["look", "A Second Look", "draws=1", "Draw an extra card each turn."],
	["purse", "A Full Purse", "each_res=1", "Start each fight with one Iron, one Red Tape, one Ingredient and one Garbage."],
	["start", "A Head Start", "infra=1", "Start each fight with an Infrastructure from your deck in play."],
	["first", "The First Reflection", "first_unit_atk=3,first_unit_def=3", "The first unit you play in each fight gets +3/+3."],
	["mend", "Mending Light", "start_hp=8", "Heal 8 at the start of each fight (up to your max HP)."],
	["hand", "A Steady Hand", "draw=2,first=1", "Two more cards in your opening hand, and you take the first turn."],
]
const SILVER_OFFER: int = 3
const SILVER_EVENT_ID: String = "S-GALLERY-silver"


## The Silver Reserve boon `id` as a run source ("Silver Reserve: Thick Glass").
static func silver_boon(id: String) -> ModifierSource:
	for entry: Array in SILVER_BOONS:
		if str(entry[0]) == id:
			return DungeonBuilder.boon_from("%s%s|%s" % [SILVER_PREFIX, str(entry[1]), str(entry[2])])
	return null


## Kept for the tools that seat a Gallery run without the choice (the old rule-audit sweep, the balance sim): the plain HP boon.
static func silver_reserve() -> ModifierSource:
	return silver_boon("thick")


## The three boons offered on a run with this seed (distinct, in pool order).
static func silver_offer(seed_value: int) -> Array[String]:
	var ids: Array[String] = []
	for entry: Array in SILVER_BOONS:
		ids.append(str(entry[0]))
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash([seed_value, "silver"])
	RngUtil.shuffle(ids, rng)
	var offered: Array[String] = ids.slice(0, SILVER_OFFER)
	var ordered: Array[String] = []
	for entry: Array in SILVER_BOONS:
		if offered.has(str(entry[0])):
			ordered.append(str(entry[0]))
	return ordered


## True once the run carries one of the Silver Reserve's boons.
static func has_silver(run: DungeonRun) -> bool:
	if run == null:
		return false
	for source: ModifierSource in run.dungeon_sources:
		if source != null and source.source_name.begins_with(SILVER_PREFIX):
			return true
	return false


## The choice pop-up at the Cracked Frame: one button per offered boon (its own words in brackets). Built in code; its text goes into
## the dungeon text table under the event's keys like any dungeon event.
static func silver_event(seed_value: int) -> DungeonEvent:
	var event: DungeonEvent = DungeonEvent.make(SILVER_EVENT_ID)
	DungeonCatalog.set_text(event.title_key(), ["The Silver Reserve"])
	DungeonCatalog.set_text(event.body_key(), ["Three tall frames lean against the wall of the Cracked Frame, and in each of them stands a slightly better you. The glass will let one of them step out and walk the gallery with you. Choose which."])
	var index: int = 0
	for id: String in silver_offer(seed_value):
		var entry: Array = []
		for candidate: Array in SILVER_BOONS:
			if str(candidate[0]) == id:
				entry = candidate
		DungeonCatalog.set_text(event.choice_key(index), ["%s" % str(entry[1])])
		DungeonCatalog.set_text(event.result_key(index), ["The reflection steps out of the frame and falls into step beside you: %s It stays with you until you leave the gallery." % str(entry[3])])
		event.choice([DungeonEvent.boon(silver_boon(id)), DungeonEvent.hint_text(str(entry[3]))] as Array[DungeonEvent.Outcome])
		index += 1
	return event


## The quest that opens the glass (Wren, in the Crease, after Primm) and its flags.
const QUEST_ID: String = "cracks_in_the_glass"
const FLAG_MIRROR_SEEN: String = "gallery_mirror_seen"
const FLAG_CLEARED: StringName = &"gallery_cleared"
## The first clear's prizes: gold, essence of every Path, the Mirrored card finish (CosmeticState.mirrored_unlocked).
const FIRST_CLEAR_GOLD: int = 1200  # Fable pass Nov 10 (Part 4.3): 1500 x 0.8
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

