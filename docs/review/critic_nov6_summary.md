# Critic pass Nov 6 - synthesis

Brief: `docs/prompts/critic_nov6.md`. Reports: `docs/review/critic_nov6/C1.md` ... `C9.md` (screenshots in the matching folders),
briefs in `docs/review/critic_nov6/briefs/`. Build reviewed: v0.5.4 (HEAD cf8d9607 + the review commits; no game code changed).

Thirteen critic runs, one at a time, each a fresh sub-agent that saw only its brief. Five play critics hit a wall before the end of their
section, so four follow-up runs started further on: **C1b** (the first hour in town, from a Beefcake save just past the cave), **C2b**
(from inside the Verdant Dump), **C4b** (from the Capital, past the gate exam) and **C4c** (Primm only). Blockers fixed during the pass:
**test tooling only, no game code** - the play driver's battle pilot could not pick Refuse Pile targets, looped on a card it could not
click, and pressed a "Discard" button that is now called "Toss" (`tools/battle_pilot.gd`, `tools/play_script.gd`). The driver also has a
new `perf` command for C9.

**Not reviewed by anyone:** Primm's phase 2, the ending sequence and the credits *as played* (three runs died on the way: two to the pilot bugs
above, one to the host's low-memory kill; C6 read the ending's text). Mount Swolympus, the Lab's middle and Elowen's rescue (C5 ran out of
time after the forest blocker). A real Shattered Gallery run (C5 could not find the entrance; C8 simmed it).

## 1. Scorecard

| Critic | Section | Fun | Clarity | Difficulty | Text | Look | Other |
|---|---|---:|---:|---:|---:|---:|---|
| C1 | Opening, Path choice, tutorial cave | 6 | 6 | 5 (uneven) | 7 | 8 | |
| C1b | First hour in Crosspath | 5 | 5 | 5 (swingy, hard) | 8 | 7 | |
| C2 | Crosspath to the Dump gate (Refusemancer) | 4 | 4 | ? (too easy on 1 fight) | 7 | 8 | |
| C2b | Verdant Dump + Rotheart | 3 | 4 | 3 (too hard) | 7 | 8 | |
| C3 | Midgame (L13 Beefcake) | 5 | 6 | 4 (both ways) | 7 | 7 | |
| C4 | Crosspath to the castle (L20) | 4 | 4 | 4 (too hard, random) | 7 | 8 | |
| C4b | Castle and Primm phase 1 | 5 | 4 | 6 (too easy, but stalls) | 8 | 8 | |
| C4c | Primm phase 1 | 4 | 3 | 4 (too hard, swingy) | 7 | 7 | |
| C5 | Postgame | 4 | 4 | 3 (too hard) | 7 | 6 | |
| C6 | Story and dialogue (desk) | 8 | 7 | n/a | 7.5 | n/a | coherence 5.5, payoff 6.5, voice 6.5, humour 7.5 |
| C7 | UI/UX tour (720p, 1080p, Low-end) | 6 | 5 | (6, neutral) | 6 | 7 | |
| C8 | Balance sims (desk) | 6 | n/a | 4 | n/a | n/a | |
| C9 | Tech and feel | n/a | 6 | n/a | n/a | 7 | performance 6, stability 8 |
| **Mean** | | **5.0** | **4.8** | **4.2** | **7.1** | **7.4** | |

(Difficulty mean leaves out C2's "?" and C7's neutral 6; with C7 it is 4.4.)

**Overall state.** The game's craft is consistently praised and its flow is consistently not. Every play critic singled out the painted
portraits, dungeon maps, boss stills, the "What beat you" defeat recap, the pre-fight rules card and the writing voice; C6 calls the
line-by-line writing the best it has seen in an indie RPG of this size. No critic found a single game `SCRIPT ERROR` in about 230 runs,
and C9 measured no leak during play. But **no play critic finished its section as briefed**. The same three frictions stopped all of them
long before content ran out. **Getting around on foot** (collision, NPCs, camera yaw, roofs) appears in seven reports. **Knowing where to
go next** (to your Path, the Capital, the Crease, the Gallery, the forest hatch) appears in six. **Difficulty that swings from trivial to
wall** appears in seven, and the sims agree it is real for some Path/boss pairs. The first hour scores 5-6 fun and the late game 4, so the
game currently gets worse the further a player goes, mostly because the friction compounds. The story's spine (C6) has the same shape:
excellent zone arcs, then a finale and ending that contradict themselves. Fixing navigation, guidance and the early fights' mana
starvation would move every play score more than any new content.

