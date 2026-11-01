# Fresh eyes - The Wayward Path, mid game (second critic, Oct 31 / Nov 1)

Screenshots cited below are in `fresh_eyes_midgame_oct31n_second/` and named `<run>_<shot>.png`.

## Summary

The mid game looks wonderful and plays badly. The painted dungeon maps (Test Kitchen, Rotheart, Omakase), the shop and boss art and the resolution stills are as good as anything in the genre. The systems around them (rules panels, the defeat recap, Deck Station filters, the reward pick with reroll) are thoughtful. But nearly every time I tried to *do* something, the game got in the way. I could not open the card vendor in five tries. Clicking cards in a 10+ card hand did nothing useful. The boss scenes took around 25 key presses and gave away their own twist. Worst of all, the snapshot's level-13 Beefcake deck lost **4 fights out of 4** against the new content: the first Test Kitchen node, the Test Kitchen boss, the Rotheart boss and the first Omakase node. Both bosses ended on full HP. Some of that is the built-in pilot and my own clumsy clicking, but no fight was even close. A player who has just freed two zones meets a wall, and the two zones that remain feel like the same wall.

## How I played

- About 55 minutes of wall clock (01:07 to 02:02), 27 runs, all from `midgame_real`.
- **Crosspath** (c8_town, c8_town2, c8_town3, c8_shop..c8_shop7): packs (opened a Gilded Beefcake pack), the Deck Station, the Character screen, the Quest log, the map and "Where to?", the Menu. I tried the card vendor (Sable) five times and failed every time. The item vendor (Tilly Tonic) worked on the first try. **Skipped:** equipment vendor, tailor, Collection Book / Hall of Records (I ran out of patience with walking and finding NPCs).
- **Endless Buffet** (c8_buffet, c8_ttk): walked in from the bridge, used the map and "Where to?", tried to talk to Sous-Chef Tarragon (no prompt came up).
- **The Test Kitchen** (c8_fight1-4, c8_boss1-4, c8_win, c8_win2, c8_win3, c8_manual, c8_manual2):
  - Node 1 (Frozen Line Cook): I played two turns myself, then the pilot took over. **Lost.**
  - I jumped to the boss with `dev travel dungeon D-TTK -2`. Boss (The Doppelganger), piloted: **lost on turn 6**, boss at 16/16.
  - I re-ran the boss with `dev win` to see the reward and ending flow.
  - Node 1 again, played "by hand" with a click macro: nothing got played (see Combat).
  - One run quit the game when an Escape opened the pause menu and my next click landed on "Quit Game". That was my mistake, but there is no confirmation step.
- **D.N.A. (freed)** (c8_zones): arrival and the Lobby.
- **Verdant Dump** (c8_zones): arrival bridge, Compost Commons. **The Rotheart** (c8_rot1, c8_rot2): jumped next to the boss. Compostella, piloted: **lost on turn 10**, boss at 22/22.
- **Side dungeon Omakase** (c8_side, c8_side2): map and rules. First node, piloted: **lost on turn 11**.
- `dev autowin` was never used. `dev win` was used once, only for the Test Kitchen boss reward screens.

## Scores (1-10, against Slay the Spire, Inscryption, Monster Train, Sea of Stars, Octopath, TCG Pocket)

| Area | Score | One line |
|---|---|---|
| Clarity | 6 | Rules panels and the defeat recap are excellent. Quest steps, boss names and turn numbering confuse. |
| Pacing and friction | 4 | Finding and talking to NPCs, long two-press dialogue, multi-click packs, ~25-press boss scenes. |
| Combat depth and feel | 4 | Interesting rules, but 4/4 losses, an unreadable 13-card hand and click-to-play that eats inputs. |
| Deck-building satisfaction | 6 | Good filters, Suggest/Fill, caps shown. Tiny text, and a deck list that shows 3 rows. |
| Reward rhythm | 5 | A nice card pick with reroll, but a zone boss pays 100 gold and 120 XP against 465 XP to the next level. |
| Exploration and world | 6 | Three distinct zones and gorgeous dungeon maps. Fog-of-war maps, no in-world waypoint, occlusion. |
| Story and humour | 6 | Barks land ("The well hummed at me...", "Employee of the month since 1987"). The boss twist spoils itself. |
| Visual cohesion and readability | 7 | Superb painted art. Placeholder glyphs in cut-ins, haze in the Dump, overlapping labels. |
| UI/UX consistency | 5 | E, Space and Esc each do different things on different screens. Quit has no confirm. E grabs the reward card. |
| Audio | n/a | Cannot judge from screenshots and logs. |
| Performance | 7 | Snapshot load ~7 s, zone travel 6-13 s, dungeon entry ~4 s. No stutter visible in the timestamps. |
| Bugs | 5 | No SCRIPT ERRORs. Stale tooltips, a vendor with no interact prompt, "1 uses left", missing waypoint. |

