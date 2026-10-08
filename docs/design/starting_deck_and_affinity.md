# Starting Deck, Primary Affinity and the Intro Dungeon

Design decisions for how a new campaign begins. All names (Affinity A-D, "Wellspring", "Wanderer")
are placeholders like the rest of the affinity naming; rename them in `Affinity.DISPLAY_NAMES`
and the story text below in one pass later.

**Reworked again for Part C of the second follow-up brief** (docs/design/open_questions.md D44).
The player used to clear the tutorial dungeon with a fixed neutral deck and choose their real
(two-color) starting deck only afterward. They now choose their **element** first, before the
dungeon even starts, and carry a single-element starter deck through it that grows to a full,
legal deck by the time they clear it. The rules below describe the current flow; see "History" at
the bottom for what changed and why.

## Flow

1. **The starting area** (`StartingAreaScene`, `scenes/starting_area.tscn`): a small, enclosed
   forest clearing, built from the same KayKit hex pieces as town. The hero wakes up alone and
   talks to themselves (placeholder lines in `data/story/intro_story.tres`, the one file to edit
   to rewrite the opening). The only interactable is the cave mouth. There is no way to reach town
   from here.
2. **The element choice** (`ElementChoiceScreen`, `core/dungeon/element_choice.gd`): confirming
   "Enter" at the cave mouth for the very first time (no profile exists yet) opens a full-screen
   choice between the four elements, each shown with its identity, playstyle and a few
   representative cards - see "Choosing" below. A retry after an abandoned first attempt (a
   profile already exists) skips this and reuses the same element.
3. **The tutorial dungeon** (`Session.begin_intro_trial(color)`): a fresh `PlayerProfile` is
   created with that element as `primary_affinity`, owning only the **23 neutral starter spells**
   (`CampaignStart.starter_spells`). The deck for the run is the **42-card starter**
   (`CampaignStart.starter_deck`): those 23 spells plus **19 basic infrastructure** of the chosen element -
   short of the normal 45-card minimum on purpose. `TrialOfTheHollow.deck_size_waiver()` (a
   `Modifier.Kind.MIN_DECK_SIZE` dungeon source) waives the minimum down to 42 for the whole run,
   so the deck is legal to play (and to edit/save in the in-dungeon deck builder, see below) the
   entire time.
4. **Tutorial rewards**: after each of the trial's 3 reward-granting fights (two regular battles
   plus the boss), the player picks 1 of 3 cards - but on this first-ever clear
   (`profile.intro_dungeon_cleared` still false), the choice is restricted to the player's own
   element only (`RewardGenerator.card_choices_for_color`), never neutral or another color. Each
   pick joins the collection *and* the run's current deck right away
   (`DungeonRun.gain_card`/`Session.apply_rewards`), so it is usable in the very next fight. Three
   picks bring the deck from 42 to a real 45 cards by the time the boss falls.
5. **Clearing the trial** (`Session.complete_trial`): the run's current deck (now 45 cards) becomes
   the player's real deck, `profile.intro_dungeon_cleared` and the `trial_cleared` flag are set -
   this is what unlocks the town. There is no separate deck-choice step any more.
6. **Town** (`TownScene`) is only reachable after that. The Wellspring landmark still exists but is
   a flavor/lore spot only (see "Wellspring" below).

If the player loses (or retreats from) the tutorial dungeon before finishing it, they are sent
back to the starting area to try again with the same element (not to a town they have not
unlocked yet, `Session.abandon_run`). Cards already picked from earlier reward screens in that
same run stay in the collection even if the run is later abandoned (rewards are granted per
battle won, not only on a full clear); the deck itself is rebuilt fresh (42 cards) on a retry.

## A deck builder inside the dungeon

The dungeon map screen has its own **Deck** button (`DungeonDeckbuilderScreen`), so the player is
never stuck with an unwanted starter draw for the whole trial. It is the same screen as town's
Deck Station, with the same validation rules (including the size waiver while it still applies) -
it just edits `DungeonRun.current_deck()` instead of `Session.deck`, and saving replaces
`run.base_deck` (clearing `lost_cards`/`gained_cards`, since the edited snapshot already reflects
everything).

## Rules

- The **starter deck** is always 23 neutral spells + 19 basic infrastructure of the chosen element = 42
  cards, including several 1-cost units (`apprentice_blade`, `scrappy_recruit`) so the
  opening turns have something to do. It is never a two-color deck.
- The 45-card minimum is waived **only inside the tutorial dungeon**, via a `MIN_DECK_SIZE`
  modifier (`TrialOfTheHollow.deck_size_waiver()`), not a special-cased check - `DeckValidator`
  and `DeckEditor` both read the minimum from the active modifiers everywhere.
- There is no neutral (colorless) infrastructure. Neutral *cards* cost generic energy and are play with infrastructure
  of any color.
- The other three elements' cards are not given to the player; nothing stops them from being
  bought/found and built into a second color later once town is reached (deck rules are unchanged
  from then on: 45 cards, 3 copies, 2 colors until the postgame flag - Part F).

## Why it makes sense in the story (placeholder lore)

The Wanderer wakes up with no memory of how they got here. Before the only way out - a shallow
cave, the **The Forgotten Cave** - one of the four **Wellsprings** already calls to them, faintly;
they answer it, and carry a scavenged, ordinary kit steeped in that element's nature into the
trial. Surviving it, and choosing their reward each time it offers one, is what actually attunes
them to it - by the time they emerge, the calling has become a real technique. *Then* the road to
town opens. A second element, and everything else, is earned by exploring and experimenting once
they arrive.

## Element identities

