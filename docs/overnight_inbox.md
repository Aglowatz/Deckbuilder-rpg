# Overnight inbox

Leave instructions here for the overnight run (one per line). The run reads this file before each part and logs what it did.

Older open questions (Oct 17 overnight, the rebalance, the v0.4.0 playtest build) are in `docs/overnight/inbox_archive.md`.

## Overnight Oct 23-24 - yours to decide (the safest choice was taken)

1. **Boss entrances are a board intro everywhere** (Part 3): before every boss, lieutenant and gatekeeper battle the battle board
   shows letterbox bars, the foe's Bestiary portrait pushing in, a name card with a title, a music sting and the opening line
   (~3.3 s, any key skips; `data/encounters/boss_intros.json`). In Crosspath the camera also pushes in on the hero facing the foe
   (0.75 s) before the gatekeepers, the Restless Dead, Shiro and the Echo (Phase 2 cycle 5); the zones' elites and the dungeons use
   the board intro alone. Say if you want the world push in the zones too.
2. **Mercy moments** (Part 1): to keep the opening hour easy, the four gatekeepers' events are their real selves slipping through
   (Moss: "Did I thorn at you?" - you heal 3; Prudence stamps APPROVED by mistake - you heal 3; Brick's Hydration Break stands his
   units down; Fennel force-feeds you a biscuit). Several bosses end with a "faltering" -1/-0 at 25% (Clench "Master...?",
   Compostella "Please. The tree.", Primm "I only wanted it to be nice", the Restless Dead, the Automaton). Say if any of these
   should be a threat instead.
3. **Mortimer and the Itamae on seed 8100** measure 25 / 31 (19 / 31 with their scripts removed, so the seed, not the scripts);
   two-seed means 34 / 38. Mortimer was fixed in Phase 2 cycle 1 (Temp Agency +1/+1 -> +1/+0: 69 / 38). The Itamae did not move with 3 starting
   Ingredients or Elite skill: on seed 8100 Refusemancer and Necrocrat lose every game and Gourmand wins every game - a matchup
   question (the L16 reference decks vs his golems) for you.