## Findings per area

### Clarity
- **Good:** the pre-fight rules card ("Before the fight: Frozen Line Cook" with every rule spelled out, `c8_ttk_54_ttk_rules.png`), the rules icons under the enemy portrait with a tip saying red helps them and green helps you, and the "What beat you" defeat box (`c8_boss4_104_end2.png`: "Sashimi Weenie dealt 9 of the 21 damage you took", plus a concrete tip). These are better than most of the genre.
- **Quest tracker in the Buffet** says "Win the pantry key from Chef Fennel Gravois ... Go to Crosspath" while I am standing in the Buffet (`c8_buffet_40_buffet_arrive.png`). The Dump says the same: "Uproot Moss Mulligan at the thorn wall ... Go to Crosspath" (`c8_zones_113_dump_arrive.png`). I could not tell whether "go to Crosspath" was the next step or a leftover.
- In Crosspath the Quest log's main list is "Key Ingredients 0/4, Root Cause 0/4, Free the Four Zones 2/5, Fragments 2/4" (`c8_town2_10_quests.png`). The tracked one, Fragments, says "free a zone, then see Elder Maren". Nothing says "the next zone is the Endless Buffet, its road leaves the square to the X".
- **Battle turn counter** jumps from Turn 1 to Turn 3 because it counts both sides' turns (`c8_fight3_67_turn2.png`). A player reads that as a skipped turn.
- **Stale message:** "Needs 2 energy; you have 0" stays on screen into the next turn (`c8_fight3_67_turn2.png`, `c8_fight4_73_t3_unit.png`).
- **The boss node panel names the twist.** The Grand Kitchen node shows "Boss: Grand Chef Escoffina. The Doppelganger, 16 HP", the dialogue speaker tag already reads "The Doppelganger" (`c8_boss1_82_intro1.png`), and the battle intro card is titled "The Doppelganger - Grand Chef of the Test Kitchen (allegedly)" (`c8_boss4_100_after_scene.png`).

### Pacing and friction
- **NPC interaction is the single most frustrating thing in the build.** I walked to Sable (cards) five times. Adjacent to her stall, no "[E] Talk" prompt appeared and E did nothing (`c8_shop6_34_e.png`). Clicking her from a few metres away did nothing either. Tilly Tonic next door worked first time with a clear "[E] Talk". Sous-Chef Tarragon in the Buffet also gave no prompt (`c8_ttk_51_tarragon3.png`). In that shot the player is the tiny yellow arrow at the bottom edge, hidden behind giant salt-shaker pillars.
- **Finding the player:** in Crosspath the roofs in the foreground hide the hero, and I mistook a cloaked townsperson for myself for several runs (`c8_shop2`, `c8_shop5_34_e.png`).
- **Dialogue takes two presses per line.** The first press finishes the typewriter and the second advances. The Test Kitchen boss's pre-fight sequence needed about 22 presses (~25 s) before "Keep Hand" appeared. `skip_dialogue` and E did not move the cut-in panel; only Space did.
- **Packs:** each pack is Open, then click the pack, then click to reveal each card, then Done. With ~15 packs in the snapshot that is 60+ clicks, and there is no "open all".
- Walking is slow for the size of the zones: 3 s of W from the Buffet bridge barely reached the plaza (`c8_buffet_46_walk.png`).

### Combat depth and feel
- **4 losses from 4 fights** with the snapshot deck: Frozen Line Cook (node 1), the Doppelganger (boss, 0 damage dealt, lost turn 6), Compostella (boss, 0 damage dealt, lost turn 10), Apprentice Itamae (Omakase node 1, lost turn 11).
  - On the Rotheart board at turn 10 I had five infrastructures and **zero units**, against Mulch Mole 10/14, Landfill Ox 9/12 and Mulch Mole 4/8 (`c8_rot2_125_rot_mid1.png`). "Wild Growth: each unit gets a buff at the start of each turn" snowballs the zone's own tanky units, and "Rot: units with 1 defense are destroyed" punishes Beefcake's glass cannons.
  - The pilot is not a strong player, but no fight was close. The first node of the next zone should not beat a level-13 player with a 46-card built deck.
