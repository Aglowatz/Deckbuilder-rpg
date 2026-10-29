# Morning report - overnight Oct 28-29 (art batches 1-4, battle feel, memory leak)

Started Wed Oct 28 20:15 MDT (Opus), finished Thu Oct 29 ~00:50 (about 4.5 of the 9 hours; every part done, then 8 polish cycles - I
stopped there rather than churn). Tag `pre-overnight-oct28` (= 9bdb73e5). Brief copy `docs/overnight/oct28/brief.md`; state
`docs/overnight/loop_state.md`; polish log `docs/overnight/loop_log.md`; questions `docs/overnight_inbox.md` ("Overnight Oct 28-29",
items 1-4). Dialogue freeze respected (no dialogue file touched). No image was generated, Pending Review and the Replaced Artwork folder were
never opened, the Drive was only copied from. No version bump, no export.

## Read this first

- **All 74 rows are in the game, none needs a redo** (`docs/art/art_status_oct28.csv`). Maren is a tortoise in dialogue (3 expressions), in
  Crosspath and at the forest cave mouth; all 21 roaming enemies walk the zones as their painted sets (the 3D models are only the fallback);
  27 of the 31 entrances slide in their CUT-* cut-out, Primm wearing CRACKED / UNRAVELLED in phases 2 and 3; the 23 squares (24 files, the
  Spotless copy) show in the Collection Book and on the battle plates.
- **One real bug found on the way**: last night's sprite swap-in looked roamer sets up as `FOE-PANTRY-HOUND`, but the importer stores them as
  `FOE_PANTRY_HOUND`, so no roamer would ever have found its art. Fixed in `ZoneEnemy._make_model`.
- **Battle feel**: try **hold Space during the enemy's turn** (3x hurry), the new **4x** speed, a resource card (a mote flies to the counter),
  any Legendary (an entrance), and the 40-80 ms hit-stop. Details and timings: `docs/design/battle_feel.md`.
- **The memory leak is found and fixed**: the D.N.A. kept every visit's ~560 wall/cabinet fade materials for the whole session (+23 MB video a
  visit). Over 10 round trips: video **+46.5 -> +0.4 MB**, static **+6.6 -> +0.8 MB**, objects **+1149 -> +28**. New smoke:
  `bash tools/run_memory_roundtrip_smoke.sh`.
