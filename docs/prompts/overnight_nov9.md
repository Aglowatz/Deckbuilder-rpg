# Overnight Nov 9 (Fable) — full playthroughs, game feel, finish Dex, release basics

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The 1.0 target is a free itch.io release this week. The owner is asleep.
Read docs/overnight_report.md (Overnight Nov 8-9) first. Work autonomously; log questions in docs/overnight_inbox.md under
"Overnight Nov 9". Tag `pre-overnight-nov9` at the start.

## House rules
- STOP_OVERNIGHT check before each part.
- Claude Code's background low-memory reaper is disabled for this run, so YOU must keep memory safe:
  - ONE Godot process at a time; kill strays before each job;
  - no sub-agents while Godot runs;
  - watch free memory, and if it drops under ~800 MB, stop that job cleanly and move on.
- Tests: memory-safe shards (`bash tools/run_tests.sh --only=tests --size=12`, `--from=N`).
- Play via `bash tools/play.sh` from a hard-linked HEAD worktree. Screenshots go to docs/overnight_shots/nov9b/.
- Commit and push after each part. **No export.**
- Don't replace art files (Batch 14 comes from the owner).

## Part 1 — The four real-fight playthroughs (last night's unfinished item, top priority)
- For each Path, one at a time: Beefcake, Necrocrat, Gourmand, Refusemancer.
  - The play bot plays from a new save to the credits and into the postgame, with **real fights**: no decreed or auto wins.
  - Save and load at each zone change.
  - Dev help only for walking stalls, and log each one.
- If a run loses a fight, it respawns per the rules and keeps going; note every loss, with the encounter, deck and level.
- Fix every blocker or softlock found and re-run from that point.
- **Report per Path:**
  - completed (yes/no);
  - hours of game time;
  - fights lost and where;
  - gold earned against the 21.3k target;
  - any difficulty walls a normal deck can't pass.

## Part 2 — Game feel and polish (closing the gap to "AA indie")
Code, shaders, particles and existing audio only.
1. **Battle impact:**
   - Card plays: lift, travel, land, with a small dust or flash.
   - Attacks: a lunge, hit-stop of a few frames, a small screen shake on big hits, floating damage numbers.
   - Unit death: a dissolve or burst in the Path colour.
   - Healing and buffs: a coloured glow and pop.
   - Make the turn banner and the phase changes snappy.
   - Respect a "Reduce motion" setting (add it).
2. **Sound coverage:**
   - Every common action has a sound from the existing SFX set: card hover, play and draw, attack, hit, block, death, buff, heal, gold, button, menu open/close, quest update, level up, pack open, map pin.
   - List and fill the gaps with existing sounds.
   - Even out loudness so no sound jumps out over the music.
3. **Transitions:** consistent fades between town, zone, battle and menus. No hard cuts or flashes of grey or empty frames. The loading card appears only when needed.
4. **UI consistency sweep:**
   - Every screen uses the same panel frames, header style, button styles, focus ring, spacing and font sizes as the Deck Station and Character page.
   - Fix strays: old-style buttons, mismatched fonts, overflow, misaligned rows.
   - Screenshot each screen before and after.
5. **Mix:** set the music, SFX and UI defaults to a balanced mix, and make sure ducking under dialogue and stings works.

## Part 3 — Finish Dex's matching game for 1.0 (his art is now in)
Play the whole Cardsharp's Circuit in all four zones:
- the rules are clear;
- the scoring feels fair;
- feedback flourishes play;
- the questline flows;
- the reward (Dex's Matching Pair) is granted and works.

Polish it to the Deck Station bar. If something can't be made solid tonight, say what's left and recommend whether to hide it.

## Part 4 — Release basics left
- An auto-save indicator (a small spinning quill or a "Saving..." corner icon).
- **Colour-blind Path symbols:** add the setting, defaulting **on** (it helps everyone tell the Paths apart). Log it so the owner can flip the default.
- Set the version to **1.0.0-rc1** (title screen, the log header, the about box).
- Re-capture the itch screenshots at true 1920x1080 if the window allows (otherwise leave last night's).
- Check data/credits/credits.cfg: leave the owner's name and the donation link empty for him, with clear comments showing where they go.

## Part 5 — Final read of the main story
One careful read of the main quest from start to credits, in game order, in the current dialogue data. Fix:
- confusing lines;
- clipped "short statement" sentences;
- jokes that don't land;
- continuity slips;
- anything that no longer matches the game (quest steps, names, the new tutorials).

Keep the voices in docs/dialogue/story_voice_nov5.md. Use a revertible dialogue pass, and re-export docs/dialogue/edit_nov9.csv.

## Finish
- All test shards green.
- docs/overnight_report.md with, at the top:
  - the playthrough table;
  - blockers fixed and still open;
  - the feel changes, with before/after screenshots and the list of sound gaps filled;
  - Dex's status;
  - the release items done;
  - the story read summary;
  - an updated plan for Nov 9-11.
- Commit and push. No export.
