# Late-game critic report - rebuilt test pack (RC3 + Nov 11 fixes), Nov 11

Saved by the lead from the critic agent's message (its file write was refused). Play scripts: `docs/review/play_scripts/critic_late_n11_01.txt`
to `_34.txt`; screenshots: `_screenshots/exported/l1_*` to `l34_*`. The critic edited no game file.

## 1. Summary
The end of The Wayward Path looks rich: the castle, Lab and Gallery node maps are lovely painted pieces, Primm's portraits and stills are the
best art in the game, and his lines are sharp ("This will not hurt. It will, however, be Standard."). The stretch plays worse than it looks:
- Walking the Capital costs HP: Tidy-Bots take 2 HP off you every few seconds.
- The Primm fight has rules text that does not match the board.
- Phases 2 and 3 ask far more than the HP you carry in.
- The battle screen falls apart past about 9 cards in hand: two overlapping rows, banners over prompts, hints that never go away.

Phase 1 beaten for real on the second try; Phase 2 lost twice, Phase 3 once, so **the ending, epilogue and credits were not seen**. The postgame
reached (Capital after the war, the cracked mirror, the Shattered Gallery map, the Lab's first fight) is reachable and well labelled, but the
world barely changes after Primm falls.

**How:** 34 runs of 170 s or less, one at a time; about 49 minutes of game time (about 12 of them loading).
- l1-l7: `c13cap`, walked the Capital to the castle door on foot with "Point me to..." (`l7_02_e`).
- l8-l14: `c13castle` + `dev travel dungeon D-PC`; Courtyard of Perfect Hedges with own clicks and `pilot` (won in 6 turns); once with autowin.
- l15-l28: `dev travel dungeon D-PC -2`; read Primm's intro in full; real fights from `dev primm 1/2/3`, autowin off, own card plays, `pilot`
  for attacks and blocks; `dev level 24` after the second loss.
- l29-l34: `c13end` and `c13post`; the cracked mirror, the Shattered Gallery; `dev travel dungeon D-LAB` and its first fight.

## 2. Scores (previous build: clarity 5, fun 4, polish 5)
- **Clarity 5/10 (no change).** Better: "Point me to..." and the dotted route (`l3_01_goalpicked`, `l6_05_map`); the pre-fight rules box and
  defeat recap (`l18_01`, `l24_end`). Worse: "Every unit is a 3/3" while own units come down 7/4 (`l19_07_t3`, `l22_t3_a`); "Turn 1" for both
  his first turn and yours; Setting Up says "2 turns left" on both of your first two turns; mirror phase ownership unreadable (`l26_t4`).
- **Fun 4/10 (no change).** Phase 1 against the Militia swarm is a real puzzle ("Phase 1 Broken" with 16 HP left; `l25_end`). Phase 2 is a 52-HP
  copy of your deck drawing two extra a turn, on carried HP; lost twice, once at level 24 with full HP. A loss restarts the castle. Tidy-Bots
  drain about 1 HP a second while walking (23 to 15 in about 10 s; `l1_04_walk`, `l1_07_north`).
- **Polish 5/10 (no change).** Strong: maps, Primm's art, the toppled statue (`l30_01`). Weak: battle screen at large hands (`l21_04_after`,
  `l19_07_t3`); dialogue box over the boss info panel (`l15_02`); stale hints; turn panel clipped at the right edge; the cracked mirror is a
  plain white rectangle (`l31_01_mirror`); white stair geometry with grey bands (`l4_09`).

**Broken:** turn panel "Turn 1 / Enemy's turn" while Primm attacks (attacks start turn 3) (`l21_04_after`); ENEMY TURN banner covers "Choose 1
card to toss"; "YOUR TURN / Turn 1" banner during the enemy's turn (`l12_04_combat`); "Needs 2 energy; you have 0" stays through later turns and
over VICTORY (`l12_05_after`, `l23_02_end`).

**Unfinished / AI-looking:** the mirror quad; the flat toppled statue cut-out; a white low-poly lamp globe (`l4_09`); the castle gate still shows
the hooded woman held by two guards while the text says she stands hood up (`l7_05`); "The Freed Leaders" scene shows only a name tag.