4. **Primm's gauntlet** now clears 40% (B 33 / G 17 / R 42 / N 67; was 48%): Gourmand is still the weak Path here (inbox Oct 23).
5. **Card picks** (Part 4): every elite and boss win offers 1 of 3 cards themed to the foe's Paths (two-Path foes can offer their
   two-Path cards), never a Legendary (the bosses' prizes stay theirs), no Epics from elites before level 8; a repeat win offers 2
   mostly-Common cards. Side-dungeon bosses now offer a pick too (they gave none before). In the world (gatekeepers, town bosses,
   zone elites, the Quota rematch, arena tiers 2-3) it is a "VICTORY - choose a card" box after the fight.
6. **Three campaign slots** (Part 6): the existing save IS slot 1 (nothing moved: slot 1 is the old `saves/` folder; slots 2 and 3
   are `saves/campaign_2/` and `campaign_3/`). Each slot has its own autosave, backup and manual saves; New Game picks a slot,
   Continue loads the newest campaign, Load Game lists the three (Play / Other saves / Copy / Delete).
7. **Your real "Slot 1" manual save was being overwritten by a GUT test** (`test_legacy_sub_areas`) on every test run, including
   tonight's at 22:43 (it now shows as "Beefcake, level 1, The Proving Grounds"). The test now uses its own folder. If that slot
   held a save you care about, its older copy is gone; your autosave (Oct 23 10:14) and Slot 2 (Oct 17) are untouched.
8. **New first-time tips** (Part 5): face-down enemy traps, tokens, the fight's rule icons, scripted events. Players who finished
   the old tips (without pressing "Skip tips") will see these four once.

## Overnight Oct 22-23 - yours to decide (the safest choice was taken)

0. **NEW NAMES FOR VETO (Part 4, the duplicate names)** - the design-sheet characters keep theirs (Wren the resistance leader, Recycle
   Rhonda); the two game-only characters get:
   - **Wren Muckfoot** (the Verdant Dump's animal handler, Round Up the Herd) -> **Billie Muckfoot** (a billy-goat pun; she speaks fluent
     goat; the surname stays).
   - **Rhonda, Portal Ripper** (the Gainlands, Calf Cove) -> **Shredna, Portal Ripper** (gym slang: shredded).
   Neither name is used by any other character (checked data/, core/, docs/design/). Say a different name and it is a one-line rename.


Part 2 (dialogue features):
1. **First talks split at 3 boxes**: when an NPC's introduction plus their favour runs over three boxes, the first talk is the
   introduction alone and a toast says "<name> has a favour to ask. Talk again."; the ! stays up and the next talk is the offer only.
   Minigame hosts with a long introduction (Chet, Chef Flambe) the same: introduction first, the game from the next talk ("... is ready when you
   are"). Capital Wren's first talk is her introduction; her street insights come on the next talk. Say if you prefer one long talk.
2. **Already built on Oct 19 and kept**: the gatekeepers' freed lines (`gate.<zone>.freed`), Kyle's and Ectomund's freed lines, the
   Dump workers' freed barks, Maren's speech once per change of state. New tonight: Maren's short greeting now has a set per number of
   freed zones (`town.elder.idle.1..4`, three lines each, in turn).
3. **Agnes in the Hall**: a `.met` variant plays once you have met her at the front desk; the stranger version no longer says
   "If we haven't met".
4. **The Primm fight's lesson lines** quote only the leaders whose zones are free: phase 1 Flex (Gainlands), phase 2 the Grand Chef
   (Buffet) and Agnes (D.N.A.) - with one of the two free, the line keeps that one's lesson only - and the end Compostella (Dump).
5. **Freed barks in the Capital** (after Primm falls): the Showcase citizens, Wren, Kestrel, Captain Spotless, Rollo, Marlo and Old
   Fern. Fig Sly is untouched (black market). **Isla** only appears after the Capital is freed, so her barks were already freed-state
   lines; nothing to add. Widow Pell's barks are about her quest, not the regime, so they stay.

Part 3 (Path choice): each tile is the Path's name, its icon, three cards and a one-line plan; the old paragraph and playstyle appear
in a strip under the tiles on hover or keyboard focus, and a More button keeps the strip open. The intro line is shorter too.

Part 1 (balance) and the rest:
6. **Six encounter changes, no card changes** (balance_log.md, "Overnight Oct 22 - Part 1"): Prudence 16 -> 20 basics and no Red
   Tape head start; Moss 17 -> 19 basics; Baron Quadzilla gets "Max Pump" (+1/+1 for his units); the Drain Warden +2/+2 -> +1/+1;
   Calf Raise Crusher 14 -> 16 basics and 8 -> 6 HP; Squat Rack Squatter 14 -> 16 basics. Prudence's HP stays 12 (a test bounds the
   gatekeepers to 12-30 HP).
7. **Beefcake in the Rotheart** (Phase 2): the Overgrown Scarecrow is 44-63% for Beefcake (other Paths 83-100%) because "Rot" kills
   1-defense units every turn and Beefcake's cheap units are x/1. Your Oct 19 answer was "no change for now"; say if Rot should spare
   the player's side, or only hit units that took damage.
8. **Siphon alone is 0%** in the sim (with Elowen 58%): as designed in the Oct 21 brief - just confirming it is still meant to be.
9. **This PC's C: drive is full** (about 630 MB free after tonight's v0.4.5 export). `_screenshots/` holds 5 GB of older shots and
   `builds/` the v0.3.0-v0.4.4 zips (4.3 GB). I removed only tonight's own files. A second export or a big art batch will fail until
   some space is freed - say what can go.
10. **Video memory grows during a long session**: about 33 MB and 530 objects per visit to Crosspath (textures themselves level off
   at ~600 MB: those caches are bounded). Not fixed tonight - the cause sits outside the node tree and needs a bisect of the town build
   (next_up 2). A player who goes back to Crosspath 20 times carries ~0.7 GB extra; restarting the game clears it.

## Oct 21 story content + balance - yours to decide (the safest choice was taken)

Part 1 (the lieutenants):
1. **The live sheet was newer than the CSV snapshot.** data/source/dungeon_list.csv (Oct 11) had no S-PASTE row, a 13-node Lab "to be
   designed" and node 14 of the castle as a deck challenge. I read the live sheet through the Sheets connector and patched the snapshot's
   changed rows only (D-HOG/D-TTK/D-ROT/D-PC story text, D-PC node 14 = Plume's elite, S-PASTE), then re-imported. Excerpts:
   docs/design/sheet_excerpts_oct21.md. S-PASTE's type is "Side Dungeon" locally (the sheet says "Side Dungeon (lieutenant)", which the
   importer does not know).
