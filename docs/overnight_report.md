# Overnight report - Mon Oct 19 -> Tue Oct 20 2026

Start 21:27 MDT (tag `pre-overnight-oct19`), all seven parts done by ~23:30, then the improvement loop. The daytime report is in
`docs/overnight_report_oct19day.md`. Old saves keep loading (every dialogue key, quest id and flag kept; only new ones added).
Questions for you: `docs/overnight_inbox.md` ("Overnight Oct 19-20", items 1-14). Final checks at the end of this file.

## In one minute

- **The D.N.A. is see-through where it matters**: no more ceiling beams, light strips or doorway headers across the view; walls go to full
  interior height (4.5 m) and are lit by glowing wall sconces; any wall between the camera and the hero fades or cuts away. Every other zone
  was checked at all nine camera angles: the only blockers left were the pennant strings over the Buffet and Dump entrances, which now fade.
- **Card text is never hidden**: the ability box sits on its own top layer, beside the hovered card (flips near the edges), never over it.
- **Tomorrow's art import is drop-in**: `docs/art/import_oct20.md` lists exactly what to run, in order.
- **The story has one source of truth** (`docs/design/story_bible.md`, ~1000 lines, 36 contradictions resolved) and **the dialogue was
  rewritten to it**: 258 conversations, scored by separate editors from **3.17 to 4.04 out of 5** (no conversation under 4). Every first
  talk is now 5 boxes or fewer (Basil was 11). Gatekeepers, workers, Kyle and Ectomund say new things once their zone is freed.
- **The Old Well is a secret quest** ("The Water Under the Well"): a vision, a hidden spring high in the Verdant Dump, a pond in the
  Endless Buffet's broccoli forest, then a hard duel against **The Wellspring's Echo** (52% / 61% on two seeds at level 16) for a
  unique relic, the **Phial of First Water**, and a lore reveal. Tested end to end in the live game.
- **Music**: five loops had a hiccup of digital silence at the wrap (fixed); a drop-in pipeline for new music; prompts for new takes with
  one shared theme, Crosspath first.

## Before / after worth seeing (`_screenshots/oct19n/`, 1280x720)

1. **D.N.A.** - `p1_before_dna_records_center.png` -> `p1_after_dna_records_center.png` (the beams and strips are gone; sconces glow);
   `p1_before_dna_spawn.png` -> `p1_after_dna_spawn.png`; `p1_after_dna_farm_a_aisle.png` (a wall in front of the hero turns to a
   ghost); `p1_after_dna_main_dungeon.png` (the Hall stair); the nine-angle grids `p1_before_dna_grid.png` -> `p1_after_dna_grid.png`.
2. **Other zones** - `grid/*.png` (nine angles each); `p1_after_buffet_gate.png`, `p1_after_heap_gate.png` (entrance bunting).
3. **Card text** - `p2_before_hand_0.png` -> `p2_after_hand_7.png`, `p2_after_field_2.png`, `p2_after_etrap_0.png`, `p2_after_token_0.png`.
4. **Equipment screen** - `_screenshots/oct19n_p3_character.png` (old background: five slots on painted frames, the three spare frames
   patched) and `oct19n_p3_character_clean.png` (the layout the new background switches to by itself).
5. **The Old Well** - `_screenshots/oct19n_p6_heap_spring.png`, `oct19n_p6_buffet_pond.png` (the two faint glows),
   `_screenshots/old_well_01_vision.png` .. `old_well_05_reveal.png` (the live smoke).

## Part by part

| Part | Commits | What |
|---|---|---|
| 1 - D.N.A. visibility | 26cf4282, 3765d67e | Beams/strips/headers removed; 4.5 m walls; sconces (+ pooled lights); per-piece fade + lens cut-away; every zone checked at 9 angles; overhead pieces fade (`OcclusionFader.is_overhead`); bunting split out. 60 fps on Medium (D.N.A. 59.7-60, Buffet 59.7, Dump 59.8, Crosspath 60). D.N.A., Buffet, Dump walk smokes OK. |
| 2 - Card text | e2cf40ea | `BattleHud` tip on CanvasLayer 25, `tip_position()` beside the card (right, else left, else above/below), follows the card each frame; name + ability text (keyword-only text skipped) + keywords; tests; first-battles smoke OK. |
| 3 - Art import prep | c02694be | ICON-GEAR/ITEM/COS conventions with fallbacks, the icon importer expects every game id (54 gear / 18 items / 10 cosmetics); `import bestiary` (new); BB-S-IRON; 33 + 26 zone kit rows; png/webp/jpg kits; 5-slot equipment screen for both backgrounds (`[character] background_painted_slots`, set by the UI importer); `docs/.gdignore` + stray translations deleted; `docs/art/import_oct20.md`. |
| 4 - Story bible | e7c78c6d | `docs/design/story_bible.md` (23 sections), `docs/design/canon.md` (banned old names), older docs archived with pointers, 7 inbox items. |
| 5 - Dialogue pass | dd29a10b, 93cb6207, c3485f6d, 03a04532 | Voice bible (81 voices), beat map, four writers, four separate editors, tests (`tests/test_dialogue_quality.gd`), report `docs/design/dialogue_pass_oct19.md`. |
| 6 - Old Well quest | c02694be | `OldWellQuest`, `OldWellStory` (`data/story/old_well_story.json`), `OldWellSpot`, Session hooks, rule + sim entry, relic, tests (21), story bible section 4. |
| 7 - Music | 92691601 | `tools/music_fix.js`, `MusicDropIn`, `import_audio.sh --dry-run`, `docs/audio/music_generation_prompts.md`, audit "Oct 19 fixes". |

## The dialogue sample