## 3. The Primm fight
- Phase 1 "Standardization" (56 HP): try 1 lost on turn 5 (Primm at 25; Militia stack + Village Militia about 12 a turn from turn 3); try 2 won
  around turn 13 with 16/31 HP.
- Phase 2 "Reflection" (52 HP), from `dev primm 2`: the checkpoint drops the four leader boons (3 rule icons instead of 9, 23 HP instead of 31)
  (`l26_02_rules`). Try 1 died turn 6 (Primm 36); try 2 at level 24 / 25 HP died turn 7 (Primm 24).
- Phase 3 "Unraveling" (50 HP): level 24, 25 HP, died turn 6 (Primm 40) (`l28_t5`).
- Militia: one stacked card with a clear "X3" badge - reads well.
- Setting Up: clear in the pre-fight box; on the board the label runs into the next rule icon (`l18_03`); "2 turns left" on Turn 1 and 2, "1 turn
  left" on Turn 3 (when attacks start); panel text clipped at the right edge.
- Phases are distinct, each with an intro card and post-phase scene. Phase 2 uses the same card art on both sides and interleaved rows; his
  Phase 2 quote repeats the polished-floor line.

## 4. The ending and the credits
- Not seen. `c13end` and `c13post` both start in the Capital.
- The Model Room intro is the best writing in the stretch.
- The Freed Leaders' speeches each end in a game-term bracket inside the quote ("(Grandmaster Flex's Heart: Beefcake units get +1 power, and
  you gain 2 max HP)").
- Postgame announcement is clear: "Cracks in the Glass" complete toast, "Under the Forest" points to Rift Station (`l29_02_quests`), "Point me
  to..." lists the Shattered Gallery (`l29_06_pointme`).
- The Capital barely reacts: Spotless's golem gate, Tidy-Bots, corruption crystals, "Primm's Castle (Dungeon entrance)" and every "!" remain.
  New: "Welcome to Pathordia.", the toppled statue, "At the end of Grave Row, the city is gathering at dusk." (not followed). Bloom overexposed.
- Gallery map gorgeous; Lab intro a single line; its first fight plays normally.

## 5. Top 10
1. HP wall in Phases 2 and 3; a loss restarts the castle (major). Fix: heal between phases or checkpoint at the last phase.
2. "Every unit is a 3/3" contradicts 7/4 own units (major). Fix: reword or apply to both.
3. 10+ card hand wraps into overlapping rows; ENEMY TURN banner hides the Toss prompt (major).
4. Turn label and Setting Up countdown wrong or out of sync (major).
5. Tidy-Bots drain about 1 HP a second on Capital walks (major; reached the castle at 17/23).
6. Stale floating energy / infrastructure hints, even over VICTORY (minor).
7. Dialogue box drawn over the boss info panel (minor; `l15_02`).
8. Mirror phase: whose units are whose (minor).
9. The cracked mirror is a white placeholder quad (minor).
10. The Capital barely changes after Primm falls (minor).

## 6. Smaller notes
- No `SCRIPT ERROR` in 34 runs. 8 engine errors in Primm runs: `Condition "!is_inside_tree()" is true` in `get_viewport_rect` from
  `res://ui/widgets/hover_tip.gd:70` (`_show`), while clicking hand cards. RID/texture leaks at exit in every run.
- Castle door popup: the dump cuts at "...nothing heals exce..."; on screen it is complete.
- "Before the fight: Primm" box has 11 rule lines; the four boons could share one.
- Max HP: Capital 23, Primm 31 (boons), Lab 18 (rule), Shattered Gallery 63 (unexplained).
- Castle guard and Primm field "Resistance Scout" units.
- HUD goal stays "Free the Four Zones" while only "Storm Primm's castle" is left (`l1_02_capital`).
- The endgame snapshot hero has 25 unopened packs.
- Right-click preview opens top left over the rule icons the first-fight tip points at (`l11_03_preview`).
- Final-dungeon room: +30 gold, +45 XP at level 20 (`l14_02`).
- Primm's Phase 1 defeat line "Why must some of them be five?" vs 7/4 on screen.
- `pilot` often stalled in these fights and never played Infrastructure.

## 7. What worked
The painted dungeon maps; Primm's writing and art; "Point me to..." with the dotted route and level hints; the defeat recap and pre-fight rules
box; the "X3" Militia stack and the "Phase 1 Broken" screen.
