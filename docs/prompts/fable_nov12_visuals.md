# Fable 24-hour pass (Nov 11-12): visual quality, world consistency, late-game design

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). RC4 is built and green. The owner releases 1.0 by hand in a few days on a
smaller plan, so this is the last long pass. **Goal: the game looks and feels like one deliberate, premium-quality world**: consistent
art direction, lighting, materials, scale and motion. The late game should play as well as the midgame.

Read first:
- docs/overnight_report.md (Overnight Nov 10-11);
- docs/overnight_inbox.md (items 12-13 of "Overnight Nov 10-11");
- docs/review/ (the late-game and wayfinding critics);
- docs/art/ (the art lists);
- docs/build_size_policy.md.

Work autonomously and in priority order. Log questions in docs/overnight_inbox.md under "Fable Nov 12". Tag `pre-fable-nov12` at the start.

## House rules
- STOP_OVERNIGHT check before each part.
- Memory:
  - ONE Godot at a time; kill strays first;
  - no sub-agents while Godot runs;
  - use `tools/run_tests.sh --min-free=900`;
  - stop a job cleanly if free memory drops under ~800 MB.
- Screenshots go to docs/overnight_shots/nov12/. **Every visual change gets a before/after pair from the same camera.**
- Commit and push after each part (and at least every 2 hours) so a PC reset loses little. No public upload.
- **Owner constraints:**
  - No difficulty setting.
  - **No battle-board or UI layout changes.** Effects, animation, lighting, shaders and colour inside existing elements are fine.
  - Approved painted art (portraits, cards, stills, icons) is not repainted or replaced. Materials, shaders, lighting, 3D props, terrain,
    procedural textures and post-processing are all in scope.
  - **Performance:**
    - Medium must hold 60 FPS in Crosspath, the Capital and a battle on this PC;
    - Low-end mode keeps its numbers (every new effect has a Low fallback or turns off);
    - the export zip may grow at most ~10% (about 800 MB).

## Owner decisions
- **Inbox 12 (bare-hero fights):** no change. Accept it.
- **Inbox 13 (Primm's Phases 2-3):** no change to Primm or his defeat flow. Only the dev fix: `dev primm N` grants the four boons like a real run.
- **Escape in a conversation** advancing one line: keep.
- **Max hand size 10** (Part 4.0).

## Part 0 — Art-direction audit and style bible (about 1.5 h)
1. Capture a fixed shot set:
   - every zone: arrival, hub, main dungeon door, two mid-zone views, at the default and Low cameras;
   - the Capital before and after Primm;
   - every dungeon's rooms;
   - a battle in each Path's backdrop;
   - the title, the map, the shops, the Deck Station, the Wardrobe, the credits.
2. **Art-director critic** (a fresh no-context critic; screenshots only, no code). It scores each shot 1-10 on:
   - style consistency, lighting, materials, scale, composition and readability;
   - the jarring things: flat untextured surfaces, white walls, low-poly blocks next to painted art, mismatched outlines or saturation,
     floating or clipping props, tiling seams, sprites lit differently from the world.

   It writes the top 25 problems, ranked by how much a player notices them.
3. Write **docs/art/style_bible.md**, drawn from the best-looking existing shots:
   - palette per zone;
   - the lighting model;
   - the material rules (no pure-white or untextured surfaces);
   - outline and edge treatment;
   - character-to-prop scale (door height, NPC height, counter height);
   - foliage and ground rules;
   - the VFX look.

   Every later part follows it.

## Part 1 — Lighting, atmosphere and colour (the biggest visible win)
Per zone, following the style bible:
- a deliberate WorldEnvironment:
  - tonemapping and exposure;
  - SSAO, plus SSIL or SDFGI where cheap;
  - soft shadows tuned so nothing floats;
  - height/depth fog for depth;
  - a sky or backdrop matching the zone's palette;
  - one colour grade per zone (an adjustment or LUT);
  - gentle bloom on light sources only.
- Light sources where the art implies them: lamps, windows, forges, glowing pickups. Use a few warm/cool accents per area, not a flat
  sun-only look.
- Characters get contact shadows (blob or projected) and are lit to match the world, so sprites sit **in** the scene, not on top of it.
- Make sure transitions between areas and indoor/outdoor carry the grade change smoothly.
- Every setting gets a Medium and a Low variant. Measure FPS before and after.

## Part 2 — World consistency and dressing
Fix the art-director critic's top 25 in order, starting with the known ones:
1. **The Gainlands' low-poly look:**
   - bevel or smooth the blocky meshes;
   - give terrain blended ground textures (grass/dirt/rock with edge breakup, no hard seams);
   - add grass and foliage clumps along edges.
2. **The Capital's outer white wall** and any other pure-white or untextured surface in the game. Find them all with a material scan:
   - give them stone, plaster or brick materials with trim, weathering and grime at the base.
3. **The Capital after Primm doesn't change:** after `primm_defeated`, the Capital visibly celebrates.
   - banners swapped, bunting, crowd NPCs, lighting warmer, a few changed barks;
   - use existing assets and shaders, no new paintings.
4. **The scale audit:** doors, stairs, counters, benches and NPCs follow the style bible's ratios in every zone. Fix outliers.
5. **Edges and props:**
   - no floating, clipping or half-sunk props;
   - zone boundaries read as natural edges (cliffs, hedges, water, fences), not invisible walls or void;
   - add a check for props below or above the ground.
6. **Ground clutter and storytelling:** each hub gets small, meaningful dressing that fits its Path's theme (decals, debris, signs,
   market goods), so areas look lived-in and distinct.
