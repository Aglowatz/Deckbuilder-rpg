# Card Packs page - redesign plan (Overnight Nov 7-8, Part 5.2)

Target look: the Character page and the Deck Station (`docs/ui/ref/nov8/target_style_*.png`) - dark panels with gold frames, caps headers in the
title font, painted icons, clear grouping. Built tonight with existing art (`ui/town/packs_screen.gd`); the planned background is
**UI-BG-PACKS** (already on the art list); until it arrives the page uses a dimmed crop of UI-BG-CHARACTER, like the Wardrobe.

## Layout (1920 x 1080 design space)

```
+--------------------------------------------------------------------------------------------------------------+
| CARD PACKS                                   7 unopened  ·  Foil Fenwick sells more on the square      [X]   |
+--------------------------------------------------------------------------------------------------------------+
| [pack icon] THE SHELF                                                                         7 packs        |
| ------------------------------------------------------------------------------------------------------------ |
|   +--------+     +--------+     +--------+     +--------+                                                     |
|   |  pack  | x3  |  pack  | x2  |  pack  | x1  | gilded | x1                                                  |
|   |  art   |     |  art   |     |  art   |     |  art   |                                                     |
|   +--------+     +--------+     +--------+     +--------+                                                     |
|   ======================== wooden shelf board ===========================                                    |
|   General Pack   Beefcake Pack   Gourmand Pack  Gilded Beefcake                                               |
|   3 cards, ...   3 cards, ...    ...            a sure Epic or Legendary                                      |
|   [  Open  ]     [  Open  ]      [  Open  ]     [  Open  ]                                                   |
+--------------------------------------------------------------------------------------------------------------+
|  [ OPEN ALL (6 packs) ]   Gilded packs (1) open one at a time on the shelf.                                  |
+--------------------------------------------------------------------------------------------------------------+
| [cards icon] LAST OPENED                                                     9 cards, 4 new                   |
| ------------------------------------------------------------------------------------------------------------ |
|  [card][card][card][card][card][card][card][card][card]   (hover or focus: the card whole, as at the Deck Station) |
+--------------------------------------------------------------------------------------------------------------+
```

- **Header:** the page title in caps (title font, gold, dark outline), the count of unopened packs, and where more come from.
- **The shelf (accent panel, gold frame):** every pack the player owns, its painted pack art large (PackArt at about 0.55 scale, ~165 x 240),
  standing on a drawn wooden shelf board; a gold count badge ("x3") at the art's corner; the pack's name and its one-line contents
  (`PackShop.describe`) under it; an **Open** button per pack. More packs than fit scroll sideways. Empty shelf: "No unopened packs. Free a zone,
  finish quests, or visit Foil Fenwick on the square."
- **Action bar:** **Open all** (every plain pack in one go, the existing summary grid); the gilded packs keep their own ceremony (the note says so).
- **Last opened (panel):** the cards from the most recent Open or Open all as a grid (NEW badges first, extra copies dimmed), with the
  Part 1.11 hover / focus zoom. Empty: "Open a pack to see its cards here."
- **Controller:** every Open button and result card is focusable; the first Open takes the focus.

## Images

| Id | Use | Status |
|---|---|---|
| UI-BG-PACKS | the page background: a merchant's back room with pack crates and a long wooden display shelf, warm lamplight, the shelf left empty for the UI | already on the art list (description updated tonight) |
| UI-PACK-SHELF | optional: a painted wooden shelf board strip (1600 x 120, transparent) to replace the drawn board | added to the art list (Part 9), low priority |

Everything else reuses existing art: the painted pack art (PACK-*), ICON-UI-PACKS, ICON-DECKBOX, the card frames.
