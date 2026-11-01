# Fresh eyes: the postgame of The Wayward Path (Nov 1 2026, critic 7)

Screenshots are in `fresh_eyes_postgame_oct31n/`, named `<run>_<shot>.png`.

## Summary

The postgame looks great and plays badly. The Path-ology Lab map is beautiful, the Undercroft arena menu is the best long-term hook in the game, and Siphon's boss card is strong. But after the credits **the game never tells you what is left**: the quest log's Main and Side tabs both say "Nothing here right now", the zone map has no marker for Mount Swolympus, and the hermit at the bottom of the Swolympus stairs (Old Man Mountain) shows no talk prompt and doesn't answer E. In about 10 minutes of looking I could not find a way up Swolympus. On top of that, the **zone and dungeon HP penalties still apply in "freed" places**. The player goes into both postgame bosses with 14 HP, against 34 HP (The Ancient Spotter) and 48 HP plus eight stacked rules (Dr. Ambrose Siphon). Both fights ended in a loss in which the boss **took zero damage**. A player who has just beaten the final boss gets an empty to-do list, a mountain they can't find, and two walls. That is a quit moment, not a postgame.

## How I played

- About 55 minutes of wall clock (02:50 to 03:45), 13 runs (c7a to c7m), every one from `dev load postgame_real`.
- **c7a**: Crosspath at the start, quest log, town map, `dev travel capital` (it puts you in the Crease), a short walk there, back to Crosspath.
- **c7b to c7f**: Quest log tabs, the HUD Menu, the Gainlands, the map and its "Where to?" list. I walked to the Swole Station and found Old Man Mountain at the foot of the stairs. Tried to talk to him (twice) and to walk north.
- **c7g and c7h**: The Ancient Spotter through `dev encounter`, because I never found the way up. I played the opening turns by hand, then handed over to `pilot`. Lost on turn 6. Boss at 34/34.
- **c7i to c7l**: The Path-ology Lab. Map and rules, then the first node (Intake Corridor, Decontamination Technician) won by the pilot in 15 turns for +35 gold and +30 XP. Then the boss node through `-2`: read the intro, fought Dr. Ambrose Siphon with the pilot, lost on turn 14 with the boss at 48/48. Afterwards I woke up in the Forest Clearing.
- **c7m**: Feats, Deck Station and the Undercroft arena menu. I did not fight in the arena.
- **Skipped**: the climb up Swolympus itself (couldn't find it), the middle Lab nodes, any arena bout, the Collection Book beyond the Deck Station grid, most Capital and Crosspath NPC dialogue.
- **Caveat**: most fights were played by the built-in pilot, which is a simple player. In my own turn 1 against the Spotter, the very first infrastructure I dragged was refused ("Needs 4 energy; you have 0"), and I then wasted the turn with Space. So read the boss results as "very hard for an ordinary player", not as "proven unwinnable". Still, zero damage across 14 turns is a strong signal.
- **No `SCRIPT ERROR`** appeared in any `stdout.log`. Loads were steady: zone travel about 5 to 11 s, snapshot load about 7 to 13 s.

## Scores (1-10, compared with Slay the Spire, Inscryption, Monster Train, Sea of Stars, Octopath, Pokemon TCG Pocket)

| Area | Score | One line |
|---|---|---|
| Clarity ("what now?", rules, losses) | 3 | Empty quest log, no Swolympus marker, a hermit you can't talk to; boss rules listed but not taught |
| Pacing and friction | 5 | Loads are fine. Pilot fights take 60-80 s for 14-15 turns; defeat dumps you in the Forest Clearing |
| Combat depth and feel (postgame) | 4 | Siphon's protocols are interesting on paper; in practice 14 HP against 48 HP and +2/+1 enemies is a wall |
| Deck-building satisfaction | 5 | The Deck Station filters are good, but the screen gives no reason to rebuild for a boss |
| Reward rhythm | 4 | +35 gold / +30 XP for a 15-turn Lab fight when you have 1200 gold; the arena prizes are the only exciting ones |
| Exploration and world | 4 | The Gainlands are lovely to look at, but the map is fog everywhere and the summit is undiscoverable |
| Story and humour | 6 | Siphon's intro ("Do sit; the straps are new") lands; the Gainlands' freed-state line and Feat names are fun |
| Visual cohesion and readability | 7 | Lab map and boss card are excellent; the Spotter fight has a bare navy board |
| UI/UX consistency | 4 | E doesn't confirm the Opening Hand, Before-the-fight or Victory popups; "Where to?" doesn't stick |
| Audio | n/a | Can't judge from screenshots and logs |
| Performance | 7 | No script errors, no visible stalls; travel loads of 5-11 s are acceptable |
| Bugs | 4 | Old Man Mountain doesn't interact; walking north from him is blocked; freed zones still apply the zone HP rule |
| **Postgame retention overall** | **3.5** | The content exists (Lab, Swolympus, an 8-bout arena, 23 unearned feats) but the game hides it and then walls it |

## Findings per area

### "What now?" after the credits
- **The quest log is empty.** Main says "Nothing here right now." (`c7b_01_quests_side.png` shows Side, and Main is the same). Completed lists the whole story (`c7b_02_quests_done.png`). Nothing mentions Swolympus, the Lab, the arena or Siphon. In comparable games the postgame starts with a shining new entry.
- **Crosspath** (`c7a_01_start.png`) looks warm and alive. The town map (`c7a_03_map.png`) shows one quest marker, on Elder Maren, and a Challenger by The Restless Cairn. That is the only postgame breadcrumb I saw in the whole session, and nothing tells you to look at the map.
- **The Capital** (`dev travel capital`) put me in the Crease hideout, not in a liberated city. It still shows "Broken services: 0 of 4" and "Zone HP: no healing after battles. Max 14 here (-7)", and it fires a "Rift Station unlocked" popup as if this were your first visit (`c7a_04_capital.png`). Primm and the zone bosses stand around in one walled courtyard (`c7a_06_capital_walk2.png`). The game hasn't marked the liberation at all. That is a missed victory lap.
- **The Gainlands** (`c7b_04_gainlands.png`) do say, nicely: "The Gainlands is free. Its people have new things to say - and the dungeons still pay gold and XP." But the HP box right above that line still says "Zone HP: no healing after battles. Max 14 here (-7)". Freed zones should not punish you.

### Mount Swolympus
- The "Where to?" list (`c7b_06_whereto.png`) offers the House of Gains, the Iron Cave, vendors, the Hot Tub and "Old Man Mountain, Hermit of the Swole Station (Quest giver)". There is no Swolympus entry. Choosing Old Man Mountain closed the map with no visible pointer in the world (`c7c_02_after_map.png`). Reopening the map, the choice had reset and the map was 95% fog (`c7c_05_map2.png`).
- I found him by walking: he stands at the foot of a long staircase flanked by four sealed icon plaques (`c7f_02_om1.png`). He shows **no [E] Talk prompt**, and E did nothing after 6 presses. Holding W from there didn't move the player (`c7f_11_north2.png` is the same frame 9 s later). Grandmaster Flex, ten steps back, does show a prompt and a speech bubble. So a player sees the obvious gate, the obvious NPC, and nothing happens. In my session, **Swolympus could not be reached**.
- **The Ancient Spotter** (through `dev encounter`): there was no boss intro card, and the board was a bare navy void with no arena art (`c7g_05_board.png`, compare the Lab's illustrated board in `c7j_04_battle.png`). Boss 34 HP against my 14. On turn 1 my opening hand held a Barbell of the Ancients, a 4-cost card I couldn't play ("Needs 4 energy; you have 0"). The pilot lost on turn 6 to "Millstone Pusher dealt all 22 damage you took (3 hits)" (`c7h_09_result.png`). Boss damage taken: 0. The Defeat screen's "What beat you" panel is a good idea and readable.

### The Path-ology Lab
- **Arrival is excellent.** The text is unsettling ("Everything about this place is familiar in the way a bruise is familiar"), and the node map (`c7i_05_lab_map.png`) is the best-looking screen I saw: tanks, roots, waterfalls, 16 named rooms, clear branching.
- **The rules** are tight and clear: max life -5, enemy units +1/+1. The pre-node popup repeats them, and they stay as icons during the fight. Good.
- **Node 1** (Decontamination Technician, 30 HP) was won in 15 turns and about 80 s, for **+35 gold, +30 XP** and no card (`c7j_06_reward.png`). With 1200 gold in your pocket and nothing visible to spend it on, that reward is meaningless.
- **The boss.** The pre-fight popup stacks **eight rules**: the two Lab rules, four Protocols, a half-health valve and "Fascinating Data" (`c7k_08_intro6.png`). Each is clearly written, and the colour coding (red/green) is never explained. "Elowen can jam one Protocol each turn" is the most interesting mechanic in the list and is never shown or taught: who is Elowen in this fight, how do I jam? The boss card (`c7l_01_board.png`) is first-rate art with a good line. The pilot then lost on turn 14 with **Siphon at 48/48** (`c7l_04_result.png`). The loss summary said "an effect dealt 7 of the 13 damage you took (7 hits)". "An effect" is the drain Protocol, and the summary should name it. Afterwards I woke up in the **Forest Clearing** (`c7l_05_after.png`), a long way from the Lab, with no message about Lab progress.
- **Writing.** "Subject 1. You came back to us. You have grown." and "My daughter is resting in your old room. She is confused, poor thing. She thinks she rescued something." are the strongest lines I read today. In `c7k` one line showed twice because E only finished the typewriter on the first press. That's minor.

### Arena, Feats, Collection
- **The Undercroft** (`c7m_04_arena.png`) is the best postgame screen: 8 bouts in Bronze/Silver/Gold tiers, a mix of puzzles and restricted decks ("Spells Only, Please", "The Neutral Mile"), real gear prizes (Champion's Laurels, Bloodsand Boots), and a walrus announcer with a megaphone. After a full story it shows **0 of 8 cleared**, so nothing in the story ever pulled the player down here. Nothing outside the arena (quest log, NPCs) points at it.
- **Feats** (`c7m_01_feats.png`): 17 of 40, with honest categories and gold prizes. Unearned ones like "Complete File", "Gold Sand" and the Path feats are good goals. But the rewards are 25-50 gold, against a 1200-gold wallet. Hidden "???" feats inside Story and Side dungeons are a good hook.
- **Deck Station**: the filters (colour, type, cost, rarity, New) and the "Deck 1/3 Own 3" counters are clear. One confusing thing: Village Militia reads 2/2 in the Deck Station but 6/3 in battle. The game never says that level scaling or gear changes the numbers. I didn't open a pack or the Collection Book proper (time).

### Combat feel at this level
- My opening hands held 7 cards plus extra draws: 11 cards in hand on turn 1 against the Spotter (`c7h_08_turn2.png`). The fan of cards overlaps so much that names are cut to "BEEFY BOUN", "LIFTING GLO", "VILLAGE MI".
- "Turn 3" shows on my second turn, because turns count both sides. That is confusing next to "wins after 6 turns".
- In both boss fights the pilot ended holding 4 to 8 cards, which the Defeat tip calls out. The tip is good. It also suggests the curve and energy at 14 HP leave no time to develop before lethal pressure arrives.

## Top 15 problems (ranked by impact on postgame retention)

1. **No postgame quests at all.**
   - Where: `c7b_01_quests_side.png`, Main and Side both say "Nothing here right now".
   - Why: the first thing a player does after the credits is press J. An empty log reads as "the game is over".
   - Fix: when Primm falls, add a Main quest "Loose Ends" with three objectives (climb Mount Swolympus, find the hatch under the forest / the Lab, prove yourself in the Undercroft). Auto-track it and make J open on it.
2. **Mount Swolympus can't be found or opened from in-game hints.**
   - Where: `c7b_06_whereto.png`, `c7f_02_om1.png`, `c7f_11_north2.png`.
   - Why: it's the postgame's headline zone and the player can't get there.
   - Fix: add "Mount Swolympus (Summit path)" to Where to?. Give Old Man Mountain a working talk prompt and postgame dialogue that opens the stairs. Light the four plaques as they unlock.
3. **Postgame bosses fight a 14-HP player.**
   - Where: `c7g_05_board.png` (14 vs 34), `c7l_01_board.png` (14 vs 48).
   - Why: zone and Lab max-life penalties stack on top of a base that is already low, and both bosses took 0 damage. A wall straight after the credits is where retention dies.
   - Fix: drop zone HP rules in freed zones, show the base max life plainly, and tune Siphon and the Spotter around a full-HP player. Or give the Lab a rest node before the Antechamber.
4. **Freed zones still show and apply "Zone HP: no healing after battles. Max 14 (-7)".**
   - Where: `c7b_04_gainlands.png`, `c7a_04_capital.png`.
   - Why: it contradicts the "is free" message in the same frame and feels like the win didn't count.
   - Fix: lift or soften zone effects when a zone is freed, and say so in the freed banner ("The Gainlands' curse is lifted: you heal after battles here").
5. **Old Man Mountain shows no interaction and blocks movement.**
   - Where: `c7f_02_om1.png`.
   - Why: he looks like a bug, so players will assume the game is broken.
   - Fix: give him the standard nameplate glow and [E] prompt, plus a line even when the summit is locked ("Come back when the mountain wants you.").
6. **The liberated Capital doesn't feel liberated.**
   - Where: `c7a_04_capital.png`, `c7a_06_capital_walk2.png`.
   - Why: "Broken services 0 of 4", a first-visit Rift popup and an underground courtyard waste the emotional peak.
   - Fix: after Primm, `travel capital` should land in the restored streets with bunting, cheering NPCs and fixed services. Hide the services tracker and stop re-firing the unlock popups.
7. **Siphon's rules are a wall of text, and the jam mechanic is never taught.**
   - Where: `c7k_08_intro6.png`.
   - Why: eight rules, a colour code nobody explains, and "Elowen can jam one Protocol" with no button or tip shown.
   - Fix: present the four Protocols as a row of jam-able tiles on the board with a first-turn tip ("Click a Protocol to have Elowen jam it this turn"). Fold the two Lab rules into a smaller line.
8. **The "Where to?" choice doesn't persist or point anywhere.**
   - Where: `c7c_02_after_map.png`, `c7c_05_map2.png`.
   - Why: the feature promises navigation and delivers nothing.
   - Fix: when a destination is chosen, show the in-world goal pointer and a HUD line ("Old Man Mountain - 40 m north"), and keep the choice selected on the map.
9. **Lab fight rewards don't matter in the postgame.**
   - Where: `c7j_06_reward.png`, +35 gold / +30 XP for a 15-turn fight.
   - Why: the player has 1200 gold and nothing to buy, so fights feel pointless.
   - Fix: give postgame nodes a card pick or essence, add a postgame gold sink (cosmetics, a pack vendor with new cards, crafting at Auntie Alembic's), or have Lab nodes drop Lab-only cards.
10. **Losing a Lab fight sends you to the Forest Clearing.**
    - Where: `c7l_05_after.png`.
    - Why: the long walk back after a boss loss doubles the frustration, and the screen says nothing about progress.
    - Fix: respawn at the Lab's Forest Hatch with a short "Your Lab progress is kept (8 rooms cleared)" card and a one-click retry for the boss.
11. **The arena is never pointed to, at 0 of 8 after a full story.**
    - Where: `c7m_04_arena.png`.
    - Why: the best long-term hook is invisible.
    - Fix: put the Announcer in Crosspath's square after the credits with a bark and a quest-marker, and list Undercroft progress in the quest log.
12. **The Ancient Spotter's board has no art and no intro card.**
    - Where: `c7g_05_board.png`.
    - Why: the summit boss looks less important than a Lab trash fight.
    - Fix: give the fight a summit board backdrop and the same boss intro card Siphon gets, and make sure both still show when the fight is started outside its dungeon.
13. **E / Space don't confirm the Opening Hand, Before-the-fight and Victory popups.**
    - Where: `c7g_05_board.png` (4 presses of E did nothing), `c7j_06_reward.png`.
    - Why: the controls line promises "E / Space / Click: interact, confirm popups", so these popups break it.
    - Fix: bind accept to the default button on every modal (Keep Hand, Continue).
14. **The hand fan at 10+ cards hides card names, and the "Turn 3" count is confusing.**
    - Where: `c7h_08_turn2.png`.
    - Why: you can't read your options at a glance.
    - Fix: compress the fan into two rows, or zoom on hover with names always visible. Count turns per player ("Your turn 2"), or label it "Round".
15. **Card stats differ between the Deck Station and battle without explanation.**
    - Where: Deck Station dump (Village Militia 2/2) against battle (6/3).
    - Why: the player can't judge a deck if the numbers change.
    - Fix: show the scaled stats in the Deck Station, or show "2/2 (+4/+1 from level)" in both places.
