# Critic 4: the world's look, art director review (Nov 17)

I opened all 113 shots in `docs/overnight_shots/nov17/art/` and nothing else.

## 1. Scores

**Overall look: 5.5 / 10**

The painted layers (dungeon maps, cards, shop portraits, title) score around 8 and would hold up next to Sea of Stars. The walkable 3D world is where the player spends most of their time, and it averages about 4.5. The overall score is weighted toward the world.

| Group | Score | One line |
|---|---|---|
| Opening Forest | 4.5 | Murky teal, crushed blacks, faceted low-poly canopy, hero hard to see |
| Crosspath (town) | 7.0 | The best 3D in the game: golden hour, painted half-timber, real density |
| Gainlands | 5.0 | Strong silhouettes and props. Oversharpened grade, blocky cliffs, tiled brick |
| Endless Buffet | 4.0 | Great concept. Washed out by orange haze, flat sea, primitive props |
| Verdant Dump | 5.0 | Dense and bold, but noisy oil-paint filter and muddy purple-orange |
| D.N.A. | 3.5 | Reads as a greybox: 10 m flat wallpaper walls, white light quads |
| The Crease | 3.0 | Cavern without a ceiling. Empty floor with repeated pillars |
| Capital, before | 4.5 | Flat pastel fills and a hard checkerboard. Looks like a vector toy, not a painting |
| Capital, after | 5.0 | Bunting, lanterns and toppled statues help. Some districts barely change |
| Dungeon maps | 8.5 | Excellent painted iso maps. The best thing in the game |
| Battles | 7.0 | Beautiful boards and cards. Large empty centre and a flat turn banner |
| UI | 7.5 | Gilded frames and great portraits. The map and a few panels fall out of style |
| Style consistency | 4.0 | Painted 2D vs 3D world, and a different post filter in every zone |
| Lighting | 5.0 | Crosspath and Capital-after are warm and good. Forest, D.N.A. and Crease are murky, Buffet and Capital are blown out |
| Materials | 4.5 | Flat fills, one tiling texture per wall, untextured primitives |
| Scale | 5.0 | Sprites read well in town. D.N.A. walls and the Crease are too large and empty |
| Composition | 6.0 | Arrival shots frame a landmark well. Hubs often have dead foreground floor |
| Readability | 6.0 | Sprites mostly pop. They get lost in the Forest, the Dump noise and the Capital glare |

## 2. Top 10 problems (ranked by how much a player notices them)

### 1. The Crease cavern has no ceiling: **blocker**
- **Files:** `crease_camp_default`, `crease_hub_default`, `crease_tunnel_default`. The top 15-20 % of the frame shows a sky and the pastel Capital skyline sitting directly on top of a flat rock wall. An "underground" market open to the sky reads as broken. (`crease_market_low` does show a rock ceiling, so the default camera sees past the cap.)
- **Fix (geometry):** extend the cavern ceiling mesh and the back wall so they fill the frame at the default camera height. Hide the Capital backdrop in this scene and use a dark blue-violet distance fog instead. Add stalactite cards hanging from the ceiling so the top of the frame has content.

### 2. D.N.A. looks like a level greybox: **blocker**
- **Files:** every `dna_*` shot. Huge flat slabs carry one tiling green wallpaper texture (`dna_mid1_default` left and right walls, `dna_mid2_low` almost the whole frame). Wall lights are plain white rectangles. A flat dark slab blocks the view in `dna_mid2_low` (centre, 430-640 x 165-340). A faceted low-poly orb on a plinth hangs at top centre of `dna_arrival` / `dna_hub` / `dna_mid1`. Blank beige "toast" signs sit at `dna_mid2_low` 1150,550 and 215,440. White untextured cubes are stacked at `dna_arrival_default` right, 1150,500.
- **Fix (geometry + material):** break each wall into bays with pilasters, crown moulding and a skirting band. Add a vertical grime/age gradient mask over the wallpaper and a second wallpaper variant per bay. Replace the white quads with modelled sconces that cast a warm light cone. Replace the orb with a modelled bureaucrat statue or clock. Give the blank signs their icons or delete them.

