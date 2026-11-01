# Fresh eyes: the first hour of The Wayward Path (v0.5.0) - Nov 1 2026

Critic 12. Played blind through the scripted driver from `C:\Dev\wp_critic` on two Paths: **Beefcake** (main run: title, opening,
Path choice, forest, the Forgotten Cave incl. the boss, Crosspath arrival and Elder Maren, quest log, map, Deck Station, Character,
Wardrobe, Packs, Sable's card stall, the Gainlands' first look and NPC, one zone fight by hand) and **Necrocrat** (opening, Path screen,
first duel by hand). Screenshots cited below are in `docs/review/fresh_eyes_firsthour_nov1/` with the run name as prefix
(`c12f_01_fight_start.png` = run `c12f`, shot `01_fight_start`). Everything judged is what the screenshots and `play.log` showed;
nothing else was read.

## Summary

This is a handsome game that cannot get out of its own way for the first fifteen minutes. The title screen, the wake-up still, the
Path screen, the dungeon map, the Hollow Warden, Elder Maren and Sable portraits are genuinely lovely - closer to Octopath and Sea of
Stars than to most indie deckbuilders - and the battle table reads well at a glance. But the hook is buried: a brand-new player taps
through **twenty-two lines of dialogue** before being asked to make a choice, picks a Path from a screen of unreadable card thumbnails,
is set loose in a dark forest where the only exit is a one-tile strip the camera hides, and then plays a first duel that, against a
**3 HP** enemy, took the built-in pilot **13 turns** (7 as Necrocrat). A zone fight against a 4 HP Quota Spotter ran **16 turns and I
lost it** with the enemy at 1 HP, both boards clogged with eight infrastructure cards each. Slay the Spire puts you in a fight in under
90 seconds and its first fight is over in three turns.

Once the game gets going it is better than its opening: gold + XP + a 3-card pick after every fight, a Hollow Well gamble that shows
your real odds, a boss node that tells you its HP and twist before you commit, a two-page level-up with a cosmetic hat, a tortoise elder
with a voice ("I have far too much pie"), a fox card dealer with a better one ("Where's it from? The past, darling. Next question."), a
quest tracker on the HUD with "Where to go" text, a map "Where to?" list of every destination, and a defeat screen that tells you
exactly **what beat you** with a tip. Those are StS-grade touches. What drags the scores down is friction and polish: overlapping
tutorial modals, popups that ignore the "E / Space" convention the game teaches, a victory/defeat banner that renders behind cards, a
ghosted "YOUR TURN", a full-height empty "QUEST UPDATED" panel that covers the NPC you are talking to, a fog-of-war town map that is
95 % black on arrival, Esc that opens Pause over a battle, and combat turns that take too long for how little HP is in play.

Overall against the comparison set: **5.7 / 10**. The art and the systems would score 7-8 on their own; the first fifteen minutes score 4.

## How I played (runs, Paths, time)

Wall clock 13:11 to 13:56 playing and reading (45 min, 19 runs), report finished by 14:05. One game process at a time, scripts in
`wp_critic/docs/review/play_scripts/critic12_*.txt`, output in `wp_critic/_screenshots/play/c12a` ... `c12s`:

