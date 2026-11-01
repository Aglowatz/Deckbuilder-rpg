# Fresh eyes: the mid game of The Wayward Path (v0.4.9), Oct 31 night

Independent critic pass from the `midgame_real` snapshot (Beefcake Path, level 13, two zones freed). Screenshots cited by file name are in
`fresh_eyes_midgame_oct31n/` (prefix = run name).

## Summary

The mid game looks expensive and plays cheap. The painted dungeon maps (Test Kitchen, Rotheart, Omakase) are as good as anything in the
genre, the card art is lavish, the pack-opening ceremony is a real treat, and the post-defeat "What beat you" panel is better than what
most deckbuilders ship. But the moment-to-moment mid game is held back by three things. First, **survival maths**: a level-13 hero still
has **16 HP** and no healing after battles in every zone, freed or not. Ordinary dungeon fights run 9-21 turns and leave you at 7/16, and
both bosses I fought killed my deck in 5-6 turns without losing a single HP. Second, **friction everywhere**: boss intro scenes that ignore
input, Escape doing three different things, NPCs and vendors you can't reliably reach, and pop-ups that freeze you in place. Third, **a
reward rhythm that is too thin** for the time a node takes: about 35 gold and 30 XP for a 2-minute fight, with 465 XP needed per level. The
zones look clearly different, but the freed D.N.A. plays exactly like an unfreed zone. As a player I would admire this game and quit it
somewhere in the Test Kitchen.

Caveat, stated honestly: most fights were played by the built-in pilot, which is a weak player (it held two 6-drops and a 12/12 in hand
through turn 5). I played the opening turns of one fight myself. The losses still say something real, because a boss that takes 16 HP in 5
turns punishes any slow hand, and the game's own defeat tips blame "cards left in hand".

## How I played

- About 50 minutes of wall clock, 28 runs (r1-r28), all starting from `dev load midgame_real`. No real save was touched.
- **Crosspath** (r1-r6, r26-r28): HUD, packs (opened 3 packs through the full ceremony), Deck Station (filters, Suggest a deck),
  Character, Quest log, Map + "Where to?", Menu, Glossary. Walked the square west, east, north and south. Vendors: I found Bertram
  (Gear), Foil Fenwick (Packs) and Pip Threadwell (Clothes), but **never got a shop screen open** (see Bugs). The Collection Book / Hall
  of Records were not found on the revealed map or in "Where to?", so I skipped them.
- **Endless Buffet** (r6, r22): arrival, Rift Station cousin, the meadow, the sign, Madame Mirepoix's bark. Got stuck against the cheese
  wedge.
- **Test Kitchen** (r7-r15, r21, r23-r25): map, rules, Prep Station (pilot, **defeat** turn 9), Walk-In Cooler (my own opening turns,
  then pilot; **won** in 21 turns at 7/16 HP), the Taste Test Lab event, and the boss Doppelganger (pilot, **defeat** on turn 5 with the
  boss at full 16 HP). To see the boss reward I then used `dev autowin on` and `dev travel ... -2`.
- **D.N.A. (freed)** (r16): arrival scene, lobby, map.
- **Verdant Dump** (r16) and **The Rotheart** (r17-r19): zone walk, Rift cousin, map, rules, boss Compostella (pilot, **defeat** on turn
  6, boss at full 22 HP). I jumped to the boss with `-2`, so I skipped the middle nodes.
- **Side dungeon**: Omakase (S-GOUR), map and rules only (r20). No fight there.
- Skipped: the Hall of Records, the tailor, every shop screen, the Capital (out of scope).

## Scores (1-10, against Slay the Spire, Inscryption, Monster Train, Sea of Stars, Octopath, Pokemon TCG Pocket)

