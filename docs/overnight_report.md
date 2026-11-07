# Fix pass Nov 7 - report

Brief: `docs/prompts/fixes_nov7.md` (critic top 15, part 1, with owner decisions D1-D8). Source: `docs/review/critic_nov6_summary.md`.
State: `docs/loop_state.md`. Questions and choices made: `docs/overnight_inbox.md`, "Fixes Nov 7". Screenshots: `docs/overnight_shots/nov7/`.
Tag `pre-fixes-nov7` marks the start. No export.

## Part 1 - First hour (items 1, 4, 5; D3, D6)

- **Your Path (item 1, D3).** Picking the Path starts that zone's main line (its gatekeeper) at once and tracks it; the tracker keeps a
  standing **YOUR PATH** line ("Face Brick Bronson on the Gainlands road") while anything else is tracked; the map and minimap ring that
  road's exit and gatekeeper in the Path's colour; Maren names the zone, gatekeeper and road at the cave mouth and again in her Path talk
  (no longer waiting for the armory); E at a sealed portal prefers the guardian standing in front of it.
- **Settling In (D3).** Maren's four errands are a side line tagged SETTLING IN; they never take the tracker from a main quest; the other
  zone lines, Fragments and Brannoch's quest open on the first arrival in Crosspath. Every gatekeeper can be fought at any point.
- **Opening hand (D6).** Every player opening hand holds at least two infrastructure (a hidden swap with the deck; after a mulligan too).
- **Early fights (item 4).** Wild Growth waits until round 3 in a main dungeon's first rooms; the cave's duel 2 has 7 HP and a Shield
  Bearer; the Warden's swarm is smaller; the Refusemancer starter swaps two Desperate Measures for a Watchtower Archer and Kidding Around.
- **Input traps (item 5).** Nothing is pre-chosen on the victory pick and E takes nothing until a card is chosen; the whole Path column is
  one click target with "Pick a Path first" beside a disabled Begin; quest banners wait while a dialogue is open and size to their text;
  the dungeon map tip sits low, clear of the title scroll, and states the D2 rule.

**Re-sims** (reports in `docs/design/sim/nov7/`, numbers in `docs/design/balance_log.md`):

| | Beefcake | Necrocrat | Gourmand | Refusemancer |
|---|---:|---:|---:|---:|
| Whole cave, before (C8) | 92 % | 92 % | 96 % | 79 % |
| **Whole cave, after** | **96 %** | **96 %** | **100 %** | **96 %** |
| Own gatekeeper (quick, L3; band 60-75 %) | Brick Bronson 92 % | Prudence Pallor 83 % | Chef Fennel 67 % | Moss Mulligan 92 % |
| Own first dungeon node, expected level | 83 % | 100 % | 100 % | 100 % |
| Own first node, bare starter at L5, no gear | 75 % | 50 % | 42 % | 83 % |
| Own first main dungeon, early study, L9 (60 runs) | 67 % | not run (time cap) | 87 % | 63 % |

The Refusemancer against Brick Bronson was 25 % in C8; now 67 %. Two own gatekeepers sit above their band (Brick Bronson and Moss
Mulligan for their own Paths, 92 %), which the gatekeeper rule twists of item 9 would address. Shots: `p1_path_choice_card_click.png`,
`p1_victory_no_default_pick.png`, `p1_cave_map_tip.png`, `p1_forest_path_quest.png`, `p1_town_path_tracked.png`.

## Part 2 - Walking and maps (items 2, 7, 14; D5, D7)

- **Walking.** The hero's body slides along whatever it meets (a tangent slide in the one mover every scene shares); Crosspath's prop
  colliders shrink to their footprints (lamps, signposts, benches, the notice board, dressed props x0.8); the fountain plinths moved out
  for a ~3 m clear ring; standing townsfolk keep only a 0.1 m core; a house between the camera and the tracked goal's door dissolves
  when the hero is within 11 m; door goal markers hang at the door. The camera yaw was already fixed (only a held swivel key turns it).
- **Reach walk smoke** (`bash tools/run_reach_walk_smoke.sh`, report `docs/review/nov7/reach_walk_smoke.md`): from the spawn to every
  shop and exit in Crosspath, the four zone hubs and the Capital, plus the postgame forest's Rift station to the Lab hatch, planned over
  each area's own walkability and walked with held keys: **38 of 38 reached** (the Dump's north landings with the vine bridges grown).
- **Compost Commons.** No invisible wall exists in the walkable map; the critic's stops were small round props met head-on by the old
  axis-only slide. The stream north is crossed by the grown vine bridges, as designed.
- **Maps (D5, item 7).** Towns stay fogged; shops, exits, quest givers and landmarks always show; walking reveals 16 m (was 9); roads are
  drawn, through the fog too; zones show their outline from the first arrival. Labels move round their icon and stay inside the frame.
  A "Where to?" pick leaves a labelled white arrow at the screen edge until you get there. Each zone hub has a roamer near its exit.
