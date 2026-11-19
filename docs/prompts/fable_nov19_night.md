# Fable, night of Nov 19-20: the owner's playtest list, the Arena puzzles rebuilt, colours back, cameras

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner played today's build; this is his list. His screenshots are in `docs/overnight_shots/nov19c/ref_*.png`. **The judgment-heavy job is Part 7, the Arena puzzles**; give it real thought.

Read first:
- the top of docs/overnight_report.md ("Fable Nov 19") and docs/overnight_inbox.md;
- docs/owner_backlog.md;
- docs/art/path_colour_guide.md;
- docs/writing/story_bible_v2.md.

Run `git status`; if anything is uncommitted, run the tests and commit it. Log questions under "Fable Nov 20". Tag `pre-fable-nov20`. Work in this order; if time runs short, finish the part you're on, skip to Part 10, and list what's left.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`. If the guard stops a background run, finish it in the foreground with `--from=N --to=K`. Tests run under the save guard.
- Commit and push after each part. No public upload.
- Shots in docs/overnight_shots/nov19c/.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board layout stays;
  - Primm's fight and the castle rooms unchanged;
  - no enemy intent shown;
  - no combat pacing changes;
  - no new painted art (Batch 18 rows instead);
  - each zone keeps its own colour grade.
- **Dialogue:** single-line changes plus the rewrites asked for here. IDs to `docs/dialogue/nov20_lines_ids.txt` with `docs/dialogue/nov20_lines.csv` for `--revert`.
- Every rules, quest or card change gets a test.

## Part 1 — The owner's decisions from "Fable Nov 19"
1. **The Path palette, partly reverted:**
   - **Necrocrat goes back to purple** in the UI (the old violet, as on its card frames). The Path icon keeps its green ghost-flame; that's fine.
   - **Gourmand goes back to blue** (the cream was too neutral).
   - Beefcake red and Refusemancer moss green stay.

   Update `core/data/path_palette.json`, the guide and its swatches; check the four still read apart (colour-blind check too). Re-check the four Batch 18 colour rows (UI-CARDBACK-N, UI-PACK-N, V-ALEMBIC, VS-ALEMBIC): keep only what's still wrong under this palette, and rewrite their descriptions to match.
2. **Cameras:**
   - **The default pitch is +4 degrees in every zone**, the D.N.A. included (it was +6), distances as now.
   - **Keep the test options available to players in Settings** so the playtesters can choose: a "Camera angle" setting (Standard / +4 (default) / +6 / +8) and a "Camera distance" setting (Closer / Default / Further), applied to every zone, alongside the existing camera presets.
   - Report how it reads in each zone (a shot per zone at the new default).
3. **Buildings in the way:** keep the see-through window with the hero's outline (inbox item 3).
4. **The info-screen rebuild** waits for the owner (don't rebuild the menus tonight).
5. **The castle's new choice numbers:** playtest as they are.

## Part 2 — Card and encounter fixes
1. **Rusty Grave Shovel** is too much like the Corporate-Approved Pen. Change it: the attached unit gains **Toxic and Swat** (keep its cost and Exhaust: attach; rebalance only if clearly off). Update the card text, the list and the tests.
2. **Hortensia Clipwell, Royal Groundskeeper** (`ref_hortensia_topiary_buff.png`):
   - Her **Topiary tokens enter as 3/4**, far too strong for this fight. They must enter at their printed base size, and that base should be small (about 1/2); check why they enter bigger (stacked buffs, the rule below) and fix.
   - **Her garden rule snowballs:** today every unit gets +1/+1 on every turn, for both players, so whoever lands units first wins. New rule: **at the start of each player's own turn, one random unit that player controls gets +1/+1.** It triggers only on that player's turn, once.
   - **Apply that rule everywhere the same "all units grow every turn" effect exists** (other encounters, arena rules, cards), and update every text that describes it.
3. **The choice node just before the Rotheart** is too easy. Make it painful but powerful: **"Give blood to distract the Rotheart (-5 HP; you take the first turn in the fight)"**, plus a do-nothing option ("Walk on"). One set of brackets only, per option. Make sure "you take the first turn" really works in that fight.

## Part 3 — Alembic, equipment
1. **Alembic's crafted card** (`ref_alembic_crafted_card.png`) is small, off-centre, and the "joins your collection" text overlaps it. Show the new card **large and centred** in "The Brew" panel, with the line underneath and no overlap. **Hovering it magnifies it** (like the reward-card hover).
2. **After a brew, the two chosen essences stay selected**, so the player can brew again at once if there's enough essence (the Craft button stays enabled while there is).
3. **Equipment:**
   - **Remove the tier** ("Tier 0") from every equipment visual (cards, lists, shops, rewards).
   - **Long descriptions wrap** onto more lines and fit (`ref_equipment_text_cut_off.png`: the Thorned Loincloth runs off the panel). Check every equipment screen with the longest description and Large text.

## Part 4 — Quests and dungeon entrances
1. **"The Door Under the Well"**: the hidden chest in Crosspath can't be found. **Rework the quest** so every step can be done by a new player: a clear hint in the giver's words, a map marker once the area is known, and the chest (or whatever the step needs) visibly placed and reachable. Walk it start to finish in the running game and screenshot each step.
2. **"Outskirts Watch"** can't be handed in to Gatekeeper Brannoch: after the first part, talking to him does nothing. Fix the hand-in and test it. **Then check every quest's hand-in** with a probe: for every quest step that says "talk to X" or "hand in to X", X exists in that zone in that state and the talk completes the step. Keep the probe as a test.
3. **Dungeon entrances** (`ref_dump_entry_prompt_levels.png`, `ref_dump_sealed_message_levels.png`):
   - **No level counts in the entry prompt:** "[E] Climb into the landfill", not "...: three levels". Every dungeon and mini dungeon.
   - **A sealed dungeon names itself**, not "???": e.g. **"The landfill is sealed. Talk to [NPC] at [place]; they may know more."**
   - **Every side dungeon has its own side quest** from that NPC, so players know what to do to open it and are sent there (tracker, map marker). If one exists already, make sure the sealed message points to it.

## Part 5 — The world
1. **The D.N.A.** (`ref_dna_desk_and_carpet_off_centre.png`):
   - **Centre the desk** (the counter with the three green terminals) in the middle of the plaza, on the carpet's line.
   - **Centre the entrance gate** you walk through with the carpet, so the gate, the carpet and the desk line up.
2. **The Gainlands:**
   - **Quest markers float far too high** above the NPCs' heads and are hard to see. Lower them to just above each head (per NPC height). **Check every zone** for the same.
   - **Gary, stuck on the bench, never turns to face the hero**: he and the bench stay as they are (he's stuck).
   - **The mini dungeon's rock formation** on the northern path hides the hero when he walks behind it. Make the hero visible there (the see-through window and outline from the fade system, or tag the rocks as tall occluders).
3. **The Endless Buffet:**
   - **The area by Dex Shufflewick and Professor Pate** is hidden behind the broccoli trees (`ref_buffet_broccoli_blocks_view.png`). Remove enough of the trees there (keep a few, and keep the east border forest) so the path and the NPCs are clearly visible.
   - **The west side, especially at the north end past the river:** the ground slopes down below the water, so the water looks higher than the ground. **Raise the sloped ground level with the rest of the zone** and make the edge where land meets water natural (a soft shore, a wet band, no slab, no straight cut). Shots at both cameras.
4. **The Verdant Dump:** taking a slide while on a mount loses the mount. **Keep the mount through the slide and after.** Also fix the Dump's walk smoke (Wren takes the heal spot's prompt).

## Part 6 — Elowen after the third zone
Her dialogue after the third zone hints that she doesn't know who the Wanderer is. **She knows exactly who he is:** she rescued him and knew what they were doing to him; she felt he needed to remember on his own. Rewrite that scene so that she **realises his memories are coming back**, and closes with the meaning of: **"You know who you are. Now go free the last zone Primm holds, and prove it."** Check her other scenes for the same mistake and keep it consistent with the story bible.

## Part 7 — The Arena puzzles: rebuild all of them (the main job)
Today the puzzles are laughably easy. **Rebuild every Arena puzzle** (all tiers, Bronze to Diamond) so that each one:
1. **Features a multi-Path synergy:** the player wins only by combining two Paths, including multi-Path cards, and each puzzle shows a different way the Paths work together. The owner's example: use a Necrocrat card to resurrect a Beefcake unit with Hustle, then use removal to deal exactly enough damage to finish the opponent.
2. **Is a tricky situation:** a set board, hand, resources and opponent, with **extra cards in hand and on the field** that look useful but lead nowhere, so the solution isn't obvious at first glance.
3. **Has exactly one intended line** (small variations are fine), achievable in one turn unless the puzzle says otherwise, with all needed information visible (what's in play, hand, resources, the opponent's HP and board).
4. **Teaches:** its title and one-line brief hint at the synergy without giving it away (e.g. "Back from the Dead, Back to the Gym"). Afterwards a short "What you just did" line explains the synergy.
5. **Gets harder by tier:**
   - Bronze: two-step combos;
   - Silver: three steps with one decoy;
   - Gold: four or more steps with several decoys and an ordering trap;
   - Diamond: the hardest, using the most cards and an unusual interaction.
6. **Proof for each puzzle:**
   - write a **solver** (a search over the player's legal plays for that turn) that confirms the puzzle can be won, finds the winning lines, and confirms the obvious naive plays fail;
   - report for each puzzle: the intended solution (step by step), how many winning lines exist, the decoys and why each fails, and the Paths and synergy shown;
   - keep the solver and one test per puzzle (solvable; naive line fails).
7. Use existing cards only (any Path pair and multi-Path cards; Iron, Ingredients, Garbage, Red Tape, Contracts and tokens as needed). The puzzles keep their tiers' rewards. Don't change the Arena's battles (the owner tunes them by hand).

Put the full puzzle table in the report so the owner can play-check each one.

## Part 8 — Batch 18 tidy-up (rows only)
In `docs/art/batch18_nov18.csv`:
- **Remove** NPC-PLAYER, STORY-MEMORY-4 and TOWN-PROP-CELLAR-FOURSEALS-CLOSED (the owner said no change to the cloak; the vault seals are in a row).
- Re-check the colour rows (Part 1).
- **Add** the Arena's new art, if missing: **ARENA-MENU-BG** (the arena menu screen) and **BB-ARENA** (its battle board, replacing the colosseum). The story: a **low-key underground cave dueling arena, literally underground**, not a colosseum (lantern light, a chalk or rope ring on a stone floor, crates and benches for a small crowd, rough rock walls, a few banners). Give exact sizes and self-contained descriptions under 600 characters.
- Rip: confirm SPR-RIP-FRONTSIDE_IDLE covers what's missing for his turning; add rows for any other direction he needs.

## Part 9 — Check the flow
- Walk "The Door Under the Well" and "Outskirts Watch" end to end.
- Play the Hortensia fight twice (the bot) and report the turn counts before and after.
- Screenshot Alembic's brew result, the equipment page with the longest text, the D.N.A. desk and gate, the Gainlands markers and rocks, the Buffet's Dex area and west shore, a sealed dungeon message and an entry prompt, and the camera settings.

## Part 10 — Tests, build, report
1. All test shards green; the walk smokes (every zone, the Dump's included); the NPC visibility probe; the fade probe; the quest hand-in probe; the puzzle solver tests.
2. **Export 1.0.0 for the playtesters:**
   - wait up to 10 minutes for at least 2.2 GB free RAM, otherwise use `EXPORT_LOW_MEMORY_OK=1`;
   - `bash tools/export_windows.sh 1.0.0`;
   - the exported smoke and the three `play_exported.sh` checks (0 SCRIPT ERROR).
3. **docs/overnight_report.md**, at the top, under "Fable Nov 20":
   - each part done or not, with shots;
   - **the Arena puzzle table** (tier, title, Paths, synergy, the solution step by step, the decoys, the solver's results);
   - the new Hortensia rule and every other place it now applies;
   - the dialogue revert command;
   - where the zip is;
   - the owner's decisions needed (at most 6, each with a recommendation).
4. Commit and push. No public upload.