| Element | Identity | Playstyle |
|---------|----------|-----------|
| A | Beefcake hits hard and fast: haste, attack spells and huge aggressive bodies that punish a slow start. | Race to deal damage before the table settles. Strike first, strike often. |
| B | Gourmand answers: bounce, card draw and food-golem defenders that buy time while you out-cook the opponent. | Control the pace, see more cards than they do, win the long game. |
| C | Refusemancer grows: big, sturdy units and HP gain that outlast anything thrown at them. | Stabilize behind tough bodies, then close it out with size. |
| D | Necrocrat trades: sacrifice, death triggers and drain effects that turn losses into value. | Grind through exchanges; every unit that dies is doing you a favor. |

See `core/dungeon/element_choice.gd` for the full text and sample cards shown on the choice
screen, and `tests/core/dungeon/test_element_choice.gd` for the coverage. The two-color sample
decks (Beefcake & Gourmand, Gourmand & Refusemancer, Refusemancer & Grave, Grave & Beefcake) still exist in
`ContentDefinitions.deck_recipes()`, but only for the AI balance simulation now - they are not
offered to the player anywhere.

## History

Two flows came before this one:

1. Originally the player picked their color at the town Wellspring before any dungeon, and got
   only the neutral deck plus that color's infrastructure to start; the intro dungeon then granted 5 cards
   of that color once cleared.
2. That was replaced by clearing the tutorial with a *fixed neutral* deck first, then choosing one
   of four pre-built two-color decks afterward (`StartingDecks`/`StartingDeckChoiceScreen`,
   superseded and removed).

See git history / `open_questions.md` D4-D6, D31, D44 for the full reasoning behind each change.
Flow (2) is fully superseded by the one above.

## Story v2 Part C: the opening, the new starting decks and the Forgotten Cave

**Flow now.** (1) Look screen (hat, cloak). (2) The Wanderer wakes in the forest clearing, says the old awakening lines. (3) A hooded **Rescuer** (`NPC-RESCUER`, name token `{rescuer}`, placeholder portrait) kneels beside them. After a short exchange ("can you still fight and pull energy from the Paths?", "you are weaker than I feared") the Rescuer asks which Path the Wanderer walked the most: **the starting deck choice (`ElementChoiceScreen`) happens here**, inside the conversation. It was removed from the cave gate. `Session.choose_starting_path` builds the profile and the 42-card starter at that moment. (4) The Rescuer points to the Forgotten Cave ("Crosspath is on the other side"), walks into the trees and fades out. (5) The clearing is bounded: pressing against the treeline (the secret nooks and the tunnel excepted) makes the Wanderer say a self-talk line ("I have to go through that cave...") and nudges them back. (6) The cave gate now only asks "Enter?" and walks into the Forgotten Cave. (7) The Hollow Warden grumbles the Wanderer "smells familiar" before the fight and lets them pass after. (8) Clearing the cave shows "Step outside": the cave-mouth scene where **Elder Maren** waits, then Crosspath. All text is in `data/story/intro_story.tres` (`prologue.*`, `tutorial.warden.*`, `cave_mouth.*`).

**Secret tunnel.** Still works until the cave is cleared; it keeps the Path chosen in the Rescuer scene (a brand-new profile that somehow has none still shows the choice).

**Hidden lab entrance.** An `L` cell in the south treeline of the clearing (anchor `lab`); built and blocked exactly like treeline until `StartingAreaBuilder.lab_open` (Part H).

**Starter packages.** The colorless template (23 cards) gives up 8 cards (C-01 x2, C-04, C-05, C-10, C-12, C-16, C-19) to make room for 8 Common cards of the chosen Path that create and spend its Resource. 19 basic Infrastructure of the Path + 15 colorless + 8 package = 42; the 3 reward picks make 45. Never more than 3 copies of a card.

| Path | Package (copies) | Resource role |
| --- | --- | --- |
| Beefcake | Hamster Wheel Runner B-05 (2), Gym Bro B-01 (2), Personal Trainer B-09, Millstone Pusher B-04, Dropped Weights B-03, Weight Belt B-14 | B-05 creates Iron, B-09 grows from using Iron |
| Gourmand | Line Cook G-01 (2), Sushi Apprentice G-02 (2), Windowsill Herb Garden G-15, Kitchen Porter G-09, Meatloaf Mold G-12, The Recipe Engine G-10 | G-01/G-15/G-09 create Ingredients, G-02/G-12/G-10 spend them |
| Refusemancer | Curbside Rat R-06 (2), Possum Prowler R-08 (2), Dumpster Diver R-02, Community Compost Bin R-10, Kidding Around R-05, Alley Scrap R-19 | R-06/R-02/R-10 create Garbage, R-08 eats it |
| Necrocrat | Skeleton Clerk N-01 (2), Infernal Intern N-02 (2), Body-builder N-04, Red Tape Dispenser N-09, Corpseified Public Accountant N-05, Pink Slip N-15 | N-01/N-02/N-09/N-05 create Red Tape, N-04 spends it |

Colorless remainder (15): Cannon Fodder, Village Militia x3, Watchtower Archer x2, Courier Pigeon, Traveling Brawler x2, Wandering Medic, Tavern Regular, Traveler's Sword, Rally the Village, Second Wind, Ambush Party.

**The cave has no Beefcake or Necrocrat.** Enemy decks use Gourmand/Refusemancer infrastructure and colorless or G/R cards only (`TrialOfTheHollow.enemy_recipe`), the nodes and the Well challenge have no such cards, and rewards are the player's own Path (their choice, so a Beefcake or Necrocrat starter is their own, not the cave's).
