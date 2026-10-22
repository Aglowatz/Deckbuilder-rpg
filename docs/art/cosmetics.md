# Hero and cosmetics (painted sprite version, world rollout Part C)

The hero is the painted 2.5D sprite `SPR-PLAYER-*` (docs/art/world_look_test.md): five drawn directions (FRONT, FRONTSIDE, SIDE, BACKSIDE, BACK, the art looks LEFT and the other
side is mirrored), a four-frame walk strip per direction and an idle. The default look is the **dark teal hooded cloak, no hat**. The old 3D Rogue (`HeroModel`) is only the
fallback when the sprite art is missing and the look of the 3D tailor and her mannequin. There is no character-design screen at the start of a game any more.

## What is wearable
Two slots, **hat** and **cloak**; data in `core/cosmetics/` (`CosmeticCatalog`, `CosmeticState`, `Dye`, `CosmeticMigration`), saved in the campaign (`Session.cosmetics`).

| Item | Id | Art name | Price | Opens at |
|---|---|---|---|---|
| Wide-Brim Hat | `hat_wide_brim` | WIDEBRIM | 90 | from the start |
| Chef's Toque | `hat_chef` | CHEF | 110 | from the start (also a Buffet chest) |
| Bowler Hat | `hat_bowler` | BOWLER | 140 | from the start (also a Capital chest) |
| Tricorn | `hat_tricorn` | TRICORN | 220 | level 5 |
| Wizard Hat | `hat_wizard` | WIZARD | 280 | one zone freed |
| Crown of Leaves | `hat_leaf_crown` | LEAFCROWN | 360 | two zones freed (also the Verdant Dump hidden chest) |
| Patchwork Cloak | `cloak_patchwork` | PATCHWORK | 210 | level 4 |
| Red Cape | `cloak_red_cape` | REDCAPE | 260 | one zone freed (also the Four-Seal Vault's reward) |
| Tattered Cloak | `cloak_tattered` | TATTERED | 180 | two zones freed (also the Gainlands hidden chest) |
| Royal Mantle | `cloak_royal` | ROYAL | 900 | after Primm (also his drop) |

The clothing vendor, Pip Threadwell, sells all ten. Items whose art is not imported yet show as **"arriving soon"** in the shop (Try and Buy are disabled and the session refuses
the purchase) and cannot be worn from the wardrobe; nothing breaks while art is missing.

## The art to make
- **Hats** `COS-HAT-<NAME>-<FRONT|FRONTSIDE|SIDE|BACKSIDE|BACK>.png`: transparent, one hat, **its bottom-centre is where it meets the head** (the game puts that point on the
  head anchor of the hero's current frame, sinks it a little and mirrors it for the right-hand directions). Size is free (it is scaled from the head's width); 640 px wide is plenty.
  The side directions are drawn looking LEFT like the body. Fit tweaks (width, sink, nudges per direction) go in `assets/art/cosmetics/hats/fit.json`.
- **Cloaks** `SPR-PLAYER-CLOAK-<NAME>-<DIR>_<IDLE|WALK>.png`: a whole alternate player sprite set, exactly like the `SPR-PLAYER-*` files (single idle per direction, a 4-frame
  strip for each walk), same pose, hair and clothes, only the cloak changes. Equipping a cloak swaps the whole set. The default set is the dark teal cloak.
- Both can sit in `Approved_WorldTest` or a new `Approved_Cosmetics` folder: `bash tools/import_cosmetics.sh` copies matching files (read-only on the Drive), slices, trims,
  measures the head anchors of every frame and the cloak's hue, re-imports and prints which items are still "arriving soon".

## How it is drawn
- `WorldSprite` (world/sprites): the hero card; `set_character("PLAYER_CLOAK_<NAME>")` swaps the set (frames the cloak set lacks fall back to the default's), `set_hat("<NAME>")`
  lays a second card on the head, `set_dye(color)` recolours.
- **Hat placement**: `tools/sprite_anchors.gd` measures, for every frame of every sprite set, the head anchor (crown centre, top row, head width). The hat card is placed from the
  anchor of the frame that is showing, so it follows the head through every walk and idle frame; its size is the head's width times the hat's `width` fit (default 1.5).
- **Dye = a recolour of the cloak**: the shader finds the cloak by its hue (the sprite set's `cloak_hue`, measured from the back view where the cloak covers the figure) and
  replaces it with the dye colour, keeping the painted shading, so hair, skin and boots stay as they are. "Natural" is the cloak as painted. There is no hat dye (a hat is one
  painted piece; recolouring it would need a per-hat mask): this is a change from the 3D wardrobe.
- `SpriteActor` is the node `TownPlayer.model` is: the scenes' effects (the bounce squash, the tumbles of the pads and slides, the mount's lift, the blink) drive it as they drove
  the 3D model.

## Old saves
A save from the 3D wardrobe loads in the default look. Every item that was **bought** is refunded as gold at its old price (a toast says how much), the free starter choices were
free, found items that still exist (the leaf crown, the tattered cloak, the royal mantle) stay owned and unequipped, and a found item that no longer exists is replaced
(the four-seals cloak by the red cape). `CosmeticMigration` has the old price table.

## The four cloaks (Apparel Part 1, Oct 22 2026): made from the hero's own cloak
No new art: `bash tools/make_cloaks.sh` (`tools/make_cloaks.gd`, then `tools/sprite_normals.gd` for the normal maps, then an import) repaints the dark teal cloak in every
frame of the default `PLAYER` set (5 directions, idle + 4 walk frames = 25 frames) and writes the character `PLAYER_CLOAK_<NAME>` with its manifest entry
(`cosmetics_manifest.json`) and shop icon (`assets/art/cosmetics/icons/CLOAK_<NAME>.png`). The same sets in the delivery format
(`SPR-PLAYER-CLOAK-<NAME>-<DIR>_IDLE.png` and the 4-frame `_WALK.png` strip) go to `_art_source/cosmetics/generated/`. A painted cloak set delivered later through
`tools/import_cosmetics.sh` simply replaces the generated one.

- **The mask**: cool pixels (green and blue above red, darker than the glow on the hand), the olive lining flooded from the cloak, dark folds filled from their
  neighbours, the cloak's dark outline where it meets open air, specks under 260 px dropped. Hand-made fixes per frame go in `tools/cloak_masks.json`
  (`{"FRONT_IDLE": {"exclude": [[x, y, w, h]], "include": [[x, y, w, h]]}}`, canvas pixels; empty today). `--masks=true` writes every mask as a magenta overlay
  into `_art_source/cloak_masks/`.
- **The repaint** keeps the painted shading: the cloak's luminance (5th..97th percentile over all frames, the same scale for every frame) runs through a
  three-colour ramp. Patterns are laid out in **body-relative coordinates** (from the head anchor's centre line and the crown), so a patch, a tear or the fur
  sits on the same part of the cloak in every frame of a direction: no jitter.
  - **Red Cape**: crimson to bright red, darker red lining, gold clasps at the throat joined by a short chain (front, 3/4 and side views).
  - **Patchwork Cloak**: jittered-grid patches (9 painted colours, some striped or checked) with dark seams and light stitches.
  - **Tattered Cloak**: worn grey-green with bleached patches and a dirtier hem; the hem is cut into frayed points and V-tears (alpha), only where open air is
    below (never a hole over the legs), the lower sides are nibbled, the edge above a cut is darker.
  - **Royal Mantle**: deep royal blue, ivory lining, white fur along the hem (with tufts) and the front edges/collar, gold clasps and a sagging chain.
- **Line-up check**: the tool re-measures the head anchor of every new frame (drift 0.0 px for all four) and counts pixels changed away from the cloak (only the
  clasps and the fur tufts). `tests/world/test_cloak_sets.gd` checks completeness, canvas, head anchors and the foot line.
- **Screenshots**: `Godot --path . --resolution 1700x420 res://tools/sprite_sheet_shot.tscn -- --cloak=ROYAL --mode=walk --rows=4 --every=9 --out=apparel/x`
  (eight directions, four walk phases stacked; the tool is now a scene so the autoloads exist and renders into a fixed-size SubViewport). Shots of Oct 22:
  `docs/art/apparel/cloak_<NAME>_walk.png`.

## Hats from one sheet (Apparel Part 2, Oct 22 2026)
ChatGPT delivers one sheet per hat: `COS-HAT-<NAME>-SHEET.png` (2560x512, five views left to right FRONT, FRONTSIDE, SIDE, BACKSIDE, BACK, transparent) for
WIDEBRIM, CHEF, BOWLER, TRICORN, WIZARD and LEAFCROWN, into `Approved_Cosmetics`. `bash tools/import_cosmetics.sh` copies them (read-only on the Drive) and
`tools/world_test_import.gd --cosmetics` splits each sheet with `HatSheet.split` (`world/sprites/hat_sheet.gd`): connected pieces, specks and cut-off slivers of the
neighbouring view dropped (under 1.5 % of the sheet's biggest piece or 6 % of the view's), each piece to the fifth that holds its middle, trimmed. Five separate
`COS-HAT-<NAME>-<DIR>.png` files still work and win over the sheet's view. Output as before: `assets/art/cosmetics/hats/<NAME>/<DIR>.png` + the icon.

- **Auto-fit** (`HatSheet.fit` -> `assets/art/cosmetics/hats/fit_auto.json`, rewritten on every import): a first-guess `width` and `sink` per hat
  (`HatSheet.BASE_FIT`), a per-direction width `ratio_<DIR>` and a per-direction `sink_<DIR>`. The painted sheets do NOT keep one scale (the chef's back view is
  drawn 40 % bigger), so each view is scaled by its own **head band**, the widest row of its bottom third (the brim, the toque's band). The sink is shallower from
  the front (x0.62; the card is drawn over the face, so the brim sits at the brows) than from behind (x1.0, over the hair).
- **Hand tuning**: `assets/art/cosmetics/hats/fit.json` (any of width, sink, dx, dy, scale, per hat and per direction as `<key>_<DIR>`) wins over `fit_auto.json`;
  a hand `sink` also replaces the importer's per-direction sinks. `SpriteLibrary.hat_fit` merges defaults <- fit_auto <- fit.
- **Head bob**: `tools/sprite_anchors.gd` now also writes `hat_anchor` for the hero's sets: each frame's head found by matching the idle frame's head patch
  (`SpriteAnchors.head_offset`, alpha + brightness, +-16 px). The hat keeps ONE size per direction (the per-frame measured head width wobbled 64-80 px with the
  hair, which made the hat pulse) and follows the walk's bob and sway exactly (`SpriteLibrary.hat_anchor`, used by `WorldSprite._update_hat`).
- **Proven before the art is approved**: `tools/fake_hat_sheets.gd` draws placeholder sheets of all six (with a stray speck) into `_art_inbox/fake_hat_sheets/`;
  a dry run that writes nowhere in the game:
  `Godot --headless --path . -s res://tools/world_test_import.gd -- --cosmetics --cos_inbox=res://_art_inbox/fake_hat_sheets/ --hat_out=res://_art_inbox/fake_hats_split/`,
  then `SPRITE_HAT_FOLDER=res://_art_inbox/fake_hats_split/ Godot --path . --resolution 1700x420 res://tools/sprite_sheet_shot.tscn -- --hat=WIZARD --mode=walk --rows=4`.
  The six real sheets were already in the Drive's `Pending Review` on Oct 22; the same dry run on copies split all 30 views cleanly
  (`docs/art/apparel/pending_hats_split.png`, walking shots `hat_pending_<NAME>.png`). Not imported: they are not approved yet.
- **Art notes for the redo list** (seen in the pending sheets): some views are hard-clipped at an edge in the painting itself (CHEF FRONT and FRONTSIDE right edge,
  LEAFCROWN FRONTSIDE / SIDE / BACK). The leaf crown is a ring drawn as one card in front of the head, so its back half shows over the hair.

## Shop and wardrobe live (Apparel Part 3, Oct 22 2026)
- Pip Threadwell sells every item whose worn art exists (`SpriteCosmetics.art_ready`): since Part 1 the four cloaks (each at its unlock: Patchwork level 4, Red
  Cape one zone, Tattered two zones, Royal Mantle after Primm). The hats stay "Soon" until `import_cosmetics.sh` brings their sheets in; then they sell with
  no code change. `tests/core/cosmetics/test_apparel_shop.gd` checks "buyable exactly when the art exists" for all ten.
- Found pieces arrive owned and unworn: Crown of Leaves from the Verdant Dump chest (`chest_fridge`), Tattered Cloak from the Gainlands chest (`chest_ground_0`),
  Royal Mantle from Primm's first defeat.
- The wardrobe's preview is the live `WorldSprite` with the hat card and the cloak set; it is now framed to show a hat (it cut the head off before). Every
  hat x cloak combination (7 x 5) is worn, applied and saved (`Session.apply_look`, the save round trip in the test).
- **The cloak dye only colours the plain hooded cloak** (`SpriteCosmetics.dye_applies`): it finds the cloak by hue, and the red cape sits beside the skin
  and hair hues, the patchwork has nine. With a named cloak on, the dye swatches rest (dimmed, tooltip "Dyes colour the plain hooded cloak"); the chosen dye is
  kept for when the plain cloak goes back on.
- Shots: `bash tools/shot.sh res://scenes/town.tscn apparel/x --open=wardrobe --wear=cloak_royal,hat_wizard` (`--wear` owns and wears; add
  `SPRITE_HAT_FOLDER=res://_art_inbox/pending_hats_split/` to see hats from a dry run). `docs/art/apparel/wardrobe_royal.png`, `wardrobe_redcape_widebrim.png`
  (the wide brim from the pending sheet), `tailor_cloaks.png`.

## The disguised Rescuer (Apparel Part 4, Oct 22 2026)
From the prologue until Percival Plume names her at the castle gate, the Rescuer travels disguised: hooded, her face behind a dark scarf, a dark cloak over the
white lab coat, four vials. `RescuerDisguise` (`core/data/rescuer_disguise.gd`) decides the picture from the flag `rescuer_named` (`StoryBeats.FLAG_NAMED`, set
by the `@set` step in the middle of `pc_capture`, so the portrait changes on the line after Plume says her name):
- **Portrait**: `DialogueBox.start` draws `RescuerDisguise.portrait_id(entry.portrait_id)`: NPC-RESCUER while unnamed (if `assets/art/portraits/NPC-RESCUER.webp`
  exists), NPC-ELOWEN after. Her NPC id stays NPC-ELOWEN everywhere (story scenes, the Cave Mouth, the prologue); expressions fall back to the base picture.
- **Sprite**: `NpcSprites.rescuer_key()` gives RESCUER while unnamed (if the set is imported), else ELOWEN; used by the prologue figure
  (`StartingAreaScene._elowen_figure`) and the Cave Mouth spot in town (`TownScene._add_npc("rescuer")`). The castle gate scene is dialogue only.
- **Until the files exist the old look stays** (both checks look for the art).
- **Importers**: `Portraits.EXTRA_PORTRAITS` makes NPC-RESCUER a known Portrait Image ID (`import portraits`); `data/source/npc_sprite_batch.csv` has the row
  NS-RESCUER (`SPR-RESCUER (sheet)`, height 1.0), so `import npc sprites` splits `SPR-RESCUER.png` (FRONT_IDLE, FRONT_TALK, SIDE_IDLE, BACK_IDLE, side mirrored to
  face left) with `tools/split_sprite_sheets.gd` exactly like the Oct 20 sheets. Dry run on a copy of the sheet found in Pending Review (not imported):
  `Godot --headless --path . -s res://tools/split_sprite_sheets.gd -- --inbox=res://_art_inbox/pending_npc_dry/` then
  `tools/split_preview.gd -- inbox=res://_art_inbox/pending_npc_dry/`: four figures, background removed, `docs/art/apparel/rescuer_split_dry.png`.
- Tests: `tests/core/data/test_rescuer_disguise.gd`.
