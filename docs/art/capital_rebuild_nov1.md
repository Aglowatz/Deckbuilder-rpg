# Capital inner-city rebuild (Nov 1-2)

Everything inside the great wall rebuilt to match the target `docs/art/paintovers/PAINTOVER-CAP-INNER-CITY.png` (also on the Drive under
`Approved_ZoneKits/Capital/`): a tyrant's dream of perfection - grand, symmetrical, spotless, slightly too perfect. Zone id `final`,
`scenes/capital_zone.tscn`, the code under `world/capital/`. The brief's Parts A-G; judgment calls are logged in `docs/overnight_inbox.md`
("Capital rebuild Nov 1-2"). Rules kept: only art already in the game or approved on the Drive (new geometry built in code from the kit's textures
and meshes is fine); the dialogue freeze; one Godot at a time; the gameplay inside the walls (every road, NPC, spot, sign, rift, entrance, the tram,
the Lost Property spot, the Crease, the roamers, the drain logic, the hidden hole and the gate) keeps working and the Capital tests stay green.

Shots: `bash tools/capital_rebuild_shots.sh <phase> [prefix,...]` writes the same standard spots every iteration into
`docs/art/capital_rebuild_nov1/<phase>/` (1280x720 JPEG, no HUD, gate open, enemies held, districts broken): `ref` (the target's framing: on the
boulevard south of the fountain, looking north up the axis to the castle), `ref_mid` / `ref_play` (the same spot from the Classic and the play
camera), `gate_plaza`, `inner_gate`, `boulevard`, `fountain`, `palace_approach`, `transit_yards`, `hungry_quarter`, `grave_row`, `the_reek`,
`overview`. Coordinates below are world metres (x east, z south, the camera looks north); the great wall stands on rows z 72-75, the city inside
is x 2..116, z 2..71, the castle hill fills x 47..74, z 0..12 and the palace stands beyond it.

## The target

![](paintovers/PAINTOVER-CAP-INNER-CITY.png)

## Part A: the audit

Before shots (`docs/art/capital_rebuild_nov1/before/`):

| | |
|---|---|
| ![](capital_rebuild_nov1/before/ref.jpg) the target's framing | ![](capital_rebuild_nov1/before/ref_mid.jpg) the same spot, Classic |
| ![](capital_rebuild_nov1/before/gate_plaza.jpg) the Gate Plaza | ![](capital_rebuild_nov1/before/fountain.jpg) the fountain |
| ![](capital_rebuild_nov1/before/boulevard.jpg) the boulevard | ![](capital_rebuild_nov1/before/palace_approach.jpg) the palace approach |
| ![](capital_rebuild_nov1/before/transit_yards.jpg) the Transit Yards | ![](capital_rebuild_nov1/before/hungry_quarter.jpg) the Hungry Quarter |
| ![](capital_rebuild_nov1/before/grave_row.jpg) Grave Row | ![](capital_rebuild_nov1/before/the_reek.jpg) the Reek |

What the before shots show against the target, point by point of the brief:

