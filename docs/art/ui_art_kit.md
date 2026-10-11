# UI art kit

55 painted UI assets from the designer sheet (`data/source/ui_art_kit.csv`), imported by `bash tools/import_ui_art.sh` from the read-only Drive folder
`G:\My Drive\Card Game Art\Approved_UI` (`data/source/art_config.cfg`, `ui_dir`; env `UI_SOURCE_DIR`). Files are named by UI ID (`UI-FRAME-B.png`). The importer only
copies: sprites are trimmed of empty margin, scaled down to 1024 px on the long side (backgrounds 1536x1024), written as WebP with alpha to `assets/art/ui/<ID>.webp`.
A plain flat background on an image that should be transparent is removed with an edge-aware fill (none needed so far). `data/source/ui_import_manifest.csv` records
MD5s so a changed Drive file is replaced on the next run. Status per ID: `docs/art/art_status.md` ("UI art kit").

Code asks `UiArt.texture("UI-...")` (null when missing, so every screen keeps its code-drawn look) or `UiArt.nine(id, margins)` for a 9-slice.
Judgment calls: `docs/design/open_questions.md`, "UI art kit".

## Cards (Part A)

- `CardView.frame_id()`: Path frame (B/N/G/R/C), MULTI for multi-Path (tinted), INF for Infrastructure (tinted by Path), TOKEN for tokens (tinted by Path).
- The art fills the frame window (`FRAME_ART_RECT`); the frame is drawn over it. Name in the name bar, cost number in the socket (coloured pips below it), rarity gem on the left rail,
  type line and rules text on the dark panel, attack/defense numbers in the frame sockets. All positions are constants at the top of `card_view.gd`, measured on the 1024x1536 frames.
- Compact (battlefield): the same frame with the UI-NAMEPLATE over the name bar, keyword chips in the panel and the UI-STAT-PLAQUE over the stat sockets.
- Card backs: `CardView.back_id()`.

## Card faces: frame overlays are off (Oct 2026)

The kit's card frames looked too busy and shrank the art window, so cards are back to the original face: full art, thin Path-coloured border, name bar with the cost across the top, type line and rules text at the bottom, attack/defense badge, and the compact battlefield view.
The framed code (UI-FRAME-*, UI-RARITY-*, UI-STAT-PLAQUE, UI-COST-SOCKET) is kept in `ui/card/card_view.gd` behind one setting, `use_card_frame_overlays` in `data/ui_config.cfg` (`UiArt.use_card_frame_overlays()`); set it to `true` to try a redesigned frame. The images stay in `assets/art/ui/`. Card backs (UI-CARDBACK-*) are separate and still in use.
Before/after screenshots: `docs/art/screens/card_face_revert/`.
