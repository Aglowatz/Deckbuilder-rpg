# Fresh eyes: the late game and ending of The Wayward Path (v0.5.1) - Nov 1 2026

Critic session 13 (late game). Played blind from the `lategame_real` snapshot through the scripted driver, 17 runs,
about 60 minutes of wall clock (17:01-18:00). Screenshots cited below are in `fresh_eyes_lategame_nov1/`, prefixed by run name.

## Summary

The final act looks like a million dollars and plays like a build that nobody has sat down and finished with a keyboard in hand.
Primm's Castle map, the Model Room still, the Capital's painted gatehouse and the three-phase boss concept (Standardization ->
Reflection -> Unraveling, each with a real rule change) are the strongest things I have seen in this game, and the Primm writing
("seventeen people, whom I thank daily, in writing"; "Why must anything be five?") is genuinely funny and sad. But the road to the
finale is paved with friction: the next step after freeing the four zones is a quest line that says "Go to the Capital" while the
map's "Where to?" list still says "Goal: Free the Four Zones" and has no Capital entry; the Capital arrival dumps you into an unlit
brick box; a castle fight of 24 HP enemies against my level-20 deck hung on an all-infrastructure hand where the built-in pilot
"stuck on turn 4"; every one of six Primm attempts stalled at a popup that does not answer E or Space (the Victory panel, the
Opening Hand panel, the "Click again to go" node), so the credits took a seventh run; the between-phase and ending dialogue is
delivered as two flat gold icons on a brown gradient instead of the gorgeous stills the intro used; the climax's prose is covered
by a blank "Quest complete" panel; and the credits say PLACEHOLDER. Fix the input/flow bugs, the ending's staging and the Capital
transition and this is a 7; today it is a 5.

## How I played (runs, places, time)

| Run | Script | What happened |
|---|---|---|
| c13lat01 | 01_town | Snapshot in Crosspath; quest log, map, character, deck, packs. 80 s incl. 21 s load. |
| c13lat02 | 02_wayon | Map "Where to?" and fast travel lists, opened a Gilded pack, walked north. Pause menu ate the back half (my script). |
| c13lat03 | 03_capital | `dev travel capital`; arrival dialogue, map, "Where to?", quest log, walked, talked. |
| c13lat04 | 04_lieutenant | `dev encounter Quota` (Vivienne Quota, Minister of Efficiency); played turn 1 by hand, pilot the rest, won in 32 decisions. |
| c13lat05 | 05_castle | `dev travel dungeon D-PC`; read the gate scene, node map, Rules (R). |
| c13lat06/07 | 06/07_courtyard | Courtyard of Perfect Hedges: played 4 turns by hand (drags, Space, battle log), pilot stuck on turn 4 twice. |
| c13lat08 | 08_primm | `dev travel dungeon D-PC -2`; map next to the boss. |
| c13lat09-13 | 09-13 | Five attempts at the Model Room: read the whole Primm intro (12 lines), phase 1 by pilot + `dev win`, phase 2 pilot + `dev win`, stalled on the phase 2 Victory panel (E/Space ignored). |
| c13lat14 | 14_ending3 | Button-probe loop: phase 1 `dev win`, phase 2 played 9 turns by pilot (Primm 52 -> 47), then `dev win`; phase 3 opening hand reached; stalled on Opening Hand (E/Space ignored). |
| c13lat15 | 15_ending4 | Same loop; phase 2 pilot 12 turns then `dev win`; phase 3 dialogue read; stalled again on the phase 3 Opening Hand. Also reached The Old Service Tunnels map (run 14). |
| c13lat16 | 16_ending5 | Explicit clicks on Keep Hand (700,438) and Continue (800,518); phase 2 pilot "stuck on turn 2" (0 energy); reached the phase 3 opening hand. |
| c13lat17 | 17_ending6 | Same with Keep Hand probes in the ending loop; all three phases `dev win`; reward panel, Primm's last words, The Model Falls, the leaders' still, The New Decree, credits, The Paths Unbound. 17:52-17:56. |

I used `dev win` for Primm phases 1 and 3 and part of 2 (said so above). Skipped: the Undercroft walk from Crosspath (jumped with
`dev travel capital` after the map gave no route), a roaming Capital enemy (`dev encounters` lists none for the Capital; the only
"roam" entries are the three town roamers), the Capital side dungeons (S-CAP, S-PASTE), shops and the Deck Station in depth.