### 3. Capital facades and floors are flat pastel fills: **major**
- **Files:** `capital_before_gate_plaza_*`, `capital_before_castle_door_*`, `capital_before_palace_approach_*`, `capital_before_hungry_quarter_*`, `capital_before_grave_row_*`, `capital_before_the_reek_*`, `capital_before_transit_yards_*` (and the same assets in `capital_after_*`).
  - Walls are pure pink, blue, mint and white with identical stamped window decals.
  - The ground is a hard, saturated pastel checkerboard.
  - The stairs (`castle_door`, centre) are flat-shaded with blotchy shadow.
  - The orange-gold statues read as noise.
  - None of these surfaces looks hand-painted, so they clash with the painted sprites standing on them.
- **Fix (material + lighting):** give the Capital the Crosspath treatment:
  - a hand-painted plaster albedo with visible brush grain;
  - baked AO at wall bases and under balconies;
  - a 1.5 m dirt/warmth gradient up from the ground;
  - 2-3 window-frame variants.
  
  Desaturate the checker by about 30 % and give it stone grain and grout lines. Lower the white-point bloom so white walls stop clipping.

### 4. The Buffet is washed out and its "sea" is a flat plane: **major**
- **Files:** every `buffet_*` shot. An orange-pink haze lifts every black, so nothing in the frame has full contrast. The sea in `buffet_arrival_*` and `buffet_mid1_default` is a flat maroon plane with flat brown oval decals and floating cracker squares. Grey dash specks float in the sky (`buffet_mid2_low` 1040,195; `buffet_arrival_default` 200,460 and 1060,565). White bokeh discs hover everywhere.
- **Fix (post + shader):** cut fog density by about half and make it height-based, so the foreground keeps its blacks. Give the sea a gravy/soup shader with scrolling normals, a fresnel sheen, specular glints and a foam line at the shore. Make the floating debris bob and give it shadows, or remove it. Find and delete the grey dash artefacts.

### 5. Untextured low-poly primitives sit next to painted art: **major**
- **Files and positions:**
  - **Buffet:**
    - `buffet_hub_default` and `buffet_hub_low`: lime faceted cabbage spheres (right), a navy brick cube (right of centre), a red cube (1190,460), an orange box with X eyes (110,450).
    - `buffet_door_default`: a hedge row of faceted green blobs (right).
    - `buffet_mid1_default`: a foreground cake pedestal made of a flat pink disc and a brown cylinder.
  - **Dump:**
    - A pink cube "pig": `dump_mid1_default` 1070,470 and `dump_mid2_low` 330,470.
    - Olive faceted topiary spheres: `dump_hub_default` bottom and `dump_mid2_low` left edge.
    - A flat yellow disc decal: `dump_door_default` 120,600.
  - **Capital:** a dark brown box planter, `capital_*_grave_row_default` 790,570.
  - **Crosspath:** a white box lantern (`crosspath_square_low` 130,520 and `ui_town_hud` left), and pastel low-poly gem blobs in the bottom corners.
  - **Gainlands:** a magenta bar, `gainlands_hub_default` 830,475.
- **Fix (dressing):** do one primitive sweep. Swap each item for a painted kit prop or delete it. Any primitive that must stay gets the painted triplanar material and the outline.

### 6. A different post filter in every zone: **major**
- **Files:** each zone has its own filter:
  - **Gainlands:** oversharpened and posterised, with halos and a yellow-green cast (all `gainlands_*`).
  - **Dump:** a heavy oil-paint/Kuwahara noise (`dump_hub_default`, `dump_mid1_default`).
  - **Buffet:** an orange haze.
  - **D.N.A.:** a dark green murk.
  - **Capital:** clipped white bloom.
  
  Moving between zones feels like moving between games.
- **Fix (post-processing):** use one master grade LUT for the whole game, with only a small per-zone tint on top. Cap sharpening at about 0.3. Halve the paint-filter radius in the Dump, or drop it. Use Crosspath's grade as the reference.

