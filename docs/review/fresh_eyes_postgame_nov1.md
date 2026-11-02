# Fresh eyes: the postgame of The Wayward Path (Nov 1, 2026)

Critic pass 13 (postgame). Played from the `postgame_real` snapshot through the scripted driver in `C:\Dev\wp_critic`, build v0.5.1.
Screenshots cited below are in `fresh_eyes_postgame_nov1/`, prefixed by run name (c13a ... c13l).

## Summary

The postgame has the bones of something good: a single "Loose Ends" quest that names three hooks (a mountain, Rip's secret, a crowd
under Crosspath), two beautifully painted new dungeon maps (the Path-ology Lab and the Ascent of Mount Swolympus), an eight-bout Arena
with clear prizes, and boss rule sheets that explain themselves better than most games in the genre. The writing keeps landing
("The regime can't confiscate a reflection. They tried."; "Do sit; the straps are new.").

What is not working is the part that keeps a player playing: the two postgame bosses are walls for the deck the game itself built
(Dr. Siphon took zero damage in eight turns; the Ancient Spotter's Millstone Pusher did 25 damage in two hits to a 19 HP hero), and
losing ejects you from the dungeon with the whole run gone. Getting to the mountain is a fetch chain gated behind an NPC who first
replays his end-of-story speech, and reaching that NPC took three runs because other NPCs physically block the paths. Popups do not
honour the "E / Space / Click: confirm" promise in the HUD, HP is shown as three different numbers, and the Capital's liberated
hideout sits under an untextured white castle blockout. Overall the postgame currently reads as a 5/10 against Slay the Spire / Monster
Train style endgames: things to do, but the first hour after the credits is friction and two unexplained defeats.

## How I played (runs, places, time)

Wall clock 17:58 to 18:32 playing (12 runs, all under 130 s of game time each; one run's process took ~7 minutes to start up), then
report. No `SCRIPT ERROR` in any `stdout.log`. Every run exits with `ERROR: Parameter "RenderingServer::get_singleton()" is null`.

| Run | Script | What happened |
|---|---|---|
| c13a | critic13_pos_a_start | Snapshot in Crosspath; Quest Log, Map, Character, Menu, Feats, Glossary; `dev travel capital` (lands in "The Crease") |
| c13b | critic13_pos_b_scout | Gainlands arrival (forced scene), Lab map + rules, Arena (Undercroft) board |
| c13c | critic13_pos_c_swol | Gainlands: walked north, blocked by Grandmaster Flex in the bridge mouth; read his talk |
| c13d | critic13_pos_d_swol2 | Wasted: `dev load` put me back at the zone entrance, my Escape opened the pause menu (deleted) |
| c13e | critic13_pos_e_swol3 | Sidestepped Flex, reached the gym hall corner; found the goal pointer |
| c13f/g | critic13_pos_f_omm / g_omm2 | Two more attempts to reach Old Man Mountain; blocked by Coach Benchley the first time, by nothing I could see the second |
| c13h | critic13_pos_h_omm3 | Reached Old Man Mountain, read both talks; Lab node 1 fight (pilot won, 11 turns) |
| c13i | critic13_pos_i_labboss | `D-LAB -2`, read the Extraction Theater text and Dr. Siphon's intro |
| c13j | critic13_pos_j_labboss2 | Dr. Siphon fight with the pilot: Defeat in 8 turns, boss at 42/42 |
| c13k | critic13_pos_k_spotter | Deck Station; `dev encounter Spotter` matched the zone brute "Quota Spotter" (4 HP); two manual turns, then pilot |
| c13l | critic13_pos_l_ancient | `S-BEEF -2` (Mount Swolympus map, rules); `dev encounter Ancient Spotter`: Defeat in 10 turns |

Skipped for time: walking the Capital's surface districts, the Collection Book (I could not find it in the Menu: Character, Deck,
Quests, Packs, Wardrobe, Glossary, Feats, Settings), opening packs, the shops, playing an Arena bout, Rip's secret and the Spot-Gary
errand chain. The Ancient Spotter was fought through `dev encounter`, which skips the boss intro and the painted board, so I could
not judge his presentation; his numbers I could.

## Scores (1-10 against Slay the Spire, Inscryption, Monster Train, Sea of Stars, Octopath, Pokemon TCG Pocket)

| Area | Score | One line |
|---|---|---|
| Clarity | 6 | Quest Log and "Before the fight" rule sheets are excellent; the postgame's four objectives are hidden as ???, the Lab has no hook, HP is three numbers |
| Pacing and friction | 3 | NPCs block paths, fetch chain before the mountain, forced arrival scenes, popups need the mouse, defeat ejects you from a 15-node dungeon |
| Combat depth and feel | 5 | Boss rules read well and stack interestingly; the two postgame bosses are untuned walls for the game's own deck; the pilot never dented Siphon |
| Deck-building | 7 | Deck Station is the best screen in the game: filters, copy caps, curve, Suggest a deck; 27 unopened packs nobody mentions |
| Reward rhythm | 4 | Victory popup shows no reward; Lab boss pays "100 gold and XP, a choice of card" for 15 nodes; Loose Ends pays 500 gold / 400 XP; level 23/30 with 0 XP progress visible |
| Exploration and world | 6 | Gainlands and the two dungeon maps are gorgeous; the Capital's hideout sits under a white blockout; the town map is mostly fog after a full campaign |
| Story and humour | 7 | Flex's ten-year breathing monologue, Old Man Mountain, Siphon's "Subject 1" all land; the Gainlands arrival scene plays again on each visit |
| Visual cohesion and readability | 7 | HUD, maps, boards and cards share one look; dungeon labels get clipped under dialogue; `dev encounter` boards are a flat navy void |
| UI/UX consistency | 4 | E / Space do not confirm Victory / Defeat / Opening-hand popups; Escape opens the pause menu over a dialogue; `button Continue` found on some popups, not others |
| Audio | n/a | Cannot judge from screenshots and logs |
| Performance | 6 | Loads 4-10 s, no stutter visible in timestamps; one process took ~7 min to boot; shutdown error on every exit |
| Bugs | 5 | Nothing fatal, but see the top 15: blocking NPCs, popups, HP numbers, stray labels, lingering banner label |

## Findings per area

### 1. What now? (c13a_01_start, c13a_02_questlog, c13a_03_map, c13a_09_feats)
- The HUD tracks "Loose Ends" with "Climb Mount Swolympus: Old Man Mountain at the Swole Station knows the way up", then "???", then
  "Go to the Gainlands" (c13a_01_start). The Quest Log's description is the best piece of signposting in the postgame: "A mountain
  nobody has climbed, a secret Rip has been keeping, and a crowd under Crosspath that wants a show" (c13a_02_questlog). But the
  objectives list is 0/4 with three of them hidden as "???", so the player cannot choose; they are funnelled into the mountain first.
- The Path-ology Lab, the postgame's story dungeon, is not mentioned anywhere: not in the Quest Log, not on the town map legend, no
  Forest Hatch marker. I only found it with `dev travel dungeon D-LAB`. Its entrance text ("A staircase of clean steel goes down
  through the roots of the forest where you woke up", c13b_06_lab_entrance) suggests it is under the starting forest; nothing tells
  the player to go back there.
- The town map after a finished campaign (c13a_03_map) is 80 % black fog with islands around visited spots; the "Where to?" bar is a
  text field, not a button (`button Where to` NOT FOUND). Fast travel exists and reads well.
- Feats (c13a_09_feats): 17 of 40, with the postgame ones hidden as "???" and plenty of visible unfinished side-dungeon feats
  ("Never Skip Leg Day", "...Yes, Chef."). Good long-term checklist; the gold rewards (10-100) are trivial at 1200 gold.
- The Character screen (c13a_04_character) shows 27 unopened packs (7 Beefcake, 4 Gourmand, 4 Refusemancer, 3 Necrocrat, 4 Gilded,
  1 Prismatic, 4 General) and 0 of 3 items equipped. Nothing in the postgame nudges the player to open them or re-equip.
- The Capital after liberation: `dev travel capital` lands in "The Crease, the hideout under the Capital" with a Rift Station popup
  from Rip Tearson (c13a_11_capital). Nurse Hesper Dray, The Grand Chef, Agnes Overdue and Archdruid Compostella are gathered there
  (c13a_15_capital_e), which is a nice "the gang is together" beat, but the top third of the screen is an untextured white castle
  blockout with grey placeholder statues. For a liberated capital this reads as unfinished.

### 2. Mount Swolympus (c13b_01_gainlands, c13c_03_walk2, c13c_11_e8, c13e_01_near_hall, c13e_02_door, c13h_01_at_omm, c13h_10_e9, c13l_01_swol_map)
- Arriving in the Gainlands plays a long cutscene with Grandmaster Flex (c13b_01_gainlands: "On the arm of the Throne of Gains
  someone has left a schedule...") before the player can move. The writing is good (c13c_11_e8: "Clench is learning to lift from
  zero. The strongest take the longest."), but it plays on every arrival through the Rift, and Escape produces "Skip this scene? You
  haven't seen it." even though I had.
- Grandmaster Flex stands in the mouth of the entrance bridge (c13c_03_walk2): holding W for 3 s moved the hero nowhere. Coach Brutus
  Benchley then blocked the walk along the gym hall. It took runs c13c, e, f, g and h to stand next to Old Man Mountain, who is 30
  world units from the bridge.
- The goal pointer (small arrow at the screen edge, c13e_02_door bottom-left) exists but is tiny and easy to miss against the sand.
- Old Man Mountain (c13h_01_at_omm, bark "There was a boy at the Lifting Festival once. Four colours in his hands... hm.") first
  replays his freed-zone speech ("YOU DID IT. Flex is out, Clench is down..."), closes, and only then shows "Old Man Mountain has a
  favour to ask. Talk again." The second talk (c13h_10_e9) is the actual hook: "Rule one. Gary's under a barbell again. Go and spot
  him; follow the groaning. Then check your form at a Flex Mirror." So the summit sits behind: find OMM, talk twice, find Gary, find a
  Flex Mirror, come back. None of these are on the map.
- The Ascent itself (c13l_01_swol_map) is a stunning painted map but only three nodes: Base Camp Bros, The Squat Rack Pass, The
  Summit Altar. Rules (c13l_02_swol_rules): Pump It Up, Processing Time, Thin Air (Hustle +1/+0) - clear and on-theme.
- The Ancient Spotter (40 HP; fought via `dev encounter`, so no intro): the pilot lost in 10 turns, "Millstone Pusher dealt all 25
  damage you took (2 hits)" (c13l_09_anc_end). A single unit hitting for 12+ twice against a 19 HP hero is a one-answer puzzle, not
  a boss fight; without a telegraph it is a coin flip on whether you drew removal.

### 3. The Path-ology Lab (c13b_06_lab_entrance, c13b_08_lab_rules, c13h_11_lab_node1, c13h_12_lab_fight_start, c13h_13_lab_fight_end, c13i_02_boss_pre, c13i_12_boss_after2, c13i_13_boss_after3, c13j_02_fight_end, c13j_03_after1)
- Best-looking dungeon map in the game: 16 nodes, four coloured specimen tanks, a visible route to The Extraction Theater. The
  entrance text and "Everything about this place is familiar in the way a bruise is familiar" (c13b_08_lab_rules) set the tone.
- Rules: Pump It Up, Processing Time, Specimen Conditions (your max life is 5 lower: 14/14), Specimen Conditions (enemies +1/+1). The
  "Before the fight" sheet (c13h_11_lab_node1) with hoverable icons that stay on screen is genuinely better than Slay the Spire's
  tooltips.
- Node 1, Intake Orderly (30 HP): the pilot won in 11 turns ending at 10/14 (c13h_13_lab_fight_end). The Victory popup says "You
  defeated Intake Orderly in 11 turns. Continue" - no gold, XP or card shown. The board (c13h_12_lab_fight_start) is a cracked white
  lab floor with vines: good.
- The boss (c13i_02_boss_pre, c13i_12_boss_after2): Dr. Ambrose Siphon, four-Path, 42 HP, nine stacked rules: his units +2/+1
  (Elowen jams one if rescued), a 3/3 Failed Experiment every third turn, drains 1 life per turn, your first card costs 1 more, a
  half-health valve (you take 2, he heals 2), draws 2 near the end. Each line is clear; together, with 14 max HP and a hand of 16/13
  and 7/4 units (c13j_01_fight_t1), they are a wall. The pilot lost in 8 turns with Siphon untouched at 42 (c13j_02_fight_end);
  "What beat you: Failed Experiment dealt 7 of the 16 damage you took (1 hit). Tip: You ended with 8 cards still in hand." The tip is
  right about the pilot, but 14 HP minus 1 per turn minus a 7-damage swing on turn 4 leaves a human player two turns of slack.
- The intro cut-out (c13i_13_boss_after3: "Subject 1. Back where you belong. Do sit; the straps are new.") and the three dialogue
  lines before it ("My daughter is resting in your old room. She is confused, poor thing. She thinks she rescued something.") are
  the strongest villain writing in the game.
- Defeat: "You are carried out of the dungeon. Your collection is safe." and you wake in The Forest Clearing (c13j_03_after1) with
  all 15 cleared nodes gone. For a postgame dungeon this long, that is the single biggest retention risk I saw.

### 4. Arena, Collection Book, Feats (c13b_11_arena_e, c13a_09_feats)
- The Undercroft (c13b_11_arena_e): walrus announcer Grand Bellows, three tiers (Bronze/Silver/Gold Sand), 8 bouts mixing battles,
  puzzles ("win THIS turn", "survive 3 enemy turns"), restricted decks (Gladiator's Kit, Spellslinger's Satchel, no units) and a
  final Marshal duel. Prizes are listed up front (Champion's Laurels, Crowd-Pleaser's Cape, Gladiator's Net, Bloodsand Boots, 500
  gold). 0 of 8 cleared after the credits. This is the most "Monster Train challenge mode" thing in the game and it is good; it just
  has no quest hook or HUD mention beyond the map icon.
- Collection Book: not in the Menu list; I could not find it in 70 minutes, so neither will a player.
- Feats: see above. The "Earned here" column is good; no progress bars on partial feats (e.g. Gold Sand 0/8).

### Combat feel at this level (c13k_01_deck, c13k_10_played2, c13k_12_enemy_turn)
- The snapshot deck is 49 cards, 19 infrastructure, mostly Beefcake with 16/13 and 10/5 units. Against a freed-zone brute (Quota
  Spotter, 4 HP, c13k_02_spot_intro1) the pilot still needed 9 turns and lost 10 HP - the zone fights are too slow for how trivial
  they are, and too trivial to be worth 9 turns.
- Manual play: dragging a unit before any infrastructure gives "Needs 3 energy; you have 0 (each ready Infrastructure gives 1 a
  turn)" (c13k_10_played2) - good feedback, but I could not find an energy counter anywhere in the HUD dump; energy is only visible
  on failure. The 11-card hand fans so tightly that names clip (c13k_12_enemy_turn).
- The phase tracker (Start / Main / Combat / Main 2 / End) with a one-line explanation of the current phase is clear and better than
  most.
- `dev encounter` fights happen on a flat navy board with no backdrop (c13k_10_played2); if any real encounter shares that path it
  will look broken.

### UI/UX consistency
- E / Space do not close the Victory, Defeat or Opening-hand popups; only clicking Continue / Keep Hand works, although the HUD footer
  promises "E / Space / Click: interact ... confirm popups". Dialogue boxes do take E.
- Escape over an open dialogue opens the pause menu instead of closing the dialogue (c13d, my own mistake, but a player will make it).
- A Rift arrival / snapshot load always places the hero at the zone's bridge entrance, 30 units from the Swole Station.
- `dump` after returning to town printed a stray label `6789 .,:;!?'` at (27,10) and the "The Gainlands is free. Its people have new
  things to say" banner stays in the UI tree long after it faded.

### Performance
- Snapshot load 7 s, zone travel 6-10 s, dungeon map 4 s + 8 s fade. No frame hitches visible between timestamps. One game process
  (run c13c) took about 7 minutes of wall clock to boot before the 50 s script ran; others took 60-90 s. Every exit logs
  `RenderingServer::get_singleton() is null`.

## Top 15 problems (ranked by impact on postgame enjoyment and retention)

1. **Postgame bosses are untuned walls for the game's own deck.** Dr. Siphon: pilot lost in 8 turns, boss untouched at 42/42
   (c13j_02_fight_end). Ancient Spotter: Millstone Pusher hit for 25 in two swings against 19 HP (c13l_09_anc_end). The pilot is
   weak, but 14 max HP, 1 drain per turn, enemy units +1/+1 and +2/+1 and a first-card tax leave no room for a human to learn the
   fight either. Fix: make Specimen Conditions a percentage not a flat -5, cap Extraction at 5 total, telegraph the Pusher's big swing
   one turn ahead, and add a rest/heal node before the Extraction Theater.
2. **Defeat ejects you from the whole dungeon** ("carried out of the dungeon", c13j_03_after1) after 15 cleared Lab nodes. Fix: keep
   cleared nodes for the run and allow one retry from the boss node, like Slay the Spire's boss retry mods or Monster Train's rerun.
3. **Popups ignore E / Space** (Victory, Defeat, Opening hand) while the HUD says they confirm. Fix: route ui_accept to the focused
   default button on every popup.
4. **Nothing points at the Path-ology Lab** - the postgame story dungeon is absent from the Quest Log, the town map and the HUD.
   Fix: a Loose Ends objective "Rip's secret: the Forest Hatch" with a map pin at the starting forest.
5. **The Swolympus hook is a hidden fetch chain**: talk to OMM twice (the first talk replays his ending speech), spot Gary, find a Flex
   Mirror, then a 3-node climb. Fix: make OMM's first line the hook, cut to one errand, pin each step on the map.
6. **NPCs physically block paths** - Grandmaster Flex in the bridge mouth (c13c_03_walk2), Coach Benchley along the gym hall. Fix:
   NPC colliders that let the hero slide past, and never place a story NPC on the only path.
7. **Loose Ends shows 3 of 4 objectives as ???** (c13a_02_questlog) so the player cannot choose; the Arena ("a crowd under
   Crosspath") and the Lab are not selectable. Fix: reveal all four up front with a "Where to go" line each.
8. **The liberated Capital's hideout sits under a white castle blockout** (c13a_11_capital). Fix: finish the backdrop or drop the
   camera so the top third is wall, not placeholder.
9. **Three different HP numbers**: HUD 19/19 "Zone HP", Character "Starting HP 26", Lab 14/14. Fix: one bar with "max 26 (-7 zone
   -5 Lab)" on hover.
10. **Victory shows no rewards** (c13h_13_lab_fight_end: just "You defeated Intake Orderly in 11 turns"). Fix: gold / XP / card line
    on the popup and a running total on the dungeon map.
11. **Forced arrival cutscene on every Gainlands entry**, with "Skip this scene? You haven't seen it." on a scene already seen. Fix:
    play once per save; make the skip prompt honest.
12. **Fast travel / loads drop you at the zone bridge**, 30 units and two blocking NPCs away from the only postgame NPC. Fix: a Rift
    station at the Swole Station, or let the quest pointer pull the camera.
13. **27 unopened packs and 0/3 items equipped with no nudge** (c13a_04_character). Fix: an "unopened packs" badge on the Menu button
    and a one-time "you have packs" banner after the credits.
14. **The Arena has no hook** beyond a map icon: 0/8 after the credits with the best prizes in the postgame (c13b_11_arena_e). Fix:
    Grand Bellows barks in the square after the credits; Loose Ends objective "Step up to the booth".
15. **Hand and energy readability**: 11 cards clip their names (c13k_12_enemy_turn); energy is only shown when a play fails
    (c13k_10_played2); dungeon labels hide under the dialogue box ("Failed Experiments Ward" shows as "Ward", c13b_06_lab_entrance).
    Fix: a visible energy counter by the End Turn button, hover-zoom on the hand, and dialogue boxes that push map labels up.

Smaller notes: Collection Book missing from the Menu; "Where to?" is a text field that `button` cannot hit; stray `6789 .,:;!?'`
label after returning to town; "The Gainlands is free" banner lingers in the UI tree; `RenderingServer` error on every exit;
`dev encounter` boards have no backdrop; Feats pay 10-100 gold, meaningless at 1200.
