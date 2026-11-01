# Fresh eyes: the postgame of The Wayward Path (second critic, Oct 31 / Nov 1)

Screenshots: `fresh_eyes_postgame_oct31n_second/`, file names are `<run>_<shot>.png`.

## Summary

After the credits, The Wayward Path gives you a lovely world, two very good painted dungeon maps and a smart arena menu. It does not give
you a reason to use any of them. The quest log is empty ("Nothing here right now.", `c10a_02_quests`). Neither the map's "Where to?"
list nor the game's dialogue mentions Mount Swolympus or the Path-ology Lab. I found Swolympus only through a debug jump, and the
Gainlands "quest giver" that the map points to was not where the marker said.

The two postgame dungeons are lopsided:

- **Mount Swolympus** is three nodes. The automated pilot cleared the Ancient Spotter in 15 turns without losing a single HP. The boss
  rule list is the best thing here: seven named rules, including a heal at half health and reinforcements on its 6th turn. The pay-off
  is +100 gold, +120 XP and a common-pool card pick. You then land back on the Gainlands bridge and see the same arrival scene again.
- **The Path-ology Lab** is 16 nodes. Its ordinary fights are easy, but Dr. Ambrose Siphon (48 HP, six Protocols, drains you every turn)
  beat my 14-HP hero in 8 turns, twice in a row, without taking any damage himself. That is a difficulty cliff, not a curve.

On top of that, several "E confirms popups" moments silently fail: the opening hand, the reward popup and the card pick. On the card
pick, E grabbed the highlighted Uncommon while an Epic sat right next to it.

The Arena (Undercroft) is the most promising long-term hook: clear puzzle and restricted-deck framing, and gear prizes. But its rewards
are tuned for a level-5 player, and the one puzzle I played is trivial.

## How I played

- About 60 minutes of wall clock, 16 scripted runs (`c10a` to `c10p`), each from `dev load postgame_real`, one at a time, in the foreground.
- **What now?** (a, b): Crosspath, the quest log, the map and its Where-to list, and the Capital via `dev travel capital`. That jump
  lands in the Crease hideout, not the liberated streets.
- **Gainlands** (c to f): the arrival scene, Grandmaster Flex's postgame lines, and the Where-to pointer to "Old Man Mountain, Hermit of
  the Swole Station". I walked about 10 s from the bridge and could not find him.
- **Mount Swolympus**: I found no in-world route, so I listed encounters with `dev encounters Spotter`, which gave its id S-BEEF.
  - g to j: entered with `dev travel dungeon S-BEEF`.
  - Node 1: I played the first turn myself (infrastructure, unit, Space), then the pilot finished it.
  - Boss: jumped to the node before the boss (`-2`), read the intro myself, the pilot fought, and I read the rewards.
- **Path-ology Lab** (k to n):
  - Read the entry text and the rules.
  - One normal fight (pilot).
  - The boss twice from `-2`, reading the intro myself, pilot fighting. Lost both.
- **Menu, Feats, Character, Deck Station, Arena** (o, p): one Arena puzzle, Lethal Lunch.
- **Skipped:**
  - The Capital's open streets: the dev jump only reaches the Crease.
  - The Collection Book itself: I saw only the Deck Station filters and the collection feats.
  - Elder Maren's "quest available" marker in Crosspath.
  - The other 7 Arena bouts.
  - A manual attempt at Siphon.
- Performance: zone loads are 6 to 11 s after a dev travel, and snapshot loads 7 to 12 s. I saw no stutter in the timestamps and no
  `SCRIPT ERROR` in any `stdout.log`.

## Scores (1-10 against Slay the Spire, Inscryption, Monster Train, Sea of Stars, Octopath, Pokemon TCG Pocket)

