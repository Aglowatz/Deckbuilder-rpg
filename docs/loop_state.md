# Loop state - Overnight Nov 3-4 (Opus 5.5)

Brief: docs/prompts/overnight_nov3.md (Parts 0, A, B, C, D, E, Finish). Tag `pre-overnight-nov3` at the start.
Questions: docs/overnight_inbox.md ("Overnight Nov 3-4"). Report: docs/overnight_report.md. Shots: docs/overnight_shots/nov3/.
Stop when STOP_OVERNIGHT exists in the repo root.
Rules: one Godot at a time; <= 3 agents, never while Godot/tests run; GUT sharded; tests green -> commit -> push per part.
Previous state: docs/overnight/nov3b/loop_state_gainlands_rock_nov3.md.

## Part 0 findings
- Gainlands techno-hard-rock set: LANDED (commits 795560c2..66ee34f2, 15 cues + MUS-BEEF-BATTLE).
- Vorbis q6 rollback: LANDED (144/144 re-rendered at true q6, music folder 290 MB).
- Missing from that pass: the v0.5.3 export + release smoke (blocked on disk). At the start of tonight: C: 1.9 GB free, ~1.7 GB free RAM.

## Reference images (docs/ui/ref/)
- character_menu_target.png: the TARGET Character page - parchment left half with a body silhouette and 5 locked slots (Helm, Armor, Weapon, Relic, Boots)
  + an "Equipment unlocks after..." pill; middle column LEVEL panel (star, Level 3, 30/80 XP bar, HP/Opening hand/Max hand/Gold, PATH ESSENCE row) over a CARD PACKS panel ("No unopened packs" + hint); right a large ITEMS panel (EQUIPPED 1/2 unlocked, 4 slots: icon x2, Empty slot +, two locks "Level unlock"; note; INVENTORY grid 5x2 with scrollbar; detail row icon/name/"Single-use • 2 charges owned"/"Equipped in slot 1"/Unequip; footer hint).
- character_menu_current.png: the CURRENT page - title clipped off the left ("TER"), every equipment slot says "Opens armory quest", LEVEL panel is a long text list (Path, Deck, Starting HP, Item slots 1/4, Copies per card...), ITEMS is a small icon + text line with Unequip/Use, CARD PACKS is plain text; lots of empty space.
- pip_tryon_current.png: Threadwell's Hats & Hems - "Try" shows the full player sprite (cloak, body) on a purple pedestal with the hat; a cloak dye swatch row under it; owned hats show a disabled "Owned" button (no Equip, no "No hat"). Why change: the body hides/competes with the hat.
- battle_item_icon_current.png: the battle item slot (Firebrand Charm) under "Battle log" - a dark translucent bar runs across the middle of the icon and the charge count "2" sits at the right edge, low contrast.
- townsfolk_badgers.png: Crosspath street - every generic "Townsfolk" NPC (several visible) is the same badger sprite; one stands half inside the left building's wall.
- flex_art_current.jpg: Flex art strip - (1) portrait: elderly HUMAN, white beard, red/cream robes, chained hands; (2) STORY-FLEX: muscular LION ripping chains in a throne hall, an old black-uniform Clench on the throne; (3) sprite: human old man full body; (4) STORY-RESCUE: human old man in a cell, hooded rescuer at the door; (5) new NPC-CLENCH: muscular human, white-and-gold uniform, red sash, dumbbell.

| Part | What | State |
|---|---|---|
| 0 | State check + image notes | done |
| A | Quick fixes 1-7 | todo |
| B | Systems + balance 1-10 | todo |
| C | Character page redesign | todo |
| D | Pip's shop | todo |
| E | Art audit CSV | todo |
| Finish | GUT, critic, report, export, smoke | todo |
