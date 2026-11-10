# The Wayward Path v1.0.0-rc1 - critic report (new-player playthrough of the exported build)

Screenshots cited below are in `docs/review/critic_rc1/shots/` (same names as in `_screenshots/exported/`; stored as .jpg in the repo to keep it small).
Play scripts: `docs/review/play_scripts/critic_rc1_r1.txt` ... `critic_rc1_r34.txt`.

## 1. Summary

The first hour of The Wayward Path looks far better than most indie card RPGs: the title painting, the opening stills, the
cave node map and every card frame are consistently handsome, the UI chrome (Settings, Credits, slots, Deck Station,
Wardrobe, Feats) is finished and readable, and the writing in the prologue and with Elder Maren is confident and funny
without being try-hard. The problems are all in the seams between those painted pieces: the 3D forest you actually walk
through is murky and the cave entrance trigger is easy to miss, the first fights drag (a 3-HP Cave Scavenger took 8-11
rounds every time because both decks flood with infrastructure), the Crosspath square still contains flat white untextured
3D blocks right next to painted buildings, and the Gainlands zone switches to a low-poly toy-kit look that does not match
the painted forest, cave, town or stills. Nothing blocked progress and no `SCRIPT ERROR` appeared in any of the 34 game
logs, but a new player will hit three or four "is this finished?" moments in the first 40 minutes.

**How I played.** 34 scripted runs of 1-5 minutes each through `tools/play_exported.sh` (about 80 minutes of game wall
clock, plus reading screenshots). Runs r1-r33 were a straight first hour with no jumps: title, Settings, Credits, New Game,
the whole opening read line by line, the Path choice (Beefcake, after reading "More" on Beefcake), the forest walk, the
Forgotten Cave (all five nodes; node 1 played by hand with clicks in r12/r14, the rest and the Hollow Warden boss with
`pilot`), arrival in Crosspath, Elder Maren, every menu (C/J/P/T/B, Glossary, Feats, map, Where to?), Foil Fenwick's
pack stall, Tilly Tonic's shop and the Power Wraps errand. Run r34 was the only jump: `dev travel zone beefcake`
(the Gainlands) and `dev travel dungeon D-HOG` / `D-HOG -2` to look at a Path zone and a main dungeon's node map and rules.
Several runs (r4-r9) were spent just finding the cave entrance; that is itself a finding (problem 1).

## 2. Scores

- **First impressions: 8/10.** Title screen, slot picker, Settings and Credits are polished (r1_01_title, r1_02_slots,
  r1_01b_settings, r1_01c_credits); the opening stills and portrait dialogue are the best-looking part of the game
  (r1_03_opening, r1_04_open, r1_14_open). It loses points when the camera pulls back to the actual 3D forest, which is
  dark, blurry and shows a tiny hero (r2_16_after, r3_04_walk1), and for the Path choice cards being unreadable thumbnails
  until you press More (r1_20_open, r2_04_more_beefcake).
- **Clarity: 6/10.** Menus, the quest HUD, card text, the node map and the "Rules of this fight" panel explain themselves
  well (r3_02_deck, r22_02_quests, r34_11_hog_rules). But the most important instruction of the first ten minutes, "go
  through the glowing arch", is undermined by a cave trigger that only fires on a small ring beside the stairs, so I
  stood under the arch with no prompt (r8_04); the "End your turn?" nag fires while you are choosing attackers (r12_14);
  "Where to?" on the map sets a goal rather than travelling (r24_02_whereto); and Escape does not close a shop
  (r31_08_hover -> r31_09_sable).
- **Fun: 6/10.** The card game itself is sound and the boss intro, hidden trait and level-up cadence are satisfying
  (r18_02_boss_a, r18_05_boss_d, r18_11_after). The first three fights are too slow for an opening: a 3-HP enemy survived
  8-11 rounds in four separate attempts because 19 of 45 starting cards are Powerhouse and the enemy deck plays
  Feastforge after Feastforge (r14_07_end1, r15_01_end1), and I lost 11 of 15 HP to that 3-HP enemy once (r14_09_after_reward1).
- **Polish: 6/10.** The 2D screens are 9/10. The 3D spaces are not: white untextured blocks in Crosspath's square next to
  painted houses (r29_01, r29_00_load), townsfolk bark bubbles printed over their own name labels (r24_01_square), a
  pitch-dark forest (r3_04_walk1), and a Gainlands zone built from flat low-poly kit pieces that clash with everything
  painted (r34_01_gainlands).
- **Unfinished / AI-made look:** Highly visible in two places a new player will stand in for minutes: the white 3D
  fountain/plinth blocks in the Crosspath square (r29_01) and the low-poly orange Gainlands (r34_01_gainlands). The
  painted art is obviously AI-generated (Credits say so plainly, r1_01c_credits) but it is consistent in style and does not
  read as placeholder. No template text or overflowing boxes were seen in 34 runs; the writing never reads as boilerplate.

## 3. Top 10 problems (most important first)

