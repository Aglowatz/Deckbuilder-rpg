# Overnight report (Oct 17-18)

Run: Sat Oct 17 20:52 MDT to Sun Oct 18 ~06:35 MDT (the end target was 07:52; the last 75 minutes went to final checks and this report). Start tag `pre-overnight-oct17`
(494fc066), all work on `main`, every part and cycle pushed. Phase 1 = the brief's 14 parts; Phase 2 = 26 improvement cycles, each aimed at the
lowest-scoring category of `docs/overnight/scorecard.md`. Your decisions are in `docs/overnight_inbox.md` (15 short items) and
`docs/design/open_questions.md` (ON17-*). The previous report is now `docs/overnight_report_oct16.md`.

**State at the end:** GUT 1816/1817 (the one failure is the pre-existing CP-2 camera test, `tests/world/test_world_look_rig.gd:94`). The story
playthrough bot goes new game -> ending at 73/73. The full tour bot (06:20) covers 275 spots, 9 menus and 5 battles with 0 errors; battles have no frame over 33 ms. The dungeons,
first-battles, music and Crosspath walk smokes all pass. Build estimate ~507 MB (+17 MB tonight: card thumbnails and stings).

## Scorecard: start of Phase 2 vs end

| Category | Start | End | What moved it |
|---|---|---|---|
| Combat feel | 7 | 8 | Played cards fly on a curve (C8); attacks wind up, lean in and settle; damage numbers scale with the blow (C19) |
| Visuals - starting forest | 6 | 7.5 | The forest floor was 88% see-through (an occlusion-fade bug) - fixed (C3). Purple top-edge shapes still open |
| Visuals - Crosspath | 8 | 8 | - |
| Visuals - Gainlands | 8 | 8 | - |
| Visuals - D.N.A. | 7 | 7.5 | Paperwork drifts over the bare ground round the offices (C18) |
| Visuals - Endless Buffet | 7 | 7.5 | Peas, carrot coins, croutons and fat sheens float in the gravy moat (C12) |
| Visuals - Verdant Dump | 7 | 7.5 | The entrance pool is an oval pond, not a hard-edged rectangle (C7) |
| Visuals - Capital | 8 | 8 | - |
| UI consistency | 6 | 8 | Character spare frames, gold display, close buttons, bubbles, quest hint, HUD key line, chips, world map; maps show roads and buildings (C4, C6, C7, C17, C24) |
| Onboarding / tutorial | 7 | 7.5 | Narration without an empty name tab; dungeon maps fill their side bands (C11) |
| Rewards & progression | 8 | 8.5 | Several levels at once readable on one page (C22) |
| Collection / bestiary | 7 | 7.5 | Bestiary and battle plate ready for enemy pictures, 90 prompts written (C15) |
| NPC life & dialogue | 6 | 8 | Three town strollers (C2, C23); freed leaders and Captain Spotless speak (C16) |
| Audio mix | 7 | 7.5 | Music bus leveller for the 26 very dynamic tracks (C10) |
| Performance | 6 | 8.5 | Worst town frame 1.16 s -> 139 ms town-only / ~220 ms in a full tour; re-opening screens 4-7x faster; town frames over 33 ms 75 -> ~30 (C1, C5, C14, C20, C25) |
| Stability | 7 | 8 | Story bot back to 73/73 (C9), dungeons smoke green (C13), every check passing at the end |

## Phase 1 - the brief's parts

| Part | Commit | What it does |
|---|---|---|
| 1 Copy limits | b1422990 | Max 3 copies; rarer cards start lower (C3 / U2 / Epic 1 / L1) and level-ups raise them. Extras convert to Path essence. One cap rules the collection, shops, packs and decks (`data/progression/level_track.json`) |
| 2 Vendor categories | 89a5f3d5 | A vendor with several categories (cards, packs, gear) opens on a picker; Back (Esc) returns to it |
| 3 Chest sparkle | 07bf48d7 | Unopened chests glint when the hero is within 3 m (one small additive mesh, no shadow, hidden far away) |
| 4 Deck Station | 73ecd924 | Ten fixed deck slots (4 open, +2 at levels 7/14/21), cover cards, save picker, "In use" badge |
| 5 Armory + rarity | 677e502f | Beetsworth closed before level 5; level 5 starts "Some Assembly Required" -> win a duel -> Starter Blade. Gear rarity and equip caps |
| Patchwork | dd8114cb | The kingdom is Patchwork (throne keeps "Pathwork Throne", inbox 3) |
| 6 Reward track 1-30 | 5606d094 | Every level gives something, all from one data file; `docs/design/level_rewards.md` |
| 7 Level-up moments | 91299003 | Full-screen level-up (number punch, headline, rewards revealed one by one, unlock boxes); "NEW GEAR!" reveal; Epic pack build-up |
| 8 Combat feel 2.0 | 7efcf1e9 | Hit pause, recoil, scaled shake, BLOCKED, turn banners, slow-motion final blow (no intent shown, no numbers changed) |
| 9 Tutorial | 9afffb94 | Resources taught by doing in battle 1 (made -> spend -> why) and battle 2; "Make It Yours" first deck edit quest |
| 10 Collection Book | 24fcbc03 | Cards by Path and rarity with completion, filters, sort, zoom; Bestiary of 90 entries with milestones |
| 11 NPC life + truth | 7bbf1707 | Passing lines for 44 NPCs; one NPC source of truth (npcs.json, npc_registry.csv, image requests) |
| 12 Music | 2cd73ca9 | Audit of 136 tracks, 35 loops fixed, per-track gain, boss-win stings, music brief |
| 13 UI + controller | 9c73af57 | One input path (UiInput), focus ring everywhere, same open fade, tour bot |
| 14 Ambient fx | 3de8b565 | Light per-area particles (dust, steam, ghost motes, gnats, ash, fluff) and footstep puffs |