Note on difficulty evidence: the sims (C8) play each Path's *reference deck* at the expected level and call the mid-game well judged,
Primm too easy and the home-zone Rotheart trivial. The play critics used real collections (a 51-card starter at L4 in the Dump, the
snapshots' decks) with the simple pilot, and lost the Rotheart's first node 3/3 and Primm's phase 1 in 2 of 4 finished fights. Both are true: the curve is fine for the
deck the sims assume, and harsh for the deck a player actually has. That gap (deck-building guidance, starter infrastructure counts,
first-node rules) is the real balance finding.

## 2. Top 15 improvements, ranked by impact

Score = impact x reach / effort weight (S 1, M 2, L 3). Items 1-5 stop or confuse a new player in the first hour, so they lead regardless.

| # | Improvement | Impact | Reach | Effort | Score |
|---:|---|---:|---:|---|---:|
| 1 | Point every player at their Path from minute one | 5 | 5 | M | 12.5 |
| 2 | Make walking work: collision, NPCs, camera, roofs | 5 | 5 | M | 12.5 |
| 3 | Fix the Deck Station traps (save slot mode, Esc, clicks, hidden rows) | 4 | 5 | M | 10 |
| 4 | Stop the early fights' mana starvation and spikes | 4 | 5 | M | 10 |
| 5 | Remove the first-hour input traps (E takes a card, Path choice clicks, toast over Tilly, hidden map tip) | 3 | 5 | S | 15 |
| 6 | Losing should never spiral: no fee when broke, retry the final boss in place | 4 | 4 | S | 16 |
| 7 | Reveal the town map and draw the "Where to?" route in the world | 4 | 5 | M | 10 |
| 8 | Make packs a reward: a real reveal, Path-weighted General Packs | 4 | 4 | M | 8 |
| 9 | Retune the difficulty outliers the sims and critics agree on | 4 | 4 | L | 5.3 |
| 10 | Primm's finale: flow, staging and the phase break | 4 | 3 | M | 6 |
| 11 | Fix the story's finale and ending contradictions | 4 | 3 | M | 6 |
| 12 | Card readability and the triple hover | 3 | 5 | M | 7.5 |
| 13 | One Esc/focus rule for every screen | 3 | 4 | M | 6 |
| 14 | Endgame and postgame wayfinding: the Capital, the Crease, the Gallery, the forest hatch | 4 | 3 | M | 6 |
| 15 | First-visit hitches, the 17 s Dump load and a Low-end mode that does something | 3 | 5 | M | 7.5 |

(Item 7 is split out of item 1 because it is its own piece of work. Items 6-15 follow the score with two deliberate exceptions: 9-11
(score 5.3-6) sit above 12 and 15 (7.5) because a wall stops play and the finale is the game's last impression, and 14 (score 6) sits
above 15 because it contains a blocker - the postgame's story can't be started on foot - and its main-story half (the way to the Capital,
the Crease) hits every player who finishes the zones. Items 1-5 are ranked among themselves by how early and how hard they stop a player.)

### 1. Point every player at their Path from minute one
- **What:** after the cave, the main quest runs through errands (Meet the Merchants, Make It Yours, the Store Room) and never names or marks
  the player's Path gatekeeper or zone. The town map marks only "Gatekeeper Brannoch" (the Capital gate). The zone exit is one entry in a
  17-item "Where to?" list.
- **Who/when:** every new player, 10-30 minutes in. C1b (90 minutes, never found the Beefcake gatekeeper) and C2 (100 minutes, never got
  through the Dump gate) both spent their whole budgets here.
- **Evidence:** C1b F1 (`C1b/c1b_r43_f1_map.png`), C2 F1 (`C2/c2r1_03_map.png`, `c2r43_01_dump.png`), C2 F3 (E at the sealed gate picks the
  portal over Moss, `C2/c2r44_02.png`).
- **Fix:** a standing "Your Path" line in the HUD tracker from the Path choice on ("Face Brick Bronson on the Gainlands road"), with a
  Path-coloured map and minimap icon on the exit. Maren names the gatekeeper and the road in her hand-in line. While a portal is sealed, E
  prefers its guardian NPC.
- **Effort:** M. **Impact 5, reach 5.**

### 2. Make walking work: collision, NPCs, camera, roofs
- **What:** the hero stops dead on benches, lamp posts, plinths, signposts, barrels, the goose and roaming townsfolk, with no sliding;
  the same input works one run and fails the next. The camera yaw changes between parts of town, so W changes meaning. Roofs in front
  hide the hero, the doors and the quest markers. In the Dump an invisible line pins the hero in the Compost Commons.
- **Who/when:** every player, all game; worst in Crosspath (the most visited scene).
- **Evidence:** C1b F2-F4 (`c1b_r5_02_n.png`, `c1b_r23_02.png`, `c1b_r36_00.png`), C2 F4 (`c2r12_03_sable.png`), C2b F1 (blocker,
  `c2b_r14_145.png`, pinned at y 121.9), C3 F3 (`c3r4_06.png`), C4 F7 (a Townsfolk blocked the hero 15+ s, `c4r7_02.png`), C4b F6 (the
  Capital fountain).
- **Fix:** capsule collision with wall sliding; shrink prop colliders to their footprints; keep a 3-4 m clear ring round the fountain and
  clear main lanes; roamers non-blocking for the hero (or step aside); a fixed camera yaw inside the town; dither or cut away roofs and
  walls in front of the hero; anchor markers at doors. Audit the Compost Commons' colliders against the art. Add a walk smoke from spawn
  to each shop and exit in Crosspath and each zone hub.
- **Effort:** M. **Impact 5, reach 5.**

### 3. Fix the Deck Station traps
- **What:** Save Deck enters a slot-pick mode whose only cue is a line drawn over the locked slots. In that mode, and with unsaved
  changes, Esc and X do nothing. Clicks on grid cards sometimes don't add. The deck list shows four rows, so the "-" buttons below are
  hidden and dead. The station said 53 cards while the fights drew from 51.
- **Who/when:** every player, at the first-deck-edit quest (minute 15-20); C2 was trapped twice.
- **Evidence:** C2 F2 (`C2/c2r40_01_saved.png`), C2b F4 (`C2b/c2b_r10_102_closed.png`, `c2b_r18_182_battle.png`), C1b F9 (`c1b_r32_01_saved.png`).
- **Fix:** Save Deck saves the active slot at once, with a separate "Save as new slot". Esc/X with unsaved changes opens Save / Discard /
  Cancel. Make the deck list scroll. Every grid click adds one copy with a visible +1. Check the 53-vs-51 count (which deck the battle
  takes). **Effort:** M (the Esc prompt and the save button alone are S - do those first). **Impact 4, reach 5.**

### 4. Stop the early fights' mana starvation and spikes
- **What:** with about 19 infrastructure in a 45-51-card deck and one per turn, the first turns are often empty while the foe floods the
  board. Store Room Ghosts (3 HP vs 17) beat the pilot 1-2 times in 3; the Hollow Warden beat it twice after two 3-HP warm-ups; the
  Rotheart's first node beat a fresh Refusemancer 3/3 ("You played no Infrastructure on 3 of your 5 turns"), with Wild Growth growing a
  0/4 flier into the main threat. The sims agree the Refusemancer has the roughest start (cave 79 %, Brick Bronson 25 %).
- **Who/when:** every new player in the first 30 minutes; Refusemancers through their first zone.
- **Evidence:** C1 F2 (`C1/c1_r18_c8_11_post.png`), C1b F5 (`c1b_r44_f2_end.png`), C2b F2 (`c2b_r20_201_t3.png`, `c2b_r21_210_result.png`),
  C8 F8 (`C8_sims/tutorial.md`, `early_no_ease.md`).
- **Fix:** in the cave, the Store Room and every main dungeon's first node, guarantee two infrastructure in the opening hand (a soft
  mulligan rule). Delay "growth" room rules (Wild Growth) to turn 3 on first nodes. Smooth the cave: duel 2 at 6-8 HP with a blocker, a
  smaller Warden swarm. Give the Refusemancer starter a sturdier early body or a starting Garbage.
