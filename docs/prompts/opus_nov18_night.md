# Overnight Nov 18-19 (Opus, about 10 hours): the story flow after each zone, Alembic, signature cards, dungeon choices, the Arena, world fixes, a playtest build

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner is asleep. **This build goes to his playtesters in the morning.** His screenshots are in `docs/overnight_shots/nov19/ref_*.png`.

Read first:
- the top of docs/overnight_report.md ("Nov 18 evening") and docs/overnight_inbox.md;
- docs/writing/story_bible_v2.md;
- **docs/owner_backlog.md** (future work; don't start any of it tonight unless this brief says so; add to it).

Run `git status` first; if anything is uncommitted, run the tests and commit it. Log questions under "Overnight Nov 19". Tag `pre-overnight-nov19`. Work in this order; it's the priority order. If time runs short, finish the part you're on, skip to Part 11, and list what's left.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`. If the guard stops a background run, finish it in the foreground with `--from=N --to=K`. Tests run under the save guard.
- Commit and push after each part. No public upload.
- Shots in docs/overnight_shots/nov19/.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board layout stays;
  - Primm's fight and the castle rooms unchanged;
  - no enemy intent shown;
  - **no combat pacing changes** (the owner tests by hand); the 45-card deck minimum stays;
  - no new painted art (use existing assets; log art needs as Batch 18 rows);
  - each zone keeps its own colour grade.
- **Dialogue:** rewrites are allowed where this brief asks for them (Maren after the second Path, Elowen, Plume, Bellows, Alembic's intro, the new notes). Keep each character's voice, main-story lines clear and emotional, humour in side content, no clipped one-line statements. Save every changed or new line's ID to `docs/dialogue/nov19_lines_ids.txt` with `docs/dialogue/nov19_lines.csv`, so `node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov19_lines.csv --revert=docs/dialogue/nov19_lines_ids.txt` undoes them.
- Every rules, quest or reward change gets a test.

## Part 1 — Card and battle bugs
1. **Post-Human Resources Ghoul** kills one of the player's units automatically when played. The card says the player chooses. Make the player pick the target, on the player's own side as the text says. Check every "choose / target" card the player plays for the same bug (auto-picked instead of chosen) and fix them the same way.
2. **Scripted fight events must be readable** (e.g. Undersecretary Vellum). When a scripted event fires in any fight (bosses, gatekeepers, the arena, dungeon fights), show a **pop-up the player must click or press Space to close**: the character's portrait and line, and a plain description of what the event does ("Vellum files an objection: your units get -1/-0 until your next turn"). The effect happens when the pop-up closes, with the usual card and board animation. Controller: A/Space closes it.
3. **Opponent spells and traps stay until the player has seen them.** When the opponent plays a spell or a trap triggers, the card stays shown (large enough to read, beside the board, not covering the player's hand) until the player clicks it or presses Space; then play continues. Add a setting "Opponent cards: wait for click (default) / continue after 4 s". Units the opponent plays don't need this.
4. **The Arena's rule messages** sit at the top of the board, behind the opponent's hand (`ref_arena_message_behind_hand.png`), where nobody can read them. Move them into the **"Rules of this fight" list under the opponent's portrait and HP panel**, as readable lines (with the existing rule icons and their hovers), for every arena and dungeon rule. Remove the banner at the top.
5. **A damaging roaming enemy that hits you is added to the Bestiary.** When a contact-damage enemy (e.g. the Gainlands' runaway meatballs) hits the hero in the world, its Bestiary entry unlocks (with the usual "new entry" note), as if you'd fought it.

## Part 2 — The story after each zone (main quest flow)
1. **Returning to Crosspath after freeing a zone:** the **first time the player enters Crosspath after freeing a zone** (every zone, every time), they arrive standing in front of Elder Maren, her scene plays automatically and the quest advances. No walking to her first.
2. **The main quest updates step by step:** as soon as a zone is freed, the tracker shows "Free a zone" ticked and the next step "Talk to Elder Maren" (for every zone). The Fragments steps follow the order the player actually freed the zones.
3. **Notifications that matter wait for a click.** The pop-up after freeing a zone ("someone is waiting for you at the mouth of the Forgotten Cave") disappears too fast. Story and unlock notifications (zone freed, someone waiting, shop open, new equipment, new arena tier) stay up until the player clicks or presses Space. Small toasts (item picked up) can still fade.
4. **Elowen:**
   - After the **second** Path she is **not** holding two cups of something hot. She is waiting, looking anxiously about. Rewrite her lines there to match.
   - When she leaves after a Path scene she slides off. She must **walk** off (her walk set exists, as SPR-RESCUER-*_WALK and Elowen's own walk; use whichever is hers). If any walk direction is missing, use the closest one mirrored and add a Batch 18 row.
   - Change her line about always finding the hero (it isn't supported by the rest of the game); rewrite it to fit.
   - After the first Path, replace "I won't come into town, though. The old woman with the shell..." with **"I won't come into town, though. I can't risk being seen."**
5. **Elder Maren after the second Path** (her dialogue there is poor). Rewrite her scene so that:
   - she still believes the hero is a **powerful Path-walker** who can help the resistance; she does **not** suspect he is the lost prince yet;
   - she is wary: he remembers nothing (or says he doesn't), and she can't be sure he can be trusted;
   - she now **starts to trust him**, because whatever he is, he is helping them;
   - she worries what happens when his memories return: will he still want to help them?

   Keep it consistent with the story bible (she worked at the castle, she's going blind, she half-suspects later, she never "knew all along").
6. **Percival Plume speaks PR.** He is Primm's minister; he never says a zone was "freed". Give him smooth spin: there has been "a leadership transition, which His Perfection fully supports", and so on. Go through **all** his lines in every zone and fix any that sound like the resistance's words.
7. **No duplicate characters.** After the D.N.A. is freed there are two Agnes Overdues in the starting area (`ref_dna_two_agnes_rip_portal.png`). Make sure there is only one, and **check every zone in every state** (before and after its freeing, after the ending) for any character standing in two places at once. Write a probe and keep it as a test.
8. **"New equipment is available at a vendor"** after clearing the D.N.A., but none could be found. Make sure that equipment is really in a vendor's stock, the note names the vendor, and the vendor's map icon shows a "new" mark. Check the same for **every** zone freeing and every other unlock note (packs, cards, shops, arena tiers) with a test per unlock.

## Part 3 — Auntie Alembic
1. **Opening:** her shop opens **after the first zone is freed**. Before that, her door note must not say "free a zone". Write something that fits the world and tells the player to come back later (e.g. "Closed for inventory. And for reasons. Do come back later, dear.").
2. **Her intro quest is a MAIN quest.** Right after the "you can now use multi-Path cards" notification, Maren's automatic scene (Part 2.1) ends by sending the hero to Alembic. If an intro quest exists, make it main and tracked; if not, create one. It teaches how to talk to her and brew a card, step by step, with the shop's own hints.
3. **The essence she gives:** on the intro quest she adds **6 essence of each Path** (enough for two brews, the player picking the two Path pairs). It is **added** to what the player already has (never replaced), up to the cap.
4. **Brewing costs 6 essence of each of the two Paths** (it costs 2 today, while her lines and the instructions say 6: `ref_alembic_shop.png`). Fix the cost, the gold price stays, and make every text match.
5. **Each Path holds at most 18 essence.** Anything over 18 is not kept (and the essence from extra copies stops once a Path is full; say so on the screen). Migrate saves: clamp to 18.
6. **The essence bars:** each bar fills in proportion to the amount out of 18 (9 = half full). The number is white below 18 and **gold/yellow at 18**. The header says the cap is 18 (not 60).
7. **The instructions at the top:** "Every copy of a card beyond your third turns into essence of its Path..." (players can own 3 copies of every card now), plus the 6-per-Path cost and the 18 cap. Update every other text about brewing (glossary, tutorial, Maren, Alembic) to match.
8. **The brew's card list:** remove the percentages. Under each card show how many the player owns out of 3 ("0/3"). A card the player has **never seen** (never owned it, never seen it in a battle, a shop or a pack) shows as a **card back** instead, and becomes visible once seen.
9. **Hovering a card on her page magnifies it**, like the reward-card hover (a card back magnifies as a card back). Same for any card grid on other menu pages that lacks it.

## Part 4 — Signature cards for the mini dungeons
1. **The first clear of each mini dungeon awards its signature card**, shown on the dungeon-clear rewards screen as a card (not just a line of text):

   | Mini dungeon | Signature card |
   |---|---|
   | The Waiting Room of Eternity (D.N.A.) | **Betty Bones, Surly Secretary** (replaces the Department of Final Approvals, which becomes a normal card again: packs and shops by its rarity) |
   | Omakase (Buffet) | Toro Toro |
   | The Trash Panda Throne (Dump) | Raccoon |
   | The Ascent of Mount Swolympus (Gainlands) | Barbell of the Ancients |
   | **The Iron Cave (Gainlands)** | **Baron Quadzilla** (new, below) |
   | The Old Service Tunnels (Capital) | The Wanderer |
   | The Paste Works (Capital) | The Infinite Pantry (plus the Colonel's Ladle as now) |
   | The Forgotten Vault (Crosspath) | Old Kingdom Banner |

2. **Signature cards are never in packs.** After the player has beaten that mini dungeon once, the card is sold in **that zone's shop** (the Capital's two in the Capital shop, the Vault's in Crosspath), up to 3 copies with the usual notice for copies above the deck limit. Before the first clear the shop doesn't show it.
3. **New card: Baron Quadzilla** (Beefcake, Epic, the Iron Cave's boss: the huge, cheerful leg-day toad on his leg-press throne). The owner wants it **powerful, fun and on theme with the Gainlands**. Proposed design (adjust the numbers only if your checks show it's out of line with other Epic signature cards like Toro Toro; report any change):
   - **Baron Quadzilla, Lord of Leg Day.** Unit, cost 3 + (B)(B), **5/6**, **Bulldoze**.
   - *When this unit enters, create two Iron.*
   - *Never Skip Leg Day: at the start of combat on your turn, you may use an Iron. If you do, other units you control get +1/+0 and Bulldoze until end of turn.*
   - Flavour: "He has not skipped leg day in forty years. He has also not left the leg press."

   Use the existing mechanics and wording (Iron, Bulldoze); add it to the card list, the glossary and the tests. **Card art: use the Bestiary or cut-out art as a stand-in** and add a Batch 18 row (CARD art matching NPC-QUADZILLA / CUT-QUADZILLA).
4. **The Gilded General Pack** (reward-only today) becomes **buyable from the Crosspath card/pack vendor after all four zones are freed**, at a gilded price.

## Part 5 — Dungeon choice nodes: no free lunches
1. **Every choice node in every main and side dungeon** (events, shrines, kiosks; **not** the tutorial cave, whose Hollow Well already trades) follows these rules:
   - **No option is purely good.** Every boon carries a drawback.
   - A **do-nothing option** is allowed (and is often there), but not required.
   - **They grow with depth:** early nodes give small boons with small, short drawbacks (the next encounter only); later nodes give stronger boons and stronger drawbacks that **last the rest of the dungeon**.
   - **Boons:** gold, a heal, +1 attack or defence for your units next encounter (or for the dungeon), an extra card drawn, an item, a card reward, Iron/resources at the start of a fight.
   - **Drawbacks:** lose HP or max HP for the dungeon, lose random cards from your deck for the dungeon, lose gold, your units start the next encounter with -attack or -defence, or enter exhausted, the enemy starts with an extra unit or resource, a curse for the rest of the dungeon.
   - The option text always states both the boon and the drawback plainly, with numbers.
2. **The Hall of Final Approvals' first room, the Take-a-Number Kiosk** (`ref_hfa_take_a_number_event.png`):
   - "Take a number and wait" **does nothing** (it heals 3 today);
   - the other two each give a small boon with a small drawback (e.g. gain 35 gold but lose 2 HP; your units get +1 attack next encounter but enter it exhausted).
3. Write the full table of every node (dungeon, node, each option's boon and drawback, its duration) into the report, so the owner can review it.
4. **The Executive Elevator Operator's rule** (each player's first spell each turn costs 1 more): confirm it works as written (spells only; units and other cards are unaffected) and that the rule is shown in "Rules of this fight". It should apply in **three fights of the Hall of Final Approvals, including the boss (Mortimer)**: the Elevator Operator's own fight and two others (pick one early and one late), not every encounter. Tests.

## Part 6 — The Arena
1. **Tiers unlock in order.** A tier opens only when **every encounter of the tier before it is beaten**. Tiers: **Bronze, Silver, Gold, and a new Diamond**.
2. **The Prize Podium** shows only the **current tier's prize**; later tiers are greyed out (locked) until reached.
3. **Every encounter win gives gold, experience and a normal pack of some type** (Bronze gives packs where it gave essence; higher tiers may add essence or an item on top).
4. **Tier prizes are equipment**, given when every encounter of the tier is beaten:
   - **Bronze:** one of the two equipment prizes Silver has today;
   - **Silver:** the other one;
   - **Gold:** one of Gold's two equipment prizes today;
   - **Diamond:** the other one, **plus one copy of the new Announcer Grand Bellows card**.
5. **Gold and Diamond each have two encounters: one puzzle and one battle.** Build Diamond's from existing arena foes, decks and art (harder than Gold). Don't rebalance the other encounters (the owner tunes the Arena by hand later; see the backlog).
6. **Pop-ups (click or Space to close):** after each arena win, a "Victory!" pop-up shows what was won; when a tier is complete, a second pop-up shows the tier prize and that the next tier is open.
7. **Preset decks:** before an encounter that uses a set deck, the deck-choice screen appears but doesn't matter, which is confusing. Replace it with a screen that says this encounter uses a preset deck (name it, and show its cards if easy) with a Continue button.
8. **New card: Announcer Grand Bellows** (Colourless, Epic, the Arena's announcer). One copy from the Diamond prize; more copies sold at the **Crosspath card vendor** (after Diamond is cleared). Proposed design (adjust only if out of line; report):
   - Unit, cost 4, **3/4**.
   - *Ladies and Gentlemen! When this unit enters, choose a unit you control and an enemy unit. They fight (each deals damage equal to its attack to the other).*
   - *The Crowd Goes Wild: whenever a unit you control destroys an enemy unit in combat, it gets +1/+0 until end of turn.*
   - Flavour: "In this corner... everyone. Somehow, everyone."

   Stand-in art from his portrait; a Batch 18 row for CARD art matching NPC-BELLOWS.
9. **Bellows' dialogue** must not mention freeing a zone. The Arena reopens because **Primm's presence in the area has weakened**: he needed his forces elsewhere. Rewrite his lines to say so naturally. **Before the Arena opens, one of Primm's guards stands at its entrance** (an existing Capital guard sprite and portrait) turning the hero away ("Closed by order of His Perfection. Move along."); he's gone when it opens.

## Part 7 — Equipment text
- In equipment descriptions, the equipment menus and Beetram's shop, **remove the "sidegrade / upgrade / downgrade vs. what you have equipped" section** and shrink the boxes to fit. Check every screen that showed it.

## Part 8 — The world
1. **Rip** (the portal NPC):
   - In the D.N.A., move Rip's portal station a little to the right, away from the walkway (`ref_dna_two_agnes_rip_portal.png`).
   - In Crosspath, Rip and Auntie Alembic are too close (`ref_crosspath_rip_beside_alembic.png`). Move Rip into the **big open area to the south-east** of where he is now and make that his spot (portal, any props and markers with him).
   - **Every Rip turns to face the hero and idles like other NPCs**, in every zone. If his art lacks the turning directions, mirror what exists and add Batch 18 rows for the missing ones.
2. **The Forgotten Cave's entrance from Crosspath** is a door on a building near the middle of town. Move it to a **small cave mouth covered in brush on the north side of the map, coming out of the forest there**, not far from Elder Maren, built only from existing assets (rock, brambles OF-PROP-BRAMBLES, the cave-mouth art, ferns, a lantern). Update the travel prompt, the map icon, quest markers and the "someone is waiting at the mouth of the Forgotten Cave" scene.
3. **The Old Service Tunnels' entrance** (`ref_capital_service_tunnel_door.png`):
   - remove the door in the middle of the Capital's wall; make that a normal, complete wall;
   - put a **manhole** in the ground where the nearby sign is (a round iron cover, slightly ajar, with a faint glow or steam, from existing assets);
   - remove that sign.

   The travel prompt and the quest marker move to the manhole.
4. **The Capital's southern edge:** walking along it, the camera suddenly flips to a low angle and looks up through the floor (`ref_capital_south_camera_flip.png`). Fix it (the camera collision, a bound or the ground clamp), at every camera preset; walk the whole southern edge both ways.
5. **Signs face the player.** Many signs in the Capital, and across the world, stand edge-on to the camera (`ref_capital_signs_edge_on.png`), so their icons and text can't be seen. Rotate **every** sign, signpost board and plaque in every zone so its face is toward the default camera view and its icon or text reads. Write a probe listing every sign and its angle to the camera, and keep it as a test.

## Part 9 — Batch 18 rows and the backlog
- Add rows to `docs/art/batch18_nov18.csv` for: the Baron Quadzilla card art; the Announcer Grand Bellows card art; any missing Elowen or Rip art; anything else tonight found that only new art can fix. Keep each description self-contained and under 600 characters (the owner runs ChatGPT from a sheet tab).
- Add anything new you deferred to `docs/owner_backlog.md`.

## Part 10 — Check the flow end to end
- Run the **strict playthrough bot** for **two** Paths (Refusemancer and Necrocrat) from a new game through freeing **two** zones: check the auto-return to Maren, the quest steps, Alembic's opening and intro quest, the essence gift (6 each, added, capped at 18), and that no story notification vanishes.
- Play each mini dungeon's first clear with a debug-free save if possible (or the fastest honest route) and screenshot each clear screen with its signature card.
- Screenshot the Arena: the podium (current tier only), a victory pop-up, a tier-complete pop-up, the preset-deck screen, and Diamond.

## Part 11 — Tests, the build, the report
1. All test shards green; the walk smokes (Crosspath, Gainlands, Buffet, Dump, D.N.A., Capital); the NPC visibility probe; the duplicate-character probe; the sign-angle probe; the D.N.A. floating/overlap probe; the card-games smoke.
2. **Export 1.0.0 for the playtesters:**
   - wait up to 10 minutes for at least 2.2 GB free RAM, otherwise use `EXPORT_LOW_MEMORY_OK=1`;
   - `bash tools/export_windows.sh 1.0.0`;
   - then the exported smoke and the three `play_exported.sh` checks (0 SCRIPT ERROR).
3. **docs/overnight_report.md**, with at the top:
   - each part done or not, with shots;
   - the choice-node table (Part 5);
   - the two new cards as built (final numbers);
   - the Arena's tiers, encounters and prizes, as a table;
   - the essence, brewing and save-migration rules;
   - the dialogue revert command;
   - what's left undone, if anything;
   - **where the zip is** and its size;
   - anything that needs the owner (at most 8 items, each with a recommendation).
4. Commit and push. No public upload.
