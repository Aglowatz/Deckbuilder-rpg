# Critic report, sitting 4 (Nov 16): what the first three sittings missed, release build

## 1. How I played

16 runs of 16 used, about 60 minutes. Scripts: `docs/review/play_scripts/s4_01.txt` to `s4_16.txt`. All shots are in `_screenshots/exported/`.

| Run | What it did | Result |
|---|---|---|
| 01 | `dev load s1_a`, `dev travel dungeon D-TUT -2`, cave map | Seen |
| 02 | Clicked the boss room, read the Warden's 3 opening lines and the "Before the boss" card | My script had no fight (wrong button name) |
| 03 | Whole Warden fight by `pilot` (won in 8 turns, 14/15 HP), result and reward screens | Stuck on the card pick: E does nothing there |
| 04 | Same fight ended with `dev win` (jump), card pick, level-ups, Warden's closing words, "Step outside", all of Maren's first talk. `dev save s4_cave` | Seen |
| 05 | `dev load s4_cave`: quest log (J), map (M), "Point me to..." | Seen |
| 06 | Picked the Tilly goal, walked, ended at the gear vendor Bertram (locked) | Seen, not the shop I aimed for |
| 07 | `dev load midgame_real`, `dev travel town`, `dev freed beefcake`: walked into Foil Fenwick's pack shop | One shop page seen |
| 08 | Walk to Maren overshot her | Wasted |
| 09 | Maren: ordinary lines, Well quest, then `dev freed gourmand`: Fragment 3 and her confession | Seen |
| 10 | Four `dev freed` in a row, hero did not move for 10 s | Wasted (see finding 9) |
| 11 | `dev freed gourmand` + `refusemancer`: Fragment 3 again, Fragment 4, the whole reveal talk | Seen |
| 12, 13 | `dev load c13castle`, `dev primm 1`, Primm's opening | 12 wasted (boss room not clicked); 13 read the opening, never reached the fight (opening is about 27 taps) |
| 14 | Opening skipped, "Before the boss" card, `dev lose` on turn 2, "Fight Primm again" clicked, then `dev autowin on` + `dev win`: phases 1 to 3 | Seen |
| 15 | `dev lose` during the opening hand: defeat panel shot, then E on it | Left the castle to the Crease (see finding 1) |
| 16 | `dev autowin on` from the start: phase 3 victory, reward, ending from "The model lies in pieces" to "File Complete" | Ending cut by the 170 s limit |

**Not reached:** the rest of the ending after "File Complete", the credits and their logo, anything after the credits. Fragments 1 and 2 (the `midgame_real` snapshot had them done). Tilly's and Sable's shops. No turn was played by hand: all three tries at drags landed on the opening-hand (mulligan) panel. The Character page (C) was never opened. I did not see a walk from the cave to town: "Step outside" put the hero in Crosspath next to Maren.

## 2. Scores

- **Clarity 7/10.** Goals, the quest log, the "Before the boss" card and the defeat panel all say plainly what to do next and what is at stake. It loses points for pop-ups that land on top of each other and for small contradictions about where Maren is and what her stick shows.
- **Fun 7/10.** The writing is the best part: the Warden's goodbye, Maren's confession, Primm's "I only wanted it to be nice" and the "sorry about the hats" exit all land. I only watched the pilot play one fight, so this score is mostly for story and pacing, not for card play.
- **Polish 6/10.** The pictures are lovely and the four Path icons were right on every crest, pack and banner I saw. But text sits over faces in the memory pictures, toasts overlap story beats, two dialogue box styles alternate in the same scene, and roofs hide the most important conversation in the game.

## 3. Findings

