# Disk cleanup - Nov 3 2026

Designer-approved list (Nov 3). Nothing else was deleted. No Godot, test run or export was running. Code, `assets/`, `data/`, `docs/`, `.git` history,
`.godot/`, `build_cache/`, every `Approved_*` folder, `Music_Source/` and `C:\Dev\music_tools` were not touched. Sizes are measured right before and
after each delete. Drive deletes go to Google Drive's trash.

C: free space: **1.31 GB before**, 4.61 GB after the local items, 4.63 GB after `git gc`.

| # | Item | Paths | Before | After |
|---|------|------:|-------:|------:|
| A1 | `builds/TheWaywardPath-v0.4.9-windows.zip` + `-v0.5.0-windows.zip` | 2 | 1,523.2 MB | 0 |
| A2 | `_screenshots/` from before Nov 1 (see below) | 198 | 377.0 MB | 0 |
| A3 | `_art_source/audio_original`, `_art_source/audio_backup_oct19` | 2 | 67.5 MB | 0 |
| A4 | `_art_inbox/` staging/test leftovers (see below) | 22 | 1,359.5 MB | 0 |
| A5 | `_logs/` old test logs, e*.json, fable_/oct28_ scripts, probes, smoke/tour/walk/story/chain/bot/g_ text, graphics_loop logs | 357 | 9.4 MB | 0 |
| A6 | `_asset_library/*.zip` (unzipped folders kept) | 13 | 36.8 MB | 0 |
| A7 | `git gc` (no history rewrite): 5 packs -> 2, 220 loose objects packed | - | 3.23 GiB pack | 3.23 GiB pack (~9 MB freed) |
| A8 | Drive `Superseded/Music_v01/`: the LMMS-era originals (plain-named .ogg/.wav dated Oct 9-11, incl. the old stinger WAVs) | 143 | 647.5 MB | 0 |
| A9 | Drive `Music Review/` (MP3 previews) | 1 | 390.0 MB | 0 |
| A10 | Drive `Character_Test`, `Paper_Test` (empty), `Texture_Test` (empty), `Paintover_Inputs` | 4 | 142.2 MB | 0 |
| A11 | Drive `Replaced Artwork - Batch 1 - Oct 28` | 1 | 7.3 MB | 0 |

Local total 3,373 MB; Drive total 1,187 MB.

## Details and what was kept

- **A2**: whole folders `oct20d`, `oct25`, `oct30`, `oct31`, `oct31n`, `dungeons`, `gamepad`, `gatekeeper_pick`, `p1ab`, `quest_smoke` (all their files
  pre-Nov 1, except the named oct20d/oct25 folders); `play/` runs with no file from Nov 1 on (`oct31_*`, `p5_ux*`, `music_pass*`, `loads_oct31n_*`);
  top-level files and `dialogue/` files dated before Nov 1 (old logs, `.import`s, hand_/c*_/p*_ shots). Kept: `nov2/`, `nov3/`, `batch11/`,
  `capital_walk/` and the other walk folders (rewritten Nov 2), `beats/`, `exported/`, `playthrough/`, `loading_timing/`, the Nov 1-2 `play/` runs.
  No doc in `docs/` calls any deleted shot a current reference.
- **A4**: `fake_hats`, `fake_hat_sheets`, `fake_hats_split`, `pending_hats*`, `pending_npc_dry`, `world_test`, `world_test_sheets`, `character_test`,
  `npc_sprites`, `npc_sprites_b11`, `npc_sprites_oct31`, `cosmetics`, `cosmetics_b11`, `cosmetics_oct31`, `paper_src`, `texture_src`,
  `env_kit_preview`, `oct29_ids_*.txt`. No game code, test or export step reads them; only the old one-off importers do (`import_npc_sprites.sh`,
  `import_cosmetics.sh`, `world_test_import.gd`, `char_import.gd`, `import_textures.gd`, `split_sprite_sheets.gd`, `fake_hats.gd`), and those copy
  their inputs from the Drive again, so they recreate the folders on their next run. `batch11/` kept.
- **A5**: only top-level files; `_logs/gut/` and every subfolder (`export*`, `probes_keep`, `bak`, ...) kept; nothing from Nov 2 on matched.
- **A8**: kept every `*_orch-v1b.*`, the 8 `*_orch-v1.*` files, the 23 plain-named files dated Oct 31 (first orchestral deliveries, not LMMS-era)
  and all 25 registry/alias JSON copies.
- **A10 - kept `Approved_WorldTest`**: `data/source/art_config.cfg` names it `worldtest_dir`, and `tools/import_cosmetics.sh` reads it as its second
  source (it copies `COS-HAT-*` / `SPR-PLAYER-CLOAK-*` from there; none are in it today). It also holds the only `SPR-PLAYER-*` default walk set and
  the World Look Test sources. Remove the `worldtest_dir` line first if it should go.
- **A11 - kept the "(1)" files in `Superseded/`** (`NPC-ELDER (1)`, `NPC-GATEKEEPER (1)`, `NPC-PATE (1)`, `N-10 (1)`, `CAP-PATH-WHITE (1)`,
  `COS-HAT-LEAFCROWN-SHEET (1)`/`(2)`, ~13 MB): each differs in size from its original, so they are older versions, not duplicate copies.
- `builds/TheWaywardPath-v0.5.1-windows.zip` is handled in Part B (deleted only after v0.5.2 exports and passes its smoke).
