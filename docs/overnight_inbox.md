# Overnight inbox

Leave instructions here for the overnight run (one per line). The run reads this file before each part and logs what it did.

Older open questions (Oct 17 overnight, the rebalance, the v0.4.0 playtest build) are in `docs/overnight/inbox_archive.md`.

## Overnight Oct 28-29 - yours to decide (the safest choice was taken)

**Answered Oct 29:** 1 - checked in game: he is already his painted NPC set at the gate (`NPC-SPOTLESS` -> `SPOTLESS`, `_screenshots/oct29_spotless_gate.png`); he is not a roamer (the "spotless" enemy entry is only the gate battle), so the item was a mistake and nothing changed. 2 - keep the threat pause. 3 - keep the red-orange rim. 4 - later (still open).

1. **Captain Spotless as a Capital roamer** still walks as the 3D KayKit knight: the roster test wants every roamer's set under a `FOE-` key and
   there is no `SPR-FOE-CAPTAIN-SPOTLESS` set. His stationary NPC set (`SPOTLESS`) exists; say "use his NPC set" and he swaps to it (he would hop
   when he moves, like the other idle-only sets), or ask for a walk set in a later batch.
2. **Threat pose**: a painted roamer that spots the hero now stops for 0.45 s in its FRONT_TALK pose (the "!" above its head) before it gives chase.
   That gives the hero a beat to react; set `ZoneEnemy.THREAT_SECONDS` to 0 if you want the old instant chase.
3. **Roamer rim**: painted roamers get a warm red-orange rim (0.62, the NPCs have the key-light colour at 0.42) so they read on busy ground and as a
   threat. `ZoneEnemy.ROAMER_RIM` / `ROAMER_RIM_STRENGTH`.
4. **Hub walk smoke** fails one check (`bash tools/run_hub_walk_smoke.sh`, D.N.A. road): the hero walks straight into Old Hob the Gravedigger,
   who stands on the smoke's line, so the obstacle toast is not shown. Not tonight's code (no NPC or road changed); the smoke route needs a
   step round Hob, or Hob a step aside. Left as is.

## Overnight Oct 27-28 - yours to decide (the safest choice was taken)

1. **Necrocrat, Part 1** (`docs/design/balance_log.md`, "Overnight Oct 27-28, Part 1"): five bodies up one point (N-03 3/4, N-04 2/3,
   N-05 2/4, N-07 3/4, N-23 3/5) and one new Common, **N-38 Hazmat Intern, 2(N) 1/3 Toxic**. Level-12 round robin: Necrocrat 45% on the
   two-seed mean (was 20-33), nobody over 75%. Three seeds now (7000 / 8100 / 9200): Necrocrat 40 / 50 / 47 (mean 46). Two cells sit outside your lines on every seed:
   Necrocrat vs Gourmand 35 / 15 / 20 (the golem walls kill a 1/3 Toxic blocker first) and Necrocrat vs Refusemancer 55 / 80 / 60 (Toxic
   counters big bodies): **Refusemancer is the weakest Path now, 35 / 23 / 22 (mean 27; was 33-43)**. Options measured on seed 8100 and reverted: (b) one Hazmat Intern in the sim package: Refusemancer still 23, Gourmand cell 15 - no
   help; (c) Pink Slip to "attack 4 or less": Necrocrat 53 but the Gourmand cell still 15 (it helps vs Beefcake). So: (a) accept, or
   (d) a Gourmand-facing answer (resource denial in the package, or a Common) and a Refusemancer body pass as its own task. The Intern's name, flavour and image row are in `docs/design/sheet_changes_oct28.csv`;
   rename freely.
2. The Hall of Final Approvals reads Refusemancer 17-33% on its elites and Mortimer (6 games; the Oct 27 sweep had 25% on all three),
   every node still "ok" overall. Not tonight's change, but Refusemancer in the D.N.A. is the weakest Path-zone pairing in the game now.

3. **Roster renames, Part 2** (`docs/design/enemy_roster_oct28.md`): five roamers renamed in data (Stray Gym Hound -> Pantry Hound,
   Flexing Brute -> Quota Spotter, Zombie Intern -> Unpaid Intern, Possessed Scarecrow Druid -> Hungry Scarecrow, Compliance Officer ->
   Correction Officer); old saves keep their Collection Book counts and the old pictures through aliases. No frozen dialogue file names any
   of them. Revert any rename by removing its `Bestiary.RENAMED` line and the spec's display name.
4. **Not in the Bestiary and left so**: the Store Room Ghosts, Brisket and Sir Loin (gate golems that never fight) and the eight Undercroft
   arena foes (Gladiator Rookie ... the Wall of Fame). Adding them changes the Collection Book's 100% and the milestone rewards; your call.
   The three town roamers were added (they are the first open-world enemies and had no entry).
