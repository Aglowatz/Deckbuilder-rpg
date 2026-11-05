# Overnight pass — Nov 4-5 (Opus) — critic fixes, economy, dialogue rewrite, postgame dungeon

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner is asleep. Work autonomously
through the parts in order. Do not ask questions; log decisions in docs/overnight_inbox.md under
"Overnight Nov 4-5" and keep going. Tag `pre-overnight-nov4` at the start.

## House rules
- Check for STOP_OVERNIGHT before each part.
- The PC has 7.4 GB RAM and low disk. Keep it light:
  - ONE Godot process at a time;
  - at most 2 sub-agents, never while Godot or the tests run;
  - close everything between steps.
- **Tests, memory-safe.** Run the suites in small batches, one batch at a time, killing stray Godot processes between batches.
  - Use `bash tools/run_tests.sh` with the smallest shards it supports, or run the folders one by one.
  - If a run is killed for low memory, re-run only the shards that did not finish. Don't start over.
  - Before the final commit, every shard must have passed at least once tonight.
- **NO export tonight**, and no release smoke. The owner will ask for an export when he wants to distribute.
- Delete nothing outside build caches you created tonight.
- Commit and push after each part. Update docs/loop_state.md after every part.
- Screenshots go to docs/overnight_shots/nov5/.

## Part 1 — Finish the critic's list (docs/review/critic_nov4b.md)
First check git log and the report: if any item below is already fixed, verify it and skip it.

1. **Old Man Mountain.**
   - Before the endgame, he says the gate hint himself, in his own talk: the gate opens "when the kingdom is whole again".
   - After he gives "Only the Worthy...", his repeat lines point to the current step (buy the protein shake / bring it to him) instead of the old "Spot Gary..." line.
   - General rule: any NPC with an active quest step of theirs speaks to that step first.
2. **Alchemist screen.**
   - Selected jars are clearly marked (tick + "Selected" + highlight).
   - The Craft button always shows its cost ("Craft — 100 gold, 6 + 6").
   - When it can't be pressed, it says why: "Pick two Paths", "Need 6 more Necrocrat essence", "Need 100 gold".
   - Do a real craft in play with 18 essence, then screenshot the result showing 12 left.
3. **Quest log after Primm.**
   - Play to Primm's defeat on a real save (NOT `dev postgame`; use the dev menu's quest step setter or a snapshot to get close, then win the fight for real).
   - Check the tracker and the log. Finished zone main quests must be completed or hidden, never "0/4".
   - The tracker switches to "Under the Forest" automatically.
   - Fix both, then test.
4. **Forest hatch.**
   - Move the Lab hatch much further south: at least 25-30 m below the clearing (today it is about 10 m).
   - The post-game trail must read as a trail: a dirt/stone path texture with edging, a few lanterns or glowing mushrooms along it, and a soft light/beacon on the hatch.
   - At the start of the game it stays blocked by brambles.
   - Screenshot both states.
5. **Iron Cave.**
   - The popup uses the real name ("The Iron Cave") once the player is at the entrance. The prompt already names it, so "???" adds nothing there.
   - Move or hide the pylon that blocks the crag at the default camera.
   - Make the crag read as a cave: an irregular rock shape and a dark arched mouth, plus torches/chalk/leg-day kit at the mouth, built from existing kit/textures.
   - Screenshot it.
6. **The "Your first duel" tip** must not cover the Opening-hand panel or the Keep Hand / Mulligan buttons. Place it clear of them, or show it after the mulligan.
7. **Rule text that makes logical sense.**
   - Cell Block Brawler: Smuggled Weights no longer repeats the no-Iron line.
   - Rename one of "Pump It Up" / "Pump Iron" so the two read clearly differently, and say who each one affects.
   - Audit every encounter's pre-fight rules list for duplicates, near-twins and contradictions, and fix them.
8. **Nameplates.** Long names/titles (Rip Tearson, Rift Technician; Bertram; any others) must be fully visible: auto-fit the font or widen the plate. Check every NPC with a title.
9. **Item slots in battle.** A used (spent) slot looks different from an empty one (greyed icon + "Used" badge), consistently on the battle bar and the character page.
10. **Never seen in game — test each one in real play and fix what is wrong:**
    - the Rescue choice and its result screen;
    - a real craft at Auntie Alembic's;
    - Shiro's 3 Gilded packs after the Victory panel (the inventory must show them);
    - the D.N.A. elevators and lobby with no dialogue covering them.

    Fix the critic play scripts as the critic described:
    - HOG: travel to node 6, then double-click the node;
    - Alchemist: click Craft with two jars selected;
    - Shiro: press Continue on the Victory panel.