| Area | Score | One line |
|---|---|---|
| Clarity (what to do, why I won or lost) | 4 | Rules and recaps explain fights well; the postgame itself is unsignposted (empty quest log, no Swolympus or Lab anywhere) |
| Pacing and friction | 5 | Fights are brisk (30-60 s with the pilot); snapshot dumps you at the zone bridge with a repeat scene; E dead on several popups |
| Combat depth and feel | 6 | Boss rule stacks are genuinely interesting; Spotter does not threaten, Siphon overwhelms; same arena backdrop for camp and summit |
| Deck-building satisfaction | 5 | Strong filters; 21 unopened packs, 0 of 3 item slots equipped and 0 essence suggest the systems do not pull the player in |
| Reward rhythm | 3 | Postgame boss pays +100 gold / +120 XP against 640 XP to the next level; arena pays early-game sums (90 gold) |
| Exploration and world | 6 | Gainlands and Crosspath are gorgeous; maps show only visited blobs; no route to Swolympus I could find |
| Story and humour | 6 | Flex's prison-breathing lines and Siphon's "This will only drain a little" land; Spotter's summit has no closing line |
| Visual cohesion and readability | 8 | Painted node maps (Swolympus, Lab) are standouts; HUD is clean; one leftover banner over the Victory popup |
| UI/UX consistency | 4 | E/Space does not confirm the opening hand or rewards; E takes the default card; two HP numbers (14 zone vs 21 starting) |
| Audio | n/a | Not judgeable from screenshots and logs |
| Performance | 7 | Loads 6-12 s, no hitches seen, no script errors |
| Bugs | 5 | Rule says Lab max life -5 but HUD stays 14/14; Siphon rule refers to Elowen, who is not in my party; mismatched node name and fight name |
| **Postgame overall (retention)** | **4** | Pretty, but nothing tells you what is left, and the two dungeons are a walkover and a wall |

## Findings per area

### What now? (quest log, map, NPCs, town, Capital)

- **The quest log is empty after the credits.** Main, Side and Completed all show "Nothing here right now." beside a big empty brown
  panel (`c10a_02_quests`). Nothing points to Swolympus, the Lab or the Arena. Compare Sea of Stars, whose post-ending log lists the
  remaining side content and the true-ending steps.
- **The Crosspath map** (`c10a_03_map`) shows unexplored dark areas plus an Elder Maren "quest available" marker. **Its "Where to?" list**
  (`c10b_01_whereto`) has vendors, challengers and the Undercroft, but no Lab entry. The Lab entry is the "Forest Hatch", per its node
  map, and the forest is not on that list either.
- **Arriving in a freed zone** shows a nice toast: "The Gainlands is free. Its people have new things to say - and the dungeons still pay
  gold and XP." That is the only postgame direction the game gives. Flex's lines are flavour only. His closing line, "The gym is open to
  everyone now", is the closest thing to a hint, and it hints at nothing concrete.
- **The Capital** (`c10a_05_capital`, `c10a_07_capital_walk2`):
  - `dev travel capital` lands in the Crease, a walled brick room with the whole cast standing in a row: Agnes, Compostella, the Grand
    Chef, Primm and Primm's guard.
  - In the postgame it pops "Rift Station unlocked: the Crease". A fast-travel unlock *after* the story ends is late to the point of
    being useless.
  - Primm standing among the friends with no comment reads oddly. Compostella's line about a crack in the marble with something
    growing out of it is a nice postgame seed, but it leads nowhere I could follow.
  - "Services restored: 4 of 4" sits in the corner as a finished tracker.
- **HP readouts:** the HUD shows "HP 14 / 14 - Zone HP: no healing after battles." everywhere, including Crosspath-adjacent zones. The
  Character screen says "Starting HP 21". Two HP figures with no explanation.

### Mount Swolympus

- **Finding it:**
  - The Gainlands Where-to list (`c10c_m2_whereto`) has no Swolympus entry.
  - Picking "Old Man Mountain, Hermit of the Swole Station (Quest giver)" drops a marker just north of the bridge (`c10d_01_pick`).
  - Walking there showed Grandmaster Flex and "Old Hob the Gravedigger" (a gravedigger at the gym?), but no Old Man Mountain
    (`c10d_04_walk`). No in-world arrow or trail guides you after you pick a target.
  - I gave up and used the dev id. A real player would likely give up too.