- **Endgame wayfinding (item 14).** A main quest's step always takes the tracker; exits say "Travel to the Capital" (sealed ones name
  their guardian); Free the Four Zones gains a Crease step with a pin; castle rooms show their type once a neighbour is cleared (the boss
  node is always the Model Room). **Postgame blocker fixed:** the Lab's path opened only after Rip's tip in Crosspath, so any other way
  into the forest met the old bramble collider; it now opens with the postgame, and the forest has the tracker, J and a goal pin. The
  Gallery has its own quest line and map / "Where to?" entry, and every Crease shaft names where it leads. Heals name their cause in the
  log and float "+2 HP (Nourish)".
- **The Capital (D7).** The nine citizens have their own names on their labels and over their lines (Gideon Plumb, Bea Ashgrove...);
  Dorrit's Last Stall stands on the castle approach; no side doors.

Shots: `p2_town_map_d5.png`, `p2_your_path_line.png`, `p2_forest_hatch_reached.png`.

## Part 3 - Menus and cards (items 3, 8, 12, 13; D4)

- **Deck Station.** Save Deck saves the deck's own slot at once (a toast says when it is not your battle deck); "Save as new slot" picks
  another; Esc with unsaved changes asks Save / Discard / Cancel; the list scrolls with the wheel over any row; every add shows "+1". The
  53-vs-51 count was the old save trap: the station showed the edited deck while battles used the last one actually saved.
- **Packs (D4).** Any click skips a single pack's animation; Open all shows the cards in a grid with NEW badges (new first) and says how
  many gilded packs it leaves; toasts are held over it. General Packs stay fully random; Sable stocks 6 Commons of the player's Path and
  5 of each other Path.
- **Cards.** Hand cards are compact (cost, name, art, stats) and the hovered one is shown whole; no left preview for hand cards; a drag
  starts on the raised card; above 10 cards the hand uses two rows; the legacy frame's rarity gem moved off the type line. Checked at
  1280x720 (`p3_hand_720p_compact.png`, `p3_hand_720p_hover.png`).
- **One Esc rule.** One press closes one thing: the first handler owns it and nothing else counts for 0.2 s; a confirm dialog answers Esc
  itself; Esc steps back out of the pause menu's pages; the dungeon Rules panel and the battle log close on Esc; every FancyButton shows
  the gold focus ring. The gamepad smoke now also checks that Esc closes the Quest Log, Character, map, Packs, Wardrobe and Deck Station
  screens (all pass; the smoke had been stale since the Nov 3-4 equip steps and was updated).

## Part 4 - Losing (D1, D2) and Primm's presentation (item 10)

- **D1.** Losing costs nothing anywhere: no fee (the six wake gags keep their joke, waived), no item loss, no Try again. A zone loss
  wakes you at the hub at full HP; Primm's at the Capital; a cave loss in the forest clearing with the cave starting over (the Nov 4-5
  retry in place is retired).
- **D2.** Leaving or losing restarts a dungeon, and every run pays every node again (it already did). The Retreat confirm and the map tip
  say "Leaving resets this dungeon. Cards and gold you've won are kept."