| Area | Score | One line |
|---|---|---|
| Clarity | 5 | Excellent rule panels and defeat recap; undermined by missing resource icons, "spells" meaning units, and a random "test" event that never says what it tests |
| Pacing and friction | 3 | 2-minute fights × 7+ nodes per dungeon, no healing, input-eating cutscenes, pop-ups that freeze walking, vendors hard to reach |
| Combat depth and feel | 5 | Phases, traps, tools, infrastructure and zone rules give real texture; one-infrastructure-per-turn plus a 16 HP life total makes slow hands lethal |
| Bosses | 4 | Great intro text and clear scripted phases on paper, but both bosses steamrolled me before any phase could trigger |
| Deck-building satisfaction | 6 | Rich filters, curve chart, rules checklist, Suggest/Fill buttons; cramped layout, a tip that covers the grid, empty filter results with no message |
| Packs and shops | 5 | Pack ritual is lovely (7/10) but 4 clicks per pack with 15 packs and no "open all"; shops not reachable in my session |
| Reward rhythm | 4 | 35 gold / 30 XP per fight against 465 XP per level; boss pick offers 2 off-colour cards out of 3; a 20-gold "mucking-out fee" on top of a loss |
| Exploration and world | 6 | Three zones look clearly different (food diorama, office crypt, violet dump); maps start black, "Where to?" lists little; the freed D.N.A. feels the same as before |
| Story and humour | 7 | The best part: "Assistant TO the Regional Merchant", "The plaque is getting heavy", Compostella's "Please. The tree." |
| Visual cohesion and readability | 6 | Dungeon maps 9/10, boards gorgeous; overworld has heavy depth-of-field haze, labels pile onto barks, hand cards cut off at the bottom edge |
| UI/UX consistency | 4 | Escape skips / closes / pauses depending on screen; E vs Space vs Click prompts differ; dialogue box drawn over the boss panel |
| Audio | n/a | Can't be judged from screenshots and logs |
| Performance | 7 | Zone loads 6-13 s, dungeon loads about 4 s, no visible stutter in my logs |
| Bugs | 4 | Boss intro soft-lock (escape only via Esc > Skip), raw "(B)" token in a tooltip, missing icons in card text, player stuck on scenery, "well" text in a kitchen |
| **Overall** | **4.8** | Beautiful, funny, and currently too punishing and too fiddly to keep a mid-game player |

## Findings per area

### Crosspath with a mid-game collection
- **Town and HUD** (`r1_01_town.png`): a warm, readable tilt-shift square. The quest tracker is good, but it shows "A third memory: free a
  zone, then see Elder Maren" while the Quest log says "Where to go: Elder Maren's home" (`r1_05_quests.png`). Is the memory ready or
  not? "Free the Four Zones 2/5" (five steps for four zones) adds to the confusion.
- **Map** (`r1_06_map.png`, `r4_08_map.png`, `r4_01_whereto.png`): fog-of-war on a hub town I have supposedly lived in for 13 levels is a
  chore. Vendors show only by personal name ("Foil Fenwick"), not by what they sell. "Where to?" lists challengers and exits, but no
  vendors, no Hall of Records and no Buffet road.
- **Packs** (`r1_02_packs.png`, `r3_01_reveal.png`, `r3_02_after.png`): the tear, flip and summary ritual is satisfying, and the summary
  screen is clear. But it takes 4-5 clicks per pack with about 15 packs waiting and no "Open all". The NEW! badge covers the card name
  ("...ING GROUNDS", "...RORED HALL"). A *Gilded Necrocrat* pack gave 2 Colorless and 1 Necrocrat card, which feels mislabelled. E does
  not tear the pack, although E is "interact" everywhere else (`r2_02_after.png`).
- **Deck Station** (`r1_03_deck.png`, `r26_01_new_filter.png`, `r26_04_suggest.png`): the feature set is strong (colour, type, cost and
  rarity filters, a "New" filter, a curve chart, a legality checklist, deck racks, Suggest and Fill Infrastructure). The layout is
  cramped: only two rows of cards are visible because the bottom deck racks take the third row, and the first-time tip covers the deck
  panel. The "New" filter with no matches shows a blank board with no message. Suggest a deck offers a single button (Beefcake), so it is
  not much of a choice. Escape with the Suggest modal open closes the whole Deck Station (`r26`, 05) instead of just the modal.
