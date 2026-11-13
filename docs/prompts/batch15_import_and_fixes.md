# Batch 15 import, the owner's answers, the in-game leftovers, and the 1.0.0 build

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). Read the top of docs/overnight_report.md and docs/overnight_inbox.md
("Fable Nov 12d" and "Dialogue Nov 13") first. Log questions under "Batch 15 + 1.0". Tag `pre-batch15-import` at the start.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`. If the low-memory guard stops a background test run, finish it in the foreground with `--from=N --to=K`.
- Commit and push after each part. No public upload.
- Shots go in docs/overnight_shots/batch15/.
- **Owner constraints:** no difficulty setting; no battle-board or menu layout changes; Primm's fight unchanged.

## Part 1 — Import Batch 15 (39 images; the owner approved all of them)
The images are already in their Approved folders on the Drive. The replaced originals are in `Superseded/Batch 15 replaced/`. Import them with the usual importers, one Godot at a time, and wire each one in:

| Images | Approved folder | Where it goes in the game |
|---|---|---|
| CAP-SHEET-WINDOWS-07 / -08 | Approved_ZoneKits/Capital | The Capital's windows: -07 by day; -08 (lit) at dusk and in the freed city after Primm |
| CAP-BANNER-FREED-01..04, CAP-BD-LANTERNS, CAP-FX-FIREWORKS | Approved_ZoneKits/Capital | The freed Capital after `primm_defeated` only. Banners in a row; the lanterns rise slowly; the fireworks are a soft, occasional effect, off in reduced-motion and on Low-end |
| CAP-PROP-PORTRAIT-PRIMM-01..03 | Approved_ZoneKits/Capital | Replace the easel "smiley" portraits (keep the smiley emblem elsewhere) |
| CAP-PROP-RUBBLE-ROW | Approved_ZoneKits/Capital | Along the Capital's rim and the Transit Yards, to hide edges |
| BUFF-PROP-STALL-01 / -02 | Approved_ZoneKits/Buffet | Buffet hub market stalls |
| DNA-PROP-SERVING-ORB | Approved_ZoneKits/DNA | The D.N.A. queue / "now serving" spots |
| DUMP-HERO-RACCOON-STATUE | Approved_ZoneKits/VerdantDump | The Dump hub, wherever the art list's row names (a landmark) |
| DUMP-PROP-MILL-SAILS | Approved_ZoneKits/VerdantDump | The mill's sails, **spinning slowly** |
| GAIN-GROUND-MAT | Approved_ZoneKits/Gainlands | Replace the gym-mat tiling texture |
| ICON-EQ-HALLPASSSLIPPERS, ICON-GEAR-EARNEDBLADE | Approved_Icons | The Hall Pass Slippers and Earned Blade icons (replace the placeholders) |
| MAP-S-GALLERY | Approved_Maps | The Shattered Gallery's dungeon map. Re-check that every node sits on the new map's paths and move node positions to match |
| MG-BG-MATCHTABLE, UI-CARDBACK-DEX | Approved_UI | Dex's matching game: the table background and the card back |
| UI-BATTLE-ITEMSLOT-EMPTY / -READY | Approved_UI | The battle item slots, inside the existing slot rect (no layout change) |
| UI-PACK-LOCKED-B / -G / -N / -R | Approved_UI | The locked state of the Path packs on the Card Packs page |
| UI-NODE-BANNER | Approved_UI | The base of the non-combat pop-up banner (`NodeCard.BANNER_ART_ID`), under the per-kind wash and icon |
| NPC-HESPER, STORY-EPI-WRINKLES | Approved_Characters, Approved_KeyArt | Replace the old art, and **remove the code recolour stopgap** for the cross |
| V-FIGSLY | Approved_Characters | His vendor portrait (two arms now) |
| STORY-CREDITS-PANORAMA | Approved_KeyArt | Behind the credits scroll (slow pan); the text stays readable |
| SPR-ELOWEN-FRONT / FRONTSIDE / SIDE / BACKSIDE / BACK_WALK | Approved_Sprites | See below |

**The locked packs:** the -N and -R packs both came back with green seals. Check each locked pack against its unlocked pack's colour. If one is off, tint its seal in code to match, and log it.

**Elowen's walk:**
- Each sheet is 4 frames in one row (1536x1024), in the same format as the townsfolk walkers (SPR-TOWNSFOLK-A-*_WALK). Build her walk animations the way the walkers' are built: the same frame rate, mirroring for the right-facing directions, the `_n` normal maps, and the same scale as her existing SPR-ELOWEN idle.
- **At the intro, when she walks away, she plays the walk in the right direction for her path, and switches back to idle when she stops.**
- Do the same wherever else Elowen moves in a scene: the Lab, her rescue, the epilogue.
- Screenshot frames of the intro walk at the default and Low cameras.

**For every image:** mark its row in docs/art/batch15_nov12.csv "In game" and screenshot it in the game. Report the size change against docs/build_size_policy.md.

## Part 2 — The owner's answers (apply)
**Fable Nov 12d:**
1. Fig Sly's label "Fig Sly - Black Market": **keep.**
2. The Crease's arrival line: **keep.**
3. Maren's first-meeting speech: **keep it as the cave-mouth welcome.** Move her one line "I am Elder Maren" (her introduction) into the welcome so the player learns her name from her.
4. Tall pieces drawn 1.3 times further: **keep.** Re-measure the Capital on Medium; if it's under 60 FPS, drop to 1.2 times.
5. New Game with an empty profile: **skip the slot grid** and go straight to the story when no save exists.

**Dialogue Nov 13:**
1. Fig Sly's lines stay locked.
2. Bertram keeps his clipped deadpan. Put his old clipped lines back where the reader preferred them, and keep the rest short.
3. Keep the redistributed verbal habits.
4. Fix the exporter's speaker labels (Dex's `cardsharp.*` lines, "(check key)", the old Escoffina name), and teach it where the tutorial hints live so they're exported in the next workbook. **Don't rewrite** the hints now.

## Part 3 — In-game leftovers (do as many as fit, in this order)
1. **The Dump's south-east and south-west corners:** close the ravine rim from behind, or hold the camera inside, so no pale wedge shows.
2. **The Tidy-Bots:** a clear tell before a roaming hit (a wind-up flash or sound), and make sure the arrival grace period applies on a real entry.
3. **The Crease's east wall:** keep the camera from being filled by the wall when the hero hugs it (camera collision or a soft pull-in).
4. **The Wanderer's dialogue portrait** has a hard vertical edge on its right. Feather or crop it in code.
5. **The Capital's world map:**
   - district names;
   - the Crease drawn as its own inset, not piled in a corner of the surface map;
   - labels that don't stack.
6. **The minimap:** sharper in the forest, less blocky in the Capital (render resolution or filtering).
7. **Crosspath's south mist band:** soften it into a natural edge (a hedge, a fence line, a treeline from the kit).
8. **The D.N.A.'s bare grey apron:** dress it lightly with kit props and decals (filing carts, paper drifts, queue posts, the serving orb).

## Part 4 — Fresh eyes on the screens nobody has checked
A no-context critic, **starting from snapshots** (not the New Game flow, which ate its last runs), looks at:
- the shrine and the Hollow Well pop-ups;
- the "Before the fight" panel;
- the Cave Warden's closing words;
- the first exit into Crosspath, and Maren;
- the Black Market screen with the new Fig Sly;
- the Transit Yards;
- Elowen's intro walk;
- the freed Capital (banners, lanterns, fireworks);
- the credits with the panorama.

It scores clarity and polish and lists its top 10. Fix the S/M items.

## Part 5 — Tests and the 1.0.0 build
1. All test shards green.
2. Set the version to **1.0.0**, then update CHANGELOG.md and docs/release/ (the release notes).
3. **The export:**
   - wait up to 10 minutes for at least 2.2 GB free RAM;
   - in the **foreground**, run `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0`;
   - then the exported release smoke, `tools/export_test_pack.sh` and the three `play_exported.sh` checks (0 SCRIPT ERROR each).
   - If memory never frees up, don't start: put the exact commands at the top of the report.
4. **docs/overnight_report.md**, with at the top:
   - the import table, with shots (Elowen's walk included);
   - what was done from Parts 2-4;
   - the critic's top 10;
   - the size;
   - where the 1.0.0 zip is, or the commands;
   - the itch upload checklist.
5. Commit and push. No public upload.
