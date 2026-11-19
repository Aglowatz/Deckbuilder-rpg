# Path colour guide (The Wayward Path)

Written Nov 19 2026 (Fable Nov 19, Part 3). **One official colour per Path, everywhere a Path is shown by colour.** It is the colour
companion of `docs/art/path_icon_style_guide.md`: the icon says which Path, the colour agrees with the icon.

- The palette lives in **one file: `core/data/path_palette.json`**. Change a hex value there and every screen follows.
- Code reads it through `PathPalette` (`core/data/path_palette.gd`); `UIStyle.affinity_color()` is the same table.
- Swatches: `docs/art/path_colour_swatches.png` (made by `python tools/path_palette_check.py`, which also prints the colour-blind check).

![swatches](path_colour_swatches.png)

## The palette

| Path | Main | Accent | Text on dark | Ink on parchment | In words |
|---|---|---|---|---|---|
| **Beefcake** | `#E0321F` | `#E0A030` | `#F26A54` | `#A3200F` | strong red, gold accent (the gold arm on the red disc) |
| **Gourmand** | `#F0C494` | `#C06A3A` | `#F5D3AC` | `#8A4A22` | warm cream, copper accent (the white hat on cream in a copper rim) |
| **Refusemancer** | `#58933B` | `#B5552D` | `#86BE64` | `#3F6B26` | deep moss green, rust accent (the leaf in rust arrows) |
| **Necrocrat** | `#72E55B` | `#55606A` | `#9BEF88` | `#2C5E55` | bright ghost green, slate accent (the skull in green flame on slate) |
| *Colorless* | `#B8A98A` | `#4C4441` | `#CFC3A8` | `#5A5046` | stone (unchanged) |

