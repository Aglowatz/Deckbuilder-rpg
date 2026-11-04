# Fresh eyes, Nov 3: six new flows of The Wayward Path

## Summary

The art is the strongest thing here. Tilly, Pip and Bertram are lovely, and the painted dungeon maps hold up next to Sea of Stars. The
writing has a real voice too ("I wrapped my own arm once! Still tough! Still a bit stuck!"). The systems around the art are weaker. Feedback
is often missing or sits in the wrong place: an item's effect never shows on the energy counters, a used item slot looks like a slot that was
never filled, a boss node tells you nothing while you stand beside it, and the hat "preview" never puts the hat on your character. The flows
all work and I found no `SCRIPT ERROR` in any of the 8 runs. The friction comes from many small readability and feedback gaps, not from things
breaking. Slay the Spire and Monster Train always show what an action changed, and that habit is what's missing here.

## How I played

I made 8 runs with `tools/play.sh`. Each run started with `dev travel town`. The scripts are `docs/review/play_scripts/critic_nov3_*.txt` and
the runs are `cn3_tilly`, `cn3_equip`, `cn3_draught`, `cn3_fight`, `cn3_fight2`, `cn3_dungeon`, `cn3_shops` and `cn3_boss`. The screenshots
I cite are in `docs/review/fresh_eyes_nov3/`. Two runs were partly wasted by my own scripts:
- In `cn3_fight` I clicked an empty item slot and pressed Escape, which opened the pause menu and stalled the pilot.
- In `cn3_boss` I didn't press **Continue** on the boss's pre-fight panel, so the fight never started.

The second slip used up my 8-run budget, so **I never saw Baron Quadzilla's hidden trait fire in the dungeon boss fight.** Flow 6 is scored
only on the "before" half. The one full Baron fight I did see came from `dev encounter` and lasted 10 turns. The pilot lost it, and no hidden
trait was announced.

## Scores

| # | Flow | Score | One-line verdict |
|---|---|---|---|
| 1 | Tilly's item lesson | 6/10 | Funny and short, but the reward is hidden behind the dialogue box and the directions are for the menu, not the C key |
| 2 | The Energy Draught | 5/10 | Clear before you use it. After use, nothing on the board changes except a floating line of text |
| 3 | A dungeon's first visit | 5/10 | Gorgeous maps, but every node is an identical "?", and the tip promises route choices the map doesn't have |
| 4 | Pip's hat shop | 6/10 | Charming, but Preview shows an icon instead of your character, removing a hat is hidden behind "No hat", and the layout jumps |
| 5 | The Character page + equipment | 6/10 | Tidy, readable columns, but Escape doesn't close it, empty gear slots look owned, and the weapon page is mostly empty |
| 6 | Baron's hidden trait (before only) | 4/10 | The boss node says "Unknown" in front of an obvious boss arena, and the pre-fight panel is a wall of six rules |

## Findings per flow

### 1. Tilly's item lesson (6/10)
- **Good:** her voice is great: short, punchy lines with a running gag (`tilly_09_freebie.png`). The whole lesson is about six boxes, which
  is the right length. The quest tracker updates straight away.
- **The reward is hidden.** "Received: Power Wraps (1 charge)" pops up on her first line, *before* she says "First visit gets a freebie!", and
  it sits behind the dialogue nameplate, half covered (`tilly_02_talk1.png`, the text cut off at y 668). The best moment of the lesson goes
  unseen.
- **The quest moves ahead of the story.** "Equip Tilly's Power Wraps" is already in the tracker on her first line, before she has offered
  anything (`tilly_02_talk1.png`).
- **The directions are for the menu.** Both the tracker and Tilly say "Menu > Character > Items, then an empty slot". The C key opens that
  page directly, and nothing ever mentions it.
- **The ending is flat.** Equipping the Wraps finishes the step, but the only feedback is the quest banner, drawn over the "CHARACTER" title
  (`char_02_wraps_equipped.png`). Tilly doesn't react, there is no sound or flourish, and her shop never opened during the lesson
  (`tilly_after.png`).
- **The typewriter is slow.** Each long line needs a tap to finish typing and another to move on. That's fine for a lesson, but add
  hold-to-fast-forward.