## Part 2 — Economy and dungeon rules
1. **Packs:** General Pack 150, Path Pack 200. Gilded packs: keep the same ratio to the Path Pack. Packs stay the bargain.
2. **Gold sources:**
   - Repeat fights pay the SAME gold as the first time; remove the 2x repeat multiplier.
   - **Dungeon clear bonus:** clearing a dungeon (boss beaten) pays a bonus equal to all the gold earned during that run, so the run's gold doubles. Show it on the clear screen ("Clear bonus: +X").
   - **Quests pay more:** raise quest gold rewards by about 50-100%, weighted toward main and longer side quests.
   - Re-run the gold study (docs/balance/gold_economy_nov3.md) and keep the target: about 20 cards plus 4-6 pieces of gear and a normal number of items, with no grinding.
   - Tune the clear bonus and quest multipliers to hit that target. Put the before/after tables in the report.
3. **Items:** each equipped item still works once per battle (keep that rule). Dyes stay at 60.
4. **No deck changes inside a dungeon.**
   - Remove the ability to rebuild or edit your deck mid-dungeon: the button, the screen access and any code path.
   - You play the whole run with the deck you entered with. Cards earned in the run go to the collection, not the deck.
   - **Exception:** the tutorial dungeon still adds its earned cards to the deck automatically, as today.
   - The Descent's lost card therefore stays lost for the run.
   - Update the tests and any tips or dialogue that mention changing your deck in a dungeon.
5. Remove the "(no tri-Path recipes exist yet)" line (ending.postgame.line.2). Tri-Path recipes are a post-game surprise: make sure they exist and are reachable after Primm. If they don't exist yet, log it.

## Part 3 — Early-game fun check (every Path)
With the new prices (cards from 100, single-use items, pricier gear, the new gold sources):
- Simulate each Path from a new save through the intro, the first shop, the first zone and its first dungeon.
- Report win rates, gold on hand at each shop visit, and what a player can afford there.
- **Goal:** every Path's early game feels fair and fun. That means a first dungeon win rate around 65-80% with the starting deck plus a couple of buys, and being able to afford at least 2-3 cards or items by the first shop visit.
- If a Path is starved or punished, adjust the starter decks, early rewards or prices (smallest change that works). Report each change.
- Write docs/balance/early_game_nov5.md.

## Part 4 — Dialogue rewrite (the big one)
The owner's verdict: a lot of the dialogue doesn't make sense or isn't good. These are the problems to fix:
- Claude's habit of short, clipped statement sentences in a row ("He waits. The door is old. You know this.") reads badly.
- The humour attempts mostly don't land.

Goals:
- **Main quests:** clear about what to do and why. ELITE storytelling, with real emotional story beats: loss, hope, the cost of Primm's "perfect" rules, why each Path matters. The story of the kingdom of Patchwork is woven through every zone so it builds to the ending.
- **Side quests:** this is where the humour lives. Character-driven and situational, with warm dad-joke and pun energy. Not a punchline every line.
- **Each primary character has a unique voice:** vocabulary, rhythm, sentence length, verbal tics and what they care about. A reader should tell who is speaking without the nameplate.
- **Sentences:** natural rhythm with varied length. Use contractions. People talk the way people talk. No strings of three-word sentences. No narrator-style fragments in spoken lines.

