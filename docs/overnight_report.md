# Overnight Nov 9-10 (Opus) - report

Brief: `docs/prompts/overnight_nov9_opus.md`. Start tag `pre-overnight-nov9b`. Questions: `docs/overnight_inbox.md`, "Overnight Nov 9-10".
Shots: `docs/overnight_shots/nov10/`. One Godot at a time; no sub-agent ran while a Godot of mine did (the two critics were the only Godot
while they played). The Fable Nov 9 report follows below.

## At a glance

- **RC2 is built:** `C:\Dev\Deckbuilder-rpg\builds\TheWaywardPath-v1.0.0-rc2-windows.zip` (**734 MB**, next to RC1's 736 MB). Release smoke on
  the exported pack **PASSED 17/17**; the exported-build checklist (runs A and B) and a Low-end walk all fine, 0 SCRIPT ERRORs. Notes for
  testers: `docs/release/rc2_notes.md`.
- **Fixed tonight (with shots below):** 17 critic findings across the three reviews - the bright forest, the textured fountain, the cave flood
  guard, the attack-aware end-turn question, "Point me to...", the Path choice strip, Primm's opening army (4 -> 3 Militia) and countdown,
  no cut-outs over stills, Basil, the Buffet hints, and smaller text fixes. Plus the Text size switch and the key-rebinding guard.
- **The critics' top 10s:** Part 2 below (midgame: clarity 5, fun 4, polish 6; late game: clarity 5, fun 4, polish 5). Both lost the hard
  fights they met at the recommended level; the late critic could not beat Primm in six tries, which is why his first phase is easier now.
- **The dialogue tool:** Part 3 below, in plain steps (three commands; tested on ten fake edits, then the test files were deleted).
- **Accessibility and controller:** a single Text size switch, Large checked at 1280x720; every menu and all ten minigame screens walk with a
  pad only (tests + the gamepad smoke, 540 pad events, 0 key/mouse); rebinding can no longer leave Move / Interact / Pause without a key.
- **Size and performance:** Low-end on the exported build runs at its 30 fps cap in Crosspath, the Capital and a battle (memory below). The
  pack has almost nothing unused left (0.8 MB found; the macOS icon and four orphan pictures removed, ~2 MB). The Capital's later visit is
  **6.1 s** (was 6.2 s): the remaining pieces were not cached tonight (reason and plan in Part 5).
- **Tests:** full suite in shards **2907 / 2909 passed, 0 failing, 2 risky** (the same two no-assert tests as before). New tests: flood guard,
  text size switch, key-rebind essentials, pad walks for the Wardrobe / Tailor / pack shop / nine minigames; the boss tempo test updated.
- **Before the public release, the owner should:** (1) play the RC2 zip once; (2) decide on Primm (inbox 4: 3 Militia, re-run the sim when the
  PC is free); (3) send `rc2_notes.md` + the Restricted itch link to playtesters; (4) when their workbooks come back, run the three dialogue
  commands (Part 3); (5) on release day: `config/version` to `1.0.0`, export, smoke, upload, flip to Public (`docs/release/itch_upload.md`).
  Decide later: the Capital caching (inbox 5), the battle board's infrastructure row and two-row hands (both critics), the Gainlands kit.

## Part 0 - the Fable pass

Nothing left: its report marks the import, RC1, the exported-build checks, the critic's quick fixes, the itch kit, the trailer and the
handover as done.

## Part 1 - the RC1 critic's findings (first hour)

| # | Finding | Effort | Done |
|---|---|---|---|
| 1 | Cave entrance trigger missable | S | fixed on Nov 9 (whole doorway answers E); the chest beside it can no longer steal the press (the gate wins inside 3 m) |
| 2 | First fights drag (8-11 rounds) | M | **Cave flood guard:** in the Forgotten Cave only, once you hold 5 infrastructure (play + hand) an infrastructure draw is swapped for the next non-infrastructure card (`GameOptions.flood_guard`, `FirstDuel.CAVE_FLOOD_GUARD`, test). Sims (60 runs per Path): the AI player clears the Scavenger in 2.9-4.1 rounds with or without it, so the critic's long fights were human floods; the guard caps them. The sim tool now prints rounds per node. |
| 3 | White fountain / plinth blocks in Crosspath | S | the fountain carries the painted stone-wall texture, tinted sandstone. Before `p1_fountain_before_rc1.jpg`, after `p1_fountain_after.jpg` |
| 4 | Near-black forest, heavy blur | S | `starting_forest.json`: key 0.42 -> 0.62, ambient 0.62 -> 0.92, exposure 1.05 -> 1.32, vignette 0.5 -> 0.36; tilt-shift halved. Mean brightness 26 -> 35 (+33 %). `p1_forest_before.jpg` / `p1_forest_after.jpg`. Camera zoom not changed (shared by every area). |
| 5 | Gainlands low-poly kit; fight starts with a toast | L | **L** - plan: run the painted-texture presets (as Crosspath) over the Gainlands ground and walls, and give roamers a first-meeting line. |
| 6 | "End your turn?" while picking attackers | S | asks "End the turn without attacking? You have N attackers selected..." instead |
| 7 | Esc does not close a shop | - | not a bug (Nov 9) |
| 8 | "Where to?" sets a goal | S | renamed "Point me to..." with a tooltip saying the arrow leads there after the map closes |
| 9 | Bark bubbles over name plates | S | fixed on Nov 9 |
| 10 | Path cards unreadable until More | M | the strip keeps the picked Path described after the pointer leaves, and shows its Resource on hover |
| notes | forest hint line lacked M: map | S | added |
| notes | stray glyph label in the dump | - | the font warm-up: a 3 x 3 px clipped label at 2 % opacity - invisible |
| notes | first-duel popups stack; level-up over the card reward; Esc during talk opens pause | M | kept: the tip already sits clear of the mulligan panel; the other two are in the backlog |

## Part 2 - exported-build checks of the mid and late game

Two fresh critics with no context, each given only its brief (`docs/review/critic_mid_brief.md`, `critic_late_brief.md`), played the
exported RC1 pack with snapshots to jump ahead. Reports: `docs/review/critic_mid_nov10/report.md` (42 shots) and
`docs/review/critic_late_nov10/report.md` (41 shots; saved by me - the harness would not let the agent write it).

**Midgame** (level-14 snapshot, the Endless Buffet and the Test Kitchen; ~30 min of game time, 16 runs): **clarity 5, fun 4, polish 6**. No SCRIPT ERROR.

| # | Problem (critic) | Sev. | Done |
|---|---|---|---|
| 1 | The Test Kitchen beat it three times at level 14; a loss restarts the dungeon | major | not changed (the pilot played; the level hints cover it); the defeat text no longer says "losing costs nothing" in a dungeon |
| 2 | Sir Loin's gate ingredients have no marker | major | the favour's hint names where the truffle and the salt are |
| 3 | Basil hidden behind the soup fountain; E at 2.3 m did nothing | major | Basil 3 m east, talk reach 1.8 -> 2.4 m |
| 4 | Huge milky fade polygons | major | not reproduced tonight (inbox 7) |
| 5 | Played infrastructure tiny; unit rows touch | major | L (battle board layout) - backlog |
| 6 | Old Hob's portrait stuck after a defeat | major | not reproduced tonight (inbox 7; in the RC2 known issues) |
| 7 | Zone counters disagree (4 of 4 after one boss) | major | likely the bot snapshot's flags + `dev win`; logged (inbox 7) |
| 8 | Meatballs knock 2 HP off on arrival | minor | the meatballs live far from the bridge; it was the snapshot's arrival spot. Kept |
| 9 | Map labels pile up; "The Beefcake Rift Express" in the Buffet | minor | the map now says "Rift Express station" |
| 10 | Small UI collisions (popups over the HP panel, clipped Open, tooltips) | minor | backlog |

**Late game** (level 20-24 snapshots, the Capital, Primm's Castle, six real Primm fights, the Lab; ~50 min, 25 runs): **clarity 5, fun 4, polish 5**. No SCRIPT ERROR.

| # | Problem (critic) | Sev. | Done |
|---|---|---|---|
| 1 | Primm is a wall: six phase-1 losses by round 4-5 (L20 and L24), "Militia dealt 36 of 39" | blocker | **Standing Army 4 -> 3 Militia** (inbox 4); the countdown fix below |
| 2 | `c13end` / `c13post` snapshots load before Primm | blocker (review only) | tooling: re-save them (inbox 6) |
| 3 | Speaker cut-outs pasted into stills that already show them | major | no cut-out over a painted still any more (the name plate stays) |
| 4 | Primm on "a sunny village" board | major | it is the Model Room's miniature kingdom (`BB-PC-BOSS`); kept, art question (inbox 8) |
| 5 | Rules contradict the screen (3/3 vs 7/4 hand cards; "Setting Up: 3 rounds" for a 2-round window) | major | the countdown never exceeds its window now (test); hand cards showing standardized stats is M - backlog |
| 6 | Invisible infrastructure, two-row hands | major | L - backlog (same as mid #5) |
| 7 | Tracker "1 done" | minor | "1 earlier step done (J: the full list)" |
| 8 | Template boss reward line | minor | Primm's node: "three duels in a row (56, 52 and 50 HP), your HP carried between them. At stake: the kingdom." |
| 9 | Dialogue: skip prompt repeats its title; two box styles; Esc opens pause on first lines | minor | the prompt reads "Skip this scene? / You haven't seen it yet."; the rest backlog |
| 10 | Outer Capital: flat white wall backdrop, unseen Tidy-Bot hits | minor | backlog |

## Part 3 - the playtesters' dialogue tool (plain steps)

`tools/import_playtester_dialogue.py` (standard library only - no packages to install). When the testers send their workbooks back:

1. Put the returned `.xlsx` files in one folder, e.g. `docs/dialogue/returned/`.
2. `python tools/import_playtester_dialogue.py docs/dialogue/returned/*.xlsx` - reads each file's "Dialogue" tab (ID in B, New line in H,
   Notes in M, Reviewer in N), skips empty New lines, and checks every rewrite against the game's current text: the ID exists, every
   `{token}` / `[tag]` / `%s` is kept, one line, at most 240 characters (90 for barks). Rows added, deleted or sorted are reported (matching is by
   ID). Two testers rewriting the same line differently is a **conflict**: both are listed, neither is taken.
3. Read `docs/dialogue/playtesters_nov9_merged_report.md` (accepted / rejected with the reason / conflicts / sheet structure).
4. `node tools/apply_dialogue_pass.js --csv=docs/dialogue/playtesters_nov9_merged.csv` - the usual dry run (also checks every line fits its box).
5. The same with `--apply`. Undo with `--revert`. Settle a conflict by putting the chosen line in a CSV (`id,new_text`) and running
   `... --merge=<file> --apply`. Run the tests.

**Tested** on a copy of the workbook with ten fake edits by two fake testers: 4 accepted (one identical rewrite from both counted once),
4 rejected (a dropped `{town}`, a 326-character line, a 101-character bark, an unknown ID on an added row), 1 conflict listed, the sorted rows
reported; the importer's dry run took all 4 ("4 would apply, 0 conflicts"). The test files were deleted. HANDOFF section 5 has the workflow.

## Part 4 - accessibility and controls

- **Text size:** Settings > Text > "Text size (dialogue, cards, tooltips)": Normal / Large / Larger (sets the three per-kind sizes, which stay
  below it; "Custom" when they differ). Saved. At 1280x720 on Large: the dialogue box and the battle fit (`p4_large_text_dialogue_1280.jpg`,
  `p4_large_text_battle_1280.jpg`; the UI is one 1920 canvas scaled to the window, so the layout is the same at every size). Test:
  `tests/ui/test_text_size_master_nov10.gd`.
- **Controller pass:** the gamepad smoke (title, Path choice, gate, Crosspath, Sable's shop, a pack, the Deck Station, a duel turn, level-up,
  the menus, the map, the pause menu and Settings > Controls) **OK, 540 pad events, 0 key or mouse events**. The pad-walk test now also walks
  the **Wardrobe, the Tailor, the pack shop and nine minigame screens** (quiz, Dex's table, growth grid, match, order, recipe, reps, sort, tubes):
  every button reachable with the D-pad, no dead ends (19/19). The Gainlands wheel panel needs a zone run; the smoke covers zone screens.
- **Key rebinding:** works and is saved (existing tests + new `tests/test_keybind_essentials_nov10.gd`). New guard: moving, Interact and Pause
  can never be left with no key (clearing the last key, or taking it for another action, is refused with a message), and Pause keeps Esc in
  its first slot. Esc, Enter and Tab stay reserved for menus.

## Part 5 - performance and size

**5.1 The Capital's later visit** (`bash tools/run_loading_timing.sh <run> final`, LOAD_TIMING=1): **before 6.2 s, after 6.1 s** (noise).
Warm breakdown: the builder 3.1 s (buildings other than the houses 0.8, props 0.6, landmarks 0.45, merge 0.3, signs 0.1, rifts 0.16),
the Capital's dressing 0.39 s, the first settled frames 0.54 s, fades 0.7 s; the painted ground is already cached (new detail marks in
`painted_terrain.gd` show its splat at 4-18 ms warm). Every remaining piece registers walk blockers as it builds, which is exactly what made
the cached Crosspath buildings break the walk smoke in October. Not done on release eve. **Plan (M-L):** cache each piece's meshes *and* its
blocker list together (`BuildCache.fetch` of {scene, blockers}), one piece at a time, with the Capital walk smoke run cold and warm after each.

**5.2 Low-end on the exported build** (rc2 test pack, settings low_end / quality 0 / 30 fps cap / 75 % scale; `p5_le01_crosspath.jpg`,
`p5_le03_capital.jpg`, `p5_le05_battle_mid.jpg`):

| Place | FPS | Frame (process) | Working set | Video memory |
|---|---:|---:|---:|---:|
| Crosspath | 30 (cap) | 7-10 ms | 1.48-1.52 GB | 946-950 MB |
| The Capital | 30 (cap) | 10-24 ms | 0.99 GB | 870 MB |
| A battle | 30 (cap) | 8-17 ms | 0.92 GB | 590-614 MB |

**5.3 Download size:** RC2 zip **734 MB** (RC1 736), pack 844.8 MB, 14,092 files. The 20 largest entries are all music (MUS-CREDITS 6.1 MB,
then the boss and battle themes at 3-3.7 MB each, Vorbis q6 by design) and the Capital rim's baked geometry (4.2 MB). By folder: music 306 MB,
textures 441 MB (the zone kits 30-54 MB each, the world sprites 36 MB). `node tools/reference_graph.js --list` finds only **0.8 MB** of exported
files nothing references (cosmetic icon sizes the game builds by name - kept); removed from the export: the macOS app icon (1.9 MB, the
Windows build embeds the .ico) and four bestiary pictures with no entry. No superseded art or test files are packed. Against
`docs/build_size_policy.md`: over the 750 MB pack warning only because of the music, as decided. New: `node tools/verify_pck.js <pck> --largest=20`.
The export now ignores `_movie/` (the 931 MB trailer capture made the size guard expect a 1.5 GB pack and stop the first RC2 export).

## Part 6 - RC2

- `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc2`: the first try stopped at the guard (the `_movie` estimate above; nothing
  replaced); the second (`EXPORT_SKIP_BAKE=1`, keeping the bake the first run had just made) **EXPORT OK**: every MD5, 89 baked shaders, zip CRCs.
- **Release smoke on the exported pack: PASSED 17/17** (title shows v1.0.0-rc2).
- **Short exported-build checklist** on the rc2 test pack: run A (title, Credits, a new game, Crosspath with the new fountain, Sable's shop, the
  Deck Station, the Wardrobe, the Card Packs page, a battle, the pause menu, Reduce motion, Copy log, the save slots), run B (Reduce motion still
  ticked after a restart), the Low-end walk. 0 SCRIPT ERRORs. The real-exe fresh-install runs (`exe_drive.ps1`) were not repeated (the exe is
  the same stock binary; only the pack changed).
- Notes: `docs/release/rc2_notes.md`. Zip: `C:\Dev\Deckbuilder-rpg\builds\TheWaywardPath-v1.0.0-rc2-windows.zip`. CHANGELOG entry added.

## Commits (all pushed)

`99df27fd` Part 1, `b9ac7b83` Part 3 + briefs, `3917e1e6` Parts 2 + 4 (first half), `74f728dd` Part 2 fixes, version bump, `d9e66405` RC2,
then this report.

# Fable Nov 9 - report

Brief: `docs/prompts/fable_nov9.md` (with the day pass `docs/prompts/day_nov9.md` as Part 0). Questions: `docs/overnight_inbox.md`,
"Fable Nov 9". Shots: `docs/overnight_shots/nov9c/`. Run on Fable 5.1, one Godot at a time, no sub-agent while a Godot of mine ran; the
critic (a sub-agent) was the only Godot while it played. Last night's report follows below under "Overnight Nov 9 - report".

## At a glance

- **Import table with screenshots:** Part 1 below (23 images, all in the game). **The Pip pick:** `V-THREADWELL_DELIGHTED` (not the -ALT).
  **Other Sable images found:** none beyond her portraits, sprites and the figure-less shop background; nothing to redo.
- **Exported-build issues found and fixed:** the title screen ignored Enter from the keyboard (fixed); everything else matched the editor. Part 2.
- **The critic's top 10:** Part 2.3 below (first impressions 8, clarity 6, fun 6, polish 6; two of the ten fixed tonight, one was the critic's own script, the rest in the backlog).
- **Where the RC1 zip is:** `C:\Dev\Deckbuilder-rpguilds\TheWaywardPath-v1.0.0-rc1-windows.zip` (736 MB). Notes for testers: `docs/release/rc1_notes.md`.
- **Trailer:** done, 44 s, `C:\Dev\Deckbuilder-rpguilds	railer_rc1.mp4` (+ poster frame). Part 3.
- **What the owner does next:** (1) play the exported zip once yourself (unzip, run `TheWaywardPath.exe`); (2) create the itch page from
  `docs/release/itch_upload.md` and `docs/release/itch_page/` (text, tags, the AI disclosure field, "$0 or donate", the 8 screenshots, the cover),
  upload the zip, keep it **Restricted**; (3) upload the trailer to YouTube and link it on the page; (4) send the Restricted link + `rc1_notes.md`
  to playtesters; (5) collect their F8 reports / logs (`post_1_0_backlog.md`, section 1); (6) on release day set `config/version` to 1.0.0, export,
  smoke, replace the upload, flip to Public (`itch_upload.md`, step 9). Decide later: the first-fight length, the fountain blocks, the forest light and
  the Gainlands kit (the critic's majors 2-5), and whether to soften Primm / the Gallery if story-only testers stall despite the level hints.
- **Tests:** full suite in shards after every change: **2890 / 2892 passed, 0 failing, 2 risky** (pre-existing tests with no assertion). New tests:
  `tests/core/sim/test_level_hints.gd`, `tests/core/data/test_art_patches.gd`, the title focus test in `tests/test_title_art.gd`, the credits and
  un-held variants in `tests/ui/test_release_basics_nov9.gd`.
- **Commits (all pushed):** Part 0 `d1025a81`, Part 1 `0981a1af`, Part 2 `8653663d`, Finish (this commit).

## Part 1 - Batch 14 + Sable (23 images, all in the game)

Filed with `node tools/batch14_move.js --apply` (Pending Review/Batch 14 -> Approved_*; every replaced file to Drive `Superseded/` and a local copy in
`_art_source/superseded_batch14/`; Sable's old world sprites moved out of Approved_WorldTest). Importers run one Godot at a time: portraits, NPC sprites
(+ `sprite_normals.gd --only=SABLE --force`), card art, key art, bestiary, icons. Rows in `docs/art/batch14_nov9.csv` say "In game (Fable Nov 9)".

| Image | Replaces | Where it shows | Screenshot (`docs/overnight_shots/nov9c/`) |
|---|---|---|---|
| V-SABLE, V-SABLE_PLEASED, V-SABLE_SCHEMING | her three portraits (the redesign: fox, high jabot, no cleavage) | Sable's talks and shop | `b14_sable_talk.jpg` (real talk), `b14_v-sable_*_talkbox.jpg` (base, pleased, scheming) |
| SPR-SABLE-FRONT_IDLE / SIDE_IDLE / BACK_IDLE / FRONT_TALK (+ REF) | her four world sprites, `_n` normal maps regenerated | her stall in Crosspath | `b14_sable_stall_sprite.jpg` |
| V-TONIC_EXCITED, V-TONIC_OOPS | the human-woman variants (now the frog) | Tilly Tonic | `b14_tonic_talk.jpg`, `b14_v-tonic_excited_talkbox.jpg`, `b14_v-tonic_oops_talkbox.jpg` |
| NPC-GATEKEEPER_HAPPY, NPC-GATEKEEPER_STERN | the bearded-human variants (now the bear) | Brannoch | `b14_brannoch_talk.jpg`, `b14_npc-gatekeeper_happy_talkbox.jpg`, `..._stern_talkbox.jpg` |
| V-FENWICK_EXCITED | the human variant (now the magpie) | Fenwick | `b14_fenwick_talk.jpg`, `b14_v-fenwick_excited_talkbox.jpg` |
| V-THREADWELL_DELIGHTED | the human variant (now the mouse) | Pip | `b14_pip_talk.jpg`, `b14_v-threadwell_delighted_talkbox.jpg` |
| RES-IRON, BAS-G, B-13 | the glossy 3D plate, the cobalt vector Feastforge, the B-26 twin | hand and full size | `b14_hand.jpg` (all three in hand), `b14_cards_full.jpg` |
| STORY-PRIMM-P1, STORY-PRIMM-P2, STORY-REVEAL-KITCHEN | the giant-scale stills | the castle's phase cutscenes, the Test Kitchen reveal | `b14_primm_p1.jpg`, `b14_primm_p2.jpg`, `b14_reveal_kitchen.jpg` (real cutscene screen) |
| BST-ANTECHAMBER-SENTRY | the Windows-logo visor | the Collection Book's Bestiary, the Lab fight | `b14_bestiary_sentry.jpg` |
| ICON-ITEM-FIELDBANDAGE | the red-cross icon (now a leaf) | Tilly Tonic's shelf, the bag | `b14_item_vendor.jpg` |

- **The Pip pick:** `V-THREADWELL_DELIGHTED` (the first try). Against the base V-THREADWELL it keeps the hat's angle and bands, the patchwork coat
  with the same diamond patches and shoulder strap, the ears and the red neck ribbon. The `-ALT` has a steeper hat, much bigger ears and a pink
  sash; it is in Drive `Superseded/` (and `_art_inbox/batch14/`).
- **Held expressions:** `Portraits.HELD_EXPRESSIONS` is empty now (all five sets repainted on-species); the mood portraits show again. The release-basics
  test asserts the eight variants are offered and that Sable's pleased face is its own picture.
- **Other Sable images in the game:** searched every asset, data file and art sheet for her. Found only her three portraits, her four world sprites
  (both replaced) and her shop background `VS-SABLE` (the velvet salon: cards, curtains and shelves, **no figure** - nothing to redo). No card, still,
  loading painting or title art shows her. Nothing added to the art list for Sable.
- **The Red Cross emblem:** still on NPC-HESPER's cap and armband and on Hesper in STORY-EPI-WRINKLES. Fixed in code: `core/data/art_patches.gd`
  recolours red-dominant pixels inside two small normalised boxes per picture to a muted leaf green as the picture loads (Portraits and KeyArt call it;
  test `tests/core/data/test_art_patches.gd`). Seen in `b14_npc-hesper_talkbox.jpg` and `b14_epi_wrinkles_green_cross.jpg`. Two **REDO** rows added to
  `docs/art/art_audit_nov9.csv` (a leaf or heart instead of the cross). The new bandage icon has no cross.
- **Size and memory** (`docs/build_size_policy.md`): the 23 replaced files total 4.28 -> 4.66 MB in the repo (**+0.38 MB**; the portraits and cards are a
  little richer, the sentry doubled at 60 -> 91 KB, two stills shrank). Same count and import rules as before, so the pack moves by well under 1 MB
  against the 750 MB budget (the export in Part 2 gives the exact number). Memory: the same textures at the same sizes; the two patched pictures are
  rebuilt as ImageTextures once when loaded (the same VRAM as before; the CPU-side copy is transient) and sit in the bounded ArtCache like the rest.
- **Tools:** `tools/batch14_move.js`; `tools/story_still_shots.sh --ids=A,B`; `tools/shot.sh res://scenes/town.tscn x --open=bestiary:<Name_with_underscores>`;
  the card gallery's `--ids` now finds resources and infrastructure; the battle `--hand=` flag loads tokens (RES-*) too.
- **Gotchas met:** the portrait importer re-added the opaque NPC-PLAYER (reverted, as before); the NPC sprite importer rewrote the whole manifest
  (spliced only SABLE's entry: canvas 320x504 -> 304x512, `cloak_hue`/`head` kept); the importers' status writer dropped the "UI art kit" and
  "Dungeon maps" sections of `docs/art/art_status.md` (restored from HEAD); `core/zone/zone_defs.gd:46` references Session, which prints a compile
  error in every headless `-s` importer run (harmless: the import still completes).

## Part 2 - RC1 build and the real-build check

**Export:** `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc1` (1.4 GB free RAM; the export's own guard wants 2 GB, its hard stop is
1.2 GB; peak Godot working set 1.3 GB, 14 MB free at the worst moment, every check passed). **Zip:** `builds/TheWaywardPath-v1.0.0-rc1-windows.zip`
= **736 MB** (pack 847 MB, 14,101 files, 89 baked shaders, every MD5 and CRC checked; build folder 952 MB). The pack is over the 750 MB budget
warning because the music is at Vorbis q6 by the designer's decision (`docs/build_size_policy.md` has the new row). Release smoke on the
exported pack: **PASSED, 17/17** (title + version, New Game to the starting area, F8 report + screenshot + log copy, pause menu, no Dev Menu,
save to slot 2 and load back).

**Exported-build test, two layers** (shots `docs/overnight_shots/nov9c/rc1_pack_*.jpg` and `rc1_exe_*.jpg`):

| Check | On the real `.exe` (fresh user folder, real clicks and keys: `tools/exe_drive.ps1`) | On the exported pack (stock binary + test pack, play driver: `tools/play_exported.sh`) |
|---|---|---|
| First launch, no settings or save | ok: title with New Game / Settings / Credits / Quit, v1.0.0-rc1; the Low-end preset picked itself on this iGPU (log: "first launch: Low-end preset") | - |
| New game through the intro to Crosspath | ok: slot chooser, the wake-up still, the forest, the Rescuer, the Path choice (Beefcake), the forest free; Crosspath reached via the driver's jump in the pack run | ok (`x04`-`x05`) |
| Save, quit, reload | ok: autosave after the Path choice; a manual save to slot 1 ("Saved to Slot 1"); Quit Game; Continue on the next launch landed in the forest; Load Game lists the autosave and Slot 1 | - |
| A battle, a shop, the Deck Station, the Wardrobe, the Card Packs page, a minigame | - | ok: Quota's duel played by the pilot then won (`x10`-`x12`), Sable's stall (`x06`), Deck Station (`x07`), Wardrobe (`x08`), Card Packs (`x09`), the Gainlands quiz (`y07`-`y08`) |
| Settings that survive a restart | ok: Reduce motion ticked on launch 2, still ticked on launch 3 (`settings.cfg`: `reduce_motion=true`) | ok: run B seeded with run A's settings shows the tick (`y01`) |
| Low-end mode | ok: auto on first start (quality Low, 30 fps cap, render scale 0.5) | ok: forced quality 0 - town, the Gainlands, a battle (`z01`-`z03`) |
| The log file and Copy log | ok: `%APPDATA%\Deckbuilder-RPG\logs\wayward.log` (+ `.1`, `.2`), boot lines with OS/GPU/driver | ok: "Copied" toast (`x15`) |
| Credits and the AI disclosure | ok: "A game by Alex Glowatz", the licences, the AI section (launch 3) | ok (`x02`) |
| The hidden donation button | ok: no Support button on the title or the Credits head | ok |

**Differences from the editor found and fixed:** none in the game itself. Two things the real exe showed that the editor runs hid:
1. **Keyboard only at the title: Enter did nothing** (no button holds the focus until a pad or the mouse gives it). Fixed: the first keyboard
   Enter or arrow focuses the top menu button (`TitleScreen.keyboard_focus_menu`, test in `tests/test_title_art.gd`). Not re-exported for this
   (an rc1b export is not needed for a focus fix; it is in the next build).
2. The exported build's Escape is matched by physical key: a synthetic Escape without a scan code is ignored (a tooling fact, not a player issue).

**Tools made for this:** `tools/exe_drive.ps1` (drives the exported exe: `wait`, `key`, `press` with scan codes, `hold`, `click`, `shot`; never
touches the player's files - move `%APPDATA%\Deckbuilder-RPG` aside by hand), `tools/play_exported.sh` + a `play` mode and settings seeding in
`tools/run_exported_suite.sh`, the scripts `docs/review/play_scripts/exported_rc1_{a,b,c}.txt` and `exe_{a,b,c,d}.txt`.

**Fresh-eyes critic of the exported build (Part 2.3):** a fresh `general-purpose` agent given only `docs/review/critic_rc1_brief.md` played the
exported pack for about 80 minutes of game wall clock over 34 runs (r1-r33 the straight first hour with no jumps: title, Settings, Credits,
the opening line by line, Beefcake via "More", the forest, all five cave nodes and the Hollow Warden, Crosspath, Maren, every menu, Fenwick,
Tilly, the Power Wraps errand; r34 the only jump: the Gainlands and the House of Gains). Report: `docs/review/critic_rc1/report.md`
(63 shots in `docs/review/critic_rc1/shots/`). It was interrupted once by the account's usage limit and resumed.

| Score | /10 | Why (the critic's words, shortened) |
|---|---|---|
| First impressions | 8 | title, stills and portraits superb; the real 3D forest dark and blurry with a tiny hero; Path cards unreadable until "More" |
| Clarity | 6 | menus and rules panels good; the cave trigger is missable, the end-turn nag fires while picking attackers, "Where to?" sets a goal, Esc does not close Tilly's shop |
| Fun | 6 | the card game is sound, boss / level-up cadence good; the first fights last 8-11 rounds against a 3-HP enemy (infrastructure flood) |
| Polish | 6 | 2D screens about 9/10; white untextured blocks in the Crosspath square, the dark forest, low-poly Gainlands kit, bark bubbles over name labels |
| Unfinished / AI-made | - | most visible: the white 3D fountain and plinth blocks in the square and the low-poly Gainlands; the painted art is openly AI (Credits) but consistent; no template text, no overflowing boxes, no SCRIPT ERROR in 34 logs |

**The critic's top 10** (severity for a new player) and what was done tonight:
1. **Major - the cave entrance trigger** only fired on a small ring beside the stairs; under the arch there was no prompt, every other way an "I'll head back" line; five runs to get in. **Fixed:** the arch answers E from the whole doorway and the bottom step (`StartingAreaScene.GATE_RADIUS` 3.0, was the 1.7 interact radius).
2. **Major - the first fights are too long:** a 3-HP Cave Scavenger lasted 8-11 rounds in four attempts, both decks flooding with infrastructure; 11 of 15 HP lost once. Backlog (balance; the Nov 1 teaching hand helps the very first duel only).
3. **Major - white untextured fountain / plinth blocks** in the Crosspath square beside painted houses. Backlog (the painted fountain and statues are the known art item).
4. **Major - the 3D forest is near-black** with heavy tilt-shift, the hero about 60 px tall. Backlog (known from N8; a light pass).
5. **Major - the Gainlands' flat low-poly kit** clashes with the painted art; the gatekeeper fight starts two steps in with only a toast. Backlog (zone kit texture pass).
6. **Minor - "End your turn? You can still play 1 card"** appears while choosing attackers with one selected. Backlog (suppress during attacker selection).
7. **Minor - Escape does not close Tilly's shop**, only the X. **Not a bug:** reproduced in the editor build (`docs/review/play_scripts/esc_shop_probe.txt`): one Escape closes the shop, tip or no tip (`_screenshots/play/esc_shop_probe/esc_02_after_escape.png`). The critic's script pressed E again beside Tilly two lines later, which re-opened it.
8. **Minor - "Where to?"** sets a goal marker rather than travelling or closing the map. Kept (by design: the arrow leads there after the map closes); the label could say so. Backlog.
9. **Minor - townsfolk bark bubbles drawn over their own name label.** **Fixed:** the bubble sits 30 px above the plate (`NpcBarks.LABEL_CLEARANCE`).
10. **Minor - Path choice thumbnails unreadable** until click + More. Backlog (show "how it plays" and the Resource on hover).

What worked for the critic: the opening and the portraits, the cave node map and the Hollow Warden reveal, the Deck Station and Character
pages, battle readability (hover zoom, the "-1 HP if unblocked" arrow, the Just Arrived tooltip, Speed), the shopkeepers' voices.

**RC1 notes:** `docs/release/rc1_notes.md` (what is in it, known issues, how to report). **The zip:** `C:\Dev\Deckbuilder-rpguilds\TheWaywardPath-v1.0.0-rc1-windows.zip`
(no Drive `Releases` folder exists; `docs/release/itch_upload.md` names the file).

## Part 3 - itch.io page kit, final

- **Re-checked against 1.0.0-rc1** (`docs/release/itch_page/page.md`): the descriptions, the features (deck slots "four to start, more as you
  level" instead of "ten"; the minigames and the postgame named; the comfort options updated: Path symbols on by default, Reduce motion, the
  autosave indicator, level hints), the controls table against `app/keybinds.gd` (tracked-quest keys, dungeon rules R / Y, right-click inspect
  added), the measured requirements (the exported build's own boot log: Ryzen 5 4500U iGPU, 7.4 GB, Low-end auto-picked, 278-370 MB video
  memory in the forest; download about 740 MB, about 950 MB unpacked), the tags (unchanged), the AI disclosure (page text + itch's own
  disclosure field in `itch_upload.md`), and "free, donations welcome" in the pricing note and the long description.
- **The eight screenshots** (`docs/release/itch_page/screenshots/`, 1920x1080, README lists the order): a Buffet-board battle, the wake-up still,
  the Shattered Gallery map, the classroom quiz, the Wardrobe, the Card Packs shelf, Dex's table, the Capital's Gate Plaza. The Nov 8 set is kept in
  `old_nov8/`. (The Capital shot is the Gate Plaza from a postgame save; `dev travel capital` lands inside the dark Crease, and the broken-state plaza
  carries a "Tidy-Bot knocks you flat" toast - neither suits a store page.)
- **Trailer: done, 44 s** - `builds/trailer_rc1.mp4` (11.9 MB, h264 1280x720 30 fps, AAC) + `builds/trailer_rc1_poster.jpg`. Made with
  `bash tools/make_trailer.sh capture` (the play script `docs/review/play_scripts/trailer_rc1.txt` under Godot's movie writer, `--write-movie`
  `--fixed-fps 30`, MJPEG AVI 931 MB in `_movie/`) and `bash tools/make_trailer.sh cut` (ffmpeg: clips at the script's CUT marks, 0.4 s fades, three
  title cards in Cinzel on the game's ink colour, the title theme `MUS-TITLE.ogg` as the only sound, faded out). Clips: the title, Crosspath, the
  Deck Station, the Endless Buffet, a battle (12 s), the Shattered Gallery map. Two captured clips were left out: the Gainlands walk ran into the
  gatekeeper's duel and the Capital clip was the Crease interior. Honest and simple, as asked; itch takes a YouTube/Vimeo link, so the owner uploads
  the mp4 there (or attaches it to the devlog). Gotcha: the play log counts wall-clock seconds while the movie counts frames at 30 fps (the capture
  renders slower than real time), so the cut script scales the marks by movie length / last mark.
- `docs/release/itch_upload.md` names the exact files (zip 736 MB, cover, the 8 screenshots, the trailer).

## Part 4 - handover and the post-1.0 plan

- **`docs/HANDOFF.md` finalised:** section 2 is the exact sequence run today (tests, export with the low-memory switch, release smoke, the test pack
  and `play_exported.sh` runs, the real-exe driver, the critic brief, the upload guide); section 3 the art pipeline with the Batch 14 filing tool,
  the importer quirks met today and the shot commands per kind; sections 4-5 music and dialogue; section 6 the six small-prompt templates;
  section 7 points at the backlog; section 8 the one-line Drive backup (`git archive ... HEAD` into `Card Game Art/Backups/`).
- **`docs/release/post_1_0_backlog.md`:** playtester feedback intake (collect, triage, reproduce, fix and ship, watch the walls), the known issues
  at rc1 (title keyboard focus - fixed tonight -, the walls, the Red Cross stopgap, the Capital load, the pack size, Credits scroll keys, Esc on a first
  viewing, the headless Session error, exit-time leak noise), the remaining art REDOs (Hesper x2, NPC-GUS, 8 bestiary pictures, one gear icon, 8
  unmatched bestiary files), nice-to-haves (the critic's list) and Steam readiness (Steamworks, achievements from feats, cloud saves, store assets,
  Steam Input, Deck, build pipeline).
- Everything is pushed to GitHub after each part (see the commit list at the end).

## Part 0 - the day pass

| Item | Done | Where |
|---|---|---|
| Credits: Alex Glowatz as creator | yes | `data/credits/credits.cfg`; "A game by Alex Glowatz" + "Game design, direction and production: Alex Glowatz" on the Credits page (`01_credits_creator.jpg`), and under the title card in the end credits. Donation link empty: Support stays hidden. |
| Colour-blind symbols on, Dex stays | yes | both already in the game; inbox items 1 and 3 closed |
| Level hints at the walls | yes | every dungeon door (zone side and main dungeons, Swolympus, the Vault hatch, the Lab hatch, the castle, the Gallery, the Paste Works) says "Travellers here are usually around level N" under its prompt, **amber when 2+ levels under** (`02_hall_prompt_level9_amber.jpg` vs `03_..._level12_muted.jpg`); the full map's "Where to?" list says "(Dungeon entrance, usually level 11)" and the dungeon icon has the same line as a tooltip (`06_map_where_to.jpg`). `core/sim/level_hints.gd` reads `ProgressionModel.LEVELS`; test `tests/core/sim/test_level_hints.gd` (every dungeon but the level-1 cave has one). Balance unchanged. |
| Dark battle backdrop | dev-only, fixed | the UI sweep's shot 16 was `dev encounter quota`: its sim group "capital:lieutenant" is not a battle-context key, so the board fell back to the placeholder slate. The real Quota duel always had the Transit Yards board. The sim group is mapped now (`data/battleboards.json`), `07_dev_quota_board.jpg`. |
| itch upload guide | yes | `docs/release/itch_upload.md` (page, "$0 or donate", text, AI disclosure field, zip, screenshots, Draft/Restricted, Support link, playtesters, public flip, butler). |

# Overnight Nov 9 - report

Brief: `docs/prompts/overnight_nov9.md`. Tag `pre-overnight-nov9` marks the start. Questions: `docs/overnight_inbox.md`, "Overnight Nov 9".
**No export.** Last night's report is archived at `docs/overnight/nov8b/overnight_report_nov8.md`. Run on Opus 5.5 (not Fable); Claude
Code's low-memory reaper was *on* for this session, so every long Godot job was started detached and watched from the foreground.

## 1. The four real-fight playthroughs

Every Path played from a new save to the credits and through the postgame (the Lab, the Shattered Gallery, Swolympus, Loose Ends) with
**every fight real**: every node of every dungeon (the tutorial cave, all side dungeons, all four main dungeons, the castle, the postgame),
every gatekeeper, every boss phase. No decreed or auto wins - except after a **wall** (4 losses on the same dungeon), which is logged, then
decreed so the run can go on. Save and load at each zone change (state digest checked), plus one mid-dungeon save/load. A loss plays out
as a loss: the hero wakes at the respawn point, the dungeon starts over, and the bot walks back in.

| Path | Completed | Steps | Game time (bot) | Fights won / lost | Walls | Gold earned (target 21.3k) | Final level |
|---|---|---|---|---|---|---|---|
| Beefcake | **yes** | 119 / 119 | 1.08 h | 93 / 30 | 6 | 15,750 (74 %) | 24 |
| Necrocrat | **yes** | 119 / 119 | 1.03 h | 82 / 20 | 4 | 17,035 (80 %) | 23 |
| Gourmand | **yes** | 119 / 119 | 0.95 h | 82 / 16 | 3 | 16,510 (77 %) | 23 |
| Refusemancer | **yes** | 119 / 119 | 1.19 h | 100 / 15 | 2 | 19,155 (90 %) | 26 |

**How to read it.** The player is the game's own planning AI (ELITE, the same player as the balance sims) sitting in the hero's seat on the
real battle screen at battle speed x4 - so "game time" is bot time, several times shorter than a human's. Between fights it opens every
pack, wears its best gear, buys the best cards Sable has for its Paths (keeping a third of the purse), and rebuilds its deck with the Deck
Station's own "Suggest a deck" (two Paths once the game allows). It plays **no optional content**: no roamers, arena bouts, quiz, Dex or
favours beyond the one each zone needs (those are set by flag) - so it arrives everywhere **3-5 levels under** `ProgressionModel`'s
expected player, and its gold is short of the 21.3k no-grind target for the same reason (the target counts the optional fights).

**Losses by encounter** (level at the time): full lists in `docs/playthroughs/full_real_<path>_nov9.log` ("FULL loss" lines).
- **Primm (all four Paths, a wall in all four):** levels 16-20. Expected player: 21.
- **The Shattered Gallery (all four, a wall in all four):** levels 22-25. Expected: 26.
- **The fourth zone's main dungeon** (the Rotheart for Beefcake and Gourmand, a wall for both): levels 14-15. Expected: 17.
- **The second zone's main dungeon** (the Hall of Final Approvals for Beefcake, the House of Gains for Necrocrat; both walls): level 9. Expected: 11.
- **S-NECRO, the D.N.A. side dungeon** (a wall for Beefcake and Necrocrat): levels 5-9. Expected: 10. It opens with the D.N.A. favour,
  so a player who takes it as soon as it opens meets it about 4 levels early.
- Lighter: the Lab (L19-21, one wall), Swolympus (L23-25), the House of Gains boss for its own Path (L5, beaten on the 2nd-3rd try).

**Difficulty walls a normal deck can't pass:** none that stay walls once the hero is at the expected level - every wall above sits 2-5
levels under it. But a **story-only player will stall at Primm and at the Gallery** on every Path, and at the second and fourth main
dungeons on some. Recommendation (owner's call, not changed tonight): say it in the game - e.g. Maren or the dungeon entrance noting
"most travellers are level N before this" - or soften those four by one step. The balance sims are the tool to pick which.

**Dev help used:** walking (teleports to spots, the zone road walk, the Lab hatch, the Rift Express, Swolympus travel), favour steps and
Maren's early chain set by flag, Old Man Mountain's errand by its counter, and the decree after each wall. Nothing else.

## 2. Blockers found and fixed

| # | Found | State |
|---|---|---|
| 1 | **Primm's Castle could strand the player** (ship blocker). Its side branches nest (courtyard -> Grand Foyer -> Portrait Gallery -> two wings); after the wings the map sent the party back one level only, onto the Gallery, with nothing left open. Nothing to click; only Retreat (which resets the final dungeon). The Beefcake run hit it 18 times (the bot jumped ahead, logged). | **fixed**: `DungeonMap.complete` keeps doubling back the way the party came until a node has an open path. New test walks every dungeon as a completionist and with 20 random walkers each (fails on the old code, passes now). The three later runs met it 0 times. |
| 2 | **Rewards screen: a second Take/Skip press** (double click, or E right after a click) applied the rewards again, stacked a second level-up panel and ran the after-rewards step twice (the tutorial's completion twice). | **fixed**: one confirm per screen. |
| 3 | **Dungeon map: choosing a node while its cutscene played** started it again on top (stacked cutscenes). | **fixed**: picks are ignored while a node cutscene is up. |
| 4 | **The Credits page showed its own editing notes** as its first heading. | **fixed** (+ test). |
| - | **Still open:** none found that blocks finishing the game. Watch item: the walls in section 1. | - |

## 3. Game feel and polish (Part 2)

Most of the battle-impact list was already in the game (Battle feel, Oct 28-29: card lift and land with dust, wind-up lunge, hit-stop,
shake scaled to damage, floating damage numbers, the dissolve shader, buff numbers). Tonight filled what was missing and checked the rest.

**Battle impact (new tonight)**
- **Reduce motion** (Settings > Accessibility, saved): no screen shake, no hit-stop, no final-blow slow motion; lunges, recoils, pops and the
  turn-banner sweep at 30 %; half the particles. A superset of "Reduce screen shake".
- **Buffs** pop: the unit grows and settles with a green glow ring (the +x/+y number was already there).
- **Healing**: a green glow ring on the healed portrait, under the burst and the "+N HP".
- **Unit death**: the burst is now in the unit's Path colour (it was a fixed peach), matching the dissolve edge.
- **Turn banner**: 0.62 s instead of 0.75 s (both sides).
- Before/after: `docs/overnight_shots/nov9b/` (Dex, UI sweep); battle feel is motion, so it is described rather than shot.

**Sound coverage:** `docs/audio/sound_coverage_nov9.md` lists every common action. Gaps filled:
1. the world purse: gold rising now chinks softly (at most every 0.5 s) and the HUD number pops;
2. Settings, Glossary, Feats, Credits and the save slots: open with a page sound, close with a soft back sound (they closed silently);
3. opening a town or zone screen no longer plays the close sound first (it "closed" nothing);
4. a miss at Dex's table has a sound.
Loudness re-measured with both tools: nothing sits more than 3 dB over its role; no change needed. Ducking verified in code: music -4.5 dB
under any dialogue box, -9 dB (story -13) under stings, eased. Default mix unchanged (music about 2 dB under effects).

**Transitions:** every scene change already goes through SceneManager's fade (no direct scene switches anywhere in the code). New: the full
loading screen only shows when it is needed - a destination that loaded in under 0.9 s earlier this session gets the plain fade (the
"still loading" card still appears if a load runs long). First visits keep the loading screen.

**UI consistency sweep:** 23 screens shot before and after (`docs/overnight_shots/nov9b/ui_before/` and `ui_after/`, script `docs/review/play_scripts/ui_sweep_nov9.txt`).
The frames, headers, buttons and focus rings already match the Deck Station across title, Settings, Character, Deck Station, Packs, Quest
Log, Map, Wardrobe, Pause, zone HUD, dungeon map and Dex. Strays found and fixed:
1. **the Credits page printed its own editing notes** ("The Credits screen's text... '#' lines are headings...") as its first heading - the
   file's header used heading marks; now comments, with a test;
2. the D.N.A. Rec Room memory cards could not take keyboard/pad focus (Dex's table could): now focusable with the shared focus ring.

## 4. Dex's Cardsharp's Circuit (Part 3): **finished - keep it in 1.0**

- **Played through end to end** by a new smoke (`tools/dex_circuit_smoke.tscn`): Dex's talk spot in all four zones (lines, quest offer,
  table), each table won, the final table opening after four, the turn-in, and the Matching Pair granted and worn: **46 / 46 steps**.
- **Scoring was unfair:** "12 moves or fewer" (11 at the final) out of 14. Simulated: a *perfect* memory beat that only 55 % / 9 % of the
  time. Now 15 / 14 out of 20 - a careful player wins a zone table 82-97 % and the final 61-87 % (`docs/minigames/dex_odds_nov9.md`).
- **Rules:** one line under the score: "Flip two cards: that is one move. Find all eight pairs in 15 moves or fewer to beat Dex (the table
  allows 20)."
- **Polish to the Deck Station bar:** a green felt table with a gold rim, the Path's own card backs (the final table: the neutral back)
  instead of a "?", Dex's portrait at the head of the table with his name and a line after every move (pair, miss, win, close, out of moves;
  in `dungeon_content.json`, `cardsharp.quip.*`), "A pair! 3 of 8 found", and a miss that says to remember where the cards were.
- The prize's effect (draw a copy of your first spell each turn) was already tested.
- Shots: `docs/overnight_shots/nov9b/dex_*`.

## 5. Release basics (Part 4)

- **Autosave indicator:** a small quill turning in a gold ring with "Saving..." in the bottom-right corner on every autosave (it holds 0.9 s
  after the last save, then fades; slower under Reduce motion). `ui/widgets/save_indicator.gd`, `EventBus.game_saved`.
- **Colour-blind Path symbols ON by default** (`Settings.DEFAULT_COLORBLIND_SYMBOLS`; inbox item 1 says how to flip it).
- **Version 1.0.0-rc1**: title screen, log header, Credits page (all read `config/version`), Windows file/product version 1.0.0.0.
- **itch screenshots:** left as last night's - this screen cannot open a true 1920x1080 window (max about 1886x1061).
- **credits.cfg:** creator and donation link left empty, with `>>> OWNER` comments showing exactly where they go.

## 6. Final read of the main story (Part 5)

All 1,484 main-quest lines read in game order (prologue, Crosspath, the four gatekeepers, dungeons and freed-zone talks, Maren's four
memories, the cave-mouth scenes, the Capital's main beats, the castle, Primm, the ending and the post-ending scenes). The Nov 5 rewrite holds
up: voices match `docs/dialogue/story_voice_nov5.md`, clipped "short statements" are gone from the main line, and the jokes sit on side
characters. Fixed: 11 hand edits and 88 quote repairs (revertible: `node tools/apply_dialogue_pass.js --csv=docs/dialogue/edit_nov9.csv --revert`; the filled sheet is
`docs/dialogue/edit_nov9/story_read_applied.csv`):
- **69 lines of speech split across boxes** (a quote opened in one box and closed two boxes later: Agnes in the queue, Mortimer, Vellum,
  the notary, the whistleblower, Old Man Mountain, the throwers...) - every box now opens and closes its own quotes; plus 19 of Primm's
  lab notes and journals split the same way with single quotes.
- **Continuity:** Primm "in his pressed grey coat" after the fight (he wears white and gold); Primm "removed two people so that eleven
  thousand could be safe" (eleven thousand is the number he *corrected*) - now "a whole kingdom".
- **Repetition:** the blueprint vault and the early journals both used "They are good. They are so good." (Flex's repeated "it was not the
  part that matters" is a deliberate beat the Wanderer throws back at Primm - a story test caught my edit, so it stays.)
- **Clunky lines:** Clench's boss intro told you to get "off the wheel" inside his gym;
  Compostella's muddled "don't shut it away in a jar... Death is not the end of them".
- Kept on purpose: the Rescuer's "Tell me: which Path resonates within you?" is pinned word for word by a test (an earlier owner call).
- Fig Sly's black-market lines are locked by the tool and were not touched.
- Nothing contradicts the current quest steps, names or tutorials. Re-exported: `docs/dialogue/edit_nov9.csv` (4,357 rows, story order).

## 7. Plan for Nov 9-11 (updated)

- **Nov 9, day (owner):** answer the inbox (colour-blind default, Dex kept, the walls). Fill `data/credits/credits.cfg` (name, donation
  link). Generate Batch 14 (`docs/art/batch14_nov9.csv`, the five mood-variant sets first). Play Dex's table once - it should now feel winnable.
- **Nov 9, day (Claude):** import Batch 14 and un-hold the portrait variants. Decide the four walls with the balance sims (Primm, the
  Gallery, the 2nd/4th main dungeons, S-NECRO's opening point) or add "travellers are usually level N" hints - whichever you choose.
- **Nov 9, night run:** the S items left from the cut-or-finish list (quiz feedback, packs shelf scroll, Alembic bars, Wardrobe tint, Gallery
  tooltip), the forest light and the tutorial-cave restart; re-run one Path with `bash tools/run_full_real.sh <path>` after any balance change.
- **Nov 10, day:** play the first hour yourself on a clean save; one fresh-eyes critic (first hour).
- **Nov 10, night run:** Crosspath roof fade, the battle infrastructure row and hand cap, the full suite, an exported-build smoke.
- **Nov 11, day:** set `config/version` to 1.0.0 (the presets already say 1.0.0), export, test the zip on a second PC, set up the itch page
  from `docs/release/itch_page/`, upload, finalise `docs/HANDOFF.md`.

## Tests

Full suite in memory-safe shards (`bash tools/run_tests.sh --only=tests --size=12`): **2,878 / 2,882** on the full pass; the 2 failures
were tonight's (the version-preset test now compares the numeric part of "1.0.0-rc1"; the word-for-word Path question was restored) and
pass on re-run; 2 risky (pre-existing tests with no assertion). New tests: `tests/core/dungeon/test_map_never_strands.gd`, the Credits
notes test. New tools: `tools/run_full_real.sh <path>` (with a memory watchdog), `tools/story_playthrough.gd --full=1`,
`tools/dex_circuit_smoke.tscn`.
