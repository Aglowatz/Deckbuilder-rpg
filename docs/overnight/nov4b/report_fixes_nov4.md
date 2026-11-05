# Fix pass Nov 4 - report

Brief: `docs/prompts/fixes_nov4.md` (playtest feedback round 1). Tag `pre-fixes-nov4`; commits `1b59529a..HEAD` on main.
Decisions you may want to change: `docs/overnight_inbox.md`, section "Fix pass Nov 4". Shots: `docs/overnight_shots/nov4/`.
Previous report: `docs/overnight/nov4/overnight_report_overnight_nov3.md`.

**Tests:** full GUT suite green, run in foreground chunks (core 1,630, ui 221, world 465 + 1 old "did not assert", audio 92, root 299).
**Export 0.5.4: not done** - the Godot editor (`title.tscn`) is open and C: has 1.4 GB free; `tools/export_windows.sh` stops on both
(it needs Godot closed and ~2.5 GB). The version is bumped to 0.5.4 everywhere (project, export presets); see "To finish" below.

## Part 1 - Battle rules

| # | What | Done |
|---|---|---|
| 1.1 | **Peek is broken** | Peek was resolved by the engine on its own (it sorted the cards silently), so the player never chose. Now a Peek on your own turn **waits for you**: `GameState.peek_requests`, `peek_cards()`, `resolve_peek()`, `GameAction.PEEK`; the ability pauses and the rest of it ("then draw a card") runs after your choice (`AbilityRunner.PEEK_WAIT`). New `PeekPanel`: all N cards together (top card first), **Top / Bottom** per card, the first card sent Top is drawn next ("Top #1", "Top #2"), Reset, Done. Covers every Peek card: Amuse-Bouche, Consult the Cookbook, Sous Chef, Courier Pigeon, Cartographer's Table, Banquet Hall, Spice Bazaar. The AI and the look-ahead copies keep the automatic choice. Verified in a live duel (critic run: the card picked Top #1 was the one drawn). Tests `tests/core/game/test_peek_choice.gd` (6). |
| 1.2 | **"Fresh Stitches"** | Renamed everywhere: the card field (`CardInstance.fresh_stitches`), glossary, keyword tooltip, the battle tooltip entry, design docs, tests and tools. Reminder `KeywordInfo.FRESH_STITCHES_REMINDER` = "Fresh Stitches: can't attack the turn it enters play." (shown when you click a unit that can't attack yet). Hustle units ignore it as before. The dialogue CSVs held the old phrase only in archived passes (`docs/dialogue/chatgpt_pass_oct21/`), not in game text. |
| 1.3 | **Pre-placed enemy units** | A unit on the table before the duel keeps Fresh Stitches through its side's first turn (`CardInstance.placed_before_duel`, set by `GameState.mark_placed_before_duel` after the start-of-duel effects). Encounters: **Trophy Hall Honor Guard** (1 Militia), **The Doppelganger** (Sashimi Weenie, both rule sets), **Royal Staircase Guard** (3 Militia), **Colonel Casserole** (Sashimi Weenie), **Primm - Standardization** (4 Militia), and the **Arena presets** with enemy units (3 challenges). Units a setup makes ready on purpose (Flex, Elowen, the sim's allies) stay ready. |
| 1.4 | **Endless Buffet buff** | **Cause:** the Colonel's fight had two rules both named "Field Rations" - the starting Weenie and a hidden "+1 attack" - and the badge row merges same-named rules into one badge, so only the Weenie showed while his units got zone +1/+1 plus +1/+0 = **+2/+1**. Not a double application (checked: Well Fed is on each seat exactly once). The hidden +1 attack is removed. **Well Fed is now +0/+1** (`ZoneEffects`), zone-wide as designed: both seats' Gourmand units, in every Buffet fight. The chip, tooltips and pre-fight text are generated from the modifier ("Gourmand units get +1 defense."); the flavour line now reads "A full belly is hard to knock over." Tests run every Buffet encounter of the catalogue plus the real gate battle. |
| 1.5 | **Casserole didn't attack** | **Cause:** in the live game the attack search has a wall-clock budget (half of 500 ms). It scored "no attack" first, and on a slower machine the clock ran out after that one candidate, so a clearly winning swing was never weighed (the sims, which have no clock, always attacked - a probe over 24 Casserole games found no missed lethal there). Fix in `AICombat`: the attacking sets come first, "no attack" fifth, and at least 5 candidates are always scored (`MIN_LIVE_CANDIDATES`); the opponent's block model is node-limited only (a starved model predicted no blocks). Same floor for the AI's blocks. All bosses use this code. Fresh Stitches flags and the buff were checked as causes and ruled out. Regression tests `tests/core/ai/test_ai_attacks_when_ahead.gd` (6 boards x 6 boss signatures, plus a clock-starved search that fails on the old code). Tool `tools/attack_when_ahead_probe.gd`. |
| 1.6 | **Boss blockers** | **Cause:** the Colonel's gate flag was only set when the Buffet scene was built; a roamer/gate duel returns to the **parked** scene (no rebuild), so after any win - dev or normal - he stood in the way until the next visit. Now the win sets the blocker flag at once (`BossBlockers`, `GameSession.resolve_zone_battle`), `EventBus.flag_set` announces it, and `ZoneScene.sync_world_flags()` runs on the return to a parked scene and on every flag change. Every blocker checked: the **Colonel** (now moves), **Captain Spotless's gate** (had the same bug: the barrier was only lifted on a rebuild - fixed the same way), the four **hub gatekeepers** (town is rebuilt after those duels; flag-driven already). Verified in play with the dev win. |

