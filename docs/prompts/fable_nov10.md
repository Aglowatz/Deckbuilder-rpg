# Fable pass Nov 10 — way-finding, turn counting, card display, rewards

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The 1.0 target is a free itch.io release. Read docs/overnight_report.md and the two
critic reports (docs/review/critic_mid_nov10/report.md, critic_late_nov10/report.md) first. Work autonomously; log questions in
docs/overnight_inbox.md under "Fable Nov 10". Tag `pre-fable-nov10` at the start.

## House rules
- STOP_OVERNIGHT check before each part.
- Memory:
  - ONE Godot at a time; kill strays first;
  - no sub-agents while Godot runs;
  - stop a job cleanly if free memory drops under ~800 MB.
- Tests: memory-safe shards. Add tests for every rule change.
- Screenshots go to docs/overnight_shots/nov10b/.
- Commit and push after each part. No public upload. Don't replace art files.

## Owner decisions (apply exactly)
- **No difficulty setting.**
- **Do NOT change the battle board or the UI layout.** Part 3 is a display fix of card numbers only.
- Primm stays as the last pass left him.

## Part 1 — Finding things in the world (the top priority)
Goal: a player always knows where to go, and can see and reach everyone they need.

1. **Quest markers point to everything relevant.** For EVERY active quest step (main and side), each relevant thing gets a marker on the world map, the minimap, the "Point me to..." list, and the on-screen arrow when it's picked:
   - the NPC to talk to;
   - each item to pick up;
   - each place to reach;
   - each enemy to beat.

   Steps with several parts (e.g. "sea salt and a black truffle") mark every part and drop each marker once it's done.
   - Extend tools/quest_audit.gd so it fails when any step lacks a marker target. Fix every gap it finds, in every zone.
2. **The route to each main dungeon must never be a guessing game.**
   - The Endless Buffet: Sir Loin's gate needs Old Meatloaf mended with sea salt and a black truffle. Both pickups get markers the moment the quest is taken, and Basil's and Sir Loin's lines say roughly where each one is.
   - Audit every zone's path from arrival to its main dungeon, including any fetch or favour gate, the same way.
   - Fix the stale line: Sir Loin still says "speak to Basil" after you've taken Basil's quest.
3. **Nobody hidden behind props.**
   - Write a check that, for every NPC with a talk prompt in every zone, takes the default and Low cameras and confirms the NPC's body and talk point aren't hidden behind props, fountains, walls or roofs.
   - Move any hidden NPC into open space (Basil, Tarragon and any others it finds).
   - Make E's talk reach match the click reach.
4. **Map labels never pile up:** collision avoidance or offsetting, hide minor labels at small zoom and show them on hover, and keep the "Point me to..." dropdown from covering the legend. Check every zone map.
5. **No white sheets from fading props:**
   - Props that fade to show the hero use dithering or a much lower alpha, capped to their on-screen bounds, so the screen never washes out.
   - Walk-test every zone with screenshots, especially north of the Buffet hub.
6. Prove it by playing: a no-context critic arrives in each Path zone fresh (from snapshots) and must reach the main dungeon using only the game's guidance, no dev travel. Report the time taken and any confusion. Fix what it hits.

## Part 2 — Turns count both players
A **turn** now means both players' turns: the first player goes, then the second player goes, and that is **Turn 1**.
1. **The battle HUD** shows "Turn N", with "Your turn" / "Enemy's turn" beneath it.
2. Update **everything that counts turns or rounds** so it means the new Turn:
   - the battle HUD and the log;
   - boss and phase timers (Primm's Setting Up, his phase rules);
   - the "from turn N" rules text and pre-fight panels;
   - countdowns and the AI;
   - feats and stats ("win within N turns");
   - tutorials, the glossary, and the sims and tools.
3. **Gameplay timing must stay identical:**
   - Convert every number so it points at the same moment in the fight as before. For example, if something happened on the old "round 3" and that was the player's second turn, its new text must say the turn where that still happens.
   - Card and rule effects that last "until end of turn" or happen "each turn" for one side keep their current behaviour. Word them clearly ("until the end of your turn", "at the start of each of your turns") where they could now be misread.
   - Report any timing you couldn't keep identical.
4. Fix the contradictions the late critic found while you're here: the Setting Up countdown agrees with the rules panel, and there's one energy message, not two contradictory ones.

## Part 3 — Card numbers in hand show their real current values (display fix, no layout change)
- When anything changes a card's numbers while it's in hand, the hand card, its hover preview and its tooltip show the changed value. That covers power, toughness, cost and any other stat:
  - Primm's "every unit is a 3/3";
  - cost changes;
  - auras or zone rules that apply in hand;
  - temporary buffs and debuffs.
- Show it with the usual convention: green when better, red when worse, with the base value in the tooltip.
- Also cover the Deck Station only if the same code path is shared. Test with Primm, a cost reducer and a zone rule, with screenshots.

## Part 4 — Rewards and defeat text
1. **Remove "Losing costs nothing"** (and any similar wording) everywhere: the defeat screen, tips, tutorials and dialogue. On a dungeon defeat, say plainly that the dungeon starts over, and that cards and gold already won are kept.
2. **Dungeon encounter rewards +50%:** every fight inside a dungeon (normal, elite and boss nodes) pays 50% more gold and XP than now. Card picks and packs are unchanged.
3. **The dungeon completion reward −20%:** the completion bonus paid for clearing a dungeon (the clear bonus that matches the gold earned in the run, plus the first-clear bonus) is cut by 20%. If you find "final dungeon" means something narrower in the data (e.g. only Primm's Castle), apply it to every dungeon's completion reward anyway, and log what you did.
4. Re-run the gold study and report the new no-grind total against the ~21.2k target and the completion estimate. If it moves more than ±10%, report it but don't re-tune.

## Part 5 — New equipment: immunity to damaging NPCs
- Add a piece of equipment that makes the player **immune to damage from roaming enemies and world hazards outside battle**: the meatball, Tidy-Bots, the gravy pit, roamer bumps, trap tiles, and anything else that takes zone HP while walking. It does not affect battles or story damage.
- **Slot:** the one with the fewest options (count them).
- **Name and flavour:** the game's humour (e.g. "Hall Pass: Roaming troublemakers and hazards can't hurt you. Paperwork says you're fine.").
- **How you get it:** a fair mid-game purchase from an existing gear shop, priced in the gear range, or a side-quest reward if one fits naturally. Pick one and log it.
- Use an existing icon for now, and add an art-list row (ICON-EQ-<name>, ICON style) with an image description for the next batch.
- Add a test.

## Finish
- All test shards green.
- Export **1.0.0-rc3** and run the release smoke and the short exported-build checklist.
- One no-context critic re-plays the midgame on the exported build (the Buffet, from arrival to the Test Kitchen boss) and scores clarity and fun against the old 5/4.
- docs/overnight_report.md: per-part results with screenshots, the turn-counting conversion table, the reward numbers and gold study, the new equipment, the critic's re-score, and where RC3 is.
- Commit and push. No public upload.