| Run | Script | What happened |
|---|---|---|
| c12a | `critic12_a_open.txt` | Title, wake-up; I under-counted the opening dialogue, pressed Esc and landed in Pause > Glossary. |
| c12b | `critic12_b_open.txt` | Full opening conversation read line by line (22 taps), Path screen, More, Begin as Beefcake, saved in the forest. |
| c12c | `critic12_c_cave.txt` | Forest: J did nothing; Esc opened Pause and blocked the walk. |
| c12d | `critic12_d_cave.txt` | Walked to the cave arch, got stuck in the trees east of it; E found nothing. |
| c12e | `critic12_e_cave.txt` | One more manual attempt failed; fell back to `dev travel dungeon D-TUT` (noted). Dungeon map, Rules. |
| c12f | `critic12_f_fight1.txt` | First duel observed, pilot played it: 13 turns to kill a 3 HP enemy. |
| c12g | `critic12_g_manual.txt` | First duel played by hand (drags, Space, click to attack) for two turns, then pilot; my Esc on the Battle log opened Pause mid-battle and the pilot got stuck in the Glossary. |
| c12h | `critic12_h_cave_rest.txt` | Rest of the cave with auto-win: card pick, the Hollow Well; stalled because the Well's result popup only closes by mouse. |
| c12i | `critic12_i_town.txt` | `dev travel town` (not the scripted arrival): empty Quest log, map, Deck Station, Character, Packs. |
| c12j | `critic12_j_necro.txt` | Necrocrat: Path screen More, first duel by hand for two turns then pilot: won in 7 turns. |
| c12k | `critic12_k_boss.txt` | `dev travel dungeon D-TUT -2`: Hollow Warden intro read, boss auto-won, reward, two level-ups, cave exit still, real Crosspath arrival with Elder Maren. |
| c12l | `critic12_l_town2.txt` | Maren's conversation to the end, quest log with the quest, town map, Pause (my misclick), walk inputs ignored afterwards. |
| c12m | `critic12_m_zone.txt` | `dev travel zone beefcake`: the Gainlands arrival, zone HUD, walk, Old Hob the Gravedigger. |
| c12n | `critic12_n_fight.txt` | `dev encounter zone:beefcake:brute` (Quota Spotter): three turns by hand, then pilot: lost after 16 turns. |
| c12o | `critic12_o_shops.txt` | Walked south (wrong way) past the Deck Station; Brindle the Baker bark; HUD Menu; P key opened Pause instead of Packs; Wardrobe. |
| c12p | `critic12_p_sable.txt` | Back to the square; Packs via the Menu button (empty state). |
| c12q | `critic12_q_sable.txt` | Map "Where to?" list; passed Sable's prompt and got stuck in a flowerbed. |
| c12r | `critic12_r_shop.txt` | Talked to Sable (quest step ticked), her stall's front page. |
| c12s | `critic12_s_stall.txt` | Stall's Cards list and Sealed Surprises (packs) page; my buy click hit the portrait, so buying is untested. |

Not reached: the Gainlands' gatekeeper and dungeon, Tilly Tonic's / Pip Threadwell / Bertram's shops, pack opening, a Necrocrat cave run.
`stdout.log` had **0 `SCRIPT ERROR`** lines across all nineteen runs; only Godot leak warnings at exit.

## Scores (1-10 against Slay the Spire, Inscryption, Monster Train, Sea of Stars, Octopath Traveler, Pokemon TCG Pocket)

| Area | Score | One line |
|---|---|---|
| First 5 minutes' hook | 4 | Gorgeous title and wake still, then 22 dialogue taps and no interactivity before the Path screen. |
| Clarity | 6 | Keywords, resources, zone rules, shop caps and the defeat recap are all explained; energy / infrastructure / attacking are not taught before the first play. |
| Pacing and friction | 3 | Walking into the cave fights you; modals stack; duels run 7-16 turns against 3-4 HP enemies; 10-22 s loads; town fog of war. |
| Combat depth and feel | 6 | Real decisions (infrastructure vs units, attack/block, Iron / Red Tape tokens, traps); feel undercut by slow turns, board clog, banner glitches. |
| Deck-building satisfaction | 6 | Deck Station and the stall are complete (filters, copy caps, curve, Suggest/Fill, Own x/cap) but dense and shout "Level 7 / 14" locks at level 1. |
| Reward rhythm | 7 | Gold + XP + 3-card pick per fight, well gamble with odds shown, boss preview, two-page level-up with a hat, quest step ticks live on the HUD. |
| Exploration and world | 5 | Forest, cave map, town, stall and the Gainlands all look great; forest navigation is a hidden corridor; town map is black on arrival; NPCs in the square unlabelled until adjacent. |
| Story and humour | 6 | Opening is all telling; Maren, Hob and Sable land; two tones that never meet in the opening. |
| Visual cohesion and readability | 7 | Consistent painted look everywhere; card text too small; damage numbers over names; ghosted banners; the Gainlands is hazy; an empty brown panel over Sable. |
| UI/UX consistency | 4 | E/Space close some popups and not others; Esc is Pause in battle but "skip the scene" in zone dialogue; P opened Pause in town; J inert in the forest; Deck button wanders. |
| Audio | n/a | Cannot judge from screenshots or logs. |
| Performance | 6 | No stutter in command timestamps; new game 10 s, dungeon 12 s, town ~22 s, zone ~15 s on this slow PC. |
| Bugs | 5 | No script errors, but: banners behind cards, doubled "YOUR TURN", empty QUEST UPDATED panel, font-test labels, sticky tooltip, pilot/Esc trap, black dev arena, truncated stall text. |

