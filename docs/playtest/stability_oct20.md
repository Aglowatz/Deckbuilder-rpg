# Overnight Oct 20-21: playtest stability on testers' PCs (v0.4.3)

Evidence (v0.4.0, two testers, Intel integrated graphics, both D3D12 Forward+):

- Tester 1: Intel Arc 130V (HP Omnibook Flip). Tester 2: Intel Iris Xe (HP Laptop 15-dw3xxx).
- First entry into Crosspath after the Forgotten Cave: music plays, the cursor moves, the HUD menu button and quest objectives are drawn,
  no dialogue (Maren's welcome never shows), nothing answers (Esc, Enter, Space, clicks) for 1-2 minutes; Continue gives the same.
- Tester 2: with the default graphics settings the game crashes before the intro starts; it runs on Medium.
- Logs (`docs/playtest/logs/`): `joe_godot.log` (Iris Xe) and `john_godot.log` (Arc 130V) hold only the engine banner and the
  "D3D12 12_0 - Forward+ - Using Device #0" line. No other files (no video notes) were in the folder.

## Part 1 - what was found

### 1. The default preset was High on every integrated GPU running D3D12 (confirmed)

`GraphicsQuality.recommended()` trusted `RenderingServer.get_video_adapter_type()`. Godot 4.7's D3D12 driver reports integrated GPUs
as **discrete**. On this PC (AMD Radeon integrated): D3D12 says type 2 (discrete), Vulkan says type 1 (integrated), same GPU.
So on a first launch (no settings.cfg) every iGPU on D3D12 started on **High**: full-resolution 3D, MSAA 2x, SSAO, volumetric fog,
a 4096 shadow atlas, the outline's normal pass. The repro bot confirms it (`quality=2 driver=d3d12 gpu_type=2` on a fresh start,
`quality=1` with Vulkan) and High runs at ~33 ms a frame here against ~17 ms on Medium.

That explains tester 2 (High crashes on the Iris Xe, Medium works) and puts tester 1 on High too: the Arc 130V reports as discrete in
the same way. Settings are saved on the first change, so a tester who never opened Settings keeps High in settings.cfg.

### 2. Why D3D12 on Windows

The project has `rendering_device/driver.windows="d3d12"` since the project moved to the repo root (Sept 25) - Godot 4.6 made D3D12 the
Windows default for new projects. `fallback_to_vulkan` is the engine default (on): if D3D12 cannot create a device the engine tries
Vulkan. A device that is created but later hangs or is lost does not fall back.

### 3. Logs say nothing because the engine log only flushes on errors

`godot.log` is buffered in release builds (`application/run/flush_stdout_on_print` was off); a process killed while frozen loses
everything printed. v0.4.0 also printed almost nothing of its own. Hence testers' logs end after the engine banner.

### 4. Runs on this PC (AMD integrated GPU) - nothing hangs

Stock 4.7.2 binary + the exported packs (the release exe ignores `-s` scripts, so the bot runs the same pack under the debug template),
`tools/run_cave_arrival_repro.sh` with the new `GODOT_ARGS`, `FRESH_SETTINGS=1` (first-launch defaults) and `COLD=1` (shader cache cleared).

| build | driver | settings | path / mode | click -> fade-in | after the fade-in | result |
|---|---|---|---|---|---|---|
| v0.4.0 | D3D12 | first launch (High), cold cache | Beefcake | 11.5 s (black, one frame) | avg 32.8 ms, worst 71 ms | welcome, Esc, F8, walks |
| v0.4.0 | Vulkan | first launch (Medium), cold | Beefcake | 14.3 s | avg 16.8 ms, worst 70 ms | ok |
| v0.4.2 | D3D12 | first launch (High), cold | Beefcake | 15.9 s (loading screen) | avg 32.9 ms, worst 87 ms | ok |
| v0.4.2 | Vulkan | first launch (Medium), cold | Beefcake | 12.8 s | avg 16.6 ms, worst 60 ms | ok |
| v0.4.2 | D3D12 | Medium | Gourmand | 15.7 s | worst 102 ms | ok |
| v0.4.2 | Vulkan | Medium | Refusemancer | 9.6 s | worst 60 ms | ok |
| v0.4.2 | D3D12 | first launch (High) | Necrocrat | 8.3 s | worst 40 ms | ok |
| v0.4.2 | D3D12, `--rendering-method mobile` | High | Beefcake | 21.4 s | worst 109 ms | ok, but **"Shader compilation failed"** (a shader the Mobile renderer cannot build) |
| v0.4.2 | D3D12 | High | Continue from a cave save | 7.8 s | worst 100 ms | ok |

The Intel-only hang cannot be reproduced on AMD hardware. What it needs to look like the report: a frame with the HUD drawn, then a
main thread that never finishes another frame (music and the cursor run on other threads) - a GPU hang or device loss under the High
preset is the best fit with the evidence (tester 2 crashes on High at the first 3D scene; both testers ran the default High), or a soft
lock with input swallowed.

### 5. Static analysis of the arrival (v0.4.0 and main)