| # | What | Where | Kind | Size | Smallest fix |
|---|---|---|---|---|---|
| 1 | On the Primm defeat panel "Fight Primm again" is the gold, highlighted button, but one tap of E (my script also sent `1`) took "Leave the castle": the hero woke in the Crease and the castle reset. A player tapping E through pop-ups loses the retry. | `s4_end_00.png` (panel), `s4_end_01.png` (the Crease); `play_s4_15_play.log` 91.7 to 100.2 | broken | S | Make E / Enter / Space press the highlighted button, or ignore keys on this panel for a second |
| 2 | The defeat panel can be very late. In run 15, 4.3 s after the loss only the DEFEAT banner was up and there was no button; the panel was there at +24 s. In run 14 the button was there at +3.5 s. | `s4_15_02_defeat.png`, `play_s4_15_play.log` 67.2 to 71.6 | broken | S | Show the panel straight after the banner |
| 3 | Maren says the crest's four signs are "the same as the ones carved on this stick of mine", but her portrait's stick shows a sun, a sprig, a crescent moon and a drop. | `s4_11_20.png` (stick, right portrait), `play_s4_11_play.log` 116.1 | wrong icon | L (repaint the stick) or S (cut the line) | Repaint the four carvings as arm, chef's hat, leaf, skull |
| 4 | Memory picture text is laid over the middle of the painting: it covers the king, queen and boy, and earlier lines dim to near unreadable. | `s4_09_24.png`, `s4_09_27.png`, `s4_11_13.png` | ugly | M | Put the text in a band at the bottom, as the ending's caption box does |
| 5 | Roofs fill the screen while talking to Maren at her home: a thatched roof covers the right 40 %, a slate roof the left, and the hero and Maren are tiny in the gap. This is where all four memory talks happen. | `s4_04_08.png`, `s4_09_29.png`, `s4_11_20.png` | ugly | M | Fade the near roofs or pull the camera in at this spot |
| 6 | Toasts stack on top of each other and on story pictures: on arrival "New quest", a Feat toast and the Crosspath title card overlap; "Quest updated" sits on both memory pictures; "Quest complete" and a Feat toast overlap on the ending's first picture. | `s4_04_29.png`, `s4_09_24.png`, `s4_11_10.png`, `s4_end_48.png` | ugly | S | Queue toasts, and hold them while a picture scene is open |
| 7 | Fragment 4 text says "a coat too fine for the cold", but the boy wears the Wanderer's ragged grey cloak. A large iron dumbbell lies in the foreground (the brief lists a dumbbell as a wrong Beefcake sign). | `s4_11_10.png` | story / wrong icon | L (art) or S (text) | Change the line to match the cloak; paint the dumbbell out |
| 8 | "The Pathwork Throne" shows "a stair of four colours" as red, blue, purple and green, which are not the four Path colours used elsewhere. The hero wears a yellow shirt and teal cloak here, and a grey cloak and white shirt in the next pictures. | `s4_end_50.png` against `s4_end_62.png` | story / ugly | L | Recolour to the four Path colours and the usual outfit |
| 9 | After four `dev freed` commands the hero ignored 6 s of movement keys with nothing visible on screen blocking him. A debug-only path, but the game took input away without showing why. | `play_s4_10_play.log` 48.2 to 54.0, `s4_10_00.png` | broken | S | Worth one check that a hidden pop-up is not holding input |
| 10 | The ending says the same beat twice on the same picture in two box styles: three plain lines in the navy box ("the leaders of the four Paths clasp hands"), then the purple caption box "The Paths Meet" says it again. | `s4_end_62.png`, `s4_end_64.png` | ugly | S | Drop one, or use one box style for the whole ending |
| 11 | "Four banners fly from the same pole" is shown over a picture of four banners on four poles. | `s4_end_62.png` | story | S | "Four banners fly side by side" |
| 12 | Where Maren is: she says "Come and find me on the square", the quest log says "Elder Maren's home, up the Gate Road from Crosspath's square", and she stands at her home. Her first line also says "nobody has come out of this cave in ten years" while standing in town. | `play_s4_04_play.log` 73.1 and 115.2, `s4_05_02_quests.png` | story / confusing | S | "Come and find me at home" and "that cave" |
| 13 | The cave's exit caption "The Refusemancer deck is yours. The road to town is open." stays on screen through the whole talk with Maren, in town, for about 50 s. | `play_s4_04_play.log` 70.0 to 120.7 | confusing | S | Clear it when the town loads |
| 14 | After Fragment 4 the hero says "I can hear her voice now, and I still can't see her face", right after a picture that shows the queen's face clearly. | `s4_11_10.png`, `s4_11_20.png` | story | S | Turn the queen away in the picture, or cut the line |
| 15 | Maren, after Fragment 3: "now you're holding it, the same way I have been holding yours." It reads as if she already knows his secret, one memory early. | `play_s4_11_play.log` 83.1 | story | S | "the same way I have been holding your memories" |
| 16 | On the reward screen "AT CAP: becomes essence" under the first card runs into the hint line "Click a card to choose it...". | `s4_03_09.png` | ugly | S | Move the cap note inside the card frame |
| 17 | The boss is "The Hollow Warden" on the name plate and "Hollow Warden" elsewhere, and the fight intro prints the name twice (title and subtitle). | `s4_02_01_bosspop.png`, `s4_02_08.png` | ugly | S | One name; give the subtitle a title ("Keeper of the door") |
| 18 | Bertram first says "you may approach" and describes his rack for four lines, then "Halt... referral only". | `play_s4_06_play.log` 51.5 to 65.4 | confusing | S | Start with the Halt lines while he is locked |
| 19 | With "Point me to..." open, the list covers the map and cuts labels ("Elder Maren", "Deck Station"). In the square the goal label sits on top of the well and the arrow. | `s4_05_04_point.png`, `s4_06_02_route.png` | ugly | S | Open the list over the legend; lift the goal label |
| 20 | In the Crease, "Back at the respawn point with full HP..." wraps to a second line hidden behind the dialogue name plate. After Primm's painted opening the scene drops to the dungeon map for the Freed Leaders' narration, in a different box. | `s4_end_01.png`, `s4_13_08_pop.png` against `s4_13_04.png` | ugly | S / M | Raise the caption; keep the leaders' lines on the Model Room picture |