## Scores (1-10 against Slay the Spire, Inscryption, Monster Train, Sea of Stars, Octopath, TCG Pocket)

| Area | Score | One line |
|---|---|---|
| Clarity | 4 | Quest log says "Go to the Capital"; the map's "Where to?" still says "Goal: Free the Four Zones" and lists no Capital. Boss rules read well; popups do not say which key continues. |
| Pacing and friction | 4 | Four popups in a row before a boss (narration still, 12-line dialogue, "Click again to go", rules, opening hand); castle fights against 24 HP mooks last 4+ turns on infrastructure-flooded hands. |
| Combat depth and feel | 6 | Phase rules (all 3/3 and two-card cap; mirror deck; +1/+1 and self-bleed) are real design. But hands of 5 Powerhouses and a 1-energy ceiling turn 2 make the castle grind. |
| Deck-building satisfaction | 5 | 47-card deck with 19 infrastructure, 21 unopened packs, 0/3 items equipped at level 20: the snapshot's bot never built, and the game never nudged it to. Pack opening is a pretty reveal. |
| Reward rhythm | 5 | Boss node tells you "gold and XP, a choice of card" up front (good); the final reward panel (+100 gold, +120 XP, pick of three with a 240-gold reroll) is clear. But the lieutenant win screen is a plain Victory box with no recap, and 100 gold after the last boss is a shrug. |
| Exploration and world | 5 | The castle map is the best screen in the game. The Capital arrival is an empty brick box with a service-tent; "Services restored: 4 of 4" with nothing to do. |
| Story and humour | 7 | Primm is a great villain on the page: polite, exact, breaking ("a world where nothing surprises you is a world with nobody else in it"). The Freed Leaders' buffs and the four-handwriting decree are lovely payoffs. The staging undercuts it (glyphs, one still, placeholder credits). |
| Visual cohesion and readability | 6 | Stills and map: 9. Capital overworld: 3 (grey blocks, placeholder brick). Battle board at 1600x900: card text under 8 px. |
| UI/UX consistency | 3 | Three different "continue" conventions (E/Click, Click/Space, click-only buttons); Esc on a dialogue opened the pause menu; Victory and Opening Hand ignore the keyboard. |
| Audio | n/a | Cannot judge from screenshots; the logs show no audio errors. |
| Performance | 7 | Snapshot load 21 s, Capital travel 23 s, castle 12 s, boss phase swaps 3-4 s. No stutter visible in timestamps; the renderer logs "Pages in use exist at exit" leaks every run. |
| Bugs | 4 | Keyboard-dead popups; pilot "stuck on turn 4"; "Where to?" never updated for the final act; renderer leaks at exit. No SCRIPT ERROR in any stdout.log. |

## Findings per area

### 1. Getting to the Capital

- **Quest log (c13lat01_02_quests, c13lat01_01_town):** The HUD tracker is clear: four checks, then "Storm Primm's castle in the Capital" with
  sub-step "Go to the Capital". Good.
- **Map (c13lat01_03_map, c13lat02_01_whereto, c13lat02_02_fasttravel):** The map legend still says "Goal: Free the Four Zones". The
  "Where to?" list has the four zones plus Old Well and a tooltip; **no Capital, no Undercroft**. Fast travel lists the four zones.
  So the one screen a lost player opens contradicts the quest log. The town's pixel-art minimap and the dark-fog main map show only a
  couple of walked spots (snapshot artefact, but a real player who jumped by map travel would be in the same state).
