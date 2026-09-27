# Starting Deck, Primary Affinity and the Intro Dungeon

Design decisions for how a new campaign begins. All names (Affinity A-D, "Wellspring", "Wanderer")
are placeholders like the rest of the affinity naming; rename them in `Affinity.DISPLAY_NAMES`
and the story text below in one pass later.

**Reworked for the post-demo pass (docs/design/open_questions.md D31).** The player used to pick
their color at a town landmark, before ever fighting anything. They now wake up alone outside
town, clear the tutorial dungeon with a fixed neutral deck, *then* choose their real starting
deck. The rules below describe the current flow; see "History" at the bottom for what changed.

## Flow

1. **The starting area** (`StartingAreaScene`, `scenes/starting_area.tscn`): a small, enclosed
   forest clearing, built from the same KayKit hex pieces as town. The hero wakes up alone and
   talks to themselves (placeholder lines in `data/story/intro_story.tres`, the one file to edit
   to rewrite the opening). The only interactable is the cave mouth. There is no way to reach town
   from here.
2. **The tutorial dungeon** (`Session.begin_intro_trial`): entering the cave starts the Trial of
   the Hollow with a **fixed neutral tutorial deck** - the "Wanderer's Pack" template
   (`CampaignStart.STARTER_DECK_NAME`, 28 neutral spells + 17 basic lands) exactly as authored, no
   player choice involved. A fresh `PlayerProfile` is created right away (still
   `primary_affinity = NEUTRAL`) so gold and reward cards earned during the tutorial persist
   normally.
3. **The starting-deck choice** (`StartingDeckChoiceScreen`, right after the boss reward): the
   player picks one of four decks, one per affinity (`StartingDecks`), each shown with its
   identity, playstyle and a few key cards. The deck is built from the existing balanced two-color
   sample decks (`ContentDefinitions.deck_recipes()`), reframed by its primary color - e.g. "Ember
   & Tide" is offered as the Ember identity deck. Choosing one (`Session.choose_starting_deck`):
   sets `PlayerProfile.primary_affinity`, adds every card in the chosen deck to the collection (so
   it is legal to play immediately), sets it as `Session.deck`, and sets the `trial_cleared` flag
   - which is what actually unlocks the town.
4. **Town** (`TownScene`) is only reachable after that choice. The Wellspring landmark still
   exists but is now a flavor/lore spot only (see "Wellspring" below) - it no longer opens a
   choice screen.

If the player loses (or retreats from) the tutorial dungeon before choosing a deck, they are sent
back to the starting area to try again, not to a town they have not unlocked yet
(`Session.abandon_run`). Progress made so far (gold, cards from earlier reward screens in that
same run) is kept, since the profile already exists by then.

## Rules

- The **tutorial deck** is always the same neutral "Wanderer's Pack" template - not tied to any
  color choice, since there is none yet.
- The **starting deck** is a real, legal, two-color 45-card deck (not a thin neutral-plus-lands
  starter). There is no separate "5-card attunement reward" any more - owning the whole deck *is*
  the reward. Old saves / helpers that still build the old neutral-plus-one-color deck
  (`CampaignStart.starter_deck`) are kept only as a lightweight fallback and for tests.
- There is no neutral (colorless) land. Neutral *cards* cost generic mana and are cast with lands
  of any color.
- The other three starting decks (the ones not chosen) are not given to the player, but nothing
  stops them from being built later once the cards are owned - deck rules are unchanged (45 cards,
  3 copies, 2 colors until the postgame flag).

## Why it makes sense in the story (placeholder lore)

The Wanderer wakes up with no memory of how they got here, and no colors of their own yet - just
a scavenged, ordinary kit (the neutral tutorial deck). The only way out is through a shallow cave,
the **Trial of the Hollow**. Surviving it is what marks them: at its heart, whichever of the four
**Wellsprings** they are drawn to recognizes them, and they walk out already carrying that
Wellspring's full technique (the starting deck), not just a taste of it. *Then* the road to town
opens. Everything beyond that (a second color, the other decks) is earned by exploring and
experimenting once they arrive.

## Starting decks (one per affinity)

| Color | Deck | Identity | Key cards |
|-------|------|----------|-----------|
| A | Ember & Tide | Fast: haste, burn, aggressive bodies | Ember Imp, Blazing Charger, Firebolt |
| B | Tide & Root | Control: bounce, draw, defenders | Deep Insight, Frost Sentry, Recall |
| C | Root & Grave | Big and sturdy, life gain | Ancient Treant, Mossback Bear, Growth |
| D | Grave & Ember | Sacrifice/value, death triggers, drain | Bloodthirst Wolf, Necromancer, Soul Drain |

See `core/dungeon/starting_decks.gd` for the full identity/playstyle text shown in the choice
screen, and `tests/core/dungeon/test_starting_decks.gd` for the coverage.

## History

Originally the player picked their color at the town Wellspring before any dungeon, and got only
the neutral deck plus that color's lands to start; the intro dungeon then granted 5 cards of that
color once cleared (see git history / `open_questions.md` D4-D6, D31 for the full reasoning
behind the change). That flow is fully superseded by the one above.
