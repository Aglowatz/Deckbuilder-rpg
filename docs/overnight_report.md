# Morning report - overnight Oct 20-21 (playtest stability, v0.4.3)

Last night's report: `docs/overnight/oct19/overnight_report_oct19.md`. Details: `docs/playtest/stability_oct20.md`; loop:
`docs/overnight/loop_log.md`; release notes: `docs/release/v0.4.3_notes.md`. Started 22:16, tag `pre-overnight-oct20`.

## Root causes, in plain words

1. **The default graphics were the heaviest on both testers' laptops.** The game picks its starting quality from what the engine says
   about the graphics chip. With DirectX 12 (the Windows default since Godot 4.6), the engine says built-in laptop graphics are a
   separate graphics card - checked on this PC: same AMD chip, "discrete" on DirectX 12, "integrated" on Vulkan. So Intel Iris Xe and
   Arc 130V started on **High** (full resolution, MSAA, SSAO, volumetric fog, big shadow maps). Tester 2's crash before the intro, gone on
   Medium, is exactly that. Tester 1 ran High the same way.
2. **The Crosspath freeze**: v0.4.0 built all of Crosspath in one frame on a black screen (8-25 s here; longer on a laptop, and on High),
   with nothing that could ever end a stuck transition or a stuck arrival. v0.4.2 (yesterday) staged the build; tonight added the
   safety nets (below). I could **not** reproduce an Intel-only hang on this AMD PC - every scenario runs here, both drivers. The most
   likely Intel story is the GPU choking on the High preset in the biggest scene; whatever it was, the next log will name it.
3. **The logs were empty** because the engine's log only flushes on errors and the game printed almost nothing; a frozen game that is
   closed loses what was buffered.
4. Found on the way: **memory only ever grew** across areas (1.86 GB of video memory after touring every area), and on **Vulkan** the
   Verdant Dump ran the driver out of buffer objects (each simple shape had its own GPU buffers) - the picture broke. Fixed.

## What changed (v0.4.3)

- **Default quality from the GPU's name** (`GpuInfo`): built-in graphics start on Medium (older Intel UHD on Low), never High; a High
  saved by an older version on built-in graphics drops to Medium once. On Intel built-in graphics, volumetric fog, SSAO and MSAA stay off
  even on High.
- **Crash-safe start** (`BootGuard`): a launch that ended while starting, loading or frozen makes the next one start in **Safe Mode**
  (Low, fog/bloom/DOF off, no background loading threads, no screenshot readbacks), saved, and said on the title screen; two bad launches
  in a row also switch DirectX 12 <-> Vulkan (one automatic restart). Exported builds only.
- **Nothing can stay stuck**: a scene-change watchdog ends any transition that stops making progress (cover removed, input back, the
  scene told to finish, a warning logged); the town recovers if its staged build stops; warm-ups give up after 20 s; the arrival is one
  queue in your order (level-ups -> rewards/quest notices -> Path warning -> Maren's welcome) with the lock always released; F8 works on
  every screen (handled before the GUI), Esc during a load opens the pause menu when it ends.
- **Saves stuck at the freeze**: Continue plays Maren's welcome again (cave cleared, welcome never finished, still fresh out of the
  cave) - tested with a real v0.4.0 save.
- **A log that says where it stopped**: `%APPDATA%\Deckbuilder-RPG\logs\wayward.log`, flushed every line, 5 runs kept: GPU, driver,
  renderer, settings, every load step, warm-ups, menus and dialogues opening/closing, hero lock, memory at each area, a heartbeat every
  5 s, and a watchdog thread that writes "the main thread has not finished a frame for 8 s (last step: ...)". F8 reports include it.
- **Shader baker** on (shaders pre-built in the export, +10 MB), loading screen holds until frames are steady (up to 30 s on a slow
  first launch), memory released between areas, shared simple shapes.
- **Tester kit in the zip**: `Start (Safe Mode).bat`, `Start (Vulkan).bat`, `Start (DirectX 12).bat`, `Start (Compatibility).bat`
  (last resort), `Start (Verbose Log).bat`, `README_PLAYTEST.txt`.

## Part 1 scenarios now (exported v0.4.3, this PC: AMD Ryzen 5 4500U integrated graphics)

| scenario | before (v0.4.0 / v0.4.2) | now |
|---|---|---|
| first launch, DirectX 12 | **High** chosen (~33 ms frames here) | Medium |
| cold cache, both drivers, all four Paths, Low/Medium/High/Safe Mode | no hang here | no hang, welcome shows, Esc + F8 work, no frame > 200 ms after the fade-in |
| Continue from a cave save | ok | ok |
| a v0.4.0 save stuck before Maren's welcome | welcome never came | welcome plays, hero walks |
| level-ups waiting / keys mashed | ok | ok (level-ups first) |
| `--rendering-method mobile` | "Shader compilation failed" | not offered (no launcher uses it) |
| a launch that crashed while loading | next launch the same | next launch in Safe Mode (checked on the real exe) |
| two bad launches in a row | - | restarts on the other driver (checked on the real exe) |
| full tour, Vulkan | broke in the Verdant Dump | OK, 0 errors |