- **The node map is gorgeous** (`c10g_06_rules`): a painted cliff path from Base Camp to The Squat Rack Pass to The Summit Altar.
  - It is only three nodes, which is thin for a "locked during the whole story" summit.
  - One rule is "Processing Time: The first Necrocrat unit costing 3 or more each turn enters exhausted". A Necrocrat rule on the Beefcake
    holy mountain reads as copy-paste.
- **Fight 1, Rival Lifter (22 HP):**
  - The pre-fight rule card is clear.
  - The opening hand gave a count summary ("4 infrastructure, 3 other cards"). That is good.
  - My hand grew to 11 cards on turn 1, and the unit's printed 2/3 turned into 7/4. No explanation of where the extra cards and the +5
    attack came from (`c10i_03_unit`).
  - A first-time "Rules of this fight" tip appeared at level 23.
  - The pilot won in 9 turns. HP went 14 to 12. Reward +35 gold, +30 XP (`c10i_10_map`).
- **Boss, The Ancient Spotter (34 HP)** (`c10j_04_board`):
  - The intro text is lovely: "It has been spotting for a thousand years. It is very, very ready." "'Lift,' it rumbles. 'I will catch
    it. I have always caught it.'"
  - It has seven rules: Ancient Form +4/+3, One More Rep heals 4 at half health, Young Spotters arrive on turn 6, and so on.
  - In play it never landed a hit: the pilot won in 15 turns with HP 14 to 14, and the Flawless feat popped.
  - The banner "Next turn: two Young Spotters climb up the mountain." was still on screen over the Victory popup.
  - The board backdrop is the same gym floor as Base Camp, so the summit has no visual climax.