- **Your calls** (inbox): Captain Spotless still walks the Capital as the 3D knight (no FOE set; his NPC set could stand in - item 1); the
  new 0.45 s threat pose before a chase (2); the roamers' warm rim (3); the hub walk smoke fails one check because Old Hob stands on its line
  (4, not tonight's code).

## By part

| Part | Commit | What |
|---|---|---|
| 0 Inventory | afeb463e | 239 files, full PNG decode (CRC, IEND, every pixel row), contact sheets; all sound; `docs/art/import_oct28.md` |
| 1 Maren + roamers | afeb463e | 21 `NE-*` rows in `npc_sprite_batch.csv`; three importers; key fix; untinted sprites; threat pose; hop for idle sets; roamer rim; walk-strip sliver pass; ZoneEnemy drives its sprite (per-frame scripts back to budget); `--lineup` shot tool |
| 2 Entrances + Bestiary | afeb463e | `Bestiary.cutout(name, phase)` + `PHASE_CUTOUTS`; `scenes/dev/entrance_gallery.tscn`; `test_art_import_oct28.gd` |
| 3 Verify | a2d52559 | bots, smokes, budgets, size; `art_status_oct28.csv` |
| 4 Battle feel | 8a5972a8 | see below; `tools/battle_sequence.tscn`; `test_battle_feel_oct28.gd` |
| 5 Memory leak | 03021ca4 | `DnaMaterials` weak references; `memory_roundtrip_smoke`; `memory_probe --zone --trips` |
| Phase 2 | 93aba051, 7f25f5df, 3f04830a, 3f9b7133, 94dcdecb + final | guards face the hero; Maren checked; ribbon number; threat pose checked; Casserole at his gate; entrance crop line; hovering sprites |

## What art is in game

| Group | Where it shows | Notes |
|---|---|---|
| NPC-ELDER, _HAPPY, _WORRIED | every Maren dialogue, the Codex | `_screenshots/dialogue/oct28_elder.png` |
| SPR-ELDER (4) | Crosspath, the forest cave mouth | `_screenshots/oct28/p2_maren_forest.png` |
| 14 SPR-FOE walk sets | Pantry Hound, Lost Junior Clerk, Bin Raccoon (Crosspath); Quota Spotter, Protein Shake Golem (Gainlands); Shambling Middle Manager, Unpaid Intern (D.N.A.); Meatloaf Golem, Gelatin Sentinel (Buffet); Mossy Trash Golem, Hungry Scarecrow (Dump); Correction Officer, Perfection Inspector, Rift Wretch (Capital) | 5 directions idle + walk, right side mirrored, threat pose |
| 7 SPR-FOE idle sets | Sprinting Energy Sprite, Speedy Ghost Courier, Runaway Meatball, Junk Gull Flock, Tidy-Bot, Shard Swarm (roamers; they hop or float as they move); Colonel Casserole (the Buffet's battle gate, Phase 2) | |
| 26 CUT-* | every boss / lieutenant / gatekeeper entrance with a speaking character | `_screenshots/oct28/entrances.png`, `p2_intro_warden.png` |
| 24 BST-* | Collection Book + battle plates | old-name pictures and counts still apply (`Bestiary.RENAMED`) |

**Needs a redo: none.** Noted only: 22 of 70 walk strips have touching figures, so the importer cuts them at the emptiest column (tiny
slivers are cleaned; at game scale nothing shows); a few strips' last figure touches the right edge by a few pixels.

## Screenshots per zone

| Area | Files (`_screenshots/oct28/` unless noted) |
|---|---|
| Crosspath | `lineup_town_idle.png`, `../dialogue/oct28_elder.png` |
| Opening Forest | `p2_maren_forest.png` |
| Gainlands | `lineup_gainlands_idle.png`, `p2_guard_faces.png` |
| D.N.A. | `lineup_dna_idle.png`, `p2_lineup_dna_threat.png`, `p2_lineup_dna_hover.png` |
| Endless Buffet | `lineup_buffet_idle.png`, `p2_casserole_gate.png` |
| Verdant Dump | `lineup_heap_idle.png`, `lineup_heap_walk.png` |
| Capital | `lineup_capital_idle.png` |
| Entrances | `entrances.png` (all 31), `p2_intro_warden.png` |
| Battle feel | `before_<path>.png`, `after_<path>.png` (one bot-played turn per Path), `p2_feel_zoom.png`, `p2_banner.png` |
| Art review | `review_walks.png`, `review_idle.png`, `review_sides.png`, `review_cut.png`, `review_bst.png` |

A lineup of any area: `bash tools/shot.sh res://scenes/<zone>_zone.tscn <name> --lineup=idle|walk|threat --nohud=true --wait=6
--set=camera_zoom:0.75` (town: `res://scenes/town.tscn ... --pos=25.2,19.5 --quiet=true`).

## Battle feel - what changed and how to try it

- Hit-stop 40 ms (1 damage) to 80 ms (5+), was up to 120; shake capped at 12 px (was 20), off with Reduce screen shake.
- Damage numbers pop past full size and settle; red with a third of the attacker's Path colour, sparks half Path colour; buffs in the buffed
  card's Path colour, debuffs violet, heals green.
- A made resource flies from its card to its counter and pops there; a spent one flies off its counter.
- A played card lands in the middle with a soft thump and dust; units keep their landing squash and summon thud.
- The turn ribbon says "Turn N" under YOUR TURN / ENEMY TURN.
- A Legendary arrives with gold rings, sparks, LEGENDARY over it, a glow, its Path ring, a small shake and the pack-reveal chime (+0.15 s).
- Every effect follows the battle speed; new 4x (1x / 1.5x / 2x / 4x; saved choices keep their index); **hold Space** to hurry 3x.
- Nothing else is awaited: the first-battles smoke's third duel took 37 s for 14 turns before and after.

## Memory before / after

| 10 round trips (after a warm-up lap) | static | video | objects |
|---|---:|---:|---:|
| before | +6.6 MB | +46.5 MB | +1149 |
| after | +0.8 MB | +0.4 MB | +28 |

Cause and fix: `docs/perf/report.md`, "Memory leak - fixed".

## Size and fps

- `assets/art` 365 -> 447 MB on disk (source copies). What exports: +26.5 MB imported. Estimated payload 793.7 MB (`tools/build_audit.js`);
  the v0.4.6 zip was 724 MB, so the next zip should be about **750 MB - under 850**. If it ever needs to shrink: a lower figure height for
  the small roamers' frames, and the cut-outs at 900 px instead of 1080.
- Medium averages 12-17 ms everywhere (60-80 fps; Capital inside 16.6 ms is the tightest); Low 10-13 ms; battle 3.1 ms. The painted roamers
  cost the Dump 1 draw call (530 -> 531; budget raised to 540, documented in `docs/perf/budgets.md`) and ~34 MB of video memory, and cut the
  Capital's nodes by 410 and meshes by 341. p99 marks wander 16-30 ms run to run on identical code (noise on this laptop).

## Checks run

GUT all groups (root 276, core 1489 + 1 pending, ui 242, world 418); tour bot 281 spots / 0 errors (twice); story bot 90/90; walk smokes
Crosspath, Gainlands, D.N.A., Buffet, Dump, Capital OK, hub FAILS one check (inbox 4); first-battles OK (twice); gamepad OK (twice);
boss-rules OK (twice); structure budget met; memory round-trip smoke OK.

## Inbox items (Overnight Oct 28-29)

1. Captain Spotless (Capital roamer) - 3D knight until a FOE set exists, or use his NPC set.
2. The 0.45 s threat pose before a chase (`ZoneEnemy.THREAT_SECONDS`).
3. The roamers' warm rim (`ZoneEnemy.ROAMER_RIM`).
4. Hub walk smoke: Old Hob stands on the D.N.A. road's test line.
