# Player character look and camera angle test

A test bench, not a change to the game. `tests/characters/character_test.tscn` is the real town (`CharacterTest extends TownScene`, painted textures included) with two things swapped:
how the hero is drawn (three looks) and where the camera sits (four presets). No real game scene or script was touched, and the bench never writes the save.

**Launch it**

```
# from C:\Dev\Deckbuilder-rpg
"C:\Tools\Godot\Godot_v4.7.2-stable_win64.exe" --path . res://tests/characters/character_test.tscn
```

or open `tests/characters/character_test.tscn` in the editor and press F6. WASD / arrows walk, the mouse wheel zooms inside the current preset, `E` talks to whoever is nearby (the dialogue shots stand next to Elder Maren on the Gate Road).

| Keys | What |
|---|---|
| **1 / 2 / 3** | Character: current 3D model (hat and cloak as they are now) / HD-2D pixel sprite / painted 2.5D sprite |
| **F1 - F4** | Camera: Current / Classic RPG / HD-2D (tilt-shift + bloom) / Low and cinematic, blending over about 0.8 s |

A caption in the top-left shows the active look and preset. The hero starts just south of the plaza fountain.

Tools: `bash tools/character_shots.sh matrix` (all 36 shots, one Godot process, `--only_preset=N` for one camera), `... perf` (frame time per combination), `Godot --headless --path . -s res://tools/char_import.gd` (re-imports the art from `_art_inbox/character_test/`),
`tools/char_sheet.gd` (contact sheet of the cleaned frames). Test: `tests/characters/test_character_sprite.gd`.

## 1. The art import

Copied (never modified) from `G:\My Drive\Card Game Art\Character_Test` into `_art_inbox/character_test/`; the cleaned frames are in `assets/art/characters/{hd2d,painted}/` and the importer's report in `assets/art/characters/character_test_report.txt`.

**Nothing is missing:** CHAR-REF and all 18 frames (HD2D and 25D, FRONT / BACK / SIDE, IDLE / WALK1 / WALK2) were there.

What the files really were (worth knowing):

- Both sets were **already transparent** (alpha 0 at the corners); there was no plain background to remove. The 25D files carry a soft glow halo in the alpha channel (the magic hand), which is cut off at the figure's edge. CHAR-REF is the only opaque one (cream background) and is only a reference sheet.
- **HD2D is not a clean pixel grid.** It is a 128 x 128 cell image (1254 px / 128 = 9.8 px per "pixel") but the generator drifted: per-frame detection found a period of 9.05 - 10.65 px and different phases. Locking the period to 9.8 px and fitting only the phase per frame gave consistent figure heights (107 - 114 cells). Each frame is snapped to that grid (median colour of each cell centre), downscaled to the true pixel size (about 55 x 112 px figure), then **all 9 frames were re-coloured to one shared 40-colour palette** and put on one 84 x 116 canvas with the feet on the bottom row and the body centre on the middle column.
- The rainbow hand glow does not survive pixelation well (it turns into a few noisy red / green / blue cells). It is the first thing that looks "AI" in the pixel set.
- **25D painted:** glow cut, stray islands removed, one scale **per direction** (the mean of its three frames' heights, so the idle / walk swap never changes the figure's size), feet on one baseline, 384 x 576 canvas (about 8 MB of texture for all nine).
- Both sets keep lossless import with the 3D auto-compression turned off (VRAM compression would smear the pixel art).

Contact sheets: run `tools/char_sheet.gd` (`-- hd2d out.png` / `-- painted out.png`).

## 2. How the sprite looks are built

- `CharSprite` (`tests/characters/char_sprite.gd` + `.gdshader`): a quad drawn as a **full billboard** (it faces the camera, not the ground, so proportions are right at any pitch), feet on the node origin, no shadow casting, a `ContactShadow` blob under it.
- **Direction from movement relative to the camera:** FRONT when moving towards the camera, BACK away, SIDE otherwise (the art looks left; moving right mirrors it); nearest of the three on diagonals, with hysteresis so an exact 45 degrees does not flicker.
- **Walk cycle** IDLE, WALK1, IDLE, WALK2; cycles per second = speed / 1.3 m of stride (capped at 4/s), so the hero's 4.6 m/s is about 3.5 cycles/s. Idle: a slow breath (HD-2D: a one-texel lift, whole texels only; painted: a 1.2 % stretch about the feet).
- **HD-2D (key 2):** nearest filtering, hard alpha, unlit (palette-true). The card is sized so one texel is a whole (or half) number of screen pixels at the current camera and zoom (0.5 / 1 / 1.5 / 2 ... screen px; computed per frame with hysteresis).
- **Painted (key 3):** smooth filtering with mipmaps and a `light()` function: the card takes the sun, the lamp pools and the **coloured ambient**, and loses the sun inside a building's shadow (the shadow map's attenuation), so it is tinted by the local light and darkened in shadow instead of looking pasted on.
- Camera extras: **F3's tilt-shift** is a full-screen pass under the HUD (sharp band follows the hero's screen height, 14 disc taps, up to 9 px blur at the top and bottom) and the depth-of-field of the town camera is swapped out while it is on; **bloom** is the town's own glow with a lower threshold and higher intensity, blended in over the transition.

