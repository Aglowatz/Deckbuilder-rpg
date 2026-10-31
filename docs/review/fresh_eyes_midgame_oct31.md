# The Wayward Path - fresh-eyes review of the mid and late game (Oct 31)

Reviewer: games critic / UX researcher with no prior knowledge of the project. Everything below is judged only from
what the scripted driver let me see and do (screenshots in `docs/review/fresh_eyes_midgame_oct31/`, scripts in
`docs/review/play_scripts/critic3_*.txt`). Build shown on the pause menu: **v0.4.8**.

## Summary

The Wayward Path has the bones of a lovely game and the surface of an expensive one. The painted dungeon maps (The Hall
of Final Approvals, The Test Kitchen, The Rotheart), the pack-opening table, the boss intro splashes and the story stills
are genuinely at the level of Slay the Spire's successors, and the writing (a ghost holding appeal number 4,000,213; a
boss whose "answer is no, the question is irrelevant"; a sous-chef "Fetcher of Things") lands more often than not.

But the moment a mid-game player stops looking and starts *doing*, the game stumbles on friction and incoherence that
the first-zone tutorial would never show you:

- With 1020 gold in hand, **the card vendor sells nothing** - every card in Sable's stall is a padlocked "???".
- The **town and zone maps are fog-of-war blobs with no building names**; after 90 seconds of walking Crosspath the
  map had revealed a coin-sized patch. I never found the Hall of Records or the item/equipment vendors or the tailor.
- Three different conventions to advance the game (E for dialogue, Space/Click for stills, a mouse-only Continue
  button for events and pre-fight rules, click-only pack tearing) mean the keyboard player gets stuck at every third
  screen.
- The Gourmand deck the snapshot gives you (19 of 45 cards are the same Feastforge infrastructure) **cannot put a boss
  under pressure**: Mortimer Grimsby ended a 10-turn fight at 30/30, Vivienne Quota at 26/26. Combat stalls into
  infrastructure-and-tool spam on both sides until a swarm of 2/2s ends it.
- The quest log says "Nothing here right now" while the HUD nags about someone waiting at the Forgotten Cave; the
  character screen shows five padlocked equipment slots with no hint of when they open; the HP number changes between
  14, 9 and 22 across three screens in five minutes.

Against Slay the Spire, Monster Train, Inscryption or Sea of Stars, the mid-game currently reads as a very
beautiful demo with the economy, wayfinding and input layer unfinished. Fixing the top five problems below would move
it from "I'd stop here" to "I'd keep going".

Overall: **5.2 / 10** (average of the scored areas; audio not scored).

## How I played

Eighteen scripted runs, about 2.5 hours of wall clock including reading screenshots and logs. Each run started at the
title screen, loaded a snapshot, and ran at most ~190 s of game time. No `SCRIPT ERROR` appeared in any `stdout.log`.

