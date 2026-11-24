# Draft mode: design (owner decisions, Nov 22; updated with the decisions of Nov 23 and the four modes of Nov 24)

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
   **Rivals:** in a zone draft the AI never gets the most powerful pieces (Epic and Legendary; the player may). In the High Rollers Draft (Nov 24; it replaced the "win three" drafts) the opponents can get every piece of equipment the player can.
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
- **Entry (Nov 23): every draft is free** (the 100 gold fee of Nov 22 is gone), **except the High Rollers Draft (Nov 24): 200 gold every time.**
- **Draft of the Day:** the same offers for every player on a given date (worked out from the date, no internet needed).
- **Feats:** go 3-0, finish every combination, win a dungeon draft without a loss, and more.

## Where it happens
1. **The travelling draft host, Trey Pickett** (a card shark in a striped suit and a straw boater, a carnival auctioneer: "Pick it, pick it, PICK IT!"): appears in every zone, near its starting area.
   - In each zone: **only that zone's draft** (that zone's Path, all its cards, plus Pathless). There is no Open Draft at his cart: choosing your own Paths happens only at the Shuffle House (Nov 23).
   - Three fairly even fights against rivals who drafted the same way, on random Paths (in a single-Path draft: one Path each, any Path, the player's included).
   - A **draft quest line** rewards fun, powerful equipment, plus cards, gold and experience.
   - **Rewards:** solid the first time, fair on replays.
2. **The Shuffle House** (the Crosspath draft arena, Nov 23; the four modes of Nov 24): a carnival-casino building in the open lawn north-east of Crosspath's square (a real 3D building since Nov 24: stone plinth, half-timbered drum, striped big top, at the end of its own cobbled path), run by **Octavia Eightfold** (a flamboyant octopus showwoman, Trey's aunt and mentor).
   - **It opens when all four zone drafts are won, or when three zones are freed.** Until then a pop-up says it isn't open yet and shows where it is.
   - **Its menu is four modes and one door (Nov 24).** The grid of seventeen tiles of Nov 23 is gone. Each mode is a big tile; Octavia presents; the chosen mode's choices, rewards and Start are below.

     | Mode | What it is | Entry | Opponents | Pays |
     |---|---|---|---|---|
     | **Classic Draft** | Choose your Paths (within the unlock rule), draft, play three opponents. Three wins or two losses. | free | Three random NPCs from a cast of 36 (shopkeepers, townsfolk, the friendly folk of the four zones). Their Paths and decks are random and change with every draft; they never follow the player's choice. Equipment up to Uncommon. | 20 / 45 / 80 / 140 gold and 10 / 25 / 45 / 80 XP by wins; three wins add a Path Pack and a kept card; the first Classic win adds 300 gold, 200 XP and a Gilded Pack. **Never a Prismatic Pack.** |
     | **Draft of the Day** (under Classic) | One Classic table a day, the same Paths, offers and opponents for everybody (from the date, no internet). | free | as Classic | as Classic |
     | **Dungeon Draft** | Draft, then play a large dungeon on one HP pool, with a pick of three after each fight. The list: every freed zone's main dungeon, Primm's Castle, the Path-ology Lab, Mount Swolympus, the Shattered Gallery, **each only after the player has cleared it once in the main game**; the Shuffled Halls after their first clear; and **Random** (one of the unlocked list). | free | the dungeon's own | The dungeon's own repeat-clear rewards, **a Prismatic Pack** on top, and a kept card. Gold and XP for every fight won, even when the run ends. |
     | **Mystery Mini** | Draft, then the wheel picks a mini dungeon (any dungeon with three encounters): the ones the player has cleared, and the ones of every freed zone. | free | the mini dungeon's own | The mini dungeon's gold and **a pack of that dungeon's Path** (a General Pack for a dungeon with no Path), and a kept card. |
     | **High Rollers Draft** | A Classic Draft for higher stakes. Three wins or two losses, like Classic. | **200 gold, every time** (in `data/draft/draft_rules.json`, `entry_fees.high`; an owner decision) | as Classic, but **they can get every piece of equipment the player can**, Epic and Legendary included | 60 / 140 / 260 / 480 gold and 20 / 45 / 80 / 140 XP by wins; three wins add **a Prismatic Pack** and a kept card; the first win adds 300 gold, 200 XP and a Gilded Pack. |

   - **The Shuffled Halls** have their own big door under the four modes (see 3).
   - **Prismatic Packs and the story lock.** A Prismatic Pack holds multi-Path cards, three- and four-Path ones included, and those stay locked until Primm is defeated. So before Primm a "Prismatic Pack" reward is paid as a Gilded Pack (the rule of Nov 23, kept; the menu says so). After Primm the Dungeon Draft, High Rollers and the Halls pay real Prismatic Packs; Classic and Mystery Mini never do.
   - **Your Paths** are four big rectangles you switch on and off (lit when on, with the Path's icon and name), in every mode. Switching on more than the story allows opens a pop-up that says why.
   - **Gone as separate tiles (Nov 24):** the six two-Path tables, Three Paths, Four Paths, the Double-Down Table, the Full House Table and "Maps". Their purpose is the Path choice in Classic and High Rollers. A win there with exactly two, three or four Paths still counts for that set of Paths (the quest goals below; a save that won the old tables keeps its progress).
   - **The arena quest line** (added by itself when the house opens) points at the four modes and the Halls: *Open Table* (finish a Classic Draft), *Two of a Kind* (win a Classic or High Rollers Draft with each of the six pairs of Paths), *Three's Company* and *Full House* (win one with three Paths, with all four; after Primm), *High Rollers* (win one; win three), *Dungeon Regular* (clear three Dungeon Drafts), *Spin the Wheel* (clear a Mystery Mini), and ***Lost in the Halls*: beating the Shuffled Halls is a side quest of its own.**
   - **The main quest:** after three zones are freed a main quest sends the player there (opening it if the zone drafts haven't); Octavia introduces it, and the player must **play (not beat)** the Shuffled Halls once. Cashing out counts as playing.
   - A main source of **multi-Path cards**, and after Primm of prismatic packs.
3. **Dungeon drafts (Nov 23; the Shuffled Halls made static on Nov 24).** One HP pool, like any dungeon: the run ends at the first loss. After each fight won, pick one of three cards: add it, replace a card with it, or take nothing.
   - **The Shuffled Halls** (the Shuffle House's own dungeon: 18 rooms on its own map, MAP-DRAFT). **Every fight is preset, like the other dungeons (Nov 24):** a fixed opponent deck in its own Paths, whatever the player drafted; fixed equipment; its own rules and scripted moments. (On Nov 23 its opponents were drafted, and copied the player's Paths.) A dealer's HP is the player's base HP plus a fixed number, because a draft is played at the base HP of the player's level.

     | Room | Dealer | Paths | The twist |
     |---|---|---|---|
     | 2 The Velvet Gate | Maurice, Head of Security | Beefcake | Starts behind a 0/4 Velvet Rope (Wallflower); calls two 2/2 House Security when three of his units have died. |
     | 3 The Tinsel Gate | Tilda Tinsel, Confetti Cannoneer | Refusemancer | The confetti cannon lands a 1/1 Confetti Critter every third turn; a Grand Finale (+1/+0) at half health. |
     | 5 The Tea Garden | Madame Darjeeling | Gourmand | Gains 1 HP a turn; pours YOU a cup on her turn 4 (you gain 3 HP); the Second Pot (4 HP and a 4/4 Cake Golem) at 40 %. |
     | 7 The Back-Room Table | "Honest" Hal Lowball | Necrocrat | The Ante: your first card each turn costs 1 more. At 30 % health he folds if you hold three or more units (you win). |
     | 8 The Auction Ring (champion) | Trey Pickett | Beefcake, Refusemancer and Pathless | Going once (turn 3), going twice (turn 5): your strongest ready units sit out. SOLD (turn 7): his units get +2/+0 for good. Beat the hammer. |
     | 10 The Carousel | Dizzy Lizzie, Carousel Queen | Gourmand and Beefcake | Her units have Hustle. On her turn 4 the music stops: her whole side stands down for a turn. |
     | 12 The Rules Library | Professor Fineprint | Necrocrat and Gourmand | Rule 1, both sides: units enter exhausted. On his turn 4 he amends it: Rule 1 goes, Rule 2 comes in (both players draw an extra card each turn). |
     | 14 The Roulette Pit (champion) | Dex Shufflewick | Necrocrat, Refusemancer and Pathless | Always goes first (his Cheater's Dice). The wheel spins on his turns 3, 5 and 7: red (you lose 2 HP, his side sits out), black (+1/+1), double zero (he heals and draws). |
     | 15 The Card Shop | Penny Sleeves | Beefcake and Necrocrat | Everything is sleeved (+0/+1). You break it, you bought it: 3 damage to you when three of her units have died. A Clearance Sale at 40 %. |
     | 19 The Big Wheel (boss) | Octavia Eightfold | all four Paths | The House Deals (an extra card each turn). The Big Wheel spins at 75 %, 50 % and 25 % health: Iron (+1/+0), the Kitchen (5 HP and a Cake Golem), Red Tape (your two strongest sit out; she draws two). |

     The other rooms: two Trade Counters (a multi-Path card for a card of your deck), two heal rooms, two buff rooms, the Chained Vault.
   - **The Counting Halls are an optional early exit (Nov 24).** From the last corridor's rooms the player can go there and **cash out**: the run ends with part of the prize (120 gold, 80 XP and a General Pack, on top of the gold for the fights won), and **it does not count as a win** (no clear, no kept card, no first-clear prize). Whoever does not cash out walks on to the Big Wheel. The room says all this.
   - **Unseen rooms show as question marks** the first time, like other dungeons; a room stays known for later runs once the player has stepped on it.
   - **Rewards are higher than a normal clear** (see the table under 2): the player keeps one card of the draft deck, gets the normal clear rewards, plus an extra pack. The Shuffled Halls' first clear also gives a guaranteed piece of draft equipment.
   - **The zone dungeons and the other large dungeons** are the Dungeon Draft's list; the mini dungeons are Mystery Mini's.
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
- **Phase 2:** the Crosspath draft arena (four modes since Nov 24: Classic, Dungeon, Mystery Mini, High Rollers), prismatic packs as rewards, Draft of the Day, feats.
- **Phase 3:**
  - dungeon drafts with a pick after each fight, and the draft dungeon map;
  - the Primm's Castle draft;
  - balance sims (opponent strength, equipment and item bans, rewards against the economy).
- **Between phases:** the owner playtests, and a ChatGPT art batch is made.
