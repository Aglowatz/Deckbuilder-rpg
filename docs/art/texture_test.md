# Painted ground texture test

Test only: the real scenes are unchanged. Scene: `tests/textures/town_square_textured.tscn` (extends `TownScene`, like the papercraft test). Press **T** to switch between the painted ground and the current flat ground (T opens the wardrobe in the real town; here it is the toggle). The real save is never written.

Run: `godot --path . res://tests/textures/town_square_textured.tscn` (F6 in the editor). Screenshots: `bash tools/shot.sh res://tests/textures/town_square_textured.tscn <name> --tex=1|0 --nohud=true [--cam=x,y,z] [--zoom=1.0..2.3] [--pos=x,z]`; dialogue: `bash tools/dialogue_shots.sh <scene> <prefix> elder --tex=1|0`.

## Import (`bash tools/import_texture_test.sh`)
Source (copied only): `G:\My Drive\Card Game Art\Texture_Test` - TEX-TOWN-GRASS, TEX-TOWN-WILDFLOWER, TEX-TOWN-STONE (1024 px PNG). Output in `assets/art/textures/`: `town_<name>_albedo|normal|rough.webp` (mipmaps on).
- **Seamless:** half-offset cross-blend limited to a 12-16 % band along the borders, so the painted middle stays untouched. Edge step vs. neighbour step went 2.07 -> 1.16 (grass), 1.73 -> 1.14 (flowers), 1.45 -> 0.94 (stone); 1.0 = invisible.
- **Normal:** from a twice-blurred luminance height (soft relief, not noise), wrap-around Sobel, OpenGL convention. **Roughness:** from luminance (light stones smoother, cracks and moss rougher).

## Shader (`assets/shaders/style_painted_ground.gdshader`)
- World-space, stochastic triangle-grid tiling (random rotation + offset per triangle, sharpened blend, `textureGrad` so mips never seam): no tile grid at any zoom.
- Grass everywhere; wildflower patches from two-octave noise masks (soft edges); stone inside the plaza radius with a noisy edge. Large-scale value and warm/cool tint patches on top.
- Same toon bands and global style uniforms as `style_terrain`. Normals only lean the surface slightly and fade out with distance (default camera: nearly flat, painted look); roughness drives a faint sheen on the lit band only.
- Opaque with a dithered edge fade at 34 m; the ground is a 1 m grid over the island's walkable cells, just above the hex tiles and under the road decals.
- In painted mode the flat ground's moss patches and plaza paving discs are hidden; roads, crest, props, buildings and characters stay as they are (roads keep their current cobbles, only the plaza uses the stone texture).

## Performance (iGPU, `tools/fps.sh`)
Medium: 57 fps (flat town 60); Low: 117 fps. The normal maps are the costly part and only run within 18 m of the camera.

## Screenshots (left: painted, right: current flat ground)
`docs/art/screens/textures/`: A (default camera), B (`--cam=0.6,1.3,2.4`), C (`--cam=5.5,2.4,1.6`), zoomout (`--zoom=2.3`), zoomin (`--zoom=1.0`), flowers, dialogue_elder (Elder Maren's portrait).
