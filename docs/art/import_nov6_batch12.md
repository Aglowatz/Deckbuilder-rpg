# Batch 12 art import (Nov 6)

**Summary:** all 84 files of `Pending Review/Batch 12` are filed in their Approved_* folders and imported. 25 older versions went to
`Superseded`, with local copies in `_art_source/superseded_batch12/`. The images were wired and shot in game, with two exceptions:
- NPC-PLAYER was held back (see Redo).
- GAIN-HERO-IRON-CRAG is a concept reference, so it has no in-game shot.

Tag `pre-batch12`. Plan: `docs/art/import_nov5_ready.md`. Rows: `docs/art/art_needed_nov4.csv`. No export.

## Filing (tools/batch12_move.js)

`node tools/batch12_move.js` (dry run) / `--apply`. It looks up each destination by exact name, because Drive folder listings are too slow.
An existing file of the same name is moved to `Superseded/` first.

| Prefix | Folder | Files | Replaced |
|---|---|---|---|
| NPC-, CUT- | Approved_Characters | 12 | NPC-FLEX, NPC-PLAYER |
| SPR- | Approved_Sprites | 57 | FLEX x4, PRIMM x4, KYLE x4, GERALD x4 |
| STORY- | Approved_KeyArt | 7 | RESCUE, FLEX, PRIMM-FALL, EPI-TOGETHER, WAKE, WAKE-NIGHT |
| BST- | Approved_Bestiary | 5 | - |
| UI- | Approved_UI | 1 | UI-BG-DECKBUILDER |
| MAP- | Approved_Maps | 1 | - |
| OF-, GAIN- | Approved_ZoneKits/OpeningForest, /Gainlands | 2 | - |

Three files the plan did not list also came: NPC-PLAYER, STORY-WAKE and STORY-WAKE-NIGHT. They are the hero redrawn in the teal cloak of
his sprite, which answers the SPR-PLAYER-CLOAK row by changing the art rather than the sprite.

## Importers (one Godot at a time)

| Importer | Result |
|---|---|
| portraits | 12 added/replaced; flat backgrounds cut from NPC-FLEX, -FLEX_REVEAL, -TOWNSFOLK(-A/B/C) |
| npc sprites | FLEX, PRIMM, KYLE, GERALD re-cut; new FLEX_FREED, ROLLO, TOWNSFOLK_A/B/C (21 frames, walks in 4 directions) |
| key art | 7 stills (STORY-CLENCH-THRONE new) |
| bestiary | 5 added: 99 of 99 entries have a picture |
| ui art | UI-BG-DECKBUILDER replaced |
| maps | MAP-S-GALLERY: the castle stand-in drops out |
| zone kits | OF-PROP-BRAMBLES (in game), GAIN-HERO-IRON-CRAG (CONCEPT: `docs/art/zone_kits/gainlands/concepts/`) |

Manifest clean-up after the importers:
- **Sprite manifest:** the importer rewrote `assets/art/world_test/sprites/manifest.json` and dropped the `head` / `cloak_hue` fields
  (written by `tools/sprite_anchors.gd`) from 26 untouched entries. HEAD's entries were kept for every unchanged set, so only the 8
  changed sets differ.
- **Zone kit JSONs:** the importer rewrote them with float churn. The new item was spliced into HEAD's text instead.
- **art_status.md:** truncated by a failed status write (see Gotchas), then restored from HEAD and regenerated.

## Wiring

- **Primm's defeat:** `primm_end` plays over the redone STORY-PRIMM-FALL again. `StoryStills.PARKED` is now empty.
- **Flex's beats:** STORY-CLENCH-THRONE is in `BACKDROP_IDS`, so Flex's beats 1-2 show Clench on his throne and no cutscene beat keeps the
  icon stage. `AWAITING_ART` is empty.
- **Freed Flex:**
  - Sprite: the `heartlift` entries in the Gainlands and Capital use `"sprite": "FLEX_FREED"` (the painted lion, not the Barbarian model).
  - Portrait: `Portraits.AFTER_ZONE_EXPRESSIONS` makes untagged NPC-FLEX lines show `reveal` (NPC-FLEX_REVEAL) once the House of Gains
    (`beefcake`) is cleared, and the dialogue box applies it.
- **Rollo:** walks as himself. `NpcSprites.KEY_ALIASES` is empty (it was NPC-ROLLO -> GUS).
- **Figsly:** he already stood as his painted FIGSLY set, imported with the first NPC sprite pass. The art list's "3D stand-in" note was
  out of date. Now pinned by a test and shot.
