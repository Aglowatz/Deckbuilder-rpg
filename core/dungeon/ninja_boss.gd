class_name NinjaBoss
extends RefCounted
## Brief 16, Group B: Shiro Swindle, Master of the Oldest Trick (NPC-NINJA). Five joke giant chests (the original one in the
## main town and one in each Path zone) each hide him: he pops out, mocks the player, steals 50 gold (or all of it) and vanishes in a
## smoke bomb. Once all five were opened the original chest closes again and glows; opening it starts the duel (a tricky trap deck on
## the town battleboard). Winning returns every stolen coin, pays 3 Gilded Packs (one random Path each) and ends the questline.
## Single source of truth for the encounter (ids, taunts, deck, rewards); the sequence itself is `world/ninja/giant_chest_event.gd`.

const NPC_ID: String = "NPC-NINJA"
const DISPLAY_NAME: String = "Shiro Swindle"
const TITLE: String = "Master of the Oldest Trick"
const STARTING_HP: int = 18
const STEAL_AMOUNT: int = 50
const QUEST_ID: String = "oldest_trick"
## The original chest (main town) comes first; the others are zone ids (`ZoneDefs`): Gainlands, D.N.A., Endless Buffet, Verdant Dump.
const ORIGINAL_CHEST: String = "town"
const CHEST_IDS: Array[String] = ["town", "beefcake", "necrocrat", "gourmand", "refusemancer"]
const SECRET_PREFIX: String = "ninja_chest_"
const FLAG_DEFEATED: StringName = &"ninja_defeated"
## Counters (Session.counters): total gold taken so far (returned on a win) and how many chests were opened.
const COUNTER_STOLEN: String = "ninja_gold_stolen"
const COUNTER_OPENED: String = "ninja_chests_opened"
const PACK_REWARD_COUNT: int = 3
const AI_NAME: String = "Balanced"

## A tricky, themed deck: traps that punish attackers and bounce/plate/exhaust units, evasive fliers and Elusive scouts, a few
## cheap removal spells and one Unconscionable Contract (he steals your best unit). 17 basic Infrastructure (Necrocrat + Gourmand).
const DECK_RECIPE: Dictionary = {
	"BAS-N": 9, "BAS-G": 8,
	"C-16": 2, "C-17": 2, "G-16": 2, "G-17": 2, "N-12": 2, "C-27": 1,
	"N-15": 2, "N-32": 1,
	"C-23": 3, "N-06": 2, "C-04": 2, "N-26": 1, "N-02": 2, "G-01": 2, "C-22": 2,
}

const TAUNTS: Dictionary = {
	"town": [
		"[smug] Well, well, well! A giant chest, sitting all alone in the middle of nowhere?",
		"[smug] Nobody has fallen for that since the Cave Mouth was a pothole! It is the oldest trick in the book, friend.",
		"Shiro Swindle, Master of the Oldest Trick. At your service. And at your expense.",
	],
	"beefcake": [
		"[smug] A giant chest. Next to a gym. Waiting for a big strong hero to flex it open!",
		"[smug] I put it right where the muscle-brained would trip over it. And here you are! The oldest trick in the book!",
		"Keep lifting, champ. I'll just lighten your purse.",
	],
	"necrocrat": [
		"[smug] A giant chest in the middle of an office, with no paperwork? You did not file a Form 27-B before opening it?",
		"[smug] Hand a stranger's treasure chest to an accountant and they open it. The oldest trick in the book!",
		"I'll be taking my fee now. Processing time: instant.",
	],
	"gourmand": [
		"[smug] A giant chest, at a buffet! You thought it was the dessert tray, didn't you?",
		"[smug] Bigger than a pie, shinier than a pie, and not a pie. The oldest trick in the book!",
		"No refunds. No substitutions. Your gold is the appetizer.",
	],
	"refusemancer": [
		"[smug] A giant chest in a junk heap, shiny and clean? Treasure does not lie around in the garbage, friend!",
		"[smug] One person's trash is another person's trap. The oldest trick in the book!",
		"Don't worry. I recycle. Your gold is going to a good home.",
	],
}

## Added after the fifth chest's taunt (whichever chest it is): where to find him.
const FINAL_HINT: Array[String] = [
	"[smug] Oh? You have opened every last giant chest in the kingdom. I am almost impressed.",
	"[smug] If you want your gold back, come and meet me where it all began. Bring your best deck.",
]
const SMOKE_SHOUT: String = "SMOKE BOMB!!!"

const OPEN_AGAIN_LINES: Array[String] = [
	"The chest is empty. It smells faintly of smoke and smugness.",
]

const FIGHT_BEFORE: Array[String] = [
	"[smug] So you came. To the first chest. Where it all began.",
	"[smug] Let's see whether you're as good with cards as you are at opening suspicious chests.",
	"Oh, and your gold? Right here. Come and win it back!",
]
const FIGHT_WIN: Array[String] = [
	"[angry] Impossible. Beaten at the oldest trick in the book?",
	"[smug] Fine, fine. A deal is a deal. Every coin back, plus three Gilded Packs for emotional damages.",
	"Next time, try not opening giant chests. Although... I will always be watching. SMOKE BOMB!!!",
]
const FIGHT_LOSE: Array[String] = [
	"[smug] Ha! Too slow, too trusting, too honest.",
	"Come back when you've learned the second-oldest trick: not opening the chest. Try again whenever you like.",
]


static func secret_id(chest_id: String) -> String:
	return SECRET_PREFIX + chest_id


static func is_chest_id(chest_id: String) -> bool:
	return CHEST_IDS.has(chest_id)


## Gold he takes: 50, or everything when the player has less.
static func steal_amount(gold: int) -> int:
	return clampi(gold, 0, STEAL_AMOUNT)


## How many of the five chests were opened, given the saved secrets.
static func opened_count(found_secrets: Array[String]) -> int:
	var count: int = 0
	for chest_id: String in CHEST_IDS:
		if found_secrets.has(secret_id(chest_id)):
			count += 1
	return count


static func all_opened(found_secrets: Array[String]) -> bool:
	return opened_count(found_secrets) == CHEST_IDS.size()


## The unique taunt of `chest_id`; the fifth opened chest also gets the hint to meet him where it all began.
static func taunt_lines(chest_id: String, is_fifth: bool) -> Array[String]:
	var lines: Array[String] = []
	for line: Variant in TAUNTS.get(chest_id, TAUNTS[ORIGINAL_CHEST]) as Array:
		lines.append(str(line))
	if is_fifth:
		lines.append_array(FINAL_HINT)
	return lines


static func deck(content: ContentSet) -> Deck:
	return ZoneDecks.from_recipe(content, DISPLAY_NAME, DECK_RECIPE)


static func personality(content: ContentSet) -> AIPersonality:
	return ZoneDecks.personality(content, AI_NAME)


static func enemy_setup(content: ContentSet) -> PlayerSetup:
	var setup: PlayerSetup = PlayerSetup.create(deck(content), null, [] as Array[ModifierSource], DISPLAY_NAME)
	setup.starting_hp = STARTING_HP
	setup.profile = PlayerProfile.new()
	setup.profile.max_hp = STARTING_HP
	return setup


## The Path of each of the three Gilded Packs (random, one per pack; repeats are possible).
static func reward_paths(rng: RandomNumberGenerator) -> Array[Affinity.Type]:
	var paths: Array[Affinity.Type] = Affinity.colored_types()
	var result: Array[Affinity.Type] = []
	for i: int in range(PACK_REWARD_COUNT):
		result.append(paths[rng.randi() % paths.size()])
	return result