- **Hand at mid-game is unreadable.** By turn 11 the hand holds 13 overlapping slivers (`c8_manual2_169_end.png`).
  - My click macro clicked seven hand positions per turn for six turns and got almost nothing onto the board: one Powerhouse in eleven turns.
  - Clicking a spell enters "Choose a target", and every later click is swallowed until you right-click or press Cancel.
  - Only drag reliably played a card (`c8_fight4_70_drag_infra.png`).
- **Card zoom is too big.** Hovering a hand card throws up a full-size card plus a keyword panel that covers half the hand (`c8_fight3_61_played_infra.png`). The zoom card in the top-left panel already shows the same card.
- Enemy infrastructure appears as tiny thumbnails at the top edge. Enemy units are fine.
- **Good:** the "End your turn? You can still play 1 card" guard, the phase ladder on the right, and "Opening hand: 3 infrastructure, 3 other cards" with a free mulligan.

### Deck-building satisfaction
- The Deck Station (`c8_town3_13_deck.png`) has the right tools: colour, type, cost and rarity filters, "New", "Deck 1/3 Own 3" under each card, a mana curve, copy caps, Fill Infrastructure and Suggest a deck. That is close to TCG Pocket.
- The "Your Deck" list shows only **three rows** (Dropped Weights, Hamster Wheel Runner, Kettlebell) in a box that could hold ten. The card rules text in the grid is about 9 px. The first-visit tip covers the bottom deck racks.
- The Gilded pack reveal is a good moment (`c8_town2_07_deck.png`: an Epic "NEW!" card). But the summary "1 new card" is buried under the three card names.

### Reward rhythm
- Test Kitchen boss: **+100 gold, +120 XP** and a pick of three cards with Skip and Reroll (170 gold) (`c8_win3_142_r1.png`). Level 14 needs 465 XP (`c8_town3_15_char.png`), so a zone boss is a quarter of a level.
- **Pressing E on the pick screen took the highlighted card at once.** A player mashing E to get through the ending text loses the choice.
- Tilly's items cost 30-60 gold against 600 in the purse (`c8_shop7_152_tilly_shop.png`), so gold has little pull at this point.
- The snapshot carried four item types and 0 of 2 slots equipped. Equipping is a separate trip to the Character screen.

### Exploration and world
- The three zones are clearly different: the Buffet's food-sculpture plaza (`c8_buffet_46_walk.png`), the D.N.A.'s green marble lobby (`c8_zones_112_dna_walk2.png`) and the Dump's ravine market (`c8_zones_116_dump_walk2.png`). The dungeon maps are the best thing in the game (`c8_ttk_54_ttk_rules.png`, `c8_rot2_123_rot_scene_3.png`, `c8_side_170_omakase_map.png`).
- **"Where to?" is a good list** (`c8_town3_16_whereto.png`, `c8_buffet_43_buffet_whereto.png`: The Test Kitchen (Dungeon entrance), The Walk-In Freezer (Mini dungeon), vendors, a healing spot). But choosing an entry only draws a pin on the map (`c8_shop_18_map_cardvendor.png`). Back in the world there is no arrow or trail (`c8_shop_19_after_whereto.png`).
- The Buffet's map is pure black except the arrival dot (`c8_buffet_43_buffet_whereto.png`). The HUD minimap in Crosspath's square is a featureless tan blob (`c8_town_01_town.png`).
- Old Hob the Gravedigger stands in both the Buffet and the Dump (`c8_buffet_46_walk.png`, `c8_zones_116_dump_walk2.png`), and Prudence Pallor (listed as a Crosspath challenger) stands in the D.N.A. lobby. If they roam on purpose, nothing says so.

### Story and humour
- The barks are good and short: "The well hummed at me. Wells don't hum. I said thank you anyway." (Crosspath), "I knead a holiday. Then I knead the dough." (Brindle), "Employee of the month since 1987, dear. The plaque is getting heavy." (D.N.A.). The Buffet's Rift station line works too: "A cousin ripped it in, then asked if there were seconds."
- The Doppelganger arc is strong on paper: "Ten years in this face and this apron, and not one Gourmand looked twice", the freezer, "Yes, Chef!" ... "they mean the right one". The resolution still (`c8_win3_147_r6.png`) is lovely. But the reveal is spoiled three ways before the fight (see Clarity), and the line "This is what was under it. I wore her face so long that I forgot my own" plays **before** the battle (`c8_win_130_win.png`).
- Narration lines carry the boss as speaker: "The Doppelganger collapses, and the Special Sauce goes with it..." is tagged "The Doppelganger".