## 3. Camera presets (final numbers)

`dist` is at zoom 1.0; the town multiplies it by `Settings.camera_zoom` (default **1.5**, range 1.0 - 2.3), so the wheel works exactly as in the game inside every preset.

| Preset | Pitch | Distance (x zoom 1.5) | Field of view | Look-up | Extras |
|---|---|---|---|---|---|
| F1 Current | 53.3 deg | 13.72 (20.6) | 38 deg | 0 | the baseline, unchanged |
| F2 Classic RPG | 45 deg | 10.0 (15.0) | 38 deg | 0 | none |
| F3 HD-2D | 30 deg | 7.4 (11.1) | 30 deg | 2 deg | tilt-shift + soft bloom |
| F4 Low and cinematic | 20 deg | 7.0 (10.5) | 44 deg | 4.5 deg | more sky and distance |

(The same lines are printed to the console by every `matrix` run.) "Look-up" turns the view back up by that many degrees so the hero sits lower in the frame and more sky shows. Tuning was by eye on the town square: F3 got a longer lens (30 deg) so the compressed, miniature look reads; F4 a wide 44 deg so the horizon and the backdrop ring fit; bloom was turned down once after the first pass washed the plaza in yellow.

## 4. The 3 x 4 matrix (same spot, south of the plaza fountain)

Columns are the camera presets, rows the character looks.

| | F1 Current | F2 Classic RPG | F3 HD-2D | F4 Low |
|---|---|---|---|---|
| **1: 3D model** | ![](character_test/matrix_1_1.jpg) | ![](character_test/matrix_1_2.jpg) | ![](character_test/matrix_1_3.jpg) | ![](character_test/matrix_1_4.jpg) |
| **2: HD-2D pixel** | ![](character_test/matrix_2_1.jpg) | ![](character_test/matrix_2_2.jpg) | ![](character_test/matrix_2_3.jpg) | ![](character_test/matrix_2_4.jpg) |
| **3: Painted 2.5D** | ![](character_test/matrix_3_1.jpg) | ![](character_test/matrix_3_2.jpg) | ![](character_test/matrix_3_3.jpg) | ![](character_test/matrix_3_4.jpg) |

### Walking towards the camera (the walk frame is caught mid-stride)

| | F1 Current | F2 Classic RPG | F3 HD-2D | F4 Low |
|---|---|---|---|---|
| **1: 3D model** | ![](character_test/walk_1_1.jpg) | ![](character_test/walk_1_2.jpg) | ![](character_test/walk_1_3.jpg) | ![](character_test/walk_1_4.jpg) |
| **2: HD-2D pixel** | ![](character_test/walk_2_1.jpg) | ![](character_test/walk_2_2.jpg) | ![](character_test/walk_2_3.jpg) | ![](character_test/walk_2_4.jpg) |
| **3: Painted 2.5D** | ![](character_test/walk_3_1.jpg) | ![](character_test/walk_3_2.jpg) | ![](character_test/walk_3_3.jpg) | ![](character_test/walk_3_4.jpg) |

### With an NPC dialogue portrait open (Elder Maren)

| | F1 Current | F2 Classic RPG | F3 HD-2D | F4 Low |
|---|---|---|---|---|
| **1: 3D model** | ![](character_test/dialogue_1_1.jpg) | ![](character_test/dialogue_1_2.jpg) | ![](character_test/dialogue_1_3.jpg) | ![](character_test/dialogue_1_4.jpg) |
| **2: HD-2D pixel** | ![](character_test/dialogue_2_1.jpg) | ![](character_test/dialogue_2_2.jpg) | ![](character_test/dialogue_2_3.jpg) | ![](character_test/dialogue_2_4.jpg) |
| **3: Painted 2.5D** | ![](character_test/dialogue_3_1.jpg) | ![](character_test/dialogue_3_2.jpg) | ![](character_test/dialogue_3_3.jpg) | ![](character_test/dialogue_3_4.jpg) |

