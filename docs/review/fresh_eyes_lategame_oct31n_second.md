# Fresh eyes: the late game and ending (second session, Oct 31 / Nov 1)

Independent critic pass on **The Wayward Path**, played only through `tools/play.sh` from `C:\Dev\wp_critic`, starting from the `lategame_real` snapshot (level 20, Beefcake Path, all four zones freed, 1200 gold). The screenshots I cite are in `fresh_eyes_lategame_oct31n_second/`. Each is named `<run>_<shot>.png`.

## Summary

The final act **looks** like the best part of the game: the castle node map, the cutscene stills (the peacock herald, Primm at his model of the kingdom) and the castle battle board are lovely and hang together well. Under the art, the late game hits three problems. Primm phase 1 is a wall. The final fight's rules contradict what the board shows. And the dialogue and battle-flow input is fiddly enough that I got stuck three times. The Capital itself feels unfinished: a brick-box hideout, a grey half-revealed plaza, a "Broken services: 0 of 4" tracker that ignores the four zones I had freed, and an HP drain that fires while you walk. I reached Primm and played phase 1 twice for real with the built-in pilot (lost both: 7 and 9 turns, Primm's 44 HP barely scratched once). I then used `dev autowin on` to see phases 2-3 and the ending, all the way to the credits and the post-credits Capital. The ending's **writing** is the strongest of the late game. Its **presentation** is mostly placeholder: icon glyphs on a gradient for every Primm phase scene and the epilogue, then a screen literally titled "PLACEHOLDER CREDITS" ("Design and direction: you", "see CREDITS.md"). After that the game drops you back into a Capital whose HUD still says "Broken services: 0 of 4" and where a roamer attacks you.

## How I played (runs, places, time)

About 50 minutes of wall clock (03:48-04:38), 17 runs (`c9a` to `c9q`):

- `c9a`: Crosspath from the snapshot, quest log (J), map (M), then `dev travel capital`. That put me in the Crease (hideout), where I walked and tried to talk.
- `c9b`: out of the Crease into the Ruined Outpost / Gate Road, the Capital map, `dev encounters lieutenant`, then started Vivienne Quota.
- `c9c`, `c9d`: Vivienne Quota (lieutenant) twice. I played turns myself by clicking and dragging, then used `pilot`.
- `c9e`, `c9f`: entered Primm's Castle, read the gate cutscene, rules (R), first-node pre-fight panel.
- `c9g`: Courtyard of Perfect Hedges (Hedge Trimmer Guard). I played turn 1 myself and the pilot finished it: won in 16 turns, no HP lost.
- `c9h`: tried to walk the castle nodes with `dev autowin on`. My script desynced with the result popups, so only node 1 cleared.
- `c9i`: `dev travel dungeon D-PC -2` (8 nodes skipped) and the Primm intro.
- `c9j`, `c9k`, `c9l`: the run stalled in the Freed Leaders boon dialogue and the pre-fight panel (see Bugs).
- `c9m`: Primm phase 1 with the pilot. **Defeat on turn 9** (Primm 44 -> 27).
- `c9n`: Primm phase 1 with the pilot again. **Defeat on turn 7** (Primm untouched at 44, "9 cards still in hand").
- `c9o`, `c9p`, `c9q`: Primm with `dev autowin on`. All three phases auto-won. I read the between-phase scenes, the epilogue, the credits and the post-credits Capital.

**Skipped:** the castle's middle nodes (Grand Foyer to Royal Stair, skipped by the `-2` jump; I saw only their hover cards), any Capital side dungeon (S-CAP / S-PASTE), a roaming Capital enemy, the Deck Station, shops and packs. That was a time-budget choice in favour of Primm and the ending.

## Scores (1-10, against Slay the Spire / Inscryption / Monster Train / Sea of Stars / Octopath / TCG Pocket)