- **Town (c13lat01_09_town_walk2):** Walking north past the fountain shows no sign, no NPC pointer, no "Undercroft" label. I gave up
  and used `dev travel capital` (a real player would need the quest marker; the tracker's arrow glyph is not a world marker).

### 2. The Capital

- **Arrival (c13lat03_01_capital_arrive, c13lat03_05_walk1, c13lat03_07_walk3):** The gate still with the hooded rescuer and the
  peacock minister is gorgeous and the text ("Guards in polished armour pour from the gatehouse. Not toward you. Toward her.") is a
  strong hook. Then the camera cuts to a brick room with two beds, a stall, a glowing hand-mirror portal and three stand-ins. The
  district name "The Crease" and "Nurse Hesper Dray" float with no context. The HUD shows a new red "Zone HP: no healing after
  battles" bar and "Services restored: 4 of 4", which means the Capital's own mechanic (restore broken services) is already done
  in this save and nothing in the room explains it.
- **Talking (c13lat03_09_talk2, c13lat03_10_talk3):** E in front of the nurse produced no dialogue box in three taps (a bubble label
  only). The one Capital NPC I could reach said nothing I could read.
- **Lieutenant (c13lat04_01_quota_intro1, c13lat04_03_quota_intro3, c13lat04_09_hover_enemy, c13lat04_13_pilot_end):** Vivienne Quota,
  Minister of Efficiency, 26 HP. The intro is a single still line; no rules panel appeared for her (icons row empty), so she plays
  like a town roamer with a title. Hovering the enemy leader gives no tooltip. Victory in 13 pilot decisions; the win screen is a
  plain "Victory!" box and then the board stays up with no reward recap.
- **Roaming enemies:** `dev encounters roam` lists only Pantry Hound / Lost Junior Clerk / Bin Raccoon (town). The Capital has no
  roaming encounter in the catalogue, so "fight a roaming Capital enemy" is not possible from this build.

### 3. Primm's Castle and the boss

- **Entrance (c13lat05_01_castle_enter, c13lat05_02_castle_d1, c13lat05_04_castle_d3, c13lat05_05_castle_d4):** Two stills, the
  rescuer is arrested in front of you, and the text is the best in the game ("as if she was always going to be here").
- **Map (c13lat05_07_castle_map, c13lat08_01_map_near_boss):** 24 named nodes on a painted isometric castle, four locked Path
  wings, a Resistance Safe Room, the Model Room as the skull node. This is the Slay-the-Spire moment the game needed. Nits: the
  node names truncate ("Gourmand Wing: the Doppelganger's La..."), and the hover card for the boss covers the right third.
- **Rules (c13lat05_08_castle_rules):** "Rules (R)" opens a dungeon rules panel; readable, short. Good.
- **Courtyard fight (c13lat06_03_fight_start, c13lat06_04_hand, c13lat07_05_drag1, c13lat07_10_space3, c13lat07_11_battlelog,
  c13lat07_12_fight_end):** A 24 HP Hedge Trimmer Guard. My opening hand had 6 Powerhouse (basic infrastructure), 1 Protein Shake
  and nothing else playable; turn 2 I had 1 energy and the tooltip "Needs 2 energy; you have 1 (each ready Infrastructure gives 1
  a turn)". Turn 4: enemy has an Elusive 1/2 scout, I still have 10 Powerhouses in hand. The pilot "stuck on turn 4". The battle
  log is a plain list with no damage numbers. Dragging a card to the table did nothing visible the first time (drop zone unclear);
  the card went down on the second drag. The "Rules of this fight" tip overlapping the rules icons on turn 2 is a nice touch.
- **Boss intro (c13lat09_01_boss_click, c13lat09_05_intro, c13lat11_03_intro, c13lat11_08_intro, c13lat09_11_intro):** Clicking the
  Model Room gives a boss card ("multi-phase final boss... a choice of card... Out of Alignment: at half health..."), then a
  narration still (Primm "moving a tiny cottage one centimetre to the left with a pair of tweezers"), then a painted scene of
  Primm at the model table and twelve lines of dialogue. The writing is excellent and the still is the best art in the game.
- **The Freed Leaders (c13lat11_13_after_esc, c13lat14_02_p1_board):** Before the fight the four freed bosses each give a buff
  ("'To grow, you have to let things go, child. Even him. Especially him.' (Compostella's Roots: Refusemancer units get +2
  defense, and you gain 2 max HP.)"). Great payoff, but it is shown over the map as a plain narration box, the four buffs appear as
  four more green rule icons with no legend, and it took me three runs to understand that "Click again to go" means click the
  node a second time.
- **Phase 1 Standardization (c13lat11_17_p1_board, c13lat11_18_p1_pilot, c13lat11_19_p1_won):** "Every unit, yours and his, is a 3/3.
  You may play at most two non-infrastructure cards a turn. (Two is the perfect number.)" Primm 56 HP vs my 31. The pilot won in 13
  turns (Primm at 1 HP in the shot). Primm goes first ("Enemy turn" on turn 1). The field shows 6/4 and 7/4 units on my side under
  an "all units are 3/3" rule: either the rule is not enforced after buffs or the display lies.
