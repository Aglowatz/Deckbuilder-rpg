# Info screen style guide (The Wayward Path)

Written Nov 19 2026 (Fable Nov 19, Part 4). A proposal: **one look for every information screen** (the pause / main menu, settings,
the quest log, the glossary, feats, credits, save slots, the map's frame, the quest box in the corner, tooltips and pop-ups), so they
sit with the painted world and with the gold-framed battle and shop screens. Mock-ups: `docs/overnight_shots/nov19b/ui_mockups/`
(made by `python tools/ui_mockups_nov19.py` from art already in the game; **magenta dashed boxes mark new art** asked for in Batch 18).
The screens as they are today: `docs/overnight_shots/nov19b/ui_now/`.

Nothing in this guide is built yet except the small fixes listed at the end.

## The idea in one line

**A storybook page in a gilt frame.** Reading happens on warm parchment in dark ink; the frame is dark walnut with gold filigree
corners; titles ride a crimson ribbon; the one thing you most likely want is a gold button, everything else is a wood button. Only
things that float over the picture (tooltips, the dialogue box, toasts) are dark with pale text.

| Mock-up | File |
|---|---|
| The quest box (top left) | `ui_mockups/mock_quest_box.jpg` |
| The pause / main menu | `ui_mockups/mock_main_menu.jpg` |
| The quest log | `ui_mockups/mock_quest_log.jpg` |
| A tooltip | `ui_mockups/mock_tooltip.jpg` |
| A settings page | `ui_mockups/mock_settings.jpg` |

## Why this, and not the panels of today

The screens as they are (`ui_now/`): a full-screen parchment backdrop with painted leaf corners, and on it a smaller dark panel that
holds the text.
- **The panels disagree.** The pause menu and the pop-ups are a violet panel; settings, the glossary and the map legend are walnut;
  the quest log is the painted book with a walnut slab laid over its right page; the quest box is a walnut plate.
- **The reading surface is the wrong one.** The parchment (the best surface for reading) is used as empty margin, and the text sits
  in pale letters on dark wood; secondary text (unknown steps, counters, hints) is dimmed further and gets hard to read.
- **Rows have no shape.** Settings are a label and a nameplate with nothing tying them together; tabs are small plates; the scroll
  bar is the engine's grey line.
- The battle board and the shops already say "gold frame, wood, parchment"; the menus only half say it.
- The art for most of it exists: `UI-PANEL-MAIN`, `UI-PANEL-POPUP` (with its ribbon), `UI-BG-QUESTLOG`, `UI-BG-WORLDMAP`,
  `UI-NAMEPLATE`, the two buttons. What is missing is small connective pieces (rows, tabs, a divider, a scroll bar, button states).

## Building blocks

| Block | Look | Art today | New art (Batch 18) |
|---|---|---|---|
| **Page** | parchment in a walnut and gold frame; 9-slice, corners never stretched | `UI-PANEL-MAIN` (stands in) | `UI-INFO-PAGE` 1536x1024, margins 128 |
| **Header ribbon** | crimson ribbon with gold trim, overlapping the page's top edge by a third of its height | the ribbon of `UI-PANEL-POPUP` | `UI-INFO-RIBBON` 1024x192, margins 176 left/right |
| **Divider** | thin gold rule, one diamond flourish in the middle | none (a grey line) | `UI-INFO-DIVIDER` 1024x48, margins 160 left/right |
| **Row plate** | a slightly darker strip of parchment, hairline border; gold border when chosen | `UI-NAMEPLATE` (stands in) | `UI-INFO-ROW` 3 x 1024x128, margins 48 |
| **Tabs** | bookmark tabs on the page's top edge: active = parchment, inactive = walnut | none (text buttons) | `UI-INFO-TAB` 2 x 384x128, margins 56 |
| **Buttons** | gold = the main choice (one per screen), wood = the others | `UI-BTN-PRIMARY`, `UI-BTN-SECONDARY` | `UI-INFO-BTN-STATES` hover / pressed / disabled, 6 x 1024x235, margins 110 / 60 |
| **Scroll bar** | walnut groove, gold grip with a diamond | none (the engine's grey bar) | `UI-INFO-SCROLLBAR` rail 48x512, grip 48x160 |
| **Quest box** | a small parchment note pinned top-left, a walnut header strip | none (a dark box) | `UI-QUESTBOX` 768x512, margins 96 / 88 / 64 / 64; `UI-QUEST-MARKS` 6 x 128 |
| **Tooltip** | near-black walnut, hairline gold border, soft shadow | `UI-PANEL-TOOLTIP` | `UI-INFO-TOOLTIP` 640x320, margins 44 |
| **Map frame** | walnut and gold frame, compass in a corner, transparent middle | `UI-BG-WORLDMAP` under the map | `UI-MAP-FRAME` 2048x1152, margins 176 |

## Type

Two families, as now: **Cinzel** (titles, tabs, buttons, quest names) and **Alegreya Sans** (everything you read).

| Use | Font | Size at 1080p | Colour on parchment | Colour on dark |
|---|---|---|---|---|
| Screen title (on the ribbon) | Cinzel bold | 34 | - | cream `#FFECBE` with a 1 px dark red shadow |
| Section heading | Cinzel bold | 24 | ink `#3A281C` | gold `#F4CE78` |
| Row label, body text | Alegreya Sans | 21 (never under 18) | ink `#3A281C` | cream `#F0E8D6` |
| Secondary text (a step done, a hint) | Alegreya Sans | 18 | soft ink `#68523C` | grey `#BEB4A0` |
| "What next" line, place names | Alegreya Sans italic | 18 | copper `#8A4A22` | gold `#E0B45C` |
| Button label | Cinzel bold | 22 | dark brown on gold, cream on wood | - |
| Tooltip title / body / example | Cinzel 22 / Alegreya 19 / italic 16 | | - | gold / cream / grey |
| Key hints at the foot of a page | Alegreya Sans | 18 | soft ink | grey |

The Text size switch (Normal, Large, Larger) scales all of these together, as today. A Path's name or number takes the Path's `ink`
colour on parchment and its `text` colour on dark (`docs/art/path_colour_guide.md`).

## Spacing (an 8 px grid at 1080p)

- Page padding: 48 px inside the frame's inner edge (24 px on the small quest box and tooltips).
- Rows: 54 px tall, 8 px apart; a label starts 24 px in; its control ends 24 px before the row's right edge and is 330 px wide.
- Sections: heading, 16 px, rows; 24 px and a divider between sections.
- Buttons: 62 px tall (the gold one 70), at least 200 px wide, 16 px apart, bottom right of the page; "back" is always Esc / B and
  is written in the key hints at the bottom left.
- Tabs: 44 px tall, 8 px apart, starting 24 px in from the page's left edge; Q / E (LB / RB) change tab.
- Scroll bar: 16 px wide, 16 px in from the page's right inner edge; lists fade out over their last 24 px rather than cutting a row.
- Width: a reading column never wider than 720 px (about 75 characters at 21 px); a wide page uses two columns (the quest log).

## Each screen

- **Quest box:** 430 to 440 px wide, grows downward to at most 5 lines, then "... 2 more". Header strip: tag (MAIN gold, SIDE walnut),
  quest name. Done steps keep a red seal and soft ink; the current step is bold; unknown steps are "???" with an empty ring. The
  "next" line at its foot is the same sentence the map's goal pointer uses. Hidden in battles and menus, as now.
- **Pause / main menu:** one narrow page (560 px), the ribbon says PAUSED, the first line says where you are and how long you have
  played; Resume is the gold button; a divider separates leaving the game from everything else.
- **Settings:** a wide page (1120 px), tabs across the top, one row plate per setting with the label left and the control right
  (choices as a nameplate with arrows, numbers as a gold slider, switches as a toggle), sections under headings. Defaults (wood) and
  Done (gold) bottom right.
- **Quest log:** the painted book stays. Tabs Main / Side / Done on the left page's top edge, row plates for quests (name, step count,
  tag), the right page for the chosen quest: place in copper italics, the story line, the steps with the same marks as the quest
  box, the reward, Track (gold) and Show on map (wood).
- **Map frame:** the map itself fills a transparent-centred frame; the legend becomes a parchment card overlapping the frame's right
  side, row plates for "Point me to..." goals.
- **Tooltips:** always dark, at most 440 px wide, title in gold, the kind of thing ("Keyword", "Item", "Rule") in grey italics on the
  right, body, then an example in italics. They never cover the thing they explain (above it, or beside it at a screen edge).
- **Pop-ups** (rewards, level-ups, confirmations): `UI-PANEL-POPUP` as today (it already is this look); they take the new ribbon
  and button states when those exist.

## What was applied now (no new art needed)

Only the quest box's readability (before: `ui_now/now_hud_quest_box.jpg`, after: `p4_after_quest_box.jpg`):
- body text 18 px and the current step 19 px (they were 16 and 17), step marks 18 px, the MAIN / SIDE tag 15 px (13);
- unknown steps ("???") and the "2 of 6" pager are no longer half see-through (82-85 % instead of 50-55 %), done steps 92 %;
- 380 px wide instead of 340, so a step wraps onto fewer lines.

Everything else waits for the owner's yes to the look (it changes every menu).

## New art (Batch 18)

Eleven rows in `docs/art/batch18_nov18.csv` (ids `UI-INFO-PAGE`, `UI-INFO-RIBBON`, `UI-INFO-DIVIDER`, `UI-INFO-ROW`, `UI-INFO-TAB`,
`UI-INFO-BTN-STATES`, `UI-INFO-SCROLLBAR`, `UI-QUESTBOX`, `UI-QUEST-MARKS`, `UI-INFO-TOOLTIP`, `UI-MAP-FRAME`), each with its exact
size, its 9-slice margins and a self-contained description. Until they arrive every screen can be built with the stand-ins the
mock-ups use; the new pieces then drop in by id.

---

# Nov 21: two new directions, with the four Paths' colours (design only)

The owner turned down the Nov 19 look above (too brown): he wants **more colour, from the four Paths** (Beefcake red `#E0321F`,
Gourmand blue `#5AAAF2`, Refusemancer moss green `#58933B`, Necrocrat violet `#9A5FC7`), still painted and storybook. Two directions
follow, each drawn as the same five screens. **Nothing is built and no art is asked for until one is picked.** The 11 info-screen
rows of Batch 18 are on hold. Mock-ups: `docs/overnight_shots/nov20/ui_mockups_v2/` (made by `python tools/ui_mockups_nov21.py`; the
drawn surfaces are flat stand-ins for painted ones).

| Screen | Direction A "Patchwork" | Direction B "Stained glass" |
|---|---|---|
| The quest box | `a_quest_box.jpg` | `b_quest_box.jpg` |
| The pause / main menu | `a_main_menu.jpg` | `b_main_menu.jpg` |
| The quest log | `a_quest_log.jpg` | `b_quest_log.jpg` |
| A tooltip and a pop-up | `a_tooltip.jpg` | `b_tooltip.jpg` |
| A settings page | `a_settings.jpg` | `b_settings.jpg` |

Both share three rules, so either can be built the same way:
- **Colour means a Path, wherever a Path is meant.** A quest wears its zone's colour, a keyword its Path's, a rule's pop-up its
  rule's. The Path icon always sits beside the colour (colour is never the only signal).
- **One gold thing per screen:** the action you most likely want.
- **No pale grey text.** Secondary lines are a darker or lighter tint of the page's own colour; unknown quest steps are italic, not dim.

## Direction A: Patchwork (a linen page in a quilt border)

The kingdom's name made into the frame. Reading happens in **dark ink on cream linen**. The border is four cloths, one per Path
(red on top, blue right, green below, violet left), joined by a visible cream running stitch, a gold button sewn on every corner.
Titles ride a cloth banner; tabs, tags, keywords and rewards are **sewn patches** in their Path's cloth; a selected row gets a thick
border in its colour and a gold-thread tab. A screen that belongs to one Path (a zone's quest box, a rule's pop-up) is bound in that
one cloth all round.
- For it: the warmest and the closest to the story ("a patchwork is strongest at the seams"); dark text on a light page is the most
  readable at Large text; the colours are strong but only at the edges, so long reading stays calm; it sits well beside the painted
  world's warm light.
- Against it: it is the gentler change, and the cream page is kin to the parchment he turned down; cloth can read as cosy rather
  than grand next to the gold-framed battle board.
- New art it would need (about 12 pieces): the quilt page (9-slice), four cloth swatches for tabs, tags and rows (one per Path, plus
  a plain one), the banner, a stitched divider, two cloth buttons with their states, a scroll bar, the corner button.

## Direction B: Stained glass (a night page in a leaded gold frame)

The four Paths as glass. The page is **deep night blue with pale lettering**, framed in lead and gold. Along the top runs a strip of
eight small panes in the four colours (or one colour for a one-Path screen). Tabs, tags, keywords, rows and buttons are **panes of
coloured glass**: dull when idle, lit from behind when chosen or hovered. The pause menu carries a small rose window of the four
Path icons. Sliders and switches fill with lit glass.
- For it: by far the more colourful, and the colours glow; it is the bigger break from the brown look; it matches the dark
  tooltips, the dialogue box and the battle HUD the game already has, so fewer surfaces disagree; "lit means chosen" is a clear rule
  for controller focus.
- Against it: pale text on dark is a little harder to read in long lists (the quest log's descriptions, the glossary); it leans
  towards a cathedral, and the Capital already owns that mood; glow must be held back or every screen shouts.
- New art it would need (about 12 pieces): the night page with its leaded frame (9-slice), the top strip, a glass pane in two
  states (9-slice, tinted in code to any Path colour), the rose window, a divider, two glass buttons with their states, a scroll bar.

## What to look at when choosing

- The quest log (`a_quest_log.jpg` against `b_quest_log.jpg`) shows the real difference: ink on linen against light on night.
- The quest box is on screen for the whole game: which one do you want in the corner for twenty hours?
- In both pause menus the buttons carry a Path colour and icon only as decoration (the Quest Log is not "the Gourmand page"). If
  that misleads, the buttons become plain (cloth-brown in A, slate in B) and colour stays where it means a Path.

**Recommendation:** B for the menus that float over the game (pause menu, quest box, tooltips, pop-ups), because it is the colourful
change that was asked for and agrees with the dark HUD; if long reading on dark worries you after seeing it, a mix is possible (B's
frame and panes round A's linen page for the quest log and the glossary). Say A, B or the mix.

---

# Nov 20: direction B, "Stained glass", is built

The owner chose B. Every information screen wears it since Fable Nov 20 day (Part 2), with the Batch 18 pieces.

**One theme, one place:** `ui/glass/glass_theme.gd` (`GlassTheme`). `GlassTheme.theme()` is a Godot Theme built once from the art; a
screen takes the look with `GlassTheme.apply(root)` (a whole-screen page sets `glass = true` on its `OverlayScreen`). The 9-slice
margins, the colours and the sizes are constants at the top of that file and nowhere else; Path colours come from
`core/data/path_palette.json`. A later change to the look is a change to that file.

| Piece | Used for |
|---|---|
| `UI-INFO-PAGE` | the page of every info screen |
| `UI-GLASS-STRIP` | the strip of Path panes along the top of a page (a quest's box shows eight lit panes in its zone's colour) |
| `UI-GLASS-PANE`, `-LIT` | rows, tabs, tags, choice lists; lit = chosen (grey art, tinted in code) |
| `UI-BTN-AMBER` | the one main action of a screen (`PrimaryButton`) |
| `UI-BTN-GLASS` | every other button, slate (grey art, tinted in code) |
| `UI-ROSE-WINDOW` | the top of the pause menu |
| `UI-INFO-DIVIDER` | either side of a page title, and between sections |
| `UI-QUESTBOX`, `UI-QUEST-MARKS` | the quest box in the corner; the step marks there and in the quest log |
| `UI-INFO-TOOLTIP` | hover tooltips, confirm pop-ups, notices, the reward box |
| `UI-MAP-FRAME` | round the map on the full map screen |
| `UI-SCROLL-RAIL`, `-GRIP` | every scrolling list |

**Screens:** the pause menu, settings (all five tabs), the glossary, feats, save and load, credits, the quest box, the quest log, the
map screen, the Collection Book's page, tooltips, the confirm pop-ups and notices (the sealed-card and too-many-Paths pop-ups, the
buy-anyway question), the reward box. **Left alone:** the battle board and its HUD, the shops' and the Deck Station's gold-framed
screens, the dialogue box, the title screen's own menu.

**Colours** (`GlassTheme`): page `#221E42`, body text `#F2ECDD`, secondary text `#BDB9EC` (a lighter tint of the page, never grey),
headings `#F4CE78`, slate glass `#66739C`, lit slate `#C9D6FF`, ink on lit glass `#17132B`. Contrast, measured on the real art by
`tests/ui/test_glass_theme_nov20.gd`: `docs/review/glass_contrast.txt` (body text 12.9:1 on the page; the lowest body pair is 5.2:1).

**How the rules are kept:** a quest wears its zone's Path colour with the Path's icon beside it (`QuestLogScreen.quest_path`); a pane
that stands for no Path is slate; a dangerous button (Quit Game, Delete) is slate glass with a warm label, because a red pane would
say "Beefcake"; one amber button per screen (Resume, Done, Track, Point me to..., the newest save to load; for a dangerous question
the safe answer); a step not yet known is italic, a feat not yet earned is italic in the secondary tint; tabs are toggles and the
chosen one is the lit pane; the keyboard / controller focus is a gold ring round the lit piece.

**Not coloured by Path yet:** the glossary's keywords (the data gives a keyword no Path) and the Settings tabs (they stand for no
Path, so they are slate; the mock-up had coloured them as decoration). Before / after shots: `docs/overnight_shots/nov20b/ui_before/`
and `ui_after/` (1280x720: `ui_after_1280x720/`; controller and Larger text: `ui_pad_large/`).
