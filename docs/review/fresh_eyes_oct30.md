# The Wayward Path - fresh-eyes review (v0.4.8, 30 Oct 2026)

Reviewer: outside games critic / UX researcher, first contact with the game, no access to design docs or code. Played through the
scripted driver (real keyboard/mouse injection + 1600x900 screenshots). Everything below is what a player sees; where I could not
judge something (audio), I say so. Screenshots cited are in `docs/review/fresh_eyes_oct30/` (prefixed by run name).

## Summary

There is a good game buried in here. The card frames, the painted dungeon maps (The Forgotten Cave, The House of Gains) and the
reward screens look like a finished, expensive product, and the card flavour text has real wit ("Runs on carbs and spite", "Punches
first. Asks questions never", "His job is to stand there. He's very good at his job"). The four-Path pitch is clear, the mulligan
prompt is honest, and the per-dungeon rules panel is a genuinely nice idea.

But a brand-new player's first 30 minutes are, bluntly, a slog that ends in a loss. The opening is ~20 lines of amnesia-fantasy
dialogue with no skip, the cave entrance is nowhere to be found on foot (three runs, never found it - I had to warp), and the very
first duel against a **3 HP** Cave Scavenger takes 8-12 turns and is **lost** by the game's own built-in pilot on two of the four
Paths, because starter hands are 60 % Infrastructure and you may only play one per turn. The tutorial then locks the turn behind a
"spend your Resource first" tip that I could not satisfy by doing what it says. On top of that are three blocking UI bugs in the
first ten minutes (Esc - the pause menu - hangs the game; closing the Deck Station blacks out the world; the Map cannot be closed
with M or its X button) and a lot of small inconsistencies that signal "beta" to a Slay the Spire or Inscryption audience.

Overall: **4.8 / 10** against the best of the genre today. The art and bones justify finishing it; the first hour does not yet.

## How I played

| Run | Path | What |
|---|---|---|
| critic_beef_01-02 | Beefcake | Title, slot select, wake-up conversation line by line, Path choice (More on all four) |
| critic_beef_03-08 | Beefcake | Forest: deck builder, character, quest log, map, pause; six attempts to walk to the cave arch |
| critic_beef_09-11 | Beefcake | Tutorial cave via `dev travel` (could not find the arch), rules panel, first duel UI |
| critic_beef_12-13 | Beefcake | First duel played by hand (clicks, Space, Iron + target), then the pilot; battle log |
| critic_beef_14-19 | Beefcake | Whole cave with auto-win: rewards, Hollow Well, shrine, boss intro and rules, exit; Crosspath arrival, menus, shops approach |
| critic_gour_01-02 | Gourmand | New game, Path "More", starter deck, first duel piloted (no auto-win) |
| critic_ref_01 | Refusemancer | Same |
| critic_necro_01 | Necrocrat | Same |
| critic_later_01-02 | Beefcake | The Gainlands zone, House of Gains map + rules, Throne of Gains boss (piloted) |
| critic_later_03-04 | Beefcake | Pause menu (Esc hung the game), HUD Menu button, Settings / Controls / Audio from the title |

27 game launches, roughly 1 h 50 min of game time plus reading, over ~2 h 45 min wall clock. Nothing touched the developer's
save slots (always "Start here" on slot 3). `stdout.log` had **zero `SCRIPT ERROR` lines** in any run - the bugs below are all
behavioural, not crashes.

Driver notes that are themselves findings: `dev save` snapshots do not capture dungeon state (loading one made inside a dungeon
put me back in the forest), the `More` button on the Path screen is only reachable with the mouse after a Path is highlighted, and a
`Got it` tip sits over the dungeon rules panel so `R` shows nothing useful until the tip is dismissed.

## Scores (1-10, against Slay the Spire / Inscryption / Monster Train / Sea of Stars / Octopath / Pokemon TCG Pocket)

| Area | Score | One line |
|---|---|---|
| First 5 minutes' hook | 4 | Pretty still, then 20 unskippable lines, then a wall of forest with no visible way out |
| Clarity (what to do, what things mean, why I won/lost) | 4 | Keywords undefined on cards, tutorial tip deadlock, "Nothing changes" event outcome, empty quest log in town |
| Pacing and friction | 3 | Opening + unreachable cave + 10-turn first duel + 8.5 s town load; three E-prompt styles |
| Combat depth and feel | 5 | Real decisions exist (Iron, Overtime, blocking) but boards clog with Infrastructure; victories feel like attrition |
| Deck-building satisfaction | 5 | Handsome Deck Station with filters, but 45-card starter deck, jargon caps, no explanation of Infrastructure/Resources before the fight |
| Reward rhythm | 6 | Card choice after every fight, gold/XP numbers clear, Feat toasts; Skip is more prominent than Take |
| Exploration and world | 4 | Dark minimap, "trees close up that way" walls, no objective marker; Crosspath and Gainlands look good from afar |
| Story and humour | 6 | Card flavour and boss lines land; the Rescuer/amnesia frame is generic and over-long |
| Visual cohesion and readability | 6 | Cards, maps and popups are excellent; 3D world is soft/low-res next to them; stills do not match the scene |
| UI/UX consistency | 4 | Close by X / M / Esc behave differently per screen; banners off-screen; hand cards cut at the bottom edge |
| Audio | n/a | Cannot judge from screenshots/logs; the game never mentions music or SFX in any UI except Settings |
| Performance | 6 | Loads 0.6-3 s, town 8.5 s; 500-700 ms hitches after every fade-in on this PC |
| Bugs / stability | 3 | Esc hangs the game, two more blocking UI bugs in the first 10 minutes, several layout bugs, zero script errors |

## Findings per area

### First five minutes

- The title (`critic_beef_01_01_title.png`) is clean: painted backdrop, five buttons, version string. The slot screen
  (`critic_beef_01_02_slot_select.png`) shows other people's saves with "Start over here / Copy / Delete" - a new player sees
  only "Start here", which is fine.
- The wake-up (`critic_beef_01_03_wake_1.png`) opens on a lovely golden-hour painting of the hero under trees... and the actual
  scene behind it is a dark teal night forest (`critic_beef_01_03_wake_3.png`). The still is reused unchanged for several lines,
  so it reads as a loading image rather than a scene.
- From wake-up to the Path choice is **15 E-presses** (the driver's `skip_dialogue` counted 15 taps), then 4-5 more after
  choosing. There is no skip, no hold-to-skip, no history. Inscryption gets you to your first card in under a minute; Slay the
  Spire in ten seconds.
- The Rescuer's lines ("A friend. That's all I can give you, and it's already more than is safe", "Tell me: which Path resonates
  the strongest within you?", "That one, then. Hold on to it, and it will hold on to you") are competent but pure fantasy-amnesia
  boilerplate. The hero's "...Gone, toward the torches. I never even asked their name" (`critic_gour_02_03_gour_deck.png`) is the
  one line with a pulse.
- The dialogue prompt flips between "E / Click to close" and "E / Click to continue" mid-conversation on consecutive lines
  (`critic_beef_01_03_wake_3.png` vs `03_wake_1`), which made me think the conversation had ended twice.
- The **Path choice** (`critic_beef_02_04_path_choice.png`) is the best screen in the opening: four columns, three sample cards
  each, a one-line pitch each, "More" for a paragraph (`critic_beef_02_06_path_beefcake_more.png`, `critic_gour_02_01_gour_more.png`).
  The pitches are good ("Hit hard and early. Save up Iron, then spend it all on one big swing"). The sample card text is unreadable
  at that size and the icons inside the rules text render as blanks in the dump ("create an  Iron"), which suggests the icon font
  is not always loaded.
- A "Feat: Leaves in Your Hair - Menu > Feats" toast fires over the Path screen while you are reading; achievements before the
  player has done anything cheapen them.

### The forest and finding the cave

- After Begin you stand by a bedroll in a teal clearing (`critic_beef_03_10_forest_start.png`). The Deck button in the top right is
  partly hidden behind the minimap compass (`critic_beef_03_10_forest_start.png`, label "Deck (B)" at 1450,45 under the ring).
- The brief says the cave is through a ruined arch to the north-east. I walked north-east, north, east and north again across
  six runs (`critic_beef_07_27_walk_ne_1.png`, `critic_beef_08_38_north_4.png`) and every direction ends in an invisible wall with
  the Wanderer saying "The trees close up that way. The cave, then." or "No point getting lost twice in one day. Back to the cave."
  The arch is visible as a distant lit stone gate in some shots (`critic_beef_07_27_walk_ne_1.png`, right of centre) but no path
  leads there and the minimap is a blank dark disc. **I never reached it on foot and used `dev travel dungeon D-TUT`.** A real
  player has no such button. This is the single worst first-impression problem.
- The map screen (`critic_beef_05_15_map.png`) shows "Map - The Awakening", a black field with a tiny revealed blob and a legend
  that promises quest icons that never appear. There is no objective marker for "the cave".
- **Bug:** closing the Deck Station with its X button (top right) leaves the 3D world black; the HUD keeps drawing and you can
  still walk (`critic_beef_06_22_after_deck_close_5s.png`, `critic_beef_06_20_forest_before.png` for the before state). Pressing B
  again (toggle) does not trigger it; only the X does. First reproduced in run 04, confirmed in 05 and 06.
- **Bug:** the Map (M) cannot be closed with M or its X button (`critic_beef_06_25_map_after_x.png`, then `26_map_after_m` still
  shows the map). Only Esc works. The Deck Station's tip says "Esc closes", the Character/Quest/Map screens all have an X, and B/C/J/M
  toggle inconsistently. Pick one rule.

### Tutorial cave (The Forgotten Cave)

- The node map (`critic_beef_09_41_cave_arrival.png`) is gorgeous and immediately legible: six nodes, paths, a shrine, a well, a boss
  behind a red skull. A tip explains glowing nodes and that HP carries between fights. This is Slay-the-Spire-grade presentation.
- `R` opens "Rules of The Forgotten Cave" but the panel is empty apart from its title (`critic_beef_09_47_cave_rules.png`,
  `critic_beef_11_49_rules_panel.png`) - a tutorial dungeon with no rules should say "No special rules here" rather than show a blank.
- Hovering a node does nothing (no tooltip on `critic_beef_11_50_hover_node.png`); clicking it starts the fight with no
  "Fight: Cave Scavenger, 3 HP" preview, so the player cannot weigh routes. Later nodes do show a tooltip (shrine, boss), but that
  tooltip then stays stuck on screen after the mouse leaves (`critic_beef_15_109_boss_intro.png` and every shot after it).
- The Hollow Well event (`critic_beef_16_121_hollow_well.png`) reads "Five cards fall into the well. If enough of them are
  infrastructure, it answers with water. Pass: Heal 4 HP. Fail: Lose a card for the dungeon." I pressed Reveal at full HP and got
  "The well answers. Nothing changes." (`critic_beef_17_140_well_result.png`). Did I pass? Did I fail? The threshold ("enough") is
  never stated. Compare Slay the Spire's events, which always show the exact outcome.
- The shrine says "Restore **999** HP" (`critic_beef_15_106_shrine.png`) - an obvious placeholder number on a 10 HP character.
- The boss node tooltip ("Hollow Warden, 3 HP. Reward: 200 gold and XP, a choice of card. The Warden Stirs: at half health...") is
  exactly the kind of transparency the earlier nodes lack. The boss intro (`critic_beef_17_144_boss_intro.png`) with the big stone
  guardian portrait and "...Hm. Woken. For this. Another of the little scavengers, I suppose" is the best writing moment in the
  first hour. The "Before the fight" rules card (`critic_beef_17_148_boss_fight.png`) is good practice.

### Combat (played by hand on Beefcake, piloted on all four)

- Layout (`critic_beef_12_57_turn1_start.png`): enemy top-left, you bottom-left, phase tracker right, resource trays right, hand
  bottom. The hand is drawn so low that card rules text is cut off by the screen edge on every card - you cannot read what a hand
  card does without hovering (`critic_beef_11_56_hover_hand.png`). Hover works and the preview is excellent, but the default state
  should be readable.
- Turn structure: Start / Main / Combat / Main 2 / End, Space advances. The phase box explains each phase ("Play an infrastructure
  and play spells. Click a card, or drag it onto the table"). Good.
- The first-duel tips are well written ("The most important card of the day"; "Hoarding is encouraged") but there are too many of
  them and they are modal: a tip after the mulligan, after the first Infrastructure, after the first Resource, before combat. Each
  needs a click on Got it or Skip tips.
- **Deadlock:** on turn 3 the "Spend your Iron" tip appears and the game refuses Space with a toast "Spend your Resource first: the
  guide is waiting for it" (`critic_beef_13_78_t3_space_with_tip.png`). I clicked the Iron (it highlights, the phase box says
  "Choose a target / Click a highlighted target"), then clicked my only unit - the targeting arrow stays drawn, the unit is not
  highlighted, nothing resolves, and the toast repeats (`critic_beef_13_80_iron_target.png`). The only escape is Skip tips. The
  tip says "Click your glowing Iron, then a unit"; I did; it did not work. Either the Iron needs a unit on the board (I had none,
  having been unable to play one) and the tip should not fire, or targeting is broken.
- Playing a unit by clicking it in hand did nothing on turn 1 for Leg Day Survivor or Tavern Regular (`critic_beef_13_75_t1_click5.png`,
  toast "You can only play one infrastructure per turn" for the wrong card). I assume they cost more energy than the 1 I had, but the
  cards do not show an energy cost badge I could read, and there is no "not enough energy" feedback. Monster Train greys out
  unplayable cards; this does not.
- Results by Path, each pilot-played from the same opening-hand rules:
  - Beefcake: **lost** on turn 8, 0 HP vs 3 HP (`critic_beef_12_64_pilot_1.png`); four Powerhouses stuck in hand.
  - Gourmand: **lost** on turn 12 with the enemy at 1 HP; six Feastforges on each side (`critic_gour_02_05_gour_pilot_end.png`).
  - Refusemancer: won on turn 11 at 10/10 HP (`critic_ref_01_05_ref_pilot_end.png`).
  - Necrocrat: won on turn 9 at 8 HP (`critic_necro_01_05_necro_pilot_end.png`).
  A 3 HP opponent should die in 3-4 turns. The reason it does not: 40-card starter decks with ~10 Infrastructure, one Infrastructure
  per turn, every opening hand has 3 of them ("3 infrastructure, 2 spells in your 5 cards" the mulligan popup admitted), and the AI
  plays the same wall. The duel becomes two players building power plants while 2/1s stare at each other with "Zz" badges.
- Keywords on cards - Overtime, Hustle, Swat, Wallflower, Sucker Punch, Peek, Bulldoze, Flying, Plating - have no inline
  definition. Only Exhaust gets a reminder line in the hover preview. A new player cannot evaluate Leg Day Survivor ("Hustle.") at
  the reward screen.
- Defeat (`critic_beef_12_68_after_fight_3.png`) says "Cave Scavenger wins after 8 turns. You are carried out of the dungeon. Your
  collection is safe." Honest, but no "why": no damage recap, no hint ("try keeping fewer Infrastructures"). Slay the Spire's death
  screen at least shows the run stats.
- The YOUR TURN / ENEMY TURN / VICTORY! / DEFEAT banner is anchored at x=1620 on a 1600-wide screen, so it reads "DEF" and "VICT"
  (`critic_beef_12_64_pilot_1.png`, `critic_necro_01_05_necro_pilot_end.png`). The floating "-2" damage number overlaps the enemy
  name plate in the same Necrocrat shot.
- The battle log (`critic_beef_13_84_battle_log.png`) is a plain list ("You played Powerhouse / Cave Scavenger played Feastforge").
  Useful; should also log damage and blocks.
- Speed: 1x button exists. I did not test 2x.

### Deck building and the Collection

- The Deck Station (`critic_beef_04_12_deck_builder.png`) is handsome: colour and type filters, cost filter, card grid with
  "Deck 2/3 Own 2", slot name "Wanderer's Deck". Hover preview (`critic_beef_05_12c_deck_hover_card.png`) is big and readable.
- But: it opens with a modal tip, the starting deck is **45 cards** (Character screen) / Deck 40 in battle, and it already contains
  Colorless cards from other Paths' identities (Tripwire, Courier Pigeon, Village Militia) which dilutes the Path you just chose.
  The header "Copy caps C3 · U2 · E1 · L1" is cryptic jargon on a screen a new player opens in minute two.
- There is no explanation anywhere before the first fight of what Infrastructure, Resources (Iron / Ingredient / Garbage / Red
  Tape), Exhaust or the four tray icons mean. The icon font fails to render inside rules text in several places ("Exhaust: add ."
  on every basic Infrastructure).

### Rewards and progression

- Post-fight (`critic_beef_14_86_after_fight1.png`): "+40 gold, +15 XP, Choose a card for your deck", three cards with full text.
  Clear and attractive. The boss gives +200 gold / +120 XP and a Feat toast ("Flawless" - for an auto-won fight, which is a
  reviewer artefact, but it also fired "Leaves in Your Hair" for existing).
- "Take card" is greyed until you click a card and "Skip card" is the gold, prominent button; the first time I pressed what looked
  like the primary button and skipped my reward. Pre-select the middle card and make Take the primary.
- Levelling: the cave took me from level 1 to 3 with HP 10 -> 11. The Character screen (`critic_beef_19_183_character.png`) shows
  five padlocked gear slots with no hint how to unlock them, a "Path essence" row of four zeros, and "Item slots 1/4". None of this
  is explained. It is a lot of locked promise for minute 25.
- Wardrobe (`critic_beef_19_182_wardrobe.png`) is a nice touch (dye swatches, hat), though the text contradicts itself: the button
  says "Plain teal cloak", the summary says "dark teal hooded cloak (Natural)", and "Nothing yet: Pip Threadwell sells them" sits
  next to an equipped cloak.

### Town (Crosspath) and the first zone (The Gainlands)

- Arrival (`critic_beef_19_175_town_arrival.png`): 8.5 s load, a title card "Crosspath - Where every Path crosses", a half-timbered
  square with a fountain and vendors. It looks like a cosy Octopath-lite town from this high camera - but the hero is a tiny sprite,
  NPC name labels only appear within a few steps, and the "Brindle the Baker" label is drawn twice stacked
  (`critic_beef_19_186_walk_n.png`).
- The quest log says "Nothing here right now" (`critic_beef_19_180_quest_log.png`) immediately after the Rescuer said "Someone there
  will be waiting for you." No objective, no marker, no NPC approaching. The town map is a black square with one dot
  (`critic_beef_19_184_town_map.png`). Card Packs: "No unopened packs." Items: "No items yet". Every system says "come back later".
- The Gainlands (`critic_later_01_200_zone_beefcake.png`): a bright sandstone plateau over blue water, banners, a gym-temple at
  the top of a bridge. Strong silhouette and a real sense of place. The HUD though plants a big "HP 11/11 - Zone HP: no healing
  after battles" box dead centre at the top, over the landmark, and the minimap is a black disc. The zone map
  (`critic_later_01_206_zone_map.png`) is 95 % black with a heal icon and a portal icon.
- The House of Gains map (`critic_later_01_207_hog_map.png`) is a showpiece - a mountain fortress with twelve named nodes and a
  "Throne of Gains" - and its rules panel (`critic_later_01_208_hog_rules.png`) actually has content: "[+] Pump It Up: Beefcake
  units get +1 attack. [-] Processing Time: ... [*] Iron-less Prison: in the prison (nodes 8-9) Iron can't be used." This is the
  kind of asymmetric dungeon rule Monster Train players love. Nodes are not numbered on the map, so "nodes 8-9" means nothing.

### Later content sample (boss, menus, Feats, Collection, Settings, controller)

- **The House of Gains boss (Chancellor Clench, Iron Regent)** is the strongest content I saw. The node tooltip tells you
  everything up front ("24 HP. Reward: 100 gold and XP, a choice of card. Iron Regent: starts the duel with 2 Iron..."), the
  intro has four lines of real character ("Chancellor Clench stands before an enormous bench press, the only weight left in the
  whole House of Gains. It is his." / "They say he trained a hundred pupils and I was the best of them. Look where that got me.
  Look where it got him."), and the pre-fight rules card lists **eight** rules in play with icons
  (`critic_later_02_235_boss_prefight.png`): Pump It Up, Processing Time, Pump Iron, Iron Regent, Reinforcements, Brownout,
  "DROP AND GIVE ME FORMS", "Master...?". The in-battle splash (`critic_later_02_236_boss_board.png`, full-height portrait, title,
  taunt, "Any key to skip") is Octopath-boss-reveal quality. Scripted turns are announced ("Brownout - The lights go out: your two
  strongest ready units are exhausted" with a bark, plus "Next turn: Patchwork Body (2/2) arrives").
- Eight rules at once is a lot for a first boss, and three of them (Pump It Up, Pump Iron, Processing Time) are dungeon-wide rules
  repeated in the boss list, two of which are near-duplicates ("Beefcake units get +1 attack" / "Your Beefcake units enter with +1
  attack"). The icons' meanings are only discoverable by hover.
- The fight itself (level 8, 14 HP, full starter deck, piloted) was **lost on turn 13 at 0 HP vs 20/24**
  (`critic_later_02_237_boss_pilot_end.png`). The board shows the same pathology as the tutorial: four Powerhouses in my hand plus
  four on the table, while Clench has a 9/5 and a 5/2 Leg Day Survivor with Hustle and a Tool. The pilot is a weak player, but the
  shape - my side all Infrastructure, his side all threats - is what a new player's deck produces too. Defeat again gives no recap
  (`critic_later_02_238_boss_after.png`).
- In the defeat shot the "-5" damage number overlaps the "You" plate and "DEF" is clipped at the right edge, as in every battle.

- **Pause menu / Feats / Collection Book: could not reach them.** Pressing Esc in the forest (run 03) and again in the forest after
  a snapshot load (run later_03) froze the game: no further input was processed and the driver killed the process at its time
  limit; the planned `20_pause_menu` and `240_pause_menu` screenshots were never taken. Twice in two attempts, so I treat it as a
  real hang rather than driver noise, but I could not rule the driver out. The on-screen **Menu** button in town
  (`critic_later_04_255_town_menu.png`) opens only Character / Deck / Quests / Packs / Wardrobe - no Feats, no Collection, no
  Glossary, no Settings - even though the Feat toasts tell you "Menu > Feats". For a new player the achievement list and the card
  collection are therefore behind the one key that hangs the game.
- **Settings** (from the title, `critic_later_04_250_title_settings.png`): five tabs (Display, Text, Accessibility, Controls, Audio).
  Display is thorough - window mode, resolution, VSync, frame cap, quality preset, DoF, bloom, fog, upscaling, render scale ("Quality
  preset (58%)"), sharpness, dynamic resolution, UI scale, camera angle, camera zoom, minimap toggle - with plain-English helper text
  ("Depth of field (tilt-shift blur, Medium and High)"). That is better than most indies. The panel scrolls, and nothing tells you
  so; "Render scale (3D)" is cut in half at the bottom edge.
- **Controls** (`critic_later_04_251_controls.png`): full rebinding table with keyboard, alternate key and controller columns,
  "Reset" per row, "Reset to defaults", a controller-button-names option and a clear statement of the fixed pad buttons ("A
  confirms and B goes back in every menu, Menu pauses, the right stick turns the camera..."). The "Menu (character, deck, quests...)"
  action is **Not set** on keyboard by default - which is presumably why the HUD says "Escape: menu" but Esc behaves differently.
  I could not test a gamepad through this harness.
- **Audio** (`critic_later_04_253_audio.png`): Master / Music / Effects / Interface / Ambience / Dialogue voices sliders, mute on
  focus loss, and an explanation of what each bus contains. "Dialogue voices" implies voiced lines exist; I saw no indication of
  that in any dialogue box.
- The stray font-test label ("6789 .,:;!?'", then '"()-+/%&') is again live in the UI tree at the top-left when the Menu is open.

### Audio

Not judgeable through this harness: no screenshot or log line refers to music, SFX or volume outside the Settings menu. I note
only that no UI moment (victory, level up, Feat) shows a visual cue that would normally pair with a sting, so I cannot tell whether
those stings exist.

### Performance (from `load_timing` lines in stdout.log and shot timestamps)

- Title 950-1000 ms. Starting forest 2.7-3.1 s ("painted: material" 1.7-1.9 s of it). Dungeon map 2.3 s first time, 0.6-0.7 s
  after. Battle 0.68 s. Rewards 0.67 s. **Town 8.5 s.** Gainlands zone 5.6 s.
- Worst frame in the first 5 s after a fade-in: 572 ms (title, first launch), 542 ms (forest, first launch), 709 ms (battle),
  585-591 ms (rewards), 532 ms (town). Those are visible hitches right when a new screen appears. Subsequent launches of the title
  and forest were clean (43-47 ms), so some of it is first-run shader/material warm-up.
- No stutter visible in the driver's command timestamps during play itself.

### Bugs found (no SCRIPT ERRORs; all reproduced at least twice unless noted)

1. Deck Station X button -> world renders black, game continues (runs 04, 05, 06).
2. Map cannot be closed with M or X; only Esc (runs 04, 06).
3. Tutorial "Spend your Iron" tip blocks the turn; Iron -> unit targeting does not resolve (run 13).
4. Turn/result banner positioned off the right edge ("DEF", "VICT") in every battle.
5. Node tooltip sticks on screen after the mouse leaves the node (runs 15-19).
6. Damage number overlaps the enemy name plate (run necro_01).
7. "Brindle the Baker" name label drawn twice (run 19).
8. Icon glyphs missing inside card rules text ("create an  Iron", "Exhaust: add .") in dumps and visibly blank in hover previews.
9. Rules of The Forgotten Cave panel is empty.
10. Shrine "Restore 999 HP" placeholder.
11. Deck button hidden behind the minimap ring in the forest HUD.
12. Stray font-test labels ("vwxyz 012345", "jklmnopqrstu", "6789 .,:;!?'") exist in the live UI at the top-left on arrival in
    town and in the Gainlands (seen in `dump`, near-invisible on screen) - a glyph warm-up label that was never hidden.
13. `dev save` snapshots lose dungeon progress (developer-tool bug, but it will bite anyone using it to test).
14. **Esc (pause menu) in the overworld hangs the game** - reproduced in run 03 and run later_03; every command after `key Escape`
    went unanswered until the process was killed. Feats and the Collection Book are only reachable through that menu.
15. Settings panel content is clipped at the bottom with no scrollbar ("Render scale (3D)" half visible on open).

## Top 20 problems, ranked by impact on a new player's enjoyment and retention

1. **The cave cannot be found on foot.** Where: forest, every direction (`critic_beef_07_27_walk_ne_1.png`,
   `critic_beef_08_38_north_4.png`). Why: the game's first task is unsolvable without the cheat menu; most players will quit
   within five minutes. Fix: a lit, unmistakable path from the bedroll to the arch, a quest marker on the minimap and HUD
   ("Go to the Forgotten Cave" with a direction arrow), and make the "trees close up" barrier message say which way to go.
2. **The first duel is lost by default on two Paths.** Where: `critic_beef_12_64_pilot_1.png`, `critic_gour_02_05_gour_pilot_end.png`.
   Why: losing an 8-12 turn tutorial fight to a 3 HP rat is humiliating, not instructive, and it ejects you from the dungeon. Fix:
   give the tutorial opponent 1-2 HP and a scripted 3-turn deck; cap Infrastructure at 2 in opening hands (or auto-mulligan one);
   let the first duel be unlosable (enemy "surrenders" at turn 6 with a lesson).
3. **Tutorial tip deadlock.** Where: `critic_beef_13_78_t3_space_with_tip.png`, `critic_beef_13_80_iron_target.png`. Why: the game
   refuses input until you do a thing it will not let you do; players who do not spot "Skip tips" are stuck. Fix: never block
   input behind a tip; only show "Spend your Iron" when a valid target unit is on the board; make tips dismissable with Esc/Space.
4. **Esc in the overworld hangs the game.** Where: runs critic_beef_03 and critic_later_03 (no screenshot possible - the planned
   `20_pause_menu` / `240_pause_menu` were never captured; see `stdout.log` of either run, which stops at `key Escape`). Why: the
   HUD tells you "Escape: menu"; the first time a player wants to save, check Feats or change a setting, the game freezes. Also
   blocks the Collection Book and Feats entirely, since the HUD Menu button (`critic_later_04_255_town_menu.png`) does not list
   them. Fix: find the pause-menu deadlock (likely input capture while a scene is still loading/fading); add Feats, Collection,
   Glossary and Settings to the HUD Menu button so no feature depends on one key.
5. **Deck Station close blacks out the world; Map cannot be closed by M or X.** Where: `critic_beef_06_22_after_deck_close_5s.png`,
   `critic_beef_06_25_map_after_x.png`. Why: both look like crashes in minute two and both are on screens the tutorial sends you to.
   Fix: one shared close routine for every overlay (toggle key, X and Esc all call it) that restores the world viewport/camera.
6. **Twenty lines of unskippable opening.** Where: `critic_beef_01_03_wake_*.png`, `critic_beef_02_03_wake_*.png`. Why: longest
   stretch of non-play in the genre's first five minutes; the still images do not match the night scene. Fix: cut to six lines
   before the Path choice, add hold-to-skip and a log, and either paint the still at night or play it by day.
7. **Hand cards are cut off at the bottom edge.** Where: `critic_beef_12_57_turn1_start.png`. Why: rules text unreadable without
   hovering, every turn. Fix: lift the hand 60 px or scale cards to fit; fan on hover like Slay the Spire.
8. **Combat keywords are undefined.** Where: `critic_beef_18_161_after_boss_map.png` ("Hustle"), `critic_necro_01_04_necro_t1.png`
   ("Wallflower"). Why: you cannot choose a reward you cannot read. Fix: inline reminder text in the hover preview for every keyword
   (as Exhaust already has) and a Glossary link on the reward screen.
9. **No feedback for unplayable cards / no visible energy cost.** Where: `critic_beef_13_75_t1_click5.png`. Why: new players click
   cards, nothing happens, they assume the game is broken. Fix: grey out unaffordable cards, show the cost badge large, and toast the
   real reason ("Needs 2 energy, you have 1").
10. **Starter decks clog with Infrastructure.** Where: `critic_gour_02_05_gour_pilot_end.png` (six Feastforges per side). Why: ten-turn
    attrition fights feel like bad draws, not decisions. Fix: Infrastructure as a separate pile (as Hearthstone mana) or a 30-card
    starter with 6 Infrastructure; let unplayed Infrastructure be discarded for a Resource.
11. **Town gives no objective.** Where: `critic_beef_19_180_quest_log.png`, `critic_beef_19_184_town_map.png`. Why: after "someone
    will be waiting for you", "Nothing here right now" is a dead end; the black map and empty packs/items screens compound it. Fix: an
    NPC who walks up on arrival, a main quest entry on arrival, a lit path to the Path-zone gate, and a pre-revealed town map.
12. **Result banner and other UI off-screen / clipped.** Where: `critic_necro_01_05_necro_pilot_end.png` ("VICT"),
    `critic_beef_03_10_forest_start.png` (Deck under the compass). Why: looks broken at the most emotional moment. Fix: anchor the
    banner to the viewport right edge with margin; move the Deck button left of the minimap.
13. **Event outcomes are opaque.** Where: `critic_beef_17_140_well_result.png` ("The well answers. Nothing changes."). Why: the
    player cannot learn the rule. Fix: "3 of 5 were Infrastructure - pass! (needed 3) You are at full HP, so no heal" style text.
14. **Reward screen primary/secondary inverted.** Where: `critic_beef_14_86_after_fight1.png`. Why: new players skip their first
    reward. Fix: pre-select a card, gold "Take", grey "Skip".
15. **Modal tips everywhere.** Where: Deck Station, Character, Map, battle (four in the first turn). Why: friction; many are
    "Got it" with no new info. Fix: non-modal coach marks that fade; one per screen; a Tutorial toggle in Settings.
16. **Dungeon nodes have no preview and tooltips stick.** Where: `critic_beef_11_50_hover_node.png`, `critic_beef_15_109_boss_intro.png`.
    Why: cannot plan a route; stuck tooltip covers the map. Fix: hover tooltip on every node (enemy, HP, reward) and hide on exit.
17. **Jargon and placeholders in early screens.** Where: `critic_beef_19_183_character.png` ("Copy caps C3 · U2 · E1 · L1", "Path
    essence 0 0 0 0", five padlocks), `critic_beef_15_106_shrine.png` ("999 HP"), empty rules panel. Why: signals unfinished. Fix:
    plain-language labels with tooltips; hide systems until unlocked; real numbers.
18. **Minimap and maps are black.** Where: `critic_beef_05_15_map.png`, `critic_later_01_206_zone_map.png`. Why: exploration fog on
    a tiny starting area reads as "nothing here". Fix: reveal the starting forest and town fully; fog only the zones.
19. **Load hitches and the 8.5 s town load.** Where: stdout `load_timing: town 8500 ms`, 500-700 ms frames after fade-ins. Why:
    every screen change stutters on a modest PC. Fix: warm materials during the title, stream the town, show a progress bar.
20. **Zone HUD covers the landmark.** Where: `critic_later_01_200_zone_beefcake.png`. Why: the one moment the world should sell
    itself, a brown box sits on it. Fix: move the zone HP widget to the top-left under the zone-effects icons; collapse after 3 s.
