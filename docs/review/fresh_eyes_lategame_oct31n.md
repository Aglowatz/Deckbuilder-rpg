# Fresh eyes: late game and ending (critic run, Oct 31 / Nov 1 2026)

Screenshots cited below are in `fresh_eyes_lategame_oct31n/`, named `<run>_<shot>.png`.

## Summary

The final act of The Wayward Path has two very different halves. The **painted parts** are the best things I saw: the Primm's Castle node map (`r9_20_map`), the castle-gate story stills (`r8_01_pc_enter`), Primm at his model of the kingdom (`r11_i06`) and the Phase 2 boss card with the cracked mirror (`r15_E08`) look like a premium indie game, and the writing in those scenes is sharp and funny ("Mind the floor: it has just been polished, by seventeen people, whom I thank daily, in writing"). The **playable parts** around them fall well short. Nothing tells you how to get to the Capital, and the HUD and map disagree with each other. The Capital is a big walk through a wash of lavender-grey with HP draining from hazards you can't see. Its one lieutenant beat the built-in player, and the Primm fight's opening Phase 1 barely dented him in 10 turns. The boss intro also **soft-locks on its last line**: click, Space and E do nothing, and only Esc > Skip gets you out. Combat itself works and the rule panels are clear, but late-game hands are flooded with basic infrastructure cards and the fights drag on. The castle has 22 nodes on one zone-HP bar with no healing. Score: about 4.5/10. The art and writing up to Primm are worth reaching, but the game makes them too hard to reach. (I did not reach Phase 3 or the ending in the time budget.)

## How I played

About 80 minutes of wall clock, 16 runs of `tools/play.sh` from the `lategame_real` snapshot (level 20 Beefcake, 1200 gold).

| Run | What | Notes |
|---|---|---|
| r1-r2 | Crosspath: quest log J, map M, "Where to?", walking | Tried to find the way to the Capital on foot |
| r3-r5 | `dev travel capital`: the Crease, Gate Road, Gate Plaza, Palace Approach; Captain Spotless | Made my own snapshot `critic_cap1` |
| r6-r7 | Lieutenant Vivienne Quota (`dev encounter quota`): played 2 turns myself, then `pilot` | **Lost** in 8 turns |
| r8-r10 | Primm's Castle: gate story scene read line by line, rules (R), node map, Courtyard fight (Hedge Trimmer Guard) | Pilot got stuck on turn 4 of the Hedge fight; jumped with `dev travel dungeon D-PC -2` |
| r11-r14 | Primm intro (read line by line), soft-lock on its last line, Esc > Skip, Freed Leaders scene | Two runs went wrong (pause menu and then Settings opened over the story box), and I recovered by reloading |
| r15 | Primm Phase 1 by `pilot` for 10 turns, then `dev win`; Phase 1 > 2 transition | Phase 1 was **forced with dev win** |
| r16 | Phase 1 forced again with `dev win`, trying to reach Phases 2-3 and the ending | Ran out of time on the Phase 2 mulligan screen; **Phase 3 and the ending were not seen** |

**Skipped:** the side dungeons (S-CAP and S-PASTE: no time left), a roaming-enemy fight in the Capital (I saw none near the main road), deck building in the Deck Station, and walking the whole route from Crosspath through the Undercroft (my character walked too slowly to cover it in the time). Most of my combat sample is the pilot plus about four turns I played myself, so my combat-depth score has low confidence.

## Scores

| Area | Score (1-10) | One line |
|---|---|---|
| Clarity | 4 | Rule panels are clear; the main quest's next step, the map goal and the "Broken services" count contradict each other |
| Pacing and friction | 3 | Slow walking, 22-node final dungeon on one HP bar, 35 s phase transition, a soft-locked boss intro |
| Combat depth and feel | 5 | Phase rules (all units 3/3, two cards a turn) are a good idea; flooded hands and long stalemates undo it |
| Deck-building satisfaction | 4 | The level-20 deck draws 5-6 copies of the same basic infrastructure; did not see a reason to build differently for the finale |
| Reward rhythm | 5 | Freed Leaders' boons (+2 max HP each, Path buffs) are a nice payoff; little else visible in the Capital |
| Exploration and world | 4 | The Capital has a strong idea (a sickly-perfect pastel city) but reads as an empty grey plain on arrival; the map is mostly dark |
| Story and humour | 7 | Best part of the game: Plume, Elowen's capture, Primm's voice. A few attribution bugs |
| Visual cohesion and readability | 6 | Painted stills and dungeon map 9/10; Capital 3D 4/10; placeholder icons in the phase transition |
| UI/UX consistency | 4 | Three dialogue box styles with three different advance keys; Esc behaves differently in each |
| Audio | n/a | Can't judge from screenshots and logs |
| Performance | 6 | Snapshot loads 7-16 s, zone travel about 10 s; Phase 1 > 2 transition took about 35 s; no stutter visible in the logs |
| Bugs | 3 | Boss-intro soft-lock, stuck map, wrong speaker labels, inconsistent services counter, pilot stall |