5. **Readable text in the world**: the Capital's gate guards carry floating labels "GATE GUARD (EXIT CONTROL)" (see `t2_after/capital_in.jpg`),
   which reads as signage against the no-text rule. They are UI name plates, not kit art; say if they should go.
6. **Cut-outs are optional**: every boss / lieutenant / gatekeeper entrance already shows its transparent dialogue portrait sliding in (shot
   `docs/overnight/oct27/intro_warden_cutout.png`). The 26 CUT-* rows only add the wider, hips-up framing and a pose; skip them if the
   portraits read well enough to you. Four entrances have no speaking character and keep the square (the Restless Dead, Baron Quadzilla,
   Colonel Casserole, the Wellspring's Echo).
7. **Maren's one line**: `town.elder.idle.4` ("Even the tortoises use them. I passed one this morning. Barely.") in
   `docs/dialogue/lines_to_update_oct28.csv` with a suggestion; optional.
8. **Unused approved art** is listed, nothing deleted: DUMP-BD-ROTHEART (sky baked in) is superseded by the sky-transparent row; the
   three retired-name Bestiary squares could be reused for new foes.

9. **Feats, Part 3** (`docs/design/feats.md`, Menu > Feats): 40 feats, rewards are gold and essence only - the game has no dye-unlock or title system, so the briefs "a dye or title" rewards were not built (a dye needs an owned-dyes concept in CosmeticState; a title needs a name-plate field). Rewards are paid once per account and only in a saving game (tests and smokes never pay). Feat group icons are rows of the art catalogue; existing icons stand in.

## Overnight Oct 25-26 - yours to decide (the safest choice was taken)

1. **The session dropped at ~00:06 and resumed at 08:05**: Parts 1 and 2 were done; the verification, the Tier 2 doc and the report were
   finished after the 8-hour window; Phase 2 polish was not started. Pushes failed intermittently overnight (DNS); everything is pushed now.
2. **Card review is proposals only** (`docs/design/card_review_oct25.csv`): nothing in the sheet, data or game changed. The 14 new cards and
   the three new opposing-Path hate cards (Desk Flip, Pest Control, Compliance Review) are suggestions; drop the hate cards if "opposes" is
   story only. The Black Market's eight cards were deliberately not reviewed for changes.
3. **Design Guidance "Buff" row reads `#ERROR!`** in the exported CSV (a broken sheet formula): worth fixing in the sheet.
4. **Height fog is Dump-only**: the forest camp and the Gainlands lake showed no visible change at their spots and were reverted. Other hollows
   can take the two keys (`fog.height`, `fog.height_density`) in their style file whenever one wants mist.
5. **Bounce colour strength**: `GroundLight.BOUNCE_AMOUNT` 1.2, reach 2.2x the shade band, `light.bounce` per zone (1.0 everywhere). It is
   deliberately subtle at the game camera; say if you want it stronger (the 3x shot in `f2_bounce/` shows the ceiling) or off in a zone.
   The first load of a zone decodes each kit texture once (Crosspath ~0.4 s of bake, cached for the session).
6. **Lantern shadows on Medium** cost 0.4 ms in the forest for a modest visible gain (the camp lantern sits on the ground); set
   `GraphicsQuality.lantern_shadows` to [0, 0, 2] to keep it High-only.
7. **SSAO on Medium dropped** (+2.3 ms on the square, 57.8 fps). **Vertex AO on the kit** and **ground decals** were already in place from
   the vertical slice and the painted-textures pass, so no new work there; decals could still be thickened per zone in a polish cycle.
8. **FSR 2 on discrete GPUs** is a rule with a test, not measured here (no discrete GPU on this PC); the first discrete-GPU tester should
   confirm Medium looks right (sprites under a temporal upscaler can ghost).

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

## Fixes Oct 26

1. **Shadow reach, Medium atlas** (Part 1): the brief suggested raising the Medium shadow atlas to 2048. Measured: +0.5 ms in the Capital
   (57.6 vs 60 fps) and no visible gain round the hero (2x crops), so Medium stays at 1024 with two cascades. Say if you want 2048 anyway.
2. **Capital inside at 60** (Part 1): this laptop ran 10-15% slow today; the Capital gate spot was 59.8 fps BEFORE the change (70 last night)
   and 58.5-60.4 after (interleaved A/B: old 61.2-62.8, new 59.5-60.4). Every Medium avg_ms budget line is met. Safest choice taken: keep the
   reach (the brief's goal) with the two cost cuts; if Capital frame rate matters more, lower `StyleRig.SHADOW_REACH["capital"]`.
3. **Low has no sun shadow** (Part 1): the brief said Low stops at 26 m; in the code Low has never had a sun shadow (`shadow_detail(LOW)` = 0).
   Adding one would not be "modest", so Low is unchanged.
4. **Far shadows change the look** (Part 1): with the sun behind the scene (Gainlands, yaw from the far side) the camera-facing cliffs and the
   gym hall's front now sit in shadow at the far end too, as the near ones always did (`docs/art/graphics_tier1/fixes26_p1_after/gainlands.jpg`).
   Physically right and consistent; if the far plateau should read brighter, raise that zone's `light.shadow_opacity` lightness.
5. **Volume** (Part 3): the cause was the slider curve, not the routing (`docs/audio/volume_fix_oct26.md`). The fix changes how the sliders
   feel: 2 dB per 5% step, 50% = -20 dB. Old settings files are converted once to the same loudness (your file on this PC now reads 95 / 90 /
   95%). If you meant something else by "not working" (no sound at all, one sound ignoring its slider), tell me which sound and where.
6. **Gamepad smoke with the DualSense plugged in** (Part 3): a real controller on device 0 overrides the smoke's simulated stick, so the stick,
   prompt and Controls-page checks fail with or without today's change (same 4 failures on HEAD). Unplug the controller to run
   `tools/run_gamepad_smoke.sh`; the held-stick repeat on sliders could only be verified for the D-pad for the same reason.

## Fixes Oct 27

1. **A repeat gatekeeper win still offers two cards** (Part 1): the brief says the pick "always offers 3". The first win of every gatekeeper,
   elite and boss now always offers three (a short pool fills from the Path's other rarities, then Colorless). A rematch of an already-beaten
   gatekeeper keeps the designed smaller pick of two (Overnight Oct 23, `RewardPicks.REPEAT_COUNT`). Safest choice: unchanged; set
   `REPEAT_COUNT = 3` if rematches should offer three too.
2. **Crosspath Medium draw calls 847-850 vs the 840 line** (Part 1 checks): the same on the code before today's change (850), so it predates
   Fixes Oct 27 (likely the Oct 26 shadow reach's far-cascade draws; Crosspath was not among the six lines raised then). Frame time is well
   inside its budget. Safest choice: budget left as it is, flagged here; raise the Crosspath Medium draw-call line to ~1020 (x1.2) if you agree.
3. **Starting-HP gear does nothing in dungeon runs** (Part 4): a run's fights start with the HP carried from the last fight, which replaced every
   "+N starting HP" modifier. Fixed for the run's own boons (Primm's Castle "Unreflected", +2 HP at the start of each fight, spent in that fight).
   Three pieces of gear carry starting HP (expansion gear: +2, +1, and -3 on the +2-attack piece) and still have no effect inside dungeons - turning
   that on would change dungeon balance (the -3 piece would start hurting), so it was left as it is. Say if gear should count in dungeons too.
4. **Signs on posts in the open zones** (Part 3): a signboard on its own post standing on grass beside a path is accepted (a post beside the path);
   only posts ON a path band moved. Their posts have no blocker (the hero walks through a 0.1 m post), as before.


## Cards Oct 27 - yours to decide (the safest choice was taken)

1. **Every review row was applied** (no "Card Review Oct 25" sheet export in `data/source/`), the three opposing-Path cards included.
   Final Notice went in at **1(N)(N)** (3 energy) instead of the review's 2(N)(N): measured on the level-12 round robin (balance_log.md,
   "Cards Oct 27, Part 1"); 3 is inside the Design Guidance's targeted-destroy rate. Say if you want it back at 4.
2. **Cannon Fodder 2/1 made the cave harder** for Beefcake / Refusemancer (76-82 / 72-82% over two seeds). The cave foes carry one Fodder
   fewer and one more basic each (`TrialOfTheHollow.enemy_recipe`); cleared runs are B 90 / N 94 / G 90 / R 85 (two-seed means). The
   alternative was leaving Fodder at 1/1.
3. **The level-12 round robin**: Necrocrat 23 -> 20-33% (mean 27), Gourmand 77 -> 73. The 23% was mostly the sim's expected-player model
   (its Necrocrat deck cut its own bodies; fixed in `ProgressionModel.CUT_ORDER`); vs Gourmand's golems it stays 10%. The next lever would
   be the Necrocrat Commons' bodies, which the brief kept off limits - say if you want that pass.
4. **Mortimer and Betty Bones are ENEMY-ONLY** (the brief's CEO-No rule), so the Hall of Final Approvals now pays **Mass Layoffs (N-29)** and
   the Waiting Room **The Department of Final Approvals (N-31)**; the dungeon list CSV, `dungeons.json`, the reference decks, the Lab's Siphon
   deck and the Vault Warden's follow. A save that already owns them keeps them (grandfathered). Chancellor Clench (NB-16) and Mr. Tiggle
   (P4-03) are enemy-only too; Clench's deck now carries his card.
5. **Boss-pick chase cards** (`DungeonSignatures`): Iron Filing Clerk (Clench), Resting In Peace Clause (Mortimer), Chef de Golem (the
   Doppelganger), Mount Trashmore (Compostella), The Harmony Engine (Primm) - offered in the boss's pick every clear until earned. The Paste
   Works pays The Infinite Pantry, the Lab the Champion of the Four Paths (both paid no card before). Two consequences worth a look: every
   Gourmand Epic is now a prize or the Black Market's, so the Buffet shelf's Epic tier only shows what was earned; the Necrocrat / Beefcake
   pair has no craftable Legendary at the Alchemist.
6. **REWARD-LOCKED replaces `not_in_packs` for the prizes**: once earned they may show up in packs and on shelves at their rarity (the brief's
   rule); before Oct 27 they never did. The Legendary leaders (The Big Unit, the Grand Chef, Compostella) included - an extra pack copy
   converts to essence at the cap of 1.


## Art import Oct 29 - yours to decide (the safest choice was taken)

1. **Row numbers**: the brief calls the delivered rows "#87-164"; in `art_batch_oct28.csv`'s own order they are rows 75-152 (SPR-PRIMM is row
   75) plus the twelve skipped expression rows 153-164. Same set of IDs; `docs/art/art_status_oct29.csv` lists all 90 by the CSV's row number.
2. **New stills have no captions of their own** (dialogue freeze): each plays behind its scene's existing narration instead of as a separate
   captioned still like the original seven. If you want captions, they would be new `still.<name>` keys.
3. **Backdrop strips are mostly above the play camera.** The torch-line ridge, Crosspath's horizon and the Capital's castle / wall strips
   are in the scenes but sit at the top edge or above the frame at the default camera; the forest's torch line is hidden by the canopy.
   Lifting them (or adding them to the Cinematic camera's view) is a one-number change in `tools/kit_looks_oct29.js`.
4. **The throne dumpster** stands on the throne's top tier behind the raccoon king; from the approach it shows mostly behind him at the top of
   the screen. Alternative: replace the 3D throne's top tier (king and bin) with the painting.
5. **Unused sheet parts**: TOWN-SHEET-FREED-BANNERS -05/-06 (two cream crest banners: maybe for all four freed, or the postgame),
   GAIN-SHEET-FLOATING-ISLANDS -04..-06 (rope pieces), DNA-DEC-FORMS -03/-06, CAPI-DEC-LOST-PROPERTY -02..-06 (the hooded-face versions could
   show once the Wanderer knows who they are; the defaced one could replace the red-cross overlay).
6. **D.N.A. clutter cap** in `tests/world/test_dna_slice.gd` raised from 40 to 50 pieces (tonight's pieces made it exactly 40; the lobby shot
   reads clear).
7. **Capital outskirts Medium p99** is over its budget (27 ms vs 24.3) with and without tonight's changes (A/B: 27.3 / 27.0 ms; averages 15.5
   ms). It predates tonight; budget left as is.
8. **Feat icons**: ten groups share eight pictures (the four one-Path groups all use PATHS, Dual Path uses MIXED); an unearned hidden feat
   shows SECRET.


## Overnight Oct 29-30 (economy + equipment + hats) - yours to decide (the safest choice was taken)

1. **The XP curve runs far ahead of the progression model.** With the XP the timeline really pays (quests 3,000, gatekeepers, roamers, dungeon
   nodes), the economy model's expected player is L8 at the Gainlands (model: 5), L12 at the House of Gains (7-9), L18 at the Test Kitchen
   boss (14), L25 at the Dump freed (19) and L30 at the Capital (18-20); `ProgressionTable.POSTGAME_STEP` is 27 (the docs say 40), so levels
   21-30 together cost less XP than 17-20. Not touched tonight (it moves HP, hands and caps for every fight); the level track's gold was
   front-loaded instead so the money lands where it is needed. Say if you want the curve re-based (`tools/economy_model.gd` shows the levels).
2. **Primm as a three-phase sequence is 82 % with the real L22 gear** (B 58 / G 79 / R 92 / N 100, 12 runs per Path; 48 % on Oct 23): the
   expected player now wears the Glass Jaw Gauntlets (+2 attack) and the Crown of Mild Hubris (+1 attack, after the +1/+1 version pushed the
   phases alone to 92-100 %). Levers: the phases' HP (36 / 32 / 32), a stat rule on Primm's units. Not retuned blind; your call.
3. **The House of Gains reads 5-10 points harder** with the Colorless-only Wicked Dagger at L7-9 (two seeds: normals 69-96, the Honor Guard
   46 / 52 vs its 60-75 band, Clench 38 / 42). Nothing under 35 %. The next lever is the Honor Guard's basics; left as it is.
4. **The late sink**: from the Capital on every profile held 2,000-6,000 gold with only Gilded / Prismatic packs and the Royal Mantle to buy.
   Phase 2 added a **reward-pick reroll**: a world pick (gatekeeper, zone elite, town boss, arena tier 2+) can be rerolled once for 40 + 10 x
   level gold (L5 90, L12 160, L22 260; `Economy.reroll_price`), a button under the three cards; the reroll never counts as another win.
   Dungeon picks reroll the same way (a "Reroll (N gold)" button beside Skip on the rewards screen; the main bosses' chase card is kept in
   the fresh set; never in the tutorial's first run). Say if you want it removed or priced otherwise.
5. **Quest gold and XP were left alone** (core/quests is in the dialogue freeze); quests pay 3,500 of the ~19,600 one-time gold. Chests and
   feats were left too (already tiered). Selling, an inn, rerolls and repairs do not exist, so there is nothing to price there.
6. **Binding Chains measured +17 alone at level 12** (6 games per Path, +-12 noise; the Reckless Tonic +13 after its 6 -> 5 HP change, the
   Hearty Pie +13). A one-use bounce is a real tempo play; left at the strong band (60 gold). Say if the 10-point rule should bind here too.
7. **Zone fees** (15-20 on waking at the hub after a loss) were left: a loss already costs time.
8. **The Gainsmith's Lifting Belt and the Spotter's Barbell are Beefcake-only now** (they are the Gainlands' puzzle and quest prizes); a
   non-Beefcake player gets a Path piece from the first zone, like the Bandolier. Alternative: keep them Path-neutral with a drawback.
9. **Hats**: the preview was never different from the world (same anchors, checked cell by cell); the hats sat high from the side and behind in both,
   fixed in `fit.json`. Art itself: the Leaf Crown's back half draws over the hair (a ring painted as one card; known), the Chef's BACK view is
   painted 40 % larger than its FRONT and the Wizard's SIDE view 17 % larger (the fit scales them back; a redo could draw the five views to one
   scale). No hero TALK frame exists, so hats have no talk cell to check.
10. **The Forgotten Vault's two normals read 54-67 %** (band 80-100; two seeds, `oct29_S-TOWN*.md`) at level 6 - with the same gear the model
    wore before tonight (the Dagger is worn from 6 now, Colorless-only). The Automaton (its boss) is 50-63 %. The foes live in
    `dungeon_content.json` (frozen tonight); the usual lever is their basics count. Left as it is.
11. **Baron Quadzilla** (the Iron Cave boss, L8) was 33 / 31 % on two seeds with the Colorless-only Dagger (45 / 52 on Oct 22 with the old +1 to
    all); his "Max Pump" is +1 attack now instead of +1/+1 (29 / 46, mean 37, Refusemancer 8-42). If that is still too hard, his HP is the
    next lever (dungeon_content.json, frozen tonight).
12. **The late game is easier with the prizes stacked.** The expected player now wears the Glass Jaw Gauntlets (+2 attack) and the Elastic
    Waistband (+1/+1) together from L16 (both first-clear prizes, both Epic, cap 2 from L13) and the Crown (+1 attack) from L22 - the old
    model wore the Dagger and the Flamethrower, so the late fights were tuned against a weaker player. Measured: the Raccoon 92 -> 46 (rule
    +2/+2), the Grate's Spotless 88 -> 73 (rule +4/+3), the Ancient Spotter 79, the Lab's Failed Experiment 94, the castle elites 83-88,
    Spotless the roamer 92, Primm's sequence 78. The sim's AI ignores the Waistband's two-cards-a-turn and the Gauntlets' -3 max HP the way a
    human cannot, so these read harder in play; say whether the rest should be tuned to the sim or left for playtests.

## XP pass Oct 30 (XP curve + recheck + v0.4.8) - yours to decide (the safest choice was taken)

1. **The curve is a step table now** (`ProgressionTable.EARLY_STEPS`, then 325 + 10 x L to 20, then 500 + 35 x (L - 20)). L5 stays at
   300 XP (the store room ghosts' hand-in), L6 costs 280 (was 150) - the one visible jump; levels 2-5 stay quick. Expected player:
   L5 Gainlands, L8 House of Gains, L11 Hall, L14 Test Kitchen boss, L18-19 Dump freed, L21-22 castle, L25 after the postgame; the
   thorough player ends near L28 and L30 (13,750 XP) needs grinding. Say if L30 should be reachable by the thorough player.
2. **The level track's late gold** (L26-30, ~950 gold, 3 packs) is no longer reached by the expected player (2,340 of 3,090). The
   economy targets still hold (98 % spent, no droughts or hoarding); left as it is. Alchemy dropped out of the expected profile's buys
   (a luxury it reaches later now).
3. **The model's in-dungeon level offsets** (elites +1, bosses +2) are gone: one dungeon pays less than a level before its boss, so the
   sim meets bosses at the dungeon's level (Primm +1). Bosses read 1-2 levels "harder" in the sim than before tonight for that reason
   alone (Part 2 measures it).
4. **Primm's three phases as one HP pool: 78 -> 68 %** (pooled over two seeds: Beefcake 32, Gourmand 65, Refusemancer 78, Necrocrat 98).
   The spread is a Path matchup: every Path-neutral lever (phase HP, a stronger phase 3, a buffed mirror, extra mirror draws, a third
   Militia in phase 1) cut Beefcake as fast as the average while Necrocrat kept winning (Standardization's 3/3 makes its small units
   bigger and Beefcake's big ones smaller). Kept: HP 44 / 42 / 42 and phase 3 +2/+2. Reaching 45-60 with no Path under 35 needs a
   Path-aware rule (e.g. Standardization at 2/2, or something Necrocrat's recursion cannot ignore); your call.
5. **Refusemancer vs the Quota Spotter at L5** pools to ~71 % over three seeds (the other Paths 80-90; the zone 81-91 %). The Spotter has
   4 HP already; one more basic gave a mixed result and was reverted. The level did not change there, so it is the starting-deck matchup.
6. **Path matchups at the bosses** (overall in band): Gourmand 13-20 % against Clench at L8, Refusemancer 8-17 % and Necrocrat 17-33 %
   against the Doppelganger at L14, Beefcake 10-50 % against Compostella - each Path is weak before its own zone (`ProgressionModel`
   gives it its zone's cards only after that zone's boss).
7. **Left a little over the band**: the Ancient Spotter 67-69 % (HP does not move it), the Grate's Spotless 66 %, the Hive 71 / 81, the
   Plume / Clocktower 78. The Path-ology Lab was not re-measured (postgame; the expected player is L25 there now, the model said 26-28).
8. **The Doppelganger (Test Kitchen boss) sits ~35 % at L14** (43 / 27 on two seeds; Gourmand 67-80, Necrocrat 17-20, Refusemancer 0-20).
   Its "Perfect Copy" +1/+1 is what bites, and the mask script (dialogue freeze) removes that rule by name and says "its units lose
   +1/+1", so it stayed. At +1/+0 it read 42 / 44 - if you change the script's line, that is the fix. Siphon (the Lab) went 44 -> 48 HP
   to stay above Primm's new first phase (test invariant); with Elowen 79 %.
9. **Captain Spotless's figure**: his zone-enemy entry (`CapitalEnemies.SPOTLESS`) now names the SPOTLESS NPC set, so wherever he is
   drawn as an enemy he is the painted captain (idle-only, so he hops). He does not roam today - the Capital never spawns him; at the
   gate he was already the painted sprite (`_screenshots/oct30/spotless_gate.png`). The two 3D knights flanking the gate are the unnamed
   gate guards (`guard_in_1/2`, `guard_height`, `guard_queue`): say if those should wear a sprite set too (none exists for them).
   The other Part 3 calls stand as asked: the reroll and its price, the Belt / Barbell Beefcake-only, Binding Chains untouched.

## Fresh eyes Oct 30 (critic -> triage -> ten fixes -> second look) - yours to decide (the safest choice was taken)

1. **The cave beacon** (`StartingAreaScene._show_cave_beacon`): the Opening Forest pass (Part C) removed the old beacon column on purpose
   ("the cave mouth itself is the landmark"). The critic walked into the treeline six times and never found the arch, so the gate now gets
   the quest objective's chevron + ring, the HUD edge pointer, the minimap objective dot, and the clearing's map is revealed, once the
   Rescuer has gone. Say if you would rather keep the clearing marker-free and only add the direction to the treeline line
   (`docs/dialogue/lines_to_update_oct30.csv`).
2. **The reward pick starts on the middle card** (Take is the live gold button at once; Skip stays plain). The critic skipped a first reward
   because Skip looked primary. If you prefer "nothing chosen until the player clicks", revert `RewardsScreen._select(1, true)` in `_ready`.
3. **The HUD Menu lists Glossary, Feats and Settings** (they open the pause menu's pages). They sit under Wardrobe without icons (no
   ICON-UI-* art for Glossary / Feats). Say if they should go elsewhere or get icons.
4. **"Esc hangs the game" was the driver** (its timers did not tick while the pause menu paused the tree). The pause menu works; the first
   critic could not reach Feats / Settings through it, so the Feats / Settings / Glossary findings came through the HUD menu instead.
5. **The first duel's losses** in the critic's report were the simple built-in pilot (`BattlePilot`) and a hand turn held by the tutorial tip
   deadlock (fixed). The sim says the cave is 80-97 % per Path. The critic's deeper point - 45-card starters with ~19 Infrastructure clog hands,
   one Infrastructure per turn - is a deck design question (D44 / rebalance Parts C-D): nothing changed; a sim study of a 15- or 17-Infrastructure
   starter is the next step if you want it.
6. **Not reproduced**: the map not closing with M / X in the forest (three driver runs: M closes it), and the sticky dungeon node tooltip.
   Both may have been side effects of the black-world bug in the critic's session. Say if you have seen either.
7. **Dialogue rewrites** are in `docs/dialogue/lines_to_update_oct30.csv` (treeline lines naming the direction, a shorter wake-up, the
   Rescuer naming Crosspath and Maren, a defeat recap line); art: a night version of the wake-up still.
8. **The play-script driver** (`bash tools/play.sh`) is a new tool: anyone (or any agent) can play the real game from a text script and
   get screenshots + the visible text. `docs/play_script.md`; the critic briefs in `docs/review/`.
9. **Left as recommendations** (design calls): hand cards' rules text below the edge (a smaller hand scale or a fan), the zone HP widget over
   the landmark, a Tutorial toggle, a Settings scrollbar, a defeat recap, the day still over the night scene.
10. **The second critic's new problems** (`docs/review/fresh_eyes_second_look_oct30.md`, not fixed tonight): confirmation popups ("Go in?",
    the Well's Reveal / Continue, the duel's Got it tips) ignore the E key the HUD advertises as interact (a click or Enter is needed) - the
    one it would fix first; the Path screen's "More" only renames itself to "Less" (its text did not change in the critic's shots); the
    treeline self-talk stops the walk until dismissed; tooltip boxes overlap the "cannot play" toast, the card preview and the player plate;
    VICTORY! can draw under a hover tooltip for its first frames. Say which to take next; the E-on-popups one touches PopupFrame /
    ConfirmDialog / TipPanel input and is a half-day with the pad tests.

## Fresh eyes round 2 (Oct 31: second critic's problems -> safe recommendations -> starter study -> mid-game critic) - yours to decide (the safest choice was taken)

1. **E answers popups now** (`ConfirmDialog`, `TipPanel`, the Well, the duel's info bubbles): a confirm press (E / Enter / Space / pad A) presses
   the focused button, so on a dangerous question (Delete, Discard, Retreat) E says Cancel, like Enter. In the duel only E and Enter press
   "Got it" - Space stays To Combat. Say if E should be the primary button everywhere instead.
2. **The Path screen's More** now adds the Resource and the whole 45-card starting deck in words (every named card with copies). If that is
   too much text for the choice moment, the shorter form is the counts line alone (`ElementChoiceScreen._more_text`).
3. **The treeline self-talk is a speech bubble** over the hero (no dialogue box, the walk never stops); the nudge back toward the cave stays.
   The lines are unchanged (freeze). The second line still fires once at the cave mouth itself (the gate counts as an edge) - harmless now.
4. **The hand is drawn compact** (0.58 instead of 0.68, centre 950): the whole card is on screen and its rules text reads without hovering.
   `--hand_style=classic|fan` on battle shots shows the alternatives (`docs/review/fresh_eyes_fixes_oct31/hand_*.png`); the fan overlaps the
   text bands and the classic cuts them. The hover lift (0.86) is unchanged. Revert = `BattleBoard.hand_style = "classic"`.
5. **Defeat recap**: a "What beat you" box on the result panel (biggest damage source in numbers + one tip chosen from the fight: missed
   Infrastructure drops, cards left in hand, a repeat attacker, an unspent Resource, else rest/heal). Wording is mine; say if you want it
   in the voice bible's tone or shorter.
6. **Settings > Text > Tutorial tips** on/off; off hides the duel bubbles and the screen tips without marking them seen. It lives under Text
   with the battle options; say if it belongs under Accessibility.
7. **Starter decks stay at 19 Infrastructure** (`docs/design/sim/starter_infra_oct31.md`): 17 / 15 cut flood turns but add dead turns and
   cost 1-2 cave points on three Paths. Levers that do not cost tempo if the flood feeling matters: a cantrip Common as the fill, or a
   mulligan rule that keeps 2-3 Infrastructure.
8. **The Well's wording** "1 of the 5 cards was Infrastructure; 2 were needed" (verb agreement) - a text change in code, not a dialogue line.
9. **The mid-game critic's snapshot was too weak** (cave never cleared, bare starter at L8), so its top finding (Sable sells nothing) and
   the empty quest log are artefacts; the snapshot script now sets `trial_cleared`. A rerun of `critic_brief_midgame_oct31.md` from a
   snapshot made by the story bot (real progress, a built deck) would give a fairer mid-game score than 5.2.
10. **Boss stalls** (Mortimer 30/30 and Vivienne 26/26 after ten turns with the bare starter): say whether a soft clock (e.g. a late-turn
    rule in boss fights) or an AI preference for units over a fourth Tool should go to a sim pass.
11. **Left as recommendations**: names on the town map + a dungeon-entrance icon + "Where to?", unlock hints printed on locked gear slots,
    "Click again to go" on dungeon nodes, a banner when the HP pool changes, the long boss nameplate wrap, fewer Test Kitchen stills
    (dialogue), D.N.A. lobby dressing (art).
12. **One Continue rule** (`ConfirmKey`): E / Enter / Space / pad A now press Continue on the pre-fight rules card, event results and
    announcements (Part 1 did popups, tips and the Well). Story stills already advance on E via their dialogue box; the pack opener on
    confirm. Say if any screen should keep Continue mouse-only.

## Overnight Oct 30-31 (eight improvements + v0.4.9) - yours to decide (the safest choice was taken)

1. **Controller sprint took the left-stick click**; the camera zoom's pad default moved to Share/View (`Keybinds`). Rebindable in
   Settings > Controls. Say if you would rather keep L3 on the zoom and put sprint elsewhere.
2. **Sprint speed 1.65x** (`TownPlayer.SPRINT`); a controller click latches it until the hero stops. Always sprint is off by default.
3. **Fast travel from the map** goes straight to the station (no Rip cutscene; the operator's lines still play at the station when you walk
   up). A freed zone now counts as a reached station even if its station was never walked past. Say if map travel should only work
   standing at a station.
4. **The goal pointer shows two goals** (the tracked quest + the most recent quest of the other kind). If two is noise, `goal_targets`
   can return only the tracked one; the setting already turns all of it off.
5. **Entering a zone tracks that zone's main line** (`Session.begin_zone_visit`). A player who tracked a side quest on purpose loses that
   choice on entering a zone (the side quest still gets the blue marker).
6. **Beginner tips are skipped past level 5 or a freed zone** (`TutorialLayer.BASIC_STEPS`). A brand-new player is unaffected; an old
   save that skipped them never sees them.
7. **Cover names** (`SpoilerFree`): the Doppelganger's plate reads "The Doppelganger" (its sheet name minus "(later named Escoffina)");
   the speaker label of the boss intro is dialogue data and unchanged. If the plate should read "Grand Chef Escoffina" until the reveal,
   that needs a reveal flag per NPC.
8. **Esc skips a story scene / cutscene seen before** (new save flags `scene_seen_<id>`, `cutscene_seen_<id>`; scenes seen before tonight
   count from their next viewing). Say if Esc should skip first viewings too (with a confirm).
9. **Vendor reach 2.8 m** (was 1.8) in town and zones; the Secret Dealer, the Alchemist and the Capital's dealer unchanged.
10. **Loudness**: 21 events moved by up to 4 dB toward their category's median (deaths and big spells a little quieter, quiet UI
    backs a little louder). The two hover ticks, `sprint_start` and `sign_read` exempt. Revert = `git checkout pre-overnight-oct30b --
    data/source/sfx_events.csv` + `node tools/sfx_build.js bank`.
11. **Dungeon maps now have a quiet ambience bed** (they were silent under the music by an earlier choice). Say if the map should stay
    music-only.
12. **Loading**: only the return to town improved. The zones' builders (the Dump 2.5 s, Crosspath's square and hub scenery 2 s) are the
    next lever, via the build cache with a cold and a warm walk smoke per cached piece.
13. **Boss nameplate wrap** ("Primm - Phase Standardization" runs under the heart): a longest-word fit was tried and had no visible effect
    (the rendered plate is wider than the measured label); reverted. Needs a look at the art plate's label sizing.
14. **Feats on bot-made saves**: "Free the Gainlands" was not credited on the story-bot snapshot (flags set directly); real play credits it.
    A load-time re-check of zone feats would cover old saves too.
15. **The critic's runs 22:20-22:40 loaded untested drafts** from the working tree (my mistake: drafts should live in a worktree while a
    critic plays). No script errors appeared; findings are about the shipped game.
16. **Frame budget, 1% lows**: the v0.4.9 run has 14 area-qualities over budget on the 1% low only (averages fine), measured while the PC
    ran out of memory (Claude Code stopped the run; its probes finished). The Oct 29 run had 7 over the same way. Worth a quiet re-run
    (`bash tools/perf_budget.sh frame`, nothing else open) before sharing: if the Deck Station (21 ms vs 14) or the zones stay over, the
    suspects from tonight are the Deck Station's curve / shape refresh and the goal pointer's second marker.
