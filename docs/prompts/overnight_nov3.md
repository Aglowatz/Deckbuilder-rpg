# Overnight pass — Nov 3 (Opus) — items, character page, Pip, dungeon fog, polish

You are working in C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner is asleep.
Work autonomously through the parts below in order. Do not ask questions; log anything you
cannot decide in docs/overnight_inbox.md with the choice you made and move on.

## House rules (same as previous overnights)
- Check for a STOP_OVERNIGHT file in the repo root before each part; if present, finish the
  current commit, write the report and stop.
- 7.4 GB RAM machine: only ONE Godot process at a time. At most 3 sub-agents, and never while
  Godot or the tests are running.
- Tests: `bash tools/run_tests.sh` (sharded GUT). Add GUT tests for every rule you change.
- Visual checks: drive the game with `bash tools/play.sh` and save screenshots under
  docs/overnight_shots/nov3/. Critics play from a worktree at HEAD.
- After each part: tests green → commit (one commit per part, clear message) → push.
  Update docs/loop_state.md after every part so a crash can resume.
- Dialogue changes follow docs/dialogue/voice_bible.md (keep the humour and the characters'
  voices). Never invent new art: reuse existing assets only.
- Spoiler rules: anything that reveals content before the player has seen it goes through the
  existing SpoilerFree system.
- End: write docs/overnight_report.md (what changed, numbers, screenshots, what is left), then
  export `bash tools/export_windows.sh 0.5.3` and run the release smoke.

## Part 0 — State check (10 min)
- Read docs/loop_state.md and the last overnight report. Confirm the Gainlands techno-hard-rock
  music set and the Vorbis q6 rollback landed. If they did not, do NOT redo them tonight; note
  exactly what is missing in the report.
- Open and LOOK AT every image in docs/ui/ref/ (use your image-reading tool on each file):
  character_menu_target.png, character_menu_current.png, pip_tryon_current.png,
  battle_item_icon_current.png, townsfolk_badgers.png, flex_art_current.jpg.
  Describe each one in two lines in docs/loop_state.md so the description survives a restart.

## Part A — Quick fixes
1. Pack opening: the "extra copies converted to essence" popup must wait until every card in the
   pack has been revealed (after the last flip/reveal animation finishes). Test with a pack that
   contains duplicates.
2. Battle item icons (see battle_item_icon_current.png): remove the dark bar across the icon.
   Put the charge count in the bottom-right corner, small badge, with an outline/shadow so it is
   readable on every icon. Check all ~15 item icons.
3. Saucepan Helmet: description "Max HP +1, and heal 1 HP at the start of every duel." Implement
   both effects (max HP +1 while equipped; at the start of each duel heal 1, not above max).
   Add tests.
4. Crosspath big treasure chest: openable from the front AND the back (both interaction zones
   open the same chest, once).
5. Gainlands "Running the wheel": play the player's walk animation at a very fast speed for the
   duration of the wheel spin (facing the running direction), then return to idle.
6. Crosspath NPC clipping: roaming NPCs walk through the building on the left side and the badger
   NPC clips through walls. Fix their paths/collision so no NPC ever overlaps a building. Check
   every roaming NPC in Crosspath, and spot-check other towns for the same issue.
7. Item slots: confirm how many consumable item slots exist in code/data. The design is FOUR slots
   total (unlock rules in Part B). Fix if different.

## Part B — Systems and balance
1. **Consumable items are one-use.** Buying an item adds one charge. Using an item in battle
   spends one charge permanently. An equipped slot shows the charges left; when charges reach 0
   the slot empties. Owning more charges than are equipped is fine (the inventory shows them).
2. **Item slots:** 4 slots. Slots 1-2 are open from the start. Slot 3 unlocks at Level 6, slot 4
   at Level 12. Locked slots show "Level unlock" (plus the level) on the character page.
   Existing saves: migrate cleanly (keep equipped items that fit).
3. **Prices:** regular shop items cost 50-100 gold. Cheapest item = 50. Energy Draught and
   Firebrand Charm = 100 (top of the regular shelf). EVERY item on the late-game (high) shelf =
   150. Spread the rest sensibly between 50 and 100 by power. Update the design sheet export /
   data sources the game reads from, and list the final price table in the report.
4. **Healing Draught → Energy Draught.** Same art. Effect: when used, the player chooses a Path
   (only Paths present in the current deck are offered) and gains +1 energy of that Path for
   this turn only. Update name, description, shop text, any dialogue or tutorial mention,
   and tests. Remove it from every healing list.
