# Character page - layout spec (Overnight Nov 3-4, Part C)

Target: `docs/ui/ref/character_menu_target.png` (1585 x 992). Current: `docs/ui/ref/character_menu_current.png`.
All positions below are in the game's 1920 x 1080 design space (the target scaled x 1.211 horizontally, x 1.089 vertically;
the target is not 16:9). The page is `CharacterScreen` (ui/town/character_screen.gd), an `OverlayScreen`; the layout constants
live in `CharacterPage` (ui/town/character_page.gd) so tests and the shot tool can read them.

No new art: the background is `UI-BG-CHARACTER` (cropped twice, see 1), panels are `UIStyle.box` dark translucent boxes with a thin
gold border (the same colours as `UiSkin` panels), icons are the existing `ICON-*` / game-icons, fonts are `UIStyle.font_title()` /
`font_bold()` / `font_italic()`, the Path colours are `UIStyle.affinity_color`.

## 1. Page frame

| Element | Target | Ours (1920 x 1080) | Data |
|---|---|---|---|
| Backdrop | dark room, parchment poster on the left | `UI-BG-CHARACTER` region x 836-1536 (the wall, map, candle) cover-fitted and dimmed to 45 % behind everything | - |
| Parchment poster with the silhouette | x 0-545, y 0-940 | `UI-BG-CHARACTER` region (245, 0, 590, 760) drawn at (10, 95), scale 1.1 -> 649 x 836 | - |
| Page title | "CHARACTER", top-left, gold serif, ~60 px | `CHARACTER` at (52, 18), 64 px title font, gold, dark outline | constant |
| Close button | round X, top-right | the OverlayScreen close button (Esc), top-right | - |

The OverlayScreen's own header title is hidden (the page title replaces it) so it is never clipped ("TER" in the current shot).

## 2. EQUIPMENT (on the poster, no panel)

| Element | Target | Ours | Data |
|---|---|---|---|
| Helm slot | (300, 165) 100 px | centre (363, 200), 124 px square | `PlayerProfile.equipped_in(HELM)` |
| Armor slot | (300, 330) | centre (363, 400) | `equipped_in(ARMOR)` |
| Weapon slot | (160, 485) | centre (193, 590) | `equipped_in(WEAPON)` |
| Relic slot | (440, 485) | centre (533, 590) | `equipped_in(RELIC)` |
| Boots slot | (300, 750) | centre (363, 860) | `equipped_in(BOOTS)` |
| Slot label | "Helm" etc. under each slot, 20 px parchment with outline | 22 px bold, 10 px under the slot | slot name |
| Slot content | lock icon (locked), the piece's icon (equipped), empty frame (open) | `UiSkin.equip_slot_style` frame + `IconArt.equipment_glyph` / `ICON-LOCK` | `has_equipment_slot`, `equipped_in` |
| Unlock pill | "Equipment unlocks after the armory quest", (85-505, 858-898) | (105, 935) 505 x 48 pill, 22 px: **"Equipment unlocks after Some Assembly Required"** (the real quest, `QuestDefinitions.ARMORY`); hidden once unlocked | `Session.flag("armory_unlocked")` |

Click a slot (unlocked) -> the **Equipment selection page** (5). A locked slot shakes and says where it unlocks.

## 3. LEVEL panel (middle column, top)

Panel (672, 95) 412 x 420, dark translucent, 2 px gold border, 14 px corners.

| Element | Target | Ours | Data |
|---|---|---|---|
| Star + "Level 3" | (590-750, 105-145), 34 px | star `ICON-LEVEL` 44 px + "Level N" 40 px title font at (24, 18) | `profile.level` |
| "30 / 80 XP" | under it, 20 px | (70, 66) 22 px | `profile.xp` / `ProgressionTable.row(level+1).xp_to_reach` ("Max level" at 30) |
| XP bar | full width, gold | (24, 100) 364 x 22, `UiSkin.skin_bar(..., "xp")` | same |
| Divider | thin gold line | 1 px gold 40 % at y 138 | - |
| HP row | heart, "HP", "13 / 16" right | y 150, icon `ICON-HP` 26 px, 24 px text | `Session.hp_run()` HP in a run, else max / max |
| Opening hand | cards icon, "5" | y 186 | `profile.opening_hand_size` |
| Max hand | "10" | y 222 | `profile.max_hand_size` |
| Gold | coin, "250" | y 258 | `Session.gold` |
| Divider | | y 296 | - |
| PATH ESSENCE heading | gold caps 22 px | (24, 308) | - |
| Essence row | four flasks + amount | y 345: four `ICON-ESSENCE-*` 36 px + amount 24 px, tinted by `UIStyle.affinity_color` | `profile.essence_of(path)` |