- **Effort:** M. **Impact 4, reach 5.**

### 5. Remove the first-hour input traps
- **What:** E on the victory screen takes the pre-selected reward card (the game taught E as "continue"). On the Path choice only the
  header and icon select a column; clicking the cards or blurb does nothing and Begin stays grey without a hint. A full-height "QUEST
  UPDATED" toast covers Tilly's portrait and cuts off her lines. The dungeon-map tip (the one explaining what a loss costs) sits under the
  cave's title scroll. Leaving the cave (Retreat, quit, crash) wipes every cleared node with no warning, and the 40-gold fights can be
  re-farmed (C1 F1).
- **Who/when:** every new player, minutes 1-20.
- **Evidence:** C1 F5 (`C1/c1_r12_c2_02.png`), C1 F3 (`c1_r4_pc_10_click_desc.png`), C7 F1 (`C7/c7_h_h_tilly_01.png`), C1 F4 (`c1_r7_cv_10_tip.png`).
- **Fix:** no default focus on Take (or E only skips the gold/XP part); the whole Path column is one click target, with "Pick a Path
  first" beside a disabled Begin; queue quest toasts while a dialogue is open and size the panel to its text; show the map tip below the
  banner or after it fades; save a dungeon's cleared nodes on quit (or at least warn "Leaving resets the cave" on Retreat) and don't pay a
  cleared node twice. **Effort:** S (the cave checkpoint is M). **Impact 3, reach 5.**

### 6. Losing should never spiral
- **What:** each defeat charges a fee (10-20 gold) and sends you to the zone's start. A player who spent their gold and then loses is at
  0 with nothing to buy and only fights they are losing. Losing Primm throws you out of the castle with a fine; the whole castle must be
  walked again for a fight decided by draws.
- **Who/when:** anyone who loses, which the critics did constantly; the final boss is the likeliest quit point.
- **Evidence:** C2b F3 (`C2b/c2b_r22_223_after.png`, gold 0), C3 F1 ("Dish duty fee: -20 gold"), C4c F3 (`C4c/c4c_r7_r02_trans1.png`).
- **Fix:** no fee below 50 gold (and none in a Path's first dungeon); a small consolation per enemy unit destroyed; on a final-boss (and
  main-boss) loss offer "Try again" from the defeat screen or respawn at the node before the boss. Keep the gate gag for the first defeat.
- **Effort:** S. **Impact 4, reach 4.**

### 7. Reveal the town map and draw the "Where to?" route
- **What:** Crosspath's map is mostly black at L3, at L13 and after the story; roads aren't drawn; labels collide and spill outside the
  frame. Picking a "Where to?" entry draws nothing in the world. Zone maps open as black boxes.
