# Owner backlog: agreed future work (not yet scheduled)

Kept by the owner's assistant. Claude Code: read this, but don't start these items unless a brief asks for them. Add new owner-requested "later" items here.

## Next scheduled
- **Objects disappearing (camera cut-away / occlusion fade):** far too many objects fade when they don't need to; it looks worse and confuses players. A Fable run dedicated to finding the right balance, after the owner provides screenshots and a brainstorm.

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
- **Camera per zone:** a default pitch and closeness test for every zone to pick what looks best. The D.N.A.'s +6 degrees is the model the owner likes.
- **The Arena's balance and difficulty:** several encounters are far too easy and the puzzles are laughably easy. The owner checks each by hand, then a Fable pass. It's fine for the Arena AI to have set hands and opening-hand rules (e.g. a guaranteed mix of infrastructure and cards) so it never stalls on too little or only infrastructure.
- **The info screens' look:** rework the default backgrounds and frames of the menus, the quest box (top left) and other info screens; new art allowed.
- **Path colour consistency:** one representative colour per Path, applied to every piece of UI and art that stands for a Path (e.g. the essence tracker, Auntie Alembic's art), like the Path icon pass. A Fable pass, then new pictures as needed.
- **Combat pacing:** the owner tests manually; no automatic changes. The 45-card minimum stays.

## Added by Overnight Nov 19 (deferred, for the owner to schedule)
- **Primm's Castle choice nodes** (Grand Foyer, Lab Notes, Garden of Uniform Flowers and the two story events): left as they were because of the "castle rooms unchanged" rule; three of their options are still purely good. A one-line yes from the owner and they get the same boon-with-drawback treatment as the other dungeons (Part 5).
- **Crosspath shop-front signs** (Sable's, Tilly's, Fenwick's...): they hang on the shop fronts round the square, so the east- and west-facing ones stay edge-on to the camera. Turning them would pull them off their walls; a decision on whether to add a free-standing board in front of each.
- **Enemy-side choice-node drawbacks** that add a unit or a resource to the enemy at the start of a fight (the brief's list): the engine has enemy attack/HP drawbacks now (foe_atk / foe_hp); "the enemy starts with an extra unit" needs a new start-of-duel summon for the enemy seat.
- **Card grids without hover magnification**: Alembic's page has it now; a sweep of the remaining menu card grids (Collection Book pages, the Glossary's examples) was not done tonight.
- **The Arena's tier prizes and pack rewards**: first numbers only; the owner's planned by-hand Arena balance pass should look at them with the encounters.