## Phase 2 - cycles (one line each; details in `docs/overnight/loop_log.md`)

| # | Category | Commit | Change |
|---|---|---|---|
| 1 | Performance | aac36d53 | Card art thumbnails for grids; cheaper card views (cached rules fit/text, one shared gradient) |
| 2 | NPC life | 674cf18c | Two townsfolk stroll the well yard and Maren's lane, with lines |
| 3 | Starting forest | 2ad2e07f | The "purple floor" was the 900 m floor fading with a blocking prop's group; wide terrain never fades now |
| 4 | UI | 6f145b69 | Character spare frames show level / Path / deck; focus ring on gear slots; Alchemist gold + live copy-cap text; readable Quest Log hint |
| 5 | Performance | 73ac88d1 | Bot measures by wall clock (delta was clamped at ~148 ms); cached art lookups (card view 2.4x cheaper); tiles built over frames; menu art warmed on a thread |
| 6 | UI | 98f11f5c | No text over the round close button; header air; readable Collection counter; padded vendor bubbles |
| 7 | Zones + HUD | 2b34f210 | HUD key line and zone chip no longer clipped; the Dump's pool is an oval pond |
| 8 | Combat feel | 1226b1eb | Played cards fly to the middle on a curve |
| 9 | Stability | 5d09a1ea | Story bot learned the multi-level "Next level" screen: 73/73 again |
| 10 | Audio | 71dcd12c | Music bus leveller (measured offline: loudness unchanged, range e.g. 18.2 -> 12.8 LU) |
| 11 | Onboarding | b8ef1a2c | Narration panel without the empty tab; dungeon map side bands show the painting |
| 12 | Buffet | ed12704d | Things float in the gravy moat |
| 13 | Stability | 25396cf0 | Dungeons smoke checks the Swolympus gate (was stale since Gainlands v2) |
| 14 | Performance | 3ceaba56 | Collection Book builds its Bestiary page on first view (226 -> 49 ms); fixed "Infrastructure attack your spells" tip text |
| 15 | Collection | 1ff67098 | Enemy pictures picked up from `assets/art/bestiary/`; 90 prompts in `docs/art/bestiary_image_requests.md` |
| 16 | NPC life | e20f887c | Freed leaders, reformed Escoffina, Primm "at work" and Captain Spotless say passing lines |
| 17 | UI | aa98ec74 | World map without dead dark strips |
| 18 | D.N.A. | 0a039588 | Paperwork drifting over the bare ground (never over rooms or the causeway) |
| 19 | Combat feel | 1ded6343 | Attack wind-up and settle; damage numbers sized by the blow |
| 20 | Performance | 313b20d7 | Owned-card thumbnails and card drawing warmed before the first grid opens |
| 21 | Starting forest | 84c87aca | Investigated the purple top-edge shapes; three sources ruled out; no change kept |
| 22 | Rewards | 1313d5fb | "All N levels on one page" when several levels arrive at once |
| 23 | NPC life | d7329ab6 | A third town stroller by the Arena gate |
| 24 | UI (map) | 5ddf9fc8 | Minimap and world map show roads and building footprints (sorted a few rows per frame, cached per area; full map build 30-68 -> 8-18 ms) |
| 25 | Performance | d9b5f799 | Profiled the first Deck Station open; Deck Station and card vendor build 4 cards on the opening frame (town worst 139 ms, 30 frames over 33 ms) |
| 26 | Starting forest | 5790868b | Second look at the purple top shapes: two more sources ruled out; nothing kept |

## Screenshots to look at (local, `_screenshots/`, not in git)