Roles:
- **main**: bars (the essence tracker), borders, glows, map and quest markers, battle effects, filter chips, the hero's outline behind a wall.
- **accent**: the second colour where a place uses two (a bar's highlight line, a rim, a dual trim). Never used alone to mean the Path.
- **text**: small text on the dark panels (a lighter step of the main; red and moss are too dark for 14 px text at full strength).
- **ink**: text and thin lines on parchment (a darker step of the main).
- **frame**: the cloth tint of the tinted card frames (`CardView`), kept exactly as it was so the cards do not change.

## Why these

1. **They are the icons' own colours.** The approved medallions are red and gold, cream and copper, moss and rust, ghost green on
   slate; the card frames, card backs, packs and plinths are painted the same way. Only the UI's tints disagreed: Gourmand was **blue**
   (`#4A8FE0`) and Necrocrat **violet** (`#9A5FC7`), colours that appear on no Gourmand or Necrocrat picture.
2. **The card frames change least:** not at all. The frames are painted art and already agree; the frame cloth tints stay as they were.
3. **Two greens are told apart by brightness, not by hue.** Refusemancer is a deep, earthy moss; Necrocrat is a bright, glowing ghost
   green, and each always comes with its accent (rust for the moss, slate for the ghost green) and its icon.
4. **Colour-blind check** (`tools/path_palette_check.py`; the smallest difference between any two Paths, CIE Lab units; under about 10
   two colours are hard to tell apart at a glance):

   | Palette | Normal | Protanopia | Deuteranopia | Tritanopia |
   |---|---|---|---|---|
   | UI tints until today (red, blue, green, violet) | 40 | 14 | **9** | 18 |
   | The icons' paint taken literally | 36 | 22 | 13 | 23 |
   | **This palette** | 38 | 22 | **21** | 29 |
   | Option 2 (Necrocrat as ghost teal) | 47 | 21 | 21 | 33 |

   The hard pair for red-green colour-blind players is Beefcake red against Refusemancer moss (21); that is why the red is a little
   brighter and the moss a little deeper than on the icons. Colour is never the only signal: the Path icon is always beside it.
5. **Readable on both backgrounds:** each main is at least 3.9:1 on the dark panel (`#1C1722`), each ink at least 4.6:1 on parchment
   (`#E9DCBF`); small text uses the `text` step (5.5:1 or more on dark).

## Option 2, if you prefer more distance between the two greens

Necrocrat as **ghost teal** (`main #7EE5CB`, `text #A5F0DD`, `ink #25605A`): further from the moss for normal vision (47 against 38),
the same for colour-blind players. It agrees a little less with the icon's flame, which is a yellow-green. **Recommended: the palette
above (ghost green)**; to try option 2, copy the three values from `"alternatives"` in the JSON file over Necrocrat's.

## Where each colour is used (the audit)

In code, every row reads the palette (before this pass the "was" column):

| Place | File | Was | Now |
|---|---|---|---|
| The UI's Path tint (text, borders, glows; about 60 call sites) | `ui/ui_style.gd` `affinity_color()` | own table: red, **blue**, green, **violet** | `PathPalette.main` |
| Alembic: jar rows, essence orbs, essence bars, the two-Path recipe | `ui/town/alchemist_screen.gd` | through the UI tint (blue / violet bars) | main; the bar's top line is the accent |
| Essence toasts | `app/toast_layer.gd` | UI tint | main |
| Card frames: cloth tint of tinted frames | `ui/card/card_view.gd` `FRAME_CLOTH` | own table (already the icon colours) | `PathPalette.frame` (same values) |
| Card accents, cost pips, pip dots | `ui/card/card_view.gd` | UI tint | main |
| Battle board: play, attack, buff and death effects; infrastructure glow; resource buttons | `ui/battle/battle_board.gd`, `battle_hud.gd`, `battle_screen.gd` | UI tint | main |
| Deck filters (the Path chips) | `ui/town/card_filter_bar.gd` | UI tint | main |
| Deck Station racks, the Deck box | `ui/widgets/deck_rack.gd` | UI tint | main |
| Character page essence counts | `ui/town/character_screen.gd` | UI tint | main |
| Collection Book progress bars | `ui/town/codex_screen.gd` | UI tint | main |
| Pack shop covers, pack glow, pack opening | `ui/town/pack_shop_screen.gd`, `core/data/pack_definitions.gd` `PATH_COLORS`, the packs' `art_color` | own table: orange, **yellow**, green, **violet** | main (path packs take the palette at load: `PackData.tint()`) |
| Zone title cards | `ui/screens/zone_title_card.gd` | the packs' table | main |
| Boss intros (the name band) | `core/dungeon/boss_intros.gd` `PATH_COLORS` | own table: orange, **yellow**, green, **violet** | main |
| Path choice in dungeons (element offers) | `ui/dungeon/element_choice_screen.gd` | UI tint | main |
| Memory screen (the four Paths) | `ui/screens/memory_screen.gd` | UI tint | main |
| The ending's Path row; the cutscene's Beefcake speaker | `core/dungeon/ending_defs.gd`, `ui/dungeon/cutscene_screen.gd` | hex in data | main |
| Map: the hero's Path tint, zone portals | `world/town_scene.gd`, `world/zone_portals.gd` | UI tint | main |
| Corrupted NPC glow, springs, vault levers | `world/town_scene.gd`, `world/vault/vault_lever_event.gd` | UI tint | main |
| The crest texture's four fields | `world/kit/kit_textures.gd` `PATH_COLORS` | red, yellow, **blue**, **violet** | the ring of four mains |
| The Lab's four tanks, the castle's district lights | `world/dungeon_backdrop.gd` | two own lists (yellow, **violet**) | the ring of four mains |
| The hero's outline behind a wall (Part 1) | `world/sprites/world_sprite.gd` `outline_color` | new | the hero's Path main, lightened |

A test (`tests/core/data/test_path_palette.gd`) keeps it so: the file has the five rows and every role, the old blue and violet are
gone from the code, and the listed files hold no Path colour table of their own.

## Painted art

Painted art that already agrees (no change): the four energy medallions, the four essence flasks, the card frames, the Beefcake,
Gourmand and Refusemancer card backs and packs, the four gilded packs, the four plinths, the resource icons.

Painted art in the wrong colours (Batch 18 rows in `docs/art/batch18_nov18.csv`):

| File | What is wrong | Right colours |
|---|---|---|
| `UI-CARDBACK-N` | its field is the same deep green as the Refusemancer back; side by side the two backs read as one Path | slate grey field, ghost-green glow, pale bone trim |
| `UI-PACK-N` (and `UI-PACK-LOCKED-N`) | the wrapper is the same green as the Refusemancer pack | slate wrapper, ghost-green glow |
| `V-ALEMBIC` (her portrait) | her two flasks and the splashes on her apron are red, yellow, **blue** and **violet** | red, cream-copper, moss green, ghost green |
| `VS-ALEMBIC` (her shop picture) | the four jars are **blue**, red, orange and green, the cauldron's flame is violet and blue | four jars in the four Path colours, in the fixed order; a four-colour flame |

## Rules for new work

- A Path's colour is its **main**; never invent a fifth (no blue for Gourmand, no violet for Necrocrat: violet and blue belong to the
  regime, the rifts and the UI's own chrome).
- Where two Paths meet (a dual card, an Alembic recipe) show both colours side by side, first Path on the left; never a blend.
- All four together: the fixed order Beefcake, Gourmand, Refusemancer, Necrocrat (`PathPalette.ring()`).
- In code never write a Path colour as a hex value: ask `PathPalette` (or `UIStyle.affinity_color`).
