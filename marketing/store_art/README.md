# Store art (not part of the game)

Copies of the STEAM-* and ITCH-COVER images from `G:\My Drive\Card Game Art\Approved_KeyArt` (the Drive originals are untouched). This folder has a `.gdignore`
(Godot never imports it) and `marketing/*` is excluded from the export presets.

Intended sizes are from `data/source/logo_title_art.csv`, checked against the Steamworks asset page (https://partner.steamgames.com/doc/store/assets).

| File | Actual size | Intended size | Use | Matches? |
|------|-------------|---------------|-----|----------|
| STEAM-HEADER.png | 1833x858 | 920x430 | Steam store page header capsule | Right ratio (2.14), too big: scale down to 920x430 |
| STEAM-MAIN.png | 1657x949 | 1232x706 | Main capsule (front-page features) | Right ratio (1.75), too big: scale down |
| STEAM-SMALL.png | 2042x770 | 462x174 | Small capsule (search, lists) | Right ratio (2.65), too big: scale down; check the logo reads at 462 px |
| STEAM-VERTICAL.png | 1146x1372 | 748x896 | Vertical capsule (seasonal sales) | Right ratio (0.84), too big: scale down |
| STEAM-LIBRARY.png | 1024x1536 | 600x900 | Library capsule (library grid) | Right ratio (2:3), too big: scale down |
| STEAM-HERO.png | 2206x713 | 3840x1240 | Library hero (library page banner, no logo) | **Too small**: right ratio (3.09) but it would have to be enlarged 1.74x; regenerate at 3840 wide |
| ITCH-COVER.png | 1408x1117 | 630x500 | itch.io cover image | Right ratio (1.26), too big: scale down |

No file has the exact pixel size. Steam says (since August 2024) it accepts larger sizes for most capsules, so the oversized ones may upload as they are; scale them down to be safe.

Not provided: the **Library Logo** (a transparent PNG with the game logo, 1280 px wide and/or 720 px tall; LOGO-WORDMARK is 1774x887 and could be resized to 1280x640), and the optional page background (1438x810).