## 5. What the lower cameras reveal

Probe shots put the hero at the north, west, east and south ends of the map (from a `--run=probes` pass of the same scene; files are `probe_<side>_<preset>.jpg`). The camera never rotates and always looks north, so the north edge is the one that can show "beyond the world"; east and west show the sides of the diorama.

| North end (the Capital gate) | West end (the Verdant Dump) |
|---|---|
| ![](character_test/probe_north_1.jpg) F1 | ![](character_test/probe_west_1.jpg) F1 |
| ![](character_test/probe_north_3.jpg) F3 | ![](character_test/probe_west_3.jpg) F3 |
| ![](character_test/probe_north_4.jpg) F4 | ![](character_test/probe_west_4.jpg) F4 |

| East end (the Endless Buffet) | South end (the Gainlands) |
|---|---|
| ![](character_test/probe_east_4.jpg) F4 | ![](character_test/probe_south_4.jpg) F4 |
| ![](character_test/probe_south_3.jpg) F3 | ![](character_test/probe_south_2.jpg) F2 |

**F1 Current (53 deg).** From the town square the frame is all ground, so nothing is wrong there. At the map ends the water plane stops in a visible **jagged hex edge with a flat pale wedge behind it** (top corners of `probe_west_1` and `probe_north_1`). No horizon, no visible sky. This is the existing look; it only shows when the hero walks to the rim.

**F2 Classic RPG (45 deg).** Same as F1 but the pale wedge is larger and reaches further in (`probe_west_2`: about a third of the top edge). Still no real horizon: the sky shows only as that wedge. Plaza and streets are fine.

**F3 HD-2D (30 deg).** From the plaza the town reads well, because the backdrop ring of rocky hexes with pine trees sits right behind the buildings. Problems:
- at the rim the **water ends in a straight blurred line against an empty pale-lilac sky** (`probe_west_3`, top left), which the tilt-shift softens but does not hide;
- at the north end a **wall of the rock-and-pine ring fills the screen** (`probe_north_3`), so the hero is looking at the back of the backdrop (flat vertical faces, no overhang, repeated texture);
- zone labels (`Label3D`) sit at a fixed height and now float over the sky or crowd the hero (`The Verdant Dump`, `The Capital`);
- the bloom makes the pale sky look washed out.

