# Fix pass — Nov 7 morning (Opus) — critic top 15, part 1

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). Source of truth: **docs/review/critic_nov6_summary.md** (its section numbers
are used below) and the critic reports in docs/review/critic_nov6/.

The owner's decisions in this prompt **override** the summary's suggested fixes and its section 6. Work autonomously; log questions in
docs/overnight_inbox.md under "Fixes Nov 7".

## House rules
- STOP_OVERNIGHT check before each part.
- ONE Godot at a time; at most 2 sub-agents, never while Godot or tests run.
- Tests: memory-safe sharded runs (`bash tools/run_tests.sh --only=tests --size=12`, resume with `--from=N` after a low-memory stop). Add GUT tests for every rule change.
- Visual checks go through `bash tools/play.sh`; screenshots to docs/overnight_shots/nov7/.
- Commit and push after each part; update docs/loop_state.md. Follow docs/dialogue/story_voice_nov5.md for any text. No export.

## Owner decisions (apply exactly)

**D1. Losing a fight**
- **No penalty:** no gold fee, no item loss, no "Try again" button.
- Losing respawns you in the zone you're in, at its respawn point, at full HP.
- This also replaces last overnight's tutorial "retry in place" (`Session.tutorial_retry_on_loss`). Losing in the cave respawns you in the forest clearing, and the cave starts over (see D2).
- Losing Primm respawns you in the Capital.
- Keep the gate gag for the first defeat only if it doesn't cost anything.

**D2. Dungeons**
- Leaving a dungeon partway (Retreat, losing, quitting) means starting over. That is intended: replaying dungeons is the main way to farm cards and gold.
- Every run pays every node again.
- Add a clear warning on Retreat: "Leaving resets this dungeon. Cards and gold you've won are kept."
- Show the same rule in the dungeon map's first-visit tip.

**D3. Starting Path**
- The starting Path only decides the starting deck.
- Maren's dialogue recommends starting with the Path you chose, because it's the easiest. When the player picks their Path, that Path's gatekeeper quest is added and auto-tracked.
- Maren's errands (merchants, deck edit, store room, armory) become a parallel "Settling In" line, not a gate.
- Every gatekeeper can be fought at any point.

**D4. General Packs**
- General Packs stay fully random across all Paths. Do NOT weight them toward the player's Path: players are meant to collect and use cards from every Path.
- Sable still stocks 5-6 singles per Path.

**D5. Town maps**
- Towns are NOT pre-revealed; exploring uncovers the map.
- Shops, exits and quest-giver icons always show on the map from the start.
- Walking reveals terrain in a generous radius.
- Draw roads.
- Zones reveal their outline and landmarks on arrival.

**D6. Opening hand:** every player opening hand has at least two infrastructure cards (a hidden soft mulligan), in every fight, for the player only.

**D7. The Capital**
- Give the four identical citizens real names and lines.
- Add one last shop just before the castle.
- No side doors.

**D8. Art rows:** add the five rows in section 4 of the summary to docs/art/art_needed_nov4.csv as "Needed — later batch" (BB-S-GALLERY, DEC-PLINTH-EMBLEMS, UI-CAULDRON, UI-BG-PACKS, KIT-HEAP-THORNWALL). Don't make art.

## Part 1 — First hour (summary items 1, 4, 5)
1. **Item 1** with D3:
   - a standing "Your Path" tracker line from the Path choice on ("Face Brick Bronson on the Gainlands road");
   - a Path-coloured map and minimap icon on that zone's exit;
   - Maren names the gatekeeper and the road;
   - while a portal is sealed, E prefers its guardian NPC.
2. **Item 4** with D6:
   - Delay "growth" room rules (e.g. Wild Growth) to turn 3 on first nodes.
   - Smooth the cave: duel 2 at 6-8 HP with a blocker, a smaller Hollow Warden swarm.
   - Give the Refusemancer starter a sturdier early body or a starting Garbage.
   - Re-sim the cave and each Path's first gatekeeper and first node, and report the numbers.
3. **Item 5**, everything except the cave checkpoint (D2 says no checkpoint):
   - No default focus on "Take" on the victory screen.
   - The whole Path column is one click target, with "Pick a Path first" next to a disabled Begin.
   - Queue quest toasts while a dialogue is open, and size the panel to its text.
   - Move the dungeon map tip clear of the title banner.

