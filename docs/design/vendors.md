# Card vendors (UI + economy fixes, Oct 22 2026)

Who sells which cards, and when. Code: `core/data/vendor_stocks.gd` (`VendorStocks.sable_sample`, `VendorStocks.zone_shelf`); the shelves
are ordinary `VendorData` (locked entries show as "???" teasers with their unlock hint). Prices (Overnight Oct 29, `Economy.CARD_PRICE` through `CardPricing`): Common 30,
Uncommon 60, Epic 150, Legendary 300, no energy term any more (docs/design/economy.md); the level track's vendor discounts apply. Cards and decks a player already owns are
never touched - only what is for sale changed.

## The principle

- **Sable** (Crosspath) is a sampler, not the place to buy a Path. A small shelf (10 at first, 12 later), mostly Colorless Commons, a
  Colorless Uncommon, and one Common of each Path as a taste. It grows a little and rotates; it never sells a Path Epic or any Legendary.
- **Each Path zone's vendor** sells that Path: all its Commons and two Uncommons from the first visit; the rest of the Uncommons and the
  Epics once the zone's boss is beaten; a Legendary only in the postgame. Unique prizes are never on a shelf.
- **Packs and the Black Market** were already gated by progress and are left as they were (see the last section).

## Sable's Card Stall (`VendorStocks.sable_sample`)

Opens after the Forgotten Cave (as before).