## Findings per area

### First 5 minutes
- `c12a_01_title.png`: the title is the best screen in the game. Four Path icons on a path, a warm painted vista, a clear menu. Promise: a cosy, colourful RPG.
- `c12a_02_wake.png`: the wake-up still is excellent. But from "You wake in a forest clearing" to "Choose your Path" I counted **22 E taps** (run c12b log), each with a typewriter. Narration in the second person, then first-person monologue ("I search for my name..."), then the Rescuer. Two voices for one character in two minutes.
- The Rescuer's lines are all exposition ("The path-ologists are hunting us", "Behind me is the Forgotten Cave. Follow it all the way through to Crosspath"). The player never answers or chooses until the Path screen.
- `c12b_31_path_screen.png`: the Path screen is clear and attractive, but the three card thumbnails per Path are **unreadable** (names ~6 px). The one-line pitches are good ("Hit hard and early. Save up Iron, then spend it all on one big swing.").
- `c12b_33_path_more.png`: More is a wall of 11-pt text: "Starting deck, 45 cards: 19 Beefcake Infrastructure, 17 units, 6 spells, 1 trap, 2 tools" plus 15 card names. Infrastructure has not been explained yet. The Necrocrat text is denser still ("orderly and value-grinding: small tokens, reanimation, drain, delayed but inevitable effects, taxes and fees, Red Tape and Contracts").
- `c12b_35_after_begin.png`: a "Feat: Leaves in Your Hair - Menu > Feats" banner pops during the Rescuer's farewell. An achievement for pressing E 22 times, over a story beat.

### Clarity
- Hover tooltips are good: `c12f_05_hover_card.png` shows the enlarged card plus the Iron explanation; `c12n_04_t1_played.png` adds a contextual rule line ("One infrastructure per turn"). The Glossary (`c12g_13_pilot_end.png`) is complete.
- The boss preview (`c12h_13_boss_intro1.png`: "Hollow Warden, 3 HP. Reward: 200 gold and XP, a choice of card. The Warden Stirs: at half health...") and the "Before the fight" rules card (`c12k_05_boss4.png`) are more than StS tells you.
- The zone HUD (`c12m_01_zone_arrive.png`) shows "Zone HP: no healing after battles" and two zone-effect icons. Clear.
- The defeat screen (`c12n_16_result.png`) is excellent: "Leg Day Survivor dealt 19 of the 22 damage you took (3 hits). Tip: block it with a unit you can afford to lose, or trade with it early." The **victory** screen has no such recap ("You defeated Cave Scavenger in 13 turns", `c12f_09_pilot90.png`).
- The stall's tip (`c12s_02_cards.png`) explains copy caps and "???" cards in three lines; "Own 2/3" and "Max" under each card are exactly the right amount of information.
- Not taught in the moment: that infrastructure is persistent energy (the Energy tip appears *after* the first play, `c12g_02_played_card.png`); what the four token counters top-right are; why the enemy has 3 HP and you 15; that playing an infrastructure uses your one-per-turn allowance ("You have 1 energy left and can still play 2 cards", `c12g_05_space2.png`).

