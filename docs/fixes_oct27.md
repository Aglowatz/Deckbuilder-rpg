# Fixes Oct 27

Four parts, one commit each (pushed): Part 1 `fce11583`, Part 2 `106870c3`, Part 3 `00124655`, Part 4 `df5afddf`. Questions and the safe choices
taken: `docs/overnight_inbox.md`, section "Fixes Oct 27". Old saves load unchanged (no saved field added or renamed). No new art was generated;
no enemy intent anywhere.

Checks after the last part: GUT root 276, core 1419 (+1 known pending), ui/audio/characters 234, world 418 - all passing. Walk smokes: Crosspath
(Part 1), the D.N.A. (Parts 2 and 3), Gainlands, Buffet, the Dump, the Capital (Part 3) - all OK. The first-battles smoke (with its new gatekeeper
ending) OK. `perf_budget.sh structure` OK after every part; `perf_budget.sh frame` met for the D.N.A. (Part 2: Low 11.2 ms / Medium 12.8 ms) and
the battle. Crosspath Medium is 847-850 draw calls against an 840 line - the same on the code before today (850), so it predates these fixes
(inbox 2).

## Part 1 - The card pick after the zone gatekeepers

**Cause** (reproduced for Brick Bronson, Prudence Pallor, Moss Mulligan and Chef Fennel Gravois by mouse, keyboard and pad, with
`tools/run_gatekeeper_pick_probe.sh <mouse|key|pad>`, which wins each gatekeeper through the real `Session.complete_battle` path and plays what
follows in Crosspath). Three faults stacked:

1. **Order**: back in Crosspath the pick box opened on the first free frame, before the gatekeeper's post-fight lines (they wait for the loading
   screen to lift). The lines then ran *under* the box, and when they ended the first-win level-up opened through `_open_overlay`, which closes
   whatever overlay is open: the box vanished unanswered and the card was lost. Sometimes it showed up a fight later, with the previous
   gatekeeper's cards.
2. **Mouse**: `RewardPopup` set each card's `mouse_filter` to IGNORE before `CardView._ready()` reset it to STOP, so the card ate every click meant
   for the pick tile under it - a click on a card did nothing (and a click beside the cards skipped the pick: the frame continued on any click).
3. **Keyboard and pad**: the pick tiles were not focusable at all; the pad's focus started on Continue, so A skipped.

The offer itself was fine: `gatekeeper_pick_path` / `RewardPicks` always gave three cards of the gatekeeper's Path (no copy-cap or empty pool).

**Fix**: the town holds reward boxes until the fight's result lines have started (with a watchdog if the reveal is missed); the first-win level-up
of a gatekeeper (and of the graveyard boss) is queued after the box instead of opening over it; a pick closed by another overlay goes back to the
front of the queue (`RewardPopup.requeue_if_unanswered`, in town and zones). Cards take the click; Left / Right / 1-3 choose by keyboard; the pad
starts on the first card (`PopupFrame.pad_first_focus`) and A picks it (`PadClick`), then the focus moves to the button. The button reads **Skip**
until a card is chosen, then **Keep <card>**; a click beside the cards no longer continues. `RewardPicks` now fills a short pool from that Path's
other rarities, then Colorless, so a pick is never short or empty. The dungeon's elite / boss pick screen (`RewardsScreen`) uses the same offer
and already took clicks and the pad; it gained keyboard choice (Left / Right / 1-3, Enter takes) and a pad start on the first card. Side fix: a
click on the dialogue box itself now advances it (only a click on the world beside it did).

**Checked**: the probe in the editor (mouse, keyboard, pad: 4/4 gatekeepers each) and on an exported debug pack
(`tools/run_gatekeeper_pick_exported.sh <pck> <mode>`: 4/4 for all three). Tests `tests/ui/test_gatekeeper_pick.gd` (each gatekeeper offers three
of its Path; a click / key / pad picks and keeps; Skip takes nothing; a closed pick is re-queued; a short pool still offers three; the dungeon pick
by click, key and pad). The first-battles smoke now fights Brick Bronson by mouse for a few turns, wins, picks by mouse in Crosspath, then wins
Prudence Pallor and picks by pad.

**Shots** `docs/fixes_oct27/p1/`: before - `mouse_beefcake_pick_open` (the box over the running dialogue), `mouse_beefcake_picked` (nothing chosen
after the click), `pad_gourmand_pick_open`; after - `mouse_beefcake_picked`, `key_gourmand_picked`, `pad_refusemancer_pick_open` (focus on the first
card), `pad_necrocrat_picked` (Keep Body-builder focused).

## Part 2 - D.N.A. walls that popped in and out

**Cause**: the Oct 26 dollhouse cut (`cut_front`) faded every full-height wall nearer the camera than the hero's depth - anywhere in the zone -
with a 0.4 m ramp and a hard step. A wall flipped as the hero walked past its depth (the pop beside the hero), walls of other rooms vanished, and
a side wall next to the hero showed as a half-cut sliver with its brass rail hanging in the air.