- **Primm (presentation only; his numbers are unchanged).** A big "Hand full: click a card to toss" prompt, with Space tossing the
  lowest-value cards; a "Phase 1 Broken" card instead of Victory; "PRIMM" on the plate and in the log; the fight plays on the Model Room
  board (BB-PC-BOSS, verified); the boss node always shows as the Model Room; Setting Up is worded in rounds with a countdown beside the
  round label; `dev primm 1|2|3` in the play driver is the checkpoint between phases; Mirrors never copies Infrastructure and announces
  what it copied. **"Every unit starts as a 3/3" was neither a rule nor a display bug:** the rule standardizes both sides' base stats and
  buffs add on top; the critic's 7/4s were 3/3 plus that save's gear and boons (GUT-tested through Primm's real seat). Two real display
  gaps found on the way (cards rebuilt by a mode change, and newly drawn cards, showed printed stats until their next refresh) are fixed.
  Shots: `p4_primm_model_room.png`, `p4_primm_phase_break.png`.

## Part 5 - Quick wins

Done: "Equipped N of M"; the equipment-unlock line names its quest, and the trophy now comes with the armory; Settings tab label, scroll
reset and themed dropdowns (and the map's "Where to?"); plurals; the dialogue hint says what E does now, a faster typewriter (Normal 80
letters a second), hold E to speed up, E ignored for 0.5 s after a conversation closes (town and zones); toasts last 3.5 s and a dialogue
clears them; the zone banner waits for dialogue and is skipped after a defeat; the cave's subtitle; dungeon Rules bullets; "Not reachable
yet"; the Hollow Well's reveal greyed at full HP; shops and people before signposts, quest givers' prompt at 2.4 m; Sable's and Tilly's
contradicting lines; Moss Mulligan's portrait; the doubled rule row; the Capital's welcome after Primm, the Model Room coat, the castle
popup's title and services line; Rift arrivals 3 m from the station; Alembic's "Two Paths" and "Brew now / Tell me more"; the
Doppelganger's cover name in the Test Kitchen's opening; the Spotless exam on the gilded gate board; the balance sim's `--filter` takes
several keys. Both failing GUT scripts are fixed (eight S-GALLERY Bestiary entries and their request rows; Meet the Merchants' current
80-gold payout), plus a third stale test (the Gallery quest has no hand-in). On hold as instructed: story line edits, Tidy-Bot balance,
the Gallery Echo cards. Not done: inbox "Fixes Nov 7", item 12.

## D8 - Art rows

The five rows (BB-S-GALLERY, DEC-PLINTH-EMBLEMS, UI-CAULDRON, UI-BG-PACKS, KIT-HEAP-THORNWALL) are in `docs/art/art_needed_nov4.csv` as
"Needed - later batch".

## Finish

- **Tests:** all 29 GUT shards green - 2824 of 2826 passed, 0 failing, 2 risky/pending (`bash tools/run_tests.sh --only=tests --size=12`). Windowed smokes run: reach walk (38/38), gamepad (OK, with the new Esc checks).
- **Fresh-eyes critic:** CRITIC_LINE

# Critic pass Nov 6 - top 15 improvements

Brief: `docs/prompts/critic_nov6.md`. Full synthesis (scorecard, evidence, fixes, quick wins, art rows, don't-touch, owner decisions):
**`docs/review/critic_nov6_summary.md`**. Reports and screenshots: `docs/review/critic_nov6/`. Inbox: "Critic Nov 6". No export; no game
code changed (only the play driver's pilot, three blocker fixes, plus a `perf` command).

Mean scores across 13 critic runs: fun 5.0, clarity 4.8, difficulty 4.2, text 7.1, look 7.4. No play critic finished its section as
briefed: walking, wayfinding and difficulty swings stopped all of them. No game script error in about 230 runs.

| # | Improvement (first hour: 1-5) | Impact | Reach | Effort |
|---:|---|---:|---:|---|
| 1 | Point every player at their Path from minute one (tracker line, map icon, E prefers the guardian at a sealed gate) | 5 | 5 | M |
| 2 | Make walking work: colliders with sliding, non-blocking roamers, fixed town yaw, roofs cut away, the Dump's invisible wall | 5 | 5 | M |
| 3 | Fix the Deck Station traps: slot-pick save mode, Esc/X dead with unsaved changes, missed clicks, hidden rows, 53-vs-51 count | 4 | 5 | M |
| 4 | Stop early mana starvation: 2 infrastructure in opening hands, no Wild Growth on first nodes, a smoother cave, a sturdier Refusemancer start | 4 | 5 | M |
| 5 | First-hour input traps: E takes a reward card, Path choice dead clicks, toast over Tilly, hidden map tip, cave resets on leave | 3 | 5 | S |
| 6 | Losing never spirals: no fee when broke, retry bosses (and Primm) in place | 4 | 4 | S |
| 7 | Reveal the town map, draw "Where to?" routes in the world, a roamer in sight of each hub exit | 4 | 5 | M |
| 8 | Packs as a reward: a card-face reveal, Path-weighted General Packs, more Path singles | 4 | 4 | M |
| 9 | Retune the agreed outliers: Gallery 1/40 (+ dropped Echo cards), Clench vs Gourmand, Beefcake fall-off, Necrocrat snowball, Betty/Automaton, ZoneOrderEase floor, late rewards | 4 | 4 | L |
| 10 | Primm's finale: a toss prompt, a phase break instead of "VICTORY!", the Model Room board, the 3/3 rule check, a phase checkpoint | 4 | 3 | M |
| 11 | Story finale and ending contradictions (C6 weak moments 1-5, plus prince hints, Primm's confession, the redemption conveyor) | 4 | 3 | M |
| 12 | Card readability at 720p and the triple hover | 3 | 5 | M |
| 13 | One Esc/focus rule for every screen | 3 | 4 | M |
| 14 | Endgame/postgame wayfinding: the Capital route, the Crease, the Gallery, the forest hatch (blocker), a thin Capital | 4 | 3 | M |
| 15 | First-visit hitches, the 17 s Dump load, a Low-end mode that cuts memory | 3 | 5 | M |

Not reviewed as played: Primm's phase 2, the ending and the credits, Swolympus, the Lab's middle, a real Gallery run (see the summary).

---

# Overnight Nov 4-5 - report

Brief: `docs/prompts/overnight_nov4.md` (Parts 1-8 + Finish). Tag `pre-overnight-nov4`. Decisions: `docs/overnight_inbox.md` ("Overnight Nov 4-5").
Shots: `docs/overnight_shots/nov5/`. Previous report: `docs/overnight/nov4b/overnight_report_fixes_nov4b.md`. No export.

## Part 1 - the critic's list (docs/review/critic_nov4b.md)

| # | Item | Result | Evidence |
|---|---|---|---|
| 1 | Old Man Mountain | His first talk now says the gate hint himself (4th box: "that gate up on the overlook... opens when the kingdom is whole again"). Any NPC speaks to the NEWEST active quest of theirs first (`Session.quests_active_for`, zone NPCs and Maren), so after "Only the Worthy..." he talks about the shake, not "Spot Gary". | `tests/core/test_overnight_nov5_part1.gd` |
| 2 | Alchemist screen | Chosen jars get a gold border, a fill and "✓ Selected"; the Craft button always reads "Craft — 100 gold, 6 + 6" and, when it can't be pressed, says why on a second line ("Pick two Paths", "Need 4 more Necrocrat essence", "Need 100 gold"). A jar short of essence can be picked so the reason shows. The 16 possible cards now sit in two rows of 8 (one row pushed the whole screen past the right edge). Real craft in play with 18 + 18 essence: both jars show 12 after. | `p1_2_01/03/04_*.png`, `docs/review/play_scripts/nov5_alchemist.txt` |
| 3 | Quest log after Primm | Primm's fall closes every unfinished zone line quietly (no "0/4" left) and starts + tracks "Under the Forest" at once (`Session.settle_postgame_quests`; old saves are settled on the next town visit). A freed zone also finishes its own line without the favour step. Verified through the code a real castle win runs (`resolve_main_dungeon`); the play driver could not get through the Model Room staging into Primm's duel (inbox 1). | `test_beating_primm_in_the_castle_settles_the_quest_log` |
| 4 | Forest hatch | The hatch is at z 34, about 29 m below the clearing's south rim (was ~10 m). The trail is painted dirt with a stone kerb, flagstones, glowing blue mushroom clumps every 3-4 m, two lanterns on posts and a cool fill light; the hatch has a brighter light and a pale beacon shaft. Brambles still block it at the start. | `p1_4_closed/open/trail/hatch.png` |
| 5 | Iron Cave | The Enter popup uses the real name at the entrance. The canyon pylon that stood in front of the crag moved 10 m south. The crag has two ragged tiers, a leaning spire and stepped lumps on its corners instead of one straight block; chalk bucket, plate stack and kettlebell rack at the mouth (the torches, arch and dark recess were already there). | `p1_5_iron_cave.png` |
| 6 | First-duel tip | Sits above the Opening-hand panel, clear of Keep Hand / Mulligan. | `p1_6_first_duel_tip.png` |
| 7 | Rule text | Pump Iron -> **Home Gym** ("yours only"); zone stat rules say "on both sides"; Smuggled Weights no longer repeats the Iron line. Audit of every dungeon fight's pre-fight list (`tools/rules_audit.gd`, 71 fights): renamed the Gainlands debuff Processing Time -> Out of Breath (the D.N.A. dungeon has its own Processing Time), Mortimer's duplicate Red Tape Everywhere -> Paper Mountain, Primm's Royal Guard -> Standing Army, the Doppelganger's Perfect Copy -> Plated Just So, Specimen Conditions (enemies) -> Enhanced Specimens, Drained Strength -> Borrowed Strength; Prize Topiary says it stacks. No contradictions found. | inbox 2 |
| 8 | Nameplates | The plate measures names in capitals, shrinks the font to 20 px, then widens (up to 560 px) before shrinking further. "RIP TEARSON, RIFT TECHNICIAN" shows in full. | `p1_8_rip_nameplate.png`, test |
| 9 | Item slots | A used-up item stays in its slot greyed with a "Used" badge (battle bar and Character page) until something else is equipped there (`PlayerProfile.spent_item_slots`, saved). | test |
| 10 | Never seen in game | Rescue choice + result (button text no longer repeats the boon's description: "Flex's Promise"); a real craft (item 2); Shiro's 3 Gilded packs in the pack inventory; the D.N.A. elevators and lobby with no dialogue. Critic scripts fixed (HOG node 6 + double-click, Craft click, Shiro Continue). Cut-in hints say "E / Click" and the driver's skip handles cut-ins. | `p1_10_*.png` |

## Part 2 - economy and dungeon rules

- **Packs:** General 150, Path 200, Gilded 800 (4x Path, as before), General II 300, Prismatic 1200.
- **Repeat fights** pay the same as the first win.
- **Dungeon clear bonus:** beating a dungeon's boss pays the run's gold again, shown on the boss's Victory screen ("Clear bonus: +X gold").
  To keep the no-grind target, dungeon nodes now pay half (a finished run pays exactly the old amount, an abandoned one half).
- **Quests:** main x1.75, side quests of 3+ steps x1.6, shorter x1.5 (milestones too).
- **No deck changes inside a dungeon:** the Deck button, B on the map and the in-dungeon Deck Station are gone. Cards won go to the
  collection (the tutorial cave still adds its picks to the deck); a card lost in the Descent stays lost.
- **Tri-Path recipes:** 35 tri-Path cards exist and every trio of Paths has some; the "(no tri-Path recipes exist yet)" line was already gone.

Gold study (`docs/balance/gold_economy_nov3.md`, "Overnight Nov 4-5"). The study had never loaded the quests (they counted as 0), so the
"before" column is the Nov 4 economy re-measured with them.

| | Before | After |
|---|---:|---:|
| Earned (no grinding) | 19,159 | **21,189** |
| Items, hats, fees | -1,325 | -1,325 |
| 20 cards | -4,700 | -4,700 |
| Left for gear | 13,134 (5 pieces) | **15,164 (6 pieces)** |

By source after: main 6,415, side quests 2,180, clear bonus 2,165, side-dungeon nodes 1,140, postgame nodes 980, the rest unchanged.

## Part 3 - early-game fun check, every Path

Full write-up: `docs/balance/early_game_nov5.md` (tool `tools/early_game_study.gd`: a new save of each Path walked through the economy
timeline as a no-grind player, then its first main dungeon simulated with the starter deck + two Commons, 10 runs per Path).

**Gold:** 520 at the first shop (5 Commons, 7 items or 3 General Packs; goal 2-3), ~800-870 at the own gatekeeper, 1,530-1,890 on reaching
the first main dungeon. Affordability is fine for every Path.

| Path | First dungeon | Level | Before | **After** | HP left |
|---|---|---:|---:|---:|---:|
| Beefcake | The House of Gains | 9 | 50% | **70%** | 17.6 |
| Necrocrat | The Hall of Final Approvals | 8 | (30% with HP-only ease) | **90%** | 18.6 |
| Gourmand | The Test Kitchen | 9 | 40% | **90%** | 16.1 |
| Refusemancer | The Rotheart | 9 | 10% | **70%** | 15.1 |

Goal 65-80%. The cause was zone order: the four zones are tuned for Gainlands -> D.N.A. -> Buffet -> Dump, but every Path starts in its own,
so a Refusemancer met the Rotheart (tuned for level 17) at level 9. **Fix:** `ZoneOrderEase` (`core/zone/zone_order_ease.gd`) - a zone
played earlier than its designed place gets easier foes (HP x1.0 / 0.95 / 0.85 / 0.42 by places early, x0.85 more for the very first zone,
units -1 attack); a freed zone, the Capital and a zone in or after its designed place are untouched. Decks, prices and rewards unchanged.
Necrocrat and Gourmand sit slightly above the band (inbox 9). Tests: `tests/core/test_overnight_nov5_part3.gd`.

## Part 4 - dialogue rewrite

Full write-up: `docs/dialogue/rewrite_nov5.md`; style guide `docs/dialogue/story_voice_nov5.md`; review sheet **`docs/dialogue/edit_nov5.csv`**.

- 1,178 lines rewritten in 15 story-order chunks (main quests first, then primary characters, side quests, barks), applied as a revertible
  pass; the 15 lines a blind critic preferred in their old form were put back and 4 weak ones fixed.
- Blind critic (100 random changed lines, versions unlabelled): main story new 49 / old 5 (6 ties), side content new 29 / old 10. Averages
  new vs old - main: voice 7.5 vs 6.3, clarity 8.0 vs 7.3, emotion 7.0 vs 6.0, humour 7.2 vs 6.3; side: voice 7.4 vs 6.6, clarity 8.1 vs
  7.3, humour 7.2 vs 6.7.
- Before / after (seven of the ten in `docs/dialogue/rewrite_nov5.md`):

| Speaker | Before | After |
|---|---|---|
| The Wanderer, waking | I search for my name. For how I got here. But I find nothing. | I keep reaching for my name, or for how I got here, and there's nothing there at all. |
| Elder Maren, memory 1 | I sense something within you that wasn't there before. I trust the Paths to guide you. | That tune's stayed with you, hasn't it? I can see it on your face. Good. Keep it somewhere safe, dearie, even when it hurts. |
| Agnes Overdue, the vacancy | Even the dead deserve humanity. Our job is to help the lost souls. Following orders be damned: we treat everyone with respect. | Everyone in that queue was somebody, dear, and the dead deserve to be treated as people. No order outranks that, not his and not anyone's. |
| Elowen, Cell 4 | They put me in your cell. My father thinks that's educational. With him it is hard to tell. | They put me in your cell. My father calls it educational, and the worst of it is that he means it. |
| Widow Pell | I cannot bury him. Form 27-B needs Form 27-C, and 27-C needs 27-B. He has waited in his chair for three years. | And I can't bury him. Form 27-B needs a 27-C, and the 27-C needs a 27-B, so he's still in his chair, waiting, the way he always used to wait for me. |
| Chef Gravois, freed | The simmer let go. The sauce let go. Plain bread. No sauce. I could weep. I am weeping. | The sauce has let go of me. Is that plain bread, with no sauce on it at all? I could weep. In fact, I am weeping. |
| A freed citizen | He was not kind. He was afraid. I think both can be true. | He wasn't kind, he was afraid, and for ten years none of us could tell the difference. |


## Part 5 - The Shattered Gallery (postgame dungeon)

Design and sim: `docs/design/shattered_gallery.md`; code `core/dungeon/shattered_gallery.gd`; tests `tests/core/dungeon/test_shattered_gallery.gd`.

- **Entry:** after Primm, a cracked mirror by the castle door (primitives, cold light) and Wren's side quest "Cracks in the Glass". Looking
  into it unlocks the dungeon; it runs on the Capital's HP with **Silver Reserve** (+40 max life inside) and returns to the Capital.
- **13 nodes, three wings:** seven **Echoes** of beaten bosses (Quota, Clench, Plume, Mortimer, the Doppelganger, Clipwell, the Rotheart -
  their own decks, 18-26 HP and one twisted rule each), three costly events, one optional paid rest, and **The Perfect Copy**: your current
  deck, your max HP + 20, one extra card a turn, your own face through a silver shader.
- **Stacking wing rules:** Silvered (enemy units +1/+0, from node 2), Reflected Order (your first card each turn costs 1 more, from node 5),
  Perfect Form (your first unit each turn is copied for the enemy, nodes 9-12; new modifier `MIRROR_FIRST_UNIT`).
- **Look and sound with no new assets:** Echo plates are their originals' Bestiary pictures through `mirror_tint.gdshader`; the castle map
  and board stand in until MAP-S-GALLERY exists; the castle and Primm cues play through a detuned mirror chorus on the Music bus.
- **Rewards:** first clear 1,500 gold, 6 essence of every Path, hidden feat **Through the Glass**, and the **Mirrored card finish** (a
  silver sheen you toggle per card in the Collection Book). Repeats: side-dungeon gold, a Prismatic Pack, the clear bonus.

**Sim** (reference deck of each Path at level 26 with gear and items; target: a strong late deck beats the boss 20-35%):

| What | Setting | Player wins |
|---|---|---:|
| The Perfect Copy alone, full HP | all three wing rules, +15 HP | 3% |
| | Silvered + Reflected Order, +20 HP (**kept**) | **51%** (Beefcake 40, Gourmand 45, Necrocrat 55, Refusemancer 65) |
| Whole run, one HP pool (events skipped) | first draft | 0% |
| | Echo HP 18-26, Silver Reserve +20, two Echoes eased | 0% (one run reached the Copy) |
| | Silver Reserve +40 (**kept**) | not measured: the host stopped the sim for low memory |

Each Echo alone is beatable (Quota and Clench 100%, Mortimer 94%, Plume 84%, the Rotheart 56%), but each costs a strong deck about 10 HP.
The whole run is a wall by design, maybe too much of one (inbox 8). Knobs: `SILVER_RESERVE`, `PERFECT_COPY_HP_BONUS`, the `WING_*_ON` lists,
the Echo HP in `dungeon_content.json`.

## Part 6 - music: the Gainlands quotes

| Cue | What quoted the old march | Now |
|---|---|---|
| MUS-CREDITS | the Gainlands section (bars 22-39, trumpets + horns) | the rock riff and answer, same bars and orchestration |
| MUS-PRIMM-02 | the Gainlands section of the medley (trumpet + horn, violins) | rock riff / answer |
| MUS-PRIMM-03 | the Gainlands head in D | rock riff head |
| MUS-PRIMM-DEFEAT | the Gainlands head on horn | rock riff head |
| MUS-QUEST-ROLLO | the whole theme (horn, then violins) | rock riff / answer |
| MUS-REUNION | a horn call from the theme's head | rock riff head |
| MUS-THRONE | the head on trumpet | rock riff head |
| MUS-CAP-RESTORED | the head in D | rock riff head |
| MUS-CAP-RIFT | its own copy of the march, bent to D minor | rock riff / answer, bent the same way |

Method: the march melody (`scores/_fork_b.py` GAIN_THEME, CAP-RIFT's BEEF) was replaced by 16 bars of the rock material (`lib/rock.py`
MOTIF_RESOLVED / ANSWER_MAJOR, up a tritone into the march's Bb major and harmony), so each cue keeps its own instruments, key and length.
All nine re-rendered at q6 one at a time, every check OK (-20.0 LUFS), delivered (`deliver_part.sh`), music smoke OK. FOREST, DECK and
TUT-EXP already quote the rock riff's melody (it is the Crossroads motif) and were left alone (inbox 6).

## Part 7 - art list and import prep

- `docs/art/art_needed_nov4.csv`: every row now has its target id(s), game file, size and format (38 rows). New rows: SPR-TOWNSFOLK-A/B/C
  (a human market regular, a badger labourer, an old hare; idle + walk in FRONT / FRONTSIDE / SIDE / BACK, talk, REF) with a portrait each
  (NPC-TOWNSFOLK-A/B/C), and MAP-S-GALLERY with a full map description. Sprite batch rows NT-TOWNSFOLK-A/B/C give the importer their height.
- `docs/art/import_nov5_ready.md`: for each id, the Approved_* folder and filename, and the command.
- Node guide for the map: `docs/art/paintover_inputs/gallery_map_guide.png` (1536 x 1024, `tools/art/gallery_map_guide.py`).

### Art import checklist (importer dry run)

Every importer was run once on placeholder PNGs with the exact names of `docs/art/import_nov5_ready.md`, through its `*_SOURCE_DIR`
override (the Drive was never touched). Each run's outputs and manifest changes were removed afterwards, along with the placeholders.

| Importer | Placeholders | Result | Fix made tonight |
|---|---|---|---|
| Portraits (`import_portraits.sh`) | 10 (NPC-FLEX_REVEAL, CUT-FLEX, NPC-TOWNSFOLK, -A/-B/-C, GYM-ATTENDANT, BRISKET, SIR-LOIN, CAPITAL-GUARD) | all 10 picked up | `Portraits.EXTRA_PORTRAITS` lists the new ids |
| NPC sprites (`world_test_import.gd --npcs`) | 38 (FLEX-FREED, ROLLO, TOWNSFOLK-A/B/C) | all cut and scaled; townsfolk 21 frames, walks FRONT/FRONTSIDE/SIDE/BACK | the 8 FLEX-FREED and ROLLO files matched no batch row: rows **NS-FLEX-FREED** and **NS-ROLLO** added to `npc_sprite_batch.csv` |
| Key art (`import_key_art.sh`) | STORY-CLENCH-THRONE | matched no ID at first | row added to `logo_title_art.csv`; wired behind the flex cutscene's beats 1-2 (`StoryStills.CLENCH_THRONE`, icon stage until the file exists) |
| Bestiary (`import_bestiary.sh`) | 5 BST ids | all 5 picked up; 99 of 99 Bestiary ids would have a picture | - |
| Maps (`import_maps.sh`) | MAP-S-GALLERY | picked up | - (the castle stand-in drops out when the real file exists) |
| Opening Forest kit (`import_zone_kit.sh openingforest --only=`) | OF-PROP-BRAMBLES | matched no row at first | row added to `openingforest_kit.csv`; `StartingAreaBuilder._build_brambles` now puts two painted cards in the gap once it exists (the walls stay the same; tests pass both ways) |
| Gainlands kit (`import_zone_kit.sh gainlands --only=`) | GAIN-HERO-IRON-CRAG | matched no row at first | row added to `gainlands_kit.csv`. It is a CONCEPT row, so it lands in `docs/art/zone_kits/gainlands/concepts/` as the reference for the crag model; the target path in the art list was corrected |
| UI art | UI-BG-DECKBUILDER | not run: the id already exists in the game and the run would overwrite it | - |

Gotcha: the key art, bestiary and map importers rewrite their manifest CSV from the source folder alone, so a run on a partial folder
empties those manifests. Restore them after any test run.

## Part 8 - fresh critic playthrough

A no-context critic played a new save from a hard-linked HEAD worktree (`/c/Dev/wp_critic`), with no dev wins, levels or gold. Report:
**`docs/review/fresh_eyes_early_nov5.md`**, with 17 screenshots in `docs/review/fresh_eyes_early_nov5/`. It picked **Necrocrat** and
**never got out of the tutorial cave** in about 80 minutes:
- it lost twice (to Hollow Stalker and to the Hollow Warden), and each loss sent it back to the bedroll with the cave reset;
- two more runs stalled on input: the Shrine popup ignored E/Space, and the boss node seemed to need a second click.

So Tilly, Meet the Merchants, the shops, the road, the D.N.A. and its first dungeon went unreviewed. Gold reached 240 with no shop in
reach. No SCRIPT ERROR in any run.

**Scores:** fun 5, clarity 5, difficulty 4 (too hard for a tutorial), text 7 ("Even in death, he files."). The art and the defeat recap
("What beat you") were its highlights.

| # | Critic's issue | Done tonight |
|---|---|---|
| 1 | The cave is too hard, and a loss restarts it from the bedroll | **Fixed:** a lost fight in the intro trial no longer ends the run. You come round at full HP on the map, the fight stays open, and the defeat panel says "Try this fight again - the cards and gold you won are kept" (`Session.tutorial_retry_on_loss`). The decks are not softened (inbox 10). |
| 2 | Popups ignore E/Space; the Shrine has no exit; E at the Well gambles a card | **Fixed:** the Shrine's Rest / Continue take E / Enter / Space / pad A and the focus. At the Well, a confirm press now means "Leave it" until the test is taken; Reveal needs a click or the pad's focus. |
| 3 | E at the cave arch needs 2-3 presses | **Fixed (cause found):** the arch is at the floor's edge, so the treeline self-talk fired there, and its nudge "back toward the cave" pushed the hero out of the arch's reach. The E then only replayed the bubble. No self-talk within 3.2 m of the arch now. |
| 4 | Enemy HP "3" next to a bar a fifth full | **Fixed:** the cave's 3-HP foes have a max HP of 3 (`PlayerSetup.max_hp_cap`), so the bar starts full (and they cannot heal past 3). |
| 5 | Path choice cards are too small to read | logged (inbox 11) |
| 6 | The boss node "needs two clicks" | One click always went; the hover hint said "Click again or press E to go", which reads as two clicks. It now says "Click it or press E to go." A swallowed first click was not reproduced (inbox 11). |
| 7 | Grey untextured rocks in front of the bedroll | logged (inbox 11) |
| 8 | The turn counter counts both sides | **Fixed:** the battle shows rounds ("Round 2" on your second turn), and so do the banners and the victory/defeat lines (`BattleHud.round_of`). |
| 9 | The tutorial foes play Gourmand and Refusemancer basics | logged (inbox 11): changing their decks moves the cave's tuned win rate |
| 10 | Long name plates overflow; hand cards cut off; a tip overlaps the phase panel | logged (inbox 11) |

Tests: `tests/core/test_overnight_nov5_part8.gd`.

## Open questions (details in `docs/overnight_inbox.md`, "Overnight Nov 4-5")

1. **Primm's real fight through the driver** stalled in the Model Room staging. Verified through code instead; one manual castle run is
   worth doing (inbox 1).
2. **A dark round object by the D.N.A. lobby's west passage**: unidentified. Keep it or remove it? (inbox 3)
3. **Clear bonus vs node gold:** the nodes pay half and the bonus doubles them back (21,189 earned, 6 gear pieces). Would you rather keep
   the full node gold (~9 pieces) or a 50 % bonus? (inbox 4)
4. **The Shattered Gallery's whole run** is a wall (0 % clears in every measured setting; Silver Reserve +40 is unmeasured). How hard
   should the full run be? (inbox 8)
5. **ZoneOrderEase:** Necrocrat and Gourmand sim at 90 % for their first dungeon, a little over the 65-80 % goal (inbox 9).
6. **The tutorial cave:** losses now retry at full HP. Should the cave decks also be softened? A second critic run starting past the
   cave is needed to review Crosspath through the first dungeon (inbox 10).
7. **The critic's remaining items:** Path choice readability, grey forest rocks, other Paths' basics in the cave, battle layout
   clipping (inbox 11).
8. **Art:** STORY-CLENCH-THRONE, OF-PROP-BRAMBLES and GAIN-HERO-IRON-CRAG were wired or listed tonight. Their sheet rows say
   "Needed" / "Requested" until the art arrives (`docs/art/import_nov5_ready.md`).

## Tests (Finish)

Full sharded GUT (`tools/run_tests.sh --only=tests --size=12`, 341 scripts in 29 shards). **Shards 1-12 ran** (the audio, AI, data,
dungeon, game and quest scripts): 1,448 tests and 3 failures, all from tonight's changes and all fixed and re-run green:
- the feat count is now 41 (Through the Glass);
- Rip's forest tip was reworded by the rewrite;
- the rewrite had dropped Primm's "No order outranks treating people with respect." from `cutscene.primm_p2.2`, so that zone lesson is
  back in the new line (`edit_nov5.csv` updated to match).

**Shards 13-29 did not run.** Claude Code stopped the run for low system memory during shard 13, and its rule is not to restart a
stopped run on my own. Those shards cover the rest of `tests/core` (quests to zone), `tests/ui`, `tests/world` and the root tests. Tonight's
targeted runs covered the scripts touched in those folders (opening forest, story backdrops, the oct31n UX, the part 1-8 test files),
all green. So the brief's "every shard passed once tonight" is **not met**. To finish:
`bash tools/run_tests.sh --only=tests --size=12 --from=13` with nothing else open.