- **Character** (`r1_04_char.png`): clear. But "Item slots 2/4" sits next to "Equipped 0/2". **Starting HP 16 at level 13** is the most
  important number in the mid game, and it is shown in small grey text.
- **Shops**: I walked up to Bertram (Gear) and got an "[E] Talk" prompt once (`r4_03_west2.png`), but on three later tries the same walk
  ended out of range, because townsfolk wander into the way (`r5_02_gearshop.png`, r28). Clicking Foil Fenwick from a few metres away did
  nothing (r6). For a hub you visit every session, the interaction radius is too small, and "click to interact" should path you to the
  NPC.

### The Endless Buffet and the Test Kitchen
- **Zone** (`r6_03_buffet_arrive.png`, `r6_09_walk3.png`, `r22_08_east.png`): a charming food-diorama look (broccoli trees, a cheese
  mesa, a gingham bridge). The tracker says "Go to Crosspath" inside the zone, because the gatekeeper lives there. That is correct, but it
  sounds like the game wants you to leave. The zone rule banner "Zone HP: no healing after battles" sits at the top centre for the whole
  visit. Madame Mirepoix's bark bubble sits on top of her own name plate. The "[E] Read the sign" prompt covers the player sprite. I got
  stuck against the cheese wedge: W and D for 7 s produced no movement (`r22_04`/`r22_08` identical). The Rift Station cousin pop-up
  appeared on its own and froze movement for about 8 s (`r6`, 07-08).
- **Buffet map "Where to?"** (`r6_06_buffet_whereto.png`): an all-black map and an empty list. A new zone should at least list its town
  and its dungeon.
- **Test Kitchen map** (`r7_02_ttk_map.png`): gorgeous, readable, and branching. 13 nodes with 7+ fights to the boss.
- **Pre-fight rules** (`r9_02_battle.png` and the Before-the-fight panel): an exemplary panel. Every rule is listed, red/green colour
  shows who it helps, and the icons stay on screen during the fight.
- **Combat feel** (`r10_03_hover.png`, `r10_06_after_end.png`, `r9_04_mid.png`, `r11_01_result.png`): the tutorial overlay with an arrow
  is clear. The inline tooltip on Powerhouse shows a **raw "(B)" token** ("Exhaust: add (B).") and card text throughout has blank gaps
  where resource icons should be ("create an  Iron", "add  ."). The illegal-play message "One Infrastructure per turn: you already played
  yours" is good. Cards in hand are cut off by the bottom edge, so cost and stats sit at y≈890 of 900. The "Opening hand: 2
  infrastructure, 4 spells" panel calls units "spells", which contradicts the card types. Fights are long: 9 turns (loss) and 21 turns /
  110 s (win at 7/16 HP).
- **Reward**: +35 gold, +30 XP for that 21-turn win (`r23_02`). With 465 XP to level 14, that is about 15 such fights per level.
- **Taste Test Lab event** (`r23_04_node2_click.png`, `r24_01_reveal.png`): the prompt "does your deck have the body for the panel?"
  never says what is tested. The reveal says "1 of the 5 cards was Unit cards; 2 were needed", so it is a pure luck draw that costs 2 HP
  in a no-healing dungeon. The result header reads "**The well stays silent.**", copy reused from a well event. Before the reveal, the
  panel is a huge empty purple box.
