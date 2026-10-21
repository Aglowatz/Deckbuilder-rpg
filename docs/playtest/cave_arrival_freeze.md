# v0.4.2 hotfix: "the game freezes when I first enter Crosspath after the cave"

Tester reports on v0.4.0: the game freezes on the first walk out of the Forgotten Cave into Crosspath. No tester godot.log files were in
`docs/playtest/logs/` (the folder does not exist yet), so everything below comes from reproduction.

## How it was reproduced (Part 1)

`tools/cave_arrival_repro_body.gd` plays the real flow like a tester: New Game on a Path, the cave's map nodes (each duel decided through the
real result panel and Continue), the rewards screens, **Step outside**, then Crosspath: Maren's welcome is pressed through with E and the
hero must walk. It is self-contained (no UiDriver), so it runs against an **exported pack** too:

    bash tools/run_cave_arrival_repro.sh                       # the project
    bash tools/run_cave_arrival_repro.sh <path to .pck>        # an export, run by the stock 4.7.2 binary
    CAVE_PATH=beefcake|gourmand|refusemancer|necrocrat  CAVE_MODE=normal|levelups|speed2x|continue|mash  COLD=1 (clear the shader cache)
    LOAD_TIMING=1 prints every build step (LoadTiming)

Machine: AMD Radeon integrated graphics, D3D12 Forward+. (The user's own Godot editor and a game it launched were open during the runs.)

| build | scenario | click -> fade-in | after the fade-in | hero freed |
|---|---|---|---|---|
| v0.4.0 export, cold shader cache | Beefcake | **19.6 s** black | 13 frames over 200 ms in 8 s, worst 897 ms | yes |
| v0.4.0 export | Gourmand | 15.7 s | worst 363 ms | yes |
| v0.4.0 export | Refusemancer | 15.6 s | worst 888 ms | yes |
| v0.4.0 export | Necrocrat | 15.2 s | worst 605 ms | yes |
| v0.4.0 export | 4 level-ups waiting | 17.9 s | worst 1380 ms; **LevelUpScreen opened during the fade, Maren's welcome opened on top of it** | yes |
| v0.4.0 export | 2x battle speed | 17.5 s | worst 288 ms | yes |
| v0.4.0 export | Continue from a save made in the cave | (resumes in the forest by design, back through the gate) | | yes |
| v0.4.0 export | keys/clicks mashed through the transition | 14.2-17.3 s | worst 1359 ms; Esc opened the pause menu during the welcome (backing out of it works) | yes |
| v0.4.1 export, cold | Necrocrat | **21.1 s** | 9 frames over 200 ms, worst 449 ms | yes |
| main (editor), before the fix | Beefcake | **24.9 s** | 9 frames over 200 ms, worst 1105 ms | yes |

**Correction (Part 2):** the "after the fade-in" column above overstates the stalls: the first repro bot looked for buttons with
`find_children` over the whole 3D town (thousands of nodes, six times every 0.25 s), which cost hundreds of ms per call by itself. The
bot now searches only the UI layers and also measures the first 5 s untouched. The **click -> fade-in** times are unaffected.

## Root cause

**The town is built in one frame, with nothing on screen.** Out of the cave, "Step outside" skips the loading screen
(`SceneManager.skip_loading_once`, Playtest v0.4.0 Part C) and fades to black for 0.2 s. `TownScene._ready` then builds the whole town
synchronously - the main thread does not return to the OS for 15-25 seconds:

| step (main, editor) | ms |
|---|---|
| TownBuilder.build | 1720 |
| TownSquare.build | 3369 |
| StyleRig.install | 1344 |
| WorldLookRig (sky, scenery, water, foliage) | 5349 |
| PaintedWorld.apply | 3616 |
| the rest (actors, spots, dressing, UI) | ~2000 |
| **one frame** | **~17 400** |

A black window that does not repaint or answer for 15-25 s is marked "(Not Responding)" by Windows after 5 s - testers saw a freeze and
some will have closed it. After the fade-in, `UiArtWarmup` built four big menu screens (300-900 ms frames each) while Maren was talking,
with all viewport input switched off for their frames (`gui_disable_input`), and sprite frames, footstep sounds and portraits were
loaded on the main thread the first time they were needed.

**The suspected input/lock deadlock did not happen in any run** (the hero was always freed when the dialogue was pressed through), but
the arrival was fragile: the welcome was three nested `dialogue.finished` callbacks with `_locked = false` only at the very end, popups
opened from `_process` during the fade (a LevelUpScreen under the welcome), and `UiArtWarmup` could leave the whole viewport deaf if a
screen build failed between `gui_disable_input = true` and `false`. Part 2 hardens all of it.

## The fix (Part 2)

**Loading** (`SceneManager.change_scene`, `TownScene`, `WorldLookRig`, `UiArtWarmup`, new `SceneWarmup` and `LoadTiming`):
- The cave exit shows the town's loading screen again (no more `skip_loading_once` there).
- Arriving through SceneManager, the town builds **in stages, one per frame** (`TownScene._stage`: TownBuilder, TownSquare, the outskirts,
  actors, spots, StyleRig, the look rig's sky / scenery / foliage / ambient, dressing, PaintedWorld, UI), so the loading screen keeps
  drawing and the window keeps answering. A town added directly (tests, tools) still builds in one go.
- SceneManager waits for `is_load_finished()` (at most 90 s): built, the first menu screens warmed (`UiArtWarmup`, now started at once
  and fully awaited), ~130 files on loader threads (`SceneWarmup`: every frame of the painted characters in town, footsteps and UI
  sounds, the town ambience, the zone title art, Maren's and the Wanderer's portraits), and - when the arrival opens with a level-up or
  a reward box - that screen opened under the cover. Then it draws frames behind the cover until 4 in a row are under 50 ms (at most 4 s).
- The game log gets one line per scene change: `load_timing: town <ms> (slowest step: ...); worst frame in the first 5 s after the
  fade-in: <ms>`. `LOAD_TIMING=1` prints every step.

**Arrival** (`TownScene`): the arrival is one queue - reward boxes, level-ups, the Path warning, then Maren's welcome in three parts -
each step opening when the previous one has closed (`ARRIVAL_ORDER`; reward boxes come before level-ups as everywhere else in the game).
The hero is held from the first frame (no hotkey or popup can open behind the fade) until the queue ends. `DialogueBox.interrupted`
moves the queue on if a conversation is ever replaced. A **lock watchdog** frees the hero, ends the queue and logs a warning after 4 s
locked with nothing on screen to close. `UiArtWarmup` can no longer leave the game deaf: if a warm-up screen stops mid-build, input
comes back after 30 frames. F8 (Report a Problem) and Esc work over every arrival screen (checked by the repro).

**Still slow (follow-up, not a freeze):** the longest single build step is ~2-4 s on this machine (TownSquare.build; the painted ground's
splat map, a per-pixel GDScript loop in `PaintedTerrain._paint_splat`; TownBuilder; the look rig's sky and scenery). The loading
screen draws between steps, but each of those is one frame.

## Verified on the exported v0.4.2 build (Part 3)

`bash tools/run_cave_arrival_repro.sh builds/_export/TheWaywardPath.pck`, stock 4.7.2 binary with the exported pack; the first run with the
shader cache cleared. During the Part 1 runs the user's own editor and a game it launched were also open; by Part 3 only the editor was,
so the loads are shorter for both versions - compare rows of the same session.

| scenario (v0.4.2 export) | click -> fade-in | longest single frame of the build | first 5 s after the fade-in, untouched | whole arrival | hero freed |
|---|---|---|---|---|---|
| Beefcake, **cold shader cache** | 16.7 s (loading screen up) | 4.3 s (TownSquare) | worst 80 ms | worst 80 ms | yes |
| Gourmand | 8.5 s | 1.1 s (painted ground) | worst 42 ms | worst 42 ms | yes |
| Refusemancer | 8.4 s | 1.1 s | worst 31 ms | worst 31 ms | yes |
| Necrocrat | 8.4 s | 1.1 s | worst 32 ms | worst 51 ms | yes |
| 4 level-ups waiting (level-up screen, then the welcome, in order) | 8.2 s | 1.1 s | worst 24 ms | worst 28 ms | yes |
| 2x battle speed | 8.2 s | 1.1 s | worst 39 ms | worst 43 ms | yes |
| Continue from a save made in the cave (forest, back through the gate) | 8.2 s | 1.1 s | worst 39 ms | worst 133 ms | yes |
| keys and clicks mashed through the transition | 8.9 s | 1.1 s | - | worst 44 ms (frames while a menu the mashing opened was up not counted) | yes |
| **v0.4.0 export, same session** | 8.0 s, **almost all of it one frame on a black screen** | ~7.5 s | worst 75 ms | worst 79 ms | yes |

F8 opened Report a Problem over the level-up screen and over Maren's welcome, Esc closed it, and Esc opened and closed the pause menu
during the welcome, in every run that checked it.
