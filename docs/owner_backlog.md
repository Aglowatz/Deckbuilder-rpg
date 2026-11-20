# Owner backlog: agreed future work (not yet scheduled)

Kept by the owner's assistant. Claude Code: read this, but don't start these items unless a brief asks for them. Add new owner-requested "later" items here.

## Next scheduled
- (nothing scheduled; the objects-disappearing pass was done Nov 19: `docs/overnight_report.md`, "Fable Nov 19")

## Art (the next ChatGPT batch, run from a sheet tab)
- The five world maps: Gainlands, Buffet, Dump, D.N.A., Capital (plans in `G:/My Drive/Card Game Art/Batch 18 Refs/`).
- A painted D.N.A. clock tower (`DNA-HERO-CLOCK-TOWER`); the hourglass sign (`DNA-SIGN-HOURGLASS`); the breakroom couch (`DNA-PROP-HEAL-COUCH`).
- Rip: any missing turning/walking art so every Rip faces and follows the player.
- Elowen's walk, if it's missing.
- Card art: **Baron Quadzilla** (Iron Cave reward; match NPC-QUADZILLA / CUT-QUADZILLA) and **Announcer Grand Bellows** (Arena Diamond reward; match NPC-BELLOWS).
- **The Arena:** a new arena menu screen and a new battle board. The story: a low-key **underground cave dueling arena** (literally underground), not a colosseum.
- **Auntie Alembic:** a visual update of her shop interface and a custom graphic for when she shows her wares.
- Everything in `docs/art/batch18_nov18.csv`.

## Design and balance passes
- **Camera per zone:** decided Nov 19 night: +4 degrees everywhere (`data/camera/zone_camera.json`), with "Camera angle" and "Camera distance" in Settings for the playtesters. Open: which preset a new player starts on.
- **The Arena's balance and difficulty:** several encounters are far too easy and the puzzles were rebuilt Nov 20 (four, each with one solver-proven solution; the owner play-checks them). The battles: the owner checks each by hand, then a Fable pass. It's fine for the Arena AI to have set hands and opening-hand rules (e.g. a guaranteed mix of infrastructure and cards) so it never stalls on too little or only infrastructure.
- **The info screens' look:** proposed Nov 19 (`docs/art/ui_style_guide.md`, mock-ups, 11 Batch 18 rows); after the owner's yes: rebuild the menus with the stand-in art, then drop in the new pieces.
- **Path colour consistency:** Gourmand blue and Necrocrat violet again since Nov 20 (`core/data/path_palette.json`, `docs/art/path_colour_guide.md`); the pictures still in the wrong colours are Batch 18 rows (the Necrocrat card back and pack; Alembic's shop picture, low priority).
- **Combat pacing:** the owner tests manually; no automatic changes. The 45-card minimum stays.

## Added by Overnight Nov 19 (deferred, for the owner to schedule)
- **The Arena's tier prizes and pack rewards**: first numbers only; the owner's planned by-hand Arena balance pass should look at them with the encounters.

## Added by Fable Nov 19 (deferred, for the owner to schedule)
- **The window in the tree cards and the D.N.A.'s cabinets:** they still fade per piece in their own shaders (to 60 % see-through, never under the hero's shoulder). Moving them to the same round window as the buildings needs their batched meshes to carry the window too.
- **A Path-coloured ring instead of the footprint outline** for a building the lens is inside: only if the plain outline reads badly in play.
- **The quest log's and the level-up pop-up's small grey text** (unknown steps, "XP toward level 3"): the same contrast fix the quest box got, as part of the info-screen rebuild.
- **The Glossary has no card pictures:** if example cards are wanted there (one per keyword), it is new content, not a hover fix.

## Added by Fable Nov 20 (deferred, for the owner to schedule)
- **A chest of its own for the well's key:** "The Door Under the Well" sends the player to Shiro Swindle's prank chest (50 gold, and it starts his questline). A small chest near the well for the key would untangle the two.
- **The see-through window in the Iron Cave's rock:** the hero's outline shows through the crag, but the round window does not open in that rock's material (it needs the fade shader's include, like the buildings).
- **More Arena puzzles:** the solver and the lab tool (`bash tools/arena_puzzle_lab.sh --file=<draft>`) make a new puzzle cheap to prove. One per Path pair would be six; there are four.
- **The Diamond puzzle's wall:** it has one blocker because the search could not finish with three. A faster search (pruning by the damage still possible) would allow a fuller board.
- **The "Under the Old Well" kind of follow-up quest is not tracked automatically** when it starts: the tracker stays on whatever was tracked. If that reads as "nothing happened", track it on start.
- **The Heart Roots' old option** (sever the roots: the Rotheart starts with 6 less HP) is out of the node; its code and cutscene are still there if it should return.