Steps:
1. **Read** docs/dialogue/voice_bible.md, the story bible/story data, the quest data and the current dialogue export. Re-export a fresh CSV first with tools/export_dialogue.js.
2. **Write docs/dialogue/story_voice_nov5.md.** It contains:
   - the kingdom's story spine (what the player learns in each zone and how it builds to Primm and the ending);
   - for each primary character (the Wanderer's companions and guides, Tilly, Rip, Old Man Mountain, Pip, Auntie Alembic, Agnes Overdue, Grandmaster Flex, the Grand Chef, Archdruid Compostella, Elowen, Primm and the other recurring NPCs and villains): a voice card with background, wants, speech pattern, 3 sample lines, and words they would never say;
   - a list of banned patterns, including the clipped-statement style, meta jokes, explaining the joke, and modern slang that breaks the world.
3. **Rewrite**, in this order:
   1. the main-quest lines zone by zone (intro, Crosspath, each Path zone, the Capital, Primm, the ending, the post-game);
   2. the primary characters' other lines;
   3. side quests;
   4. barks.

   Rules for every rewrite:
   - Keep IDs, {tokens} and [tags]. Max 240 chars per line, barks under 90.
   - Keep the spoiler rules (SpoilerFree) and the reveal tests passing.
   - Keep quest instructions accurate to the current game: check every "go here, do this" against the quest data.
   - Fix lines that don't make sense with the current story or state, e.g. a hint about something the player never heard.
4. **Apply** with `node tools/apply_dialogue_pass.js` as a revertible pass (record the IDs so `--revert=` works). Then re-export the CSV as docs/dialogue/edit_nov5.csv so the owner can review it in the sheet.
5. **Critic.**
   - One sub-agent with no context reads 60 random main-quest lines and 40 side-quest lines before and after, and scores voice, clarity, emotion and humour.
   - Fix what it flags.
   - Report the before/after examples (10 best) in docs/dialogue/rewrite_nov5.md.
6. Fix the Oct 31 export speaker labels (the Paste Works quest is Marlo; `fx.wake_outside` is a guard; the `.rushed` Primm-fight variants are Primm) in tools/export_dialogue.js.

## Part 5 — New postgame dungeon: "The Shattered Gallery" (existing art only)
Concept (refine it, but keep the spirit):
- After Primm falls, the cracked mirrors of his castle show "perfect" versions of everything the player beat.
- **Entry:** a shattered mirror in Primm's castle/model room, opened by a short postgame quest from a fitting character.
- **Structure:** about 12-14 nodes over three wings plus a final room.
  - Each wing is a gauntlet of **Echoes**: mirror versions of earlier bosses and elites, using their existing sprites/portraits tinted with a cold silver mirror shader. Each Echo has a twisted rule, e.g. "Perfect Form: the first unit you play each turn is copied for the enemy".
  - A few event nodes with harsh choices. No rest nodes, except one optional costly one.
- **Final boss: The Perfect Copy.** It plays an exact copy of the player's current deck, with more HP and one extra card drawn each turn. Card art is the player's own; the boss portrait is the hero's own art behind the mirror shader.
- **It is allowed to be unfair and very hard:**
  - zone HP with no healing between fights;
  - stacking mirror rules wing by wing;
  - enemies that start with boards (Just Arrived still applies).

  Balance-sim it. Target: a strong late deck wins the final boss about 20-35% of the time. Report the numbers.
- **Rewards:**
  - big gold and essence;
  - a feat;
  - a cosmetic "Mirrored" card finish (shader only, no new art) the player can apply to cards they own, or a similar no-art prize;
  - first clear only, plus small repeat rewards.
- **No new assets** except ONE map image, which the owner makes tomorrow:
  - Use a stand-in map until then (MapArt.STANDIN_MAPS).
  - Reuse existing music: the Primm/Capital cues, or an existing cue with a mirror/detune effect applied at runtime. No new audio files over 1 MB.
  - Every rule, shader and tint is code.
  - Keep RAM/VRAM and download size impact minimal. Report the bytes added.
- **Map prompt material for tomorrow:**
  - Add a row MAP-S-GALLERY to docs/art/art_needed_nov4.csv with a full description in the style of the other dungeon maps.
  - Make a node-position guide image docs/art/paintover_inputs/gallery_map_guide.png: the node layout and paths on a plain background at the map resolution, like deck_station_slots_guide.png.
- Tests: the unlock, the node graph, each Echo rule, the Perfect Copy deck copy, and the rewards.
- Write docs/design/shattered_gallery.md.

## Part 6 — Music: Gainlands quotes
Non-Beefcake cues that quote the old orchestral Gainlands march (FOREST, DECK, CREDITS, PRIMM-02, QUEST-ROLLO, CAP-RIFT, TUT-EXP, REUNION, THRONE...) should quote the new rock riff/answer (tools/music lib/rock.py) instead.
- Re-orchestrate the riff for each cue's own instruments: orchestral cues stay orchestral, quoting the rock riff's melody.
- Re-render at q6 with the existing toolkit.
- Run the music smoke.
- One cue at a time, to stay within memory.

## Part 7 — Art list and import prep for tomorrow morning
1. Add to docs/art/art_needed_nov4.csv:
   - **Generic townsfolk:** a walking sprite set (idle + walk, 4 directions, matching the sprite style) for 3 generic townsfolk (a mix of humans and humanoid animals), plus 1 dialogue portrait each.
   - MAP-S-GALLERY (Part 5).
2. Make sure every row in art_needed_nov4.csv has its exact target id, file path, size and format, so a drop-in import works.
3. Write docs/art/import_nov5_ready.md: for each id, the Approved_* folder and filename the owner should save it as, and the import command that will pick it up.
4. Make sure the importer handles every one of these ids (sprites, portraits, stills, UI background, map) with a dry run on placeholder files. Remove the placeholders after.

## Part 8 — Fresh critic playthrough (no dev shortcuts)
A sub-agent with no context plays a NEW save from a HEAD worktree (hard-linked, as before) with the play driver. It goes through:
- the intro;
- Tilly's item lesson;
- Meet the Merchants;
- the first shop;
- the first zone;
- its first dungeon, with fog and hidden nodes.

No dev win, no auto-win. It scores fun, clarity, difficulty and text quality, and lists its top 10 issues. Fix the quick ones; log the rest.

## Finish
- All test shards green (memory-safe batches).
- Write docs/overnight_report.md:
  - Part 1 results with screenshots;
  - the economy tables;
  - the early-game numbers;
  - the dialogue before/after;
  - the Shattered Gallery design and sim;
  - the music cue list;
  - the art import checklist;
  - the critic's findings;
  - the open questions.
- Commit and push. **No export.**
