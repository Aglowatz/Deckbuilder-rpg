# Midgame critic: The Wayward Path, v1.0.0-rc1 exported build (Nov 10)

## 1. Summary

The midgame looks good up close and plays badly between the beautiful parts. The Endless Buffet's painted portraits (Basil, Madame Mirepoix, the Grand Chef), the Test Kitchen's node map and the Doppelganger unmasking are the best things I saw, and the writing has a real voice. Getting to those moments is the problem. The zone's 3D hub hides its own NPCs behind props and fountains. Big props fade into milky white sheets that wash out the screen. The route to the main dungeon is gated behind a fetch quest that names its items but not where they are. Then the dungeon flattened this level-14 hero three times in three fights: two first-row fights and the boss, all lost. The battle board is readable once units are down, but played infrastructure sits as tiny cards half-hidden behind the hand, and the boss fills the table with 8+ units. Losing sends you back to the zone entrance and restarts the whole dungeon. The game rarely feels broken, but the midgame is hard to navigate and very hard to win.

**How I played.** 16 runs, about 30 minutes of game time in total (less than the 45 asked for: about 8 runs went on finding my way and learning the battle input). I started from snapshot `bot_refusemancer_enter_gourmand` (level 14, at the Buffet's entrance bridge).
- **Walked like a player (m1-m8):** the Grand Pantry hub, the Soup Fountain, the Fortune Cookie, Basil (main favour quest "Mend the Meatloaf"), Madame Mirepoix's shop (Cards and Gear), the Deck Station (B), the Character page (C), the quest log (J), Card Packs (P), the map and its "Where to?" list, the jelly pad, the gravy pit, the sea-salt area. I also walked north to Sir Loin's golem gate in front of Layer-Cake Town, the route to the Test Kitchen.
- **Jumped to the dungeon (m9-m11):** the gate does not open until Old Meatloaf is mended, and after several runs I could not find the black truffle (no marker for it on the map or minimap). So I used `dev travel dungeon D-TTK`, as the brief allows.
- **First-row fights (m10, m11):** I played the opening turns myself with clicks and drags (playing infrastructure, a Wonder and units, trying combat), then let `pilot` finish. Both were lost: Prep Station Sous-Chef (enemy at 14 HP, me at 22) and Frozen Line Cook (15 HP).
- **Boss (m12, m13):** I read the boss intro after `dev travel dungeon D-TTK -2`. The boss fight was piloted at 2x speed and lost.
- **Boss win (m14, m15):** `dev win` on the boss so I could see the victory, the card pick, the zone-freed screen and what the game asks next.
- **After (m16):** the quest log and post-freedom NPC lines.

Snapshots saved: `m2a`, `m5` (after accepting Basil's quest), `m15` (Buffet freed).

No SCRIPT ERROR appeared in any of the 16 game logs.

## 2. Scores

- **Clarity: 5/10.** Menus, tips, the rules panel and the defeat recap ("Cake Golem dealt 21 of the 24 damage you took") are clear. The world isn't: NPCs are hidden behind props (m5_11_after, m2_03_square2), quest items have no marker, the map's labels pile on top of each other (m1_03_map, m4_01_whereto), and the battle board hides played infrastructure under the hand (m9_10_t1, m10_14_combat).
- **Fun: 4/10.** The writing and the boss reveal are a treat (m12_08_intro6, m5_05_basil3). But the core loop here was three losses in a row at the recommended level ("usually level 14", m7_01_wt_pick), each one restarting the dungeon, plus a fetch-quest gate with no guidance. Walking the hub costs HP in a no-healing zone: a meatball bonks you for 2 on every arrival (m1_08_walk1), and the gravy pit takes 1 more (m8_03_nw).
- **Polish: 6/10.** The 2D art is lovely: card art, portraits, the dungeon map, the victory panel. The 3D world drags it down: huge translucent white occluder sheets (m7_06), flat dark stone cubes and low-poly salt shakers beside painted sprites (m2_11_east, m2_03_square2), and toasts drawn over the HP panel (m5_14_after, m15_06_back).
- **Broken:**
  - After a defeat, back in the zone, Old Hob the Gravedigger's full portrait sits over the scene with no dialogue box or text (m11_05_after, m13_05_after, both times).
  - The zone counters disagree. Before the boss the quest log said "Free the Four Zones 2/6" (m1_05_quests) while "Fragments" said 3/4. After beating only the Buffet boss, all four zones show as beaten, including the Verdant Dump, which I never touched, and the banner says "4 of 4 zones free" (m15_06_back, m16_01_quests).
- **Unfinished or obviously AI-made:**
  - Flat 3D stand-ins: a big dark brick cube in the hub (m2_03_square2, m2_11_east), plain white salt-shaker columns, and a low-poly roast chicken and props (m8_03_nw) beside painted sprites and portraits.
  - The Gear shop holds three items in an otherwise empty screen (m6_06_gear).
  - A few lines read like templates: "The Endless Buffet is free. Its people have new things to say - and the dungeons still pay gold and XP."
  - Most of the writing does not read as template.

## 3. Top 10 problems

1. **The midgame dungeon is lost at the recommended level, and every loss restarts it (major).** I lost to Prep Station Sous-Chef (m10_16_result), Frozen Line Cook (m11_04_result) and the Doppelganger (m13_04_result). The first two were first-row nodes with 14-15 HP against my 22. The rules stack against a Refusemancer deck ("Dress Code Violation: Refusemancer units -1 attack", m9_03_rules). The boss adds +1/+1 and a free unit, and fields 8 units by round 4 (m13_01_prefight, m13_03_mid). The defeat panel says "the dungeon starts over" (m10_16_result). Smallest fix: let a defeat send you back to the last cleared node, not the entrance, or soften the off-Path penalty in the zone's own dungeon. Caveat: my turns were clumsy and the pilot finished each fight. Still, three for three is a warning.
2. **The route to the main dungeon is gated by a fetch quest with no guidance (major).** Sir Loin blocks the Layer-Cake Town gate until Old Meatloaf is mended "with sea salt and a black truffle" (m7_09, m7_14_pastgate). The map marks Meatloaf but neither ingredient (m7_01_wt_pick), and the "Where to?" list has no entries for them (m4_01_whereto). I could not find the truffle in several runs. Smallest fix: put both pickups on the map, the minimap and the "Where to?" list once the quest is taken.
3. **NPCs are hidden behind props (major).** Basil stands inside or behind a tiered fountain: only a red blob shows, and the [E] Talk prompt floats over the fountain (m5_11_after, m5_14_after). Sous-Chef Tarragon's name label floats over a salt shaker with nobody visible (m2_03_square2). Pressing E at 2.3 m from Basil did nothing; clicking him worked. Smallest fix: move these two NPCs into open space, and extend E range to match click.
4. **Occluder fades become giant milky sheets (major polish).** Walking north of the hub turns half the screen into flat translucent white polygons (m7_06). Smallest fix: fade with dithering or a lower alpha, and cap the fade to the mesh's on-screen bounds.
5. **Battle board: played infrastructure sits as tiny cards tucked behind the hand (major clarity).** Infrastructure cards (your energy) appear as thumbnails overlapping the top of the hand (m9_10_t1, m9_13_t2, m10_14_combat). The enemy's sit at top centre, partly under its units (m13_03_mid). The two unit rows touch, with no clear midline (m9_13_t2). Smallest fix: give infrastructure its own visible tray beside the deck, with an energy counter.
6. **A lone NPC portrait sits over the zone after a defeat (major, broken).** Old Hob the Gravedigger's portrait sits over the scene with no dialogue box, twice, right after "Continue" on a defeat (m11_05_after, m13_05_after). Smallest fix: either show the bark box with it, or clear the portrait when a scene starts.
7. **The zone-freed counters disagree (major, broken).** Before: "Free the Four Zones 2/6" (m1_05_quests). After one boss: four ticks including the untouched Verdant Dump, "4 of 4 zones free", and "4/6" (m15_06_back, m16_01_quests). Smallest fix: audit which flags set the Dump objective and the "N of 4" banner. The two quests should count the same thing.
8. **Arrival and walking chip HP in a "no healing after battles" zone (minor).** A "runaway prototype meatball" hits for 2 HP on every arrival on the entrance bridge (m1_08_walk1), and the gravy pit takes 1 (m8_03_nw). It is funny once and annoying every load. Smallest fix: make it fire once per save, or cost no HP.
9. **The map is cramped and its labels collide (minor).** The Hearty Meal, Soup Fountain, Sous-Chef Tarragon and Beefcake Rift Express labels stack on each other (m1_03_map, m4_01_whereto). The "Where to?" dropdown spills over the legend. The Buffet's portal ripper is called "The Beefcake Rift Express". Smallest fix: offset or hide labels at small zoom, and show names on hover.
10. **Many small UI collisions (minor):**
    - "New quest" and "Quest updated" toasts are drawn over the HP panel (m5_14_after, m15_06_back).
    - The Refusemancer pack's Open button is cut off by the shelf frame (m1_06_packs).
    - The Rules popup opens over the Loading Dock node (m9_03_rules).
    - The boss node keeps its "Unknown. Step on it to find out" tooltip under the boss's intro dialogue (m12_02_bossclick).
    - In battle, the "Rules of this fight" label is overdrawn by the extra rule icons (m13_03_mid).

    Smallest fix: one pass to move the toasts below the HP panel and give the shelf more height.

## 4. Smaller notes

- **SCRIPT ERROR:** none in play_m1.log through play_m16.log.
- **Deck Station:**
  - Nearly every card in a level-14 collection is tagged "NEW", including starter cards like Cannon Fodder (m6_08_deck). The tag loses its meaning.
  - The deck called "Refusemancer deck" uses a Beefcake strongman as its cover (m6_08_deck).
- **Tips:** the first-time tips (Opening Packs, Buying Cards, Buying Equipment, Building a Deck, Rules of this fight) all fire at level 14 on this snapshot (m1_06_packs, m6_04_cards, m6_06_gear, m6_08_deck). That may only be the snapshot's tip state.
- **End-turn confirm:** "End your turn? You can still play 1 card this turn" appeared while every card in hand said "Needs N energy; you have 0". The playable card was the infrastructure, but the message does not say so.
- **Key prompts in battle:** the main-phase button says "To Combat [Space]". With no units able to attack, Space jumped straight to Main 2 (m10_14_combat). That is fine, but it is not announced.
- **Sir Loin and Basil:** Sir Loin says "speak to Basil" even after you have taken Basil's quest (m7_09). After you accept Basil's favour, the toast "Basil has a favour to ask. Talk again." stays in the scene tree.
- **Boss rewards:** the main boss pays "+50 gold, +120 XP" plus a clear bonus of 50 (m14_02_win2), then a first-clear bonus of 150 gold and 100 XP plus packs (m15_06_back). The base number feels small for a zone boss.
- **Card pick:** E does not choose a card. You must click or press 1-3, then "Take" (m14_02_win2, m15_02_next). The glossary lines under the pick (Trap, Ingredient, Garbage) are very helpful.
- **Rules every fight:** the "Before the fight" rules panel repeats in full before every node fight (m9_04_node). It is good the first time and slow after that.
- **What the game asks next is clear:** "Find the resistance in the Crease (the manhole on the Gate Plaza)", "Go to the Capital", and Fragments says "see Elder Maren" (m15_06_back, m16_02_fourzones).
- **Gear shop:** "Sidegrade vs Trash Panda Tiara" and "Downgrade vs Quota's Stopwatch" are a nice comparison aid (m6_06_gear).

## 5. What worked

1. **The boss intro and the unmasking.** Painted stills, a clear rules preview (m13_01_prefight), and a line that lands: "Delicious is the word I was given for it. I say it often, and I have never known what it means." (m12_08_intro6). The aftermath with the real Grand Chef thawing out of the freezer is lovely.
2. **NPC portraits and voice.** Basil the nervous line cook (m5_03_basil1, m5_05_basil3), Mirepoix the cat card shark (m6_04_cards), and the shop banter.
3. **The Test Kitchen node map** (m9_02_map). It is gorgeous and readable, and the rooms get real names once you visit them (m12_02_bossclick).
4. **The defeat recap** (m10_16_result). It tells you exactly what killed you and how to answer it, and it promises that nothing is lost.
5. **The Character page, the quest log and the Card Packs shelf** (m1_04_char, m1_05_quests, m1_06_packs). They are clean, well laid out, and the quest log's "Where to go" line is just right.
