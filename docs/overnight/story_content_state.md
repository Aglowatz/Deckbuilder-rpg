# Story content + balance brief (Oct 21 2026) - running state

Resume file for the "BUILD THE MISSING STORY CONTENT + BALANCE FIXES" brief. Brief copy: `docs/overnight/brief_story_content_oct21.md`.
Start tag `pre-story-content-oct21`. Check for `STOP_TASK` (repo root or `C:\Users\asche`) before each part. One Godot at a time.

## User decisions (locked)

- Lieutenants and Isla are humanoid animals as in their art: Quota ferret, Crumb badger, Plume peacock, Clipwell hare, Isla bear. Isla gets
  one light line that she takes after her mother's side.
- Elowen stays "The Rescuer" (`{rescuer}`) until Plume has her seized at the castle gate on the Wanderer's first entry ("Miss Elowen Vey, I
  presume"); from then on her name is used.
- No new art; list missing pictures in `docs/art/art_backlog.md`. No enemy intent. Don't touch the black market vendors.

## The live sheet (fetched Oct 21 via the Sheets connector; the local CSVs in data/source are from Oct 11-13 and miss these)

Spreadsheet `1GRfPvgp9I4TWVRO4T7p4bOJMwJ9kaVKt2q-0ybdXfYw`. Excerpts saved in `docs/design/sheet_excerpts_oct21.md`.

The local snapshot `data/source/dungeon_list.csv` was patched with the live rows (D-HOG/D-TTK/D-ROT/D-PC story, D-PC node 14 = Plume
elite, S-PASTE inserted with local reward/map/board columns) and re-imported (`bash tools/import_dungeons.sh`). The 16-node D-LAB rows
are held back for Part 2: scratchpad `lab_part2.json` = the D-LAB cell values (copy is in sheet_excerpts_oct21.md).

## Design plan (my calls; log in inbox)

- Quota: D-HOG node 6 foe becomes "Vivienne Quota, Minister of Efficiency" (story_keys hg_quota before/after). Flees: a beat after the
  zone falls. Capital: one-off duel in the Transit Yards once cap_wheels is done and the Gainlands are free (sheet).
- Crumb: D-TTK node 6 scene (story_keys ttk_crumb: he inspects the War Machine, leaves); flees; S-PASTE via a new Marlo quest
  `cap_paste_works` (after cap_recipes + Buffet freed); relic reward "The Colonel's Ladle".
- Plume: D-PC start-node capture scene on first entry (new start-story hook, flag `elowen_seized`, `rescuer_named` -> {rescuer} reads
  Elowen); D-PC node 14 elite Plume with memo. Old saves past Primm get a story note.
- Clipwell: D-ROT node 6 (Root-Choked Mill) elite = Clipwell; flees; Capital short scene on the lawn after cap_untidy (no 2nd fight).
- Elowen: town cave-mouth spot ("gate") shows her while `cave_mouth_seen` < zones freed (max 4) and not seized; Lab = sheet's 16 nodes,
  Cell 4 rescue, T-24 ally, Protocols with suppression; not rescued -> confrontation after the boss.
- Isla: Brannoch's gate after primm_defeated; Funeral: Grave Row after the ending; Hob: graveyard NPC + zone wake line + cameos.

## Part status

| Part | Status | Notes |
|---|---|---|
| 1 lieutenants | done | Lieutenants, StoryScenes, S-PASTE + cap_paste_works, capture + StoryBeats; sims in balance_log "Oct 21 - Part 1"; GUT green; dungeons + Capital walk smokes green (dungeons smoke fixed for the rules card and the v0.4.0 arrival) |
| 2 Elowen | done | Cave Mouth scenes (StoryBeats), 16-node Lab, Cell 4 + T-24, ProtocolJam + HUD chooser, confrontation scenes, sims in balance_log Part 2 |
| 3 canon beats | not started | |
| 4 balance | not started | |
| 5 verify | not started | |
