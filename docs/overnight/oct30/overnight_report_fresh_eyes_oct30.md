# Report - Fresh-eyes critique + fix Oct 30 (Fable)

Fri Oct 30, ~18:00 -> Sat Oct 31 ~02:00 MDT. State `docs/overnight/loop_state.md`; questions `docs/overnight_inbox.md` ("Fresh eyes
Oct 30"). Last run's report: `docs/overnight/oct30/overnight_report_xp_oct30.md`. Dialogue freeze respected (no line or key changed;
rewrites in `docs/dialogue/lines_to_update_oct30.csv`); no art generated; the black market, prices and the XP curve untouched; no enemy
intent; no version bump, no export. Old saves load (nothing in the save format changed).

## Read this first

- **A critic with no project context played the game** (27 runs, four Paths through the cave, Beefcake to the House of Gains boss)
  through a new play-script driver and scored it **4.8 / 10** against Slay the Spire, Inscryption, Monster Train, Sea of Stars, Octopath
  and TCG Pocket. Report: `docs/review/fresh_eyes_oct30.md` (66 screenshots in `docs/review/fresh_eyes_oct30/`).
- **The three "blocking bugs" were two real ones and one artefact**: the Deck Station left the world black (real: its `_exit_tree`
  skipped the base class, so the WorldCover's 3D switch-off was never released), the battle banner read "VICT" at the bottom right
  (real: centre anchors set before the HUD had a size), and "Esc hangs the game" was the driver's timer not ticking while the pause
  menu paused the tree (the driver is fixed; the pause menu works).
- **Ten fixes landed** (commit 413c70de): the cave beacon, the tutorial tip that held the turn, the black world, the banner, the Deck
  button under the minimap, challenge outcomes in numbers, unplayable-card reasons, reward pick pre-selected with keyword help, three
  placeholders in words, the HUD menu with Glossary / Feats / Settings. Before/after shots: `docs/review/fresh_eyes_fixes_oct30/`.
- **Second look** (a new critic, no project context, Gourmand Path, 13 runs): **8 of the 10 fixes landed, 2 partly** (the unplayable-card
  toast can hide behind the clicked card's tooltip; the cave's Rules panel sat half under the map tip - moved below it afterwards). The
  first 30 minutes now score **6-8** where the first critic gave 3-5 (hook 7, clarity 7, pacing 6, combat feel 7, rewards 7, readability 7,
  UI consistency 6, bugs 8); the cave was reached on foot in ~12 s. Report: `docs/review/fresh_eyes_second_look_oct30.md`. New problems it
  found: confirmation popups ignore the E key the HUD advertises, the Path screen's "More" only renames itself, treeline lines stop the
  walk until dismissed, tooltips overlap the rule toast and the plate (inbox 10).
- **Tools**: `bash tools/play.sh <script> [name] [limit]` plays the real game from the title with keys, clicks, drags, buttons by text,
  screenshots, a `dump` of visible text, a battle pilot, dialogue skipping, dev jumps and snapshots (`docs/play_script.md`). Any
  future "fresh eyes" pass starts from `docs/review/critic_brief_oct30.md`.

## Part 1 - the critic's scores and top 20

| Area | Score | Area | Score |
|---|---:|---|---:|
| First 5 minutes' hook | 4 | Story and humour | 6 |
| Clarity | 4 | Visual cohesion and readability | 6 |
| Pacing and friction | 3 | UI/UX consistency | 4 |
| Combat depth and feel | 5 | Audio | n/a (not judgeable through screenshots) |
| Deck-building satisfaction | 5 | Performance | 6 |
| Reward rhythm | 6 | Bugs / stability | 3 |
| Exploration and world | 4 | **Overall** | **4.8** |

The top 20, one line each (verdicts from the triage, `docs/review/fresh_eyes_triage_oct30.md`):

| # | Problem | Verdict | Today |
|---|---|---|---|
| 1 | The cave cannot be found on foot | partly (the path exists; no marker, fogged map, self-talk interrupts) | Fix 1 |
| 2 | The first duel is lost by default on two Paths | partly / conflicts (sim 80-97 %; the critic's losses were the simple pilot + the tip deadlock; deck design) | recommendation |
| 3 | Tutorial tip deadlock | valid (`use_targets` counted the enemy's units) | Fix 2 |
| 4 | Esc hangs; Feats / Collection unreachable | artefact (driver) / partly (HUD menu) | driver fix; Fix 10 |
| 5 | Deck Station X blacks out the world; Map cannot close | valid (reproduced; `_exit_tree` without super) / not reproduced (M closes the map) | Fix 3 |
| 6 | Twenty unskippable opening lines | conflicts (dialogue freeze; art) | CSV + art recommendation |
| 7 | Hand cards cut off at the bottom | partly (by design; hover lifts) | recommendation |
| 8 | Combat keywords undefined outside battle | valid | Fix 9 (reward screen) |
| 9 | No feedback for unplayable cards | partly (dimmed; the toast was terse) | Fix 8 |
| 10 | Starter decks clog with Infrastructure | conflicts (deck design, sim evidence) | recommendation |
| 11 | Town gives no objective on arrival | partly (the real exit lands beside Maren; the critic warped in) | CSV line for the Rescuer |
| 12 | Banner off-screen; Deck button under the minimap | valid | Fixes 5, 6 |
| 13 | Event outcomes opaque | valid | Fix 7 |
| 14 | Reward screen: Skip looks primary | valid | Fix 8b |
| 15 | Modal tips everywhere | conflicts (once-ever tips decision) | recommendation |
| 16 | Dungeon nodes without a preview; sticky tooltip | partly (not reproduced today) | - |
| 17 | Jargon and placeholders | valid | Fix 9b |
| 18 | Minimap and maps black | partly (fog by design; the forest now revealed) | Fix 1 |
| 19 | Load hitches, 8.5 s town load | valid, known (perf list) | - |
| 20 | Zone HUD covers the landmark | partly (by design) | recommendation |

## Part 2 - triage

`docs/review/fresh_eyes_triage_oct30.md`: every problem checked against CLAUDE.md, the design docs and the decisions; 8 valid, 8 partly,
4 conflicting with a deliberate decision (the dialogue freeze, the once-ever tips, deck design / balance with sim evidence), 1 harness
artefact. The ten fixes favour clarity, onboarding, friction and feel; nothing needed new art or a dialogue edit.

## Part 3 - the ten fixes (commit 413c70de)

| # | Fix | Where | Before / after |
|---|---|---|---|
| 1 | **Cave beacon**: once the Rescuer leaves (or on a return before the cave is cleared) the cave gate gets the quest objective's gold chevron + ground ring, the HUD edge pointer while off screen, the minimap's objective dot, and the clearing's map is revealed | `StartingAreaScene._show_cave_beacon`, `QuestMarkerLayer.set_fixed_objective`, `MinimapHud.reveal_all / refresh_pois_now`, `MapPoi.objective` | `before_forest.png` / `after_01_forest_beacon.png` |
| 2 | **Tutorial "spend your Iron" tip** fires (and holds End Turn) only with a unit of the player's own to buff | `TutorialLayer._has_own_target` | (the critic's `critic_beef_13_80_iron_target.png`) |
| 3 | **Deck Station close** no longer leaves the world black: `_exit_tree` calls the base (WorldCover release, music pop, log) | `DeckbuilderScreen._exit_tree`; source-scan test `test_overlay_exit_tree.gd` | `before_deck_closed_world.png` / `after_03_deck_closed_world.png` |
| 4 | **Map close**: M / X reproduced as working in the forest (brightness check, three runs); nothing to change | - | `fix_repro_c/57_map_after_m.png` |
| 5 | **Battle banner** (YOUR TURN / ENEMY TURN / VICTORY! / DEFEAT) centred | `BattleHud` banner anchors | `before_victory_banner.png` / `after_07_victory_banner.png` |
| 6 | **Forest Deck button** left of the minimap ring | `starting_area_scene.gd` | same forest shots |
| 7 | **Challenge outcome in numbers** ("3 of the 5 cards were Infrastructure; 3 were needed.", "You were already at full HP, so there was nothing to mend.") | `ChallengeResolver.explain / heals_on_success`, `ChallengeScreen` | tests `test_challenge_explain.gd` |
| 8 | **Unplayable-card reasons** ("Needs 2 energy; you have 1 (each ready Infrastructure gives 1 a turn)", "One Infrastructure per turn: you already played yours...") and **the reward pick starts on the middle card** so Take is the live gold button | `BattleScreen._why_not_castable / _try_play`, `RewardsScreen` | `after_rewards_preselect.png` |
| 9 | **Keyword help on the reward screen** (the hovered or chosen card's keywords and resources, one line each) and **placeholders in words**: shrine "Restore all your HP" / "mend all of your HP", Character "Copies per card: 3 Common, 2 Uncommon, 1 Epic, 1 Legendary", the cave's rules panel "No special rules here" | `RewardsScreen._show_keywords`, `DungeonMapScreen`, `ShrineScreen`, `CharacterScreen` | `after_06_cave_rules.png` |
| 10 | **HUD Menu** lists Glossary, Feats and Settings (each opens the pause menu on that page) | `TownHud`, `SceneManager.show_glossary_page / show_settings_page` | `after_10_town_menu.png` |

Checks after the fixes: GUT root 286, core 1500 + 1 pending, ui 245, world 424 (all green); first-battles smoke OK (57 fps lowest);
opening forest smoke OK (the hero still walks the path to the cave; Maren at the mouth; Crosspath); hub walk smoke OK; structure
budget OK. After the commit: story playthrough bot 90 / 90 (a first background run was reaped by the low-memory guard; the foreground run
passed), tour bot OK (281 spots, 9 menus, 5 battles, 0 errors, 0 warnings).

## Part 4 - second look

A second critic subagent (brief `docs/review/critic_brief_second_look_oct30.md`, no project docs) played the first 30 minutes on the
Gourmand Path and answered ten questions about the changed areas: 13 runs, ~75 min, 40 screenshots in `docs/review/fresh_eyes_second_look_oct30/`,
no script errors.

| # | Fix | Verdict | What the critic saw |
|---|---|---|---|
| 1 | Cave beacon | landed | chevron over the arch, ground ring, minimap dot, map marker; "[E] Enter the cave" reached in ~12 s with held keys; one treeline box froze the walk until E |
| 2 | Deck Station close | landed | X and Esc both close it; the world is drawn afterwards |
| 3 | Map close | landed | M opens, M closes, X closes |
| 4 | Battle banners | landed | YOUR TURN / ENEMY TURN ("Turn 2") / VICTORY! whole and centred; nit: at 0.4 s VICTORY! draws under a hover tooltip and the enemy units |
| 5 | Resource tip hold | landed | no "the duel waits for you" tip in a hand-played and a piloted duel; End Turn always available |
| 6 | Unplayable cards | partly | both new messages appear; the floating sentence can hide behind the clicked card's own tooltip |
| 7 | Reward screen | landed | middle card chosen, "Take Amuse-Bouche" gold, keywords (Peek, Ingredient, Wallflower) glossed under the cards |
| 8 | Well / shrine | landed | "2 of the 5 cards were Infrastructure; 2 were needed. You were already at full HP..."; shrine "Restore all your HP" |
| 9 | Copies / rules panel | partly | Character and Deck Station say "Copies per card: 3 Common, 2 Uncommon..."; the cave's Rules panel sat half under the map tip (**follow-up**: the panel now opens below the tip, y 300; GUT ui green) |
| 10 | HUD Menu | landed | Character, Deck, Quests, Packs, Wardrobe, Glossary, Feats, Settings; Glossary and Feats open and Esc returns |

Part A scores (first 30 minutes, Gourmand): hook 7, clarity 7, pacing and friction 6, combat feel 7, reward rhythm 7, visual
readability 7, UI/UX consistency 6, bugs 8 (the first critic's: 4, 4, 3, 5, 6, 6, 4, 3). Its closing line: "Fix the popups and a new
player will get from the title to their first reward without once wondering whether the game has stopped listening."

New problems (inbox 10, not fixed tonight): confirmation popups ("Go in?", the Well's Reveal / Continue, the duel's Got it tips) ignore
the E key the HUD advertises as interact and need a click or Enter; the Path screen's "More" only renames itself to "Less"; the
treeline self-talk stops movement until dismissed; tooltip boxes overlap the rule toast, the card preview and the player plate; the
pause menu worked everywhere tried.

## Recommendations that need art, dialogue or a design call

- **Dialogue** (`docs/dialogue/lines_to_update_oct30.csv`): the treeline lines name the direction; the wake-up cut to about six lines;
  the Rescuer's farewell names Crosspath and Maren; a defeat recap line.
- **Art**: a night version of the wake-up still (the day still over the night clearing).
- **Design calls** (sim evidence first): the starter decks' Infrastructure ratio / a smaller first-duel foe; a hand fan or a smaller
  hand scale so the rules text shows without hovering; the zone HP widget out of the landmark's way; a Tutorial toggle in Settings; a
  scrollbar on the Settings panel; a defeat recap.

## Checks run

GUT root / core / ui / world after the fixes; first-battles smoke; opening forest + hub walk smokes; structure budget; the play-script
driver's repro and verification runs (`_screenshots/play/fix_*`); story playthrough bot and tour bot (Part 3's end); the critic's 27
runs and the second critic's runs.

## Inbox (Fresh eyes Oct 30)

See `docs/overnight_inbox.md`, section "Fresh eyes Oct 30".