- v0.4.0 builds the town in one 8-25 s frame with no loading screen (fixed in v0.4.2, which the testers did not have).
- No game-code path leaves `SceneManager.busy` stuck: every await is a SceneManager tween, `process_frame` or a timer that runs while
  paused. But nothing would end a transition that did stop (no watchdog), and Esc is refused while busy.
- Main-thread waits on background work in main: `load()` of a file a loader thread is still loading (SceneWarmup/UiArtWarmup paths
  after their timeouts) blocks until the thread is done; `UiArtWarmup.settled()` had no timeout of its own (only SceneManager's 90 s).
- Synchronous GPU readbacks on the main thread: the save thumbnail (`Session.capture_thumbnail`, at the autosave on every area change,
  in the town's `_ready`, every Esc), `ZoneTitleCard.is_bright_middle`, UiSkin/UiArt `get_image` of imported textures. Each is a full
  GPU sync; a driver that hangs there freezes the game exactly as reported.
- `UiArtWarmup` turns all GUI input off while a warm-up screen is up; its stall guard stopped running between two screens
  (`set_process(false)`) and while the tree was paused.
- If the town's staged `_ready` ever stopped part-way, processing and input stayed off and the lock watchdog (in `_process`) never ran.
- Continue: the arrival is never replayed - a save made before the welcome finished (`maren_met` unset) lands in a town where the
  welcome never comes.

## What changed

### Part 2 - a log that says where the game stopped

- `GameLog` (autoload, first in the list) writes `%APPDATA%\Deckbuilder-RPG\logs\wayward.log`, **flushed after every line**; the last
  five runs are kept (`wayward.1.log` .. `wayward.4.log`), each file capped at 1.5 MB of routine lines (warnings always go in).
- At start: version, launch number, how the previous launch ended, OS/CPU/RAM, renderer + driver + API, GPU name / vendor / the
  engine's type / what the game reads it as, the GPU driver version, video memory in use, screen, command line, then the graphics
  settings in use (`Settings.summary()`: quality, recommended quality, render scale, fog, bloom, DOF, vsync, renderer, SAFE MODE).
- Every scene change step (`LoadTiming.mark` -> fade out, loading screen up, change scene, each town build stage, scene built, settled,
  fade in, revealed), every warm-up start and finish with ms (SceneWarmup, UiArtWarmup), every modal open/close (OverlayScreen
  subclasses, Dialogue, PauseMenu, FeedbackForm), every hero lock change (town, zones, forest), a GPU readback step.
- A heartbeat every 5 s: `scene=Town busy=no hero=free modals=[Dialogue] paused=false fps=60 mem=...`.
- A **watchdog thread** writes `WARNING stall: the main thread has not finished a frame for 8 s (last step: ...)` - the one line a hung
  game can still leave - and when frames come back, how long it was gone.
- `application/run/flush_stdout_on_print=true` so the engine's own godot.log keeps the game's prints too.
- F8 reports now also hold `wayward.log`, `wayward_previous_run.log`, `boot_state.cfg`, and the renderer, graphics summary, Safe Mode
  reason and how the previous launch ended in `report.json`.

### Part 3 - fixes

- **Default preset** (`GpuInfo`): the GPU kind comes from its name - Intel UHD/HD/Iris Plus = older iGPU -> Low; Iris Xe, Arc 130V/140V,
  "Arc Graphics", AMD "Radeon Graphics"/7x0M/Vega APUs, Adreno = iGPU -> Medium; Arc A/B cards, Radeon RX, GeForce = discrete -> High;
  software renderers -> Low. Integrated GPUs never start on High. A settings.cfg from v0.4.2 or older holding High on an iGPU drops
  once to the recommended level (`settings_version` 2).
- **Intel integrated GPUs**: volumetric fog, SSAO (both compute passes) and MSAA stay off even on High there (FXAA instead) - the
  High-only passes that fit tester 2's crash. (Godot 4.7 itself carries an Iris Xe compute-barrier workaround since beta 3.)
- **Crash-safe start** (`BootGuard`, `user://boot_state.cfg`): stages starting -> title -> loading <scene> -> playing <scene> -> exit
  (stalled while the main thread is stuck). A launch that ended starting, loading or stalled makes the next launch start in **Safe Mode**:
  Low, fog/bloom/DOF off, no loader threads (warm-ups load a few files per frame on the main thread), no screenshot readbacks; saved, and
  said on the title screen. Two bad launches in a row also switch the renderer (D3D12 <-> Vulkan, a one-time restart with
  `--rendering-driver`). Exported builds only (editor, GUT and `-s` tools never touch the file). `-- --safe-mode` forces it.
- **Transition watchdog** (`SceneManager`): every transition has an id and a phase; with no progress (no load step, no change in the
  scene's `load_progress`, no frames while settling) for 8 s (30 s while a scene builds) or busy past 120 s, it is ended by force: tweens
  killed, the loading screen freed, the cover cleared and input back, the scene's `recover_after_timeout()` called, `revealed` emitted,
  a warning logged. Time with the pause menu or the report form open does not count.
- **Settle**: behind the cover, frames are drawn until they are steady - up to 30 s (was 4 s) while frames still spike (a slow iGPU
  compiling the town's first pipelines), but a steadily slow machine settles at once (a frame counts as quick under 50 ms or 1.6x the
  quickest frame seen).
- **Esc and F8**: F8 is handled in `_input` (before any GUI can swallow it); Esc during a transition is remembered and opens the pause
  menu at the reveal (not while the report form is open).
- **Warm-ups never wait for ever**: UiArtWarmup's pictures give up after 20 s like SceneWarmup's files; its input guard keeps running
  between screens and while paused (it could stop with all GUI input off).
- **Town**: `recover_after_timeout()` switches processing and input back on if its staged build never finished; the arrival start and
  the lock watchdog run first in `_process` (an error later in the frame can no longer stop them).
- **Arrival order** (brief): level-ups -> reward boxes / quest notices -> Path warning -> Maren's welcome (three parts).
- **Continue from a save stuck before the welcome** (cave cleared, `maren_met` unset, not a fast-forwarded game): the arrival plays again
  beside Maren's door - the testers' v0.4.0 saves.
- **Thumbnails**: the save screenshot (a full GPU sync) is skipped in Safe Mode and during scene changes, and logged when slow.
- **Shader baker** on in the export preset (472 shaders baked for D3D12 and Vulkan, +10 MB): less shader compiling on a cold start
  (1 s here; more on a 4-core laptop). The export runs non-headless for it.

### Renderer choice: D3D12 stays the Windows default

- D3D12 is what Godot 4.6+ ships as the Windows default (fewer broken Vulkan drivers and overlays on Windows); `fallback_to_vulkan` is
  on, so a PC that cannot create a D3D12 device starts on Vulkan by itself.
- Tester 2's Iris Xe runs the game on D3D12 at Medium; the crash came with High (now never the default on an iGPU).
- On this PC both drivers run every scenario; Vulkan loads Crosspath a little faster (12.8 vs 15.9 s cold, 9.6 vs 15.7 s warm).
- So: D3D12 by default, `Start (Vulkan).bat` one double-click away, and two bad launches in a row switch drivers on their own.

## Part 5 - verified on the exported v0.4.3 build

Exported pack (`tools/export_windows.sh`, shader baker on), stock 4.7.2 binary + the pack for the bot runs (the release exe ignores `-s`);
the crash-safe start and the driver switch on the real release exe. AMD integrated GPU (Ryzen 5 4500U), 1600x900.

| scenario | driver | settings | load (click -> fade-in) | after the fade-in | result |
|---|---|---|---|---|---|
| Beefcake, cold shader cache | D3D12 | first launch -> **Medium** (was High) | 14.9 s | no frame over 200 ms | welcome, F8, Esc, walks |
| Gourmand, cold | Vulkan | first launch -> Medium | 10.5 s | no frame over 200 ms | ok |
| Refusemancer | D3D12 | Low | 14.4 s | ok | ok |
| Necrocrat | Vulkan | Low | 10.0 s | ok | ok |
| Necrocrat | D3D12 | **Safe Mode** (`-- --safe-mode`) | 8.7 s | ok | ok |
| Beefcake | Vulkan | Safe Mode | 10.1 s | ok | ok |
| Gourmand | D3D12 | High (chosen) | 8.6 s | ok | ok |
| Refusemancer | Vulkan | Medium | 9.3 s | ok | ok |
| 4 level-ups waiting | D3D12 | Medium | 8.4 s | ok | level-ups, then the welcome |
| Continue from a cave save | Vulkan | Medium | 8.6 s | worst 91 ms | ok |
| keys and clicks mashed | D3D12 | Medium | 8.0 s | worst 61 ms | ok |
| **a v0.4.0 save stuck before the welcome** (Continue) | D3D12 | Medium | - | - | first run: the welcome did not replay (v0.4.0 saves load with the legacy quest flag, which the first condition excluded) - **fixed**: replays, hero free, walks |

Every run: Maren's welcome shows, Esc opens and closes the pause menu during it, F8 opens Report a Problem over it, no frame over 200 ms
after the fade-in, the hero walks afterwards.

Real release exe (`builds/_export/TheWaywardPath.exe`):
- Normal launch: `wayward.log` has the header (GPU "read as integrated", engine type 2), the settings line (Medium) and "title screen
  shown"; boot stage `title`.
- A launch left in "loading town" (a crash during a load): the next launch logs `SAFE MODE: ...ended while loading town`, settings Low with
  fog/bloom/DOF off, the title says so (`_screenshots/p1/safe_mode_title.png`; the notice got a dark outline afterwards to be readable).
- Two bad launches in a row: "trying the vulkan driver", "restarting with the vulkan driver", and the restarted process runs Vulkan and
  reaches the title in 0.6 s.
- A kill 1 s after starting happens before the engine runs any script: nothing can see that (nor would a crash that early be ours).

Bot artifact: the mashing scenario can click into the pause menu's Settings and save a quality - restore settings.cfg after running it.