- `on17_forest_spawn.png` vs `on17_forest_fixed.png` - the starting forest before / after the floor fix (cycle 3).
- `on17_ui_character.png` vs `on17_ui2_character.png` - Character screen spare frames (cycle 4).
- `on17_ui5_vendor.png` vs `on17_ui6_vendor.png` - text over the close button, fixed (cycle 6).
- `on17_zone_heap.png` vs `on17_zone_heap3.png` - the Dump's entrance pool (cycle 7).
- `on17_zone_buffet.png` vs `on17_zone_buffet2.png` - the gravy moat (cycle 12).
- `on17_dna_breakroom_center.png` vs `on17_dna3_breakroom.png`, and `on17_dna4_lobby.png` - D.N.A. paperwork (cycle 18).
- `stills/STORY-WAKE_1280x720.png` - narration panel without the tab (cycle 11).
- `dungeons/t_01_trial_map_start.png` - dungeon map side bands (cycle 11).
- `on17_ui7_map.png` vs `on17_ui8_map.png` vs `on17_ui9_map.png` - world map: no dead strips (cycle 17), then roads and buildings (cycle 24).
- `on17_bestiary_art.png` - a stand-in picture in the Bestiary (cycle 15; the stand-in file was removed).

## How to test the big items

- **Copy caps, Deck Box, Collection Book**: new game -> town -> Deck Station (opens on the Deck Box, 4 of 10 slots open) -> the card grid shows `Deck x/3 Own y`. Buy a 4th copy at Sable's: it turns into essence. Hall of Records = Collection Book (Cards / Bestiary tabs).
- **Vendor picker**: talk to Sable (cards + packs): picker first, Back (Esc) returns to it.
- **Armory quest**: reach level 5 (`bash tools/shot.sh res://scenes/town.tscn x --levelup=5` shows the moment), talk to Beetsworth, win any duel, collect the Starter Blade.
- **Level-up moments**: any level-up. Several at once (free a zone): "All N levels on one page".
- **Combat feel**: any duel. Watch the card curve, the attack wind-up, numbers sized by damage, hit pause and the slow-motion final blow.
- **Tutorial**: new game -> the first two cave battles teach Resources step by step; town -> quest "Make It Yours".
- **NPC lines**: walk past townsfolk; free a zone and walk past its leader at the hub.
- **Music leveller**: an arena battle or the credits; `AudioMix.MUSIC_LEVELLER = false` to compare.
- **Maps**: press M in town after walking around: roads and buildings appear within a second or two of arriving.
- **Bots and smokes**: `bash tools/run_story_playthrough.sh` (73 steps), `bash tools/run_tour_bot.sh` (~9 min, writes `docs/overnight/bot_report.md`; `TOUR_ONLY=town` for a quick run), `bash tools/run_dungeons_final_smoke.sh`, `bash tools/run_first_battles_smoke.sh`, `bash tools/run_music_smoke.sh`, `bash tools/run_crosspath_walk_smoke.sh`.

## Reverted or left off, and why

- **Building card grids over frames** (cycle 1): it made more 35-45 ms frames while card views cost ~10 ms. It was turned back on in cycle 5, once card views were 2.4x cheaper.
- **Cycles 21 and 26**: test changes for the starting forest's purple top-edge shapes (look-rig cloud tint/opacity, style-preset clouds, kit mountain scale, the two small cloud models). None changed the picture, so all were reverted. The sky panorama and the post shader were ruled out by reading them. What to check next is in next_up 2.
- **Cycle 25 hiccup**: a backup copy of a script left in `_logs/` duplicated its class name and failed GUT's compile check for one run. It was deleted, GUT re-run clean, and the bot numbers re-measured on the clean tree.
- **Town stroller at the rift station** (cycle 23): its loop crossed an unwalkable edge, so it was left out.
- **Music leveller order**: first placed after the duck amplifier, which would halve duck depth. Moved before it before committing.
- Nothing else was reverted. No balance numbers, enemy intent, chapters, walkable dungeons, papercraft/ornate frames, free camera or 3D text were added.

## Top 10 next (from `docs/overnight/next_up.md`)

1. First opens of big screens: the first Deck Station open is ~140 ms town-only and ~220 ms in a full tour. Its deck list (20 ms cold) and filter bar (17 ms) are next.
2. The purple "stalactites" at the top of the starting-forest view. Six sources are ruled out; check the StyleRig sky against WorldSky next.
3. Make the 90 enemy pictures (`docs/art/bestiary_image_requests.md`); the game picks them up.
4. Time the first 30 minutes with a real-input onboarding bot (the story bot shortcuts the prologue).
5. Zone maps: mark water separately (roads and buildings are done, cycle 24; water still reads as off-map dark).
6. Listen pass: the Music leveller, boss-win stings, MUS-SHOP-GRISTLE's -7.2 dB loop step.
7. One shared tile style for choice tiles; three pause-menu icons for the next art request.
8. Strolling townsfolk in the zone hubs.
9. A combat feel pass in a real arena duel at each battle speed.
10. Floating 3D exit labels in the zones vs the no-world-text rule (inbox 12).