### Pacing and friction
- The forest: `c12d_02_walk2.png` shows the "trees are too dense" barrier with the cave's glowing circle just left of the player; `c12d_09_e6.png` shows me wedged in the eastern tree wall with the circle at the top of a staircase I could not reach. Three attempts (c12c, c12d, c12e), never entered on foot; used the dev jump. The walkable strip to the stairs is one character wide and the isometric camera hides the hero behind foliage.
- Duel length: pilot 13 turns vs 3 HP (c12f), 7 turns as Necrocrat (c12j), **16 turns and a loss** vs 4 HP Quota Spotter (c12n, `c12n_15_pilot.png`: eight infrastructure cards per side, enemy at 1 HP). The zone says HP does not heal between fights, so a 16-turn fight that costs 22 damage is the whole run. The tutorial enemy should die in 3-4 turns.
- Modals: `c12g_05_space2.png` has the **"End your turn?" confirm and the "Play a unit" tip open on top of each other**, the tip covering the confirm's buttons. In `c12n_12_t2_resolved.png` a faded "Play a unit" tip sits mid-screen under a doubled "YOUR TURN" banner. In the stall (`c12s_02_cards.png`) the tip covers the third row of cards.
- Popup conventions: the Hollow Well result (`c12h_06_well2.png`) only closes via the mouse "Continue"; E and Space do nothing, so `skip_dialogue` stalled for the rest of run c12h. Dialogue closes on E; tips need "Got it"; the level-up says "Click or press Enter - Esc skips" (`c12k_13_after2.png`); zone dialogue says "Esc: skip the scene" (`c12m_13_zone_e2.png`); in battle and in the opening Esc opens Pause (`c12a_18_after_begin.png`). Five conventions.
- Pause > Glossary opened over a live battle (c12g) and only its Back button closed it; the pilot sat "stuck on turn 3" for 70 s.
- Town navigation: the goal is "Sable's Cards, on the west side of Crosspath's square" but the map is black outside the few metres you have walked (`c12l_07_map.png`, `c12o_05_map.png`); I walked the wrong way for a whole run (c12o) before the "Where to?" dropdown (`c12q_01_where_to.png`) listed every destination. That list is the fix; it should be the default view.
- Loads on this PC: new game 10 s, dungeon 12 s, town ~22 s, zone ~15 s (`play.log` timestamps), black screens with no progress indication.
- Run c12l: after Maren's conversation and a Pause toggle my three `hold` walks did not move the hero at all (`c12l_11_walk_a.png` and the next shot are identical). In c12q the hero stuck against a flowerbed by Sable's door and E did nothing. Collision edges near interactables need a look.

### Combat depth and feel
- The system is a real one: hand of 5, infrastructure as persistent energy with a one-per-turn cap, units with attack/defense, a combat phase where you click attackers and the AI blocks, resource tokens (Iron +1/+1, Red Tape -2/-0), traps (Tripwire, Ambush Party), Hustle / Flying / Sucker Punch keywords that matter. The Necrocrat deck (`c12j_06_t1_played.png`) plays differently from Beefcake. More texture than Pokemon TCG Pocket's first hour.
- Feel: cards slide, "Cave Scavenger plays Cannon Fodder" with the card enlarged (`c12f_06_pilot20.png`) is a nice beat, phases are listed on the right. But: "VICTORY!" renders **behind** units (`c12f_09_pilot90.png`, `c12j_10_pilot.png`) and so does "DEFEAT" (`c12n_15_pilot.png`); "YOUR TURN" draws twice, offset (`c12n_12_t2_resolved.png`); damage floaters ("-3", "-2") sit over the name plates; a card tooltip persisted after the mouse left it (`c12g_10_t2_attack_click.png`).
- The `dev encounter` fight had a **black arena** with no background (`c12n_04_t1_played.png`) where the cave fights had painted ground. Possibly a debug-start artefact; if a real Gainlands fight looks like this it is a bug.
- Board clog is the dominant impression of every fight after turn 6: rows of identical Powerhouse / Brass Forge cards (`c12f_08_pilot60.png`, `c12n_15_pilot.png`). Hearthstone hides mana as crystals for a reason.
- Why I lost in c12n: Leg Day Survivor (4/2 Hustle) hit three times and nothing in my hand could block profitably; by hand I could not make clicking my units register an attack on turn 2 (enemy still at 4 HP on turn 5, `c12n_12_t2_resolved.png`). The pilot then played 25 decisions and still lost. Either attacking needs a clearer affordance than "click a unit" or the tutorial should force one attack.

