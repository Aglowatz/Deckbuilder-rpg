# Fresh eyes: the mid game of The Wayward Path (v0.5.1) - 1 Nov 2026

Critic 13, no context beyond the brief. Played from `dev load midgame_real` (Beefcake, level 13, Crosspath, 600 gold) through the
scripted driver, 18 runs, 16:15-17:00 MST of play plus the write-up. Screenshots cited here are copied into
`docs/review/fresh_eyes_midgame_nov1/` with the run name as prefix (e.g. `c13g2_07_turn2.png`).

## Summary

The mid game looks like a finished, expensive game and plays like an early one. The painted dungeon maps (Test Kitchen, Rotheart,
Omakase), the rules popups, the character portraits and the pack-opening flow are all at or above Slay the Spire / Monster Train polish.
What is under them is slow and thin: a 15-HP line cook took the built-in player 26 turns to kill and the same fight, played by hand
plus the pilot, was lost; Omakase's first node beat me in 11 turns and the recap tip was "play more Infrastructure" - advice the game's
own deck-builder, hand and tutorial do nothing to make actionable. Zones are gorgeous dioramas with almost nobody to talk to (I met one
Buffet NPC and one Dump NPC, both the same Rift Express bodybuilder saying the same joke), the zone map opens fully black on arrival,
Crosspath's walking is unreliable right after a load, and the "Where to?" list is a list of Rift Express stations, not of places. Boss
intros are the best writing in the game and the boss fight that follows them was over in zero turns because I had to autowin to reach
it in time - which says something about how long the road there is.

Overall against the genre's best: **5.3 / 10** for the mid game. The art is a 9; the loop is a 4.

## How I played

| Run | What | Where | Notes |
|---|---|---|---|
| c13a | Town screens: packs (Open all, 12 packs), Character, Quest log, Map, Deck Station, two walks | Crosspath | Walking after load did not move the hero (see bugs) |
| c13b | Deck Station: New filter, hover, add, Suggest a deck; map; NPC | Crosspath | Esc after the Suggest dialog closed the station and opened the pause menu, so the rest of the run was spent in Paused |
| c13c | Map > Where to?; fountain NPC; walk west | Crosspath | Where to? did not open (click landed on the button but no list appeared in the shot) |
| c13d | `dev travel zone gourmand`, arrival dialogue, zone map | Endless Buffet | Zone map fully black on arrival; Where to? is at y 384 here, 457 in town |
| c13e | Buffet Where to?, walk north, E at the station (Rift Express unlock + screen), walk east | Endless Buffet | Never found a talkable NPC other than the Rift cousin; Tarragon's label was 2 m away but E went to the station |
| c13f | `D-TTK` enter, intro, rules (R), Loading Dock node, first fight (pilot) | Test Kitchen | Opening-hand popup ignored Space and a hand click |
| c13g | Walk-In Cooler fight by pilot (26 turns), Prep Station | Test Kitchen | 0 SCRIPT ERRORs in any run |
| c13g2 | Walk-In Cooler by hand (2 turns of drags/clicks) then pilot: **lost**, carried out, "Dish duty fee: 20 gold"; `D-TTK -2`, boss intro, `dev autowin on` for the Grand Kitchen | Test Kitchen / Buffet | Said so: autowin used for the boss |
| c13h | `dev travel zone refusemancer`, walk, talk, map; `D-ROT -2`, rules | Verdant Dump / Rotheart | |
| c13i | `dev travel zone necrocrat` look back, Percival Plume; `S-GOUR` map and rules | D.N.A. / Omakase | |
| c13j | Where to? pick; Brindle the Baker; fountain NPC | Crosspath | |
| c13k | Rotheart boss intro, `dev autowin on`, Victory in 0 turns, card choice | Rotheart | Said so: autowin |
| c13l, n, o, p, q, r | Six attempts to reach Sable (cards), Tilly Tonic (items), Foil Fenwick (packs), Pip Threadwell (clothes) on foot | Crosspath | Reached Sable's and Fenwick's greeting lines once (c13o); never saw a shop screen: E after the greeting opened nothing, Esc opened the pause menu |
| c13m | `S-GOUR` The Counter Seat by hand (3 drags) then pilot: **lost in 11 turns** | Omakase | Defeat recap shown |

Skipped for time: the tailor and the Collection Book (never reached a shop screen), the Buffet's road from Crosspath (used the jump), the
Rotheart's non-boss nodes by hand, the equipment vendor.