**F4 Low and cinematic (20 deg).** The most revealing preset, and also where it looks most like a place:
- **Sky quality:** the procedural sky is a plain cream-to-lilac gradient with soft streaks; no sun disc, no real clouds, no horizon haze colour, and it clashes in warmth with the saturated green ground. It fills the top 15 - 25 % of the frame and looks like a flat backdrop, not a sky.
- **Backdrop ring:** convincing from the plaza (rows of cliff hexes with pines and the Capital's towers behind), but it is a **ring of identical rock hexes with the same pine on top**: the repetition is obvious at this height, and the ring is thin, with water showing through gaps (`probe_north_4`).
- **Empty horizon at the rim:** from the west and east ends the world is a handful of islands in an endless flat blue plane with a hard line where the water stops (`probe_west_4`, `probe_east_4`); nothing is placed past the edge.
- **Building backs and unfinished sides:** the Capital seen from the north is a stack of bare white and purple prisms with flat roofs and no back detail (`probe_north_4`, left). Only the Capital was checked from behind; the other zones' backs were not probed.
- **Near clutter:** grass tufts and signposts are close to the lens, and big foreground objects (the notice board, signposts) cover a lot of the frame (`matrix_*_4`).

What a low camera needs from the world is in section 7.

## 6. Comparison and honest notes

### Which combination fits the art

- **Card art, dialogue portraits and the painted textures are all soft, hand-painted, warm.** The **painted 2.5D sprite** is the only one of the three that is the same kind of picture (same brush edge, same palette: teal cloak, ochre shirt, brown boots). Elder Maren's portrait next to the painted hero in the dialogue shots looks like one world; next to the pixel hero it looks like two art directions.
- The **HD-2D pixel sprite** is internally consistent but is a *different* medium from the painted ground, the cards and the portraits. It works as a design when the whole screen is pixel-flavoured; here the textures under it are painted, so the sprite reads as a game-within-a-game. (Octopath-style HD-2D gets away with it because everything else is highly detailed and dramatically lit; our world is flat-lit toon.) It would need a dedicated pixel NPC set, pixel UI frames and likely pixel-flavoured ground to feel intentional.
- The **3D model** matches the toon world, the buildings and the NPCs (they are all KayKit models), but not the card art or the portraits. It is the least "ours" of the three, and the new painted portrait art makes that gap more obvious.
- **Best matches:** painted 2.5D with F2 or F3 (it takes the lamp light and the shadows, sits well under the tilt-shift). The 3D model with F1 is the safest as it needs nothing else. HD-2D with F3 is the most striking single image but the least coherent with the rest of the game.

### Readability

- **F1:** all three looks are small (very roughly 45 px for the 3D model and 60 px for the cards at 1600x900; HD-2D snaps to half-size texels, and the pixel detail is lost). At F1 the faces and the cloak shape are unreadable for every look; the 3D model's chunky silhouette is clearest.
- **F2 - F3:** the sprites are about 100 - 175 px tall and read clearly; painted shows face and hands, pixel shows a clean silhouette. F3's tilt-shift keeps the hero sharp and everything near the top and bottom soft, which also guides the eye.
- **F4:** the figure is about 110 px; readable but easily lost behind foreground props (grass and signs); lamp posts and the notice board cover the hero if they line up (the first matrix attempt had the hero behind a lamp).
- Sprite sizes were chosen at 1.0 m tall (the 3D model is about 0.7 m); by the snapping rule the pixel sprite drifts from about 0.9 m (F1) to about 1.3 m (F2) (computed, not measured on screen) because it snaps to whole texels, so the hero gets a bit bigger when the pixel look and the camera interact. That is inherent to pixel art on a perspective camera.

### Animation quality

- Direction logic works (front / back / side with mirroring, hysteresis on diagonals). Walks in the shots catch the WALK frames.
- **Only three poses per direction**, so the cycle is IDLE - WALK1 - IDLE - WALK2: it reads as a "step, pause, step" shuffle, not a smooth walk, especially at the hero's brisk 4.6 m/s (about 14 fps of drawing). It looks acceptable for pixel art (it is a classic cadence) and stiff for the painted version, where a smooth 3D walk exists today.
- **Frame-to-frame consistency is imperfect in the source art:** the cloak shape changes a lot between frames (it flares in WALK1/WALK2 and hangs in IDLE), the side-walk frames are 70 - 80 px wide vs 43 px for the idle, so aligning by centre of mass makes the body slide a little when the cycle changes. The painted hand glow changes colour per frame. These would be fixed by re-generating with a rigid style sheet or by hand-cleaning, not by code.
- Turning is instant (a pop between FRONT, SIDE and BACK), while the 3D model turns smoothly. A sprite approach usually adds a diagonal pair (front-left, front-right, back-left, back-right) to hide this.
- The 3D hero keeps its real animations, idle, walk, and the hat / cloak sway.

### Performance (Ryzen 5 4500U iGPU, 1600x900, Medium quality, vsync off, three seconds per cell, run alone)

| Look | F1 | F2 | F3 (tilt-shift + bloom) | F4 |
|---|---|---|---|---|
| 1: 3D model | 64.6 fps (15.5 ms) | 64.9 fps (15.4) | 55.5 fps (18.0) | 65.5 fps (15.3) |
| 2: HD-2D pixel | 64.8 fps (15.4) | 65.4 fps (15.3) | 55.5 fps (18.0) | 66.1 fps (15.1) |
| 3: Painted 2.5D | 64.8 fps (15.4) | 65.3 fps (15.3) | 55.4 fps (18.0) | 66.1 fps (15.1) |

Draw calls 596 / 519 / 425 / 696 for F1 - F4 (the low camera sees more of the scenery and fewer meshes get culled). On this iGPU numbers are noisy by +-5 fps, so read it as: **the character look costs nothing measurable** (one quad vs one skinned model); **the camera costs a little**: F3's tilt-shift and bloom pass cost about 3 ms (60 -> 55 fps), and F4 draws the most (about 100 more draw calls than F1) but still held the same fps. F3 stays above 50 fps; if the 60 fps Medium target must hold, the tilt-shift taps (14) and radius are the lever, or run it only on High.

### What each lower camera would require from the world

- **F2 (45 deg):** almost nothing. Better pale-wedge fix at the water edge (extend the water plane, or fade it into the fog colour), otherwise ready.
- **F3 (30 deg):** a **real horizon**: extend the water plane out to the fog distance (or fog it so the line vanishes), a **sky that matches the painted look** (painted cloud layer, sun glow, warmer horizon band instead of the plain gradient), and dressing for the **north-end backdrop ring** (the back of the cliff ring is bare). Zone labels must scale with the camera (or fade by pitch).
- **F4 (20 deg):** all of F3 plus **distant scenery** (silhouette mountain ranges and far islands beyond the ring, with aerial perspective: bluer, hazier, lower contrast with distance), a **proper skybox** (painted clouds, sun, gradient that ties to the ground colours), a **second backdrop ring** or distance layer so the thin ring does not show water behind it, **varied hex cliffs** (the repetition is obvious), finished backs on gateways, the Capital and the arena, and a **clutter pass** (lower grass near the camera, smaller signposts, fade foreground props). It also calls for the occlusion fader to treat tall props between camera and hero (it already exists for walls).
- Rough effort guesses (not measured): F2 about half a day; F3 about 2 - 3 days (water and sky, plus the label fix); F4 about 1 - 2 weeks (sky, distant layers and a back-side pass over every zone, repeated per zone since each zone has its own backdrop).
- Every zone would need the same checks; this test only looked at the town.

### Effort to extend each approach to all NPCs

There are 13 `_add_npc` placements in town (vendors, elder, guard, tailor, mannequin, arena, alchemist, the four corrupted NPCs, the pack vendor), plus every zone's NPCs, enemies and bosses on the world side.

- **3D model (today):** zero art; every NPC is a KayKit model with tint. Hat and cloak cosmetics already work (`HeroModel`, `CosmeticMeshes`, `CloakSway`) for any hero-shaped NPC (the tailor and the mannequin use them).
- **Painted 2.5D sprites:** per NPC, most stand still and turn to face the player, so the cheap version is **one front idle frame (plus two for a breath) = 1 - 3 images**; a walker needs 9 (like the hero). The hero's set is 9 frames per look plus cleanup, and the cleanup tool is reusable (`tools/char_import.gd`). For the 13 town NPCs: about 13 - 40 images; for every zone's characters: a few hundred images, plus art direction to keep one painter's hand. The shader and billboard are written. Facing the player is replaced by a mirrored FRONT / SIDE frame, so NPCs that look away would need BACK frames.
- **HD-2D pixel sprites:** the same image counts, but each needs the grid cleanup, one shared palette, and consistent pixel size; the AI generator drifted on the hero, so expect hand fixing. The extra cost is mostly *style*: the portraits, the ground and the UI would need a pixel pass to match.
- **Hats and cloaks (12 hats, 11 cloaks, dyes):**
  - **3D model:** done, procedural and dyeable.
  - **Sprites:** the cloak is **baked into the art** (the base figure wears the teal cloak), so a different cloak means a different set of frames. Realistic options: (a) **layers:** regenerate the body without cloak or hat, then draw each cloak and hat as separate layers per direction and per frame (3 directions x 3 frames x 23 items = 207 layer images, plus an anchor table so hats follow the head's bob), dyes via a palette-swap shader (clean for pixel art, because the palette is shared; fine for painted if the layers are greyscale); (b) **bake full sets per outfit:** 9 frames x each combination, which explodes (12 x 11 combinations); (c) **a hat-only system:** hats as 3-direction layers (36 images, anchored to the head) and keep the cloak fixed, dropping cloak cosmetics for the sprite look. (a) is the real cost: about 2 - 3 weeks of art plus anchor tooling, and the cloak sway (cloth physics today) would become hand-drawn flare frames. The "cloak shows from the back" cases are also where the generator's inconsistency would hurt most.
  - **Hat on the dialogue portrait / character screen:** unaffected, those are separate.
- Sprites also lose today's free features: the idle / walk blend, per-NPC tint is easy (a uniform), but the **ninja**, **tortoise shell** and **mount** attachments would need sprite versions.

### Recommendation (opinion)

Keep the **3D model** as the shipping hero for now, since it carries cosmetics, animation and the existing NPC set. If the game moves towards a painted look, try the **painted 2.5D** card with the **F2 Classic RPG** camera first: it needs the least from the world and matches the portraits and cards best. Adopt **F3** only with sky and horizon work and a decision on the tilt-shift cost; **F4** is the most atmospheric and the most expensive. HD-2D is a strong look but a style change for the whole game, not a character swap.