### Deck building and shops
- `c12i_09_deck.png`: Deck Station is the most complete screen in the game: colour / type / cost / rarity filters, copy caps, mana curve, "Fill Infrastructure" and "Suggest a deck", rack slots. Also the densest: 25 filter buttons, four slots labelled "Level 7" / "Level 14" at level 1, and a tip panel over the bottom rack.
- Sable's stall (`c12r_08_e7.png`, `c12s_02_cards.png`): a lovely two-choice front page (Cards / Card Packs), ten cards at 30 gold (60 for an uncommon), "Own x/3", "Max" when capped, "???" for unrevealed stock, a quip in the corner that changes per page ("The misprints on the wall are not for sale. (They are, but you can't afford them.)"). The packs page (`c12s_07_packs.png`): a General Pack at 100 gold with Buy / Buy & open and a locked tier "at level 10, or once two zones are free". This is the best-presented shop I have seen in an indie deckbuilder. Buying is untested (my click landed on the portrait).
- The quip truncates on the packs page: "(They are, but you can" (`c12s_07_packs.png`).
- Card art is strong and consistent; flavour lines land ("Punches first. Asks questions never.", "Even in death, he files.", "Built when the four Paths still worked together. It remembers.").
- Reward pick (`c12h_02_reward.png`): three cards, "Weight Belt joins your deck", keyword explained under the cards, Take / Skip. Exactly right.
- Wardrobe (c12o log): Hat / Cloak / Cloak dye with "Nothing yet: Pip Threadwell sells them in town." Good empty state. Packs (`c12p_14_packs.png`): an empty purple screen with one line and a tip; serviceable.

### Reward rhythm
- 120 gold to start; +40 gold +15 XP for the first fight; boss +120 XP and two levels at once (`c12k_13_after2.png`: "Looking sharp", Bowler Hat cosmetic, 60 gold, XP bar to level 4). The level-up is one of the best-feeling screens: big number, sunburst, one line of flavour, next-level bar.
- Hollow Well (`c12h_05_well.png`): "about 69 % to pass", exact draw shown, Inscryption-grade text ("it answers with water"). It then said "You were already at full HP, so there was nothing to mend" - a node that does nothing when you are healthy should offer an alternative.
- The Meet the Merchants quest (`c12l_06_quests.png`): clear description, objectives, "Where to go: Sable's Cards, on the west side of Crosspath's square", rewards listed ("Participation Trophy, 50 gold, 40 XP"), "Everyone gets the trophy." Talking to Sable ticks the step live in the HUD (`c12r_06_e5.png`). Good voice, good UI.

### Exploration and world
- Forest (`c12c_03_quest_log.png`): moody teal, lantern-lit bedroll, the arch glowing. Beautiful and empty; nothing to pick up or read.
- `c12e_04_dungeon.png`: the dungeon map is the strongest single piece of art after the title. `c12k_02_boss1.png`: the Hollow Warden's portrait over the map is superb and his three lines ("Only one may pass, and he is long dead.") are the right length.
- Cave exit (`c12k` log): "Daylight at last. Your deck is whole, and the way out is open." then "Step outside". Nice.
- Crosspath arrival (`c12k_16_after5.png`, `c12k_24_arrive8.png`): Elder Maren the tortoise is the first character with a voice ("I said I'd help whoever she sends along, not take in a stray", "a body in that state needs a bed, and I have far too much pie"). The quest tracker appears top-left. The town is warm Octopath-style, with bark bubbles from townsfolk (`c12p_05_walk3.png`: "Flour in my whiskers again. Occupational dusting."). But the near rooftops are heavily blurred (depth of field) and the square's glowing NPCs have no labels until you are adjacent (`c12i_14_walk2.png`); the zone, by contrast, shows a name tag and "[E] Talk" from a distance (`c12m_10_zone_walk2.png`), and Sable's door does too once you are close.
- Town map (`c12l_07_map.png`): 95 % black on arrival with a goal dot. Fog of war in the first hub town is the opposite of what Sea of Stars does; the first thing a player needs is to see where the shops are. The "Where to?" dropdown (`c12q_01_where_to.png`) lists 16 destinations including the four zone exits and six "Challengers" - that is the right information, hidden behind a button that looks like a label.
- The Gainlands (`c12m_01_zone_arrive.png`): a sudden shift to saturated low-poly desert, a bridge entrance, a gym temple. It reads as a different game from the painted cave and town; it is also hazy / low-contrast as if a fog volume sits over everything.

