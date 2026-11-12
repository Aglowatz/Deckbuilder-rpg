# Fable Nov 12: owner's fix list, non-combat pop-ups, the Crease, the 3D world pass, RC6

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). This prompt **replaces** docs/prompts/fable_nov12_final.md. It keeps that file's Part 1 (the world pass) and its Batch 15 import, and puts the owner's new list first.

Read first:
- the top of docs/overnight_report.md;
- docs/overnight_inbox.md, "Fable Nov 12";
- docs/art/style_bible.md.

Work autonomously. Log questions under "Fable Nov 12c". Tag `pre-fable-nov12c` at the start.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:**
  - ONE Godot at a time; no sub-agents while Godot runs;
  - use `tools/run_tests.sh --min-free=900`;
  - before any export, wait until free RAM is at least 3 GB. If it isn't, log it and leave the exact command for the owner.
- Commit and push after every part, and at least every 90 minutes. No public upload.
- Before/after screenshots for every visible change go in docs/overnight_shots/nov12c/. Add tests for every rule change.
- **Owner constraints:**
  - no difficulty setting;
  - **the battle board and the other menus keep their layout.** The owner has explicitly opened up two things: the non-combat dungeon pop-ups and the pre-fight rules panel (Part 2). Redesign those freely.
  - **No new art**, except the two images the owner is making in ChatGPT (Part 2 and A7). Both must work without them first.
  - Medium holds 60 FPS (the Capital included); Low keeps its numbers; the zip grows at most ~10%.

## Owner decisions from inbox "Fable Nov 12" (apply)
| Item | Decision |
|---|---|
| 1, 2, 3, 4, 5, 6, 7, 8, 12 | Keep as built. |
| 11 | Do two of the three: (a) a dungeon room's type shows one step ahead; (b) every level-21+ castle fight's three reward cards include at least one Uncommon or better. |
| Primm | The defeat flow changes; see A9. His fight itself is unchanged. |

## Part A — The owner's fix list (do all of it first, in this order)

### A1. The Hollow Well in the tutorial cave: a sacrifice for healing
Replace the current Hollow Well with this rule: **"Sacrifice a random card from your deck for the rest of this dungeon: heal 4 HP."**
- The card is picked at random from the dungeon deck. It's gone for the rest of this run and returns to the deck when the dungeon ends (win, loss or leaving). Nothing is lost permanently.
- After the choice, show the sacrificed card face up in the pop-up: "The well takes **Card Name**. It returns when you leave the cave."
- The player can **decline** ("Leave it").
- If HP is full, the offer still shows, but the button reads "You're at full HP" and is disabled.
- It can't take a card if the deck is at the game's minimum dungeon deck size. In that case, explain why.
- **Once per dungeon run.** Wording and the tutorial hint stay consistent with this (no "losing costs nothing" style claims).
- Make it work in the save/resume flow.
- Tests:
  - random pick, heal 4 (capped at max);
  - the card is back after leaving, losing or clearing;
  - decline;
  - full HP;
  - the minimum deck size;
  - save and resume mid-dungeon.

### A2. The Cave Warden's closing words show his picture
After the Cave Warden (tutorial boss) fight, his closing dialogue shows his portrait, like every other speaker. Use the existing art: NPC-WARDEN, or CUT-WARDEN if that's the cut-out used in dialogue. Check every boss's post-fight lines for the same gap and fix any you find.

### A3. Deck copies text
Find every place that says a deck can hold **4 copies** of a card: tooltips, the glossary, tutorials, the Deck Station, dialogue, the rules doc, the itch page text. Change it to the true rule: **"You can have up to 3 copies of any one card, depending on your level."** Check the actual per-level limits in code and word any tooltip that names numbers to match them.

### A4. First exit from the tutorial cave
On the first exit into Crosspath:
- the player stands **just left of Elder Maren**, facing the square;
- no building is faded or hidden at the spawn point or while the camera settles.

Make sure the occlusion fader doesn't trigger there (move the spawn, or exclude those buildings near the spawn). Screenshot it at the default and Low cameras.

### A5. Chef Fennel Gravois's snack
The snack token he creates is a 0/1, but the rules text says 1/1. **Make the token a 1/1, as the text says.** Check every other "create a token" card and effect in the game for text-versus-token mismatches, fix any, and add a test that checks token stats against their creating text where the text states numbers.

