# Overnight inbox - archive (Oct 17 and Oct 18 daytime)

Older questions, still open unless the main inbox says otherwise. Moved here from docs/overnight_inbox.md on Oct 19 to keep the inbox short.

## Overnight Oct 17 - decisions that are yours (most important first)

The run took the safest reasonable choice for each and carried on; the full reasoning is in `docs/design/open_questions.md` (ON17-...).

1. **Copy caps use the game's rarities** (ON17-1). There is no "Rare" tier (Common, Uncommon, Epic, Legendary), so Epic stands in for Rare:
   Common 3, Uncommon 2, Epic 1, Legendary 1 at the start. Raises: Uncommon 3 at L9, Epic 2 at L12 and 3 at L22, Legendary 2 at L18 and 3
   at L30 (`data/progression/level_track.json`). Change the levels there.
2. **You never own more than your cap** (ON17-4). A copy over the cap converts into Path essence (gold for a neutral card) the moment it
   arrives. Old saves: copies over the cap convert on load and saved decks drop the extras (the battle deck is topped up with basic
   infrastructure so it stays legal). The alternative (keep extras in the collection until the cap rises) is easy to switch to.
3. **The kingdom is Patchwork** (ON17-6): renamed from the build's "Pathwork"; the throne keeps the sheet's name "the Pathwork Throne". Say if the throne should be the Patchwork Throne too.
4. **XP curve** (ON17-7): levels 21-30 got cheaper (one completionist run reaches 30, a main-line run lands around 21-23). Levels 1-20 unchanged.
5. **Gold is a level reward again** (ON17-8) because this brief asked for it; Brief 16 had removed it.
6. **The level-5 armory quest replaces the 5/10/15/20/25 equipment-slot choices** (Part 5). Old saves with slots count the quest as done.
7. **Species for the NPCs the sheet left blank** (Part 11, ON17-10): King, Queen, Elowen, Dr. Siphon human (the royal line is human); Vivienne Quota ferret, Colonel Crumb badger, Percival Plume peacock, Hortensia Clipwell hare, Isla Brannoch bear (her father is a bear). Change them in `tools/npc_truth_input.json` and re-run `node tools/npc_truth.js`.
8. **The strolling baker is Brindle the Baker** (the name the town already used; NPC-VILLAGER, a badger). Three townsfolk also stroll the well yard, Elder Maren's lane and the Arena gate (NPC-TOWNSFOLK: the shared townsfolk sprite with tints).
9. **Music: nothing was dropped** (Part 12). No track is broken after the loop fixes. Audition the 35 loop-fixed seams (`docs/audio/loop_fixes.md`); MUS-SHOP-GRISTLE still steps -7.2 dB at its loop wrap.
10. **Boss wins play a 3.6 s cut of the boss track's climax** instead of the generic victory sting (`STG-WIN-*`). Say if you prefer the generic one.
11. **Keyboard / pad focus** now shows a gold ring on every menu button (Part 13). HUD buttons stay mouse-only on purpose (so Space/E in the world never re-presses a menu button).
12. **Floating exit labels in the zones** ("The Way to Town", "Back to Town" over the entrance bridges) are readable text in the 3D world, which the rules forbid. They predate tonight and I left them alone. Keep them, or swap them for an icon sign like the town's?
13. **Music leveller** (cycle 10): a gentle compressor on the Music bus keeps the quiet parts of the 26 very dynamic tracks audible under battle sounds, at unchanged loudness. Listen to the arena battle and the credits. `AudioMix.MUSIC_LEVELLER = false` turns it off.
14. **Enemy pictures**: the Bestiary and the battle plate will show a picture for each enemy as soon as one exists. There are 90 prompts in `docs/art/bestiary_image_requests.md`, in batches of 20. Save each as a square PNG named with its ID under `assets/art/bestiary/`.
15. **New passing lines (cycle 16)** for the freed leaders, the reformed Escoffina, postgame "Primm, at work" and Captain Spotless are in `tools/npc_truth_input.json` (two each). Primm's lines are humble ("I am learning to let that be"). Edit them freely, then re-run `node tools/npc_truth.js`.


## Major rebalance (Oct 18) - decisions that are yours

The rebalance took the safest reasonable choice for each and carried on; the full reasoning and every number is in
`docs/design/balance_log.md`, the sheet-side list in `docs/design/sheet_changes.md`, the resume state in `docs/design/balance_state.md`.

1. **No `docs/design/sheet_snapshot/` and no `docs/design/canon.md` exist in the repo.** The CSVs in `data/source/` (card_list,
   token_list, design_guidance, dungeon_list) were treated as the sheet snapshot, and `docs/design/combat_rules.md` as the canon.
   The local Design Guidance rows for Iron / Red Tape / Eat Garbage still carried the OLD rules; they were updated to the brief's.
