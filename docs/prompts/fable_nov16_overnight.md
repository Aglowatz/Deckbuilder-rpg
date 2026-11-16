# Overnight Nov 15-16 (Fable): Batch 16 import, the open issues, a fresh-eyes playthrough, 1.0.0

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner is asleep.

Read first:
- the top of docs/overnight_report.md (Fable Nov 15b, then Nov 15);
- docs/overnight_inbox.md ("Fable Nov 15b", "Fable Nov 15", "Fable Nov 14");
- docs/art/batch16_nov14.csv;
- docs/art/path_icon_style_guide.md.

Run `git status` first; if anything is uncommitted, run the tests and commit it. Log questions under "Overnight Nov 16". Tag `pre-overnight-nov16`. Work in this order; it's the priority order.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`. If the guard stops a background run, finish it in the foreground with `--from=N --to=K`.
- **Tests must never write the player's real save or autosave** (see Part 3.1).
- Commit and push after each part. No public upload.
- Before/after shots in docs/overnight_shots/nov16/.
- **Owner constraints:**
  - no difficulty setting;
  - no battle-board layout changes;
  - Primm's fight unchanged;
  - approved art is not repainted.

## Part 1 — Import Batch 16 (46 images; the owner approved all of them)
The images are in their Approved folders on the Drive, named as in docs/art/batch16_nov14.csv. The replaced originals are in `Superseded/Batch 16 replaced/`.

| Images | Approved folder | Wire in |
|---|---|---|
| V-FIGSLY | Approved_Characters | Fig Sly's shop portrait and his dialogue portrait. **Screenshot both and count the hands: two.** |
| STORY-MEMORY-3, STORY-MEMORY-4, STORY-REUNION, STORY-EPI-FILE-COMPLETE | Approved_KeyArt | Their story scenes (Path icons fixed) |
| NPC-SCUFF, CUT-SCUFF, BST-ENFORCER-SERGEANT-SCUFF | Approved_Characters, Approved_Bestiary | Sergeant Scuff's dialogue portrait, boss cut-out and Bestiary square, replacing the Correction Officer stand-in |
| UI-CARDBACK-B, UI-CARDBACK-N | Approved_UI | The Beefcake and Necrocrat card backs |
| ICON-FEAT-PATHS | Approved_Icons | The Path feats badge |
| DEC-PLINTH-BEEF / GOUR / REF / NECRO | Approved_EnvKit | The four Path plinths (same size, swap in) |
| TOWN-SHEET-FREED-BANNERS-01..06 | Approved_EnvKit | Crosspath's freed banners: 01-04 one per Path, 05-06 the four-icon ring |
| CAP-BANNER-FREED-03 / -04 | Approved_ZoneKits/Capital | The freed Capital's Refusemancer and Necrocrat banners |
| LOGO-EMBLEM, LOGO-WORDMARK, APP-ICON | Approved_KeyArt | The title screen, the credits, the **Windows export icon** (`.ico` in the export preset), the itch page kit (docs/release/itch_page/) and anything else that uses the logo |
| TOWN-PROP-SHORE-STONES-01..03 | Approved_EnvKit | Crosspath's lake bank, replacing the textured-block river stones |
| CAP-PROP-CREASE-STALL-01 / -02, CAP-PROP-CREASE-CRATES | Approved_ZoneKits/Capital | The Crease market: Fig Sly at stall 01, replacing the flat boxes |
| SPR-RESCUER-*_WALK (5) | Approved_Sprites | The Rescuer's walk wherever she moves, built like Elowen's walk (mirroring, normal maps, scale) |
| NPC-QUADZILLA, NPC-CAIRN | Approved_Characters | Those bosses' dialogue portraits |
| DNA-PROP-CRATES, DNA-PROP-CABINET-TIPPED | Approved_ZoneKits/DNA | The debris outside the D.N.A. (with the Capital wasteland kit) |
| UI-PACK-GILDED-G / -N / -R, UI-PACK-N, UI-PACK-R | Approved_UI | The gilded packs per Path and the Path packs. Remove the code overlay that drew the canonical icon over the old paintings, where the new art already shows it. Check each medallion is whole and centred |

