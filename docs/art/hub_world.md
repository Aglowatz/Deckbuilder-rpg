# The hub world (Oct 16, Block 3)

The main zone outside the town square, rebuilt as one country instead of an island in a sea. Code: `world/hub/` (`HubLand`, `HubObstacles`,
`UndercroftHouse`, the ground and road shaders), the land mode of `WorldScenery`, `TownBuilder.hub_land`. Gatekeeper data: `core/zone/gatekeepers.gd`.
Decisions ON-22..28 in `docs/design/open_questions.md`. Screenshots below are in `docs/art/hub_world/` (`bash tools/hub_shots.sh` remakes them;
`--gates=open` shows the cleared roads). The walk smoke: `bash tools/run_hub_walk_smoke.sh`.

## What changed
- **No sea.** Painted land runs to the horizon (soft patches of darker woods and dry meadow); the town keeps its lake (the south-east bay round the
  giant chest's peninsula) and its little ponds, and two lakes lie out in the country. The visual islands and their bridges are gone.
- **Five roads with their own character**, each continuing from its passage to the horizon: a winding forest path under tall pines and oaks
  (the Verdant Dump, west), a cracked roadway with dead street lamps and dead trees (the D.N.A., south-west), a sunny meadow road with
  sunflowers and hay ending at a gorge (the Gainlands, south), an orchard lane between rows of fruit trees (the Endless Buffet, east), and a
  dead-straight imperial road between dark pine walls (the Capital, north).
- **The obstacles** (gatekeeper beside each): the gorge bridge (drawn up / lowered and connecting), the permit barrier and checkpoint booth (the
  striped arm rises), the great pantry door in its stone frame (it swings open), the thorn wall of twisted trees and brambles (it withers and
  sinks). Each clears with an animation right after its gatekeeper's first defeat.
- **The edges.** The flat hex tiles and the rocky rim blocks are gone (the painted ground reaches just past the walkable edge, HubLand's
  ground continues it); a belt of trees rings the town and thins into groves; the far tree line, hills and mountains stand in haze beyond.
- **The Capital on the horizon**: the Capital's painted wall-and-castle card stands on the imperial road's axis at 275 m, hazy.
- **The camera** pulls back only 12 percent near a road's end, and settles in about a second.
- **The Undercroft**: the colosseum is gone; an abandoned cottage (boarded windows, weeds, a leaning tree) stands at the end of Champions'
  Road, with a cellar hatch chained shut until the first zone is free; then it glows and a muffled crowd roars below when the hero is near.

## Look at these
| Shot | What to check |
|---|---|
| `road_refusemancer.jpg`, `road_necrocrat.jpg`, `road_beefcake.jpg`, `road_gourmand.jpg`, `road_final.jpg` | each road's character from its passage |
| `gate_<zone>_locked.jpg` / `gate_<zone>_open.jpg` | each obstacle and its cleared state, the gatekeeper beside it |
| `capital_horizon.jpg` | the imperial road and the hazy Capital at its end |
| `undercroft_house.jpg` | the abandoned cottage and its hatch (first zone free) |
| `edge_<angle>_<zoom>.jpg` | the map edge from all nine camera combinations (Cinematic / Classic / Overview x Close / Normal / Far) |

## Known limits
- The south road's drawn-up bridge cannot be seen from the north-looking camera (it rises behind the lens); the locked state reads as a gorge
  with the far posts and the crank, the lowered bridge reads clearly.
- The painted ground and HubLand's grass are tuned to match but not identical; a faint seam can show where the painted ground ends.
- The obstacles and the Undercroft cottage's boards are built from textured blocks (kit textures, no flat colours); concept art for the four
  obstacles would let them become proper kit models (see the art needs list in the overnight report).
