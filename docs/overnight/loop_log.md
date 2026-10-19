# Overnight Oct 18 - loop log

One line per Phase 2 cycle: cycle, category, change, score before -> after, commit. Last night's: `docs/overnight/oct17/loop_log.md`.

| Cycle | Category | Change | Score | Commit |
|---|---|---|---|---|
| 1 | Balance | The two early walls whose HP never mattered lost their head start: Colonel Casserole opens with a 1/1 Weenie instead of a 3/3 Golem (42% -> 73%, in band), Prudence with 1 Red Tape instead of 2 (38% -> 53%). Before choosing, the Performance drop was checked: steady town 60.1 fps (p95 16.7 ms); the bot slow frames are spread over first menu opens (2-5 each; the bot now reports them per action), so no single regression. | 5 -> 5.5 | (this commit) |
| 2 | Balance | Stat rules for the too-easy late fights: the Castle's Mirror Knight 79 -> 75%, Royal Guard 83 -> 54%, Clocktower 88 -> 58%; the Lab's Failed Experiment 96 -> 75%, Drain Warden 92 -> 83%; Betty 71 -> 63%; Bellows 88 -> 71%. The Hall's two bumps overshot (46% / 29%) and were reverted. Spotter, Spotless, Shiro, the Automaton do not respond to stat rules. | 5.5 -> 6 | (this commit) |
| 3 | Performance | Glyphs warm before the first menu: the UI fonts rasterize per size and outline (no MSDF), so a screen showing a new size drew dozens of glyphs on its first frame. UiArtWarmup now draws a 3-px clipped, nearly invisible label through the menus' 18 common sizes (body, bold, title plain / outline 6 / 8), one per frame (~1.5 s, starting 2 s after an area loads). Town bot (two runs each): frames over 33 ms 77-82 -> 43-45, worst 193-210 -> 134-143 ms (character screen), deck 175 -> 121-137, vendor 166-192 -> 107-124. | 7.5 -> 8 | (this commit) |
| 4 | Balance | Epics for the late bosses that ignored stat rules: the Spotter 92 -> 79%, Shiro 88 -> 83%; Spotless and the Vault Automaton unchanged (92% / 71%). Partial: these need a design call (inbox). | 6 -> 6 | (this commit) |
