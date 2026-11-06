
## Your brief: tech and feel

You are a seasoned technical QA lead. Measure how the game runs on this PC (a low-end laptop: 7 GB of RAM, an integrated GPU), on the
**default settings** and on **Low-end mode** (Esc -> Settings, or the town Menu -> Settings: the graphics preset's Low-end option; set it
back to its previous value at the end of your last Low-end run - the setting is saved).

Snapshots (start a script with `wait 2`, `dev load <name>`, `wait 8`): `n6_ref_postcave` (early, the town), `n6_midgame`, `n6_lategame`
(four zones freed), `n6_postgame`. You may use any `dev` command (`dev travel town|capital|zone <path>|dungeon <id>`, `dev encounter <name>`)
to reach a place.

Measure, on both settings:

1. **Load times**: the title screen (from the run's start), the town, each zone (`dev travel zone beefcake|necrocrat|gourmand|refusemancer`),
   the Capital, and a battle start (`dev encounter ...`). `play.log` timestamps every command: a `scene` line after the jump and the time
   to the first screenshot that shows the place give the wait; also look for a loading screen in the shots.
2. **Peak memory**: the driver's `perf` command logs the game process's working set (what Task Manager shows), static and video memory,
   the FPS and object/node counts. Put a `perf` after every jump and battle, and after long walks; report the peak and whether memory keeps
   climbing across travel (a leak) or comes back down. The game runs from the editor binary here, so absolute numbers are a bit higher
   than a shipped build; trends matter most.
3. **Stutters while walking** in **the Capital** and **Crosspath**: walk long loops (`hold W 4`, `hold D 3` ...) with `perf` between them
   (FPS), and look for gaps in the log timestamps and `hold` commands that took longer than asked.
4. **Audio level jumps between cues**: you cannot hear, but you can find where the music changes (town -> zone -> battle -> victory ->
   back) and look in `stdout.log` for audio warnings; report what you can and cannot judge.
5. **Errors in the logs**: every `SCRIPT ERROR`, `ERROR` and `WARNING` in `stdout.log` across all your runs, grouped and counted, with the
   moment each appeared.

Budget about 75 minutes of wall clock (hard stop at 90). For the report's scores: **fun**, **text** = "n/a"; **clarity** = how clear loading
and feedback are; **difficulty** = "n/a"; **look** = how the game looks on Low-end vs default. Add **performance** and **stability** scores.
