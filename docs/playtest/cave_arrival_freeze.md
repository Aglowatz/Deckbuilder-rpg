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
with all viewport input switched off for their frames (`gui_disable_input`), and the first draws of the town's materials added more
stalls: 2-13 frames over 200 ms in the first ~8 s.

**The suspected input/lock deadlock did not happen in any run** (the hero was always freed when the dialogue was pressed through), but
the arrival was fragile: the welcome was three nested `dialogue.finished` callbacks with `_locked = false` only at the very end, popups
opened from `_process` during the fade (a LevelUpScreen under the welcome), and `UiArtWarmup` could leave the whole viewport deaf if a
screen build failed between `gui_disable_input = true` and `false`. Part 2 hardens all of it.