- **Who/when:** every player, every map open.
- **Evidence:** C7 F5 (`C7/c7_a_map_01.png`, `c7_k_k_map.png`), C2 F10, C2b F6-F7 (`c2b_r1_03_map.png`), C3 F3, C1b F12, C5 F12.
- **Fix:** reveal the whole hub town on first entry; draw roads; reveal each zone's outline and landmarks on arrival (fog only for detail);
  a ground trail or edge-of-screen arrow after a "Where to?" pick; label collision and clamping. Put one roaming foe within sight of each
  zone hub's exit - C2b found no roamer or side content on foot in 40 minutes (C2b F6). **Effort:** M. **Impact 4, reach 5.**

### 8. Make packs a reward
- **What:** "Open all" ends in a paragraph of card names, with no cards to look at; gilded packs are skipped silently and the list stays
  stale; toasts cover the list. Single-pack opening takes about 15 s with no skip. General Packs are mostly other Paths' cards (about 4 of
  15 usable for a one-Path deck), and Sable stocks two Refusemancer singles.
- **Who/when:** every player, every shop visit; the core gold-to-deck loop.
- **Evidence:** C3 F4 (`C3/c3r2_06_open1.png`), C7 F8 (`C7/c7_i_i_packs_02_open.png`), C2 F5 and F9 (`C2/c2r29_01_deck.png`).
- **Fix:** Open all shows a grid of card faces with NEW badges; any click skips a single pack's animation; say what Open all skips; weight
  General Packs to the player's Path(s) plus colourless; stock 5-6 singles per Path. **Effort:** M. **Impact 4, reach 4.**

### 9. Retune the difficulty outliers
- **What (sims, C8):** the Shattered Gallery's full run clears 1/40 with Silver Reserve +40 (C8 could not confirm the +40 from its
  outputs; the sequence sim does add it, `tools/balance_sim_tool.gd:216`). Deaths pile up at the third wing: the Doppelganger and
  Hortensia Echoes (labelled Normal) and the Rotheart Echo (Elite). Chancellor Clench is 0-17 % for the Gourmand. Beefcake falls off from
  L10 (Grimsby 33, Rotheart 33, Siphon 17, Betty 8) with dead own-Path cards (B-23 Snack Bar, B-24). Necrocrat is rough in the Gainlands
  (elites 30-40 %) and then snowballs from L11 (Primm 100/80/100). Side bosses spike: Betty Bones as low as 8 %, the Automaton as low as
  13 %. ZoneOrderEase works through foe HP alone (down to 0.36 for the Refusemancer's Dump, still only 67 %; the Gourmand overshoots to
  92 %). Primm is too easy in the sim for every Path. Late rewards are worthless: castle and Lab fights pay +20 gold / +30 XP at L20-23
  across about 25 castle nodes (C4b F4, C5 F6). Max HP barely grows: 23 at L20, 19 at L23 in C5's save (C4, C5 F7 - verify the postgame
  snapshot's HP, since 15 + 1 per 2 levels should give about 26).
  **What (play):** gatekeepers trivial (Fennel lost at 21/21 HP; Moss at 4 HP), then main bosses that end it in 5 rounds (C3); the Spotless
  exam a coin flip (C4); the Lab boss 42 life vs 14 with eight rules (C5).
- **Who/when:** every player at a boss; the Gourmand at its first main dungeon.
- **Evidence:** `C8_sims/all_paths_table.md`, `seq_gallery_*.md`, `one_D-HOG_13.md`; C3 F1 (`C3/c3r13_01_result.png`, `c3r17_05_result.png`);
  C4 F4; C5 F3 (`C5/c5r19_28_fight_start.png`).
- **Fix:** C8's numbers as the starting point. Gallery: no Perfect Form on the third wing's Normal fights (or Echo HP 20 -> 14), relabel
  the hardest node Elite, target 30-50 % clears. Clench: starting Iron 2 -> 1. Snack Bar 1 cost "Pay 1: +2/+0"; B-24 +1 defence. Betty's
  Surly +3/+1 -> +2/+1; the Automaton loses one extra. Gatekeepers get a rule twist that teaches the Path. Necrocrat: drop the Trophy
  Hall Honor Guard's starting Militia. ZoneOrderEase: an HP floor of about 0.65 and an attack ease that grows with places early (-1 at 2,
  -2 at 3), Gourmand to about 0.8, and add the Necrocrat to the early study. Siphon without Elowen drops a Protocol. Shorten the castle's
  main line to about 6 rooms with optional side rooms, and pay late fights in things gold can't buy (a card pick, a relic). Primm: no
  change until Decision 9's re-measure (the sims say too easy, C4c says phase 1 is too short a clock). Re-sim each, then one play critic
  per changed boss.
- **Effort:** L. **Impact 4, reach 4.**

### 10. Primm's finale: flow, staging and the phase break
- **What:** Primm's two-card limit fills the hand, and the end-of-turn "Too many cards - choose 1 to toss" step is announced only in the
  side panel, with a disabled Toss button and Space doing nothing. Phase 1 ends on the ordinary "VICTORY!" box naming "Primm - Phase 1:
  Standardization". The fight uses a reused village-square board, not the Model Room the intro builds up. "Every unit starts as a 3/3"
  visibly didn't apply to the player's units (7/4, 6/4). "Setting Up: first 2 turns" didn't match when the Militia first attacked. The
  boss node is a "???".
