OVERNIGHT - Oct 23. Target 9 hours. I'm asleep: work autonomously, take the safest choice, log questions in docs/overnight_inbox.md, never block. `date` at start and per part; stop by 9 hours. Tag pre-overnight-oct23. Keep docs/overnight/loop_state.md current so you can resume after a reset or a dropped connection. Read CLAUDE.md, docs/overnight_report.md, docs/design/ai_state.md, data/encounters/modifiers.json, core/data/enemy_decks.gd, docs/design/story_bible.md and balance_state.md first.

RULES: STOP_OVERNIGHT check per part/cycle; one Godot process at a time, foreground, close between runs, max 10-12 screenshots per part; sims modest (7.4 GB RAM); GUT + walkability + relevant smokes + commit + push per part, revert what can't pass; old saves keep loading; enemy intent stays HIDDEN (rules and scripted events are announced, the AI's next move is not); balance philosophy: PvE - fights should be fun and memorable, the opening hour easy and enjoyable for every Path, no walls (nothing under ~35% at its intended level), bosses a real challenge; tune encounters before cards; log number changes in balance_log.md + sheet_changes.md; dialogue to the voice bible standard; no new art generation; don't touch the black market vendors; don't export a build tonight.

PART 1 - Boss and elite scripting (every boss and elite gets a memorable identity)
- Extend the encounter system with mid-fight triggers: at HP thresholds (e.g. 50% / 25%), on a given turn, when a condition is met (a unit dies, the player has N units, etc.). Effects: phase change (new one-sided rule replaces/adds to the old), signature card played or shuffled in, reinforcements (tokens or a named unit enter), arena event (e.g. Clench's power goes out, the Doppelganger's mask slips, Mortimer files a Form, Compostella's roots spread), a short boss line, heal/shield once.
- Telegraphing: every trigger is listed under the encounter's rule icons from the start (what can happen, not exactly when the AI acts), and a one-line warning appears the turn before a timed event fires. The AI uses its signatures with these.
- Give every main-dungeon boss, side-dungeon boss, lieutenant, gatekeeper, the arena champions and every elite at least one scripted trigger that fits its story and Path (bosses 2-3). Keep the tutorial boss gentle. Define them in data (modifiers.json or a new encounter_scripts.json), not hard-coded per fight where avoidable.
- Sim each at its intended level with the new AI (two seeds), within the philosophy above. Replay a few by eye. Tests for the trigger system (threshold, turn, condition, warning).

PART 2 - Dual-Path enemies before the Capital
- Today multi-Path enemy decks appear only from the Capital onward (plus Shiro, the Vault, the Echo, the arena). Players can build two-Path decks after freeing their first zone, so show them good two-Path play earlier: use the unused pairings (Gourmand+Beefcake, Gourmand+Refusemancer, Beefcake+Refusemancer) and the others where they fit the story - e.g. late elites in the main dungeons that sit between two Paths' lore, freed-zone challenge fights, a few side-dungeon foes and the Old Service Tunnels. Each dual-Path deck should demonstrate a clear synergy the player could copy (the AI profile blends both Paths). Story-appropriate names and short lines. Keep the first zone visit single-Path. Sim at intended levels.

PART 3 - Boss entrances
- Before each boss/lieutenant/gatekeeper battle: a short skippable intro - camera push or framing on the boss in the world (or a stylised board intro in dungeons), a name card with title ("Chancellor Clench - Iron Regent"), a music sting, and the boss's opening line. Under ~4 seconds, skippable with any key, consistent style. Screenshots.

PART 4 - Rewards after elites and bosses
- After an elite or boss win, offer a choice of 1 card from 3, themed to the encounter's Paths and the player's progress (respecting copy caps; extra copies convert as usual). Each boss keeps its guaranteed unique reward; re-fighting already-cleared encounters gives smaller rewards. Check the economy audit still looks healthy.

PART 5 - Keyword and status help in battle
- Hovering any keyword, status (e.g. Red Tape's -2/-0 with turns left, exhausted, buffs), encounter rule icon, token or trap shows a plain-language explanation in the top-layer tooltip box. Add a Glossary page in the pause menu (keywords, resources, statuses, card types, rule icons). First-time tips for traps as face-down cards, tokens as cards, encounter rules and the new scripted events.

PART 6 - Multiple save slots
- Three save slots on the title screen (New Game picks a slot; Continue loads the most recent), each showing Path, level, area, play time and last played; copy/delete with confirmation. Migrate the existing save into slot 1. Report a Problem includes the active slot's save. Crash-safe save + backup per slot as now.

PHASE 2 - IMPROVEMENT LOOP (until 9 hours)
- Scorecard cycles as before (re-score first; lowest category; never the same category three times in a row; verify; commit or revert; log). Prefer first-hour clarity and fun, boss-fight feel, and anything Parts 1-6 found but didn't finish. Every 4 cycles run the tour bot and story bot and fix regressions first.

MORNING REPORT: docs/overnight_report.md - by part with commits, a table of every boss/elite's scripted triggers, the new dual-Path encounters, balance before/after, how to test each item, inbox items. Final commit + push.
