# Fable Nov 19: what fades and what doesn't, a camera test per zone, the Path colours, a design for the info screens

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). This is a **judgment-heavy pass**: look at the screen, decide what reads best for a new player, prove it with shots. The owner's screenshots are in `docs/overnight_shots/nov19b/ref_*.png`.

Read first:
- the top of docs/overnight_report.md ("Overnight Nov 19") and docs/overnight_inbox.md;
- docs/owner_backlog.md;
- docs/art/path_icon_style_guide.md.

Run `git status`; if anything is uncommitted, run the tests and commit it. Log questions under "Fable Nov 19". Tag `pre-fable-nov19`. Work in this order.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`. If the guard stops a background run, finish it in the foreground with `--from=N --to=K`. Tests run under the save guard.
- Commit and push after each part. **No export**, no public upload.
- Shots in docs/overnight_shots/nov19b/.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board layout stays;
  - Primm's fight and the castle rooms unchanged (their choice-node texts may change, Part 5);
  - no new painted art (art needs become Batch 18 rows);
  - each zone keeps its own colour grade;
  - no combat pacing changes.

## Part 1 — Objects disappearing (the main job)
**The owner's problem:** far too many things fade or vanish when they don't need to. It makes the game look worse and makes navigation confusing. **The biggest issue: players can't walk through places that look walkable,** because the thing blocking them has faded away.

His examples:
1. `ref_fade_crosspath_building_gone.png`: **whole buildings** vanish when the hero stands near them.
2. `ref_fade_crosspath_signpost.png`: the **little signpost** disappears when the hero walks near it. Small things disappearing makes navigation hard.
3. and 4. `ref_fade_dna_counter_visible.png` / `ref_fade_dna_counter_gone.png`: in the D.N.A., the **waist-high counter/desk** disappears when the hero is behind it. Walking south, it then looks as if he can walk straight through, but he can't.

**First, take stock (before changing anything):**
- Find every system that hides, fades, dithers or cuts away world objects (the camera occlusion fader, the cut-away for walls and buildings, the "hold inside bounds" code, distance culling, per-zone overrides).
- For each zone (Crosspath, the Opening Forest, the Gainlands, the Buffet, the Dump, the D.N.A., the Capital and the Crease), record which objects fade, when, and why.
- Shoot the owner's four cases and **six more of the worst per zone**, at the default and Low cameras.

**The rules to build (tune them by looking, not by numbers alone):**
1. **What looks solid must stay visible.** Anything that blocks walking (counters, desks, partitions, fences, hedges, rails, rocks, low walls, signposts, crates) **never fades** if it is lower than about the hero's shoulder. The hero is never really hidden by something waist-high.
2. **Small things never fade:** signs, signposts, lamps, posts, plants, props, banners. They are how players find their way.
3. **Only fade what actually hides the hero,** and only while it does: a building, a tall wall, a tree canopy or a column **between the camera and the hero** that covers most of him. Not when he is merely near it, beside it, or in front of it.
4. **Fade partly, never vanish.** When something must fade, it goes to see-through (about 35-50% opacity, or a dither), never to nothing. Only the part in front of the hero fades (a cut-out circle or the nearest section), not the whole building, and the roof or top doesn't disappear when only its wall is in the way.
5. **The hero's silhouette instead of fading, where it reads better:** when he is behind a building or wall, show his outline (a soft silhouette in the Path colour or white) through it, rather than fading the building at all. Try both and pick per case; prefer the silhouette for buildings and large walls.
6. **Whatever fades still shows where it blocks:** its footprint stays readable (its base or lower part stays opaque, or a soft outline and shadow on the ground), so nobody tries to walk through it.
7. **Smooth:** fades ease in and out (about 0.2-0.3 s), with no flicker when the hero walks along an edge (hysteresis).
8. **Per zone where needed,** but one system and one set of rules. Tag objects by type (tall_occluder, low_blocker, small_prop, sign) rather than by hand, one by one, wherever possible.

**Check:**
- After shots of every case above, both cameras.
- Short walk sequences: along Crosspath's main street past the houses; around the signpost; through the D.N.A.'s cubicle farms and behind the counters; past the Capital's walls; through the Buffet's food forest and the Dump's trees.
- **A probe:** list every object that can fade, its type and its rule; it fails if any low_blocker or sign can fade. Keep it as a test.
- FPS on Medium and Low-end, before and after.
- A short report section per zone: what faded before, what fades now, and why.

## Part 2 — A camera test for every zone (choose nothing; give the owner a sheet)
The owner liked the D.N.A.'s steeper camera (+6 degrees). He wants a default camera **angle and closeness** test for every zone, to decide what looks best. The camera also decides what blocks the view, so do this **after** Part 1, with the new fade rules on.
- For each zone (Crosspath, the Opening Forest, the Gainlands, the Buffet, the Dump, the D.N.A., the Capital and the Crease), shoot the same 3 representative spots (the arrival, the hub, a busy area) at:
  - the current default;
  - pitch +4, +6 and +8 degrees;
  - each of those a little closer and a little further (about -10% and +10% distance).
- Make one **contact sheet per zone** (a grid labelled with the pitch and distance) as a JPG in docs/overnight_shots/nov19b/camera/, plus your recommendation per zone and why: what reads best, sees most, and keeps the zone's character.
- **Don't change any default.** The owner picks from the sheets. Make it a one-line change per zone to apply his choice later (e.g. a per-zone value in `zone_looks.json` or the camera config), and document where.

## Part 3 — The Path colours: one official colour per Path
**Today the Paths' colours don't agree.** Alembic's essence bars show Gourmand blue and Necrocrat purple; the card frames use red, blue, green and purple; the Path icons use red/gold, cream/copper, moss green/rust and slate/ghost green. The owner wants **one representative colour per Path**, used everywhere a Path is shown, like the Path icon pass.
1. **Audit:** list every place a Path is shown by colour, in code and in art:
   - UI: essence bars, card frames, energy and resource icons, deck filters, map markers, quest tags, the Deck Station, shops, Alembic, the battle board's resource counters, toasts, the hero silhouette colour from Part 1;
   - painted art: icons, packs, card backs, banners, plinths, Alembic's portrait and shop art, loading screens.
2. **Propose the palette:** one main colour and one accent per Path, chosen so that:
   - the four are easy to tell apart (also for colour-blind players: check with a simulator) and readable on both dark and parchment backgrounds;
   - they agree with the approved Path icons;
   - the most-seen places (the card frames) change least.

   Put it in `docs/art/path_colour_guide.md`, with swatches (a PNG), hex values, where each colour is used, and the reasons. If two options are close, show both and recommend one.
3. **Apply it in code:** one palette file the whole UI reads from (no hard-coded Path colours left). Update every UI place from the audit, so the owner can still change a colour in one place. Before/after shots of Alembic, the Deck Station, the shops, the battle board and the map.
4. **Painted art in the wrong colours** becomes Batch 18 rows (`docs/art/batch18_nov18.csv`), each naming the file, what's wrong and the right colours, with a description under 600 characters, self-contained, for a ChatGPT sheet tab.

## Part 4 — A design for the info screens (spec and mock-ups; build nothing that needs new art)
The owner wants the default look of the information screens reworked: the menus, the quest box (top left), the settings, the quest log, the map frame, the tooltips and pop-ups. New art is allowed.
1. Shoot every info screen as it is now.
2. Propose **one coherent look** that fits the painted, storybook style and the gold-framed battle and shop screens: frames, backgrounds, header ribbons, dividers, buttons, scroll bars, the quest box's shape, typography sizes and spacing.
3. Make **mock-ups** of 4-5 key screens (the quest box, the main menu, the quest log, a tooltip, a settings page), composed from existing assets plus clearly marked placeholders for new art. Save them in docs/overnight_shots/nov19b/ui_mockups/ with a short spec in `docs/art/ui_style_guide.md`.
4. List the new art the design needs (frames, panels, ribbons, a parchment or wood background, button states) as Batch 18 rows, with exact sizes, 9-slice margins and descriptions under 600 characters each.
5. Changes that need **no** new art and are clearly better (spacing, the quest box's readability, contrast, font sizes) may be applied now; list them with before/after shots.

## Part 5 — Small items
1. **Primm's Castle choice nodes:** give its purely-good options (Study the portrait, Read the notes, Pick the odd one out, and any other) a drawback each, by the same rules as every other dungeon: no purely good option, scaling with depth (the castle is the deepest, so strong boons with lasting drawbacks). **The rooms and fights stay unchanged.** Add them to the choice-node table in the report.
2. **The enemy-side drawback:** add the start-of-fight summon for the enemy seat ("the enemy starts with an extra unit"), and use it in two or three choice nodes where it fits. Tests.
3. **Hover magnification** on every remaining card grid: the Collection Book pages, the Glossary's example cards, and any other menu with small cards. Unseen cards magnify as card backs.
4. **Owner decisions applied (no code needed, just record them):**
   - Baron Quadzilla stays as built (playtest first);
   - Grand Bellows stays;
   - the Cardio Machine and the Department of Final Approvals stay normal cards;
   - the separate Swolympus / Iron Cave clear flags stay;
   - the Arena's numbers wait for the owner's hand pass;
   - opponent cards wait for a click by default;
   - **Crosspath's shop-front signs: no change.**

## Part 6 — Tests and report (no export)
1. All test shards green; the walk smokes (every zone); the NPC visibility probe; the new fade probe; the sign-angle probe.
2. **docs/overnight_report.md**, at the top, under "Fable Nov 19":
   - **Part 1:** the rules as built, before/after shots per zone (the owner's four cases first), the walk sequences, FPS;
   - **Part 2:** the contact sheets and your recommendation per zone (and where to change each);
   - **Part 3:** the palette (swatches), what changed in code, the Batch 18 rows;
   - **Part 4:** the mock-ups, the spec, what was applied, the Batch 18 rows;
   - **Part 5:** the castle nodes table;
   - the owner's decisions needed (at most 6, each with a recommendation; the camera choice per zone and the palette approval are expected).
3. Commit and push. No export, no public upload.