### Visual cohesion and readability
- **Placeholder glyphs in the boss cut-in:** a flat white chef's hat against a flat yellow wizard hat (`c8_boss1_85_intro4.png`), and later a purple slime glyph (`c8_win_130_win.png`). These come seconds after the full painted portrait (`c8_boss1_82_intro1.png`) and look unfinished.
- The two bosses I met share a template: white-haired older woman, three-quarter pose, staff or ladle (`c8_boss1_82_intro1.png`, `c8_rot2_123_rot_scene_3.png`).
- The Verdant Dump has a heavy sepia-violet haze plus tilt-shift that washes out the whole screen (`c8_zones_113_dump_arrive.png`).
- In the D.N.A. lobby the NPC names and the bark bubble pile on top of each other: "Prudence Pallor", "Agnes Overdue" and "Employee of the month..." are illegible (`c8_zones_112_dna_walk2.png`).
- The "-3" and "-4" damage pops overlap the "YOU" plate (`c8_rot2_125_rot_mid1.png`).

### UI/UX consistency
- Space advances the cut-in but does not press "Continue" on the Victory popup (c8_win2).
- Esc is labelled "skip" in the cut-in, but on the earlier speech box it opens the pause menu (c8_boss3).
- E on the card-pick screen takes the card.
- "Quit Game" in the pause menu quits with no confirmation (c8_manual).
- The dialogue box sits on top of the dungeon node panel and hides half of its rules text (`c8_boss1_82_intro1.png`).
- "Owned - 1 uses left" (`c8_shop7_152_tilly_shop.png`). The Vitality Charm's description is only flavour ("A small, steady comfort.") with no effect stated.

### Audio
- Cannot judge. Nothing in the logs indicated audio problems.

### Performance
- Snapshot load ~7 s, `dev travel zone` 6-13 s (the Dump took 13 s), dungeon entry ~4 s, and a 26-decision fight in ~65 s at 1x.
- Hitches I could see: none. The game took about 30 s from launch to title on each run, which is fine.

### Bugs
- No `SCRIPT ERROR` in any `stdout.log`.
- Sable (card vendor) never shows an interact prompt (`c8_shop6_34_e.png`).
- The stale energy message persists across turns (`c8_fight4_73_t3_unit.png`).
- The freed D.N.A. still shows "Zone HP: no healing after battles", right under the banner "The D.N.A. is free" (`c8_zones_112_dna_walk2.png`). Either the hazard should lift or the text is wrong.
- The town HUD's quest-tracker labels stay "visible" behind full-screen menus: the dump of the Packs screen still lists them. That is harmless for players, but focus or navigation may land on them.

## Top 15 problems (ranked by impact on mid-game enjoyment and retention)

1. **The new zones are a wall.**
   - Where: `c8_fight4_75_after_pilot.png`, `c8_boss4_104_end2.png`, `c8_rot2_125_rot_mid1.png`, Omakase node 1.
   - What: 4/4 losses for a level-13 built deck, including the first node of the next zone and the side dungeon's first node. Both bosses ended on full HP.
   - Why it matters: this is where players quit.
   - Fix: re-tune Buffet and Dump encounters for a two-zones-freed player. Show a recommended level or "danger" on nodes. Soften zone rules that hard-counter the player's Path on early nodes (Rot destroying low-defense units, Wild Growth snowballing the home side). Add a mid-game "Bring the right deck" hint that points to Suggest a deck with the zone's weakness.
2. **Playing cards from a big hand is broken in practice.**
   - Where: `c8_manual2_169_end.png`, `c8_fight3_61_played_infra.png`.
   - What: 13 overlapping slivers, clicks hit the wrong card, a spell click traps you in targeting, and the hover zoom covers the hand.
   - Fix: fan or compress with a second row past 8 cards, raise the hovered card without a second giant zoom, dim unplayable cards, add a one-click "play infrastructure" button, and cancel targeting when another hand card is clicked.
3. **NPCs and vendors are hard to reach and hard to talk to.**
   - Where: `c8_shop6_34_e.png`, `c8_ttk_51_tarragon3.png`.
   - What: no prompt next to Sable or Tarragon, and the hero is hidden by roofs and props.
   - Fix: a larger interaction radius, a prompt that names the target ("[E] Sable - Cards"), click-to-walk to an NPC, and fade or cut out geometry between the camera and the hero.
