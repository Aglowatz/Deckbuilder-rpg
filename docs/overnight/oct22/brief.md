# Overnight brief - Oct 22 2026 (copy)

OVERNIGHT - Oct 22. Target 9 hours. Asleep: work autonomously, take the safest choice, log questions in docs/overnight_inbox.md, never
block. `date` at start and per part; stop by 9 hours. Tag pre-overnight-oct22. Keep docs/overnight/loop_state.md current.

RULES: STOP_OVERNIGHT check per part/cycle; one Godot process at a time, foreground, close between runs, max 10-12 screenshots per part;
GUT + walkability + relevant smokes + commit + push per part, revert what can't pass; old saves keep loading; number changes backed by
the sim (two seeds) and logged in balance_log.md + sheet_changes.md; dialogue to the voice bible standard; no new art generation
(ChatGPT is still making 26 images - don't touch Pending Review); no enemy intent; don't touch the black market vendors.

PART 1 - Whole-game balance re-measure (after this week's changes: ~15 Colorless commons in each starter deck, Sable's smaller sample
stock, zone vendor stocks gated by zone bosses, the lieutenants, the Paste Works, Elowen's arc + T-24, the Old Well Echo).
- Full catalog sim at each encounter's intended level, using the deck a player can realistically own at that point under the NEW shop
  availability (update the progression model / reference decks). Tutorial runs 50 per Path. Targets as in balance_state.md. Fix the
  biggest outliers (prefer encounter tweaks over card nerfs), re-run, up to 4 iterations. Before/after table in balance_log.md.

PART 2 - Dialogue features that need code (inbox Oct 19-20 item 10)
- Gatekeepers get freed-zone lines; split the long first talks (7-9 boxes: Agnes, Bramble, Gerald, Wren, Ledgerbone, Chet, Flambe) into
  intro now + quest offer on the next talk or a natural split; Maren plays her four boxes once, then a short rotating greeting that
  reacts to progress; Agnes doesn't say "Oh, you're new" in the Hall after the front desk; freed variants for worker barks, Kyle,
  Ectomund, the Capital's showcase citizens and Isla; the Primm fight only quotes the leaders whose zones are actually freed. Story
  playthrough bot + quest smoke must pass.

PART 3 - Path choice screen
- Each Path tile shows a one-line game plan and its icon/art; the full identity paragraph appears on hover/focus (and a "More" toggle
  for keyboard/controller). The screen reads in under ~20 seconds. Screenshot before/after.

PART 4 - Duplicate names
- Wren (resistance leader) vs Wren Muckfoot (Dump animal handler); Recycle Rhonda vs a Gainlands ripper Rhonda. Keep the design-sheet
  characters; give the game-only two new, funny, unique names that fit zone and voice; update every reference (dialogue, npcs.json,
  registry, quests, story bible, canon, sheet_changes.md). Log the new names first thing in the inbox for veto.

PART 5 - Stability on the exported build
- Export a test build; run the opening hour, the tour bot and the story playthrough on it with d3d12 and Vulkan, on Medium, Low and
  Safe Mode. Check hats/cloaks in the wardrobe and walking in every zone, the disguised Rescuer, new maps/boards, the Deck Station at
  1280x720 and 1920x1080, card crops in battle, the lieutenant and Paste Works fights, Elowen's Lab arc. Fix crashes, softlocks, stalls
  over ~200 ms after a fade-in, visual breaks. Memory after a full tour must stay sane.

PART 6 - Release candidate v0.4.5 (don't share)
- Bump to 0.4.5, export (shader baker, launchers, README_PLAYTEST.txt), release smoke on the exported build, zip as
  builds/TheWaywardPath-v0.4.5-windows.zip, docs/release/v0.4.5_notes.md (player-facing changes since v0.4.4). Commit, push, tag v0.4.5.

PHASE 2 - IMPROVEMENT LOOP (until 9 hours): scorecard cycles (re-score first; lowest category; never the same category three times in a
row; verify; commit or revert; log). Prefer first-hour clarity, cheap Tier 2 visual polish (docs/art/graphics_tier1.md), and Part 5
leftovers. If the zip changes, rebuild v0.4.5 at the end.

MORNING REPORT: docs/overnight_report.md - by part with commits, balance before/after, new names for veto, how to test, zip path/size,
inbox items. Final commit + push.