- **Phase 2 Reflection (c13lat11_22_phase2, c13lat11_27_p2_board, c13lat14_24_p3_board, c13lat14_25_p3_pilot, c13lat14_26_p3_won):**
  "His deck is a copy of yours, and he draws an extra card each turn. He can only imitate; he has never created anything." Primm 52
  HP, I start at 16 (phase 1 damage carries). Primm plays Powerhouse, Hamster Wheel Runners and Protein Farts back at me. A mirror
  match against my own infrastructure flood is the one time the deck's weakness is interesting. Pilot took him 52 -> 47 in 9 turns.
- **Phase 3 Unraveling (c13lat14_33_ending):** "His units get +1/+1 and he draws an extra card each turn, but he loses 1 HP at the
  start of each of his turns. The rules he wrote are breaking down." Primm 50, me 22.
- **Between phases (c13lat11_31_phase3, c13lat11_36_phase3, c13lat14_30_ending, c13lat14_36_ending):** Primm's lines ("Why must
  anything be five?", "If the rules are not perfect then I have been... then I have been...") are delivered on a brown gradient
  with two flat gold icons (a crowned face and a hat). After the painted intro this reads as a placeholder scene.

### 4. The ending: reached on the seventh attempt (c13lat17)

It took seven attempts (c13lat09 to c13lat17, about 30 minutes of game time) to get from the Model Room node to the credits, and
that is the headline finding of this session. The first six ended on the same walls:

