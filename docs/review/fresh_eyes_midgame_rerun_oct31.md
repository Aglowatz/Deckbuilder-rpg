# Fresh eyes: mid and late game rerun (Oct 31)

Critic run on the `midgame_real` snapshot (Beefcake, level 13, 46-card deck, Gainlands + D.N.A. freed). Screenshots cited below are in `docs/review/fresh_eyes_midgame_rerun_oct31/`, named `<run>_<shot>.png`.

## Summary

The Wayward Path looks like a much more expensive game than it plays. The dungeon node maps (Test Kitchen, Rotheart, Primm's Castle), the card art, the pack-opening table and Crosspath's square are lovely. Octopath-style dioramas with Inscryption-style table battles is a strong combination. The mid and late game is let down by four things:

1. **The game forgets you are mid-game.** "Your first duel", "Play an Infrastructure... the most important card of the day", "Energy" and "You made a Resource!" tips all fire again at level 13, and one of them blocks the turn.
2. **Your HP is tiny and changes from screen to screen.** Starting HP is 16 on the Character screen, 11/11 in the Capital, 17 in a lieutenant fight and 15 against Primm. Every zone also says "no healing after battles".
3. **The bosses flatten the deck.** Each of the three bosses I fought ended with the boss untouched (16/16, 22/22, 44/44) inside 5 to 8 turns. The built-in pilot played those fights, so this partly measures the pilot. But a 10-turn grind against the *first* Test Kitchen node also left me at 4/16 HP in a zone that does not heal. I don't think a normal player gets through a 13-node dungeon at that rate.
4. **Twists are spoiled in the UI.** Boss panels and speaker plates give away reveals before the scene plays them: "The Doppelganger (posing as Grand Chef Escoffina)", "(later named Escoffina)", and "Old Hob the Gravedigger (secretly Death)".

There are also several smaller clarity and consistency problems: the quest tracker says "Go to Crosspath" inside every zone, the town map does not name buildings, the opening tips overlap popups, and the Capital hideout is a bare greybox room.

Overall: about **5.5/10** for the mid and late game against the comparison set. The fixes are mostly content-state and UI fixes, not rewrites.

## How I played

- About 40 minutes of wall clock (22:21 to 23:00), 15 runs, one game process at a time. Scripts are `docs/review/play_scripts/critic4_*.txt`.
- Runs:
  - `c4_town`, `c4_town2`, `c4_town3`, `c4_shop`: packs, Deck Station, Character, Quest log, map, Glossary, Feats, town walk, vendor attempts.
  - `c4_buffet`, `c4_buffet2`: the Endless Buffet on foot.
  - `c4_ttk` to `c4_ttk4`: Test Kitchen map and rules, node 1. I played the opening turns by hand, then `pilot` finished the fight.
  - `c4_ttkboss` to `c4_ttkboss3`: the Doppelganger boss intro and fight (pilot, lost).
  - `c4_dump`, `c4_rot`: Verdant Dump arrival, Rotheart map, Compostella intro and fight (pilot, lost, then `dev win` used too late; see below).
  - `c4_cap`, `c4_primm`, `c4_primm2`:
    - the Capital (The Crease) and the Primm's Castle map;
    - the lieutenant Vivienne Quota (pilot, then **`dev win`**);
    - the Primm intro and Phase 1 (pilot, lost);
    - a short look at the freed D.N.A.
  - `c4_town3` also opened the side dungeon Omakase (S-GOUR): map and rules only.
- **Skipped or only partly done**:
  - the shops: E near Sable and Tilly only played a bark and no shop opened (see bugs);
  - the tailor, and the Collection Book / Hall of Records (I could not find it: the town map names no buildings);
  - fighting through a side dungeon;
  - most of the D.N.A. revisit (only the arrival herald);
  - Primm's later phases.
- `dev autowin` was not used. `dev win` was used once on the lieutenant fight. On the Rotheart it came too late (the pilot had already lost).
- No `SCRIPT ERROR` in any `stdout.log`.

## Scores

| Area | Score /10 | One line |
|---|---|---|
| Clarity | 4 | Rule panels and the defeat recap are good, but tutorial tips repeat at level 13, HP changes between screens, and the tracker says "Go to Crosspath" everywhere |
| Pacing and friction | 5 | Zone loads take 6 to 13 s, and the boss intros need 20 to 50 presses. The Rift popup blocks the map on arrival. Fights run 6 to 10 turns at 1x |
| Combat depth and feel | 5 | Interesting rules (Primm's "every unit is a 3/3, two cards a turn"; zone buffs), but a 16-HP pool against boards of 6/10 units makes fights feel decided early |
| Deck-building satisfaction | 6 | Deck Station filters, copy counts and rack slots are strong, but card text in the grid is microscopic and a tip covers the filters |
| Reward rhythm | 5 | Packs feel good (an Epic hit, NEW tags). Bosses show only "100 gold and XP, a choice of card". Losing costs 20 gold. Feats are not back-filled for freed zones |
| Exploration and world | 6 | The Buffet and the Dump read as distinct places. The Crease is a greybox. Maps start almost fully fogged and don't name places |
| Story and humour | 6 | Good jokes (soup ladle, Rip Tearson cousins, Percival Plume). Twists are spoiled by the UI, and the boss cutscenes use flat placeholder icons |
| Visual cohesion and readability | 7 | Painted node maps and the battle table are gorgeous. Some placeholder white pillar meshes in the Buffet. Enemy nameplates clip into the HP heart |
| UI/UX consistency | 4 | E vs Space vs Click differs by dialogue type. Overlapping popups. Vendors don't open on E. "Item slots 2/4" vs "Equipped 0/2" |
| Audio | n/a | I can't judge from screenshots and logs |
| Performance | 6 | No stutter visible in the logs. Zone loads 6 to 13 s (the Dump took 13 s). Dungeon travel about 4 s. Snapshot load 7 to 11 s |
| Bugs | 5 | No script errors, but there are state bugs: repeated first-time tips, inconsistent HP, feats not awarded for freed zones, a stale "Needs 4 energy" warning |

## Findings per area

### Crosspath with a mid-game collection
- `c4_town_01_town.png`: the square is beautiful and the vendor nameplates appear as you walk (`c4_town3_02_nw.png`). That is Octopath-level dressing.
- `c4_town_09_map.png`: at level 13, after two freed zones, the town map is about 85 % black fog with four islands of reveal. It names no buildings, so I could not find the Hall of Records. A hub map should always be fully revealed and labelled.
- `c4_town_08_quests.png`: "Free the Four Zones 2/5". Five steps for four zones reads like an error. Fragments is "2/4" in the log but shows "4 of 4" in the HUD tracker pager, which is a different counter on the same panel.
- Packs (`c4_town2_03_gilded_summary.png`): the tear-and-reveal ritual is satisfying, the "EPIC!" flourish lands, and "No extra copies" is clear. Two problems:
  - The packs list re-flows after a pack type runs out, so my second click hit nothing. A small thing.
  - The pack tip sits on screen the whole time, behind the reveal.
- Deck Station (`c4_town2_05_deck.png`):
  - Good: colour, type and cost filters, "Deck 1/3 Own 3" counts, a right-hand list with +/- buttons, Fill Infrastructure, and level-locked rack slots (a nice goal).
  - Bad: the "Building a deck" tip covers the filter row and the first card row on entry. Card rules text in the grid is about 7 px and unreadable without hover. Powerhouse shows an empty count bar.
- Character (`c4_town2_07_char.png`):
  - "Item slots 2/4" in the Level panel contradicts "Equipped 0/2" in the Items panel.
  - The save has 12 Healing Salves and nothing equipped, and nothing nudges you to equip them.
  - Path essence shows 0/0/0/0 with no explanation of what essence is for.
  - The gear slots show icons but no names or stats.
- Vendors (`c4_shop_01_sable.png`, `c4_shop_02_sable.png`, `c4_shop_04_tilly.png`): standing on Sable and Tilly and pressing E played a funny bark ("Two typos, darling...") but **no shop opened** on a second or third E. I could not reach any shop in two attempts. Either the interaction needs facing and isn't saying so, or the bark eats the input.
- Glossary (`c4_town3_07_glossary.png`): clean and complete, with tabs for keywords, resources and rule icons. It's good.
- Feats (`c4_town3_08_feats.png`): "Hold My Coat - Free the Gainlands" and "The Spotter Is Spotted - Free your first gatekeeper" are **not** marked earned, although this save has freed the Gainlands and the D.N.A. The header says "this campaign: 7", which also disagrees with the 2 shown as earned.

### The Endless Buffet
- Arrival (`c4_buffet_01_arrive.png`): a tablecloth bridge with broccoli trees is a fun, readable identity. The zone effects show as two small icons under the tracker.
- Two seconds later the Rift Station popup (`c4_buffet_05_walk.png`) appears mid-walk and **blocks M (map)**: `c4_buffet_08_map.png` is the same popup. The popup is fine; blocking input on arrival is not.
- Tracker: "Win the pantry key from Chef Fennel Gravois / Go to Crosspath" while I am standing in the Buffet. The map goal marker (`c4_buffet2_02_map.png`) points back at the entrance bridge. I could not tell where the main dungeon was.
- `c4_buffet2_07_north.png`, `c4_buffet2_10_nw.png`:
  - Good: Madame Mirepoix's card stall, Old Hob, a soup cauldron with a funny "already stuffed" line, a cheese mountain, and the "Mashed Potato Meadow" title card.
  - Bad: several **untextured white pillar/figure meshes** (the white cones by the bridge, the "salt shakers") look like stand-ins next to the painted props.
- Test Kitchen map (`c4_ttk_02_map.png`): the best screen in the game, readable and enticing. The rules (`c4_ttk_03_rules.png`) are short and clear, and they are repeated on a pre-fight card. That is excellent and better than most Spire clones.
- Node 1 by hand (`c4_ttk2_02_battle.png`, `c4_ttk3_*`):
  - **"Your first duel"** tip at level 13. It sits on top of the Opening Hand popup, so two dialogs overlap with two sets of buttons.
  - Then "Play an Infrastructure - the most important card of the day", "Energy" and "You made a Resource!" all fire again (`c4_ttk3_02_played_infra.png`, `c4_ttk3_05_space.png`).
  - Dragging a 4-cost unit with 1 energy gives a clear "Needs 4 energy; you have 1" message. That's good, but the message stays on screen into turn 3 (`c4_ttk3_08_my_t2.png`).
  - The enemy nameplate "Prep Station Sous-Chef" overprints its own HP heart.
  - A played Infrastructure becomes a tiny card stub by the hand; the board itself stays empty and lifeless.
- Node 1 result (`c4_ttk4_02_after.png`): victory in 10 turns at **4/16 HP**, in a zone with "no healing after battles". That is one node of 13.
- Boss (`c4_ttkboss_01_click.png`):
  - The boss panel reads "Boss: The Doppelganger (posing as Grand Chef Escoffina)". The speaker plate reads "THE DOPPELGANGER (LATER ...". The twist is printed before she speaks.
  - The cut-in portrait is gorgeous. The cutscene that follows (`c4_ttkboss_06_battle.png`) is a chef-hat icon and a wizard-hat icon on a gradient, which looks like placeholder art next to that portrait.
  - The intro took about 22 presses. It also changes from "E / Click" to "Click / Space", and my skip tool didn't see the second kind at all.
- Boss fight (`c4_ttkboss3_03_mid.png`): Mise en Place starts the boss with a board. I (pilot) lost in 6 turns and the boss stayed at 16/16. The defeat recap (`c4_ttkboss3_06_after.png`) is excellent: "Sashimi Weenie dealt 12 of the 18 damage... Block it with a unit you can afford to lose". Slay the Spire doesn't give you that much.

### A freed zone (the D.N.A.)
- `c4_primm2_05_dna.png`: Percival Plume's "Great news, citizens! The D.N.A. has been freed, a change His Perfection fully supports and in fact arranged!" is the best joke I saw.
- Otherwise the zone still shows "Zone HP: no healing after battles" and the same dark marble corridor. I saw nothing that makes revisiting worthwhile (no new vendor or quest marker in view). This was a short look, so the judgement is partial.

### The Verdant Dump and the Rotheart
- `c4_dump_03_walk.png`: the warm autumn and violet palette is distinct from the Buffet. The Rift popup interrupts the walk again. The tracker again says "Go to Crosspath".
- The Dump took **13 s** to load (19.5 to 32.9 s in the log).
- Rotheart map (`c4_dump_05_dmap.png`): beautiful, but it is **the same 13-node lattice** as the Test Kitchen: entrance far left, a diamond mesh, the boss top right, "-2" = node 12. After two dungeons the shape is predictable.
- Boss (`c4_rot_01_intro.png`): "Compostella, the Rotheart (the corrupted Refusemancer leader)", with a nice line: "Please. The tree. I could not let her go."
- Fight (`c4_rot_04_mid.png`): the boss had Mulch Mole 6/10 (x4 stack) and Rubbish Goat 6/9 against my 16 HP. Lost on turn 8 with the boss at 22/22.
- `dev win` sent after the defeat did nothing (the fight was over). That is a tooling note, not a game bug.
- After the defeat (`c4_rot_06_after.png`):
  - The zone title banner draws over Old Hob's dialogue.
  - The dump labels him "Old Hob the Gravedigger (secretly Death)". On screen the plate truncates to "OLD HOB THE GRAVEDIGGER ...", so this may only leak through the tooltip text or the dump, but the data is there.
  - A "-20 gold mucking-out fee" makes defeat almost free. That's fine for retention but strips tension.

### The Capital and Primm's Castle
- The Crease (`c4_cap_03_walk.png`): a flat brick box with two cots, a table, a pot and the portal. It reads as greybox next to everything else.
- **HP 11/11 here** with no explanation, against Starting HP 16 on the Character screen.
- The map (`c4_cap_04_map.png`) is again mostly fog.
- Lieutenant Vivienne Quota (`c4_primm_06_quota.png`, `c4_primm_08_quota_mid.png`):
  - "Your first duel" again.
  - The pilot was frozen by "Spend your Resource first: the guide is waiting for it". That is a tutorial gate at level 13.
  - The Minister of Efficiency plays a Beefcake deck (Personal Trainer, Weight Belt, Powerhouse). That's thematically odd.
  - My HP was 17 here.
  - `dev win` led to a legendary card reveal, "The Big Unit 12/12" (`c4_primm_10_reward.png`), and a chest tip. That's a nice reward moment.
- Primm's Castle map (`c4_cap_05_pc_map.png`): stunning, with wings named after each zone's villain ("Gourmand Wing: the Doppelganger's Lab Notes"). The labels truncate ("Doppelganger's La...").
- Primm intro: about **50 presses (about 36 s)**, including a "Freed Leaders" interlude with Grandmaster Flex. A "Feat: A Name" toast popped over it. This is too long for something you replay after every loss.
- Primm Phase 1 (`c4_primm2_02_battle.png`):
  - The rule is great: "Every unit, yours and his, is a 3/3. You may play at most two non-infrastructure cards a turn. (Two is the perfect number.)"
  - Broken services (4 of 4) is listed with a Heap of Rubbish token in my opening hand.
  - The hand still shows my 6/3 units as 6/3 under a "every unit is a 3/3" rule. The hand doesn't preview the rule.
  - Eight rule icons plus two panels crowd the left side.
  - Primm has **44 HP against my 15**. I (pilot) lost on turn 5 with Primm at 44/44 (`c4_primm2_03_mid.png`).

### Side dungeon (Omakase, S-GOUR)
- `c4_town3_09_sgour.png`: three nodes (Counter Seat, Conveyor Gauntlet, Chef's Choice) and a "Fresh Fish: tokens +1/+1" rule. A short side dungeon is a good counterweight to the 13-node mains. I didn't fight it.

### Performance
- Snapshot load 7 to 11 s. Zone travel: Buffet 6 to 7 s, D.N.A. 6 s, Capital 10 s, Dump 13 s. Dungeon travel about 3 to 4 s. Battles start about 4 s after the node.
- No visible hitching in the pilot timestamps.

## Top 15 problems (ranked by impact on mid- and late-game enjoyment and retention)

1. **First-time tutorial tips fire again at level 13 and can block the turn.**
   - Where: `c4_ttk2_02_battle.png`, `c4_ttk3_02_played_infra.png`, `c4_ttk3_05_space.png`, `c4_primm_06_quota.png`, `c4_primm_08_quota_mid.png`.
   - Why it matters: it tells a veteran player the game doesn't know them. "The guide is waiting for it" gates their turn. The tips also overlap the Opening Hand dialog.
   - Fix: store tip state in the campaign save and back-fill it. Any save past the tutorial cave or at level 5+ should mark all basic tips as seen. Never stack a tip over a modal; queue it.
2. **Player HP is tiny and inconsistent.**
   - Where: 16 on the Character screen (`c4_town2_07_char.png`), 11 in the Capital (`c4_cap_03_walk.png`), 17 against Quota, 15 against Primm (`c4_primm2_02_battle.png`).
   - Why it matters: you cannot plan around a number that changes without explanation, and "Zone HP: no healing" makes every point matter.
   - Fix: show one HP number with its sources (base + gear + zone modifier) in a tooltip on the HP bar and on the pre-fight card. If the Capital lowers HP, say so on arrival.
3. **Bosses outclass a level-13 built deck by a wide margin.**
   - Where: the Doppelganger 16/16 untouched (`c4_ttkboss3_03_mid.png`), Compostella 22/22 (`c4_rot_04_mid.png`), Primm 44/44 against my 15 HP (`c4_primm2_03_mid.png`).
   - Caveat: the pilot played these fights.
   - Why it matters: even allowing for a weak pilot, 0 damage dealt in three boss fights suggests a wall, and walls end runs and sessions.
   - Fix: run the boss sweeps with the midgame deck. Target a 45-60 % first-try win for a competent player. Consider a scaled HP pool (16 at level 13 is lower than the 20+ enemy totals), or boss HP tied to zones freed.
4. **No healing in zones plus long fights means attrition across 13 nodes.**
   - Where: node 1 of the Test Kitchen won at 4/16 after 10 turns (`c4_ttk4_02_after.png`).
   - Why it matters: the player is effectively dead before the boss unless they leave. That pushes Retreat-and-walk loops, which is friction rather than tension.
   - Fix: add a rest or heal node or two per 13-node dungeon (Spire's campfires). Or heal a fraction after each win. Or make Healing Salves auto-suggest equipping.
5. **The UI spoils story twists.**
   - Where: `c4_ttkboss_01_click.png` ("The Doppelganger (posing as Grand Chef Escoffina)", "(later named Escoffina)"), and the "(secretly Death)" speaker name in `c4_rot_06_after.png`.
   - Why it matters: the reveals are the best writing in the game, and the node card gives them away before the scene.
   - Fix: separate display names from internal or reveal names. Show "Grand Chef Escoffina" and "Old Hob the Gravedigger" until the reveal flag fires.
6. **The quest tracker says "Go to Crosspath" inside every zone, and map goal markers point back at the entrance.**
   - Where: `c4_buffet_01_arrive.png`, `c4_buffet2_02_map.png`, `c4_dump_03_walk.png`, `c4_cap_03_walk.png`.
   - Why it matters: the player cannot find the main dungeon or the next step.
   - Fix: when the player is in the target zone, show the in-zone step ("Find Chef Fennel Gravois in the Grand Pantry") and put the dungeon entrance on the map from arrival.
7. **Vendors don't open on E.**
   - Where: `c4_shop_01_sable.png`, `c4_shop_04_tilly.png`. A bark plays instead.
   - Why it matters: shops are the mid-game gold sink. If the player can't reach them, gold (600) piles up and means nothing.
   - Fix: make E on a vendor always open the shop (bark as a toast), and show an "[E] Shop" prompt.
8. **Boss intros are long and the cutscene visuals are placeholders.**
   - Where: 22 presses for the Doppelganger, about 50 for Primm. Flat hat icons in `c4_ttkboss_06_battle.png`.
   - Why it matters: you replay these after every loss. The flat icons undercut the painted portraits.
   - Fix: a "Skip intro" button after the first viewing, and the painted portraits in the cutscene. Unify the advance keys to E / Space / Click everywhere.
9. **The town and zone maps are mostly fog and name nothing.**
   - Where: `c4_town_09_map.png`, `c4_cap_04_map.png`.
   - Why it matters: the brief and the player both expect to find the Hall of Records by the map. I couldn't.
   - Fix: reveal hubs fully, label buildings and vendors, and add map pins for every service.
10. **Arrival popups block input.**
    - Where: the Rift Station dialog on arriving in the Buffet, the Dump and the Capital blocks M and movement (`c4_buffet_08_map.png`). The zone banner draws over dialogue (`c4_rot_06_after.png`).
    - Fix: show the unlock as a non-modal toast, and never draw the zone title over a dialogue box.
11. **Every main dungeon uses the same 13-node lattice.**
    - Where: `c4_ttk_02_map.png` and `c4_dump_05_dmap.png` (and Primm's Castle is similar).
    - Why it matters: dungeon three feels like dungeon one with new paint, and it's long.
    - Fix: vary the topology and length (9 to 15 nodes, forks that rejoin, optional dead-end treasure). Show the node types (fight, elite, event, rest) before you commit.
12. **Feats are not awarded retroactively, and the feat counters disagree.**
    - Where: `c4_town3_08_feats.png` ("Free the Gainlands" not earned on a save that freed it; "2 of 40" next to "this campaign: 7").
    - Fix: re-evaluate feats on load from the campaign flags, and show one count.
13. **Overlapping and stale battle messages, and a clipping nameplate.**
    - Where: the "Needs 4 energy" warning stays across turns (`c4_ttk3_08_my_t2.png`). The tip panel sits over Opening Hand (`c4_ttk2_02_battle.png`). The enemy name runs into the HP heart (`c4_ttk2_02_battle.png`, `c4_primm2_02_battle.png`).
    - Fix: clear warnings at the phase change. Size nameplates to the name, or wrap the name above the heart.
14. **The Deck Station is hard to read.**
    - Where: the entry tip covers the filters, and the grid card text is about 7 px (`c4_town2_05_deck.png`). The Character screen contradicts itself on item slots and doesn't nudge you to equip (`c4_town2_07_char.png`).
    - Fix: open the tip as a dismissable side panel, enlarge the grid cards or add a list view with readable rules text, merge the "Item slots 2/4" and "Equipped 0/2" wording, and badge un-equipped consumables.
15. **Greybox and stand-in art in late-game places.**
    - Where: The Crease brick box (`c4_cap_03_walk.png`), the white pillar/figure meshes in the Buffet (`c4_buffet_01_arrive.png`, `c4_buffet2_10_nw.png`). The freed D.N.A. offers nothing new beyond a herald (`c4_primm2_05_dna.png`).
    - Fix: dress the Crease as a cosy resistance den, replace the white stand-ins, and give freed zones a visible "after" state (a lit-up palette, new vendor stock, a freed-zone quest) so revisiting pays.