### A6. The Capital's floating grey rectangles
The outer edges of the Capital (and the Transit Yards, the Reek and the wall approaches) show floating flat grey boxes and slabs. Replace every one with set dressing that fits the ruined wasteland aesthetic, from the existing Capital kit:
- **The kit:** CAP-SHEET-RUBBLE, CAP-WALL-RUIN, CAP-WALL-ASH, CAP-ROOF-BROKEN, CAPI-PROP-STATUE-FALLEN, CAP-PROP-PRIMM-STATUE-SIDE, CAP-TREE-DEAD, CAP-PLANT-CRYSTAL, CAP-DEC-ASH, and the backdrop cards.
- **The look:** dilapidated building shells with broken roofs, toppled statues, rubble mounds, dead trees and crystal growths, at believable scale, standing on the ground (none floating). Use fog and backdrop cards to close the distance.

Use the `matscan` and `groundscan` driver commands to find every box. Then screenshot each Capital district at the default and Low cameras, before and after.

### A7. Fig Sly: art and the dual-colour dots
1. **His art:** the vendor portrait V-FIGSLY has an extra (third) arm. The owner is making a replacement in ChatGPT, landing in Pending Review/Batch 15 as `V-FIGSLY.png`. Import it when it lands (Superseded gets the old one). Until then, change nothing.
2. **The dots:** dual-colour (multi-Path) cards show small coloured dots just below the card name. **Remove those dots from every card in every view:**
   - in hand and on the board;
   - the full-size view and tooltips;
   - the shops, the Deck Station, the collection, the reward screen and the pack opening.

   The Path cost icons on the top right stay. Screenshot a multi-Path card in each view.

### A8. The Crease / the Black Market: underground and findable
1. **Rebuild the area so it reads as entirely underground and enclosed:**
   - rock or cavern walls on every side;
   - a low rock ceiling or overhang so no sky shows;
   - no castle backdrop;
   - warm lantern pools and a few cool crystal or rift glows;
   - dripping stalactites;
   - crates and stalls for the market;
   - a damp stone floor with puddles.
2. **Remove the four black doorways.** Keep the Rift Station as the way in and out. Keep Fig Sly, Kestrel and every NPC and service reachable, and move them into the new layout so they're visible and not hidden behind props.
3. **Make the quest that leads players to the Crease prominent, so every player finds it:**
   - it's offered automatically or very visibly when the player first reaches the Capital;
   - it shows on the tracker, has a map pin and appears in "Point me to...";
   - its first step's "Where to go" line names exactly how to get there.

   If it's currently a side quest that's easy to miss, make it a step of the Capital's main line, or give it the YOUR PATH line until it's done. Log which you did.
4. **Fix the duplicated "Services restored: 0 of 4" bars.** The HUD shows two identical bars; show one.
5. Walk the area with the driver: no voids, nothing hidden, the NPC visibility probe passes.

### A9. Losing to Primm: restart the fight or leave
When the player loses to Primm in **any phase**, the defeat screen offers two choices:
- **"Fight Primm again"**: restart the fight from the very beginning of Phase 1, with full HP and the leaders' boons as on a normal arrival at his room. The castle's earlier rooms are not replayed.
- **"Leave the castle"**: the normal dungeon-leave behaviour.

The rest of Primm's fight is unchanged. Update the defeat text, the tests and the late-game docs.

### A10. Inbox 11 (a) and (b)
Implement both, as in the decisions above, with tests.

## Part B — The non-combat dungeon pop-ups: a vastly better look (the owner's priority)
**Scope:** every non-combat node pop-up:
- the healing shrine / rest (e.g. "Whispering Shrine");
- the Hollow Well;
- events, treasure, rescue and challenge intros;
- any other non-fight node;
- the **"Before the fight" rules panel**, which is sparse today: a big empty box with one icon and a line.

The current pop-ups are a flat purple box with a small flat cyan clip-art icon, plain text and a bare HP bar. Make them feel like a premium, illustrated moment, using only existing art, shaders and code:

