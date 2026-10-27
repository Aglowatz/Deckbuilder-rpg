# "The volume is not working" - what was wrong (Fixes Oct 26, Part 3)

## Short answer

The sliders were wired correctly - every one reached its bus, in the editor and in the exported v0.4.5 pack, by mouse and by controller.
What was wrong was **how far a slider moves the sound**: the position went straight to the bus as an amplitude (`linear_to_db`), so

- the top half of every slider (100% -> 50%) was only **6 dB** - "a little quieter", not half as loud;
- the defaults sat where a step does almost nothing: Master / Effects at 80% (-1.9 dB), Music at 60% (-4.4 dB); one 5% step there was
  **0.5-0.7 dB**, below what the ear notices (about 1 dB);
- on a controller, four D-pad presses from 80% to 60% changed the level by **2.5 dB**, and holding the stick or the D-pad moved a slider
  **one step** however long it was held.

So a player moving a slider by a reasonable amount heard little or no change. Fixed with a dB taper and hold-to-repeat on the pad.

## How it was checked (nothing guessed)

All probes are in `tools/` and print one line per measurement.

| Check | Tool | Result |
|---|---|---|
| Saved values, every bus's volume_db / mute / duck at startup, after the scene loads, after Settings opens, after each slider | `volume_probe.gd` (Crosspath, real panel) | the saved values (0.8 / 0.6 / 0.8...) load before the scene and sit on the buses; each slider sets exactly its bus; no bus muted, bypassed or ducked |
| Each slider at 0 silences its own bus while music, ambience, UI ticks, battle hits and dialogue blips play | `volume_probe.gd` (bus peak meters) | Master 0 -> Master -200 dB; Music 0 -> Music -200; Effects 0 -> SFX -200 (Battle, UI, World feed it); UI, Ambience, Voice likewise |
| Players routed to the right bus | `volume_probe.gd` + code read | playing players: Music 1, Ambience 3, Battle 6, UI 1; every `AudioStreamPlayer*` in the code sets a bus that exists (music, ambience, emitters, sfx, 3D sfx, UI, voice); `sfx_events.csv` buses are UI / Battle / World / Voice only |
| What the listener hears per slider position | `volume_tone_probe.gd` (a steady -12 dBFS tone on each bus, Master's output peak) | exactly the amplitude curve: 100 / 80 / 50 / 25 / 10 / 5% = 0 / -1.9 / -6 / -12 / -20 / -26 dB on every bus; no compressor or limiter undoes a slider (the bus volume applies after the bus's effects) |
| The real UI by mouse: title Settings, in-game pause menu (Esc) | `volume_flow_probe.gd` (mouse presses and drags pushed through the window) | every drag changes its value and its bus, paused or not |
| The exported build | `volume_flow_probe.gd` on `builds/_export/TheWaywardPath.pck` (v0.4.5, Oct 23) with the stock debug binary, as `run_release_smoke_exported.sh` does | identical to the editor |
| The controller (pause menu by Start, D-pad to Settings > Audio, left / right, stick) | `volume_pad_probe.gd` (`pad_driver.gd` events) | values change - but 0.5 dB per press, one step per hold (above) |
| Output device change while running (a DualSense or headset plugged in switches Windows' default) | `volume_device_probe.gd` (switches `AudioServer.output_device` through Default, the Realtek speaker, the DualSense speaker and back) | volumes and mutes unchanged, sound keeps playing on each device |
| Mute when unfocused | code + test | off by default; on: Master mutes on focus-out and comes back on focus-in (`test_the_game_mutes_when_unfocused_only_if_asked`) |
| Ducking left stuck | code + test | dialogue ducks are keyed by the box and released on finish and on `_exit_tree`; moments expire; both buses return to 0 dB |
| Performance-pass pause/menu changes (WorldCover, dynamic resolution) | code read | none touches audio (WorldCover only stops 3D rendering) |
| Controller-support changes to Settings | code read + pad probe | `PadFocus` leaves left / right to a focused slider (`_keeps_its_arrows`); the pad B / Start handlers never touch audio |
| The saved config vs the bus tree at startup | code read | `Settings._ready`: `AudioMix.ensure_layout()` first, then `load_settings()`, then `apply()` - the buses exist before the values land |

## The fix

- **dB taper** (`Settings.volume_db`): a slider position maps to dB on a straight line, 100% = 0 dB down to 5% = -38 dB, 0 = silence (and the
  bus mutes). Every 5% step is 2 dB; 50% is -20 dB (a quarter as loud).
- **Same loudness for everyone already playing**: settings.cfg version 3. A version 1-2 file holds amplitudes; `_migrate_volumes` converts each
  once to the position that sounds the same (`position_from_amplitude`: 0.8 -> 95%, 0.6 -> 90%, 0.3 -> 75%, 0 stays 0) and saves. New
  defaults: Master, Effects, Interface, Ambience, Voices 95% (-2 dB), Music 90% (-4 dB) - what the old defaults sounded like.
  (`migrated_quality` now keys on `QUALITY_FIX_VERSION` 2 so the version bump does not re-run the old iGPU High fix.)
- **Hold to repeat on the pad** (`PadFocus._repeat_range`): a focused slider held left / right keeps stepping after 0.4 s, every 0.12 s, like
  a held key (D-pad verified by `volume_pad_probe.gd`: held 1 s, 80% -> 100%). The held stick is read with `Input.get_joy_axis` as well;
  simulated stick events do not update the engine's stick state, so the stick hold could only be checked on a real controller.

After the fix (`volume_pad_probe.gd`): four D-pad presses from 95% = -2 dB to 75% = -10 dB (was 2.5 dB in total).

## Tests

`tests/audio/test_volume_fix.gd`: the taper steps are audible and monotonic; every slider of the real Settings panel sets its bus and a
player on that bus (Music, Battle under SFX, UI, Ambience, Voice) hears a 2 dB step, silence at 0 and the same level back; saved values apply
at startup; an old file keeps its loudness and is not converted twice; the new defaults sound like the old ones; nothing stays ducked after
dialogue and a moment; nothing stays muted after opening / closing Settings and losing / regaining focus; a held pad direction keeps moving
a slider and stops on release. `tests/test_settings_access.gd` updated for the taper.

## Listen for this

Settings > Audio: drag Music from 90% to 50% - the music drops clearly (16 dB). On a controller, hold the D-pad on a slider: it runs.