5. **Tilly item tutorial (intro questline).** Add a step right after the first intro fight:
   Tilly gives the player one free Field Bandage and tells them, in her voice, exactly how to
   equip it: open the Character page, find Items, select the Field Bandage, choose an empty slot.
   Highlight the Character menu button (and then the Items panel) until the player has equipped
   it; the step completes on equip. Keep her lines short and funny.
6. **Equipment tutorial (equipment questline).** Find the quest step where Equipment becomes
   unlocked. Add a step there: the player receives (or already has) one piece of equipment and
   is told by the relevant NPC how to equip it from the Character page (click the slot → the
   new Equipment selection page from Part C). Highlight the path the same way; the step
   completes on equip.
7. **Hidden battle triggers.** Any enemy trigger (e.g. Baron Quadzilla gaining HP when he
   "dies") stays hidden until it has fired at least once in THIS save. Until then, the battle
   UI and the pre-fight description show a chip reading "Hidden trait ?" (tooltip: "Something
   happens in this fight you haven't seen yet."). After it fires once, it is shown normally in
   battle and in every later pre-fight description for that save. Store per save.
8. **Dungeon fog (per save).**
   - First visit to a dungeon: every node is either locked or shows "?" (boss node included).
   - A node that becomes reachable shows "?" until the player steps on it.
   - Once stepped on, that node's real icon is shown on all later runs of that dungeon in that save.
   - The dungeon's name is shown as "???" until the player has entered it once.
   - New game = all hidden again. Migrate existing saves so already-visited dungeons/nodes stay revealed if the save has that data; otherwise start hidden.
9. **Card economy study and new card prices.**
   - Simulate a full no-grind playthrough: the critical path plus normal side content, no repeated fights for gold. Use the real gold sources (fights, chests, quests, feats, sells) and the real costs (items, hats, rest, etc.).
   - Write docs/balance/gold_economy_nov3.md with these sections:
     - total gold earned per zone and per playthrough;
     - what a typical player also buys (about 6-8 item charges, a few hats);
     - the gold left over for cards.
   - Set card prices so that a no-grind player can buy about 20 cards across the whole playthrough. Keep the rarity price ratios sensible.
   - Check grinding: repeat fights / replayed dungeons must still pay enough that grinding for more cards is reasonable. Target roughly one extra card per 3-4 repeat fights at the zone's level. Report the actual figure.
   - Apply the new prices in data. Put the before/after table in the report.
10. **Townsfolk variety** (see townsfolk_badgers.png). Generic townsfolk all use the badger sprite.
   Build a pool of reusable NON-story NPC sprites (exclude named story characters and anyone
   who appears in that same zone), with small tint/hat variations through the existing sprite
   cosmetics where safe. Assign per town so each town has visible variety. No new art.

## Part C — Character page redesign (modern game menu, no new art)
The target is docs/ui/ref/character_menu_target.png. The current page is
character_menu_current.png.

**Step 1 — layout spec.** Before writing UI code, write docs/ui/character_menu_spec.md. It lists every panel, label, line item, and its rough position and size, transcribed from the target image, and maps each element to our real data. Required elements:

1. Page title: CHARACTER.
2. EQUIPMENT panel:
   - a body silhouette with Helm, Armor, Weapon, Relic and Boots slots;
   - before unlock it reads "Equipment unlocks after the <real quest name>" (use the real unlock condition and quest name; not "armory" unless that is real).
3. LEVEL panel:
   - Level, an XP bar with "current / next XP", HP current/max;
   - Opening hand, Max hand, Gold;
   - a PATH ESSENCE row (icon + amount for each Path).
4. CARD PACKS panel:
   - unopened packs (open button), or "No unopened packs" plus the hint "Find packs in dungeons, quests and shops."
5. ITEMS panel — the visual focus. It must be more prominent than the other panels: accent border/glow and larger.
   - Subtitle: "Equip up to 4 single-use items".
   - "EQUIPPED  x / 4 unlocked" header with 4 slots, each showing:
     - an item icon with a charge badge, or
     - "Empty slot +", or
     - a lock with "Level N".
   - Note under the slots: "Additional slots unlock as you level up. One charge is consumed per use."
   - INVENTORY grid ("N item types") showing every owned item with its icon and charge count, scrollable.
   - Detail row for the selected item:
     - large icon, name, "Single-use • N charges owned", and its effect text;
     - "Equipped in slot N" or "Not equipped";
     - an Equip / Unequip button.
   - Footer hint: "Select an item, then choose an empty slot to equip."
   - Interaction: click an inventory item, then click an empty slot (or the Equip button → first empty slot). Clicking an equipped slot selects it for Unequip.

**Step 2 — Equipment selection page.** Clicking an equipment slot opens an Equipment selection page in the same style as the Items inventory:
- a grid of owned equipment that fits that slot;
- a detail row (icon, name, stats/effect, Equip / Unequip);
- a back button.

**Step 3 — visual rules.**
- Dark translucent panels, thin gold/accent borders, section headers in caps, consistent spacing.
- Reuse the existing fonts, icons, panel textures and Path colours. No new art.
- Must fit and stay readable at 1280x720 and 1920x1080, and in Low-end mode.
- Keyboard/controller navigation still works.

**Step 4 — compare.**
- Screenshot the finished page in three states:
  - early save (2 slots, equipment locked);
  - mid save (equipment unlocked, items equipped);
  - the Equipment selection page.
- Build docs/ui/ref/character_menu_result.png with the target and the result side by side.
- Do one critic pass comparing them element by element against the spec, fix the gaps, then re-shoot.

## Part D — Pip's shop (Threadwell)
1. "Try" becomes **Preview**: it shows only the hat, large, centred on a plain panel, without
   the player sprite (see pip_tryon_current.png for why).
2. Owned hats: the Buy button becomes **Equip** (or "Equipped" when worn). Add a "No hat"
   entry so the player can remove their hat. The equipped hat shows in the world and in
   battle as today.
3. Cloak recolouring is broken. Time-box a fix to 45 minutes using the existing masks in
   _art_source/cloak_masks (or a shader on existing sprites). It only counts as working if the
   recolour shows correctly on the player in all four walk directions, idle, and in battle.
   - If it works: keep cloaks, with Preview/Equip handled the same way as hats.
   - If not:
     - remove the cloak system entirely (shop entries, save data with a clean migration, UI, any refunds of gold spent on cloaks);
     - make Pip's shop hats-only;
     - rewrite every Pip line and any other dialogue or text that mentions cloaks so it only talks about hats, in Pip's voice;
     - record which path you took in the report.

## Part E — Art audit (no art generation)
Write docs/art/art_needed_nov4.csv: id, where it is used, the current file, the problem, and a one-line description of the needed image in the existing style. Cover the following:
1. **Grandmaster Flex must be a lion in every image.** The canonical look is the muscular lion in STORY-FLEX (the scene where he rips his clothes off).
   - Before his transformation he is a frail, elderly lion: white mane, ragged red-and-cream robes, chained wrists.
   - Images that currently show a human and need redoing:
     - NPC-FLEX (dialogue portrait);
     - STORY-RESCUE (prison rescue);
     - SPR-FLEX-FRONT_IDLE and all other Flex sprites/directions;
     - the post-dungeon Flex NPC image;
     - any other image of him.
2. **STORY-FLEX:** the figure on the throne must be Grandmaster Clench in his NEW design (NPC-CLENCH: muscular, white-and-gold uniform with red sash, dumbbell). It currently shows an old black-uniform design.
3. **Missing art:** the dialogue scene before Grandmaster Clench's fight has no art. List the image(s) it needs.
4. **Consistency:** check all Gainlands characters across portraits, sprites and story stills, then every other zone, and list every mismatch.
5. **Placeholders:** scan the whole game for placeholder or missing art (placeholder textures, debug squares, reused wrong portraits, missing story stills) and list each one.

Do not change art references for these. Tomorrow they become a ChatGPT batch and an import pass.

## Finish
- Full `bash tools/run_tests.sh` green.
- Critic play-through from a HEAD worktree covering these flows:
  - the Tilly item tutorial;
  - buying and using an Energy Draught;
  - a dungeon first visit;
  - Pip's shop;
  - the character page;
  - Baron Quadzilla's hidden trait.
- Fix anything the critic flags.
- Write docs/overnight_report.md:
  - per-part results;
  - the price tables;
  - the gold study numbers;
  - the cloak decision;
  - screenshots;
  - open questions.
- Export 0.5.3 and run the release smoke.
- Commit and push.