2. **S-PASTE's reward**: the sheet leaves it blank and the card list is frozen (every unused unique card is taken), so the first win over
   Crumb pays a new relic, **the Colonel's Ladle** (gain 1 HP whenever a unit enters under your control). Each lieutenant pays a relic on
   the first win: Quota's Stopwatch (you always go first), Plume's Notary Quill (start with 1 Red Tape, max HP +2), Clipwell's Golden
   Shears (1 damage to each attacker). Say if you want cards instead (needs new sheet rows).
3. **Quota and Clipwell replace two elites** (the Regime Checkpoint Captain and the Rootbound Miller) with the same decks and rules,
   renamed. Their approved Bestiary pictures (BST-REGIME-CHECKPOINT-CAPTAIN, BST-ROOTBOUND-MILLER) are now unused.
4. **Clipwell's fight is in the Dump** (the Root-Choked Mill, the Rotheart's elite: she has trimmed the roots into a topiary of Primm), as
   your brief allowed; in the Capital she has a short scene at the Sick Patch after Old Fern's quest (the sheet's "regulation lawn"
   battle became a scene, so she is not fought twice). Quota is fought twice (the brief's Regime Checkpoint elite, and the sheet's
   Transit Yards rematch after Rollo's quest).
5. **Crumb is not fought in the Test Kitchen**: he inspects the Prototype Bay in a scene and leaves; the elite there is still the
   Unfinished War Machine. He is the boss of the Paste Works.
6. **Plume's ribbon-cutting** plays once, in the D.N.A., the first time you are there after freeing it (the sheet has him do it after every
   freed zone; one felt like enough). The other three zones get a short "the lieutenant fled to the Capital" beat from their freed leader
   or Basil/Bramble the first time you are back in them (old saves too).
7. **Why Elowen is at the castle gate**: she simply turns up ("Somebody has to watch the door while you knock it down"); it plays on the
   first castle run however many zones are free. Maren says only "her father worked in my laboratory, once" (no name: the Lab keeps the
   Siphon reveal).
8. **The Paste Works door** is a beacon on the shuttered stall at the Hungry Quarter's south-west corner (no new art). Marlo's second quest
   needs The Recipe Box done and the Buffet free.

Part 2 (Elowen):
9. **The Lab is the sheet's 16-node layout now** (it was a 14-node placeholder). Its map MAP-LAB is still the code-drawn placeholder,
   redrawn for the new nodes (`tools/make_lab_placeholder_art.gd`); the painted map is on the art backlog.
10. **Siphon's Protocols are softer than the sheet**: as written (Augmentation +2/+2, a Failed Experiment every turn, Extraction = 1 life
    and one Resource of each Path a turn, Containment +2) the fight was 0% alone and 13% with Elowen. Kept: Augmentation +2/+1,
    Replication every second turn, Extraction = you lose 1 life and he gains 1 (no Resources), Containment +1: **60-68% with Elowen,
    ~2% without her**. The solo fight is the sheet's "insanely powerful and unfair"; she is the chance. If you want the solo fight
    winnable: Replication every third turn gives 13% alone / 78% with her (balance_log.md, Part 2 table).
11. **Choosing the Protocol**: Elowen picks the one hurting most at the start of your turn (Augmentation when he has two units out,
    Extraction when you are at 8 life or less, otherwise Replication) and the battle HUD row "Elowen jams:" lets you switch any time on
    your turn. The sheet says "choose": say if it should ask every turn instead.
12. **Failed Experiment (T-25)** is a plain four-Path 3/3; the sheet's "one keyword of the experiment that created it (random)" is not
    built (no such script effect yet).
13. **"Tess"** is written literally in the Lab scenes (her nickname for the prince, from the sheet); it would not follow a rename of
    `{prince}`.
14. **Cave Mouth scenes**: Elowen waits a little to the side of the Forgotten Cave's mouth in Crosspath (the bible's "Cave Mouth outside
    Crosspath"), one scene per freed zone, played in order (an old save three zones in gets them on three visits). A toast says someone
    is waiting. They stop after the capture.
15. **If Elowen was not rescued** she confronts her father after the fight (she picks the lock of Cell 4 herself) and is free either way.

Part 3 (canon beats):
16. **The royal funeral is postgame**, in Grave Row through Old Hob (after Primm falls; old saves get it too). **Agnes does not pass on
    yet**: she asks Hob for one more week to hand over to Prudence ("Pencilled in."), so the D.N.A. keeps its head in the postgame. Say if
    she should go at the funeral.
17. **Old Hob's cameos** stand a few steps off each zone's hub (the first open ground) and in Grave Row; the 0-life line plays before each
    zone's own wake-up lines and the fee keeps its zone name ("Correction fee"...). The town roamers' losses (no wake-up) have no Hob line.
