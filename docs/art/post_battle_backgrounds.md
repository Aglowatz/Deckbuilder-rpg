# Post-battle backgrounds

Oct 19. Every screen that follows a fight or a dungeon shows where the player is, built from existing art only, through one widget:
`PostBattleBackdrop` (`ui/widgets/post_battle_backdrop.gd`).

- `PostBattleBackdrop.for_board(key)` - the battleboard of the fight (`Battleboards.texture_for`, the BB-* images, keys in
  `data/battleboards.json`), blurred (a 25-tap shader), darkened 42 % and vignetted, fading in over 0.45 s.
- `PostBattleBackdrop.live()` - the live scene behind (a zone, Crosspath, the forest) blurred the same way (screen-texture mip blur).
- Story stills keep their STORY-* art and cutscenes their own pictures; they draw over the backdrop.

## Audit: what each screen showed, and what it shows now

| Screen | Context | Before | Now |
|---|---|---|---|
| Battle result panel (Victory / Defeat / Draw) | any fight | the fight's battleboard behind a 60 % shade, the HUD (trays, battle log) still drawn over it, no blur | `for_board(context.board_key)`, above the HUD, blurred, fading in as the table clears |
| Rewards screen ("Victory!", gold, card pick) | every dungeon fight (the Forgotten Cave, zone main and side dungeons, the Capital's castle) | **the generic arena diorama (`ArenaBackdrop`) for every dungeon** | `for_board(offer.board_key)` - the board of the fight just won (`RewardOffer.board_key`, set in `Session.complete_battle`); without one, the run's board (`PostBattleBackdrop.dungeon_board_key`) |
| Trial complete ("Through the Forgotten Cave") | the cave's last fight | the arena diorama | BB-TUT (it is drawn inside the rewards screen) |
| A boss's closing words (dialogue after the boss) | zone main dungeons | the arena diorama behind the dialogue box | that dungeon's board (BB-HOG, BB-TTK, BB-HFA, BB-ROT, BB-PC...) |
| Story still after a boss | zone main dungeons, Primm | its STORY-* picture | unchanged (STORY-* art) |
| Level-up screen | after any fight (over the rewards screen, a zone, Crosspath) | a 90 % near-black shade | `live()` + a 30 % shade: the rewards board or the zone/town stays visible, blurred |
| Quest complete / chest / reward popups (`PopupFrame`) | back in a zone or Crosspath after a fight | an 82 % shade | `live()` + a 30 % shade |
| Post-fight conversations (gatekeepers, Shiro, roamers, arena results) | Crosspath, zones | the live scene | unchanged: the live scene (the place itself) |
| Dungeon defeat ("carried out") | any dungeon | back in town / the zone (live) | unchanged |

## Context -> background (the battleboards the result and rewards screens use)

| Fight | Context key | Background |
|---|---|---|
| The Forgotten Cave (tutorial) | `dungeon:hollow` | BB-TUT |
| Crosspath roamers, Shiro, the Vault | `town` | BB-TOWN |
| A gatekeeper (Brick, Prudence, Chef, Moss) | `zone:<their zone>` | their zone's board (BB-GAIN, BB-DNA, BB-BUFF, BB-DUMP) |
| The Graveyard's Cairn | `graveyard` | BB-GRAVE |
| The Undercroft arena | `arena` | BB-ARENA |
| Gainlands / D.N.A. / Endless Buffet / Verdant Dump roamers | `zone:beefcake` / `zone:necrocrat` / `zone:gourmand` / `zone:refusemancer` | BB-GAIN / BB-DNA / BB-BUFF / BB-DUMP |
| The Capital outside / inside | `capital:out` / `capital:in` | BB-CAP-OUT / BB-CAP-IN |
| House of Gains / Test Kitchen / Hall of Forms / the Rotheart | `dungeon:beefcake` / `dungeon:gourmand` / `dungeon:necrocrat` / `dungeon:refusemancer` | BB-HOG / BB-TTK / BB-HFA / BB-ROT |
| Primm's Castle / Primm's three phases | the castle's dungeon-list battleboard / `boss:final` | BB-PC / BB-PC-BOSS |
| Side dungeons | `mini:<zone>` (the dungeon list's battleboard id) | BB-S-BEEF, BB-S-GOUR, BB-S-NECRO, BB-S-REF, BB-S-CAP, BB-S-TOWN |
| The Lab | its dungeon-list battleboard | BB-LAB |

`tests/ui/test_post_battle_backdrop.gd` checks that every context key above has a real image (never the placeholder), that the rewards
screen uses the fight's board and no arena diorama, and that popups over the world keep it visible.

## Screenshots (`_screenshots/`, 1280x720, git-ignored)

| Case | Before | After |
|---|---|---|
| Zone fight (Gainlands) result | `d19_bg_before_result_gain.png` (HUD over an unblurred board) | `d19_bg_after_result_gain.png` |
| Dungeon boss (House of Gains) rewards | `d19_bg_before_rewards_hog.png` (the arena diorama) | `d19_bg_after_rewards_hog.png` (BB-HOG) |
| The Capital result | `d19_bg_before_result_capital.png` (outside board, HUD on top) | `d19_bg_after_result_capital.png` (inside: BB-CAP-IN) |
| Tutorial rewards | the arena diorama (as the House of Gains before) | `d19_bg_after_rewards_tut.png` (BB-TUT) |
| Level-up / quest complete over Crosspath | near-black shades | `d19_bg_after_levelup_town.png`, `d19_bg_after_questpopup_town.png` |

Screenshot hooks: `--result=win|lose` on `scenes/battle.tscn` (with `--ctx=<context key>`), `--board=<context key>` on `scenes/rewards.tscn`.
