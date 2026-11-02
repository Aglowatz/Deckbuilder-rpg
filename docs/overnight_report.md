# Report - Capital sides pass (Nov 2, Fable 5.1)

Sun Nov 2 07:00 -> 09:30 MST. Brief: "CAPITAL SIDES PASS (follow-up to the inner-city rebuild)", items 1-7. Tag `pre-capital-sides-nov2`.
Full report (what the screenshot showed, every part, the critics' rounds, perf, the before / after gallery): `docs/art/capital_rebuild_nov1.md`,
section "The sides pass (Nov 2)". Judgment calls: `docs/overnight_inbox.md` ("Capital sides Nov 2", items 1-5). Previous report below.

## Morning summary

- **No scatter on paving.** Plants stand only on painted lawn or inside a planter; every district lane and separator is lined with continuous
  white planters (gold lips, roses, a cone in a gold urn every 4 m). A test counts loose plants inside the wall (0).
- **No black objects.** The cause was the kit's near-black flat slots under the toon shadow band, not a missing texture. Every inside piece is
  restyled white and gold (bins, sacks, crates, the compost covers, the sick patch, drain covers, Ward bars, tram rails, dead windows, dead
  globes, Fern's shack). A probe test walks every visible triangle inside the wall: 434.8 m2 of near-black before, 0.31 after (budget 0.6).
- **No skinny buildings.** The Reek's yards, Grave Row's crypts and the Hungry Quarter's six stalls are grand townhouses with their district's
  service layer (one long shop-house a side of the Hungry lane); the plaza corners' pylons are gate piers; the district pylons are gone; the
  walls' inner faces wear a blind arcade with niche statuettes, wall basins and eleven engaged towers.
- **Side plazas** at (19, 58) and (100, 58): a two-tier side fountain with the gilded Primm on top, a gilded statue pair, a checker disc with
  ring borders, banner lamps, rose planter arcs; the routes end at the rim. The wheels, the pylons, a chest, the junk and the transit rift
  moved a little for them; every NPC, talk spot, pickup and entrance stays.
- **Gardens / order**: pink 3D lamps in rows on every lane (the painted card read brown), two parterre beds on Grave Row, a white-and-gold
  cordon round every rift inside the wall.
- **Critics (sides only, strict)**: s2 4/4/5/5/4/3/5/4 -> s3 4/4/5/5/4/4/6/5 -> s4 5/5/6/6/4/4/6/5. What they ask for next is mostly the
  story's props (the wheels, the rifts, the shed, the cable) - inbox 1.
- **Verified**: world 432/433 (one pre-existing pending), core 1563/1564 (one pre-existing pending), walk smoke OK (36 screenshots), the walkability test green,
  `capital_in` Medium 833 draw calls / p99 19.5 ms (budget 850 / 25; the first measure was 859 - the new statics merged city-wide fixed it).

Commits: ca14bb1c (Parts 1-4), ff06ea81 (perf), af4b45b2 (round 2), 88762f43 (round 3), and the finish commit.


---

# Report - Capital inner-city rebuild (Nov 1-2, Fable 5.1)

Sun Nov 1 20:10 -> 23:15 MST. Brief: "CAPITAL INNER-CITY REBUILD (overnight)", Parts A-G. Tag `pre-capital-rebuild-nov1`. Full report with
the before/after gallery, the plan, the piece list, the scores per iteration and the perf table: `docs/art/capital_rebuild_nov1.md`.
Questions and judgment calls: `docs/overnight_inbox.md` ("Capital rebuild Nov 1-2", items 1-4). Previous report: `docs/overnight/nov1/report.md`.

## Morning summary

Everything inside the great wall was rebuilt in code from the kit's own textures and painted cards (no new image files):

- **The kit** (`world/capital/capital_grand.gd`): a grand townhouse generator (storeys, bays, pastel accent, hip / mansard / gable roofs,
  balcony, pediment with the sun medallion, flower boxes, door, pinnacles, one banner that can hang a degree off), slender towers with pointed
  pastel spires, the gilded Primm (the painted statue card) on tall laurel plinths, a three-tier fountain, planters, paving borders,
  balustrades, lamp banners. Look-dev lineup: `tools/capital_lineup.tscn`.
- **The layout**: the sixteen Showcase footprints, every route, anchor, spot, sign, rift, entrance and the hidden hole stay exactly where they
  were; the houses are 4- and 5-storey mirrored townhouses, towers stand at the plaza's four corners and three districts' corners, two gilded
  pairs flank the avenue's mouth and the castle terraces, four parterre beds and eight banner lamps ring the enlarged fountain, rose planters
  run the boulevard and the lawn panels, the plaza and the boulevard wear a crisp 2 m checker with white-and-gold borders, the gate piers
  carry medallions, lancets and banners, and a skyline of five-storey rows and spires stands beyond the walls and on the hill top. The Grave
  Row flower clumps are gone; nothing random is left inside.
- **Light**: four grade passes (`data/zone_styles/capital_inside.json`): no violet ambient, thin fog, far blur cut, bloom cut, shadows up,
  exposure down, a bluer horizon band.
- **Checks**: world tests 431/431, core 1564/1564, the Capital walk smoke OK (twice), `perf_budget.sh frame capital_in` met on Medium after
  a perf pass (1004 -> 847 draw calls; the townhouses and towers draw as a shadow body plus a no-shadow detail mesh; the second rank, towers,
  statues, lamps and benches batch or instance). Loading path unchanged.
- **Scores** (a fresh critic per iteration, nine criteria, 1-10): c2 4/5/4/2/7/4/6/3/4 -> c6 6/6/5/4/7/6/7/4/5. Statues/fountain reached 8
  once; towers and light stayed at 4. Every critic reported "no roofs, no spires, white sky, overexposed": the play camera sees about six
  degrees above the horizon, so the roofs of any townhouse nearer than ~40 m, the plaza towers' spires and the blue sky are out of frame in
  play, and the sunlit cream plaster is a look-wide matter. Those are camera and look decisions, not Capital ones (inbox 1, 4). The brief's
  8+ on every criterion was not reached; the loop stopped at the plateau rather than making the zone gloomy to please a still picture.

## What to look at in game

1. Walk in through the gate: the inner gate plaza, the fountain ring with its parterres, the gilded pair at the avenue's mouth, the boulevard
   to the castle. Try the Far zoom and the Overview angle for the skyline.
2. The fallen state (after Primm, or `--flags=zone_final_completed` in a shot): crooked banners, warm windows, toppled statues, the dry
   fountain. The Showcase's houses no longer turn into ruins (inbox 2: say if you want the ruins back).
3. The districts keep their own models and states inside the new frame (inbox 3: replacing them with townhouse modules is a day's work).

## Art requests (nothing missing was invented)

- A side / three-quarter painting of the gold Primm statue: the plinth pairs face south like every card; a second angle would let the pairs
  face each other across the boulevard.
- A tileable pastel slate roof in sage (only pink and blue exist), and a gold urn card without the topiary (the rose beds use white planters).
- A CAP-PATH-WHITE re-upload (the Drive copy is truncated; noted since the art pass).

## Parts

| Part | Result |
|---|---|
| A | 13 before shots from the standard spots and the target's framing; the audit table and the plan (fc73c016) |
| B | `CapitalGrand` + the lineup scene; lineup shots in the report (663bf3af) |
| C | The layout as above; `KitBatch.merge_static(root, cell_size)` keeps far views unculled; `garden_fields` apart from the rows' people-room rule |
| D | The light passes; a fog-off and an ACES diagnostic shot showed the remaining paleness is the scene's own brightness, not fog |
| E | Tests, walk smoke, perf (table in the report); the Transit tower moved off a Tidy-Bot home, the Ward tower dropped (it cut the strip to the Ward chest) (b69feace, 1e19b4f4) |
| F | Six shot sets (c1-c6), five critic reports (`docs/review/capital_critic_c2..c6.md`) |
| G | This report, the gallery, the scores, the art requests; committed and pushed |

Gotchas for the next run: the play camera's six-degree sky band; a `node -e` string with an escaped apostrophe or a backtick inside bash
double quotes hangs the whole command (write .js files); the loudspeakers' open horns read as black discs from the front (gold inside now);
the forecourt lawn holds two rifts, so no tower pair fits there; `KitBatch` merged meshes never fade.
