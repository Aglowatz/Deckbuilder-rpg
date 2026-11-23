# Owner backlog: agreed future work (not yet scheduled)

Kept by the owner's assistant. Claude Code: read this, but don't start these items unless a brief asks for them. Add new owner-requested "later" items here.

## Next scheduled
- **The two weeks to 1.0:** `docs/release/two_week_plan.md` (written by the Nov 21 review) orders everything below by what a player would feel, with who does it and a day. Start there.

## Art (the next ChatGPT batch, run from a sheet tab)
- **Batch 19** (`docs/art/batch19.csv`): a redo of the Endless Buffet's world map from a fresh plan (the painted sushi shop stands in the Raw Deal's old place), and the other rows listed there.
- Rip: walking art, if he should ever follow the player (he turns through eight directions on the spot since Nov 20).
- (Elowen's walk is not missing: she and her disguise both have full walk sets in the game. Closed by the Nov 21 review.)

## Design and balance passes
- **Camera per zone:** since Nov 21: +6 degrees everywhere (`data/camera/zone_camera.json`) and five presets on V (+6 to +14); "Camera angle" and "Camera distance" stay in Settings. Decided Nov 22: a new game (and a player who never changed it) starts on +6, preset 1 of 5; V cycles the five and the choice is saved.
- **The Arena's balance and difficulty:** several encounters are far too easy and the puzzles were rebuilt Nov 20 (four, each with one solver-proven solution; the owner play-checks them). The battles: the owner checks each by hand, then a Fable pass. It's fine for the Arena AI to have set hands and opening-hand rules (e.g. a guaranteed mix of infrastructure and cards) so it never stalls on too little or only infrastructure.
- **Combat pacing:** the owner tests manually; no automatic changes. The 45-card minimum stays.
- **The heal rooms and the six drawbacks of Nov 21** stay as they are until the owner has playtested them (decided Nov 20). The cheapest dial if the last stretch of a dungeon is too hard: the heal (5 to 7) before the prices.

## Added by Overnight Nov 19 (deferred, for the owner to schedule)
- **The Arena's tier prizes and pack rewards**: first numbers only; the owner's planned by-hand Arena balance pass should look at them with the encounters.

## Added by Fable Nov 19 (deferred, for the owner to schedule)
- **A Path-coloured ring instead of the footprint outline** for a building the lens is inside: only if the plain outline reads badly in play.
- **The Glossary has no card pictures:** if example cards are wanted there (one per keyword), it is new content, not a hover fix.

## Added by Fable Nov 20 (deferred, for the owner to schedule)
- **More Arena puzzles:** the solver and the lab tool (`bash tools/arena_puzzle_lab.sh --file=<draft>`) make a new puzzle cheap to prove. One per Path pair would be six; there are four.
- **The Diamond puzzle's wall:** it has one blocker because the search could not finish with three. A faster search (pruning by the damage still possible) would allow a fuller board.
- **The Heart Roots' old option** (sever the roots: the Rotheart starts with 6 less HP) is out of the node; its code and cutscene are still there if it should return.

## Added by Fable Nov 21 (deferred, for the owner to schedule)
- **Primm's Castle keeps one full heal** (the Resistance Safe Room), now on some routes only (Fable Nov 21 castle). The Path-ology Lab's became a "heal 5 for a cost" room on Nov 20.
- **Balance after Nov 21:** simulated by the Nov 21 review (`docs/balance_report_nov21.md`): the changes moved little; the heal rooms cost HP, not clears. Open decisions from it: the Arena table, the House of Gains (Vivienne Quota), Mortimer for Beefcake, the economy.
- **The Deck Station's search and controllers** (decided Nov 20: later): the controller's cursor skips the search box because there is no on-screen keyboard; the Path toggles and the other filters work with a controller.

## Added by Fable Nov 20 day (deferred, for the owner to schedule)
- **The gold-framed screens beside the glass ones:** the shops, the Deck Station, the Character screen and the dialogue box keep their walnut-and-gold look (the brief); the glass pop-ups open over them. If the two looks should meet, it is its own pass (inbox, "Fable Nov 20 day").
- **The title screen's own menu** (Continue, New Game ...) keeps its gold buttons; the pages it opens are glass. (The rose window tops it since the Nov 21 review.)
- **Glossary keywords in their Path's colour:** the data gives a keyword no Path; it would need one column in the keyword table.
- **The D.N.A.'s painted map shows a sunny village** (red and blue roofs, green lawns) where the zone is a haunted office at dusk; it fits the walk grid, the mood is the painter's. A repaint in the zone's palette would be a Batch 19 row if wanted (Nov 21: optional, not wanted for now; the row is marked so in `docs/art/batch19.csv`).

## Added by the Nov 21 review (deferred, for the owner to schedule)
- ~~The Arena's proposed rows~~ applied by Fable Nov 21 castle (the bold rows); re-simulated in the balance report's section 6. Diamond Sand has no player level in `ProgressionModel.LEVELS` (the sim assumes 25; the prize multiplier reads the same table).
- ~~Two "freed" lines for the Gainlands~~ written by Fable Nov 21 castle (Gary, Chet Thunderabs; revertible).
- **Batch 19 has a second row:** the locked Necrocrat pack as a sealed parcel like the other three.
- **Card sheet wording** (names and flavour the importer owns): "Stock The Pantry", "The Recycling Center", "honor" / "favor" in three flavour lines, "Draw 2 cards" on N-18 and N-20.
- **The player read-me in the zip** (`docs/release/player_readme.txt`): the export still writes the playtest read-me; switch it for the public build.
- **The memory smoke's object count** grows by about 15 objects a zone round trip (static and video memory are flat); chase it only if a long session ever shows it.
- **A real-fight bot run per Path** (`bash tools/run_full_real.sh <path>`): the fight pilots can finish scripted-event fights again since the Nov 21 review; none has been run since Nov 17.

## Added by Fable Nov 21 castle (deferred, for the owner to schedule)
- **Batch 19 grew by six rows** (`docs/art/batch19.csv`): the castle map repainted for the new routes (refs `plan-primm-castle.jpg`, `now_MAP-PC.jpg`), the Pantry Mimic's portrait, Auntie Alembic's brewing scene, an empty glass jar, and two optional token pictures (the Captured Trainee, the Spotless Statue). Stand-ins work until then.
- **The owner's card sheet** must get this pass's changes or the next import reverts them: Wobble Weights' text (NB-13), "Pathwork" in two NPC rows, and the D-PC cell of the dungeon list (written by `tools/castle_nov21.py`).
- **The item and equipment strength table** (`docs/balance_report_nov21.md`, section 5): proposals to tick line by line; nothing beyond Part 1's four was changed.
- **The Extra Pocket** (the equipment that lets each equipped item be used twice per battle) stays as it is for now (the owner, Nov 21): revisit with testing. The item strength table in `docs/balance_report_nov21.md` (section 5) has its number.

## Added by Fable Nov 22 night (deferred, for the owner to schedule)
Written down, not built (the brief's Part 4). Each is placed in `docs/release/two_week_plan.md`.
- **The Extra Pocket** (each equipped item can be used twice per battle): revisit with testing. One charge of an item is worth +0 to +13 points of win rate (`docs/balance_report_nov21.md`, section 5); the Pocket roughly doubles it. Plan: item 22, after 1.0.
- **Beefcake against Mortimer and against Primm:** no change now (the owner, Nov 22); watch both in the playtests. The numbers: Mortimer 0 wins in 18 for an on-level Beefcake deck; Primm for Beefcake in the table of the Nov 22 report. The lever, if a playtester hits the wall: a Beefcake-only answer, not the bosses' numbers. Plan: item 4 (Mortimer) and item 23.
- **More Arena puzzles:** four today, six would be one per pair of Paths (`bash tools/arena_puzzle_lab.sh --file=<draft>` proves a draft). Plan: item 15.
- **The collection grind:** everything costs about 13 hours of repeat clears after the story (about 75,800 gold; a brew is 6 essence of each of two Paths). The dial is the essence: how much a spare copy gives, or what a brew costs. Plan: item 13 (decide), item 24 (apply).
- **The Deck Station's search for controllers** (an on-screen keyboard; the other filters already work with a controller). Plan: item 19.
- **The D.N.A.'s map repainted at dusk** (optional; the row in `docs/art/batch19.csv` is marked "do not make" until wanted). Plan: item 21.
- **Batch 20** (`docs/art/batch20.csv`): one redo row so far, the castle map's eleven missing walkways (the game draws a line for those until then).
