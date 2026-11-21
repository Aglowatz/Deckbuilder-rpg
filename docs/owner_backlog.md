# Owner backlog: agreed future work (not yet scheduled)

Kept by the owner's assistant. Claude Code: read this, but don't start these items unless a brief asks for them. Add new owner-requested "later" items here.

## Next scheduled
- (nothing scheduled; Batch 18 and the stained-glass info screens were done Nov 20: `docs/overnight_report.md`, "Fable Nov 20 day")

## Art (the next ChatGPT batch, run from a sheet tab)
- **Batch 19** (`docs/art/batch19.csv`): a redo of the Endless Buffet's world map from a fresh plan (the painted sushi shop stands in the Raw Deal's old place), and the other rows listed there.
- Rip: walking art, if he should ever follow the player (he turns through eight directions on the spot since Nov 20).
- Elowen's walk, if it's missing.

## Design and balance passes
- **Camera per zone:** since Nov 21: +6 degrees everywhere (`data/camera/zone_camera.json`) and five presets on V (+6 to +14); "Camera angle" and "Camera distance" stay in Settings. Open: which preset a new player starts on.
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
- **A full-heal room is left in Primm's Castle** (the Resistance Safe Room; the owner's rule: the castle rooms are unchanged). The Path-ology Lab's became a "heal 5 for a cost" room on Nov 20.
- **Balance after Nov 21:** foes open with two Infrastructure (confirmed Nov 20), the zone dungeons have no full heal, five cards changed: no sim pass was run.
- **The Deck Station's search and controllers** (decided Nov 20: later): the controller's cursor skips the search box because there is no on-screen keyboard; the Path toggles and the other filters work with a controller.

## Added by Fable Nov 20 day (deferred, for the owner to schedule)
- **The gold-framed screens beside the glass ones:** the shops, the Deck Station, the Character screen and the dialogue box keep their walnut-and-gold look (the brief); the glass pop-ups open over them. If the two looks should meet, it is its own pass (inbox, "Fable Nov 20 day").
- **The title screen's own menu** (Continue, New Game ...) keeps its gold buttons; the pages it opens are glass. (The rose window tops it since the Nov 21 review.)
- **Glossary keywords in their Path's colour:** the data gives a keyword no Path; it would need one column in the keyword table.
- **The D.N.A.'s painted map shows a sunny village** (red and blue roofs, green lawns) where the zone is a haunted office at dusk; it fits the walk grid, the mood is the painter's. A repaint in the zone's palette would be a Batch 19 row if wanted (Nov 21: optional, not wanted for now; the row is marked so in `docs/art/batch19.csv`).