## Scores (1-10 against Slay the Spire, Inscryption, Monster Train, Sea of Stars, Octopath, TCG Pocket)

| Area | Score | One line |
|---|---|---|
| Clarity | 5 | Rules popups and the pre-fight card are excellent; why I lost and what "energy" means mid-fight are not |
| Pacing and friction | 3 | 26-turn trash fights, dead walking, popups that eat Space, Esc that opens the pause menu over a shop |
| Combat depth and feel | 4 | Lots of systems (Iron, Overtime, Hustle, Exhaust, refuse, tokens) but turns are "play Powerhouse, pass" |
| Deck-building | 6 | The Deck Station is good; the collection is not: 36 pack cards and no way to see what changed in my deck |
| Reward rhythm | 5 | 100 gold + card pick for a boss is fine; 0/465 XP to 14 after two zones is not; the "Dish duty fee" is a mystery tax |
| Exploration and world | 5 | Three distinct looks; nothing to find; the zone map is black and the town map is five islands |
| Story and humour | 7 | Boss intros and the Rift cousin are genuinely funny; most NPCs are one-liners you cannot talk to twice |
| Visual cohesion and readability | 8 | Dungeon maps, boards and popups are superb; hand text at 1600x900 is unreadable without hovering |
| UI/UX consistency | 4 | Esc means "close" in some screens and "pause" in others; Where to? moves between screens; two different Victory screens |
| Audio | n/a | Cannot judge from screenshots; nothing in the logs indicates music or SFX state |
| Performance | 6 | Load 8-18 s, zone jump 10-17 s, no stutter visible in timestamps; every exit leaks RIDs/textures (19 of 19 runs) |
| Bugs | 4 | Walking after load, Space on the opening hand, shops unreachable by E, Victory "in 0 turns", exit leaks |

## Findings per area

### Crosspath with a mid-game collection

- **Packs** (`c13a_02_packs.png`, `c13a_04_pack_result.png`): "Open all (12 packs)" is the right button and the result is a wall of 36
  names in two paragraphs. No card art, no rarity, no "add to deck" shortcut; two Feats pop in the top corner at the same time, stealing
  the moment. Pokemon TCG Pocket's one-at-a-time reveal is the bar; even Slay the Spire's three-card choice shows the cards.
- **Character** (`c13a_06_character.png`): clear and attractive. Equipped gear shows icons but no names or effects without hovering.
  "0 / 465 XP to level 14" after clearing two zones and their dungeons means the snapshot's player levelled exactly at the last fight,
  or XP is granular enough that the bar reads as empty most of the time; either way the first thing a returning player sees is an empty
  bar. Items list "Healing Salve (12 left)" next to "Equipped 0 / 2": the save never equipped an item. A mid-game player with 12 salves
  and empty slots is a UX failure, not a player failure.
- **Quest log** (`c13a_07_quests.png`): good. "Where to go: Elder Maren's home, up the Gate Road from Crosspath's square" is exactly the
  sentence the map should also say. "Free the Four Zones 2/5" (five objectives for four zones) reads as a typo.
- **Map** (`c13a_08_map.png`): five explored islands in a black field, names on the islands. The legend is fine; the "Where to?" line
  edit under it is a text box, not a list, and clicking it did nothing visible in three runs (c13c, c13j, c13l). "Fast travel..." works
  and opens the Rift Express. There is no "road to the Buffet" on the map; a player who has not been told the next zone is east has to
  walk into the dark.
- **Deck Station** (`c13a_09_deck.png`, `c13b_04_deck_suggest.png`): the best screen in the game. Filters, copy caps, curve histogram,
  colour count, deck racks, Fill Infrastructure and Suggest a deck. Two problems: the card list shows 14 cards and no scroll affordance,
  and after "Open all" there is no "New" badge count or "just opened" rack, so the 36 new cards are needles in a 9999-copy haystack
  (Old Kingdom Crossroads "Own 9999" is a visible placeholder). Esc from the Suggest dialog closed the whole station and then the pause
  menu opened (`c13b` log).