### Story and humour
- Opening: earnest fantasy mentor. Town: Maren's dry warmth, Sable's theatrical patter ("Sable, darling: seller of cards, and of very good stories about cards.", "My prices are fair, mostly. Primm's taxes are not."). Zone: Old Hob the Gravedigger ("Just measuring. Lovely broad shoulders round here. Very roomy work. Heh.", `c12m_13_zone_e2.png`) with a perfect portrait. Cards: jokes. The game's actual voice is everything after the opening; the opening hides it.
- "Path-ologists", four Paths named Beefcake / Gourmand / Refusemancer / Necrocrat, "We solve everything here with cards", "Primm's taxes" - a strong comic premise that the first five minutes never use.
- Second-person narration then first-person monologue then dialogue in one scene is a craft issue; pick one.

### Visual cohesion and readability
- Cohesive painted style across title, stills, map, town, stall, battle table; UI frames consistent. 7/10 on looks alone.
- Readability problems: card text in hand ~9 px (`c12f_01_fight_start.png`), Path thumbnails unreadable, More text 11 px, damage numbers over names, doubled "YOUR TURN", Deck Station and stall tips over content, town DOF blur, the Gainlands haze.
- `c12r_02_e1.png`: the "QUEST UPDATED - Meet the Merchants" notice is a **full-height empty brown panel** (380 x 880 px) with two lines of text at the top, drawn over Sable's portrait and over the first half of her dialogue line. It is the first thing a player sees when they complete their first objective.
- `c12i_07_quests.png` (dev-jump arrival, empty log): "Nothing here right now." beside a huge empty brown rectangle. With a quest the same screen is fine (`c12l_06_quests.png`); hide the panel when empty.

### UI/UX consistency
- Closing conventions differ by popup (see Pacing). Esc means Pause in battle and the opening, "skip the scene" in zone dialogue, "skips" on the level-up.
- J (quest log) did nothing in the forest (run c12c), works in town. P opened the **Pause menu** in town (run c12o, `c12o` log: shot `15_packs` shows "Paused"); Packs via the Menu button works (`c12p_14_packs.png`). T works.
- "Deck (B)" sits top-right in the forest, "Menu" top-right in town, "Deck (B)" bottom-left in the dungeon. The HUD Menu dropdown (`c12o_14_menu.png`) is good: eight entries with their keys.
- Battle has two end-turn affordances in different styles: a round "End Turn" button and a pill "End Turn [Space]" (`c12g_02_played_card.png`, `c12n_12_t2_resolved.png`).
- Hidden labels with font test strings (`"()-+/%&`, `6789 .,:;!?'`, `YZ abcdefghi`) appear in the town HUD scene tree on arrival (c12i and c12k logs). Not visible in the PNGs at that size; smells like a font-warmup label that should be removed from the tree.

### Audio
- Cannot judge from screenshots or logs.

### Performance
- No long gaps between consecutive commands in any `play.log` beyond the loads listed. Godot reports leaked RIDs/ObjectDB instances at every exit (19 runs) - harmless to the player, worth a look.

