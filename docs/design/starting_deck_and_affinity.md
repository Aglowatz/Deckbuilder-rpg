# Starting Deck, Primary Affinity and the Intro Dungeon

Design decisions for how a new campaign begins. All names (Affinity A-D, "Wellspring", "Wanderer")
are placeholders like the rest of the affinity naming; rename them in `Affinity.DISPLAY_NAMES`
and the story text below in one pass later.

## Rules

- The player starts with **only the neutral starter deck** ("Wanderer's Pack"): 28 neutral
  spells and 17 basic lands. No colored spell is owned at the start.
- At the very beginning the player **picks one primary color**. It decides the color of the 17
  basic lands in the starter deck (`CampaignStart.starter_deck`). It is saved on the profile as
  `PlayerProfile.primary_affinity`.
- There is no neutral (colorless) land. Neutral *cards* cost generic mana and are cast with lands
  of any color.
- After clearing the **intro dungeon**, the player receives **5 cards of their chosen color**
  (one copy of five different cards, `CampaignStart.complete_intro_dungeon`), granted exactly once
  (`PlayerProfile.intro_dungeon_cleared`). The reward lists live in
  `ContentDefinitions.attunement_rewards()`.
- The sample pair decks (Ember & Tide, Tide & Root, ...) are **not** given to the player. They are
  opponents' decks and balance references. Players discover more cards and build their own decks;
  the normal deck rules apply (45 cards, 3 copies, 2 colors until the postgame flag).

## Why it makes sense in the story (placeholder lore)

The Wanderer is a nobody from the roads, carrying only ordinary gear: the neutral cards are
mundane tools and hired help that anyone can use. What they do have is a **pull**: every
Wanderer feels drawn to one of the four **Wellsprings** of the world (the four affinities). The
choice at the start is answering that pull. From the first day the Wanderer can draw raw power
from the ground of that Wellspring, which is why their basic lands are of that color, but they
have no *technique*: no colored spells, just untrained mana feeding ordinary tools.

The intro dungeon is the **Trial of the Hollow**, a shallow cave the pull leads them into. Its heart
is a small spring of their Wellspring. Clearing the trial makes the spring **recognize** them: it
teaches five techniques (the five attuned cards). That is the moment the Wanderer becomes an
attuned mage instead of a hired blade, and it explains why they now hold cards of exactly the
color they chose, and only that color. Everything beyond that (a second color, the other pair
decks) is earned by exploring and experimenting.

## Cards per color (attunement reward)

| Color | Theme | Reward cards |
|-------|-------|--------------|
| A | aggressive | Ember Imp, Blade Dancer, Raider, Firebolt, Flame Burst |
| B | control | Frost Sentry, Sage, Recall, Deep Insight, Dissolve |
| C | big creatures | Mossback Bear, Rampaging Boar, Stag Warden, Growth, Rejuvenate |
| D | sacrifice/value | Bone Servant, Grave Tender, Martyr, Bloodthirst Wolf, Soul Drain |

Each set is a small, playable core of that color's identity (two or three creatures, a removal or
utility spell, a finisher/support) that mixes cleanly into the neutral starter.
