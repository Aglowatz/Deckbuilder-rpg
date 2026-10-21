# Overnight inbox

Leave instructions here for the overnight run (one per line). The run reads this file before each part and logs what it did.

Older open questions (Oct 17 overnight, the rebalance, the v0.4.0 playtest build) are in `docs/overnight/inbox_archive.md`.

## Overnight Oct 19-20 - yours to decide (the safest choice was taken)

Story bible (Part 4): `docs/design/story_bible.md` is now the one story reference and `docs/design/canon.md` the quick reference; every
contradiction found is in the bible's last section. These are the ones that need you. No game data was changed.

1. **The rescuer is Elowen Vey in the sheet, "The Rescuer" in the game.** The `{rescuer}` token still reads "The Rescuer" and her postgame
   lines deliberately withhold her name. Assumed: canon is Elowen Vey (Siphon's daughter, childhood friend), the token stays as it is until
   you say when her name is first spoken in game (prologue, a Cave Mouth scene, the Lab rescue?).
2. **Elowen's sheet arc is not in the game**: Cave Mouth scenes after each freed zone, Percival Plume having her taken back to the Lab when
   the Wanderer first enters the castle, and her ally token (T-24) in the Siphon fight. The game's Lab has a "Rescuer" boon instead.
   Assumed: the sheet is canon; nothing built until you schedule it.
3. **The four lieutenants (Quota, Crumb, Plume, Clipwell), S-PASTE, Old Hob as Death, the royal funeral and Isla's homecoming** are sheet
   canon with no game content. Assumed: canon, marked "[canon, not built]" in the bible.
4. **Species of the lieutenants and Isla**: the sheet's Notes say "Human." for Quota, Crumb, Plume, Clipwell and Isla; the Oct 17 run filled
   the blank species column with ferret, badger, peacock, hare and bear (`tools/npc_truth_input.json`, archived item 7). Assumed: human (the
   sheet) in the bible; game data untouched. Note Isla as a human daughter of a bear needs a line of story, or make her a bear.
5. **Two names are shared**, against the rule "no two characters may share a name": Wren (resistance leader) and Wren Muckfoot (the Dump's
   animal handler), and Recycle Rhonda and a Gainlands ripper called Rhonda. Assumed: kept for now. Rename the game-only two?
6. **[Done overnight Oct 19: npcs.json + npc_registry.csv say Brindle the Baker]** **The baker**: in game he is "Brindle the Baker"; `data/npcs/npcs.json` says "Bun the Baker". Assumed: Brindle (what the player sees);
   npcs.json needs the fix (`tools/npc_truth_input.json` + `node tools/npc_truth.js`).
7. **Small game-text fixes for the dialogue pass** (assumed: fix them, they are leftovers of retired names): two loading tips call the
   kingdom "Pathwork" (`data/loading/loading_tips.txt:35`, `:46`); the Alchemist's note is signed "Z.V." (Zinnia Vex) and calls Primm "THE
   USURPER" (`intro_story.tres:116`); Bellows is "she" in the Marshal blurb (`intro_story.tres:204`, he is a walrus with a moustache); Basil
   calls the fake Grand Chef "a man" (`gourmand_story.tres`, `npc.odalys.return`); Root Cause says Moss Mulligan's voice "isn't his"
   (`core/quests/quest_definitions.gd`, she is female); the arena prompt still says "Enter the Grand Clashatorium"
   (`world/town_scene.gd:962`); Kyle's lines say 2003 while his name says '09. **[Done tonight: all of these are fixed (Part 5 + text fixes).]**
8. **The Old Well secret quest's lore is now canon** (Part 6, story bible section 4): the one Wellspring rises under Crosspath; the Forgotten
   Vault was built over its source and locked by all four Paths together; it ran while one house held the four Paths together and failed ten
   years ago (when the cave's Hollow Well dried); it "waited for a hand that can hold all four". The quest starts at the well once one zone is
   freed. Say if the lore or the start condition should change. No rematch after the win (the well just hums). The Echo has no Bestiary entry
   and "The Old Well" speaker has no portrait yet.
9. **The Echo's difficulty**: +2/+2 for its units (one rule badge, "The Spring Remembers") brought it from 97% to 52% / 61% on two seeds at
   level 16 (`docs/design/balance_log.md`). Gourmand is the weakest Path against it (36-44%). The reward is the Phial of First Water (relic,
   legendary: multi-Path cards cost 1 less generic, +1 HP at the start of your turn), 250 gold, 300 XP.
10. **Dialogue that needs code** (Part 5, `docs/design/dialogue_pass_oct19.md` section 5): gatekeepers have no freed-zone lines (their victory
    lines were made to read true either way); first talks join intro + quest offer (7-9 boxes for Agnes, Bramble, Gerald, Wren, Ledgerbone,
    Chet, Flambe); Maren's four boxes replay on every visit; Agnes says "Oh, you're new" in the Hall even after the front desk; worker barks
    and Kyle/Ectomund have no freed variants; the Primm fight quotes the leaders even when fewer than four zones are freed. Say which to build.
11. **Druid Sorrel** speaks in the Dump (`core/zone/heap_growth.gd`) but is in neither the sheet nor the voice bible. Kept. Fenwick
    (`town.pack_vendor.first`) opens with "Psst. Over here.", the same as Fig Sly (hands off); say if Fenwick should change. "Thimble's Hats &
    Hems" was a leftover of the retired tailor name: now "Threadwell's Hats & Hems" (overnight cycle 28).
12. **Equipment screen** (Part 3): weapon on the screen left (the figure's right hand, facing you), relic on the screen right. On the old
    background the three spare painted frames get a parchment patch (their leader lines still show); the new UI-BG-CHARACTER switches the
    layout to our own frames by itself (`data/ui_config.cfg` `[character] background_painted_slots`; slot centres tunable there). The Level /
    Path / Deck badges moved into the stats panel as rows.
13. **Music** (Part 7): no track was rated 1-2 any more after the Oct 17 work, so the pass fixed five loops with silence at the wrap and
    re-rated Crosspath; MUS-TOWN-FREED (opens like MUS-TOWN) and MUS-DECK (7.7 dB step at the wrap) are 3s and are first in
    `docs/audio/music_generation_prompts.md`. Listen list in `docs/audio/music_audit.md` "Oct 19 fixes".
14. **Zone kit pieces** (Part 3): tomorrow's new Gainlands / Dump kit pieces import cleanly but the world keeps its stand-ins until a short
    wiring pass - schedule it?

## Daytime Oct 19 - yours to decide (the safest choice was taken)

1. **[Measured overnight Oct 19: with the boons 42-83% per Path, ~58% mean - in band, no change; see balance_log.md]** **Primm, three phases in a row, is unmeasured with the boons.** Without the four leaders' boons the sequence cleared only 4-21% per
   Path (one HP pool, as in the game); last night's "~50%" multiplied full-HP phases. The sim now adds the boons, but the re-run was
   stopped by Claude Code's low-memory guard (this PC had ~2.6 GB free) and I did not restart it on my own. Phase 1 has its boss rule
   (Royal Guard) but stays at 100% alone. To measure: `Godot --headless --path . -s res://tools/run_balance_sim.gd -- --what=sequence
   --filter=boss:primm --games=12` (~11 min). If it is still under 45%, the lever is phase 2/3 (lost there most), not phase 1.

2. **The Path choice is the longest read of the opening** (Part 3, `docs/playtest/onboarding_timing.md`): 279 words on one screen right
   after 18 lines of dialogue (~80 s if every tile is read). Kept as is; say if the tiles should show only the one-line game plan with the
   identity paragraph on hover.

## Overnight Oct 18-19 - yours to decide (the safest choice was taken; most important first)

1. **[Resolved Oct 19: keep as is]** **Items work once per battle** (Part 1). Each equipped item can be used once per fight (1 / 2 / 3 uses with 1 / 2 / 3 item slots);
   leftover charges carry to later fights. Before, a stack of Salves could all be drunk in one fight and carry anything. Say if you prefer
   "one item per turn" instead (`GameState.items_used`).
2. **[Resolved Oct 19: softened - only the first Necrocrat unit each turn enters exhausted; see balance_log.md]** **The Gainlands are nearly unwinnable for a level-5 Necrocrat** (17% vs both roamers in the sim): the zone's Processing Time debuff
   makes Necrocrat units enter exhausted. Players are now warned on arrival and pointed to the D.N.A. (cycle 5). Keep the rivalry as is,
   soften the debuff, or route Necrocrat players to the D.N.A. first?
3. **[Resolved Oct 19: no change for now]** **The Rotheart's normals stay at 54-63%** under its two rules (Overgrowth: every unit +1/+1 each turn; Rot: 1-defense units die at end
   of turn). A replay shows the sim player turtling while the foe board grows; a person who attacks does better. Keep, make Overgrowth every
   second turn, or make Rot one-sided?
4. **[Resolved Oct 19: boss rules - Shiro 48% (his rules were never applied), Bellows 56% (Heckling Crowd), Primm phase 1 Royal Guard; see Daytime item 1]** **Late bosses that do not respond to numbers**: Shiro (88%, his deck is traps), Grand Bellows (75-79%), Primm phase 1 (100%, but the
   three phases in a row come to ~50%). Stat rules (+N/+N for the boss's units) brought nine other late fights into or near band; say if
   you would rather raise their decks than give them rules.
5. **Starting decks changed** (Part 2, cycle 9): Necrocrat 2 Waiting Room, 2 Ghoul, 1 Red Tape Dispenser, 1 Corpseified Public Accountant
   (from 3 Notary Wraiths, 2 Requisition Forms, 1 Invisible Ink); Beefcake 1 Mill Worker, 2 Shot Putters. L1 spread 24 -> 13 points.
   The live sheet needs these rows (`docs/design/sheet_changes.md`).
6. **Rarity and gear moves** (Part 1): Grandma's Rolling Pin Uncommon -> Epic (+38 for Gourmand at L12), Trash Panda Tiara Epic -> Uncommon;
   Big Brain Beret -2 max HP; Cheater's Dice lost its -1 hand; Thorned Loincloth -2 max HP (was -5); Scroll of Insight draws 2;
   Alchemist needs 6 essence of two Paths (was 10).
7. **A listen pass**: the new sounds are existing bank events (save chime on a sent report, end-turn on an auto-ended turn, a soft alert
   with the zone Path warning), plus last night's open items (music leveller, boss stings, MUS-SHOP-GRISTLE's loop step).
8. **Battle speeds are 1x / 1.5x / 2x** (were 1 / 1.7 / 2.8) as asked; the old 2.8x is gone. Auto-end turn is off by default.
9. **Arrival card subtitles** ("Home of the Beefcake Path", "Where every Path crosses", "Seat of His Perfection", "Beneath Crosspath"
   for the town's dungeons): edit them in `ZoneTitleCard.SUBTITLES`.
10. **Dialogue presentation plan** (Part 5): open questions at the end of `docs/design/dialogue_presentation_plan.md`; 204 portrait images
    in `docs/art/portrait_expression_requests.md` (High 72 / Medium 87 / Low 45; 29 wait for a base portrait). Fig Sly is left out on purpose.

Resolved tonight: Oct 17 item 12 (floating exit labels - no 3D words at the zone exits since v0.4.0); the starting forest's purple
top-edge shapes (gone since the Opening Forest rebuild); Colonel Casserole and Prudence Pallor (their free starting units were the problem,
cycle 1); the spells-only arena (cycle 10).

## Overnight Oct 20-21 (playtest stability, v0.4.3) - yours to decide (the safest choice was taken)

1. **Arrival order changed to your brief's order**: level-ups -> reward boxes / quest notices -> Path warning -> Maren's welcome. v0.4.2
   had reward boxes before level-ups ("as everywhere else in the game"). Elsewhere (after a battle) the order is unchanged.
2. **Continue replays Maren's welcome** when a save was made in Crosspath before her welcome finished (`maren_met` unset, not a
   fast-forwarded game). This is what un-sticks the testers' v0.4.0 saves. Say if you would rather it never replays.
3. **Renderer default kept at D3D12** (see the morning report for why); Vulkan is one double-click away (`Start (Vulkan).bat`) and two
   bad launches in a row switch to the other driver by themselves (a one-time restart).
4. Nothing reproduces the Intel-only freeze on this AMD PC. The next tester log will say exactly where the game stopped (wayward.log).