## Findings per area

### 1. Getting to the Capital (clarity)
- The HUD tracker still reads **"Free the Four Zones"** with four ticks, then "Storm Primm's castle in the Capital" and "Go to the Capital" (`r1_02_questlog`). The quest log's "Where to go" says *"The castle on its hill, up the palace avenue (The Capital)"*. That tells you where the castle is once you're in the Capital, not how to get to the Capital.
- The Crosspath map's goal ring sits on **Gatekeeper Brannoch** (top of `r1_04_whereto`), not on the way to the Capital. The legend still says "Goal: Free the Four Zones".
- In the "Where to?" list the Undercroft appears only as **"The Undercroft (Arena)"**, and no entry is called "The Capital" or "Road to the Capital". Choosing it put no marker on the map and no pointer in the world (`r2_02_town_pointer`, `r2_05_map_after`), and the dropdown went back to "Where to?".
- In the Capital itself the map's goal ring is again labelled "Free the Four Zones" (`r3_04_map`).
- Walking: 6 s of holding W moved Tessar from the south of the square only to the fountain (`r2_04_walk2`). Even with sprint, Crosspath to the Capital on foot looks like a long trip with no guidance.

### 2. The Capital
- **Arrival:** you land in the Crease, a hideout under the Capital, with a nice Rip Tearson card and a clear one-line Rift Station unlock (`r2_06_capital_arrive`). The HP panel at the top centre explains zone HP well: "Zone HP: no healing after battles. Max 18 here (-2, hover)", and hovering it gives a breakdown (`r3_04_map` shows that tooltip, stuck over the map).
- **"Broken services: 0 of 4"** on the overworld, even though all four zones are freed (`r3_02_services`). It lists Blackout, Famine, Restless Dead and Clutter, each with a "+". In the Primm battle the same panel says **"4 of 4"** in red with "-" (`r15_12_p1`). As a player I can't tell whether "broken" is good or bad, or whether freeing the zones did anything.
- **Invisible HP drain:** walking straight up the Gate Road cost 4 HP, then 6 HP (18 > 14 > 12) with the toast "Ow! The Capital has hurt you again. (-HP)" (`r4_08_n2`, `r5_02_spot2`). I didn't see what hurt me. With no healing between fights, this is punishing and feels random.
- **Look:** the Gate Road is a flat grey-violet plain with dead trees and lamp posts (`r4_01_loaded`). The Palace Approach (pastel checkerboard, striped lawns, "A Perfectly Happy Citizen" NPCs, `r5_07_plaza2`) has a real satirical identity, but the whole zone sits under a heavy washed-out filter, and the buildings are flat untextured blocks next to the painted art.
- **NPCs:** Captain Spotless's bark ("A SMUDGE is TREASON! ...It's on me, isn't it.") is funny, but his name tag is drawn over the bark text (`r4_08_n2`). Pressing E next to him with the "[E] Talk" prompt showing started no conversation (`r5_02_spot2`, five E presses, no dialogue box).
- **Lieutenant (Vivienne Quota, the only one `dev encounters lieutenant` lists):** a plain navy board with no backdrop (`r6_09_myturn2`), unlike the painted castle boards. She plays Beefcake cards (Powerhouse, Leg Day Survivor), so the fight felt like a mirror match against my own Path rather than "the Minister of Efficiency". The pilot **lost** in 8 turns and left her at 26/26 (`r7_08_end`). The defeat card is good ("What beat you: Leg Day Survivor dealt 12 of the 24 damage", plus a tip), but it says **"You are carried out of the dungeon"** in an overworld fight, and the board's "Needs 4 energy" hint stays behind it.
- I couldn't find a roaming enemy on the main avenue in the time I had.

