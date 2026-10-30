# The Wayward Path - fresh-eyes second look (Oct 30, v0.4.8)

Critic / UX researcher, second look. I had not seen the game before and read nothing but the two briefs. Everything below comes from my
own scripted runs (`docs/review/play_scripts/critic2_*.txt`, output in `_screenshots/play/critic2_01` ... `critic2_13`). Cited
screenshots are copied into `docs/review/fresh_eyes_second_look_oct30/` as `<run>_<shot>.png`.

## Summary

The first 30 minutes on the Gourmand Path now hold together. The opening is handsome and short enough, the Path choice screen sells
each Path in one line plus three cards, the cave is signposted in the world, on the minimap and on the map, and the first duel explains
itself: unaffordable cards and the one-Infrastructure rule both get a plain sentence, the reward screen pre-selects a card and glosses
its keywords, the Hollow Well says exactly why you passed, the shrine says what it restores, and the town's Menu button reaches the
Glossary and the Feats. Of the ten questions, eight landed outright, two partly (the cave's Rules panel still has no copy-cap line, and
one of the two "card cannot be played" messages can be hidden behind the card's own tooltip). The one new problem worth fixing before
anything else: several confirmation popups (the cave's "Go in?", the Well's "Reveal" / "Continue", the duel's "Got it" tips) ignore the
E key that the HUD advertises as "interact", so a keyboard player who has been pressing E for ten minutes suddenly has to find the
mouse. The pause menu (Esc) worked everywhere I tried it, including mid-dialogue.

## How I played

| Run | What | Result |
|---|---|---|
| critic2_01 | Title, New Game, opening read line by line | Opening is ~35 lines; my Esc opened the pause menu mid-dialogue (works) |
| critic2_02 | Opening again, all lines, Path choice (More / Begin), post-choice lines, save | Gourmand chosen; `c2_forest_start` saved |
| critic2_03 | Deck Station (B) + Esc, map (M, M), walk NE with `hold` | Esc closes the deck; M toggles the map; hit the "trees close up" barrier |
| critic2_04 | Deck Station X button, map X button, walk again | Both X buttons close cleanly; reached "[E] Enter the cave" in ~12 s |
| critic2_05 / 06 / 07 | Enter the cave with E | "Go in?" popup ignores E (6 taps); snapshots do not restore the popup or the dungeon map |
| critic2_08 | `dev travel dungeon D-TUT`, Rules (R), Esc | Cave map, rules text, pause |
| critic2_09 | (wasted: `dev load` restores the forest, not the cave) | - |
| critic2_10 | Node hovers, first duel with `pilot` in 6 s slices, Victory popup | Pilot won in 7 turns (~45 s) |
| critic2_11 | First duel by hand: Infrastructure, second Infrastructure, unaffordable card, Space phases, `dev win`, reward hovers | Messages, banners, reward screen |
| critic2_12 | Reward taken, Hollow Well opened, town Menu, Character (C), Glossary, Feats, Esc | Well needs a click; Menu lists everything |
| critic2_13 | Hollow Well Reveal and result | "The well answers. 2 of the 5 cards were Infrastructure; 2 were needed." |

About 75 minutes of wall clock, 13 runs, no `SCRIPT ERROR` in any `stdout.log`.

## Part A - the first 30 minutes on the Gourmand Path

Scored against Slay the Spire / Inscryption / Monster Train / Sea of Stars / Octopath / Pokemon TCG Pocket, not against an earlier
build.

| Area | Score | Note |
|---|---|---|
| First five minutes' hook | 7 | Gorgeous title and wake-up still (`critic2_01_01_title`, `critic2_02_16_line`); the Rescuer's lines are good ("Hands like ice, pulse like a rabbit's. We'll fix that later."), but 35 taps of text before any choice is long by Inscryption's standard |
| Clarity | 7 | Path screen (`critic2_02_41_gourmand_selected`), duel tips, "Needs 3 energy; you have 1", reward keyword glosses, Well explanation: a new player always knows why. Lost a point for the "More" button (below) and the cave Rules panel |
| Pacing and friction | 6 | Cave reachable in ~12 s on foot, but two "trees close up" dialogue boxes freeze movement until dismissed, the "Go in?" popup wants a click, and the duel's tips each want a click on "Got it" |
| Combat feel | 7 | Phases are explicit (To Combat / End Turn with an "End your turn? You have 1 energy left" guard), tooltips on every keyword, "Cave Scavenger plays Feastforge" callouts; the first duel is a soft 3-HP punching bag, which is right for a tutorial |
| Reward rhythm | 7 | +40 gold, +15 XP, three-card pick with a default already chosen and its keywords explained (`critic2_11_22_reward`); feat toast "Leaves in Your Hair - Menu > Feats" right after the Path choice |
| Visual readability | 7 | The cave map, battle board and reward screen read cleanly; the forest is very dark (`critic2_02_60_forest_free`) and the cave-mouth marker is a small yellow triangle in a dim scene |
| UI/UX consistency | 6 | X buttons, Esc and hotkeys all close what they open; but the E key is "interact" everywhere except on confirmation popups, and tooltips can cover the floating rule message |
| Bugs | 8 | Nothing broke. One z-order issue (VICTORY! drawn under a hover tooltip and the enemy units at 0.4 s, `critic2_11_20_victory_banner`) and the "More" button that only renames itself |

Findings:

1. **"More" does nothing visible.** On the Path screen, after clicking Gourmand, pressing More turns the button into "Less" and the
   description does not change (`critic2_02_41_gourmand_selected` vs `critic2_02_42_gourmand_more`). The hint says "Point at a Path (or
   press More) to read how it plays", and the two-line blurb is already shown when a Path is selected, so a player presses More and
   sees nothing happen.
2. **Movement-blocking barrier lines.** Walking NE from the bedroll triggers "The trees close up that way. The cave, then." as a full
   dialogue box that stops movement until E is pressed (`critic2_03_09_walk2`); at the cave mouth a second one ("No point getting lost
   twice in one day. Back to the cave.") fired when I pressed E at the entrance before the "Go in?" popup. Barks that do not pause the
   player would do the same job.
3. **Confirmation popups ignore E.** "The Forgotten Cave - Go in?" (`critic2_05_06_e5`), the Hollow Well's "Reveal" and "Continue",
   and the duel's "Got it" tips all sat through repeated E taps; `skip_dialogue` also did not count them as dialogue. The HUD footer says
   "E / Space / Click: interact" on the same screen.
4. **Tooltip over message.** When you click a card you cannot play, the floating sentence ("One Infrastructure per turn: you already
   played yours...") appears at mid-screen while the card's own hover tooltip opens over it (`critic2_11_14_t2_click2`): the sentence is
   half hidden behind the tooltip. The tooltip does carry a short red line ("One infrastructure per turn", "Not enough energy"), which
   rescues it.
5. **Tip boxes overlap the card preview.** The "Play a unit" tip is drawn over the enlarged left-hand card preview
   (`critic2_11_11_enemy_turn`), and the "Energy" tip sits on top of the player plate (`critic2_11_05_after_infra2_try`).
6. **The opening could lose a third of its lines.** Thirty-plus taps before the Path choice; several lines are one short sentence each
   ("Two hands, one of them shaking. I'll start with the"). Merging the Wanderer's self-inventory into fewer boxes would get a player to
   the Path screen a minute sooner.

## Part B - the ten questions

| # | Question | What I saw | Screenshot | Verdict |
|---|---|---|---|---|
| 1 | Finding the cave on foot | After the Rescuer leaves there is a bobbing yellow triangle over the arch, a glowing ring on the ground before it, a dot at the top-right of the minimap and a ringed marker on the map (M) with "Dungeon entrance" in the legend. `hold W+D 2`, `hold W+D 1.5`, E (barrier line), `hold W 2`, `hold W+D 1`, `hold W 1` put me on the "[E] Enter the cave" prompt in about 12 s of walking. Stuck once: the "trees close up" box froze movement until dismissed | `critic2_02_60_forest_free`, `critic2_03_04_map_open`, `critic2_04_08_walk5`, `critic2_04_10_after_e2` | **landed** |
| 2 | Deck Station close | B opens it with a "Building a deck" tip; the X at top right (1550,55) closes it and the forest is drawn; Esc closes it and the forest is drawn | `critic2_03_02_deck_station`, `critic2_04_02_deck_closed_x`, `critic2_03_03_deck_closed_esc` | **landed** |
| 3 | Map in the forest | M opens "Map - The Awakening" with a legend; M again closes it; opened again, its X closes it. World drawn each time | `critic2_03_04_map_open`, `critic2_03_05_map_after_second_m`, `critic2_04_03_map_closed_x` | **landed** |
| 4 | Battle banners | YOUR TURN (`critic2_11_11_enemy_turn`, turn 3) and ENEMY TURN with "Turn 2" under it (`critic2_11_10_space3`) are whole and centred. VICTORY! is whole and centred after the pilot's win (`critic2_10_18_pilot7`); 0.4 s after `dev win` it is centred but drawn beneath the enemy units and an open tooltip (`critic2_11_20_victory_banner`). Nothing clipped at an edge | as listed | **landed** (z-order nit) |
| 5 | "Spend your Ingredient" tip | Played the first duel by hand (3 turns) and with `pilot` (7 turns). Tips I saw: Your first duel, Play an Infrastructure, Energy, Nothing left to play, Play a unit, You made a Resource! ("Hoarding is encouraged"). No tip said the duel waits for me, and none appeared with no unit of mine on the table. End Turn was always available; the "End your turn? You have 1 energy left" guard offers Keep playing / End Turn / Don't ask again | `critic2_10_12_pilot1`, `critic2_11_11_enemy_turn` | **landed** (not reproducible) |
| 6 | Unplayable cards | Clicking En Garde-Manger (cost 3) with 1 energy: floating "Needs 3 energy; you have 1 (each ready Infrastructure gives 1 a turn)." plus a red "Not enough energy" line in the tooltip. Clicking a second Feastforge: "One Infrastructure per turn: you already played yours. Play a unit or a spell, or end the turn." plus red "One infrastructure per turn" in the tooltip. The floating sentence can be hidden behind the tooltip of the card just clicked | `critic2_11_05_after_infra2_try`, `critic2_11_14_t2_click2` | **partly** - the message exists and is good, but the mid-screen sentence should sit above the tooltip or the tooltip should be suppressed for a second |
| 7 | Reward screen | Before touching anything: Amuse-Bouche (middle) has the white frame, the gold button reads "Take Amuse-Bouche", and "Amuse-Bouche joins your deck." sits under the cards, with "Peek: ..." and "Ingredient: ..." glossed below. Hovering Sourdough Sentry adds "Wallflower: Can't attack." | `critic2_11_22_reward`, `critic2_11_23_reward_hover_left` | **landed** |
| 8 | Hollow Well and shrine | Well: "Five cards fall into the well. If enough of them are infrastructure, it answers with water. Pass: Heal 4 HP. Fail: Lose a card for the dungeon." After Reveal, the five cards are shown and the result says "The well answers. 2 of the 5 cards were Infrastructure; 2 were needed. You were already at full HP, so there was nothing to mend." Shrine hover: "Rest here before the last chamber. Restore **all** your HP." | `critic2_13_04_well_reveal_b`, `critic2_10_01_hover_shrine` | **landed** |
| 9 | Copies per card: Rules (R) and Character (C) | Cave Rules panel: "No special rules here: the ordinary duel rules apply." - nothing about copies, and the panel sits half under the dungeon-map tip. Character screen in town: "Copies per card - 3 Common, 2 Uncommon, 1 Epic, 1 Legendary" in plain words (the Deck Station also says "Copy caps: Common 3, Uncommon 2, Epic 1, Legendary 1; infrastructure unlimited") | `critic2_08_11_rules`, `critic2_12_11_character` | **partly** - C and the Deck Station say it; R does not |
| 10 | HUD Menu button in town | Menu drops down Character (C), Deck (B), Quests (J), Packs (P), Wardrobe (T), Glossary, Feats, Settings. Glossary opens (Keywords / Resources / Statuses / Card types / Rule icons / Zones / Terms); Feats opens ("2 of 40 earned on this account", Leaves in Your Hair "Earned here"). Esc closes each and returns to the town | `critic2_12_13_menu`, `critic2_12_14_glossary`, `critic2_12_16_feats` | **landed** |

Notes on Part B:

- Q1: a brand-new player will see the triangle and the ring only once the Rescuer has gone; before that the arch is a faint shape in a
  dark scene. The map's "Dungeon entrance" legend uses a door icon while the map itself shows a ringed dot; same meaning, different
  glyph.
- Q4: ENEMY TURN sits over the board with "Turn 2" under it; the phase panel on the right also updates. Good.
- Q6: the duel also surfaces a "Cards glow gold when you can pay for them" tip, which is the right teaching; the gold glow was visible
  on the Feastforge in my hand.
- Q9: the Rules panel toggles with R; Esc while it is open opens the pause menu instead of closing the panel.

## New problems

1. **E does not confirm popups.** "The Forgotten Cave - Go in?" survived six E taps (`critic2_05_06_e5`); Hollow Well "Reveal" and
   "Continue" survived E and `skip_dialogue`; the duel's "Got it" tips survived E. The HUD on those very screens says "E / Space / Click:
   interact". A keyboard-first player will think the game has hung. Fix: let E / Space / Enter press the focused (gold) button on every
   confirm dialog, or stop advertising E there.
2. **"More" on the Path screen only renames itself** (`critic2_02_42_gourmand_more`). Either show the long description when pressed or
   remove the button and the "(or press More)" hint.
3. **Barrier dialogue boxes stop movement** ("The trees close up that way. The cave, then.", `critic2_03_09_walk2`). A held walk key
   does nothing until E is pressed, so a player holding W+D sits still with a text box open.
4. **Tooltip covers the "cannot play" sentence** (`critic2_11_14_t2_click2`); tip boxes overlap the card preview and the player plate
   (`critic2_11_11_enemy_turn`, `critic2_11_05_after_infra2_try`).
5. **VICTORY! under the units and tooltip for the first beat** (`critic2_11_20_victory_banner`). Draw the banner on the top layer from
   frame one.
6. **Rules (R) in the cave is partly covered** by the "Tip: The dungeon map" box until Got it is pressed (`critic2_08_11_rules`), and
   says nothing about deck rules a new player might want (copy caps, 45-card minimum).
7. Driver-only: `dev load` restores the forest, not the cave map or an open popup, so continuation scripts for the cave must `dev travel
   dungeon D-TUT` again. Not player-facing.

Pause menu (Esc): worked in the forest during dialogue (`critic2_01_23_after_begin`), on the cave map, in the duel's surroundings and
in town (`critic2_12_18_pause_town`); it lists Resume / Save Game / Load Game / Settings / Glossary / Feats / Report a Problem / Open
feedback folder / Quit to Title / Quit Game. Esc also closed the Deck Station, the Map, the Character screen, the Glossary and the Feats.

## Closing

Measured against the games it will sit next to, the first half hour of The Wayward Path is now a competent, good-looking on-ramp
rather than a maze. Slay the Spire gets you into a fight in ninety seconds and Inscryption in less; this game asks for three to four
minutes of reading first, but the reading is pleasant and the Path screen is a better "who am I" moment than most. Once inside the
cave, the teaching is better than Sea of Stars' and close to Pokemon TCG Pocket's: every card you cannot play tells you why, every
keyword on the reward screen is defined underneath it, the Well tells you the arithmetic of your pass, and the shrine says exactly what
it does. What still breaks the spell is small and mechanical: the E key that the HUD promises is "interact" goes dead on confirmation
popups, the More button is a placebo, and two or three overlapping boxes in the first duel look unfinished. Fix the popups and a new
player will get from the title to their first reward without once wondering whether the game has stopped listening, which is the test
the first 30 minutes need to pass.