## 4. CARD PACKS panel (middle column, bottom)

Panel (672, 530) 412 x 485.

| Element | Target | Ours | Data |
|---|---|---|---|
| Icon + "CARD PACKS" | (590-840, 505-545) | `ICON-UI-PACKS` 40 px + title 34 px at (24, 18), divider at y 76 | - |
| Empty state | "No unopened packs" 28 px centred + italic hint | centred at y ~200: "No unopened packs" 30 px + "Find packs in dungeons, quests and shops." 22 px italic muted | `profile.packs` |
| Packs | (not in target) | one row per pack kind: pack name, "x N", **Open** button (opens `PackOpeningScreen`); scrolls | `PackCatalog`, `profile.pack_count` |

## 5. ITEMS panel (right, the visual focus)

Panel (1112, 95) 775 x 920 - the largest panel, with an **accent border** (3 px bright gold) and a soft gold **glow** (StyleBox shadow,
cheap enough for Low-end).

| Element | Target (target px) | Ours (inside the panel) | Data |
|---|---|---|---|
| Icon + "ITEMS" | (960-1135, 108-145) | `ICON-UI-ITEMS` (fallback item bag) 48 px + "ITEMS" 44 px at (28, 20) | - |
| Subtitle | "Equip up to 4 single-use items" | (90, 72) 22 px | constant (4 = `ProgressionTable.row(MAX_LEVEL).item_slots`) |
| Divider | y 182 | y 110 | - |
| "EQUIPPED" + "1 / 2 unlocked" | (957, 208) / right | (28, 124) 26 px gold caps; right-aligned "x / 4 unlocked" = equipped count / item_slots | `profile.equipped_count()`, `profile.item_slots` |
| Four slots | 4 x 130 x 110 at y 237-345 | 4 x 162 x 140, gap 22, at y 165; number (1-4) top-left | `profile.item_in_slot(i)` |
| - equipped | icon + "x2" badge, name below | icon 84 px centred, charge badge bottom-right (`ItemBar.charge_badge`), name under the slot (20 px) | `item_uses_left` |
| - empty | "+" and "Empty slot" | a big "+" 48 px, "Empty slot" | - |
| - locked | lock, "Level unlock" | `ICON-LOCK` 56 px, label "Level 6 unlock" / "Level 12 unlock" | `ProgressionTable` first level with `item_slots > i` |
| - selected | gold 3 px frame | 3 px bright gold border on the slot (or inventory cell) chosen | - |
| Note | two italic lines centred | y 340: "Additional slots unlock as you level up. One charge is consumed per use." 20 px italic muted | constant |
| Divider | y 443 | y 400 | - |
| "INVENTORY" + "1 item type" | (957, 471) / right | (28, 414) 26 px; right "N item types" | `profile.owned_items.size()` |
| Inventory grid | 5 x 2 cells 105 x 100, scrollbar | 5 columns, cells 128 x 116, gap 12, in a ScrollContainer 712 x 252 (two rows visible, more scroll); empty cells shown as frames to fill two rows | `profile.owned_items` + `item_uses_left` |
| - cell | icon + "x2" badge, tick when equipped | icon 76 px, charge badge bottom-right, a gold tick top-left when equipped | `is_item_equipped` |
| Divider | y 733 | y 680 | - |
| Detail row | icon 85 px, name, "Single-use • 2 charges owned", "Equipped in slot 1" green, Unequip button | icon 100 px at (28, 696); name 30 px gold at (150, 692); "Single-use • N charges owned" 22 px; effect text 20 px (the item's description, two lines max); "Equipped in slot N" (green) / "Not equipped" (muted); button 190 x 62 at (557, 716): **Equip** / **Unequip** | `ItemData.display_name`, `description`, `item_uses_left`, `slot_of_item` |
| Empty detail | - | "Select an item to see what it does." | - |
| Divider + footer | "Select an item, then choose an empty slot to equip." italic | y 860 divider, footer at y 872, 20 px italic muted | constant |

Interaction:
- Click an inventory item: selects it (detail row). Then click an empty unlocked slot: equips it there. Or press Equip: first empty slot.
- Click an equipped slot: selects that item (detail shows it, the button reads Unequip).
- Click a locked slot: "Slot N opens at level L." toast.
- Every slot and cell is a Button: Tab / arrows / a controller move focus; confirm presses. `PadFocus.register(self)`.

## 6. Equipment selection page (Step 2)

Opened by clicking an unlocked equipment slot. It replaces the middle and right columns (x 672-1887, y 95-1015) with one panel in the
Items panel's style (accent border):

| Element | Ours | Data |
|---|---|---|
| Header | slot icon + "HELM" (etc.) 44 px; subtitle "Choose what you wear on your head" | slot |
| Back button | top-right of the panel, "Back" (Esc also goes back) | - |
| "OWNED" + "N pieces" | 26 px caps | `profile.owned_equipment` filtered by slot |
| Grid | 7 columns, cells 140 x 140, scrolls; equipped piece ticked | `EquipmentData` icon via `IconArt.equipment_glyph`, rarity border colour |
| Detail row | icon 110 px, name (rarity colour), rarity + tier line, effect text, "Equipped" / "Not equipped", Equip / Unequip | `source_name`, `description`, `GameSession.why_not_equip` (shown red when it cannot be worn: armory still closed) |
| Empty state | "You own nothing for this slot yet. Bertram's smithy and dungeon chests have gear." | - |

## 7. Visual rules (Step 3)

- Panels: `Color(0.07, 0.05, 0.12, 0.86)` fill, 2 px gold `UIStyle.GOLD_DIM` border (Items + Equipment page: 3 px `UIStyle.GOLD`
  + 18 px gold shadow at 25 %), 14 px corners; section headers in caps, 26 px, gold; 24-28 px inner margins.
- One divider style (1 px gold at 40 %). One footer/hint style (20 px italic muted).
- Fits at 1280 x 720 (the design space is scaled by the project's canvas stretch; minimum text 20 px -> 13 px at 720p) and
  1920 x 1080. Low-end mode: no shaders on the page; the glow is a StyleBox shadow.

## 8. Tutorials that point at this page (Part B5/B6)

`CharacterScreen.highlight(target)` pulses a gold outline on: `"items"` (the Items panel), `"inventory:<item id>"`, `"empty_slot"`
(every empty unlocked slot), `"equipment:<slot>"`, `"equip_grid:<piece id>"`. The tutorial steps call it while their quest step is open.

## 9. Result and critic pass (Step 4)

`docs/ui/ref/character_menu_result.png`: the target, then the early save, the mid save and the Equipment selection page (shots in
docs/overnight_shots/nov3/, play scripts docs/review/play_scripts/nov3_overnight.txt and nov3_mid.txt).

Element by element against sections 1-6 (all present). Gaps found and fixed before the re-shoot:
- the backdrop sat under the OverlayScreen's own dark shade (no poster) - now above it, below the header;
- the Boots label ran under the unlock pill - Boots moved up to y 835;
- the Equipment page was see-through over the panels and opened with nothing selected - the panels step aside, the first piece is selected;
- a two-line effect crowded the status line in the detail row - tightened;
- Power Wraps showed a white fallback glyph since the Nov 2 rename - it uses the Field Bandage painting (`IconArt.ITEM_ART_ALIASES`).
Left as is: the LEVEL panel's icon is our ICON-LEVEL (the target draws a star); the inventory scrollbar only appears past ten item types.