### 3. Primm's Castle
- **Entry scene:** excellent. The guards seize the hooded Rescuer, Percival Plume the peacock reads her charges ("Removed one item of laboratory property, which has been walking about ever since"), and Tessar's "Elowen. Her name is Elowen. I never even asked." lands (`r8_01_pc_enter`). Small art continuity slip: the second still shows two Plumes (`r8_06_map`). The skip dialog repeats itself: "Skip this scene?" / "Skip this scene? You haven't seen it."
- **Rules (R):** two clear rules, Perfect Order (units can't have more than 2 keywords) and Mirrors (the first card each player plays is copied for the opponent). The pre-fight panel lists them again ("Before the fight: Hedge Trimmer Guard"). Good. But R also opens on top of a story box that's still playing, so input reaches the screen underneath.
- **Node map:** the best screen in the game (`r9_20_map`): 22 painted rooms, a red stair up to The Model Room, Path "wings" for each faction. It's also **very long** for a final dungeon on a single 18-HP zone bar with no healing. I couldn't see any rest nodes in the labels apart from a "Resistance Safe Room".
- **Courtyard fight (Hedge Trimmer Guard):** the castle backdrop board looks great (`r10_03_result`). On turn 4 the hand held **five Powerhouses** and the board had one infrastructure. The pilot stalled there ("stuck on turn 4", 125 decisions) with a "Snack Bar: Not enough energy" tooltip. Whether that was the deck or the pilot, a 40-card level-20 deck that draws that much basic infrastructure isn't fun.

### 4. Primm (three phases)
- **Intro:** clicking The Model Room once opens an info card about the boss (multi-phase final boss, rewards, Royal Guard, Out of Alignment, "Click again to go"), but a story box is drawn **on top of it**, so you can't read it (`r11_i02`). The narration lines ("The Model Room is round and domed...", "A man in a pressed grey coat...") are labelled **"Primm, 'His Perfection'"** as the speaker.
- A second dialogue style follows (purple box, "Click / Space to continue", `r11_i06`). The lines are some of the best in the game. On the last line ("Ten years I have been mending this kingdom... I am afraid I shall have to correct you.") **click, Space, E and Enter all do nothing** (`r12_16`, tried in r11, r12 and r13). Only Esc > "Skip" moves on (`r13_03_esc`). A first-time player who doesn't try Esc is stuck. Pressing Esc one box earlier (the brown box that has no "Esc: skip" hint) opens the **pause menu over the scene**, and E then clicks pause-menu buttons (`r14_L1` > Settings in `r14_10_pre`).
- **The Freed Leaders** (Grandmaster Flex and the other three) step in with boons: +2 max HP each plus a Path buff. That's a lovely payoff for freeing the zones, and the pre-fight panel lists everything clearly, including Royal Guard and Out of Alignment.
- **Phase 1, Standardization:** "Every unit, yours and his, is a 3/3. You may play at most two non-infrastructure cards a turn." A strong, readable rule, with a Primm's Rule panel on screen (`r15_12_p1`). After 10 turns of pilot play Primm was still at **44** and I was at 11. His Royal Audit ("Shred target unit or Wonder") on my best unit felt boss-like. I forced the win with `dev win`.
- **Phase transition:** about 35 s from Continue to the Phase 2 board. Primm's line ("Why... why will they not all be three? It is a perfectly good number.") is good, but it plays over **two flat placeholder icons**, a crowned-beard glyph and a wizard hat (`r15_16_ph3`), instead of portraits. That's a jarring drop after the painted intro.
- **Phase 2, Reflection:** a strong boss card (`r15_E08`): Primm next to a cracked mirror showing Tessar, 42 HP, "His deck is a copy..." rule.
- Phase 3 and the ending: not reached, see section 5.

### 5. Phase 3 and the ending: NOT REACHED
I ran out of time before Phase 3, the ending and the credits. In r16, forcing Phase 1 with `dev win` and clicking through, the Phase 1 > 2 transition took **about 70 seconds** from "Continue" to the Phase 2 opening hand (play.log 83.0 s to 155.7 s). The transition's dialogue box isn't the kind `skip_dialogue` detects, so it needed manual clicks, and the run ended on Phase 2's mulligan screen. So I **can't score the ending's writing**. My story score (7) rests on the castle gate, the Freed Leaders and Primm's intro and transition lines, all of which are strong. The developer should do a dedicated pass on Phase 3 and the ending, using Esc > Skip on the intro's last line (problem 1).

### 6. Side dungeon (S-CAP / S-PASTE): skipped (time).

### Audio and performance
- Audio: can't be judged from screenshots and logs.
- Performance: snapshot loads took 7-16 s; `dev travel capital` and `dev travel dungeon` took about 10-11 s; the Primm Phase 1 > 2 transition took 35-70 s, which is too long for something you see on every retry; no SCRIPT ERROR in any run's stdout.log. Enemy turns resolve quickly (about 4 s).

## Top 15 problems (ranked by impact on late-game enjoyment and retention)

1. **The Primm intro soft-locks on its last line.** Where: `r12_16`, `r11_i06`. Why: it's the climax of the game, and click, Space and E (the keys the box itself names) do nothing, so a player who doesn't think of Esc can't fight the final boss. Fix: make the last line advance on click, Space or E like the others, and add a timeout fallback that starts the battle; add an automated test that steps through every boss intro with E only.
2. **No clear route to the Capital.** Where: `r1_02_questlog`, `r1_04_whereto`, `r2_05_map_after`. Why: the final act starts with the player wandering Crosspath. Fix: add a quest step "Go down to the Undercroft under Crosspath" with a map goal ring and world pointer on the Undercroft; call it "The Undercroft (to the Capital)" in "Where to?"; give it a fast-travel option once it's been found.
3. **"Free the Four Zones" stays the active quest title and goal label after all four are freed.** Where: `r1_02_questlog`, `r3_04_map`. Why: the HUD and map tell you you're still on the old goal. Fix: complete that quest when the fourth zone falls, start "Storm the Capital", and update the goal ring and legend.
4. **"Broken services 0 of 4" on the overworld vs "4 of 4" in battle.** Where: `r3_02_services` vs `r15_12_p1`. Why: the Capital's central mechanic (the freed zones weakening Primm) is invisible or contradictory. Fix: one counter, worded from the player's side ("Primm's stolen services cut off: 4/4"), with each line ticked off and showing what it does to the Capital or to Primm.
5. **Invisible HP drain in the Capital.** Where: `r4_08_n2`, `r5_02_spot2`. Why: losing 6 of 18 HP walking up the main road, with no healing, before any fight. Fix: show the hazard (marked tiles, or a patrolling enemy you can see), name it in the toast ("Inspection Spotlight: -2 HP"), and let the Crease heal you.
6. **The lieutenant and Primm Phase 1 outlast the built-in player, and the fights drag.** Where: `r7_08_end` (Quota still at 26/26), `r15_12_p1` (Primm 44 after 10 turns). Why: if an automated player that plays its cards can't scratch them, many real players will bounce off the finale. Fix: tune Quota's HP and deck down, cap Phase 1 at about 30 HP or let Out of Alignment trigger sooner, and run the balance sweeps against the actual `lategame_real` deck.
7. **Late-game hands flooded with basic infrastructure.** Where: `r10_03_result` (five Powerhouses in hand, turn 4), `r6_09_myturn2`. Why: dead draws in the most important fights. Fix: cap the basic infrastructure count the deck builder auto-adds, show the infra/other split in the Deck Station, and suggest about 16/40.
8. **The final dungeon is too long for one non-healing HP bar.** Where: `r9_20_map`. Why: 22 nodes plus the HP drain before it means a likely forced retreat, followed by a long redo. Fix: shorten the critical path to about 8-10 nodes with the wings as optional, make the Resistance Safe Room a guaranteed heal, and add a checkpoint before the Royal Stair.
9. **Narration labelled with Primm's name; the boss info card hidden under the story box.** Where: `r11_i02`. Why: it confuses who is speaking and hides the boss rules at the moment they matter. Fix: no name tag for narration lines; play the story first, then show the info card, or move the card above the dialogue layer.
10. **Placeholder icons in the phase transition.** Where: `r15_16_ph3`. Why: the drop from painted portraits to flat glyphs at the dramatic peak. Fix: reuse the Primm and Tessar portraits from the intro or the boss card.
11. **Three dialogue styles, three sets of advance and skip keys.** Where: `r8_01_pc_enter` ("E / Click to close - Esc: skip"), `r11_i02` ("E / Click to continue"), `r11_i06` ("Click / Space to continue - Esc: skip"), `r15_E08` ("Any key to skip"). Why: Esc either skips the scene or opens the pause menu over it (`r14_L1`). Fix: one dialogue component in which E, Space, click and Enter always advance and Esc always means "skip scene?", and block the pause menu while a story box is open.
12. **The Capital's look on arrival.** Where: `r4_01_loaded`, `r3_13_walk`. Why: a flat grey plain with dead trees under a heavy wash is the first impression of the "perfect" Capital. Fix: lighten the filter, lead with the pastel Palace Approach style from the start, add sky, scenery and signposts toward the castle.
13. **Map problems.** The map wouldn't close with Esc while a tooltip was showing (`r3_04_map` to `r3_13_walk`, the whole rest of that run). The Capital map is almost all dark, and arriving by jump reveals nothing. Fix: Esc and M always close the map; reveal the main avenue and the castle on arrival in the Capital, since the Rescuer's people would know it.
14. **Talk prompts that do nothing, and overlapping labels.** Where: Captain Spotless, `r4_08_n2` (name tag over the bark) and `r5_02_spot2` (E opened no dialogue). Fix: put the name tag above the bark; if an NPC only barks, don't show "[E] Talk", or give every NPC with a talk prompt at least one line.
15. **Defeat text and board leftovers.** "You are carried out of the dungeon" after an overworld lieutenant fight, and the "Needs 4 energy" hint left on screen behind the result card (`r7_08_end`). Quota's plain navy board compared with the painted castle boards (`r6_09_myturn2`). Fix: wording per context ("You limp back to the Crease"), clear the hints on battle end, and give the Capital fights a backdrop.
