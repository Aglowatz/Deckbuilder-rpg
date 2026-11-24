# Draft mode: design (owner decisions, Nov 22; updated with the decisions of Nov 23)

The owner moved the launch back to ship this with 1.0 (no hard date). This is the agreed design for Claude Code runs to build. Where a detail says "default", the run picks it and the owner tunes it later.

## Goals
- A fun, repeatable endgame activity, Hearthstone-style drafting.
- A main way to collect multi-Path cards, prismatic packs and powerful gear.
- **Small and light:** code and data, plus about 20-25 new pictures (about 10-20 MB). The fights use the existing battle engine, and the draft screens use the card art already in the game.

## A separate mode with its own rules
- **Player HP:** the base HP for the player's level, with no equipment bonuses or penalties.
- **Opening hand:** the player's normal hand size for their level.
- **Equipment and items:** only what is drafted in this run. The main game's loadout doesn't apply.
- **The deck (Nov 23):** at least 35 cards including Infrastructure. The player may play up to all 25 drafted cards and sets the number of each kind of basic Infrastructure (one kind per drafted Path). The default is 20 of the 25 with 15 basics split by the deck's Paths. Non-basic Infrastructure can be offered as a pick and counts among the drafted cards. The deck builder looks and works like the main one (the full deck and its stats on the right).
- **No copy limits:** no rarity or level caps, and more than 3 copies is fine. A deck with 5 or 6 copies of a common is allowed; crazy decks are part of the fun.
- The main game's 45-card minimum and its copy caps don't apply here.
- **When multi-Path drafting opens (Nov 23; it replaces "after all four zones" everywhere):**
  - if the Shuffle House opens before any zone is freed: single-Path drafts only;
  - **two-Path drafts and two-Path cards after the first zone is freed** (the same moment Auntie Alembic opens and essence brews two-Path cards);
  - three- and four-Path drafts and cards after Primm is defeated.
  - **Prismatic packs are draft rewards only after Primm;** before that, drafts pay Gilded and Path packs.

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
6. **Equipment and items in the pool (Nov 23):** every item, and every piece of equipment that does something in battle, **except** (the owner's removals, `data/draft/draft_rules.json`):
   - Gotta-Go Galoshes;
   - every piece that damages enemy units or gives them minus toughness (the Flamethrower and the like);
   - every piece whose effects are only outside battle (Hall Pass Slippers and the like).

   **Variety:** weak pieces are common and strong ones rare; a piece is not offered twice in one draft unless its slot runs out; every slot is well stocked (the 8 pieces of Phase 1 and the 12 modest pieces of Nov 23 are in the pool).
   **Rivals:** in a zone draft the AI never gets the most powerful pieces (Epic and Legendary; the player may). In the arena's harder "win three" drafts the AI drafts from the same pool as the player.
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
- **Entry (Nov 23): every draft is free.** (The 100 gold fee of Nov 22 is gone.)
- **Draft of the Day:** the same offers for every player on a given date (worked out from the date, no internet needed).
- **Feats:** go 3-0, finish every combination, win a dungeon draft without a loss, and more.

## Where it happens
1. **The travelling draft host, Trey Pickett** (a card shark in a striped suit and a straw boater, a carnival auctioneer: "Pick it, pick it, PICK IT!"): appears in every zone, near its starting area.
   - In each zone: **only that zone's draft** (that zone's Path, all its cards, plus Pathless). There is no Open Draft at his cart: choosing your own Paths happens only at the Shuffle House (Nov 23).
   - Three fairly even fights against rivals who drafted the same way, on random Paths (in a single-Path draft: one Path each, any Path, the player's included).
   - A **draft quest line** rewards fun, powerful equipment, plus cards, gold and experience.
   - **Rewards:** solid the first time, fair on replays.
2. **The Shuffle House** (the Crosspath draft arena, Nov 23): a carnival-casino building on the town square, run by **Octavia Eightfold** (a flamboyant octopus showwoman, Trey's aunt and mentor).
   - **It opens when all four zone drafts are won, or when three zones are freed.** Until then a pop-up says it isn't open yet and shows where it is.
   - Its menu holds: the **Open Draft** (1 to 4 Paths, within the unlock rules above), the **six two-Path challenges**, the **three- and four-Path challenges** (after Primm), the harder **"win three" drafts**, **the Shuffled Halls** and **Mystery Mini** (draft, then a random mini dungeon).
   - A quest line through every arena encounter is added automatically when it opens.
   - **The main quest:** after three zones are freed a main quest sends the player there (opening it if the zone drafts haven't); Octavia introduces it, and the player must **play (not beat)** the Shuffled Halls once.
   - A main source of **multi-Path cards**, and after Primm of prismatic packs.
3. **Dungeon drafts (Nov 23):** **the Shuffled Halls** (the Shuffle House's own dungeon: 18 rooms on its own map, Trey is a fight inside and Octavia is the final boss), every freed zone's main dungeon on its own map, every mini dungeon, the postgame dungeons and the vault. One HP pool, like any dungeon: the run ends at the first loss.
   - **Rewards are higher than a normal clear:** the player keeps one card of the draft deck, gets all the normal clear rewards, plus an extra pack. The Shuffled Halls' first clear also gives a guaranteed piece of draft equipment.
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
