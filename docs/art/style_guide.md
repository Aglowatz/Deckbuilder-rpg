# Style guide: "cozy diorama, readable toon"

Benchmarks: Lil Gator Game, Slime Rancher, A Hat in Time. Audience: young adults. Words to hold on to: bright, charming, expressive, readable, fun.

References viewed (`_reference/`, git-ignored, never published): **ref_cozy_interior** (warm tile floor lit in pools, dense prop clutter, hanging lanterns, a tiny
hero under a big hat), **ref_boxing_room** (chunky beveled props with painted wood/stone grain, saturated purple carpet against warm cream walls, banners, high-angle
framing, simple expressive characters), **ref_necro_grayscale** (a monochrome diorama, soft fog on the floor, bright lamp pools, one red accent on the hero).
Only these three images were present in `_reference/`; the three benchmark games are described from the brief, not from images.

## 1. What the references have in common (the target)

1. **Camera:** high angle (about 50-60 degrees down), orthogonal-feeling, everything in a room-sized stage. Props are big relative to the hero.
2. **Value structure:** dark-to-mid base with *pools of warm light*; the player sits in or near a bright pool. Backgrounds are slightly darker and softer.
3. **Density:** every patch of floor has a reason to exist: rugs, baskets, barrels, crates, plants, hanging tools. Empty ground is the enemy.
4. **Material language:** chunky shapes, soft bevels, painted textures with visible grain, slightly desaturated *base* with saturated *accents*.
5. **Colour in shadow:** shadows are purple/blue/teal, never gray. Highlights drift warm (yellow/peach). Light from lamps blooms.
6. **Characters:** big head, small body, large readable silhouettes, one strong colour per character, a hat or hair shape that reads from above.

## 2. Toon shading model (`StyleToon`, a spatial shader used by every world mesh)

- **Banded diffuse:** light is quantised to **3 bands** (shadow, mid, lit) with a **soft edge** (smoothstep width ~0.08, so bands feel painted, not posterised).
- **Coloured shadow tint:** the shadow band multiplies albedo by a per-zone *shadow colour* (cool violet by default) instead of darkening towards gray. Mid band = albedo.
  Lit band = albedo with a warm highlight lift.
- **Rim light:** a Fresnel term, thresholded, tinted by the sky/fill colour, strength 0.25 by default (0 on ground, higher on characters).
- **Inputs:** `albedo_texture` (the existing atlases and vertex colours both work), `albedo_tint`, `emission` colour + energy, `shadow_tint`, `band_softness`, `rim_strength`,
  `wind_strength` (vertex sway for foliage), `desaturate` (the D.N.A. monochrome mode).
- **Why a shader and not StandardMaterial3D:** one set of uniforms lets the zone preset restyle the whole world and unifies the imported packs (KayKit x4, Kenney x many).
  Global shader parameters carry the zone's shadow tint, rim colour, wind and desaturation, so presets change the look without touching meshes.

## 3. Outlines

Decision (logged in open_questions.md, section Q): **inverted hull** is rejected for imported glTF kits (hundreds of meshes, double draw cost, bad on thin foliage);
**screen-space edge detection** (depth + normal Sobel in a full-screen post pass) is used. It is uniform across all packs, costs one pass, scales with the quality setting,
and stays subtle: line width about 1 px at 1080p, colour = dark tinted by the zone shadow colour (never pure black), fading with distance.

## 4. Palette rules

- **Saturated but harmonious.** Per scene: a *base hue family* (60% of pixels), a *support family* (30%) and an *accent* (10%). Accents are reserved for things the player should act on.
- **Value first:** squint test. If a grayscale screenshot does not read (player, doors, NPCs, pickups), the lighting is wrong, not the colours.
- **Shadows are coloured** (violet in warm scenes, teal in sunny scenes, deep blue-green in the D.N.A.). No shadow colour has R=G=B. Ambient light is always tinted.
- **Characters** are the most saturated thing in the frame (after pickups).
- **Ground is calmer than props:** ground saturation ~70% of prop saturation; variation through value/hue patches, not noise.

## 5. Lighting rig (every 3D scene)