4. **Boss scenes are long and spoil their own twist.**
   - Where: `c8_boss1_82_intro1.png`, `c8_boss4_100_after_scene.png`, `c8_win_130_win.png`.
   - What: about 22 presses before the fight, and the Doppelganger is named in the node panel, the speaker tag and the intro card. The "under the face" reveal plays before the battle.
   - Fix: show "Grand Chef Escoffina" until the scripted mid-fight slip, move the reveal lines into the fight event or the ending, make one press finish and advance a line, and offer a single "skip scene" press.
5. **Placeholder glyphs in the cut-in panels.**
   - Where: `c8_boss1_85_intro4.png`, `c8_win_130_win.png`.
   - Fix: use the painted portraits (they exist), or the boss cut-out from the intro card.
6. **Inconsistent confirm and cancel keys, plus destructive defaults.**
   - What: E takes the reward card, Space ignores the Victory Continue, Esc means pause on one box and skip on the next, and Quit Game has no confirm.
   - Fix: one rule everywhere (E/Space confirms the *focused button*, Esc backs out or skips). The card pick needs an explicit choice. Confirm before quitting.
7. **Quest guidance in the zones is muddled.**
   - Where: `c8_buffet_40_buffet_arrive.png`, `c8_zones_113_dump_arrive.png`, `c8_town2_10_quests.png`.
   - What: "Go to Crosspath" shows while you are in the zone, and nothing names the next zone.
   - Fix: phrase steps as "Next: beat Chef Fennel Gravois (Crosspath, south square) for the pantry key". Show the zone's main dungeon as the goal once inside. Add a "Next zone" line to the main quest.
8. **"Where to?" has no in-world follow-through.**
   - Where: `c8_shop_18_map_cardvendor.png` versus `c8_shop_19_after_whereto.png`.
   - Fix: when a destination is chosen, drive the existing goal pointer and screen-edge arrow to it until you arrive.
9. **Thin rewards for big moments.**
   - Where: `c8_win3_142_r1.png`.
   - What: 100 gold and 120 XP for a zone boss, a quarter level, while shop prices make gold meaningless.
   - Fix: roughly double boss XP (aim for a level per zone boss), add a guaranteed Gilded pack or gear piece, and give gold sinks that matter at 600+ (reroll, gear upgrades, cosmetics).
10. **A freed zone does not feel freed.**
    - Where: `c8_zones_112_dna_walk2.png`.
    - What: the hazard text remains and the lobby looks the same. The banner promises new dialogue, but nothing points to it.
    - Fix: lift the zone HP rule, change lighting and props, and mark NPCs with new lines (a speech icon) so revisiting has a reason.
11. **Readability in the world.**
    - Where: `c8_zones_112_dna_walk2.png`, `c8_zones_113_dump_arrive.png`.
    - What: overlapping NPC labels and barks, and the Dump's haze and tilt-shift wash out the screen.
    - Fix: stack or offset name plates, hide names while a bark shows, and cut the Dump's post-process haze by half.
12. **Deck Station layout wastes its best panel.**
    - Where: `c8_town3_13_deck.png`.
    - What: the deck list shows 3 rows and the card text is tiny.
    - Fix: make the list fill the right column, add a compact text-list mode for the grid, and enlarge rules text on hover in place.
13. **Packs take too many clicks.**
    - Where: `c8_town_02_packs.png`, `c8_town2_07_deck.png`.
    - What: 4+ clicks per pack, with 15 packs waiting.
    - Fix: an "Open all" button with a single summary screen (new cards first), and keep the ceremony for Gilded packs.
14. **Battle HUD noise.**
    - Where: `c8_fight3_67_turn2.png`, `c8_rot2_125_rot_mid1.png`.
    - What: the turn counter counts both sides, a stale energy message, damage pops over the name plate, and first-time tips still interrupting at turn 11 (Tools).
    - Fix: number rounds, not half-turns. Clear the message on phase change. Anchor pops to the HP number. Show tips at the start of a turn and never while a targeting arrow is up.
15. **Equipment and items need too many trips.**
    - Where: `c8_town3_15_char.png`, `c8_shop7_152_tilly_shop.png`.
    - What: the save owned items with 0/2 equipped, gear slots show icons with no stats, and "Path essence 0 0 0 0" is unexplained.
    - Fix: auto-equip into empty item slots on purchase, show stats on the slot plates, and add a tooltip that says what essence is for.
