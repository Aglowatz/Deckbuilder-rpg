# Sound pass - gaps and tonight's sounds (Overnight Oct 30-31, Part 8)

The audit first, then what was added. Sources: the bank (`data/audio/sfx_bank.json`, built from `data/source/sfx_events.csv` by
`node tools/sfx_build.js`), the global UI hook (`app/ui_sounds.gd`: every Button, tab and slider), the battle sounds
(`ui/battle/battle_sounds.gd`), the ambience profiles (`core/audio/ambience_profiles.gd`), the first-battles smoke's sound counts and the
sound check (`bash tools/run_sfx_check.sh`: every event and profile through the real mixer). No new recordings; everything is built from
sounds already in the game.

## Gaps found

| Where | Gap | Now |
|---|---|---|
| Dungeon node maps (every dungeon) | `Audio.set_ambience("none")`: music only, silence under it between cues | a quiet bed per dungeon from its zone's own sets (`dungeon_cave / gainlands / dna / buffet / heap / capital`, -10 to -20 dB; `ZoneSoundscape.dungeon_profile`) |
| Goal pointer (new, Part 2) | a goal changing (a step done, a new quest tracked) was silent | `goal_update`: a paper tick and a glass tap, once per new goal (not on the first refresh of a scene) |
| Sprint (new, Part 3) | no cue | `sprint_start`: a short soft whoosh when the hero breaks into a run; the footsteps follow the faster walk cycle by themselves |
| Fast travel from the map (new, Part 3) | - | the Rift Express's own `rift_open` |
| Attack previews (new, Part 4) | - | the existing `preview_tick` / `preview_lethal` (a paper tick, a knock and a heartbeat on a lethal aim) now also play for aimed cards, abilities and Resources |
| Deck Station (new, Part 7) | - | filters `ui_tick`, Suggest a deck `deck_sort`, the Suggest buttons through the UI hook |
| Dialogue (Part 6) | the voice ticked on a 70 ms timer, kept ticking after a skipped line | one blip every 2 letters as they appear, silent once the line is complete |
| Feats | - | already: the `STG-SECRET` sting with the toast (unchanged) |
| Zones / town / forest / Capital | - | every walkable area already has its bed and one-shots (forest, town, Gainlands, D.N.A., Buffet, Dump, Capital outside / inside / districts) |

Not changed: the battle scene's ambience (music only, deliberate), the settings sliders (unchanged), the black market.

## Loudness by category

`node tools/sfx_loudness.js [--apply]` measures every event offline with ffmpeg's ebur128 (the loudest momentary loudness, 400 ms window, as
the game plays it at rest) and pulls events more than 5 LU from their category's median toward it (at most 4 dB a run). Before:
`docs/audio/loudness_oct31_before.md`; after: `docs/audio/loudness_oct31.md`. 21 events moved (deaths and big spells down 1.5-2.5 dB,
`gate_big` / `chest_giant` / `arena_cheer` down, `ui_back`, `card_return`, the two spend sounds up). Exempt by design: the two hover ticks (the
quietest sounds in the game because they fire constantly), `sprint_start` (soft on purpose), `sign_read` (raising it peaked at -0.2 dBFS).

| Category | Events | Spread p10-p90 before | after |
|---|---:|---:|---:|
| Battle | 49 | 9.0 LU | 7.3 LU |
| Resources | 13 | 8.9 LU | 7.9 LU |
| UI | 37 | 9.4 LU | 7.6 LU |
| World | 27 | 7.4 LU | 7.5 LU |
| Footsteps | 15 | 3.2 LU | 3.2 LU |

Sound check after the change: 170 rows, every ambience profile (the six new dungeon beds included) audible, 0 silent; one event over
-1 dBFS on its bus, `thrower_land` at -0.9 dB (as before tonight).