7. **The logged leftovers:**
   - the cracked-mirror quad in Primm's fight;
   - the "milky" fades (check that none remain);
   - Old Hob's stuck portrait;
   - the entrance ambush and the Rift Station pop-up repeating on every entry (show once per visit, or once ever, whichever fits).

## Part 3 — Motion and game feel (no layout changes)
- **Battles:**
  - card play: lift, travel, slam onto the board;
  - attack lunge, a hit flash and 2-3 frames of hit-stop on big hits;
  - small screen shake, with a Settings toggle that defaults on and is off in reduced-motion;
  - damage and heal numbers that pop and drift;
  - death dissolve;
  - a buff shimmer when a stat changes;
  - a turn-change sweep;
  - a victory flourish.

  Each one is short and skippable by the existing fast-forward.
- **World:**
  - character idle bob and squash on landing;
  - dust puffs from footsteps on dirt;
  - pickups that glow and bob;
  - doors and chests that animate open;
  - ambient life per zone (birds, steam, drifting leaves, flies at the Dump, sparkles in the Gallery).
- **UI:**
  - button hover and press easing;
  - screen transitions (a fade or wipe in the zone's colour);
  - reward reveal sequencing;
  - consistent sound on every click and confirm. Use the existing SFX; log any that are missing.

## Part 4 — Late-game design (the late-game critic gave 5/4/5)
1. Apply the owner decisions (inbox 12 and 13 above).
2. The late critic's logged items, within the constraints:
   - the turn-ribbon lag;
   - who owns the mirror phase (clearer rule text and a visual tell);
   - the Primm build-up: castle rooms escalate in look and music; the throne room's lighting and VFX should feel like a finale.
3. **The ending and credits:** paced presentation.
   - stills with slow pan/zoom (Ken Burns);
   - music swells timed to the story beats;
   - a crossfade to the credits;
   - a short "thanks for playing" card that points to the postgame (the Lab, the Gallery).
4. A fresh no-context late-game critic replays the Capital → Primm → ending → postgame on the exported build. Target: clarity 7, fun 6,
   polish 7. Fix the S/M items and re-score.

## Part 5 — The art gap list for the owner's next ChatGPT batch
Claude can't paint. Write **docs/art/batch15_nov12.csv** (the same columns as earlier batches) with the 20-30 painted images that would raise
quality most, ranked:
- anything the art-director critic flagged that only new painting can fix;
- REDOs from post_1_0_backlog;
- ICON-EQ-HALLPASSSLIPPERS;
- the ending and credits stills, if any are thin;
- Dex's matching-game table and card back, if still missing.

Each row has a full image description in the house style and the target path.

## Part 6 — Verify and build RC5
1. **Before/after:** the art-director critic re-scores the same Part 0 shot set. Add a side-by-side gallery at docs/review/visual_nov12/index.html.
2. **Performance:** FPS and memory on Medium and Low in Crosspath, the Capital, the Buffet hub and a boss battle, before and after.
3. All test shards green. Add tests for the Primm phase restart, the gear offer order, the Capital post-Primm state and the prop-ground check.
4. Export **1.0.0-rc5**; the release smoke and the three exported checks must show 0 SCRIPT ERROR. Write docs/release/rc5_notes.md.
5. **docs/overnight_report.md**, with at the top:
   - the art-director scores before and after;
   - the top 25 and what was done;
   - the lighting changes per zone;
   - the motion list;
   - the late-game critic's re-score;
   - the performance and size numbers;
   - where RC5 is;
   - the Batch 15 list;
   - a short updated release-day checklist.
6. Commit and push. No public upload.