2. **Iron at 1 energy is strong, not weak.** Beefcake's reference deck wins 83% against Refusemancer with Iron and 60% without it
   (`docs/design/sim/matchup_beefcake_refusemancer*.md`), so no cost change is proposed. If Beefcake still reads as too strong after
   the Part G iterations, the lever would be the Iron rule itself (+1/+0 instead of +1/+1, or pay 2), not more card nerfs.
3. **Chancellor Clench doubles the new resources** (Iron +2/+2, Red Tape -4/-0). Say if you would rather have +2/+1 / -3.
4. **The "lose N HP" cost went on six Refusemancer abilities** (Landfill Ox, Acid Vomitor, Poo-uid, Archdruid Compostella,
   Conscripted Constrictor, Tuskeroni). Possum Prowler, Bird of Paradump, Freegan Forager, Truck Tire, Trash Panda Powerlifter and
   Scrapheap Lich eat for free (energy only). The Raccoon frees the energy, never the written HP cost.
5. **The tutorial's three enemy decks were retuned** for the new starting decks (fewer walls, thinner on attackers); the Hollow
   Warden keeps 3 HP. The AI-played tutorial clears are 78-86% per Path (`docs/design/starting_decks.md`): the balanced AI is more
   cautious than a person racing a 3-HP enemy, so a human should sit above that.
6. **Colorless cards were nerfed** (Banner 4, Rally 3, Mercenary Captain 2/3, Resistance Scout 1/2, Automaton 4/5) because
   on-curve bodies that fit any deck beat the Path commons that pay for abilities. Say if colorless should stay at the vanilla rate.
7. **Starting decks are 45 cards from turn one** (19 Infrastructure + 26). The tutorial's 3 picks make them 48; the 42-card waiver
   only remains for old saves. The deck lists are in `docs/design/starting_decks.md`; the sheet needs them as new rows (Part H).
8. **Encounter rules** (`data/encounters/modifiers.json`) are shown as icon + tooltip in the battle HUD and on the dungeon map's
   node info; a zone roamer's rules appear in its "wants a word" toast. Enemy intent is still never shown.
9. **The first zone's roamers sit near 60% for the AI at level 5** (Flexing Brute, Protein Shake Golem at 9 HP, 24 cards) against the
   normal-fight target of 80%. Thinning them further did nothing: the limit is the level-5 player (12 HP, two common pieces, starter deck
   plus a few commons) against Beefcake decks that the zone's own Pump It Up buffs, with Necrocrat entering exhausted. Options are yours:
   accept it (a human races better than the cautious AI), make the Gainlands' buff player-only, or expect level 6-7 there (more XP from
   Crosspath's fights).
10. **Part E stopped after the measured groups** (STEP 1 of the playtest brief): the late-game HP/size raises for the Dump, Rotheart, Capital, Castle, Lab, Swolympus and the arena were applied blind from the first baseline and then halved after the Test Kitchen measured 3-57% with the full raise. They are listed as UNMEASURED in `docs/design/balance_state.md` for the Part G run.

## Playtest v0.4.0 (Oct 18) - questions and safest choices taken

11. **Roamer floor**: the three Crosspath outskirts enemies sit at 84 / 90 / 85% overall at level 1, but the Necrocrat and Gourmand starters vs the Stray Gym Hound and Gourmand vs the Bin Raccoon are at 80-83% (the brief asked for 85%+ for any Path). Dropping HP further makes the fights trivial (4 HP already); left at the band floor. Tell me if you want them easier still or the Gourmand starter tuned instead.
12. **Audio bitrates**: 101-196 kbps (avg 126), 218 MB packed. Left as delivered (re-encoding to 96 kbps would save ~50 MB at an audible cost); say the word if size matters more.
13. **Deck Station racks**: the painted background has 5 cells along the top and 7 along the bottom; the ten slots use the top five and the middle five of the bottom rack (the two outer bottom cells stay decorative). The one-time "Building a deck" tip moved under the top rack so it never covers the slots.
14. **Pre-battle brief**: before each dungeon battle a short panel lists the rules in play (icon row + one line each) with a Continue button; it is skipped in screenshot runs and when a fight has no rules at all. If one extra click per fight is too much, make it a 1.5 s toast instead (`DungeonMapScreen._show_rules_brief`).
15. **Maren's welcome**: the cave-mouth conversation now plays at her door in Crosspath, with two lines reworded ("just down the hill" -> "walked yourself right into {town}"; "This way." -> "knock when you are ready"). Her door greeting (town.elder.first) still plays when talked to.
16. **Zone HUD pill**: the "+ buff - debuff" text chip in the zone HUD was the small text pill; it is the icon row now. The Capital's "Broken services" chip stays as it was (it already opened a panel).
17. **Build size 593 MB zip / 649 MB pck** (v0.3.1: 477 / 488): the zone kits (150 MB packed at a 1024 px BC7 cap) and the SFX pass are the growth. A 512 px cap on zone-kit prop textures would cut about 60 MB; left at 1024 to avoid a quality call without eyes on it. Say the word and `tools/art_import_rules.json` takes the cap.