| Target | Now | Decision |
|---|---|---|
| 1. A grand processional boulevard on one axis, the skyline stepping up to the castle | The axis exists (gate - fountain - avenue - stair - castle, x 60) but nothing rises along it: 4 m houses, 3.6 m lamps, a flat 9 m wall; the castle is a pale flat plate behind heavy haze and the far blur | keep the axis and every route; make the skyline (townhouses 12-18 m, towers 16-26 m, the castle sharper) and widen the paved boulevard visually |
| 2. Tall ornate townhouses in mirrored identical rows | Sixteen 4 x 4 m one-storey houses with hipped pink roofs and a painted door; two awning shops | a modular grand townhouse generator (storeys, bays, roof, balcony, arches, pediment, trim, flower boxes, banner) on the same sixteen footprints and the same doors (the "Try the door" spots stay); a second rank of taller ones behind |
| 3. Slender towers with pointed spires | none inside the city except the castle's | tower pieces (the kit's `spire` grown: a banded shaft, a balcony ring, a lancet lantern, a pink/blue/gold cone) at the plaza's four corners, the avenue's ends and the districts' corners, taller toward the castle |
| 4. Gilded Primm statues on tall plinths in pairs | one painted gold Primm on the fountain | the painted statue card (CAPI-PROP-PRIMM-STATUE: gold Primm on a laurel plinth, exactly the target) on a tall white-and-gold plinth, in mirrored pairs flanking the boulevard; toppled once Primm falls |
| 5. The fountain as a formal plaza's centrepiece | a 6.6 m single basin with a middle tier, eight rose posts, four jets, a 4.2 m statue | a tiered basin (three tiers, 9.4 m across), more water, the statue higher; a formal ring round it: a gold-bordered walk, four parterre quadrants, eight lamps |
| 6. Formal gardens only | lawn stripes with rows of topiary / rose / lamp cards along the white roads, wildflower clumps in Grave Row | geometric parterres: white planters with gold trim holding rose beds in straight runs, topiary cones in gold urns at every corner, lawn panels bordered by white paths; the clumps go |
| 7. Crisp checker plazas framed by white-and-gold borders | a 1 m pink/sage/cream checker over the whole inside | 2 m checker panels on the plaza and the boulevard framed by white borders with a gold line, cream streets elsewhere, a polish sheen |
| 8. Pink lamp posts, sun-face banners in identical sets | 3D ornate lamps with a gold pole; banners only on the gate towers and two plaza signs | the kit's pink globe lamp (CAP-PROP-LAMP) everywhere inside, as one MultiMesh; the sheet's sun banners on every townhouse, lamp pair and tower, the same angle |
| 9. Bright clean noon, warm gold, soft shadows, light haze, backdrop beyond the wall | washed out: the inside fog + the castle's own haze + the far depth blur grey everything past 30 m; the CAP-BD-CITY ring is lost behind the wall | Part D: thinner fog, haze only beyond the castle, a warmer sun, a sheen on the gold, less far blur in the Capital, the backdrop raised |
| 10. No scatter | the inside is already rows, not scatter, except Grave Row's flower clumps and the rose posts | remove the clumps; every piece in a row |
| 11. A few identical citizens | nine KayKit knights with a ":)" label, pale | keep nine, keep them identical, no change to their spots |
| 12. Eerily perfect touches | mirrored rows | exact symmetry everywhere; one banner a degree off per plaza |

The plan:

- **Axis**: unchanged (`CapitalLayout` routes). The boulevard is the avenue (x 57..63) plus its verges to the house fronts (x 53.5..66.5): the whole
  13 m reads as one paved boulevard with a white-and-gold border at the house line.
- **Buildings**: the sixteen footprints stay (x 43.5 / 49.5 / 66.5 / 72.5, z 19.5 / 26.5 / 33.5 / 40.5, 4 x 4 m), so every door spot, citizen alley and
  the walkability stay as they are; the inner columns become three-storey townhouses (12 m), the outer columns four-storey (15 m) so the skyline
  steps up away from the boulevard and nothing near the camera hides the hero (the camera looks north; the tallest masses stand at the sides).
- **Towers**: 2 x 2 m footprints on lawn, off every route and spot: the plaza's four corners (16 m), the avenue's north end either side of the
  forecourt (22 m), one at each district's corner (14 m).
- **Gardens**: parterres in the plaza's four quadrants and the lawn panels between the ring streets and the houses; the districts' lanes keep
  their planters.
- **Removed**: the Grave Row flower clumps, the generic lamp model, the old row pattern inside the Showcase (replaced by the parterres).
- **Pieces** (Part B, `world/capital/capital_grand.gd`): townhouse, tower, plinth + statue, fountain, planter run, urn + topiary, lamp, banner set,
  paving border, balustrade.
