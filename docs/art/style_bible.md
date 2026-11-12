# The Wayward Path - style bible (Fable Nov 12)

One page of rules for everything that is drawn in the 3D world, so the game reads as **one deliberate world**. It is drawn from the
best-looking shots of the fixed set (`docs/overnight_shots/nov12/before/`), the art-director critic's report
(`docs/review/critic_art_nov12/report_before.md`) and the earlier guides it replaces as the first thing to read
(`style_guide.md`, `art_bible.md`, `storybook_scale_and_camera.md`, `zone_styles.md` stay as the detail).

**The look in one sentence:** a hand-painted storybook diorama at golden hour - warm key light, coloured (never grey) shadows, painted
textures on chunky shapes, painted people standing *in* it with a soft shadow at their feet.

## 0. Reference shots (pull everything toward these)

| Shot | Why it works |
|---|---|
| `crosspath_square_default`, `crosspath_street_low` | warm low sun, long violet shadows, every surface painted (timber, plaster, roof tiles, cobbles), lit windows, dense props, people grounded |
| `forest_arrival_default` | one mood: teal dusk, light shafts, a single amber lantern as the accent; nothing flat, nothing white |
| `dump_mid2_default` | layered depth (foreground foliage, mid stalls, far mill and violet glow), warm/cool contrast, textured ground |
| `ui_title`, the dungeon maps (`dungeon_D-TTK`, `dungeon_S-GOUR`) | the painted target itself: saturated but harmonious, light pools, soft brushwork |
| `battle_zone_refusemancer_mid` | a painted board with a clear value structure: dark frame, lit centre |

## 1. Palette per zone

Each zone has a base family (about 60 % of the frame), a support (30 %) and an accent (10 %, kept for things the player acts on). The
hex codes are the zone style files' (`data/zone_styles/*.json`, first = dominant).

| Zone | Time of day | Base | Support | Accent | Shadow colour | Never |
|---|---|---|---|---|---|---|
| Opening Forest | dusk into night | teal `#1C3C46`, moss `#3F5E3A` | bark `#6B4E3A`, leaf `#6A8A3A` | lantern amber `#FFA850`, mushroom cyan `#6FF0E0` | deep teal | black voids, grey fog |
| Crosspath | golden late afternoon | plaster `#F2E3C6`, straw gold `#E8B86B` | roof red `#C4573A`, timber `#5B4636`, grass `#6E8B4E` | slate blue `#6F8FB0` shutters, lit windows | violet | cold white light |
| The Gainlands | bright late morning | sandstone `#F2C14E`, chalk `#F7EBD3` | brick red `#D9483B`, wood `#7A5230` | sky blue `#5FA8D3`, banner red | cool blue-violet | flat primary-blue or pure-red planes; untextured sand |
| The Endless Buffet | dinner-time evening | crust `#F4D8B0`, caramel `#C98B3A` | tomato `#E07A5F`, icing pink `#F6B8C4` | herb green `#6B8E3D`, cream highlights | warm plum | cream rectangles with no texture; one orange wash over everything |
| The Verdant Dump | golden-hour sunset | moss `#7C8F45`, soil `#8B6D4C` | rust `#B5552D`, slate `#5C6B5E` | amber `#E3A857`, corruption violet | violet | milky translucent boxes; grey flats |
| The D.N.A. | 4:59 PM overcast | filing grey-green `#6E7470`, paper `#C9C6B8` | dark green `#3D4A44`, pale green `#9BB59A` | ghost green `#4FBF7A`, stamp red `#8A2E2E` | deep blue-green | pure black areas (dark is a colour: `#16201c` at the darkest), flat grey slabs |
| The Capital, outside | eerie overcast dusk | ash `#8C8A86`, dust `#B9B2A4` | char `#5E5B57` | rift purple `#9B59D0`, camp lantern amber | plum | a single grey with nothing warm in frame |
| The Capital, inside | "perfect" noon | cream stone `#F2ECDD` (not `#FFFFFF`), mint `#BFE3D0` | pink `#F5C6D0`, powder blue `#A7C7E7` | gold `#E6C35C` | lavender | paper white: the brightest wall stays under 92 % value so the grade has room |
| The Capital, freed | warm afternoon after the fall | the same city, honey-warmed | bunting in the four Paths' colours | gold, petals | soft violet | the blown-out cream of the old freed preset |

Rules: shadows are tinted (no shadow has R = G = B); the ground is calmer than the props (about 70 % of their saturation); characters and
pickups are the most saturated things in a frame.

## 2. The lighting model

Every walkable scene uses the same rig (`StyleRig`, data in the zone style file):

1. **One key light** (the sun or moon): warm, 24-58 degrees high, from the front-right of the game camera (yaw 110-140) so shadows fall
   toward the lower left and read. Energy 0.6-1.05. It casts the only large shadows.
2. **Coloured ambient** (the shadow colour): violet / teal / plum per zone, energy 0.3-0.9. This is what a shadow *is* here.
3. **A faint cool fill** from the opposite side (energy 0.18) so no face goes flat.
4. **Pools:** a warm omni (`#ffb45a`, range 4-7 m, no shadow) wherever the art implies a source - lamps, lit windows, ovens, forges,
   braziers, rifts (purple), ghost lamps (green). Three to six in view; they are the warm/cool accents. Budget 12 near the camera on
   Medium, 1 on Low-end (the glow decal on the ground keeps the pool visible when its light is culled).