1. **The cave entrance trigger is easy to miss; the forest can feel like a soft-lock.** Walking straight up to the glowing
   arch (the quest goal, yellow marker on it) gives no prompt (r8_04); only standing on a small glowing ring to the
   front-left of the stairs shows "[E] Enter the cave" (r9_01_cave_enter). Meanwhile every other direction answers with
   "No point getting lost twice in one day. I'll head back up the path to the glowing arch." (r5_04_w) or "The trees are
   packed too tight" (r3_07_walk4). It took me five runs (r4-r9) to get in. Severity: **major** (first 10 minutes).
   Smallest fix: make the arch's whole doorway and the bottom step part of the interaction area, and show the "[E] Enter
   the cave" prompt as soon as the hero is within ~3 m of the arch.

2. **First fights are long and dull.** Cave Scavenger has 3 HP yet every attempt lasted 8-11 rounds (r14_07_end1,
   r15_01_end1, r14_09_after_reward1 "You defeated Cave Scavenger in 11 rounds"). Both tables fill with infrastructure
   (seven Powerhouses, ten Feastforges), the enemy chump-blocks with Courier Pigeons, and I dropped to 4/15 HP against it
   once. The Hollow Stalker and Hollow Warden also went 8-10 rounds (r17_02_node3, r18_09_boss_end). Severity: **major**
   (fun). Smallest fix: cut the starting deck's infrastructure from 19 to about 14 of 40 (or give the first two cave
   enemies fewer infrastructure and more 1-2 cost units) so the first fight ends in 4-5 rounds.

