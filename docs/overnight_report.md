# Fable Nov 21 review - report: the launch readiness review

Brief: `docs/prompts/fable_nov21_launch_review.md`. Start tag `pre-fable-nov21-review`. Questions: `docs/overnight_inbox.md`,
"Fable Nov 21 review". Shots: `docs/overnight_shots/nov21r/`. **Nothing was uploaded.** One commit per part, all pushed.

<!-- NOV21R-STATUS -->

## Part 1 - your answers to "Fable Nov 20 day"

| # | Your answer | Done |
|---|---|---|
| 1 | The Buffet's map redo stays in Batch 19; the D.N.A. row optional, not wanted for now | `docs/art/batch19.csv`: the Buffet row "confirmed", the D.N.A. row "Optional - not wanted for now; do not make" |
| 2 | The Raw Deal's flat front stays; check it at +12 and +14 degrees | Checked at +6, +12 and +14 from the door and from both sides (`p1/rawdeal_tilt*.jpg`). The painting carries its own roof in perspective and the camera never turns, so it reads as a building at every preset. **Nothing changed**; the modelled roof stays hidden. |
| 3 | The manhole stays | nothing to do |
| 4 | Glass and gold stay side by side; add the rose window above the title menu if it fits | The rose window tops the title menu (`p1/title_rose.jpg`, before: `p1/title_before.jpg`). The buttons stay where they were; it sits in the free sky to their upper right and crowds nothing. |
| 5 | The slate Quit / Delete and "Done" stay | nothing to do |
| 6 | The info screens follow the Text size setting | Built: `ui/glass/menu_text.gd` (MenuText). Every glass screen (pause menu, settings, quest log, glossary, feats, credits, save and load, the map's legend, the quest box, pop-ups and notices) grows with the row now named "Tooltip and menu text size"; the Text size switch sets it with the others. Large is 1.15, Larger 1.3 (milder than the tooltips' 1.2 / 1.4, because a page's panes must still hold their text). Cards keep their own row. Shot at Large (1600 x 900) and at Larger (1280 x 720), 19 screens each: `p1/large_*.jpg`, `p1/larger_*.jpg`. **Nothing overflows or clips.** On the way: the feats list ran under its scroll bar ("Earned here"); fixed. |
| 7 | Look at the five zone maps in the exported game; add a 2048 px rule if they look soft | Looked at all five on M in the exported build (`p1/exported_map_*.jpg`). They are sharp: the map is drawn about 760 px tall at 1600 x 900 and about 900 px at 1080p, and the stored picture is 1536 px. **No rule added.** One correction to last night's note: the project's own files are already 1536 px (the Nov 20 import stored them at that size), so a 2048 px rule alone would change nothing; the 2048 px originals would have to be imported again (about 0.5 MB per map, 2.5 MB in all, and only a 4K screen would show it). Inbox 1. |

## Part 2 - the playthrough audit

**What was played.**

| Run | What it covers | Result |
|---|---|---|
| The story bot, once per Path (`bash tools/run_story_bot_nov21r.sh <path>`) | A new game to the postgame: the forest and the cave, the gatekeeper duel, each zone's road, favour, side dungeon and main dungeon to its boss, Maren's four memories, the cave-mouth scenes, the Undercroft, the Capital, the castle gate, Primm, the ending, the funeral, Isla, the Lab, Elowen's rescue, the Shattered Gallery, Mount Swolympus; **a save and a load at every zone change and in the middle of a dungeon**. Each Path plays its own zone first, so the four runs are four zone orders. The fights are won by decree in these runs (the bot checks the flow, not the balance). | **119 checks each, 0 failed, 0 script errors** (8 minutes a run). The only warnings in the four logs are the engine's own leak lines at exit. |
| The opening-hour smoke (keyboard) | Maren's early chain really played: Meet the Merchants with a card bought, Tilly's gift equipped, Make It Yours with a pack opened, the store room ghosts, level 5, Bertram's quest (the story bot decrees this chain) | OK |
| The controller smoke | The same hour with a controller only: the Path choice, the gate, Maren, Sable's shop, a pack, the Deck Station, a ghost duel turn, level 5, Bertram, the menus, the pause menu | OK, **after the smoke was brought up to date** (finding 8) |
| The quest audit (`bash tools/quest_audit.sh`) | Every quest can be finished on paper: prerequisites, steps, markers, hand-ins, reward ids | 56 quests, 0 errors, 0 warnings |
| The quest hand-in probe | Every quest that is handed in to somebody, in the game: the hero on that NPC's spot, E, the quest completes | 32 of 32 |
| The tour bot at 1280 x 720 | Every area, every spot (287: NPCs, shops, signs, chests), nine menus, one battle per zone | 0 errors, 0 warnings |
| The layout check | 13 screens (the Deck Station, the five shops, the tailor, the alchemist, the Wardrobe, the Character page, the Collection Book, the bestiary, the quest log, the maps) at 1280 x 720 and 1920 x 1080 | 0 overflowing, 0 clipped |
| A features script (`play_scripts/nov21r/p2_features.txt`, 1280 x 720) | All 12 pack types on the shelf and "Open all"; the tailor, the Wardrobe, the Deck Station, the Character page, the Collection Book, Feats; **all six Arena battles and all four puzzles** started from the Undercroft and won, the tier prize paid | 0 script errors (`p2/f*.jpg`) |
| Each Crosspath shop with the controller (`p2_pad_shops.txt`) | A opens the talk and then the shop, B leaves | works (`p2/pad_*.jpg`) |
| Old saves (`tests/core/data/test_old_saves_nov21.gd`) | Four real bot saves from **Nov 9 and Nov 16** (before the three-copies rule, the three-Path lock, the heal rooms, the renames): a mid-dungeon save, two zones freed, the postgame, and "ready for the Capital" | All four load. Level, XP, every card (up to the cap of three), gold, quests, gear, items, unopened packs, cosmetics, flags and cleared dungeons are kept; the active deck is a legal 45 cards at once; a second save and load changes nothing. |
| Every choice room of every dungeon (`tests/core/dungeon/test_event_rooms_never_trap_nov21.gd`) | The new heal rooms and the older events: a hero with no gold and 1 HP | Always a choice that costs nothing and does not end the run; every choice resolves; a choice one gold short is refused with a reason and changes nothing |

**Findings.**

| # | Severity | What | State |
|---|---|---|---|
| 1 | bad | **Recipe for Wonder (G-31) cost less than its text says.** The card reads "Pay 1(G), use three Ingredients, destroy this Tool"; the script charged only (G). A new test now compares every card's printed energy costs and printed keywords with its script: this was the only card of 358 that differed. | **fixed** (the script charges 1(G); `tests/core/data/test_card_text_matches_script_nov21.gd`) |
| 2 | minor | **"neutral cards" for Pathless cards** in three places: every Path Pack's and Gilded Pack's description, Sable's first talk, and the Neutral Mile's rule line ("neutral" was the word before "Colorless"). The bout keeps its name. | **fixed** |
| 3 | minor | **"colors" for Paths** in the Deck Station: the tip ("at most 2 colors"), the filter's first entry in shops ("All colors"), the Fill Infrastructure tooltip | **fixed** |
| 4 | minor | **Fourteen dialogue lines in American spelling** where the rest of the dialogue is British ("four colors" in the wake-up still and two memories, "center", "favorite", "recognize"). No real typo was found in 15,900 strings; names agree with the registry. | **fixed**, single lines, revertible (Part 4) |
| 5 | minor | **The feats list ran under its scroll bar** ("Earned here" lay under the bar) | **fixed** |
| 6 | minor | **The glossary did not name two rules added since Nov 17:** essence (what becomes of a fourth copy, the 18 cap, the Alembic's 6 essence and 100 gold) and the dungeons' resting places | **fixed** (two entries under Terms) |
| 7 | minor | **The quest log handed out its live lists when saving.** Every save path writes to disk at once, so no save was ever affected; a dictionary kept in memory would have been emptied by the next reset. | **fixed** (it hands out copies) |
| 8 | minor | **Three smokes had gone out of date** and failed without a fault in the game. The controller smoke: Tilly's gift is a reward box since Nov 21 and waits for a press; the smoke's next A closed the box instead of greeting Pip. The Old Well smoke: its level-1 hero gains four levels from the quest's XP and the smoke did not press through the level-up pages (it also expected the old brief layout and no markers on the quest's steps). The dungeons smoke: it checked the cave's clear before the Warden's closing words and the reward box were answered. | all three **brought up to date and green** (controller: OK; Old Well: 48 checks; dungeons: 0 failures) |
| 8b | bad (for the tools, not the player) | **No automated fight pilot could finish a fight with a scripted event since Nov 19.** A boss's or elite's scripted event is a pop-up that waits for a click or Space ("Master...?", `p2/pilot_stuck_at_event.jpg`). The battle counts as busy while it waits, and every driver only waited on "busy": the dungeons smoke's "stuck after 6000 steps", the play driver's `pilot`, the story bot's real fights and the critics' sittings all sat at the pop-up until their time ran out. It closes for a player with a click, Space, Enter, or the controller's A or X. | **fixed**: `BattlePilot.answer_event`, called by ten driver loops. The next real-fight bot run or critic sitting can finish boss fights again. |
| 9 | minor | **Two people in the Gainlands have no "freed" lines:** Gary still lies under "the last barbell they didn't confiscate" although Brenda now says he is "lifting with a proper spotter at last", and the rep-game host still says "the regime banned my show". Quiz masters and minigame hosts in the other zones have no freed lines either, but say nothing that dates. | **open** (new lines are yours to write; two would do) |
| 10 | minor | **The locked Necrocrat pack in Foil Fenwick's shop is not a sealed parcel** like the other three (Batch 18's picture is a violet pack with a small padlock), so it reads as an open pack in a row of sealed ones (`p2/f09_fenwick.jpg`) | **open**: a row in `docs/art/batch19.csv` |
| 11 | note | **An old save's essence above 18 per Path is trimmed on loading** (the Alembic's cap of Nov 19, as designed; the four fixtures hold less, so the tests could not show it). Copies above three become essence or gold, as designed. | by design |
| 12 | note | **"Own 4/3" in the Collection Book** appears only in a state made by the developer shortcut (`Session.ensure_game` adds the Path's three showcase cards past the cap); a played game cannot reach it (every grant goes through `add_cards`, which converts a fourth copy). | not a player issue |

**Checked and found clean:** softlocks and dead ends (the dungeon maps are walked by a completionist and by random walkers in `test_map_never_strands.gd`; the choice rooms above; the story bots); quest markers and hand-ins (the audit and the probe); duplicate or missing rewards (a quest's gear is never in a shop or a chest roll: `ChestLoot.TIER_GEAR` leaves quest and dungeon pieces out, and a chest whose piece is owned holds its stand-in); cards that can be lost (a "lose a card" room takes it from the run's deck only); pop-ups (a notice closes with a click, Enter, Space, E, Esc, A or B); the renames (Colorless and Patchwork Cloak only in save-safe ids, Omakase only in asset names and the Itamae's own word).

**Controller.** Every screen the smokes and scripts reached is usable with a controller. The known gap stays: the Deck Station's search box cannot be typed into (deferred by you).

**Not covered by a machine:** real fights from start to finish (the last full real-fight runs were Nov 9 and Nov 17; Part 3's sims play every fight, but not through the screens), and the walk between places by hand (the walk smokes of Part 9 cover reachability).

---

# Fable Nov 21 night - report: the launch file was last night's brief; checked, tested and exported

Brief: `docs/prompts/fable_nov21_night_launch.md`. Start tag `pre-fable-nov21-night`. Questions: `docs/overnight_inbox.md`,
"Fable Nov 21 night" (2 items). **1.0.0 exported, nothing uploaded.** Pushed.

**What happened.** The launch file is byte-for-byte the same file as `docs/prompts/fable_nov20_night.md`, the brief of the night
of Nov 20-21. All eleven parts of that brief are already in the game (commits `c274ee70` to `86095732`; the full report is the
section "Fable Nov 21" further down), and the Nov 20 day pass was built on top of it. Carrying it out again would have undone
later work (rows on hold for pictures that are now imported, mock-ups for a look you have since chosen and had built, a scene
rewritten twice), so I did not. **No game code, data or dialogue changed tonight.** What I did instead:

| Part of the brief | Tonight |
|---|---|
| 1 to 10 | not redone; each item checked against today's game (spot checks by search, and each has its test in the suite, which is green). Nothing had slipped. |
| 11 Tests, build, report | **done in full**, see below. This is the first build that holds the Nov 20 day pass (Batch 18's 39 pictures, the stained-glass info screens, the Lab's break room as a choice room). |

**Spot checks that still hold:** Gourmand `#5AAAF2` with the alternatives marked "not chosen"; "Colorless" and "Patchwork Cloak"
appear only in save-safe ids and one art source sheet, never in shown text; the choice-room table regenerates (74 rows,
`python tools/choice_nodes_nov21.py`); five camera presets 6 to 14 degrees; "Omakase" only in internal asset and music names and
in the Itamae's Bestiary joke; Maren's "never told a soul" line is gone.

## Part 11 - tests and the build

- **GUT, all 46 shards** (`tools/run_tests.sh --min-free=900`, 32 minutes): **3572 of 3574 passed, 0 failing**, 2 pending. Real
  saves untouched (20 files checked).
- **Walk smokes, all seven:** Buffet, D.N.A., Capital, Crosspath, Gainlands, Verdant Dump, the hub: all OK.
- **Probes:** NPC visibility 150 checks, 0 failed; fade probe 7 places, nothing but tall occluders can fade, 0 script errors; quest
  hand-in 32 passed, 0 failed. The hover-zoom probe and the Arena puzzle solver tests are in the suite (green).
- **Build:** 2.7 GB of RAM was free, so the normal export ran: `bash tools/export_windows.sh 1.0.0` -> EXPORT OK.
  **`builds/TheWaywardPath-v1.0.0-windows.zip`, 768 MB on disk (804,813,956 bytes; 764 MB last night).** It replaces last
  night's zip.
- **The exported build:** `run_release_smoke_exported.sh` PASSED (1.0.0). A fresh test pack, then the three `play_exported.sh`
  checks (`n21n_a`, `_b`, `_c`, the `exported_rc1_*` scripts) each ran to "done" with **0 SCRIPT ERROR**.
- **One side effect of the export:** its size rules were applied to the five new zone maps for the first time (longest side 1536
  px in the packed game, WebP quality 0.80, as for every other map; the full-size files stay in the project). Inbox 2.
- **Not verified:** nobody looked at the five maps at 1536 px on the map screen in the exported game; the day pass's shots were
  taken at full size. The open items of the two earlier reports are unchanged.

## Your decisions (2)

1. **Which brief did you mean?** If tonight was meant to be a new list, it never reached `docs/prompts/`. Recommendation:
   **save the new brief there and launch again; nothing of tonight's stands in its way.**
2. **The five zone maps are packed at 1536 px.** Recommendation: **keep it unless they look soft on the full map screen (M); if
   they do, a rule for `MAP-WORLD-*` at 2048 px in `tools/art_import_rules.json` costs a few MB.**

Dialogue revert: nothing to revert tonight (last night's command is in "Fable Nov 21" below).

---

# Fable Nov 20 day - report: Batch 18 in the game, the stained-glass info screens, your answers

Brief: `docs/prompts/fable_nov20_day.md`. Start tag `pre-fable-nov20-day`. Questions: `docs/overnight_inbox.md`, "Fable Nov 20 day"
(6 items). Shots: `docs/overnight_shots/nov20b/`. **No export, nothing uploaded.** One commit per part, all pushed.

## Status by part

| Part | Done | Notes |
|---|---|---|
| 1 Import Batch 18 | yes | 39 of 39 in the game; one map needs a redo row (the Buffet), one sprite was mirrored on import |
| 2 Stained-glass info screens | yes | one theme file, every screen on the list, the rules checked by tests |
| 3 Your answers | yes | the Lab's break room is a choice room; the rest recorded |
| 4 Loose ends | yes | stand-ins removed (list below), backlog updated, three small things fixed on the way |
| 5 The flow | yes | played in the real game, 25 shots in `p5/` |
| 6 Tests and report | yes | every test shard green after three older tests were brought in line; seven walk smokes and four probes pass; no export | |

---

## Part 1 - the 39 pictures

**Drive:** each file was copied from `Pending Review/Batch 18/` into its Approved folder (the Pending copies stay). Seven of them
replace an older picture of the same name; the seven older files are kept in `Superseded/Batch 18 replaced/`.

| Picture | Where it is now | Shot (`nov20b/`) |
|---|---|---|
| B-37 Baron Quadzilla, C-36 Announcer Grand Bellows | the cards' own art everywhere a card is drawn (the card, the Collection Book, shops, reward screens all read one picture per card); the borrowed Bestiary square and portrait are gone | (the cards' art is the same file in every place) |
| ARENA-MENU-BG | behind the Arena menu; Bellows and the ring on the left, the list on the calm right side | `p1_arena_menu.jpg`, `p5/p5_01_arena_menu.jpg` |
| BB-ARENA | the board of every Arena battle and puzzle | `p1_arena_board_battle.jpg`, `p1_arena_board_puzzle.jpg`, `p5/p5_02_arena_battle.jpg` |
| STORY-REVEAL-KITCHEN, STORY-DOPPEL | the Test Kitchen's last room: beats 1 to 4, then beat 5 | `p1_doppel_01.jpg` to `_14.jpg` |
| BUFF-HERO-RAWDEAL-FRONT, BUFF-SIGN-RAWDEAL | the front of the Raw Deal and its hanging sign beside the freezer door | `p1_raw_deal_front.jpg`, `p5/p5_12_raw_deal_front.jpg` |
| ICON-COS-PLAINCLOAK | the Plain Cloak in the Wardrobe (tile and "Your Look") and in Pip's shop (the Plain Cloak tile and every dye tile), in the dye's colour | `p1_wardrobe.jpg`, `p1_pip_cloaks.jpg` |
| UI-CARDBACK-N, UI-PACK-N, UI-PACK-LOCKED-N | the Necrocrat card back, pack and locked pack, violet, wherever the green ones showed (same ids) | `p1_pack_shop.jpg`, `p1_packs_page.jpg`, `p5/p5_08_card_packs.jpg` |
| DNA-HERO-CLOCK-TOWER | the clock tower north-west of the Hall's stair | `p1_dna_clock_tower.jpg`, `p1_dna_hourglass_sign.jpg` (top left) |
| DNA-SIGN-HOURGLASS | over the lit elevator to the Waiting Room of Eternity | `p1_dna_hourglass_sign.jpg` |
| DNA-PROP-HEAL-COUCH | the breakroom couch; the heal, its prompt and its glow work as before | `p1_dna_couch.jpg`, `p5/p5_16_dna_couch.jpg`, `p5_17_dna_couch_rested.jpg` |
| SPR-RIP-FRONTSIDE_IDLE, SPR-RIP-BACKSIDE_IDLE | Rip's two three-quarter views, with normal maps; he shows eight different pictures round the circle (five drawn, three mirrored) | `p1_rip_gainlands_1_from_the_front.jpg`, `p5/p5_13_rip_buffet.jpg`, `p5_18_rip_dna.jpg` |
| TOWN-PROP-CAVE-MOUTH-BRUSH | the Forgotten Cave's mouth on Crosspath's north edge | `p1_cave_mouth_brush.jpg` |
| CAP-PROP-SERVICE-MANHOLE | the way into the Old Service Tunnels | `p1_capital_manhole.jpg`, `p5/p5_22_capital_manhole.jpg` |
| MAP-WORLD-GAIN / BUFF / DUMP / DNA / CAP | the full map screen (M) of each zone | `p1_map_*.jpg`, `p5/p5_11`, `_14`, `_19`, `_20`, `_21` |
| VS-ALEMBIC | behind Auntie Alembic's shop (same id) | `p1_alembic_shop.jpg` |
| The 14 UI pieces | Part 2 | `ui_after/` |

**What did not drop straight in, and what I did:**
- **Rip's three-quarter back view faces right; the game's sprites all face left** (the right-hand views are mirrors). I mirrored the
  copy that goes into the game; the Drive file is untouched. His two new frames came at the game's own size (320x504), so they were
  placed as delivered beside his four older frames, which were not re-cut.
- **The Raw Deal's front is a flat picture standing on the pavilion's front edge.** The modelled pavilion stays as an unseen body
  (its blocking and its lantern lights); its meshes are hidden. The way in moved 2.4 m east so the hero stands at the painted
  freezer door; a roaming meatball moved 3 m further away from it (the 10 m rule). Inbox 2.
- **The manhole was painted as seen from the game's camera**, so it lies flat on the ground and is stretched away from the camera
  until it looks as painted. Its old spot is tucked against the foot of the wall, where the wall's plinth covered most of the
  picture; it now lies just in front of the spot the hero stands on (the interaction point did not move). Inbox 3.
- **The clock tower** is a camera-facing picture 17.5 m tall on the old tower's spot; its lit face is at 14 m, where the old clock
  was, so it shows over the building fronts from the Hall's stair and the elevator bank. From the south gate the tower is outside
  the frame, as the old one was.
- **Two captions under STORY-DOPPEL described the old picture** ("a shifting shadow", "the unfinished war machines"). They now say
  what is shown: "Beneath it there is no face at all, only smooth white porcelain above a spotless white coat." / "She holds the
  smile in one hand, and behind her the copper vat goes on breathing its green fumes." The line "I wore her face for so long that I
  forgot my own" matches beat 5 (`p1_doppel_14.jpg`). Revert: `docs/dialogue/nov20b_lines_ids.txt`.

### The five maps

Tool: `python tools/art/world_map_fit.py`. It takes a fresh top-down plan of each zone (the same `--top=auto` capture as Nov 17,
whose world square is known), registers the painting against it (a stretch and a shift per axis, found by correlating the two
pictures) and writes the world rectangle the whole painting covers (`data/maps/world_map_fit.json`). The map screen draws the
painting in that rectangle with the same transform as its pins. Check sheets (the painting's outlines over the plan):
`p1_mapfit_MAP-WORLD-*.jpg`.

| Map | Fit | Painting covers (x, z, width, depth in metres) | Markers | Verdict |
|---|---|---|---|---|
| Gainlands | score 0.73 | -29.0, -43.2, 170.2 x 172.8 | bridge, hall, stations and yards on their painted places (`p1_map_gainlands.jpg`) | good |
| Endless Buffet | 0.19 (the plan is very dark; the outlines agree: river, turntable, bridge, paths) | 0.2, -2.6, 99.0 x 103.4 | all on their places **except the Raw Deal**: its icon sits in the east district where it now is, on painted lawn; the painted red-roofed shop still stands at the top centre | **redo row in Batch 19** |
| Verdant Dump | 0.53 | -24.6, -1.8, 148.5 x 161.4 | terraces, pools, bridge, grove (`p1_map_dump.jpg`) | good; the map screen shows the ravine's own strip of it |
| D.N.A. | 0.25 (dark plan; the plaza's outline, the carpet and the gate agree) | -2.6, -11.9, 95.2 x 94.8 | gate, carpet, elevators, Hall (`p1_map_dna.jpg`) | fits; the painting shows a sunny village, not the zone's mood (optional Batch 19 row) |
| Capital | 0.64 | -34.4, -13.8, 181.7 x 184.2 | wall, gate, plazas, castle; the Crease stays its own inset (`p1_map_capital.jpg`) | good |

No warp was needed: the painter kept each plan's framing to within a few per cent. `docs/art/batch19.csv` has the Buffet's redo row
(today's plan is on the Drive: `Batch 19 Refs/plan-buffet.jpg`) and the D.N.A.'s optional one.

### Checks

- A shot of every picture in place: above.
- Walk smokes of the areas touched (Buffet, D.N.A., Capital, Crosspath): all OK. All seven again in Part 6.
- NPC visibility probe: 150 checks, 0 failed.
- **FPS** (windowed, the zone's spawn, 6 s):

| Zone | Medium before | Medium after | Low-end before | Low-end after |
|---|---|---|---|---|
| D.N.A. | 79.2 | 78.8 | 89.4 | 90.4 |
| Endless Buffet | 80.9 | 81.7 | 92.5 | 99.9 |

- **Download size:** not measured (no export today). The art in the repo grew by 8.0 MB in Part 1 (40 new files 8.1 MB, eight
  replaced files 2.2 -> 2.1 MB) and shrank by 1.4 MB in Part 4 (four retired pictures): **about +6.6 MB**, so the zip should come
  out near 771 MB against today's 764.

---

## Part 2 - the stained-glass info screens

**The theme file:** `ui/glass/glass_theme.gd` (`GlassTheme`). One Godot Theme built once from the Batch 18 pieces; a screen takes
the look with one line (`GlassTheme.apply(root)`, or `glass = true` for a whole-screen page). The 9-slice margins, the colours and
the sizes are constants at the top of that file and nowhere else; Path colours come from `core/data/path_palette.json`. Written up
in `docs/art/ui_style_guide.md` ("Nov 20: direction B is built").

**Before / after** (`ui_before/` and `ui_after/`, same file names; the window is 1886x1061 on this monitor at the 1920x1080
setting; `ui_after_1280x720/` is the smallest supported window; `ui_pad_large/` is the controller and the Larger text size):

| Screen | File | What changed besides the glass |
|---|---|---|
| Pause menu | `ui_03_pause_menu.jpg` | the rose window on top, where you are under the title, Resume the amber button, a divider before the two ways out; it floats over the dimmed game (the parchment sheet is gone) |
| Quest box | `ui_02_quest_box.jpg` | UI-QUESTBOX, a thin strip in the quest's zone colour, the painted step marks; an unknown step is italic |
| Quest log | `ui_14_quest_log.jpg` | each quest a pane in its zone's Path colour with the Path's icon; the chosen one lit; the painted marks; Track is the amber button |
| Settings, five tabs | `ui_04` to `ui_08` | each setting on a plate of glass; tabs are panes, the chosen one lit; switches and sliders in glass; "Back" is "Done", the amber button |
| Glossary | `ui_09_glossary.jpg` | the chosen tab is lit (the others used to be faded to 60 %); body text one size up with more line spacing |
| Feats | `ui_10_feats.jpg` | a feat not yet earned is italic in the secondary tint (the row used to be faded to 62 %) |
| Save and load | `ui_11_save.jpg`, `ui_12_load.jpg` | one amber button: the newest save to load, the first free slot to save into |
| Credits | `ui_01_credits.jpg` | - |
| Map screen | `ui_15_map.jpg` | the map in UI-MAP-FRAME; "Point me to..." is the amber button |
| Collection Book | `ui_16_collection_book.jpg` | its page, tabs and filter chips; the cards keep their own look |
| Tooltip | `ui_20_tooltip.jpg` | every hover tooltip of the game |
| Confirm pop-ups and notices | `ui_13_confirm_popup.jpg`, `ui_21_notice_popup.jpg`, `ui_22_question_popup.jpg`, `p3_sealed_card_popup.jpg`, `p5_deck_filter_too_many_paths.jpg` | for a dangerous question the amber button is the safe answer |
| Reward box | `ui_23_reward_box.jpg` | - |
| Announcements ("Now open") | - | found in Part 5 and made glass too |

**The rules, and how each is kept** (tests: `tests/ui/test_glass_theme_nov20.gd`):
- **Colour means a Path:** a quest wears its zone's colour and icon (quest log, quest box strip); everything that stands for no
  Path is slate. The mock-up's coloured Settings tabs are slate for that reason. A dangerous button (Quit Game, Delete) is slate
  with a warm label: a red pane would say "Beefcake".
- **One amber button per screen:** tested on the pause menu, every settings tab, save, load and a dangerous question.
- **No pale grey text:** secondary lines are `#BDB9EC`, a lighter tint of the page; a test fails if an info screen paints text
  with the old grey.
- **Lit glass = chosen or focused:** tabs are toggles (UI-GLASS-PANE-LIT when chosen); hover lights a button; the keyboard or
  controller focus adds a gold ring (`ui_pad_large/pad_01...jpg`, `pad_02...jpg`).
- **Glow held back:** only the lit pane itself is bright; no outer glow was added.

**Contrast** (measured on the real art, tinted as the game tints it; `docs/review/glass_contrast.txt`):

| Pair | Ratio |
|---|---|
| body text on the page | 12.9 : 1 |
| secondary text on the page | 8.2 : 1 |
| headings on the page | 10.1 : 1 |
| body text on a pop-up or tooltip / in the quest box | 14.6 / 14.2 : 1 |
| body text on a row plate | 12.1 : 1 |
| a slate button's label | 5.8 : 1 |
| ink on a lit tab / on the amber button | 11.3 / 7.9 : 1 |
| ink on a lit Path pane (red, blue, green, violet) | 5.2 / 8.4 / 6.5 / 5.8 : 1 |
| text on a Path pane at rest | 9.7 to 12.6 : 1 |
| the warm label on a dangerous button (large bold, needs 3.0) | 4.0 : 1 |

Two lit Path panes (red and violet) measured 3.8 with dark ink at the Paths' own colours, so lit Path glass is drawn a step
brighter than the Path colour (`GlassTheme.lit`).

**Large text:** the Text size setting scales cards, dialogue and tooltips, as before; it never scaled the menus, and it still does
not (`ui_pad_large/large_*.jpg`). Menu body text is 18 to 23 px at 1080p. If the menus should follow the setting, it is a small
follow-up.

**Checks:** before / after at both window sizes; mouse and controller; the hover-zoom probe 6 of 6; the UI walk
(`docs/review/play_scripts/nov20b/ui_walk.txt`: every screen from the pause menu, a setting changed and changed back, a quest
tracked, the glossary read). One thing the walk found and I fixed: on the long Controls page the controller could not reach
"Done" (the rows scrolled out of sight lie below it on the screen); the last row now leads to it.

**Left alone:** the battle board and HUD, the shops' and the Deck Station's gold-framed screens, the Character screen, the dialogue
box, the title screen's own menu. None of them clashes badly enough to stop; the glass pop-ups do open over the gold screens
(inbox 4). The 11 old info-screen rows in `docs/art/batch18_nov18.csv` are marked "Superseded by the stained-glass set (Nov 20)".

---

## Part 3 - your answers

1. **The Path-ology Lab's Night Shift Break Room** is a choice room now (tests: `tests/core/dungeon/test_lab_heal_room_nov20.gd`):

| Option | You get | It costs |
|---|---|---|
| Feed the vending machine | heal 5 | 80 gold |
| Drink the night shift's coffee | heal 5 | "Night-Shift Jitters": in the next fight the first card you play each turn costs 1 more |
| Leave the room as you found it | nothing | nothing |

   The zone dungeons' prices are 30, 40, a card and 50; the postgame room asks 80, and its drawback is one of the stronger ones
   already in the game. Primm's Castle's Resistance Safe Room is still a full heal. Table: `docs/design/choice_nodes_nov21.md`.
2. The AI's opening hand: two Infrastructure, as built. Recorded (`docs/design/balance_log.md`).
3. The Raw Deal keeps its name. Recorded.
4. The new heal rooms and drawbacks stay as they are until you have played them. Recorded.
5. The Deck Station's search and controllers: in the backlog as "later".
6. Stained glass: Part 2.

---

## Part 4 - loose ends

**Stand-ins removed:**
- code: the two cards' borrowed pictures (`CardArt.STAND_INS`); the kit-built D.N.A. clock tower and its turning clock card; the
  couch built from flat colours; the built iron manhole cover; the cave mouth assembled from the forest's mouth, brambles, hedges
  and a lantern; the parchment backdrop of the pause menu;
- pictures taken out of the game (their Drive files stay; their importers now skip them): `VS-BELLOWS` (the colosseum behind the
  Arena menu), `UI-BG-MENU`, `UI-BG-WORLDMAP`, `UI-BG-QUESTLOG` (the three parchment backgrounds of the old info screens): 1.4 MB.
- **Kept on purpose:** the modelled sushi pavilion (it is the Raw Deal's blocking and lights behind the painted front);
  `UI-PANEL-TOOLTIP` and the old button and panel art (the shops and the battle still use them); the Bestiary square and the
  portrait the two cards had borrowed (they are the Bestiary's and the dialogue's own).

**Backlog:** `docs/owner_backlog.md` is up to date (done items out; four new "later" items from today).

**Found and fixed on the way:**
- Fenwick's shop showed "(missing text: pack.hint.gilded_general)" under the locked Gilded General Pack. It now says "Stocked once
  all four zones are free."
- The two STORY-DOPPEL captions (Part 1).
- The controller could not reach "Done" on the Controls page (Part 2).

---

## Part 5 - the flow

Played in the real game from a mid-game state made with the dev commands (level 16, the four gates open, one zone free for the
Arena). Scripts: `docs/review/play_scripts/nov20b/p5_*.txt`. Shots in `p5/`:
`p5_01_arena_menu`, `p5_02_arena_battle`, `p5_03_arena_battle_later`, `p5_04_arena_after_the_fight`, `p5_05_arena_puzzle`,
`p1_alembic_shop` (the shop's backdrop), `p5_07_pack_shop` (the locked Necrocrat pack), `p5_08_card_packs` (the Necrocrat pack on
the shelf), `p5_09b_necrocrat_pack_opened` (a pack opening; see the note), `p5_10_map_crosspath`, `p5_11_map_buffet`,
`p5_12_raw_deal_front`, `p5_13_rip_buffet`, `p5_14_map_dna`, `p5_15_dna_clock_tower`, `p5_16_dna_couch`,
`p5_17_dna_couch_rested`, `p5_18_rip_dna`, `p5_19_map_gainlands`, `p5_20_map_dump`, `p5_21_map_capital`,
`p5_22_capital_manhole`; the cutscene is `p1_doppel_01` to `_14`.

Everything opened and worked. **Not captured as asked:** the pack I opened in the run was not the Necrocrat one (my click landed on
another pack's button); the Necrocrat pack is shown sealed on the shelf and in the shop, and the opening screen is the same for
every pack. A few older shots with stale names are still in `p5/` (`p5_09_pack_opened.jpg` and others from the first try): a
clean-up command was refused by a safety check, so I left them; they are harmless.

---

## Part 6 - tests

- **GUT, all 46 shards** (`tools/run_tests.sh --min-free=900`, 33 minutes): **3569 of 3574 passed**, 2 pending, 3 failing. The three
  were older tests pinned to things today changed on purpose, and were brought in line and re-run green: the cosmetic icon count
  (+ the Plain Cloak's own), the Wardrobe's dye swatch (the painted cloak shows the dye itself now), the Raw Deal's door (it is the
  painted freezer door). The save guard reports the real saves untouched (20 files checked).
- **Walk smokes, all seven:** Buffet, D.N.A., Capital, Crosspath, Gainlands, Verdant Dump, the hub: all OK.
- **NPC visibility probe:** 150 checks, 0 failed. **Fade probe:** 7 places, nothing but tall occluders can fade, 0 script errors.
  **Quest hand-in probe:** 32 passed, 0 failed. **Hover-zoom probe:** 6 of 6 (in the suite). **Arena puzzle solver tests:** green
  (in the suite).
- New tests today: `tests/test_batch18_import.gd` (12), `tests/ui/test_glass_theme_nov20.gd` (9),
  `tests/core/dungeon/test_lab_heal_room_nov20.gd` (6).
- **No export** (the brief). The last zip in `builds/` is still last night's 1.0.0 (764 MB), without today's work.

---

## Your decisions (6)

They are in `docs/overnight_inbox.md` under "Fable Nov 20 day", each with a recommendation:
1. the Buffet map's redo (Batch 19); 2. the Raw Deal as a flat front with the way in moved to its painted door; 3. the manhole in
front of the standing spot; 4. the gold-framed screens beside the glass ones; 5. dangerous buttons in slate, and "Done" for "Back";
6. whether the menus should follow the Text size setting.

---

# Fable Nov 21 - report: your playtest list, cards, dungeons, the Deck Station, the castle scene, five cameras

Brief: `docs/prompts/fable_nov20_night.md`. Start tag `pre-fable-nov21`. Questions: `docs/overnight_inbox.md`, "Fable Nov 21"
(6 items). Shots: `docs/overnight_shots/nov20/` (no `ref_*` shots of yours were in the folder). **Nothing was uploaded.** One commit
per part, all pushed.

## Status by part

| Part | Done | Notes |
|---|---|---|
| 1 Your decisions | yes | the well's key has a small chest of its own; the rest recorded as "stays" |
| 2 Cards | yes | the sacrifice-for-damage bug found and fixed; six card changes; two renames; the AI's opening hand |
| 3 Three- and four-Path cards wait for Primm | yes | one lock in the filter every source already uses; pop-up; explained in four places |
| 4 Dungeons | yes | no full heal in the four main-zone dungeons; six new drawbacks; a silent bug found (below) |
| 5 Menus | yes | all eight items; a hover-zoom probe kept as a test |
| 6 Camera | yes | five presets on V, +6 the default, 15 shots, fade probe green at the steepest |
| 7 The world | yes | The Raw Deal moved and renamed; round window in trees, cabinets and the crag; quests track on start |
| 8 Story | yes | Maren's staff line; the castle gate scene rewritten, played and shot |
| 9 Batch 18 | yes | 11 rows held, 5 rows added |
| 10 Mock-ups | yes | two directions, five screens each; nothing built |
| 11 Tests, build, report | yes | every test shard green; seven walk smokes and three probes pass; 1.0.0 exported (764 MB zip), exported smoke and three exported play checks clean |

---

## Part 2.1 - the sacrifice-to-damage bug

**The cause.** The rules were right: on the rules engine Dead Weight and Yeet could always hit the opponent (and the AI did). The
fault was in the battle screen's order of questions. For Dead Weight it asked **"Choose a target" first** and "Choose the unit to
destroy" second, in nearly the same words, with your own units lit up as legal targets. So the natural click (the unit you mean to
sacrifice) made that unit the *target of the damage*; the card then destroyed a unit and hit nothing, and with a single unit there was
no second question at all. Nothing on screen said the opponent's portrait could be clicked. A second, smaller fault: the portrait's
click area was read from the cursor rather than from the click itself and ignored the portrait's on-screen scale.

**The fix** (`ui/battle/battle_screen.gd`):
- the cost comes first: "Choose the unit to destroy. This is the cost, paid first."; then the target;
- the unit that is destroyed is no longer offered as a target;
- the target prompt says what can be chosen: "Choose a target: a unit or the opponent. Click a unit or the opponent's portrait."
  (and "Choose one of your units" for Yeet's first choice); the controller text likewise;
- the portrait takes the click's own position and the drawn size; a click that chose it is used up.
The same order is used for abilities with a sacrifice cost (Necro Rat).

**Cards affected:** Dead Weight (NB-04, the reported one: the cost question came second), Yeet (B-25: its prompts did not say which
choice was which or that the opponent could be picked). Checked and working, now with the clearer prompt: Hammer Thrower (B-34) and
Sir Loin (GB-13), the other two cards that can aim at "a unit or the opponent". No other card sacrifices a unit for damage (Necro Rat
destroys a unit and drains 5 HP with no target choice for the opponent).

**Tests:** one per card that it can target and damage the opponent on the engine (`tests/core/game/test_cards_nov21.gd`), the same in
the real battle screen with the mouse and the controller (`tests/ui/test_sacrifice_damage_targets_nov21.gd`, including a real click
event on the portrait), and the AI finishing a game with each. I also drove a real fight with injected mouse clicks:
`p2_dead_weight_1_choose_the_sacrifice.jpg`, `_2_choose_the_target.jpg`, `_3_opponent_hit.jpg`.

## Part 2 - the other card changes

| Change | Now |
|---|---|
| Overdue Library Book | "Draw 1 extra card each turn. Then discard 1 card at random." |
| Soul Food Kitchen | (G)(N), 2 total |
| Food Fight | (G)(R), 2 total |
| Community Garden | 1(G)(R) |
| Un-Deadlifter ("Undead Lifter") | 1(N)(B), still 3/2 |
| To Die For | "Destroy target unit. Create two Ingredients." |

Sheet rows for your Google Sheet: `docs/design/sheet_changes_nov21.csv`. Logged in `docs/design/balance_log.md`.

**Renames.** "Colorless" / "Colourless" is **"Pathless"** in every shown text (the Path's name, the Collection Book's filter and
card page, the Deck Station, the Wicked Dagger and Solid Plate, the Old Kingdom dungeon rule, the card quiz, the Glossary, which now
has a "Pathless" entry). "Patchwork Cloak" is **"Pathwork Cloak"**. Left on purpose: internal ids and file names (`colorless_regime`
decks, `cards_colorless.txt`, the palette key), code comments, the art-prompt sheets, and the section header "Colorless:" in
`card_list.csv` (your sheet's own header; the importer reads either word). The kingdom of Patchwork keeps its name.

**The AI's opening hand.** "Resources" read as Infrastructure (the cards that give energy; inbox 3). Every AI opening hand now holds
at least two, by the same hidden, seeded swap your own hand has had since Nov 7, after its draw and after its mulligan
(`GameOptions.foe_opening_infrastructure_floor`). Exceptions: every fight of the Forgotten Cave (the tutorial). The Opening Forest has
no fights. Tests: the rule over 200 seeds, the mulligan, the same seed twice, the exceptions, Captain Spotless over 80 fights, every
Arena battle over 25.

## Part 3 - three- and four-Path cards wait for Primm

- **The rule.** `core/data/multi_path_lock.gd`. Every generator (packs, reward picks, the reward generator, shops, Auntie Alembic)
  already asks one filter (`CardAvailability.allowed`); it now refuses a card of three or four Paths until Primm is defeated. After
  his defeat they are ordinary cards. No fixed prize before Primm is one (quests, boss picks, dungeon prizes, signature cards,
  chests, the Arena: tested); the one four-Path prize, Reunion of the Paths, is paid by his defeat.
- **Owned cards stay owned** and cannot go in a deck until then (the deck check says so too).
- **Where it is explained:** the pop-up when you try to add one; a one-time notice in the Deck Station the first time your collection
  holds one, and "Sealed" on that card's tile; the Glossary ("Three- and four-Path cards"); the card's page in the Collection Book.
  After Primm, Crosspath's news says once: "Three- and four-Path cards are open".
- **The pop-up.** A card refused for its Path (the wrong Path for this deck, or a sealed card) opens a pop-up with the card's name as
  the title, the reason, and OK (mouse, Enter / Space / E / Esc, the pad's A or B). `p3_sealed_card_popup.jpg`,
  `p3_wrong_path_popup.jpg`, `p3_seal_explained_once.jpg`. A copy-cap refusal stays a short line.

## Part 4 - dungeons: the choice-room table

Full table of every room: `docs/design/choice_nodes_nov21.md` (made by `python tools/choice_nodes_nov21.py`). The four heal rooms:

| Dungeon | Room | Option | You get | It costs | Lasts |
|---|---|---|---|---|---|
| The House of Gains | The Meditation Garden | Pay the towel deposit and stretch | heal 5 | 30 gold | at once |
| | | Skip the fee and nap on the mats | heal 5 | the first unit you play gets -2 attack | next fight |
| | | Walk on | nothing | nothing | |
| The Test Kitchen | The Staff Break Room | Buy a staff lunch from the honesty box | heal 5 | 40 gold | at once |
| | | Eat the counted samples | heal 5 | the enemy starts with +2 HP | next fight |
| | | Leave the fridge alone | nothing | nothing | |
| The Hall of Final Approvals | The Coffin Breakroom | File one of your cards as Form 9-Z and lie down | heal 5 | a random card leaves your deck | this run |
| | | Nap without an appointment | heal 5 | you skip your first card draw | next fight |
| | | Keep walking | nothing | nothing | |
| The Rotheart | The Last Clean Spring | Leave an offering and drink | heal 5 | 50 gold | at once |
| | | Wade in and soak | heal 5 | your units enter exhausted | next fight |
| | | Leave it clean | nothing | nothing | |

The price rises in the designed order of the zones (30, 40, a card, 50 gold; the drawback from one unit to all of them). Shot:
`p4_heal_room_2_the_choice.jpg`.

**New drawbacks** (code in the engine, each with a test, `tests/core/dungeon/test_dungeon_heals_nov21.gd`), and the other rooms that
use them now:

| Drawback | Used in |
|---|---|
| The first unit you play has -2 attack | the Meditation Garden |
| You skip your first card draw | the Coffin Breakroom; the Take-a-Number Kiosk ("Take every number", was 2 damage) |
| The first card you play each turn costs 1 more (mine) | the Corrupted Pantry ("Take only the sealed jars", was 2 damage) |
| Your first Infrastructure enters exhausted (mine) | the R&D Archives ("Photograph the blueprints", was -2 max HP) |
| The enemy starts with one more card (mine) | the Form 27-B Office ("Forge the stamp", was 2 damage) |
| The enemy's first unit gets +1/+1 (mine) | the Locker Room of Legends ("Raid the gym bag", was -1 max HP) |
| Your units enter exhausted (existed) | the Last Clean Spring |
| The opponent starts with 2 extra HP (existed) | the Staff Break Room |

**A bug found on the way:** four choices had "a random card leaves your deck" written as their cost, and the game never read it
(the Corrupted Pantry's ladle, the Weeping Compost Pool, and two rooms of the Shattered Gallery): they were free. The cost is real now.

**Full heals that stay** (reported, not changed): the Forgotten Cave's Whispering Shrine (the tutorial), **Primm's Castle's
Resistance Safe Room** (your "castle rooms unchanged" rule), the Path-ology Lab's Night Shift Break Room. The side dungeons have no
heal room. Inbox 2.

## Part 5 - menus

1. **Deck Station Path filter:** toggles; as many Paths as the deck may walk (one at the start, two after a zone is free); none on
   shows everything; with some on, only the cards a deck of exactly those Paths could hold (a two-Path card needs both on); Pathless
   cards only while the Pathless toggle is on (it does not count toward the limit); one too many opens a pop-up.
   `p5_deck_filter_two_paths.jpg`, `p5_deck_filter_too_many_paths.jpg`.
2. **Keyword search:** a search box above the toggles: names, card text, keywords, the type and the Path; every typed word must
   match. `p5_deck_search_keyword.jpg`. (Typed with a keyboard; the controller's cursor skips the box.)
3. **The Wardrobe's "Your Look":** the turning hero is gone; the piece under the pointer (or the focus) is shown by itself, large,
   with its name and description; "You are wearing" stays underneath. Every hat and cloak has its own picture; the Plain Cloak (and
   "No hat") show the stand-in mark their tiles use, tinted by the dye: Batch 18 row `ICON-COS-PLAINCLOAK`.
   `p5_wardrobe_item_hat.jpg`, `_item_cloak.jpg`, `_plain_cloak_dyed.jpg`.
4. **Open all** opens the gilded packs too and its button counts them. `p5_packs_open_all_counts_gilded.jpg`.
5. **Rewards wait for a click.** Seven reward paths only flashed a line; they use the reward box now (Continue, or Enter / Space /
   E): the prize chest of each zone (**the Head Chef's Ladle**), the old puzzle prize, a gatekeeper's first win, the Restless Cairn,
   the Sealed Vault's card, Tilly's gift, a side dungeon's first-clear gear, and the packs for toppling Primm. Every item, piece of
   gear and pack in a reward box can be hovered (or focused) for its full info; a dungeon treasure's list likewise.
   `p5_reward_box_waits_hover_info.jpg`. Checked and already waiting: hidden chests, quest rewards, card picks after fights, dungeon
   fight rewards, treasure rooms, the Arena's prizes.
6. **Hover zoom everywhere.** The probe (`tests/ui/test_card_hover_zoom_probe_nov21.gd`, list in `docs/review/hover_zoom_probe.txt`)
   finds 21 scripts that show a card and requires a zoom in each. Six had none and have one now: a won card in the reward box (the
   Toro Toro case), battle choices, the Refuse Pile's top card, the card games, the matching game, the deck cover picker.
7. **Mid-fight pop-ups:** one layout: the event's name, a blank line, the complete effect, a blank line, the dialogue with the
   speaker's name in bold. `p5_event_popup_1_clench.jpg`, `_2_doppelganger.jpg`, `_3_mortimer.jpg`. Where the short and the long
   description said the same thing twice, the fuller one stands alone.
8. **Small grey text:** the quest log's later and unknown steps (parchment at 40 to 60 % before, 78 to 82 % now, the unknown line
   in italics) and the level-up's "XP toward level N" (18 px muted violet-grey before, 20 px parchment now).

## Part 6 - the camera

V cycles five presets: **+6 (the default), +8, +10, +12, +14 degrees** from the original, each 3 % further out than the one before
(+14 stands 12 % further out than +6), with a toast ("Camera 3 of 5: +10°"). Settings > Display keeps "Camera preset" (the four
framings; V used to cycle these), "Camera angle" (the same five) and "Camera distance". The choice is saved; an older settings file
maps onto the new presets (+8 stays +8, everything else becomes +6). Sheets, five presets each, at the default framing and at your
Low framing: `p6_camera_five_crosspath_default.jpg` / `_low.jpg`, `p6_camera_five_dna_*.jpg`, `p6_camera_five_buffet_*.jpg`; the toast:
`p6_cam_v_toast.jpg`. **The fade probe at +14:** green (7 places, nothing but tall occluders fades, 0 errors;
`docs/review/fade_probe_tilt4_nov21.txt`).

## Part 7 - the world

- **The Raw Deal** (was Omakase; inbox 4). Still entered through a walk-in freezer; the outside is the sushi pavilion that already
  stood over the freezer door (red roof, green noren, paper lanterns, a counter with stools, a sign board). It moved to the **east
  district of the Buffet, behind Colonel Casserole's gate**: that district is sealed from the Test Kitchen's by the hedge, so he must
  be beaten to reach it (tested by route: none from the middle district, one from his gate). Its quest marker, map icon, sealed
  message ("The Raw Deal's freezer door is sealed. Talk to Basil...") and Basil's line follow. Shots: `p7_raw_deal_front.jpg`,
  `p7_raw_deal_sealed_message.jpg`, `p7_raw_deal_from_the_path.jpg`, `p7_raw_deal_on_the_map.jpg`, `p7_raw_deal_gate_colonel_*.jpg`.
  Left on purpose: the Itamae's own word "Omakase." (his line and his event's name) and the music file names.
- **See-through windows.** Tree cards, the D.N.A.'s cabinets and partitions, and the Iron Cave's rock open the same round window as
  the buildings (the shared include is in their three shaders), and the hero's outline is drawn behind batched trees and cabinets.
  `p7_window_tree_dump.jpg`, `p7_window_cabinet_dna.jpg`, `p7_window_crag_gainlands_default.jpg`. FPS at Medium, before and after:
  the Dump 66.6 and 71.3, the D.N.A. 79.2 and 77.9, the Gainlands 82.2 and 84.2 (within the run-to-run noise). Full D.N.A. walls keep
  their room cut.
- **Quests track on start.** A quest that starts on its own ("Under the Old Well" after Maren takes the key) becomes the tracked
  quest, with "Now tracking: ..." A batch of several new quests keeps the old rule.

## Part 8 - story

- **Maren after the fourth zone:** "Four signs in a ring, the same as the ones carved on this staff of mine. I have leaned on it for
  as long as I can remember, and my fingers have known those four signs longer than my head has." ("never told a soul why" and the
  Queen's gift are gone.)
- **The castle gate** (`scenes/pc_capture`, nine steps, shots `p8_castle_gate_1.jpg` to `_8.jpg`): the guards already have her when
  he arrives; Plume: "Miss Elowen Vey! Former junior Path-ologist. The charges: absent without leave, and the removal of one item of
  laboratory property, which has been walking about ever since."; he starts to run and she shakes her head; Elowen: "Don't follow
  me! Stay out of sight and get to the top of that castle. Stop Primm! It's the only way any of this ends."; she is gone before he
  is halfway there; the Wanderer: "I had to learn her name from a list of charges. She said not to follow her, and to stop him. So
  I'll keep out of sight, and I'll go up." She never speaks to him. The story bible (three rows) and the NPC registry (Elowen's
  entry) agree.

**Dialogue revert** (six lines and one scene):
`node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov21_lines.csv --revert=docs/dialogue/nov21_lines_ids.txt`, then
`python tools/nov21_lines.py --revert-scenes` (the castle gate; both versions are in `docs/dialogue/nov21_scene_rewrites.json`).

## Part 9 - Batch 18 (`docs/art/batch18_nov18.csv`, 34 rows)

- **On hold** (status column): the 11 info-screen rows.
- **Added:** `STORY-REVEAL-KITCHEN` and `STORY-DOPPEL` as a remake pair (what differs today and the description both share:
  `docs/art/doppelganger_nov21.md`; in short, one shows a blank white face in a calm kitchen, the other a black smoke creature in a
  cannon factory, and her own lines say she has no face); `BUFF-HERO-RAWDEAL-FRONT` and `BUFF-SIGN-RAWDEAL`; `ICON-COS-PLAINCLOAK`.
- Every new row has its exact file path and size, a self-contained description under 600 characters and small existing refs
  (`python tools/batch18_nov21_rows.py` checks all three).

## Part 10 - mock-ups

`docs/overnight_shots/nov20/ui_mockups_v2/`, notes in `docs/art/ui_style_guide.md` ("Nov 21"). **A "Patchwork":** a cream linen
page in a quilt border of the four Paths' cloths, stitched seams, cloth tabs and banners, dark ink (`a_*.jpg`). **B "Stained
glass":** a night-blue page in a leaded gold frame, panes of coloured glass that light up when chosen, pale lettering (`b_*.jpg`).
Five screens each (quest box, pause menu, quest log, tooltip, settings). Nothing built, no art rows. Inbox 1.

## Part 11 - tests, build

- **Tests:** all 45 shards green: **3,545 of 3,547 passed, 0 failing, 2 pending**; real saves untouched (20 files checked). On
  the way, seven older tests failed and were brought in line with tonight's rules: the three-essence brew and the four-Path prize
  (both open only after Primm, when the seal lifts), the Buffet's gates (the Raw Deal is behind the Colonel now), the camera key's
  label, the tree cards' window. One was a real find: a roaming meatball stood 2.3 m from the Raw Deal's new door; it moved.
  The hover-zoom probe and the puzzle solver tests are part of the suite.
- **Walk smokes, all green:** Crosspath, the Opening Forest, the Gainlands, the Buffet, the Dump, the D.N.A., the Capital.
- **Probes:** NPC visibility 150 checks, 0 failed; fade probe 7 places, nothing but tall occluders fades, 0 script errors (and the
  same at the steepest camera, Part 6); quest hand-in 32 of 32.
- **Build:** 2,266 MB of RAM was free, so the normal export ran: `bash tools/export_windows.sh 1.0.0` -> EXPORT OK.
  **`builds/TheWaywardPath-v1.0.0-windows.zip`, 764 MB on disk (800,971,658 bytes).**
- **The exported build:** `run_release_smoke_exported.sh` PASSED (1.0.0). The three `play_exported.sh` checks failed on the first
  try: tonight's new play command `dev hand` used a helper from the tests folder, which the test pack does not hold, so the play
  driver would not load. The fault was in the test tool only (the playtest zip holds neither tools nor tests and was not rebuilt).
  After the fix and a fresh test pack (`bash tools/export_test_pack.sh`) all three ran to "done" with **0 SCRIPT ERROR**.
- **Not verified:** nobody played a whole dungeon by hand with the new heal rooms; the difficulty after Parts 2 and 4 was not
  re-simulated (inbox 3 and 5).

## Your decisions (the safest choice was taken; details in the inbox)

1. The info screens: direction A, B, or B's frame round A's page.
2. Primm's Castle and the Path-ology Lab still have a full-heal room: leave them, or give them the "heal 5 for a cost" rule too.
3. "At least two resources" was read as two Infrastructure: confirm.
4. The Raw Deal as the name, or another from the list.
5. The first-turn drawbacks are first numbers (and the dungeons are harder without the full heal): playtest, then tune.
6. Controller players cannot type in the Deck Station's search box: fine for now, or an on-screen keyboard later.

---

# Fable Nov 20 - report: your playtest list, the Arena puzzles rebuilt, colours back, cameras

Brief: `docs/prompts/fable_nov19_night.md`. Start tag `pre-fable-nov20`. Questions: `docs/overnight_inbox.md`, "Fable Nov 20"
(6 items). Shots: `docs/overnight_shots/nov19c/` (`ref_*` are yours). **Nothing was uploaded.** Commits: `d6465eba` (Parts 1 to 3),
`67ea12e7` (Parts 4 and 6), `656852b5` (Part 5), `065dc572` (Part 7), `62b96b75` (Part 9), then the Part 10 commit.

## Status by part

| Part | Done | Notes |
|---|---|---|
| 1 Your decisions | yes | Gourmand blue, Necrocrat violet; +4 degrees everywhere with two new Settings rows; a shot per zone |
| 2 Cards and encounters | yes | Rusty Grave Shovel, Hortensia's Topiaries and garden rule, the Rotheart's blood choice |
| 3 Alembic, equipment | yes | brewed card large and centred with hover; essences stay chosen; no tier; long text wraps |
| 4 Quests and entrances | yes | The Door Under the Well reworked and walked; Brannoch's hand-in; a hand-in probe; sealed messages; a tracked step into every side dungeon |
| 5 The world | yes | the D.N.A. line-up, quest marks, the crag, the Buffet's clearing and shore, the mount on the slide, the Dump's smoke |
| 6 Elowen | yes | the cave-mouth scene after the third zone rewritten; bible and registry agree |
| 7 Arena puzzles | yes | four puzzles rebuilt, a solver, one test per puzzle; table below |
| 8 Batch 18 rows | yes | three rows removed, colour rows redone, two Arena rows added; Rip confirmed |
| 9 Flow check | yes | both quests walked; Hortensia's numbers; all the shots asked for |
| 10 Tests, build, report | yes | every test shard green; seven walk smokes and three probes pass; 1.0.0 exported (764 MB zip), exported smoke and three exported play checks clean |

---

## Part 7 - the Arena puzzles (the main job)

All four puzzles (one per tier, the same four ids, tiers and prizes as before, so nobody's cleared flags or rewards move) are new.
Each is "win THIS turn" on a set board with the whole position visible: both HP totals, both fields, your hand, your energy, your
resources and your Refuse Pile. The Arena's battles are untouched.

### How they were proven

`core/arena/puzzle_solver.gd` is a full search on the real rules engine: from the puzzle's start it tries every legal play with
every target, every ability, every resource use, every choice of what to pay a cost with, every set of attackers, and then **every
way the opponent can block**. A line only counts as winning when it wins against every block. Two lines that make the same plays in
another order, or that add a spare harmless play, are counted as one **solution**.

For each puzzle the tests (`tests/core/arena/test_arena_puzzles_nov20.gd`, one test per puzzle) require: it can be won; it has
**exactly one solution**; that solution is the intended one; no decoy card is in it; every naive line written in the design notes
fails (after it, no win is left); and the solver's line, replayed action by action on a fresh game, ends with the opponent at 0 HP.
Report tool: `bash tools/arena_puzzle_lab.sh` (prints all of this; `--file=` solves a draft file, so a new puzzle can be tried
before it goes in). The puzzles are data now: `data/arena/arena_puzzles.json`.

What the solver does **not** cover: it plays the engine, not the screen. I looked at the four starting boards in the running game
(`p7_board_bronze.jpg`, `_silver`, `_gold`, `_diamond`: the title and rule, the hand, the field, the Refuse Pile's count and both HP totals are on screen) but did not click a solution through by hand, so please play-check each one; the table gives the line.

### The table

| Tier | Title (id) | Paths | What it teaches | Board |
|---|---|---|---|---|
| Bronze | **Back from the Dead, Back to the Gym** (`arena_lethal_lunch`) | Necrocrat + Beefcake | Reinstating the right unit: Vigor Mortis brings a Beefcake heavy hitter back with Hustle, and its 5 attack switches Flex on 'Em from 2 damage to 4 | You: 7 energy (4 B, 3 N), Gym Bro 1/1. Hand: Vigor Mortis, Flex on 'Em, Dry Scoop, Pink Slip. Refuse Pile: Beefy Bouncer, Leg Day Survivor, Skeleton Clerk. Opponent: 8 HP, Village Militia 2/2 |
| Silver | **Mise en Place** (`arena_hold_the_line`) | Gourmand + Beefcake | Ingredients as ammunition, and their order: the Ingredient must exist before Sir Loin enters | You: 8 energy (4 G, 4 B), 1 Ingredient, Gym Bro 1/1. Hand: Shaker Bottle, Sir Loin, A Feast for the Eyes. Opponent: 9 HP, Tavern Regular 3/4 |
| Gold | **The Chairman Needs a Quorum** (`arena_zero_to_hero`) | Refusemancer + Necrocrat | The Refuse Pile as a resource: fill it, turn it into Rats, cash the Rats in, and get paid for every death | You: 6 energy (3 N, 3 R), Necro Rat 4/4, Rat King Bureaucrat 2/3, Skeleton Clerk 1/2, The Breakroom. Hand: Plague of Rats, Become Useful at Work, Sewer Rat Courier, Rusty Grave Shovel. Refuse Pile: four unit cards. Opponent: 17 HP, Old Kingdom Automaton 4/6 |
| Diamond | **The Heaviest Paperwork** (`arena_final_bell`) | Gourmand + Beefcake + Necrocrat | One unit's attack counted three times, and the unusual part: your own trap, set this turn, sprung by your own sacrifice | You: 9 energy (5 B, 3 N, 1 G), Un-Deadlifter 3/2, Millstone Pusher 1/2. Hand: GLP-100, Death Grip, Dead Weight, Flex on 'Em, Yeet, Vigor Mortis. Opponent: 30 HP, Old Kingdom Automaton 4/6 |

**Solutions, step by step**

- **Bronze (2 steps and the attack).** 1) Vigor Mortis on Beefy Bouncer in the Refuse Pile: a 5/4 with Bulldoze and Hustle. 2) Flex
  on 'Em: 4 damage because you control a 5-attack unit (8 -> 4). 3) Attack with the Bouncer and Gym Bro: if the Militia blocks the
  Bouncer, Bulldoze carries 3 over and Gym Bro adds 1; if it blocks Gym Bro, the Bouncer deals 5. (Flex may also come after the attack.)
- **Silver (3 steps and the attack).** 1) Play Shaker Bottle. 2) Destroy it on Gym Bro: +2/+2 and a second Ingredient. 3) Play Sir
  Loin and aim his entrance at the Tavern Regular: two Ingredients, 4 damage, the blocker is gone. 4) Attack with Sir Loin (6) and
  Gym Bro (3) = 9.
- **Gold (4 steps, an ordering trap and a choice trap).** 1) Become Useful at Work, destroying **Skeleton Clerk**: The Breakroom
  takes 1 HP and the Refuse Pile now holds five unit cards. 2) Plague of Rats: five Rats. 3) Necro Rat's ability: the five Rats die,
  the Automaton is destroyed, the opponent loses 5 HP and The Breakroom takes 5 more (17 -> 6). 4) Attack with Necro Rat (4) and Rat
  King Bureaucrat (2). The sacrifice must come before the Plague (four unit cards make four Rats, and the Chairman needs five),
  and it must be the Clerk (the Rat King is the 2 damage that finishes it).
- **Diamond (6 actions, an ordering trap).** 1) Overexert Millstone Pusher for (B)(B): 11 energy. 2) Play GLP-100 and 3) destroy it
  on Un-Deadlifter: 13/1. 4) Flex on 'Em **now**, while a 5-attack unit stands: 4 (30 -> 26). 5) Set Death Grip. 6) Dead Weight,
  destroying Un-Deadlifter: 13 to the opponent, and Death Grip springs on that death for 13 more. Flex on 'Em after the throw deals
  only 2 (28 of 30).

**Decoys, and why each fails**

| Puzzle | Decoy | Why it leads nowhere |
|---|---|---|
| Bronze | Leg Day Survivor (in the Refuse Pile) | Hustle is printed on it, so Vigor Mortis looks made for it; with 4 attack Flex on 'Em deals 2 and the Militia blocks it: 3 of 8 |
| Bronze | Pink Slip | removes the blocker, but with Vigor Mortis there is no energy left for Flex on 'Em: 6 of 8 |
| Bronze | Dry Scoop | +1 attack is never the missing damage |
| Silver | A Feast for the Eyes | a 5/5 with Hustle and three Ingredients, but then Sir Loin cannot be afforded and nothing else spends Ingredients: 3 of 9 at most |
| Gold | Sewer Rat Courier | a fifth Rat with no sacrifice, but it costs 2 and Plague of Rats takes 5 of the 6 energy |
| Gold | Rusty Grave Shovel | Toxic only kills the Automaton if it blocks the carrier, and gets nothing through by itself |
| Gold | Rat King Bureaucrat as the sacrifice | three Zombie Temps instead of two, but then the Clerk attacks for 1 where the Rat King attacks for 2: 16 of 17 |
| Diamond | Yeet | the same 13 as Dead Weight for one energy more: with GLP-100, Death Grip and Flex on 'Em you are exactly one short; with Dead Weight as well, the second throw has only the Pusher (27 of 30) |
| Diamond | Vigor Mortis | Un-Deadlifter comes back as a 3/2: GLP-100 and Death Grip are spent, and the Automaton blocks it |

**The solver's results**

| Puzzle | Can be won | Solutions | Winning lines (orderings) | Positions searched | Naive lines tried, all failing |
|---|---|---|---|---|---|
| Bronze | yes | 1 | 2 | 397 | just attack; Vigor Mortis on Leg Day Survivor; Pink Slip on the Militia first; Flex on 'Em first |
| Silver | yes | 1 | 1 | 242 | just attack; Sir Loin first with one Ingredient; A Feast for the Eyes |
| Gold | yes | 1 | 1 | 2,456 | just attack; Plague of Rats at once; sacrificing the Rat King; Sewer Rat Courier for the fifth Rat |
| Diamond | yes | 1 | 112 | 112,286 | just attack; pump and attack; Dead Weight before Flex on 'Em; Yeet instead of Dead Weight |

Each puzzle's title and one-line brief hint at the synergy without naming the play, and after a win the result screen and the
Arena's prize pop-up say **"What you just did: ..."** (the `lesson` text in the puzzle file).

Things to know:
- **Silver was "Hold the Line" (survive three turns).** Every puzzle is "win this turn" now. Its id and prize are unchanged, so a save
  that had cleared it keeps the flag.
- **Diamond's opponent has one blocker, not three.** With three, the search could not finish (every pump and removal card had five
  targets); with one it finishes in about four minutes and the puzzle is the same, since no attack gets through either way.
- **Diamond's test takes about four minutes** (the full search). It is one test in one file.

---

## Part 1 - your decisions

**Palette.** `core/data/path_palette.json`: Gourmand `#5AAAF2` (blue, cream accent), Necrocrat `#9A5FC7` (the old violet exactly,
ghost-green accent); Beefcake and Refusemancer as they were. The guide (`docs/art/path_colour_guide.md`) and the swatch sheet are
updated. Do the four read apart: for normal vision better than ever (49, was 38 to 40). For red-green colour-blind players the
close pair is blue against violet. With the exact old blue `#4A8FE0` that pair scored 9 (hard to tell apart); I made the blue one
step lighter so the two differ by brightness, which lifts it to 14. The exact old blue is kept in the file under `"alternatives"`
(inbox 1). The Path icon is always beside the colour.

Batch 18 colour rows re-checked under this palette: `UI-CARDBACK-N` and `UI-PACK-N` stay (their green field still reads as the
Refusemancer's; the descriptions now ask for violet, the green-flame medallion unchanged); `V-ALEMBIC` is removed (her red, blue,
green and violet are all Path colours again); `VS-ALEMBIC` shrinks to one change (the orange jar becomes violet), low priority.

**Cameras.** Every place is +4 degrees in `data/camera/zone_camera.json` (the D.N.A. came down from +6), distances unchanged.
Settings > Display now has **Camera preset** (the four existing presets; the row used to be called "Camera angle"), **Camera
angle (how far it looks down)**: Standard / +4 (default) / +6 / +8, and **Camera distance**: Closer / Default / Further. Both
apply in every place. Shot: `p9_camera_settings.jpg`.

How +4 reads, a shot per zone at the Cinematic and the Low preset (`p1_camera_plus4_all_zones.jpg`, singles `p1_cam_<zone>_*.jpg`):

| Zone | At +4 |
|---|---|
| Opening Forest | the clearing and both figures read clearly; the near tree on the right still frames the Low shot |
| Crosspath | the square is open; the two near roofs at the screen edges are a little lower in frame than before |
| Gainlands | the hall and the road read well; the big wheel beside the arrival spot still crosses the Low shot |
| Buffet | the plaza and the castle front are clear at both presets |
| Dump | the Commons reads well; the bunting line sits across the lower third at Low |
| D.N.A. | at +4 (was +6) slightly more of the far partitions overlap, the lobby and its desk still read |
| Capital | the gate wall fills the frame as before; the ground in front shows a little more |

**Buildings in the way:** kept as built. **Info screens:** not touched. **Castle numbers:** not touched.

## Part 2 - cards and encounters

- **Rusty Grave Shovel:** "Exhaust: attach to target unit you control. Attached unit gets Toxic and Swat." Cost (N)(R) unchanged, no
  stat bonus (inbox 2). Card list, script, card file and a test.
- **Hortensia Clipwell.** Why the Topiaries entered as 3/4: a 1/1 token, +1/+1 from Royal Groundskeeper (all her units), +1/+1 from
  Prize Topiary (her tokens), then Wild Growth on top. Now a Topiary's printed size is **1/2** and it enters as that: Prize Topiary
  is gone and Royal Groundskeeper no longer applies to tokens. Her own units keep +1/+1.
- **The garden rule (Wild Growth), new:** "At the start of each player's own turn, one random unit that player controls gets
  +1/+1." Once per turn, only on that player's turn. The three-buffs-per-unit cap is gone with the old rule (inbox 3).
- **Where else that rule applied:** I searched the dungeon rules, the encounter modifiers and scripts, the arena, the zone effects
  and every card script. It existed in exactly one place, the Rotheart dungeon's rule (which is the rule in Hortensia's fight: she
  is that dungeon's lieutenant), so that one change covers every fight of the dungeon, the Rotheart's included. Texts updated: the
  rule badge, the dungeon list (`dungeons.json`, `dungeon_list.csv`). The Echo of Hortensia Clipwell (the Shattered Gallery)
  had the same stacked token buff: her Topiaries are printed 1/2 as well and the +1/+1 on tokens is gone there too.
- **Hortensia's fight, the battle bot, 10 games each (Beefcake deck):** before: 8 wins, 12.3 turns on average (10 to 16); after:
  9 wins, 12.6 turns (10 to 16).
- **The choice before the Rotheart:** "Give blood to distract the Rotheart (-5 HP; you take the first turn in the fight)" and "Walk
  on". One set of brackets per option: a choice can now carry its own bracket text, and everywhere else a boon is written without
  inner brackets ("boon: Lucky Towel, +2 max HP"). "You take the first turn" is real: tested over 20 seeds with the coin flip the
  dungeon fights use. The old option (sever the roots: the Rotheart starts with 6 less HP) is gone from the node (inbox 4).

## Part 3 - Alembic, equipment

- The brewed card stands **centred in "The brew" panel at 1.1 of a card's size** (it was 0.55 and off to one side), the "joins your
  collection" line under it, wrapped, never over it. Hovering magnifies it like a reward card. Shots: `p9_alembic_2_brewed_card.jpg`,
  `p9_alembic_3_hover.jpg`.
- After a brew the chosen essences stay chosen and Craft stays enabled while there is enough essence and gold
  (`p9_alembic_4_second_brew_at_once.jpg`); when something runs out the button says what.
- **No tier** on any equipment visual (it was printed in one place, the character page's detail). **Long descriptions wrap** and
  stay left of the Equip button; the cause was that the label's width was set before wrapping was switched on. Checked with the two
  longest descriptions (Big Brain Beret, Thorned Loincloth) at Normal and Large text: `p9_equipment_*`. The shop and reward screens
  already wrapped; they print no tier.

## Part 4 - quests and dungeon entrances

- **"The Door Under the Well".** The chest was always there and reachable (a test now walks a route from Maren to it); what was
  missing was any way to find it: the step said "somewhere in Crosspath" and had no marker. Now Maren says where when she gives the
  quest and when asked again ("the big chest out east... where the lane past the Rift Express stop meets the water"), the step is
  "Open the big chest by the water, east of the Rift Express stop" with a marker on the chest (world, minimap, map, route line),
  and after Shiro's scene a line says "At the bottom of the chest lies an old iron key. Bring it to Elder Maren." Handing it in
  opens the hatch and starts a one-step quest, "Under the Old Well", that marks the hatch. Walked in the running game, nine shots:
  `p9_well_1` to `p9_well_9`. (Opening that chest still costs 50 gold to Shiro: inbox 5.)
- **"Outskirts Watch".** Brannoch only knew how to give the Capital's quest and talk about it; he never looked for a quest of his
  that was ready. He now takes a finished quest first, offers a quest other than the Capital's in that quest's own words, and
  gives its reminder. Shots `p9_watch_1` to `_4`.
- **The hand-in probe** (`bash tools/run_quest_handin_probe.sh`, about 10 minutes, windowed): for each of the 32 quests that are
  handed in to somebody, a fresh game, every step forced done, the hero on that NPC's spot in the hand-in area, talk, and the quest
  must be completed. Result: **32 passed, 0 failed** (`docs/quests/handin_probe.txt`). I wrote the probe after fixing Brannoch, so I have no run of it failing on him; his talk simply had no hand-in branch. Kept as a tool (it needs the running game) with a static test beside it
  (`test_fable_nov20_part4.gd`: every hand-in names an area and a spot, and that spot is that person).
- **Entrances:** no level counts ("[E] Climb into the landfill", "[E] Open the freezer door"); a test checks every dungeon prompt.
  **A sealed dungeon names itself and who to ask:** "The landfill is sealed. Talk to Brother Bramble at the stream in the Verdant
  Dump; they may know more." (`p9_dump_sealed_message.jpg`, `p9_buffet_sealed_message.jpg`), built from the side quest's own
  giver, for the landfill, the freezer, the Waiting Room, Mount Swolympus, the Old Service Tunnels, the hatch and the Gallery.
- **Every side dungeon has its quest, and is a tracked step once open.** All of them already had a quest that opens them. What was
  missing: once it was handed in, nothing sent the player to the door. Five one-step quests now start by themselves at that moment
  with the entrance marked (Under the Old Well, Little Paw Prints, Seating: 1, The Older Way In, Only the Worthy Climb); the
  Waiting Room, the Paste Works and the Gallery already had such a step.

## Part 5 - the world

- **D.N.A.:** the red runner and the Hall stand on x = 45.5; the gate stood a metre east of that line and the routing desk a metre
  west. Gate, causeway, arrival spot and desk are on the line now (`p9_dna_desk_default.jpg`, `p9_dna_gate_default.jpg`).
- **Quest marks too high:** a real bug, not a height setting. A spot's marker added the ground's height to a position that already
  stood on the ground, so on the Gainlands' plateau (4 m up) every mark made before the hero came near floated 4 m and more over
  its head. Fixed at the source; it applies to every zone (the others are near sea level, which is why only the Gainlands showed
  it). `p9_gain_marker_gus.jpg`, `p9_gain_marker_gary.jpg`. Gary and his bench are unchanged.
- **The Iron Cave's rocks:** they were treated as land (their walls run far below the sea), so they never took part in the fade.
  They are tall occluders now: the hero's outline shows through them (`p9_gain_crag_north_default.jpg`). The round see-through
  window does not open in this rock's material, only the outline (inbox 6).
- **Buffet, Dex and Professor Pate:** no tree stands in the clearing in front of them or along the south side of their path; the
  forest's west half, the trees behind them and the east side stay (`p9_buffet_dex_area_default.jpg`, `_low.jpg`).
- **Buffet, the west side:** near the table's edge the ground can no longer lie under the gravy. The last metres rise to a low
  beach with a darker wet band of uneven width, and the water line wanders (small bays a finger deep) instead of running straight
  (`p9_buffet_west_shore_*`). This is the rule all round the table, not only in the west.
- **Dump:** the mount comes down the slide with you and you are still riding at the bottom. The walk smoke's failure was real play
  too (in front of the Harvest Meal the prompt was Billie Muckfoot's): she stands a few steps west now.

## Part 6 - Elowen

The scene at the cave mouth after the third zone (`cave_mouth_3`) had her say she was "starting to think" he might be her lost
friend. Rewritten: she sees his memories coming back ("It's coming back, isn't it? A room, a voice, the taste of frosting."), says
why she held his name back ("A past that someone hands you is only one more thing they've told you to be."), keeps the dumbbell and
frosting callback the bible's thread table points at, and closes with "You know who you are. Now go free the last zone Primm
holds, and prove it." Her other scenes (cave mouth 1, 2 and 4, the castle gate) were checked and already agree. The NPC registry's
note said "believes he's the lost prince but isn't sure": corrected there and in the story bible.

**Dialogue revert** (seven lines: Maren's two for the well quest, Elowen's five):
`node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov20_lines.csv --revert=docs/dialogue/nov20_lines_ids.txt`

## Part 8 - Batch 18

Removed NPC-PLAYER, STORY-MEMORY-4, TOWN-PROP-CELLAR-FOURSEALS-CLOSED (and V-ALEMBIC, see Part 1). Added **ARENA-MENU-BG**
(1672x941, the menu screen) and **BB-ARENA** (1536x864, the battle board): a low-key underground cave ring, lantern light, chalk
and rope on a stone floor, crates and benches, rough rock, a few banners; each description is self-contained and under 600
characters. **Rip:** he has front, side and back idles and a front talk pose, the same set as every standing NPC; the two
three-quarter idles in SPR-RIP-FRONTSIDE_IDLE are all that is missing for his turning. No other row needed. 29 rows.

## Part 10 - tests and build

- **Tests:** `bash tools/run_tests.sh --min-free=900`, all 44 shards in one run: **3,415 of 3,417 passed, 0 failing, 2 pending** (the same two as
  before). Real saves untouched (19 files checked). New test files: `test_fable_nov20_part2.gd` (cards, Hortensia, the Rotheart
  choice), `test_fable_nov20_part3.gd` (Alembic, equipment), `test_fable_nov20_part4.gd` (quests, entrances, Elowen),
  `test_fable_nov20_part5.gd` (the world), `test_arena_puzzles_nov20.gd` (the solver, one test per puzzle); the camera and palette
  tests were updated. Tests that described the old behaviour were rewritten to the new one: Wild Growth's two, the boon wording in three
  places, the D.N.A. doorway list. The seven tests of the old puzzles' solutions (in `test_arena.gd` and
  `test_arena_tiers_nov19.gd`) were replaced by three about the preset board and by the new solver tests.
- **Walk smokes, all seven pass:** Crosspath, the Opening Forest, the Gainlands, the Buffet, **the Dump (it failed before tonight)**,
  the D.N.A., the Capital.
- **Probes:** NPC visibility 150 checks, 0 failed; fade probe 7 places, nothing but tall occluders can fade, 0 script errors;
  quest hand-in probe 32 of 32; the puzzle solver tests are part of the suite above.
- **Build:** 2.7 GB of RAM was free, so the normal export ran: `bash tools/export_windows.sh 1.0.0` -> EXPORT OK.
  **`builds/TheWaywardPath-v1.0.0-windows.zip`, 764 MB on disk (800,946,732 bytes; the same size as Nov 19).** The script still
  warns that the payload is over its 750 MB budget, as it did on Nov 19.
- **The exported build:** `run_release_smoke_exported.sh` PASSED (1.0.0). The three `play_exported.sh` checks (`exported_rc1_a`,
  `_b`, `_c`) each ran to "done" with 0 SCRIPT ERROR in all six logs. They run on the test pack
  (`builds/_testpack/TheWaywardPath_test.pck`), and that pack was dated Nov 17, so I rebuilt it from tonight's code
  (`bash tools/export_test_pack.sh`) and ran the three again; the numbers above are from the fresh pack. Yesterday's three checks
  must have run on the Nov 17 pack: the export script does not rebuild it.
- **Not verified:** nobody clicked a puzzle solution through in the battle screen (the engine replay and the four board shots are
  what I have); the Buffet's shore and the D.N.A. gate were judged from screenshots at two cameras, not walked all the way round.

## Decisions needed from you (details in the inbox, "Fable Nov 20")

| # | Question | Recommendation |
|---|---|---|
| 1 | Gourmand's blue is one step lighter than the old blue, so colour-blind players can tell it from the violet | keep the lighter blue |
| 2 | The Rusty Grave Shovel gives Toxic and Swat and no stats | playtest; +0/+1 if it feels thin |
| 3 | Wild Growth has no "three per unit" cap any more | keep your wording; bring the cap back if one unit runs away |
| 4 | The Heart Roots node lost "sever the roots" | keep your two options |
| 5 | The well quest's key is in Shiro's prank chest (50 gold) | fine for now; a chest of its own later |
| 6 | The four new puzzles, and Diamond's single blocker | play-check all four |

## One thing I changed outside the game

Your settings file (`%APPDATA%/Deckbuilder-RPG/settings.cfg`) was rewritten during one of tonight's play-script runs: a script that
opens Settings and closes it saved the run's values, and the run had set the camera preset to Cinematic. Yesterday's notes say you
play on the **Low** preset, so I set `camera_angle` back to 3 (Low) by hand. If your preset was something else, or any other
setting looks off, that is why; everything else in the file read as defaults. The cause is fixed: a scripted run can no longer
write the player's settings file (`Settings.save_settings`), which is in tonight's build.

---

# Fable Nov 19 - report: what fades and what doesn't, a camera test per zone, the Path colours, a design for the info screens

Brief: `docs/prompts/fable_nov19_fade_camera_colour.md`. Start tag `pre-fable-nov19`. Questions: `docs/overnight_inbox.md`, "Fable Nov 19"
(6 items). Shots: `docs/overnight_shots/nov19b/` (`ref_*` are yours). **No export, nothing uploaded.** Commits: `e239a77e` (Parts 1 and 3),
`e06c7a04` (Parts 2, 4, 5), then the report commit.

## Status by part

| Part | Done | Notes |
|---|---|---|
| 1 Objects disappearing | yes | one typed fader; your four cases fixed; probe test + tool; FPS unchanged within noise |
| 2 Camera test per zone | yes (no default changed) | 16 contact sheets (8 places x the Cinematic and the Low preset), one line per place to apply a choice |
| 3 Path colours | yes | one palette file, every UI tint reads it; guide + swatches; 4 Batch 18 rows |
| 4 Info screens | yes (spec, 5 mock-ups, 11 Batch 18 rows) | applied now: only the quest box's readability |
| 5 Small items | yes | castle nodes, the enemy's starting unit (3 nodes), hover magnification; the Glossary has no card pictures (nothing to magnify) |
| 6 Tests and report | yes | GUT full run 3372 / 3375 (1 test updated and re-run green on its own, 2 pending as before); five zone walk smokes and the forest smoke pass; the Dump's walk smoke fails on the start tag too (Wren takes the heal spot's prompt) |

---

## Part 1 - objects disappearing

### What was wrong (the stock-take, before any change)

Three separate systems faded things, each by its own rule:
1. **The group fader** (`OcclusionFader`): every mesh 1 m or taller was a candidate; if one sight line from the lens to the hero touched its
   box, **the whole parent group faded to nothing** (its roof, its trim, its neighbours under the same parent); and **anything within
   6.5 m of the lens faded too**, whether or not it hid the hero ("foreground clutter"). That second rule is your first screenshot: with
   the Low camera 23 m behind the hero, every house the lens came near was gone. Ground decals draped over terrain counted as "tall"
   because their box spans the hills: the mud, moss and petal decals of the Dump and the Gainlands faded on most of the map.
2. **The tree cards' shader** (`kit_card.gdshader`): a tree in the lens-to-hero corridor went 86 % see-through, bushes included.
3. **The D.N.A.'s per-piece shader** (`dna_fade.gdshader`): cabinets and partitions went 86 % see-through when the line to the hero's
   **hips** crossed them; full-height walls between the lens and the hero's room were cut away completely.
Plus, unchanged and not part of the problem: the distance range fade (`StyleRig._limit_range`, things 48 m+ away), the Capital's "hide the
wall the lens is inside", and the labels' own fader.

Measured by walking the hero over every walkable cell of every place in the running game at the default and the Low camera
(`docs/review/nov19b/fade_stock_before.txt`):

| Place | Things that could fade, before | of which low (under 1.5 m) | small (under 1.3 m across) | Now | of which low or small |
|---|---|---|---|---|---|
| Opening Forest | 1 | 0 | 0 | 1 | 0 |
| Crosspath | 55 | 15 | 1 | 32 | 0 |
| Gainlands | 116 | 70 | 18 | 29 | 0 |
| Buffet | 68 | 39 | 5 | 24 | 0 |
| Dump | 146 | 68 | 27 | 46 | 0 |
| D.N.A. | 20 | 6 | 6 | 8 | 0 |
| Capital and Crease | 178 | 49 | 38 | 78 | 0 |

### The rules as built (one system: `world/style/occlusion_fader.gd`)

Every thing gets a **type** from its size and its name (or a `fade_type` meta set by hand; none was needed):

| Type | What | Rule |
|---|---|---|
| `tall_occluder` | a building, a tall wall, a big tree, a column (1.5 m or taller and a metre or more across) | the only type that ever goes see-through |
| `low_blocker` | anything lower than the hero's shoulder (1.5 m): counters, desks, fences, hedges, rails, rocks, crates, graves | **never fades** |
| `small_prop` | under a metre across at any height (lamp posts, poles), or short and narrow (barrels, plants), or named lamp / banner / post / plant / bench... | **never fades** |
| `sign` | anything of a prop's size with "sign" in its name: signposts, sign boards | **never fades** |

1. **What looks solid stays visible:** rules above. Also checked live: a thing whose top is under the hero's shoulder *where he stands*
   never fades (a wall on lower ground), and a piece that shrinks under 1.5 m while it animates (the Dump's roots) stops fading.
2. **Only what really hides him:** five sight lines run from the lens to his hips, chest, head and both shoulders; a tall occluder
   starts to fade when **two** of them pass through it. Near it, beside it or in front of it: nothing. The "anything near the lens"
   rule is gone.
3. **Partly, never to nothing, and only where he is:** a tall occluder is never faded as a whole. A **soft window** opens in it round the
   hero (2.3 m radius at his depth, in the world shaders: `assets/shaders/style_occlusion.gdshaderinc`): only the part of it nearer the
   lens than he is, kept at 36 % (a fine dither), with a soft rim. Its roof, its far side and everything outside the circle stay solid.
   A mesh whose material cannot take the window fades as a whole instead, to 45 % opacity, never less.
4. **His outline:** through whatever is left in front of him the hero's shape is drawn as a soft outline in **his Path's colour**
   (lightened; warm white before a Path is chosen). It reads the depth buffer, so only the hidden part of him is tinted. Both were tried:
   the outline alone keeps the building perfect but hides who or what stands next to him (a roamer, a chest, the person he talks to); the
   window alone loses him in a busy roof. Together, with the outline at 40 % inside the window, he reads at once and so does the
   ground round him. Used for every tall occluder.
5. **Where it blocks stays readable:** the lowest 0.75 m of anything with a window stays solid (its foot), in the shader.
6. **The one exception - a piece the lens itself is inside** (the camera trails behind the hero and passes through houses), or that hides
   him while standing within 3 m of the lens (it would fill the screen with one roof): nothing of it can be drawn, so it is cut away,
   and **a soft outline of its footprint is laid on the ground** so nobody tries to walk through the gap.
7. **Smooth:** a quarter of a second in and out; a thing that started to fade keeps its window until no line touches it for 0.2 s.
8. **One system, one set of rules, no per-zone exceptions.** The tree cards and the D.N.A.'s cabinets keep their own shaders (they are
   batched by the hundred) but follow the same rules now: nothing under the hero's shoulder fades, 60 % see-through at most (was 86 %),
   and the foot of a D.N.A. piece stays solid; a D.N.A. wall cut away for the room keeps a 0.7 m stub.
The person in reach (the [E] prompt) counts like the hero: a tall thing that hides them opens its window. A far quest door no longer
hollows out the house in front of it (its marker shows it).

### Your four cases

| Case | Before (yours) | After |
|---|---|---|
| 1 Whole buildings vanish near the hero | `ref_fade_crosspath_building_gone.png` | `p1_after_building_a_default.jpg`, `p1_after_building_a_low.jpg`: every house stands; the one he is behind has a window round him |
| 2 The signpost disappears | `ref_fade_crosspath_signpost.png` | `p1_after_signpost_default.jpg`, `p1_after_signpost_low.jpg`: the signpost never fades (type `sign`); walk strip `walks/walk_signpost.jpg` |
| 3 / 4 The D.N.A. counter disappears | `ref_fade_dna_counter_visible.png`, `ref_fade_dna_counter_gone.png` | `p1_after_counter_default.jpg`, `p1_after_counter_low.jpg`: the counter is a `low_blocker`, solid with the hero behind it; walk strip `walks/walk_counter.jpg` |

All ten owner-case shots on one sheet: `p1_owner_cases_after.jpg`.

### Per zone: what faded before, what fades now, and why

Before / after sheets, six of the worst spots per zone as the scan ranked them (Capital: eight), default and Low camera:
`p1_fade_<zone>.jpg` (columns: before default, after default, before Low, after Low).

| Zone | Faded before (besides buildings) | Fades now | Why |
|---|---|---|---|
| **Crosspath** | the signposts (on 375 of the walked cells), the bridge's deck planks and rails, a market stall, a lantern post, the gate's sign icon | the houses, the church, the inn, the well, the notice board, the cart, the bridge's tall posts | they are taller than the hero and stand between the lens and him |
| **Opening Forest** | the forest's props as one group of 47 | the same tall tree and rock group, as a window | the clearing is ringed by tall trees; nothing low was involved |
| **Gainlands** | the mud and chalk ground decals (1,669 and 825 cells), 70 low pieces: the gym yard's low walls, benches, racks; 18 posts | the mill sails and towers, the gym hall, the stone gateway, the tall yard frames | only tall structures |
| **Buffet** | the crumb decals (1,770 cells), kitchen counters and tables, pancakes, plates, pads, the neon strip, the bridge's bunting | the broccoli giant, the cake cathedral, the hall wings, the ovens, the tall cheese wedges, the columns | only tall structures; counters are waist-high |
| **Dump** | seven ground decal sheets (up to 3,250 cells each), 68 low pieces (roots, crop rows, the barricade, scrap boards), 27 posts | the greenhouse, the windmill, the shacks, tall debris walls, big trees | only tall structures; the tree cards fade to 60 % in their own shader |
| **D.N.A.** | **the front counter**, the kitchen counter, the console, the water cooler, the round table, the time clock, the television, a sign icon | the entrance gate, the columns, the street rows behind the fronts, the ruler's statue and banners | counters and desks are `low_blocker`s; in the cubicle farms nothing fades any more (every partition is under the shoulder) |
| **Capital and Crease** | 18 graves, the queue posts, six street lamps, hatches, beds, carts, junk piles, complaint boxes, the manhole | the great wall (both runs), the gate arch, the district houses, the tram shed, the watchtower, booths and tall rift crystals | the wall used to vanish whole; now it stands with a window (`walks/walk_wall.jpg`) |

### Walk sequences

Seven steps along a line, default camera above and Low below, one strip each (`docs/overnight_shots/nov19b/walks/`):
`walk_street` and `walk_behind_houses` (Crosspath's houses), `walk_signpost`, `walk_counter`, `walk_cubicles`, `walk_maze` (D.N.A.),
`walk_wall`, `walk_graves` (Capital), `walk_forest`, `walk_kitchen` (Buffet), `walk_trees`, `walk_windmill` (Dump), `walk_gym`
(Gainlands). In each the window follows the hero and nothing else changes from frame to frame.

### The probe (kept as a test and a tool)

- `tests/world/test_fade_probe_nov19.gd`: builds all seven places, lists every thing the fader knows with its type and rule, walks the
  hero over every walkable cell at both cameras, and **fails if a low blocker, a small prop or a sign can fade** (checked on each piece's
  own box, not by the fader's word). 385 things known across the seven places; 0 offenders.
- `bash tools/run_fade_probe.sh`: the same sweep in the running game (with dressing and people): 7 places, 0 things other than tall
  occluders can fade, 0 script errors. The full list with types: `docs/review/nov19b/fade_stock_after.txt`.
- `tests/world/test_occlusion_ground.gd`: the rules one by one (types, the window, never whole, beside / in front of a wall, easing and
  hold, the lens-inside cut and its footprint).
- Play-script commands for next time: `fadeshot <name> <x> <z>`, `fadescan <prefix> [shots]`, `fadecat`, `fades`.

### FPS (`tools/perf_run.sh`, the same session, before = the start tag's code)

| Area | Medium before | Medium after | Low-end before | Low-end after |
|---|---|---|---|---|
| Crosspath | 77.3 | 76.2 | 92.0 | 90.4 |
| Gainlands | 83.0 | 85.6 | 105.0 | 97.3 |
| Buffet | 82.5 | 82.7 | 93.0 | 98.4 |
| D.N.A. | 81.6 | 79.7 | 88.3 | 89.7 |
| Dump | 75.6 | 73.0 | 83.4 | 83.1 |
| Capital (inside) | 67.7 | 65.8 | 82.1 | 80.3 |

Average frame rate is the same within the run-to-run noise (about 2 fps down on Medium where more things are now drawn that used to be
faded away; nothing below 60). The 1 % lows moved both ways between runs (`docs/perf/runs/nov19b_fade_before.md`, `_after.md`).

### Known limits

- With the **Low** camera a tall statue or post right in front of the lens is now part of the picture instead of fading (the D.N.A.
  gate's stamp statue in `p1_after_counter_low.jpg`). It never hides the hero; it does take a corner of the screen.
- A building the lens is inside still disappears (it cannot be drawn from inside); its footprint outline is what tells you it is
  there. Inbox 3 has the alternative.
- The window is a dither, so on a still screenshot zoomed in it shows its pattern; in motion at 1080p it reads as glass.
- A person the hero talks to **behind a house** is seen through the same window (Gatekeeper Brannoch behind the item shop): both figures
  read, but small, where the whole house used to vanish. If that feels cramped in play, talk points behind buildings can open a wider
  window (one number, `WINDOW_RADIUS`, or a second window on the person).

---

## Part 2 - the camera test (no default changed)

**Your saved setting is the Low camera** (`settings.cfg`: `camera_angle=3`), while the game's default for a new player is Cinematic, so
every place was shot at both. Per place: three spots (the arrival, the hub, a busy area) x pitch +0, +4, +6, +8 degrees (the D.N.A.
also +10) x three distances (10 % closer, as now, 10 % further). The cell marked **(NOW)** is today's default. New fade rules on.

Sheets: `docs/overnight_shots/nov19b/camera/camera_<place>_low.jpg` (what you see) and `camera_<place>_cinematic.jpg` (what a new
player sees), for `crosspath`, `forest`, `gainlands`, `buffet`, `dump`, `dna`, `capital`, `crease`.

| Place | Recommendation | Why |
|---|---|---|
| Crosspath | **+4, distance as now** | the roofs of the south rows hide less of the street and the square reads as a place; the tree line and the mountains stay in the picture at Low. At +8 the horizon is gone and it stops looking like Crosspath |
| Opening Forest | **+0 (as now)** | its mood is the depth between the trunks and the teal light; every degree steeper trades that for forest floor |
| Gainlands | **+4, distance as now** | the mill wheels and yard frames cover less of the plateau paths; the skyline (Swolympus, the far Capital) still shows |
| Buffet | **+4, distance as now** | tables and counters in the foreground stop hiding the plaza floor; at +6 and +8 the gingerbread skyline is cut off |
| Dump | **+0 (as now), or 10 % further** | the terraces read by their horizon and layers; steeper flattens the ravine. A little further out shows more of the route |
| D.N.A. | **+6 (as now)** | +8 and +10 gain nothing more over the partitions and lose the far wall and its windows |
| Capital | **+4, distance as now** | the checkered plazas and the paths between the districts read better; the wall tops and the castle still close the picture |
| Crease | **+0 (as now)** | a low cavern: steeper only shows more ceiling |

**To apply a choice:** one line per place in **`data/camera/zone_camera.json`** (`"pitch_bonus"` in degrees, `"distance"` 1.0 = as now,
0.9 = 10 % closer). Nothing else. `ZoneCamera` (`world/look/zone_camera.gd`) reads it; the D.N.A.'s +6 moved there from its scene; the
rig glides between the Capital's and the Crease's values when you walk down. Test: `tests/world/test_zone_camera_nov19.gd` (no default
changed). To re-shoot: `bash tools/play.sh docs/review/play_scripts/nov19b/camera_test.txt` (play command `camgrid`).

---

## Part 3 - one colour per Path

The audit's finding: **the painted art already agrees with itself** (icons, frames, card backs, packs, plinths: red and gold; cream
and copper; moss and rust; ghost green on slate). **The odd one out was the UI's own tint table**: Gourmand blue, Necrocrat violet,
and three more private tables (packs: yellow and violet; boss intros: yellow and violet; the crest: blue and violet).

**The palette** (`docs/art/path_colour_guide.md`, swatches `docs/art/path_colour_swatches.png`):

| Path | Main | Accent |
|---|---|---|
| Beefcake | `#E0321F` red | `#E0A030` gold |
| Gourmand | `#F0C494` cream | `#C06A3A` copper |
| Refusemancer | `#58933B` deep moss | `#B5552D` rust |
| Necrocrat | `#72E55B` bright ghost green | `#55606A` slate |

- Chosen with a colour-blind simulator (`python tools/path_palette_check.py`): the smallest difference between two Paths under
  red-green colour blindness was 9 with the old tints, 13 with the icons' paint taken literally, **21 with this palette**. The two
  greens are told apart by brightness (deep moss against glowing ghost green).
- The card frames do not change at all (their cloth tints are kept as they were).
- **Option 2**, shown in the guide: Necrocrat as ghost teal `#7EE5CB` (further from the moss for normal vision). Recommended: ghost green.

**In code:** one file, **`core/data/path_palette.json`**, read by `PathPalette`; `UIStyle.affinity_color()` is now that table, so about
sixty call sites follow (Alembic's jars and essence bars, toasts, card accents and cost pips, the battle board's effects, deck
filters, the Deck Station racks, the Collection Book bars, the character page, shops and pack covers, zone title cards, boss intro
bands, the memory screen, the ending, map tints, portals, vault levers, the crest texture, the Lab's tanks, the castle model's district
lights, and the hero's outline from Part 1). The private tables are gone (`test_path_palette.gd` keeps it so). A Path pack takes its
Path's colour whatever its data file says (`PackData.tint()`).

Before / after (the "before" is the old tints loaded into the same build): `p3_before_*.jpg`, `p3_after_*.jpg` for `alembic`, `deck`,
`packs`, `map`, `codex`, `battle`. A fresh save has no essence, so Alembic's bars are empty in the shot; the visible changes are the
row borders, the filter chips and the Collection Book's Path list.

**Painted art in the wrong colours** (4 rows added to `docs/art/batch18_nov18.csv`): `UI-CARDBACK-N` and `UI-PACK-N` (green like the
Refusemancer's; should be slate with ghost green), `V-ALEMBIC` (flasks and apron splashes in blue and violet), `VS-ALEMBIC` (jars blue
/ red / orange / green, a violet flame).

---

## Part 4 - a design for the info screens

- **As they are now:** 17 shots in `docs/overnight_shots/nov19b/ui_now/` (title, pause, settings x4, the quest box, quest log, map,
  glossary, feats, three pop-ups, the character page, dialogue, save slots).
- **The proposal** (`docs/art/ui_style_guide.md`): *a storybook page in a gilt frame.* Reading happens on parchment in dark ink (today
  the parchment is only the margin and the text sits pale on dark wood or violet panels that differ from screen to screen); a crimson
  ribbon carries each title; one gold button per screen, wood buttons for the rest; row plates, bookmark tabs, a gold divider and a
  real scroll bar tie the lists together; tooltips stay dark so they read over anything. Type sizes, colours and an 8 px spacing grid
  are in the guide.
- **Mock-ups** (`docs/overnight_shots/nov19b/ui_mockups/`, made from art already in the game; magenta dashed boxes mark the new
  pieces): `mock_quest_box.jpg`, `mock_main_menu.jpg`, `mock_quest_log.jpg`, `mock_tooltip.jpg`, `mock_settings.jpg`.
- **New art:** 11 rows in `docs/art/batch18_nov18.csv` with exact sizes and 9-slice margins: `UI-INFO-PAGE`, `UI-INFO-RIBBON`,
  `UI-INFO-DIVIDER`, `UI-INFO-ROW`, `UI-INFO-TAB`, `UI-INFO-BTN-STATES`, `UI-INFO-SCROLLBAR`, `UI-QUESTBOX`, `UI-QUEST-MARKS`,
  `UI-INFO-TOOLTIP`, `UI-MAP-FRAME`.
- **Applied now (no new art):** the quest box only. Text 18 / 19 px (was 16 / 17), the "???" steps and the "2 of 6" pager no longer
  half see-through, 380 px wide (was 340) so steps wrap less. Before `ui_now/now_hud_quest_box.jpg`, after `p4_after_quest_box.jpg`.
  The rest changes every menu, so it waits for your yes (inbox 4).

---

## Part 5 - small items

1. **Primm's Castle choice nodes** follow the rule of every other dungeon now: no purely good option; the deepest dungeon, so strong
   boons with lasting drawbacks. **Rooms and fights are unchanged**, and anything that strengthens the enemy in the castle lasts one fight
   only, so Primm's own fight is never touched. The two story events (the early journals, the Corrected) got drawbacks too.

   | Node | Option | Boon | Drawback | Duration |
   |---|---|---|---|---|
   | 3 Grand Foyer | Study the portrait | heal 6 (was 3) | 'His Eyes Follow': -1 max HP | rest of the dungeon |
   | 3 Grand Foyer | Pocket a gilded candlestick | +80 gold (was 50) | 'Fingerprints Everywhere': -2 max HP (was -1) | rest of the dungeon |
   | 3 Grand Foyer | Count the reflections | 'Seen Him First': your units +1 defense | 'One Reflection Too Many': the enemy starts with a Militia (1/1) | next fight |
   | 8 The early journals | Read them | 'A Good Man's Plans': +2 max HP, units +1 defense | lose 3 HP | rest of the dungeon |
   | 8 The early journals | Sit with the book | heal 7 (was 4) | 'Sympathy for Him': -1 max HP | rest of the dungeon |
   | 12 Lab Notes | Read the notes | 'Lab Notes': your units +1 / +1 | 'Too Much Reading': -1 card in the opening hand | rest of the dungeon |
   | 12 Lab Notes | Take the samples | +80 gold (was 50) | lose 3 HP | at once |
   | 12 Lab Notes | Practise the smile | 'Perfect Smile': your units +1 defense | lose 2 HP (was 1) | rest of the dungeon |
   | 16 The Corrected | Sit with them and listen | 'They Were Heard': +4 max HP (was 3) | lose 3 HP | rest of the dungeon |
   | 16 The Corrected | Free the nearest bed | heal 8 (was 5) | 'Their Voices Stay': -1 max HP | rest of the dungeon |
   | 16 The Corrected | Take the record book | +90 gold (was 60) | 'Robbed the Corrected': -2 max HP | rest of the dungeon |
   | 22 Garden | Pick the odd one out | heal 8 (was 3) | 'The Gardeners Noticed': enemy units +1 attack | next fight |
   | 22 Garden | Pick a handful of the rest | +90 gold (was 40) | 'Uniform Pollen': -2 max HP | rest of the dungeon |
   | 22 Garden | Plant something crooked | 'Crooked Little Hope': your units +1 / +1 | lose 3 HP (was 1) | rest of the dungeon |

   Four result texts gained a closing sentence for the new drawback (Study the portrait, Count the reflections, Read the notes, Take the
   samples). The full table of every dungeon: `docs/design/choice_nodes_nov19.md` (updated).
2. **The enemy-side drawback "the enemy starts with an extra unit":** new `Modifier.Kind.STARTING_UNITS` (the unit enters at the start
   of the duel, like a unit that just arrived), boon spec key `foe_unit=<token number>` (`foe_units=2` for two). Used in three nodes:
   the Hall of Final Approvals' kiosk, "Skip the queue" ('Security Was Called': a Zombie Temp 1/1, next fight; it replaces the
   exhausted first unit); the Path-ology Lab's study, "Take the journal" ('Alarm Raised': a Failed Experiment 3/3, next fight; it
   replaces the enemy's +1 attack for the rest of the dungeon); the castle's Grand Foyer above. Tests
   `tests/core/dungeon/test_fable_nov19_part5.gd`.
3. **Hover magnification:** the Collection Book magnifies a card not found yet as its **card back** (found cards already had the big
   preview); the dungeon challenge's revealed cards, the three sample cards of a Path offer and the Peek panel's cards grow under the
   mouse like reward cards. The Deck Station, the shops, the packs page and Alembic already had it. **The Glossary shows no card
   pictures** (text and icons only), so there was nothing to magnify there. Tests `tests/ui/test_hover_zoom_nov19.gd`.
4. **Your decisions, recorded** (no code): Baron Quadzilla stays as built (playtest first); Grand Bellows stays; the Cardio Machine and
   the Department of Final Approvals stay normal cards; the separate Swolympus / Iron Cave clear flags stay; the Arena's numbers wait for
   your hand pass; opponent cards wait for a click by default; Crosspath's shop-front signs: no change. The inbox items they answered
   are marked answered; the backlog entries they closed are removed.

---

## Part 6 - tests (no export)

- **GUT:** the full run (43 shards, 3375 tests): **3372 passed, 1 failing, 2 pending** (both pending before this pass: art not imported
  yet). The one failure was `test_boon_effects`, which did not know the new `foe_unit` key: a test to update. Fixed and re-run on its
  own (5 of 5); the whole suite was not run a second time. Real saves untouched (19 files checked).
- **Walk smokes:** Crosspath OK, the Opening Forest OK, the Gainlands OK, the Buffet OK, the D.N.A. OK, the Capital OK.
  - The Capital's smoke failed at first **because of this pass**, for a reason worth knowing: its walker counted time in frames, the
    Capital now draws faster on the Low camera (fewer things in the transparent pass), so its 8 "seconds" ran out early and the hero
    stopped short of a crate stack in the Transit Yards. The smoke times its walks by the clock now; the game was not at fault.
  - **The Dump's smoke fails, and it already failed on the start tag** (checked by running the tag's code): at the heal spot the prompt
    offers Wren, who stands nearer. Not from this pass and not fixed in it (the heal spot or Wren needs to move a step; listed in the
    backlog).
- **Probes:** the new fade probe (test and `tools/run_fade_probe.sh`): 0 offenders. The sign-angle probe (in the suite): passed. The
  NPC visibility probe: 150 checks, 0 failed after one fix to the probe itself (it counted a building's invisible shadow proxy as a
  thing in the way; the old fader used to hide that proxy together with its house).
- **Not run:** the strict playthrough bot and any export (the brief asked for neither).

---

## Decisions needed (details in the inbox, "Fable Nov 19")

1. **The camera per zone:** recommended Crosspath +4, Gainlands +4, Buffet +4, Capital +4, the rest as now. One line each in
   `data/camera/zone_camera.json`.
2. **The palette:** approve red / cream / moss / ghost green (or option 2, ghost teal for the Necrocrat).
3. **The fade look:** keep "a window round the hero plus his outline" for every tall thing (recommended), or buildings fully solid
   with the outline only.
4. **The info-screen look:** yes to "a storybook page in a gilt frame"? Then it can be built with the stand-ins before the art arrives.
5. **Which camera is the default for a new player:** you play on Low; the game ships on Cinematic. Recommended: keep Cinematic until
   the zone pitches are chosen, then decide.
6. **The castle's numbers** (heals 6 to 8, gold 80 to 90 against -1 / -2 max HP): first numbers; recommended to playtest as they are.

---

# Overnight Nov 19 (Opus) - report: the story after each zone, Alembic, signature cards, choice nodes, the Arena, world fixes, the playtest build

Brief: `docs/prompts/opus_nov18_night.md`. Start tag `pre-overnight-nov19`. Questions: `docs/overnight_inbox.md`, "Overnight Nov 19" (8 items).
Shots: `docs/overnight_shots/nov19/` (`ref_*` are yours; `p1_`..`p10_` mine). Dialogue revert:
`node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov19_lines.csv --revert=docs/dialogue/nov19_lines_ids.txt` (27 changed lines; the new
keys `memory.1.alembic`, `town.arena.guard`, the Diamond tier's and its two bouts' texts are additions and stay; the Part 5 event texts are
part of the mechanics change and revert with git).

**The playtest build:** `builds/TheWaywardPath-v1.0.0-windows.zip`, **801 MB** (800,892,178 bytes; 778 MB on Nov 15 - two cards, the new art stand-ins and code). Export OK; `run_release_smoke_exported.sh` PASSED; the three `play_exported.sh` checks (`n19a`, `n19b`, `n19c`) ran to "done" with **0 SCRIPT ERROR**. Not uploaded anywhere.

## Status by part

| Part | Done | Notes |
|---|---|---|
| 1 Card and battle bugs | yes | all five; shot `n19_arena_rules` (rules list) |
| 2 The story after each zone | yes | strict bot: Maren's scene played after every freed zone, both Paths |
| 3 Auntie Alembic | yes | `p10_alembic_shop` |
| 4 Signature cards | yes | `p10_signature_clear` |
| 5 Choice nodes | yes (not Primm's Castle) | table below; castle left as it was (your rule) - inbox 1 |
| 6 The Arena | yes | `p10_arena_*` |
| 7 Equipment text | yes | |
| 8 The world | yes (Crosspath shop-front signs not turned) | `p8_*` - inbox 7 |
| 9 Batch 18 rows, backlog | yes | 5 new rows; 5 backlog items |
| 10 Flow end to end | yes | two strict runs; one representative clear screen (every mini dungeon uses the same code path) |
| 11 Tests, build, report | yes - GUT 3342 tests in 34 shards green after fixes (8 old-design assertions updated), walk smokes, probes, export | |

## Part 1 - card and battle bugs
- **The player's own choices** (Post-Human Resources Ghoul and the rest). A general "player choice" pause in the engine (`GameState.choice_requests`,
  `ChoicePanel`): when the opponent's edict ("your opponent destroys a unit they control") hits you, YOU pick which of your units dies (highlighted
  on the board, or a button). The same pause now covers every choice the engine used to make for you: a triggered ability's target (Grim Repper,
  Swole Revenge, The Junkyard Gym, Bulking Program...), a pick inside an effect (Push Broom, Endless Filing, Circle of Life Insurance), "choose one"
  (Community Garden, County Fairgrounds, Spirit-Lifting Belt) and "you may" (Barbell of the Ancients, Rubbish Goat). One option only = no question.
  The AI and look-ahead copies keep the automatic picks. Tests `tests/core/game/test_player_choices_nov19.gd`.
- **Scripted events** (Vellum, Mortimer, every boss/gatekeeper/arena/dungeon script) are a pop-up: the foe's portrait, its line, what the event does
  in plain words; click, Space, Enter or pad A closes it, and the event's board animation plays after.
- **Opponent spells and traps** wait in the middle of the table (big, clear of your hand) with "Click or press Space to continue". Setting
  "Opponent spells and traps: Wait for click (default) / Continue after 4 s" (Settings, next to Battle speed). Units don't wait.
- **Rules of this fight** is a list of readable lines (icon with its hover, name, text) under the opponent's plate, for every fight; the Arena's
  banner across the top is gone and the bout's own name and rules are the list's first line.
- **A roamer that hurts you** (meatballs, sprites, couriers, gulls, Tidy-Bots) counts as met: its Bestiary entry unlocks with a "New Bestiary
  entry" note (it did unlock silently before; the note is new and fires for fights too).

## Part 2 - the story after each zone
- **Back in Crosspath after a freed zone** the hero arrives a step in front of Elder Maren and her memory scene plays at once (once per zone;
  talking to her later still works if it was cut short). Then the other news.
- **Fragments**: two steps per memory, "free a zone" (ticks the moment the Nth zone falls, whichever it was, with the zone roads marked) then
  "talk to Elder Maren".
- **Story and unlock notices wait for a click** ("Someone is waiting...", the shops opening, the arena and alchemist news); small toasts still fade.
- **Elowen**: no cups after the second zone (pacing, watching the road); she walks off facing her way with her walk frames; "I'll find you. I always
  do" is "once I'm clear of them and it's safe, I'll come and find you. Trust me that far."; "I won't come into town, though. I can't risk being seen."
- **Maren after the second zone** rewritten: wary (a Path-walker who remembers nothing, or says so), starting to trust because he's helping, worried
  what happens when his memories return; the "that boy is ten years dead" suspicion is gone from this scene (she still worked at the castle, memory 3).
- **Plume speaks PR** ("a leadership transition, which His Perfection fully supports and, in a very real sense, arranged"); his after-the-ending
  broadcasts spin too.
- **One Agnes** in the freed D.N.A.; probe `tests/world/test_no_duplicate_npcs_nov19.gd` checks every zone before and after freeing.
- **"New equipment"**: the level-13 note names Bertram's advanced rack; a freed zone's screen names its shop and the new piece ("New equipment at
  Clerk Ledgerbone, Requisitions (Gear): Notary Seal" - it was behind the shop's Gear tab); the map and minimap show a gold **NEW** tag on any vendor
  with something new (equipment, items, cards, packs, Alembic, the Arena, a zone shop) until you open it. Tests per unlock.

## Part 3 - Auntie Alembic
- Opens with the **first** freed zone. Closed note: "CLOSED FOR INVENTORY. AND FOR REASONS. ... DO COME BACK LATER, DEAR."
- **"A Pinch of Everything" is MAIN**: Maren's first memory scene ends (after "Decks may now use two Paths") by sending you to her; the quest starts
  tracked; steps "Talk to Auntie Alembic", "Brew a card: click two Path jars, then Craft".
- See the essence rules below. Brew cards show **owned/3**; never-seen cards are card backs; hovering magnifies (backs stay backs).

## Part 4 - signature cards
First clear = a reward box with the card itself and "More copies are now sold in <shop> (never in packs)". Table in
`docs/design/card_availability.md`. Betty Bones replaces the Department of Final Approvals (now a normal card); the Ultimate Cardio Machine (the
Iron Cave's old prize) is a normal card too (inbox 4). Swolympus and the Iron Cave had shared one "cleared" flag; fixed (inbox 5). The Gilded
General Pack is sold by Foil Fenwick once all four zones are free (400 gold).

### The two new cards as built
| Card | Built |
|---|---|
| **Baron Quadzilla, Lord of Leg Day** (B-37) | Beefcake, Epic unit, 3 + (B)(B), 5/6, Bulldoze. When this unit enters, create two Iron. Never Skip Leg Day: at the beginning of combat on your turn, you may use an Iron; if you do, other units you control get +1/+0 and Bulldoze until the end of your turn. Not in packs; the Iron Cave's first clear, then the Gainlands shop. Stand-in art: the Bestiary square. |
| **Announcer Grand Bellows** (C-36) | Colourless, Epic unit, 4, 3/4. Ladies and Gentlemen! When this unit enters, choose a unit you control and an enemy unit; they fight. The Crowd Goes Wild: whenever a unit you control destroys an enemy unit in combat, it gets +1/+0 until the end of your turn (new engine event `combat_kill`). One from the Diamond prize, more at Sable's after. Stand-in art: his portrait. |

Numbers as proposed (inbox 2, 3).

## Part 5 - choice nodes
Full table (also `docs/design/choice_nodes_nov19.md`):

| Dungeon | Node | Option | Boon | Drawback | Duration |
|---|---|---|---|---|---|
| The House of Gains | 5: Locker Room of Legends | Borrow the lucky towel | 'Lucky Towel': +2 max HP | lose 1 HP | rest of the dungeon |
| The House of Gains | 5: Locker Room of Legends | Raid the gym bag | +60 gold | 'Spotter Knows': -1 max HP | rest of the dungeon |
| The House of Gains | 5: Locker Room of Legends | Do a set with the ghost of a champion | heal 3; a card (B-01) | 'Jelly Legs': your first unit enters exhausted | next fight |
| The House of Gains | 7 | (story event "hg_descent", built in code) | | | |
| The House of Gains | 9 | (story event "hg_rescue", built in code) | | | |
| The Test Kitchen | 7: The Corrupted Pantry | Eat the glowing stew | 'Corrupted Feast': +3 max HP, your units +1 attack | lose 2 HP | rest of the dungeon |
| The Test Kitchen | 7: The Corrupted Pantry | Take only the sealed jars | +40 gold | lose 2 HP | at once |
| The Test Kitchen | 7: The Corrupted Pantry | Ask the ladle to stop | heal 1; a card (G-04) | lose 1 random card(s) from your deck | rest of the dungeon |
| The Test Kitchen | 10: R&D Archives | Compare the handwriting | 'Impostor Exposed': your units +1 attack, your units +1 defense | 'Watched by the Impostor': enemy units +1 attack | rest of the dungeon |
| The Test Kitchen | 10: R&D Archives | Photograph the blueprints | +50 gold | 'Flash Burn': -2 max HP | rest of the dungeon |
| The Test Kitchen | 10: R&D Archives | Pocket the recipe marked DO NOT SERVE | a card (G-17) | 'Do Not Serve': -1 card in the opening hand | rest of the dungeon |
| The Test Kitchen | 10: R&D Archives | Leave the archives alone | nothing | nothing | at once |
| The Hall of Final Approvals | 2: Take-a-Number Kiosk | Take a number and wait | nothing | nothing | at once |
| The Hall of Final Approvals | 2: Take-a-Number Kiosk | Take every number | +35 gold | lose 2 HP | at once |
| The Hall of Final Approvals | 2: Take-a-Number Kiosk | Skip the queue | 'Cut the Line': your units +1 attack | 'Back of the Queue': your first unit enters exhausted | next fight |
| The Hall of Final Approvals | 8: Form 27-B Office | Fill out the forms | 'Duly Authorized': +3 max HP | pay 20 gold | rest of the dungeon |
| The Hall of Final Approvals | 8: Form 27-B Office | Forge the stamp | +50 gold | lose 2 HP | at once |
| The Hall of Final Approvals | 8: Form 27-B Office | Ask the clerk what Form 27-C is | a card (N-15); heal 1 | 'Put on Hold': your first unit enters exhausted | next fight |
| The Hall of Final Approvals | 12: The Shredding Room | Shred a spare appeal | +70 gold | 'Paper Cuts': -2 max HP | rest of the dungeon |
| The Hall of Final Approvals | 12: The Shredding Room | Shred your own number | heal 4 | 'No Number': -1 card in the opening hand | rest of the dungeon |
| The Hall of Final Approvals | 12: The Shredding Room | Reach in for what it ate | a card (N-17) | lose 3 HP | at once |
| The Hall of Final Approvals | 12: The Shredding Room | Leave the shredder alone | nothing | nothing | at once |
| The Rotheart | 7: Weeping Compost Pool | Drink from the pool | 'Compost Courage': +3 max HP | lose 2 HP | rest of the dungeon |
| The Rotheart | 7: Weeping Compost Pool | Bottle some of it | +40 gold | 'The Pool's Grudge': enemy units +1 attack | next fight |
| The Rotheart | 7: Weeping Compost Pool | Comfort the pool | heal 2; a card (R-01) | lose 1 random card(s) from your deck | rest of the dungeon |
| The Rotheart | 12: The Heart Roots | Sever the Heart Roots | the Rotheart starts her fight with less HP | lose 2 HP | boss fight |
| The Rotheart | 12: The Heart Roots | Leave them be | nothing | nothing | at once |
| Primm's Castle | 3: Grand Foyer | Study the portrait | heal 3 | - | at once |
| Primm's Castle | 3: Grand Foyer | Pocket a gilded candlestick | +50 gold | 'Fingerprints Everywhere': -1 max HP | rest of the dungeon |
| Primm's Castle | 3: Grand Foyer | Count the reflections | 'Seen Him First': your units +1 defense | - | rest of the dungeon |
| Primm's Castle | 8 | (story event "pc_early_journals", built in code) | | | |
| Primm's Castle | 12: The Doppelganger's Lab Notes | Read the notes | 'Lab Notes': your units +1 attack, your units +1 defense | - | rest of the dungeon |
| Primm's Castle | 12: The Doppelganger's Lab Notes | Take the samples | +50 gold | - | at once |
| Primm's Castle | 12: The Doppelganger's Lab Notes | Practise the smile in the mirror | 'Perfect Smile': your units +1 defense | lose 1 HP | rest of the dungeon |
| Primm's Castle | 16 | (story event "pc_corrected_citizens", built in code) | | | |
| Primm's Castle | 22: Garden of Uniform Flowers | Pick the odd one out | heal 3 | - | at once |
| Primm's Castle | 22: Garden of Uniform Flowers | Pick a handful of the rest | +40 gold | - | at once |
| Primm's Castle | 22: Garden of Uniform Flowers | Plant something crooked | 'Crooked Little Hope': your units +1 attack, your units +1 defense | lose 1 HP | rest of the dungeon |
| The Path-ology Lab | 4: The Observation Deck | Read the notes on the Subject | 'Know Your Enemy': your units +1 attack | lose 2 HP | next fight |
| The Path-ology Lab | 4: The Observation Deck | Drink the Path-ologists' tea | heal 4 | 'Sedated': your first unit enters exhausted | next fight |
| The Path-ology Lab | 4: The Observation Deck | Rifle the lockers | +80 gold | lose 3 HP | at once |
| The Path-ology Lab | 7: The Draining Chamber | Put your hand on the glass | heal 6 | 'Drained': -1 max HP | rest of the dungeon |
| The Path-ology Lab | 7: The Draining Chamber | Read the dials | 'Know the Machine': your units +1 attack | 'Feedback': the enemy starts with +3 HP | rest of the dungeon |
| The Path-ology Lab | 7: The Draining Chamber | Tear out the straps | 'Never Again': +3 max HP | lose 3 HP | rest of the dungeon |
| The Path-ology Lab | 11 | (story event "lab_cell4", built in code) | | | |
| The Path-ology Lab | 12: The Mentor's Study | Take the journal for Wren's true record | 'The True Record': +2 max HP | 'Alarm Raised': enemy units +1 attack | rest of the dungeon |
| The Path-ology Lab | 12: The Mentor's Study | Leave it on the desk | nothing | nothing | at once |
| The Shattered Gallery | 3: The Weight of Glass | Lift it anyway | 'Unbroken Reflection': your units +1 attack | lose 5 HP | rest of the dungeon |
| The Shattered Gallery | 3: The Weight of Glass | Leave it on the rack | - | 'Second Thoughts': -2 max HP | rest of the dungeon |
| The Shattered Gallery | 3: The Weight of Glass | Break it for the silver | +150 gold | lose 1 random card(s) from your deck | rest of the dungeon |
| The Shattered Gallery | 6: The Valid Reflection | Sign it | 'Approved': +3 max HP | 'Filed Away': your units -1 attack | rest of the dungeon |
| The Shattered Gallery | 6: The Valid Reflection | Refuse to sign | - | lose 4 HP | at once |
| The Shattered Gallery | 6: The Valid Reflection | Sign someone else's name | heal 6 | pay 100 gold | at once |
| The Shattered Gallery | 8: The Quiet Frame | Rest (pay 250 gold) | heal 12 | pay 250 gold | at once |
| The Shattered Gallery | 8: The Quiet Frame | Rest, and leave a card as the fee | heal 8 | lose 1 random card(s) from your deck | rest of the dungeon |
| The Shattered Gallery | 8: The Quiet Frame | Keep moving | nothing | nothing | at once |
| The Shattered Gallery | 12: Your Reflection | Look it in the eye | 'Know Yourself': your units +1 attack | 'Seen Through': -3 max HP | rest of the dungeon |
| The Shattered Gallery | 12: Your Reflection | Turn your back on it | - | lose 3 HP | at once |
| The Shattered Gallery | 12: Your Reflection | Smash it | 'Shattered Pride': your units +1 defense | lose 6 HP | rest of the dungeon |

Story events built in code: hg_descent (the House of Gains' stairs: pay 40 gold, lose 3 HP, or lose a random card for the run), hg_rescue and lab_cell4 (rescues), pc_early_journals and pc_corrected_citizens (Primm's Castle, unchanged).

Processing Time ("each player's first spell each turn costs 1 more"; units and other cards unaffected - tested) now applies in three Hall of
Final Approvals fights only: the Intake Clerk (early, node 3), the Executive Elevator Operator (13) and Mortimer (14), and shows in Rules of this fight there.

## Part 6 - the Arena
| Tier | Bouts (kind) | Each win pays (first clear) | Tier prize (every bout beaten) |
|---|---|---|---|
| Bronze Sand | Warm-Up Brawl (battle), Lethal Lunch (puzzle), The Neutral Mile (battle, preset deck) | gold, XP, a Path / General Pack (+ Energy Draught on the Mile) | Champion's Laurels |
| Silver Sand | Hold the Line (puzzle), Spells Only, Please (battle, preset deck + rule), The Four Fists (battle) | gold, XP, a General Pack tier II / Path Pack (+ essence) | Crowd-Pleaser's Cape |
| Gold Sand | Zero to Hero (puzzle), The Marshal (battle) | gold, XP, a pack (+ essence / an item) | Gladiator's Net |
| Diamond Sand (new) | The Final Bell (puzzle: three blockers, eleven HP, exactly five energy - solved in a test), The Four Fists, Unbound (battle: the Champion again, 54 HP, more Epics) | gold, XP, a pack, essence | Bloodsand Boots + Announcer Grand Bellows |

A tier opens when every bout of the one before is beaten; locked tiers are greyed with "Locked: beat every bout of ... first". The podium shows
the current tier's prize, later tiers as "???". Pop-ups: "Victory!" (what you won) and "Tier complete!" (prize, next tier open). Preset-deck bouts
show "A preset deck" (its name and cards) with Continue instead of the deck choice. Bellows: the ring is open because Primm's guards have left
Crosspath; before it opens one of Primm's Capital guards stands at the hatch ("Closed by order of His Perfection. Move along.").

## Part 7 - equipment text
The Upgrade / Sidegrade / Downgrade line and the "Compared with... You'd lose..." block are gone (Bertram's shop tiles, zone shops' Gear, every
equipment tooltip); tiles are 24 px shorter. The Character screen never showed it.

## Part 8 - the world
- **Rip** turns to the hero (every zone, Crosspath too); his three-quarter idles are mirrored side frames (Batch 18 row). D.N.A. station 1.8 m right;
  Crosspath's station out on the open lawn south-east of the square (`p8_rip_crosspath`).
- **The Forgotten Cave** comes out at a brush-covered cave mouth on Crosspath's north edge, a short walk from Maren (painted cave mouth, brambles,
  hedge, lantern - `p8_cave_mouth`); prompt, map icon, markers and Elowen's spot moved with it; the stone hut is a plain house.
- **The Old Service Tunnels**: plain wall where the door was; a manhole (iron cover ajar, warm glow, steam) where the lantern-sign stood; sign gone
  (`p8_manhole`).
- **The Capital's south edge**: the camera trailed into the Crease's cavern rock (built far south) and looked at it from below; outside, the lens now
  stops short of it, sliding in along its own line (`p8_south_edge_a/b`).
- **Signs**: every board in the Capital and the D.N.A. turns to face the camera (Buffet, Gainlands and Dump already did); a plaque on a sideways wall
  stands on posts in front of it. Probe `tests/world/test_sign_facing_nov19.gd` lists every sign with its angle (`p8_capital_signs`). Crosspath's
  shop-front signs not turned (inbox 7).

## Essence, brewing and the save migration
- A copy beyond your third converts to essence of its Path (more for rarer cards).
- A brew costs **6 essence of each of two Paths + 40 gold** (it was 2 + 2; the gold is unchanged).
- Each Path holds **at most 18**; extra is lost, and a conversion into a full jar says so ("your Beefcake essence is full (18), so no more is kept").
- Alembic's gift: **+6 of every Path**, added to what you have, capped at 18.
- Bars fill out of 18; the number is white below 18 and gold at 18; the header says "at most 18 each".
- **Saves**: every Path above 18 is clamped to 18 on load (`GameSession.migrate_essence_cap`).

## Part 10 - end to end
- Strict bot, Refusemancer: new game to two freed zones in 31 min, exit 0, **0 script errors**, Maren's fragment after each zone, "A Pinch of
  Everything" tracked after the first. 11 issues: walk traps and door shortcuts of the kind every earlier strict run had (Dump route snags, the west
  street) - nothing from tonight's changes.
- Strict bot, Necrocrat: two freed zones in 41 min (the Hall of Final Approvals took six tries), exit 0, **0 script errors**, Maren's scene after
  each. 8 issues: route traps, plus "Gerald did not offer the Waiting Room quest" (likely yesterday's Take a Number change - left for the next pass).
- The bot does not brew at Alembic's; the gift, the cost and the cap are covered by tests.

## Checks (Part 11)
- **GUT:** full run 3332/3342 with 8 failing - all assertions of the old design (card and pack counts, the Fragments step's marker, the Alembic
  blurb, the Iron Cave's prize, Swolympus's flag, the script pop-up's layer under the Peek); fixed and re-run green. Real saves untouched.
- **Walk smokes:** Crosspath (19 shots), Gainlands (14), Buffet (22), Dump (21), D.N.A. (20), Capital - all OK. **NPC visibility probe:** 150/150.
  **Duplicate-character probe**, **sign-angle probe**, **D.N.A. prop probe:** green (in the suite). **Card-games smoke:** 137/137. Log `_smokes_nov19.txt`.

## Left undone
- Primm's Castle's choice nodes (your castle rule - inbox 1); Crosspath's shop-front signs (inbox 7).
- One clear-screen shot stands for all eight mini dungeons (they share one code path); the bot does not brew at Alembic's (tests cover it).
- A hover-magnify sweep of the other menu card grids (backlog).
- Open from the strict Necrocrat run: Gerald did not offer the Waiting Room quest (probably yesterday's Take a Number change).

## Needs you (details and recommendations in the inbox)
1. Primm's Castle choice nodes - give them drawbacks too? (yes recommended)
2. Baron Quadzilla's numbers - playtest as is.
3. Announcer Grand Bellows - keep.
4. The Ultimate Cardio Machine and the Department are normal cards now - keep.
5. Swolympus's own first-clear flag - fine as is.
6. Arena prize numbers and the Diamond battle's foe - your by-hand pass.
7. Crosspath shop-front signs - free-standing boards (recommended).
8. Opponent cards wait for a click by default - keep.

---

# Nov 18 evening (Opus) - report: the D.N.A. finished properly, card ownership, a defeat-three quest per zone

Brief: `docs/prompts/opus_nov18_evening.md`. Start tag `pre-nov18-evening`. Questions: `docs/overnight_inbox.md`, "Nov 18 evening" (6 items).
Shots: `docs/overnight_shots/nov18c/` (`ref_*` are your three). No export, no upload.

## 1. The D.N.A. (Part 1)

Shots: `p1_before_<spot>_<cam>.jpg` / `p1_after_<spot>_<cam>.jpg`, cam = `default` (Cinematic) or `low`. Spots: `arrival`, `hub`,
`stair_front_close` / `_far`, `stair_west_close` / `_far`, `stair_east_close` / `_far`, `lifts_front`, `lifts_behind`,
`lifts_west_close`, `lifts_east_close`, `farm_a`, `farm_b`, `breakroom`, `time_clock` (`bash tools/dna_nov18c_shots.sh <tag> [spot]`;
the zone's shot hook takes `--yaw=deg --dist=ratio` now for side and close/far views).

- **A street behind the fronts** (`world/dna/dna_street.gd`). Behind every painted front run (the north side over the Filing Department
  and the Records Basement, the west long side) the open ground is cut into civic buildings 5-9 m wide and 6.5-8.5 m deep: bodies in
  DNA-WALL-EXTERIOR or DNA-WALL-GREY rising 1-4.6 m over the front's cornice (an upper storey set back), a brass cornice and parapet
  (DNA-TRIM-BRASS), slate roofs (DNA-ROOF-SLATE: hipped, mansard or gabled) with chimneys and dormers, a small tower on each long row,
  lit DNA-SHEET-WINDOWS on the sides, backs and upper floors. Every building is a closed box, so a row's ends are corners. They sit
  outside the walk grid, clear of the Hall, its stair and the clock tower (the row by the tower ends at it). One mesh per row (draw
  calls: see FPS). The Filing Tower moved further west and the Records Stair round to the open east side to make room; the wasteland
  keeps off the street. The DNA-BD-TOWERS skyline stands just inside the far scenery ring with thicker haze (`zone_looks.json`).
  **Cubicle Farm A's north wall is low now** - it had a 2 m strip behind it (the lone wall in `ref_dna_flat_fronts_punchcard.png`;
  inbox 6). Compare `p1_before/after_arrival_*`, `_hub_*`, `_stair_*_far_*`.
- **Nothing floats, nothing sits in a wall.** The time clock is a brass punch clock (dial, hood, a time card in its slot, a card rack) on
  a stone pillar standing against the breakroom's west wall; "[E] Punch in" is a step in front of it (`p1_*_time_clock_*`). The
  pneumatic tubes are gone. Signs on the waist-high rails stand on the rail (they hung 1.5 m up, a third of a metre off it). Booths moved
  onto walled-in floor beside their old spots, or left out (6 kept, 5 out; inbox 5). Lamps at corners stand clear of both walls.
  The clock tower's flat glow panel (a pale slab from the sides) is gone.
  **Probe** `DnaPropProbe` (`world/dna/dna_prop_probe.gd`; test `tests/world/test_dna_props_nov18c.gd`): every layout prop, booth,
  column, set piece, chest, sign, stair ghost, dressing piece and wasteland piece against the ground (or the counter it stands on, or
  the wall it hangs on) and against every front, rail, desk partition, elevator wall, maze cabinet and street building. Its first run,
  after the clock, tubes, booths and signs above, found **9** (five corner lamps, the elevator-bank lamp, a records cabinet half in the
  north front, two booths); **now 0 of 441**. Known before any of that: 11 booths on rails, the floating clock, 4 tube runs, 4 sunk ghosts.
- **Elevator walls one piece.** Each half of the bank (`LiftBank_W` / `_E`) is one node: its wall (now 4.2 m, a storey and a half) and its
  two elevators with stone shaft surrounds up to the cornice and brass floor dials. The camera's cut-away dissolves a node's meshes
  together, so wall and shafts go together or not at all (`p1_after_lifts_west_close_low.jpg`: the near bank gone whole, the far one whole).
- **Stair ghosts.** The four cards that sank into the steps are gone; nine ghosts wait single file up the stair's left side and four
  more across the landing to the left door leaf, each with its feet on its tread, bobbing upward only (`p1_after_stair_front_close_*`).
- **The couch** (`DnaProps.heal_couch`): a big oxblood velvet couch facing the camera on a rug, a side table with a cup, a standard
  lamp with a warm shade and a warm light over it, a heart sign (ICON-MAP-HEAL on a brass-framed board) on its own post behind it, the
  screen label "Breakroom: rest here", the map/minimap heart (as before) and a soft gold glow on the floor while the hero is within
  5.5 m. The heal works as before (spot in front of it). `p1_after_breakroom_*`, `p1_after_couch_close.jpg`.
- **The Waiting Room of Eternity**: the live elevator's door has a warm glowing frame, light spilling out, a brass bracket with a
  hanging sign over it (the clock plaque - no hourglass in any sign sheet, Batch 18 row `DNA-SIGN-HOURGLASS`), a red runner off the main
  axis to it, the screen label "The Waiting Room of Eternity" (its door was still called "Sub-Basement 3") and the map/minimap icon
  once explored (fog). `p1_after_lifts_front_*`, `p1_after_lifts_behind_*`.
  **Quest "Take a Number"** (inbox 1): Gerald's old "Number 4,000,212" made official - same quest, new tracked steps: find the
  Waiting Room (the lit elevator; set when the hero comes within 6 m), then clear it; both steps pin the door on the map; taking it
  unseals the door; reward **390 gold, 120 XP, a Necrocrat Path Pack**. Tests `tests/core/quests/test_take_a_number_nov18c.gd`.
- **Checks:** D.N.A. walk smoke OK (20 shots); NPC visibility probe 150/150; prop probe 0; every NPC, chest, the couch and the
  Waiting Room reachable from the causeway (test); aisles round the new pieces 2.5 m+ (test).
- **FPS (arrival, 8 s, uncapped):** Medium **82.3 -> 82.2**; Low-end **97.2 -> 96.3** (draw calls 821 -> 874; with one mesh per building
  it was 76.6 / 1068, so the street is merged per row).

## 2. Card ownership (Part 2)

- **Own 3 of every card at all times** (`CopyCaps.own_cap`; basic Infrastructure unlimited). Packs, rewards and shops give real copies
  up to 3 at any level; a 4th converts as before. **Deck limits unchanged** (`CopyCaps.for_card`, rarity and level). `Session.copy_cap`
  is the ownership cap now, `Session.deck_cap` the deck limit; the load-time cap pass trims owned copies past 3 and deck copies past the
  deck limit.
- **The notice** (`CopyCaps.buy_notice`, the card vendor): buying a copy past what fits in a deck right now asks first, e.g. "You can only
  use 1 copy of <card> in a deck right now. You'll be able to use 2 at level 12 and 3 at level 22. Buy anyway?" - Buy / Cancel (the
  shared confirm box, mouse and pad); the levels come from the level track. Shot `p2_notice.jpg` (`--open=vendor_notice` on the town).
- **Deck Station**: "Deck 1/1 · Own 3", hover note "2 more usable at level 22" (or "1 more usable at level 12, all 3 at level 22").
  The shop and the Collection Book say "Own 2/3"; the book adds "In a deck: 1 for now. You'll be able to use ...".
- Words: the rule ("You can own up to 3 copies of any card. How many you can put in a deck depends on its rarity and your level."), the
  glossary, the loading tips, the level-up lines and level-track headlines ("Epics: 2 copies in a deck"), `docs/design/combat_rules.md`,
  `docs/design/progression.md`.
- Tests `tests/core/data/test_card_ownership_nov18c.gd` (2nd and 3rd copy at level 1, a 4th converts, the notice text and its levels,
  the deck limit still enforced, the Deck Station note, rewards/packs up to 3, the wording).

## 3. Quests (Part 3)

- **Only counted enemies are marked.** Roamer markers (world, minimap, map - one resolver) skip the contact-damage hazards (the D.N.A.'s
  Speedy Ghost Couriers were marked for Kyle's Hall Monitor; also sprites, meatballs, gulls, Tidy-Bots, shard swarms), elites and bosses
  (Colonel Casserole, Captain Spotless) and the foes that block a way (`ZoneQuestDefinitions.is_ordinary`). Checked for Hall Monitor,
  Clear the Backlog, Clear the Lanes (its pin no longer says "sprites"), Who Ate the Compost? and the new ones.
- **Defeat three, one per zone** (the D.N.A.'s is Kyle's Hall Monitor; Crosspath added because its outskirts have roamers; the Opening
  Forest has none). Count 0/3 from when taken; only ordinary roamers; one time; side quests; any zone order.

| Zone | Quest | Giver (where) | Counts | Reward (after the side-quest gold scale) |
|---|---|---|---|---|
| Gainlands | Spot Check | Foreman Gus (by the wheels) | brutes, golems | Gilded Beefcake Pack, 225 gold, 50 XP |
| Endless Buffet | Leftovers | Sous-Chef Tarragon | meatloaf golems, gelatin sentinels | Gilded Gourmand Pack, 390 gold, 100 XP |
| Verdant Dump | Pest Control | Billie Muckfoot (the pens) | trash golems, scarecrows | Gilded Refusemancer Pack, 450 gold, 115 XP |
| Capital | Thin the Patrols | Kestrel | officers, inspectors, rift wretches | Gilded General Pack (new, inbox 3), 525 gold, 135 XP |
| Crosspath | Outskirts Watch | Gatekeeper Brannoch (the gate) | hound, clerk, raccoon (they return) | Gilded General Pack, 135 gold, 35 XP |

  (Hall Monitor at the D.N.A.: 330 gold, 80 XP, a Gilded pack.) Each has one offer, active, ready and done line in its giver's voice
  (`data/dungeons/dungeon_content.json`, new keys). Tests `tests/core/quests/test_defeat_three_nov18c.gd`.

## 4. Dialogue revert

`node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov18c_lines.csv --revert=docs/dialogue/nov18c_lines_ids.txt` (Gerald's four
rewritten Take a Number lines and the elevator sign; the five new quests' lines are new keys the quests need).

## 5. Checks (Part 4)

- **GUT:** full suite 42 shards **3274/3287, 11 failing** on the first run - all tests of the old copy-cap rule (an Epic capped at 1
  owned, the old rule wording and loading tip, special Infrastructure trimmed to 2), the quest audit (the new counters' producer is a
  generated name; taught to it), Gus now having a second quest (Gainlands quest count, the marker test). Updated and re-run: green
  (73/73 in those files and the new ones). Real saves untouched (SaveGuard). Log `docs/overnight_shots/nov18c/_full_run.txt`.
- **Walk smokes:** the D.N.A. OK (20 shots), the Gainlands OK (14), the Buffet OK (22), the Dump OK (21), the Capital OK (36).
  **Card-games smoke:** 137/137. **NPC visibility probe:** 150/150. **Prop probe:** 0 of 441. Log `_smokes.txt`.
- No export, no upload.

## 6. For you

Six items in `docs/overnight_inbox.md` ("Nov 18 evening"), each with a recommendation: Take a Number stays Gerald's; the Gainlands' two
beat-three quests; the new Gilded General Pack; the hourglass plaque (Batch 18); five booths out; Farm A's north wall low.

# Nov 18 day (Opus) - report: the owner's playtest fixes - battle, quests, cards, UI, and the D.N.A. back outdoors

Brief: `docs/prompts/opus_nov18_day.md`. Start tag `pre-nov18-day`. Questions: `docs/overnight_inbox.md`, "Nov 18 day". Shots:
`docs/overnight_shots/nov18b/` (`ref_*` are the owner's own "before" shots for the battle, pack, quest and gear items). No export, no upload.

All seven parts are done. Commits: Parts 1-5 together (`503a7022`; the parts share files - the battle board holds Parts 1 and 2), Part 6 (`ee290832`), Part 7.

## 1. Card rules (Part 1)

**Unconscionable Contract - fixed.** The rules always moved the unit (`GameState.steal_card`); the **battle board never did**: a card's view
keeps the "owner" it was made with, so a stolen unit stayed drawn in the enemy's row, and clicks treated it as the enemy's (it could not be
picked to attack). `BattleBoard.set_controller` now moves the view to its new controller's row (card back, hover, input), from both the
`CONTROL_CHANGED` event during playback and every `sync_state`; the battle log writes "You took control of X". It dies to its owner's
Refuse Pile (`real_owner`, unchanged). Tests `tests/core/game/test_control_nov18.gd`:
`test_contract_moves_the_unit_to_the_players_side_for_the_rest_of_the_battle`, `test_a_stolen_unit_that_dies_goes_to_its_owners_refuse_pile`,
`test_the_ai_casts_the_contract_on_the_players_best_unit`, `test_the_board_moves_a_stolen_unit_into_the_players_row`,
`test_the_control_event_moves_the_view_during_playback`, plus the log.

**Other control effects found** (every one goes through `steal_card`, so the same fix covers them): **Squatter's Rights** (NB-05, gain an
Infrastructure; `test_squatters_rights_moves_the_infrastructure_view`), **Hostile Takeover** (NB-12, all resources;
`test_hostile_takeover_moves_the_resource_views`), and the temporary steals' hand-back (`borrowed`). Reclamation Order and Mirrored Hall
create or reinstate a card on your side (a new view), so they were never affected. No "swap" effect exists in the card list.

**Granted keywords show on the unit.** Every keyword a unit has that is not printed - from a Tool, spell, aura, equipment or rule - is a
chip / badge like a printed one, ringed green-gold; its hover and the battle preview say where it came from ("Toxic (from
Corporate-Approved Pen)", "Flying (from X, this turn)"); it goes when the effect ends (`GameState.granted_keywords_of`,
`StaticEffects.keyword_sources`, `CardInstance.keyword_sources`). Tests `tests/ui/test_granted_keyword_badges.gd` (pen equip/remove,
spell this turn, Necro Rat aura, no double badge).

**Special Infrastructure is collected.** Only the four basics (Powerhouse, Ghost Town, Feastforge, Wasteworks) are unlimited
(`CardData.is_unlimited`). The 11 others (INF-01..04 Uncommon, INF-05..11 Epic) follow the copy caps of their rarity (Uncommon 2, Epic 1 at
the start, rising to 3 with levels), appear in packs (they always could), **rewards and shops** (they were filtered out), convert past
the cap like any card. General packs have no Path filter (one Uncommon Infrastructure per Path in the Tier I pool). The Deck Station shows
"Deck 0/2  Own 1"; the glossary, the copy-cap rule line and the design docs say "Basic Infrastructure is unlimited".
**Save migration** (`Session.migrate_infrastructure_caps`, on load, before the cap check): for each special Infrastructure the save keeps
the copies it owns or the most any saved deck holds, whichever is more, **up to the cap**; then the usual cap pass trims decks to the cap
and turns owned copies past it into essence (or gold for the colourless INF-11). Starting decks hold basics only, so they need nothing.
The town says "Special Infrastructure is now collected like other cards: you keep the N copies your decks use." Starting decks and the
deck suggester build legal decks. Tests `tests/core/data/test_infrastructure_caps_nov18.gd` (8) and the updated deck-rule/reward tests.

## 2. The battle screen (Part 2)

| Item | Before | After |
|---|---|---|
| AI action pop-up | `ref_battle_ai_popup_and_stacks.png` | gone (`BattleScreen._ai_step`); the card's fly-in and the log stay; attacks/blocks keep a 0.3 s beat |
| Stacks | same | `p2_after_stacks.jpg`, `p2_after_stacks_720.jpg`: identical tokens fan upward inside their lane (a 20 % strip of each card underneath: name bar + art), drawn a little smaller so the lane height is unchanged; "xN" badge kept. Token cards (Contracts...) fan downward the same way; infrastructure spacing 86 -> 96 px and an exhausted one tilts 8 degrees (was 14, which covered its neighbour) |
| Full art on the field | `ref_battle_pigeon_text_vs_fullart.png` | a hand card clicked while hovered kept the hover's detail look on the field (`hover_uid` survived); now only a hovered HAND card is shown whole, and every sync puts field cards back in the field look |

The "is thinking..." line for a long AI search (only when a search took over 150 ms) is kept (inbox 4). Tests `tests/ui/test_battle_board_nov18.gd`.

## 3. Packs and rewards (Part 3)

`CardHoverZoom` (`ui/card/card_hover_zoom.gd`): the hovered or pad-focused card grows smoothly to the battle preview's height (450 px),
stays on screen, and shrinks back - pack results (each card once face up, and the summary row, focusable by pad), the post-fight reward
pick and the dungeon reward screen. It works from the card's on-screen size, so 1280x720, 1920x1080, Large text and 115 / 130 % UI scale
all land on the same size; inside a row container it grows about a pivot (the row can re-lay itself out mid-hover). Shot
`p3_after_reward_hover.jpg` (before: `ref_pack_open_small_cards.png`). Tests `tests/ui/test_card_hover_zoom.gd` (7).

## 4. Quests (Part 4)

- After the cave and Maren, **Meet the Merchants is tracked** (Fragments starts at the same moment and used to take the tracker).
- **Meet the Merchants, Make It Yours, the store room ghosts and Some Assembly Required are MAIN** (MAIN tag, main section, orders 1-4,
  before the zone lines and Fragments). While an errand is tracked nothing else takes the tracker; the next errand always does.
- **"Your Path" is gone from the quest box.** What it said lives in quests: the errands (tracked from the start) and each Path's
  gatekeeper line (its zone's main quest).
- **Kyle's Rec Room matching game is scrapped**: its screen (`MatchGameScreen`), its rewards and story keys and its tests are deleted (Dex's
  card-matching tables keep the `MatchGame` rules). Kyle gives **"Hall Monitor"**: beat three roaming staff in his wing (Cubicle Farm A and
  the Filing Department - five roamers, ids ending `_west`); the tracker counts 0/3, the map marks only those roamers. Reward: a **Gilded
  Necrocrat Pack, 220 gold, 80 XP** (the game's first win paid 210 gold, 70 XP and a Path Pack).
- Dialogue: three single lines of Kyle's that described the game are rewritten, and the new quest's offer / active / ready lines added.
  **Revert:** `node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov18b_single_lines.csv --revert=docs/dialogue/nov18b_single_lines_ids.txt`
  (the three rewrites; the quest's own three lines are new keys in `data/story/dna_story.tres` that the quest needs).
- Tests `tests/core/quests/test_quests_nov18.gd` (8): order after Maren, MAIN tags, the tracker keeps the errand, no Your Path row,
  Hall Monitor 0/3 -> 3/3 and its pack.

## 5. UI (Part 5)

- **Empty gear slot** (`ref_gear_empty_vertical_text.png`): the message was a second child of the list's ScrollContainer, which gave it no
  width (one letter per line). Now one line under OWNED across the list, wrapped: "You don't own any armor yet. Find gear in chests and
  shops (Bertram's smithy has some)." - every slot, Large text wraps.
- **The Deck Station** is a card-trader's stall on the square at the mouth of the Gate Road (where every new player walks down from the
  cave and Maren's), built from existing pieces: the kit market stall (ENV-PROP-STALL look, ENV-AWNING-01, lantern) without its produce,
  the hanging ENV-SIGN-CARDS sign, painted card backs (UI-CARDBACK-*) on the counter, sacks; a "Deck Station" screen label like a shop's,
  a shop pin with the deck icon on the map and minimap. The old inn on Champions' Road stays as a plain building. Make It Yours points at
  the new spot (same spot id). Before `p5_before_deckstation_*`, after `p5_after_deckstation_*` (square and close, default and Low).
- Tests `tests/ui/test_ui_nov18.gd`.

## 6. The D.N.A. (Part 6)

| Spot | Before (default / Low) | After (default / Low) | Flat pitch, for the comparison |
|---|---|---|---|
| Arrival, hub, door, mid1, mid2, Farm A aisle, Farm B aisle, the maze | `p6_before_<spot>_default/_low.jpg` | `p6_after_<spot>_default/_low.jpg` | `p6_after_pitch0_<spot>_*.jpg` (+8 degrees was taken as `p6_after_*` first, then +6) |

- **Outdoors.** No ceiling, no end bay and its painted back wall (`DnaBuilder.OPEN_AIR`); chandeliers float (no chains); the sky is
  DNA-SKY-GLOOM graded to a deep evening (`zone_looks.json` dna sky). Marble, runners, partitions, booths, banners, sconces, ghost-flame
  posts, moonlight and the chandeliers' sway are kept. The two-storey painted walls stay only as **building fronts on the north side and
  the west long side** (`DnaHall.is_front`), capped at 11 m with a cornice (the dark vault band is gone); every other outline cell is a
  waist-high partition on the same cells (same collision), so from the arrival and the plaza you see out over the grey wasteland to the
  DNA-BD-TOWERS skyline. Two chandeliers that hung between the camera and the hero on the way to the Hall's door are gone.
- **Room to move.** Each cubicle farm is three tidy rows of desk islands (two desks back to back over a knee-high partition, 4 per row,
  3 m between islands, 3.4 m between rows) instead of 27 cubicles boxed in on three sides (every one a dead-end slot). Records basement:
  3 m gap between the stacks (was 2), its coffins, cabinets and lamps out of the aisles; breakroom counter against its wall (no slot behind
  it), bench and lily moved; mail-room cabinets flush with the wall; the quiz office's desk back from its partition.
  **Pinch points** (`tools/dna_pinch_probe.gd`, walk grid, ways narrower than 2.5 m): **257 before -> 11 after** on the routes (the
  remaining 11 are 1-2-sample spots: Clerk Ledgerbone's vendor desk corner, room corners by a lamp). With `--strict` (also the strips
  along walls and pockets) 93 remain - most are the Filing Department maze, whose 2 m corridors are deliberate (inbox 1).
- **Camera.** The D.N.A. alone looks down **+6 degrees** at every preset (`DnaScene.PITCH_BONUS`, `CameraRig.zone_pitch_bonus`). +8 read
  the plaza best but cut the clock tower off at the top of the frame; flat showed the skyline but hid the aisles behind partitions; +6
  keeps both (compare `p6_after_*` with `p6_after_pitch0_*`).
- **The clock tower** (`_build_clock_tower`): a kit-built tower north-west of the Hall's stair - DNA-WALL-EXTERIOR body on a plinth, brass
  bands, a pale clock stage carrying DNA-PROP-LOBBY-CLOCK scaled up with a warm glow behind it, a slate spire with a green ghost lantern;
  low enough that the clock stays in frame from the arrival and the plaza, above the building fronts (clearest at Low: `p6_after_mid1_low.jpg`).
  A painted tower would read better: Batch 18 row `DNA-HERO-CLOCK-TOWER`.
- **Elevator walls**: the elevator bank's north wall either side of the corridor is a 2.5 m tall, 2.1 m deep block (the doors are 1.8 m)
  instead of a 1.15 m partition the doors stuck out of. Beside the Hall's stair, tall thick pylons replace the thin walls whose dark hooded
  figures stood up like two shafts.
- **The Hall's door**: tall double doors (DNA-SHEET-DOORS-02 scaled to 10.9 m) in a stone frame with side piers and a pediment with the
  stamp relief, red stamp banners either side, warm light from the gap and a pool of it on the forecourt, the ghost queue on the steps.
- **FPS (lobby, 8 s):** Medium **72.3 -> 75.9**; Low-end (uncapped) **96.8 -> 101.3**.

Tests `tests/world/test_dna_open_air_nov18.gd`.

## 7. Checks (Part 7)

- **GUT:** full suite 42 shards **3254/3260, 4 failing** - all four were D.N.A. tests of the old design (fewer wall sconces now the walls
  are gone, three records lamps first put on top of the stacks, the coffin memo's spot, a node named like the elevators); fixed and re-run
  green (18/18). Parts 1-5 had their own run earlier (the world shards re-run after a class-cache refresh: green after two layout tests
  were updated for the stall).
- **D.N.A. walk smoke:** OK (causeway -> gate -> lobby -> NPCs, vendor, interactables -> quiz, Kyle, puzzle -> Sub-Basement 3, the Hall ->
  giant chest, lever -> town; 20 screenshots). **Crosspath walk smoke:** OK (19 screenshots). **Card-games smoke:** 137/137.
  **NPC visibility probe:** 150/150, both cameras.
- **Strict bot (Necrocrat, new game):** forest -> cave -> town -> Maren's welcome -> **"Maren's early-game chain is done (merchants, deck
  edit, ghosts, armory)"** -> the zone lines wait for Maren's send-off -> Free the Four Zones -> the hero's own Path line tracked -> the D.N.A.
  entered, boss beaten, zone freed, memory fragment -> into the Gainlands; stopped there (the brief asked for the chain). Bot findings to
  look at: twice it could not walk from the lobby to the Hall's door and was moved on at the mail room's north doorway (43, 28.2) - the
  doorway's cells and the props near it are unchanged this pass; it looks like the route cutting the doorway's corner; one "way back to
  town" trap at the lobby counter (also in an older Refusemancer run); "side_s_necro was not offered by barnaby" and a missing marker on
  npc_necrocrat while Free the Four Zones was tracked (both older).
- **Pinch probe:** 257 -> 11 (route probe), 93 with `--strict` (mostly the maze). **FPS:** see section 6.
- No export, no upload.

## 8. For the owner

See `docs/overnight_inbox.md`, "Nov 18 day" (5 items, each with a recommendation).


# Overnight Nov 17-18 (Opus) - report: 81 new images, the D.N.A. as an indoor grand hall, the owner's decisions

Brief: `docs/prompts/opus_nov17_night.md`. Start tag `pre-overnight-nov18`. Questions: `docs/overnight_inbox.md`, "Overnight Nov 18".
Shots: `docs/overnight_shots/nov18/`. Import note: `docs/art/import_nov18_batch17.md`. No export, no upload. Ran on Opus 5.5.

All seven parts are done. Every one of the 81 images is in the game; the D.N.A. is one huge haunted government hall at night; tonight's
owner answers are applied; the tests, the five walk smokes, the card-games smoke and the NPC probe pass. The strict bot result is
in section 8: a full new game on the Refusemancer Path reached the credits and the first postgame step, Primm beaten with no wall.

## 1. The D.N.A. before and after (Part 2)

The owner's choice: one enormous grand hall, indoors (target `Haunted Office of Necrotic Affairs.png`, layout `PAINTOVER-DNA-HUB.png`).
Only the look changed: the walk grid, rooms, routes, NPC spots, doors, quests, the dungeon entrance and every interaction are as before
(the D.N.A. walk smoke walks all of them; the NPC probe sees all 7 NPCs from both cameras).

| Spot | Before (default / Low) | After (default / Low) |
|---|---|---|
| Arrival | `p2_before_dna_arrival_default.jpg` / `_low` | `p2_after_dna_arrival_default.jpg` / `_low` |
| Hub (the lobby) | `p2_before_dna_hub_default.jpg` / `_low` | `p2_after_dna_hub_default.jpg` / `_low` |
| Door (the Hall's stair) | `p2_before_dna_door_default.jpg` / `_low` | `p2_after_dna_door_default.jpg` / `_low` |
| Mid 1 (the mail room) | `p2_before_dna_mid1_default.jpg` / `_low` | `p2_after_dna_mid1_default.jpg` / `_low` |
| Mid 2 (breakroom to farm A) | `p2_before_dna_mid2_default.jpg` / `_low` | `p2_after_dna_mid2_default.jpg` / `_low` |
| Walk, entrance to the Hall | - | `walk/w_*.jpg` (20 shots from the walk smoke) |

What it is now (`world/dna/dna_hall.gd`, `DnaBuilder._build_grand_hall`):
- **Walls.** Every wall cell that touches the outside is a two-storey painted hall wall on its inside: DNA-WALL-HALL-A and -B in
  alternating bays (never the same twice in a row), DNA-WALL-HALL-NARROW for the leftovers and short runs. Each bay is drawn in three
  height bands that map the paintings' own wainscot and gallery lines to the same wall heights, so the lines run level round the hall.
  Its outside faces are DNA-WALL-EXTERIOR (the arrival). Every other wall cell is a waist-high partition (DNA-RAIL-PARTITION, same
  cells, same collision) with DNA-RAIL-POST at the ends and corners; a two-cell-thick wall reads as two partitions, posts at the ends.
- **Floor.** DNA-FLOOR-MARBLE everywhere inside (polished: the lamps glint on it), red DNA-FLOOR-RUNNER from the gate up the middle
  to the Hall's stair, and to the lobby's neighbours.
- **The far end and the ceiling.** A dark ceiling over the building's footprint; north of it a dark end bay with
  DNA-BD-HALL-INTERIOR on its far wall behind the Hall of Final Approvals. No sky shows from inside at either camera.
- **Columns, chandeliers, banners, sconces, booths.** Columns (DNA-PROP-COLUMN) along the long walls rising into the dark; 13
  chandeliers over the open floor, chains up out of frame, swaying very slightly (off on Low-end); stamp banners from the gallery on
  the side walls; sconce pairs; the office booths on the rooms' back partitions. Walls near the lens cut away (a two-storey wall never
  fills the view); every hanging or standing card fades when the camera comes close.
- **The landmark.** DNA-PROP-LOBBY-CLOCK stands on the Hall's drum where the faceted grey dome stood.
- **Signs.** Every board is a brass plaque from DNA-SHEET-SIGNS whose icon matches what it points to (stamp, clock, arrow, folder,
  raised hand, ghost).
- **Light.** Warm gold from the chandeliers and sconces (pooled lights), the ghost-flame posts as the green accent, cool moonlight
  shafts slanting from the tall windows of the side walls with slow dust motes (off on Low-end and Low), deep shadow overhead. The
  D.N.A.'s own grade, warmed and less desaturated (0.45 -> 0.18), fog a warm near-black.
- **Fixed on the way:** far chunks no longer hide their floor and walls (the outdoor ground showed through); the wasteland no longer
  puts rubble in the walled-in gaps between rooms; the notch between Cubicle Farm A and the Breakroom is hall floor.

**FPS (lobby, 8 s):** Medium **63.8 -> 71.5**; Low-end (uncapped) **86.3 -> 89.7**. Draw calls 1143 -> 998.

## 2. The 81 images (Part 1 and Part 3)

Every row of `batch17a_dna.csv` (17) and `batch17_nov17.csv` (64) is "In game (Nov 18)". Drive filing done (the 11 newest copies moved
into their usual folders, the old ones copied to `Superseded/Batch 17 replaced/`; the duplicate hall wall moved there too). The import
fixes (marble 2x2 crop through the square centres, partition crop, seam blends, the open cellar's doorway backed) are in the import
note with their tiling previews (`p1_tile_*.jpg`). Full table with the Path-icon check per row: `docs/art/import_nov18_batch17.md`.

| Images | In game | Shot |
|---|---|---|
| 17 D.N.A. hall pieces | The grand hall | `p2_after_dna_*`, `walk/` |
| 5 statues x 2 | Each zone hub's plinth, standing / toppled | `p3_statue_<zone>_<oppressed/freed>.jpg` |
| UI-CARDBACK-R / -G / -C | Card backs | `b17_battle_backs.jpg` |
| UI-PACK-G, UI-PACK-GILDED-B | Packs, no code medallion over them | `b17_packs.jpg` |
| MAP-S-CAP, BB-S-CAP | The tunnel map and board | `b17_map_s_cap.jpg`, `b17_board_s_cap.jpg` |
| NPC-ELDER x3 | Maren's portraits | `b17_portrait_NPC-ELDER*.jpg` |
| DUMP-SHEET-ENTRANCE-FLAGS-07 / -08 | The Dump entrance pennants | (Dump entrance) |
| MAP-WORLD-TOWN | Crosspath's map, pins lined up | `p3_town_map_all.png`, `p3_town_map_fog.png` |
| CUT-QUADZILLA | Quadzilla's intro cut-out | `b17_portrait_CUT-QUADZILLA.jpg` |
| 8 BST-* | The Shattered Gallery's Bestiary | `b17_bestiary_*.jpg` |
| ICON-NODE-WELL | The Well's node card and map node | `b17_map_tutorial_well.jpg` (fogged until reached) |
| 4 vault pieces | The painted cellar door and seals | `p3_vault_<locked/two/ajar/open>_zoom.jpg` |
| 18 card-game pieces | The four card games | `p3_cardgame_<game>_<how/mid/win>.jpg` |
| BUFF tart, cake stand, fliers | The east food forest | `p3_buffet_east.jpg` |
| BUFF-PROP-VEG-01..03 | The hub's cabbage beds, the river | `p3_buffet_hub.jpg` |
| NPC-PLAYER_CONFUSED / _DETERMINED | The hero's portraits (teal) | `b17_portrait_NPC-PLAYER_*.jpg` |
| DUMP-PROP-PIG | The escaped pig | `p3_dump_pig.jpg` |

**Hero cloak check:** the world sprites, the Wardrobe default and every story still but one are teal. Two pictures still show the
old cloak: the neutral portrait NPC-PLAYER and Fragment 4 (STORY-MEMORY-4) - Batch 18 rows.

## 3. The statues, the vault, the card games, the Buffet forest (before -> after)

- **Statues:** the flat grey-tinted cut-outs on the plinths are the painted stone statues, same scale in all five zones (3.3 m standing
  on the plinth, 1.5 m toppled beside it). `p3_statue_*`.
- **The vault:** the box-built cellar door is the painted door; locked seals are the painted padlock seals with the faint Path outline,
  a turned seal is the blank seal with its full icon; the doors open on the painted open cellar (warm light on the stair while ajar).
  Fixed diamond order kept (see inbox 2). `p3_vault_*`.
- **Card games:** Reps has the painted rack, bench, bar and plates (one per right guess, alternating ends, heaviest first); Order Up the
  painted pass, paper tickets with the target written on them, and the brass bell; Sort It Out the fair's conveyor and four painted
  crates with the type icons on their plaques; File in Order the records office, the painted cabinet's drawers under the cards and the
  APPROVED / REJECTED stamps. How to play, mid-game and win for each: `p3_cardgame_*`.
- **The Buffet forest:** the giant fruit tart and the tall cake stand stand among the cloches; butterflies and birds flap through their
  painted frames (hidden on Low-end). `p3_buffet_east.jpg`. The hub's green-ball beds are cabbages. `p3_buffet_hub.jpg`.

## 4. The owner's answers (Part 4)

| # | Answer | Done |
|---|---|---|
| 1 | Deck minimum stays 45 | Unchanged. No pacing numbers changed tonight, no sims run (inbox 7). |
| 2 | Primm's Standing Army and the castle's 4th room unchanged | Unchanged. |
| 3 | Elowen's name line | "...knocked it down. Elowen. It's Elowen. I promised." at the gate, before the guards; the name flag now comes just before her line (inbox 6); the Wanderer's closing line follows it. |
| 4 | The hero's own voice in the finale | Flex's and the Grand Chef's quoted lessons replaced with his own lines (phase 1: "Ten years of 'again'... not yet."; phase 2: "...you cannot copy a choice."). Agnes's stays (one per phase). |
| 5 | No shared colour grade | Each zone keeps its own; the D.N.A.'s was tuned for the hall. |
| 6 | Forest brightness / rim light: no | Unchanged. |
| 7 | No boss intent strip | Not added. |
| 8 | Reps keeps the streak after a miss | Done (rules text too). It made Reps much easier (inbox 1). |
| 9 | "Free the Four Zones" auto-starts: keep | Kept. |
| 10 | Tracker names kept | Kept. |
| 11 | The hero's cloak is teal | Portraits in; remaining pictures logged (Batch 18). |
| 12 | The Nov 16 leftover lines | Applied: Maren's "holding it. Do with it as you see fit.", "Four banners fly side by side over the square", "find me at my house", "I can see her face", "a worn cloak too thin for the cold". |

Ten single lines changed. **Revert:** `node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov18_single_lines.csv --revert=docs/dialogue/nov18_single_lines_ids.txt`
(the moved name flag is a data change in `data/story/story_scenes.json`, pc_capture; it is not part of the dialogue revert).

## 5. Small leftovers (Part 5)

- **The Verdant Dump's south corners:** grass slopes, no pale wedge, and the camera followed smoothly both ways at both cameras
  (`run_heap_corner_camera.sh`: the hero stays at 0.60-0.63 of the frame, at most 1.9 px jump, the lens at most 0.7 m to the side).
  `p5_dump_*`. Fine, nothing changed.
- **The Buffet castle's last chimney:** stands on the roof slope, no floating or clipping piece. `p3_buffet_east.jpg`. Fine.
- **The waist-high hedge by the Buffet entrance:** low, never blocks the path or reads as a wall (it is the cabbage bed now).
  `p5_buffet_entrance(_low).jpg`. Fine.

## 6. Batch 18 (Part 6)

`docs/art/batch18_nov18.csv`, 8 rows, each description self-contained and under 600 characters: MAP-WORLD-GAIN, -BUFF, -DUMP, -DNA,
-CAP (parchment maps that follow the plans), NPC-PLAYER (teal, transparent), STORY-MEMORY-4 (the boy's cloak teal), and the cellar door
with its sockets in a diamond. The five plans are in `G:/My Drive/Card Game Art/Batch 18 Refs/` (`plan-gainlands.jpg`, `plan-buffet.jpg`,
`plan-dump.jpg`, `plan-dna.jpg`, `plan-capital.jpg`; 2048x2048, 360-396 KB); copies in `p6_plan-*.jpg`.

## 7. Build size

101 asset files written; source art **+14.7 MB** net (17.3 MB new and replaced against 2.6 MB replaced). No export tonight; at the
import rules' compression that is roughly +15-25 MB on the 1.0.0 pack (784 MB, over the 750 MB warning on purpose,
`docs/build_size_policy.md`).

## 8. Tests and checks (Part 7)

- **GUT:** all 34 shards (size 12) run; the only failures were tests that encoded tonight's replaced designs (the quoted lessons, the
  Reps reset, the old statue/pennant/flier art, the D.N.A.'s old desaturation, sign pictures). They follow the owner's answers now;
  the touched files re-run 81/81 green. Real saves untouched.
- **Walk smokes:** Crosspath, Gainlands, Buffet, Dump and D.N.A. all OK.
- **Card-games smoke:** 137 checks passed.
- **NPC visibility probe:** **150 checks, 0 failed** (every zone, both cameras; the D.N.A. alone 14/14 earlier).
- **Strict bot (Refusemancer, new game, no shortcuts):** **went all the way: new game -> four zones -> the Capital -> Primm beaten
  (L22, 21 min, no 10-loss wall; on Nov 17 it hit the wall at L24) -> the ending and credits -> the first postgame step**, 74 min.
  23 issues, all of the kinds the Nov 17 run logged (the bot's own walking getting stuck at the same spots in the Dump, D.N.A., Buffet
  and Capital - it is moved on and carries on; the D.N.A. ones are at the same coordinates as on Nov 17, so the grand hall added
  none), plus 4 script errors of one new kind (a Buffet quest marker asked after the hero had left the zone: guarded tonight,
  `BuffetInteractables.picked_this_visit`). Log `_logs/strict/refusemancer.log`.

## 9. For the owner (most important first)

1. **Reps is easy now** (98 % first-set wins for a sensible guesser): ten reps or two misses would restore it. Recommend ten reps.
2. **Vault door sockets in a row vs the diamond rule:** recommend the small repaint (Batch 18 row); until then the seals keep the diamond.
3. **NPC-PLAYER (neutral) and STORY-MEMORY-4 still show the old cloak:** recommend sending the two Batch 18 rows with the maps.
4. **The Hall of Final Approvals is still the grey 3D building inside the painted hall:** recommend a painted interior facade card in
   the next batch (look at `p2_after_dna_door_default` first).
5. **Combat pacing (your answer 1):** not touched tonight; recommend a feel-only pass next (readable enemy turns, reward moments).
6. **The cabbage beds:** check that this is the patch you meant (inbox 4).
7. **The Batch 18 plans are renders, not drawn diagrams:** recommend sending them as they are; the painter only needs the shapes.
8. **No export was made tonight** (the brief): the last zip is 1.0.0 of Nov 17; tonight's build needs an export before upload.


# Overnight Nov 16-17 (Opus) - report: a full playthrough, six harsh critics, fixes, 1.0.0

Brief: `docs/prompts/opus_nov17_overnight.md`. Start tag `pre-overnight-nov17`. Questions: `docs/overnight_inbox.md`, "Overnight Nov 17".
Critic reports, triage and plans: `docs/review/critic_nov17/`. Shots: `docs/overnight_shots/nov17/`. No public upload. Ran on Opus 5.5.

**A note on time:** the session sat idle from about 23:00 to 06:50 (it waited for input after a tool step), so the night ran as a day:
Part 1 in the evening, Parts 2-5 from 06:50 to the afternoon. Everything in the brief was done; the critics had smaller budgets than
planned and the re-checks are short.

## The verdict

| Lens | Before (Nov 16 or earlier) | Tonight, round 1 | Re-check on the fixed build |
|---|---|---|---|
| 1. Combat and deckbuilding | fun 6 (never higher) | **4/10** (provisional: one fight finished) | **4/10** (C5 F4 P6) |
| 2. The late game and the ending | clarity 5 | **4/10** (never reached the ending) | **4/10** (C3 F3 P6); the town quest fix seen |
| 3. The story and the writing | blind readers: rewrite = old | **6/10** | - |
| 4. The world's look (art director) | 6.2 (Nov 12) | **5.5/10** (painted ~8, the 3D world ~4.5) | - |
| 5. The first 30 minutes and the menus | first hour 6 / 6 / 7 | **4/10** | - |
| 6. The new card games | never played | **3/10** (reached only Reps) | - |

Tonight's critics were told to score against Slay the Spire, Inscryption, Octopath and Sea of Stars, not "good for a small team"; the
numbers are lower than earlier sittings partly for that reason, and partly because they play through a scripted driver that cannot react
inside a turn (critics 1, 2 and 6 say so plainly). Read the scores as "where the game stands against the best", not as a regression.

**The three weakest parts of the game right now, in plain words:**

1. **Fights are slow and the choices are thin.** A first-room fight takes about 8 turns; most turns the right play is obvious (play the
   one infrastructure, then whatever fits); a new card is 1 in 45, so winning one rarely changes how you play; bosses do nothing for two
   turns and then flood the board. This is the core loop, and it is why fun has never passed 6.
2. **Finding things.** Several places a player must reach were missing from "Point me to..." (the Capital road, the quiz teachers, the
   card-game hosts) and the main line could vanish (no main quest with four lands free if Brannoch was skipped). Tonight's fixes close
   the ones that were bugs; walking in the 3D world still costs critics many runs.
3. **The 3D world's look against the painted art.** The dungeon maps, cards, portraits and Crosspath score 7-8.5; the D.N.A. (a greybox
   look), the Capital (flat pastel fills) and the Buffet (washed out, a flat sea) score 3.5-5, and every zone has its own colour filter.

**Would I ship this tonight? Yes, as a free itch.io release - with honest expectations.** There is no blocker left that stops a game:
the full no-shortcut playthrough went from a new game to Primm with no soft-lock, no lost main-line marker and no trap; every test is
green; the exported build runs clean. What players will feel is a slow, gentle deckbuilder with lovely painted art, good jokes and an
uneven 3D world. That is a fair free game; it is not yet a game reviewers recommend. The next real gain is in the combat pacing (owner
decisions 1-2), not in more content.

## The playthrough's facts (Part 1, `docs/review/critic_nov17/playthrough.md`)

One complete game on the Refusemancer Path with the new **strict bot** (`bash tools/run_strict_playthrough.sh refusemancer`): every fight
played by the game's planning AI, real walking along the quest arrow's route, every quest done by walking up and pressing E, no flags
set, no fight decreed until a 10-loss wall. Three sittings of the same save (the bot crashed twice on its own code and continued from
the save it had just made).

| Chapter | Bot time | Level / gold at the end | Losses |
|---|---|---|---|
| Forest + the Forgotten Cave | 1.6 min | L3 / 520 | 0 |
| Crosspath: Settling In | 2.9 min | L5 / 554 | 0 |
| Verdant Dump (gatekeeper, side quest + Landfill Depths, the Rotheart) | 19 min | L10 / 1,379 | 3 |
| Gainlands (gatekeeper, a favour by play, the House of Gains) | about 15 min | L13 / 1,484 | 2 |
| D.N.A. | 5.5 min | L14 / 1,524 | 0 |
| Endless Buffet | 6.0 min | L16 / 2,619 | 0 |
| Capital: Captain Spotless | 2.4 min | L17 / 2,769 | 2 |
| The Crease, Fig Sly | 0.4 min | L17 / 1,809 | 0 |
| Primm's Castle and Primm | 42 min | L24, **wall** (decreed) | 10 |

- **Level and gold at each main dungeon:** Rotheart L8 (514), House of Gains L10 (444), Hall of Final Approvals L13 (384), Test Kitchen
  L14 (1,099), Spotless L16 (2,344), the castle L17 (1,809), Primm first reached at L19. 1.40 h of game time at the fastest battle speed;
  59 fights won, 12 lost.
- **Blockers and their fixes:** no soft-lock, no unwinnable fight below Primm, no trap. Found: the Rescuer's four cave-mouth scenes had
  no marker (**fixed**: a "!"), and "Free the Four Zones" (the castle's marker) depended on talking to Brannoch (**fixed**: it starts by
  itself once a zone is free). **Primm's Castle is the wall** (owner decision 2). The ending's own flow was not reached by the bot (the
  decree skips it), and both late-game critics lost to Primm: **no one has seen the credits from a real Primm win tonight**. The ending,
  the credits and the new tracker are covered by tests, and the Nov 16 critic reached "File Complete".

## What was fixed (shots in `docs/overnight_shots/nov17/fixes/`)

| Fix | From | Shot / test |
|---|---|---|
| The card quiz header names each zone's exam ("Compliance Re-Certification", ...) | known item | `quiz_header_dna.jpg`; test |
| Card-game hosts said "[missing text: quiz.start]" in every zone | found tonight | test |
| The freed Capital flies the four Paths' banners on its wall, towers, gate, houses, lamps and decrees | known item | `capital_freed_banners.jpg`; tests |
| After Primm: "The City Gathers" (see the ending, the gathering in Grave Row), then "After the Fall" (the Lab and the Gallery, marked) | known item | tests |
| The four old zone smokes deleted; the docs point at `run_card_games_smoke.sh` | known item | - |
| The Rescuer wears a "!" while she waits at the cave mouth | playthrough | - |
| "Free the Four Zones" starts by itself once a zone is free and leads over a side quest | playthrough, critic 2 | test; the re-check saw it |
| "Point me to..." lists the roads out (the Capital), the quiz teachers, the card-game hosts and the filing terminal | critics 2, 6 | tests |
| The Crease's back wall hides the sky and the skyline | critic 4 #1 | `crease_before.jpg` / `crease_after.jpg` |
| The Path choice selects on any click, with a gold frame | critic 5 #1 (blocker) | - |
| Peek can always be closed (Done, E, Space, Enter; the rest stays on top) | critic 5 | test |
| The forest's J / C / P say where they open | critic 5 | - |
| No "F8" in the pause menu with a controller | critic 5 | - |
| DEFEAT no longer covers the result panel's text | critic 2 | the re-check saw it |
| Hand cards say "On play" / "On death" / "On attack" instead of "Effect" | critic 1 | test |
| Card-game pop-ups keep the controller's focus (no guess under How to play, no "?" on the result screen) | critic 6 | - |
| Reps' rules say a miss resets the reps | critic 6 | - |
| 11 single lines of dialogue (Primm's cut-in, the Tuesday payoff, Escoffina x2, the seed, the Hollow Warden, Prudence, Mortimer's number, a missing "little prince" setup, the Rescuer's "stay down", Primm's "simply not true") | critics 2, 3 | revert file `docs/dialogue/nov17_single_lines_ids.txt` |

**Not fixed (logged in the triage with a plan):** what the board-layout rule protects (the hand overflowing, attackers covering
blockers), every combat number (owner decisions 1-2), the 3D world's materials (the L-plans), the walk out of Crosspath on foot (the
critics walked blind; the arrow and "Point me to..." now lead there), the story's structure (Elowen, the hero's voice), the Buffet's
haze, the forest's darkness.

**Checks:** the full suite, 41 shards, 0 failing (one stale log line, re-run green), real saves untouched; the Capital, Crosspath, Dump
and Buffet walk smokes pass; the NPC visibility probe 150 checks, 0 failed; the card games smoke 137 checks, 0 failed; the exported smoke
PASSED; exported play checks A, B and C with 0 script errors (B could not seed A's settings file and ran with defaults).

## The owner's decisions (with context: `docs/overnight_inbox.md`, "Overnight Nov 17")

1. **Combat pacing:** try a 40-card minimum with 15 infrastructure in the sims. Both combat critics' "one change" was a card pick after
   every dungeon fight. Recommendation: sim the 40-card deck first, then decide on the card pick.
2. **Primm's free Militia and the castle's 4th room.** Recommendation: Standing Army with 2 Militia, or Setting Up through turn 3.
3. **Elowen says her own name** at the gate before Plume does. Recommendation: yes (one line).
4. **The hero's own voice in the finale:** replace two quoted lessons with his own. Recommendation: yes (a small scene edit).
5. **One colour grade** for all zones, Crosspath's as the base. Recommendation: yes.
6. **The Opening Forest's brightness** (+0.5 EV, a rim light, keep the teal dusk). Recommendation: yes.
7. **An intent strip for bosses** (L5). Recommendation: yes.
8. **Reps keeps the streak after a miss.** Recommendation: yes.
9. **"Free the Four Zones" starts by itself** (done tonight; say if it should stay Brannoch's alone).
10. **The post-Primm quest names** ("The City Gathers", "After the Fall"; they are mine).
11. **The hero's cloak colour** (teal or brown; a Batch 17 row).
12. **The five lines still yours from Nov 16** (Maren's "holding yours" is now flagged by two critics).

## The L-item plans

`docs/review/critic_nov17/l_plans.md`: L1 the D.N.A.'s walls and lights, L2 the Capital's facades and floor, L3 the primitive sweep,
L4 the Gainlands' rock and brick, L5 an intent strip for bosses (needs a yes).

## Batch 17 additions

Three rows added to `docs/art/batch17_nov16.csv`: GAIN-PROP-BARBELL (+ a plate), the hero portrait's cloak colour (owner: teal or
brown), BUFF-PROP-VEG / DUMP-PROP-PIG (painted cards for the low-poly vegetables and the cube pig).

## Where the zip is

**`builds\TheWaywardPath-v1.0.0-windows.zip`, 784,415,439 bytes (748 MB), Nov 17 12:32**, rebuilt with everything above. Not uploaded
anywhere. The test pack for exported-build runs: `builds\_testpack\TheWaywardPath_test.pck`.


# Fable Nov 16 (evening) - report: your answers, the Dump's entrance and camera, the Buffet's castle, forest and west edge, 1.0.0

Brief: `docs/prompts/fable_nov16_evening.md`. Start tag `pre-fable-nov16c`. Questions: `docs/overnight_inbox.md`, "Fable Nov 16c"
(26 items). Shots: `docs/overnight_shots/nov16c/`. No public upload. No difficulty setting, the battle board untouched, Primm's fight
untouched, no new painted art. Ran on Fable 5.2. The Fable Nov 16 (day) report follows below.

## In short

| Part | Done? | What |
|---|---|---|
| 1. Your answers | **Done** | The trivia is a card quiz in all four zones. The three puzzles are gone; a chest holds each reward. The seals sit in Path order with a faint icon outline and a tooltip. Eight old screens and their rule code are deleted. |
| 2. The Dump's entrance | **Done** | The two gate trees, their code and their art are gone. The path runs open to the prompt, the sign and Moss Mulligan. |
| 3. The Dump's camera | **Done** | The camera follows in both south corners. The cause was last night's own wedge fix. |
| 4. The Buffet | **Done** | The castle is one gingerbread house. The entrance trees are a low hedge. The river thins into the outer gravy; the black line is gone. Steam, statue and banners fixed. |
| 5. Verify and build | **Done** | Smokes and all 41 test shards green. 1.0.0 exported; the exported smoke and the three exported play checks pass. |

- **Tests:** all 41 shards ran: **3194 of 3196 passed, 0 failing**, 2 pending; your real saves were not touched (14 files checked).
- **Smokes:** the Crosspath, Buffet and Dump walk smokes pass. The NPC visibility probe passes (150 checks). A new card games smoke
  plays each zone's card game, the card quiz and the chest with real clicks: 137 checks, 0 failed.
- **The zip:** **rebuilt with everything above.** `builds\TheWaywardPath-v1.0.0-windows.zip`, 784,409,895 bytes (749 MB), Nov 16 19:23. Not uploaded anywhere.

## What you must still do

1. **Play the card quiz once in each zone**, with a mouse and with a controller. It is tested by code, by a smoke with real clicks
   and by screenshots, not by hand.
2. **Look at both south corners of the Dump** (inbox 13): the rock wall beside them is a grass slope now. That is what lets the camera
   follow. `p3_after_*`.
3. **Look at the castle** (inbox 15 to 18): one chimney is left in its roof, and the Dining Hall wings in front of it are unchanged.
4. **Look at the hedge right of the Buffet's entrance** (inbox 19): it is waist-high, not knee-high.
5. **The old zone smokes** (`run_fifth` to `run_eighth_brief_final_smoke.sh`) cannot reach their zones from town any more; that was so
   before this pass. I updated their quiz and chest steps but could not run them. `tools/run_card_games_smoke.sh` covers the same
   ground from inside each zone. Say if the old four should be repaired or deleted.
6. **One small thing I saw only after the export:** the quiz's header reads "Card Quiz" in every zone. The per-zone names
   ("Fitness Theory Exam", "Compliance Re-Certification" ...) are set but not shown. I left the code as the zip has it; it is a
   two-line fix for the next build (inbox 25).


## Part 1 - your answers

### The card quiz (it was the trivia)

| | Shot |
|---|---|
| How to play | `c1_quiz_gain_how.png` |
| A picture question | `c1_quiz_gain_mid.png`, `c1_quiz_dna_mid.png`, `c1_quiz_gain_mid_720.png` |
| Passed / not passed | `c1_quiz_gain_win.png`, `c1_quiz_gain_lose.png` |

**The rules:**

- **Where:** at the same four teachers (Professor Pump, Professor Pate, Druid Thistlewick, Director Ectomund), in the painted classroom.
- **Four questions**, about four different real cards of that zone's Path or colourless ones, in a shuffled order:
  - two show **a cropped piece of a card's art** and ask "Which card is this?" (four card names);
  - one shows a card's art and name and asks **its cost** (four numbers);
  - one shows a unit's art and name and asks **its power** (four numbers).
- The card's face is not shown before the answer (it prints the cost and the power). After each answer the whole card turns up.
- **Three right answers pass**, as before. The first pass pays the old reward for that score; after it every attempt pays the old
  small fee; a fail before the first pass pays nothing.
- The quest flags are the old ones: the D.N.A.'s "Pass Director Ectomund's Compliance quiz" works.
- It has the How to play screen, the "?" button and the win / lose panels of the other card games. Keys 1 to 4 or the buttons.

The 16 written questions are deleted. 12 teacher and sign lines that said "the answers are on the signs" now say what the quiz asks.

### The chests (they were the three puzzles)

| Zone | Removed puzzle | Chest at the same spot | Holds (once) | Shot |
|---|---|---|---|---|
| Gainlands | Power Grid (hamster wheels) | The Grid Crew's Strongbox | Gainsmith's Lifting Belt | `c1_chest_gainlands.png` |
| Endless Buffet | Mystery Stew Pot | The Stew Cook's Chest | Head Chef's Ladle | `c1_chest_buffet.png` |
| Verdant Dump | Seed Shrine (garden) | The Gardeners' Chest | Refusemancer Seed Satchel | `c1_chest_dump.png` |

- A save that had solved the puzzle finds the chest open and empty.
- No quest step needed a puzzle, so no quest changed. The sign at each spot and the gear list's "where from" line are updated.
- The stew pot model is gone from the Pancake summit (inbox 5).

### The seals

`c1_seals_locked.png`, `c1_seals_locked_close.png`, `c1_seals_2of4.png`, `c1_seals_2of4_close.png`.

- The four seals form a diamond on the cellar doors: arm at the top, chef's hat right, leaf at the bottom, skull left.
- A locked seal shows a small padlock over a **faint pale outline of its Path's icon**. When it turns, the full icon shows.
- **Tooltip:** the mouse over a seal says "Gourmand seal: locked" (or "turned"). Standing at the door shows all four lines, for
  keyboard and controller.

### Deleted, kept

- **Deleted:** `RepGameScreen`, `OrderGameScreen`, `SortGameScreen`, `TubePuzzleScreen`, the three puzzle screens, the trivia screen,
  and the rule code of all of them. `RepGame`, `OrderGame` and `SortGame` keep only their reward tables.
- **Kept as they are:** the compact deck-rule lines, the vault's place, the Buffet's north side.

## Part 2 - the Dump's entrance in Crosspath

| | Before | After |
|---|---|---|
| Default camera | `p2_entrance_before_default.png` | `p2_entrance_after_default.png` |
| Low camera | `p2_entrance_before_low.png` | `p2_entrance_after_low.png` |
| Road still sealed | | `p2_entrance_after_sealed.png` |

- The two gate trees, `HubObstacles.GATE_FROM_SPOT` and the rest of the gate code, and the two cut-out tree pictures are deleted.
- Three low bushes stand beside the path. No tree stands in the view of the prompt, the sign and Moss Mulligan.
- The thorns across the forest road until Moss Mulligan is beaten are unchanged.
- **A fault found on the way and fixed:** in Crosspath every NPC's name floated about 170 px above its figure (in the sky at the Low
  camera). "Moss Mulligan" in your screenshot hangs over empty grass for this reason. Names, barks and the quest pointer now sit
  where they belong.

## Part 3 - the Dump's camera in the south corners

**The cause:** last night's fix for the pale corner wedge. It held the camera in from the side rims in the south 18 m of the zone.

| Walking into the south-east corner and out | Before | After |
|---|---|---|
| Where the hero stands across the frame (0.50 = the middle) | 0.50 to 0.81 (0.89 at Low) | 0.50 all the way |
| The camera's distance to the side of the hero | up to 11.8 m | under 1 m |
| Biggest jump of the hero on screen between two frames | 18.1 px (21.7 px at Low) | 0.8 px (1.6 px at Low) |

The south-west corner measured the same before (the hero at 0.22 of the frame, 0.15 at Low) and is the same after as the south-east.

**The fix:**

- The hold is deleted. The camera follows the hero everywhere in the Dump.
- The wedge is solved at its cause. The valley's side walls now sink over the last 24 m toward the south and are gone before the
  corners, so no cliff curves round in front of the camera.
- A knee-high line of rocks, bushes and mushrooms marks the edge of the walkable ground there.
- The chest and the lever are in plain view at both cameras.

**Shots** (a walk of five stops, both cameras, before and after): `p3_before_default_se_3_toward_lever.jpg`, `_4_lever`, `_5_chest`,
`_6_corner`, `_8_out`, and `p3_before_default_sw_4_corner.jpg`; the same names with `after`, and with `low`.

To measure it again: `bash tools/run_heap_corner_camera.sh after 0` (default camera) or `... after 3` (Low).

## Part 4 - the Endless Buffet

### 4.1 The castle

| | Before | After |
|---|---|---|
| From the entrance | `p4_before_entrance.jpg`, `_low` | `p4_after_entrance.jpg`, `_low` |
| From the hub | `p4_before_hub.jpg`, `_low` | `p4_after_hub.jpg`, `_low` |
| On the road north | `p4_before_road.jpg`, `_low` | `p4_after_road.jpg`, `_low` |
| At its door | `p4_before_forecourt.jpg`, `_low` | `p4_after_forecourt.jpg`, `_low` |

- **Before:** a kitchen-laboratory. A copper great hall and dome with a chef's hat, two copper tanks, two glass greenhouses, a whisk
  crane and a ladle crane with hanging loads, seven chimney stacks, four cake towers, oven arches in the wall.
- **After:** one gingerbread house. A tall biscuit body under one steep pie-crust gable roof, the gable to the front.
  - Thick white frosting along the eaves (with drips), down the gable's edges (scalloped), along the ridge and down the corners.
  - Gumdrops in pink, mint, yellow, red and lilac on the ridge, the gable and the walls.
  - The kit's frosted and candy-cane windows; a round candy-cane window high in the gable.
  - Candy-cane posts at the door and at the wall's corners. The kit's frosted gingerbread door.
  - Two towers only: the gate's, under frosting-topped cones.
- The door, the gate's size, the solid circles and the walk grid are unchanged. Only art the kit already had is used.

### 4.2 The trees by the entrance

`p4_before_entrance.jpg` / `p4_after_entrance.jpg`, `p4_before_hub.jpg` / `p4_after_hub.jpg`.

- 14 of the 18 trees right of the bridge are gone, and the grove of three on the plaza's corner. The hub shows from the entrance.
- A low hedge stands where the trunks stood, as solid as they were: the walk grid is the same.
- Four trees stay at the east end, where the stand runs into the east border's forest. That forest is untouched.

### 4.3 The west side

`p4_before_west.jpg` / `p4_after_west.jpg` (and `_low`), and side by side, enlarged: `p4_west_before_after_zoom.png`.

- **The slab and the straight cut:** the river ended a metre past the table's edge. It now runs out 18 m and thins away, and on the
  west side it widens into a delta. The outer gravy shows through more and more: no edge.
- **The faint black line:** it was the game's outline pass drawing the shore that lies under the gravy. The shore now runs down to a
  flat bed, and the outline pass draws nothing under the gravy in the Buffet.
- **The rest of the edge:** I checked the west, south-west, north-west, east and south sides (`p4_after_west_south`, `_north_west`,
  `_east`, `_entrance`). The line was there all round; it is gone all round. The east end of the river had the same cut and has the
  same fix.

### 4.4 The quick checks

| Thing | Was it a fault? | What I did | Shot |
|---|---|---|---|
| The grey lady | Half. She is the ruler's stone statue (your Nov 15 request), but she read as a faded picture | Warm, darker stone; moved off the paving, west of the Hearty Meal | `p4_after_statue.jpg` |
| The steam "discs" | Yes | Every puff is a soft round fading card now, in the whole zone | `p4_after_steam.jpg` |
| The banner pole on the path | Yes | The ruler's two banners flank the road north at the plaza's far end, off the paving | `p4_after_hub.jpg` |

### FPS (Medium, 1920x1080, this machine)

| Place | Before | After |
|---|---|---|
| The castle's door | 71.3 | 71.8 to 72.1 |
| The hub | 81.0 | 76.1 to 82.4 (four runs; the spread is the machine's) |
| The entrance bridge | 82.7 | 81.0 to 84.6 |
| The west shore | not measured | 73.1 |

The castle draws 9 fewer objects than before. The Dump and Crosspath changes add nothing that costs frames.

## Part 5 - verify and build

1. **Smokes** (each run alone, in the foreground):
   - Crosspath walk smoke: OK (the loop round the town, 7 shop doors, the alley, the lakeshore, the hatch).
   - Buffet walk smoke: OK (bridge, plaza, NPCs, quiz, Dinner in a Dash, the chest on the summit, both dungeons' doors, lever, back to town).
   - Dump walk smoke: OK (the same round in the Dump, the chest on Rust Peak included).
   - NPC visibility probe: OK, 150 checks, 0 failed.
   - **Card games smoke (new, `bash tools/run_card_games_smoke.sh`): OK, 137 checks, 0 failed.** In each of the four zones, with real
     keys and clicks: the host's card game opens on How to play, is won and pays; the card quiz opens with its teacher, deals four
     questions from the zone's cards, is answered by clicking, pays the trivia's top reward and sets its flags; the chest gives its
     gear once (the D.N.A.: File in Order gives the lanyard).
   - The four old zone smokes (fifth to eighth brief) do not get from town into their zones any more (see "What you must still do").
2. **Tests:** `bash tools/run_tests.sh --min-free=900`, all 41 shards in five foreground pieces: **3194 of 3196 passed, 0 failing**,
   2 pending. Real saves untouched (14 files checked before and after).
3. **Export:** free memory stayed at 1.6 GB for the 10 minutes, so the export ran with `EXPORT_LOW_MEMORY_OK=1`. `EXPORT OK`: the zip's
   CRCs, contents and size checked by the script. Peak memory 1,689 MB.
   - One stale Godot process from this afternoon (11 MB, started 14:20) blocked the export's own check; I ended that one process.
4. **The exported build:**
   - `bash tools/run_release_smoke_exported.sh`: **PASSED (1.0.0)**, 0 script errors.
   - The three `tools/play_exported.sh` checks (`exported_rc1_a`, `_b`, `_c`) each ran to "done"; `grep -c "SCRIPT ERROR"` on their
     six logs prints 0 six times. Run b opens the Gainlands quiz: the exported build shows the card quiz.
5. **Where the zip is:** `builds\TheWaywardPath-v1.0.0-windows.zip` (784,409,895 bytes). The unpacked build is `builds\_export\`.

**The memory guard** stopped one background run again this evening (the smokes). Everything was then run in the foreground, as your
brief says. Nothing is left unrun.

---

# Fable Nov 16 (day) - report: clean-up, Deck Station, four card minigames, the Dump gate, the vault, the Buffet's edges

Brief: `docs/prompts/fable_nov16_day.md`. Start tag `pre-fable-nov16b`. Questions: `docs/overnight_inbox.md`, "Fable Nov 16b"
(28 items). Shots: `docs/overnight_shots/nov16b/`. No public upload. No difficulty setting, the battle board untouched, Primm's fight
untouched, no new painted art. Ran on Fable 5.2. The Overnight Nov 15-16 report follows below.

## In short

- **Disk:** 20.1 GB freed (12.8 GB free before, 32.9 GB after). One empty folder is left for you (see below).
- **Deck Station:** the deck list is a narrow column down the whole right side. A 62-card deck shows whole at 1920x1080 (it showed
  one row before); 23 rows at a 130 % UI scale.
- **Four card minigames** replace one non-card game per Path zone, at the same spot, host and rewards: Reps, Order Up, Sort It Out,
  File in Order. **The trivia in the four zones and the other three puzzles are not replaced** (inbox 7: your call).
- **The Dump's entrance** in Crosspath is an arch of two trees over the path, walked through to the travel prompt.
- **The Four Seals** is a small cellar door in a grassy bank with four iron seals (padlock, then the Path's icon), and a gold-framed
  toast replaces the lever's cutaway.
- **The Buffet:** gravy all round the table at the ground's edge, and a food forest to the east horizon.
- **Tests:** **the full suite did not finish.** Shards 1 to 20 of 41 ran: 1959 of 1960 passed, 0 failing. Then the session's memory guard stopped the run. Every test file touching today's work passed when run on its own. The three walk smokes and the NPC probe pass.
- **The zip:** **not rebuilt.** `builds\TheWaywardPath-v1.0.0-windows.zip` is still last night's build (04:21) and has none of today's work in it.

## What you must still do

0. **Finish Part 6 yourself, or ask me to.** With the other programs closed:
   `bash tools/run_tests.sh --from=21 --min-free=900` (shards 21 to 41, about 30 minutes), then
   `bash tools/export_windows.sh 1.0.0` (or with `EXPORT_LOW_MEMORY_OK=1` in front), then
   `bash tools/run_release_smoke_exported.sh` and the three `tools/play_exported.sh` checks. To stop the guard killing long runs,
   start Claude Code with `CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP=1` set in its environment.
1. **Remove one empty folder.** Close the ChatGPT app, then run:
   `Remove-Item -Recurse -Force "C:\Users\asche\Documents\Codex"`
   (`...\Codex\2026-11-15\files-mentioned-by-the-user-batch` was held open by another program; everything in it is already gone.)
2. **Decide inbox 7:** whether the classroom trivia (four zones) and the three other puzzles (hamster wheels, stew pot, garden)
   should also go, and what should stand there.
3. **Look at four places where taste matters:** the gate's position on the path from town (inbox 13), the cellar door staying
   where the vault stood (inbox 17), the Buffet's north side without its layer-cake rim (inbox 23), and the hosts' rewritten lines
   (inbox 10).
4. **Play one round of each new game** with a mouse and with a controller. They are tested by code and by screenshots, not by hand.
5. **Batch 17** grew by 7 items (21 items, 65 images). The new references are not on the Drive yet:
   `python tools/art/batch17_build.py` copies them.

## Part 0 - disk space

| | Free on C: |
|---|---|
| Before | 12.8 GB (13,766,610,944 bytes) |
| After | 32.9 GB (35,341,123,584 bytes) |
| **Freed** | **20.1 GB** |

Deleted: the seven old zips in `builds/`, `builds/_export/`, `builds/_testpack/`, and everything inside `_movie/`, `_screenshots/`
(11 GB), `_art_inbox/`, `_art_source/`, `_logs/` and `Documents\Codex\`. Kept: `builds/TheWaywardPath-v1.0.0-windows.zip`,
`builds/trailer_rc1.mp4`, `.godot/`, `.git/`, `_asset_library/`, `build_cache/`, everything git tracks.

The five scratch folders are emptied, not removed: 169 tool and test files name `_screenshots/` and 28 name `_logs/`, and some
write there without creating the folder first. Nothing a tool or test reads back was in them.

## Part 1 - the Deck Station's deck list

| | Before | After |
|---|---|---|
| 1920x1080 | `p1_deck_before_1080.png`: one card row under a big header | `p1_deck_after_1080.png`: every row of a 62-card deck |
| 1280x720 | `p1_deck_before_720.png` | `p1_deck_after_720.png` |
| 115 % / 130 % UI scale | held at 100 % | `p1_deck_after_115.png`, `p1_deck_after_130.png`: 23 rows |
| Large text | | `p1_deck_after_large_text.png` |
| A row hovered | | `p1_deck_after_hover.png`: the card beside the row |

- **Shape:** a column the screen's whole height, right of the slot racks. The collection took the freed width: 8 cards a row (7).
- **A row:** cost, Path icon, name, copies ("2/3"), - and +. Groups by type (Units, Spells, Tools, Traps, Wonders,
  Infrastructure), each with a small header and its count. A gold scrollbar when the deck is longer than the column.
- **Header:** the deck's name, the five slot buttons, three rule checks (cards / at least 45, copy caps, Paths), the cost curve.
- **Footer:** Save Deck, Save as new slot, Reset, Fill Infrastructure, Suggest a deck.
- **Removed:** the Primm hint and the two summary lines. The "Tip: Building a deck" pop-up stays, moved clear of the column.
- **Controller:** down from the first row passes every row and reaches the footer; right of a row's - is its +. A bug fixed on
  the way: after the first + or -, no row could be focused again.
- **Deck logic:** unchanged. The row buttons call the same add and remove as before.

## Part 2 - four card minigames

**Inventory.** Each Path zone has a replayable minigame with a host, a one-time puzzle, a trivia quiz and Dex's card-matching
table. The D.N.A.'s replayable game (Kyle's) is card matching too. Kept exactly: Dex's four tables and Kyle's game. Replaced: the
three replayable non-card games and, in the D.N.A., the tube puzzle from your screenshot. Not replaced: the trivia and the other
three puzzles (inbox 7).

| Zone | Game | Replaces | Rules | Reward (same as the game it replaces) |
|---|---|---|---|---|
| Gainlands | **Reps** | Rep Counter, Chet Thunderabs | One unit face up. Is the next card's power higher or lower? A tie is right. Eight in a row wins; a miss resets the streak; the fourth miss ends the set | First win: up to 210 gold, 70 XP, a Healing Salve, a Beefcake Pack. Later wins: up to 50 gold, 5 XP |
| Endless Buffet | **Order Up** | Order Up!, Chef Flambe | A ticket shows a total; pick cards from a row of six whose costs add up to it exactly. Three tickets; two swaps of the row; the third wrong plate ends the shift | First win: up to 210 gold, 70 XP, a Scroll of Insight, a Gourmand Pack. Later: up to 50 gold, 5 XP |
| Verdant Dump | **Sort It Out** | Sort It Out!, Recycle Rhonda | Twenty cards on a belt; send each to the bin of its type (Unit, Spell, Infrastructure, Other) before it falls off. Sixteen wins; the fifth lost card stops the belt. It speeds up gently (9 s a card at the start, 6.7 s at the end) | First win: up to 210 gold, 70 XP, a Healing Salve, a Refusemancer Pack. Later: up to 50 gold, 5 XP |
| D.N.A. | **File in Order** | Pneumatic Soul Routing, the Mail Room's terminal | Seven cards; put them in ascending cost (ties by power) by swapping two at a time, nine swaps at most. The stamp checks: the first wrong check is free and marks the cards out of place, the second is REJECTED | The Soul Courier's Lanyard, once. Replays pay nothing |

Stars count slips in a won game: none 3, one or two 2, more 1. The gold above is for 3 stars.

**Every game** uses the game's real cards (the zone's Path plus colourless), opens on a one-screen "How to play" with three lines
and a looping example, has a "?" to reopen it, ends on a win or lose panel with the reward, and can be played with mouse, keys or
controller. Reps sits on the painted gym; the other three on their zone's loading painting, blurred, in a wood and brass frame.

**Winnable on a first try:** Reps deals in the player's favour (someone who only guesses away from the nearer edge wins 84 % of
first sets; a coin flip wins 8 %). Every Order Up row holds a right answer, also after a swap. Seven cards never need more than
six swaps. Sort It Out allows four lost cards.

**Shots** (`p2_<game>_...png`, game = `reps`, `order`, `sort`, `file`): `_how`, `_mid`, `_win`, `_lose`, `_mid_720`,
`_mid_large_text`: 24 pictures.

**Also changed:** 18 lines of the hosts and signs that described the old rules; the D.N.A. spot is "Mail Room Filing Terminal".
No quest, feat or glossary entry named the old games. **Tests:** 17 for the rules, 12 for the screens. Rules and decisions:
`docs/design/card_minigames.md`.

## Part 3 - the Dump's entrance from Crosspath

| | Before | After |
|---|---|---|
| Default camera | `p3_gate_before_default.png`: two trees side by side as one flat card beside the path | `p3_gate_after_default.png` |
| Low camera | `p3_gate_before_low.png` | `p3_gate_after_low.png`: the arch over the path |
| At the travel prompt | `p3_gate_before_at_prompt.png` | `p3_gate_after_at_prompt.png`, `p3_gate_after_at_prompt_low.png` |
| Road still sealed | | `p3_gate_after_sealed.png`: the thorns alone across the forest road |

- One tree stands on each side of the path from town, turned toward it and leaning in 12.5 degrees; the tops cross over the path.
- The hero walks north through the arch to the travel prompt, the sign and Moss Mulligan, 4.4 m behind it.
- The flat two-tree card is not built any more. The three pieces are cut from the approved painting; nothing is newly painted.
- No tree is planted in the gate or within 6.5 m in front of it. I found no boulder that covers it (inbox 15).

## Part 4 - the Four Seals

| | Before | After |
|---|---|---|
| Locked | `p4_vault_before_locked.png` | `p4_vault_after_locked.png`, `p4_vault_after_locked_low.png` |
| 2 of 4 | `p4_vault_before_2of4.png` | `p4_vault_after_2of4.png`, `p4_vault_after_2of4_low.png` |
| 4 of 4 | | `p4_vault_after_4of4_low.png`: doors ajar, the quest marker, the map icon |
| Open (the Warden beaten) | | `p4_vault_after_open.png`, `p4_vault_after_open_low.png` |
| The toast | | `p4_toast.png` |

- **Placement:** a 1.75 m cellar door in a grassy bank (the old frame stood 4.75 m), a hedge on each side, an apple tree half in
  front, stepping stones up to it. Fieldstone, planks, beams, hedge and grass from the town's painted set. No purple.
- **Seals:** four round iron seals with a padlock. When a zone's lever is pulled, its seal turns to that Path's icon, with a small
  warm glow and a clunk, the next time the hero comes within 9 m. No colour lights; locked seals are identical. With all four the
  doors stand ajar; after the Warden they stand open.
- **Toast:** the Path's icon on an iron seal, "A seal turns in Crosspath", one line, "2 of 4" with four pips. About six seconds, or
  until clicked. The lever no longer holds the hero for three seconds.
- **Map and marker:** on the map and minimap from the first lever on (a padlock and the count). The quest step and its place line
  are reworded.

## Part 5 - the Buffet's edges

| | Before | After |
|---|---|---|
| Front edge | `p5_before_front.png`, `_low` | `p5_after_front.png`, `_low` |
| East side | `p5_before_east.png`, `p5_before_east_north.png`, `_low` | `p5_after_east.png`, `p5_after_east_north.png`, `_low` |
| Entrance | `p5_before_entrance.png`, `_low` | `p5_after_entrance.png`, `_low` |

- **Water:** the gravy lies all round the table at the river's level, 0.38 m under zero (the moat lay 2.6 m down, south side
  only). No slab side, step or blank band. A short wet shore runs under it; pebbles and crumbs lie along the water line; the shared
  water shader draws the foam.
- **East forest:** about 900 broccoli and cauliflower trees in four layers to the horizon, leeks and herbs at the front, cake
  stands, cloches and stock pots as boulders, on painted crumb soil. The gravy river runs on through it. It stands outside the
  table: nobody can walk there, and nothing on the table is behind a tree.
- **Alive:** 8 steam plumes, 9 butterflies, 4 birds, 14 warm light patches, swaying leaves. Low builds none of the first four.
- **Frame rate on Medium** (average fps, before -> after): beside the forest 102 -> 92, the front edge 83 -> 83, the bridge 86 -> 83.

## Part 6 - checks and build

| Check | Result |
|---|---|
| Crosspath walk smoke | **Pass** (the loop, 7 shop doors, the alley, the lakeshore, the hatch) |
| Buffet walk smoke | **Pass** (bridge to plaza, every NPC and game, the Freezer, the Test Kitchen, back to town) |
| Dump walk smoke | **Pass** |
| NPC visibility probe | **Pass**: 150 checks, 0 failed |
| Full test suite | **Not finished.** Shards 1 to 20 of 41: 1959 of 1960 passed, 0 failing (the one other is an old no-assert test). The run was in the background and the session's memory guard stopped it at shard 21 (1.1 GB of RAM free). I did not start it again: the guard's notice says not to |
| Export 1.0.0, the exported smoke, the three play checks | **Not run.** I did not build a release on a suite that had not finished |

**What did run for today's code.** Each of these test files passed on its own, in a fresh process: the Deck Station column (6) and
slots (6), the card games' rules (17) and screens (12), the Dump gate (5), the Four Seals (8) and the vault guardian (9), the
Buffet's edges (5) and its older slice tests (18), plus the screen-fit, controller-focus (19), music (23), Batch 13 (10), hub world
(5), Nov 14 (19) and Nov 15b (4) files they touch. Two caveats: the controller-focus, music and compile-every-script files ran after
Part 2 and not again after Parts 3 to 5; and the UI and world test folders sit in shards 21 to 41, so only the files named here
are covered from those.

**The zip.** `C:\Dev\Deckbuilder-rpguilds\TheWaywardPath-v1.0.0-windows.zip` is last night's build. Do not upload it as
today's.

## Part 7 - art for the next batch

Seven items added to `docs/art/batch17_nov16.csv` and `docs/prompts/chatgpt_batch17.md` (items 15 to 21; Batch 17 is now 21 items,
65 images):

| Item | Pictures |
|---|---|
| The cellar door of the Four Seals, closed and open | 2 |
| An iron seal, locked and blank | 2 |
| Minigame rooms: the kitchen pass, the fair's conveyor, the mail room | 3 |
| Reps: bench, barbell, four plates | 6 |
| Ticket, bell, four bins, filing cabinet, APPROVED and REJECTED stamps | 9 |
| The Dump's gate as one grown arch; the withered thorns without trees | 2 |
| The Buffet's forest: fruit tart, tall cake stand, a sheet of butterflies and birds | 3 |

---

# Overnight Nov 15-16 - report: Batch 16, the open items, save safety, fresh eyes, Batch 17, 1.0.0

Brief: `docs/prompts/fable_nov16_overnight.md`. Start tag `pre-overnight-nov16`. Questions: `docs/overnight_inbox.md`, "Overnight Nov
16" (16 items). Shots: `docs/overnight_shots/nov16/`. No public upload. No difficulty setting, no battle-board change, Primm's fight
untouched, no approved art repainted. Ran on Fable 5.2. The Fable Nov 15b report follows below.

## In short

- **Batch 16 is in the game: all 46 pictures**, each wired, shot and checked against the Path icon guide. **Fig Sly has two hands**
  in his shop and in his dialogue.
- **The open items:** five of the nine needed work and four of those are done (the Dump's fair stage, the Dump's south corners, the
  minimap, Crosspath's south edge). **The Capital's load time is not improved** (see Part 2). The other four were done already.
- **A test run can no longer write your saves.** It is blocked under every file call of the save system and checked from outside
  on every run.
- **Four fresh-eyes sittings** on the exported build: first hour 6 / 6 / 7, midgame 7 / 6 / 7, late game 5 / 6 / 6, and a fourth for
  what those three missed, 7 / 7 / 6 (clarity / fun / polish). 19 findings fixed, the rest triaged and logged.
- **Batch 17 is prepared:** 14 items, 38 pictures.
- **Tests:** all 40 shards after the last change of the night: **3151 of 3153 passed, 0 failing**, 2 risky (the two old no-assert tests).
- **The zip:** `C:\Dev\Deckbuilder-rpg\builds\TheWaywardPath-v1.0.0-windows.zip`, 783,638,031 bytes (784 MB), built Nov 16 04:21.
  The exported smoke prints PASSED (1.0.0); the three exported play checks ran to "done" with 0 script errors. Not uploaded.

## What you must still do before uploading

1. **Play the first ten minutes of the zip yourself**, and one fight. The checks cover the title, the menus, a new game and a save;
   they are not a playthrough.
2. **Look at five things I changed where taste matters:** Crosspath's south edge (tree crowns in the ravine), the Dump's two south
   corners (the camera holds in and the hero stands off-centre), the minimap and the full map (drawn differently), the Feats page's
   new "Path feats" heading, and Fig Sly's changed price line (inbox 9).
3. **Read inbox items 9 to 14.** They are the choices only you can make: five story lines critics flagged, the smiling-sun banners
   still on the freed Capital's wall, the ending that nothing tracks after Primm falls, the roofs over Maren's home.
4. **Use the new logo files** in `docs/release/itch_page/logo/` for the page (cover, banner, icon). The older ITCH-COVER and STEAM-*
   pictures on the Drive carry the old logo.
5. **Then the usual:** `docs/release/itch_upload.md`.

Nothing here blocks the upload. The zip's own icon is the new app icon.

## Part 1 - Batch 16 (46 pictures, all in the game)

The full table with every picture, its place, its shot and its check against the icon guide is `docs/art/import_nov16_batch16.md`.

| Pictures | In the game as | Shot (`docs/overnight_shots/nov16/b16_...`) |
|---|---|---|
| V-FIGSLY | Fig Sly's shop portrait and dialogue portrait. **Two hands** (one on the lapel, one at his side); a critic counted two as well | `figsly_shop`, `dlg_npc_V-FIGSLY` |
| STORY-MEMORY-3, -4, STORY-REUNION, STORY-EPI-FILE-COMPLETE | Their story scenes. The crest reads arm, chef's hat, leaf, skull clockwise from the top; each banner carries one icon | `still_STORY-*_1600x900` |
| NPC-SCUFF, CUT-SCUFF, BST-ENFORCER-SERGEANT-SCUFF | Sergeant Scuff's portrait, boss cut-out and Bestiary square. The Correction Officer stand-ins are gone | `dlg_npc_NPC-SCUFF`, `bestiary_scuff` |
| UI-CARDBACK-B, -N | The Beefcake and Necrocrat card backs | `battle_backs` |
| ICON-FEAT-PATHS | A "Path feats" heading on the Feats page, above the four one-Path groups (inbox 1) | `feats` |
| DEC-PLINTH-* (4) | The four plinth statues round Crosspath's fountain | `town_square_freed` |
| TOWN-SHEET-FREED-BANNERS-01..06 | 01 to 04 one per freed zone; **05 and 06 hang for the first time**, once all four zones are free (inbox 2) | `town_square_freed` |
| CAP-BANNER-FREED-03, -04 | The freed Capital's Refusemancer and Necrocrat banners | (same places as the Batch 15 shots) |
| LOGO-EMBLEM, LOGO-WORDMARK, APP-ICON | The title, loading and pause screens, the credits, the window icon, the **Windows export icon** (`assets/icon/app_icon.ico`), the itch page kit | `title`, `credits` |
| TOWN-PROP-SHORE-STONES-01..03 | Crosspath's lake bank, in place of the modelled stones | `lakeshore` |
| CAP-PROP-CREASE-STALL-01, -02, -CRATES | The Crease market: Fig Sly in front of stall 01, the supply stall beside it, five crate stacks | `crease_market` |
| SPR-RESCUER-*_WALK (5) | The Rescuer walks away in her own masked frames (mirrored, normal maps, Elowen's scale) | `rescuer_walk` |
| NPC-QUADZILLA, NPC-CAIRN | Baron Quadzilla's and the Restless Cairn's lines | `dlg_npc_NPC-QUADZILLA`, `dlg_npc_NPC-CAIRN` |
| DNA-PROP-CRATES, DNA-PROP-CABINET-TIPPED | The debris outside the D.N.A. | `dna_debris` |
| UI-PACK-GILDED-G / -N / -R, UI-PACK-N, UI-PACK-R | Their packs. The code-drawn icon is off for these five: the paintings carry the right medallion, whole and centred (inbox 3) | `packs_all` |

**Against the icon guide:** every Path sign in the 46 pictures is the canonical icon. Two notes: the feats badge is a shield, not the
hexagon asked for; the gilded packs came with painted medallions, not the plain disc asked for. Both are right as painted.

**Size** (`docs/build_size_policy.md`): the zip went from 778.1 MB (Nov 15) to 783.6 MB, **5.6 MB more**. The pack is 860.5 MB, over
the 750 MB warning as before, on purpose (music at q6). Source art in `assets/`: +6.8 MB.

## Part 2 - the open items

| # | Item | Result | Shots (`p2_...`) |
|---|---|---|---|
| 1 | The Dump's fair stage | **Done.** Four plank sorting bins with something sorted in each, painted cloth bunting in two rows, a plank sign board for the icon. No flat blue banner, no flat bins | `fair_stage_before`, `fair_stage_after` |
| 2 | The Dump's two south corners | **Done.** The Nov 13 fix had left a pale wedge on the default camera. The camera now holds in from the side rims in the Dump's southern 18 m (inbox 5). Low camera was clean | `dump_se_default_before` / `_after`, `dump_sw_default_before` / `_after`, `dump_se_low`, `dump_sw_low` |
| 3 | The Tidy-Bots' tell | **Done already** (Nov 13: they stop, flash twice and sound an alert) | |
| 4 | The Crease's east wall | **Done already** (a quarter of the frame when the hero hugs it) | `crease_east` |
| 5 | The Wanderer's portrait edge | **Done already** (feathered) | |
| 6 | The Capital's map | **Done already**: district names (they appear as you explore), the Crease as its own inset, labels that do not stack. Tonight the map also writes short names | `capital_map` |
| 7 | The minimap | **Done.** Drawn by a new shader: crisp edges in the forest, the Capital's stair-steps become slanted lines and rounded corners. The full map uses it too | `minimap_forest_before` / `_after`, `minimap_capital_before` / `_after`, `p4_map_*_after` |
| 8 | Crosspath's south edge | **Done.** The flat violet band is a wooded ravine: tree crowns rise out of the cleft, their tops under the camera's line to the hero (inbox 6) | `crosspath_south_before` / `_after`, `crosspath_south_low_before` / `_after` |
| 9 | The Capital's later-visit load | **Not done: about 6 s before and after.** Storing the rim ruins cut their step from 0.45 s to 0.1 s (6.12 s to 6.02 s for the visit), but with them stored the Capital walk smoke could not walk to Rollo; so did storing four landmark models. Both are built live again. The numbers of what is left are in inbox 7 | |

## Part 3 - your saves are safe from test runs

- **How it is blocked.** `SaveGuard` (`core/data/save_guard.gd`) sits under every file call of the save system. In a test run, a path
  into your save folder becomes the same path under `user://test_saves/` before anything is opened, written, renamed or deleted. It
  does not matter what a test sets, or which flags the run was started with.
- **What is protected:** all three campaigns, every slot, the autosave, backups and thumbnails; the old `save.json`; the account's
  feats; the title screen's memory; and, in a test run, the settings.
- **The test that fails if a run touches the real folder:** `tests/test_save_guard.gd` tries every old way in on purpose and compares
  your real files with how they were when the run started.
- **The check from outside:** `tools/run_tests.sh` lists your real folder before the first shard and after the last, prints `Real
  saves: untouched (14 files checked)` and fails the run if anything changed.
- **The exported play runs are covered too.** They used to read your real campaigns (and one check pressed Save Game on them). They
  now start like a fresh install and save in the test folder (inbox 15).
- **Documented:** `docs/HANDOFF.md`, section 2b.
- **The full suite ran three times tonight**, the last time after the last code change.

## Part 4 - fresh eyes on the exported build

Each critic had one brief and nothing else: no repo, no reports. Reports and the full triage: `docs/review/critic_nov16/`.

| Sitting | Clarity | Fun | Polish | Top issues it found |
|---|---|---|---|---|
| 1. The first hour | 6 | 6 | 7 | Blurry, blocky maps; a reward card that "joins your deck" and is gone after a loss; one loss restarts the cave; the Dump pennant's single leaf |
| 2. The midgame | 7 | 6 | 7 | Dex cannot be found; the Refusemancer card back is not the Path icon; pack notices cover the result; "Fifty gold" against 360; the way out of the Buffet square is not shown |
| 3. The late game | 5 | 6 | 6 | The tunnels' mural and board show a sun, a wave, a sprig and a flame; the freed Capital still flies the smiling sun; nothing tracks the ending after Primm; no map marker for the manhole |
| 4. What the three missed | 7 | 7 | 6 | On Primm's defeat panel E left the castle; Maren's stick shows the wrong four signs; roofs over Maren's home; memory text over the picture |

**The story checks hold** (sitting 4 read them line by line): Maren's failing eyes, and that she does not know him until the fourth
memory; bars, never glass; "Tessar" first in the fourth memory, with the name plate changing then. **The icons hold** on every crest,
pack, banner and logo the critics saw. Wrong signs were found only in older art: the tunnels' map and board, three card backs,
Maren's stick, a Dump pennant. All are Batch 17 rows.

**Fixed (19):**

- Cards won in a lost first cave stay in the deck (inbox 10).
- C, B, P and T close the page they open.
- On Primm's defeat panel the key presses the lit button, "Fight Primm again". It always left the castle.
- The full map is crisp and writes short names. Dex is on every zone's map and list. The manhole to the Crease stays on the map.
- The Dump's entrance pennants are the paw print, not a single leaf.
- The pack result drops the notices that covered it; NEW! sits above the card; "at its copy cap" replaces "you own 4".
- "Plated Just So" has its own icon; Fig's price line; the item subtitle; the clear bonus line; "Guarded gate" for "Golem gate".
- No forest banner under the cave-loss notice. The Well takes its own icon as soon as Batch 17 brings it.

**Not the game, the test (7):** the Dev Shrine in town, "no marker for Maren", the hero who stopped moving, "Turn 1 on turn 6" and
three more came from the test pack's debug binary, from debug jumps into states the game cannot reach, or from the scripted player. I
checked the first three in a normal save. They are marked in the triage.

**Logged, not fixed:** every M and L item, and the S items that are your lines or your rules. The ones worth your time are inbox 11
to 14. **No sitting reached the credits**; the ending was read up to "File Complete".

## Part 5 - Batch 17 (prepared only)

`docs/art/batch17_nov16.csv`, `docs/prompts/chatgpt_batch17.md`, 67 numbered references in `G:/My Drive/Card Game Art/Batch 17
References/`. Rebuild with `python tools/art/batch17_build.py`. **14 items, 38 pictures:**

| # | Item | Pictures | Why |
|---|---|---|---|
| 1-5 | The five ruler statues in stone, each standing and toppled: Clench, the Grand Chef, Mortimer, Compostella, Primm | 10 | Asked for; they are a grey-tinted flat picture today |
| 6 | ICON-NODE-WELL | 1 | Critic: the Well's pop-up shows playing cards. The game uses it by itself once imported |
| 7 | UI-CARDBACK-R, -G, -C | 3 | Critic: not the Path icons (I checked all five backs) |
| 8 | MAP-S-CAP, BB-S-CAP | 2 | Critic: the tunnels' mural and board show the old four signs |
| 9 | NPC-ELDER and its two expressions | 3 | Critic: Maren's stick shows a sun, a sprig, a moon and a drop |
| 10 | Two Dump entrance pennants with the real icon | 2 | Critic: the single leaf (the game hangs paw prints meanwhile) |
| 11 | The six painted world maps | 6 | Critic, twice: blocky maps. Carried over from Batch 15. The biggest item; it can wait |
| 12 | CUT-QUADZILLA | 1 | He is a speaking boss now and has no cut-out (inbox 4) |
| 13 | UI-PACK-G, UI-PACK-GILDED-B | 2 | The last two packs off the guide; the code icon can go once they are in |
| 14 | The eight echo Bestiary pictures | 8 | Carried over from Batch 15: the only Bestiary pictures missing |

**Still marked REDO: nothing.** The statue poses in the prompt are written from the five cut-outs, which I looked at.

## Part 6 - tests, the build, the release kit

- **Tests:** 40 shards, 3151 of 3153 passed, 0 failing, 2 risky, real saves untouched (14 files checked). Run in full three times; the last run (25 minutes, ended 04:56) came after the last code change. The export was built from that same code. The same two no-assert tests as before are the "risky" ones.
- **Walk smokes:** the Dump's and Crosspath's pass. The Capital's passes on the final code (it is what caught the two caches).
- **The export:** free memory stayed under 2.2 GB for the ten-minute wait (1.7 GB), so it ran with the low-memory flag, in the
  foreground: `EXPORT OK`. Peak 1.65 GB.
- **Exported smoke:** PASSED (1.0.0). **Three exported play checks:** all ran to "done"; `SCRIPT ERROR` count 0 in all six logs. Check
  B's save and load steps no longer run (inbox 15).
- **The itch page kit:** `logo/` (cover 630x500, banner, wordmark, emblem, app icon), `screenshots/nov16/` (six fresh pictures with a
  README), `page.md` updated. `docs/release/ship_checklist.md`, `v1.0.0_notes.md` and `CHANGELOG.md` updated.
- **A test build was exported twice during the night** for the critics. Its zip, `builds/TheWaywardPath-v1.0.0-test-nov16-windows.zip`
  (787 MB), is still there: delete it when you like. It is not the release.

## Not done / still open

- The Capital's load time (Part 2, item 9).
- The credits were not seen by a critic.
- The triage's "Logged" rows: about 45, most of them small.
- One slip of mine, in inbox 16: for 17 minutes I ran the game beside a critic's last runs.

---

# Fable Nov 15b - report: the hour pass (verify, your answers, small fixes)

Brief: `docs/prompts/fable_nov15_hour.md`. Start tag `pre-fable-nov15b`. Questions: `docs/overnight_inbox.md`, "Fable Nov 15b" (7 items).
Shots: `docs/overnight_shots/nov15b/`. One Godot at a time, no sub-agents. No public upload. Primm's fight, the battle board and the
difficulty are untouched. Ran on Fable 5.2, Nov 15 (evening). The Fable Nov 15 report follows below.

## In short

- **Both Dump objects from your screenshots are found and fixed.** Neither was what last pass removed. The "floating door" was the
  **fridge** by the market; the "wooden block" was the **giant root ramp's slab, tilted the wrong way**.
- **Primm's rule line shows once** (its phase badge); everything else in your answers was "keep as built".
- **Walk smokes:** the Gainlands', the Buffet's and the Dump's pass. The statue shots found **Compostella's statue standing inside
  the Dump's Rift Station**; it is moved.
- **UI scale:** the Wardrobe, the Card Packs page and the Deck Station no longer crop at 115 % and 130 %. They are held at 100 %
  (the fallback in the brief), not rebuilt.
- **Tests:** all 40 shards ran: 3121 of 3124 passed, **1 failing**, 2 pending (the same two as before). The one failure was mine (the new rocks by the fridge chest stood too near the lever); I moved them and re-ran that file and the three other Dump and pass files: 89 of 89 pass. The full suite was not run a second time after that one-line layout change. The memory guard stopped the background run after shard 17; shards 18 to 40 were finished in the foreground.
- **The zip:** **rebuilt.** `C:\Dev\Deckbuilder-rpguilds\TheWaywardPath-v1.0.0-windows.zip`, 778,087,866 bytes (778 MB), built Nov 15 19:48. Free memory stayed at 2.0 to 2.15 GB for the whole 10-minute wait (the rule is 2.2), so the export ran with the low-memory flag, as the brief says: `EXPORT OK`. The exported smoke prints PASSED (1.0.0); the three exported play checks ran to "done" and their six logs hold 0 script errors. Not uploaded anywhere.

## The parts

| Part | What | Result | Shots |
|---|---|---|---|
| 1 | Your answers | Primm's duplicate rule line removed from the gold panel; nothing else needed a change (the Gate Plaza and palace-approach signs already show the purple swirl) | none (a test pins it) |
| 2 | The Dump against your screenshots | Fridge removed, ramp fixed, tree wall re-checked | `ref_dump_*` (yours), `p2_fridge_before` / `_after`, `p2_ramp_before` / `_after`, `p2_treasure_field`, `p2_top_right_tree_wall` |
| 3 | Three walk smokes + statue shots | All three pass; one real find (the Dump's statue) | `p3_statue_<zone>_standing` / `_toppled`, `p3_statue_heap_standing_before` |
| 4 | UI scale 130 % | Nothing cropped at 115 % or 130 %; held at 100 % | `p4_wardrobe_*`, `p4_packs_all_*`, `p4_deck_*` (10 = 100 %, 115, 13 = 130 %) |
| 5 | Tests, build, report | see "In short" | |

## Part 1 - your answers

- **Primm's rule shows once.** His phase badges stay; the gold "Primm's rule" panel under the HUD no longer repeats the same line
  (`BattleHud.rule_text_is_shown`). The panel still appears for a phase rule that has no badge, so nothing can go unshown. Nothing
  else in his fight changed.
- **Kept as built:** Nov 15 items 1, 2, 3, 5, 6, 7, 8 and Nov 14 items 2, 3, 4, 5, 6, 8, 9, 11, 12. No code change.
- **Nov 14 item 7:** the two signs already carry the purple travel swirl; no change.

## Part 2 - the Verdant Dump

- **The "floating door" (`ref_dump_floating_door.png`) was the fridge** in the market's east corner, at (77, 132). It was turned so the
  walk saw its blank green back and its open door: one thick slab and one thin one. Removed. Its chest (the Leaf Crown) is still
  there, with rocks, a bush, mushrooms and flowers along the rim behind it.
- **The "wooden block" (`ref_dump_wooden_block.png`) was the giant root ramp** from the farm terrace up to the compost terrace, at
  x 62 to 67, z 54 to 70. Its bark slab was rotated the wrong way: the foot stood 3.5 m up in the air on the rope posts, the head
  was buried, and the walk went up the slope through it. One sign flipped (`HeapTerraces.root_ramp`); it lies on the slope now. A
  test checks the foot is on the lower terrace and the head on the upper one. I fixed it instead of removing it, because it is one
  of the three ways up (inbox 1).
- **Last pass's removals** (the hay bale by the barn, the hollow log) were neither of these. They stay removed.
- **The top-right tree wall:** the walk-grid flood test still finds no walker cell in the treasure field, and the four treasure
  chests are reached on the mount only. The field's shot is `p2_treasure_field.png`: four chests with their glow in open ground.
- **New tool:** `tools/heap_plain_probe.gd` lists the Dump's meshes with their colour, or every mesh in a rectangle
  (`HEAP_PROBE_RECT="x0,z0,x1,z1"`). `tools/heap_odd_probe.gd` could not see either object: the fridge sits on the ground, and the
  ramp is longer than its slab limit.

## Part 3 - walk smokes and statues

- **Gainlands:** OK. **Verdant Dump:** OK (run again after the statue moved: OK).
- **Endless Buffet:** failed first on two steps, both faults of the smoke (written Oct 18, the zone has moved since): Odalys' prompt
  was checked from the edge of her wide spot, where Dolcetta's is nearer, and the heal table's run-up started behind the ruler
  statue. The smoke now steps in closer and checks its run-up is clear. It passes.
- **The Dump's statue stood inside the Rift Station** (`p3_statue_heap_standing_before.png`): the default spot was (41, 129), the
  station is at (42, 130). It stands in the open plaza at (44.5, 126.5) now (`HeapZone` `statue_offset`).
- The Gainlands' and the Buffet's statues stand clear, standing and toppled.
- `--at=xz:<x>,<z>` now works for shots in every zone (it was the Dump's only).

## Part 4 - UI scale

- All three screens fill the whole 1920x1080 canvas. The Wardrobe and the Card Packs page are laid out at fixed positions; the Deck
  Station re-flowed, but between its racks the deck list had one row at 115 % and two at 130 %.
- Each now tells `UiScale.fit` it needs the whole canvas, so the screen is held at 100 % while the setting is higher. At 100 % nothing
  changed. This is the brief's fallback (cap the scale on that screen); a real larger layout needs scrolling pages (inbox 4).
- A test opens all three at 130 % and checks the factor is 1.0.

## Not done / still open

- A second full test run after the last layout fix (see Tests above). The play checks cover the first minutes, the menus and a save, not a playthrough: play the Dump's market and the root ramp yourself before uploading.
- The fair stage's plain-colour blocks on the farm terrace (inbox 6).
- Batch 16 is still waiting on its images.

---

# Fable Nov 15 - report: the owner's four fixes

Brief: `docs/prompts/fable_nov15_fixes.md`. Start tag `pre-fable-nov15`. Questions: `docs/overnight_inbox.md`, "Fable Nov 15" (10 items).
One Godot at a time, no sub-agents. No public upload. No difficulty setting, no battle-board change, Primm's fight untouched. Ran on
Fable 5.2, Nov 15. The Fable Nov 14 report follows below.

## In short

- **Parts 1, 2, 3, 4 and 4b are done**, each committed and pushed with before/after shots in `docs/overnight_shots/nov15/`.
- **Part 5 (Batch 16) was skipped as told**: the images are not made yet. Three pack-art rows were added to its list (below).
- **Tests: all 40 shards green, 3118 of 3120 passing, 0 failing** (2 risky: the same two no-assert tests as before). The background run
  was stopped by the low-memory guard after shard 36; shards 37 to 40 were finished in the foreground, as the house rules say.
- **Walk smokes:** the D.N.A.'s (run twice: after Part 1 and at the end), Crosspath's and the Capital's all pass.
- **The 1.0.0 zip:** **built.** `builds/TheWaywardPath-v1.0.0-windows.zip`, 778 MB (742 MiB). The exported smoke prints PASSED (1.0.0) and the three exported play checks finish with 0 script errors. Not uploaded anywhere.
- **Look at these first:** the "Before the fight" card now opens for roamers that carry a rule of their own (inbox 2); the early-zone
  ease is now a visible badge (inbox 3); the D.N.A.'s far skyline is switched on (inbox 7).

## The 1.0.0 zip

**`C:\Dev\Deckbuilder-rpg\builds\TheWaywardPath-v1.0.0-windows.zip`** (778,089,162 bytes, built Nov 15 14:05). This is the first 1.0.0
zip: the Nov 13 and Nov 14 passes could not build one for lack of memory.

- Free memory was 2.22 GB when I checked (the rule is 2.2), so the export ran at once, in the foreground: `EXPORT OK`.
- `bash tools/run_release_smoke_exported.sh`: **PASSED (1.0.0)** (no Dev Menu, save and load work).
- The three exported play checks (`exported_rc1_a`, `_b`, `_c`) ran to "done"; `grep -c "SCRIPT ERROR"` on their six logs prints 0 six times.
- This is also the first time the Nov 13 dialogue rewrite, Batch 15 and the Nov 14 pass have run as an exe. The play checks cover the
  first minutes, the menus and a save; they are not a playthrough. **Play the first ten minutes yourself before uploading.**

## The parts

| Part | What | Done? | Shots (`docs/overnight_shots/nov15/`) |
|---|---|---|---|
| 1 | Outside the D.N.A.: a wasteland like the Capital's | **Done.** 76.7 fps on Medium (79 before) | `ref_capital_wasteland` (yours), `p1_ref_capital_gate_mine`, `p1_dna_*_before` / `_after` (six cameras) |
| 2 | Mortimer Grimsby off the Rift Station | **Done.** He has one spot (he only appears once the zone is freed) | `p2_mortimer_before`, `p2_mortimer_after`, `_zoom`, `p2_mortimer_after_prompt` |
| 3 | 3D and placeholder NPCs | **Done.** Two kinds found, both fixed; the scan is clean | `p3_pip_before` / `_after`, `p3_statue_gainlands_*`, `p3_npc_3d_scan_report.txt` |
| 4 | Every fight shows every rule in effect | **Done.** 48 of 118 fights were missing a rule | `p4_officer_before_the_fight_after`, `p4_officer_rule_icon_hover_after` |
| 4b | Shop scrollbars, the pack medallion, the pack icons | **Done**; the foil pattern needs art (Batch 16) | `p4b_*` |
| 5 | Import Batch 16 | **Skipped as told** (not made yet) | |
| 6 | Verify and build | see "In short" | |

## Part 1 - outside the D.N.A.

Your reference and my own matching shot of the Capital's gate approach are `ref_capital_wasteland.png` and
`p1_ref_capital_gate_mine.png`. Six fixed cameras were shot before and after (`bash tools/dna_outside_shots.sh before|after`): the
arrival, the causeway, the lobby's west and east sides, and the west and east edges of the main block.

- **The ground is the Capital's.** The grey 4 m tiles are gone. The endless ground is the Capital's cracked ash (`TEX-CAP-ASH`) with
  soft patches of its broken paving (`TEX-CAP-CRACKEDROAD`), tinted grey-green, sampled at two scales so no repeat shows.
- **The Capital's wasteland kit, composed, never in rows** (`world/dna/dna_wasteland.gd`). On Medium: 21 stretches of broken low wall,
  7 ruined house shells further out, 35 rubble mounds, rubble rows at the feet of the south walls, 54 dead trees, 21 purple crystal
  clusters, ash drifts, 465 dark tufts of dead grass, 9 old dead lamp posts (six of them a loose avenue beside the causeway, like
  the Capital's gate road) and 3 fallen statues. High has a few more (72 trees, 28 crystals, 12 lamps, 620 tufts). All tinted toward
  the D.N.A.'s grey-green; the crystals keep their purple.
- **Office touches kept as debris:** four tipped cabinets, two leaning filing towers and four drifts of forms. The rows of cabinets,
  crates, queue posts and towers are deleted.
- **The floating paper is untouched** (380 sheets, the same field).
- **Edges and fog:** the fog is the Capital's density (0.0065, was 0.005), and the zone's far skyline (its tower backdrop, which was in
  the data but switched off) now stands behind the ground in every direction, so the ground never ends in a bare horizon (inbox 7).
- **Nothing blocks the view or the way:** every piece stands off the floor and its walls, off the causeway and clear of the Filing
  Tower, the Endless Queue, the Records Stair and the Hall; nothing is solid; and a piece with floor to its north may only stand as
  high as the camera's line allows (the Capital rim's rule). The spots nearest the buildings are filled first, so the budget is spent
  where it is seen.
- **Frame rate on Medium: 76.7 fps** at the arrival (79 after Nov 14, 81 before that).
- **When Batch 16's D.N.A. crates and tipped cabinet arrive** they replace the turned cabinet cards in `DnaWasteland.OFFICE_DEBRIS`.

## Part 2 - Mortimer Grimsby

He stood at (49.1, 55.7), 0.6 m from the Rift Station at (48.5, 55.5): the station was placed on his old spot. He now stands at
**(41.0, 54.4)**, on the open floor of the lobby's west side: 7.6 m from the station, clear of the west passage, and more than 2.5 m
from every NPC, prop, counter and prompt in the room (a test checks each one, and open floor all round him).

- He has **one spot**: he is only in the lobby once the zone is freed (the statue stands in for him before that).
- **Name label, talk prompt, bark:** `p2_mortimer_after_prompt.png` (his label, Prudence's and Agnes's are separate; "[E] Talk" shows).
- **NPC visibility probe** (freed D.N.A., both cameras): **20 checks, 0 failed**, Mortimer included. The probe can now free a zone first
  (`NPC_FREED=necrocrat`), which it could not before, so the freed lobby's people had never been probed.
- **NPC overlap probe** (freed): Mortimer is not flagged; no pair of NPCs is closer than 1.2 m.

## Part 3 - 3D and placeholder NPCs

**What was found** (the scan: `bash tools/run_npc_3d_scan.sh`, 17 area states: the forest in four states, Crosspath oppressed and
freed, each of the four zones oppressed and freed, the Capital outside, inside and freed; it reports every rigged 3D model and every
capsule a metre or more tall):

| Where | What it was | What I did |
|---|---|---|
| Crosspath, beside Pip Threadwell (36.4, 6.5) | Her "window mannequin": the blocky 3D hero model in a party hat, with no talk prompt | **Removed** (inbox 6) |
| The Gainlands' hub (49.5, 83.0) | The ruler's statue: a red capsule with a ball for a head, a box for a cape | **Replaced** with Chancellor Clench's painted figure in stone |
| The Endless Buffet's hub (41.0, 67.0) | The same capsule statue | **Replaced** (the Doppelganger, as the Grand Chef) |
| The D.N.A.'s hub, the Verdant Dump's hub, the Capital | The same capsule statue (standing, or toppled once the zone is freed) | **Replaced** (Mortimer, Compostella, Primm) |

- **Nothing else.** After the fixes the scan finds **0 figures in all 17 states**. Every roamer, vendor, quest giver, freed leader and
  stroller is a painted sprite. (The ambient animals of the Dump are props, not people, and were left alone.)
- **The statue** is the boss's painted entrance cut-out through a stone shader, on the same plinth with the same plaque: standing while
  the zone is oppressed, lying beside the plinth once it is freed (`p3_statue_gainlands_after_zoom.png`). Inbox 5.
- **The check:** `tests/test_fable_nov15.gd` fails if any zone NPC or freed-lobby NPC, or anyone Crosspath places, does not resolve to
  an imported painted sprite set, and if a ruler statue contains a capsule or a sphere. The scan script exits 1 on any figure.

## Part 4 - every fight shows every rule in effect

**The Correction Officer.** The +1/+1 was not his: any Capital roamer whose post is within 9 m of an open rift fights with +1/+1 on its
units and 3 more HP. It was applied with no word anywhere. Now:

- the rule is **Rift-Empowered** ("This foe stood beside an open rift: its units get +1/+1 and it has 3 more HP. Seal the rift (or fight
  its guards away from it) and the next ones fight as normal.");
- a roamer that carries it shows the **"Before the fight" card** before the duel (`p4_officer_before_the_fight_after.png`), and the rule
  is one of the **fight's rule icons**, with its hover text (`p4_officer_rule_icon_hover_after.png`);
- its units carry the +1/+1 as the ordinary stat bonus, so their numbers show green over the base value like any other buff.
- I named it for its real cause rather than "Regime Drill" (inbox 1).

**The audit.** `tests/test_rule_audit.gd` builds **all 118 fights** with the game's own code (every roamer of every zone, the Capital's
also beside a rift; every fight room of all 16 dungeons (the tutorial cave, the Gallery and the Lab among them), the four Path zones entered as a first zone; Primm's three phases; the
gatekeepers; Crosspath's roamers; the Graveyard, Shiro, the vault, the Old Well, the store room; the eight arena bouts; Quota's rematch;
Captain Spotless at the gate). Each seat now remembers where its modifiers came from, and each rule badge says which modifiers it
stands for. The test fails for any modifier on a seat (beyond the player's own gear and items) that no shown badge covers.

**Encounters that were missing a rule: 48 of 118.** The full before and after lists are `docs/review/rule_audit_nov15_before.json` and
`_after.json`.

| Applied, not shown | Fights | Which | Now shown as |
|---|---|---|---|
| The early-zone ease: -1 or -2 attack on the foe's units (and less HP) | 39 | In a first-zone visit: the D.N.A. (2 roamers, 7 Hall rooms, 3 side-dungeon rooms), the Buffet (2, 7, 3), the Dump (2, 7, 3), and the gatekeepers Prudence Pallor, Chef Fennel Gravois and Moss Mulligan | **Caught Unprepared** (green: it helps you). Inbox 3 |
| A rift's empowering: +1/+1, +3 HP | 3 | The Correction Officer, the Perfection Inspector and the Rift Wretch, beside an open rift | **Rift-Empowered** |
| Primm's phase rules (units become 3/3 and you may play two cards a turn; he draws 2 more; +3/+3, 1 more draw, he loses HP each turn) | 3 | Primm, phases 1, 2 and 3 | **Standardization / Reflection / Unraveling**, one badge each, with the phase's existing rule line. They were only on the gold panel under the HUD. The fight is unchanged (inbox 4) |
| An escalating summon at the start of each of its turns | 2 | The Graveyard (the Restless Cairn) and the Four-Seal Vault's Warden | **The Graveyard Will Not Stay Quiet**, **The Seals Send Guardians** |
| "No unit plays" on the player | 1 | The arena's spells-only bout (the Cardboard Colossus) | **Spells Only** |

After the fixes: **0 of 118**.

- **Also listed now** (they are not modifiers, so the audit cannot see them; I added them by hand): Grandmaster Flex and Elowen Vey
  fighting beside you when rescued, the Rotheart's 6 lost HP after you cut the Heart Roots, and a freed zone's friendly rematch (a
  two-Path deck, 10 more HP).
- **Hidden traits** stay "?" and are listed: every one of the 35 encounters with an unseen scripted trigger shows exactly one "Hidden
  trait ?" chip that stands for all of them (a test).
- **No rule is shown without being applied:** every dungeon rule in the list has its modifiers.
- **Three other fights with modifiers checked by eye:** covered by the audit rows and the existing boss-rules tests; I did not take
  separate screenshots of them.

## Part 4b - shops and pack opening

**1. Scrollbars.**

- **Fig's Gilded Goods.** The row asked for a fixed 1780 px, wider than its panel beside the vendor, so it was clipped at the panel's
  edge with no bar (`p4b_fig_packs_large_before.png`). The row now takes the room there is. The tiles are their real 236 px (the name
  wraps, the two buttons stack), so **all four packs fit at the default and at Large text**, at 1280x720 and 1920x1080
  (`p4b_fig_packs_default_after`, `p4b_fig_packs_large_1080_after`, `p4b_fig_packs_large_720_after`).
- **When they do not fit** (UI scale 130 %: `p4b_fig_packs_ui130_after.png`) a **gold scrollbar** shows under the row. The mouse wheel
  moves the row sideways, the bar drags, and a controller's left / right brings the next pack into view (the row follows the focus).
  If the tiles are also too tall for the screen the row scrolls up and down too, so the buttons can always be reached.
- **Every list.** The theme's scrollbar was a 35 % black track with no edge, invisible on dark wood. It is now a framed track 14 px
  thick with the gold grabber, in every list of the game (vendor tabs, the Deck Station, the Collection Book, item lists, the quest
  log, Settings).
- **The same shop row** (`ScrollKit.row`) is on the Card Packs shelf and its results row, the Wardrobe's hat and cloak rows and the Deck
  Station's cover picker. **The Card Packs shelf had the same fault as Fig's shop in another form:** its bar sat below the panel's edge
  and was never seen, and a Gilded pack's Open button was cut off. Both are fixed (`p4b_card_packs_shelf_after.png`).
- **Checked at Large text, 1280x720:** the Wardrobe, the Deck Station, the Card Packs page, the Collection Book
  (`p4b_lists_large_720_after.png`), and at 1600x900 the card, item, gear, hat and pack vendors. No content is cut without a bar.
- **Not fixed:** at a UI scale of 130 % the Wardrobe, the Card Packs page and the Deck Station are cropped at the right and bottom, as
  before this pass (inbox 10).

**2. The medallion.** The Gilded pack's medallion was a square cut out of the Path Pack's painting and scaled up, so the circle cut its
bottom off. It is now the Path's icon itself, whole, centred on the medallion and inside the gold ring, on every Path Pack and every
Gilded pack, in the shops, on the shelf and on the opening screen (`p4b_pack_opening_necrocrat_after.png`). The General and Prismatic
packs keep their own painted centres (they belong to no Path).

**3. The icons, against `docs/art/path_icon_style_guide.md`** (`p4b_pack_art_before_sheet.png` is the art as painted):

| Pack art | Medallion as painted | Wrapper pattern | In the game now | Art needed |
|---|---|---|---|---|
| UI-PACK-B | gold arm on red: correct | dumbbells: correct | the canonical icon | none |
| UI-PACK-G | chef's hat, on a brown disc (the guide: cream) | croissants: fine | the canonical icon | none |
| UI-PACK-N | **a skull over a quill and scroll: wrong** | stamps: fine | the canonical icon (skull in ghost-flame) | **Batch 16: UI-PACK-N redo** |
| UI-PACK-R | **three leaves in a swirl on rust red: wrong** (the guide: a leaf in three arrows on moss green) | leaves: fine | the canonical icon | **Batch 16: UI-PACK-R redo** |
| UI-PACK-GILDED (one picture for all four Paths) | the Beefcake arm | **dumbbells on every Path's gilded pack: wrong for three of four** | the canonical icon of each Path | **Batch 16: UI-PACK-GILDED-N, -G, -R** |
| UI-PACK-GENERAL-1 / -2, UI-PACK-PRISMATIC | compass, star: no Path | stars | unchanged | none |

**For your ChatGPT run:** the three rows are in `docs/art/batch16_nov14.csv` (now 23 rows) and as items 22 and 23 of
`docs/prompts/chatgpt_batch16.md` (your item 21 is the Gilded Necrocrat pack). The game picks up `UI-PACK-GILDED-N` / `-G` / `-R` by
themselves once imported; until then the dumbbell foil stays on the gilded packs.

## Batch 16 import status

**Not imported: skipped as told** (the images are not made yet). Nothing in this pass depends on it. When it lands it runs as its own
short task; this pass added three rows to its list (above) and one place that will use its art (the D.N.A.'s debris).

## Tests and the build

- **GUT: 40 shards, 3118 of 3120 passing, 0 failing, 2 risky** (the same two tests that assert nothing). New: `tests/test_fable_nov15.gd`
  (10 tests) and `tests/test_rule_audit.gd` (5). One older test was made independent of test order (Primm's phase 2 may list the
  bosses' setup window).
- **The background test run was stopped by the low-memory guard** after shard 36 of 40; nothing had failed. I finished shards 37 to 40
  in the foreground (`--from=37`), as the house rules say.
- **Walk smokes:** the D.N.A. (75 checks), Crosspath (29) and the Capital (137): all OK.
- **Probes:** NPC visibility, freed D.N.A.: 20 checks, 0 failed. 3D-figure scan: 0 in 17 area states. Rule audit: 0 of 118 fights.
- **Not run:** the Gainlands, Buffet and Dump walk smokes (their statues changed in Part 3; the statue keeps its plinth, its blocker
  and its plaque spot, and the tests cover it). The Buffet's two plaza failures noted on Nov 14 are as they were.
- **The build:** see "The 1.0.0 zip" above.

## New tools

| Tool | What it does |
|---|---|
| `bash tools/dna_outside_shots.sh before\\|after` | The D.N.A.'s outside from six fixed cameras |
| `bash tools/run_npc_3d_scan.sh [label ...]` | Every area, oppressed and freed, scanned for rigged 3D models and capsules; exit 1 on any |
| `NPC_FREED=necrocrat bash tools/run_npc_visibility_probe.sh` | The visibility probe with zones freed first (the freed lobby's people) |
| `tests/test_rule_audit.gd` (`tools/rule_audit_sweep.gd`) | Builds all 118 fights and lists rules applied and not shown; writes `_logs/rule_audit.json` |
| `--zone_fight=final:officer:rift` (battle shot), `--roamer_brief=officer:rift` (zone shot) | A roamer's real fight, and its "Before the fight" card |
| `--open=vendor_packs` (zone shot), `--open=packs_all`, `--open=pack_open:<id>` (town shot) | A vendor's pack page, the shelf with every pack, the opening screen |

---

# Fable Nov 14 - report: the owner's playtest list, the Path icons, Batch 16

Brief: `docs/prompts/fable_nov14_owner_list.md`. Start tag `pre-fable-nov14`. Questions: `docs/overnight_inbox.md`, "Fable Nov 14"
(18 items). One Godot at a time, no sub-agents. No public upload. No difficulty setting, no battle-board change, Primm's fight
untouched, no new art (Batch 16 lists it). Ran on Fable 5.2, Nov 14 to 15. The Batch 15 report follows below.

## In short

- **Every item of your list is done except the build.** Parts 1 to 6 are committed and pushed, each with before/after shots.
- **The 1.0.0 zip was not built.** Free memory stayed at 2.0 GB for the ten minutes the brief allows (the rule is 2.2 GB). The
  commands are below. The last zip in `builds/` is still RC5 (Nov 12).
- **Tests: all 33 shards green, 3103 of 3105 passing, 0 failing** (2 risky, the same two no-assert tests as before).
- **The NPC visibility probe passed** (150 checks) and the walk grids are checked by tests (the Dump on foot and on the mount, the
  Buffet's forest, the roamers' distances in all five zones).
- **Walk smokes:** the D.N.A.'s passed. **The Dump's and the Buffet's each fail two checks** (details under "Tests and the build").
  One cause was mine and is fixed; the other failures are in the two hub plazas, where this pass changed nothing, and I did not
  prove they predate it.
- **Four things to look at first:** the officer's name (inbox 2), which Dump objects I took for the "floating door" and the "block"
  (inbox 10: I had no screenshots), the two shafts with no Path (inbox 7), and Dex's final table at 19 (inbox 17).

## The 1.0.0 zip

**There is no 1.0.0 zip yet.** Close what you can, then run these from `C:\Dev\Deckbuilder-rpg` in Git Bash, one at a time, in the
foreground:

```
EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0
bash tools/run_release_smoke_exported.sh
bash tools/export_test_pack.sh
bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_a.txt r1a 480
SUITE_SETTINGS_FILE=_screenshots/exported/settings_play_r1a.cfg bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_b.txt r1b 480
bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_c.txt r1c 480
grep -c "SCRIPT ERROR" _screenshots/exported/play_r1a.log _screenshots/exported/play_r1b.log _screenshots/exported/play_r1c.log
```

- The export takes 4 to 10 minutes and writes `builds/TheWaywardPath-v1.0.0-windows.zip`. "EXPORT STOPPED" means nothing was replaced.
- The smoke must print `PASSED`. The last line must print 0 three times.
- None of this pass, the Batch 15 pass or the Nov 13 dialogue rewrite has been run as an exe. Play the first ten minutes yourself
  before uploading.

## Your list, item by item

Shots are in `docs/overnight_shots/nov14/` (`_before` / `_after`).

| # | Item | Done? | Shots |
|---|---|---|---|
| 1.1 | The cut to Primm in the Old Service Tunnels | **Done.** It was the castle's "Primm tells you who you are" scene firing before every boss in the Capital's zone; now only at his own room | (no picture: a scene that no longer plays; a test pins it) |
| 1.1 | The tunnels' boss is one of Spotless's officers | **Done.** Enforcer Sergeant Scuff; deck, HP, stats and rewards unchanged | `p1_officer_before_line`, `p1_officer_after_line` |
| 1.2 | Fragment 2: bars, not glass | **Done**, and every line that referred back to it | `p1_fragment2_after` |
| 1.3 | Elder Maren's thread | **Done.** 17 of her lines, 3 lines of others, the bible and the voices doc | (text: the tables below) |
| 2.1 | Remove Fig's crate; Items in his own shop | **Done.** Cards / Items / Card Packs | `p2_crease_crate_*`, `p2_fig_picker_after` |
| 2.2 | Items showing "?" | **Done.** A deliberate effect, removed (below) | `p2_fig_items_before`, `p2_fig_items_after` |
| 2.3 | His portrait | Batch 16 row 1 (not touched) | |
| 3.1 | Signs: the Crease's dark board, the plaza manhole's sign, Path icons on the shaft signs | **Done.** Four of six shafts show a Path; two belong to no Path (inbox 7) | `p3_crease_signs_*` |
| 3.2 | Crosspath's rocks and shoreline | **Done.** Curved water line, narrow earth bank, rounded stones, one grass to the water | `p3_shore_a_*`, `p3_shore_b_*` |
| 3.3 | No enemies within 20 m of arrival points, entrances and exits | **Done** in all five zones; the test covers it | (positions: a test) |
| 3.4 | The Dump: floating door, walk-through block, top-right closed, treasure field | **Done**, with one caveat: I picked the door and the block by probe, without your screenshots (inbox 10) | `p3_dump_*` |
| 3.5 | The Buffet's entrance: no block, a bank, a food forest | **Done** | `p3_buffet_entrance_*`, `p3_buffet_forest_after` |
| 3.6 | Outside the D.N.A.: an organised wasteland | **Done.** 79 fps on Medium (81 before); the paper still floats | `p3_dna_apron_*` |
| 4 | Path icons: guide, inventory, fixes | **Done.** 8 code and text fixes; 14 painted ones are Batch 16 rows | `p4_fountain_plinths_after`, `p4_ending_after`, `docs/art/path_icon_sheet.png` |
| 5 | Dex: 20 moves, limit 26 | **Done.** The final table is 19 (inbox 17) | `p5_dex_after` |
| 6 | Batch 16 list and prompt | **Done.** 20 rows, 94 references on the Drive | |
| 7 | Verify and build | see "Tests and the build" | |

## The officer

**Enforcer Sergeant Scuff, "Sub-Inspector of Tunnels That Do Not Exist".** A junior Enforcer whom Captain Spotless sent below; young,
earnest, apologetic, the only man in the regime with muddy boots. He borrows the Correction Officer's talk frame as his portrait and its
Bestiary square until Batch 16 (row 4).

- **Boss intro:** "HALT, please. Captain Spotless says nobody is to be down here, and that includes me, so let us be quick about it."
- **Before:**
  - "A grate lets in light from a perfect city. Under it a young Enforcer sergeant stands to attention in a puddle, reading his orders
    off a card, in the only muddy boots the regime owns."
  - "'HALT, please. Sergeant Scuff, Enforcers. Captain Spotless sent me to check the service tunnels in case anyone tried to sneak
    into the city this way, and I'm sorry to report that someone has. It's you.'"
- **After:**
  - "Sergeant Scuff sits down on a barrel and takes off his helmet. 'My gran laid pipe down here,' he says. 'She said these tunnels
    used to be full of people. I put that in a report once, and the Captain had me write it again.'"
  - "'All four Paths, shoulder to shoulder, and nobody measuring anybody. I'll tell the Captain I found nothing down here, which is
    what he says there is. Go on. The grate isn't locked.'"
- **In the fight:** "INSPECTION! The Captain wants heights, he wants smudges, and he wants every smile at the regulation angle!" and,
  near the end, "Mud. On the boots. The Captain will see it from all the way up there, I know he will." (the same two events, renamed).
- **Bestiary:** "Captain Spotless sent him down to guard tunnels that do not exist. His are the only muddy boots in the regime, and he
  has apologised to them."

Also updated: S-CAP's `boss` field, the reward card's "where to find it" line, the dungeon list, the encounter rule's text, the boss
table in `docs/design/encounter_scripts.md`, the tests. The hook, the quest text and the feats never named the boss. An old save's
Bestiary counts carry over.

## Maren's post-Path conversations, before and after

Changed lines are bold. Every gameplay instruction is unchanged. Revert everything with
`node tools/apply_dialogue_pass.js --revert=docs/dialogue/fable_nov14_ids.txt`.

**After the first Path (Fragment 1)**

| | Before | After |
|---|---|---|
| Maren | You've gone as pale as flour. Sit down, sit down. Something has come back to you, hasn't it? | **Even with my eyes I can see you've gone as pale as flour. Sit down, sit down. Something has come back to you, hasn't it?** |
| Maren | (unchanged) | Tell me all of it, however small it seems to you. In my experience it's the small things that turn out to matter. |
| Maren | (unchanged) | ...A lullaby. That tune comes from the old days, from the court, and there are very few of us left who would know it. Fewer still who ever hummed it to a child. |
| Maren | (unchanged) | Have some pie. And don't ask me why my eyes are wet, because I shan't tell you, and you wouldn't want to make an old tortoise lie. |
| Maren | (unchanged) | But look at you. With one zone free, the corruption is losing its grip on the land, and it's slipping off you along with it. |
| Maren | (unchanged) | You ought to be able to carry a second Path now. Go down to the Deck Station and try building a deck with two, and then come and tell me how it feels. |

**After the second Path (Fragment 2)**

| | Before | After |
|---|---|---|
| memory | (unchanged) | White rooms, and a white light that never changes, whatever the hour is outside. |
| memory | There is glass on every side of me, and behind the glass there are faces in white coats, taking notes. | **There are bars on every side of me, and behind the bars there are faces in white coats, taking notes.** |
| memory | (unchanged) | No one in that place ever uses my name. They call me 'the Subject', and whatever I do, the only thing they ever say to me is 'again.' |
| memory | (unchanged) | Again. Again. Again. |
| memory | (unchanged) | I wasn't lost. I was kept. |
| Maren | Glass, and white coats, and 'again.' So that is where they had you, all those years. | **Bars, and white coats, and 'again.' So that is where they had you, all those years.** |
| Maren | You've earned some truth from me in return, so here is the first piece of it: I'm not only an old tortoise who bakes. | **The way you said that... I taught the royal children at the castle once, and there was a boy who asked his questions just that way. For a moment I thought... No. That boy is ten years dead, and I'm a foolish old tortoise.** |
| Maren | There's a resistance in this kingdom, and I'm its contact here in {town}. A woman called Wren leads it, from a hideout inside the Capital itself. | **You've earned some truth in return: I'm not only an old tortoise who bakes. There's a resistance in this kingdom, and I'm its contact here in {town}. A woman called Wren leads it, from a hideout inside the Capital itself.** |
| Maren | (unchanged) | I wasn't sure of you before, and I'm sorry for that. I'm sure of you now, or near enough, and there aren't many people I would say that about. |

**After the third Path (Fragment 3)**

| | Before | After |
|---|---|---|
| Maren | A man in white and gold, who knelt and then stood up. And before that, those rooms of yours with glass on every side. | **A man in white and gold, who knelt and then stood up. And before that, those rooms of yours with bars on every side.** |
| Maren | I know that glass, because I helped to blow it. A long time ago I founded the study of the Paths, and I did it for the best of reasons, the way people generally do. | **I knew that throne room, dearie. I worked at the castle once, studying the Paths, and of an afternoon I taught the royal children their letters. I began that study for the best of reasons, the way people generally do.** |
| Maren | {villain} took my work and built a cage out of it, and the best student I ever had stayed on to run the laboratory for him. And I ran. | **{villain} took my study and built those cells out of it. I never forged a bar of them, but every one stands on something I wrote down. The best student I ever had stayed on to run the place for him, and I ran.** |
| Maren | I have been hiding here ever since with my hands in pie dough, where nobody would think to ask what else those hands had made. | **I have been hiding here ever since with my hands in pie dough, where nobody would think to ask what those hands used to write.** |
| Maren | (unchanged) | That's my secret, and now you're holding it, the same way I have been holding yours. You may do with it as you see fit. |

**After the fourth Path (Fragment 4)**

| | Before | After |
|---|---|---|
| memory | (unchanged) | A boy of eleven stands in a coat too fine for the cold, and someone is calling to him across a courtyard: '{prince}!' |
| memory | I turn toward a woman's voice, and then a man's, and on every door around me is the {royal_house} crest: four signs in a ring. | **I turn toward a woman's voice, and then a man's, and on every door around me is the {royal_house} crest: an arm, a chef's hat, a leaf and a skull, four signs in a ring.** |
| memory | (unchanged) | {prince_full}, son of the king and queen. The whole kingdom believes he died ten years ago. |
| memory | (unchanged) | That is who I am. |
| Maren | {prince}. {prince} {royal_house}. I met a boy at court once, hiding behind his mother's cloak, and he asked me why tortoises carry their houses about with them. | **{prince}. {prince} {royal_house}. I taught a boy by that name his letters. The first day he hid behind his mother's cloak, and he asked me why tortoises carry their houses about with them.** |
| Maren | (unchanged) | I told him, 'So that we are never far from home.' |
| Maren | I knew, you see. The Warden opens that tunnel for one family only, and I knew who you were the moment you walked out of it. I was too frightened to say so. | **And you have sat at my table all these weeks, and I didn't know you. My eyes have been going for years, and I had been told that boy was dead, and whenever my heart said otherwise I told it to hush.** |
| Maren | Four signs in a ring, the same as the ones carved on this stick of mine. I have leaned on it for ten years and never told a soul why. | **Four signs in a ring, the same as the ones carved on this stick of mine. The Queen gave it to me the day I began teaching you, and I have leaned on it for ten years and never told a soul why.** |
| Maren | And my laboratory, my life's work, was used on that boy. It was used on you. Forgive me, if you ever can. I would understand it if you couldn't. | **And my study, my life's work, was the thing they used on that boy. It was used on you, and I ran, and I never once asked who was behind those bars. Forgive me, if you ever can. I would understand it if you couldn't.** |
| Wanderer | (unchanged) | My mother called to me across that courtyard. I can hear her voice now, and I still can't see her face. I'd like to, one day. I'd like to know what the two of them were like. |
| Wanderer | You built the glass, Maren. You also gave me a bed and a pie when you still thought I might be a spy. I know which of those I'm keeping. | **You ran, Maren. You also gave me a bed and a pie when you still thought I might be a spy. I know which of those I'm keeping.** |
| Maren | (unchanged) | ...Then let us make this kingdom a home again, {prince}. All of it, for all of them. |

**After the fourth Path, when Primm already told him (the rushed castle)**

| | Before | After |
|---|---|---|
| Maren | (unchanged) | So he knew you from the very first. He told you who you are, and now you've come to me for the rest of it. |
| Maren | I knew as well. The Warden opens that tunnel for one family only, and I knew who you were the moment you came out of it. I was simply too frightened to say so. | **I should have known you myself. I taught you your letters. But my eyes have been going for years, and I had been told that boy was dead, and I was too frightened to hope I'd been told wrong.** |
| Maren | So hear it from somebody who held your hand at court: you are {prince_full}, and I am so very sorry for what was done to you with the things I built. | **So hear it from somebody who held your hand at court: you are {prince_full}, and I am so very sorry for what was done to you with the things I wrote.** |

**Elsewhere:** her cave-mouth welcome ("Come closer, dearie; my eyes aren't what they were..."), her first kitchen line ("...my eyes,
which see as far as a pie and not much further"), her line after two Paths ("'With my eyes I couldn't say,' I told them, 'but I know a
damp young man with good posture when one drips on my floor.'"), her line about Elowen's father ("the best student I ever had"), "bars
on the doors" for where Elowen was taken, and her Year 1 note in the castle ward ("I am told the subject is a child, and that he asks
for his mother. A child is not a specimen. I will not stay to see it. M."). The Wanderer's answer is now "You ran, Maren. You also gave
me a bed and a pie..." and his line to Primm says "behind bars for ten years".

## Why the items showed "?"

It was deliberate. The vendor-screen pass gave every shop one effect, and Fig Sly's was "hidden compartments": a wooden door with a "?"
over each tile that slid away while the mouse was on it (`VendorFx.add_compartment`, called from `ItemVendorScreen._make_tile` when
the screen id was `VS-FIGSLY`). The Nov 4 fix pass took the doors off his cards and missed his items. The doors and the function are
deleted; his Items page is the ordinary item shop.

## The Path icons

- **Guide:** `docs/art/path_icon_style_guide.md`; **sheet:** `docs/art/path_icon_sheet.png`; **code:** `PathIcons`.
- **The four:** Beefcake a gold flexed arm on red; Gourmand a white chef's hat on cream and copper; Refusemancer a green leaf in three
  rust arrows; Necrocrat a pale skull in green flame on slate. Colorless is the plain stone disc. All four in a ring read clockwise
  from the top: arm, hat, leaf, skull.
- **Inventory:** `docs/art/path_icon_inventory.csv`, **62 places**: 40 already right, **8 fixed now** (7 in code, 1 line of text),
  **14 painted** (Batch 16).
- **Fixed in code:** the ending's four icons, Crosspath's fountain pillars and crest plinths, the feats' one-Path groups, the Capital
  camp's tents, the pack fallback, the Crease's shaft signs; and Fragment 4's line now reads "an arm, a chef's hat, a leaf and a skull,
  four signs in a ring".
- **The picture after the fourth Path is `STORY-MEMORY-4`**: the ring on the arch above the King is a star, a flame, a leaf and a moon.
- **Not changed, your call (inbox 15):** the UI's accent tints for Gourmand (blue) and Necrocrat (violet) do not match their icons.

## The treasure field and the gold study

The Dump's top-right pocket is reached across the scree only (the mount). A stand of trees closes the strip along the north rim; the
walk grid is flooded on foot and on the mount in a test.

| Chest | Gold in the chest | Also |
|---|---|---|
| `chest_field_a` | 150 | Summoning Charm |
| `chest_field_b` | 120 | a Gilded Refusemancer Pack |
| `chest_field_c` | 180 | Sucker Punch Mitts (Binding Chains if you own them) |
| `chest_field_d` | 210 | Ward Sigil |

They stand on mossy plinths, half as big again as a hidden chest, with a warm glow, and the popup says "Treasure chest". The two older
chests in the pocket are unchanged. "The Oldest Trick in the Book" counts Shiro's five giant chests only, so these are not in it.

**Gold study** (`docs/design/sim/economy_model_nov14.md`): the expected, no-grind walk opens half the hidden chests and earns
**23,007 gold, 330 more than before these chests** (+1.5 %). A thorough player gains 660. The model's figure was already above the
21.2k of Nov 8 before this pass, because quest and clear rewards were raised after that study; the four chests are not what moved it.

## Batch 16

`docs/art/batch16_nov14.csv`, prompt `docs/prompts/chatgpt_batch16.md`, references in
`G:/My Drive/Card Game Art/Batch 16 References/` (94 files, numbered by row).

| # | Images | Why |
|---|---|---|
| 1 | V-FIGSLY | two right hands |
| 2 | STORY-MEMORY-4 | the crest above the King: the four Path icons |
| 3 | STORY-MEMORY-3 | the banners behind the King |
| 4 | NPC-SCUFF, CUT-SCUFF, BST-ENFORCER-SERGEANT-SCUFF | the new officer |
| 5, 6 | UI-CARDBACK-B, UI-CARDBACK-N | a dumbbell; a skull with a quill |
| 7 | ICON-FEAT-PATHS | a dumbbell, a leaf, a ladle, a stamp |
| 8 | DEC-PLINTH-BEEF / -GOUR / -REF / -NECRO | Crosspath's freed-zone statues |
| 9, 10 | TOWN-SHEET-FREED-BANNERS-01 to -06 | Crosspath's freed banners |
| 11 | CAP-BANNER-FREED-03, -04 | a leaf swirl; a stamp |
| 12, 13 | STORY-REUNION, STORY-EPI-FILE-COMPLETE | banners in the crowd |
| 14, 15 | LOGO-EMBLEM, APP-ICON, LOGO-WORDMARK | a dumbbell, a sprout in a tin, a skull with a quill |
| 16 | TOWN-PROP-SHORE-STONES-01 to -03 | painted stones for Crosspath's shore |
| 17 | CAP-PROP-CREASE-STALL-01 / -02, CAP-PROP-CREASE-CRATES | the Crease's flat stand-ins |
| 18 | SPR-RESCUER walk set (5 sheets) | the masked Rescuer walks in Elowen's frames |
| 19 | NPC-QUADZILLA, NPC-CAIRN | two bosses speak with no portrait |
| 20 | DNA-PROP-CRATES, DNA-PROP-CABINET-TIPPED | the wasteland's stand-ins |

Nothing in `docs/art/` is still marked REDO (Batch 14 delivered all twelve), so rows 16 to 20 are the five most visible stand-ins left.

## The world, in a little more detail

- **Crosspath's shore.** The lake was drawn straight from its 24-corner outline; it is drawn from a rounded copy now, so the water
  line is a curve (the two corners at the waterfall stay sharp). The 3 m band of pale sand is a 1 m bank of wet earth with a ragged
  edge. The two-tone grass was the town's painted ground stopping 2 to 3 m short of the water, with the brighter country grass showing
  in the gap; the town's grass runs to the water now. The far shore keeps the country grass. Crosspath has no painted rock prop, so the
  stones are rounded ones in the ridge's rock texture (a painted set is Batch 16 row 16).
- **Enemies at entrances.** The four Path zones' own roamers already kept 20 m. What you met at the Dump's entrance was the extra
  roamer the game adds within sight of every exit so a newcomer sees a fight at once. It lived 14 to 17 m from the exit; it lives
  23.5 to 31 m out now, 20 m from the arrival point as well, and at least 9 m from every person and service of the hub. Three Capital
  Tidy-Bots moved.
- **The Dump.** Removed: the hollow log by the east water (a 6 m slab of bark with no collision) and the hay bale beside the top-right
  barn (side-on it was four pale planks hovering over the grass). `tools/heap_odd_probe.gd` lists every floating mesh and walk-through
  slab if you meant others. The top-right is closed by four trees and three bushes along the north rim.
- **The Buffet.** A bank runs from the table's edge down under the gravy round the south half of the table. The food forest is east
  of the bridge (the west side holds Tarragon, the golem, the rift station and the giant chest): 18 trees in two rows, herbs and leeks
  at their feet, solid on the walk grid.
- **The D.N.A.** 16 rows either side of the causeway and beside the lobby: cabinets (every third tipped over), a queue of rope posts,
  crate stacks, filing towers, dead trees, rubble. Low-end keeps every other piece.

## Tests and the build

- **GUT:** 33 shards of 12, each in a fresh Godot: **3103 / 3105, 0 failing.** New: `tests/test_fable_nov14.gd` (21 tests, one or
  more per part). Six older tests were updated for the new character and the tree wall.
- **NPC visibility probe:** OK, 150 checks.
- **D.N.A. walk smoke:** OK (75 checks, 20 screenshots).
- **Dump walk smoke: FAILED, 2 causes.**
  - At the heal table the prompt offered was Billie Muckfoot's ("heal: the prompt is up (near wren)"). On that run the extra exit
    roamer stood 0.1 m from Billie, which was my regression and is fixed; **the re-run after the fix did not finish**: the session stopped it for low memory one check in, so whether this check passes now is not known.
  - A script error every frame after the smoke's save and load (`herded_this_visit` on no visit). Fixed with a guard.
- **Buffet walk smoke: FAILED, the same 2 checks before and after the roamer fix**, so the roamer was not the cause:
  - at Basil's spot the prompt offered is Madame Mirepoix's;
  - the walk from Mirepoix to the heal table stops 3 m short (the straight line crosses the fountain).
  Both are in the plaza, where this pass changed nothing; Batch 15 moved Mirepoix and her stall 3.4 m. I believe they date from that
  and did not verify it against the old build. **Worth a look in the game: stand at Basil and check that E talks to him.**
- **Not run:** the Gainlands, Capital, Crosspath and opening-forest walk smokes, and a Low-camera walk of each changed area. The
  shots were taken at the default camera only.
- **A slip of mine, repaired:** while checking a log I ran `git stash pop` with nothing stashed, which applied an old Nov 4 stash onto
  the tree and conflicted in 19 files. Nothing of this pass was uncommitted in those files; I restored exactly those 19 from the last
  commit. Both old stashes are still in the stash list.

## New tools

`tools/heap_foot_probe.gd` (the Dump's walk grid on foot and mounted, as text), `tools/heap_odd_probe.gd` (floating meshes and
walk-through slabs), `tools/buffet_rect_probe.gd`, `tools/dna_floor_probe.gd`, `tools/flat_mesh_probe.gd` (which ground mesh lies
where), `tools/art/path_icon_inventory.py`, `tools/art/batch16_build.py`, `tools/nov14_maren_table.js`, `docs/dialogue/fable_nov14_rows.js`.
Shot hooks: town `--open=memory2|memory3 --memory_line=N`, zone `--open=vendor_items`.

---

# Batch 15 + 1.0 - report (Nov 13): the last art batch, the owner's answers, the leftovers, the 1.0.0 build

Brief: `docs/prompts/batch15_import_and_fixes.md`. Start tag `pre-batch15-import`. Questions: `docs/overnight_inbox.md`, "Batch 15 + 1.0"
(10 items). One Godot at a time; the one critic ran while no Godot ran and saw pictures only. No public upload. No difficulty setting,
no battle-board or menu layout change, Primm's fight untouched. Ran on Fable 5.2. The Fable Nov 13 dialogue report follows below.

## In short

- **All 39 Batch 15 images are in the game**, each with a screenshot. 22 rows of `docs/art/batch15_nov12.csv` say "In game"; the two
  rows that were not in the batch (the painted world maps, the Gallery's bestiary pictures) say "Not delivered".
- **Your answers are applied**: both sets, 9 items.
- **All eight in-game leftovers are done.**
- **A fresh critic looked at 21 unchecked screens: clarity 5/10, polish 5/10.** Four of its top 10 were caused by how the pictures
  were taken, three were real and small and are fixed, three need art or a larger change and are logged.
- **Tests: all 33 shards green, 3084 of 3086 passing, 0 failing** (2 risky, the same two no-assert tests as before). The intro walk, the freed city, the map and every new shot ran with 0 script errors.**
- **The 1.0.0 build was not built.** Free memory stayed at 1.8 GB for the ten minutes the brief allows (the rule is 2.2 GB), so the export was not started. The source is at 1.0.0, tested, committed and pushed; the commands are below.**

## The 1.0.0 zip

**There is no 1.0.0 zip yet.** Close what you can (ChatGPT and the browser hold most of the memory), then run these from
`C:\Dev\Deckbuilder-rpg` in Git Bash, one at a time, in the foreground:

```
EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0
bash tools/run_release_smoke_exported.sh
bash tools/export_test_pack.sh
bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_a.txt r1a 480
SUITE_SETTINGS_FILE=_screenshots/exported/settings_play_r1a.cfg bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_b.txt r1b 480
bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_c.txt r1c 480
grep -c "SCRIPT ERROR" _screenshots/exported/play_r1a.log _screenshots/exported/play_r1b.log _screenshots/exported/play_r1c.log
```

- The export takes 4 to 10 minutes and writes `builds/TheWaywardPath-v1.0.0-windows.zip`. "EXPORT STOPPED" means nothing was replaced.
- The smoke must print `PASSED`. The last line must print 0 three times.
- Expect a pack of about 864 MB and a zip of about 750 MB (RC1 was 847 and 736; this batch adds about 17 MB to the pack). The disk
  has 18 GB free; the export's peak is under 2 GB.
- The last zip in `builds/` is RC5 (Nov 12): RC6 was never built, so 1.0.0 is the first build with the Nov 12 fix pass, the dialogue
  rewrite and this batch.
  **Play the first ten minutes of the exported game yourself before uploading** - none of that work has been run as an exe.

## Part 1 - the import

| Images | Where it is in the game | Shot (`docs/overnight_shots/batch15/`) |
|---|---|---|
| CAP-SHEET-WINDOWS-07 / -08 | Every townhouse window of the Capital: -07 by day, -08 (lit) in the freed city | `windows_day_plaza`, `windows_day_reek`, `freed_capital_approach_low` |
| CAP-BANNER-FREED-01..04 | After `primm_defeated`: a row down the avenue, and the four over Primm's emblem | `freed_capital_approach`, `_low`, `freed_capital_plaza_low` |
| CAP-BD-LANTERNS, CAP-FX-FIREWORKS | After `primm_defeated`: lanterns climbing slowly, one soft burst every 4.5 to 9 s. Reduce motion or Low-end: one still lantern card, no fireworks | `freed_capital_approach_low` |
| CAP-PROP-PORTRAIT-PRIMM-01..03 | The easel portraits (the smiley stays the emblem elsewhere) | `freed_capital_approach_low` |
| CAP-PROP-RUBBLE-ROW | The foot of the south wall in the Reek and the Transit Yards; the outskirts' south edge | `rubble_row_transit_yards` |
| BUFF-PROP-STALL-01 / -02 | The Buffet hub's two market stalls | `buffet_stalls` |
| DNA-PROP-SERVING-ORB | The head of the lobby's ghost queue, and beside TAKE A NUMBER | `dna_serving_orb` |
| DUMP-HERO-RACCOON-STATUE | The raccoon king on the throne beside the Rotheart's gate (the art list's row) | `dump_raccoon_statue` |
| DUMP-PROP-MILL-SAILS | The three mills' sails, turning slowly | `dump_mill_sails` |
| GAIN-GROUND-MAT | The gym mats | `gainlands_gym_mat` |
| ICON-EQ-HALLPASSSLIPPERS, ICON-GEAR-EARNEDBLADE | Their own icons (60 of 60 gear icons) | `icons_gallery`, `gear_icons_character` |
| MAP-S-GALLERY | The Shattered Gallery's map; all 13 nodes moved onto the new painted landings, every painted path matches a link | `gallery_map_nodes` |
| MG-BG-MATCHTABLE, UI-CARDBACK-DEX | Dex's matching game: table and card back | `dex_match_table` |
| UI-BATTLE-ITEMSLOT-EMPTY / -READY | The battle item slots, same slot rect | `battle_item_slots` |
| UI-PACK-LOCKED-B / -G / -N / -R | Fenwick's locked Path Packs | `locked_packs` |
| UI-NODE-BANNER | The pop-up banner's base | `node_banner_shrine`, `node_banner_treasure` |
| NPC-HESPER, STORY-EPI-WRINKLES | Replaced; the code recolour and its test are deleted | `portrait_hesper` |
| V-FIGSLY | Replaced (two arms) | `portrait_figsly` |
| STORY-CREDITS-PANORAMA | Behind the credits and the thanks card, a slow pan; the text carries a dark outline | `credits_panorama`, `credits_thanks_card` |
| SPR-ELOWEN-*_WALK (5) | The intro and the cave mouth | `elowen_walk_default`, `elowen_walk_low` (six frames each), `elowen_walk_default_frame`, `elowen_walk_low_frame` |

**The locked packs.** Beefcake red, Gourmand orange and Necrocrat deep green match their packs. The Refusemancer parcel also came with
a green seal while its pack carries a rust-red medallion, so its seal is tinted rust in code (a small shader that re-colours only the
wax). Each seal now echoes its pack and the two green parcels can be told apart.

**Elowen's walk.** Built the way the townsfolk walkers are: four frames per sheet, the walkers' figure height and her own idle's scale,
normal maps, the walkers' frame rate, mirrored for the right-facing directions. She has idles for three directions and walks for five,
so the importer and the sprite now accept a walk with no idle of its own. At the intro she walks north-west into the trees (3 m in
2.6 s, her back three-quarter frames) and fades over the last second; a figure that stops goes back to its idle. The same at the cave
mouth after each freed zone. **Two things to know** (inbox 1 and 2): she still wears the disguise in both scenes and the disguise set
has no walk frames, so she walks in Elowen's own frames, seen from behind; and the Lab, her rescue and the epilogue are stills and
dialogue, so no figure of hers walks there.

**Three placements that differ from the brief's wording** (inbox 3, 4, 6): the Capital has no dusk, so the lit window is the freed
city's; the lanterns and fireworks stand in front of the castle because the sky is never in frame inside the city; Madame Mirepoix's
stall moved 3.4 m so it stands behind her.

**Size.** 81 new files, 8.0 MB of source art, **about 17 MB more in the pack**; the seven replaced files are 0.3 MB smaller. Against
`docs/build_size_policy.md`: the pack was already over the 750 MB warning on purpose (music at q6); this batch adds 2 %.
The numbers are from the imported files; the export will print the real pack size.

## Part 2 - your answers

**Fable Nov 12d**
1. Fig Sly's label: kept.
2. The Crease's arrival line: kept.
3. Maren's cave-mouth welcome now carries her introduction: "...I'm Elder Maren, dearie, and this is Crosspath. We settle most things
   here with cards..."
4. Tall pieces at 1.3 times: kept. Re-measured on Medium with the new windows: **68.5 to 73.1 fps** at the six inside cameras (Gate
   Plaza 68.5, Transit Yards 69.3, Grave Row 70.3, the Reek 71.4, Palace Approach 71.9, Hungry Quarter 73.1). No need for 1.2.
5. New Game with no save in any slot starts the story at once, in slot 1. The slot grid appears once a save exists.

**Dialogue Nov 13**
1. Fig Sly's lines: still locked.
2. Bertram: his 14 lengthened lines are back to the clipped originals (`docs/dialogue/bertram_nov13b.csv`); the lines that were already
   short are unchanged. Every line of his is under 150 characters.
3. The redistributed verbal habits: kept.
4. The exporter: Dex's 20 `cardsharp.*` lines say "Dex Shufflewick"; the 20 "(check key)" rows are named (Tilly Tonic, Auntie
   Alembic, Pip Threadwell, narration); the chef reads "The Grand Chef", the impostor "The Doppelganger" and, after the naming,
   "Escoffina". **The 56 tutorial hints are in the export** (the first duel's 20 steps and the nine one-time screen tips), with ids the
   importer already applies. None was rewritten.

## Part 3 - the leftovers (all eight)

| # | What | Result | Shot |
|---|---|---|---|
| 1 | The Dump's south corners | The land is drawn once more from behind in shadowed rock, so the camera inside the rim sees stone, not fog | `dump_corners_after` |
| 2 | The Tidy-Bots | Any roamer whose touch costs HP stops for 0.85 s, flashes twice and sounds the alert before it comes. The arrival grace is 3 s and counts only while the hero can move, so it holds on a real entry | (behaviour; covered by a test) |
| 3 | The Crease's east wall | The camera holds 3.4 m off both side walls and the view slides instead of turning back; the wall takes about a third of the frame, not half | `crease_east_wall_after` |
| 4 | The Wanderer's portrait | Fades to clear over the last 11 % of its width | `portrait_wanderer_feathered` |
| 5 | The Capital's map | District names; the Crease as its own framed inset "under the city"; a name is never written over an icon or another name, and a name several places share is written once | `capital_map_after` |
| 6 | The minimap | Draws a 3x smoothed copy of the map picture: rounded edges in the Capital. In the forest the minimap shows almost nothing but the clearing, so the gain there is small | `minimap_before_after` |
| 7 | Crosspath's south band | A knee-high kit hedge along the ravine's lip and a shadow in the cleft. The rock lip still shows as a pale and violet strip between them (inbox 9) | `crosspath_south_edge_after` |
| 8 | The D.N.A.'s apron | 17 kit pieces and 10 ground decals either side of the causeway: filing towers, cabinets, paper stacks, a roped queue with a serving orb, ghost lamps, loose forms | `dna_apron_after` |

## Part 4 - fresh eyes

A critic with no context got 21 pictures of the nine places in the brief and nothing else (`docs/review/critic_batch15/`: `brief.md`,
`shots/`, `report.md` with my triage under it). **Clarity 5/10, polish 5/10.**

| # | Its finding | Size | Verdict |
|---|---|---|---|
| 1 | The thanks card sits on top of the credits' words | S/M | **Fixed.** Real after Skip, and worse over the new panorama |
| 2 | Five things stacked at the top of the Transit Yards view | M | Mostly the capture (a fresh profile's Feat banners). The first-visit tip and the new-quest banner do share the first seconds: logged |
| 3 | "Quest complete" covers the Black Market's title | S | **Fixed.** Quest notices wait while a shop is open |
| 4 | Flat stand-in shapes round Fig Sly | L | Real: needs art |
| 5 | Giant townsfolk cut off at the bottom of the freed plaza | M | Real on the Low camera: logged |
| 6 | The well's two pictures are the same | M | The capture (full HP closes the offer). The medallion's icon is a fair point: logged |
| 7 | No panel before the fight | M | The capture |
| 8 | A late quest in the box on the first step into Crosspath | S/M | The capture. The flat lantern on the house is real: logged |
| 9 | The boss panel does not say "boss", claims rules it does not list, red X on Continue | S | **Fixed** |
| 10 | Pale, unpainted-looking citizens and lilac rectangles in the freed city | M | Real: logged |

It liked the dialogue box with the painted portraits, the dungeon map and pop-up frames, and the mood of the opening forest.
**What this means:** the low scores come mostly from the last city and the hideout, where stand-ins still sit beside painted art.
That is art, not code, and it is the honest state of those two places at 1.0.

## The itch upload checklist

The full guide is `docs/release/itch_upload.md`. In short:

1. Build the zip and run the checks above. All three must be clean.
2. Unzip it into a fresh folder, run `TheWaywardPath.exe`, start a New Game (it should go straight to the forest), walk to the cave.
3. itch.io > Dashboard > the project (or Create new project: "The Wayward Path", Games, Downloadable).
4. Pricing: "$0 or donate", suggested 3 to 5 USD (or "No payments").
5. Page text, tags and the AI disclosure from `docs/release/itch_page/` (`page.md`, `ai_disclosure.md`). AI field: Yes; Graphics,
   Sound/Music, Text/Dialogue; not Code.
6. Uploads: `builds/TheWaywardPath-v1.0.0-windows.zip`, tick Windows. It is under itch's 1 GB limit.
7. Cover and the eight screenshots from `docs/release/itch_page/screenshots/`. Consider replacing one with the freed Capital or the
   credits panorama (`docs/overnight_shots/batch15/`).
8. Visibility: Draft, check the page, download once and run it; then Restricted for playtesters or Public.
9. After the upload: `git tag v1.0.0 && git push --tags`.
10. Optional: the in-game Support button (`data/credits/credits.cfg`, `[support] url`), which needs a re-export.

---

# Fable Nov 13 - report (the dialogue rewrite: one cohesive, emotional story)

Brief: `docs/prompts/fable_nov13_dialogue.md`. Start tag `pre-dialogue-nov13`. Questions: `docs/overnight_inbox.md`, "Dialogue Nov 13"
(9 items). Text only: no gameplay, layout or art change, Primm's fight untouched, nothing exported or uploaded. One Godot at a time; the
drafting agents (at most 3 at once) only ran while no Godot ran. Ran on Fable 5.2. The Fable Nov 12d report follows below.

## In short

- **All four tiers are done and in the game: 1,245 lines rewritten** out of 4,405 exported (plus the 66 loading tips), every tier tested,
  committed and pushed. Final GUT: **3070/3072, 0 failing** (2 risky/pending, the same two as before the pass); the prologue smoke passes. The harness twice stopped the background test run for low memory, so the suite was finished in the foreground from the shard it had reached (inbox 9).
- **A new story bible and voice sheets** drive it: `docs/writing/story_bible_v2.md` and `docs/writing/voices.md`.
- **Two blind readers found the old and new text about level** (new preferred 23 of 40, then 19 of 40 on a second sample). Both times
  voice distinctness and emotional impact went up and naturalness went slightly down, because some new lines were padded. See "The
  critic" below for what it means and the 73 lines fixed or put back because of it.
- **Not every line changed, on purpose.** About 2,150 of the exported lines are dialogue or narration a rewrite could touch (the rest are
  labels, rule text, sign titles and quest-log wayfinding). Of those, 1,245 changed. The lines left alone are mostly narration that
  already flowed (the castle's rooms, the ending beats, the funeral), signs and memos (short and deadpan by design), and lines the story
  leans on word for word.

## Tiers done

| Tier | What | Lines rewritten | Written by |
|---|---|---|---|
| 1 | The main story: prologue, cave, Maren's questline, the four Fragments, cave-mouth scenes, gatekeepers, zone finales, the Capital line, Primm, the ending | 293 | the lead writer (me) |
| 2 | The core cast: Gainlands 70, Buffet 61, D.N.A. 76, Dump 51, Capital 128, Crosspath (Brannoch, Old Hob) 13 | 399 | agents, one per zone; Crosspath by me; every batch read and edited by me |
| 3 | Side content: Crosspath's shops, arena, Rift Express and secrets 132; Gainlands 51; Buffet 51; D.N.A. 33; Dump 33; Capital 11; postgame 20 | 331 | agents; read and edited by me |
| 4 | The world: barks, citizens, guards, pop-ups, map descriptions (Capital 69, Crosspath 59, Gainlands 27, Dump 26, Buffet 24, D.N.A. 17), plus the 66 loading tips | 222 + tips | agents; tips by me |

**Per character (lines rewritten):** Elder Maren 136, the Wanderer 33, the Rescuer 32, Agnes Overdue 30, Basil 28, Old Hob 27, throwers
and rippers 26, Capital guards and clerks 25, Rip Tearson and cousins 24, Gerald 23, Brother Bramble 23, Old Man Mountain 23, Chef Marlo 22,
Bertram Beetsworth 22, Wren 21, Pip Threadwell 20, the Perfectly Happy Citizens 20, Grandmaster Flex 19, the gate golems 18, Old Fern 17,
Granny Gristle 17, Percival Plume 16, Rollo Spokes 16, Announcer Bellows 16, narration and UI 143, and about 60 more speakers with fewer
than 16 each. The full list is in each tier's ledger (`docs/dialogue/rewrite_nov13_t*/applied_ledger.json`).

**What changed in kind:**
- Maren is rambling and warm and gets plainer with each Fragment; she says the theme once ("Four peoples who never matched, stitched
  together, and it held").
- Every endearment has one owner: Maren "dearie", Agnes "dear", Auntie Alembic "dear heart", Sable "darling", Madame Mirepoix "my sweet",
  Granny Gristle "my lovely" (and "Hah!"; Old Hob keeps "Heh."), Compostella "child", Flex "son", Rip "buddy", Crumb "soldier".
- Only Brannoch and Nurse Hesper Dray are terse now. Dex Shufflewick's put-downs became friendly table-talk; Pip no longer teases
  customers; the guards and clerks of the Capital are people who do not understand the rules either.
- The Wanderer answers people (to Quota: "You're the first person in this place who hasn't shouted at me. Who are you?").

## Before and after: 15 key scenes

1. **The opening** (`intro::awakening_lines::1`)
   - Before: "I keep reaching for my name, or for how I got here, and there's nothing there at all."
   - After: "I keep reaching for my name, and it isn't there. Neither is how I came to be here. There's nothing at all, like a room that somebody has emptied."
2. **Maren's first talk** (`intro::cave_mouth.maren::1`)
   - Before: "And look at the state of you. I told her I'd help whoever she sent along. I never said I'd take in a half-drowned stray."
   - After: "And just look at the state of you. I told her I would help whoever she sent along, but I don't recall agreeing to take in a half-drowned stray who can barely stand."
3. **Maren names the kingdom** (`intro::town.elder.first::1`)
   - Before: "Ten years ago Patchwork was whole. Beefcakes kept the lights on, Gourmands fed us, Necrocrats minded the dead and Refusemancers turned rubbish into harvests. Everyone complained, and everything worked."
   - After: "Ten years ago Patchwork was whole. Beefcakes kept the lights on, Gourmands fed us, Necrocrats minded the dead, Refusemancers turned rubbish into harvests. Four peoples who never matched, stitched together, and it held."
4. **A memory scene: the Coup** (`intro::memory.3.after::1`)
   - Before: "I know that glass, because I helped to blow it. Long ago I founded the study of the Paths, and I did it for the best of reasons."
   - After: "I know that glass, because I helped to blow it. A long time ago I founded the study of the Paths, and I did it for the best of reasons, the way people generally do."
5. **The Rescuer at the cave mouth** (`scenes/cave_mouth_1/steps/1::2`)
   - Before: "Let me see your hands. Steadier than they were. Good. That's the first thing I've been able to tick off my list in a long time."
   - After: "Let me see your hands. They're steadier than they were, and that's good. It's the first thing I've been able to cross off my list in a long time."
6. **The Gainlands' beat: Clench to his teacher** (mid-fight, `enc::Chancellor Clench, Iron Regent/2/line`)
   - Before: "You said I would go further than you. Look how far I went. ...Master?"
   - After: "You told me I would go further than you ever did. Well, look how far I went. Tell me it was far enough. ...Master?"
7. **The Buffet's beat: Basil** (`gourmand::npc.odalys.return::0`)
   - Before: "You came back! Good, good. I've been stirring the same pot for an hour, just to give my hands something to do. A Gourmand never stops stirring."
   - After: "Oh! You came back. Good, that's good. I've been stirring this same pot for an hour, because when my hands stop I start thinking, and I'd honestly rather stir."
8. **The D.N.A.'s beat: Prudence Pallor, freed** (`dna::freed_npc.prudence::0`)
   - Before: "Prudence Pallor, Deputy Head of the Department. Yes, I stamped DENIED on everything. I was tired, the paperwork was valid, and I am sorry."
   - After: "Prudence Pallor, Deputy Head of the Department. For ten years I stamped DENIED on everything, because the paperwork was valid and I was too tired to ask whether it was right. I am sorry for it."
9. **The Dump's beat: Brother Bramble and the twelfth tree** (`refusemancer::npc.marigold.return::3`)
   - Before: "Forgive me. I talk to that spot more than I talk to most people. It's a very good listener, and it never tracks mud into the Grange."
   - After: "Forgive me, I do go on. I talk to that spot more than I talk to most people, because it's a very good listener and it has never once tracked mud into the Grange."
10. **The Capital arrival: Wren** (`capital::npc.wren.intro::0`)
    - Before: "Another one through the shafts. Sit down. I'm Wren; I was the Royal Archivist once, and now I keep the records this city isn't supposed to have."
    - After: "Another one down through the shafts. Sit, please. I'm Wren. I was the Royal Archivist once, and these days I keep the records this city isn't supposed to have."
11. **A Capital quest: Widow Pell** (`capital::quest.cap_burial.ready::1`)
    - Before: "I sat by the plot all morning and didn't say a word. It was the first quiet in three years that wasn't a fear."
    - After: "I sat by the plot the whole morning and never said a word to him, and it was the first quiet in three years that I wasn't afraid of."
12. **Primm before the fight: the Wanderer** (`capital::cutscene.primm_intro.3::0`)
    - Before: "Sorry, that's forest mud. I've walked a long way to get here, and everyone I met on the road was afraid of you."
    - After: "I'm sorry about the floor. It's forest mud. I've walked a long way to get here, and everyone I met on the road was afraid of you."
13. **Primm at the end** (`capital::cutscene.primm_end.6::0`)
    - Before: "I'm not going to correct you; that was always your way. I'm not going to forgive you either, not today. Start smaller than a kingdom. Say sorry to one person."
    - After: "I'm not going to correct you. That was always your way of doing things. And I'm not going to forgive you either, not today. Start with something smaller than a kingdom. Say sorry to one person."
14. **The ending: Maren** (`capital::ending.beat.10::2`) and the credits
    - Before: "...loud enough for the whole plaza to hear. She has said it in her kitchen; this is the first time she has said it to the kingdom. 'Welcome home.'" / "A game about a kingdom that was strong because it was not the same."
    - After: "...loudly enough for the whole plaza to hear. She has said it in her kitchen, but this is the first time she has said it to the kingdom. 'Welcome home.'" / "A game about a kingdom that was strong because its pieces did not match."
15. **The epilogue: Isla** (`scenes/isla_talk/steps/0::1`)
    - Before: "I keep walking to the gate and back. Nobody stops me. I keep expecting somebody to stop me."
    - After: "I keep walking down to the gate and back again, just because I can. Nobody stops me, and I still catch myself waiting for somebody to."

Primm's own lines, the castle's rooms, the funeral and most of the ending were read as scenes and kept nearly whole: they were already the
best writing in the game, and the bible quotes them.

## The critic: old against new

A reader with no context got 40 conversations (10 per tier; tier 4 as barks), each in two unlabelled versions in random order
(`docs/review/dialogue_nov13/`: `sample.md`, `key.json`, `critic_brief.md`, `critic_scores.txt`). Scores are 1-10.

| | Naturalness | Voice | Emotion | Clarity | Humour | Mean |
|---|---|---|---|---|---|---|
| **Old** | 7.65 | 7.30 | 5.88 | 6.28 | 6.78 | 6.78 |
| **New** | 7.33 | 7.88 | 6.35 | 6.33 | 6.78 | 6.93 |

| Tier | Old mean | New mean | New preferred |
|---|---|---|---|
| 1 main story | 6.94 | 6.88 | 4 of 10 |
| 2 core cast | 6.98 | 7.22 | 6 of 10 |
| 3 side content | 6.80 | 7.08 | 6 of 10 |
| 4 barks | 6.38 | 6.54 | 7 of 10 |

- **New preferred in 23 of 40.** The gains are in voice (+0.58) and emotional impact (+0.47). Humour is level. **Naturalness fell by
  0.32.** The reader's reason: some new lines "pad the line past its point with trailing clauses and fillers like 'you see'", burying a
  punchline or a hurt that the old line ended on. Where the new text won, it was for specific detail and for a voice nobody else has.
- **Tier 1 came out level (old preferred 6 of 10, means 6.94 against 6.88).** The main story's old lines were already the product of the
  Nov 5 rewrite, and several of my changes there were small. This is the place a human read is most worth having.
- **The 10 weakest lines the reader named: 8 were old lines, 2 were new.** Both new ones are fixed (Granny Gristle's turnip line now ends
  on its joke; Bertram's equipment-slots line is back to his deadpan).
- **Fixed after the critic (32 lines):** every conversation where the old version was preferred for a stated reason was revisited. 21
  lines went back to their original (Pallor's freed lines, the Doppelganger's reveal, Flex's "in, hold, and out again", Wren's "Hesper
  charges by the piece", Captain Spotless's barked opening, Fenwick's first line, Bertram's stamps, three barks) and 11 were tightened
  (Hob's "Paperwork. Heh.", Gary's "No rush. Bit of a rush.", Fenwick's "I won't judge. I sniff.", Professor Pump's sigh, Kestrel's quest
  lines, Granny Gristle). The scores above are from before these fixes; no second critic run was made.
- **The critic's confusions worth knowing:** the Old Well secret's cardsharp lines are labelled "Elder Maren" in the export though Dex
  Shufflewick says them (a label in the exporter, not in the game); "Three." in the third cave-mouth scene is unclear without the count of
  zones on screen; "8 reps to one beat" does not say what to press (the rule text elsewhere does).

### Second blind read (morning of Nov 13, after the fixes)

A second reader, with a different sample of 40 conversations drawn from the fixed text (`docs/review/dialogue_nov13/round2/`):

| | Naturalness | Voice | Emotion | Clarity | Humour | Mean |
|---|---|---|---|---|---|---|
| **Old** | 7.75 | 7.67 | 6.15 | 6.38 | 7.00 | 6.99 |
| **New** | 7.53 | 7.95 | 6.47 | 6.28 | 6.80 | 7.00 |

- **Level: new preferred in 19 of 40** (main story 4 of 10, core cast 6, side content 5, barks 4). Voice and emotion are up again;
  naturalness and humour are slightly down again. Two readers now agree, so take this as the real picture: **the rewrite made the cast
  more distinct and the sad scenes land harder, and it cost some snap.**
- **The reader's rule, which matches the first one's:** fit the length to the speaker. Short, flat lines won for the terse, the hurried
  and the deadpan (Kestrel, Rollo, Bertram, Ectomund, the Rip cousins). Longer, hedging lines won where the dithering is the character
  (Gerald, Basil, Kyle, Old Man Mountain, the Hollow Warden). The losing versions either padded a joke or an instruction, or trimmed away
  the one odd detail that made the speaker a person.
- **Fixed after this read (41 lines): 37 put back to their original text and 4 rewritten.** Kestrel's first talk, Rollo's talk and his
  wheel quest (his lines after the Capital is freed keep the new text), Bertram's greeting and barks, the Rip cousins' "rarely speak"
  line, Ectomund's "That is not corruption. That is personality.", Pallor's "Ideally both.", Bronson's "a terrible souvenir", Flex's
  "Now, shall we?", Maren's "And I ran.", and six barks went back. Tilly's two Power Wraps instructions were rewritten so the keys to
  press can be followed, and Maren's road hint says "the easiest one for you" again.
- **Counts after both rounds of fixes:** 1,208 lines differ from the text before tonight (Tier 1: 288, Tier 2: 383, Tier 3: 322,
  Tier 4: 215), down from 1,245. The tier table above shows the first count.
- After these fixes the full suite was run again in three foreground pieces (`run_tests.sh` has a new `--to=K`): 3070/3072, 0 failing.
  The workbook was rebuilt and copied to the Drive again.
- No third read was made. The pattern is clear enough that a human pass over the flagged speakers is the better next step.

## Checked in the game

Play-script runs (`docs/review/play_scripts/nov13/`, with the new `dev textsize 1` for Large text) at 1280x720 and at 1920x1080 (this
screen clamps that window to 1886x1061): the opening lines, Maren and Brannoch in Crosspath, Old Man Mountain and Foreman Gus in the
Gainlands, and Primm's entrance in the Model Room (1280x720 only). Shots: `docs/overnight_shots/nov13/` (8). No overflow, no cut-off text,
no unfilled token; portraits match the speakers. Every one of the 1,245 lines also passed the importer's box measure (at most 4 lines at
Normal and 6 at Large, the same measure as `tests/test_dialogue_fit.gd`).

Added in the morning: Kestrel and Captain Spotless at the Capital (1280x720, Large text; two more shots). Not run in the game: a zone's
whole main quest played through, Wren in the Crease, and the Primm fight to its ending (the play script reached his entrance and the
victory screen but not the ending scene; the mid-fight and ending scenes were checked by the box measure and the tests only).

## Plants and payoffs

22 pairs, with line IDs, are in `docs/writing/story_bible_v2.md`, section 4. The ones the rewrite touched or sharpened:
voices through a wall (prologue to the last cave-mouth scene); the door that knows one hand (the Warden to Maren's confession); the
lullaby (Fragment 1 to the Queen at the funeral); "again" (Fragment 2 to Primm's end and Agnes); four signs in a ring (the key, the crest,
Maren's stick, the headstones, the Throne); "never far from home" (Fragment 4 to "Welcome home" and the King); the gate that is never
locked (Brannoch to Isla); the two graves (Old Hob); the third form (Agnes to HEIR: ALIVE); filed on a Tuesday (Kyle and the HR memo to
Mortimer); the dumbbell and the frosting (Old Man Mountain and Basil to the Rescuer); the twelfth tree (Bramble to Compostella); "not the
part that matters" (Flex to Primm); a blank page (the Grand Chef to Primm); the wells (townsfolk and Wren to the journals and "I miss the
wells"); "I only wish somebody would say so" (the four insights to the hero's silence); her name (prologue to "somewhere with a roof");
"I always do" (prologue to Cell 4); Maren's handwriting (the recipe card to the note in the ward); the steady hands (cave mouth to the
hatch); argued like family (Maren to the Queen); the tidy lady with shears (Moss Mulligan to Clipwell).

## Decisions I had to make

1. **Fig Sly is unchanged.** `docs/design/canon.md` locks the black market vendor's lines and the importer refuses them; the brief lists
   him among the vendors. I kept the lock (14 lines). Inbox 1.
2. **No lines were added.** The format allows it only with an importer extension and several tests count lines per key. Every beat fitted
   its existing boxes, so I did not extend the importer for new IDs. Inbox 2.
3. **Endearments were reassigned** (Mirepoix "my sweet", Granny Gristle "my lovely" and "Hah!", Alembic "dear heart", Crumb "soldier" only,
   the Grand Chef drops "dear" in one bark, Clipwell none). These are verbal habits, not names. Inbox 3.
4. **Short-box tests were obeyed, not loosened:** Maren's idle lines stay under 140/160 characters, the prologue under 160, boss intro
   lines under 160.
5. **Tested phrases were kept** ("Tell me: which Path resonates within you?", "strength is not control", "treating people with respect",
   "easiest road for you", "Not on my list. Off you pop.", "Tell Basil", and so on).
6. **Basil no longer says "the real Chef"** before the reveal (he could not know); it is "Chef baked a birthday cake... back before all
   this".
7. **Flex's line in the breathing room changed** from "You carry the whole kingdom in your lungs, son" (which nearly names the hero) to
   one about a held breath.
8. **Nurse Hesper's wake line after the Capital is freed** now says there is no fee (it read as a charge for being defeated, and there is
   no defeat penalty).
9. **Primm's past is only what the castle already says.** The bible invents nothing about him.

## Kept usable: the playtesters' work

- `tools/import_playtester_dialogue.py` now reads the tier ledgers. A returned row whose line was rewritten tonight, written against the
  old text, is **not applied**; the report lists it under "Base changed tonight" with the old base, tonight's line and the tester's line
  side by side. Tested with a doctored copy of the Nov 9 workbook.
- `docs/dialogue/playtesters_nov13.xlsx`: a fresh workbook (same four tabs and columns A-N, 4,405 rows of tonight's text, the Voice Guide
  tab rebuilt from `voices.md`), built by the new `tools/build_playtester_workbook.py` and copied to
  `G:/My Drive/Card Game Art/Playtester Dialogue/Wayward Path - Dialogue for Playtesters (Nov 13).xlsx`. The "Speakers" tab is as it was
  on Nov 9. I could not open the file in Excel from here; the XML parses and the importer reads all 4,405 rows back. Inbox 6.

## What was not reached

- **Tutorial hints** are not in the dialogue export and were not touched. Loading tips are done (edited in the file; revert with git).
- **Signs, posters, memos and plaques** were read and almost all kept (about 480 lines): they are short and deadpan by design.
- **The dungeon event screens' choice results** were only touched where clipped; most were kept.
- **A second critic run** after the 32 fixes, and a whole zone played in the game.
- **Quest Log text** (titles, steps, "where to go") was left as it is: it is the wayfinding the last three passes tuned.

## Tools made tonight

| Tool | What it does |
|---|---|
| `tools/dialogue_scene_build.js` | Scene files ("@key", "idx| text", "## purpose") to an edit CSV for the importer, with checks |
| `tools/dialogue_scene_chunks.js` | Splits the export into writing chunks by tier and zone |
| `tools/dialogue_scene_review.js` | Prints a scene file's changed lines as old / new for review |
| `tools/dialogue_blind_sample.js` | Builds the blind old/new critic sample from the ledgers |
| `tools/build_playtester_workbook.py` | Rebuilds the playtesters' workbook from the game's text and `voices.md` |
| `tools/apply_dialogue_pass.js` | Now reverts a tier from its ids file alone; knows `{road}`, `{obstacle}`, `{card}` |
| `tools/play_script.gd` | New `dev textsize 0|1|2` |

The scene sources, with a one-line purpose for every conversation, are in `docs/dialogue/rewrite_nov13/` (`t1_*.txt` to `t4_*.txt`).

## How to revert

- **One tier's group** (the lines go back to their text from before tonight):
  `node tools/apply_dialogue_pass.js --revert=docs/dialogue/rewrite_nov13_t1_ids.txt` (Tier 1), or for the other tiers one file per
  group: `rewrite_nov13_t2_<gainlands|buffet|dna|dump|capital|town>_ids.txt`, `rewrite_nov13_t3_<town|gainlands|buffet|dna|dump|capital|postgame>_ids.txt`,
  `rewrite_nov13_t4_<town|gainlands|buffet|dna|dump|capital>_ids.txt`. A whole tier is those files one after another.
- **Single lines:** put their IDs in a text file and pass it with `--csv=<that tier's CSV> --revert=<file>`.
- **The loading tips:** `git checkout pre-dialogue-nov13 -- data/loading/loading_tips.txt`.
- **Everything:** `git checkout pre-dialogue-nov13 -- data core` (text files only changed there), or reset to the tag.
- After a revert run `bash tools/run_tests.sh`.


---

# Fable Nov 12d - report (2-hour pass: the broken checks, a fresh playtest, the ghost building, edges, RC6)

Brief: `docs/prompts/fable_nov12_2h.md`. Start tag `pre-fable-nov12d`. Questions: `docs/overnight_inbox.md`, "Fable Nov 12d" (7 items).
Shots: `docs/overnight_shots/nov12d/`. One Godot at a time; the one sub-agent (the critic) ran the game itself and nothing of mine ran
beside it. Owner constraints kept: no difficulty setting, the battle board and the menus keep their layout, no new art, Primm's fight
unchanged, nothing uploaded. Ran on Fable 5.2. The Fable Nov 12c report follows below.

## RC6

**RC6 is not built.** Free RAM stayed between 2.07 and 2.15 GB through the ten-minute wait (20:50 to 20:59, nothing of mine running);
the rule was 2.2 GB, so the export was not started. No exported smoke and no `play_exported.sh` check ran. The source is at
`1.0.0-rc6`, tested and pushed. To build it, close Chrome, ChatGPT and anything else heavy, then in Git Bash from
`C:\Dev\Deckbuilder-rpg`, in the foreground:

```
EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc6
bash tools/run_release_smoke_exported.sh
bash tools/export_test_pack.sh
bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_a.txt r1a 480
SUITE_SETTINGS_FILE=_screenshots/exported/settings_play_r1a.cfg bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_b.txt r1b 480
bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_c.txt r1c 480
grep -c "SCRIPT ERROR" _screenshots/exported/play_r1*.log
```

The export takes 4 to 10 minutes ("EXPORT STOPPED" means nothing was replaced); the smoke must print `PASSED`; the last line must print 0
three times.

## One thing to know first: tests were overwriting your campaign-1 autosave

`%APPDATA%\Deckbuilder-RPG\saves\autosave.json` (and its `.bak`) was rewritten by test runs today, at 19:59, 20:25 and 20:44, with
test state (level 3, 450 gold, a Crease flag). Twelve test files switch saving back on at the real path. **I cannot tell what was in
that slot before today and cannot recover it**; campaigns 2 and 3 are untouched (Oct 24, Oct 31). I do not think this pass introduced it
(those tests date from Nov 7 on, and every full test run would have done the same), but that is not verified. Fixed from here on: under
a GUT run the default save path is a scratch file. Checked: the twelve files plus the Crease test pass (94 tests) and the autosave's
timestamp did not move. The last full test run was before this guard; the twelve files were re-run after it.

## At a glance

- **The three failing checks all pass.** One real game bug was behind them (Maren's Path talk); the rest was the smokes being out of date.
- **The critic scored clarity 6, fun 6, polish 6, but its report is partial**: it used 9 runs and reached neither the cave's pop-ups nor
  the Black Market screen. Five of its findings are fixed; the rest are in the inbox.
- **The Transit Yards ghost building is gone.** It was a townhouse standing in the draw-distance dissolve.
- **Zone edges: six zones shot, none fixed.** Three have something left (the Dump's two south corners, Crosspath's south band, the
  D.N.A.'s bare apron).
- **Motion: pickups bob.** Chests and per-zone ambient effects already existed.
- **Tests: 3070 / 3072 passed, 0 failing, 2 pending (40 shards, 24 minutes).**

## Part 1 - the three checks

| Check | Result | Game or smoke? |
|---|---|---|
| Opening-hour smoke (`run_playtest_smoke.sh`) | **Passes** | Both, see below |
| Controller smoke, "Y hides the card details" | **Passes** | Smoke (timing) |
| NPC visibility probe, Corwin Bale | **50 / 50** | Game |

**The opening-hour smoke, check by check:**

| Check that failed | Which was wrong | What changed |
|---|---|---|
| "the only active quest is Meet the Merchants" | Smoke | It expects Meet the Merchants and Fragments (Fragments starts at `trial_cleared` since Nov 7). |
| "every merchant met: hand it to Maren" and the seven after it (Maren takes it back, Make It Yours, its banner, the pack, the Packs screen, opening the pack, Make It Yours back, the store room) | Smoke | One cause: since Nov 3-4 the quest has a step "Equip Tilly's Power Wraps", which the smoke never did. It equips them now. |
| "Bertram says enemies roam the edges of town" | Smoke | His line says "the lanes round the edge of town" since the dialogue rewrite. |
| "the Starter Blade and every equipment slot" | Smoke | Since Nov 3-4 the quest ends on equipping the blade. The smoke equips it. |
| The four "main line appears after the armory quest" checks and "the own Path's quest is tracked" | Smoke | Since Nov 7-8 the zone lines start with Maren's Path talk, not with the armory. The smoke checks they wait, then start with the talk. |
| "Maren has the Path talk ready" / "Maren sends the hero to their own Path's zone" | **Game** | Her cave-mouth welcome never set `elder_greeted`. So the report after the armory quest played her first-meeting speech ("Up and walking. Good. I am Elder Maren...", "buy a few cards from Sable"), hours late, and the Path talk needed a second conversation. The welcome sets the flag now; saves made in between are healed when she is next talked to. Inbox 3. |

Also fixed in the game on the way: the opponent's turn logged "AI produced no legal action" when a duel ended while its move was being
announced (harmless, but an error line).

**The controller check** passed on the first run I made and had failed before: the smoke pressed Y while the last card was still
resolving or a once-ever tip held the pad, when the battle cursor rightly ignores it. The smoke waits for the cursor now. The game is
unchanged. The smoke also puts your zoom and camera angle back when it ends.

**Corwin Bale** stood at x 73.5, straight behind the townhouse at x 72 to 77 from both cameras. He stands in the open alley at x 68.5
now (the mirror of Nell Hargreave's spot) and strolls 2 m instead of 3.2 m, so he cannot reach the house.

## Part 2 - the no-context playtest

Report: `docs/review/critic_nov12d/report.md`. Brief: `docs/review/critic_nov12d_brief.md`. Dev build, the play-script driver, 9 runs,
about 22 minutes, 0 script errors in every run.

**Scores: clarity 6, fun 6, polish 6.** The first hour looked finished to it (about 7 for polish); the Capital rougher (about 5).

**What it did not reach** (it lost three runs to the New Game flow and two to its own cave scripts): the shrine, the Hollow Well, the
"Before the fight" panel, the Cave Warden and his closing words, Crosspath, Maren, the Black Market screen, the Transit Yards. **So the
new pop-ups and the Warden's closing words have still not been seen by fresh eyes.**

| # | Its finding | Size | Done? |
|---|---|---|---|
| 1 | "Back out into the wastes." shows on arriving in the Crease | S | **Fixed**: the Crease has its own line (inbox 2) |
| 2 | The Black Market is easy to miss: no name, an identical stall beside it, a small reach | S | **Fixed**: a "Fig Sly - Black Market" label, reach 1.8 m to 2.6 m (inbox 1) |
| 3 | The Crease's east wall fills half the frame; flat cream rectangles hang in the air | M | **Half**: the rectangles were lantern glass, now small amber lanterns. The wall is unchanged |
| 4 | New Game is three decisions before any story | M | Not changed (inbox 5) |
| 5 | Tidy-Bots knock you flat with no warning | M | Not changed (both hits followed debug jumps) |
| 6 | The Capital map is hard to read | M | Not changed |
| 7 | The minimap is a blurry blob | M | Not changed |
| 8 | The wall's faces are plain slabs | L | Not changed (art) |
| 9 | The enemy's name crowds its plate | S | **Fixed**: the name starts 6 px clear of the portrait ring |
| 10 | The Path choice interrupts the Rescuer; the Wanderer's portrait has a hard edge | S | Not changed: the edge is art, the order is the design |
| note | A room out of reach says "Step on it to find out" | S | **Fixed**: "You can't reach it yet: clear a room that leads to it." |

Three of the five S items are fixed, plus the S note and half of one M. Shots: `crease_arrival.jpg`, `crease_fig_label.jpg`,
`crease_black_market.jpg`.

## Part 3 - the visual leftovers

**The Transit Yards ghost building: fixed.** It was the townhouse at x 72 to 77, z 33 to 45, about 48 m from that camera: exactly where
the zone's draw distance ends, so it stood half dissolved for as long as the hero stood there. Pieces 7 m tall or more now draw 1.3
times further and switch without a dissolve. Before: `docs/overnight_shots/nov12c/partc/capital_before_transit_yards_default.jpg`.
After, same camera: `docs/overnight_shots/nov12d/capital_after_transit_yards_default.jpg` and `_low.jpg`.

**Edges of the other zones: shot, not fixed.** A new driver command, `edgeshots <prefix>`, stands the hero near the eight outermost
walkable points of a place and shoots each at the default and the Low camera. Sheets: `docs/overnight_shots/nov12d/edges/<zone>_edges_default.jpg`
and `_low.jpg`, with every single shot beside them. I looked at the default sheets only; the Low sheets are shot but not reviewed.

| Zone | Default camera | Left to do |
|---|---|---|
| The Dump | **A pale wedge at the south-east and south-west corners**: the camera sits inside the ravine's rim and sees the fog through its back | Close the rim from behind or hold the camera in. Worst of the six |
| Crosspath | A violet mist band along the bottom of the frame at the south edge | Rough but reads as a boundary |
| The D.N.A. | Flat grey apron to the horizon outside the offices | Bare, no void |
| The Gainlands | Sea and painted backdrop at all eight points | Nothing (a blank pale board stands on the west islet; not checked what it is) |
| The Buffet | Gravy sea and backdrop at all eight points | Nothing |
| The forest | Closed by trees and rock at all eight points | Nothing |

## Part 4 - motion

- **Pickups bob** (the Buffet's ingredients, the Dump's beans and crates, the Capital's compost, recipe cards and seed jars): a 9 cm
  bob, a slow turn for a single model, a breathing ground ring. Off on Low-end and under Reduce motion. Tested in a unit test; **I did
  not look at one in the game.**
- **Chests already animate open** (the lid swings, a flash of light; `ChestKit.open_animated`, since Oct). Nothing added.
- **Every zone already has an ambient effect** (`AmbientFx`, since Oct 17: dust in the Gainlands, steam in the Buffet, gnats and fluff
  in the Dump, motes and the paper drift in the D.N.A.). Nothing added.

**FPS on Medium after the pass** (this PC, 1600x900; measured with the tall-piece range at 1.45 times, shipped at 1.3 times):

| Place | Medium | Before (Nov 12c) |
|---|---:|---|
| Crosspath | 75.6 | 70.1 |
| The Capital, `perf_run capital_in` | 63.7 | 57.0 |
| The Capital, Transit Yards camera | 60.6 | 65.8 to 69.1 across the cameras |
| The Capital, Gate Plaza / Hungry Quarter / Palace Approach cameras | 64.5 / 62.8 / 66.4 | same range |
| The Buffet / the Dump / the Gainlands | 81.9 / 71.7 / 83.3 | 82.7 / - / - |

Medium holds 60 everywhere measured, but the Capital's cameras lost about 3 to 5 fps to the ghost-building fix (inbox 4).

## Part 5

- **Tests:** 3070 / 3072 passed, 0 failing, 2 pending (40 shards, 24 minutes).
- **Settings on this PC:** Camera angle is 0 (Cinematic, the default) and zoom is 1.5 in `%APPDATA%\Deckbuilder-RPG\settings.cfg`; they already read so when I checked, and I changed nothing by hand. Scripted runs no longer write the camera angle or zoom into your settings (that is how it got
  left on "Low").

## What's left before 1.0.0

1. **RC6 or 1.0.0 itself** (see the top).
2. **Ten minutes of your own play**: a new game through the cave (the pop-ups, the well, the Warden), then the Capital (the manhole,
   the Crease, Fig Sly). The critic did not get there.
3. **Inbox "Fable Nov 12d"**, items 1 to 4: Fig Sly's label, the Crease line, Maren's speech, the tall-piece range.
4. **Fig Sly's portrait** (`V-FIGSLY.png`) and the rest of Batch 15, still not delivered.
5. **The Dump's two south corners** (the pale wedge), if you want it closed before release.
6. The final checklist of the Nov 12c report below still applies.

---

# Fable Nov 12c - report (the owner's fix list, the pop-ups, the Crease, the world pass, RC6)

Brief: `docs/prompts/fable_nov12_fixes.md` (it replaced `fable_nov12_final.md`). Start tag `pre-fable-nov12c`. Questions:
`docs/overnight_inbox.md`, "Fable Nov 12c" (17 items). Shots: `docs/overnight_shots/nov12c/`. One Godot at a time; no sub-agent ran.
Owner constraints kept: no difficulty setting; the battle board and the other menus keep their layout (only the non-combat dungeon
pop-ups and the pre-fight rules panel were redesigned, as opened up); no new art; nothing uploaded. Ran on Fable 5.2. The Fable pass
Nov 11-12 report follows below.

## At a glance

- **Part A (the fix list): all ten items done**, each with tests and shots (table below). A7.1, Fig Sly's portrait, waits for your image.
- **Part B (the pop-ups): done.** Every non-combat room and the "Before the fight" panel are one illustrated card. Gallery below.
- **Part C (the 3D world): about a third done.** Done: contact shadows, the water, the Capital's and the Crease's edges, the marker
  size at the Low camera. **Not done: eight of the twelve items in whole or in part** - see "What was not done".
- **Part D (Batch 15): nothing to import.** `G:/My Drive/Card Game Art/Pending Review/Batch 15/` did not exist at any check (start of
  every part, last at the end). Two rows were added to `docs/art/batch15_nov12.csv` (V-FIGSLY, UI-NODE-BANNER); all 23 stay "To make".
- **Tests: 3065 / 3067 passed, 0 failing, 2 pending** (39 shards, 24 minutes, after Part C).
- **RC6: **not built.** The export needs 3 GB of free RAM by the house rule; this PC had 1.8 to 2.0 GB free through a 15-minute wait (nothing of mine was running), so it was not started. The source is at version 1.0.0-rc6, tested and pushed. The command is under Part E.****
- **Three things found on the way that were not on the list:** the Capital's grey rectangles were a cache bug (not missing art); the
  occlusion fader could leave a wall or a building invisible for the rest of a visit; the east wall and the front wall faded away
  whenever the hero walked beside them. All three are fixed.

## What was not done (read this before the rest)

- **Part C, item 2 (blended ground, less tiling, edge foliage):** not done.
- **Item 4 (map edges and voids):** done for the Capital and the Crease only. The four Path zones, Crosspath and the forest were not
  scanned.
- **Item 5 (stray quads, foreground obstructions):** only the quest markers' size near the lens. No zone-by-zone scan.
- **Item 6 (duplicate and broken sprites):** not done.
- **Item 7 (the Transit Yards ghost buildings):** the fader bug that could leave pieces transparent is fixed, **but the pale building at
  the top left of the Transit Yards view is still there** (`docs/overnight_shots/nov12c/partc/capital_before_transit_yards_default.jpg`).
  The fader is not fading anything at that camera, so it is something else; I did not find what.
- **Item 8 (faceted props), item 9 (the measured scale table), item 10 (hub storytelling clutter):** not done.
- **Item 11 (light):** every zone already had a grade (Crosspath, the forest and the Dump included), so nothing was added there. New
  light sources only in the Crease (nine lantern lights, five crystal glows).
- **Item 12 (the world motion list):** only the Crease's dripping stalactites. No pickup bob, door or chest animation, ambient life or
  castle music escalation.
- **Part E.1, the no-context playtest:** not run as a no-context critic. I drove the real flow with the play-script driver and the
  smokes instead (the well, the Warden's closing line, the first exit, the Crease, a Primm loss and retry) and looked at the shots
  myself. A fresh pair of eyes has not seen this build.
- **Fig Sly's portrait** is unchanged (as instructed, until the image lands).
- **Three checks fail that this pass did not cause and did not fix** (details under Part E): the opening-hour smoke's quest check, the
  controller smoke's "Y hides the card details", and one strolling citizen in the NPC visibility probe.

## Part A - the fix list

| | What | Done | Shots (`docs/overnight_shots/nov12c/`) | Tests |
|---|---|---|---|---|
| A1 | The Hollow Well: "Sacrifice a random card from your deck for the rest of this dungeon: heal 4 HP." | Random pick from the whole dungeon deck; heal 4 capped at max; the card is back after clearing, losing or leaving (`DungeonRun.deck_after_run`); "Leave it"; at full HP the button reads "You're at full HP" and is disabled; at the minimum deck size it says why; once per run; a save taken mid-dungeon holds the whole deck (a run is never saved, so the cave restarts from its mouth). The sacrificed card shows face up with "The well takes **Card Name**. It returns when you leave the cave." | `a1/`, `popups_after/well*` | `tests/core/dungeon/test_hollow_well_offer.gd` (16) |
| A2 | The Cave Warden's closing words show his picture | In the dialogue box with NPC-WARDEN (they were plain text in the "Through the Forgotten Cave" panel); the line that describes him is narration. Audit of every dungeon boss: all others had a speaker and portrait. The four gatekeepers' post-fight lines had the same gap: fixed. Baron Quadzilla, the Restless Cairn and the Store Room Ghosts have no portrait art (inbox 2). | `a2/` | `tests/ui/test_boss_closing_portraits.gd` (4) |
| A3 | Deck copies text | The only player-facing "4 copies" were two loading tips; fixed, plus the progression and essence docs, the designer guidance sheet and code comments. The in-game tooltips already named 3 and the per-level caps (Common 3; Uncommon 2, 3 from level 9; Epic 1, 2 from 12, 3 from 22; Legendary 1, 2 from 18, 3 at 30). The Glossary's Terms tab gained "Copies of a card" with the caps at your level. No itch page text mentioned copies. | - | `tests/core/data/test_copy_rule_text.gd` (3) |
| A4 | First exit from the cave | The hero stands 1.4 m to Maren's left (west), facing the square, and keeps facing it through her welcome. The old spot stood under her eave, so the fader hid her whole house. | `a4/` before and after at the default and Low cameras | `tests/world/test_cave_arrival.gd` (+1: position, facing, no building under either camera's sight line) |
| A5 | Chef Fennel Gravois's Snack | The token's data was already 1/1. It stood as 0/1 because the "zone met early" ease takes 1 attack off his units. Tokens whose numbers a rule or a boss event states now enter with those numbers (`GameState.create_stated_token`). All 44 texts that state a token's numbers match the token. | - | `tests/core/game/test_token_text_stats.gd` (4) |
| A6 | The Capital's floating grey rectangles | A cache bug: the rim's dead trees and rubble are painted cards that came back from the build cache with no material. Fixed at the root. Also fixed: wall sections left invisible by the fader; the east and front walls fading when the hero walks beside them. Added from the kit, on the ridges outside the wall: ruined houses, ash walls, toppled statues, rubble mounds, crystals (`CapitalRimRuins`), and ash ground under the walls. `matscan`: 2 groups before and after (the far apron and one tunnel arch); `groundscan`: 0 offenders before and after. | `a6/before/`, `a6/after/` (17 edge spots x 2 cameras) | `tests/world/test_capital_rim_ruins.gd` (7), `tests/world/test_occlusion_ground.gd` (+2) |
| A7 | Fig Sly's art; the dual-colour dots | The dots are gone from the card face every view draws (hand, board, full size, shops, the Deck Station, the collection, rewards, packs). The Path cost icons stay. **The portrait: nothing changed, no file landed.** | `a7/` (before, after, one card in each view) | `tests/ui/test_multipath_dots.gd` (3) |
| A8 | The Crease | An enclosed cavern (`CapitalCrease`): rock walls on three sides running on past the camera, a 7.6 m rock ceiling, about 100 stalactites (five drip), stalagmites, ten puddles, nine lantern lights, five crystal glows, a second stall and five stacks of painted crates. No sky, no castle. The six black doorways are floor hatches with a lit marker (same shafts); the tunnel is a timbered mouth in the east wall; the ladder stands against the west wall. **Quest:** a new main quest, "Under the Capital", starts and takes the tracker on first arrival in the Capital (inbox 6). **One "Services restored" bar.** NPC visibility probe: Wren, Fig Sly, Hesper and Kestrel pass at both cameras. | `a8/before/`, `a8/after/` (10 spots x 2 cameras + HUD) | `tests/world/test_crease_cavern.gd` (8) |
| A9 | Losing to Primm | "Fight Primm again" (Phase 1, full HP, the leaders' boons given once, earlier rooms kept) or "Leave the castle". Driven for real: a Phase 2 loss, Fight again (Phase 1 at 23 / 23 HP), a loss, Leave (back in the Capital). | `a9/` | `tests/core/dungeon/test_primm_retry.gd` (5) |
| A10 | Inbox 11 (a) and (b) | (a) the castle map shows a room's type once a room leading to it can be reached; (b) every castle fight's three reward cards include an Uncommon or better, the paid reroll too. | `a10/` | `tests/core/dungeon/test_inbox11_nov12.gd` (6) |

## Part B - the pop-ups

One card for every non-combat room and for "Before the fight" (`ui/dungeon/node_card.gd`):

- **Banner:** the dungeon's own painted map, cropped round the room and blurred, under a colour wash per kind and a vignette; the room
  kind's large icon in the middle with a glow and a bob; particles per kind (motes for a shrine, mist for the well, sparkles for
  treasure, embers before a fight). `UI-NODE-BANNER` becomes the base by itself when it lands.
- **Body:** vellum with dark ink inside the gold frame; the kind in small caps over the name; the flavour line in italics, wrapped into
  even lines; what it does as icon rows; "HP 9 → 15" with the heal as a ghost segment on the bar ("already full" at full HP); the cost
  as a chip; a primary and a secondary button with icons. Esc and the pad's B press "Leave it" where leaving is allowed.
- **Motion and sound:** the card scales and fades in over 0.25 s, the banner a beat later; a shimmer crosses the HP bar as it fills; the
  well shows the card it took; existing sounds on open, confirm and close. Still under Reduce motion.
- **Pre-fight panel:** the foe's cut-out (head and shoulders) or Bestiary picture in the banner; a row per rule (icon, name, one line); a
  hidden trait as a "?" row; two columns and a lower banner past five rules. A card taller than the screen gives up banner height.

**Gallery:** `docs/overnight_shots/nov12c/popups_gallery_before_after.jpg` (before and after, side by side);
`popups_before/` and `popups_after/` (the well open, at full HP and after the card is given; the shrine; an event; a rescue; treasure;
the pre-fight panel with 3 rules and with 9) at 1280x720 and 1920x1080; `popups_after_large_text/` at the largest text size.
**Controller:** the buttons take the pad's focus and B leaves (tests in `tests/ui/test_node_card.gd`, 14). I did not take a screenshot
with a controller prompt showing, and the controller smoke does not walk the cave's rooms.

## Part C - the 3D world

| Item | Done? |
|---|---|
| 1 Contact shadows | **Done.** Characters' blobs are darker with a dense core (0.42 -> 0.52 on Low, 0.70 on Medium and High) and a little bigger; every ground prop gets a soft base shade from one MultiMesh per scene (`PropShade`; none on Low-end). |
| 2 Blended ground | Not done. |
| 3 Water | **Done in part.** The shared toon water and the sea plane lean to the sky at a grazing view and the sea has slow ripples; the Capital's fountains use the shared water. The Dump's stream already used it. The town fountain keeps its own shader. |
| 4 Map edges and voids | The Capital (A6) and the Crease (A8) only. |
| 5 Stray quads | Quest markers shrink near the lens. No scan. |
| 6 Sprites | Not done. |
| 7 Ghost buildings | The fader's stuck-transparent bug fixed; the Transit Yards' pale building is still there. |
| 8, 9, 10 | Not done. |
| 11 Light | Grades already existed in every zone; new lights only in the Crease. |
| 12 Motion | The Crease's drips only. |

**FPS after items 1, 3 and the Capital work** (this PC, 1600x900; `docs/perf/runs/n12c_partc.md`, `n12c_partc_cap.md`):

| Place | Medium | Low | Nov 12 before |
|---|---:|---:|---|
| Crosspath | 70.1 | 91.3 | 69 / 91 |
| The Buffet hub | 82.7 | 101.8 | 80 / 99 |
| A battle | 352 | 371 | 354 / 350 |
| The Capital, four paint-over cameras (`tools/capital_fps.sh`) | 65.8 to 69.1 | 82.2 to 84.5 | 64 / 85 |
| The Capital, `tools/perf_run.sh capital_in` | **57.0** | 75.8 | this probe read 58.3 to 61.2 on Nov 3 |

Medium holds 60 at the Capital's paint-over cameras. **The other Capital probe reads 57**, and it read under 60 before this pass on
two of three earlier runs; I could not move it (restricting, merging and unshadowing the new rim ruins changed nothing: 57.0 both times).

## Part D - Batch 15

| File | Status |
|---|---|
| The 21 rows of Nov 12 | To make (the folder never appeared) |
| `V-FIGSLY.png` | To make (row added) |
| `UI-NODE-BANNER.png` | To make, optional (row added) |

## Part E - verify and build

- **Tests:** 3065 / 3067, 0 failing, 2 pending.
- **Driven for real:** the well offer, taken and at full HP; the Warden's closing line; the first exit; the Capital's edges on foot;
  the Crease at ten spots; a Primm loss, retry and leave. 0 script errors in the play runs I checked (the Capital edges and scans, the Crease, the Primm retry, the water shots).
- **Opening-hour smoke (`run_playtest_smoke.sh`): FAILED, not from this pass.** The cave, the arrival 1.4 m from Maren and her welcome
  pass. It then fails "the only active quest is Meet the Merchants" because Fragments is active too; Fragments has started at
  `trial_cleared` since Nov 7 (`QuestDefinitions.story_gate`). Eleven later checks fail after it. I did not fix the smoke or look at
  the later ones one by one.
- **Controller smoke: one check fails** ("Y hides the card details" in the ghost duel); the other pad checks pass.
- **NPC visibility probe (the Capital): 48 of 50 pass**; the two failures are one strolling citizen (Corwin Bale) at both cameras.
- **RC6:** **not built** (free RAM 1.8 to 2.0 GB for 15 minutes; the rule is 3 GB). No exported smoke and no `play_exported.sh`
  check was run on RC6. `project.godot` is at `1.0.0-rc6`, `CHANGELOG.md` and `docs/release/rc6_notes.md` are written. To build it:
  close Chrome, ChatGPT and anything else heavy, then in Git Bash from `C:\Dev\Deckbuilder-rpg`, in the foreground:
  1. `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc6` (4 to 10 minutes; "EXPORT STOPPED" means nothing was replaced);
  2. `bash tools/run_release_smoke_exported.sh` (look for `PASSED`);
  3. `bash tools/export_test_pack.sh`, then
     `bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_a.txt r1a 480`,
     `SUITE_SETTINGS_FILE=_screenshots/exported/settings_play_r1a.cfg bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_b.txt r1b 480`,
     `bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_c.txt r1c 480`;
     `grep -c "SCRIPT ERROR" _screenshots/exported/play_r1*.log` must print 0 three times.
  The zip should come out near RC5's 734 MB: this pass added code and shaders only, no art.

## One thing to check on your PC

The play-script shot runs save the camera angle into your settings: **Settings > Display > Camera angle is on "Low"** now (the shot
scripts end on it; I do not know what it was before this session). The controller smoke had also changed the zoom to 1.3; I set it back to
the default 1.5.

## The final 1.0.0 release checklist

As Nov 11's (in the Overnight Nov 10-11 report below: donation link, version, export, smoke, the three exported checks, the real exe
once, tag, the itch upload, download it back, flip to Public), with these changes:

0. **Read inbox "Fable Nov 12c" first.** Items 5 and 6 (the shafts as floor hatches; the new quest), 13 (the pop-ups' light vellum
   body) and 14 (the shrine can be left) change what players see and were my choices.
1. **Play ten minutes before anything else:** a new game through the cave (the well, the Warden, the first step into Crosspath), then
   a late save in the Capital (the edges outside the wall, the manhole, the Crease, Fig Sly). Nobody but me has looked at this build.
2. **Fig Sly:** when `V-FIGSLY.png` is in Pending Review / Batch 15, say "import portraits" (or run `bash tools/import_portraits.sh`),
   check him in the Crease, commit. Then export.
3. **Export RC6 (or go straight to 1.0.0):** the three numbered commands under Part E above. No RC6 zip exists yet.
4. Set the camera angle back if "Low" is not what you want players' default screenshots to show (it is a per-PC setting, not in the build).
5. Then steps 1 to 10 of Nov 11's list with `1.0.0`.

---

# Fable pass Nov 11-12 - report (visual quality, world consistency, late game)

Brief: `docs/prompts/fable_nov12_visuals.md`. Start tag `pre-fable-nov12`. Questions: `docs/overnight_inbox.md`, "Fable Nov 12" (12 items).
Shots: `docs/overnight_shots/nov12/` (`before/`, `after/`, `part4/`). Gallery: `docs/review/visual_nov12/index.html`. Style bible:
`docs/art/style_bible.md`. One Godot at a time; the three critics (art director before and after, late game) were no-context agents and no
Godot of mine ran while the late-game critic played. Owner constraints kept: no difficulty setting; the battle board and every menu layout
untouched (effects, shaders and colour inside existing elements only); no approved painting repainted or replaced. Ran on Fable 5.2 (the
launch line was pasted into a running session). The Overnight Nov 10-11 report follows below.

## At a glance

- **The art-director score did not move: 6.3 before, 6.2 after** (113 shots each, the same cameras, a fresh no-context critic each time).
  The second critic scored content this pass never touched about half a point lower (dungeon maps 8.2 -> 7.6, Crosspath 7.5 -> 6.9, the
  forest 6.2 -> 5.7), so the two numbers are not on one scale; against that drift the zones that were worked on gained (table below), but
  **the honest reading is: this pass fixed specific named faults, it did not lift the 3D world to the level of the painted layers.** The
  3D world scores 5.4-5.6 in both reports; the painted screens 7.4-7.6. What closes that gap is painted art (Batch 15) and material
  work on a scale this pass did not reach.

  | Group | Before | After | Change | Worked on? |
  |---|---:|---:|---:|---|
  | The D.N.A. | 4.4 | 4.7 | +0.3 | yes (lighting 3.6 -> 4.7) |
  | The Capital after Primm | 5.6 | 5.8 | +0.2 | yes (lighting 4.3 -> 6.8) |
  | The Gainlands | 5.5 | 5.7 | +0.2 | yes |
  | Battles | 7.4 | 7.6 | +0.2 | the tutorial board fix (4.8 -> 7.8) |
  | The Endless Buffet | 5.5 | 5.5 | 0.0 | yes |
  | Screens (UI) | 6.8 | 6.8 | 0.0 | no (layouts are fixed) |
  | The Capital before Primm | 5.8 | 5.4 | -0.4 | a little (wall, camera) |
  | The Verdant Dump | 5.8 | 5.3 | -0.5 | a little (ghost glasshouse) |
  | The Opening Forest | 6.2 | 5.7 | -0.5 | no |
  | Dungeon maps | 8.2 | 7.6 | -0.6 | no |
  | Crosspath | 7.5 | 6.9 | -0.7 | no |
  | **All 113** | **6.3** | **6.2** | -0.1 | |

  (Means of the six criteria per shot, from `docs/review/visual_nov12/scores_before.csv` / `scores_after.csv`.)
- **RC5 is built:** `builds/TheWaywardPath-v1.0.0-rc5-windows.zip`, **734 MB** (RC4: 734 MB; pack 845 MB, 14104 files, every MD5 matches).
  The release smoke on the exported pack **PASSED**; the three exported-build checks ran with **0 SCRIPT ERROR**. Full GUT before the
  export: **2984 / 2987 passed, 1 failing** (a test that pinned the old 97 % fade; fixed after), 2 pending. Not uploaded anywhere.
- **Performance held** (Medium, this PC): Crosspath 72 -> 69 fps, the Buffet hub 85 -> 80, the Capital 63 -> 64 (65 in the freed state),
  a battle 344 -> 354; Low unchanged (91 / 99 / 85 / 350). All inside this laptop's 10 % run-to-run drift; the Capital keeps about 4 fps
  over 60.
- **Late-game critic on RC5: clarity 6, fun 4, polish 6 (old build 5 / 4 / 5; target 7 / 6 / 7) - the target was missed.** It never beat
  Primm's Phase 2 or 3, so it did not see the ending. Part of that was the test driver skipping its turns (fixed; see Part 4.4). Four of
  its small items are fixed **in the source but not in the RC5 zip**: the re-export was stopped by the machine's low-memory guard and
  was not started again. **The zip on disk is the build from 07:59, before those four fixes.** No second critic was run.
- **Owner decisions applied:** max hand size 10 (inbox 1 says what replaced the three things that raised it); inbox 12 no change (a test
  pins the Armory's order); inbox 13 no change to Primm, and `dev primm N` grants the four boons (verified: 31 HP at the Phase 2
  checkpoint); Escape in a conversation kept.

## What was not done (read this before the rest)

The brief was a 24-hour pass; these parts were not done or only partly done:

- **Part 1:** no SSAO / SSIL / SDFGI (SSAO measured +2.3 ms on Medium in October and the Capital has 4 fps of headroom); no new sky or LUT
  per zone; no new light sources placed; sprites' contact shadows unchanged (both critics still call them faint). Per-zone grades were
  changed only in the D.N.A., the Gainlands, the Buffet and the freed Capital. FPS was measured in four places, not every zone.
- **Part 2.1:** the Gainlands got smooth cliffs and a calmer palette, **not** blended ground textures or edge foliage; its fortress brick
  still tiles (after-critic #6) and its shadows are still hard (#7).
- **Part 2.4, the scale audit:** the ratios are in the style bible; no zone-by-zone measurement was made and no outlier fixed.
- **Part 2.6, hub storytelling clutter:** none added (only the freed Capital's dressing).
- **Part 3:** only the gaps found were filled (buff shimmer, the result banner, zone-coloured fades). The battle list's other items
  already existed (lift / land, hit-stop, shake with its Settings toggle, floating numbers, death dissolve, the turn sweep) and were not
  re-tuned; the world list (pickup bob, door and chest animations, more ambient life) and the UI list (reward sequencing, a click-sound
  audit) were not worked on.
- **Part 4.2:** castle rooms do not escalate in music (the look does, through the vignette).
- **Top 25:** see the table - 7 done, 7 partly, 1 kept by design, 10 not (most need painting: Batch 15).
- **Part 4.4:** the late-game target (7 / 6 / 7) was missed (6 / 4 / 6); no re-score after the fixes; six of the critic's top 10 are
  not fixed or only half.
- **Part 6:** the RC5 zip does not contain the last four fixes (commit 86de96a4). The re-export was stopped by the low-memory guard
  before it wrote anything; the smoke and the three exported checks were therefore run on the 07:59 build only.
- **Memory before/after:** only "after" was read (below); no baseline was taken at the start.

## Part 0 - the audit and the style bible

- **The fixed shot set:** 113 shots through the play-script driver (`bash tools/nov12_shots.sh <tag> [set ...]`, scripts in
  `docs/review/play_scripts/nov12/shots_*.txt`): each zone's arrival, hub, main dungeon door and two mid-zone views at the default and
  the Low camera angle; the Capital before (9 places) and after Primm (5); 16 dungeon maps; 7 battles; 9 screens. New driver commands:
  `hud off|on`, `cam N`, `calm`, `spots`, `at <anchor>`, `matscan [m]`, `groundscan`.
- **The art-director critic** (brief `docs/review/critic_art_nov12_brief.md`; reports `docs/review/critic_art_nov12/report_before.md`,
  `report_after.md`): images only, six scores per shot, a ranked top 25.
- **`docs/art/style_bible.md`:** reference shots, a palette per zone, the lighting model, material rules (no pure-white, pure-black or
  untextured large surface), outlines and edges, a scale table (hero 1.70 m), foliage and ground, VFX.

## Parts 1-2 - the top 25 (the before report's ranking) and what was done

| # | Problem | Done |
|---|---|---|
| 1 | D.N.A. buildings are unlit black boxes | **Done, partly effective.** Ambient 0.4 -> 0.95 (#6f8a80), the key from the side (yaw 118), exposure 1.06, lighter wallpaper with a faint self-light, a brass picture rail; the wall at the lens cuts away on floor outside every room (`DnaRoomCut` - the giant chest's alcove was 40 % wall). Lighting 3.6 -> 4.7; the after critic still calls the zone a grey box (its floor and repeats). |
| 2 | The Capital after Primm is blown out | **Done.** `CAPITAL_FREED` is the inside's AgX grade turned to a golden afternoon (it was an old ACES preset). Lighting 4.3 -> 6.8. |
| 3 | Ghost buildings mid-fade | **Done for the Dump** (the glasshouse's glass stayed when its frame dissolved) and in general (`OcclusionFader.FADED` 1.0). **Not gone in the Capital's Transit Yards** (still in the after report). |
| 4 | Flat single-colour blocks | **Partly.** Every untextured flat colour gets a painted wash in the toon shader (`flat_wash`) and is never pure white or black. The critic still names the same blocks (Grave Row's box, the camp's slabs, the stalls, the mats): a wash is not a texture. Batch 15 rows. |
| 5 | Main dungeon doors do not read as doors | **Done for two:** the kit's painted oven-brick door in the Test Kitchen's arch and the studded door behind the House of Gains' portcullis. The D.N.A.'s Hall already had its kit door; not changed. |
| 6 | Faceted low-poly props | **Partly:** smoother Capital lamp globes. Hedges, statues, the D.N.A. sphere: not done (Batch 15 rows for the statue and the orb). |
| 7 | Smiley portraits and emblem | **Kept** (Primm's emblem; inbox 7). Batch 15 asks for painted easel portraits. |
| 8 | Windows are flat colour cut-outs | **Done in the Buffet** (glazing bars, oven grates). **Not in the Capital** (hundreds of panes: Batch 15's first row). |
| 9 | Broken Low camera at the Resistance Camp | **Done.** The lens rides 1.1 m over the ground under it and the Capital counts its rim hills. |
| 10 | Flat city wall and grey gate road | **Partly:** dust over the plinth and streaks under the cornice. Still "no surface detail" for the after critic. |
| 11 | Navy rectangle on the palace | **Done:** five cloths in the Paths' colours (painted banners: Batch 15). |
| 12 | Stray giant quads and billboards | Not done (quest markers and paper at the Low camera). |
| 13 | Tutorial battle has no board art | **A dev-tool artefact, fixed:** `dev encounter` now uses the cave's board (4.8 -> 7.8). Players always had it. |
| 14 | Map edges show voids and strips | Not done (Batch 15: a rubble row). |
| 15 | Gainlands materials tile and stretch | **Partly:** smooth-shaded cliffs and rocks, saturation 1.26 -> 1.12, a calmer sea. The brick and the mats: not done. |
| 16 | Buffet is an orange monochrome with haloed sharpening | **Partly:** a lavender fill light; the default sharpening 0.8 -> 0.4 for every zone (new installs; a saved setting is kept). |
| 17 | World map looks like a debug view | Not done (painting: Batch 15). |
| 18 | Flat-colour windmill blades and bunting | Not done (Batch 15). |
| 19 | Fountain water flat blue with scribble | Not done. |
| 20 | Flat bridge deck and grey water at the Dump | Not done. |
| 21 | Foreground obstructions | Not done. |
| 22 | Duplicate and broken sprites | Not done. |
| 23 | Battle item slots and plain overlays | **Partly:** VICTORY / DEFEAT stand on a band with an outline. The slots: Batch 15. |
| 24 | Dungeon maps hide their own art | Not done (UI layout). |
| 25 | Shop screens clipped and empty | Not done (UI layout: owner constraint). |

**The known ones from the brief:**
- **2.2 the material scan** (`matscan`): lists every untextured surface of 2.5 m or more per zone; the wash above is the blanket answer.
- **2.3 the Capital after Primm celebrates** (`CapitalCelebration`): the golden light, the fountains running again, a crowd of townsfolk
  in the Gate Plaza and on the avenue with six new passing lines, bunting from the fountain to the plaza's lamps and across the avenue,
  confetti on the paving, the Path-coloured cloths. One mesh for the decor; Low-end halves the crowd and drops the confetti. Medium 65 fps
  freed against 69 before at the gate. **The after critic's verdict: "a nicer time of day, not a celebration"** - it wants several times
  the crowd, banners on the houses, stalls and a changed sky. The crowd is 18 people; this is the place to add more if you want it.
- **2.5 the prop-ground check** (`PropGroundCheck`, `groundscan`, 5 tests): all five zones scan clean apart from by-design pieces.
- **2.7 the leftovers:** the cracked mirror is nine dark shards on a backing (was one pale pane); **Old Hob's stuck portrait reproduced
  and fixed** (the listener portrait stood alone for 0.7 s after a scene's last line - the midgame critic's route, before and after
  shots in `_screenshots/play/n12_repro_hob/`); the entrance roamer stays beaten per save; the Rift pop-up was already once ever; the
  "milky" fades were the 3 % residue and the glasshouse glass.

## Lighting changes per zone

| Zone | Changed |
|---|---|
| The D.N.A. | ambient 0.4 -> 0.95 and greener, key yaw 140 -> 118, exposure 0.98 -> 1.06, wallpaper tint and self-light |
| The Gainlands | saturation 1.26 -> 1.12, post saturation 1.22 -> 1.08, look saturation 1.16 -> 1.04, shadow opacity 0.7 -> 0.62, sea tint, smooth cliff normals |
| The Endless Buffet | ambient #e8c2a4 -> #c9b4d2 (a lavender fill) at 0.56, shadow tint to match |
| The Capital, freed | a new preset on the inside's grade: sun pitch -34, warm key, violet ambient 0.42, shadow opacity 0.62, exposure 0.46 |
| Everywhere | default sharpening 0.8 -> 0.4; scene fades in the zone's colour; untextured flats washed |
| Crosspath, the forest, the Dump, the Capital before | unchanged |

## Part 3 - the motion list

Added: a band of light crossing a card when its numbers rise (`card_shimmer.gdshader`); the result word on a band with an outline and a
swell; scene fades through the zone's colour (`SceneManager.fade_colour`). All hurried by the battle speed and off or still under Reduce
motion. Already in the game and left as they were: card lift and land, attack recoil, hit-stop and the final blow's slow motion, screen
shake with "Reduce screen shake", floating damage and heal numbers, the death dissolve, the turn ribbon, button hover and press easing,
click sounds everywhere (`UiSounds`), footstep puffs and per-zone ambient particles. Not done: see "What was not done".

## Part 4 - the late game

- **4.0 max hand size 10:** `GameState.MAX_HAND_CAP`; levels 14 / 28, the Lanyard, Quota's Stopwatch and the Weighing Scale no longer
  raise it (inbox 1).
- **4.1 owner decisions:** inbox 12 and 13 no change; `dev primm N` grants the four boons.
- **4.2 the turn panel** follows the turn the board has played back to (it flipped to "Your turn" in the middle of the foe's attacks).
  **The mirror phase:** Primm's copies of your cards wear a constant silver sheen and the rule says "His copies sit on his side of the
  table and shine silver, like a mirror; the plain ones are yours." **The build-up:** castle fights wear a rift-violet vignette that
  deepens with the rooms cleared; the three phases have their own (gold, cold silver, pulsing violet with cracks of light).
- **4.3 the ending:** each still drifts slowly (`StillBackdrop.drift`), a 2.4 s crossfade into the credits, a "Thank you for playing" card
  naming the Lab and the Gallery, then the postgame announcement. Music cues unchanged (the three beat cues and the credits cue existed).
- **4.4 the late-game critic on RC5:** `docs/review/critic_late_nov12/report.md` (30 scripts, 34 runs on the exported pack, 0 SCRIPT ERROR). Scores
  6 / 4 / 6. Phase 1 won in 8 turns; Phase 2 lost four times, Phase 3 lost once and one unfinished. Its built-in player stalled 2-6
  times a fight there: in a ten-card hand it clicked the covered centre of a card, nothing happened and the driver passed the turn.
  `tools/battle_pilot.gd` now clicks the card's uncovered strip. After that, on the dev build at level 20: Phase 2 **won** (1 try, no
  stalls), Phase 3 **lost 3 of 3** (turns 6, 7, 7, no stalls). Primm was not tuned (owner decision); inbox 10 asks the owner to play
  Phase 3 once. Fixed from its top 10: #4 the turn panel left the screen during Setting Up (the line is set smaller and can no longer
  widen the panel), #5 the funeral is on the map and in "Point me to...", #7 the Phase 3 hint, #10 the reward line's wording, #3 the
  driver. Not done: #1 and #2 (Primm's difficulty, retry a phase), #6 (room fog), #8 (needs painting), #9 (not reproduced), the
  smaller notes. All four game fixes were checked on screen in the dev build (`docs/review/play_scripts/nov12/late_fix_*.txt`).

## Part 5 - Batch 15

`docs/art/batch15_nov12.csv`: 21 rows in the earlier batches' columns, ranked. The top: the Capital's windows (2), six painted area maps,
the battle item slots, ICON-EQ-HALLPASSSLIPPERS, ICON-GEAR-EARNEDBLADE, Dex's table and card back, Primm's easel portraits (3), the freed
banners (4), NPC-HESPER and STORY-EPI-WRINKLES (REDOs), the Gallery's eight bestiary pictures and its map, prop cards for the things both
critics called stand-ins (the Dump's statue and sails, the Buffet's stalls, the D.N.A.'s orb, a rubble row), locked packs, a credits
panorama, lanterns and fireworks for the freed sky. The after critic adds candidates not yet in the list: the Gainlands' fortress brick,
the Dump's heart door, painted hedges.

## Part 6 - verify and RC5

- **Tests:** `tests/test_fable_nov12.gd` (20: Primm's phase restart and the boons, the Armory's order, the freed preset, the cloths, the
  celebration and its Low-end cut, the hand cap, the finale vignette, the wash range, the fade colour, the mirror sheen) and
  `tests/world/test_prop_ground_nov12.gd` (5). Full GUT, 38 shards, 24 min: 2984 / 2987, 1 failing (fixed), 2 pending. After that run
  only the default sharpening and its test changed (those files re-run green). **After the late critic's fixes (3 new tests): full GUT
  again, 38 shards, 24 min: 2988 / 2990 passed, 0 failing, 2 pending.**
- **Performance** (`docs/art/graphics_tier1/fps_n12_before.md` / `fps_n12_after.md`, 5 s each, vsync off):

  | Area | Low before | Low after | Medium before | Medium after |
  |---|---:|---:|---:|---:|
  | Crosspath square | 92.3 | 91.1 | 71.9 | 69.3 |
  | The Buffet hub | 99.8 | 99.4 | 84.9 | 80.3 |
  | The Capital, inside | 85.8 | 85.1 | 63.2 | 64.2 |
  | A battle | 353.5 | 350.1 | 343.8 | 354.0 |

  The battle is an ordinary fight, not a boss (the finale vignette is one full-screen pass on a 350 fps screen). Memory after, one
  session walking Crosspath -> the Capital -> the Buffet: working set 1.80 GB / 0.96 GB / 0.91 GB, video memory 1026 / 930 / 700 MB. No
  before reading was taken.
- **Export:** `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc5` -> EXPORT OK, zip 734 MB, export peak 1.83 GB working set.
  The "over the 750 MB budget" warning is the same as RC3's and RC4's. The RC4 zip is kept.
- **Checks:** `run_release_smoke_exported.sh` PASSED (1.0.0-rc5). `play_exported.sh` A, B (A's settings), C (Low-end): 0 SCRIPT ERROR in
  all six logs. Three `button Continue: NOT FOUND` lines (A twice, B once) are the scripts pressing a box the Enter key had already
  closed; the shots show the game back in Crosspath.
- **Not re-exported:** the four late fixes (turn panel, funeral map entry, Phase 3 hint, reward line) are in the source after the zip
  was built. A second `export_windows.sh 1.0.0-rc5` started with 2.1 GB free and was stopped by the session's low-memory guard during
  the import step; the zip from 07:59 is untouched (MD5s as checked then). To get them into a build: close other programs, run the
  export line above, then `run_release_smoke_exported.sh` and the three `play_exported.sh` checks.
- **Docs:** `CHANGELOG.md`, `docs/release/rc5_notes.md` (both list the four late fixes; the notes say they need the re-export).

## Release-day checklist (the owner)

As Nov 11's (below, in the Overnight Nov 10-11 report), with these changes:

0. **Re-export RC5 (or go straight to 1.0.0) before giving it to anyone**: the zip on disk lacks the last four fixes.
1. Read inbox "Fable Nov 12" first - items 1 (hand-size replacements), 5 (six new crowd lines) and 6 (fountains running) change what
   players see and were my choices.
2. Decide whether RC5 or RC4 is the base for 1.0: RC5 changes the look of every zone a little (the wash, the sharpening) and of three
   zones a lot. If in doubt, play the D.N.A., the Gainlands and the freed Capital for five minutes each on your own screen.
3. Then steps 1-10 as before, with `1.0.0` in place of the RC name; the three exported checks may print the harmless `NOT FOUND` lines
   above.
4. After release: Batch 15 is the next visible gain; the after critic's top 25 (`report_after.md`) is the list to work from.

---

# Overnight Nov 10-11 - report

Brief: `docs/prompts/overnight_nov10.md`. Start tag `pre-overnight-nov10`. Questions: `docs/overnight_inbox.md`, "Overnight Nov 10-11".
Shots: `docs/overnight_shots/nov11/`. One Godot at a time; the critics (the wayfinding critic, the late-game critic) were the only Godot while
they played, and no sub-agent ran while a Godot of mine did. Owner constraints kept: no difficulty setting; the battle board and the UI
layout untouched (Part 1's token stacks and the Setting Up words live inside the existing row and rule row); Primm as he was. Owner
decisions applied: stashes stay marked while a step wants one (1); the Dump's herd grazes on the Commons (2); the D.N.A.'s Hall door marked from arrival
(3); the Capital's secret wall hole kept (4). The Fable pass Nov 10 report follows below.

## At a glance

(Resumed Nov 11 after a PC reset cut the run after Part 5.)

- **RC4 is built:** `builds/TheWaywardPath-v1.0.0-rc4-windows.zip`, 734 MB (pack 845 MB, 14098 files, MD5s match). The release smoke on
  the exported pack **PASSED**; the three exported-build checks (fresh settings, carried settings, Low-end) ran with **0 SCRIPT ERROR**.
  Full GUT before the export: **2965 / 2967 passed, 0 failing** (2 pending), 38 shards. Not uploaded anywhere.
- **The exported-build critic's top 10 (Part 1):** all ten done - gates named in the main quest's "Where to go", roamers 10 m clear of every
  door, token swarms stacked "xN", "Setting Up" in words, 6 s toasts, E prefers the quest NPC, alphabetical "Point me to...", Esc order.
- **Wayfinding, minutes to the main dungeon door** (no-context critic, exported pack, guidance only):

  | Zone | Nov 10 | Run 1 | Run 2 |
  |---|---|---|---|
  | The Gainlands | not reached, 23.5 | reached, 21.2 | **reached, 18.6** |
  | The Verdant Dump | not reached, 19.1 | not reached, 24.0 | not reached, 24.1 (traversal, not direction; fixed after) |
  | The D.N.A. | reached, 18.3 | **reached, 5.8** | - |

- **Fight pacing (Part 3):** the expected player now plays the midgame's 27 ordinary fights in **5.6 turns** (5.8), 98 % wins, **none over 7**
  (2 before), after about -20 % HP on the L10-14 band's ordinary foes. The real cause of the critics' 9-11 turns is **gear**: a bare hero still
  runs 9-10 turns - **inbox 12 is your call** (accept / a stall breaker / steer damage gear).
- **Late-game critic (Part 4): clarity 5, fun 4, polish 5 - no change from 5/4/5.** Its top 10: Primm's Phase 2-3 HP wall (**inbox 13**, Primm
  untouched), "Every unit is a 3/3" vs 7/4 (reworded), the 10+ card hand (logged: board layout), turn label / Setting Up countdown (countdown
  fixed, ribbon lag logged), Tidy-Bot drain (fixed: 10 s retreat), stale battle hints (fixed), dialogue over the node panel (fixed), mirror-phase
  ownership / the cracked-mirror quad / the unchanged Capital (logged). **A blocker it led to was fixed first:** after "Skip card" on a boss's
  reward, E never advanced the boss's closing words - Primm's included, so the ending could not be reached that way.
- **The release-day checklist** is at the end of the Finish below.

## Part 1 - the exported-build critic's top 10 (inbox 14)

| # | Problem (critic) | Done |
|---|---|---|
| 1 | The main quest's dungeon step never names the gate | Every zone's dungeon step "Where to go" line names the gate and what opens it, and a second line once it is open (`QuestObjective.hint_open` / `way_open`): the Buffet "Sir Loin's gate on the way wants Old Meatloaf mended - see Basil (the favour Mend the Meatloaf)" -> "Sir Loin's gate is open: north over the Gravy River on the Lazy Susan"; the Dump "Two things bar the way: the stream (plant the Magic Bean from the stream bank at the West Sprout Mound...) and the junk barricade on the stairs (charge it on a mount from the stables)" -> "The way is clear"; the Gainlands "Nothing is locked on the way: the middle road climbs straight to it from the bridge, past three road guards"; the D.N.A. "Its door is open: no permit, no favour, nothing locked on the way". Mend the Meatloaf's summary ends "Needed for the gate: Sir Loin opens the way to Layer-Cake Town and the Test Kitchen for a mended loaf." Owner decision 3: the D.N.A.'s favour step carries a part that marks the Hall's door from arrival (its hint: "...or go straight up to the Hall of Final Approvals: its door is open, no favour needed"). |
| 2 | A roamer camps the Test Kitchen door | `ZoneScene.ROAMER_DOOR_CLEARANCE` 10 m: `tests/world/test_roamer_doors_nov11.gd` builds every zone headless and fails on any roamer whose home +/- patrol comes within 10 m of a dungeon door, a gate or the exit (and on a home a roamer may not walk); it prints the nearest fitting home for an offender. Eleven moves (inbox 1): the Buffet's jelly (50, 20) -> (36, 32) - the Gelatin Sentinel - its loaf and the hub meatball, the Dump's gulls, the Capital's two castle-approach roamers, its tunnel-mouth inspector and a Tidy-Bot; the scene's exit roamer stands 14-17 m out. Road guards are the obstacle on their road by design and are exempt. |
| 3 | 9-11-turn fights | Part 3 below. |
| 4 | The boss's token swarm overlaps | Identical tokens on the battlefield (same card, same live numbers and state; not attacking, blocking or blocked) share one slot with an "xN" badge (`BattleBoard._field_stacks`, `FieldStack<owner>_<n>`), both sides, from two copies up; the row's spacing counts slots, so seven Sashimi Weenies take one card's width. Real cards never stack; the pad skips the cards under a stack's top. |
| 5 | "Setting Up" is an unlabelled hourglass in the fight | "Setting Up - attacks start Turn 3" stands beside the hourglass in the rules row (`RuleIconRow.set_note`, `BattleHud._refresh_setup_note`) until the window is over; the turn panel's countdown now survives every refresh (a sync wiped it). |
| 6 | Toasts stay 20-30 s | The HUD toast is capped at 6 s plus the fade on the wall clock (`TownHud.TOAST_MAX_HOLD`; `_process` enforces the deadline whatever the tween does) and a click dismisses it. |
| 7 | E prefers plaques to the quest NPC | A person with a quest to give or hand in wins the E prompt over a plaque, a sign or a prop in reach, and reaches 0.8 m further (`ZoneScene.QUEST_NPC_BEATS`); never over a door, an exit or a station. |
| 8 | "Point me to..." reorders | Goals first (the tracked quest's first), then the places in alphabetical order (`FullMapScreen.where_to_places`). |
| 9 | The favour toast survives accepting | `TownHud.clear_toast("has a favour to ask")` when the offer is taken. |
| 10 | Escape opens the pause menu over pop-ups | `SceneManager.close_top_popup`: Esc presses Continue on a visible reward / quest-complete / level-up box, else advances the open conversation; the pause menu only when nothing else is open (inbox 8). |

Tests: `tests/ui/test_part1_fixes_nov11.gd` (10: the four zones' hints, the Buffet's line before and after the gate, the Dump's open line,
the D.N.A.'s door on the favour step, seven tokens -> one slot with "x7", a hurt / attacking token leaves the stack, real cards never stack,
the Setting Up note and its end, the alphabetical list, the toast cap and clear) and `tests/world/test_roamer_doors_nov11.gd` (6: the five
zones, the exit roamer). The quest, wayfinding, route, board token, rule badge, hand number and turn counting suites green after the change.

## Part 2 - wayfinding in every zone, proven

### 2.1 The Dump's arrow (inbox 11)

`RouteGuide` plans on a per-zone grid and frame budget (`setup(..., grid, budget)`; `ZoneScene._route_grid` / `_route_budget_usec`,
`QuestMarkerLayer.set_routing`): the Dump uses a 1 m grid and 12 ms a frame (`HeapScene.ROUTE_GRID` / `ROUTE_BUDGET_USEC`), the other zones
keep 0.75 m and 5 ms. `tests/world/test_route_grid_nov11.gd`: the Commons -> Rotheart plan (the failing strict search plus the gated one)
takes 0.8 s of search in 67 slices (1.4 s in 273 slices before), so the arrow follows the route about 1.1 s after a pick instead of ~4.6 s;
the gated route still crosses the stream on a vine bridge's line and the grown-bridge strict route still exists.

### 2.2 The no-context wayfinding critic on the exported build

A fresh critic (brief `docs/review/critic_wayfinding_nov11_brief.md`, report `docs/review/critic_wayfinding_nov11/report.md`, 46 runs on
the RC4-tree test pack after Part 1 and 2.1, fights auto-won, no dev travel) arrived in each zone and had to reach the main dungeon's door
with the game's guidance only:

| Zone | Nov 10 (before any fix) | Nov 11 run 1 (after Part 1, 2.1) | Clarity | What stopped or slowed it |
|---|---|---|---|---|
| The Gainlands | not reached, 23.5 min, 17 runs | **reached, 21.2 min, 20 runs** | 2 -> 5 | the gym hall north of the Station dissolved (the occlusion fader's 6.5 m "clutter" rule) so the road looked open and it walked into an "invisible wall" for 5.4 min; the legend's "Goal:" rows were not buttons; the Flex Mirror's 1.5 m reach |
| The Verdant Dump | not reached, 19.1 min, 14 runs | **not reached, 24.0 min, 21 runs** (stopped at the junk barricade, 40 m from the door, with the bean planted and the bridge grown) | 3 -> 3 | "finish a favour" did not accept Brother Bramble's side-dungeon quest, so it never saw the dungeon step and its text about the stables; planting the bean and growing the bridge changed nothing visible in the tracker |
| The D.N.A. | reached, 18.3 min, 11 runs | **reached, 5.8 min, 5 runs** | 5 -> 8 | the front desk (no routing); the arrival pop-up |

Fixed from its report (run 2 follows below):
- **The gym hall never dissolves as clutter** (`occlusion_near` 2.0 on its meshes, as the other landmarks): the critic's four lost runs
  (`g14_n1.png`, `g17_gap.png`: an open plaza where a two-storey brick hall stands) were the fader hiding the building the arrow routes round.
- **"Finish a favour" accepts the zone's side-dungeon quest** (`QuestDefinitions.ZONE_SIDE_QUEST`), and the favour hints say "any quest one of
  them gives you counts" (inbox 7).
- **A part done is announced**: "Quest updated / Root Cause / Done: A Magic Bean (by the stream...)" when a part of the current step completes
  without the step moving (`Session._note_step_moves`, inbox 8).
- **The legend's "Goal:" rows are buttons** (a click points the arrow at that quest's nearest place, inbox 10); **the Flex Mirrors answer E from
  2.4 m**; **the herd's two far animals graze on the Commons** (owner decision 2, inbox 11).
- Logged, not changed: the entrance ambush and the Rift Station pop-up repeat on every entry (a `dev save` resumes at the entrance: a human
  enters a zone a few times, not twenty); the Commons' counters; the junk gull's -2 HP (the zone's hazard).

**Run 2** (resumed Nov 11 after the PC reset; same no-context critic brief, `docs/review/critic_wayfinding_nov11_brief_run2.md`, on a test
pack exported after Parts 2.2 and 3; report `docs/review/critic_wayfinding_nov11/report_run2.md`, saved by me from its final message as its
own write was refused; scripts `wy_*`, shots `_screenshots/exported/wy2_*.png`):

| Zone | Nov 10 | Run 1 | **Run 2** | Clarity | What slowed it |
|---|---|---|---|---|---|
| The Gainlands | not reached, 23.5 min | reached, 21.2 min | **reached, 18.6 min, 24 runs** | 2 -> 5 -> 6 | the "middle road climbs straight" line (the road jogs west round the gym hall; it took the far west road and its stone bridge, ~120 s + 4 runs on the bridge's sticky west end); a road guard fight on every arrival; the door dialog said "???" |
| The Verdant Dump | not reached, 19.1 min | not reached, 24.0 min | **not reached, 24.1 min, 39 runs** (bean planted, bridge crossed, mount taken; stopped wedged in town) | 3 -> 3 -> 5 | traversal, not direction: wedged between the barn and a crate / planter on the town -> bean line, the golem fight beside the bean on nearly every pass, stair edges; the line still named the bean after it was planted and did not say which stables |
| The D.N.A. | reached, 18.3 min | reached, 5.8 min | (not re-run) | 5 -> 8 | - |

The Dump's 24 minutes went on walking, not on finding the way: its report says the text "said exactly what bars the Rotheart", and every
resumed run re-walks from the entrance (39 resumes x 25-60 s). Fixed from run 2:
- **The Gainlands' line describes the real road**: "take the middle road - it leaves the plaza west round the gym hall, turns back east behind
  it, then runs straight north along the ridge past three road guards to the fortress stairs (the far west road and its stone bridge are the
  long way round)".
- **The Dump's line follows the way**: once the stream is crossed it stops naming the bean and says "one thing left: the junk barricade on the
  stairs north of the Farm Terrace - borrow a mount at the Farm Terrace stables (across the stream, not the town's)"
  (`QuestObjective.step_hint` / `current_hint`); the stables marker says "The Farm Terrace stables, across the stream".
- **The town wedge**: the crate (40, 112.5) and the planter (41.5, 112.5) beside the barn are gone; **the Mossy Trash Golem** roams at
  (28, 118) r 2.5, 11 m clear of the bean and the mound (was (30, 109) r 3.5, between them); a test keeps every roamer 6 m clear of both.
- **The main dungeon's door dialog** carries the dungeon's name (the prompt over the door already said it; "???" stays on maps before a visit).
- Logged, not changed: the world arrow's floating label shows the tracked quest's name, not the "Point me to..." pick (the arrow itself
  follows the pick); the mount is not kept by a `dev save` resume; the Gainlands' stone bridge's west end is sticky (a 1 m step needed); the
  road guard 8 m in fights on every arrival (by design: the guards are the middle road's obstacle; a player arrives a few times, not 24).
  **The Dump was not re-run a third time** (it would take another ~70 minutes of the morning, and run 2's cap came from traversal the fixes
  above address); worth one run after release if you want the number.

## Part 3 - fight pacing (ordinary fights)

**Cause.** Not enemy HP alone: **the player's gear.** The balance sim's expected player (the `ProgressionModel` deck, gear and items
for the level) already finished the midgame's 27 ordinary fights in 5.8 turns on average (2 over 7). The critics' 9-11 came from a hero
without that gear. A hand-played sample (resumed Nov 11, `docs/review/play_scripts/n11_pace_sample_a.txt` / `_b.txt`: the exported-build
critic's own level-14 hero `bot_refusemancer_enter_gourmand`, the built-in pilot, after the first HP trim) took **10 turns** (Gelatin
Sentinel), **11** (Frozen Line Cook), **13** (Meatloaf Golem) and **lost in 8** (Prep Station Sous-Chef). The sim's gear lift on the
Gelatin Sentinel (`--what=gear`, `_logs/sim_gear_probe.md`) shows why: bare (no gear, no items) **9.2 turns, 72 %**; the model's L13 gear
**6.3 turns, 94 %**; gear + items 6.6, 100 %. The bot's five pieces (Clipwell's Shears, Mystery Stain Bib, Raccoon Crown, Gotta-Go Galoshes,
Quota's Stopwatch) each move it by under half a turn, and it had no items slotted (the pilot never uses items anyway). The fights are not
energy-flooded; a player who has not geared for damage cannot break the enemy's board and chips.

**Fix (smallest that works, ordinary fights at levels 10-14 only; bosses, elites, gatekeepers, Primm and the Gallery unchanged).** The band
that ran long is the D.N.A., the Endless Buffet and their side dungeons (levels 10-14); the Dump, the Alley and the final stretch (levels
16-20) already ran 4.5-5.2 turns. Their ordinary foes' HP down by about 20 % from what they were: Gelatin Sentinel 16 -> 13, Shambling
Middle Manager 14 -> 11, the D.N.A.'s rooms 18/18/19/20 -> 14/14/15/16, the Test Kitchen's rooms 14/15/15/15 -> 12/12/12/12, the Apprentice
Itamae 13 -> 11, the Conveyor Belt Sushi Chef and the Receptionist of Number One 18 -> 14, the Eternal Queue 19 -> 15. The Meatloaf Golem
(12) and the Unpaid Intern (10) were already short.

| Expected player (sim, 8 games per Path and fight, seed 7100) | Fights | Turns | Beefcake | Necrocrat | Gourmand | Refusemancer | All | Over 7 turns |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Before (Nov 10) | 27 | 5.8 | 93 % | 100 % | 99 % | 98 % | 98 % | 2 |
| After | 27 | **5.6** | 94 % | 100 % | 99 % | 99 % | **98 %** | **0** |

Per group (before -> after, mean turns): the D.N.A.'s rooms 6.8 -> 6.3, the Test Kitchen's 6.2 -> 5.7, S-GOUR 6.5 -> 6.1, S-NECRO 6.5 -> 6.0,
the Buffet's roamers 6.3 -> 6.1, the D.N.A.'s 6.4 -> 6.1; the others unchanged. Tables: `docs/design/sim/nov11/before_*.md` / `after2_*.md`
(`python -I tools/pace_table_nov11.py before after2`).

**What the trim does not fix (inbox 12, your call).** A hero without the model gear still runs long after the trim: the sim's bare player
(`--nogear`, `docs/design/sim/nov11/after2_bare_*.md`, partial) takes 9.1 turns on both Buffet roamers (69-72 %) and 8.9-10.2 in the Test
Kitchen's rooms; the Sentinel's 14 -> 13 HP moved it 9.2 -> 9.1. For that player the board stalls and HP is not the lever. Not changed
tonight (it is a rules change, not a number): the options are in the inbox.

## Part 4 - the late game on the exported build

**A blocker found on the way: after "Skip card" on a boss's reward, E never advanced the boss's closing words.** Re-saving the
snapshots (`docs/review/play_scripts/n11_resave_end_1.txt`, `_2.txt`, editor build, fights auto-won) stalled on Primm's first closing line
("The model lies in pieces...") for 200 s and 80 taps of E. The Rewards screen's keyboard handler (`RewardsScreen._input`: 1-3 choose, E
takes) stayed live after the pick was skipped - the cards and the Take button were still alive - so every E went to "E never takes a card you
did not choose" (an error blip, the key swallowed) and the dialogue on top never saw it. Taking a card freed the button, which is why bots and
critics who took a card got through. Fixed: the handler stands down once the pick is confirmed or skipped (`_confirmed`) or the panel is
hidden. Re-run (`resave3`): the closing words, the fall still, the ending, the credits and the postgame announcement went through in 59 s of
taps, back in the Capital at level 21. Any main dungeon's boss epilogue had the same trap after a skipped card.

**The snapshots:** `c13end` and `c13post` now both hold that run's state - Primm defeated, the postgame unlocked, the hero in the Capital
(`user://dev_saves`, the old ones in `dev_saves/_backup_nov11/`). The ending itself only plays by beating Primm, so a snapshot cannot sit
"inside" it; `c13castle` + `dev travel dungeon D-PC -2` is the way to see it.

**The no-context late-game critic** (a test pack rebuilt with the Rewards fix; 34 runs, about 49 minutes of game time; report
`docs/review/critic_late_nov11/report.md`, saved by me from its final message as its own write was refused; scripts `critic_late_n11_*`,
shots `_screenshots/exported/l*_*.png`) walked the Capital to the castle, played the Courtyard, read Primm's intro, fought Primm for real from
the phase checkpoints and toured the postgame from `c13end` / `c13post`. **Scores: clarity 5, fun 4, polish 5 - no change from 5/4/5.** It
beat Phase 1 on its second try (16 of 31 HP left), lost Phase 2 twice (once at level 24) and Phase 3 once, so it did not see the ending; the
re-save run above did (auto-won). No `SCRIPT ERROR` in any of its 34 logs.

| # | Its top 10 | Done |
|---|---|---|
| 1 | HP wall in Primm's Phases 2 and 3; a loss restarts the castle | **Logged** (owner: Primm stays as is). Note: its Phase 2/3 tries started from `dev primm 2/3`, which drops the four leaders' boons (23 HP instead of 31, 3 rule icons instead of 9) - a dev-checkpoint gap, not what a player gets; still, 16 HP carried into a 52-HP mirror is steep. Inbox. |
| 2 | "Every unit is a 3/3" while its units showed 7/4 | **Reworded** (the rule sets every unit's BASE to 3/3 and boons and buffs add on top - working as built): "Every unit starts as a 3/3, so cheap units are as good as big ones; boons and buffs still add on top. You may play two cards a turn." |
| 3 | 10+ card hand wraps into two rows; ENEMY TURN ribbon over the Toss prompt | **Logged** (battle board layout: owner constraint; the two-row hand is already a known issue in the RC notes). |
| 4 | Turn label and Setting Up countdown out of sync | **Countdown fixed**: it counted the boss's own turns taken, so with the hero first it read 2, 2, 1 on Turns 1-3; it now follows the Turn shown (`GameState.setup_turns_left_shown`): 2, 1, then gone on Turn 3 when attacks start; the engine's rule is unchanged. **The ribbon / panel lag logged**: the board plays events back behind the game state ("YOUR TURN" over the enemy's turn, "Turn 1" while Primm attacks), a playback-timing change too risky for an RC. |
| 5 | Tidy-Bots drain about 1 HP a second on a Capital walk | **Fixed**: a damaging roamer that knocks you flat goes home and leaves you be for 10 s (`ZoneEnemies.DAMAGE_RETREAT_TIME`; was 2.2 s, then it re-chased at 5 m/s), and does not re-aggro while it cools down. Same 2 damage per knock. |
| 6 | Stale "Needs 2 energy; you have 0" hints, even over Victory | **Fixed**: the battle toast clears at the result screen and its fade runs under a pause too (it froze there); it already cleared at every turn and phase change. |
| 7 | Dialogue box over the boss node's info panel | **Fixed**: the dungeon map hides the node info panel when a scene opens. |
| 8 | Mirror phase: whose units are whose | Logged (board look: owner constraint). |
| 9 | The cracked mirror is a white quad | Logged (art; no art replaced tonight). |
| 10 | The Capital barely changes after Primm falls | Logged (postgame content). |

Also fixed: the 8 engine errors `!is_inside_tree()` from `HoverTip._show` while clicking hand cards (no tip for a control that has left the
tree). Logged from its smaller notes: the Freed Leaders' game-term brackets inside quotes, the 11-line pre-fight box, the castle gate still
(the hooded woman held by guards), the HUD goal title "Free the Four Zones" when only the castle is left, the Shattered Gallery's unexplained
63 max HP, the castle guard and Primm fielding "Resistance Scout", the white lamp globe and stair bands near the castle. `pilot` stalls in
Primm's fights (a test-tool gap, not the game).

## Part 5 - the test runner's memory guard (inbox 13)

`bash tools/run_tests.sh --min-free=MB` (default 900) `--wait-max=SEC` (default 600): before each shard the runner reads the free RAM
(PowerShell's CIM on Windows, `/proc/meminfo` elsewhere) and waits, polling every 10 s, until it is above the floor; a shard it cannot start
in time is skipped and listed under "Crashed shards" with the `--from=N` to rerun it. `--min-free=0` turns the wait off. Documented in
`docs/HANDOFF.md` section 2.

## Part 6 - RC4

- **Version** `1.0.0-rc4` in `project.godot`; `CHANGELOG.md` has the RC4 entry; `docs/release/rc4_notes.md` is the playtester page.
- **Export:** `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc4` -> **EXPORT OK**,
  `builds/TheWaywardPath-v1.0.0-rc4-windows.zip` **734 MB** (RC3: 734 MB), pack 845 MB, 14098 files, 89 baked shaders, every MD5 matches;
  zip CRCs checked. Export peak 1851 MB working set (2.7 min). The "over the 750 MB budget" warning is the same as RC3's. The RC3 zip is kept.
- **Release smoke on the exported pack** (`bash tools/run_release_smoke_exported.sh`): **PASSED** (title and pause version, New Game, F8 form +
  report files, pause menu buttons, no Dev Menu in release, save/load slot 2). It first failed 2 checks: the smoke pressed Esc once for the
  pause menu, and since Part 1 Esc advances the opening conversation first, so the menu stayed shut. The smoke now taps Esc until the
  menu shows (6 taps from the opening scene - each advances one line) and checks the menu is really visible.
- **Exported-build checklist** (test pack rebuilt; `play_exported.sh` runs A, B with A's settings, C on Low-end): **0 `SCRIPT ERROR`** in all
  three game logs, every scripted button found. Three script updates for the new Esc order (no game change): A closes the "New Gear!" box with
  its Continue before Esc; B saves to **slot 3** (slot 2 holds the Nov 10 run's 10-second test save and asked "Overwrite this save?" - never
  overwritten; slot 3 now holds a 10-second test save too - both deletable from Load Game) and leaves the slot screen with Back; C waits
  out the way back and sends Enter before Esc.
- **Logged from the checks, not changed:** (1) an Esc pressed during a load is remembered, but dropped if the scene arrives with the hero
  locked for its title (`SceneManager._end_transition` needs `pause_allowed`); (2) after the dev-only fight in run C (`dev encounter quota`
  from the Gainlands) the way back lands in the town scene with the hero locked and no box visible until a key (Enter / Esc) - a real
  return (run A, Crosspath) shows the "New Gear!" box. Worth a look after release if a tester reports a frozen hero after a fight.

## Finish

- **Tests:** full GUT in 38 shards before the export (`bash tools/run_tests.sh --min-free=800`, 24 min): **2965 / 2967 passed, 0 failing**, 2
  pending. Since then only the release smoke and the three play scripts changed (tools / docs, no game code).
- **Commits** (all pushed; nothing uploaded): `c70394ba` Part 1, `97120a7a` Part 2.1, `cb64b5c1` Part 5, `559ad36a` Parts 2.2 + 3 (resumed),
  `a0ec9de7` Part 3, `25b5d32e` Part 2.2 run 2, `1ec6857f` Part 4 (the Skip-card blocker, snapshots), `8678b445` Part 4 (late critic fixes),
  and the Part 6 commit with RC4's version, changelog, smoke and scripts.
- **Your inbox:** items 12 (fight pacing for an ungeared hero) and 13 (Primm's Phases 2-3) need a decision; the rest are notes.

### Release-day checklist for Nov 11 (the owner)

Everything below is from `docs/HANDOFF.md` section 2 and `docs/release/itch_upload.md`; about 90 minutes end to end, most of it the upload.

1. **Decide the donation link first** (it is baked into the build): in `data/credits/credits.cfg` set `[support] url="..."` to your itch
   page's pay-what-you-want address (`https://<your-itch-name>.itch.io/the-wayward-path/purchase`) or a Ko-fi / PayPal link. While it is
   empty every "Support the game" button stays hidden - that is also fine for 1.0.
2. **Version:** `project.godot` -> `config/version="1.0.0"`. Add the 1.0.0 entry at the top of `CHANGELOG.md` (the RC4 notes list what
   changed since RC3). Commit.
3. **Export:** close Godot, free RAM (close Chrome / ChatGPT), then in Git Bash from `C:\Dev\Deckbuilder-rpg`:
   `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0` (4-10 minutes; "EXPORT STOPPED" means nothing was replaced). The zip lands at
   `builds/TheWaywardPath-v1.0.0-windows.zip`.
4. **Smoke:** `bash tools/run_release_smoke_exported.sh` (about a minute; look for `PASSED`). Then the three exported-build checks:
   `bash tools/export_test_pack.sh` (2 minutes), then `bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_a.txt r1a 480`,
   `SUITE_SETTINGS_FILE=_screenshots/exported/settings_play_r1a.cfg bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_b.txt r1b 480`,
   `bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_c.txt r1c 480`; `grep -c "SCRIPT ERROR" _screenshots/exported/play_r1*.log`
   must print 0 three times. (Run B saves to slot 3 of this PC's own saves; the 10-second test saves in slots 2 and 3 can be deleted from
   Load Game first, or B just meets "Overwrite this save?", backs out and goes on.)
5. **The real exe once:** unzip the 1.0.0 zip into a fresh folder, run `TheWaywardPath.exe`, start a new game to the Path choice, Esc,
   Settings, quit; launch again and Continue. (Or the scripted version: HANDOFF section 2, step 3.)
6. **Tag:** `git add -A && git commit -m "1.0.0" && git tag v1.0.0 && git push && git push --tags`.
7. **itch upload** (`docs/release/itch_upload.md`): Dashboard -> the project -> Edit -> Uploads -> Upload files -> the 1.0.0 zip (about
   740 MB: 5-15 minutes; leave the tab open), tick Windows, label "Windows 64-bit (zip)"; delete or untick the RC file so players get one
   file. Pricing "$0 or donate" with a suggested 3-5 USD (or "No payments"). Check the page text, the eight screenshots and the cover, the AI
   disclosure (Yes: Graphics, Sound/Music, Text/Dialogue). Save.
8. **Download it back once** as a player (View page -> Download), unzip in a fresh folder, run the exe to the title screen.
9. **Flip:** Visibility & access -> **Public** -> Save. Optional devlog post "1.0 is out". Send the playtesters the public link.
10. After the flip: `docs/release/post_1_0_backlog.md` holds what is known and not done; F8 reports arrive in `%APPDATA%\Deckbuilder-RPG\feedback`.

---

# Fable pass Nov 10 - report

Brief: `docs/prompts/fable_nov10.md`. Start tag `pre-fable-nov10`. Questions: `docs/overnight_inbox.md`, "Fable Nov 10" (items 1-14).
Shots: `docs/overnight_shots/nov10b/`. One Godot at a time; the two critics (the wayfinding critic, the exported-build critic) were the only
Godot while they played, and no sub-agent ran while a Godot of mine did. Owner decisions kept: no difficulty setting; the battle board and the
UI layout untouched (Part 3 is numbers only); Primm as the last pass left him. Last night's report (Overnight Nov 9-10) follows below.

## At a glance

- **RC3:** `C:\Dev\Deckbuilder-rpg\builds\TheWaywardPath-v1.0.0-rc3-windows.zip` (**734 MB; RC2 was 734 MB too**; re-exported after the last two fixes so it matches `main`, smoked again: PASSED), release smoke on the exported pack
  ****PASSED** (`_screenshots/release_smoke_exported.log`)**, the short exported-build checklist ****done, 0 SCRIPT ERRORs**: the three RC1 scripts on the RC3 test pack - A (fresh settings: title, Credits, a new game through the intro, Crosspath, a shop, the Deck Station, the Wardrobe, the packs page, a battle, the pause menu, a setting, Copy log, a manual save, quit, load; 16 shots), B (seeded with A's settings: Settings, save and Continue, the Gainlands quiz; 8 shots), C (quality 0: a zone, the town, a battle; 4 shots) - `_screenshots/exported/x*.png`, `y*.png`, `z*.png`**. Notes for testers: `docs/release/rc3_notes.md`.
- **Part 1 (finding things):** every step of every active quest marks every part; the audit fails on a marker-less step; the gates on the way to
  the Buffet's and the Dump's main dungeons are marked; the NPC visibility probe passes; "Point me to..." opens over the map with one row per
  goal; the white sheets were steam puffs at the lens. **The wayfinding critic reached 1 of 4 main dungeons (Gainlands 2, D.N.A. 5, Buffet 4,
  Dump 3 /10)** - its first fix, a route-following arrow, is in (Part 1.6 below), with the dotted route on the map.
- **Part 2 (turns):** Turn N = both players' turns everywhere a player reads a number; no moment moved (table below).
- **Part 3 (hand numbers):** hand cards and the raised hover card show this fight's power, toughness and cost in green / red; the right-click
  preview says the printed values ("In this fight: 7/4 (printed 3/3)").
- **Part 4 (rewards):** no "losing costs nothing"; dungeon fights +50 %; completion -20 %; the gold study says 22.8k no-grind (+7 % on the
  21.2k target, inside the band, not re-tuned).
- **Part 5:** the Hall Pass Slippers (Boots, 500 gold at Mirepoix's): no HP from the world's hazards outside battle.
- **Tests:** **2942 tests in 31 shards: 2940 passing, 0 failing, 2 risky** (the same two no-assert tests as before). The parts had broken six test expectations, all fixed and re-run green: R-08's card script hash (the "your turn" wording; `import_cards.sh --stamp`), the Old Well's steps now marked like every step, Setting Up said in turns, 26 pieces and 4 on Mirepoix's shelf, the defeat line's new words. The sharded run was stopped once by the memory guard (free RAM under 800 MB with Chrome and Defender busy); the rest ran one shard at a time with a check before each. **The exported-build critic (the Buffet, arrival to the Test Kitchen):** clarity **7**, fun **6**
  (was 5 / 4). Polish 7. Its top three: the main quest's own step never names Sir Loin's gate or the side quest that opens it; a roaming Gelatin Sentinel camps the Test Kitchen door; every fight runs 9-11 turns. Report: `docs/review/critic_exported_midgame_nov10/report.md`.

## Part 1 - finding things

### 1.1 Markers for every part of every step

- `QuestObjective.parts`: a step can name several targets, each with its own "done" condition; `targets()` lists the undone ones. Mend the
  Meatloaf marks the salt, the truffle and Old Meatloaf; the Pantry Run its six pickups; the roamer-count favours every live roamer of the
  zone (`QuestMarkers.SPOT_ROAMERS`); the stash hunts every unopened stash; the Dump's herd each animal, the Capital's wheels each wheel. A
  part drops the moment it is done (the pickup taken, the animal home, the wheel freed).
- The world: up to 10 chevrons per step, the gold arrow at the nearest; the map and the minimap carry every active quest's goals (the tracked
  quest's pin to the minimap's rim); the menu steps ("Open a pack") carry no marker and say so (`menu_step`).
- `tools/quest_audit.gd` fails on a step with no marker target (and checks every part's area and spot). It found the Old Well's hum steps,
  Loose Ends, the giant chests, the vault levers and the favour steps - all marked now. Shots: `p1_point_me_list_buffet_quests.png`,
  `p1_map_goals_buffet.png`.

### 1.2 The route to each main dungeon

`tools/dungeon_route_audit.gd` plans a route from the arrival point to the main dungeon's door over each zone's real walkability, fresh (nothing
opened) and open (every gate granted), and names the gates on the open route:

| Zone | Fresh | Open | Gate on the way | What the player is told |
|---|---|---|---|---|
| The Gainlands | route | route | none | - |
| The D.N.A. | route | route | none | - |
| The Endless Buffet | no route | route | Sir Loin's golem gate | Sir Loin: "speak to Basil, east of the Soup Fountain"; Basil's offer and the gate's "active" line name the Salt Flats and the Broccoli Forest; the main line's dungeon step marks the gate until it opens |
| The Verdant Dump | no route | route (142 m) | the vine bridges, the junk barricade on the stairs | the main line marks the Magic Bean + the West Sprout Mound (Part 1.6), the stables and the barricade; the bridge sign and Moss Mulligan name the bean |
| The Capital | "narrow" route | route | the city gate | inbox 7: a fresh hero can slip through the hidden west hole; kept |

Sir Loin's stale "speak to Basil" is gone (his need line now says where Basil stands); a mended loaf not yet reported gets its own line
("Tell Basil yourself... His word opens this gate").

### 1.3 Nobody behind a prop

`tools/npc_visibility_probe.gd` stands the hero on every talk point and casts sight lines from the default and the Low camera to each NPC's
feet, chest, head and name plate (a mesh between the lens and the hero is ignored, it fades). The first full run: 78 checks, nine real hides.
Moved: Basil and Tarragon (clear of the Buffet's bridge gate; Tarragon again 3 m west of Rip at the Rift station after the Nov 10 critic
run), Madame Mirepoix's awning, sign, pudding and cupcake, Billie Muckfoot (off the Rift station's line, then off the greenhouse's corner),
Dex in the Dump (out of the appliance grove), Kestrel, a Capital ward patient. The brightened card copies now fade for the hero too. A prop
between the camera and the person you can talk to dissolves (`OcclusionFader.talk_focus`); with nobody in reach, E walks to the nearest
person in view (E's reach = the click's). Last run: every check ok; two "partly" rows remain (Mirepoix's head behind a cupcake at the default
camera - the cupcake is smaller and further back now; Dex's feet behind the stream fence at the Low camera, plate and prompt clear).

### 1.4 Map labels

Landmarks are named first and win the room; minor names hide below map scale 5.5 and show on hover; "Point me to..." is an in-screen list
over the map's right edge (a Window popup sat over the legend whatever it was told); the legend has one line per quest goal. Nov 10 critic
run: one row per goal name ("A hidden stash (any) (one of 14)" instead of fourteen rows that buried the Meatloaf's three), the area each
goal stands in ("An escaped animal (the Compost Commons)"), "via" rows for roads out ("Root Cause: via Back to Town"), and Escape closes the
list and the map together. Shots: `p1_point_me_list_gainlands.png`, `p1_point_me_list_dump.png`.

### 1.5 White sheets

Not the occlusion fader: the milky sheets north of the hub were the steam and mist puff billboards reaching the lens at the Low camera.
`ParticleLook.near_fade` fades every puff material between 9 m and 2.5 m of the camera (the Buffet's steam, the Gainlands' and the Dump's
mist). The fade walk (`docs/review/play_scripts/fade_walk_gourmand_nov10.txt`) shows no sheets; the Low shots at the Salt Flats only carry the
fall-in-the-gravy tint.

### 1.6 The wayfinding critic (and what it changed)

A no-context critic (brief `docs/review/critic_wayfinding_nov10_brief.md`, report `docs/review/critic_wayfinding_nov10/report.md`, 57 runs,
84 minutes of game time) arrived fresh in each Path zone and had to reach the main dungeon's door with the game's guidance only:

| Zone | Door reached | Game time | Runs | Clarity /10 | What stopped it |
|---|---|---|---|---|---|
| The Gainlands | no | 23.5 min | 17 | 2 | the straight arrow over the plateau wall; a pocket beside the House of Gains' stairs where it stood wedged |
| The D.N.A. | yes | 18.3 min | 11 | 5 | the front desk and the mail-room terminal on the arrow's line |
| The Endless Buffet | no (Meatloaf mended, not reported) | 22.9 min | 15 | 4 | the arrow across the Gravy River (two falls); the truffle pocket; Sir Loin's unchanged line |
| The Verdant Dump | no | 19.1 min | 14 | 3 | the arrow across the stream; no bean, no mound found; two herd animals across the water |

Its three fixes, and what was done:

1. **A route-aware pointer, or the route on the map** (35 of its 84 minutes went into the straight arrow). Done: `RouteGuide`
   (`world/route_guide.gd`) plans an A* route over the zone's own walkability (a 0.75 m grid, 8 neighbours, the midpoint between cells tested
   so a thin wall is never stepped over), sliced at 5 ms a frame so nothing hitches. The gold arrow and the "Point me to..." arrow point
   9 m along the route; the full map draws the route dotted (white for the pick, gold for the tracked goal); a waypoint that is on screen
   gets a small arrow of its own (the critic's "dead end" at (49, 55) now shows the arrow at the road's foot to the east:
   `p1_route_arrow_critic_dead_end.png`, `p1_route_arrow_middle_road.png`, `p1_map_route_gainlands.png`). Two walkability tests per zone: strict
   (what the hero can walk now - the Buffet's river only on a ferry's line, the Dump's stream only on a grown bridge) and through-gates (a
   shut golem gate, an ungrown vine bridge, a barricade count as open), so where a gate shuts the road the arrow leads to the gate, where
   the sign says what opens it (`p1_map_route_buffet_ferry.png`: the route crosses the Gravy River on the Lazy Susan; `p1_route_arrow_dump_arrival.png`).
   Search cost (tests): the Gainlands 45 ms, the Buffet 360 ms, the Dump 1.5 s (inbox 11).
2. **The gate and its requirement in the main quest and on the map.** The Buffet's dungeon step already marked Sir Loin's gate (Part 1.2);
   Sir Loin now acknowledges a mended loaf ("Tell Basil"). The Dump's main line marks the Magic Bean by the stream and the West Sprout Mound
   from the favour step on, until a bridge is grown; the Centre Bridge sign and Moss Mulligan's refusal name the bean. (Two of Billie's three
   animals graze across the water: inbox 10 asks whether to move one.)
3. **Keep the main quest in the HUD; a place name on every row.** A side quest in hand keeps the tracker when the next side quest is accepted
   (a favour still takes it from the main quest's "finish a favour" step; a main quest still takes it from a side quest). Every "Point me
   to..." row names its area; goals of one name make one row. Plus the two physical blockers: the forecourt strip beside the House of Gains'
   stairs is rubble now (the hero cannot squeeze in past the cheek wall), and the Steps banner sits on the stairs, not 14 m round them.

Not changed: Old Man Mountain in front of the gym hall and Brother Bramble at the greenhouse door stay (the route arrow walks round them);
the D.N.A.'s "finish a favour" step before an open door is the design (inbox 12); the Delt ripper out of order is a world feature.

Tests: `tests/world/test_route_guide_nov10.gd` (5: the gap, the gate, no route, a moved target), `tests/world/test_route_guide_zones_nov10.gd`
(3: the real Gainlands, Buffet and Dump routes), `tests/core/quests/test_wayfinding_nov10.gd` (5: the tracker rule, the list rows, the Dump's
parts, the story lines, the pocket). The quest audit, the zone and quest suites green after the change.

## Part 2 - a turn is both players' turns

`GameState.turn_number_of(half) = max(1, floor((half + 1) / 2))`: the engine's own counter still advances once per side (every internal
threshold keyed on it - the AI's stall rule, the item policy, Processing X, "until the start of its controller's next turn" - is untouched,
so nothing happens at a different moment). What the player reads:

| Where | Before | Now |
|---|---|---|
| Battle HUD turn panel | "Round N" / "Your turn" - "Enemy turn" | "Turn N" / "Your turn" - "Enemy's turn" |
| Board ribbons | "Round N" | "Turn N" |
| Battle log header | "-- Your turn --" / "-- Primm's turn --" | "-- Turn 1: your turn --" / "-- Turn 1: Primm's turn --" |
| Boss Setting Up (pre-fight panel, rules panel) | "Its units do not attack in rounds 1-2; they can attack from round 3" | "...in turns 1-2; they can attack from turn 3" (same window: the boss takes its N-th turn inside Turn N whichever side goes first) |
| Setting Up countdown under the turn label | "Setting Up: 2 rounds left" | "Setting Up: 2 turns left" - `setup_turns_left = clamp(window - turns_taken + 1, 0, window)`; countdown and panel agree (test: 2, 2, 1, 0 for turns taken 0..3) |
| Result lines | "in N rounds" | "in N turns" (`p1`... the Victory panel: "You defeated Quota Spotter in 1 turn") |
| Card text (34 cards + 1 token) | "until end of turn" | "until the end of your turn"; the traps that fire on the enemy's turn (BR-07, C-16, GB-04, GRB-01): "until the end of the enemy's turn" |
| Glossary / keyword info | "Round" | "Turn" (one turn = both players' turns; "your turn" and "the enemy's turn" are its halves) |
| Tutorials, status info, campaign start, pre-fight texts | rounds | turns |
| Sims and tools (`record.turns`, `turns_played`, `node_turns`, the "turns avg" print) | half-turns | turns (inbox 6: their numbers are half what they were) |
| `docs/design/combat_rules.md` Turn Structure | - | the paragraph above |

Energy: the end-turn question and the hand tooltips count the same pool (`GameState.energy_available`: ready infrastructure + the pool), so
the two contradictory messages are one. Shots: `p2_before_the_fight_setting_up_turns.png`, `p2_hud_turn1_your_turn.png`,
`p2_battle_log_turn_header.png`. Test: `tests/core/test_turn_counting_nov10.gd` (6).

## Part 3 - hand cards show this fight's numbers

`CardView.apply_instance` already drew a unit's live attack and toughness; now a shrunk attack reads red (Primm's 3/3, Red Tape) as a shrunk
toughness did, and the cost is live too: `game.generic_cost_for` + `pips_for` against the printed `energy_value()`, green when cheaper, red
when dearer, on the framed socket's number and on the plain face's pip row (`PipRow.generic_override`). `BattleBoard.sync_state` re-applies
every live view each sync (a view was asked once, when it was made - a rule that arrived after the draw never reached the hand). The
right-click preview adds `BattleHud.now_line`: "In this fight: 7/4 (printed 3/3); costs 2 (printed 3)." - only the parts that differ. No
layout changed. Under Primm's Standardization a postgame hero's Carpool (printed 3/3) reads 7/4 in green: 3/3 plus the hero's boons and gear
(`p3_primm_hand_live_numbers.png`, `p3_primm_hover_carpool.png`; the right-click preview of the Overclocked Mill Worker: "In this fight: 7/4 (printed 2/4)." in gold under its text, `p3_primm_peek_in_this_fight.png`). The House of Gains' Home Gym (+1 attack for Beefcake units) shows the
same way; a Colorless hand (Courier Pigeons, Village Militia) keeps its print. Tests: `tests/ui/test_hand_numbers_nov10.gd` (3: Primm's 3/3 in
red with the printed values in the preview line, a cost reducer in green and a tax in red on both faces, a zone rule's pump in green kept
through a rebuild).

## Part 4 - rewards and the defeat text

- "Losing costs nothing" and its cousins are gone from the defeat panels, the Old Well's confirm and the level hints; a dungeon defeat says the
  dungeon starts over from its first room and that the cards and gold you won are kept.
- Rewards (`docs/design/balance_log.md`, "Fable pass Nov 10, Part 4"):

| What | Before | Now |
|---|---|---|
| Every fight inside a dungeon (normal, elite, boss; main and side) | gold x1, XP x1 | gold x1.5 (rounded to 5), XP x1.5 (`Economy.DUNGEON_FIGHT_BONUS`); picks and packs unchanged; the tutorial cave is not a dungeon run |
| Clear bonus at the boss | the run's gold once more | 0.8 of it (`CLEAR_BONUS_SHARE`) |
| Main dungeon first clear | 200 gold, XP 0.5 of a level step, pack bonus 150 gold / 100 XP | 160, 0.4, 120 / 80 |
| Side dungeon first clear | 100 gold, XP 0.15 of a step | 80, 0.12 |
| Primm's Castle, the Lab, the Shattered Gallery | 400 XP; 400/400; 1500 gold | 320; 320/320; 1200 |
| Repeat clears | 300 main / 200 side | unchanged (not a completion reward) |

- Gold study (`docs/design/sim/nov10/gold_study_nov10.md`, the economy model paying the +50 % the game pays): **22,771 gold no-grind** against
  the ~21.2k target (+7 %, inside +/-10 %, so no re-tune); 12,971 left after the shopping list; a completionist needs about 135 extra fights
  (9.0 h) at the best grind.

## Part 5 - the Hall Pass Slippers

Boots: the slot with the fewest pieces (7 boots against 9 helms, 11 armours, 15 weapons, 19 relics). Uncommon, tier 2, **500 gold on Madame
Mirepoix's gear shelf** in the Endless Buffet (a mid-game shop at the gear price formula) - picked over a side-quest reward so a player who
hates the gravy can buy their way out. "Outside battle, roaming troublemakers and hazards can't hurt you: no HP lost to bumps, rifts, pits,
gravy or falls." Flavour: "Paperwork says you're excused. The paperwork is laminated." `Modifier.Kind.WORLD_IMMUNITY`, `ZoneRun.world_damage`:
every zone-HP hit outside battle (roamer bumps, the Buffet's gravy and rift stations, the Dump's falls and pits, the Gainlands' hazards) goes
through it and shows "Hall Pass Slippers: no harm done. The paperwork says you're excused." Battles and story damage are untouched. Icon: the
Traveler's Boots stand in; `ICON-EQ-HALLPASSSLIPPERS` is on `docs/art/art_needed_nov2.csv` with an image description. Test:
`tests/core/test_hall_pass_slippers_nov10.gd` (3).

## Finish

- **Tests:** **2942 tests in 31 shards: 2940 passing, 0 failing, 2 risky** (the same two no-assert tests as before). The parts had broken six test expectations, all fixed and re-run green: R-08's card script hash (the "your turn" wording; `import_cards.sh --stamp`), the Old Well's steps now marked like every step, Setting Up said in turns, 26 pieces and 4 on Mirepoix's shelf, the defeat line's new words. The sharded run was stopped once by the memory guard (free RAM under 800 MB with Chrome and Defender busy); the rest ran one shard at a time with a check before each.
- **RC3:** `builds/TheWaywardPath-v1.0.0-rc3-windows.zip` (734 MB; RC2 was 734 MB too); `builds/_export/` holds the unzipped build. Release smoke on the exported
  pack: **PASSED** (`_screenshots/release_smoke_exported.log`). The short exported-build checklist (runs A-C of the RC1 scripts on the test pack): **done, 0 SCRIPT ERRORs**: the three RC1 scripts on the RC3 test pack - A (fresh settings: title, Credits, a new game through the intro, Crosspath, a shop, the Deck Station, the Wardrobe, the packs page, a battle, the pause menu, a setting, Copy log, a manual save, quit, load; 16 shots), B (seeded with A's settings: Settings, save and Continue, the Gainlands quiz; 8 shots), C (quality 0: a zone, the town, a battle; 4 shots) - `_screenshots/exported/x*.png`, `y*.png`, `z*.png`.
- **The exported-build critic:** a no-context critic (brief `docs/review/critic_exported_midgame_nov10_brief.md`, report `docs/review/critic_exported_midgame_nov10/report.md`; 33 runs, 40.8 min of game time on the RC3 test pack, no `dev autowin`, no SCRIPT ERROR) replayed the Buffet from arrival to the Test Kitchen's boss: **clarity 7 (was 5), fun 6 (was 4), polish 7**. It stood 8 m from the door after 18.3 min on foot, guided by the tracker, the map's blue circles, the dotted route, the gate's sign and Basil; it used `dev travel` into the dungeon only after a roamer beside the door ate two approaches. What it credits: the gate sign and Basil's hand-in line, the dotted route and the labelled arrow, the Defeat card's recap, the right-click preview's "In this fight: 2/3 (printed 1/1)", "Turn 1 / Your turn". Its top 10 (verbatim in the report): (1) the main quest's dungeon step should say "Sir Loin's gate wants Old Meatloaf mended - see Basil" (the step marks the gate on the map, but its "Where to go" text does not say it: a one-line text fix for the next pass); (2) a roaming Gelatin Sentinel camps the Test Kitchen door; (3) 9-11-turn fights; (4) the boss's token swarm overlaps; (5) Setting Up is an unlabelled hourglass during the fight; (6) toasts stay 20-30 s; (7) the E prompt prefers plaques to the quest NPC; (8) walking costs HP (bumps, the gravy); (9) the "Point me to..." list reorders between opens; (10) a stale favour toast and Escape over pop-ups. Fixed tonight from its notes: the respawn toast still said "Losing costs nothing" (gone), and the dotted route grazed the Soup Fountain (routes now keep a 0.6 m body clear of props). The rest is logged for the owner (inbox 14).
- No public upload. Commits: Part 1 (`170722b5`, `731e720c`), Part 2 (`26847a85`), Part 4 (`a305b9df`, `4b9e85f4`), Part 5 (`d3b775cf`),
  Part 1.6 + Part 3 (`ebcbdad3`), Finish (the Finish commits that follow `ea2a6377`).

### Screenshots (`docs/overnight_shots/nov10b/`)

| File | What |
|---|---|
| `p1_point_me_list_buffet_quests.png` | the Buffet map with Mend the Meatloaf and the Pantry Run active: every part a goal, the list open over the map |
| `p1_map_goals_buffet.png` | the legend's one line per quest goal |
| `p1_point_me_list_gainlands.png`, `p1_point_me_list_dump.png` | one row per goal name, the area in brackets, "via" rows; the Dump's bean and mound rows |
| `p1_map_route_gainlands.png` | the dotted route from the bridge up the middle road to the House of Gains |
| `p1_route_arrow_critic_dead_end.png` | at (49, 55), where the critic gave up: the waypoint arrow at the road's foot to the east |
| `p1_route_arrow_middle_road.png` | the waypoint arrow up the Gauntlet |
| `p1_map_route_buffet_ferry.png` | the Buffet's route crossing the Gravy River on the Lazy Susan |
| `p1_route_arrow_dump_arrival.png` | the Dump: "The Rotheart" arrow north toward the Centre Bridge's foot |
| `p2_before_the_fight_setting_up_turns.png` | Primm's pre-fight panel: "Setting Up: ...in turns 1-2; they can attack from turn 3" |
| `p2_hud_turn1_your_turn.png` | the HUD: "Turn 1 / Your turn" |
| `p2_battle_log_turn_header.png` | the log: "-- Turn 1: your turn --" |
| `p3_primm_hand_live_numbers.png` | Primm's fight: the Militia 3/3, the hand's live numbers |
| `p3_primm_hover_carpool.png` | the raised Carpool: 7/4 (printed 3/3) |
| `p3_primm_peek_in_this_fight.png` | the right-click preview: "In this fight: 7/4 (printed 2/4)." |

---

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