### 7. The Opening Forest, the first thing a player sees, is murky: **major**
- **Files:** `forest_arrival_default`, `forest_arrival_low`.
  - The blacks are crushed under a teal murk.
  - The umbrella-tree canopy at top right is visibly faceted low-poly against the painted foliage cards.
  - The hero is a tiny dark sprite in the middle of the frame.
- **Fix (lighting + geometry):** raise exposure by about 0.7 EV. Put a warm key light pool on the clearing and a rim light on the hero. Re-skin the faceted canopy with the same painted leaf cards as the other trees.

### 8. Gainlands rock and brick materials: **major**
- **Files:**
  - `gainlands_mid1_*`: the orange cliffs are stair-stepped blocks with a stretched texture, and torn triangles at the cliff edge (bottom right, 700-800,600-720).
  - `gainlands_hub_*` and `gainlands_mid2_*`: inverted-pyramid floating rocks (790-900,170-260).
  - `gainlands_door_*`: one tiled brick texture with visible repetition and flat olive emblem banners.
  - Blue-grey untextured curb stones in every Gainlands shot.
- **Fix (geometry + material):** swap the cliff kit for rounded, sculpted painted rock pieces and cap the torn edges. Add vertex-colour dirt and a stone trim band to the fortress brick. Repaint the curbs in sandstone. Give the banner emblems a painted gold-leaf texture instead of a flat olive fill.

### 9. Empty voids and dead planes at map edges: **major**
- **Files:**
  - `capital_before_the_reek_default` and `capital_before_transit_yards_default`: the bottom 15 % is a flat brown dirt band past a rubble strip.
  - `dump_arrival_default`: a flat grey water plane with yellow splotches.
  - `crease_tunnel_default`: a bottom band of untextured dark floor.
- **Fix (camera + dressing):** clamp the camera so it never sees past the dressed edge. Where it still can, continue the ground with painted cover (rubble, foliage) and fade the far edge into fog.

### 10. "Capital after" barely celebrates in some districts: **minor**
- **Files:** `capital_after_grave_row_default` is nearly identical to `capital_before_grave_row_default`: same layout, same brown box, a near-empty square, only warmer light. `capital_after_hungry_quarter_low` has few people and no bunting. `capital_after_gate_plaza_default` and `capital_after_palace_approach_default` celebrate properly with bunting, lanterns and toppled statues.
- **Fix (dressing):** copy the gate-plaza celebration kit (bunting lines, sky lanterns, confetti, a crowd of 10+) into every district. Remove the leftover corruption crystals.

Also noted, below the top 10:
- Purple triangles drift through the Crosspath sky (`crosspath_square_low`, `ui_town_hud`) and read as debris.
- In `ui_map`, flat black fog-of-war and pixel-stepped area shapes don't match the parchment frame.
- In `ui_shop_items`, the tip box overlaps a clipped "…k level" label (940,617).
- The battle "YOUR TURN" bar is a flat grey band (`battle_zone_gourmand_mid`).
- The empty purple battle-log slots look unfinished.

## 3. The jarring things I looked for

- **Flat untextured surfaces:** yes, often.
  - Buffet: cabbage spheres, the pedestal, the navy cube.
  - Dump: the pig cube.
  - Capital: the brown box, the flat stairs.
  - D.N.A.: the cubes.
  - Gainlands: the curbs.
- **Pure-white or pure-colour walls:**
  - Capital: pink, blue and mint facades, and white walls (`capital_before_gate_road_default`, which is also washed lavender-grey).
  - D.N.A.: single-texture wallpaper walls.
- **Low-poly blocks next to painted art:**
  - Forest: the faceted canopy.
  - Dump: the faceted tree canopy at top centre (`dump_arrival_default`, `dump_hub_default`).
  - D.N.A.: the faceted orb.
  - Capital: faceted lamp globes in the foreground (`capital_after_hungry_quarter_low`, `capital_after_palace_approach_default`).
  - Gainlands: the inverted-pyramid rocks, and the balls-on-a-string smoke (`gainlands_arrival_low`, `gainlands_hub_low`).
