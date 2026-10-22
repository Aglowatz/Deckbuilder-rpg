# Card art crops (UI + economy fixes, Oct 22 2026, Part 3)

**What was wrong.** On the battlefield a card shows its art at 0.56 scale (CardView COMPACT) with a tall name plate across the top. The
art was a fixed crop (`CardArt.compact`: the middle 80% of the width from 4% down, zoomed in 1.25x) drawn *behind* the plate, so the
upper part of every painting - where the art style puts the subject's head - sat under the plate. Acid Vomitor's head, En
Garde-Manger's face and the Cake Golem's candles were hidden (`battle/battle_before.jpg`).

**What changed.**
- `CardArt.cropped(card_id, window, zoom, small)` / `CardArt.crop_region(...)`: every display cuts the painting for its own window, as
  large as fits, centred horizontally and placed so the painting's **focus** (default 0.3 of its height, the head of a portrait) sits in
  the middle of the window when it can - in practice the crop is anchored at the top of the painting instead of the centre.
- A battlefield card's art window now starts **below** its name plate (CardView `_art_window`), with a lighter 1.1x zoom.
- Full cards (hand, collection, vendors, rewards) show the whole 2:3 painting as before (the plate covers its clear top 10%, as the art
  style intends); they go through the same function, so a per-card override applies everywhere.
- The Deck Station slots (Part 2) use the same crop for the cover painting.
- **Overrides**: `data/art/card_focus.json`, card id -> `{"focus": 0-1, "zoom": >= 1}` (read by `CardArt.focus_for`).

**Review.** `bash tools/card_crop_sheet.sh <tag> [field,card,slot] [ids]` renders every card and token (341) at each display size:
`sheets/field_*.jpg` (battlefield, real 0.56 size), `sheets/card_*.jpg` (full card), `sheets/slot_*.jpg` (Deck Station slot). All
pages were reviewed after the change: with the new default every head and main subject is in view, including the three known bad
cards (`battle/battle_after.jpg`), so **no override was needed** and the JSON ships empty. A few paintings put the head at the very top
edge of the picture itself (Portal Ripper, Flex on 'Em, Hulking Hauler, Grandmaster Flex); the crop already starts at that edge, so no
focus value can show more of them.