## Part 2 - Economy

Cards: **Common 100** (a General Pack's price), Uncommon 200, Epic 500, Legendary 1000 (ratio 1 : 2 : 5 : 10 kept; was 300 / 600 / 1500 / 3000).
Equipment is now the saving goal: Common 1200-1800, Uncommon 2000-3200, Epic 3500-5500 by tier (was 60-600).

| Shop piece | Before | After |
|---|---:|---:|
| Cardboard Cuirass, Saucepan Helmet, Extra Pocket, Traveler's Boots (Common t1) | 60 | 1200 |
| Flip-Flops of Fortitude (Common t2) | 90 | 1400 |
| Wicked Dagger, Solid Plate, X-Ray Goggles (Uncommon t1) | 120 | 2000 |
| Protein Shaker Bandolier, Notarized Seal, Dog-Eared Bookmark (Uncommon t2) | 180 | 2400 |
| Cheater's Dice, Hover Boots, Thorned Loincloth, Sucker Punch Mitts (Uncommon t3) | 240 | 2800 |
| Flamethrower, Blade of Earned Reputation, Big Brain Beret, Grandma's Rolling Pin (Epic t3) | 450 | 4500 |

The gold study (re-run, new section in `docs/balance/gold_economy_nov3.md`): a no-grind player earns **16,029** gold; after 7 item charges,
3 hats and the hub fees **14,704** is left for cards and gear. The 20-card mix costs 4,700, leaving 10,004: the **4 essential pieces**
(8,900) or **6 cheaper ones** (8,200) - inside the 4-6 target. Buying only the essentials leaves room for ~25 cards; no gear at all, ~63.
Grinding (12 repeat fights an hour): **8-17 Commons or 3.6-7 average cards per hour** in the Path zones and the Capital (3 Commons an hour
in Crosspath's outskirts); a tier-1 Common piece of gear is about an hour of grinding.

## Part 3 - UI and shops

- **Level-up popup:** no level-up mentions equipment any more - the rarity-cap lines ("Wear up to 1 Epic piece of equipment", the "1
  equipment slot" the Level 5 popup showed) are gone from the popup and the reward docs, and five headlines that talked about gear are new
  (L5 "Getting the hang of this", L19 "Seasoned traveler", L22 "Epics up to 3 copies, and a Gilded Pack", L25 "A cape worth swishing", L28
  "Room for one more card"). The item slots at 6 and 12 still show. Every level 2-30 checked by a test. (The rarity caps still apply; inbox 6.)
- **Character page:** each slot is placed from a point on the silhouette (`CharacterScreen.SILHOUETTE_POINTS`, read off the poster art)
  through the poster rect, so it stays on the figure at any size: helm over the head, armor mid-chest, weapon and relic on the hands, boots
  between the feet; slots 124 -> 110 px so the Helm caption clears the Armor slot. Before/after at 1280x720 and 1920x1080:
  `part3_character_before_*.png`, `part3_character_after_*.png`.
- **Pip's shop:** "Plain Cloak" everywhere (the shop tile, the Wardrobe). **Hats** and **Cloaks** tabs. The **12 cloak dyes are back** in
  the Cloaks tab, each sold like a piece (Preview on the hero in the Plain Cloak, Buy 60 gold, Equip); owned dyes are saved, an old save keeps
  the dye it wears, the Wardrobe picks among owned dyes. The preview never opens empty. **Dye in battle:** the hero was never drawn in battle
  (a pointy-hat glyph); your plate now shows the dressed hero (`HeroBust`: hat, cloak set, dye). Checked in the world (crimson cloak), in
  Pip's preview and on the battle plate.
- **White arches:** they were **Mirepoix's cloches** (`VendorFx.Cloche`, a translucent silver dome drawn over every card, lifting on hover).
  Removed, with the two other overlays on card faces: Gristle's tin-can front (covered the rules text) and Fig Sly's compartment doors on
  cards. Benchley's tubs and Gristle's cans now sit under the cards. Checked every card shop (Sable, Benchley, Ledgerbone, Mirepoix,
  Gristle, Fig Sly) and the Collection Book, Deck Station and card pick; no arches anywhere (`part3_shop_*.png`, `part3_grid_*.png`).
  Mirepoix's two lines about lids were rewritten.

## Part 4 - World

- **Crosspath townsfolk:** the "Townsfolk" by the trainer's lamp post (and the one in the market) was the Gainlands gym attendant in gym kit;
  both are mole farm hands now (the Dump's extra set, own tints), the only non-story standing set left (every other painted set is a named
  character). No idle wander: only the badger and the Capital citizen have walk cycles (inbox 7). `part4_townsfolk_lamp_post.png`.
- **Chests x1.25** in every zone, the town and the starting forest (`ChestKit.SCALE` 0.28125), with the footprint (0.18 -> 0.225 m) and the
  reach to open (1.5 -> 1.6 m); the Capital's chests are solid now like everyone else's. Every chest checked for open ground beside it; the
  walkability floods to every chest still pass. The ninja's giant chest keeps its size.
- **Buffet footsteps:** the paved cracker roads squelched because the Buffet's footsteps never looked at the roads; they now step as
  **cobble** (the same `path_weight` that paints them), the Grand Pantry's checkered plaza as **tile** (it knocked like wood, from the old
  lazy-susan hub), the meadow still squelches. Other zones checked: the **Dump's paths** squelched like mud through the wetlands - now dirt;
  Gainlands, D.N.A., Capital, town and forest map their paths correctly.
- **Buffet top-left "stairs":** three pie-crust slabs = one of the **Potato Peak's decorative "biscuit bridges"** over its gravy pool
  (`BuffetLandmarks._potato_peak`): no script, no collision, part of a backdrop landmark; the north one sat on the table by the Cheddar
  Cliffs and read as a stair to nowhere. All three removed; nothing referenced them. `part4_buffet_stairs_before.png` / `_after_*.png`.

## Critic play (from the main repo at HEAD)

No room for a worktree (1.4 GB free; a checkout is ~1.6 GB), so the runs used the main repo at the committed HEAD, untouched meanwhile.
Scripts `docs/review/play_scripts/critic_nov4_*.txt` (new driver commands `dev hand`, `dev energy`, `dev play`).

- **Peek** (a live duel, Consult the Cookbook): panel, picks, Done; the Top #1 card was drawn, the spell went to the Refuse Pile. OK.
- **Colonel Casserole, played out** (pilot, level 12 starter deck): his Weenie showed 1/2 with Fresh Stitches (Zz) on turn 1; he attacked
  every turn he could ("attacks with Sashimi Weenie and 5 more"); the pilot lost (it is a weak player). OK.
- **Colonel Casserole, dev win:** back in the zone the Colonel had stepped off the road, prompt "Chat with Colonel Casserole". OK.
- **Card shop** (Sable): Commons at 100, no overlays. **Pip:** tabs, Plain Cloak, dye tiles, dye preview on the hero; found the preview panel
  empty on opening - fixed (the tab's first piece shows). **Character page:** slots on the silhouette, pill centred. OK.

## To finish (needs you)

1. Close the Godot editor and free about 1 GB on C: (e.g. the v0.5.2 zip in `builds/`, 600 MB, or old play runs in `_screenshots/play/`, 377 MB -
   I deleted nothing).
2. `bash tools/export_windows.sh` (version 0.5.4 is already set), then the release smoke as in `docs/release/how_to_build.md`.