### 2. The Energy Draught (5/10)
- **Before use: good.** The Character page explains it clearly ("Choose a Path in your deck: gain 1 energy of that Path this turn. A fizzy
  kick in a familiar bottle."), and the battle tooltip says the same plus "No target needed" (`fight_00_hover_draught.png`).
- **The tooltip covers your hand.** It is wide and sits over the first two hand cards (`fight_00_hover_draught.png`).
- **"Choose a Path" never asks you to choose.** With one Path in the deck, it simply applies. The text promises a choice the player never
  makes.
- **After use: almost nothing changes.** A plain floating line says "+1 Beefcake energy this turn." (`fight_01_used_draught.png`), but the
  player's energy row (bottom right) still reads **x0** on every Path. The player can't see the energy they just bought. In Slay the Spire,
  a potion's effect is always visible on the HUD.
- **A used slot looks like an empty one.** After use, the Draught's slot shows the same blank "Empty item slot" art as slot 2, with no "used"
  or "spent" mark (`fight_03_after_empty.png`). Players will wonder whether it was ever equipped.
- **Charges behave correctly.** One charge, spent on use, and the slot is empty afterwards. On the Character page, "1 / 2 unlocked" and
  "Equipped in slot 1/2" are clear (`char_02_wraps_equipped.png`).
- **Equip-flow quirk.** Clicking an inventory item and then a slot works, and the checkmark on the inventory tile is a nice touch. But Escape
  doesn't close the page (see flow 5).

### 3. A dungeon's first visit (5/10)
- **Good:** the art is excellent. Mount Swolympus and the Iron Cave are some of the best map art I've seen in an indie card game
  (`dungeon_beef_first.png`, `dungeon_iron_first.png`).
- **There is no information to plan with.** Every node on an unvisited map is the same dark "?" disc with a tiny "???" plate, so there is
  nothing to choose or plan. Slay the Spire's map icons are its whole decision layer.
- **The tip promises what the map lacks.** It says "some of them are real choices between routes", but both maps are three nodes in a straight
  line, and the tip box covers the top third of the map, boss node included (`dungeon_beef_first.png`).
- **Reveal works but is quiet.** A cleared node becomes a red-and-gold checkmark with its name ("The Calf Raise Crawl", "The Squat Rack
  Gallery"), and a gold line joins it to the next node (`boss_00_hover_node.png`). That's readable, but nothing tells you in advance what a
  node is.
- **The "next" node is hard to spot.** It has a gold ring; the others are dark. The difference is subtle on the busy painted background.

### 4. Pip's hat shop (6/10)
- **Good:** Pip's portrait and barks are delightful ("You are going to turn heads, mostly in confusion."; "The bare-head look! I shall lie
  down in the back for a moment."), and prices are clear (`hats_00_shop.png`).
- **Preview shows an icon, not you.** Preview puts a big icon of the hat in an empty panel (`hats_01_preview.png`). Players want to see it on
  their own character, the way the dressing rooms in Pokemon TCG Pocket or Sea of Stars do. That panel is the obvious place for the hero model
  wearing the hat.
- **Buy equips at once, with no confirmation.** It's fine for 100g, but the "Equipped" state looks greyed out, like a disabled button
  (`hats_02_bought.png`).
- **Removing a hat is hidden.** There is no "Take off" button: you "Equip" the **No hat** card (`hats_03_off.png`). Hats and the cloak sit in
  one grid, so two cards show "Equipped" at the same time (`hats_00_shop.png`), which reads oddly.
- **The layout jumps.** The grid shifts and changes width between states (compare the card edges in `hats_00_shop.png`, `hats_02_bought.png`
  and `hats_03_off.png`; the right column moves about 30 px).
- **Locked cards repeat one joke.** Seven "???" cards all say "Not yet. That one is still on the sewing table, and it is sulking." It's
  funny once. The list also runs below the screen with no visible scrollbar.
- **The hat never shows up elsewhere.** It doesn't appear on the Character page silhouette, which is a generic grey figure.

### 5. The Character page and equipment (6/10)
- **Good:** a clean three-column layout (gear doll, stats and packs, items), large fonts, and useful empty states ("No unopened packs - Find
  packs in dungeons, quests and shops.") (`char_01_items.png`).
- **Escape doesn't close the page.** After pressing Escape I was still on the Character page (`char_03_escape_no_close.png`); only the X
  button closed it. In battle, Escape opens the pause menu (`fight_esc_pause.png`), so the key behaves differently from screen to screen.
- **Empty gear slots look owned.** Once gear is unlocked, empty slots show pale blue ghost icons of a helm, armour, sword, amulet and boots
  (`char_04_gear_unlocked.png`). At a glance they look like items you own. Only the Weapon slot is lit, which shows where to click, but it's
  unclear what the other four are.
- **The weapon page wastes space.** It is about 70% empty, with a single 120 px tile for "Starter Blade" (`char_05_weapon_page.png`). The
  stat line is clear ("The first unit you play each battle gets +1 attack"), but there is no comparison and no sense of tiers to come.
- **Bertram's nameplate is cut off.** It reads "BERTRAM BEETSWORTH, ASSIS..." (`bertram_00_nameplate.png`). His line is good ("Stamp. Stamp.
  Stamp. Three stamps is the correct number of stamps.").
- **The directions are for the menu again.** The tracker says "Menu > Character > the Weapon slot".
- **The quest banner covers the page title.** "QUEST UPDATED" lands on top of "CHARACTER" (`char_02_wraps_equipped.png`).

### 6. Baron Quadzilla's hidden trait (4/10, "before" only)
- **The boss node is a blank.** Hovering it while standing next to it gives "??? Unknown. Step on it to find out what waits there." It sits
  in front of a giant painted squat rack and statues (`boss_00_hover_node.png`). The map has already told the player it's the boss, so the
  hover text should say so too.
- **The pre-fight panel is a wall of rules.** It lists six rules in four colours with no legend (`boss_01_prefight.png`). One of them
  ("Processing Time: The first Necrocrat unit...") doesn't apply to my Beefcake deck at all. The "Hidden trait ?: Something happens in this
  fight you haven't seen yet." teaser is a good idea, but it is the sixth line and easy to miss.
- **The panel's promise wasn't kept in the fight I saw.** It says "the same icons stay on screen during the fight", but my `dev encounter`
  fight showed no rule icons on the board (`fight_00_hover_draught.png`). That may be because it was a debug encounter.
- **The Baron starts ahead and the fight reads as hard.** He starts with 2 Iron (x2 at the top right). In the encounter fight he reached 7
  energy by turn 10 and killed me from 15 HP while staying at 13/13 himself (`fight_04_t10.png`). The pilot played badly, so this says little
  about balance.
- **After the special move: not observed** (see How I played).

## Top 10 problems (ranked by impact)

1. **Item effects aren't shown on the HUD.** The Energy Draught's +1 energy never appears on the energy counters, which still read x0
   (`fight_01_used_draught.png`). *Fix:* show the bonus on the Path's energy counter (for example "x1" with a gold "+1" pip) and pulse it.
   Do the same for every item buff.
2. **Unvisited dungeon maps give no information.** Every node is "?"/"???", even the boss (`dungeon_iron_first.png`,
   `boss_00_hover_node.png`). *Fix:* show node-type icons (fight, shrine, chest, boss) before the first visit, keep names hidden, and always
   name the boss node ("Boss: ???" at the least).
3. **The hat preview doesn't show the player wearing the hat** (`hats_01_preview.png`). *Fix:* render the hero (or the portrait cut-out)
   wearing the hat in the preview panel, and rotate it on hover.
4. **The item reward is hidden.** "Received: Power Wraps" pops up behind the dialogue box, before Tilly announces it (`tilly_02_talk1.png`).
   *Fix:* show the toast after the "freebie" line, above the dialogue box, with the item icon and a sound.
5. **Escape behaves differently on each screen.** It doesn't close the Character page, but opens pause in battle
   (`char_03_escape_no_close.png`). *Fix:* make Escape close the top-most panel everywhere, and open pause only when nothing else is open.
6. **The boss pre-fight panel is overloaded, and the hidden trait is buried in it** (`boss_01_prefight.png`). *Fix:* group the rules into
   "Helps you" and "Helps him", drop rules that don't apply to the player's deck, and give the hidden trait its own highlighted box.
7. **A used item slot looks like an empty one** (`fight_03_after_empty.png`). *Fix:* show a used state: the item art greyed out with a
   "Used" or "0" badge until the battle ends.
8. **Quest directions describe menu paths instead of keys.** "Menu > Character > Items" appears in the tracker, in Tilly's lines and in
   Bertram's step. *Fix:* say "Press C (Character) > Items" and show the key prompt, plus the pad button when a controller is in use.
9. **The hat shop's layout jumps and it has no clear way to take a hat off** (`hats_00_shop.png` vs `hats_03_off.png`). *Fix:* use
   fixed-width cards, split Hats and Cloaks into tabs, and add a "Take off" button on the equipped hat's card. Give "Equipped" a gold
   checkmark style instead of the disabled grey.
10. **Empty gear slots look like owned gear, and Bertram's nameplate is cut off** (`char_04_gear_unlocked.png`,
    `bertram_00_nameplate.png`). *Fix:* show empty slots as dark outlines with a "+", reserve the ghost icons for nothing, and shrink the
    nameplate font (or shorten the title) so the whole name fits.