- **Who/when:** every player who reaches the end.
- **Evidence:** C4b F1-F2 (`C4b/c4b_r22_q03.png`, `c4b_r21_p01.png`), C4c F2, F6-F8 (`C4c/c4c_r6_q03.png`, `c4c_r3_battle_start.png`,
  `c4c_r5_b06_t3.png`), C4c F12.
- **Fix:** a big centred "Hand full: click a card to toss" prompt over the hand, with Space tossing the lowest-value card. A phase-break
  card in place of the victory box; show "Primm" in plates and logs. Wire the Model Room board (BB-PC-BOSS exists; check which board the
  boss node loads). Check the 3/3 rule on the player's side (rule or display bug) and word Setting Up in rounds with a countdown on the
  Militia. Show the boss node as the Model Room. A checkpoint between phases (also needed for testing the ending). Also check the
  castle's first fight (Hedge Trimmer Guard, "Mirrors: the first card each player plays is copied"): C4 saw the player's side with no
  infrastructure and 1 energy at round 2 in both tries (C4 F1, `C4/c4r31_05_stall.png`). The pilot loop behind C4's stall is fixed and two
  re-runs won, but exclude Infrastructure from Mirrors and log "Mirrors copied X" in big text either way.
- **Effort:** M. **Impact 4, reach 3.**

### 11. Fix the story's finale and ending contradictions
- **What:** the Wanderer's climactic lines quote the four leaders; Primm never answers "You took my mother and father", and the hero
  forgives him in the same breath; the ending says the castle comes down, then "does not fall; it opens"; Maren is "the first" to say the
  prince's name after saying it several times (and beat 10 is tagged with Agnes as the speaker); "all that way I never once asked her"
  contradicts two "Who are you?" lines; the credits roll while the Rescuer is in a cell; the identity reveal (Memory 4) gets no reaction.
- **Who/when:** every player who finishes; the last impression.
- **Evidence:** C6 weak moments 1-5 (`capital::cutscene.primm_p1.2`, `primm_p2.2`, `primm_end.3-8`; `capital::ending.beat.1/8/10`;
  `scenes::pc_capture/steps/9::1` vs `intro::prologue.wanderer.1::0`; `intro::memory.4.reply::0`).
- **Fix:** C6's rewrite directions: one line of the Wanderer's own at the climax, Primm answering the accusation in his own register, no
  instant forgiveness; pick "opens" for the castle; branch beat 8's "everything comes back"; fix the speaker tags; "I asked her twice and
  she said 'a friend'"; an ending beat that notices her absence (or the Lab before the credits); a Wanderer beat before he absolves Maren.
  In the same pass: cut two of the identical "you've a look of the prince" hints and give the Wanderer a reaction to the rest (C6 F7);
  make Primm's confession about credit and consent, not authorship, so it stops contradicting the archive and the ending (C6 F8); let one
  lieutenant refuse redemption and one be arrested instead of three identical menial-job turns (C6 F9).
  Run it as a dialogue CSV pass (`tools/export_dialogue.js` / importer) and check the zone-lesson tests afterwards.
- **Effort:** M. **Impact 4, reach 3.**

### 12. Card readability and the triple hover
- **What:** rules text on hand and grid cards is unreadable at 720p and small at 900p; the rarity gem clips "Basic Infrastructure"; hovering
  a hand card shows it three times (left preview, raised card, tooltip) and at 720p the preview covers the Battle log and item slots; a drag
  can grab the neighbouring card after the fan re-flows; the hand balloons to 11-14 overlapping cards.
- **Who/when:** every player, every turn.
- **Evidence:** C7 F2-F3, F17 (`C7/c7_j_j_bat_02.png`, `c7_l_l_bat_03_hover.png`), C1 F13, C1b F10, C3 F12, C5 F8.
- **Fix:** fanned hand cards show cost, name and stats (full text on hover); drop the left preview for hand cards; move the gem off the type
  line; start a drag on the currently raised card; two-row fan or a hand cap above 10. **Effort:** M. **Impact 3, reach 5.**

### 13. One Esc/focus rule for every screen
- **What:** Esc doesn't close the dungeon Rules panel, the battle log or the Deck Station; in shops it goes back two levels at once or
  leaves a buy confirm floating; Settings' Back and Esc go different places. Keyboard focus is visible in the Deck Station and invisible in
  the pause menu, Settings and the dungeon map.
- **Who/when:** keyboard and controller players, all game.
- **Evidence:** C7 F4 (`C7/c7_a_pause_02_kbd.png`, `c7_l_l_dun_05_kbd.png`), C1b F8 (`c1b_r17_04_after_esc.png`), C2b F8, C5 F9.
- **Fix:** a modal stack: Esc closes the topmost popup only, with a 0.2 s guard after a close; Back returns to the opener; the Deck
  Station's gold focus ring everywhere. Extend the gamepad smoke to assert Esc closes each registered screen. **Effort:** M. **Impact 3, reach 4.**

### 14. Endgame and postgame wayfinding
- **What:** the main quest isn't auto-tracked on load; "Go to the Capital" has no direction and the way in is an unmarked trigger behind
  Brannoch; nothing points to the Crease; the castle is 20-25 "???" nodes. In the postgame the forest hatch can't be reached on foot (the
  hero stops south of the camp; likely the old bramble collider), the forest drops the tracker, J and the goal pin, and the Gallery has no
  quest entry, no "Where to?" line and unlabelled Crease doors.
