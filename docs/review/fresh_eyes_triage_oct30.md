# Fresh eyes Oct 30 - triage of the critic's top 20

Source: `docs/review/fresh_eyes_oct30.md` (a critic subagent with no project context, 27 runs through `tools/play.sh`, four Paths
through the cave, Beefcake on to the House of Gains boss). Checked against CLAUDE.md, the design docs (story bible, canon,
balance_state, economy, equipment, feats, battle_feel), `open_questions.md` decisions and the inbox. Verdicts: **valid**, **partly**,
**conflicts** (a deliberate decision), **artefact** (the review harness, not the game).

| # | Problem (critic's words, short) | Verdict | Evidence / what it touches | Today? |
|---|---|---|---|---|
| 1 | The cave cannot be found on foot | **partly** | The worn path camp -> gate exists (`OpeningForestLayout.PATH`, 4.4 m wide) and `run_opening_forest_smoke.sh` walks it with held keys; the critic's straight holds hit the treeline, and every treeline stop is a self-talk box that interrupts the walk. Real gaps: no objective marker on the gate, the forest map is fogged, no HUD hint. Lines are frozen. | **Fix 1**: a beacon on the cave gate (world + minimap) once the Rescuer leaves, the forest map revealed |
| 2 | The first duel is lost by default on two Paths | **partly / conflicts** | The sim says the cave is 80-97 % per Path with the real AI (XP pass report); the critic's losses were the simple `BattlePilot` and a hand turn held by the tip deadlock (#3). The "Infrastructure clog" is the deck design (45 cards, 19 infra; D44/D45, rebalance Parts C/D). Balance changes need sim evidence. | No. Recommendation: starter-deck infra ratio study with the sim |
| 3 | Tutorial tip deadlock ("Spend your Iron" holds the turn, targeting never resolves) | **valid** | `TutorialLayer._usable_resource_coins` counts `ResourceRules.use_targets`, which lists **every** unit, the enemy's included; so the tip fires, and `blocks_turn_end` holds Space, when the player has no unit of their own (screenshot: only the enemy's Courier Pigeon on the table). | **Fix 2**: the tip and the hold need a unit of the player's own |
| 4 | Esc hangs the game; Feats / Collection unreachable | **artefact** (the hang) / **partly** (the menu) | The pause menu pauses the tree and `UiDriver.seconds` used a timer that does not tick while paused: both "hung" runs stop at the `wait` after `key Escape` (fixed in the driver, Part 1 commit). The pause menu has Save / Settings / Glossary / Feats. The HUD's Menu button (Character / Deck / Quests / Packs / Wardrobe) does not list them, so a player who never presses Esc never finds Feats or the Glossary. | **Fix 10** (if time): Glossary + Feats in the HUD menu; verified with the fixed driver in the second look |
| 5 | Deck Station X leaves the world black; the Map cannot be closed with M or X | **valid (reproduce)** | Screenshot `critic_beef_06_22` is a black world with a live HUD. In the forest both X and Esc go through `OverlayScreen.request_close` -> `closed`; the M toggle is handled by the map (`FullMapScreen._unhandled_input`) and by the scene. To reproduce with the driver first. | **Fix 3** (Deck Station) and **Fix 4** (Map), as reproduced |
| 6 | Twenty lines of unskippable opening | **conflicts** | Dialogue freeze (`intro_story.tres`); the dialogue speed setting exists (SA-4). The still-vs-night mismatch needs art. | No. Recommendation (dialogue file): a shorter wake-up; art: a night version of the still |
| 7 | Hand cards cut off at the bottom | **partly** | `BattleBoard.HAND_Y` 985 on the 1080 canvas with 450-tall cards: the rules text is below the edge by design (hover lifts the card, BT-decisions). Lifting the hand collides with the field rows. | No. Recommendation: a smaller hand scale or a fanned hand |
| 8 | Combat keywords undefined outside battle | **valid** | `KeywordInfo.KEYWORD_TEXT` has every keyword; the battle hover box lists them (`BattleHud` 552-577) but the reward / deck / collection previews only show "Exhaust" (rules text). | **Fix 9**: keyword reminders under the card preview outside battle |
| 9 | No feedback for unplayable cards | **partly** | BT-3 dims unplayable hand cards; a click on a dimmed card is silent. | **Fix 8**: a toast with the reason (energy, one Infrastructure per turn, not your main phase) |
| 10 | Starter decks clog with Infrastructure | **conflicts** | Deck design decisions (D44, rebalance C/D); balance needs sim evidence. | No. Recommendation with the sim |
| 11 | Town gives no objective on arrival | **partly (reproduce)** | The real arrival (cave rewards -> "Step outside") spawns beside Elder Maren whose welcome gives Meet the Merchants (playtest smoke). The critic reached town through `dev travel dungeon D-TUT` + auto-win, which may have skipped the arrival. To check with the driver through the real exit. | Checked in Part 3's first run; fix if the real path shows it |
| 12 | VICTORY / YOUR TURN banner off the right edge; Deck button under the minimap | **valid** | `BattleHud._banner` uses `PRESET_CENTER` anchors and then a `position` of (385, 440) while the HUD has no size yet, so the offsets land at (960 + 385, 540 + 440) once laid out: "VICT" at the bottom right in every battle. The forest's Deck button sits at x 1650 under the minimap ring (`starting_area_scene.gd` 186). | **Fix 5** (banner) and **Fix 6** (button) |
| 13 | Event outcomes opaque ("Nothing changes") | **valid** | `ChallengeScreen._show_outcome` prints the effects only; at full HP a passed well prints nothing. The threshold is in `ChallengeData`. | **Fix 7**: "3 of the 5 were Infrastructure (needed 3): passed. You were already at full HP." |
| 14 | Reward screen: Skip looks primary | **valid** | `RewardsScreen`: Take is the primary style but disabled until a pick; the plain Skip reads as the live button. | **Fix 8b**: the middle card pre-selected (Take live at once) |
| 15 | Modal tips everywhere | **conflicts** | Once-ever tips are a decision (BT-9..15, Oct 17 tutorial pass); Skip tips exists. | No. Recommendation: a Tutorial toggle in Settings |
| 16 | Dungeon nodes without a preview; the tooltip sticks | **partly / valid (reproduce)** | Battle nodes in the cave show no info; later nodes do; a tooltip that stays after the mouse leaves is a bug. | Reproduce with Fix 3/4's run; fix the sticky tooltip if seen |
| 17 | Jargon and placeholders: "Restore 999 HP", "Copy caps C3 · U2 · E1 · L1", empty rules panel | **valid** | `TrialOfTheHollow` shrine `heal_amount = 999`; `CharacterScreen` 296; the Forgotten Cave has no rules so its panel is a bare title. | **Fix 9b**: "Restore all HP", "Copies allowed: 3 Common, 2 Uncommon ...", "No special rules here" |
| 18 | Minimap and maps black | **partly** | Fog of war is the design for zones; for the 40 m starting forest it hides the one goal. | Part of **Fix 1** (forest revealed) |
| 19 | Load hitches, 8.5 s town load | **valid, known** | Performance pass Oct 25 (BuildCache, warmups); this PC is the fill-rate-bound iGPU. | No. Already on the perf list |
| 20 | Zone HUD covers the landmark | **partly** | The zone HP box is centred at the top by design (zone HUD Oct 18). | No. Recommendation: move it to the top-left column |