| Run | Script | What happened |
|---|---|---|
| c3_01 | critic3_01_town | `dev load midgame_l8` dropped me in the **opening forest**, not Crosspath (scene `StartingArea`). P/C/J/M did nothing there; only B (Deck Station) worked. |
| c3_02 | critic3_02_town | `dev travel town`; opened the Packs screen; pressing Open twice stacked two openers; Space/E do not tear a pack. |
| c3_03 | critic3_03_packs_menus | My own `dev save` made in Town **reloaded into the forest again**; run wasted. |
| c3_04 | critic3_04_packs_menus | Opened 8 packs by clicking (one Legendary), Character, Quest log, Map. |
| c3_05 | critic3_05_town_walk | Clicked the HUD Menu button; Esc opened Pause on top of it and the whole walk ran under the pause menu. |
| c3_06 | critic3_06_town_walk | Walked the square: Brindle the Baker, Townsfolk, signpost; map after walking. |
| c3_07 | critic3_07_shops | Walked behind a house, found "Sable - Cards" label; Deck Station filters, click/right-click, hover; Glossary. |
| c3_08 | critic3_08_vendor | Talked to Sable (4 lines) and opened her stall. |
| c3_09 | critic3_09_shop_dna | Sable's Cards page: all "???"; then `dev travel zone necrocrat`, the D.N.A. lobby, Rift Station popup. |
| c3_10 | critic3_10_dna | D.N.A. zone-effect tooltips, Rip Tearson, the Rift Express screen, `dev travel dungeon D-HFA`, map, rules. |
| c3_11 | critic3_11_hfa_nodes | Take-a-Number Kiosk event (read it), choice popup. |
| c3_12 | critic3_12_hfa_fight | Chose "Skip the queue" (boon); the result popup's Continue blocked everything after. |
| c3_13 | critic3_13_hfa_fight | Node click only shows a tooltip; `dev travel dungeon D-HFA -2`; Mortimer's intro (read it); pre-fight rules popup. |
| c3_14 | critic3_14_hfa_boss | Mortimer Grimsby fight with `pilot`: **defeat on turn 10, boss untouched at 30/30**. |
| c3_15 | critic3_15_buffet | `dev travel zone gourmand`, Grand Pantry, Madame Mirepoix, map; `D-TTK` map and rules; `-2`. |
| c3_16 | critic3_16_ttk_boss_dump | Test Kitchen boss intro stills (E does not advance them); `dev travel zone refusemancer`, Brother Bramble; `D-ROT` map, rules. |
| c3_17 | critic3_17_bosses | Test Kitchen boss: 8 stills + dialogue, fight never started inside the budget; **Compostella fight with pilot to turn 9 (10/22 vs my 12/14), then `dev win`**. |
| c3_18 | critic3_18_capital | `dev travel capital` (The Crease, HP 9/9); `dev encounter lieutenant` = Vivienne Quota, 10 turns, nobody damaged, `dev win`, Epic Relic drop; `dev encounter Primm` to turn 7 then `dev lose` to see the defeat screen. `dev travel dungeon D-PC -2` and `S-NECRO` **did nothing after a `dev encounter`** (I stayed at the Capital gate in Crosspath), so I did not see Primm's Castle's map or a side dungeon. |

Where I used `pilot`, `dev win`, `dev lose` or `dev travel ... -2` it is stated. I played the opening turns of the
Test Kitchen boss by hand in script 17 but the story stills ate the inputs (see Problem 3). I did not reach the
Collection Book / Hall of Records, the item/equipment vendors or the tailor because I could not find them (Problem 4).

## Scores (1-10, against Slay the Spire / Monster Train / Inscryption / Sea of Stars / Octopath / TCG Pocket)

