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

## What changed (Parts 2-3)

See the sections below (filled in as each part lands) and `docs/overnight_report.md`.