- **Mismatched outlines or saturation:**
  - The Capital is far more saturated and flatter than Crosspath.
  - Sprites carry painted outlines, but most 3D props have none or a thin inconsistent one.
  - The dungeon maps are much higher detail than the world they open from.
- **Floating or clipping props:**
  - Buffet: floating cracker squares in the sea, grey dash specks.
  - D.N.A.: paper quads hanging in the air (`dna_arrival_default`).
  - A flat standee seen edge-on at `dna_door_default` 490,560.
- **Tiling seams and repetition:**
  - Brick on the Gainlands fortress.
  - D.N.A. wallpaper and marble.
  - The Buffet cracker ground ripples oddly (`buffet_mid2_default`).
- **Sprites lit differently, or missing a contact shadow:**
  - Capital: white-costumed NPCs blow out to near white (`capital_before_palace_approach_low`).
  - Forest: the hero goes nearly black.
  - Contact shadows are present on most sprites. Good.
- **Empty voids at map edges:** the Crease sky, the Capital dirt band, the Dump water plane (see #9).
- **Blown-out or muddy lighting:**
  - Blown out: the Capital and the Buffet.
  - Muddy: the Forest, D.N.A., the Crease, and the Dump (noise).
- **Banding:** mild banding in the Buffet sky gradient and the Capital-before grey sky. Nothing severe.
- **Placeholders:**
  - D.N.A. blank beige signs.
  - The Dump pig cube.
  - The Buffet orange "X-eyes" box.

## 4. Three things that work and must not be lost

1. **The dungeon room maps** (`dungeon_D-HOG`, `dungeon_D-TTK`, `dungeon_S-GOUR`, `dungeon_D-HFA`, `dungeon_D-ROT`, `dungeon_S-REF`). These are rich hand-painted isometric dioramas:
   - warm practical light pools against a cool ambient;
   - every square inch dressed;
   - a clear palette per zone (copper and steam for the Test Kitchen, lantern amber and teal water for Omakase, toxic green for Final Approvals).
   
   This is the target for the 3D world.
2. **Crosspath at golden hour** (`crosspath_street_default`, `crosspath_square_default`, `crosspath_street_low`). Painted albedo on the half-timber and roof tiles, a warm key with violet shadows, a hazy mountain backdrop, a fruit tree and barrels giving foreground depth, and enough NPCs to feel lived in. It proves the 3D world can look like the paintings. Pull every zone toward this material and grade.
3. **Battle boards, cards and the gilded UI frame** (`battle_zone_beefcake_mid`, `battle_zone_gourmand_start`, `ui_title`, `ui_shop_cards`, `ui_wardrobe`).
   - The board backgrounds are themed paintings (a gym arena, a banquet tablecloth).
   - The card art is consistent and appealing.
   - The vendor portraits are characterful.
   - The gold-filigree frame ties every screen together.
   
   Keep this art bar. Also worth keeping: the `capital_after_palace_approach_default` bunting and warm lanterns.

## 5. The 3D world vs the painted art

**Yes, the gap is still there and it is large.** The painted layers sit around 8-8.5. The 3D world averages about 4.5, with Crosspath (7) the one zone that closes it. Stepping from `dungeon_D-HFA` (a lush, lamp-lit painted bureaucracy) into `dna_hub_default` (green wallpaper boxes) is the most jarring moment in the set.

**The single biggest step: a material pass that uses Crosspath as the reference.** Retexture every 3D surface in the other zones with a hand-painted albedo that carries:
- brush grain;
- baked AO in creases and at wall bases;
- a ground-up dirt/warmth gradient.

Remove every untextured primitive and every one-texture slab. Ship it under **one shared colour grade** instead of a different filter per zone. Crosspath already shows this formula works in this engine with these sprites. The Capital and D.N.A. would gain the most (each could rise 2+ points), and they are the zones the player sees last.