| Area | Score | One-line reason |
|---|---|---|
| Clarity | 5 | Rules and boss events are *listed* well (pre-fight popup, hover icons, "What beat you" on the Primm defeat) but the rest contradicts itself: empty quest log vs HUD nag, three different HP numbers, duplicate "Red Tape Everywhere" lines, tips for "Your first duel" at a level-8 boss. |
| Pacing and friction | 4 | Every third screen needs a different key; mouse-only Continue popups; stacked pack openers; fog maps; walking 90 s revealed a coin of the town map; 8 stills before the Test Kitchen boss. |
| Combat depth and feel | 5 | The board, phase tracker and attack preview are solid; boss scripts (Temp Agency, The Mask Slips, Overgrowth) are good ideas. But two of three fights stalled for 10 turns with no damage dealt either way, and the starter-ish Gourmand deck has no clock. |
| Deck-building satisfaction | 6 | The Deck Station is the best screen in the game: filters, caps, hover keyword panel, racks. Held back by a four-row deck list for 26 cards, "Own 9999" on a card, Esc not always closing it, and a vendor with nothing to sell. |
| Reward rhythm | 4 | 1020 gold and nothing to buy; five padlocked gear slots with no unlock text; packs are fun but converted duplicates feel like nothing; a lieutenant drops an Epic relic the Character screen cannot equip (slot locked). |
| Exploration and world | 5 | The three zones *are* different (marble-and-void D.N.A., cheddar plateaus and gingham roads of the Buffet, violet compost of the Dump) and the dungeon maps are superb; but the overworld maps are useless blobs, dungeon entrances were only reachable by debug jump, and the D.N.A. lobby is a flat grey room in a black void. |
| Story and humour | 7 | Consistently the strongest area. Agnes Overdue, Mortimer's "four hundred years", the Rift cousins, Compostella "I am HUNGRY", the Doppelganger's face reveal still. A few lines repeat (Sable's second line twice) and the still text is clipped mid-word by the typewriter when you advance early. |
| Visual cohesion and readability | 7 | Card art, maps, pack table and boss splashes are excellent and cohesive. Readability bugs: doubled NPC name labels, boss nameplate wrapping over the HP heart, "-3" damage float over "YOU", legendary flash washes out the cards, zone-effect icons are 20 px and unlabeled. |
| UI/UX consistency | 4 | Five different "advance" conventions; Esc sometimes closes a screen, sometimes opens Pause over it; `Open` stays clickable under an opener; dungeon node click = tooltip, not travel; tips popups from the tutorial fire mid-boss. |
| Audio | n/a | Cannot judge from screenshots and logs. No audio-related errors appeared in `stdout.log`. |
| Performance | 6 | Zone jumps 6-10 s on this low-end PC, dungeon jumps ~4 s, no visible stutter in the timestamps, no script errors in 18 runs. Pilot decisions took ~1 s each, so AI turns are not slow. |
| Bugs | 4 | Snapshot loads into the wrong scene; pack opener stacking; dead hotkeys in the forest; doubled labels; "Own 9999"; text clipping; stale shop/card labels left in the UI tree after battles (seen in `dump` at the Capital gate). |

## Findings per area

### Clarity
- Good: the dungeon tip ("HP carries from fight to fight ... lose a duel and you wake at the hub"), the R rules panel
  (`c3_10_dna__14_hfa_rules.png`), the pre-fight rules popup with hover icons (`c3_13_hfa__18_boss_battle_start.png`),
  the event choices stating their mechanical effect in brackets (`c3_11_hfa__04_after_kiosk.png`), the Primm defeat
  screen's "What beat you: Militia dealt 9 of the 12 damage you took" (`c3_18_capital__16_primm_lose.png`). This is
  the right instinct and better than Slay the Spire's silence on why you died.
- Bad: the quest log is empty at level 8 (`c3_04_packs__14_quests.png`) while the HUD permanently reads "Someone is
  waiting at the mouth of the Forgotten Cave." Which is it? The Character screen shows five padlocks and "Item slots
  1/4" with no unlock levels (`c3_04_packs__13_character.png`). The HP pill shows 14/14 in the D.N.A. and Buffet,
  9/9 in the Capital (`c3_18_capital__01_capital_arrival.png`), 14 in the lieutenant fight and 22 against Primm. The
  Mortimer rules popup lists "Red Tape Everywhere" twice with different numbers (one Red Tape / three Red Tape).
- The Mortimer defeat screen showed only "DEFEAT" and a "..." button for 5+ seconds with no analysis
  (`c3_14_boss__06_boss_d.png`), while the Primm defeat had the full panel. Inconsistent and, for the player who just
  lost 13 nodes of progress, the worst moment to be silent.
- Zone effects are two 20-px icons top-left; they explain themselves only on hover (`c3_10_dna__01_zone_effect_hover.png`),
  and the hover text is good ("Beefcakes do things on the spot, which here requires a permit, in triplicate").

### Pacing and friction
- The snapshot itself loads into the starting forest where P/C/J/M are dead keys (`c3_01_town__01_town.png`); a
  player who saved there would think the menus are broken.
- Pack opening: Space/E do nothing, the pack needs a click; pressing Open again while an opener is up stacks a second
  one (two sets of "Click to reveal" labels in the dump), and Esc peels one layer at a time
  (`c3_02_town__12_town_end.png` shows the stale second opener).
- The HUD "Menu" dropdown does not close on Esc; Esc opens Pause over it.
- Fog of war: 60-90 s of walking Crosspath revealed a thumb-sized patch (`c3_06_walk__11_map_explored.png`), and the
  revealed patch has no building names. The brief told me the map names the buildings; the map I saw does not.
- Dungeon map: clicking a node shows its tooltip (`c3_13_hfa__01_intake_click.png`) and nothing else; there is no
  "Enter" affordance, so I never learned whether it is double-click, a second click, or a key.
- Event result ("Boon: Cut the Line") and pre-fight rules both end in a mouse-only Continue; E/Space do nothing,
  `skip_dialogue` cannot clear them.
- Before the Test Kitchen boss: 3 dialogue lines, then at least 8 story stills ("Click / Space to continue") with
  dialogue boxes ("E / Click to continue") *layered on top of* stills (`c3_17_bosses__09_after_space.png` shows a
  still's text clipped mid-word under a dialogue box). The fight did not start inside a 60-second window of inputs.
- The Rift Express list has five "???" rows that all say the same sentence (`c3_10_dna__09_walk3.png`); fine once,
  tedious as a list.

### Combat depth and feel
- The board reads well: lanes, Zz for summoning sickness, keyword pills (Flying, Swat, Sucker Punch), a phase tracker
  with a one-line coach ("Second main phase / Play anything you held back"), a battle log button, speed button.
  Boss intro splash with a quote (`c3_14_boss__02_battle_start.png`) is Monster Train quality.
- Mortimer Grimsby: by turn 8 he had five units (two Zombie Temps, Audit Wraith 3/3 Flying, Filing Clerk, Infernal
  Intern) and I had a Meatloaf Mold and a row of Feastforges (`c3_14_boss__05_boss_c.png`). He finished at 30/30. The
  pilot is not a good player, but the deck it was given (19 Feastforge, Line Cooks, Soup Kitchen Volunteers) offers no
  removal and no reach; the boss's Temp Agency (+1 unit every second turn, +1/+0 to all) is a clock the player has no
  answer to. A mid-game boss should be lost on decisions, not on the deck list.
- Vivienne Quota: turn 10, 14 vs 26, zero damage either way (`c3_18_capital__08_lt_a.png`). She played three Tools
  and four Powerhouses and no units; my side sat behind a Shield Bearer. Ten turns of nothing is a pacing failure
  regardless of who is piloting.
- Compostella was the fight that worked: Overgrowth buffs stack visibly (Watchtower Archer 7/9, En Garde-Manger 6/7,
  `c3_17_bosses__21_rot_a.png`), the boss talks mid-fight ("...I am the bin you never empty..."), and by turn 9 it was
  10/22 vs 12/14 - a real race. This is what the other two should feel like.
- The scripted events read (Temp Agency, "Mortimer Files a Form", The Roots Spread, The Mask Slips) via a banner at
  the top of the board with a boss quote - good - but eight rule lines before a fight is a wall.
- "Needs 3 energy; you have 1 (each ready Infrastructure gives 1 a turn)" is a clear refusal message. Good.
- Tutorial tips still fire in boss fights at level 8: "Your first duel" (`c3_17_bosses__20_rot_battle.png`), "Attack!",
  "You made a Resource!" with Got it / Skip tips. These belong to the first hour.

### Deck-building satisfaction
- Deck Station (`c3_01_town__12_deck.png`, `c3_07_shops__13_wardrobe.png`): colour/type/cost filters, per-card
  "Deck 2/3 Own 2", legality checklist (45+ cards, caps, 2 Paths), Fill Infrastructure, named racks with level-locked
  slots (14, 14, 21, 21), hover zoom plus a keyword explainer ("Trap - Played face-down on your turn...",
  `c3_07_shops__10_after_rclick.png`). "You do not own another copy." is the right feedback.
- Problems: the right-hand deck list shows **four rows** of a 26-card list in a scroll box; the collection grid shows
  14 cards with no visible scrollbar; Spice Bazaar reads "Deck  Own 9999"; after Save Deck, Esc did not close the
  station and T did nothing (c3_07 shots 12-13).
- Packs (`c3_02_town__03_pack_opening.png`, `c3_02_town__07_pack2_after.png`, `c3_04_packs__09_tier2_a.png`): the
  velvet table, the tear, the NEW! stickers and the LEGENDARY! flash are TCG-Pocket-grade. Nine packs gave ~12 new
  cards including a Legendary trap. Duplicate conversion ("+2 Gourmand essence") is explained but essence has no
  visible use anywhere I went.
- Vendor: Sable's stall splits into Cards / Card Packs (`c3_08_vendor__07_shop_click.png`); the Cards page is 16
  padlocked "???" cards (`c3_09_shop_dna__02_shop_cards.png`). The tip says "Cards marked ??? unlock as you play" -
  at level 8 with the first zone freed, nothing had unlocked. 1020 gold with no sink.

### Reward rhythm
- Node tooltips state rewards up front ("35 gold and XP, no card choice"; boss "100 gold and XP, a choice of card").
  Good.
- Event choices are real trade-offs (heal 3 / 35 gold + curse / run-long boon). Good.
- The lieutenant dropped "Quota's Stopwatch - Epic Relic: You always take the first turn and draw an extra card on
  it. Max hand size +2" via a NEW GEAR! popup - a strong, legible reward - but the Relic slot on the Character screen is
  a padlock.
- XP bar at "0 / 380 XP to level 9" at level 8; I could not see what a level gives (copy caps grow, racks unlock at
  14 and 21 - the only hints).

### Exploration and world
- Crosspath (`c3_02_town__01_town.png`) is a handsome HD-2D square; the player silhouette shows through buildings
  (`c3_07_shops__03_vendor_side.png`). NPC barks are charming ("Flour in my whiskers again. Occupational dusting").
- The D.N.A. (`c3_09_shop_dna__08_dna_arrival.png`, `c3_10_dna__03_walk1.png`): a marble lobby with a red carpet and
  ghost clerks, surrounded by black void and flat grey tile. It reads as a greybox next to the Buffet and the Dump.
- The Buffet (`c3_15_buffet__01_buffet_arrival.png`, `c3_15_buffet__06_buffet_walk3.png`): cracker roads, cheese
  plateaus, broccoli trees, a jelly bounce pad on the map legend - distinct and funny.
- The Dump (`c3_16_ttk__12_dump_arrival.png`, `c3_16_ttk__14_dump_walk2.png`): violet-and-rust compost grange; the
  arrival banner warns "this place works against the Gourmand Path ... The Endless Buffet favours your Path - it may be
  the easier start" - excellent orientation.
- The Capital arrival is "The Crease", a brick cellar with a Rift (`c3_18_capital__01_capital_arrival.png`) and a
  "Broken services: 3 of 4" tracker - intriguing, but I could not judge the city itself in the budget.
- Dungeon maps (`c3_10_dna__13_hfa_map.png`, `c3_15_buffet__10_ttk_near_boss.png`, `c3_16_ttk__17_rot_map.png`) are
  the best art in the game and the node names are jokes in themselves (Coffin Breakroom, Weeping Compost Pool,
  Golem Assembly Line).
- I never found a dungeon entrance on foot; every dungeon was reached by `dev travel`. The zone maps show a
  "Exit / portal" icon but nothing marked as the dungeon.

### Story and humour
- Rip Tearson cousins (#2, #4 "the One Who Eats", #5 "Smells Fine", #7 "Allegedly") are a great running gag; the Rift
  Express blurb ("Rips are free. Beefcakes charge for spotting, and spotting is also free") is tight.
- Agnes Overdue and the Take-a-Number Kiosk are the best event I saw. Mortimer's intro ("You have, according to the
  clock, four hundred years") is a proper villain. Compostella's intro is read in one E-press per line and lands.
- The Doppelganger's face-slip still (`c3_17_bosses__09_after_space.png`) is a striking image - but it is the sixth
  screen in a row before the fight, and the still's caption is cut mid-word ("slip aw") when a dialogue box is
  stacked on it.
- Sable repeats her second line on the third E (c3_08 shots 03-04).

### Visual cohesion and readability
- Doubled NPC name labels: "Brindle the Baker" is drawn twice, the second copy covering the bark's last line
  (`c3_06_walk__05_northwest.png`); same for Brother Bramble (`c3_16_ttk__14_dump_walk2.png`).
- Boss nameplate "MORTIMER GRIMSBY, CE-No" wraps "No" over the HP heart (`c3_14_boss__05_boss_c.png`); the "-3"
  damage float sits on top of "YOU" (`c3_14_boss__06_boss_d.png`).
- Sable's bark box truncates ("The misprints on the wall are not for", `c3_08_vendor__07_shop_click.png`).
- The LEGENDARY! flash whites out the three cards for the whole beat (`c3_04_packs__09_tier2_a.png`).
- The Mortimer boss icon on the map is a red skull that reads as "locked" next to the padlocks.

### UI/UX consistency
- Advance conventions seen: `E / Click` (dialogue), `Click / Space` (stills), `Click, or press Enter / Space / E`
  (gear popup), mouse-only `Continue` (event results, pre-fight rules, victory/defeat), click-only (pack tearing,
  card reveal), `Got it` tips, `Any key to skip` (boss splash). Pick one.
- Esc: closes the Deck Station (run 1) but not after Save Deck (run 7); closes one pack opener layer; opens Pause on
  top of the Menu dropdown.
- Hotkeys P/C/J/M do nothing in the starting forest; B works.
- `dump` at the Capital gate after the lieutenant fight still listed "Sable's Card Stall", "What are you after?" and a
  "Back From the Heap - Legendary" card label: screens are being left in the tree after they are hidden.

### Audio
Not judgeable from this harness. Nothing in `stdout.log` about audio.

### Performance
- `dev travel zone` 6.3-8.8 s; `dev travel dungeon` 3-4 s; `dev travel town` ~6.5 s; `dev load` ~5 s. All on a slow PC.
- Pilot: 4-23 decisions per 8-45 s, i.e. ~1-2 s per AI/player action at Speed 1x. No visible hitches in timestamps.
- 0 `SCRIPT ERROR` across 18 runs.

### Bugs (list)
1. `dev load` of any snapshot (including one saved in Town) starts in `StartingArea`, not where it was saved.
2. P, C, J, M dead in `StartingArea`.
3. Pack opener stacks when Open is clicked while one is open; Esc closes one layer per press.
4. HUD Menu dropdown: Esc opens Pause instead of closing it.
5. NPC name label rendered twice.
6. Deck Station: "Deck  Own 9999" on Spice Bazaar; Esc did not close after Save Deck.
7. Boss nameplate text overflow; damage float over "YOU"; vendor bark truncation; still caption clipped under dialogue.
8. "Red Tape Everywhere" duplicated in the pre-fight rules.
9. Tutorial tips ("Your first duel", "Attack!", "You made a Resource!") fire in level-8 boss fights.
10. Mortimer defeat: no summary panel and a "..." button for 5+ s (Primm defeat had the panel).
11. HP shown as 14/14, 9/9, 14 and 22 across zone HUD, Capital HUD, lieutenant and Primm fights.
12. Quest log empty while HUD shows a quest hint.
13. Hidden screens left in the UI tree (shop labels at the Capital gate).
14. `dev travel dungeon` after a `dev encounter` did nothing (stayed at the Capital gate) - debug-only, but it cost me
    Primm's Castle and the side dungeon.

## Top 15 problems (ranked by impact on mid/late-game enjoyment and retention)

1. **The card vendor sells nothing.** Where: `c3_09_shop_dna__02_shop_cards.png` - 16 "???" padlocks at level 8 with
   1020 gold. Why: gold is the primary reward and it has no sink; the shop is the mid-game's deck-growth loop. Fix: at
   minimum unlock the Colorless commons and the player's Path's commons/uncommons by level (not by hidden flags); show
   the unlock condition on each "???" card ("Unlocks: clear The Hall of Final Approvals"); make Card Packs purchasable
   from the first visit.

2. **Boss fights stall; the given deck has no clock.** Where: `c3_14_boss__05_boss_c.png` / `06_boss_d.png` (Mortimer
   30/30 after 10 turns), `c3_18_capital__08_lt_a.png` (Vivienne 26/26 after 10 turns, three Tools, no units). Why: a
   boss you cannot dent is the number one reason to quit a deckbuilder. Fix: cap infrastructure at ~12 of 45 in the
   snapshot/starter deck and give every Path 2-3 cheap removal or direct-damage commons; make the AI prefer units over a
   fourth Tool when the board is empty; add a soft enrage (boss gains +1/+0 per turn after turn 8) so stalls resolve.

3. **Five different ways to say "continue".** Where: `c3_02_town__03_pack_opening.png` (click only),
   `c3_16_ttk__05_ttk_prefight.png` (Click/Space), `c3_13_hfa__18_boss_battle_start.png` and
   `c3_11_hfa__04_after_kiosk.png` result (mouse-only Continue), dialogue (E/Click). Why: keyboard and pad players get
   stuck; the brief's own `skip_dialogue` cannot get past them. Fix: one rule - E, Space, Enter and click all advance
   anything advanceable, Esc closes anything closable - and apply it to packs, stills, popups and Continue buttons.

4. **Maps do not help you find anything.** Where: `c3_04_packs__15_map.png`, `c3_06_walk__11_map_explored.png`,
   `c3_15_buffet__07_buffet_map.png`. Why: a mid-game player needs the Hall of Records, the tailor, the item vendor and
   the dungeon entrance; I found none of them. Fix: reveal the hub town fully once visited; label buildings and
   vendors by name on the map; mark the dungeon entrance with a distinct icon; add a "Where to?" list (like Octopath's
   town list) in the map legend that pings the location.

5. **The pre-fight funnel before a boss is too long and layered.** Where: Test Kitchen - 3 dialogue lines, 8+ stills,
   dialogue boxes over stills (`c3_17_bosses__09_after_space.png`), then a rules popup, then the splash. Why: it is
   the moment of highest tension and the game takes two minutes of clicking before the first card. Fix: cap the
   pre-boss story at three stills, never stack a dialogue box on a still, fold the boss's own rules into the splash
   (which already has his quote), and keep the zone rules on the R key.

6. **Quest log says nothing while the HUD nags.** Where: `c3_04_packs__14_quests.png` vs the permanent "Someone is
   waiting at the mouth of the Forgotten Cave." Why: a player at level 8 asks "what now?" and the game answers "Nothing
   here right now." Fix: always keep one main-quest entry ("Free a second Path zone: the Endless Buffet favours you")
   with a map ping; move the HUD hint into the tracked quest.

7. **Character screen is five padlocks.** Where: `c3_04_packs__13_character.png`; the lieutenant then drops an Epic
   Relic (`c3_18_capital__11_pc_map.png` popup) that cannot be equipped. Why: rewards you cannot use are worse than no
   rewards. Fix: print the unlock level/quest on each padlock; unlock at least Weapon and Relic by level 8; hover a
   padlock to see what gear exists for it.

8. **Pack opener stacking and dead hotkeys.** Where: `c3_02_town__12_town_end.png` (second opener left behind), run 1
   (P/C/J/M dead in the forest). Why: feels broken on first contact with the mid-game. Fix: disable Open while an
   opener is up; Esc closes the whole packs flow; enable the menu hotkeys in every walkable scene.

9. **Readability bugs on the board and in the world.** Where: `c3_06_walk__05_northwest.png` (doubled "Brindle the
   Baker" covering the bark), `c3_14_boss__05_boss_c.png` (nameplate wrapping over the heart),
   `c3_14_boss__06_boss_d.png` ("-3" over "YOU"), `c3_08_vendor__07_shop_click.png` (truncated bark). Why: these are the
   first things a reviewer screenshots. Fix: dedupe the name label, autoshrink nameplates, offset damage floats above
   the portrait, autoscroll or wrap vendor barks.

10. **Three HP numbers in five minutes.** Where: zone pill 14/14, Capital pill 9/9 (`c3_18_capital__01_capital_arrival.png`),
    lieutenant 14, Primm 22. Why: the "zone HP" rule is the mid-game's main risk system and the player cannot trust the
    number. Fix: one HP source of truth shown identically in zone, dungeon and battle; if the Capital or a boss changes
    max HP, say so in a banner.

11. **Mortimer defeat screen is silent.** Where: `c3_14_boss__06_boss_d.png` ("DEFEAT", button "..."), vs
    `c3_18_capital__16_primm_lose.png` which has "What beat you". Why: losing 13 nodes of a run with no explanation is
    the quit moment. Fix: always show the analysis panel, plus "retry the boss from the last shrine" as an option.

12. **Tutorial tips fire inside level-8 boss fights.** Where: `c3_17_bosses__20_rot_battle.png` ("Your first duel"),
    run 14 dump ("You made a Resource!", "Attack!"). Why: patronising and they block the pilot/keyboard. Fix: tips are
    once-ever per profile, not per snapshot; never show a tip on a boss node.

13. **Pre-fight rules popup overload and duplicate lines.** Where: `c3_13_hfa__18_boss_battle_start.png` - eight
    lines, "Red Tape Everywhere" twice. Why: nobody reads eight lines; the duplicate makes the player doubt the rest.
    Fix: merge zone rule + boss rule of the same name into one line ("Start with 1 Red Tape; this boss starts with 3"),
    show at most three boss lines and keep the icons' hover for the rest.

14. **The D.N.A. lobby looks like a greybox.** Where: `c3_09_shop_dna__08_dna_arrival.png`, `c3_10_dna__03_walk1.png`
    - black void walls, flat grey tile. Why: it is the first new zone a Gourmand player will try and it undersells the
    game next to the Buffet and the Dump. Fix: a ceiling/fog plane and wall dressing at the same density as the Buffet;
    even a painted backdrop like the Capital's lore still would do.

15. **Dungeon node interaction is unexplained.** Where: `c3_13_hfa__01_intake_click.png` - clicking a glowing node only
    shows its tooltip. Why: the first thing a player does on the map is click a node; nothing happens. Fix: single click
    = travel (with the tooltip on hover), or add an explicit "Enter" button in the tooltip and a glowing-node pulse.

### Honourable mentions (not top-15 but worth a ticket)
- Deck Station: deck list shows four rows; "Own 9999"; Esc after Save Deck.
- Essence has no visible use; the Character screen shows "4" Gourmand essence and nothing to spend it on.
- Hidden screens stay in the UI tree after battles (dump shows shop labels at the Capital gate).
- Rift Express "???" rows repeat the same sentence five times.
- Sable's second line repeats.
- The LEGENDARY! flash hides the cards it celebrates.
