# Draft mode: design (owner decisions, Nov 22)

The owner moved the launch back to ship this with 1.0 (no hard date). This is the agreed design for Claude Code runs to build. Where a detail says "default", the run picks it and the owner tunes it later.

## Goals
- A fun, repeatable endgame activity, Hearthstone-style drafting.
- A main way to collect multi-Path cards, prismatic packs and powerful gear.
- **Small and light:** code and data, plus about 20-25 new pictures (about 10-20 MB). The fights use the existing battle engine, and the draft screens use the card art already in the game.

## A separate mode with its own rules
- **Player HP:** the base HP for the player's level, with no equipment bonuses or penalties.
- **Opening hand:** the player's normal hand size for their level.
- **Equipment and items:** only what is drafted in this run. The main game's loadout doesn't apply.
- **The deck:** 35 cards. 20 come from the 25 drafted cards, and 15 are basic Infrastructure added automatically, split across the drafted Paths (the player can change the split). Non-basic Infrastructure can be offered as a pick and counts among the 20.
- **No copy limits:** no rarity or level caps, and more than 3 copies is fine. A deck with 5 or 6 copies of a common is allowed; crazy decks are part of the fun.
- The main game's 45-card minimum and its copy caps don't apply here.
- **The multi-Path lock stays consistent:** two-Path cards and challenges open with the Crosspath draft arena (after all four zones); three- and four-Path cards and challenges open after Primm.

## The draft
1. **Choose Paths first.**
   - Set challenges (zone drafts, arena challenges) fix the Paths.
   - Repeatable drafts let the player choose 1 to 4 Paths.
   - Offers come only from the chosen Paths plus **Pathless cards (always included)**.
   - A multi-Path card is offered only if all its Paths are chosen (and three- and four-Path cards only after Primm).
2. **25 card picks, one of three each time.**
   - **Guaranteed high-rarity slots:** default every 5th pick (picks 5, 10, 15, 20, 25) offers three cards of the top two rarities.
   - Other picks are weighted by rarity (default: mostly commons and uncommons, some rares).
   - Offers lean toward cards that fit what's already taken, never three useless options.
   - The screen shows the cost curve and the Path split so far.
3. **5 equipment picks** spread through the draft (default after picks 4, 9, 14, 19 and 23): a random slot each time, three pieces for that slot, weighted by rarity.
4. **2 item picks** (default after picks 7 and 17): three items each time, for the run's 2 item slots.
5. **One reroll per draft** to start. It can be spent on a card, equipment or item offer, and is built so the number can change later.
6. **Equipment and items in the pool:** start with **all** equipment and items in the game. Fable's sims and the owner's playtests decide whether anything is too broken and gets banned from drafts (a ban list in data).
7. **Every piece of equipment made for drafts also exists in the main game**, even if it's weak: sold by vendors, found in chests, or given by draft quests. The weaker pieces show up earlier and more easily.
8. **Saving:** a draft in progress (picks, offers, the reroll, wins and losses) is saved and resumes after quitting.

## A run
- **Fights:** three opponents, with full HP each fight.
- **Default end:** 3 wins, or 2 losses. The owner may tune this.
- **Opponents:**
  - **Rival drafters:** AI decks drafted with the same system, each with a personality (aggressive, controlling, swarming), using existing NPC portraits and names;
  - **Champions:** hand-made decks for set challenges;
  - **Fudging:** opponents must be competitive. If the AI drafts badly, fix its deck (fudge it) so fights stay fun.
- **Rewards:**
  - something for every result, rising with wins, with a clear bonus for winning all three;
  - **the first win of each thing pays much more** (a zone draft, an arena draft, a two-Path draft and so on);
  - **keep one card:** after a full win, the player chooses one drafted card to keep in their collection. This applies to dungeon drafts too.
- **Entry fee:** **100 gold for every draft; the first attempt at each one is free.**
- **Draft of the Day:** the same offers for every player on a given date (worked out from the date, no internet needed).
- **Feats:** go 3-0, finish every combination, win a dungeon draft without a loss, and more.

## Where it happens
1. **The travelling draft host** (a new recurring character, like Dex and Rip): appears in every zone.
   - In each zone: a draft with **that zone's Path** (all its cards available, plus Pathless). Win three fairly even fights.
   - A **draft quest line** rewards fun, powerful equipment, plus cards, gold and experience.
   - **Rewards:** solid the first time, fair on replays.
2. **The Crosspath draft arena** (like the Undercroft, reusing the cave arena's look): opens when all four zone drafts are beaten.
   - Challenges for each **two-Path pair** (6), then after Primm each **three-Path set** (4) and **all four** (1); complete one of each.
   - Each challenge is three fights: some truly random, some set (the main arena challenges).
   - A main source of **multi-Path cards and prismatic packs**.
3. **Dungeon drafts:** once a zone is freed, its main dungeon becomes a draft challenge.
   - Draft a deck, then play the dungeon. **After each real fight, pick one of three cards:** add it, replace a card with it, or take nothing.
   - Rewards: cards, packs, essence, late-game rewards. **Primm's Castle awards prismatic packs.**
   - **A dungeon map made for drafts** (planned by Fable; it needs a painted map in the art batch). Its rooms shape the run more directly:
     - offers of relevant multi-Path cards;
     - challenging but rewarding planned encounters;
     - heals, buffs and curses.

     The zone dungeons stay available as well.
   - **Later option:** harder levels for replays (more HP for every encounter, stronger units, opponents starting with resources, Infrastructure or extra cards).
4. **Prismatic packs** already exist: 4 cards, at least one multi-Path, sold by Foil Fenwick after Primm. Drafts become another source.

## New pictures (about 20 to 25; Fable writes the rows)
- **The draft host:** portrait, world poses and shop backdrop (4-5 pictures).
- **Screens:** the pick screen backdrop, and the draft hall (possibly the cave arena menu reused).
- **The draft dungeon map.**
- **Icons:** the map marker, and a reroll icon if needed.
- **Equipment:** 6-8 icons for the reward gear (the weaker draft gear reuses existing icons).
- **Cards:** 4-8 new card arts for a few fun, high-impact new cards.
- Everything else (opponent portraits, battle boards, the Undercroft) is reused.

## Building it
- **Phase 1:**
  - the draft engine (Path choice, offers, rarity slots, equipment and item picks, the reroll, building the 35-card deck, saving and resuming, AI drafters and fudging, runs, rewards, the fee);
  - the travelling host and the four zone drafts with their quest line;
  - the art rows.
- **Phase 2:** the Crosspath draft arena and its 11 challenges, the champions, prismatic packs as rewards, Draft of the Day, feats.
- **Phase 3:**
  - dungeon drafts with a pick after each fight, and the draft dungeon map;
  - the Primm's Castle draft;
  - balance sims (opponent strength, equipment and item bans, rewards against the economy).
- **Between phases:** the owner playtests, and a ChatGPT art batch is made.