- The phase-2 **Victory** panel ignores E and Space (c13lat11_49_ending: ten taps later it is still up; the dump shows the
  board's "Primm 52 HP" labels behind it).
- The phase-3 **Opening Hand** panel ignores E and Space (c13lat14_33_ending after twenty taps). Clicking Keep Hand at 700,438
  does work (c13lat16), so the modal is mouse-only.
- Each phase swap takes a different number of inputs (narration box, 6-12 dialogue lines on the "Click / Space" box, a Victory
  panel, a rules panel, an opening hand), so a script that worked for phase 1 is one step off for phase 2 and two for phase 3.
  That is an automation problem, but it mirrors a real one: there is no single "continue" action.
- Phase 2 by the pilot: Primm 52 -> 47 in 9 turns (c13lat14_25_p3_pilot), 52 -> 52 in 12 turns (c13lat15_13_p3_pilot: a 10-card
  hand of Powerhouses and a Kettlebell), "stuck on turn 2" with "Needs 2 energy; you have 0" (c13lat16_02_p3_pilot). The mirror
  deck makes Primm's side as clogged as mine, so neither side does anything for ten turns.

Between phases (c13lat11_31_phase3, c13lat14_30_ending, c13lat15_17_ending, c13lat15_19_ending): "Why... why will they not all be
three? It is a perfectly good number."; "Your cards. Your plays. Your own deck, in my hands. And you still beat me. How?"; "I
made... (he stops.) I made a list of things other people had already built, and I put my name on it."; "Everything is coming
apart. Why is everything coming apart? I only wanted it to be nice!" This is good villain writing: the admission is earned and
funny and sad in the same line. It deserves a face, not two gold glyphs.

**The ending itself (run c13lat17, with `dev win` on all three phases; the Continue and Keep Hand buttons clicked by coordinate):**

- **c13lat17_02_p3_won, c13lat17_03_after_p3:** "You defeated Primm - Phase 3: Unraveling in 2 turns", then a proper reward panel:
  +100 gold, +120 XP, a choice of card (Unstable Rift / Spotter / Late-ish Courier, Reroll 240 gold). Good. But the reward for the
  final boss of the game is the same panel as any fight, and 100 gold means nothing when the game is over.
- **c13lat17_06_ending, c13lat17_10_ending:** Primm, greyed out: "...It is over. The rules were not enough." and "It was the mirrors.
  Wasn't it. I wanted a world where nothing could surprise me. And I forgot that a world where nothing surprises you is a world
  with nobody else in it." That last line is the thesis of the game and it lands. Still two glyphs on a gradient.
- **c13lat17_14_ending:** "The Model Falls" narration ("You hear the scale model split... In the gallery a portrait slips off its
  hook... nobody picks it up") is covered by a **blank brown panel** titled "QUEST COMPLETE: Free the Four Zones" with a "Feat: Sorry
  About the Hats" toast over its title. The quest-complete panel has no body text and it sits on top of the climax's prose. Bug.
- **c13lat17_20_ending:** the one painted still of the ending: the four freed leaders (lion, dryad, ghost bureaucrat, chef) holding
  hands in a confetti square with the hero grinning at the edge. Best image in the game, and the narration box under it is cut
  mid-sentence ("In the Capital's square, you watch the leaders of") because I shot it mid-typewriter; fine.
- **c13lat17_26_ending:** "The New Decree" ("DIFFERENT PATHS MAY MIX AGAIN... MAY crossed out for SHOULD, then WILL, IF THEY FEEL
  LIKE IT. Four hands have left their marks") is a lovely closing joke, shown over a collage of flat icons (bricks, bunting, a
  crowned bust) with "HEIR: ALIVE. FILE COMPLETE." stamped in red across it. The stamp is a good gag; the collage is placeholder.
- **c13lat17_30_ending, c13lat17_32_ending:** the credits roll says "PLACEHOLDER CREDITS / Design and direction: you / Music:
  synthesized in code". The closing lines ("For everyone who waited to be heard. For everyone learning to choose again. The Paths
  will be back, in some other order.") are sincere and short. A Skip button exists.
- **c13lat17_34_ending_late:** "The Paths Unbound" panel: decks may now use 3+ Paths, the Alchemist brews tri-Path cards, Primm
  "works under guard on wells and pipes". Clear postgame hook, delivered as a rules panel.

Verdict on the ending: the writing is a 7, the staging a 3. Two painted stills (the leaders, the decree) would carry it; today one
still, a dozen gradient-and-glyph boxes, a blank quest panel over the prose, and placeholder credits.

### 5. The Old Service Tunnels (S-CAP), map only

- **c13lat14_53_scap_map:** Three nodes (The Sewer Checkpoint, The Four-Faction Junction, The Grate Beneath the Plaza) on a painted
  sewer with the four Path colours as a mural; 10 s to load after `dev travel`. A three-node side dungeon is short for the Capital,
  but the art holds the standard of the castle. I did not fight in it (time).

### Deck, packs, character

- **Character (c13lat01_04_character):** Level 20, HP 23, 0/3 items equipped, gear slots filled. Nobody told the bot (or would tell
  a player) that three item slots are empty before the final dungeon.
- **Deck (c13lat01_05_deck):** 47 cards, 19 infrastructure. The Deck Station shows the collection in a grid with counts; readable,
  but no "suggested" or "curve" help, and no warning that 40 % infrastructure floods hands (which it did, every fight).
- **Packs (c13lat01_06_packs, c13lat02_03_pack_open):** 21 unopened packs at the end of the game. The open animation is pretty; the
  "extras turn into essence" tip is clear. An "Open all (21 packs)" button exists, which is the right call.

### UI/UX consistency

- Three continue conventions: narration still "E / Click to continue"; dialogue still "Click / Space to continue - Esc: skip";
  Victory and Opening Hand panels: click only (E and Space ignored, c13lat11_49_ending, c13lat14_33_ending). The driver's
  `skip_dialogue` (which taps E) stops at the Space-only boxes, which is exactly what a keyboard player will hit.
- Esc during the Primm dialogue opened the pause menu (c13lat11 play.log: Resume found) instead of skipping.
- The pause menu's Settings shows "Resolution 1600 x 900, Graphics quality Medium" (c13lat06 play.log) - fine.

### Performance

Load timings from play.log: `dev load` 21 s (first run), `dev travel capital` 23 s, `dev travel dungeon D-PC` 12 s, node click to
fight 8 s, phase transitions 3-4 s. Every run ends with Godot "Pages in use exist at exit in PagedAllocator" and "157 ObjectDB
instances were leaked" (c13lat04 stdout.log) - not player-visible but a leak.

## Top 15 problems (ranked by impact on late-game enjoyment and retention)

1. **Victory / Opening Hand / boss-node popups ignore E and Space.** Where: c13lat11_49_ending (phase 2 Victory after 10 E/Space
   taps), c13lat14_33_ending (phase 3 Opening Hand after 20 taps). Why: a keyboard or pad player is stuck in the middle of the final
   boss. Fix: make Space/E/Enter activate the default button on every modal (Continue, Keep Hand), and show the key on the button.
2. **The map's "Where to?" and Goal line never learn about the Capital.** Where: c13lat02_01_whereto, c13lat01_03_map. Why: the
   first screen a lost player opens says the wrong goal and offers no route. Fix: add "The Undercroft -> the Capital" to Where to?
   and update the Goal label from the tracked quest.
3. **Castle fights flood the hand with Powerhouse.** Where: c13lat06_04_hand (6 of 7 cards are basic infrastructure), c13lat07_10_space3
   (10 of 12). Why: the built deck has 19 infrastructure in 47 cards; the pilot itself got "stuck on turn 4" twice. Fix: cap
   infrastructure draws per turn, or have the mulligan rule guarantee at most 3 infrastructure, and warn in the Deck Station above
   30 %.
4. **The ending is staged as glyphs on a gradient, with a blank quest panel over its best prose and placeholder credits.** Where:
   c13lat11_31_phase3, c13lat17_10_ending (two icons), c13lat17_14_ending (blank "Quest complete" box covering "The Model Falls"),
   c13lat17_26_ending (icon collage), c13lat17_30_ending ("PLACEHOLDER CREDITS"). Why: the last ten minutes of a 20-hour game decide
   the review score and the recommendation. Fix: reuse the Model Room still (darker grade per phase, cracked for Unraveling) behind
   Primm's lines; defer the quest-complete and feat toasts until after the ending; paint the decree; write the credits.
5. **The Capital arrival is a brick box.** Where: c13lat03_05_walk1, c13lat03_09_talk2. Why: after a painted gate still, the first
   walkable Capital screen is grey block walls, two beds and nothing to do; "Services restored 4 of 4" is already done. Fix: land
   the player at the gate plaza, let the first NPC explain Zone HP and services, and dress the Crease.
6. **"Click again to go" is the only way to start the boss.** Where: c13lat09_01_boss_click (bottom right, cut off by the narration
   box). Why: it took three runs to discover. Fix: a "Fight Primm" button on the node card after the intro.
7. **Three continue conventions.** Where: c13lat05_02_castle_d1 (E/Click), c13lat11_03_intro (Click/Space), c13lat11_19_p1_won
   (click only). Fix: one convention, one prompt string, everywhere.
8. **Lieutenant fights have no rules and no identity.** Where: c13lat04_03_quota_intro3 (empty rules row, 26 HP). Why: "Minister of
   Efficiency" plays like a Bin Raccoon with a title. Fix: one signature rule per lieutenant, shown in the rules panel.
9. **Phase 1 "every unit is a 3/3" shows 6/4 and 7/4 units.** Where: c13lat11_18_p1_pilot. Why: either the rule is wrong or the
   display is; the player cannot tell which. Fix: clamp the displayed stats to the rule or state that buffs apply after.
10. **No Capital roaming enemies.** Where: c13lat04 play.log (`dev encounters roam` lists town only). Fix: two or three Capital
    roamers (guards, clerks) with the Zone HP tension.
11. **Primm's rules in phase 2 and 3 are only in the left panel.** Where: c13lat11_27_p2_board. Why: the phase swap dialogue does not
    say the rule; you learn it from a sidebar after the fight starts. Fix: a rules interstitial per phase ("Phase 2: Reflection -
    his deck is a copy of yours").
12. **Empty item slots at the final boss.** Where: c13lat01_04_character (0/3). Fix: a "you have empty item slots" prompt at the
    castle gate and at the boss node.
13. **21 unopened packs at the end of the game.** Where: c13lat01_06_packs. Fix: prompt at zone-clear and at the castle gate.
14. **Node and rule names truncate.** Where: c13lat05_07_castle_map ("Gourmand Wing: the Doppelganger's La..."), the Freed Leaders'
    buffs as unlabeled green icons (c13lat11_17_p1_board). Fix: two-line labels; hover text for buffs with the leader's name.
15. **Renderer leaks at exit and a 21 s snapshot load.** Where: every stdout.log ("Pages in use exist at exit"). Fix: free the
    castle map's textures on scene exit; stream the castle's painted map.