### Bugs seen
1. "VICTORY!" / "DEFEAT" rendered behind units (`c12f_09_pilot90.png`, `c12j_10_pilot.png`, `c12n_15_pilot.png`).
2. "YOUR TURN" banner drawn twice, offset (`c12n_12_t2_resolved.png`).
3. "QUEST UPDATED" notice is a full-height empty panel over the NPC portrait and dialogue (`c12r_02_e1.png`).
4. Card hover tooltip persists after the mouse leaves (`c12g_10_t2_attack_click.png`).
5. "Play a unit" tip opens over the "End your turn?" confirm (`c12g_05_space2.png`); a faded tip lingers mid-screen (`c12n_12_t2_resolved.png`).
6. Damage floaters over the name plates (`c12f_09_pilot90.png`, `c12n_15_pilot.png`).
7. Pause > Glossary opens over a live battle; Back is the only way out (c12g).
8. Quest Log empty state with a blank panel (`c12i_07_quests.png`).
9. Font test-string labels in the town HUD tree (c12i, c12k logs).
10. J inert in the starting forest (c12c); P opens Pause in town (c12o).
11. Forest walk: hero wedges into the tree wall east of the cave arch and vanishes behind foliage (`c12d_09_e6.png`); hero sticks on a flowerbed beside Sable's door (c12q).
12. Feat banner pops during a story line (`c12b_35_after_begin.png`).
13. `dev encounter` fight has a black arena (`c12n_04_t1_played.png`) - check real zone fights.
14. Hollow Well result popup ignores E/Space (`c12h_06_well2.png`).
15. Walk inputs ignored after Maren's conversation / Pause toggle (c12l).
16. Stall quip truncated on the packs page (`c12s_07_packs.png`).

## Top 15 problems (ranked by impact on a new player's enjoyment and retention)

1. **Duels run 7-16 turns against 3-4 HP enemies, and the board clogs with infrastructure.** Where: `c12f_08_pilot60.png` (turn 13, six Powerhouses each side), `c12n_15_pilot.png` (turn 16, eight each, lost with the enemy at 1 HP). Why: combat is the loop; if the tutorial fight feels like a slog nothing after it matters. Fix: show infrastructure as a stack with a counter (Hearthstone crystals) instead of a row of cards; give tutorial enemies 2-3 HP and no infrastructure; start the player with two infrastructure on the table; tune so cave fights end by turn 4 and zone fights by turn 8.

2. **The opening is 22 taps of exposition before any choice.** Where: `c12a_02_wake.png` through run c12b's log. Why: StS and Inscryption put a decision in front of you inside a minute. Fix: cut to eight lines; move the cave directions into the cave's first node text; put the Path choice at line 6; let the player answer the Rescuer once (two options); give the Rescuer one line in the voice Maren and Sable already have.