| Step | When | Shelf |
|---|---|---|
| Sample | from the start | 5 Colorless Commons, 1 Colorless Uncommon, 1 Common of each of the four Paths (10 cards) |
| Grown | level 5 or one zone freed | + a second Colorless Uncommon, + one Uncommon of one Path (12 cards) |
| Rarer cards | level 17, level 27 (the level track's "rarer cards at Sable's stall") | + 2 Colorless Epics each (a fixed pair; they do not rotate) |

- **Rotation**: which Commons, Uncommons and which Path's Uncommon are picked is seeded by the player's level and the number of zones
  freed, so the shelf changes on a level-up or a freed zone and stays the same between visits otherwise.
- The next step's cards show as "???" teasers ("Reach level 5" ...), so the stall visibly has more to come.
- Before: Sable sold every card in the game - the player's own Paths and Colorless right away, other Paths by rarity behind lifetime
  gold spent (80 / 180 / 320 / 500) or level (3 / 9 / 15 / 21) or the General Pack tier 2 unlock. Every Path's best cards were one shop
  away by level 9-15. (`VendorData.graduated` is kept for old tests and tools; nothing sells from it now.)

## Path zone vendors (`VendorStocks.zone_shelf`)

| Zone | Vendor | Path |
|---|---|---|
| The Gainlands | Coach Brutus Benchley, Swole Station | Beefcake |
| D.N.A. | the D.N.A. shop | Necrocrat |
| The Endless Buffet | Madame Mirepoix, the Grand Pantry | Gourmand |
| The Verdant Dump | Granny Gristle, the Compost Grange | Refusemancer |

| Tier | When | What |
|---|---|---|
| Opening | first visit | every Common of the Path; the two Uncommons from the zone's curated list (`ZoneCards.*_VENDOR_IDS`) |
| Boss beaten | the zone is freed (`zone_<id>_completed`) | every other Uncommon of the Path; every Epic of the Path |
| Late | the postgame (Primm defeated) | the Path's Legendary |

Never on a zone shelf (`VendorStocks.sellable`): tokens, Infrastructure, `not_in_packs` cards, signature cards, the main-dungeon and
side-dungeon prizes (`ZoneCards.MAIN_DUNGEON_REWARD_IDS`, the four `*_MINI_REWARD_ID`s) and the Black Market's own cards
(`CapitalContent.BLACK_MARKET_CARD_IDS`).

Before: each zone vendor sold a fixed list of 10 cards (mostly Commons, two or three Uncommons), all from the first visit, never more.

### Sable's shelf at points of a run (one rotation each; Path in brackets, rarity C/U/E)

| Point | Cards | Shelf |
|---|---:|---|
| Level 1 (after the cave) | 10 | Training Grounds C, Desperate Measures C, Wandering Medic C, Courier Pigeon C, Healing Potion C, Underdog's Gambit U, Hamster Wheel Runner [Beefcake] C, Meatloaf Mold [Gourmand] C, Turf War [Refusemancer] C, I've Made a Huge Mistake [Necrocrat] C |
| Level 3 | 10 | Village Militia C, Training Grounds C, Traveler's Sword C, Rally the Village C, Wandering Medic C, Resistance Scout U, Sledgehammer [Beefcake] C, Conveyor Belt Chef [Gourmand] C, Raised Bed [Refusemancer] C, Pink Slip [Necrocrat] C |
| Level 5 | 12 | Watchtower Archer C, Village Well C, Tripwire C, Stapler C, Cannon Fodder C, Mercenary Captain U, Adventurer's Pack U, Pre-Workout Canister [Beefcake] C, Food Critic [Gourmand] C, Garbage Pit [Refusemancer] C, Red Tape Dispenser [Necrocrat] C, Overclocked Mill Worker [Beefcake] U |
| Level 9, one zone freed | 12 | Wandering Medic C, Old Kingdom Automaton C, Village Militia C, Second Wind C, Watchtower Archer C, Resistance Scout U, Mercenary Captain U, Weight Belt [Beefcake] C, Rolling Pin [Gourmand] C, Hayfork Harpoon [Refusemancer] C, Late Fee [Necrocrat] C, Banquet Hall [Gourmand] U |
| Level 17, three zones | 14 | Old Kingdom Automaton C, Tavern Regular C, Rally the Village C, Village Militia C, Tripwire C, Adventurer's Pack U, Underdog's Gambit U, Bronzer [Beefcake] C, Seasoning Station [Gourmand] C, Alley Scrap [Refusemancer] C, Waiting Room [Necrocrat] C, Acid Vomitor [Refusemancer] U, Four-Path Compass E, Mirrored Hall E |
| Level 27, postgame | 15 | Tripwire C, Courier Pigeon C, Training Grounds C, Traveler's Sword C, Cannon Fodder C, Resistance Scout U, Underdog's Gambit U, Spotter [Beefcake] C, Sent Back to the Kitchen [Gourmand] C, Junkyard Giraffe [Refusemancer] C, Grave Shift Worker [Necrocrat] C, Audit Wraith [Necrocrat] U, Four-Path Compass E, Mirrored Hall E, Unstable Rift E |

### Path zone shelves

| Zone | Opening (first visit) | + after the boss | + postgame |
|---|---|---|---|
| Beefcake (23 / 27 / 28) | Gym Bro [Beefcake] C, Bronzer [Beefcake] C, Dropped Weights [Beefcake] C, Millstone Pusher [Beefcake] C, Hamster Wheel Runner [Beefcake] C, Portal Ripper [Beefcake] C, Late-ish Courier [Beefcake] C, Spotter [Beefcake] C, Personal Trainer [Beefcake] C, Shot Putter [Beefcake] C, Beefy Bouncer [Beefcake] C, Leg Day Survivor [Beefcake] C, Hulking Hauler [Beefcake] C, Weight Belt [Beefcake] C, Kettlebell [Beefcake] C, Lifting Gloves [Beefcake] C, Pre-Workout Canister [Beefcake] C, Sledgehammer [Beefcake] C, Counterweight [Beefcake] C, Dry Scoop [Beefcake] C, Flex on 'Em [Beefcake] C, Alarm-ish Clock [Beefcake] U, Yeet [Beefcake] U | Snack Bar [Beefcake] U, Overclocked Mill Worker [Beefcake] U, The Carpool [Beefcake] U, Swole Patrol Sergeant [Beefcake] E | Global Gains Platinum Membership [Beefcake] L |
| Necrocrat (23 / 27 / 28) | Skeleton Clerk [Necrocrat] C, Infernal Intern [Necrocrat] C, Post-Human Resources Ghoul [Necrocrat] C, Body-builder [Necrocrat] C, Corpseified Public Accountant [Necrocrat] C, Notary Wraith [Necrocrat] C, Grave Shift Worker [Necrocrat] C, Corporate-Approved Pen [Necrocrat] C, Red Tape Dispenser [Necrocrat] C, Push Broom of Undeath [Necrocrat] C, Late Fee [Necrocrat] C, Invisible Ink [Necrocrat] C, Waiting Room [Necrocrat] C, The Breakroom [Necrocrat] C, Pink Slip [Necrocrat] C, Processing Delay [Necrocrat] C, Buried in Paperwork [Necrocrat] C, Requisition Form [Necrocrat] C, Resting In Peace Clause [Necrocrat] C, I've Made a Huge Mistake [Necrocrat] C, Become Useful at Work [Necrocrat] C, Middle Management Zombie [Necrocrat] U, Audit Wraith [Necrocrat] U | Working in Your Own Casket [Necrocrat] U, Endless Filing [Necrocrat] U, Permission to Die - Denied [Necrocrat] U, Department of Final Approvals [Necrocrat] E | Unconscionable Contract [Necrocrat] L |
| Gourmand (23 / 28 / 29) | Line Cook [Gourmand] C, Sushi Apprentice [Gourmand] C, Conveyor Belt Chef [Gourmand] C, Sourdough Sentry [Gourmand] C, Food Critic [Gourmand] C, Soup Kitchen Volunteer [Gourmand] C, Sous Chef [Gourmand] C, Pastry Artificer [Gourmand] C, Kitchen Porter [Gourmand] C, The Recipe Engine [Gourmand] C, Gourmand Cooking Academy [Gourmand] C, Meatloaf Mold [Gourmand] C, Hearth Kitchen [Gourmand] C, Seasoning Station [Gourmand] C, Windowsill Herb Garden [Gourmand] C, Dinner Is Served [Gourmand] C, Sent Back to the Kitchen [Gourmand] C, Rolling Pin [Gourmand] C, Lunchbox [Gourmand] C, Plate It [Gourmand] C, Consult the Cookbook [Gourmand] C, The Cullinator [Gourmand] U, En Garde-Manger [Gourmand] U | Health Code Violation [Gourmand] U, Stock The Pantry [Gourmand] U, Banquet Hall [Gourmand] U, Chef de Golem [Gourmand] E, The Infinite Pantry [Gourmand] E | The Eternal Banquet [Gourmand] L |
| Refusemancer (23 / 27 / 28) | Mulch Mole [Refusemancer] C, Dumpster Diver [Refusemancer] C, Landfill Ox [Refusemancer] C, Rubbish Goat [Refusemancer] C, Kidding Around [Refusemancer] C, Curbside Rat [Refusemancer] C, Junkyard Giraffe [Refusemancer] C, Possum Prowler [Refusemancer] C, Heap Tortoise [Refusemancer] C, Community Compost Bin [Refusemancer] C, Raised Bed [Refusemancer] C, Garbage Pit [Refusemancer] C, Reclaimed Land [Refusemancer] C, Rusty Spring Trap [Refusemancer] C, Turf War [Refusemancer] C, Recycling Day [Refusemancer] C, Hayfork Harpoon [Refusemancer] C, Rusty Can Opener [Refusemancer] C, Alley Scrap [Refusemancer] C, Landfill Grab [Refusemancer] C, Let them eat cake [Refusemancer] C, Acid Vomitor [Refusemancer] U, Manure Miracle [Refusemancer] U | Bird of Paradump [Refusemancer] U, Second-Hand Life [Refusemancer] U, The Recycling Center [Refusemancer] U, Poo-uid [Refusemancer] E | Back From the Heap [Refusemancer] L |

## Packs and the Black Market (checked, not changed)

- **Path Packs** (`data/packs/path_*.tres`) only go on sale once that Path's zone is freed (`zone_<id>_completed`); the level track hands
  out one earlier as a reward. **General Packs**: tier 1 from the start (Colorless and every Path, rarity-weighted), tier 2 at level 10
  or two zones freed (`PackConfig.tier2_level` / `tier2_zones`). **Gilded Packs**: first clears of the main dungeons. Nothing floods
  the early game; left as is.
- **The Black Market** (the Capital, the last zone): its eight cards (`CapitalContent.BLACK_MARKET_CARD_IDS`, Epics) and its pack
  stall are reached around level 18; unchanged (character and place as they were).
- **The Secret Dealer** (Crosspath, hidden): sells every Epic and Legendary, but only appears once the Ninja's original chest has been
  opened or the hidden secret found (`town_scene._secret_dealer_open`), around level 12 in the progression model - a late, earned
  shop. Left as it was (its character and place are part of the secret); noted here in case its stock should be thinned later.

## Checks

- Tests: `tests/core/data/test_vendor_stocks.gd`.
- Economy audit and early-game sim: see `docs/design/balance_log.md` ("UI + economy fixes Oct 22").

## Cards Oct 27 (Part 1)

- Sable's sample sells **two Commons of the player's own Path** (`VendorStocks.OWN_PATH_COMMONS`, passed from `Session.profile.primary_affinity`
  by the vendor screen) and one of each other Path; the shelf is still 11 cards at first.
- The 14 new cards (`docs/cards_oct27.md`) reach the shelves by rarity and Path like any other card: the new Commons are on their zone's shelf
  from the first visit, the new Uncommons (Final Notice, Landfill Leviathan) after the zone's boss, Iron Filing Clerk at the Alchemist.
- Availability (Part 2): a card's `availability` (GENERAL / REWARD-LOCKED / ENEMY-ONLY, `data/source/card_overrides.csv`) is checked by every
  shelf through `CardAvailability` - see `docs/design/card_availability.md`.