## Part 2 — Walking and maps (items 2, 7, 14)
1. **Item 2**, all of it:
   - capsule collision with wall sliding, and prop colliders shrunk to their footprints;
   - a clear ring round fountains, and clear main lanes;
   - roamers never block the hero;
   - a fixed camera yaw inside a town;
   - roofs and walls in front of the hero dither or cut away, and markers anchor at doors;
   - fix the invisible wall in the Dump's Compost Commons;
   - add a walk smoke from spawn to each shop and exit in Crosspath and each zone hub.
2. **Item 7** with D5:
   - a ground trail or edge-of-screen arrow after a "Where to?" pick;
   - map labels that don't collide and stay inside the frame;
   - one roamer within sight of each zone hub's exit.
3. **Item 14** with D7:
   - Auto-track the main quest on step change.
   - The Capital: an "[E] Travel to the Capital" exit, plus a tracker step and pin for the Crease.
   - Castle nodes show their type once a neighbour is cleared.
   - **Postgame blocker:** the forest hatch can't be reached on foot. Remove the leftover bramble collider and add a walk smoke from the rift to the hatch.
   - The postgame forest behaves as a normal zone (tracker, J, pin).
   - The Gallery gets its own quest line, a "Where to?" entry and labelled Crease doors.
   - Heals in the Gallery show in the log and as floating numbers.

## Part 3 — Menus and cards (items 3, 8, 12, 13)
1. **Item 3 (Deck Station):**
   - Save Deck saves the active slot at once, with a separate "Save as new slot".
   - Esc/X with unsaved changes opens Save / Discard / Cancel.
   - The deck list scrolls.
   - Every grid click adds one copy, with a visible +1.
   - Find and fix the 53-vs-51 count.
2. **Item 8** with D4:
   - "Open all" shows a grid of card faces with NEW badges.
   - Any click skips a single pack's animation.
   - Say what "Open all" skips (gilded packs).
   - Toasts don't cover the result.
3. **Item 12:**
   - Hand cards show cost, name and stats only; the full card shows on hover. No left preview for hand cards.
   - Move the rarity gem off the type line.
   - A drag starts on the raised card.
   - Use a two-row fan above 10 cards.
   - Check readability at 1280x720.
4. **Item 13:**
   - A modal stack: Esc closes only the topmost popup, with a 0.2 s guard after a close.
   - Back returns to the opener.
   - The Deck Station's gold focus ring everywhere.
   - Extend the gamepad smoke so it checks Esc closes each screen.

## Part 4 — Losing, and Primm's presentation (items 6, 10)
1. **D1 and D2** replace item 6.
2. **Item 10, presentation only.** Do NOT change Primm's numbers (owner's decision; a separate measurement comes later).
   - A big centred "Hand full: click a card to toss" prompt over the hand; Space tosses the lowest-value card.
   - A phase-break card instead of the ordinary VICTORY box; show "Primm" in the nameplates and logs.
   - Wire the Model Room board (BB-PC-BOSS), and show the boss node as the Model Room.
   - Find out whether "Every unit starts as a 3/3" is a rule bug or a display bug on the player's side. Fix it and report which it was.
   - Word "Setting Up" in rounds, with a countdown.
   - Add a checkpoint between phases (for testing).
   - Exclude Infrastructure from the Hedge Trimmer Guard's Mirrors, and log "Mirrors copied X".

## Part 5 — Quick wins (summary section 3)
Do every quick win in section 3 **except** these, which are on hold for the overnight story and balance pass:
- the story line edits;
- Tidy-Bot balance;
- the Gallery Echo cards.

Also fix the two failing GUT scripts (Bestiary entries for the eight S-GALLERY foes; `test_polish_chests` expected quest gold).

## Finish
- Run all test shards green.
- One fresh-eyes critic (no context) plays a new save for 60 minutes from the title. Report whether it reaches its Path's gatekeeper and what stopped it.
- Write docs/overnight_report.md: per-part results, screenshots, the re-sim numbers, and anything not done.
- Commit and push. No export.