Other bugs from the report: the sticky node tooltip (#16), the doubled "Brindle the Baker" label, missing inline icons in rules
text ("create an  Iron" is the driver's `dump` stripping the icon; the hover previews need a look), the stray glyph warm-up labels (near
invisible by design, `UiArtWarmup.GLYPH_TEXT`), the Settings panel clipped without a scrollbar, `dev save` losing dungeon progress
(the Dev Menu snapshot saves the Session, not the open map - a dev-tool limit).

## The ten fixes (clarity, onboarding, friction, feel; no art, no dialogue edits)

1. **Cave beacon** - a pulsing marker over the cave gate and on the minimap once the Rescuer leaves; the forest map revealed.
2. **Tutorial resource tip** needs a unit of the player's own; it never holds the turn otherwise.
3. **Deck Station X** in the forest: reproduce the black world, fix.
4. **Map close** with M and X: reproduce, fix.
5. **Battle banner** centred (VICTORY / DEFEAT / YOUR TURN / ENEMY TURN).
6. **Forest Deck button** left of the minimap.
7. **Well / challenge outcome** says the count, the threshold and why nothing changed.
8. **Unplayable card click** toasts the reason; **reward pick pre-selected** so Take is the live button.
9. **Placeholders and jargon**: shrine "Restore all HP", copy caps in words, "No special rules here"; **keyword reminders** in card previews outside battle.
10. **HUD menu**: Glossary and Feats entries (time permitting; otherwise a recommendation).

## Recommendations that need art or dialogue (not done today)

- A night version of the wake-up still, or the opening played at dusk (art).
- A shorter wake-up (six lines before the Path choice) and a treeline line that names the direction ("The trees close up that way -
  the cave is up the path to the north-east") - `docs/dialogue/lines_to_update_oct30.csv`.
- Starter deck Infrastructure ratio / a 1-2 HP tutorial foe with a scripted deck (sim evidence first).
- A defeat recap (damage taken by turn, a hint) - a feature, not today.
- Hand fan / smaller hand scale so the rules text shows; the zone HP widget to the top-left; a Tutorial toggle; Settings scrollbar.
