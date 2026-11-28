# Nov 27 day - the random-play soak (Part A)

Bot: `tools/soak_bot.gd` (+ `soak_bot.sh`, `soak_bot_launcher.*`, `soak_bot_logger.gd`). Run again before release:

    bash tools/soak_bot.sh <seed> [minutes=25] [WxH=1280x720]     # ONLY=<segment> for one segment, TAG=<x> for a second folder

It plays the real game in a window with random but valid choices, in segments: the title (settings, load, credits), a new game, Crosspath
(every spot: people, shops, Auntie Alembic, Pip, the deck station, the Bestiary, the Shuffle House), the zones and the Capital, the
Shuffle House (four modes, the Shuffled Halls, the Puzzle Tables), zone drafts, dungeons with their events, single fights (played at
random, then won or lost by decree so both result screens are seen) and a save -> load round trip. Each step checks script errors
(engine logger with backtraces), softlocks, UI off the screen, overlapping buttons, cut-off text, placeholder art (Godot icon,
"placeholder"/"missing" textures, pure magenta on screen) and saves that come back different. Each folder: `soak.log`, `issues.md`,
`stdout.log`, the first frame of each problem.

**Safety:** it refuses to run unless SaveGuard is on (the wrapper sets WAYWARD_TEST_SAVES=1; since today any `--no-save` run is
protected too) and never presses Copy, Delete, Restore, Start Over, Overwrite, Quit or the window settings.

## Runs

| Folder | Seed | Window | Length | Steps | Script errors | Distinct issues |
|---|---:|---|---:|---:|---:|---:|
| seed101 / 102 / 103 | trials | 1280x720 | 3 min each | 46 / 285 / 194 | 0 | layout finds below; **102 copied a real campaign slot** (see the report) |
| seed1_1280x720 | 1 | 1280x720 | 25 min | 2,181 | 0 | 2 |
| seed2_1920x1080 | 2 | 1920x1080 | 25 min | 1,725 | 1 | 4 |
| seed2_..._trace, _trace2 | 2 | 1920x1080 | 4 min each | 258 / 271 | 1 / **0** (before / after the fix) | 1 / 0 |
| seed3_1280x720 | 3 | 1280x720 | 25 min | 1,896 | 0 | 1 (benign) |
| seed4_1920x1080 | 4 | 1920x1080 | 25 min | 2,001 | 0 | 2 |

About 2 hours of play, 8,800 steps.

## Found and fixed (each with a test in `tests/test_nov27_soak.gd`)

1. **A `--no-save` run could change the player's campaign slots** (Copy / Delete on the title's campaign screen). SaveGuard now protects
   every `--no-save` run.
2. **The battle's gold button ran off the right edge** ("Confirm Blocks (1)  [Space]" grew from x 1640 to 1974). It grows left now.
3. **Long battle banners ran off both sides** ("MIRRORS COPIED COURIER PIGEON" at 92 px). They shrink to fit 1200 px.
4. **The world Menu list's frame was cut at the right edge** in every zone, dungeon and Crosspath. It moves left to keep 12 px.
5. **A save lost a card on its first load** (deck 48 -> 47): the fast-forwarded game (`Session.ensure_game`, used by the tools, bots and
   most tests) went past the copy cap with the trial's sample picks. The real game was not affected (`add_cards` converts the extra).
6. **"Lambda capture at index 0 was freed"** when a fight began while a conversation held an area's title banner (the banner's wait
   timer called back with the freed scene). It holds a weak reference now; the same seed and steps give no error.
7. **Floating battle text off the screen** ("+3 HP (Nourish)" over the opponent's plate started 37 px off the left edge). Clamped.

## Looked at, not bugs

- The duel "never finished" (seed 2): the opponent-card pop-up waited for a click (the bot had set Opponent cards to "Wait for click").
- First-load flag migrations (own Path, Maren's direction, the story beats), the town banner's "seen" flag after a load, and the tracker
  following the zone's main line after resuming in a zone: by design.
- A hand card's labels below the bottom edge (cards peek over it by design); the Load page over the pause menu (stacked, not overlapping).

## Not fixed (minor, listed)

- A battle rule tooltip stays over the defeat panel while the pointer rests where the rule badge was (seed 2, `offscreen_02_shuffle.jpg`):
  it goes when the pointer moves.
- A label 50 px below the bottom-left corner during a Puzzle Table result (seed 2): not visible, not identified.
- No placeholder art and no magenta seen in ~8,800 steps.
