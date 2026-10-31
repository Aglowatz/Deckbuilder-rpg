# Fresh eyes round 2 - triage of the mid-game critic's top 15 (Oct 31)

Source: `docs/review/fresh_eyes_midgame_oct31.md` (a critic subagent with no project context, brief `critic_brief_midgame_oct31.md`,
18 runs from the `midgame_l8` snapshot: Gourmand L8, Gainlands freed, 1020 gold, 9 packs). Verdicts: **valid**, **partly**,
**conflicts** (a deliberate decision), **artefact** (the snapshot or the harness, not the game).

**The snapshot was weaker than a real level-8 player.** It was made from a forest save taken before the cave, then `dev travel town`:
the Forgotten Cave was never cleared (so Sable's whole stall, gated on it, stayed "???"; the quest log had nothing; the HUD kept saying
"someone is waiting at the cave"), the deck was the bare 45-card starter with 19 Infrastructure (no cave picks, no packs opened into it,
no zone cards), and loading the snapshot resumed in the forest because `trial_cleared` was unset (P / C / J / M dead). Several findings
below come from that. The snapshot script now sets the flag (`dev flag trial_cleared`) and resumes in Crosspath.

| # | Problem | Verdict | Evidence | Tonight? |
|---|---|---|---|---|
| 1 | The card vendor sells nothing at L8 | **artefact** | `VendorStocks.sable_sample` gates every card on clearing the Forgotten Cave; the snapshot never cleared it. A real L8 player has the stall open. The teaser ("Clear X to unlock") already shows on click | No (snapshot fixed for next time) |
| 2 | Boss fights stall; the deck has no clock | **partly / conflicts** | The bare starter at L8 is far weaker than the expected player (`ProgressionModel.reference_deck` adds packages by level; the sim says Mortimer ~ in band for the expected deck). The Infrastructure ratio: Part 3 study says keep 19. Enrage / AI tool preference = balance + AI with sim evidence | No. Recommendation |
| 3 | Five "continue" conventions | **valid** | Mouse-only Continue on the pre-fight rules card (both copies), the event result, announcements | **Fix 1**: `ConfirmKey` - E / Enter / Space / pad A press them (guarded) |
| 4 | Maps do not help find anything | **partly** | Fog of war is the design; the town map has building names in its legend but not on the map. Needs a design call (reveal the hub, label buildings) | No. Recommendation |
| 5 | The pre-boss funnel is long and layered | **conflicts** | Story stills are frozen (dialogue freeze, story bible); the rules card is the "Before the fight" decision (Oct 19) | Part of Fix 2 (rules lines merged); the rest a recommendation |
| 6 | Quest log empty while the HUD nags | **artefact** (mostly) | The cave was never cleared, so Maren's quest chain never started | No |
| 7 | Character screen is five padlocks | **partly** | Each locked slot already has a tooltip "Locked - <hint>"; slots open by level/quests by design (equipment budget Oct 29) | No. Recommendation: print the hint on the slot, not only on hover |
| 8 | Pack opener stacking; dead hotkeys | **valid / artefact** | Open while a ceremony was up tore a second pack under the first (valid); dead hotkeys = the forest resume (artefact) | **Fix 3**: one ceremony at a time |
| 9 | Readability: doubled baker label, nameplate wrap, "-3" over YOU | **valid** | The baker's spot and her sprite both registered "Brindle the Baker"; HP floats used the plate centre | **Fix 6** (baker), **Fix 7** (float above the plate); nameplate wrap left |
| 10 | Three HP numbers | **partly / conflicts** | Zone HP carries (zone rule), the Capital sets its own pool, bosses use the battle's max (level) - each is a design rule, explained in its own place | No. Recommendation: one banner when the pool changes |
| 11 | Mortimer's defeat screen silent | **artefact** | The shot is the 1.2 s DEFEAT banner before the result panel; the result panel (with the recap) followed. Verified: `fix31_g/05_defeat_panel` shows "What beat you" on Mortimer. The "..." gold button was real | **Fix 5**: the primary button hides when it reads "..." |
| 12 | Tutorial tips in L8 boss fights | **valid** (amplified by the snapshot: a profile that skipped the cave never saw them) | `TutorialLayer.wanted()` ignored the fight kind | **Fix 4**: no tutorial in boss fights |
| 13 | Rules popup overload, duplicate line | **valid** | The Hall's "Red Tape Everywhere" and Mortimer's printed as two lines | **Fix 2**: same-named rules merged ("...Also: ...") in both copies of the card; test |
| 14 | The D.N.A. lobby looks greybox | **valid, needs art** | Zone kit dressing density | No. Recommendation (art) |
| 15 | Clicking a node only shows its tooltip | **partly** | Click 1 = select + preview, click 2 = travel (the dungeon map design); the tip says "click a glowing node" | No. Recommendation: "Click again to go" in the preview |

## The seven fixes (commit 7ae5ab5f)

1. **One Continue rule**: `ConfirmKey.attach(screen, button)` - E / Enter / Space / pad A press the screen's button after a 0.4 s guard;
   on the pre-fight rules card (`RulesBrief`, `DungeonMapScreen._show_rules_brief`), the event result (`EventScreen`, now focused), the
   announcement card (`AnnouncementScreen`). The Well, popups, dialogs and tips were done in Part 1.
2. **Same-named rules merged**: `RulesBrief.distinct_by_name` / `line_text` -> "Red Tape Everywhere: Start each battle with one Red Tape.
   Also: Starts the duel with 3 Red Tape." The icon row keeps every badge.
3. **One pack ceremony at a time** (`PackOpeningScreen.open_from_inventory`).
4. **No tutorial tips in boss fights** (`BattleScreen`, `context.is_boss`).
5. **No gold "..." button**: the primary button hides while it has nothing to say (mulligan, end of fight).
6. **The baker labelled once** (`TownScene` spot label skipped for the wandering baker).
7. **The HP loss number rises above the plate** instead of over its name (`BattleBoard._on_hp`).

Plus the harness: `dev flag <name> [off]` in the play driver; the mid-game snapshot sets `trial_cleared`.
