# How to build the Windows release

## Before you start

- **Free RAM: about 2 GB.** The export peaks at ~1.7 GB (the Godot editor with a D3D12 device ~1.45 GB + the shader baker ~0.25 GB;
  details in `export_memory.md`). On this 7.4 GB laptop that means closing things first.
- **Close first:** the Godot editor and any game or smoke-test window (the script refuses to start while one runs), browsers (Edge,
  Chrome), other Claude Code / terminal sessions you are not using, Discord, Google Drive sync, Phone Link. The script prints the
  biggest programs running whenever free RAM is under 2000 MB.
- **Free disk: about 2.5 GB** (the new build folder and zip sit next to the old ones until the swap).

## The one command

```
bash tools/export_windows.sh 0.4.5
```

Run it in a terminal in the foreground (not as a background job) and let it finish; it takes about 4 minutes: import (~30 s),
export (~2.5 min, a Godot window opens and closes - the shader baker needs it), checks and zip (~1 min). The version defaults to
`config/version` in `project.godot`.

If free RAM is under 2000 MB it warns and lists what to close; under 1200 MB it stops before starting Godot. `EXPORT_LOW_MEMORY_OK=1
bash tools/export_windows.sh 0.4.5` runs anyway (it will page and be slow, but a stall or a kill still cannot break the zip).

## Good zip or broken zip

The script only replaces `builds/_export/` and `builds/TheWaywardPath-v<ver>-windows.zip` when every check passed:

- **Good:** the last lines say `zip: builds/TheWaywardPath-v<ver>-windows.zip = ~690 MB (checked: CRCs, contents, size)` and
  `EXPORT OK`. The zip holds `TheWaywardPath.exe` (~104 MB), `TheWaywardPath.pck` (~730 MB), the five `Start (...).bat` launchers and
  `README_PLAYTEST.txt`.
- **Stopped:** it prints `EXPORT STOPPED: <reason>` and `Nothing was replaced` - the previous zip and build folder are exactly as they
  were. Reasons: Godot running, too little RAM or disk, Godot exited non-zero or was killed, an export error in the log, a missing or
  small exe, a .pck that is cut short / fails an MD5 / has no baked shaders / is under 90% of the estimated payload, a zip that fails its
  CRC test or has the wrong files or size. Logs: `_logs/export/` (`export.log`, `import.log`, memory timelines `*.csv`).

To check any zip or pack by hand:

```
unzip -tq builds/TheWaywardPath-v0.4.5-windows.zip          # "No errors detected" = every file's CRC matches
unzip -l builds/TheWaywardPath-v0.4.5-windows.zip           # exe, pck, 5 launchers, README_PLAYTEST.txt
node tools/verify_pck.js builds/_export/TheWaywardPath.pck --min-shaders=40   # "PCK OK: ... MD5s match"
```

A broken pack (for example from a disk that filled up or a killed export) usually still has the right name and a plausible size, and
the game then hangs at load. `verify_pck.js` catches it: it reads the pack's own file table and checks that every file is inside the
pack and matches its MD5.

## After the zip

1. `bash tools/run_release_smoke_exported.sh` - the release smoke on the exported pack (windowed, ~1 min). Look for `PASSED`.
2. Update `docs/release/v<ver>_notes.md` (size, what is new), commit, `git tag v<ver>`, push with tags.