The 30 best before -> after examples, the score table per zone and the list of things that need code are in
**`docs/design/dialogue_pass_oct19.md`** (with the first-talk trims and the barks pass at the end). Three to start with:

- Opening, the first words: "Where am I?... I remember a kingdom. Four Paths... Light, through the rocks" -> "...Cold. Leaves in my mouth.
  Great start." / "No name. Two hands. One of them is shaking. I'll start with the other one." / "...And I'm not alone."
- The Buffet reveal: "THIS is my real face. Behold the true dish of {villain}: the Doppelgänger." -> "This is what was under it. I wore her
  face so long that I forgot my own. There is nothing in here to taste with."
- Primm's end: "It is not too late to say sorry." -> "I'm not going to correct you. That was your way. Start smaller. Say sorry to one
  person."

| Area | Conversations | Old | Final | Under 4: old -> final |
|---|---|---|---|---|
| Opening + Crosspath | 68 | 3.01 | 4.01 | 49 -> 0 |
| Gainlands | 29 | 3.31 | 4.00 | 17 -> 0 |
| Endless Buffet | 27 | 3.19 | 4.00 | 16 -> 0 |
| D.N.A. | 28 | 2.89 | 4.00 | 24 -> 0 |
| Verdant Dump | 25 | 2.92 | 4.00 | 19 -> 0 |
| Capital, castle, side dungeons, Lab | 81 | 3.41 | 4.11 | 41 -> 0 |
| **All** | **258** | **3.17** | **4.04** | **166 -> 0** |

(Score = the lowest of five 1-5 scores: in character, funny, story beat landed, brevity, clarity of what to do next.)

## The Old Well walkthrough (spoilers)

1. **Start**: once at least one Path zone is freed, touch the Old Well in Crosspath's square. A short vision plays (the well whispers) and
   the hidden side quest **"The Water Under the Well"** starts (the Quest Log entry is vague on purpose; no map markers). Before any zone is
   freed the well keeps its old line. The Forgotten Vault's hatch beside the well is unchanged.
2. **Task, Verdant Dump**: the Overgrown Plateau (the highest terrace), at its west edge where the river starts down the gorge, just off the
   lane round Rust Peak. A faint cyan glow and motes: "Kneel by the water". (The top terrace needs the junk barricade smashed with a mount,
   as for the Rotheart.)
3. **Task, Endless Buffet**: the bank of the little gravy pond in the Broccoli Forest, just off the forest road: "Look into the pond".
4. **Return**: the well glows brighter: "Lean over the Old Well" -> confirm -> the Echo speaks -> the Before-the-fight card shows
   **The Spring Remembers** (one icon): the Echo's units get +2/+2, it heals 2 HP at the start of its turns and starts with an Iron, a Red
   Tape, an Ingredient and a Garbage. Its deck is 40 existing cards from all four Paths. Intended level ~16; the sim says 52% / 61%.
5. **Reward (first win only)**: the **Phial of First Water** (relic, legendary: multi-Path cards cost 1 less generic energy, +1 HP at the
   start of your turn), 250 gold, 300 XP, and the final vision: the one Wellspring rises under Crosspath, the Vault was built over its
   source and sealed by all four Paths, it failed ten years ago (when the cave's Hollow Well dried), and it waits "for a hand that can hold
   all four". The Echo's duel plays the Vault's battle song; the visions play the Vault's theme.
- Smoke: `bash tools/run_old_well_smoke.sh` (every check passed tonight).

## Music

- **Fixed**: MUS-BEEF-EXP, MUS-BEEF-DUN-EXP, MUS-BEEF-DUN-BATTLE, MUS-BEEF-BOSS, MUS-SHOP-MIREPOIX ended in 30-40 ms of digital silence
  (a hiccup at every wrap): trimmed, normalised to -20 LUFS, OGG q5; originals in `_art_source/audio_backup_oct19/`.
- **No track was still rated 1-2** after the Oct 17 work, so the "worst tracks" were re-rated: Crosspath's MUS-TOWN-FREED (opens like
  MUS-TOWN) and MUS-DECK (a 7.7 dB step at the wrap), MUS-QUIZ, MUS-ARENA-BATTLE and MUS-ARENA-ELITE are now 3s. Their seams were searched
  for a better loop point (none safer than the composed wrap).
- **Pipeline**: drop a file named by its ID into Approved_Audio and `bash tools/import_audio.sh` trims silence, finds a loop point,
  normalises (two-pass loudnorm), encodes OGG q5 and registers it (`--dry-run` to preview). Verified: 144 IDs, nothing to copy, none missing.
- **Prompts** (`docs/audio/music_generation_prompts.md`): one shared main theme, the "Crossroads figure" in D Dorian, in every prompt;
  Crosspath first: MUS-TOWN_v03, MUS-TOWN-FREED_v02, MUS-TOWN-BATTLE_v02, MUS-DECK_v02; then MUS-QUIZ_v02, MUS-ARENA-BATTLE_v02,
  MUS-ARENA-ELITE_v02. A listen list is in `docs/audio/music_audit.md` "Oct 19 fixes".

## Tomorrow's art import

Everything is in **`docs/art/import_oct20.md`** (in order: card art, portraits, NPC sprites, icons, zone kit gainlands, zone kit heap,
maps, battleboards, **bestiary** (new: `bash tools/import_bestiary.sh` from `Approved_Bestiary`), UI art), with what each reports and the
screenshots to check after. The new UI-BG-CHARACTER switches the equipment screen to its own five frames automatically.

## Phase 2 (the improvement loop)

PHASE2_TABLE

## Scorecard (start -> end)

SCORECARD_TABLE

## Final checks

FINAL_CHECKS