- **Shops**: the four stalls are labelled in the world (`c13o_06_e2.png`: "Sable - Cards", "Tilly Tonic - Items"; `c13q_06_near_foil.png`
  area: "Foil Fenwick - Packs", "Pip Threadwell - Clothes") and have good greeting lines ("Where's it from? The past, darling. Next
  question."). Pressing E twice got the greeting and a second line; a third E and a `button Shop` found nothing, and Esc opened the
  pause menu (`c13o_12_e4.png` is Fenwick's second line; c13l 08 is the pause menu). In six attempts I never saw a buy screen. Either the
  shop opens on a prompt I could not find, or it does not open from the greeting. The brief's player would conclude the stalls are decor.
- **NPCs**: Brindle the Baker ("I knead a holiday. Then I knead the dough. Busy, busy badger.", `c13j_07_left_npc_4.png`) and Townsfolk.
  One line each, then the same line again. The glow and the "[E] Talk" prompt are good.

### The Endless Buffet and The Test Kitchen

- **Arrival** (`c13g2_15_rewards.png` shows the arrival banner on a later return): a title banner, "Home of the Gourmand Path" and the two
  zone effects in one card. Clear. The "Zone HP: no healing after battles" strip under the HP bar is the kind of persistent rule text
  Slay the Spire never needed because its HP bar is the rule; here it works.
- **The zone** (`c13e_06_walk_nw.png`): a confectionery town built from cake, broccoli trees, a pink fountain and a lot of white
  blocking-out statues (the white silhouettes around the square read as unfinished props, not as design). The only interaction I found in
  ~12 s of walking was the Rift Station; Sous-Chef Tarragon stood two metres from me and E went to the station every time. The map on
  arrival is 100 % black (`c13d_07_buffet_map.png`) - a zone map that shows nothing is worse than no map; Octopath reveals the whole
  town on entry and only hides the field.
- **Rift Express** (`c13e_08_talk2.png`, `c13e_12_walk_e.png`): the funniest system in the game ("HNNNGH... Rip Tearson, Beefcake Rift
  Express, serving this exact spot. I'm a cousin; we hire entirely on relative strength."; "A cousin ripped it in, then asked if there
  were seconds."). The station list is clean. But I was ripped into the zone by a jump and the first E I pressed unlocked fast travel back
  out - the zone's first offered action is "leave".
- **Test Kitchen map** (`c13f_01_ttk_enter.png`, `c13f_06_ttk_rules.png`): a painting. Fifteen named rooms, locks on the ones you cannot
  reach yet, a boss skull at the Grand Kitchen, R shows four rules in plain words ([+]/[-]/[*] prefixes are a good touch). This is better
  than Slay the Spire's map and as good as Inscryption's. The only miss: the node icons (swords, locked swords, a hand) are not in the
  legend anywhere, and "Prototype Bay", "Corrupted Pantry" etc. give no hint of what kind of node they are until you click.
- **Fights** (`c13g2_03_after_drag_unit.png`, `c13g2_05_after_attack.png`, `c13g2_07_turn2.png`, `c13g2_10_t2_combat.png`): the board is
  gorgeous and the phase strip (Start / Main / Combat / Main 2 / End) with a one-line explanation of the current phase is clearer than
  Hearthstone. But: turn 1 I could play one Powerhouse (an infrastructure) and nothing else; turn 2 the same; the Frozen Line Cook played
  "Lunchbox" and passed. The built-in pilot needed **26 turns** to kill a 15-HP enemy (`c13g_11_after_fight.png`). My own attempt (two
  hand turns then pilot) **lost** and was carried out of the dungeon to the zone with "Dish duty fee: 20 gold (logged)" stamped over the
  arrival banner and Old Hob the gravedigger saying "Hm? You? Not on my list. Off you pop. Heh." - a defeat sequence that nobody
  explained (why a gravedigger, why 20 gold, why "logged"). Hovering a card gives a clear keyword box (Exhaust, Iron) - the best keyword
  tooltip in the genre, `c13g2_10_t2_combat.png` - but the hand text itself is 7-pt and unreadable at 1600x900.
- **Opening hand popup**: ignored Space and a click on a card; only the "Keep Hand" button worked (c13f/c13g logs). The HUD says Space
  confirms popups.
- **Boss** (`c13g2_17_near_boss.png`, `c13g2_18_boss_pre.png`, `c13g2_24_boss_battle.png`): the intro is the game's high point. The
  Grand Kitchen card lists Grand Chef Escoffina's four scripted events in plain language ("Mise en Place", "Setting Up: ... units do not
  attack. Watch what it builds", "No Face of Its Own: near the end the face it wore is gone"), the portrait is excellent, the line "She
  smiles the smile from every portrait in the Pantry. She has worn it for ten years without a crease" is a real sentence. Then the
  cut-out dialogue ("You never taste your own soup, do you?") plays over silhouettes on a gradient with no portraits - the one place the
  game drops its art. With autowin on, the fight itself was skipped; I cannot judge the boss as a fight and say so.

### Look back: the D.N.A.

`c13i_01_dna_arrive.png`, `c13i_04_dna_talk2.png`. A freed zone is a marble lobby, dark, with paper blowing across the floor and Percival
Plume, Deputy Minister, announcing "Great news, citizens! The D.N.A. has been freed, a change His Perfection fully supports and in fact
arranged!" and handing out a notarized Certificate of Participation. That is a good joke and it is the whole visit: no new vendor, no
changed music I can see, no reward on the map. The Rift Express station is the reason to come back. Freed should mean a new thing to do
here; in Sea of Stars a freed town changes its NPCs and opens a chest line.

### The Verdant Dump and The Rotheart

- `c13h_01_dump_arrive.png`, `c13h_03_dump_walk2.png`: a bridge into a purple-and-rust fairground with a windmill greenhouse and a
  cyan fountain; the palette is unlike the Buffet, which is the point. The first E again hit the Rift Station and the same cousin joke,
  with a new punchline ("then looked at his hands, then at the hole, then at his hands again" - good). The quest "Uproot Moss Mulligan
  at the thorn wall" is tracked but nothing on screen or on the (black) map points at a thorn wall.
- **Rotheart map** (`c13h_09_rot_rules.png`): a second painting, with a visible route and a heart-shaped boss tree. The rules card uses
  the same [+]/[-]/[*] grammar. The checkmarked nodes at `-2` show a cleared path.
- **Boss** (`c13k_09_rot_board.png`, `c13k_12_rot_reward.png`): Compostella's pre-fight card lists eight rules; the intro ("half woman
  and half tree. Roots run from her arms into the floor and out into every plant in the Dump"; the small voice: "Please. The tree. I could
  not let her go.") is the best writing I saw. Victory with autowin printed "You defeated Compostella, the Rotheart in 0 turns." - the
  recap should never print 0. The reward (100 gold, 120 XP, a three-card pick with Reroll 170 gold) is well presented; a Reroll that costs
  more than the gold you just won is a strange price.

### Omakase (side dungeon)

`c13m_01_counter_pre.png`, `c13m_03_turn1.png`, `c13m_07_turn2.png`, `c13m_10_end.png`. A sushi bar with koi ponds, two nodes (The
Counter Seat, Chef's Choice). Apprentice Itamae (13 HP). I kept a six-card hand, dragged three cards and only one landed (a Powerhouse);
"Needs 2 energy; you have 0 (each ready Infrastructure gives 1 a turn)" is a good inline message but it appeared after the drag, not
before. Turn 4 I had nine cards in hand, two infrastructures on the table and nothing to spend on. The pilot lost in 11 turns and the
recap ("Toro Toro dealt 15 of the 25 damage you took (3 hits). Tip: You played no Infrastructure on 3 of your 5 turns. Keep an opening
hand with 2 or 3 (mulligan one with fewer), and play one every turn you can.") is the most useful defeat screen in the genre - but it
diagnoses a deck problem the Deck Station's "Fill Infrastructure" button already claims to solve (19 infrastructure in 46 cards).
Something between the deck's ratio and the draws does not add up, and the player cannot see which.

### Audio

Cannot judge. No screenshot or log line shows a music or SFX state; nothing in the HUD indicates what is playing.

### Performance

`dev load` took 8-18 s (c13a 18 s, others ~8 s), a zone jump 10-17 s (the Dump 17 s), a dungeon entry ~5 s. No gaps in the command
timestamps that would suggest a hitch during play. Every run's `stdout.log` ends with the same engine errors
(`RenderingServer::get_singleton() is null`, leaked RIDs of type Texture / FontAdvanced, `70 ObjectDB instances were leaked at exit`,
one run `Pages in use exist at exit in PagedAllocator`) - exit-time leaks, harmless to the player, but a signal that scenes are not freed.
No `SCRIPT ERROR` in any of the 18 runs.

## Top 15 problems (ranked by impact on mid-game enjoyment and retention)

1. **Fights are long and inert.** 26 turns for the pilot to beat a 15-HP Frozen Line Cook; my hand turns were "play one Powerhouse,
   pass" (`c13g_11_after_fight.png`, `c13g2_07_turn2.png`). *Why*: Slay the Spire's trash fights take 3-5 turns; nothing retains a
   player like a fight that ends. *Fix*: start both sides with 1 energy and one infrastructure in play; cap trash enemy HP at ~10 at this
   level; let units attack the turn they enter unless a keyword says otherwise.
2. **Losing a dungeon fight ejects you to the zone with an unexplained toll.** "Dish duty fee: 20 gold (logged)" over the arrival
   banner and a gravedigger saying "Not on my list. Off you pop." (`c13g2_15_rewards.png`). *Why*: the player does not know they lost,
   what they lost, or what "logged" means. *Fix*: a Defeat screen first (the Omakase one is excellent), then "Dish duty: -20 gold" as a
   line on it, then the zone.
3. **Energy and infrastructure are not taught where they bite.** "Needs 2 energy; you have 0" appears after the failed drag
   (`c13m_07_turn2.png`); the defeat tip says keep 2-3 infrastructure in the opening hand but the mulligan popup shows no infrastructure
   count. *Fix*: show energy as a pip row next to the hand; grey out unplayable cards; put "Infrastructure: 1 / 6" on the mulligan popup.
4. **Shops cannot be opened the way the game teaches.** E on Sable / Fenwick gives two greeting lines and then nothing; `button Shop`
   NOT FOUND; Esc opens the pause menu (c13l-c13r, `c13o_12_e4.png`). *Why*: a mid-game player with 600 gold and nothing to spend it on
   stops caring about gold. *Fix*: the second E opens the shop; a "Browse" button in the dialogue box; Esc in a dialogue closes the
   dialogue, never pauses.
5. **The zone map opens fully black** (`c13d_07_buffet_map.png`), the town map is five islands (`c13a_08_map.png`), and "Where to?" is a
   text field that did nothing in three runs. *Fix*: reveal the whole zone map on entry (fog only the field); make "Where to?" a real list
   of named places that sets the goal pin; draw the road to the next zone on the town map.
6. **Walking in Crosspath is unreliable right after a load.** In four of six town runs the first 3-5 s of held WASD did not move the hero
   (c13a 10/11, c13n 02, c13q 01). *Why*: the first thing a returning player does is walk; if it fails they think the game froze. *Fix*:
   give the world input focus on load; ignore the HUD/quest panel for focus.
7. **Opening-hand popup ignores Space and card clicks** (c13f/c13g logs) while the HUD says Space confirms popups. *Fix*: Space = Keep
   Hand; clicking a card toggles mulligan.
8. **Pack opening is a text list.** 36 cards as two paragraphs of names, Feats popping over it (`c13a_04_pack_result.png`). *Fix*: fan
   the cards one pack at a time with rarity glow, "New" tags and an "Add to deck" button; queue Feats until after.
9. **New cards vanish into the collection.** After opening 12 packs the Deck Station has no "just opened" rack and shows 14 cards with no
   scroll cue (`c13a_09_deck.png`). *Fix*: a "New (36)" filter pre-selected after a pack opening; a visible scrollbar; hide "Own 9999".
10. **Zones have nobody to talk to.** One interactable (the Rift Station) in each of the Buffet and the Dump in ~30 s of walking; Tarragon
    stood two metres away and E chose the station (`c13e_06_walk_nw.png`). *Fix*: E targets the NPC the hero faces; put two or three
    talkable NPCs at each arrival square; keep the station a step off the path.
11. **A freed zone is an empty lobby with one joke** (`c13i_04_dna_talk2.png`). *Fix*: one new vendor or a repeatable challenge per freed
    zone, and a map icon that says so.
12. **Esc is inconsistent.** It closes the Deck Station from the Suggest dialog and then pauses (c13b); it pauses over a shop greeting
    (c13l); it closes the map. *Fix*: Esc closes the top-most layer only; it pauses only when nothing is open.
13. **Boss dialogue drops to silhouettes.** After the painted intro, the exchange plays over a chef-hat and a wizard-hat on a gradient
    (`c13g2_24_boss_battle.png`). *Fix*: use the boss portrait and the hero portrait already on screen one step earlier.
14. **Recaps and bars print nonsense numbers.** "defeated ... in 0 turns" (c13k), "0 / 465 XP" on the first Character open, "Free the Four
    Zones 2/5", "Reroll (170 gold)" against a 100-gold reward (`c13k_12_rot_reward.png`). *Fix*: clamp turns to 1; show XP earned since
    last level in the same bar; count 4; price rerolls below the reward.
15. **Hand text is unreadable at 1600x900** (`c13m_03_turn1.png`). The tooltip rescues it but a nine-card hand needs nine hovers. *Fix*:
    raise the lifted card on hover to 1.6x (Slay the Spire does this) and set hand body text to at least 11 px.
