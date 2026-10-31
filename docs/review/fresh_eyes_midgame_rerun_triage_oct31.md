# Mid-game critic rerun - triage of the top 15 (Overnight Oct 30-31, Part 1)

Source: `docs/review/fresh_eyes_midgame_rerun_oct31.md` (a new critic subagent with no project context, brief
`docs/review/critic_brief_midgame_rerun_oct31.md`, 15 runs, ~40 min, 46 shots). Snapshot `midgame_real`, made by the story playthrough
bot (`bash tools/run_story_playthrough.sh --snapshot_after=2 --snapshot=midgame_real`): the cave, Maren's chain, Brannoch, the Gainlands
and the D.N.A. played through by the bot (favours, side and main dungeons, memories), then the expected player's level 13, deck
(`ProgressionModel.reference_deck`), gear, items and 600 gold. **Overall 5.5 / 10** (the first mid-game critic, from a weaker snapshot:
5.2).

Verdicts: **valid**, **partly**, **conflicts** (a deliberate decision), **artefact** (the snapshot or the harness).

Snapshot caveats found by the triage: the bot decrees its battles, so a `midgame_real` hero never saw the first-duel tips (finding 1 is
amplified by that, but a real save that skipped them - an old save - would see the same); the snapshot gives items without equipping them
(the "12 Healing Salves, none equipped" in finding 4). Harness caveat: from ~22:20 to ~22:40 the critic's runs loaded some of this night's
untested Part 2-8 drafts (they were stashed as soon as that was noticed; no run logged a script or parse error).

| # | Problem | Verdict | Evidence / reason | Tonight |
|---|---|---|---|---|
| 1 | First-time tips fire again at L13 and block the turn | **valid** (amplified by the snapshot) | `TutorialLayer` showed every unseen `tut_*` step whatever the hero's level | **Fix 1** |
| 2 | HP tiny and inconsistent (16 / 11 / 17 / 15) | **partly / conflicts** | Each pool is a rule: zone HP carries, the Capital's Famine lowers it, bosses use the battle max | **Fix 6**: the HP bar says when the max differs and breaks it down (tooltip) |
| 3 | Bosses are walls at L13 | **partly** | The pilot played all three boss fights; the sim (`docs/design/sim/`) has these bosses in band for the expected deck. Balance only with sim evidence | No. Recommendation: a boss sweep with the story-bot snapshot deck |
| 4 | No healing across 13 nodes | **conflicts** (zone HP is the design) + snapshot | Items given unequipped by the snapshot | No. Recommendation (badge unequipped healing items) |
| 5 | The UI spoils twists ("posing as", "secretly Death") | **valid** | The sheets' names were shown as-is on plates and the "Boss:" line | **Fix 2** |
| 6 | Tracker says "Go to Crosspath" inside every zone | **valid** | The tracked quest was the town's Fragments line, so the zone pointed at its exit | **Fix 3** (+ Part 2's second goal) |
| 7 | Vendors don't open on E | **valid** (fixed after the triage) | The shot shows no "[E]" prompt: the hero stood outside the stall's reach and the bubble was a proximity bark (reach 1.8 m vs bark 3.2 m) | **Fix 7**: vendor reach 2.8 m; the critic's script now opens the stall |
| 8 | Boss intros long, flat placeholder icons | **partly** (stills are frozen with the dialogue) | | No. Recommendation: "Skip intro" after the first viewing |
| 9 | Maps fogged and name nothing | **valid** (the fog is the design) | The full map drew icons only | **Fix 4**: names under every revealed place |
| 10 | Arrival popups block input | **partly** | The Rift operator's intro is a dialogue (frozen) | No |
| 11 | Same 13-node lattice in every dungeon | **conflicts** (dungeon list import) | | No |
| 12 | Feats not back-filled for freed zones | **partly / artefact** (bot flags) | | No (inbox) |
| 13 | Stale "Needs 4 energy", nameplate clip | **valid** (warning) | The hover box's "why not" line was computed once on hover | **Fix 5** (+ toasts no longer cut each other short) |
| 14 | Deck Station hard to read | **partly** | Part 7 adds the curve / mix / synergy / suggest | Part 7 |
| 15 | Greybox / stand-in art | **valid, needs art** | | No (art) |

## The fixes

1. **The first-duel basics are skipped past them** (`TutorialLayer.BASIC_STEPS`, `past_basics`, `step_seen`): level 5+ or a zone freed
   counts the eleven first-duel steps as seen; the later topics (traps, Tools, the Refuse Pile, keywords, tokens, rules) still show once.
2. **Cover names** (`SpoilerFree.name`): "X (posing as Y)" shows Y, "X (secretly Y)" / "X (later named Y)" show X, on NPC plates
   (`NpcRegistry.Entry.plate_name`) and the dungeon's "Boss:" line. The sheets are unchanged.
3. **A zone tracks its own main line on arrival** (`Session.begin_zone_visit`): the tracker and the goal pointer lead to the zone's next
   step instead of the town errand's exit.
4. **The full map names places** (`FullMapScreen._draw_map`): each revealed point's name under its icon (vendors, the Hall of Records,
   roads, dungeons), skipping a name that would overlap one already written.
5. **The hover box's "why not" follows the game** (`BattleHud.refresh_preview_note` from `BattleScreen._refresh_ui`), and a new toast
   kills the older one's fade.

Checks: GUT root 286, core 1518 (+1 pending), ui 256, world 428 - all green; first-battles smoke OK (lowest 55 fps); Crosspath and Buffet
walk smokes OK; structure budget OK; memory round trip OK (6 trips, static +0.8 MB, video +1.6 MB). Test:
`tests/core/quests/test_midgame_rerun_fixes.gd`.

## After the fixes

- **Finding 2 (HP)**: the zone HP bar now says when the max differs from the level's ("Max 11 here (-5, hover)" in the Capital) and its
  tooltip lists the base, each rule that changes it and the total (`DungeonRun.hp_breakdown`; shot `docs/review/overnight_oct31/p1_capital_hp_caption.png`).
- **Finding 3 (boss walls) - sim evidence, no change**: the balance sim with the expected decks (8 games per Path, `docs/design/sim/boss_check_oct31_ttk.md`
  and `_rot.md`): the Doppelganger at L14 wins 47 % overall (Beefcake 50 %, band 40-60 %); Compostella at L17 66 % overall (Beefcake 38 %,
  Necrocrat 100 %; 8 games each is noisy). The bosses are in or near band for the expected deck; the critic's 0-damage fights were the
  driver's simple pilot. A 25-game second-seed run would be the next step if the designer wants Compostella looked at.