- **Who/when:** every player in the last third; the forest hatch blocks the postgame story outright.
- **Evidence:** C4 F2, F5 (`C4/c4r1_03_map.png`, `c4r26_10_map.png`), C4b F3-F4, C5 F1 (blocker, `C5/c5r9_18_map2.png`), C5 F2, F4.
- **Fix:** auto-track the main quest on step change; a visible exit with "[E] Travel to the Capital"; a tracker step and pin for the Crease;
  show node types once a neighbour is cleared; remove the forest's postgame bramble collider and add a walk smoke from the rift to the hatch;
  the forest as a normal zone in the postgame (tracker, J, pin); a Gallery quest line, a "Where to?" entry and labelled Crease doors.
  While there: the Capital is one straight corridor with four identical "A Perfectly Happy Citizen" NPCs and no doors or shops - name the
  citizens, open 2-3 side doors, add a last shop or healer (C4 F6). In the Gallery, show heals in the log and as floating numbers (a
  3-life foe rose to 9 with no explanation, C5 F5).
- **Effort:** M. **Impact 4, reach 3** (the main-story half reaches every player who finishes the zones; the postgame half fewer).

### 15. First-visit hitches, the Dump's load and Low-end mode
- **What:** the first Verdant Dump load takes 15.5-17 s with nothing on screen ("painted: swaps 7360 ms"); a 0.4-0.5 s freeze about 3 s
  after each zone's first arrival (shader compile); a 0.6 s hitch 4.9 s after returning to Crosspath; Capital walking spikes of 36-44 ms;
  Low-end changes almost nothing (same memory and loads, still Forward+), adds black holes in the Gainlands cliffs, and Settings still shows
  DoF/Bloom/Fog on.
