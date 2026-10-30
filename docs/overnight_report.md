# Report - art import Oct 29 (art batches 5-9) + v0.4.7 candidate

Thu Oct 29, 14:50 - ~19:00 MDT (Opus). Tag `pre-art-import-oct29`. State `docs/overnight/loop_state.md`; import log `docs/art/import_oct29.md`;
status `docs/art/art_status_oct29.csv`; questions `docs/overnight_inbox.md` ("Art import Oct 29", items 1-8). Last night's report:
`docs/overnight/oct28/overnight_report_oct28.md`. Dialogue freeze respected (no dialogue file or key touched; the new stills need no text).
No image generated; Pending Review / Superseded / Replaced Artwork never read; the Drive only copied from; black market untouched.

## Read this first

- **Everything delivered is in the game, nothing needs a redo**: 78 rows In Game, 12 portrait-expression rows Skipped by design, 0 redo.
- **v0.4.7 candidate is built, not shared**: `builds/TheWaywardPath-v0.4.7-windows.zip`, **762 MB** (798,308,713 bytes; under the 850
  line). Release smoke on the exported pack with D3D12: **Medium PASSED, Low PASSED**. Tag `v0.4.7`. Notes `docs/release/v0.4.7_notes.md`.
  **Flag:** the pack inside is 852 MB, over the project's 800 MB export budget (`CLAUDE.md`); the zip is fine.
- The 15 new stills have no captions of their own (freeze): each plays **behind its scene's own narration** (inbox 2).
- Old Hob moved 1.4 m north: the hub walk smoke passes now.

## By part

| Part | Commit | What |
|---|---|---|
| 0 Inventory | 8ead7f6c | 86 / 86 files present and sound (full decode, sizes, alpha, edges); contact sheets; assets/art 447 MB before |
| 1 Story stills | 8ead7f6c | 15 rows in `logo_title_art.csv`, `import key art`; `StillBackdrop` + `StoryStills` maps for cutscenes, ending beats, story scenes, memories; `scenes/dev/still_gallery.tscn` |
| 2 Cards / icons / hat / sprites | 5ba61b8d | 16 card art (356 / 356 have art; N-10 replaced); 4 relic icons; 8 feat icons wired into Menu > Feats and the toast; Leaf Crown re-fit (hand fit); DUMPWORKER + PRIMM sets |
| 3a Forest / Crosspath / Gainlands | 2cfa186f | kit rows + imports for all zones; cave mouth, giant trees, torch line, Lab hatch; painted fountain, freed banners, horizon; hamster wheel, sky islets, posters, House of Gains |
| 3b D.N.A. / Buffet / Dump / Capital | bedd13ff | hall facade, filing towers, ghost queue, lamps, topiary, forms; cake cathedral + Test Kitchen strips, tasting stands, rosettes; Rotheart sky strip, junk mountain, throne dumpster, pennants, corruption; wall + castle strips, gold / fallen statue, lost-property notices, rifts + sealed stones, white path |
| 4 Old Hob | 44736f1e | one step off the D.N.A. road's line; no dialogue change |
| 5 Verify | 148b6541 | bots, smokes, budgets, status CSV |
| 6 v0.4.7 | d90e6c20 + tag | bump, guarded export, exported release smoke Medium + Low, notes |

## What's in game (where)

Full table per ID: `docs/art/art_status_oct29.csv`; per zone: `docs/art/import_oct29.md`. Short version:

- **Stills** behind: wonder / vacancy / sever / primm_intro / primm_reveal cutscenes; ending beats throne and facade; pc_capture, lab_cell4,
  royal_funeral, isla_homecoming; memory fragments 1-4.
- **Cards** everywhere a card shows; **relic icons** on the character screen, armory, reward box; **feat icons** on the Feats page and toast.
- **Leaf Crown** on the hero in all five directions; **farmhands** in the Dump; **Primm** in the Crease after the ending.
- **Zones**: see Part 3 tables in the import log.

## Needs a redo

None. Things to look at (not art problems): the backdrop strips mostly sit above the play camera (inbox 3); the throne dumpster is mostly
behind the raccoon king (inbox 4); unused sheet parts listed in inbox 5.

## Screenshots (`_screenshots/oct29/`)

| Area | Files |
|---|---|
| Review sheets | `review_story.png`, `review_small.png`, `review_zone.png` |
| Story stills | `stills.png` (all 15 in place), `still_story-*.png` |
| Cards / feats / hat | `cards_new.png`, `feats.png`, `hat_leafcrown.png` (auto fit), `hat_leafcrown_fit.png` (final) |
| NPC sprites | `p2_primm_crease.png`, `p2_dump_worker.png` |
| Opening Forest | `before_forest.png`, `after_forest.png`, `p3_forest_cave.png` |
| Crosspath | `before_town.png`, `after_town.png` (banners forced on) |
| Gainlands | `before_gainlands.png`, `after_gainlands.png`, `p3_gain_hall.png` |
| D.N.A. | `before_dna.png`, `after_dna.png`, `p3_dna_lobby.png` |
| Buffet | `before_buffet.png`, `after_buffet.png`, `p3_buffet_stands.png`, `p5_buffet_stands.png` |
| Verdant Dump | `before_heap.png`, `after_heap.png`, `p3_heap_throne.png`, `p5_heap_throne.png` |
| Capital | `before_capital.png`, `after_capital.png`, `p3_capital_statue.png` |

## Size and fps

- `assets/art` 447 -> 475 MB on disk. Export payload 850 MB (pck 852 MB, budget 800); zip 762 MB (v0.4.6: 690 MB).
- Medium average frame 12.0-15.7 ms in every 3D area (63-83 fps); Low 7.8-12.7 ms; battle 2.9 ms; menus 5.7-8.1 ms. Structure budget OK.
  p99 marks noisy as last night; the Capital outskirts Medium p99 (27-32 ms vs 24.3) is over with and without tonight's changes (A/B).
- Memory round-trip: flat (static +0.9 MB, video -0.1 MB, objects +28 over 10 trips).

## Checks run

GUT root 286, core 1490 + 1 pending, ui 242, world 422; tour bot 281 spots / 0 errors; story bot 90 / 90; walk smokes Crosspath, Gainlands,
D.N.A., Buffet, Dump, Capital, hub OK; prologue, first battles, gamepad OK; exported release smoke D3D12 Medium + Low PASSED.
Tests changed with intent: the Buffet / D.N.A. skyline tests (new strips), the sprite-rollout test (Primm now has a set), the D.N.A.
clutter cap 40 -> 50 (inbox 6).

## Inbox (Art import Oct 29)

1. Row numbering (#87-164 vs CSV rows 75-164). 2. Stills without captions. 3. Backdrop strips above the camera. 4. Throne dumpster placement.
5. Unused sheet parts. 6. D.N.A. clutter cap. 7. Capital outskirts p99 (pre-existing). 8. Feat icons for ten groups from eight pictures.
