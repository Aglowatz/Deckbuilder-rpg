# Triage - mid-game critic, Overnight Oct 31 -> Nov 1 (first score 4.8/10)

Report: `docs/review/fresh_eyes_midgame_oct31n.md` (52 min, 28 runs, `midgame_real`, played from the worktree at 3a2cbaf5).
Most fights were played by the driver's `pilot`, which plays weakly (keeps its hand, no tempo) - the combat and boss findings are read
with that in mind.

| # | Problem | Verdict | Cause | Action |
|---|---|---|---|---|
| 1 | 16 HP at L13, no healing after battles, even freed | **design call** | Zone HP carries by rule; max HP by level + gear (Oct 30 curve) | Inbox: freed zones heal / per-level HP |
| 2 | Bosses kill before their scripted phases | **partly / design** | The pilot never blocks well; sims put the Doppelganger at 25 % with the built deck (TOO HARD band) | Inbox: boss tempo window; Doppelganger tune |
| 3 | Boss intro ignores input, looks frozen | **valid bug** | A click ON the cutscene's text panel was swallowed by the panel (PanelContainer stops the mouse) and never reached the screen; keys worked (the critic's E presses went to the pre-boss dialogue) | **Fixed**: panel + column ignore the mouse; test clicks the screen |
| 4 | Fights long, pay little (15 fights a level) | **design call** | Oct 30 XP step table (deliberate) | Inbox |
| 5 | Holes in card text / "(B)" / "4 spells" | **valid (part)** | The battle tooltip printed raw energy codes; the dump's gaps are inline icons (they render) | **Fixed**: `KeywordInfo.plain_rules` ("one Beefcake energy", runs counted); "units and spells" wording |
| 6 | Vendors hard to reach, click doesn't path | partly / design | Reach is 2.8 m (Oct 30-31); click-to-walk is a feature | Inbox (click-to-walk) |
| 7 | Freeing a zone changes nothing you see | **valid (part)** | Freed lines / music exist but nothing announces them | **Fixed**: once-per-visit "X is free" banner; healing rule = inbox |
| 8 | Escape does three different things | **valid (part)** | Deck Station: Esc closed the station behind "Suggest a deck" | **Fixed**: Esc closes the topmost Deck Station popup first. Scene skip on Esc is the designer's answer 9 (kept) |
| 9 | Deck-test events: no info, "the well stays silent" in a kitchen | **valid** | The rule was only explained after the reveal; the well's headline was used for every deck test | **Fixed**: "The test: draw 5 - 2+ must be Unit cards. Your deck: about N % to pass." before the reveal; "Passed!" / "Not this time." outside the well. Decline option = inbox |
| 10 | Labels collide, haze, pop-ups freeze you | partly | Rift unlock speech is a dialogue line (freeze); DoF is the look | Inbox |
| 11 | Maps black, "Where to?" nearly empty | **valid** | The list only named places already walked to, and skipped interactables (Deck Station, Hall of Records) | **Fixed**: lists every named place (revealed or not, up to 16); a pinged place shows its icon and name through the fog |
| 12 | Rewards off-Path | design call | Boss picks follow the Oct 27 availability rules | Inbox |
| 13 | Pack opening doesn't scale (no Open all) | valid, feature | - | Inbox (next) |
| 14 | Deck Station cramped, blank on empty filter | **valid (part)** | No message for zero matches | **Fixed**: "No cards match these filters" note. Racks/rows = inbox |
| 15 | Small collisions | **valid (part)** | Two different rules named "Overgrowth"; feat toast over the reward header | **Fixed**: the Rotheart's rule is "Wild Growth"; toasts wait (hidden, timers paused) while a reward pick is up. Hat placeholders in the reveal cutscene = art (it has no still) |

Fixes are in one commit after this doc; tests `tests/ui/test_midgame_fixes_oct31n.gd` (9).
Also noted: the Gainlands zone effect and the Hall of Final Approvals rule are both named "Processing Time" (never on screen together; left).