- **Who/when:** every player on a modest PC; the target audience of Low-end.
- **Evidence:** C9 F1-F7 (`C9/` shots; `load_timing` lines in the runs' stdout).
- **Fix:** bake the painted swaps at import/export (or stream after the fade) and show a loading card over 2 s; prewarm zone materials
  behind the fade; find the deferred town step at ~5 s; Low-end lowers the texture mip limit, foliage counts, draw distance and particles,
  and offers the Compatibility renderer; refresh the dependent Settings rows when a preset is chosen. The Capital's "inside the gate" view
  shows grey stand-in blocks and a dark slab over half the screen - fade the occluder and hide the stand-ins (C9 F8,
  `C9/c9_b_b_05_cap_walk2.png`). **Effort:** M. **Impact 3, reach 5.**

## 3. Quick wins (S effort, not in the top 15)

UI and text:
- Character page "0 / 4 unlocked" means equipped: "Equipped 0 of 4" (C2 F11, C3 F2, C7 F9). *Checked: C3's "all slots locked at L13" is
  this label plus the snapshot leaving items unequipped - the slots are open (`character_screen.gd:537`).*
- "Equipment unlocks after Some Assembly Required" -> name it as a quest; don't hand out a relic the player can't equip (C1b F7, C7 F9).
- Settings: the Accessibility tab label clips ("Accessibil"); theme the OptionButton popups; reset scroll on tab change (C7 F6, C9 F12).
- Pluralise "in 1 rounds" and "at most 1 colors"; "Hidelog" (C7 F10).
- Dialogue prompt says "close" on lines that aren't the last, and while typing (C1 F8, C2b F12, C4b F14); ignore E for 0.5 s after a
  conversation closes (C1b F13). Every line takes two presses (finish typing, then advance): a faster typewriter and hold-to-fast-forward
  (C1 F8, C1b F13, C2 F12, C4 F13).
- Curb Alert and other Refuse Pile targets: open the pile as a large picker automatically - a human hesitates at the 60 px pile too (C2 F7).
- Overworld haze: cut the Dump's colour grade and edge blur by about a third and give walkable ground its own value (C2b F11, C3 F13).
- Time-limit toasts to 3-4 s and clear them on dialogue open (C4 F8, C2 F11 stale Power Wraps toast).
- Hold the zone title banner until no dialogue is open, and skip it after a defeat (C2b F10, C3 F14).
- Quest log control hint is under the quill art (C7 F11); tip boxes overflow and cover content (C1b F11, C7 F12, C3 F6 tip over the
  End Turn confirm).
- Dungeon Rules text shows a raw "[*]" (C5 F9). Unreachable map nodes: say "Not reachable yet" (C4b F7).
- Cave banner subtitle "The Forest Clearing" under "The Forgotten Cave" (C1 F9).
- The Hollow Well offers a heal at full HP (C1 F6).
- The Doppelganger's speaker label spoils the Grand Chef reveal (C3 F8); Alembic says "Four Paths" after a two-Path brew (C3 F9);
  Alembic: "Brew now / Tell me more" after two lines (C3 F10).
- Alembic's craft screen: the first click is eaten and the panel resizes under the cursor (C3 F5).
- Interaction priority: shops/NPCs over signposts; talk prompt at 2.4 m for quest NPCs (C3 F3, C4 F13).
- Sable tells a Refusemancer their deck is "all plain neutral cards" (C2 F8); Tilly's item lines contradict ("every fight" vs "one use")
  (C1b F6); give "darling" to Sable only (C1b F14, C6 F19).
- Moss Mulligan shows no portrait although `NPC-MULLIGAN` exists - wire it; build or remove the "breathing wall of thorns" text (C2 F6).
- "Rules of this fight" drawn twice on the battle HUD (C2 F14, C4c F9); the round label lags the banner (C4c F11); the ENEMY TURN banner
  over the action line (C4b F11); the sticky tooltip after a play (C4b F12).
- Name tags over the wrong NPC (Old Hob over Granny Gristle's prompt) (C2b F5); the gear tip says 5 locked pieces, shows 1 (C2b F9).
- Castle entry popup titled "???" and stating the broken-service debuff with 4/4 restored (C4b F5). Narration under character nameplates
  (C4b F8, C6 F20). The Model Room text says "grey coat"; the art shows white and gold (C4b F9, C4c F10).
- Tidy-Bots: a visible patrol with a gap to time, a stun with no HP loss, or a heal to full at the Spotless exam - today every retry pays
  4-6 of 23 HP on the walk *to* the exam (C4 F3, major); off once the exam is passed (C4b F6). The Spotless exam uses the BB-CAP-OUT board,
  not the purple wasteland (C4 F11).
- "Welcome to Primm's Perfection" after Primm is gone; rift spawn 2-3 m in front of the station; the "???" station lists (C5 F10-F11).
- Freed-zone payoff: statues on the fountain plinths, "Storm the Castle" once 4/4 (C4 F10).
- Defeat dialogue order: the wake narration before the guard and the fee (C4c F4).

Story (C6, line edits):
- Gerald both passed on and still serving coffee (F11). Maren "the day she brought you to my door" (F12). Kestrel's Capital instructions
  loop (F14). Bramble's compost line after the culprit is caught (F23). Plant the D.N.A.'s Tuesday rule early and give Kyle the filing (F6,
  S-M). Cut ending beat 6's sermon (F10).

Data and tests:
- Gallery Echoes drop their signature cards (`ZoneDecks: NB-16 is enemy-only ... dropped`, N-33 likewise): add the Echoes as allowed owners
  (C8 F6, `C8_sims/gallery_dropped_cards.txt`).
- The two failing GUT scripts from Part 0: Bestiary entries for the eight S-GALLERY foes; update `test_polish_chests`' expected quest gold.
- `--filter` taking several keys and a `--resume` for the balance sim (C8 tool note).

## 4. Art needed

In the art-list format (`docs/art/art_needed_nov2.csv` columns). Most visual findings are wiring or code, not art: Moss's portrait, the
Model Room board (BB-PC-BOSS) and the Capital exam board (BB-CAP-OUT) already exist.

```
Art ID,Category,Zone,Name/what,Priority,Lock (STYLE LOCK name),Size/format,Save to,File name(s),Image description,Notes
BB-S-GALLERY,Battle board,Postgame / The Shattered Gallery,"The Shattered Gallery battle board",High,BOARD,"16:9 1920x1080, opaque",Approved_Boards,BB-S-GALLERY.png,"[BOARD lock] A long mirrored hall seen from above at the board's usual angle: cracked silver mirror panels on both sides reflecting a cold blue-white light, a polished dark marble floor with hairline cracks radiating from the centre, thin gilt frames, a faint silver dust in the air. Calm centre for the cards, detail at the edges.","C5 F5: the Gallery's fights play on a pure black board today. Silver and cold to match mirror_tint.gdshader."
DEC-PLINTH-EMBLEMS,Prop set,Crosspath,"Four Path emblems for the fountain plinths (one per freed zone)",Medium,PROP,"4 images 1024x1024, transparent",Approved_Props,"DEC-PLINTH-BEEF.png, DEC-PLINTH-NECRO.png, DEC-PLINTH-GOUR.png, DEC-PLINTH-REF.png","[PROP lock] Four small stone-and-bronze statues for square plinths: a raised dumbbell held by a fist (Beefcake), a quill crossed with a bone over a ledger (Necrocrat), a covered silver dish with steam (Gourmand), a sprouting tin can with a raccoon tail curling round it (Refusemancer). Same stone base, same warm afternoon light, three-quarter view.","C4 F10: the plinths stay empty after all four zones are freed. One appears per freed zone."
UI-CAULDRON,UI icon,Crosspath / Auntie Alembic,"Painted cauldron for the crafting screen",Low,UI,"1024x1024, transparent",Approved_UI,UI-CAULDRON.png,"[UI lock] A squat copper cauldron on three iron legs over embers, bubbling with four swirling colours (red, green, gold, violet) that do not mix, wisps of steam, painted in the same style as the vendor portraits.","C3 F13: the flat green vector cauldron clashes with Alembic's painted shop."
UI-BG-PACKS,UI background,Menus,"Painted framed background for the Card Packs, pack result and Wardrobe screens",Medium,UI,"16:9 1920x1080, opaque",Approved_UI,UI-BG-PACKS.png,"[UI lock] A shopkeeper's table seen from the front: dark wood, a green felt cloth, brass corners, warm lamplight from the top left, a soft empty middle for the pack grid or the hero preview, the same gold-on-wood frame as the Character and Quest Log screens.","C7 F7: these three screens use a flat purple-to-orange gradient unlike every other screen."
KIT-HEAP-THORNWALL,Zone kit piece,Verdant Dump / gate,"The breathing wall of thorns across the forest path (corrupted and withered states)",Medium,ZONEKIT,"2 images 2048x1024, transparent",Approved_ZoneKits/heap,"KIT-HEAP-THORNWALL.png, KIT-HEAP-THORNWALL-DEAD.png","[ZONEKIT lock] A wall of tangled violet-black thorn vines, three metres high, filling a forest path between two trees, swollen as if mid-breath, with small glowing seed pods. The second image: the same vines grey, withered and parted in the middle.","C2 F6: the text promises a breathing thorn wall at Moss Mulligan's gate; the path behind him looks open. Swap to the withered state when the gatekeeper falls."
```

## 5. Don't touch

Named by most critics, in this order of agreement:
- **The "What beat you" defeat recap** (C1, C1b, C2b, C3, C4, C4c, C5, C7) - turns a loss into a lesson. Add it to close wins too.
- **The painted art**: portraits (C1b, C2, C2b, C7), dungeon node maps (C1, C2b, C3, C4b, C5), boss stills - the Doppelganger unmasking,
  the castle-gate arrest, the Model Room (C3, C4, C4b, C4c), the title screen and the Capital's pastel satire (C4, C7).
- **The writing voice** (all play critics, C6): Tilly, Sable, Maren, Bertram, Old Hob, Spotless, Primm ("This will not hurt. It will,
  however, be Standard."), Rip, Dr. Siphon. C6's list of untouchable scenes: the royal funeral, Isla's homecoming, the Doppelganger
  getting a name, the Agnes vacancy, Compostella's release, Primm's last journal.
- **The pre-fight "Before the fight" rules card and the dungeon Rules (R)** (C2b, C3, C4, C4b, C5).
- **Duel-1 onboarding**: one tip at a time with an arrow and "the duel waits for you", the phase ladder, the energy-cost tooltip, the End
  Turn guard (C1, C1b, C5, C7).
- **The quest log's "Where to go" line** and reward preview (C1b, C2, C3, C5).
- **The Deck Station's rules panel, curve and focus ring** (C2, C7) - fix its traps (item 3), keep its design.
- **Alembic's brew odds grid** and the Well's "about 69 % to pass" line (C1, C3).
- **The Rift Express screen** (C5); **event nodes with real three-way choices** (C4b, C5); **the shop buy confirm** (C1b, C2, C2b).
- **Balance:** the L10-21 middle of the curve for three Paths, each Path strongest at home, Swolympus' Ancient Spotter, and the cards
  C8 names as pulling their weight (B-06, B-36, N-01, N-15, R-08).
- **Stability:** no game script errors in ~230 runs; memory plateaus across travel loops (C9).

## 6. Decisions for the owner

1. **Should the main quest lead to the Path gatekeeper before Maren's errands?** The errands (merchants, deck edit, store room, armory)
   sit between the cave and the player's own Path, and two critics never got past them. *Recommended default:* keep the errands but make
   them a parallel "Settling In" line; the main tracker shows the Path gatekeeper from the Path choice on, and the gatekeeper is beatable
   at any point.
2. **Defeat cost.** Fees plus a walk back to the start make losses spiral. *Recommended:* no fee below 50 gold, retry from the node before
   a boss, and a consolation (gold per unit destroyed).
3. **Opening-hand guarantee.** *Recommended:* at least two infrastructure in every opening hand (a hidden soft mulligan), not only in the
   tutorial - it fixes most "I played nothing" losses without touching card numbers.
4. **How hard is the Shattered Gallery's full run meant to be?** 1/40 with Silver Reserve +40 today (the sim applies it,
   `balance_sim_tool.gd:216`), and two Echoes miss their cards.
   *Recommended:* 30-50 % for a good deck; fix the dropped cards first, then take Perfect Form off the third wing's Normal fights.
5. **General Packs for one-Path decks.** *Recommended:* weight them 60 % to the player's Path(s) plus colourless; keep fully random packs
   as a cheaper "Mystery Pack".
6. **The ending's castle and the Rescuer.** *Recommended:* the castle "opens" (matches the postgame), and the ending names the Rescuer's
   absence with a hook to the Lab, rather than moving the Lab before the credits.
7. **Town fog of war.** *Recommended:* the hub towns (Crosspath, the Capital) are fully revealed on first entry; fog stays for zones,
   showing their outline and landmarks.
8. **Low-end's purpose.** *Recommended:* make it a real memory and GPU cut (texture mip limit, foliage, draw distance, Compatibility
   renderer), even at a visible look cost, since its audience can't run Medium.
9. **Primm's difficulty.** The sims call him too easy for every Path with reference decks; play critics lost him 2 of 3 with snapshot
   decks and the pilot. *Recommended:* fix the toss step and the 3/3 display first, then re-measure with one hand-played critic before
   changing his numbers.
