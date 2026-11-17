# L items from Nov 17 - plans the owner can hand to a smaller session

Each is one session's work on the $20 plan if split as written. Start every prompt with the HANDOFF line ("Repo C:\Dev\Deckbuilder-rpg,
Godot 4.7.2. Read CLAUDE.md first. One Godot at a time. Don't export unless I ask.").

## L1. The D.N.A. stops reading as a greybox (art critic A2, 3.5/10 for the zone)

1. **Wall bays** (one session): in the D.N.A.'s room builder (`world/dna/`), split every wall run longer than 4 m into bays: a pilaster
   (painted trim strip, 0.4 m) every 3 m, a skirting band (0.3 m, darker) and a crown moulding (0.25 m). Same painted textures, no new art.
2. **A grime gradient**: a vertex-colour darkening from the floor up (0 -> 1.2 m, 25 %) on every wall mesh, as Crosspath's walls do.
3. **The white light quads**: replace with the town kit's lantern/sconce model and a small warm OmniLight3D (only on Medium+).
4. **The faceted orb at the hub's top centre and the white cubes**: find them with the play-script `meshscan` command at the hub
   (`dna_hub_default` shot); replace the orb with the zone kit's clock or statue piece, give the cubes the paper-stack card or delete them.
5. **Blank signs**: give them their sign icons (`IconSign`) or remove them.
Check: `bash tools/nov12_shots.sh <tag> dna` before and after; `bash tools/run_dna_walk_smoke.sh`.

## L2. The Capital's facades and floor (art critic A3)

1. **The checker floor**: desaturate the plaza's paving colours about 30 % and add a grout line (the paving shader's colour pair in
   `capital_materials.gd`); one constant per colour.
2. **Facades**: put Crosspath's painted plaster albedo (brush grain) under the pastel accent colours as a multiply (`CapitalGrand`'s
   `accent_*` materials), and add a 1.5 m dirt gradient at the foot of every house (vertex colour, as L1.2).
3. **Bloom**: lower the Capital's glow in its two style presets (`StylePresets.capital*`) until white plaster stops clipping.
Check: `nov12_shots.sh <tag> capital_before capital_after`; the Capital walk smoke (the camera-band gotcha: never move geometry).

## L3. The primitive sweep (art critic A5)

1. List every untextured primitive the critic named (Buffet hub: lime cabbage spheres, the navy brick cube, a red cube, the orange box
   with X eyes; the Dump: the pink "pig" cube, olive topiary spheres; Crosspath: a white box lantern, pastel gem blobs; Gainlands: a
   magenta bar) with `meshscan` at each shot's place.
2. For each: swap for the zone kit's painted piece of the same role (cabbage -> the kit's veg card; cube crate -> the kit's crate card),
   or give it the zone's painted triplanar material and the outline, or delete it. One zone per session.

## L4. The Gainlands' rock and brick (art critic A8)

1. The plateau's cliff faces (`gainlands_terrain.gd`): add a second noise octave to the wall vertices and break the stepped rows with a
   slight lean, so they read as sculpted rock; scale the rock texture by world size (no stretching).
2. The fortress brick: a second brick variant per face and vertex dirt at the base. The blue-grey curbs: the sandstone material.

## L5. An intent strip for bosses (combat critic C4)

Show what the foe will do next turn, as Slay the Spire does: during the boss's setup turns a small strip over its portrait reads
"Next: summons 2 units" / "Next: attacks with everything" from the boss's scripted events (`data/encounters/encounter_scripts.json`
already holds the turn-by-turn plan) and, for normal foes, the AI's intended attack count after its main phase. One session for the
display from the scripts (no AI change), a second for normal foes. **Needs the owner's yes**: it changes how fights read.