1. **Layout:**
   - a two-part card: a wide **illustration banner** across the top, then a parchment or vellum body under it;
   - the existing ornate gold frame;
   - a title plate with the node type in small caps above the name (e.g. "SHRINE · Whispering Shrine").
2. **The illustration banner, with no new art yet:**
   - build it from what exists: the dungeon's own map art (MAP-*.webp) cropped and blurred around this node's position, plus a vignette and a soft colour wash per node type;
   - the large existing node icon (ICON-NODE-HEAL / EVENT / TREASURE / RESCUE / CHALLENGE and so on) centred with a glow and gentle bob, replacing the flat cyan silhouette;
   - drifting particles that fit the type (motes for a shrine, mist for a well, sparkles for treasure).
3. **Text:**
   - the flavour line in italic, then a clear separate line saying what it does mechanically, with icons ("Heal to full HP", "Heal 4 HP · lose a random card for this dungeon");
   - good type hierarchy and spacing, with no orphan words on their own line.
4. **The outcome preview:**
   - the HP bar shows the heal as a ghost segment and the before → after numbers ("HP 9 → 15");
   - at full HP, say so plainly;
   - for a choice with a cost, show the cost as a small chip.
5. **Choices as buttons with icons:** a primary and a secondary button (e.g. Rest / Leave it), consistent across all node types. Esc means "Leave it" where leaving is allowed.
6. **Motion and sound:**
   - the pop-up scales and fades in over ~0.25 s, the banner a beat later;
   - the confirm plays a short effect (a heal shimmer over the HP bar, the well swallowing the card);
   - use existing SFX on open, confirm and close.
7. **The pre-fight panel:**
   - the same frame and banner, using the enemy's bestiary portrait or cut-out when it has one;
   - the rules as rows of icon + name + one-line text;
   - Hidden trait shown as a "?" row with its explanation;
   - no big empty space.
8. **One optional generic art asset:** the owner may provide `UI-NODE-BANNER.png` (a generic painted dungeon alcove at 1600x500) in Pending Review/Batch 15. If it lands, use it as the banner base under the per-type wash and icon. Everything above must look finished without it.

Screenshot every pop-up type before and after at 1280x720 and 1920x1080, with Large text, and with a controller (it must be fully pad-usable).

## Part C — The 3D world, everything code can fix
Do Part 1 of docs/prompts/fable_nov12_final.md **in full** (items 1-12):
1. contact shadows;
2. blended ground and less obvious tiling;
3. the shared water shader;
4. map edges and voids;
5. stray quads and foreground obstructions;
6. duplicate and broken sprites;
7. the Transit Yards ghost buildings;
8. faceted props;
9. the measured scale table;
10. hub storytelling clutter;
11. light sources and per-zone grades;
12. the world motion list.

A6 above already covers the Capital's grey boxes; do the same kind of scan in every other zone. Measure FPS on Medium and Low after items 2, 3 and 11.

## Part D — Import Batch 15
Check `G:/My Drive/Card Game Art/Pending Review/Batch 15/` at the start of each part. When files land, import them as Part 2 of fable_nov12_final.md describes, plus `V-FIGSLY.png` (A7) and `UI-NODE-BANNER.png` (Part B). Mark the CSV rows "In game" and screenshot each one. Add a V-FIGSLY row and a UI-NODE-BANNER row to docs/art/batch15_nov12.csv.

## Part E — Verify and build RC6
1. A quick no-context playtest of the tutorial cave through to Crosspath (the Well, the Cave Warden ending, the first exit), and a Capital pass (the Crease quest, the Black Market, the edges). It lists anything still wrong; fix the S/M items.
2. All test shards green.
3. **The export:**
   - wait for ≥3 GB free;
   - `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc6`;
   - the exported smoke and the three `play_exported.sh` checks with 0 SCRIPT ERROR;
   - docs/release/rc6_notes.md.
4. **docs/overnight_report.md**, with at the top:
   - A1-A10 done, with before/after shots;
   - the pop-up redesign gallery;
   - Part C done / not done with FPS;
   - the Batch 15 import table;
   - where RC6 is;
   - the final 1.0.0 release checklist.
5. Update docs/HANDOFF.md and docs/release/post_1_0_backlog.md.
6. Commit and push. No public upload.