## 4. Checked and fine

- **Cave Warden's closing words:** right. In the dialogue box with his picture: "...The door knows your hand... Pass, and may the Paths guide you home.", then a narration line (`s4_04_04.png`). His name in game is "the Hollow Warden", not "Cave Warden".
- **Maren's eyes and what she knows:** right. "Come closer, dearie; my eyes aren't what they were", "I still can't make you out", "With my eyes I couldn't say". She does not know him until Fragment 4 ("I didn't know you. My eyes have been going for years"). Only doubt: finding 15.
- **Bars of the cell:** right in text ("those rooms of yours with bars on every side", "I never forged a bar of them"). "Primm Sees" shows a barred door, no glass (`s4_end_56.png`). I saw no picture of the cell itself.
- **The name Tessar:** right. First appears in Fragment 4's first line; the name plate reads "The Wanderer" before and "Tessar" after (`s4_11_20.png`). In Primm's lines I read, nobody says it early.
- **Crest in the third and fourth memory pictures:** right. Arm top, chef's hat right, leaf in arrows bottom, skull left, on the banner, the king's chest and the door (`s4_09_27.png`, `s4_11_10.png`).
- **Banners in the ending's pictures:** right in the two I reached (`s4_end_62.png`, `s4_end_66.png`): arm on red, chef's hat, leaf in recycling arrows, skull in green flame. Pack art at Fenwick's is right too (`s4_07_05.png`).
- **Credits' logo:** not reached.
- **"Fight Primm again":** shown, with "Leave the castle" and a clear explanation of both (`s4_end_00.png`). It is the highlighted button. Clicked, it restarted Phase 1 at Turn 1 with full HP and no replay of the opening (`s4_14_07_again.png`). E did not choose it (finding 1).
- **Full map and its short names:** the town map is crisp and the names are short and readable (`s4_05_04_point.png`). Zone and Capital maps not opened.
- **C closing the Character page:** not checked.

## 5. SCRIPT ERROR lines

None. `grep "SCRIPT ERROR"` gives 0 for every one of `play_s4_01.log` to `play_s4_16.log`. The only ERROR lines are Godot's resource-leak notices at exit.

## 6. What worked (keep exactly as is)

1. **The Fragment 4 reveal talk.** "So that we are never far from home", Maren's "Forgive me", and Tessar's "You also gave me a bed and a pie when you still thought I might be a spy. I know which of those I'm keeping." The name plate changing to "Tessar" at that moment is the right touch.
2. **Primm's fall.** "Why will they not all be three?", "I only wanted it to be nice", "Take the crown. No: leave it. No: take it." and the Feat "Sorry About the Hats". The "Before the boss" card listing every rule and the four leaders' boons is clear.
3. **The Path icons in the big pictures and the shop.** The crest ring, the ending banners and Fenwick's packs all use the one right icon per Path. Fenwick's shop page (`s4_07_05.png`) is the best-looking screen I saw.