18. **Isla** comes home on your next talk with Brannoch after Primm falls (she takes after her mother's side: "You've got your mother's
    curls"), then stands at the gate.

Part 4 (balance):
19. **The L5 Necrocrat in the Gainlands is in band (81% mean)**, through four changes (balance_log.md, Part 4): Processing Time now only
    delays Necrocrat units costing 3 or more (game rule; the text says so); the Brute 4 HP / 11 basics and the Protein Shake Golem 3 HP, a
    gentler tool deck (no Kettlebell, Yeet or Pre-Workout) and the Aggressive AI (it walled every Path at ~65%); and in the sim only, the L5
    Necrocrat deck keeps its 1-2 drops and owns two Village Militia + two Watchtower Archers from General Packs. Every Path rose (80-84%);
    the roamer fights are short now (~5 turns). Say if Processing Time should stay as it was.
20. **The Echo gets a second rule for you, "First, Water": your Gourmand units get +0/+1** (the blue stream fed the Gourmands' first
    stockpot). Gourmand 44 / 56% on two seeds (was 44 / 36); no other Path changes. Cost -1 for Gourmand was too strong (80-84%).

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

## Oct 23 - Battle AI upgrade - yours to decide (the safest choice was taken)

1. **Gatekeepers at Normal skill.** Brick, Chef, Moss and Prudence are Elite fights (band 60-75%) played by a Normal-skill AI with 15% mistakes
   so the first hour stays forgiving (`AIPlayer.SKILL_OVERRIDES`). If you want them sharper later, remove the override and ease their decks instead.
2. **Slow starters vs engines.** With 12 games per cell: Chef 58 for N/G/R, Moss 50 for Necrocrat, the Restless Dead 31 / 25 for Necrocrat /
   Refusemancer (69 for Gourmand). The Graveyard's summon ladder (`GraveyardBoss.summon_stages`) is the next lever if you want those two Paths up.
3. **Primm.** His three phases now play at Elite skill (48% cleared overall; Gourmand 25%). Any +1/+1 on a phase made the gauntlet a wall under
   the new AI. A Gourmand-only ease would be a boon or a phase-1 tweak - your call.
4. **Chancellor Clench** played nothing for six turns in both reviewed replays (two-Path deck, Powerhouses without Ghost Towns): a deck-build
   question (the mixed basics split), not the AI. The fight still measures 56% in band.
5. **The dungeons smoke's Swolympus toast check** fails ("the Swolympus gate says it is sealed"): a Gainlands HUD text, not touched by this
   brief; last green Oct 17.
6. **Test Kitchen normals for Refusemancer** (25% before the fuel-hoarding fix) were not re-measured after it; the next sweep will say.

## Performance pass Oct 25 - yours to decide (the safest choice was taken)

(filled in as the night goes)

1. **A background screenshot batch was stopped by Claude Code for low system memory** (14:10, while idle). Nothing was wrong with
   the batch itself; from then on every Godot run was foreground and one at a time, as your brief says. If you start Claude Code with
   `CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP=1` long background batches are not reaped.
2. **Hub walk smoke: one pre-existing failure.** On the Necrocrat road the blocked-road toast reads "The bridge is drawn up on the far
   side of the gorge... Beat Brick Bronson to open it." (the Gainlands bridge text) where the smoke expects the Necrocrat gatekeeper's
   name. It fails the same with the build cache off (the old code path), so it is not from the performance pass; not touched.
3. **Two load-time caches were reverted** (Phase 2): caching the kit buildings' geometry and the hub's tree belt would take Crosspath from
   5.1 to 4.2 s, but with a warm cache the Crosspath walk smoke got stuck at one spot in the west (-15.4, 26.0). The cause was not found
   before the stop time; details and the bisect switch are in `docs/perf/perf_state.md` (Phase 2, cycle 2). Worth another look by day.
4. **Summary for the morning** (details `docs/perf/report.md`): Medium 3D areas 48-74 -> 65-85 fps, Low 62-109 -> 83-125, menus over the
   town 48-70 -> 136-184, loads Crosspath 8.2 -> 4.5 s and the Dump 8.6 -> 5.2 s, video memory after a full tour ~950 MB instead of ~1017.
   New setting: Settings > Display > Dynamic resolution (Auto = Low and Medium; it stayed idle on this PC). New check:
   `bash tools/perf_budget.sh`. Export estimate +16 MB (741.5 MB). No playtest export made, as asked.
5. **One visible-by-design change**: none. The only new UI is the Dynamic resolution row in Settings > Display.