| Light | Role | Default |
|---|---|---|
| Key (DirectionalLight3D, shadows) | warm sun/lamp direction, 35-50 degrees elevation | warm (#fff0d8), energy 1.0-1.4 |
| Fill / sky (ambient) | cool, low | lavender/teal, energy 0.5-0.7 |
| Rim | the toon shader's Fresnel (no extra light) | sky colour, 0.25 |
| Pools | OmniLight3D under lanterns, windows, fires; short range (4-7 m), warm, no shadows | #ffb45a, energy 1.5-2.5 |
| Emissive | window panes, lantern glass, crystals, rifts: emission feeds bloom | per object |

Pool budget: at most 12 omni lights alive near the camera on Medium; at most 24 on High.

## 6. Post-processing stack (per zone preset)

Tonemap (Filmic/ACES per preset), exposure, **bloom** (threshold ~0.9), **SSAO** (radius 1-1.4, intensity 1.4-1.8, off on Low), **colour grading** (built-in adjustments: saturation/contrast/brightness),
**distance fog** per zone plus optional **volumetric fog** on High, **screen-space outline** pass, optional **depth of field / tilt-shift** (toggle), a faint vignette. No chromatic aberration, no film grain.

## 7. Camera framing

High-angle diorama: pitch about -52 degrees, narrow FOV (38-42), distance 14-16 m, smooth follow (~0.25 s damping). Player in the lower-middle third. Optional tilt-shift DOF.
No horizon in towns (a ring of foliage/cliffs hides the stage edge).

## 8. Environment density rules

- Within 8 m of any walkable route there is a prop about every 2 m, in clusters of 3 (big, medium, small), not a uniform spread.
- Every building has a *skirt* (flower box, crates, barrel, bench, lantern by the door); every path has *edges* (stones, tufts, flowers).
- 3+ ground treatments per area (paths, dirt patches, moss/leaf litter); decals blend softly.
- Vertical interest: banners, hanging lanterns, signs, string lights, chimney smoke.
- Keep walkable lanes at least 2 m wide; clutter lives at the edges and in alcoves.
- Foliage sways (shader wind). Foliage density is a quality setting.

## 9. VFX style

Particles are soft, warm and sparse: dust motes in light, falling leaves, fireflies, chimney smoke, steam. Hit effects are bold, flat, shape-first (stars, rings, swooshes) with an emissive core.
Sizes read at the diorama distance (bigger than realistic). Colours follow the palette; smoke is tinted by the zone, never gray.

## 10. Character proportions

Chibi: head about 40% of height, thick limbs, big feet, mitten hands. Outline-friendly silhouettes. Accessories (hat, cloak) are exaggerated (a hat is about as wide as the shoulders).
Idle animation always on; NPCs get small flavour animations. Faces are simple; the eyes and brow carry emotion.

## 11. Zone moods

| Zone | Mood | Key / fill / shadow | Fog | Accent | Particles | Signature |
|---|---|---|---|---|---|---|
| **Main town** (Crosspath) | warm, cozy, bustling, golden | key #ffd9a0 low, fill lavender, shadow violet | warm peach, light | banner reds/blues, flowers | dust motes, leaves, birds | lantern pools, market clutter |
| **Starting area** | soft, mysterious | pale moon-gold key, blue-lilac fill, indigo shadow | blue-violet mist, medium | glowing teal gate | fireflies, drifting spores | mist, soft glow |
| **D.N.A.** | near-monochrome grays/blacks (ref_necro_grayscale) | cold white key, gray-blue fill, near-black blue shadow | gray floor mist | **red** | dust, paper scraps | colour only on the player, interactables, enemies, key objects |
| **Gainlands** | bright, sunny, high-energy, big skies | bright white-gold key, sky-blue fill, teal shadow | very light, long | saturated cyan/magenta/orange | cloud streaks, petals, sparkles | big sky, strong rim light |
| **Endless Buffet** | warm, saturated, appetizing | orange-yellow key, pink fill, raspberry shadow | warm cream steam | red/green/yellow food colours | steam, crumbs, sparkles | glossy highlights, steam |
| **Verdant Dump** | earthy greens, rust orange, golden hour | low gold key, olive-teal fill, brown-purple shadow | golden haze | rust orange, rotten lime | motes, spores, ash | golden-hour rays, rust palette |
| **The Capital** (Primm's Perfection) | facade: unnaturally clean pastel; outskirts: desaturated, unsettling, vivid rift colours | facade soft white-pink key, mint fill; outskirts dim gray-violet | facade none; outskirts thick violet | rift magenta/cyan | facade sparkles; outskirts ash, rift sparks | the contrast itself |

**D.N.A. accent colour: red.** It matches ref_necro_grayscale and the zone's bureaucratic-menace theme. Interactables use the warm red-orange end, enemies the deep crimson end;
the player keeps their own natural colours (the only fully natural colours in the frame).

## 12. Honest scope: what this pass can and cannot do with the current assets

**Can:** unify the look through shader, light, fog, post, outlines and camera; put colour into shadow; add dense dressing by re-using existing kit pieces (KayKit hex props, furniture,
restaurant, halloween; Kenney nature/food/furniture); add wind, particles, light pools and ground variation; give each zone a distinct mood; make characters read better.

**Cannot (yet):** the kits are low-poly with flat or gradient atlases. We will not match the hand-painted textures, sculpted bevels or bespoke hero props of the references.
Silhouettes are generic (kit repetition shows), there are few bespoke faces/expressions, and no baked lighting or authored surface detail (grain, stains, stitching).

**Later custom assets (Blender / AI textures) would add:**
- Hand-painted tiling textures (cobble, wood, plaster, moss, carpet) with grain, replacing the flat colours of the kits.
- Bespoke hero props per zone (the Rift Express, the D.N.A. vault door, buffet counters, the dump heap).
- A custom hero with facial expressions and modular hats/cloaks with painted detail.
- Hand-authored decals (stains, cracks, leaf piles, chalk marks), banners and signage art.
- Baked light/AO on large set pieces, and stylised skyboxes per zone.
- Flipbook VFX sheets (smoke, steam, sparkle) in the final art style.

## 13. Result log (end of Brief 12)

**Achieved**
- One look for every pack: `StyleToon` (3 soft bands, coloured shadows from the tinted ambient, rim, wind, desaturation with per-instance colour keep) converts every KayKit and Kenney mesh at runtime; screen-space outlines; 13 zone presets
  (sky, key/fill light, fog, volumetrics, grading, bloom, SSAO, outline colour, particles); Low/Medium/High quality plus optional soft depth of field.
- The town square is the reference quality: cobbles, paths, moss, stalls with goods, lamp posts with budgeted light pools, bunting, benches, a wind-swaying meadow, motes, leaves, birds and NPCs that fidget and turn to the hero.
  Every other area got its preset, particles, generic dressing (foliage/clutter/ground patches), and the D.N.A. is near-monochrome with colour only on the hero, NPCs, enemies (red rim) and the Rift station.
- Battle, rewards, dungeon-map and title backdrops use the same rig (the dungeon stages keep their own mood colours).
- The hero is an unarmored adventurer (KayKit Rogue) with 12 hats and 10 cloaks, 12 dyes and a spring-driven cloak; a wardrobe, a new-game look choice and a tailor with try-on.
- Medium holds 60+ fps on the dev PC (town 64, other zones 76-98); Low 120; High 24 (for stronger GPUs).

**Not reached / honest gaps**
- Textures are still flat or gradient: no painted grain, stains or stitching; kit repetition is visible (the same barrel, crate and stall).
- Characters keep the stock KayKit faces (no expressions); hats poke through the hair block a little; cloaks are plain cloth.
- The grass tufts and Kenney props are chunkier than the references; ground blending is procedural, not authored.
- Lighting is one sun + fill + a few budgeted point lights: no baked light or real window glow; the towns buildings do not light their own pools.
- Dressing in the zones is generic scatter, not authored layouts like the town square.

**Custom assets that should come next (for the Blender test)**
1. Hand-painted tiling textures: cobble, planks, plaster, moss, carpet, tile (the biggest visual win).
2. A custom hero (bald or hair-as-separate-mesh head, expressive face, modular bust) with painted hats and cloaks; a few signature NPC silhouettes.
3. Bespoke hero props per zone (Rift Express, D.N.A. vault door and filing cabinets, buffet counters, dump heap, Capital facade pieces).
4. Hand-authored decals and signage (stains, chalk, leaf piles, banners).
5. Window and lantern meshes with baked glow, plus baked AO on big set pieces; stylised skyboxes.
6. Flipbook VFX (smoke, steam, sparkles) in the final style.

**Graphics loop performance sign-off (2026-10-06, dev PC with an integrated GPU, 1600x900, `tools/fps.sh`)**

| Scene | Medium (60 target) | Low |
|---|---|---|
| Town | 63 (was 69 before TW-1..5, trimmed in F-02: patches 44 to 30, skirts 21 to 14, ambient particle size 1.6x to 1.2x) | 124 |
| Starting area | 76 | 114 |
| D.N.A. | 75 | 146 |
| Gainlands | 77 | 114 |
| Endless Buffet | 81 | 124 |
| Verdant Dump | 84 | 109 |
| Capital (outskirts) | 83 | 101 |
| Battle table (generic) | 69 | 140 |

High stays about 25 fps in the town on this machine (meant for stronger GPUs). Lessons: larger ambient particle quads cost about 2.5 fps in the town (overdraw); the light-pillar beacons cost nothing measurable; each ground-decal disc is a mesh, so keep them in the tens.