**For every image:**
- run the importers one Godot at a time;
- mark the CSV row "In game";
- screenshot it in the game;
- check it against the Path icon style guide.

Report the size change against docs/build_size_policy.md.

## Part 2 — The items still open from earlier passes
Go through the reports and inboxes from Nov 13 to Nov 15 (batch15_import_and_fixes Part 3, the Nov 14 and 15 passes). Finish anything still open on this list, and log anything that turns out to be done already:
1. **The Verdant Dump's fair stage** on the farm terrace (beside the trash chute): its plain-colour banner and the four flat sorting bins get re-dressed from the Dump kit (painted cloth flags, scrap-wood bins, signs without text).
2. The Dump's two south corners (no pale wedge at the default or Low camera).
3. The Tidy-Bots get a clear tell before a roaming hit.
4. The Crease's east wall doesn't fill the camera when the hero hugs it.
5. The Wanderer's dialogue portrait loses its hard right edge.
6. **The Capital's world map:**
   - district names;
   - the Crease as its own inset;
   - labels that don't stack.
7. The minimap is sharper in the forest and less blocky in the Capital.
8. Crosspath's south mist band becomes a natural edge.
9. The Capital's later-visit load time (about 6 s): cache what's still rebuilt and report before and after.

## Part 3 — Reliability
1. **Tests and the player's saves:** an earlier run's tests overwrote the owner's campaign 1 autosave, and the Nov 15b run nearly did it again.
   - Make it **impossible**: in test mode, the save system writes only to a temp folder (e.g. `user://test_saves/`), whatever flags are passed.
   - Add a test that fails if a test run touches the real save folder.
   - Document it in docs/HANDOFF.md.
2. **Run the full suite** (all shards) at least once after the last change of the night, not just the touched files.

## Part 4 — A fresh-eyes playthrough of the exported build
Export a test build first (the same way as 1.0.0), then send a no-context critic (no repo or report access) through it in three sittings, starting from snapshots where needed:
1. **The first hour:** new game, the cave (the Well, a shrine, the pop-ups), the Cave Warden, Crosspath, the first quests, the first Path zone.
2. **The midgame:**
   - one full Path zone to its main dungeon and boss;
   - Fig Sly's shop (cards, items, packs, the scrollbar);
   - the Deck Station;
   - Dex.
3. **The late game:**
   - the Capital, "Under the Capital" and the Crease;
   - the service tunnels with Sergeant Scuff;
   - Primm (including "Fight Primm again");
   - the ending and credits;
   - the postgame start.

For each sitting it scores clarity, fun and polish (1-10) and lists **anything broken, confusing, ugly, inconsistent with the story** (Maren's eyes and her castle past, the bars not glass, Tessar) **or using a wrong Path icon**. Fix every S item and as many M items as fit; log the rest.

## Part 5 — Batch 17 (prepare only)
Create docs/art/batch17_nov16.csv and docs/prompts/chatgpt_batch17.md (the same format as Batch 16, references numbered by item and copied to `G:/My Drive/Card Game Art/Batch 17 References/`). Include:
- the five ruler statues (Clench, the Grand Chef, Mortimer, Compostella, Primm), each standing and toppled, in stone, on the existing plinths;
- anything the Part 4 critic found that only new art can fix;
- anything else still marked REDO.

Keep it under 25 items.

## Part 6 — Build 1.0.0 and report
1. All test shards green.
2. **Export 1.0.0:**
   - wait up to 10 minutes for at least 2.2 GB free RAM; if it never frees, use `EXPORT_LOW_MEMORY_OK=1` as before;
   - in the foreground, run `bash tools/export_windows.sh 1.0.0`;
   - then the exported smoke and the three `play_exported.sh` checks (0 SCRIPT ERROR).
3. Update the itch page kit (docs/release/itch_page/) with the new logo, icon and fresh screenshots of the improved areas, and the release checklist (docs/release/).
4. **docs/overnight_report.md**, with at the top:
   - the Batch 16 import table with shots (Fig Sly's two hands included);
   - Part 2, done or not;
   - the save-safety fix;
   - the critic's scores and top issues per sitting, with what was fixed;
   - the Batch 17 list;
   - where the zip is;
   - **what the owner must still do before uploading.**
5. Commit and push. No public upload.
