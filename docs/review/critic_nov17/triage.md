# Nov 17: triage of the playthrough and the critics' panel

Sources: `playthrough.md` (Part 1), `01_combat.md` ... `06_cardgames.md` (Part 2). Severity is the critic's (blocker / major / minor);
reach = how many players meet it (all / most / some / few); effort S (an hour or less) / M (a few hours) / L (a day or new art).
"Owner?" = needs the owner's taste or a rule change. Status: **Fixed** (tonight, with a test or a shot), **Logged** (not tonight),
**L plan** (written below), **Owner** (in the report's decisions).

## Part 1 - the playthrough

| # | Issue | Sev | Reach | Effort | Owner? | Plan / status |
|---|---|---|---|---|---|---|
| P1 | Primm's Castle is a wall for the planning AI (10 tries, L17-24; the castle's 4th room lost 5 times, Primm's later phases 5) | major | some | M | yes (Primm fixed) | **Owner**: the castle's 4th room, not Primm, is the most-lost fight of the game |
| P2 | The Rescuer's cave-mouth scenes had no marker | major | most | S | no | **Fixed** ("!" over her while she waits) |
| P3 | "Free the Four Zones" (the castle's marker) depends on talking to Brannoch | minor | few | S | yes | **Owner** (start it on the first Capital visit?) |
| P4 | Captain Spotless beat an L16 hero twice | minor | some | - | - | Logged (inside the sims' band) |

## Critic 4 - the art director (5.5/10)

| # | Issue | Sev | Reach | Effort | Owner? | Plan / status |
|---|---|---|---|---|---|---|
| A1 | The Crease shows the sky and the Capital's skyline over its back wall | blocker | all | S | no | **Fixed** (the north wall rises above the ceiling; shot after) |
| A2 | The D.N.A. reads as a greybox (one-texture wallpaper walls, white light quads, a faceted orb, blank signs, white cubes) | blocker | all | L | no | **L plan** |
| A3 | The Capital's facades and floors are flat pastel fills; a hot checkerboard | major | all | L | taste | **L plan** |
| A4 | The Buffet is washed out by its haze; the sea is a flat plane with decals | major | all | M | taste | Logged (the Buffet's look was the owner's Nov 16 pass) |
| A5 | Untextured low-poly primitives beside painted art (Buffet cabbages, cubes, an X-eyed box; the Dump's pink pig cube; topiary spheres) | major | all | M | no | **L plan** (a primitive sweep) |
| A6 | A different post filter in every zone | major | all | M | taste | **Owner** (one master grade?) |
| A7 | The Opening Forest (the first screen) is murky | major | all | S | taste (teal dusk) | **Owner** |
| A8 | The Gainlands' stepped cliffs and tiled brick | major | all | L | no | **L plan** |
| A9 | Voids at map edges (the Reek, the Transit Yards, the Dump's arrival water, the Crease's tunnel) | major | most | M | no | Logged |
| A10 | The freed Capital barely celebrates in Grave Row | minor | most | S | no | By design: Grave Row holds the royal funeral after Primm; bunting there would be wrong. Lanterns / mourners are an owner idea |

## Critic 1 - combat and deckbuilding (4/10, provisional: one fight finished)

| # | Issue | Sev | Reach | Effort | Owner? | Plan / status |
|---|---|---|---|---|---|---|
| C1 | No roamer near the Dump's entrance (the nearest are 22 m off; the critic found none in four runs) | major | some | S | no | Logged (they were moved off the bean line on Nov 10 on purpose) |
| C2 | The 45-card minimum with 19 basic infrastructure dilutes every new card | major | all | M | **yes** (a core rule) | **Owner** |
| C3 | Fights are long (8 turns, 1.5 min at pilot speed for a first room) | major | all | M | yes (balance) | **Owner** (with C2) |
| C4 | Boss setup turns then a swarm: nothing shows what the boss will do | major | all | L | yes | **L plan** (an intent strip) |
| C5 | The hand overflows over 6 cards and overlaps the infrastructure row | major | most | M | **no: the board layout stays** | Logged (owner rule) |
| C6 | Attackers cover blockers during combat | minor | most | M | board layout | Logged (owner rule) |
| C7 | Four boxes before the first action; "End your turn?" catches double presses | minor | all | S | - | Checked: the confirm only asks while a card is playable and has "don't ask again"; logged |
| C8 | The boss intro says "The Grand Chef", the board "The Doppelganger" | minor | most | S | story | Logged: the impostor is the twist; critic 3 to judge |
| C9 | Hand cards show a generic "Effect" chip | minor | all | S | no | **Fixed** (the chip says when: On play, On death, On attack ...) |
| C10 | Path identity blurs in a two-Path deck | minor | some | M | - | Logged |

## Critic 2 - the late game and the ending (4/10; did not reach the ending: Primm phase 1 lost on turn 6 at L17)

| # | Issue | Sev | Reach | Effort | Owner? | Plan / status |
|---|---|---|---|---|---|---|
| L1 | With four lands free there was no main quest ("Nothing here right now"); the HUD tracked a side quest | blocker | some (whoever skipped Brannoch) | S | no | **Fixed**: once a zone is free, Free the Four Zones starts by itself and leads over a side quest (same as playthrough P3) |
| L2 | Crosspath's "Point me to..." had no entry for the Capital | major | all | S | no | **Fixed**: exits come right after dungeons and gates; the cap is 22 |
| L3 | The north exit is hard to find on foot (the lawn stops you under the label) | major | some | M | no | Logged (the critic's blind scripting played a part; the road is marked once L2 points at it) |
| L4 | DEFEAT drawn over the defeat panel's own text | major | all who lose | S | no | **Fixed**: the word clears as the panel opens |
| L5 | Primm's three free Militia decide phase 1 | major | all | S | **yes (Primm unchanged)** | **Owner** |
| L6 | Standing Army says 3/3, the board shows 3/1 with a -2 | minor | all | S | Primm rules | Logged (a debuff on the board, not the rule; Primm unchanged) |
| L7 | Primm's long pre-fight scene replays on every re-entry | minor | some | S | - | Logged |
| L8 | Primm's cut-in line repeats his first Model Room line | minor | all | S | single line | **Fixed** (one line, `docs/dialogue/nov17_single_lines.csv`) |
| L9 | "Usually level 21" with a level-16 hero and nothing says where to level | minor | some | S | - | Logged (the hint already shows amber 2+ levels under) |
| L10 | The tracker's pager flips to a side quest while a shop is open | minor | some | S | - | Logged |

## Critic 5 - the first 30 minutes and the menus (4/10; reached the cave's first fight; controller run done)

| # | Issue | Sev | Reach | Effort | Owner? | Plan / status |
|---|---|---|---|---|---|---|
| F1 | The Path screen only selects on the Path's name; the picked tile looks no different | blocker | all | S | no | **Fixed**: a click layer over each whole tile, a gold frame on the picked one |
| F2 | Nothing can be saved before the Path choice; retries replay the opening | major | some | S | - | Logged (the opening is about 25 lines; a skip exists for dialogue) |
| F3 | The first duel is slow: stacked tips, a 3 HP scavenger alive on turn 5 | major | all | M | yes (first-duel AI, tips) | **Owner** (with C3) |
| F4 | A save inside the cave reloads at the forest with the cave reset | major | some | - | rule | By design (dungeon runs are never saved; the owner's rule since Oct); logged |
| F5 | J, C and P did nothing in the forest, with no word | major | most | S | no | **Fixed**: the hero says those start in town |
| F6 | Hand cards cut off at the bottom; infrastructure half-hidden | major | all | M | **board layout stays** | Logged (owner rule) |
| F7 | The Path screen's sample cards are too small to read | minor | all | S | - | Logged |
| F8 | The Peek pop-up could not be closed without choosing | minor | most | S | no | **Fixed**: Done always works (unchosen cards stay on top); E, Space, Enter confirm |
| F9 | The pause menu says F8 with a controller | minor | some | S | no | **Fixed** (no key shown while a pad is connected) |
| F10 | The forest is very dark; the hero's cloak is teal in the wake picture and brown in the portrait | minor | all | M/L | taste / art | **Owner** (with A7); the cloak is a Batch 17 row |

## Critic 6 - the new card games (3/10; reached only Reps)

| # | Issue | Sev | Reach | Effort | Owner? | Plan / status |
|---|---|---|---|---|---|---|
| G1 | The quiz teachers are not in "Point me to..." | blocker | all | S | no | **Fixed**: quiz, minigame and puzzle places are in the list |
| G2 | The card-game hosts and the D.N.A.'s filing terminal are not in "Point me to..." | blocker | all | S | no | **Fixed** (with G1) |
| G3 | The D.N.A.'s filing terminal could not be walked to (4 routes stopped at the lobby's north wall) | blocker? | some | M | no | Logged: the D.N.A. walk smoke reaches the Mail Room; the critic walked blind. With G2 the arrow now routes there |
| G4 | Dex's ledge in the Dump looked unreachable (a fence and a gate) | major | some | S | no | Logged (the Dump's gates open with the beans; walk smoke passes) |
| G5 | With How to play open, the pad's A guessed on the table beneath | major | pad | S | no | **Fixed**: nothing outside an open card-game overlay takes focus |
| G6 | On the result screen the D-pad reached the header's "?" | major | pad | S | no | **Fixed** (with G5) |
| G7 | Reps: a miss also resets the streak, and the rules did not say so | major | all | S | no | **Fixed** (the rule says it); keeping the streak is an **Owner** call |
| G8 | Reps' "Power" vs the mana number on the card | minor | all | S | - | Logged |
| G9 | The barbell prop is grey blocks | minor | all | L | art | Batch 17 row candidate |
| G10 | Nine boxes before the first Reps | minor | all | S | - | Logged |

## Critic 3 - the story and the writing (6/10; read the whole main story, saw the opening in game)

| # | Issue | Sev | Reach | Effort | Owner? | Plan / status |
|---|---|---|---|---|---|---|
| S1 | Elowen's name is taken from her (Plume names her) and her rescue is a postgame hook: the warmest bond never pays off before the credits | major | all | M | **yes (story)** | **Owner** |
| S2 | The hero's finale argument is a collage of other characters' lines; he has little voice of his own | major | all | M | **yes (story; no broad rewrite)** | **Owner** |
| S3 | Primm both does and does not know who the hero is | major | all | S | story | Partly: logged; the intro line is the owner's (the cut-in line was changed, L8) |
| S4 | The D.N.A.'s Tuesday payoff contradicts itself | major | most | S | no | **Fixed** (one line) |
| S5 | After the ending the Gate Road still looks blighted against the ending's words | major | all | M | no | Logged (c13end is an old snapshot; the freed Capital look was rebuilt Nov 12; to check on a fresh save) |
| S6 | "Best student" and Maren's "I taught the royal children" repeat | minor | all | S | story | Logged (one of them is in the owner's list) |
| S7 | Hob's "What are you writing?" gag runs six times; two explanations of "nothing dies" | minor | all | S | story | Logged |
| S8 | Who gave the seed shifts | minor | most | S | no | **Fixed** (Compostella's line names the groundskeeper) |
| S9 | Escoffina: name vs title | minor | most | S | no | **Fixed** (two lines) |
| S10 | Reaching Maren's door for a memory is hard on foot | minor | some | - | - | Logged (blind walking; the Rescuer and Maren are marked) |

**Single lines changed** (`docs/dialogue/nov17_single_lines.csv`; revert with `node tools/apply_dialogue_pass.js
--csv=docs/dialogue/nov17_single_lines.csv --revert=docs/dialogue/nov17_single_lines_ids.txt`): Primm's cut-in, Mortimer's Tuesday line,
the Grand Chef's and the Doppelganger's naming lines, Compostella's seed line, the Hollow Warden's opening line, Prudence's first
"authorization", Mortimer's number, the Wanderer's "a story about a little prince" (no such scene existed), the Rescuer's "stay down"
(the hero stands), Primm's "That is simply not true". **Not touched (the owner's list from Nov 16):** Maren's "the same way I have been
holding yours", "Four banners fly from the same pole", "find me on the square", "I still can't see her face", "a coat too fine". Plume's
slip line was left (the fix would assert a fact about Elowen's father).

## Part 4 - re-checks on the fixed build (fresh agents, the same briefs, 8 runs, three anchor shots and the round-1 score)

| Lens | Round 1 | Re-check | What changed in what they saw |
|---|---|---|---|
| 1. Combat | 4 (C6 F4 P6) | **4** (C5 F4 P6) | Same pace and thin choices. New findings: a normal fight's reward has no card pick (owner decision 1); "One Infrastructure per turn" toast outlives its turn; three "Victory" moments; a hover preview over the banner |
| 2. Late game | 4 (C3 F4 P6) | **4** (C3 F3 P6) | Fixed and seen: town's log now shows Free the Four Zones with a where-to-go line (it was "Nothing here right now"); DEFEAT no longer covers the panel text. Still: walking out of town on foot failed for this critic too; Primm phase 1 lost on turn 6 to the Militia (owner decision 2) |

Neither re-check reached further than round 1, so the numbers cannot show the fixes; the screenshots do (`n17rlate_03_journal` against
the anchor `n17late_03_cmain`).

## Found by me tonight (not by a critic)

| # | Issue | Status |
|---|---|---|
| M1 | Every zone's quiz host said "[missing text: quiz.start]" (and the result remark): a missing story key is not empty | **Fixed** (`CardGameScreen.story_line`), test |
| M2 | The strict playthrough tool: `tools/run_strict_playthrough.sh` (real walking, quests by E, no decree) | New tool |