Smokes: GUT 2079/2079; prologue, playtest (D3D12 and Vulkan), tour bot (D3D12 and Vulkan) OK; release smoke on the export PASSED with
both drivers. The tour bot and playtest smoke need project-only tool classes, so they ran on the project, not the export; the export
was covered by the self-contained arrival repro and the release smoke.

## Renderer and default settings

- **DirectX 12 stays the default.** It is Godot's Windows default since 4.6 (fewer broken Vulkan drivers and overlays), the engine
  falls back to Vulkan when DirectX 12 cannot start, tester 2's Iris Xe ran fine on DirectX 12 at Medium, and the crash came with High.
  Vulkan loads Crosspath a bit faster here (10.6 vs 15.5 s cold) but broke in the Dump before tonight's fix. If a tester has trouble:
  Safe Mode first, then `Start (Vulkan).bat`; the game also switches by itself after two bad launches.
- **Defaults**: discrete GPU -> High; built-in graphics -> Medium; older Intel UHD/HD/Iris Plus and software rendering -> Low.

## The zip

`builds/TheWaywardPath-v0.4.3-windows.zip` - **637 MB** (pack 702 MB). Tag `v0.4.3` marks the first build of this version (Part 6, 01:51); the zip was **rebuilt at the end with the same version** to include the loop fixes below (the final commit on main). In the folder: the exe, the pack, `README_PLAYTEST.txt` and five launchers (Safe Mode, Vulkan, DirectX 12, Compatibility, Verbose Log) - each started from a fresh unzip and checked in the log (right renderer, Safe Mode where meant, title reached).

## What to tell testers

> v0.4.3 fixes the freeze entering Crosspath and the crash with default graphics on laptops. Unzip the whole folder (not into Program
> Files) and run TheWaywardPath.exe - your saves carry over; Continue from where it froze and Elder Maren's welcome plays again. If it
> crashes or freezes, double-click "Start (Safe Mode).bat"; if that doesn't help, "Start (Vulkan).bat". Press F8 for any problem; if it
> froze, send us %APPDATA%\Deckbuilder-RPG\logs\wayward.log (and wayward.1.log). README_PLAYTEST.txt has the details.

## Inbox

Added to `docs/overnight_inbox.md` (Overnight Oct 20-21 section): the arrival order change, Continue replaying the welcome, the renderer
choice, and that the Intel hang itself was not reproducible here.

## Phase 2 - stability and first-hour loop (details in `docs/overnight/loop_log.md`)

1. **Vulkan broke in the Verdant Dump; memory only grew** - world-art caches released when changing area; identical primitive shapes
   share one mesh. Vulkan tour now OK with 0 errors; video memory after a full tour 1.53 GB instead of 1.86 GB (D3D12).
2. **First-draw spikes after a fade-in without a loading screen; results opening under the cover** - every scene change settles behind
   its cover; post-battle conversations in town wait for the reveal (the store-room ghosts' lines used to type out unseen).
3. **The stall watchdog verified** - an 11 s main-thread block leaves "the main thread has not finished a frame for 8 s (last step: ...)"
   in the log, then "back after 11.2 s".
4. **Compatibility (OpenGL) renderer works** as a last resort - `Start (Compatibility).bat`; its Forward+-only pieces guarded.
5. **Opening hour on Low + Vulkan** clean (54-60 fps); the remaining post-arrival spike in the smoke is the smoke's own screenshot.
6. **F8/Esc during the loading screen** - new repro mode, all checks pass.
7. **"Not Responding" during long loads** - zones still build in one long frame (4-8 s here); the game now keeps answering Windows during
   it (`KeepAlive`, verified: the window stays "Responding" through a 9 s blocked frame), and held keys are released after such a frame.
8. **Regression sweep** - every zone walk smoke, the opening forest, first battles and quest smokes OK.

Final checks on the rebuilt zip: GUT 2079/2079; release smoke PASSED on D3D12 and Vulkan; arrival soak (both drivers, four Paths,
level-ups, Continue, F8/Esc during the load) - see the loop log's last entry; all five launchers start correctly.

### Not done / worth doing next

- The Intel-only hang itself was never reproduced here - the next tester log (`wayward.log`) will say where it stops.
- Zones still build in one frame (now with the window kept answering). Staging them like Crosspath would make the loading screen keep
  moving; it is the biggest remaining load-time item.
- Texture memory still grows slowly with menus and card art (bounded by what exists); Crosspath alone uses ~870 MB of video memory on
  Medium.
- The tour bot and the playtest smoke cannot run on the exported pack (they need project-only tool classes); the export was covered by
  the self-contained arrival repro and the release smoke.
