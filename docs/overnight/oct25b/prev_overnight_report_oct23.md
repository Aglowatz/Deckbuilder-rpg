# Morning report - overnight Oct 23-24 (scripted bosses, two-Path foes, boss entrances, card picks, battle help, save slots)

Started Fri Oct 23 19:59 MDT, tag `pre-overnight-oct23` (= 965fb1d1). Brief copy `docs/overnight/oct23/brief.md`; state file
`docs/overnight/loop_state.md`; questions `docs/overnight_inbox.md` (section "Overnight Oct 23-24", items 1-8); scorecard
`docs/overnight/scorecard.md`; last report `docs/overnight/oct22/prev_overnight_report_oct22.md`. No build was exported (by rule).

## Read this first

- **Every boss and elite now has scripted mid-fight events** (64 events over 45 fights), shown from the start as amber rule icons, with a
  banner, the boss's line and a log line when they fire, and a one-line warning the turn before a timed one. The opening hour's four
  gatekeepers got "mercy moments" (their real selves slipping through) rather than threats - inbox 2 if you want them meaner.
- **Your real "Slot 1" manual save was being overwritten by a GUT test on every test run** (found and fixed tonight; inbox 7).
- **Three campaign slots**: your existing save is slot 1 - nothing was moved (inbox 6).
- Balance: every elite/boss measured on two seeds; nothing under ~35% on its two-seed mean except where the scripts were shown not to
  be the cause (the Itamae's matchups, inbox 3). Mortimer fixed in Phase 2.

## By part

| Part | Commit | What |
|---|---|---|
| 1 Scripted events | 9d4e2cfb | `EncounterScripts` (core): HP thresholds, turn triggers (warned), unit deaths/counts; effects: phase rules, summons, signature cards, heal, shield, damage, resources, buffs/debuffs, exhausts, draws, mercy heals. Data `data/encounters/encounter_scripts.json`; carried through every existing rule path (game + sim) by a carrier modifier; cloned for the AI's look-ahead (it plays toward/away from thresholds). 18 tests. Two-seed sweep + three re-measure rounds. |
| 2 Two-Path foes | 9d4e2cfb | 3 new archetypes (Gourmand+Beefcake "Bulking Season", Gourmand+Refusemancer "Farm to Table", Beefcake+Refusemancer "Junkyard Gym") and 7 two-Path foes from the second zone's dungeon on, with blurbs that name the synergy. |
| 3 Boss entrances | 2395ae5b, 98a10130, 1d3544b6 | Board entrance for 29 bosses/lieutenants/gatekeepers (letterbox, portrait push-in, name card + title, sting, opening line; ~3.3 s, any key skips); Crosspath and the zones also push the camera in on the hero facing the foe first. |
| 4 Card picks | 2395ae5b, d91eb2a5 | `RewardPicks`: 1 of 3 cards themed to the foe's Paths after every elite/boss (dungeons and the world), copy caps respected, no Legendaries, no early Epics; repeat wins offer 2 mostly-Common cards; side bosses pick too. Economy audit: gold unchanged; ~45 extra cards over a run. |
| 5 Battle help | 2395ae5b, b81bea39 | Status lines in the battle tooltip (exhausted / skips refresh, Red Tape with turns left, pumps, buffs, the fight's rules, granted keywords, Tools, tokens, protection), shield on the plate, Glossary in the pause menu (6 tabs), 4 new first-time tips. |
| 6 Save slots | 2395ae5b | `CampaignSlots`: three campaigns, each with its own autosave + backup + manual saves; New Game picks a slot, Continue loads the newest, Load Game lists them (Play / Other saves / Copy / Delete, all confirmed); Report a Problem notes the slot. Smokes updated. |
| Phase 2 | 9e56be59 ... (12 cycles) | see below |

Verification after Parts 1-6: GUT 2221 passing / 0 failing / 1 pending (the known chef-hat art); story bot 90/90 (three times); tour bot
OK (281 spots, 5 battles, 0 errors, three times); playtest smoke OK; release smoke PASSED; first-battles smoke OK; boss-rules smoke OK;
dungeons smoke OK 49/49 (green for the first time since Oct 21); tutorial run 88 / 90 / 88 / 100 (unchanged).

## Scripted events - every boss and elite

Full table with the lines: `docs/design/encounter_scripts.md` (`node tools/encounter_scripts_table.js`).

| Encounter | Scripted events (when: what) |
|---|---|
| Hollow Warden (tutorial boss) | **The Warden Stirs** (50% HP): A 1/1 Cave Echo rises beside the Warden. |
| Brick Bronson (gatekeeper) | **HYDRATION BREAK** (50% HP): Brick heals 3. His units are exhausted and miss his next turn. |
| Chef Fennel Gravois (gatekeeper) | **TASTE IT!** (50% HP): You heal 2. A 1/1 Snack joins Fennel. |
| Moss Mulligan (gatekeeper) | **Did I Thorn at You?** (50% HP): The thorns loosen: you heal 3. |
| Prudence Pallor (gatekeeper) | **Stamped APPROVED** (50% HP): Prudence stamps APPROVED by mistake: you heal 3. |
| The Restless Dead | **The Count Pauses** (50% HP): The dead stand still: their units miss their next turn.<br>**The Cairn Remembers** (25% HP): The dead hesitate: their units get -1/-0. |
| Shiro Swindle | **SMOKE BOMB!!!** (50% HP): Your strongest ready unit is lost in the smoke until after your next turn.<br>**Body Double** (25% HP): Shiro's log absorbs the next 4 damage. |
| The Warden of the Four Seals | **The Seal of Iron Breaks** (50% HP): The Warden gathers the broken seal: the next 3 damage is absorbed.<br>**The Last Seal** (25% HP): The Warden's units get -1/-0. |
| The Wellspring's Echo | **Ripples** (50% HP): Two 1/1 Ripples rise from the well.<br>**Still Water** (25% HP): The Echo heals 3. |
| Colonel Casserole (zone elite) | **Honour Duel** (50% HP): Casserole's units get +1/+1. |
| Captain Spotless (Capital gate) | **HALT** (50% HP): Your strongest ready unit is exhausted. |
| Vivienne Quota, Minister of Efficiency | **Efficiency Review** (50% HP): Quota draws a card. |
| Quota, Transit Yards rematch | **Mandatory Break** (50% HP): Quota draws a card; her units take a break through her next turn. |
| Trophy Hall Honor Guard | **Empty Trophy** (50% HP): A 1/1 Reserve Guard steps off a pedestal. |
| Chancellor Clench, Iron Regent | **Brownout** (turn 5 (warned)): The lights go out: your two strongest ready units are exhausted.<br>**DROP AND GIVE ME FORMS** (50% HP): Clench gains 2 Iron.<br>**Master...?** (25% HP): Clench falters: his units get -1/-0. |
| Baron Quadzilla | **Final Set** (50% HP): The Baron's units get +1/+0.<br>**He Stands Up** (25% HP): The Baron heals 2, but his units get -1/-0. |
| The Ancient Spotter | **One More Rep** (50% HP): The Ancient Spotter heals 4.<br>**Young Spotters** (turn 6 (warned)): Two 1/1 Young Spotters arrive. |
| Unfinished War Machine | **Self-Repair** (3 of its units died): The War Machine heals 2. |
| Cannon-Blender Gunner | **Full Blend** (turn 4 (warned)): You take 2 damage. |
| The Doppelganger | **The Mask Slips** (50% HP): Perfect Copy ends. Two 1/1 Sashimi Weenies are rushed out.<br>**No Face of Its Own** (25% HP): The Doppelganger falters: its units get -1/-0. |
| The Itamae Supreme | **Omakase** (turn 4 (warned)): The Itamae serves you: you heal 2.<br>**...Enough.** (25% HP): The Itamae's units get -1/-0. |
| Colonel Cornelius Crumb, Director of Culinary Defense | **Battle Rations** (50% HP): Crumb gains 2 Ingredients.<br>**Paste Barrage** (turn 6 (warned)): You take 2 damage. |
| Notary Wraith | **In Triplicate** (50% HP): The Notary Wraith gains a Red Tape. |
| Undersecretary Vellum | **Noted.** (50% HP): Vellum gains a Contract. |
| Mortimer Grimsby, CE-No | **Mortimer Files a Form** (turn 4 (warned)): A 1/1 Filing Clerk is hired.<br>**Filed on a Tuesday** (30% HP): Mortimer hesitates over the form: his units get -1/-0. |
| Betty Bones, Surly Secretary | **Forms A Through F** (50% HP): Betty gains 2 Contracts; a 1/1 Zombie Temp files in.<br>**Out to Lunch** (turn 5 (warned)): Betty is on lunch: her units are exhausted this turn. |
| Hortensia Clipwell, Royal Groundskeeper | **Regulation Topiary** (50% HP): Two Topiaries join Clipwell. |
| Hive of Mutant Bees | **The Hive Swarms** (2 of its units died): Two 1/1 flying Mutant Bees buzz in. |
| Compostella, the Rotheart | **The Roots Spread** (50% HP): Two Sporelings sprout; her units get +0/+1.<br>**Please. The Tree.** (25% HP): The hungry green falters: her units get -1/-0. |
| His Majesty the Raccoon | **The Royal Bins** (50% HP): A 1/1 Rat joins; His Majesty gains a Garbage.<br>**Sweating Profusely** (25% HP): His Majesty's units get -1/-0. |
| Enforcer Captain Spotless | **Inspection** (turn 5 (warned)): Your strongest ready unit stands to attention.<br>**A SMUDGE** (25% HP): Spotless polishes: his units get -1/-0. |
| Mirror Knight | **Reflection** (50% HP): A Reflection steps out of the glass. |
| Royal Staircase Guard | **Hold the Stair** (50% HP): The guard absorbs the next 3 damage. |
| Percival Plume, Deputy Minister of Good News | **Positive Spin** (50% HP): Plume heals 2. |
| Clocktower Sentinel | **The Hour Strikes** (turn 4 (warned)): The hour strikes: your two strongest ready units are exhausted. |
| Primm (standardization) | **Out of Alignment** (50% HP): Primm absorbs the next 2 damage. |
| Primm (reflection) | **Every Mirror Agrees** (turn 5 (warned)): A 2/2 Polished Reflection steps out. |
| Primm (unraveling) | **I Only Wanted It to Be Nice** (25% HP): Primm's units get -1/-0. |
| The Failed Experiment | **Mutation** (50% HP): A 1/1 Discarded Sample crawls out. |
| The Drain Warden | **Drain Cycle** (turn 4 (warned)): You take 2 damage; the Drain Warden heals 2. |
| Dr. Ambrose Siphon, Chief Path-ologist | **This Will Only Drain a Little** (50% HP): You take 2 damage; Siphon heals 2.<br>**Fascinating Data** (25% HP): Siphon draws 2 cards. |
| The Old Kingdom Automaton | **Recalibrate** (50% HP): The Automaton absorbs the next 3 damage.<br>**Recognised** (25% HP): The Automaton hesitates: its units get -1/-0. |
| Arena: Cardboard Colossus | **Getting Soggy** (50% HP): The Colossus is soggy: its units get -1/-0. |
| Arena: Champion of the Four Fists | **The Fourth Fist** (50% HP): The Champion's units get +1/+0. |
| Arena: Announcer Grand Bellows | **THE CROWD GOES WILD** (turn 3 (warned)): A 1/1 Rowdy Fan climbs into the ring.<br>**INTERMISSION** (50% HP): Bellows heals 2; his units sit out his next turn. |

## The new two-Path encounters (Part 2)

| Foe | Where (level) | Paths | Synergy it shows | Two seeds |
|---|---|---|---|---|
| Executive Elevator Operator | Hall of Final Approvals, node 13 (L11) | Necrocrat + Beefcake | Iron turns the crank, Red Tape keeps the doors shut | 100 / 96 |
| Cannon-Blender Gunner (elite) | Test Kitchen, node 11 (L15) | Gourmand + Beefcake | Bulking Season: Ingredients + Iron spent together (Protein Forge, The Gain Train) | 69 / 69 |
| Hive of Mutant Bees (elite) | the Rotheart, node 10 (L18) | Gourmand + Refusemancer | Farm to Table: Garbage into Ingredients and golems | 81 / 75 |
| Rot Tunnel Horror | the Rotheart, node 11 (L17) | Beefcake + Refusemancer | Junkyard Gym: every Garbage becomes a buff or an Iron | 83 / 92 |
| Conveyor Belt Sushi Chef | Omakase, node 2 (L14) | Gourmand + Necrocrat | numbered plates: tokens and Red Tape | 92 / 83 |
| Pizza Crust Courtier | Throne of Lids, node 2 (L17) | Gourmand + Refusemancer | Farm to Table | 100 / 100 |
| Junction Patrol | the Old Service Tunnels, node 2 (L19) | Beefcake + Refusemancer | Junkyard Gym | 96 / 100 |

The first zone (the Gainlands, the House of Gains, the Iron Cave) stays single-Path. Freed zones (Phase 2 cycle 13): once a zone is
free, its roamers come back as two-Path sparring partners (+10 HP, 96-100% in 5-7 turns on two seeds; a gold toast "... wants a
rematch: two Paths this time!").

## Balance before / after

Full table: `docs/design/balance_log.md`, "Overnight Oct 23, Part 1" and "Phase 2 cycle 1/8". Highlights (before = Oct 23 AI pass,
after = seed 7000 / seed 8100, 16 games per cell):

| Fight | Before | After | |
|---|---:|---:|---|
| Gatekeepers Brick / Fennel / Moss / Prudence | 73 / 62 / 63 / 65 | 63 / 66 / 69 / 63 | mercy moments |
| The Restless Dead (first boss) | 38-44 | 50 | eased |
| Chancellor Clench | 56 | 56 / 69 | Brownout, 2 Iron, Master...? |
| Mortimer | 47 | 69 / 38 | Temp Agency +1/+0 (cycle 1) |
| The Doppelganger | 38 | 44 / 38 | the mask slips |
| Compostella | 66 / 44 | 63 / 31 | |
| Primm, three phases as one HP pool | 48 | 40 | Gourmand 17 |
| The Itamae | 44 | 44 / 31 | the matchups, not the scripts (inbox 3) |
| Colonel Casserole | 78-88 | 69 / 75 | was too easy |
| Champion of the Four Fists | 88 | 81 / 81 | |

## Phase 2 - cycles

| # | Category | What | Commit |
|---|---|---|---|
| 1 | Balance | Mortimer Temp Agency +1/+1 -> +1/+0 (44/25 -> 69/38); Itamae 3 Ingredients measured, reverted | 9e56be59 |
| 2 | UI consistency | the pre-fight brief puts scripted events under their own amber heading | bf1b7024 |
| 3 | Collection / bestiary | a met boss's Bestiary page lists its "Signature moves" | c65ba68a |
| 4 | Performance | AI think time with scripts measured: unchanged (max 0.48 s); tour + story bots | (log) |
| 5 | Combat feel | Crosspath camera push before gatekeeper/town boss fights | 98a10130 |
| 6 | Rewards feel | the pick box shows its cards larger | d91eb2a5 |
| 7 | Onboarding | status tooltip wording matches the cards (-2/-0, N turns left) | b81bea39 |
| 8 | Balance | the Itamae at Elite skill: no change, reverted (matchup note) | (log) |
| 9 | Combat feel | zone camera push before elites/lieutenants; Colonel Casserole's entrance | 1d3544b6 |
| 10 | Stability | dungeons smoke green (49/49): the smoke now finishes the freed Gainlands' scene before the Swolympus gate | 2584d479 |
| 11 | Dialogue | entrance lines no longer repeat their boss's scripted lines | ec5faf38 |
| 12 | Balance | the Automaton's shield/falter timing: no change, reverted | (log) |

## How to test

- **Scripted events**: fight Brick Bronson at the gorge bridge (Crosspath): the amber icon under his portrait reads "HYDRATION BREAK";
  at half health a banner shows it with his line. Clench (House of Gains, last node): on his 4th turn the warning "Next turn: Clench cuts
  the power..." appears; on his 5th your two strongest ready units are exhausted. Hover an amber icon: "Scripted event"; after it fires
  the icon dims and its tooltip says the turn. Battle log (bottom left) has an amber line for each.
- Screenshots: `docs/overnight/oct23/p1_banner_brick.png`, `p3_intro_doppel.png`, `c2_brief_bellows.png`, `c6_pick.png`,
  `c7_status.png`, `p5_glossary_rules.png`, `p6_campaigns.png`. Re-shoot: `bash tools/shot.sh res://scenes/battle.tscn x --as="The
  Doppelganger" --intro=hold --wait=2.5` (entrance), `--script_key=town:npc:beefcake --as="Brick Bronson" --no_intro=true` (banner),
  `res://scenes/town.tscn x --open=pick` (card pick), `res://scenes/title.tscn x --open=campaigns` / `--open=glossary4`.
- **Entrances**: any boss, lieutenant, gatekeeper or Colonel Casserole; any key skips.
- **Card pick**: beat a gatekeeper (VICTORY box in Crosspath) or a dungeon elite (the rewards screen); beat it again for the 2-card pick.
- **Battle help**: hover a unit with Red Tape on it, an exhausted one, a token; Esc -> Glossary.
- **Save slots**: title -> Load Game (your save is Slot 1) -> Copy to 2 -> Delete 2; New Game -> Slot 3.
- **Sims**: `SWEEP_KINDS=elite,boss bash tools/ai_sweep.sh <tag> 4 7000 [groups]`; `--what=sequence --filter=boss:primm`; the replay tool
  logs scripted events as `!! tN SCRIPT <name>`.
- **Tests**: `tests/core/dungeon/test_encounter_scripts.gd`, `test_reward_picks.gd`, `tests/core/data/test_campaign_slots.gd`,
  `test_world_reward_pick.gd`, `tests/ui/test_oct23_battle_help.gd`.

## Inbox (yours to decide; the safest choice was taken)

1. Entrances: board intro everywhere + a camera push in Crosspath and the zones; no push inside dungeons (they have no 3D foe).
2. Mercy moments for the gatekeepers and several bosses' last stand - say if any should be a threat instead.
3. The Itamae: 44 / 31 whatever his numbers (Refusemancer and Necrocrat lose every seed-8100 game, Gourmand wins every one).
4. Primm's gauntlet clears 40% (Gourmand 17).
5. Card picks: rules above; side-dungeon bosses now also offer a pick.
6. Save slots: slot 1 = the old folder; slots 2-3 new folders.
7. **Your real Slot 1 manual save was overwritten by a test** (tonight 22:43 and on earlier GUT runs); fixed.
8. Four new first-time tips will show once even for players who finished the old ones.