3. **White untextured 3D blocks in Crosspath's square.** The fountain/plinth group in the middle of the square is flat
   white boxes and cylinders with no texture, right beside painted half-timbered houses and painted NPCs (r29_01 shows it
   filling the right half of the screen during Tilly's intro; r29_00_load, r24_01_square from the other side). This is the
   single most "unfinished" thing a new player sees, and they see it for the whole Settle-in quest chain. Severity:
   **major** (polish / trust). Smallest fix: swap the fountain and plinths for the painted fountain sprite used elsewhere,
   or at least give them a stone texture matching the cobbles.

4. **The 3D forest is too dark and the hero is tiny.** After the vivid stills, the playable forest is near-black with heavy
   tilt-shift blur (r2_16_after, r3_04_walk1, r5_04_w); the hero sprite is about 60 px tall and the only readable thing
   is the yellow goal marker. Severity: **major** (first impressions). Smallest fix: raise the forest's ambient light /
   exposure by about 30 percent, pull the camera in one zoom step for the starting area, and lower the depth-of-field strength.

5. **Gainlands zone art does not match the rest of the game.** The Path zone (reached by `dev travel zone beefcake`, so a
   jump) is low-poly kit geometry in flat orange/teal with painted sprites standing in it (r34_01_gainlands); the cave,
   town and dungeon maps are fully painted (r9_04, r34_12_hog_near_boss). Two steps in, a fight starts with no intro
   dialogue, only a toast "Quota Spotter wants a word..." (r34_02 -> r34_03). Severity: **major** (polish; this is the
   first zone most players will pick). Smallest fix: run the painted-texture pass that the town already has over the
   Gainlands ground and walls, and give the gatekeeper one spoken line before the fight starts.

6. **"End your turn?" nag fires while choosing attackers.** With one attacker selected in the Combat phase, pressing End
   Turn opens "End your turn? You can still play 1 card this turn." (r12_14). It is the wrong question at that moment (the
   player wants to know the attack will be cancelled), and the built-in pilot could not get past it in r12. Severity:
   **minor**. Smallest fix: do not show the nag during attacker selection, or change its text to "You have 1 attacker
   selected - end the turn without attacking?".

7. **Escape does not close a shop.** In Tilly Tonic's Supplies, Escape left the shop open and nothing else responded
   (r31_08_hover, then r31_09_sable after Escape and three more key presses); only the small X at top right closes it.
   Every other full-screen page (Character, Packs, Wardrobe, Deck Station) closes on Escape. Severity: **minor**.
   Smallest fix: bind Escape to the shop's Close button.

8. **"Where to?" on the map sets a goal instead of going there.** The list under the town map is labelled "Where to?" and
   lists every vendor, challenger and exit (r24_02_whereto); picking one just recolours the button to the chosen name and
   moves the goal marker; the map stays open and the hero does not move. Severity: **minor** (clarity). Smallest fix:
   rename the control "Track a place" (or "Set goal") and close the map after a pick, or actually fast-travel.

9. **Townsfolk bark bubbles print over their own name label.** In the square the speech bubble "The well hummed at me..."
   sits on top of the TOWNSFOLK label (r24_01_square, r29_00_load). Severity: **minor**. Smallest fix: offset the bubble
   one label height upward or hide the name label while a bark is showing.

10. **Path choice cards are unreadable until "More".** The four Path columns show three card thumbnails at about
    75 x 110 px whose text cannot be read (r1_20_open), and the Begin button is grey with "Pick a Path first" before any
    column is selected; the useful explanation only appears after clicking a column and then More
    (r2_04_more_beefcake). Severity: **minor** (first impressions). Smallest fix: show the one-line "how it plays" text
    and the Resource line for the hovered Path by default, and let hovering a thumbnail show the full card.

## 4. Smaller notes

- **SCRIPT ERROR:** none in any `play_rc1r*.log` (34 runs). Every run's game log ends with the usual Godot exit noise
  (leaked RIDs, "resources still in use at exit", "Parameter RenderingServer::get_singleton() is null") - 34 of 34 runs,
  so the game is not cleaning up on quit, but a player will not see it.
- First-duel onboarding stacks two popups at once: "Your first duel ... Got it / Skip tips" and "Opening hand ... Keep
  Hand / Mulligan" are both on screen in r10_03_node1; then "Play an Infrastructure" appears over the hand. Consider
  sequencing them.
- Pressing Escape while an NPC dialogue is open opens the pause menu on top of the dialogue instead of closing the line
  (r21_11, then the Paused dump in the r21 log).
- Two hidden chests sit on the way to the cave and pay 40 and 15 gold with the caption "pocket money" (r3_07_walk4 area);
  nice touch, but the second chest is 2 m from the cave ring and I triggered it when trying to enter the cave.
- The dump of several town loads (r23, r24, r28, r29) lists a stray label at the top-left containing glyph strings such as
  `6789 .,:;!?'`, `jklmnopqrstu` and `"()-+/%&` for the first frame after load. I could not see it in the PNGs, so it may
  be an off-screen font warm-up label; worth a look in case it flashes on slower machines.
- After the Hollow Warden the Level Up screen (two levels at once) appears on top of the still-open card reward
  (r18_11_after shows both in the dump); the order works but the reward's "Take Late-ish Courier" button is hidden until
  the level-up is dismissed.
- The Hollow Well node says "Your deck: about 69 % to pass" and greys "You're at full HP" (r16_02_node2) - clear and good.
- The boss pre-fight panel says "Hover an icon for its text; the same icons stay on screen during the fight" and "Hidden
  trait ?" (r18_05_boss_d); the rule icons did appear under the portrait during the fight (r18_09_boss_end). Promise kept.
- The HUD bottom line changes from "WASD / arrows: move  E / Space / Click: interact  Esc: menu" in the forest to a
  version with "M: map" in town; M also works in the forest (r2_17_map), so the forest line could mention it.
- The forest minimap is a blocky pixel mask (r2_16_after top right) that looks rougher than the circular frame around it.
- Credits state the paintings were generated with an image model and the score was written "with AI assistance"
  (r1_01c_credits): honest and clearly worded.
- Tilly Tonic's "I'm teal today... I'm green again... I'm turning yellow!" running gag and Foil Fenwick's "Do you want to
  smell one? Just a sniff." are the kind of voice that keeps the shops from feeling like menus (r29_01, r27_08).
- Maren's second talk ends on "...you're in no state to argue with any of them. Settle in first" (r21_11); the HUD quest
  line "Settle in: Say hello to Tilly Tonic at her supply shop" matches it exactly. Good.
- The Gainlands HUD shows "Zone HP: no healing after battles." as a persistent banner with zone-effect icons at the left
  (r34_01_gainlands); it is the clearest rule reminder in the game and could be reused in dungeons.
- Jumped content (r34): the House of Gains node map is one of the best screens in the build (r34_12_hog_near_boss) and its
  Rules panel is readable (r34_11_hog_rules); "Out of Breath" is a Necrocrat-specific rule shown to a Beefcake player, which
  is fine but reads as noise for a first visit.

## 5. What worked (keep exactly as is)

1. The opening: the wake-up still, the masked Rescuer, "Ugh... where am I? And while I'm asking, who am I", and the hand
   that lights up with four colours (r1_03_opening, r1_04_open, r1_10_open, r1_14_open). It is short, funny and sets up the
   Paths without a lecture.
2. The Forgotten Cave node map and the Hollow Warden reveal: painted map, question-mark nodes that resolve into named
   places, and the Warden's portrait filling the left third as he speaks (r9_04, r18_02_boss_a).
3. The Deck Station and Character pages: filters, copy caps with coloured ticks, the "Suggest a deck" and "Fill
   Infrastructure" buttons, the locked slots that say which level opens them (r3_02_deck, r22_01_character).
4. Battle readability: the hovered-card zoom, the "-1 HP if unblocked" arrow when choosing attackers, the Just Arrived
   tooltip, the phase list on the right, and the Speed button (r12_04_played_unit, r12_13_attack, r14_04_after_spell).
5. The shopkeepers' voices and portraits: Tilly Tonic, Foil Fenwick and Elder Maren each have a distinct register and a
   portrait that matches it (r29_01, r27_08, r21_05_maren), and the pause menu's Report a Problem / Open feedback folder
   entries make the RC feel supported (r1_01_title bottom line, pause menu).
