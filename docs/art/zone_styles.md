# Zone style files

`data/zone_styles/<area>.json` holds everything the Art Bible fixes per area. Edit a file and save: in a debug build the running scene picks light, fog, grade, bloom and kit tints up within a second (`ZoneStyleWatcher`). Material swaps are read when buildings are built, so they apply at the next scene load.

| Area file | Style preset | Scene |
|---|---|---|
| `main_town` | `town` | town |
| `starting_forest` | `start` | starting area |
| `gainlands` | `gainlands` | Gainlands zone |
| `dna` | `dna` | D.N.A. zone |
| `buffet` | `buffet` | Endless Buffet zone |
| `heap` | `heap` | Verdant Dump zone |
| `capital_outside` | `capital_outskirts` (+ `capital_dark`) | Capital, outside the wall |
| `capital_inside` | `capital_inside` (+ dark, freed) | Capital, inside the wall |
| `castle_grounds` | (none yet) | Primm's Castle courtyard |
| `pathology_lab` | `lab` (none yet) | Lab hatch yard |

## Keys

| Key | Meaning |
|---|---|
| `time_of_day` | The Art Bible's fixed time of day (documentation) |
| `palette` | Hex codes, first = dominant (documentation + `ZoneStyles.palette()`) |
| `light.key_color/key_energy/key_pitch/key_yaw` | The one key light |
| `light.ambient_color/ambient_energy` | The ambient fill (coloured shadow) |
| `fog.color/density` | Haze |
| `grade.warmth` | World look warmth |
| `grade.post_saturation` | Saturation of the post pass |
| `grade.saturation/contrast` | Preset-level grade |
| `bloom.intensity/threshold` | Glow |
| `vignette` | Darker frame edges |
| `material_swaps` | `{kit id: kit id}`: which kit surface this zone uses |
| `tints` | `{group: colour}`: neutral kit textures recoloured by group (`wall`, `trim`, `roof`, `ground`, `prop`, `tree`, `decal`, or a slot family such as `awning`, `door`, `window`, `sign`) |
| `tint_strength` | 0..1, how far tints move toward their colour |

Code: `ZoneStyles` (data, swaps, tints), `StylePresets.get_preset` (light/fog/grade), `WorldLookRig.mood_for` (warmth, bloom, vignette), `EnvKit.material` (swap and tint, `EnvKit.retint()` for hot reload).