- **After the boss:**
  - Two Victory popups in a row: "You defeated The Ancient Spotter in 15 turns", then the reward one (`c10j_05_end`, `c10j_o1`).
  - The reward: +100 gold, +120 XP, and a pick of Lifting Gloves (Common), Snack Bar (Uncommon) or Swole Patrol Sergeant (Epic).
  - **Pressing E took Snack Bar, the pre-highlighted card**, so a player mashing through text loses the Epic. The line "Added to your
    collection: Snack Bar" shows *before* you choose, which reads as if it has already been taken.
  - No word from the Spotter, no summit scene, no new NPC line. You are dropped on the Gainlands bridge and the same arrival scene ("On
    the arm of the Throne of Gains someone has left a schedule...") plays again.

### The Path-ology Lab

- **The entry text is strong:** "Everything about this place is familiar in the way a bruise is familiar. Your hands are shaking. You go
  down anyway."
- **The 16-node painted map** (`c10k_02_rules`) is the best map in the game I saw: specimen tanks, branches, distinct room names.
- **Rule mismatch:** "Specimen Conditions: Your max life is 5 lower in the Lab." The HUD still shows 14 / 14 inside the Lab, so the rule
  is either not applied or not shown.
- **Node name vs fight name:** clicking "Intake Corridor" opened "Before the fight: Decontamination Technician", while "Decontamination"
  is a different node on the map.
- **The ordinary fight** was easy: the pilot won, HP 14 to 14, +35 gold, +30 XP. Pressing E did not close the reward popup; four presses
  in a row did nothing.
- **Siphon's intro is the best villain writing I saw:** "Subject 1. You came back to us. You have grown. Remarkable, after so many
  cycles." "My daughter is resting in your old room. She is confused, poor thing. She thinks she rescued something." "Please, sit. This
  will only drain a little."
- **Siphon's rules** (six Protocols plus two scripted events) are rich but long: eight lines on one card. One of them says "Elowen can jam
  one Protocol each turn". Elowen is not in my party, and nothing in the fight showed her, so for this save the rule refers to a
  character who is not there.
- **The fight:**
  - Siphon starts at 48 HP against my 14.
  - Both pilot runs lost in 8 turns with Siphon untouched at 48 (`c10m_03_mid`).
  - The defeat recap is excellent (`c10m_05_end`): "Failed Experiment dealt 12 of the 21 damage you took (2 hits). Tip: You ended with 8
    cards still in hand."
  - The board shows why: only 4 infrastructure in play by turn 8, with "Containment: your first card each turn costs 1 more" choking it.
  - The pilot is a simple player, but going from flawless wins to a boss that cannot be damaged, with no middle step, will read to a
    real player as a wall.
  - After defeat you land in the Forest Clearing, so a retry is a fresh 16-node trek. I did not test whether node progress is kept.

### Arena and long-term goals

- **The Undercroft** (`c10o_05_arena`) is well presented. It has a walrus barker, three tiers (Bronze Sand, Silver Sand and more),
  labelled BATTLE, PUZZLE and RESTRICTED DECK bouts with one-line rules, first-clear prizes, and gear prizes (Champion's Laurels helm,
  Crowd-Pleaser's Cape). It shows "0 of 8 cleared" in the postgame.
- **Its rewards are tuned for the early game:** 90 gold and 40 XP, against 640 XP needed for level 24.
- **Lethal Lunch** (`c10p_02_board`) gives you a 9/5 and an 8/3 against one 2/2 blocker and 10 HP, plus a removal spell. Any line wins.
  The pilot solved it in 5 decisions. Inscryption and the Slay the Spire puzzle mods make puzzles hinge on one non-obvious line; this
  one does not.
- **Feats** (`c10o_02_feats`): 17 of 40, with gold rewards per feat and hidden ??? entries.
  - This is the strongest "keep playing" structure.
  - But I saw no visible postgame-specific feat (none for Swolympus, the Lab or Siphon), unless those are hidden.
  - "Four Paths, One Kingdom" pays 5 essence of each Path, yet the Character screen shows Path essence 0 / 0 / 0 / 0.
- **The Character screen** shows the save's loose ends: 21 unopened packs (Beefcake x7, Gourmand x4 and more, plus Gilded and Prismatic),
  0 of 3 item slots equipped with 12 Healing Salves in the bag, and 0 of 640 XP. These are partly the bot's habits, but nothing in the
  postgame nudges you to open packs or equip items. A "You have 21 unopened packs" badge on the HUD would.

### Visuals, UI and performance

- **Visuals:** Crosspath and the Gainlands are warm and readable. The node maps are the best art in the game. Boards are clear, the
  phase rail is good, and the "what beat you" recap is excellent.
- **UI inconsistency:** E/Space confirms dialogue but not the Opening Hand popup (Keep Hand needs a click), not the reward popup, and on
  the card pick E takes the highlighted card.
- **Performance:** fine. No errors in any `stdout.log`.

## Top 15 problems (ranked by impact on postgame enjoyment and retention)

1. **No postgame direction at all.**
   - Where: the quest log is empty on every tab (`c10a_02_quests`); the Where-to lists have no Swolympus or Lab (`c10b_01_whereto`,
     `c10c_m2_whereto`).
   - Why it matters: players finish, open J, see nothing, and quit. The postgame content effectively does not exist for them.
   - Fix: on the credits returning, add a "Loose Ends" main quest with steps for the Lab ("A hatch in the forest"), Swolympus ("The
     summit is open") and the Arena. Mark them on the maps and in Where-to.
2. **Siphon is a difficulty wall after a walkover postgame.**
   - Where: `c10m_03_mid`, `c10m_05_end`. Lost in 8 turns twice, boss at 48/48. The ordinary Lab fight and the Spotter were flawless.
   - Why it matters: the story finale of the postgame ends in frustration with no ramp.
   - Fix: cut his HP to about 35, or start Protocols one per turn. Let the player jam one Protocol when Elowen is absent. Add a mid-Lab
     elite that teaches Protocols.
3. **Siphon's rule references Elowen, who is not present.**
   - Where: Siphon's pre-fight rule card ("Elowen can jam one Protocol each turn").
   - Why it matters: it promises a counterplay the player does not have, and it is confusing lore.
   - Fix: swap the rule text by variant. Show Elowen on the board when she is there.
4. **E/Space mis-handles the card pick and other popups.**
   - Where: E took the highlighted Uncommon over an offered Epic (`c10j_o1`); E does nothing on Keep Hand or the reward popup.
   - Why it matters: lost rewards, and stuck-feeling screens.
   - Fix: E on the card pick should only move focus, or need a second press. Make E confirm Keep Hand and Continue consistently.
5. **The Swolympus route is unfindable in-world.**
   - Where: the marker for Old Man Mountain had no NPC at that spot (`c10d_01_pick`, `c10d_04_walk`); no on-screen pointer.
   - Why it matters: the headline postgame zone is invisible.
   - Fix: add an in-world guide trail to the Where-to target, a signposted "Path to the Summit" gate, and a Swolympus entry in Where-to.
6. **The Swolympus pay-off is flat.**
   - Where: `c10j_05_end`, `c10j_o1`. Three nodes; +100 gold, +120 XP, a common-pool pick; no closing scene; the arrival scene replays.
   - Why it matters: a summit sealed for the whole story should feel like a summit.
   - Fix: add a short summit scene and a unique reward (a legendary or a cosmetic). Add 2 to 3 more nodes. Do not replay the zone
     arrival scene on return.
7. **The Spotter does not threaten.**
   - Where: 15 turns, HP 14 to 14 (`c10j_04_board`).
   - Why it matters: rich rules with no tension.
   - Fix: give it a turn-1 body, and move the Young Spotters earlier (turn 3). Let One More Rep also buff.
8. **Postgame rewards are too small.**
   - Where: +35 gold / +30 XP per fight, +120 XP for a boss, against 640 XP per level; Arena first clears are 90 to 150 gold.
   - Why it matters: nothing feels worth grinding.
   - Fix: scale gold and XP with player level in freed zones and the Arena. Give a postgame currency or exclusive cosmetics.
9. **The Lab's max-life rule is not visible.**
   - Where: `c10k_02_rules` says -5, the HUD shows 14/14.
   - Why it matters: it erodes trust in the rule text.
   - Fix: apply it and show "14 (-5 Lab)" on the HUD, or reword the rule.
10. **There are two HP numbers.**
    - Where: the HUD "HP 14 / 14 Zone HP" vs Character "Starting HP 21".
    - Why it matters: confusion about how tough you are and why.
    - Fix: one HP figure, with a tooltip explaining zone HP.
11. **The Capital jump lands in the Crease; the liberation is not celebrated.**
    - Where: `c10a_05_capital`, `c10a_07_capital_walk2`. The Rift Station unlock comes after the story; Primm stands uncommented
      among the heroes.
    - Fix: open the Capital streets as the arrival point, with festival dressing. Unlock the Crease station during the story. Give
      Primm a postgame line.
12. **The Lab node name does not match the fight.**
    - Where: "Intake Corridor" opened "Decontamination Technician".
    - Fix: match the node label to the encounter, or show the encounter name on hover.
13. **Lethal Lunch is trivially easy, and the Arena is tuned for early game.**
    - Where: `c10p_02_board`, `c10o_05_arena`.
    - Fix: give postgame players a scaled Gold Sand tier with puzzles that need one exact line, and level-scaled prizes.
14. **Unclaimed systems stay unclaimed.**
    - Where: 21 unopened packs, 0 of 3 items equipped, essence 0.
    - Why it matters: the deck-building loop stalls.
    - Fix: add a HUD badge for unopened packs, an "equip items?" prompt before a dungeon, and point the essence crafting vendor out in
      the postgame quest.
15. **Small presentation leftovers.**
    - A stale "Next turn: Young Spotters" banner over the Victory popup; a double Victory popup; a first-time rules tip at level 23;
      the same gym backdrop for Base Camp and the Summit; a Necrocrat rule on Swolympus; unexplained extra hand cards and stat jumps
      (`c10i_03_unit`).
    - Fix: clear banners on battle end, merge the two victory popups, add a summit board backdrop, theme the dungeon rule, and add a
      hover breakdown for buffed stats.
