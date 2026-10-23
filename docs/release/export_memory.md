# Export memory (Oct 23 2026)

Measured on the 7.4 GB laptop with `tools/measure_process.ps1` (working set of every `Godot*` process, sampled every 250 ms, with the
line Godot was printing at that moment). Raw timelines: `_logs/export_mem/*.csv` (not in git). How to build: `how_to_build.md`.

## Where the memory goes

| Step | Peak (working set) | Notes |
|---|---:|---|
| Headless import, nothing to reimport | 1.01 GB | editor start + file scan |
| Headless import, 499 world sprites reimported | 1.17 GB | 35 s; texture conversion happens here, never in the export |
| Export, windowed, shader baker on (the shipped way) | **1.69 GB** | ~1.25 GB after the editor starts; +0.25 GB in the first 5% of packing while the baker compiles 332 shaders; ~1.49 GB flat for the rest |
| Export, windowed, baker off | 1.45 GB | the baker costs ~0.25 GB and ~20 s |
| Export, headless, baker off | 0.94 GB | the editor window / D3D12 device is ~0.5 GB |
| Export, headless, baker **on** | 0.95 GB | **bakes nothing** (0 shaders in the pack, no error) - not usable |
| Export, windowed, tiny window / `--disable-render-loop --low-dpi --audio-driver Dummy` | 1.68 GB | no measurable change |
| Export with `_art_inbox`, `_art_source`, `_screenshots`, `_logs`... behind `.gdignore` | 1.71 GB | no change in peak (noise); kept so new inbox art is never imported during a build |
| Zip, `Compress-Archive -CompressionLevel Optimal` (old) | **1.56 GB** (1.9 GB private) | buffers the 760 MB pack; a second spike as big as the export |
| Zip, `tar.exe -a -c` (new) | ~6 MB | streams from disk; same 689 MB zip, standard Deflate, opens in Explorer/.NET |
| `verify_pck.js` (every MD5) / `unzip -t` | < 60 MB | 1.4 s / 5 s |

Packing does not load every texture: memory stays flat at ~1.49 GB while ~11,900 files are stored, and the `.ctex` files are copied
from `.godot/imported` as they are (no re-import, no re-compression). Pre-importing in its own headless step keeps any reimport out of
the export process.

## The shader baker

It bakes 77 D3D12 shader caches (4 MB of the pack) so testers' laptops do not stall compiling them on first sight. It only runs with a
real rendering device, so the export stays windowed; Godot gives no error when it is skipped, so `verify_pck.js --min-shaders=40` now
fails a pack without them. The baker only bakes for the driver the editor runs on (D3D12 here); the Vulkan launcher compiles at run time.

## Before / after

| | Before | After |
|---|---:|---:|
| Highest peak in the run | 1.69 GB (export), then 1.56 GB again (zip) | 1.69 GB (export) only |
| Free RAM the run needs | ~2 GB twice (export, zip), no check | ~2 GB once; warns under 2000 MB, stops under 1200 MB |
| Export peak (v0.4.5 rebuild) | 1.69 GB | 1.68 GB (import 1.00 GB in its own run) |
| Pack / zip size | 727.6 MB, 11,937 files / 689,085,438 bytes | 727.0 MB, 11,901 files / 688,415,926 bytes |

The export's own 1.7 GB is the floor for a baked build on this machine: the editor with a D3D12 device is ~1.45 GB of it and no
command-line switch changed that.

## Dev-only content

The pack was already clean of docs, screenshots, paint-overs, inbox art, `-vN` duplicates and test scenes (fixed excludes in
`tools/update_export_excludes.js` + 450 unreferenced models). Non-resource files (`.md`, `.txt`, `.csv`) are never packed. The one
leftover was the character look test's heroes (`assets/art/characters/`, ~2 MB, used only by `scenes/dev/`), now excluded.