3. **You cannot find your way into the cave on foot.** Where: `c12d_02_walk2.png`, `c12d_09_e6.png`. Why: the only exit is a one-tile strip hidden by foliage; I failed three times. Fix: widen the path to the stairs to three tiles, paint a lit footpath from the bedroll to the arch, fade foliage that occludes the hero, show "E - Enter the Forgotten Cave" from 3 m away (the zone and Sable's door already do this).

4. **Tutorial modals stack and linger, and tips cover content.** Where: `c12g_05_space2.png` ("Play a unit" over "End your turn?"), `c12n_12_t2_resolved.png` (faded tip under a doubled banner), `c12s_02_cards.png` (tip over the stall's third row). Why: the first confirm dialog is unreadable and the tip points at the wrong thing. Fix: queue tips; never show a tip while a confirm is open; suppress the end-turn confirm on tutorial turns; clear a tip when its trigger is done; dock tips in a strip that does not overlap content.

5. **Popups obey different keys and Esc means three things; P opens Pause.** Where: `c12h_06_well2.png` (mouse only), `c12k_13_after2.png` ("Enter continues, Esc skips"), `c12m_13_zone_e2.png` ("Esc: skip the scene"), `c12a_18_after_begin.png` (Esc = Pause), run c12o (P = Pause in town). Why: the HUD teaches "E / Space / Click: interact" and then breaks it; controller players will be stuck on the Well. Fix: every popup's primary button accepts E/Space/Enter; Esc closes or skips the top-most thing and opens Pause only when nothing is open; audit every HUD hotkey in every scene.

6. **VICTORY! / DEFEAT / YOUR TURN banners render behind cards or twice; QUEST UPDATED is an empty wall.** Where: `c12f_09_pilot90.png`, `c12n_15_pilot.png`, `c12n_12_t2_resolved.png`, `c12r_02_e1.png`. Why: the payoff moments (winning, completing the first objective) look broken. Fix: banners on a CanvasLayer above the board, dim the board to 60 %, one instance per banner; shrink the quest notice to a 2-line toast that slides in under the tracker.

7. **No explanation of infrastructure/energy before the first card is played, and attacking is unclear.** Where: `c12g_02_played_card.png` (Energy tip after the play), `c12n_12_t2_resolved.png` (my unit clicks did not attack; enemy still 4 HP on turn 5). Why: the game's mana and attack model is unlike StS; the first decisions are blind. Fix: a one-screen "How a turn works" card before the first duel (infrastructure = energy orbs; drag units out; in Combat click units to attack, enemy blocks), and a pulsing outline on attack-ready units in the Combat phase.

8. **The town map is black fog on arrival and square NPCs have no labels.** Where: `c12l_07_map.png`, `c12o_05_map.png`, `c12i_14_walk2.png`. Why: the first errand is "find Sable's Cards"; I spent a whole run walking the wrong way. Fix: reveal the whole square on arrival (fog only outside town); make the "Where to?" list (`c12q_01_where_to.png`) the default right-hand panel; label shops on the map; show name tags and "[E] Talk" within 3 m in town as the zone does.

9. **The Path screen's thumbnails and More text are unreadable.** Where: `c12b_31_path_screen.png`, `c12b_33_path_more.png`. Why: the first hour's biggest decision is made on vibes. Fix: enlarge the three cards on hover in the bottom panel; replace the card list with three sentences and a strength/speed/complexity gauge.

10. **Esc + Glossary can trap a live battle.** Where: run c12g, `c12g_13_pilot_end.png`. Why: a player who opens Pause mid-fight and taps Glossary sees no battle and no obvious way back. Fix: Esc closes the Glossary; Pause shows the battle dimmed; "Resume" on every sub-screen.

11. **The victory screen does not explain what won, while the defeat screen does.** Where: `c12f_09_pilot90.png` vs `c12n_16_result.png`. Why: learning happens on wins too. Fix: reuse the "What beat you" box as "What won it" (top damage source, turns, HP lost).

12. **Card text at hand size is too small.** Where: `c12f_01_fight_start.png` (~9 px rules text). Why: hovering every card slows already slow turns. Fix: +20 % hand scale, 12 px minimum, keywords as icon + word, first line only on the small card.

13. **Damage numbers and tooltips overlap the HUD.** Where: `c12n_15_pilot.png` ("-3" over "You"), `c12g_10_t2_attack_click.png`. Fix: float numbers from the heart, not the name; clear tooltips on mouse-exit and drag start.

14. **The Deck Station shouts locked content at a level-1 player.** Where: `c12i_09_deck.png`. Fix: a "Simple" first view until level 5; collapse locked slots into one chip; move the tip to a "?" button.

15. **The Gainlands looks like a different game and is hazy.** Where: `c12m_01_zone_arrive.png` vs `c12e_04_dungeon.png`. Why: the first zone is where retention is decided; the style break and the fog volume make it read as unfinished. Fix: reduce the fog/haze, raise ground contrast, add the painted overlay treatment the cave and town use.

Smaller notes for the backlog: the Feat banner during a story line; the Hollow Well does nothing at full HP; "Deck (B)" moves around the screen; two End Turn buttons in one battle screen; font test-string labels in the town HUD; J inert in the forest; the heavy DOF blur over the near third of Crosspath; "Skip tips" beside "Got it" on every tip so a misclick kills the whole tutorial; the empty quest-log panel; the dev-encounter black arena; walk inputs ignored after the Maren scene; the hero sticking on the flowerbed by Sable's door; the truncated stall quip on the packs page; shop buying untested.