| Area | Score | One line |
|---|---|---|
| Clarity | 4 | Primm's "every unit is a 3/3" while my units show 7/1 and 6/4. The services tracker says 0 of 4 after freeing four zones. Tips point at things a card preview covers. |
| Pacing and friction | 4 | Trash fight 16 turns. Dialogue boxes accept different keys. The pre-fight panel needs a mouse click. The castle `-2` jump skips 8 nodes the player would have to walk. |
| Combat depth and feel (late game) | 5 | Rules stack (Perfect Order, Mirrors, 4 boons, Royal Guard, Out of Alignment, Primm's rule) is interesting on paper. In play, phase 1 is a stall-then-lose. |
| Deck-building satisfaction | n/a (5) | Not tested. The deck I saw holds 6+ Powerhouse in a 10-card hand repeatedly (flood). |
| Reward rhythm | 5 | +35 gold / +30 XP for a castle trash node at level 20 with 1200 gold banked feels like nothing. Boss boons are good. |
| Exploration and world | 4 | The Capital I saw is grey plaster, dead trees and a brick box. The map reveals nearly nothing. The castle node map is excellent. |
| Story and humour | 7 | The ending dialogue ("Start smaller. Say sorry to one person.") and the epilogue's decree are the best writing I saw. Plume and Primm's intro land. Primm's intro is short and the still never changes. |
| Visual cohesion and readability | 4 | Gate cutscene, node map, castle board and the one painted ending still are top-tier. The Primm phase scenes and epilogue are placeholder icons on a gradient. The credits say "PLACEHOLDER CREDITS". The Crease is greybox and the lieutenant board has no backdrop. |
| UI/UX consistency | 4 | "E / Click to close" vs "Click / Space to continue". Stale "Needs 3 energy" toast stays through VICTORY. Rules panel does not close on Esc. Box overlaps the node info card. |
| Audio | n/a | Cannot judge from screenshots/logs. |
| Performance | 7 | Zone/dungeon loads 4-11 s (`dev travel capital` 11 s). No stutter visible in log timestamps. Snapshot loads ~7-9 s. |
| Bugs | 4 | No SCRIPT ERRORs in any stdout.log. Several logic/presentation bugs (below). |
| **Overall (late game + ending)** | **4.6** | |

## Findings per area

### 1. Getting to the Capital
- The HUD tracker is clear: "Storm Primm's castle in the Capital" and "Go to the Capital" (`c9a_01_town.png`). The quest log adds "Where to go: The castle on its hill, up the palace avenue (The Capital)".
- **But the town map's goal ring sits on Gatekeeper Brannoch, at the top of Crosspath.** It is labelled "Goal: Free the Four Zones", a quest that reads 4/5 done (`c9a_03_map.png`). Nothing on the map says "Undercroft" or "to the Capital". The final act's first step is told in text but not shown on the map.
- The snapshot only revealed spots the bot stood on, so most of the town map is black. That is a test artefact, but a returning player after a break would see much the same.

### 2. The Capital
- `dev travel capital` drops you in **the Crease**, the hideout. You get an unskippable-feeling Rift unlock card from Rip Tearson, whose portrait is fine (`c9a_04_capital.png`). The room is a flat brick box with beds, a stall and a portal (`c9a_07_walk.png`). It reads as a greybox interior, far below the town and castle art.
- **"Broken services: 0 of 4"** shows in the HUD with all four Path zones freed and their dungeons beaten (`c9a_04_capital.png`). The quest says "Primm's Capital runs on four stolen services. Free each Path zone to break one". So either the tracker is broken or it means something else that is never explained. Either way the player's late-game progress looks erased.
- **Zone HP:** "HP 18/18, Zone HP: no healing after battles". Then while just walking the Gate Road: "Ow! The Capital has hurt you again. (-HP)" took me to 16/18. There was no visible cause (`c9b_04_walk.png` -> map at 16/18). An 18-HP pool at level 20 that drains while walking is a harsh, unexplained rule. The popup does not say why or how to avoid it.
- The Gate Road is grey plaster walls, dead trees and a ruined tower (`c9b_04_walk.png`). The palace behind is a washed-out flat backdrop. The map is almost entirely black, with Wren, healer, vendor and Rift Express bunched in a corner (`c9b_06_map.png`).
- **Lieutenant (Vivienne Quota, 26 HP):** the battle board has **no backdrop**, just a flat navy void (`c9b_07_battle_start.png`, `c9d_05_after_pilot.png`). Castle fights have full art. I clicked and dragged cards: clicks on a 10-card fanned hand often hit the neighbour card. Fair, the hand is crowded, but cards overlap so much that only ~70 px of each is clickable. In 4 turns neither I nor the pilot got an infrastructure down. **The pilot reported "stuck on turn 4" with 0 energy and a hand full of Powerhouses** (`c9d_05_after_pilot.png`: "Needs 1 energy; you have 0"). I could not tell from the screen why the Powerhouses were not playable. If infrastructure was legal, the pilot should have played it. If it was not, nothing on screen says why. This needs a look.

### 3. Primm's Castle
- **The node map is the highlight of the late game** (`c9e_05_node.png`). It is a painted castle with wings, a red carpet to the Model Room, lightning, locked side rooms named for each Path, and checkmarks for cleared nodes. Easily Slay-the-Spire-map-plus.
- Rules (R): "Perfect Order: Units can't have more than 2 keywords" and "Mirrors: The first card each player plays each game is copied for the opponent". Both are clear. **Esc does not close the rules panel** (it stays over the map in `c9e_05_node.png`).
- The gate cutscene is strong (`c9f_03_intro.png`): guards, the herald, Elowen arrested. At my 0.8-1 s pace, the typewriter often was not finished before the next tap ("Former junior Path-ologi..."). The same first tap both completes the line and risks skipping the next.
- **The first trash fight took 16 turns** (Hedge Trimmer Guard, 24 HP; `c9g_07_end.png`). I banked 10 Irons, unused. The fight never threatened me (18/18 at the end). It was a slog, not a challenge. Reward: +35 gold, +30 XP.
- The tutorial tip "Rules of this fight" draws an arrow to the rules icons. **The hover card preview for the card I had just clicked covers exactly those icons** (`c9g_02_played.png`). The stale "Needs 3 energy..." toast stays under the tip, and **stays on screen through the VICTORY banner** (dump at 148 s).
- Pre-boss info card: when you click the Model Room, the speaker box opens **on top of** the node info panel, cutting it to "...ti-phase final boss)... Click again to go" (`c9i_07_intro.png`).
- **Text vs art:** the narration says "A man in a pressed grey coat and a thin gold circlet". The portrait and still show Primm in **white and gold robes** (`c9i_07_intro.png`, `c9i_10_intro.png`).

### 4. Primm
- Intro (`c9i_10_intro.png`): great still, good opening line. It is short (about 10 lines) and the same still holds for every line. The exchange ("Everyone I met was afraid of you." / "Please remain still. I know how to put this right.") is OK but undercooked for the final villain's first face-to-face.
- **The Freed Leaders** scene (`c9j_p14_intro.png`) is a smart payoff. Each freed zone leader grants a boon ("The heart and the mind, son. You brought both. We are with you." -> +1 Beefcake power, +2 max HP). It plays as text over the node map with no portraits of those leaders. A big emotional beat is delivered as a stat list.
- **The pre-fight panel lists 8 rules at once:** Perfect Order, Mirrors, 4 boons, Royal Guard ("2 Militia, 3/3, like every unit under Standardization") and Out of Alignment. Then the fight adds a 9th, Primm's rule: "Every unit, yours and his, is a 3/3. You may play at most two non-infrastructure cards a turn". That is a wall to digest before the last fight.
- **The rule contradicts the board.** Under "every unit is a 3/3", my units show **7/1, 6/4, 7/1** with "-3" debuff badges (`c9m_b03.png`). Either the rule is only half applied or the numbers are not; the player cannot tell which. This is the single worst clarity problem I found.
- **Difficulty:** two real attempts with the pilot (a simple player, so treat this as a floor). Both lost: turn 9 with Primm at 27/44 (`c9m_b03.png`), then turn 7 with Primm untouched at 44 (`c9n_q02_trans.png`). The defeat card is helpful: "Militia dealt 21 of the 27 damage you took (7 hits). Tip: You ended with 9 cards still in hand". That is the good kind of loss screen. But with a 2-card-per-turn cap and an 18-26 HP pool against 44 HP phase 1 (of three), the fight reads as a gear/HP check. It does not feel like a puzzle.
- The battle backdrop for Primm is a **sunny harbour town plaza**, not the domed Model Room the cutscene just showed (`c9m_b02.png`). It is pretty, but it breaks the place.
- Phases 2-3: see the ending section. Reached only with `dev autowin on`.

### 5. The ending
I reached it with `dev autowin on` (runs `c9p`, `c9q`), so phases 2 and 3 were auto-won and I saw only their between-phase scenes, not their boards.

- **Every between-phase scene is placeholder vector icons on a flat purple gradient.** Primm is a gold crowned-face glyph, then a pale-blue bust on a plinth, then a lilac one. You are a wizard-hat glyph (`c9p_s02.png`, `c9p_s10.png`, `c9p_s24.png`). After the painted gate scene and the Model Room still, the climax drops to the look of a debug screen. This is the most damaging visual gap in the game: the last ten minutes look the cheapest.
- **The writing in those scenes is the best in the late game:**
  - Primm: "Everything you can do, I can do. I have had ten years of practice with it. Let us see how you like fighting yourself." (`c9p_s06.png`). That sets up a mirror phase.
  - You: "You copied my cards. What I do with them is mine. A name is a blank page until you sign it. I'm not your subject." (`c9p_s10.png`).
  - Primm, cracking: "Everything is coming apart. Why is everything coming apart? I only wanted it to be nice!" (`c9p_s16.png`).
  - "I did it for them. I did it for the people. You do see that?" (`c9p_s24.png`), answered by "I'm not going to correct you. That was your way. Start smaller. Say sorry to one person." (`c9p_s32.png`).

  A villain undone by kindness, not killed, fits the tone, and the Feat "Sorry About the Hats" is a good wink. Since phases 2-3 were auto-won, I cannot say whether the mirror phase plays as well as it reads.
- **The epilogue narration** ("The Model Falls", "The Rifts Close", "The Wrinkles", "The New Decree") is warm and specific: "In the Reek, the Sick Patch is a flower bed"; "DIFFERENT PATHS MAY MIX AGAIN... MAY crossed out for SHOULD, then WILL, IF THEY FEEL LIKE IT. Four hands have left their marks." It is again shown over icon placeholders: a brick glyph, a crown, bunting (`c9p_s42.png`).
- **One painted ending still exists.** The four freed leaders join hands in a cheering crowd, with "Above you, four banners share one crowded pole" (`c9p_s50.png`). It is beautiful, and it shows what the other scenes should be.
- **UI collisions during the ending:**
  - A "Quest complete: Free the Four Zones" card opens as a **tall empty wooden panel** that covers the middle of "The Model Falls" narration (`c9p_s37.png`). The four-zones quest only completes at the very end.
  - Two text boxes ("The Wrinkles..." with "Click / Space to continue" and "...a hooded traveler smile... There is always another path." with "E / Click to close") were open **at the same time** (c9p final dump).
- **Credits: "PLACEHOLDER CREDITS. Design and direction: you. Engine: Godot 4. Art: Kenney, KayKit, game-icons.net and friends (see CREDITS.md). Music: synthesized in code."** (`c9q_t39.png`). These are literal developer placeholders on the most-seen screen of a finished playthrough. A red "HEIR ALIVE. FILE COMPLETE." stamp shows faintly behind the decree text (`c9q_t45.png`). The closing lines ("For everyone who waited to be heard... The Paths will be back, in some other order. Thank you for playing.") are lovely and deserve a real credits screen.
- **Post-credits:** you are dropped back into the Capital's **Palace Approach** with Wren at the fountain: "writing the title of the first honest page: THE TRUE RECORD, VOLUME ONE." (`c9q_t48.png`). Nice beat. But:
  - The HUD still says **"Broken services: 0 of 4"** and **"Zone HP: no healing after battles"**.
  - A roaming enemy immediately fought me (auto-won: "Won! +70 gold, +50 XP. HP stays as it is.", `c9q_t54.png`).
  - The plaza is heavily over-bloomed and washed out.

  The world does not acknowledge that you just won.

### 6. Bugs and input problems seen
- "Broken services: 0 of 4" with four zones freed (`c9a_04_capital.png`).
- Lieutenant board has no backdrop (`c9b_07_battle_start.png`).
- Pilot "stuck on turn 4" with 0 energy and Powerhouses in hand against the lieutenant (`c9d_05_after_pilot.png`).
- Stale "Needs N energy" toast persists across turns and through VICTORY (`c9g_02_played.png`, c9g dump).
- Tip arrow target hidden under the card preview (`c9g_02_played.png`).
- Rules panel ignores Esc on the castle map (`c9e_05_node.png`).
- Speaker box overlaps the boss node info card (`c9i_07_intro.png`).
- Narration "grey coat" vs white/gold art (`c9i_07_intro.png`).
- Input is inconsistent: the Primm cutscene says "Click / Space to continue", the Freed Leaders box says "E / Click to continue", and **Space did not advance it**. A run stalled there for 50 s (c9j). The pre-fight "Continue" and the Victory "Continue" did not respond to E or Space in my runs (c9k, c9o). The brief's controls promise "E / Space / click ... advance dialogue, confirm popups".
- The `-2` dev jump reported "8 cleared on the way". Not a player bug, but it means I can't vouch for the middle castle nodes.
- No `SCRIPT ERROR` in any run's stdout.log.

## Top 15 problems (ranked by impact on late-game enjoyment and retention)

1. **The ending looks like placeholder.** Every Primm between-phase scene and most of the epilogue are flat vector glyphs (crowned face, bust on a plinth, wizard hat, brick, bunting) on a purple gradient (`c9p_s02.png`, `c9p_s16.png`, `c9p_s42.png`). It comes right after the game's best painted art. The last ten minutes are what a player remembers and screenshots. *Fix:* use the Primm portrait and still (three expression or damage states) and the hero's portrait for the phase scenes. Paint 3-4 epilogue stills in the style of the leaders' handshake still (`c9p_s50.png`), and reuse zone stills where possible.
2. **"PLACEHOLDER CREDITS. Design and direction: you ... (see CREDITS.md)"** (`c9q_t39.png`). It reads as unfinished to every player who finishes. *Fix:* write a real credits roll (names, asset packs with proper attribution, tools, thanks) and keep the closing lines. Remove the faint "HEIR ALIVE. FILE COMPLETE." stamp bleeding behind the decree (`c9q_t45.png`), or make it a deliberate beat.
3. **Primm phase 1 is a wall.** Two pilot runs lost in 7-9 turns, Primm at 44 HP with two more phases to go (`c9n_q02_trans.png`, `c9m_b03.png`). The final boss is where players quit for good. *Fix:* lower phase 1 to ~30 HP, or show the four boons' +HP clearly in the run HP bar. Exempt cheap cards from the 2-card cap, and playtest until the simple pilot wins phase 1 at least 1 in 3. Offer a retry-from-phase checkpoint.
4. **Primm's rule says every unit is a 3/3, yet my units show 7/1 and 6/4** (`c9m_b03.png`). The player cannot reason about the final fight. *Fix:* show Standardization literally (stamp each unit 3/3 with the original greyed out), or reword the rule to what it actually does.
5. **"Broken services: 0 of 4" after freeing all four zones, and still after beating Primm** (`c9a_04_capital.png`, `c9q_t54.png`). This erases the player's progress at the start of the final act and contradicts the ending. *Fix:* tick a service per freed zone (and name it), retire the tracker after the ending, and lift the Zone HP rule and Capital roamers once Primm falls.
6. **Dialogue and confirm input is inconsistent.** Space works in some boxes and not others, Continue buttons ignore E/Space, and two text boxes can be open at once. I stalled three times (c9j, c9k, c9l). *Fix:* one dialogue and popup input rule everywhere (E, Space, Enter and click all advance and confirm; the first press completes the typewriter). Queue boxes so only one shows at a time.
7. **The Capital looks unfinished:** the brick-box Crease and the grey Gate Road (`c9a_07_walk.png`, `c9b_04_walk.png`), and the over-bloomed Palace Approach after the ending (`c9q_t54.png`). *Fix:* dress the Crease (lanterns, maps, resistance clutter, warm light), give the Gate Road a landmark and colour accent, and tone down the post-ending bloom.
8. **Walking damage with no explanation** ("Ow! The Capital has hurt you again. (-HP)", 18 -> 16 just walking) plus no healing after battles. *Fix:* name the source, show it as a HUD rule icon, telegraph each tick, and point to the healer on the first one.
9. **Castle trash fights drag:** 16 turns for a 24-HP guard that never threatened me, for +35 gold and +30 XP (`c9g_07_end.png`). *Fix:* cut castle trash HP ~30 % or add turn pressure. Scale rewards to level 20.
10. **The Freed Leaders payoff is a stat list over the map** (`c9j_p14_intro.png`), followed by an 8-rule pre-fight wall and a 9th rule in the fight. *Fix:* show the leaders' portraits with one line each, then a single boon card. Group the rules into "Castle / Your boons / Primm's tricks" with green and red colour coding.
11. **Ending UI collisions:** the "Quest complete: Free the Four Zones" card shows as a tall **empty** wooden panel over the "Model Falls" narration (`c9p_s37.png`). The speaker box covers the boss node info card (`c9i_07_intro.png`). *Fix:* hold quest toasts until the cutscene ends and size the card to its content. Close info cards when dialogue opens.
12. **The lieutenant fight has a blank navy board** (`c9b_07_battle_start.png`), and the pilot stuck at 0 energy with Powerhouses in hand (`c9d_05_after_pilot.png`). *Fix:* give `capital:lieutenant` a backdrop and investigate why infrastructure was not playable.
13. **Place mismatches:** Primm's battle backdrop is a sunny harbour plaza, not the Model Room (`c9m_b02.png`). The narration says "pressed grey coat" over white and gold art (`c9i_07_intro.png`). *Fix:* a Model Room board, and one rewritten line.
14. **Stale toasts and sticky panels:** "Needs 3 energy" stays through VICTORY, the rules panel ignores Esc, and the tip arrow points under a card preview (`c9g_02_played.png`). *Fix:* clear toasts on phase change, make Esc close panels, and hide previews while a pointer tip is up.
15. **The final act's start is not on the map.** The town map's goal ring is on Gatekeeper Brannoch, labelled "Goal: Free the Four Zones" (`c9a_03_map.png`), and nothing marks the Undercroft or the road to the Capital. *Fix:* point the goal marker at the Undercroft entrance once four zones are freed, and add "The Capital" to "Where to?".

(Also noted, below the cut: crowded 10-card hands with 5-6 Powerhouses and ~70 px of clickable card each; Primm's intro uses one still for every line; the gate cutscene's typewriter is easy to skip past.)
