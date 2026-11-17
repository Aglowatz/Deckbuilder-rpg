# Critic 1 - combat and deckbuilding: the core fun (Nov 17)

Read `docs/review/critic_nov17_common.md` first (the rules, the commands, the report). Then this brief. Nothing else.

**Your lens:** is the core loop fun? Fights, the decisions in them, the pace, how the enemy plays, card balance, how rewarding a new card
feels, packs, the card shops and building a deck. Across the game's history **fun has never scored above 6/10**; find out exactly why.
Think like a Slay the Spire or Monster Train player: are there real choices each turn, do fights end on interesting decisions, are
there synergies to discover, does a new card change how you play, is the enemy readable, is the pace right, does winning feel earned?

**Budget: 14 runs, 80 minutes.** Lens name for files: `combat`. Report: `docs/review/critic_nov17/01_combat.md`.

## What to play

**Play at least 6 of the 12 fights yourself, by hand** (clicks, drags, End Turn): read the cards, plan, block, attack. Use `pilot` only for
the others, and say which were yours. Twelve fights in all, across three zones and two Paths:

1. **Early game, the Refusemancer Path (about level 5):** `dev load bot_refusemancer_enter_refusemancer` (you stand at the Verdant Dump's
   entrance with a real deck). Fight two roaming enemies by hand. Open the Deck Station is in town (`dev travel town`, `key B`): look at
   your deck, build or change it, use its suggestions if it offers them; open your packs (`key P`); visit **Sable's card shop** on the
   town square (walk up, `key E`) and buy something.
2. **Mid game, the same Path:** `dev load bot_refusemancer_enter_gourmand` (the Endless Buffet, a stronger hero). Fight two roamers by
   hand, then play **the zone's main dungeon from start to finish**: walk to its door if you can, else `dev travel dungeon D-TTK`. Every
   room, every pick on the reward screens, and **the boss by hand** (no `dev win` on the boss, ever; if you lose, try again once and say so).
3. **A second Path:** `dev load bot_beefcake_enter_necrocrat` (a Beefcake hero entering the D.N.A.). Two fights by hand, one with
   the pilot. Note how the Beefcake deck plays compared with the Refusemancer deck: is each Path's style distinct?
4. **The rewards:** after fights, how do the reward screens, the card picks, level-ups and packs feel? Buy and open a pack in a zone
   shop (each zone hub has a card vendor) and decide whether any card you got changes your deck.

Shoot every reward screen and at least two full turns of one fight (the enemy's turn too). `rclick` a card for its full preview.

## Your report also answers, in one short paragraph each

- **Decisions:** in a typical turn, how many real options did you have, and how often was the right play obvious?
- **Pace:** how long did a fight take (turns, minutes)? Too fast, too slow, too much waiting on animations?
- **The enemy:** could you read what it would do? Did it ever surprise you in a good way?
- **Cards:** name the three best and the three deadest cards you saw, and why.
- **Rewards and deckbuilding:** did any new card make you rebuild your deck? Did the Deck Station help or get in the way?
- **The one change** that would raise fun the most.