5. **Grounding:** every character and every prop taller than a crate has a contact shadow (a soft blob under sprites, the ground light
   map's ambient shade under buildings and big props). Nothing floats: a prop's base is at or 2 cm under the ground.
6. **Depth:** distance fog in the zone's horizon colour, height fog where the land drops (the Dump's ravine), far haze cards on the
   skyline, and the tilt-shift band. Far things are lighter and cooler than near things.
7. **Grade:** AgX tonemapping with one exposure per zone, a shadow tint and a highlight tint (`grade.*`), bloom on light sources only
   (threshold >= 1.0: a lit wall never blooms), a soft vignette (0.08-0.4).
8. **Sprites are lit like the world:** the same key, ambient and grade reach them (their normal maps catch the key on Medium and up),
   and they sit under the zone's fog. A sprite is never brighter than the wall behind it in shade.

Per quality level: High adds SSAO, normal-crease outlines, volumetric shafts; Medium is the reference (ground light map, depth outlines,
FSR 1); Low drops the sun shadow (ambient lifts 1.5x so cliffs do not show "holes"), bloom and haze cards. Every new effect names its
Medium and Low behaviour before it ships.

## 3. Materials

- **No pure-white, pure-black or untextured large surface.** Anything over 2 m with a single flat colour gets a painted or procedural
  texture (stone, plaster, brick, wood, cloth, metal) - `tools/play_script` command `matscan` lists offenders.
- White is **cream stone** (`#F2ECDD` at most), black is **deep colour** (`#16201c`, `#1a1420`).
- Walls have three bands: a darker grime or plinth band at the base (weathering where wall meets ground), the wall body, a trim or
  cornice. Large walls break every 6-8 m (pilaster, buttress, banner, window).
- Ground is always blended: two textures (grass/dirt, sand/rock, tile/moss) with a noisy edge between them - no hard polygon seam between
  ground types, and a soil or shade band where a building meets it.
- Texel density: about 128 px per metre at the game camera for anything the hero can walk up to; never a stretched single texture over a
  10 m face.
- Saturated flat planes (the primary-blue mats, plain red cloth) are painted cloth or water with a darker border and a little variation.
- Emissive only on things that are lights (window panes, lantern glass, rifts, glowing pickups).

## 4. Outlines and edges

- One screen-space outline for every 3D mesh: about 1 px at 1080p, the zone's shadow colour darkened (never pure black), fading with
  distance. Painted sprites carry their own painted edge and take no outline.
- Hard 90-degree block edges are bevelled or broken (a chamfer, a cap stone, moss, a lip) wherever the hero can stand next to them:
  cliffs, wall tops, steps, plinths.
- Silhouettes against the sky are irregular (crenels, roof ridges, trees), never a straight box top.

## 5. Scale (hero = 1.70 m)

| Thing | Size | In heroes |
|---|---|---|
| Hero, adult NPC | 1.70 m (large folk up to 2.3 m, small folk 1.1 m) | 1.0 |
| Door (a person's) | 1.95 m high, 1.25 m wide | 1.15 high |
| Great door / gate | 3.4-5.0 m high | 2-3 |
| Storey | 2.5 m ground floor, 1.9-2.1 m upper | 1.5 |
| Counter, stall table | 0.95-1.05 m | hip to waist |
| Bench seat | 0.45-0.5 m | knee |
| Step | 0.18-0.25 m high, 0.3 m or more deep | - |
| Barrel / crate | 1.0 / 0.8 m | hip |
| Lamp post | 3.2-4.2 m | 2-2.5 |
| Sign, plaque centre | 1.5-1.9 m | eye |
| Tree | 4.2-6.8 m | 2.5-4 |

Outliers are fixed, not excused: a door lower than the hero, a counter at shoulder height, a lamp globe bigger than a head and a half.

## 6. Foliage and ground

- Grass, weeds and flowers grow **along edges** (wall feet, path borders, cliff lips, around posts), not as an even scatter on open
  ground, and never on a road or a plaza.
- Every hub has small dressing that tells its Path's story (chalk and weights; crumbs and spilled sauce; sprouts through junk; stamped
  papers and queue ropes; confetti and petals after the fall).
- Zone boundaries are something: a cliff, a hedge, water, a fence, a wall, a treeline. Never bare void or an invisible wall on open
  ground.

## 7. VFX

- Soft, round, painterly: additive glows with a warm core, 6-12 particle sparks, no hard-edged quads, no pure white (the hottest pixel
  is cream or the Path's colour).
- Timing: fast in (60-120 ms), eased out (200-400 ms); a hit stops the frame for 2-3 frames only on big hits; screen shake is small
  (4-8 px), decays in 0.25 s and is off under Reduce motion.
- Each Path keeps its colour: Beefcake red-gold, Gourmand cream-orange, Refusemancer green-violet, Necrocrat ghost green, neutral gold.
- Ambient life is sparse and looping: birds, steam, leaves, flies, paper, sparkles - never more than three kinds in view.
- Everything has a Low fallback (fewer particles or off) and respects Reduce motion.