- **Crosspath crowds:** `TownScene.STROLLERS` has five walkers on the new sets:
  - A by the Well, C on Maren's lane and B at the Arena gate;
  - two new loops: B round the square and A by the market.

  `stroller_character` falls back to VILLAGER when a set is missing. All five stay on walkable ground (`test_sprite_npcs`).
- **Townsfolk portrait:** NPC-TOWNSFOLK uses its own portrait, no longer NPC-CITIZEN (`npc_game_map.json` / `npcs.json`). The A/B/C
  portraits are imported and listed in `Portraits.EXTRA_PORTRAITS`. The strollers only bark, so no dialogue box shows those portraits yet.
- **Brambles:** OF-PROP-BRAMBLES stands in the bramble gap by itself, through the existing `StartingAreaBuilder._build_brambles` hook.

## Screenshots (docs/art/batch12/)

Tool: `bash tools/batch12_shots.sh [portraits|stills|world|ui]`. New shot aids:
- dialogue_shots token `portrait:<ID>[@<NPC>][~<expr>]`
- town `--strollers_at=<anchor>`
- town `--open=bestiary --beast=<Entry_Name>`

| Shot | Shows |
|---|---|
| portraits.jpg | every new portrait in the real dialogue box (frail lion, revealed lion, CUT-FLEX, townsfolk x4, gym attendant, Brisket, Sir Loin, guard, player) |
| stills.jpg | flex 1 (Clench throne), flex 3 (reveal), rescue 1, primm_end 1/5 (real-size Primm), epilogue 6 (caught mid gold flash, as in Batch 11), STORY-WAKE, STORY-FLEX |
| wake_night.jpg | the night wake still on a fresh start |
| npcs_rollo_flex_walkers.jpg | freed Flex in the Gainlands hub, Rollo in the Capital, townsfolk A + B at the Well |
| crosspath_walkers.jpg | townsfolk B + C beside the hero |
| crease_freed_flex.jpg, primm_crease.jpg | the freed Flex lion and Primm (white-and-gold) in the Crease after the fall |
| figsly.jpg | Fig Sly, painted, at his stall |
| dna_gerald.jpg, dna_kyle.jpg | the new ghost-green sprites |
| bestiary.jpg | the five new Collection Book pictures |
| map_gallery.jpg | The Shattered Gallery's own map |
| deck_station.jpg | the new deck station backdrop |
| brambles.jpg | the painted thicket south of the bedroll |

## Redo / open

1. **NPC-PLAYER (REDO):** it arrived opaque, with a dark painted backdrop, so the dialogue box showed a dark rectangle behind the hero.
   - The game keeps the previous cut-out, and the manifest row keeps the old MD5.
   - The new file is in Approved_Characters, so **the next portrait import would bring the rectangle back**: replace it with a
     transparent version first.
2. **CUT-FLEX** is imported but not shown in battle. Using it needs a new "ally joins" entrance in the Clench fight (new UI and a line of
   text). Decide whether to build it.
3. **GAIN-HERO-IRON-CRAG** is a CONCEPT row: the reference for a crag model, not in-game art.
4. **Tests:**
   - The full sharded run was stopped by the host for low memory after 14 of 29 shards.
   - Shards 1-13 all passed. Shard 14 has one pre-existing failure from the Nov 4-5 overnight: `test_mini_dungeon` says the
     `cracks_in_the_glass` quest has no offer/ready/done text.
   - Every test touching this change passed alone: batch12, story backdrops x2, crosspath bounds, compile-all, capital, painted NPCs,
     no-citizen, sprite NPCs, NPC labels, ending postgame, zone stories, sprite rollout.
   - Shards 15-29 still need a run with nothing else open: `bash tools/run_tests.sh --size=12 --from=15`.

## Gotchas

- `Portraits` is compiled by the importers' `-s` scripts, which have no autoloads. Naming `Session` there broke every importer's
  status write (`replace_section` "nonexistent"). It is now looked up at run time.
- A failed status write truncates `docs/art/art_status.md`: restore it from HEAD.
- Teleporting to a spot puts the hero in front of its NPC; use `--at=beside:<anchor>` for NPC shots. `--postgame=1` removes the
  forest brambles; use `--quiet=true` for the forest without the wake.
