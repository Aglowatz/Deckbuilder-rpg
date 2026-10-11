# Painted ground texture test (retired)

The test scene (`tests/textures/town_square_textured.tscn`) and its importer were retired when the real Main Town got the painted textures (see "Painted textures" in `docs/art/style_guide.md`). What it proved lives on in the real system:

- the seam fix (half-offset cross-blend over a narrow band) is `tools/import_textures.gd`;
- the stochastic triangle-grid tiling, large-scale variation, normal lean and toon bands are `assets/shaders/style_painted_terrain.gdshader`;
- the T toggle is now Shift+T in debug builds (`PaintedWorld`), because T opens the wardrobe;
- the town's painted/flat comparison screenshots are in `docs/art/screens/textures/town/` (before/after, 3 angles + dialogue).

The original test screenshots stay in `docs/art/screens/textures/` (A, B, C, zoomin, zoomout, flowers, dialogue_elder).