- **Boss: the Doppelganger** (`r12_02_boss_click.png`, `r12_09_boss_end.png`, `r14_03_esc.png`, `r15_04_boss`, `r15_06_boss_mid.png`,
  `r25_02_cut2.png`): the intro writing lands ("She has worn it for ten years without a crease"). The map-intro dialogue box is drawn
  **on top of** the boss info panel, hiding the rules. The second scene uses two placeholder silhouettes (a chef's hat and a wizard hat)
  instead of portraits. **Input soft-lock**: on three runs, E, Space and click did nothing on the "Welcome to the Executive Test Kitchen"
  line for 10+ s. Only Esc > "Skip this scene? You haven't seen it." got me out. On another run, Space after a 3 s wait did advance it.
  So the scene silently drops input for several seconds per line, and to a player that looks frozen. The boss rules panel is excellent
  (Mise en Place / Perfect Copy / The Mask Slips / No Face of Its Own). In the fight, the boss ran a 3/3, a 3/4, a 3/4 and a Wonder from
  turn 2 and I was dead on turn 5 (`r15_06_boss_mid.png`: "You 1" behind DEFEAT, boss untouched at 16). None of the scripted phases ever
  happened.
- **Boss reward** (`r25_04_boss_reward.png`): +100 gold, +120 XP and a pick of 3. Two of the three are Gourmand for a Beefcake deck. The
  line "Added to your collection: Stock The Pantry" appears *before* you choose, which reads as if the choice was made for you. Reroll
  costs 170 gold, which is steep against 35-gold fights. A "Feat: Flawless" toast covered the top of the panel (this one came from
  autowin, so it is a dev artifact, but the toast overlapping a reward panel is real).

### A look back at the freed D.N.A.
- (`r16_02_dna_walk.png`): it's dark green-grey, with labels piling onto one another ("Prudence Pallor" and "Agnes Overdue" on top of
  Agnes's bark, all unreadable). There is a nice peacock ribbon-cutting scene on arrival. But the HUD still says **"Zone HP: no healing
  after battles"** in a zone I freed, and the tracker reads "Go to Crosspath". Nothing tells me what freeing changed or why I should come
  back: no "freed" banner, no new vendor, no lifted rule. Compare Sea of Stars and Octopath, where a liberated town visibly changes and
  offers something.

### The Verdant Dump and the Rotheart
- **Zone** (`r16_07_dump_walk2.png`, `r16_08_dump_walk3.png`): a distinct violet-amber palette, but very hazy. Heavy depth of field and
  bloom make it hard to read where the paths go. The zone load took 13 s. The Rift cousin pop-up again froze me for two 4-second walks.
  The cousin gag ("looked at his hands, then at the hole, then at his hands again") is funny.
- **Map** (`r17_03_rot_preboss.png`): another beautiful painted map with a clear route to the heart.
- **Rules** (`r18_05_rules.png`, `r19_03_line5.png`): two different rules are both named **"Overgrowth"** (+2 defence for Refusemancers,
  and "each unit gets a buff each turn"). "Rot: units with 1 defence are destroyed" is a good, legible twist.
- **Boss: Compostella** (`r19_01_line3.png`, `r19_06_boss_mid.png`): the best boss intro I saw ("I am what you throw away... Please. The
  tree."). The fight: the every-turn buff snowballed a Possum Prowler to **8/10 with x4 buffs**, which "dealt 16 of the 20 damage you
  took (2 hits)". I was dead on turn 6 with the boss at 22/22. The "near the end" phase (her units get -1/-0) never came. The loss also
  charged a **"Mucking-out fee: -20 gold"**.
- Escape during the map-side boss intro opens the **Pause menu**, while Escape during the cutscene offers **Skip** (`r18`, 05 vs
  `r14_03_esc.png`).

### Side dungeon: Omakase (S-GOUR)
- (`r20_03_sgour_map.png`): three nodes on a lovely koi-pond map. A short side dungeon is exactly the right length for this game's slow
  fights. I didn't fight here.

### Performance
- Snapshot load about 7-8 s, zone travel 6.5-13 s (the Dump is the slowest), dungeon entry about 4 s. No SCRIPT ERROR in any `stdout.log`.
  Every exit logs leaked RIDs/ObjectDB instances (shutdown noise, not player-facing).

## Top 15 problems (ranked by impact on mid-game enjoyment and retention)

1. **16 HP at level 13 with no healing after battles, even in freed zones.** Where: `r1_04_char.png`, `r11_01_result.png` (7/16 after
   one normal win), `r16_02_dna_walk.png` (freed zone still "no healing"). Why: every fight chips a tiny pool across 7+ nodes, so one bad
   draw ends a 15-minute dungeon run. It also makes HP-costing events feel spiteful. Fix: scale max HP with level (for example 16 + 2 per
   level), heal fully between dungeon visits and partly (30-50 %) after each dungeon fight, and lift "no healing" once a zone is freed.

2. **Bosses kill before their scripted phases ever happen.** Where: `r15_06_boss_mid.png` (dead turn 5, boss 16/16),
   `r19_06_boss_mid.png` (dead turn 6, boss 22/22, an 8/10 Possum). Why: the phases ("The Mask Slips", "Please. The tree.") are the
   story payoff, and players will never see them. A boss that wins on turn 5 feels unfair, not climactic. Fix: tune boss tempo so turns
   1-3 are a setup window (slower starting board, buffs that begin on turn 3), cap the Rotheart's per-turn buff stacks, and test against a
   mid-skill human line, not a perfect one.

3. **Boss intro scenes drop input and look frozen.** Where: `r12_09_boss_end.png`, `r14_03_esc.png` (E, Space and click ignored for 10+
   s; only Esc > Skip works), `r25_02_cut2.png` (works after a 3 s wait). Why: a player who taps twice and sees nothing will think the
   game hung, right before the biggest fight. Fix: the first press finishes the typewriter, the next press advances, with no hidden
   cooldown. Show a pulsing "continue" arrow only when input is accepted.

4. **Fights are long and pay little.** Where: `r11_01_result.png` (21 turns, about 110 s) → `r23_02_aw1_reward.png` (+35 gold, +30 XP);
   level 14 needs 465 XP. Why: about 15 fights per level, with dungeons of 7+ fights each, makes the mid game a grind with no sense of
   progress. Fix: raise per-fight XP about 2-3x or show level progress on the victory panel; add a per-dungeon completion bonus; consider
   shorter fights (lower enemy HP or faster resource ramp at this level).

5. **The resource system is opaque on cards.** Where: `r10_03_hover.png` (raw "Exhaust: add (B)."), every dump line ("create an  Iron",
   "Exhaust: add  ."), `r9_02_battle.png` ("2 infrastructure, 4 spells" when two of them are units). Why: mid-game players are building
   around Iron and Ingredients, and the card text literally has holes in it. Fix: render the resource icons in every rich text (tooltip,
   pack reveal, event reveal, Deck Station), replace "(B)" with the icon and name, and say "4 other cards" instead of "spells".

6. **Vendors and NPCs are hard to reach, and click-to-interact doesn't path.** Where: `r4_03_west2.png` (Talk prompt once) versus
   `r5_02_gearshop.png` and r28 (same walk, out of range), r6 (clicking Foil Fenwick did nothing). Why: the hub is visited every session.
   Fiddly interaction there makes shopping and deck tuning feel like work. Fix: widen the interaction radius for vendors, make clicking
   an NPC walk to and talk to them, and add a "Shops" section to "Where to?" (or a vendor board in the square).

7. **Freeing a zone changes nothing you can see or use.** Where: `r16_02_dna_walk.png`. Why: freeing zones is the main goal ("Free the
   Four Zones"), and the reward should be felt on return; otherwise there's no reason to go back. Fix: a "Freed" banner on arrival, lift
   the no-healing rule, brighten the palette, add a grateful NPC or vendor with zone cards, and list new side content.

8. **Escape does three different things.** Where: `r14_03_esc.png` (skip scene), `r18` 05 (pause during the map intro), `r26` 05 (closes
   the whole Deck Station from a modal). Why: an inconsistent "back" key causes lost context and accidental exits. Fix: Escape always
   closes the top-most layer first (modal → screen → pause), and skipping a scene gets its own key or button.

9. **Random "deck test" events punish HP with no information.** Where: `r23_04_node2_click.png`, `r24_01_reveal.png`. Why: "does your
   deck have the body for the panel?" hides that it draws 5 random cards and needs 2 units. It then costs HP in a no-heal dungeon and
   prints "The well stays silent." in a kitchen. Fix: state the test up front ("Draw 5: need 2+ Units"), show your odds from your current
   deck, offer a decline option, and give each event its own result line.

10. **Overworld readability: labels collide, haze is heavy, pop-ups freeze you.** Where: `r16_02_dna_walk.png` (three names on one
    bark), `r6_09_walk3.png` (bark over the name plate, prompt over the player), `r16_07_dump_walk2.png` (Rift pop-up while walking), the
    Dump's depth-of-field haze. Why: you can't tell who you're talking to or where to go. Fix: stack or offset barks above name plates,
    fade the name when a bark shows, cut DoF/bloom in zones, and show Rift Station unlocks as a non-blocking toast.

11. **Maps start black, and "Where to?" is nearly empty in new zones.** Where: `r6_06_buffet_whereto.png` (empty), `r4_01_whereto.png`
    (no shops, no Buffet road). Why: mid-game players want to go to the dungeon, the shop or the quest NPC. A black map makes the
    first visit a blind walk. Fix: pre-reveal landmarks (town, dungeon entrance, Rift Station, quest-giver) when you enter a zone, and
    list them in "Where to?" with fast-travel where unlocked.

12. **Rewards often don't fit the deck you're playing.** Where: `r25_04_boss_reward.png` (2 of 3 Gourmand for Beefcake), `r3_01_reveal.png`
    (a "Gilded Necrocrat" pack gives 2 Colorless). Why: a boss pick that's two-thirds off-Path feels like a non-reward, and a reroll at 170
    gold is about 5 fights' pay. Fix: weight boss picks toward the player's Path (at least 2 of 3 on-Path or Colorless), make gilded
    zone packs mostly that zone's colour, and cut the reroll price.

13. **The pack-opening ritual doesn't scale.** Where: `r1_02_packs.png` (15 packs), `r3_02_after.png`. Why: 4-5 clicks per pack times 15
    packs is about 70 clicks, and the NEW! badge hides card names. Fix: "Open all" with a single summary grid, keep the ceremony for
    gilded packs, and move the NEW! badge off the title bar.

14. **The deck-building screen is cramped and silent.** Where: `r1_03_deck.png` (deck racks eat the third card row, tip covers the deck
    list), `r26_01_new_filter.png` (blank board for an empty filter). Why: building with a 100+ card mid-game collection needs space and
    feedback. Fix: collapse the deck racks into a dropdown so the grid shows 3-4 rows, add "No cards match: clear filters", and show
    card counts per filter chip.

15. **Small UI collisions and inconsistencies.** Where: `r12_02_boss_click.png` (dialogue over the boss panel), `r18_05_rules.png` (two
    rules named "Overgrowth"), `r1_04_char.png` ("Item slots 2/4" vs "Equipped 0/2"), `r1_05_quests.png` ("Free the Four Zones 2/5"),
    the boss reward "Added to your collection" text before the pick, `r25_04_boss_reward.png` (Feat toast over the reward header),
    `r12_09_boss_end.png` (placeholder hat silhouettes in the boss scene). Why: each is small, but together they make the game feel
    unfinished just when the art makes it feel premium. Fix: one consistency pass. Rename duplicate rule names, queue toasts until panels
    close, put real portraits in the cutscene, and show "Click a card to add it" until a pick is made.