**Now** (`dna_fade.gdshader` `room_cut`, `world/dna/dna_room_cut.gd`): the hero's region is the room they stand in, else the corridor or doorway
(`DnaLayout.links`, recorded as carved). A wall piece fades only when it stands where it hides that region's floor from the camera: the union of
the triangles camera -> each edge of the floor rectangle facing the camera (full fade within 0.5 m of it, solid again 1.3 m out), each weighted
by how far the camera is past that edge's line. So the near wall (and only the walls between the camera and the room) cut away; the room's side
and far walls and every wall elsewhere stay up; nothing fades by distance. Every term is continuous in the camera position, so walls ease as the
camera glides; a change of room eases over 0.6 s, blending up to three regions so a one-metre doorway crossed fast does not jump. Cabinets and
cubicle partitions keep their sight-line fade. The 10 m walls and 12 m shell of Oct 26 use the same cut.

**Checked** `tests/world/test_dna_room_cut.gd` (a GDScript copy of the shader's test): every room at the 3 zooms x 3 angles - walls hiding the
floor fade, the far walls stay; every room and corridor - the hero is never behind a standing wall; a frame-by-frame walk at walking speed
(4.9 m/s) through the zone, room to room - no wall changes by 0.2 or more in a frame (a pop was 1.0). D.N.A. walk smoke OK; frame budget met.

**Shots** `docs/fixes_oct27/p2/`: `before/after_mail_pop_a/_b` (the hero 0.6 m apart beside the mail room's west wall: before it flips, after it
stands, the same in both), `lobby_close`, `farm_a_far` (Far zoom, Classic), `records_mid` (Overview), `after_bank_close`.

## Part 3 - Signs in the walkways

**D.N.A.** Every sign, poster and memo was a board placed at a point and height with nothing holding it: the room-name signs hung in the middle of
the doorways, posters stood up to 3.5 m out on the floor. `DnaLayout._mount_signs` hangs each flat on the nearest free full-height wall face (one
per face, never on a sconce's face, nothing standing in front), facing into the room, name signs at 1.7 m and posters at 1.5 m; the cubicle memo
stays pinned on its cubicle partition. Their "Read the sign" spots follow (built from `layout.signs`). Moved (22):

| Sign | Was (x, z) | Now | Where |
|---|---|---|---|
| lobby main | 46.0, 46.2 (open floor) | 47.0, 45.5 | lobby north wall by the mail-room doorway |
| requisitions | 52.5, 52.0 | 56.0, 51.5 | lobby east wall |
| exit | 43.2, 59.4 | 43.5, 60.0 | lobby south wall by the gate |
| coffee | 22.5, 48.2 | 23.1, 47.5 | breakroom north wall |
| heal couch | 31.5, 58.4 | 31.5, 60.0 | breakroom south wall |
| time clock | 18.2, 53.5 | 18.1, 52.5 | breakroom west wall |
| suggestion box | 33.5, 50.2 | 35.0, 50.5 | breakroom east wall |
| cubicle farm A / B | 10.0 / 64.0, 43.8 | 9.5 / 63.5, 44.0 | farm south walls |
| quiz | 84.5, 39.1 (open floor) | 88.0, 40.5 | farm B east wall |
| printer | 56.3, 42.5 | 56.1, 42.5 | farm B west wall |
| mail room | 45.0, 28.25 (in the doorway) | 43.1, 27.5 | doorway's west jamb |
| puzzle | 45.0, 28.25 (in the doorway) | 42.5, 28.1 | mail room north wall beside the doorway |
| filing maze | 16.5, 21.8 (in the doorway) | 14.1, 22.5 | doorway's west jamb |
| matching | 2.5, 4.1 | 2.5, 4.05 | filing maze north wall (was 5 cm off) |
| elevator bank | 45.0, 24.0 (in the doorway) | 47.0, 24.5 | doorway's east jamb |
| elevator rule | 43.5, 16.2 | 43.1, 15.5 | elevator bank west wall |
| side dungeon | 48.5, 16.2 | 48.5, 16.05 | elevator bank south wall |
| records | 72.0, 23.8 (in the doorway) | 74.0, 25.5 | doorway's east jamb |
| filed complaint | 80.0, 23.8 | 79.5, 24.0 | records south wall |
| executive | 45.0, 13.8 (in the doorway) | 43.1, 14.5 | doorway's west jamb |
| main dungeon | 38.6, 2.0 | 38.5, 2.05 | executive floor north wall |

**Every zone**: `bash tools/run_sign_walkway_probe.sh` (`tools/sign_walkway_probe.gd`) loads each area and checks every icon sign against the area's
own `is_walkable` and its path bands (`paths`, `routes`, the hub's roads): mounted on something solid, standing on its own post off the paths, or
a problem (on a path, or floating). It found 14 more and they were fixed (`SignPlacement` steps a post off the path to its verge, trying open
ground on either side; the Capital hangs "wall" plaques flat on their building's face or the first solid surface behind them, and the map's edge
no longer counts as a wall behind a plaque):

| Zone | Sign | Was | Now |
|---|---|---|---|
| Gainlands | beefcake poster | on a path, 63.8, 69.5 | verge, 62.6, 67.3 |
| Buffet | hub main | on the path, 33.0, 57.0 | verge, 33.0, 52.1 |
| Buffet | the three district gates | on the path, x 26 / 54 / 74, z 33.0 | verge, z 31.2 |
| Dump | swap shed, fields, scrapmore, stable 2, landfill | on paths | verges beside them |
| Capital | grave main | floating 0.55 m in front of the north wall | flat on the wall |
| Capital | hungry main | on its stand on a route | stand beside the route |
| Capital | gate main / gate inside / facade shop 1, 2 / transit main / net hungry / ward main | up to 0.5 m off their walls | flat on them |

After: town 7, Gainlands 9, Buffet 15, D.N.A. 23, Dump 33, Capital 62 signs - 0 problems. Tests `tests/world/test_dna_signs_on_walls.gd` (on a wall
or partition, flat, facing the room, readable height, one per face, reachable) and `tests/world/test_signs_off_paths.gd` (no zone sign on a path).
The probe cannot tell a board on a wall from one sunk into it, so the moved signs were also checked by eye. **Shots** `docs/fixes_oct27/p3/`:
`before/after_dna_mail` (two boards in the doorway -> on the walls), `dna_lobby`, `buffet_gates`, `capital_grave`.

## Part 4 - Boons and curses say what they do

**Text**: `RuleBadges.for_boons` showed only the modifiers' labels - empty for every event boon of the dungeon list - so all of them read "A boon:
it fights on your side." `BoonText` (core) now writes the effect from the numbers ("Your units get +1 attack for the rest of this run." then
"Applies to you only."), names a curse a curse (red badge), and tells what the marker boons do (Elowen or Flex fights beside you; the Rotheart
starts with 6 less HP). The dungeon map's rules panel ("Boons and curses", each with its effect, curses in red), the event and challenge results
and the event choice buttons ("boon: Cut the Line (your units get +1 attack)") use it.

**Verified in play** (`tests/core/dungeon/test_boon_effects.gd`, `tests/ui/test_boon_in_battle.gd`):

- **Cut the Line** (the D.N.A.'s "Skip the queue", `atk=1`): taken through the real event resolver, your units have +1 attack in each of three
  fights of the run, defense unchanged; the next run starts without it. On the battle screen a 2/3 unit of yours shows **3/3**, the enemy's 2/3
  stays 2/3, and the badge says the sentence above. It already worked in the rules engine.
- **Every boon and curse of `data/dungeons/dungeon_content.json`** (20: Lucky Towel, Steam-Cleansed, Spotter Knows, Corrupted Feast, Impostor
  Exposed, Palate of the Panel, Marked 'Difficult', Cut the Line, Duly Authorized, Compost Courage, Fingerprints Everywhere, Seen Him First, Lab
  Notes, Perfect Smile, Crooked Little Hope, Know Your Enemy, Know the Machine, Never Again, The True Record, Pathwalker): each changes exactly the
  numbers its text names - the run's max HP and current HP, the fight's max and starting HP, a unit's attack and defense.
- Two real faults found and fixed: a **max-HP curse left current HP above the new max** (the map showed 13/12; now 12/12), and a boon's **"+N HP at
  the start of each fight"** (`STARTING_HP`, Primm's Castle "Unreflected") did nothing in a run because the carried HP replaced it - it now adds to
  every fight and is spent in that fight (it does not pile up). Gear with starting HP is unchanged in dungeons (inbox 3).

**Shots** `docs/fixes_oct27/p4/`: `before/after_rules` (the map's rules panel with Cut the Line, Marked Difficult and Duly Authorized),
`before/after_event` (the Take-a-Number Kiosk's choices).

## New tools

- `bash tools/run_gatekeeper_pick_probe.sh [mouse|key|pad]` - wins each gatekeeper and picks in Crosspath; `tools/run_gatekeeper_pick_exported.sh
  <pck> [mode]` - the same on an exported pack (`--export-pack "Windows Desktop"` makes a debug pack).
- `bash tools/run_sign_walkway_probe.sh [area ...]` - every sign of every area against its walkable ground and paths (`PROBE_ARGS=--all` lists them
  all with their verdicts).
- Dungeon map shots (`bash tools/shot.sh res://scenes/dungeon_map.tscn <name> --main=<zone> ...`): `--open=rules` and `--boons=Name|atk=1;Other|max_hp=-1`.
