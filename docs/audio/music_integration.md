# Music integration

The approved soundtrack (`G:\My Drive\Card Game Art\Approved_Audio`, 123 music cues and 21 stings, catalogued in `data/source/music_list.csv`) is imported and wired
to the game. Nothing in the Drive folder was moved, renamed or deleted: the importer only copies.

## How it fits together

| Piece | File | What it does |
|---|---|---|
| Audio registry | `data/audio/audio_registry.json` (generated), `core/data/audio_registry.gd` | Stable ID -> file, loop on/off, bus, base volume, alias. Replace a track by swapping `assets/audio/music/<ID>.ogg` (or `stings/<ID>.wav`) and running "import audio". |
| Importer | `tools/import_audio.sh` (`--analyze` also refreshes loudness and loop-seam data) | Copies by ID (loops OGG, stings WAV, long story cues converted to OGG with ffmpeg), writes the registry and `data/source/audio_import_manifest.csv`. The folder is `audio_dir` in `data/source/art_config.cfg`. |
| Director | `app/music_director.gd` | Pure functions: which ID plays for a game state (zone + completion flag, dungeon ID, battle context, Capital area, vendor screen, cutscene...). |
| Manager | `app/music_manager.gd` (owned by the `Audio` autoload) | Equal-power crossfades, an override stack that resumes the area track, stings with ducking, the dialogue duck. |
| Triggers | `data/source/music_triggers.csv` | One row per ID: where it plays (this document's table is generated from it by `tools/audio_doc.js`). |
| Levels | `data/source/audio_levels.csv`, `tools/audio_analyze.js` | Loudness (EBU R128 via ffmpeg), true peak and loop-seam checks of every delivered file. |

### Playback rules

- **Area track.** `Audio.play_music(id)` sets the area's music; asking for the track already playing does nothing (no restart). Changing area crossfades over 1.5 s (equal power: the sum stays at full loudness; the smoke measured at most 0.25 dB change per frame).
- **Overrides.** `Audio.push_music(id)` / `pop_music(token)` lay a battle, a shop, a story cue or the graveyard over the area track. The area track is suspended at its position and **resumes where it left off** when the override is popped; if the area changes underneath, the new area's music is what comes back. One-shot story cues hand back by themselves when they end.
- **Shops and menus.** A vendor screen pushes its theme once when it opens (`OverlayScreen.music_cue`), so purchases never retrigger it; closing resumes the town. The deck station and the collection have `MUS-DECK`. Short overlays (character, quests, map, wardrobe, packs, fast travel, pause, settings) keep the current music.
- **Stings.** `Audio.sting(id)` plays over the music on the Music bus and ducks it by 9 dB (13 dB over a story cue) while it rings. The old `victory` / `defeat` / `level_up` effect names play the registry stings (fallback: the old Kenney sounds).
- **Dialogue.** The `DialogueBox` ducks the music by 4.5 dB while a conversation is up (fast attack, 14 dB/s release).
- **Never silent.** An ID with no loadable file falls back to a category track (fight song / deck theme / town theme), then to the synthesized `MusicSynth` map track.
- **Levels.** Loops and story cues are brought to -20 LUFS and stings to -17 LUFS (peak ceiling -1.5 dBTP) by a per-ID base volume in the registry, and the Master bus carries a -1 dBFS hard limiter. The delivered files were already within 0.6 LU of each other. The existing Master / Music / Effects / UI sliders apply (the Music slider scales music and stings).
- **Loop points.** The OGG files are full-file loops (Godot's `loop = true`, offset 0); the Drive registry's loop end equals the decoded length for every loop.

## Verification

- `tests/audio/` (GUT): registry completeness, aliases, loop flags, levels; every director mapping; stack, resume, auto-pop, crossfade and duck bookkeeping; every ID has a trigger row.
- `bash tools/run_music_smoke.sh` (windowed, real mixer; log in `_screenshots/music_smoke.log`): new game -> forest -> town (crossfade) -> graveyard -> Fenwick's shop with three purchases (no retrigger) -> a gate-envoy battle and its victory sting -> Gainlands -> House of Gains map -> boss -> zone freed (freed track + zone sting) -> every Capital area with all four zones free. All checks passed; worst crossfade step 0.25 dB per frame; the mixer output peaked at -0.9 dBFS before the limiter was added (no clipping).
- Not audible to a script: musical balance against dialogue and effects. The levels above are measured, the feel is for a listening pass.

## Status

- **In Game (142):** MUS-ARCHIVE, MUS-ARENA-BATTLE, MUS-ARENA-ELITE, MUS-BEEF-BATTLE, MUS-BEEF-BOSS, MUS-BEEF-DUN-BATTLE, MUS-BEEF-DUN-EXP, MUS-BEEF-EXP, MUS-BEEF-FREED, MUS-BEEF-RELEASE, MUS-CAP-BEEF-BROKEN, MUS-CAP-BEEF-RESTORED, MUS-CAP-CORRECTION, MUS-CAP-ENFORCER, MUS-CAP-FACADE-BATTLE, MUS-CAP-FACADE-EXP, MUS-CAP-GOUR-BROKEN, MUS-CAP-GOUR-RESTORED, MUS-CAP-NECRO-BROKEN, MUS-CAP-NECRO-RESTORED, MUS-CAP-OUT-BATTLE, MUS-CAP-OUT-EXP, MUS-CAP-REF-BROKEN, MUS-CAP-REF-RESTORED, MUS-CAP-RESTORED, MUS-CAP-RIFT, MUS-CASTLE-BATTLE, MUS-CASTLE-EXP, MUS-CREASE, MUS-CREDITS, MUS-DECK, MUS-FOREST, MUS-GALLERY, MUS-GOUR-BATTLE, MUS-GOUR-BOSS, MUS-GOUR-DUN-BATTLE, MUS-GOUR-DUN-EXP, MUS-GOUR-EXP, MUS-GOUR-FREED, MUS-GOUR-RELEASE, MUS-GRAVE-BATTLE, MUS-GRAVE-EXP, MUS-LAB-BATTLE, MUS-LAB-CELL, MUS-LAB-EXP, MUS-LAB-RESCUE, MUS-MAREN, MUS-MEM-01, MUS-MEM-02, MUS-MEM-03, MUS-MEM-04, MUS-MINIGAME-BEEF, MUS-MINIGAME-GOUR, MUS-MINIGAME-NECRO, MUS-MINIGAME-REF, MUS-NECRO-BATTLE, MUS-NECRO-BOSS, MUS-NECRO-DUN-BATTLE, MUS-NECRO-DUN-EXP, MUS-NECRO-EXP, MUS-NECRO-FREED, MUS-NECRO-RELEASE, MUS-OMAKASE-BATTLE, MUS-OMAKASE-BOSS, MUS-OMAKASE-EXP, MUS-PANDA-BATTLE, MUS-PANDA-BOSS, MUS-PANDA-EXP, MUS-PRIMM-01, MUS-PRIMM-02, MUS-PRIMM-03, MUS-PRIMM-BREAK, MUS-PRIMM-DEFEAT, MUS-QUEST-FERN, MUS-QUEST-MARLO, MUS-QUEST-PELL, MUS-QUEST-ROLLO, MUS-QUIZ, MUS-REF-BATTLE, MUS-REF-BOSS, MUS-REF-DUN-BATTLE, MUS-REF-DUN-EXP, MUS-REF-EXP, MUS-REF-FREED, MUS-REF-RELEASE, MUS-REUNION, MUS-SHIRO-BOSS, MUS-SHOP-ALEMBIC, MUS-SHOP-ALEMBIC-POST, MUS-SHOP-BEETSWORTH, MUS-SHOP-BELLOWS, MUS-SHOP-BENCHLEY, MUS-SHOP-FENWICK, MUS-SHOP-FIGSLY, MUS-SHOP-GRISTLE, MUS-SHOP-LEDGERBONE, MUS-SHOP-MIREPOIX, MUS-SHOP-SABLE, MUS-SHOP-THREADWELL, MUS-SHOP-TONIC, MUS-SIPHON-BOSS, MUS-SWOLY-BATTLE, MUS-SWOLY-BOSS, MUS-SWOLY-EXP, MUS-THRONE, MUS-TITLE, MUS-TOWN, MUS-TOWN-BATTLE, MUS-TOWN-FREED, MUS-TUNNEL-BATTLE, MUS-TUNNEL-BOSS, MUS-TUNNEL-EXP, MUS-TUT-BATTLE, MUS-TUT-BOSS, MUS-TUT-EXP, MUS-VAULT-BATTLE, MUS-VAULT-BOSS, MUS-VAULT-EXP, MUS-WAIT-BATTLE, MUS-WAIT-BOSS, MUS-WAIT-EXP, STG-ARENA, STG-CRAFT, STG-CRAFT-POST, STG-DEFEAT, STG-DUNGEON, STG-LEVEL, STG-MINI-FAIL, STG-MINI-SUCCESS, STG-PACK-COMMON, STG-PACK-LEGEND, STG-PACK-RARE, STG-PURCHASE, STG-QUEST, STG-RIFT, STG-SECRET, STG-SHIRO, STG-VICTORY, STG-ZONE-BEEF, STG-ZONE-GOUR, STG-ZONE-NECRO, STG-ZONE-REF
- **Reference only, never triggered by design (2):** MUS-LULLABY (Reference only), MUS-PRIMM-MOTIF (Reference only)
- **No trigger yet:** (none) - every cue that the brief expected to be missing (the memories, the Crease, the Archive, the Gallery, the Lab cell and rescue, the Capital districts) has a scene in the game and is hooked to it.
- **Missing file:** (none)
- **Files in the Drive folder matching no ID:** (none)

### Loops that need a fix (composer / renderer)

These play, but the wrap is audible. Listed for the next production pass; the files are left as delivered.

- MUS-CAP-CORRECTION: 0.60 s of digital silence at the wrap; ends 14 dB quieter than it begins (decay / cut-off tail)
- MUS-CAP-FACADE-BATTLE: ends 15 dB quieter than it begins (decay / cut-off tail)
- MUS-CAP-FACADE-EXP: ends 15 dB quieter than it begins (decay / cut-off tail)
- MUS-CAP-OUT-EXP: 0.49 s of digital silence at the wrap; ends 14 dB quieter than it begins (decay / cut-off tail)
- MUS-CASTLE-EXP: ends 16 dB quieter than it begins (decay / cut-off tail)
- MUS-CREASE: 0.50 s of digital silence at the wrap; ends 17 dB quieter than it begins (decay / cut-off tail)
- MUS-DECK: 0.49 s of digital silence at the wrap
- MUS-FOREST: 0.44 s of digital silence at the wrap
- MUS-GRAVE-EXP: ends 15 dB quieter than it begins (decay / cut-off tail)
- MUS-LAB-EXP: 0.43 s of digital silence at the wrap
- MUS-MAREN: 0.53 s of digital silence at the wrap
- MUS-PRIMM-01: ends 15 dB quieter than it begins (decay / cut-off tail)
- MUS-PRIMM-02: ends 14 dB quieter than it begins (decay / cut-off tail)
- MUS-PRIMM-BREAK: 0.53 s of digital silence at the wrap
- MUS-QUIZ: 0.45 s of digital silence at the wrap
- MUS-SHOP-ALEMBIC: 0.54 s of digital silence at the wrap; ends 13 dB quieter than it begins (decay / cut-off tail)
- MUS-SHOP-ALEMBIC-POST: 0.51 s of digital silence at the wrap
- MUS-SHOP-BEETSWORTH: 0.45 s of digital silence at the wrap
- MUS-SHOP-BELLOWS: 0.41 s of digital silence at the wrap
- MUS-SHOP-FIGSLY: 0.51 s of digital silence at the wrap
- MUS-SHOP-GRISTLE: 0.36 s of digital silence at the wrap
- MUS-SHOP-SABLE: 0.45 s of digital silence at the wrap
- MUS-TUT-EXP: 0.37 s of digital silence at the wrap

### Loops to listen to (6-12 dB step at the wrap)

- MUS-TUT-BATTLE: listen: 7 dB step at the wrap
- MUS-TUT-BOSS: listen: 7 dB step at the wrap
- MUS-VAULT-BATTLE: listen: 8 dB step at the wrap
- MUS-VAULT-BOSS: listen: 8 dB step at the wrap

## Every ID

Columns: base volume is the registry's gain in dB (loudness target), "Loop check" is the automatic seam analysis.

| ID | Cue | File | Kind | dB | Trigger(s) | Status | Loop check | Notes |
|---|---|---|---|---|---|---|---|---|
| MUS-ARCHIVE | Good intentions | `music/MUS-ARCHIVE.ogg` | story | +3.0 | Primm's Castle: the Archive gate node (`pc_archive_gate`) and the early-journals event (`pc_early_journals`) | In Game | n/a (one-shot) |  |
| MUS-ARENA-BATTLE | The Grand Clashatorium | `music/MUS-ARENA-BATTLE.ogg` | loop, loop | +0.9 | Grand Clashatorium fights, Bronze and Silver Sand (BB-ARENA) | In Game | OK |  |
| MUS-ARENA-ELITE | The championship card | `music/MUS-ARENA-ELITE.ogg` | loop, loop | +0.9 | Grand Clashatorium Gold Sand (tier 3) fights | In Game | OK |  |
| MUS-BEEF-BATTLE | The Gainlands — combat | `music/MUS-BEEF-BATTLE.ogg` | loop, loop | +1.2 | Overworld battles on BB-GAIN; the town's corrupted beefcake gate envoy | In Game | OK |  |
| MUS-BEEF-BOSS | Chancellor Clench, Iron Regent | `music/MUS-BEEF-BOSS.ogg` | loop, loop | +1.2 | House of Gains principal boss (BB-HOG, boss node) | In Game | OK |  |
| MUS-BEEF-DUN-BATTLE | House of Gains — combat | `music/MUS-BEEF-DUN-BATTLE.ogg` | loop, loop | +1.2 | House of Gains battles and elites (BB-HOG) | In Game | OK |  |
| MUS-BEEF-DUN-EXP | House of Gains — exploration | `music/MUS-BEEF-DUN-EXP.ogg` | loop, loop | +1.1 | House of Gains node map (D-HOG) and its events | In Game | OK |  |
| MUS-BEEF-EXP | The Gainlands — exploration | `music/MUS-BEEF-EXP.ogg` | loop, loop | +1.1 | The Gainlands (`ZoneScene`, zone `beefcake`) until its own completion flag is set | In Game | OK |  |
| MUS-BEEF-FREED | The Gainlands — restored | `music/MUS-BEEF-FREED.ogg` | loop, loop | +1.1 | The Gainlands once `zone_beefcake_completed` is set (returning after the boss, and every later visit) | In Game | OK |  |
| MUS-BEEF-RELEASE | Flex's rescue and true strength | `music/MUS-BEEF-RELEASE.ogg` | story | +2.3 | House of Gains leader release scene: cutscene `rescue` (`CutsceneScreen`) | In Game | n/a (one-shot) | One-shot; hands back to the dungeon music when it ends or the scene closes. |
| MUS-CAP-BEEF-BROKEN | Transit Yards — broken service | `music/MUS-CAP-BEEF-BROKEN.ogg` | loop, loop | +1.1 | Transit Yards (area `transit`) while `zone_beefcake_completed` is not set | In Game | OK |  |
| MUS-CAP-BEEF-RESTORED | Transit Yards — service returns | `music/MUS-CAP-BEEF-RESTORED.ogg` | loop, loop | +1.1 | Transit Yards (area `transit`) once `zone_beefcake_completed` is set | In Game | OK |  |
| MUS-CAP-CORRECTION | Smiled incorrectly | `music/MUS-CAP-CORRECTION.ogg` | loop, loop | +1.0 | The Correction Ward (area `ward`) | In Game | Needs loop fix: 0.60 s of digital silence at the wrap; ends 14 dB quieter than it begins (decay / cut-off tail) |  |
| MUS-CAP-ENFORCER | Every smudge is treason | `music/MUS-CAP-ENFORCER.ogg` | loop, loop | +0.7 | Captain Spotless (the Approved Gate exam) and Capital officers / inspectors | In Game | OK |  |
| MUS-CAP-FACADE-BATTLE | Approved disagreement | `music/MUS-CAP-FACADE-BATTLE.ogg` | loop, loop | +1.0 | Capital battles on BB-CAP-IN | In Game | Needs loop fix: ends 15 dB quieter than it begins (decay / cut-off tail) |  |
| MUS-CAP-FACADE-EXP | Everything is perfectly fine | `music/MUS-CAP-FACADE-EXP.ogg` | loop, loop | +1.0 | Inside the walls: Checkpoint Plaza, the Showcase Quarter, the Castle Approach, Checkpoint Row (areas `plaza`, `perfection`, `approach`, `yard`) | In Game | Needs loop fix: ends 15 dB quieter than it begins (decay / cut-off tail) |  |
| MUS-CAP-GOUR-BROKEN | Hungry Quarter — broken service | `music/MUS-CAP-GOUR-BROKEN.ogg` | loop, loop | +1.1 | Hungry Quarter (area `hungry`) while `zone_gourmand_completed` is not set | In Game | OK |  |
| MUS-CAP-GOUR-RESTORED | Hungry Quarter — service returns | `music/MUS-CAP-GOUR-RESTORED.ogg` | loop, loop | +1.1 | Hungry Quarter (area `hungry`) once `zone_gourmand_completed` is set | In Game | OK |  |
| MUS-CAP-NECRO-BROKEN | Grave Row — broken service | `music/MUS-CAP-NECRO-BROKEN.ogg` | loop, loop | +1.0 | Grave Row (area `grave`) while `zone_necrocrat_completed` is not set | In Game | OK |  |
| MUS-CAP-NECRO-RESTORED | Grave Row — service returns | `music/MUS-CAP-NECRO-RESTORED.ogg` | loop, loop | +1.0 | Grave Row (area `grave`) once `zone_necrocrat_completed` is set | In Game | OK |  |
| MUS-CAP-OUT-BATTLE | The wasteland road | `music/MUS-CAP-OUT-BATTLE.ogg` | loop, loop | +0.8 | Capital battles on BB-CAP-OUT (before the hero has gone through the gate) | In Game | OK |  |
| MUS-CAP-OUT-EXP | Outside the approved walls | `music/MUS-CAP-OUT-EXP.ogg` | loop, loop | +1.0 | Capital outskirts, the gate and the open road (`CapitalScene`, areas `outskirts` / `gate`) | In Game | Needs loop fix: 0.49 s of digital silence at the wrap; ends 14 dB quieter than it begins (decay / cut-off tail) |  |
| MUS-CAP-REF-BROKEN | The Reek — broken service | `music/MUS-CAP-REF-BROKEN.ogg` | loop, loop | +1.0 | The Reek (area `reek`) while `zone_refusemancer_completed` is not set | In Game | OK |  |
| MUS-CAP-REF-RESTORED | The Reek — service returns | `music/MUS-CAP-REF-RESTORED.ogg` | loop, loop | +1.0 | The Reek (area `reek`) once `zone_refusemancer_completed` is set | In Game | OK |  |
| MUS-CAP-RESTORED | Pathordia — many ways home | `music/MUS-CAP-RESTORED.ogg` | loop, loop | +1.0 | Postgame Capital (`zone_final_completed`): inside the walls, outside the districts | In Game | OK |  |
| MUS-CAP-RIFT | A seam in reality | `music/MUS-CAP-RIFT.ogg` | loop, loop | +1.0 | Capital Rift Wretches and Shard Swarms | In Game | OK |  |
| MUS-CASTLE-BATTLE | The mirror parquet | `music/MUS-CASTLE-BATTLE.ogg` | loop, loop | +0.8 | Castle ordinary and elite battles (BB-PC) | In Game | OK |  |
| MUS-CASTLE-EXP | Behind the white and gold | `music/MUS-CASTLE-EXP.ogg` | loop, loop | +1.0 | Primm's Castle node map (D-PC) and its events | In Game | Needs loop fix: ends 16 dB quieter than it begins (decay / cut-off tail) |  |
| MUS-CREASE | Tea of dissent | `music/MUS-CREASE.ogg` | loop, loop | +1.0 | The Crease hideout (area `crease`; Wren, Nurse Hesper Dray) | In Game | Needs loop fix: 0.50 s of digital silence at the wrap; ends 17 dB quieter than it begins (decay / cut-off tail) |  |
| MUS-CREDITS | Many ways forward | `music/MUS-CREDITS.ogg` | story | +3.0 | Ending credits (`EndingScreen._start_credits`) | In Game | n/a (one-shot) | 332 s, longer than the placeholder credits scroll; it is a one-shot and is left to finish or be replaced by the Capital's music. |
| MUS-DECK | A plan in the cards | `music/MUS-DECK.ogg` | loop, loop | +1.0 | Deck station, Codex / collection and the dungeon deck builder (`music_cue()` of those overlay screens) | In Game | Needs loop fix: 0.49 s of digital silence at the wrap | Short overlays (character, quests, map, wardrobe, packs, fast travel) keep the area music. |
| MUS-FOREST | A stranger in the trees | `music/MUS-FOREST.ogg` | loop, loop | +1.0 | Starting forest (`StartingAreaScene`): waking, the Rescuer, the Path choice | In Game | Needs loop fix: 0.44 s of digital silence at the wrap | Dialogue ducks it by 4.5 dB. |
| MUS-GALLERY | Kept for reference | `music/MUS-GALLERY.ogg` | story | +3.0 | Primm's Castle: the Gallery node (`pc_gallery`, the painted-over royal portrait) | In Game | n/a (one-shot) |  |
| MUS-GOUR-BATTLE | The Endless Buffet — combat | `music/MUS-GOUR-BATTLE.ogg` | loop, loop | +1.2 | Overworld battles on BB-BUFF; the town's corrupted gourmand gate envoy | In Game | OK |  |
| MUS-GOUR-BOSS | The Doppelganger | `music/MUS-GOUR-BOSS.ogg` | loop, loop | +1.1 | Test Kitchen principal boss (BB-TTK, boss node) | In Game | OK |  |
| MUS-GOUR-DUN-BATTLE | Test Kitchen — combat | `music/MUS-GOUR-DUN-BATTLE.ogg` | loop, loop | +1.1 | Test Kitchen battles and elites (BB-TTK) | In Game | OK |  |
| MUS-GOUR-DUN-EXP | Test Kitchen — exploration | `music/MUS-GOUR-DUN-EXP.ogg` | loop, loop | +1.1 | Test Kitchen node map (D-TTK) and its events | In Game | OK |  |
| MUS-GOUR-EXP | The Endless Buffet — exploration | `music/MUS-GOUR-EXP.ogg` | loop, loop | +1.1 | The Endless Buffet (`ZoneScene`, zone `gourmand`) until its own completion flag is set | In Game | OK |  |
| MUS-GOUR-FREED | The Endless Buffet — restored | `music/MUS-GOUR-FREED.ogg` | loop, loop | +1.1 | The Endless Buffet once `zone_gourmand_completed` is set (returning after the boss, and every later visit) | In Game | OK |  |
| MUS-GOUR-RELEASE | The true Chef and a name freely given | `music/MUS-GOUR-RELEASE.ogg` | story | +3.0 | Test Kitchen leader release scene: cutscene `wonder` (`CutsceneScreen`) | In Game | n/a (one-shot) | One-shot; hands back to the dungeon music when it ends or the scene closes. |
| MUS-GRAVE-BATTLE | Something beneath the stones | `music/MUS-GRAVE-BATTLE.ogg` | loop, loop | +0.9 | The Restless Cairn scripted challenge (BB-GRAVE) | In Game | OK |  |
| MUS-GRAVE-EXP | Old Hob's evening hum | `music/MUS-GRAVE-EXP.ogg` | loop, loop | +0.9 | The town graveyard (within 6 m of the Restless Cairn): lies over MUS-TOWN, hands back 3 m further out | In Game | Needs loop fix: ends 15 dB quieter than it begins (decay / cut-off tail) |  |
| MUS-LAB-BATTLE | Experiments still running | `music/MUS-LAB-BATTLE.ogg` | loop, loop | +1.0 | Lab battles (BB-LAB) | In Game | OK |  |
| MUS-LAB-CELL | Ten years of marks | `music/MUS-LAB-CELL.ogg` | story | +3.0 | Path-ology Lab event node 7, "The Prince's Old Cell" (event `dg_d_lab_7`) | In Game | n/a (one-shot) |  |
| MUS-LAB-EXP | The subject's corridors | `music/MUS-LAB-EXP.ogg` | loop, loop | +1.0 | Path-ology Lab node map (D-LAB, postgame) | In Game | Needs loop fix: 0.43 s of digital silence at the wrap |  |
| MUS-LAB-RESCUE | The hand that helped | `music/MUS-LAB-RESCUE.ogg` | story | +3.0 | Path-ology Lab rescue node (story key `dg_lab_rescue`, the captured Rescuer) | In Game | n/a (one-shot) |  |
| MUS-LULLABY | Concordia's lullaby — motif master | `music/MUS-LULLABY.ogg` | motif | +3.0 | Composition reference (motif master); never triggered by gameplay | Reference only | n/a (one-shot) | Imported as asked. Its theme is quoted by the memory, throne and reunion cues. |
| MUS-MAREN | Maren — pie and secrets | `music/MUS-MAREN.ogg` | loop, loop | +1.0 | Elder Maren's memory conversations (`TownScene._play_memory`): under her lines, the fragment cue lies on top | In Game | Needs loop fix: 0.53 s of digital silence at the wrap | Pushed with the dialogue; popped over 1.5 s when the conversation ends. |
| MUS-MEM-01 | Warmth | `music/MUS-MEM-01.ogg` | story | +3.0 | Memory fragment 1 (`MemoryScreen`; the Nth zone freed, whichever zone it was) | In Game | n/a (one-shot) | One-shot; hands back to Maren's theme / the town when the screen closes. |
| MUS-MEM-02 | The cells | `music/MUS-MEM-02.ogg` | story | +3.0 | Memory fragment 2 (`MemoryScreen`; the Nth zone freed, whichever zone it was) | In Game | n/a (one-shot) | One-shot; hands back to Maren's theme / the town when the screen closes. |
| MUS-MEM-03 | The coup | `music/MUS-MEM-03.ogg` | story | +3.0 | Memory fragment 3 (`MemoryScreen`; the Nth zone freed, whichever zone it was) | In Game | n/a (one-shot) | One-shot; hands back to Maren's theme / the town when the screen closes. |
| MUS-MEM-04 | His name | `music/MUS-MEM-04.ogg` | story | +3.0 | Memory fragment 4 (`MemoryScreen`; the Nth zone freed, whichever zone it was); also Primm's early-identity reveal cutscene `primm_reveal` | In Game | n/a (one-shot) | One-shot; hands back to Maren's theme / the town when the screen closes. |
| MUS-MINIGAME-BEEF | Chet's revolutionary routine | `music/MUS-MINIGAME-BEEF.ogg` | loop, loop | +1.1 | The Gainlands minigame screen (Rep game) | In Game | OK |  |
| MUS-MINIGAME-GOUR | Flambe's cooking show | `music/MUS-MINIGAME-GOUR.ogg` | loop, loop | +1.1 | The Endless Buffet minigame screen (Order game) | In Game | OK |  |
| MUS-MINIGAME-NECRO | Kyle's memory matching | `music/MUS-MINIGAME-NECRO.ogg` | loop, loop | +1.0 | The Department of Necrotic Affairs minigame screen (Match game) | In Game | OK |  |
| MUS-MINIGAME-REF | Rhonda's sorting ribbons | `music/MUS-MINIGAME-REF.ogg` | loop, loop | +1.0 | The Verdant Dump minigame screen (Sort game) | In Game | OK |  |
| MUS-NECRO-BATTLE | The Department of Necrotic Affairs — combat | `music/MUS-NECRO-BATTLE.ogg` | loop, loop | +1.1 | Overworld battles on BB-DNA; the town's corrupted necrocrat gate envoy | In Game | OK |  |
| MUS-NECRO-BOSS | Mortimer Grimsby, CE-No | `music/MUS-NECRO-BOSS.ogg` | loop, loop | +1.1 | Hall of Final Approvals principal boss (BB-HFA, boss node) | In Game | OK |  |
| MUS-NECRO-DUN-BATTLE | Hall of Final Approvals — combat | `music/MUS-NECRO-DUN-BATTLE.ogg` | loop, loop | +1.1 | Hall of Final Approvals battles and elites (BB-HFA) | In Game | OK |  |
| MUS-NECRO-DUN-EXP | Hall of Final Approvals — exploration | `music/MUS-NECRO-DUN-EXP.ogg` | loop, loop | +1.0 | Hall of Final Approvals node map (D-HFA) and its events | In Game | OK |  |
| MUS-NECRO-EXP | The Department of Necrotic Affairs — exploration | `music/MUS-NECRO-EXP.ogg` | loop, loop | +1.0 | The Department of Necrotic Affairs (`ZoneScene`, zone `necrocrat`) until its own completion flag is set | In Game | OK |  |
| MUS-NECRO-FREED | The Department of Necrotic Affairs — restored | `music/MUS-NECRO-FREED.ogg` | loop, loop | +1.0 | The Department of Necrotic Affairs once `zone_necrocrat_completed` is set (returning after the boss, and every later visit) | In Game | OK |  |
| MUS-NECRO-RELEASE | Agnes — help people | `music/MUS-NECRO-RELEASE.ogg` | story | +3.0 | Hall of Final Approvals leader release scene: cutscene `vacancy` (`CutsceneScreen`) | In Game | n/a (one-shot) | One-shot; hands back to the dungeon music when it ends or the scene closes. |
| MUS-OMAKASE-BATTLE | Omakase — combat | `music/MUS-OMAKASE-BATTLE.ogg` | loop, loop | +1.1 | Omakase ordinary battles (BB-S-GOUR) | In Game | OK |  |
| MUS-OMAKASE-BOSS | The Itamae Supreme | `music/MUS-OMAKASE-BATTLE.ogg` (alias of MUS-OMAKASE-BATTLE) | loop, loop | +1.1 | Omakase boss (BB-S-GOUR, boss node) | In Game | OK | Compatibility alias: plays MUS-OMAKASE-BATTLE's file. |
| MUS-OMAKASE-EXP | Omakase — exploration | `music/MUS-OMAKASE-EXP.ogg` | loop, loop | +1.1 | Omakase node map (S-GOUR) and events | In Game | OK |  |
| MUS-PANDA-BATTLE | Trash Panda Throne — combat | `music/MUS-PANDA-BATTLE.ogg` | loop, loop | +1.1 | Trash Panda Throne ordinary battles (BB-S-REF) | In Game | OK |  |
| MUS-PANDA-BOSS | His Majesty the Raccoon | `music/MUS-PANDA-BATTLE.ogg` (alias of MUS-PANDA-BATTLE) | loop, loop | +1.1 | Trash Panda Throne boss (BB-S-REF, boss node) | In Game | OK | Compatibility alias: plays MUS-PANDA-BATTLE's file. |
| MUS-PANDA-EXP | Trash Panda Throne — exploration | `music/MUS-PANDA-EXP.ogg` | loop, loop | +1.0 | Trash Panda Throne node map (S-REF) and events | In Game | OK |  |
| MUS-PRIMM-01 | Standardization | `music/MUS-PRIMM-01.ogg` | loop, loop | +0.9 | Primm duel phase 1 (BB-PC-BOSS; chosen from the ACTUAL phase index, `PrimmBoss.phase(0).music`) | In Game | Needs loop fix: ends 15 dB quieter than it begins (decay / cut-off tail) |  |
| MUS-PRIMM-02 | Reflection | `music/MUS-PRIMM-02.ogg` | loop, loop | +1.0 | Primm duel phase 2 (BB-PC-BOSS; chosen from the ACTUAL phase index, `PrimmBoss.phase(1).music`) | In Game | Needs loop fix: ends 14 dB quieter than it begins (decay / cut-off tail) |  |
| MUS-PRIMM-03 | Unraveling | `music/MUS-PRIMM-03.ogg` | loop, loop | +0.9 | Primm duel phase 3 (BB-PC-BOSS; chosen from the ACTUAL phase index, `PrimmBoss.phase(2).music`) | In Game | OK |  |
| MUS-PRIMM-BREAK | Rules between duels | `music/MUS-PRIMM-BREAK.ogg` | loop, loop | +1.0 | Primm cutscenes before and between the phases (`primm_intro`, `primm_p1`, `primm_p2`) | In Game | Needs loop fix: 0.53 s of digital silence at the wrap |  |
| MUS-PRIMM-DEFEAT | Finally seeing | `music/MUS-PRIMM-DEFEAT.ogg` | story | +3.0 | Primm's fall: cutscene `primm_end`, then the ending's first beat (`crumble`) | In Game | n/a (one-shot) |  |
| MUS-PRIMM-MOTIF | For their own good — motif master | `music/MUS-PRIMM-MOTIF.ogg` | motif | +3.0 | Composition reference (motif master); never triggered by gameplay | Reference only | n/a (one-shot) |  |
| MUS-QUEST-FERN | Old Fern — untidy | `music/MUS-QUEST-FERN.ogg` | story | +2.9 | Old Fern: quest hand-in dialogue in the Capital (`ZoneScene._talk_quest_npc`) | In Game | n/a (one-shot) |  |
| MUS-QUEST-MARLO | Chef Marlo — the recipe box | `music/MUS-QUEST-MARLO.ogg` | story | +3.0 | Chef Marlo: quest hand-in dialogue in the Capital (`ZoneScene._talk_quest_npc`) | In Game | n/a (one-shot) |  |
| MUS-QUEST-PELL | Widow Pell — a burial permit | `music/MUS-QUEST-PELL.ogg` | story | +3.0 | Widow Pell: quest hand-in dialogue in the Capital (`ZoneScene._talk_quest_npc`) | In Game | n/a (one-shot) |  |
| MUS-QUEST-ROLLO | Rollo Spokes — the wheel never stops | `music/MUS-QUEST-ROLLO.ogg` | story | +0.8 | Rollo Spokes: quest hand-in dialogue in the Capital (`ZoneScene._talk_quest_npc`) | In Game | n/a (one-shot) |  |
| MUS-QUIZ | Questions in triplicate | `music/MUS-QUIZ.ogg` | loop, loop | +1.0 | The four Path trivia quizzes (`QuizScreen`) | In Game | Needs loop fix: 0.45 s of digital silence at the wrap |  |
| MUS-REF-BATTLE | The Verdant Dump — combat | `music/MUS-REF-BATTLE.ogg` | loop, loop | +1.1 | Overworld battles on BB-DUMP; the town's corrupted refusemancer gate envoy | In Game | OK |  |
| MUS-REF-BOSS | Compostella, the Rotheart | `music/MUS-REF-BOSS.ogg` | loop, loop | +1.2 | The Rotheart principal boss (BB-ROT, boss node) | In Game | OK |  |
| MUS-REF-DUN-BATTLE | The Rotheart — combat | `music/MUS-REF-DUN-BATTLE.ogg` | loop, loop | +1.1 | The Rotheart battles and elites (BB-ROT) | In Game | OK |  |
| MUS-REF-DUN-EXP | The Rotheart — exploration | `music/MUS-REF-DUN-EXP.ogg` | loop, loop | +1.0 | The Rotheart node map (D-ROT) and its events | In Game | OK |  |
| MUS-REF-EXP | The Verdant Dump — exploration | `music/MUS-REF-EXP.ogg` | loop, loop | +1.0 | The Verdant Dump (`ZoneScene`, zone `refusemancer`) until its own completion flag is set | In Game | OK |  |
| MUS-REF-FREED | The Verdant Dump — restored | `music/MUS-REF-FREED.ogg` | loop, loop | +1.0 | The Verdant Dump once `zone_refusemancer_completed` is set (returning after the boss, and every later visit) | In Game | OK |  |
| MUS-REF-RELEASE | Compostella — let the seed return | `music/MUS-REF-RELEASE.ogg` | story | +2.9 | The Rotheart leader release scene: cutscene `sever` (`CutsceneScreen`) | In Game | n/a (one-shot) | One-shot; hands back to the dungeon music when it ends or the scene closes. |
| MUS-REUNION | Alive. File complete. | `music/MUS-REUNION.ogg` | story | +3.0 | Ending beat `reunion` (the four Paths meet) | In Game | n/a (one-shot) |  |
| MUS-SHIRO-BOSS | The oldest trick in the book | `music/MUS-SHIRO-BOSS.ogg` | loop, loop | +0.5 | Shiro Swindle's duel (after the giant-chest questline) | In Game | OK |  |
| MUS-SHOP-ALEMBIC | Essences together | `music/MUS-SHOP-ALEMBIC.ogg` | loop, loop | +0.9 | Auntie Alembic (Alchemist, town): vendor screen VS-ALEMBIC (`OverlayScreen.music_cue`), one override per visit | In Game | Needs loop fix: 0.54 s of digital silence at the wrap; ends 13 dB quieter than it begins (decay / cut-off tail) | Not retriggered by purchases; the area music resumes when the shop closes. |
| MUS-SHOP-ALEMBIC-POST | Three essences, new possibilities | `music/MUS-SHOP-ALEMBIC-POST.ogg` | loop, loop | +1.0 | VS-ALEMBIC after `postgame_unlocked` | In Game | Needs loop fix: 0.51 s of digital silence at the wrap | Replaces MUS-SHOP-ALEMBIC. |
| MUS-SHOP-BEETSWORTH | Assistant to the regional merchant | `music/MUS-SHOP-BEETSWORTH.ogg` | loop, loop | +1.0 | Beetsworth (equipment, town): vendor screen VS-BEETSWORTH (`OverlayScreen.music_cue`), one override per visit | In Game | Needs loop fix: 0.45 s of digital silence at the wrap | Not retriggered by purchases; the area music resumes when the shop closes. |
| MUS-SHOP-BELLOWS | Browsing the prizes | `music/MUS-SHOP-BELLOWS.ogg` | loop, loop | +0.9 | Bellows (Grand Clashatorium): vendor screen VS-BELLOWS (`OverlayScreen.music_cue`), one override per visit | In Game | Needs loop fix: 0.41 s of digital silence at the wrap | Not retriggered by purchases; the area music resumes when the shop closes. |
| MUS-SHOP-BENCHLEY | The gym pro shop | `music/MUS-SHOP-BENCHLEY.ogg` | loop, loop | +1.1 | Benchley (Gainlands): vendor screen VS-BENCHLEY (`OverlayScreen.music_cue`), one override per visit | In Game | OK | Not retriggered by purchases; the area music resumes when the shop closes. |
| MUS-SHOP-FENWICK | Foil, whispered reverently | `music/MUS-SHOP-FENWICK.ogg` | loop, loop | +1.0 | Fenwick (pack vendor, town): vendor screen VS-FENWICK (`OverlayScreen.music_cue`), one override per visit | In Game | OK | Not retriggered by purchases; the area music resumes when the shop closes. |
| MUS-SHOP-FIGSLY | Off the books | `music/MUS-SHOP-FIGSLY.ogg` | loop, loop | +1.0 | Figsly (black market, the Crease): vendor screen VS-FIGSLY (`OverlayScreen.music_cue`), one override per visit | In Game | Needs loop fix: 0.51 s of digital silence at the wrap | Not retriggered by purchases; the area music resumes when the shop closes. |
| MUS-SHOP-GRISTLE | Found, not stolen | `music/MUS-SHOP-GRISTLE.ogg` | loop, loop | +1.0 | Gristle (Verdant Dump): vendor screen VS-GRISTLE (`OverlayScreen.music_cue`), one override per visit | In Game | Needs loop fix: 0.36 s of digital silence at the wrap | Not retriggered by purchases; the area music resumes when the shop closes. |
| MUS-SHOP-LEDGERBONE | A correctly completed form | `music/MUS-SHOP-LEDGERBONE.ogg` | loop, loop | +1.0 | Ledgerbone (D.N.A. lobby): vendor screen VS-LEDGERBONE (`OverlayScreen.music_cue`), one override per visit | In Game | OK | Not retriggered by purchases; the area music resumes when the shop closes. |
| MUS-SHOP-MIREPOIX | Under the silver cloche | `music/MUS-SHOP-MIREPOIX.ogg` | loop, loop | +1.0 | Mirepoix (Endless Buffet): vendor screen VS-MIREPOIX (`OverlayScreen.music_cue`), one override per visit | In Game | OK | Not retriggered by purchases; the area music resumes when the shop closes. |
| MUS-SHOP-SABLE | Sable's velvet salon | `music/MUS-SHOP-SABLE.ogg` | loop, loop | +1.0 | Sable (card vendor, town): vendor screen VS-SABLE (`OverlayScreen.music_cue`), one override per visit | In Game | Needs loop fix: 0.45 s of digital silence at the wrap | Not retriggered by purchases; the area music resumes when the shop closes. |
| MUS-SHOP-THREADWELL | Pip's tiny runway | `music/MUS-SHOP-THREADWELL.ogg` | loop, loop | +0.9 | Threadwell (tailor, town): vendor screen VS-THREADWELL (`OverlayScreen.music_cue`), one override per visit | In Game | OK | Not retriggered by purchases; the area music resumes when the shop closes. |
| MUS-SHOP-TONIC | Tilly's bubbling apothecary | `music/MUS-SHOP-TONIC.ogg` | loop, loop | +1.0 | Tonic (item vendor, town): vendor screen VS-TONIC (`OverlayScreen.music_cue`), one override per visit | In Game | OK | Not retriggered by purchases; the area music resumes when the shop closes. |
| MUS-SIPHON-BOSS | A life's work | `music/MUS-LAB-BATTLE.ogg` (alias of MUS-LAB-BATTLE) | loop, loop | +1.0 | Dr. Ambrose Siphon (BB-LAB, boss node) | In Game | OK | Compatibility alias: plays MUS-LAB-BATTLE's file. |
| MUS-SWOLY-BATTLE | Mount Swolympus — combat | `music/MUS-SWOLY-BATTLE.ogg` | loop, loop | +1.2 | Mount Swolympus ordinary battles (BB-S-BEEF) | In Game | OK |  |
| MUS-SWOLY-BOSS | The Ancient Spotter | `music/MUS-SWOLY-BATTLE.ogg` (alias of MUS-SWOLY-BATTLE) | loop, loop | +1.2 | Mount Swolympus boss (BB-S-BEEF, boss node) | In Game | OK | Compatibility alias: plays MUS-SWOLY-BATTLE's file. |
| MUS-SWOLY-EXP | Mount Swolympus — exploration | `music/MUS-SWOLY-EXP.ogg` | loop, loop | +1.1 | Mount Swolympus node map (S-BEEF) and events | In Game | OK |  |
| MUS-THRONE | The Pathwork Throne | `music/MUS-THRONE.ogg` | story | +2.3 | Ending beat `throne` (`EndingScreen`) | In Game | n/a (one-shot) |  |
| MUS-TITLE | The Wayward Path | `music/MUS-TITLE.ogg` | loop, loop | +1.0 | Title screen (`TitleScreen._ready`; also drops any music override left from a game) | In Game | OK |  |
| MUS-TOWN | Crosspath — roads converge | `music/MUS-TOWN.ogg` | loop, loop | +0.9 | Town (`TownScene`) until all four zones are freed; the base under shops, the graveyard and Maren's scenes | In Game | OK |  |
| MUS-TOWN-BATTLE | Friendly ground, serious cards | `music/MUS-TOWN-BATTLE.ogg` | loop, loop | +0.9 | Battles on BB-TOWN (town duels, neutral encounters); also the generic fight-song fallback | In Game | OK |  |
| MUS-TOWN-FREED | Crosspath — returning citizens | `music/MUS-TOWN-FREED.ogg` | loop, loop | +0.9 | Town once `ZoneCompletion.count` reaches 4 (partial recovery keeps MUS-TOWN) | In Game | OK |  |
| MUS-TUNNEL-BATTLE | Old Service Tunnels — combat | `music/MUS-TUNNEL-BATTLE.ogg` | loop, loop | +0.9 | Old Service Tunnels ordinary battles (BB-S-CAP) | In Game | OK |  |
| MUS-TUNNEL-BOSS | Captain Spotless | `music/MUS-TUNNEL-BATTLE.ogg` (alias of MUS-TUNNEL-BATTLE) | loop, loop | +0.9 | Old Service Tunnels boss (BB-S-CAP, boss node) | In Game | OK | Compatibility alias: plays MUS-TUNNEL-BATTLE's file. |
| MUS-TUNNEL-EXP | Old Service Tunnels — exploration | `music/MUS-TUNNEL-EXP.ogg` | loop, loop | +0.9 | Old Service Tunnels node map (S-CAP) and events | In Game | OK |  |
| MUS-TUT-BATTLE | Forgotten Cave — first trials | `music/MUS-TUT-BATTLE.ogg` | loop, loop | +1.0 | Forgotten Cave battles (BB-TUT) | In Game | listen: 7 dB step at the wrap |  |
| MUS-TUT-BOSS | Hollow Warden — familiar scent | `music/MUS-TUT-BATTLE.ogg` (alias of MUS-TUT-BATTLE) | loop, loop | +1.0 | Hollow Warden boss (BB-TUT, boss node) | In Game | listen: 7 dB step at the wrap | Compatibility alias: plays MUS-TUT-BATTLE's file. |
| MUS-TUT-EXP | Forgotten Cave — old passage | `music/MUS-TUT-EXP.ogg` | loop, loop | +1.0 | Forgotten Cave node map (D-TUT, no main/side dungeon active) | In Game | Needs loop fix: 0.37 s of digital silence at the wrap |  |
| MUS-VAULT-BATTLE | Forgotten Vault — combat | `music/MUS-VAULT-BATTLE.ogg` | loop, loop | +0.7 | Forgotten Vault ordinary battles (BB-S-TOWN) | In Game | listen: 8 dB step at the wrap |  |
| MUS-VAULT-BOSS | The Vault Guardian | `music/MUS-VAULT-BATTLE.ogg` (alias of MUS-VAULT-BATTLE) | loop, loop | +0.7 | Forgotten Vault boss (BB-S-TOWN, boss node; also the Warden of the Four Seals duel) | In Game | listen: 8 dB step at the wrap | Compatibility alias: plays MUS-VAULT-BATTLE's file. |
| MUS-VAULT-EXP | Forgotten Vault — exploration | `music/MUS-VAULT-EXP.ogg` | loop, loop | +0.5 | Forgotten Vault node map (S-TOWN) and events | In Game | OK |  |
| MUS-WAIT-BATTLE | Waiting Room of Eternity — combat | `music/MUS-WAIT-BATTLE.ogg` | loop, loop | +1.1 | Waiting Room of Eternity ordinary battles (BB-S-NECRO) | In Game | OK |  |
| MUS-WAIT-BOSS | Betty Bones | `music/MUS-WAIT-BATTLE.ogg` (alias of MUS-WAIT-BATTLE) | loop, loop | +1.1 | Waiting Room of Eternity boss (BB-S-NECRO, boss node) | In Game | OK | Compatibility alias: plays MUS-WAIT-BATTLE's file. |
| MUS-WAIT-EXP | Waiting Room of Eternity — exploration | `music/MUS-WAIT-EXP.ogg` | loop, loop | +1.0 | Waiting Room of Eternity node map (S-NECRO) and events | In Game | OK |  |
| STG-ARENA | Grand Bellows presents | `stings/STG-ARENA.wav` | sting | +6.1 | Arena screen opens | In Game | n/a (one-shot) |  |
| STG-CRAFT | Two Paths, one new card | `stings/STG-CRAFT.wav` | sting | +5.8 | Alchemist craft (two Paths) | In Game | n/a (one-shot) |  |
| STG-CRAFT-POST | More than two | `stings/STG-CRAFT-POST.wav` | sting | +5.9 | Alchemist craft with three or more Paths | In Game | n/a (one-shot) |  |
| STG-DEFEAT | A setback, not the end | `stings/STG-DEFEAT.wav` | sting | +6.0 | Battle lost (`defeat` effect name) | In Game | n/a (one-shot) |  |
| STG-DUNGEON | The way through | `stings/STG-DUNGEON.wav` | sting | +6.0 | Dungeon cleared: the Forgotten Cave's end, a side dungeon first / repeat clear | In Game | n/a (one-shot) |  |
| STG-LEVEL | A little stronger | `stings/STG-LEVEL.wav` | sting | +5.7 | Level-up popup and unlock fanfares (the `level_up` effect name) | In Game | n/a (one-shot) |  |
| STG-MINI-FAIL | Try another approach | `stings/STG-MINI-FAIL.wav` | sting | +5.8 | Quiz or minigame failed | In Game | n/a (one-shot) |  |
| STG-MINI-SUCCESS | Correctly sorted | `stings/STG-MINI-SUCCESS.wav` | sting | +6.2 | Quiz, minigame or puzzle passed | In Game | n/a (one-shot) |  |
| STG-PACK-COMMON | A new possibility | `stings/STG-PACK-COMMON.wav` | sting | +7.5 | Pack opening: the pack tears open | In Game | n/a (one-shot) |  |
| STG-PACK-LEGEND | A legend in your hands | `stings/STG-PACK-LEGEND.wav` | sting | +6.0 | Pack reveal: a legendary card | In Game | n/a (one-shot) |  |
| STG-PACK-RARE | Something special | `stings/STG-PACK-RARE.wav` | sting | +5.8 | Pack reveal: a rare or epic card | In Game | n/a (one-shot) |  |
| STG-PURCHASE | A good bargain | `stings/STG-PURCHASE.wav` | sting | +6.5 | Any vendor purchase (cards, items, equipment, packs, tailor) | In Game | n/a (one-shot) |  |
| STG-QUEST | A promise kept | `stings/STG-QUEST.wav` | sting | +6.2 | Quest completed popup (`RewardPopup`) | In Game | n/a (one-shot) |  |
| STG-RIFT | The seam closes | `stings/STG-RIFT.wav` | sting | +5.9 | A Capital rift sealed | In Game | n/a (one-shot) |  |
| STG-SECRET | An unexpected way | `stings/STG-SECRET.wav` | sting | +6.1 | A secret discovered (`Session.discover_secret`) | In Game | n/a (one-shot) |  |
| STG-SHIRO | Smoke bomb! | `stings/STG-SHIRO.wav` | sting | +2.8 | Shiro's smoke bomb | In Game | n/a (one-shot) |  |
| STG-VICTORY | Battle won | `stings/STG-VICTORY.wav` | sting | +6.0 | Battle won (`BattleScreen` result; the `victory` effect name plays this sting) | In Game | n/a (one-shot) |  |
| STG-ZONE-BEEF | The wheels breathe again | `stings/STG-ZONE-BEEF.wav` | sting | +6.1 | The Gainlands freed (announcement screen) | In Game | n/a (one-shot) |  |
| STG-ZONE-GOUR | A meal worth sharing | `stings/STG-ZONE-GOUR.wav` | sting | +6.1 | The Endless Buffet freed | In Game | n/a (one-shot) |  |
| STG-ZONE-NECRO | Approved: humanity | `stings/STG-ZONE-NECRO.wav` | sting | +6.1 | The D.N.A. freed | In Game | n/a (one-shot) |  |
| STG-ZONE-REF | Back to the soil | `stings/STG-ZONE-REF.wav` | sting | +6.1 | The Verdant Dump freed | In Game | n/a (one-shot) |  |
